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
--!   @file                   adc_top.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--
-- This module performs the following steps:
--    . cross clock domain
--    . for each data path, add an independant user-defined dynamic latency
-- Note: The output valid signal is aligned with a data path when its i_adcx_delay is set to '0'
-- Example0:
-- i_adcx_delay |   0                                       |
-- o_adc_valid  |   1   1   1   1   1   1   1   1   1   1   |
-- o_adcx       |   a0  a1  a2  a3  a4  a5  a6  a7  a8  a9  |
--
-- Example1:
-- i_adcx_delay |   1                                       |
-- o_adc_valid  |   1   1   1   1   1   1   1   1   1   1   |
-- o_adcx       |   xx  a0  a1  a2  a3  a4  a5  a6  a7  a8  |
--
-- Example2:
-- i_adcx_delay |   2                                       |
-- o_adc_valid  |   1   1   1   1   1   1   1   1   1   1   |
-- o_adcx       |   xx  xx  a0  a1  a2  a3  a4  a5  a6  a7  |
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library fpasim;

entity adc_top is
  generic(
    g_ADC1_WIDTH       : positive := 14; -- adc1 bus width (expressed in bits). Possible values [1; max integer value[
    g_ADC0_WIDTH       : positive := 14; -- adc0 bus width (expressed in bits). Possible values [1; max integer value[
    g_ADC1_DELAY_WIDTH : positive := 6; -- adc1 delay bus width (expressed in bits). Possible values [1; max integer value[
    g_ADC0_DELAY_WIDTH : positive := 6  -- adc0 delay bus width (expressed in bits). Possible values [1; max integer value[
  );
  port(
    ---------------------------------------------------------------------
    -- input @i_clk_adc
    ---------------------------------------------------------------------
    i_adc_clk     : in  std_logic;      -- adc clock
    i_adc_valid   : in  std_logic;      -- valid adcs value
    i_adc1        : in  std_logic_vector(g_ADC1_WIDTH - 1 downto 0); -- adc1 value
    i_adc0        : in  std_logic_vector(g_ADC0_WIDTH - 1 downto 0); -- adc0 value
    ---------------------------------------------------------------------
    -- output @i_clk
    ---------------------------------------------------------------------
    i_clk         : in  std_logic;      -- output clock
    -- from regdecode
    -----------------------------------------------------------------
    i_rst_status  : in  std_logic;      -- reset error flag(s)
    i_debug_pulse : in  std_logic;      -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
    i_en          : in  std_logic;      -- enable
    i_adc1_delay  : in  std_logic_vector(g_ADC1_DELAY_WIDTH - 1 downto 0); -- delay to apply on the adc1 data path
    i_adc0_delay  : in  std_logic_vector(g_ADC0_DELAY_WIDTH - 1 downto 0); -- delay to apply on the adc2 data path
    -- output
    -----------------------------------------------------------------
    o_adc_valid   : out std_logic;      -- valid adc value
    o_adc1        : out std_logic_vector(g_ADC1_WIDTH - 1 downto 0); -- adc1 value
    o_adc0        : out std_logic_vector(g_ADC0_WIDTH - 1 downto 0); -- adc0 value
    ---------------------------------------------------------------------
    -- errors/status @i_clk
    --------------------------------------------------------------------- 
    o_errors      : out std_logic_vector(15 downto 0); -- output errors
    o_status      : out std_logic_vector(7 downto 0) -- output status
  );
end entity adc_top;

architecture RTL of adc_top is

  constant c_FIFO_READ_LATENCY : natural := fpasim.pkg_fpasim.pkg_ADC_FIFO_READ_LATENCY;

  ---------------------------------------------------------------------
  -- FIFO
  ---------------------------------------------------------------------
  constant c_IDX0_L : integer := 0;
  constant c_IDX0_H : integer := c_IDX0_L + i_adc0'length - 1;

  constant c_IDX1_L : integer := c_IDX0_H + 1;
  constant c_IDX1_H : integer := c_IDX1_L + i_adc1'length - 1;

  constant c_FIFO_DEPTH : integer := 16; --see IP
  constant c_FIFO_WIDTH : integer := c_IDX1_H + 1; --see IP

  signal wr_rst_tmp0 : std_logic;
  signal wr_tmp0     : std_logic;
  signal data_tmp0   : std_logic_vector(c_FIFO_WIDTH - 1 downto 0);
  --signal full0        : std_logic;
  --signal wr_rst_busy0 : std_logic;

  signal rd1       : std_logic;
  signal data_tmp1 : std_logic_vector(c_FIFO_WIDTH - 1 downto 0);
  signal empty1    : std_logic;
  --signal rd_rst_busy1 : std_logic;

  signal data_valid_tmp1 : std_logic;

  signal errors_sync1 : std_logic_vector(3 downto 0);
  signal empty_sync1  : std_logic;

  signal adc0_tmp1 : std_logic_vector(i_adc0'range);
  signal adc1_tmp1 : std_logic_vector(i_adc1'range);

  ---------------------------------------------------------------------
  -- apply delay
  ---------------------------------------------------------------------
  signal data_valid1   : std_logic;
  signal data_valid_r1 : std_logic;
  signal adc1_rx       : std_logic_vector(o_adc1'range);
  signal adc0_rx       : std_logic_vector(o_adc0'range);

  ---------------------------------------------------------------------
  -- error latching
  ---------------------------------------------------------------------
  constant NB_ERRORS_c : integer := 3;
  signal error_tmp     : std_logic_vector(NB_ERRORS_c - 1 downto 0);
  signal error_tmp_bis : std_logic_vector(NB_ERRORS_c - 1 downto 0);

begin


   wr_tmp0                            <= i_adc_valid;
  data_tmp0(c_IDX1_H downto c_IDX1_L) <= i_adc1;
  data_tmp0(c_IDX0_H downto c_IDX0_L) <= i_adc0;
  wr_rst_tmp0                         <= '0';
  inst_fifo_async_with_error : entity fpasim.fifo_async_with_error
    generic map(
      g_CDC_SYNC_STAGES   => 2,
      g_FIFO_MEMORY_TYPE  => "auto",
      g_FIFO_READ_LATENCY => c_FIFO_READ_LATENCY,
      g_FIFO_WRITE_DEPTH  => c_FIFO_DEPTH,
      g_READ_DATA_WIDTH   => data_tmp0'length,
      g_READ_MODE         => "std",
      g_RELATED_CLOCKS    => 0,
      g_WRITE_DATA_WIDTH  => data_tmp0'length,
      ---------------------------------------------------------------------
      -- resynchronization: fifo errors/empty flag
      ---------------------------------------------------------------------
      g_SYNC_SIDE         => "rd",      -- define the clock side where status/errors is resynchronised. Possible value "wr" or "rd"
      g_DEST_SYNC_FF      => 2,         -- Number of register stages used to synchronize signal in the destination clock domain.   
      g_SRC_INPUT_REG     => 1          -- 0- Do not register input (src_in), 1- Register input (src_in) once using src_clk 

    )
    port map(
      ---------------------------------------------------------------------
      -- write side
      ---------------------------------------------------------------------
      i_wr_clk        => i_adc_clk,
      i_wr_rst        => wr_rst_tmp0,
      i_wr_en         => wr_tmp0,
      i_wr_din        => data_tmp0,
      o_wr_full       => open,          -- not connected
      o_wr_rst_busy   => open,          -- not connected
      ---------------------------------------------------------------------
      -- read side
      ---------------------------------------------------------------------
      i_rd_clk        => i_clk,
      i_rd_en         => rd1,
      o_rd_dout_valid => data_valid_tmp1,
      o_rd_dout       => data_tmp1,
      o_rd_empty      => empty1,
      o_rd_rst_busy   => open,          -- not connected
      ---------------------------------------------------------------------
      -- resynchronized errors/status 
      ---------------------------------------------------------------------
      o_errors_sync   => errors_sync1,
      o_empty_sync    => empty_sync1
    );

  rd1 <= '1' when empty1 = '0' else '0';

  adc1_tmp1 <= data_tmp1(c_IDX1_H downto c_IDX1_L);
  adc0_tmp1 <= data_tmp1(c_IDX0_H downto c_IDX0_L);

  ---------------------------------------------------------------------
  -- apply a different delay on each adc data
  ---------------------------------------------------------------------
  inst_dynamic_shift_register_adc0 : entity fpasim.dynamic_shift_register
    generic map(
      g_ADDR_WIDTH => i_adc0_delay'length,
      g_DATA_WIDTH => adc0_tmp1'length
    )
    port map(
      i_clk        => i_clk,
      i_data_valid => data_valid_tmp1,
      i_data       => adc0_tmp1,
      i_addr       => i_adc0_delay,
      o_data       => adc0_rx
    );


  inst_dynamic_shift_register_adc1 : entity fpasim.dynamic_shift_register
    generic map(
      g_ADDR_WIDTH => i_adc1_delay'length, -- width of the address. Possibles values: [2, integer max value[ 
      g_DATA_WIDTH => adc1_tmp1'length  -- width of the input/output data.  Possibles values: [1, integer max value[
    )
    port map(
      i_clk        => i_clk,            -- clock signal
      i_data_valid => data_valid_tmp1,      -- input data valid
      i_data       => adc1_tmp1,        -- input data
      i_addr       => i_adc1_delay,     -- input address (dynamically select the depth of the pipeline)
      o_data       => adc1_rx           -- output data with/without delay
    );

-- synchronize with the dynamic_shift_register output when i_adc0/1_delay = 0
---------------------------------------------------------------------
data_valid1 <= data_valid_tmp1 and i_en;
  inst_pipeliner_sync_with_dynamic_shift_register_when_delay_eq_0 : entity fpasim.pipeliner
    generic map(
      g_NB_PIPES   => 1,                -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => 1                 -- width of the input/output data.  Possibles values: [1, integer max value[
    )
    port map(
      i_clk     => i_clk,               -- clock signal
      i_data(0) => data_valid1,     -- input data
      o_data(0) => data_valid_r1        -- output data with/without delay
    );

  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_adc_valid <= data_valid_r1;
  o_adc0      <= adc0_rx;
  o_adc1      <= adc1_rx;

  ---------------------------------------------------------------------
  -- Error latching
  ---------------------------------------------------------------------
  error_tmp(2) <= errors_sync1(2) or errors_sync1(3); -- fifo rst error
  error_tmp(1) <= errors_sync1(1);      -- fifo rd empty error
  error_tmp(0) <= errors_sync1(0);      -- fifo wr full error
  gen_errors_latch : for i in error_tmp'range generate
    inst_one_error_latch : entity fpasim.one_error_latch
      port map(
        i_clk         => i_clk,
        i_rst         => i_rst_status,
        i_debug_pulse => i_debug_pulse,
        i_error       => error_tmp(i),
        o_error       => error_tmp_bis(i)
      );
  end generate gen_errors_latch;

  o_errors(15 downto 3) <= (others => '0');
  o_errors(2)           <= error_tmp_bis(2); -- fifo rst error
  o_errors(1)           <= error_tmp_bis(1); -- fifo rd empty error
  o_errors(0)           <= error_tmp_bis(0); -- fifo wr full error

  o_status(7 downto 1) <= (others => '0');
  o_status(0)          <= empty_sync1;

  ---------------------------------------------------------------------
  -- for simulation only
  ---------------------------------------------------------------------
  assert not (error_tmp_bis(2) = '1') report "[adc_top] => FIFO is used before the end of the initialization " severity error;
  assert not (error_tmp_bis(1) = '1') report "[adc_top] => FIFO read an empty FIFO" severity error;
  assert not (error_tmp_bis(0) = '1') report "[adc_top] => FIFO write a full FIFO" severity error;

end architecture RTL;
