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
--    for each input ADCs, this module performs the following steps:
--      . fixed or not the adc values to a constant value
--      . add a configurable and dynamic delay.
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


entity adc_top is
  generic(
    g_ADC1_WIDTH       : positive := 14;  -- adc1 bus width (expressed in bits). Possible values [1; max integer value[
    g_ADC0_WIDTH       : positive := 14;  -- adc0 bus width (expressed in bits). Possible values [1; max integer value[
    g_ADC1_DELAY_WIDTH : positive := 6;  -- adc1 delay bus width (expressed in bits). Possible values [1; max integer value[
    g_ADC0_DELAY_WIDTH : positive := 6  -- adc0 delay bus width (expressed in bits). Possible values [1; max integer value[
    );
  port(
    i_clk       : in std_logic;         -- clock
    i_rst       : in std_logic;         -- reset
    ---------------------------------------------------------------------
    -- input
    ---------------------------------------------------------------------
    i_adc_valid : in std_logic;         -- valid adcs value
    i_adc1      : in std_logic_vector(g_ADC1_WIDTH - 1 downto 0);  -- adc1 value
    i_adc0      : in std_logic_vector(g_ADC0_WIDTH - 1 downto 0);  -- adc0 value
    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------

    -- from regdecode
    -----------------------------------------------------------------
    -- adc selection command
    -- adc_bypass valid
    i_adc_bypass_valid : in std_logic;
    -- adc1_bypass. 0: no change on adc1 data, 1: zeroed the adc1 values
    i_adc1_bypass      : in std_logic;
    -- adc0_bypass. 0: no change on adc0 data, 1: zeroed the adc0 values
    i_adc0_bypass      : in std_logic;

    -- data path command
    -- enable
    i_en         : in  std_logic;
    -- configurable and dynamic delay to apply on the adc1 data path
    i_adc1_delay : in  std_logic_vector(g_ADC1_DELAY_WIDTH - 1 downto 0);
    -- configurable and dynamic delay to apply on the adc0 data path
    i_adc0_delay : in  std_logic_vector(g_ADC0_DELAY_WIDTH - 1 downto 0);
    -- output
    -----------------------------------------------------------------
    o_adc_valid  : out std_logic;       -- valid adc value
    o_adc1       : out std_logic_vector(g_ADC1_WIDTH - 1 downto 0);  -- adc1 value
    o_adc0       : out std_logic_vector(g_ADC0_WIDTH - 1 downto 0)  -- adc0 value

    );
end entity adc_top;

architecture RTL of adc_top is

---------------------------------------------------------------------
-- adc_select
---------------------------------------------------------------------
  signal adc_valid : std_logic;
  signal adc1      : std_logic_vector(i_adc1'range);
  signal adc0      : std_logic_vector(i_adc0'range);

---------------------------------------------------------------------
-- adc_shift
---------------------------------------------------------------------
  signal shift_adc_valid : std_logic;
  signal shift_adc1      : std_logic_vector(i_adc1'range);
  signal shift_adc0      : std_logic_vector(i_adc0'range);

begin

---------------------------------------------------------------------
-- adc_select
--  for each adcs, fixed or not the adc values to a constant value
---------------------------------------------------------------------
  inst_adc_bypass : entity work.adc_bypass
    generic map(
      g_ADC1_WIDTH => i_adc1'length,  -- adc1 bus width (expressed in bits). Possible values [1; max integer value[
      g_ADC0_WIDTH => i_adc0'length  -- adc0 bus width (expressed in bits). Possible values [1; max integer value[
      )
    port map(
      i_clk              => i_clk,      -- clock
      i_rst              => i_rst,      -- reset
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_adc_valid        => i_adc_valid,    -- valid adcs value
      i_adc1             => i_adc1,     -- adc1 value
      i_adc0             => i_adc0,     -- adc0 value
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      -- from regdecode
      -----------------------------------------------------------------
      i_adc_bypass_valid => i_adc_bypass_valid,  -- adc_en valid
      i_adc1_bypass      => i_adc1_bypass,  -- adc1_en. 1: no change, 0: zeroed the adc values
      i_adc0_bypass      => i_adc0_bypass,  -- adc0_en. 1: no change, 0: zeroed the adc values
      -- output
      -----------------------------------------------------------------
      o_adc_valid        => adc_valid,  -- valid adc value
      o_adc1             => adc1,       -- adc1 value
      o_adc0             => adc0        -- adc0 value
      );

---------------------------------------------------------------------
-- adc_shift
--  for each adcs, add a configurable and dynamic delay.
---------------------------------------------------------------------
  inst_adc_shift : entity work.adc_shift
    generic map(
      g_ADC1_WIDTH       => adc1'length,  -- adc1 bus width (expressed in bits). Possible values [1; max integer value[
      g_ADC0_WIDTH       => adc0'length,  -- adc0 bus width (expressed in bits). Possible values [1; max integer value[
      g_ADC1_DELAY_WIDTH => i_adc1_delay'length,  -- adc1 delay bus width (expressed in bits). Possible values [1; max integer value[
      g_ADC0_DELAY_WIDTH => i_adc0_delay'length  -- adc0 delay bus width (expressed in bits). Possible values [1; max integer value[
      )
    port map(
      i_clk        => i_clk,            -- output clock
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_adc_valid  => adc_valid,        -- valid adcs value
      i_adc1       => adc1,             -- adc1 value
      i_adc0       => adc0,             -- adc0 value
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      -- from regdecode
      -----------------------------------------------------------------
      i_en         => i_en,             -- enable
      i_adc1_delay => i_adc1_delay,     -- delay to apply on the adc1 data path
      i_adc0_delay => i_adc0_delay,     -- delay to apply on the adc2 data path
      -- output
      -----------------------------------------------------------------
      o_adc_valid  => shift_adc_valid,  -- valid adc value
      o_adc1       => shift_adc1,       -- adc1 value
      o_adc0       => shift_adc0        -- adc0 value
      );

---------------------------------------------------------------------
-- output
---------------------------------------------------------------------
  o_adc_valid <= shift_adc_valid;
  o_adc1      <= shift_adc1;
  o_adc0      <= shift_adc0;

end architecture RTL;
