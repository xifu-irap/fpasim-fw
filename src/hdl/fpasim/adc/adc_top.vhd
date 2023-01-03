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
--    @file                   adc_top.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details                
--
--    This module performs the following steps:
--       . for each data path, add an independant user-defined dynamic latency
--    Note: The output valid signal is aligned with a data path when its i_adcx_delay is set to '0'
--    Example0:
--    i_adcx_delay |   0                                       |
--    o_adc_valid  |   1   1   1   1   1   1   1   1   1   1   |
--    o_adcx       |   a0  a1  a2  a3  a4  a5  a6  a7  a8  a9  |
--
--    Example1:
--    i_adcx_delay |   1                                       |
--    o_adc_valid  |   1   1   1   1   1   1   1   1   1   1   |
--    o_adcx       |   xx  a0  a1  a2  a3  a4  a5  a6  a7  a8  |
--
--    Example2:
--    i_adcx_delay |   2                                       |
--    o_adc_valid  |   1   1   1   1   1   1   1   1   1   1   |
--    o_adcx       |   xx  xx  a0  a1  a2  a3  a4  a5  a6  a7  |
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


entity adc_top is
  generic(
    g_ADC1_WIDTH       : positive := 14; -- adc1 bus width (expressed in bits). Possible values [1; max integer value[
    g_ADC0_WIDTH       : positive := 14; -- adc0 bus width (expressed in bits). Possible values [1; max integer value[
    g_ADC1_DELAY_WIDTH : positive := 6; -- adc1 delay bus width (expressed in bits). Possible values [1; max integer value[
    g_ADC0_DELAY_WIDTH : positive := 6  -- adc0 delay bus width (expressed in bits). Possible values [1; max integer value[
  );
  port(
    i_clk         : in  std_logic;      -- output clock
    ---------------------------------------------------------------------
    -- input
    ---------------------------------------------------------------------
    i_adc_valid   : in  std_logic;      -- valid adcs value
    i_adc1        : in  std_logic_vector(g_ADC1_WIDTH - 1 downto 0); -- adc1 value
    i_adc0        : in  std_logic_vector(g_ADC0_WIDTH - 1 downto 0); -- adc0 value
    ---------------------------------------------------------------------
    -- output 
    ---------------------------------------------------------------------
    -- from regdecode
    -----------------------------------------------------------------
    i_en          : in  std_logic;      -- enable
    i_adc1_delay  : in  std_logic_vector(g_ADC1_DELAY_WIDTH - 1 downto 0); -- delay to apply on the adc1 data path
    i_adc0_delay  : in  std_logic_vector(g_ADC0_DELAY_WIDTH - 1 downto 0); -- delay to apply on the adc2 data path
    -- output
    -----------------------------------------------------------------
    o_adc_valid   : out std_logic;      -- valid adc value
    o_adc1        : out std_logic_vector(g_ADC1_WIDTH - 1 downto 0); -- adc1 value
    o_adc0        : out std_logic_vector(g_ADC0_WIDTH - 1 downto 0) -- adc0 value

  );
end entity adc_top;

architecture RTL of adc_top is

  ---------------------------------------------------------------------
  -- apply delay
  ---------------------------------------------------------------------
  signal data_valid1   : std_logic;
  signal data_valid_r1 : std_logic;
  signal adc1_rx       : std_logic_vector(o_adc1'range);
  signal adc0_rx       : std_logic_vector(o_adc0'range);

begin

  ---------------------------------------------------------------------
  -- apply a different delay on each adc data
  ---------------------------------------------------------------------
  inst_dynamic_shift_register_adc0 : entity work.dynamic_shift_register
    generic map(
      g_ADDR_WIDTH => i_adc0_delay'length,
      g_DATA_WIDTH => i_adc0'length
    )
    port map(
      i_clk        => i_clk,
      i_data_valid => i_adc_valid,
      i_data       => i_adc0,
      i_addr       => i_adc0_delay,
      o_data       => adc0_rx
    );


  inst_dynamic_shift_register_adc1 : entity work.dynamic_shift_register
    generic map(
      g_ADDR_WIDTH => i_adc1_delay'length, -- width of the address. Possibles values: [2, integer max value[ 
      g_DATA_WIDTH => i_adc1'length  -- width of the input/output data.  Possibles values: [1, integer max value[
    )
    port map(
      i_clk        => i_clk,            -- clock signal
      i_data_valid => i_adc_valid,      -- input data valid
      i_data       => i_adc1,        -- input data
      i_addr       => i_adc1_delay,     -- input address (dynamically select the depth of the pipeline)
      o_data       => adc1_rx           -- output data with/without delay
    );

-- synchronize with the dynamic_shift_register output when i_adc0/1_delay = 0
---------------------------------------------------------------------
data_valid1 <= i_adc_valid and i_en;
  inst_pipeliner_sync_with_dynamic_shift_register_when_delay_eq_0 : entity work.pipeliner
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


end architecture RTL;
