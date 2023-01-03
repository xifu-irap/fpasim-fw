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
--    This module generates fpga specific IO component
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity io_adc is
  generic(
    g_ADC_A_WIDTH   : positive := 7;  -- adc bus width (expressed in bits).Possible values [1;max integer value[
    g_ADC_B_WIDTH   : positive := 7;  -- adc bus width (expressed in bits).Possible values [1;max integer value[
    g_INPUT_LATENCY : natural  := 0  -- add latency after the input IO. Possible values: [0; max integer value[
    );
  port(
    ---------------------------------------------------------------------
    -- input
    ---------------------------------------------------------------------
    -- input
    i_clk        : in std_logic;        -- clock
    -- from reset_top: @i_clk
    i_io_clk_rst : in std_logic;  -- Clock reset: Reset connected to clocking elements in the circuit
    i_io_rst     : in std_logic;  -- Reset connected to all other elements in the circuit (longer duration than io_clk_rst)
    -- i_adc_a
    i_adc_a_p    : in std_logic_vector(g_ADC_A_WIDTH - 1 downto 0);  -- Diff_p buffer input
    i_adc_a_n    : in std_logic_vector(g_ADC_A_WIDTH - 1 downto 0);  -- Diff_n buffer input

    -- i_adc_b
    i_adc_b_p : in std_logic_vector(g_ADC_B_WIDTH - 1 downto 0);  -- Diff_p buffer input
    i_adc_b_n : in std_logic_vector(g_ADC_B_WIDTH - 1 downto 0);  -- Diff_n buffer input

    ---------------------------------------------------------------------
    -- output @i_out_clk
    ---------------------------------------------------------------------
    i_out_clk     : in  std_logic;
    i_rst_status  : in  std_logic;
    i_debug_pulse : in  std_logic;
    -- data
    o_adc_valid   : out std_logic;
    o_adc_a       : out std_logic_vector(g_ADC_A_WIDTH * 2 - 1 downto 0);
    o_adc_b       : out std_logic_vector(g_ADC_B_WIDTH * 2 - 1 downto 0);

    ---------------------------------------------------------------------
    -- errors/status: @i_out_clk
    ---------------------------------------------------------------------
    o_errors : out std_logic_vector(15 downto 0);
    o_status : out std_logic_vector(7 downto 0)
    );
end entity io_adc;

architecture RTL of io_adc is

  constant c_FIFO_READ_LATENCY : natural := work.pkg_fpasim.pkg_IO_ADC_FIFO_READ_LATENCY;
  ---------------------------------------------------------------------
  -- ouput FIFO
  ---------------------------------------------------------------------
  constant c_IDX0_L            : integer := 0;
  constant c_IDX0_H            : integer := c_IDX0_L + o_adc_a'length - 1;

  constant c_IDX1_L : integer := c_IDX0_H + 1;
  constant c_IDX1_H : integer := c_IDX1_L + o_adc_b'length - 1;

  constant c_FIFO_DEPTH : integer := 16;            --see IP
  constant c_FIFO_WIDTH : integer := c_IDX1_H + 1;  --see IP
  ---------------------------------------------------------------------
  -- io_adc_single
  ---------------------------------------------------------------------
  signal adc_a          : std_logic_vector(o_adc_a'range);
  signal adc_b          : std_logic_vector(o_adc_b'range);

  ---------------------------------------------------------------------
  -- FIFO
  ---------------------------------------------------------------------

  signal wr_rst_tmp0  : std_logic;
  signal wr_tmp0      : std_logic;
  signal data_tmp0    : std_logic_vector(c_FIFO_WIDTH - 1 downto 0);
  --signal full0        : std_logic;
  signal wr_rst_busy0 : std_logic;

  signal rd1          : std_logic;
  signal data_tmp1    : std_logic_vector(c_FIFO_WIDTH - 1 downto 0);
  signal empty1       : std_logic;
  signal rd_rst_busy1 : std_logic;

  signal data_valid_tmp1 : std_logic;

  signal errors_sync1 : std_logic_vector(3 downto 0);
  signal empty_sync1  : std_logic;

  signal adc0_tmp1 : std_logic_vector(o_adc_a'range);
  signal adc1_tmp1 : std_logic_vector(o_adc_b'range);

  ---------------------------------------------------------------------
  -- error latching
  ---------------------------------------------------------------------
  constant NB_ERRORS_c : integer := 3;
  signal error_tmp     : std_logic_vector(NB_ERRORS_c - 1 downto 0);
  signal error_tmp_bis : std_logic_vector(NB_ERRORS_c - 1 downto 0);

begin

---------------------------------------------------------------------
-- adc: a ways
---------------------------------------------------------------------
  inst_io_adc_single_a : entity work.io_adc_single
    generic map(
      g_ADC_WIDTH     => i_adc_a_p'length,  -- adc bus width (expressed in bits).Possible values [1;max integer value[
      g_INPUT_LATENCY => g_INPUT_LATENCY  -- add latency after the input IO. Possible values: [0; max integer value[
      )
    port map(

      i_clk        => i_clk,            -- clock
      -- from reset_top: @i_clk
      i_io_clk_rst => i_io_clk_rst,
      i_io_rst     => i_io_rst,
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_adc_p      => i_adc_a_p,        -- Diff_p buffer input
      i_adc_n      => i_adc_a_n,        -- Diff_n buffer input
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_adc        => adc_a
      );

---------------------------------------------------------------------
-- adc: a ways
---------------------------------------------------------------------
  inst_io_adc_single_b : entity work.io_adc_single
    generic map(
      g_ADC_WIDTH     => i_adc_b_p'length,  -- adc bus width (expressed in bits).Possible values [1;max integer value[
      g_INPUT_LATENCY => g_INPUT_LATENCY  -- add latency after the input IO. Possible values: [0; max integer value[
      )
    port map(
      i_clk        => i_clk,            -- clock
      -- from reset_top: @i_clk
      i_io_clk_rst => i_io_clk_rst,
      i_io_rst     => i_io_rst,
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_adc_p      => i_adc_b_p,        -- Diff_p buffer input
      i_adc_n      => i_adc_b_n,        -- Diff_n buffer input
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_adc        => adc_b
      );

---------------------------------------------------------------------
-- clock domain crossing
---------------------------------------------------------------------
  wr_rst_tmp0                         <= i_io_clk_rst;
  wr_tmp0                             <= '1' when (i_io_rst = '0' and wr_rst_busy0 = '0') else '0';
  data_tmp0(c_IDX1_H downto c_IDX1_L) <= adc_b;
  data_tmp0(c_IDX0_H downto c_IDX0_L) <= adc_a;

  inst_fifo_async_with_error : entity work.fifo_async_with_error
    generic map(
      g_CDC_SYNC_STAGES   => 2,
      g_FIFO_MEMORY_TYPE  => "distributed",
      g_FIFO_READ_LATENCY => c_FIFO_READ_LATENCY,
      g_FIFO_WRITE_DEPTH  => c_FIFO_DEPTH,
      g_READ_DATA_WIDTH   => data_tmp0'length,
      g_READ_MODE         => "std",
      g_RELATED_CLOCKS    => 0,
      g_WRITE_DATA_WIDTH  => data_tmp0'length,
      ---------------------------------------------------------------------
      -- resynchronization: fifo errors/empty flag
      ---------------------------------------------------------------------
      g_SYNC_SIDE         => "rd"  -- define the clock side where status/errors is resynchronised. Possible value "wr" or "rd"
      )
    port map(
      ---------------------------------------------------------------------
      -- write side
      ---------------------------------------------------------------------
      i_wr_clk        => i_clk,
      i_wr_rst        => wr_rst_tmp0,
      i_wr_en         => wr_tmp0,
      i_wr_din        => data_tmp0,
      o_wr_full       => open,          -- not connected
      o_wr_rst_busy   => wr_rst_busy0,
      ---------------------------------------------------------------------
      -- read side
      ---------------------------------------------------------------------
      i_rd_clk        => i_out_clk,
      i_rd_en         => rd1,
      o_rd_dout_valid => data_valid_tmp1,
      o_rd_dout       => data_tmp1,
      o_rd_empty      => empty1,
      o_rd_rst_busy   => rd_rst_busy1,  -- not connected
      ---------------------------------------------------------------------
      -- resynchronized errors/status 
      ---------------------------------------------------------------------
      o_errors_sync   => errors_sync1,
      o_empty_sync    => empty_sync1
      );

  rd1 <= '1' when empty1 = '0' and rd_rst_busy1 = '0' else '0';

  adc1_tmp1   <= data_tmp1(c_IDX1_H downto c_IDX1_L);
  adc0_tmp1   <= data_tmp1(c_IDX0_H downto c_IDX0_L);
---------------------------------------------------------------------
-- output
---------------------------------------------------------------------
  o_adc_valid <= data_valid_tmp1;
  o_adc_a     <= adc_a;
  o_adc_b     <= adc_b;

  ---------------------------------------------------------------------
  -- Error latching
  ---------------------------------------------------------------------
  error_tmp(2) <= errors_sync1(2) or errors_sync1(3);  -- fifo rst error
  error_tmp(1) <= errors_sync1(1);                     -- fifo rd empty error
  error_tmp(0) <= errors_sync1(0);                     -- fifo wr full error
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

  o_errors(15 downto 3) <= (others => '0');
  o_errors(2)           <= error_tmp_bis(2);  -- fifo rst error
  o_errors(1)           <= error_tmp_bis(1);  -- fifo rd empty error
  o_errors(0)           <= error_tmp_bis(0);  -- fifo wr full error

  o_status(7 downto 1) <= (others => '0');
  o_status(0)          <= empty_sync1;

  ---------------------------------------------------------------------
  -- for simulation only
  ---------------------------------------------------------------------
  assert not (error_tmp_bis(2) = '1') report "[io_adc] => FIFO is used before the end of the initialization " severity error;
  assert not (error_tmp_bis(1) = '1') report "[io_adc] => FIFO read an empty FIFO" severity error;
  assert not (error_tmp_bis(0) = '1') report "[io_adc] => FIFO write a full FIFO" severity error;

end architecture RTL;
