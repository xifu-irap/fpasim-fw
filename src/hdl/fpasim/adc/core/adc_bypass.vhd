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
--    @file                   adc_bypass.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This module allows to bypass or not each input ADCs.
--
--
--      . When a bypass is applied one of the input ADCs, the corresponding output is set to fixed constant value (0)
--      . Otherwise, no change is applied. That's mean, the input ADCs is copied into the corresponding output.
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.pkg_fpasim.all;


entity adc_bypass is
  generic(
    g_ADC1_WIDTH : positive := 14;  -- adc1 bus width (expressed in bits). Possible values [1; max integer value[
    g_ADC0_WIDTH : positive := 14  -- adc0 bus width (expressed in bits). Possible values [1; max integer value[
    );
  port(
    i_clk              : in  std_logic;  -- clock
    i_rst              : in  std_logic;  -- reset
    ---------------------------------------------------------------------
    -- input
    ---------------------------------------------------------------------
    i_adc_valid        : in  std_logic;  -- valid adcs value
    i_adc1             : in  std_logic_vector(g_ADC1_WIDTH - 1 downto 0);  -- adc1 value
    i_adc0             : in  std_logic_vector(g_ADC0_WIDTH - 1 downto 0);  -- adc0 value
    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    -- from regdecode
    -----------------------------------------------------------------
    -- adc_bypass valid
    i_adc_bypass_valid : in  std_logic;
    -- adc1_bypass. 0: no change on adc1 data, 1: zeroed the adc1 values
    i_adc1_bypass      : in  std_logic;
    -- adc0_bypass. 0: no change on adc0 data, 1: zeroed the adc0 values
    i_adc0_bypass      : in  std_logic;
    -- output
    -----------------------------------------------------------------
    o_adc_valid        : out std_logic;  -- valid adc value
    o_adc1             : out std_logic_vector(g_ADC1_WIDTH - 1 downto 0);  -- adc1 value
    o_adc0             : out std_logic_vector(g_ADC0_WIDTH - 1 downto 0)  -- adc0 value

    );
end entity adc_bypass;

architecture RTL of adc_bypass is

  -- initial value of the adcx_bypass signal
  constant c_ADC_BYPASS_INIT : std_logic:= '0';
  -- adc1 value when bypassed
  constant c_ADC1       : std_logic_vector(i_adc1'range) := (others => '0');
  -- adc0 value when bypassed
  constant c_ADC0       : std_logic_vector(i_adc0'range) := (others => '0');

  ---------------------------------------------------------------------
  -- latch input command
  ---------------------------------------------------------------------
  -- adc1 latched command
  signal adc1_bypass_r0 : std_logic := c_ADC_BYPASS_INIT;
  -- adc1 latched command
  signal adc0_bypass_r0 : std_logic := c_ADC_BYPASS_INIT;

  ---------------------------------------------------------------------
  -- select the adc
  ---------------------------------------------------------------------
  -- delayed adc_valid
  signal adc_valid_r1 : std_logic;
  -- selected adc1
  signal adc1_r1      : std_logic_vector(i_adc1'range);
  -- selected adc0
  signal adc0_r1      : std_logic_vector(i_adc0'range);

  ---------------------------------------------------------------------
  -- optional output delay
  ---------------------------------------------------------------------
  constant c_IDX0_L : integer := 0;                             -- index0: low
  constant c_IDX0_H : integer := c_IDX0_L + i_adc0'length - 1;  -- index0: high

  constant c_IDX1_L : integer := c_IDX0_H + 1;                  -- index1: low
  constant c_IDX1_H : integer := c_IDX1_L + i_adc1'length - 1;  -- index1: high

  constant c_IDX2_L : integer := c_IDX1_H + 1;      -- index2: low
  constant c_IDX2_H : integer := c_IDX2_L + 1 - 1;  -- index2: high

  -- temporary input pipe
  signal data_pipe_tmp0 : std_logic_vector(c_IDX2_H downto 0);
  -- temporary output pipe
  signal data_pipe_tmp1 : std_logic_vector(c_IDX2_H downto 0);

  -- delayed adc valid
  signal adc_valid_rx : std_logic;
  -- delayed adc1
  signal adc1_rx      : std_logic_vector(i_adc1'range);
  -- delayed adc0
  signal adc0_rx      : std_logic_vector(i_adc0'range);

begin

-- define a default value for the latched the command
  p_latch_command : process (i_clk) is
  begin
    if rising_edge(i_clk) then
      if i_rst = '1' then
        -- default command
        adc1_bypass_r0 <= c_ADC_BYPASS_INIT;
        adc0_bypass_r0 <= c_ADC_BYPASS_INIT;
      elsif i_adc_bypass_valid = '1' then
        -- latch command
        adc1_bypass_r0 <= i_adc1_bypass;
        adc0_bypass_r0 <= i_adc0_bypass;
      end if;
    end if;
  end process p_latch_command;

-- for each adc, force or not the adc data to a constant value
  p_select_adc0 : process (i_clk) is
  begin
    if rising_edge(i_clk) then
      adc_valid_r1 <= i_adc_valid;

      -- adc0 selection
      if adc0_bypass_r0 = '1' then
        adc0_r1 <= c_ADC0;
      else
        adc0_r1 <= i_adc0;
      end if;

    end if;
  end process p_select_adc0;

-- for each adc1, force or not the adc data to a constant value
  p_select_adc1 : process (i_clk) is
  begin
    if rising_edge(i_clk) then

      -- adc1 selection
      if adc1_bypass_r0 = '1' then
        adc1_r1 <= c_ADC1;
      else
        adc1_r1 <= i_adc1;
      end if;

    end if;
  end process p_select_adc1;

---------------------------------------------------------------------
-- optional output delay
---------------------------------------------------------------------
  data_pipe_tmp0(c_IDX2_H)                 <= adc_valid_r1;
  data_pipe_tmp0(c_IDX1_H downto c_IDX1_L) <= adc1_r1;
  data_pipe_tmp0(c_IDX0_H downto c_IDX0_L) <= adc0_r1;

  inst_pipeliner_sync_with_adc_enable_out : entity work.pipeliner
    generic map(
      g_NB_PIPES   => pkg_ADC_SEL_OUTPUT_LATENCY,  -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => data_pipe_tmp0'length  -- width of the input/output data.  Possibles values: [1, integer max value[
      )
    port map(
      i_clk  => i_clk,                  -- clock signal
      i_data => data_pipe_tmp0,         -- input data
      o_data => data_pipe_tmp1          -- output data with/without delay
      );

  adc_valid_rx <= data_pipe_tmp1(c_IDX2_H);
  adc1_rx      <= data_pipe_tmp1(c_IDX1_H downto c_IDX1_L);
  adc0_rx      <= data_pipe_tmp1(c_IDX0_H downto c_IDX0_L);

---------------------------------------------------------------------
-- output
---------------------------------------------------------------------
  o_adc_valid <= adc_valid_rx;
  o_adc1      <= adc1_rx;
  o_adc0      <= adc0_rx;

end architecture RTL;
