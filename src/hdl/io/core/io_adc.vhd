-- -------------------------------------------------------------------------------------------------------------
--                              Copyright (C) 2022-2030 Ken-ji de la Rosa, IRAP Toulouse.
-- -------------------------------------------------------------------------------------------------------------
--                              This file is part of the ATHENA X-IFU DRE Focal Plane Assembly simulator.
--
--                              fpasim-fw is free software: you can redistribute it and/or modify
--                              it under the terms of the GNU General Public License as published by
--                              the Free Software Foundation, either version 3 of the License, or
--                              (at your option) any later version.
--
--                              This program is distributed in the hope that it will be useful,
--                              but WITHOUT ANY WARRANTY; without even the implied warranty of
--                              MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--                              GNU General Public License for more details.
--
--                              You should have received a copy of the GNU General Public License
--                              along with this program.  If not, see <https://www.gnu.org/licenses/>.
-- -------------------------------------------------------------------------------------------------------------
--    email                   kenji.delarosa@alten.com
--    @file                   io_adc.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details                
--
--    This module does the following steps:
--         . deserializes data on ADC IOs from @i_adc_clk to @o_adc_clk_div.
--         . pass data word from @o_adc_clk_div to the @sys_clk (async FIFO).
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.pkg_io.all;

entity io_adc is
  generic(
    g_ADC_A_WIDTH : positive := 7;  -- adc bus width (expressed in bits).Possible values [1;max integer value[
    g_ADC_B_WIDTH : positive := 7  -- adc bus width (expressed in bits).Possible values [1;max integer value[
    );
  port(
    ---------------------------------------------------------------------
    -- input
    ---------------------------------------------------------------------
    -- input
    i_adc_clk_p : in std_logic;         -- clock
    i_adc_clk_n : in std_logic;         -- clock
    -- i_adc_a
    i_adc_a_p   : in std_logic_vector(g_ADC_A_WIDTH - 1 downto 0);  -- adc_a differential p input
    i_adc_a_n   : in std_logic_vector(g_ADC_A_WIDTH - 1 downto 0);  -- adc_a differential n input

    -- i_adc_b
    i_adc_b_p : in std_logic_vector(g_ADC_B_WIDTH - 1 downto 0);  -- adc_b differential p input
    i_adc_b_n : in std_logic_vector(g_ADC_B_WIDTH - 1 downto 0);  -- adc_b differential n input

    -- from reset_top: @o_adc_clk_div
    i_io_clk_rst  : in  std_logic;      -- small reset pulse width
    i_io_rst      : in  std_logic;      -- large reset pulse width
    o_adc_clk_div : out std_logic;  -- divided clock ( after IO DDR deserializing: 1-> 8 ) @i_clk_p/(8/2) = @i_clk_p/4
    ---------------------------------------------------------------------
    -- output @i_out_clk
    ---------------------------------------------------------------------
    i_out_clk     : in  std_logic;  -- output clock (at the read async fifo side)
    i_rst_status  : in  std_logic;      -- reset error flag(s)
    i_debug_pulse : in  std_logic;  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
    -- data
    o_adc_valid   : out std_logic;      -- adc data valid
    o_adc_a       : out std_logic_vector(g_ADC_A_WIDTH * 2 - 1 downto 0);  -- adc_a data
    o_adc_b       : out std_logic_vector(g_ADC_B_WIDTH * 2 - 1 downto 0);  -- adc_b data

    ---------------------------------------------------------------------
    -- errors/status: @i_out_clk
    ---------------------------------------------------------------------
    o_errors : out std_logic_vector(15 downto 0);  -- output errors
    o_status : out std_logic_vector(7 downto 0)    -- output status
    );
end entity io_adc;

architecture RTL of io_adc is

  constant c_INPUT_LATENCY     : natural := pkg_IO_ADC_IN_LATENCY;
  constant c_FIFO_CDC_LATENCY  : natural := pkg_IO_ADC_FIFO_CDC_STAGE;
  constant c_FIFO_READ_LATENCY : natural := pkg_IO_ADC_FIFO_READ_LATENCY;
  constant c_ADC_A_WIDTH       : natural := 56;
  constant c_ADC_B_WIDTH       : natural := 56;
  ---------------------------------------------------------------------
  -- ouput FIFO
  ---------------------------------------------------------------------
  constant c_WR_FIFO_DEPTH     : integer := 1024;
  -- adc_a
  constant c_ADC_A_WR_IDX0_L   : integer := 0;
  constant c_ADC_A_WR_IDX0_H   : integer := c_ADC_A_WR_IDX0_L + c_ADC_A_WIDTH - 1;

  constant c_ADC_A_RD_IDX0_L : integer := 0;
  constant c_ADC_A_RD_IDX0_H : integer := c_ADC_A_RD_IDX0_L + o_adc_a'length - 1;

  constant c_ADC_A_WR_FIFO_WIDTH : integer := c_ADC_A_WR_IDX0_H + 1;
  constant c_ADC_A_RD_FIFO_WIDTH : integer := c_ADC_A_RD_IDX0_H + 1;

  -- adc_a
  constant c_ADC_B_WR_IDX0_L : integer := 0;
  constant c_ADC_B_WR_IDX0_H : integer := c_ADC_B_WR_IDX0_L + c_ADC_B_WIDTH - 1;

  constant c_ADC_B_RD_IDX0_L : integer := 0;
  constant c_ADC_B_RD_IDX0_H : integer := c_ADC_B_RD_IDX0_L + o_adc_b'length - 1;

  constant c_ADC_B_WR_FIFO_WIDTH : integer := c_ADC_B_WR_IDX0_H + 1;
  constant c_ADC_B_RD_FIFO_WIDTH : integer := c_ADC_B_RD_IDX0_H + 1;
  ---------------------------------------------------------------------
  -- io_adc_single
  ---------------------------------------------------------------------
  signal adc_a                   : std_logic_vector(c_ADC_A_WR_IDX0_H downto 0);
  signal adc_b                   : std_logic_vector(c_ADC_B_WR_IDX0_H downto 0);
  signal adc_clk_div             : std_logic;

  ---------------------------------------------------------------------
  -- FIFO
  ---------------------------------------------------------------------
  -- adc_a
  signal adc_a_wr_rst_tmp0  : std_logic;
  signal adc_a_wr_tmp0      : std_logic;
  signal adc_a_data_tmp0    : std_logic_vector(c_ADC_A_WR_FIFO_WIDTH - 1 downto 0);
  --signal adc_a_full0        : std_logic;
  signal adc_a_wr_rst_busy0 : std_logic;

  signal adc_a_rd1          : std_logic;
  signal adc_a_data_tmp1    : std_logic_vector(c_ADC_A_RD_FIFO_WIDTH - 1 downto 0);
  signal adc_a_empty1       : std_logic;
  signal adc_a_rd_rst_busy1 : std_logic;

  signal adc_a_data_valid_tmp1 : std_logic;

  signal adc_a_errors_sync1 : std_logic_vector(3 downto 0);
  signal adc_a_empty_sync1  : std_logic;

  -- adc_b
  signal adc_b_wr_rst_tmp0  : std_logic;
  signal adc_b_wr_tmp0      : std_logic;
  signal adc_b_data_tmp0    : std_logic_vector(c_ADC_B_WR_FIFO_WIDTH - 1 downto 0);
  --signal adc_b_full0        : std_logic;
  signal adc_b_wr_rst_busy0 : std_logic;  -- @suppress "signal adc_b_wr_rst_busy0 is never read"

  signal adc_b_rd1          : std_logic;
  signal adc_b_data_tmp1    : std_logic_vector(c_ADC_B_RD_FIFO_WIDTH - 1 downto 0);
  signal adc_b_empty1       : std_logic;
  signal adc_b_rd_rst_busy1 : std_logic;

  signal adc_b_data_valid_tmp1 : std_logic;  -- @suppress "signal adc_b_data_valid_tmp1 is never read"

  signal adc_b_errors_sync1 : std_logic_vector(3 downto 0);
  signal adc_b_empty_sync1  : std_logic;

  signal adc_b_tmp1 : std_logic_vector(o_adc_b'range);
  signal adc_a_tmp1 : std_logic_vector(o_adc_a'range);

  ---------------------------------------------------------------------
  -- error latching
  ---------------------------------------------------------------------
  constant NB_ERRORS_c : integer := 6;
  signal error_tmp     : std_logic_vector(NB_ERRORS_c - 1 downto 0);
  signal error_tmp_bis : std_logic_vector(NB_ERRORS_c - 1 downto 0);

begin

---------------------------------------------------------------------
-- io_adc_single
---------------------------------------------------------------------
  inst_io_adc_single : entity work.io_adc_single
    generic map(
      g_INPUT_LATENCY => c_INPUT_LATENCY  -- add latency after the input IO. Possible values: [0; max integer value[
      )
    port map(
      -- from reset_top: @i_clk
      i_io_rst      => i_io_rst,
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_adc_clk_p   => i_adc_clk_p,     -- clock
      i_adc_clk_n   => i_adc_clk_n,     -- clock
      i_adc_a_p     => i_adc_a_p,  -- Diff_p buffer input -- @suppress "Incorrect array size in assignment: expected (<7>) but was (<g_ADC_A_WIDTH>)"
      i_adc_a_n     => i_adc_a_n,  -- Diff_n buffer input -- @suppress "Incorrect array size in assignment: expected (<7>) but was (<g_ADC_A_WIDTH>)"
      i_adc_b_p     => i_adc_b_p,  -- Diff_p buffer input -- @suppress "Incorrect array size in assignment: expected (<7>) but was (<g_ADC_B_WIDTH>)"
      i_adc_b_n     => i_adc_b_n,  -- Diff_n buffer input -- @suppress "Incorrect array size in assignment: expected (<7>) but was (<g_ADC_B_WIDTH>)"
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_adc_clk_div => adc_clk_div,
      o_adc_a       => adc_a,
      o_adc_b       => adc_b
      );

  o_adc_clk_div <= adc_clk_div;

---------------------------------------------------------------------
-- clock domain crossing
---------------------------------------------------------------------
  -- adc_a
  adc_a_wr_rst_tmp0 <= i_io_clk_rst;
  adc_a_wr_tmp0     <= '1' when (i_io_rst = '0' and adc_a_wr_rst_busy0 = '0') else '0';

  adc_a_data_tmp0(c_ADC_A_WR_IDX0_H downto c_ADC_A_WR_IDX0_L) <= adc_a;

  inst_fifo_async_with_error_adc_a : entity work.fifo_async_with_error
    generic map(
      g_CDC_SYNC_STAGES   => c_FIFO_CDC_LATENCY,
      g_FIFO_MEMORY_TYPE  => "auto",
      g_FIFO_READ_LATENCY => c_FIFO_READ_LATENCY,
      g_FIFO_WRITE_DEPTH  => c_WR_FIFO_DEPTH,
      g_READ_DATA_WIDTH   => adc_a_data_tmp1'length,
      g_READ_MODE         => "std",
      g_RELATED_CLOCKS    => 0,
      g_WRITE_DATA_WIDTH  => adc_a_data_tmp0'length,
      ---------------------------------------------------------------------
      -- resynchronization: fifo errors/empty flag
      ---------------------------------------------------------------------
      g_SYNC_SIDE         => "rd"  -- define the clock side where status/errors is resynchronised. Possible value "wr" or "rd"
      )
    port map(
      ---------------------------------------------------------------------
      -- write side
      ---------------------------------------------------------------------
      i_wr_clk        => adc_clk_div,
      i_wr_rst        => adc_a_wr_rst_tmp0,
      i_wr_en         => adc_a_wr_tmp0,
      i_wr_din        => adc_a_data_tmp0,
      o_wr_full       => open,          -- not connected
      o_wr_rst_busy   => adc_a_wr_rst_busy0,
      ---------------------------------------------------------------------
      -- read side
      ---------------------------------------------------------------------
      i_rd_clk        => i_out_clk,
      i_rd_en         => adc_a_rd1,
      o_rd_dout_valid => adc_a_data_valid_tmp1,
      o_rd_dout       => adc_a_data_tmp1,
      o_rd_empty      => adc_a_empty1,
      o_rd_rst_busy   => adc_a_rd_rst_busy1,  -- not connected
      ---------------------------------------------------------------------
      -- resynchronized errors/status 
      ---------------------------------------------------------------------
      o_errors_sync   => adc_a_errors_sync1,
      o_empty_sync    => adc_a_empty_sync1
      );

  -- adc_a and adc_b fifos are read at the same time.
  adc_a_rd1  <= '1' when adc_a_empty1 = '0' and adc_b_empty1 = '0' and adc_a_rd_rst_busy1 = '0' and adc_b_rd_rst_busy1 = '0' else '0';
  adc_a_tmp1 <= adc_a_data_tmp1(c_ADC_A_RD_IDX0_H downto c_ADC_A_RD_IDX0_L);

  -- adc_b
  adc_b_wr_rst_tmp0                                           <= i_io_clk_rst;
  adc_b_wr_tmp0                                               <= '1' when (i_io_rst = '0' and adc_a_wr_rst_busy0 = '0') else '0';
  adc_b_data_tmp0(c_ADC_B_WR_IDX0_H downto c_ADC_B_WR_IDX0_L) <= adc_b;

  inst_fifo_async_with_error_adc_b : entity work.fifo_async_with_error
    generic map(
      g_CDC_SYNC_STAGES   => c_FIFO_CDC_LATENCY,
      g_FIFO_MEMORY_TYPE  => "auto",
      g_FIFO_READ_LATENCY => c_FIFO_READ_LATENCY,
      g_FIFO_WRITE_DEPTH  => c_WR_FIFO_DEPTH,
      g_READ_DATA_WIDTH   => adc_b_data_tmp1'length,
      g_READ_MODE         => "std",
      g_RELATED_CLOCKS    => 0,
      g_WRITE_DATA_WIDTH  => adc_b_data_tmp0'length,
      ---------------------------------------------------------------------
      -- resynchronization: fifo errors/empty flag
      ---------------------------------------------------------------------
      g_SYNC_SIDE         => "rd"  -- define the clock side where status/errors is resynchronised. Possible value "wr" or "rd"
      )
    port map(
      ---------------------------------------------------------------------
      -- write side
      ---------------------------------------------------------------------
      i_wr_clk        => adc_clk_div,
      i_wr_rst        => adc_b_wr_rst_tmp0,
      i_wr_en         => adc_b_wr_tmp0,
      i_wr_din        => adc_b_data_tmp0,
      o_wr_full       => open,          -- not connected
      o_wr_rst_busy   => adc_b_wr_rst_busy0,
      ---------------------------------------------------------------------
      -- read side
      ---------------------------------------------------------------------
      i_rd_clk        => i_out_clk,
      i_rd_en         => adc_b_rd1,
      o_rd_dout_valid => adc_b_data_valid_tmp1,  -- not connected
      o_rd_dout       => adc_b_data_tmp1,
      o_rd_empty      => adc_b_empty1,
      o_rd_rst_busy   => adc_b_rd_rst_busy1,     -- not connected
      ---------------------------------------------------------------------
      -- resynchronized errors/status 
      ---------------------------------------------------------------------
      o_errors_sync   => adc_b_errors_sync1,
      o_empty_sync    => adc_b_empty_sync1
      );

  adc_b_rd1  <= adc_a_rd1;
  adc_b_tmp1 <= adc_b_data_tmp1(c_ADC_B_RD_IDX0_H downto c_ADC_B_RD_IDX0_L);

---------------------------------------------------------------------
-- output
---------------------------------------------------------------------
  o_adc_valid <= adc_a_data_valid_tmp1;
  o_adc_a     <= adc_a_tmp1;
  o_adc_b     <= adc_b_tmp1;

  ---------------------------------------------------------------------
  -- Error latching
  ---------------------------------------------------------------------
  error_tmp(5) <= adc_b_errors_sync1(2) or adc_b_errors_sync1(3);  -- fifo rst error
  error_tmp(4) <= adc_b_errors_sync1(1);  -- fifo rd empty error
  error_tmp(3) <= adc_b_errors_sync1(0);  -- fifo wr full error
  error_tmp(2) <= adc_a_errors_sync1(2) or adc_a_errors_sync1(3);  -- fifo rst error
  error_tmp(1) <= adc_a_errors_sync1(1);  -- fifo rd empty error
  error_tmp(0) <= adc_a_errors_sync1(0);  -- fifo wr full error
  gen_errors_latch : for i in error_tmp'range generate
    inst_one_error_latch : entity work.one_error_latch
      port map(
        i_clk         => i_out_clk,
        i_rst         => i_rst_status,
        i_debug_pulse => i_debug_pulse,
        i_error       => error_tmp(i),
        o_error       => error_tmp_bis(i)
        );
  end generate gen_errors_latch;

  o_errors(15 downto 7) <= (others => '0');
  o_errors(6)           <= error_tmp_bis(5);  -- fifo rst error
  o_errors(5)           <= error_tmp_bis(4);  -- fifo rd empty error
  o_errors(4)           <= error_tmp_bis(3);  -- fifo wr full error
  o_errors(3)           <= '0';               -- 
  o_errors(2)           <= error_tmp_bis(2);  -- fifo rst error
  o_errors(1)           <= error_tmp_bis(1);  -- fifo rd empty error
  o_errors(0)           <= error_tmp_bis(0);  -- fifo wr full error

  o_status(7 downto 2) <= (others => '0');
  o_status(1)          <= adc_b_empty_sync1;
  o_status(0)          <= adc_a_empty_sync1;

  ---------------------------------------------------------------------
  -- for simulation only
  ---------------------------------------------------------------------
  assert not (error_tmp_bis(5) = '1') report "[io_adc] => FIFO is used before the end of the initialization " severity error;
  assert not (error_tmp_bis(4) = '1') report "[io_adc] => FIFO read an empty FIFO" severity error;
  assert not (error_tmp_bis(3) = '1') report "[io_adc] => FIFO write a full FIFO" severity error;
  assert not (error_tmp_bis(2) = '1') report "[io_adc] => FIFO is used before the end of the initialization " severity error;
  assert not (error_tmp_bis(1) = '1') report "[io_adc] => FIFO read an empty FIFO" severity error;
  assert not (error_tmp_bis(0) = '1') report "[io_adc] => FIFO write a full FIFO" severity error;

end architecture RTL;
