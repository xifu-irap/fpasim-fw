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
--!   @file                   io_adc.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--
-- This module generates fpga specific IO component
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library UNISIM;
use UNISIM.vcomponents.all;


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
    i_io_rst     : in std_logic;  -- Reset connected to all other elements in the circuit

    -- i_adc_a
    i_adc_a_p : in std_logic_vector(g_ADC_A_WIDTH - 1 downto 0);  -- Diff_p buffer input
    i_adc_a_n : in std_logic_vector(g_ADC_A_WIDTH - 1 downto 0);  -- Diff_n buffer input

    -- i_adc_b
    i_adc_b_p : in std_logic_vector(g_ADC_B_WIDTH - 1 downto 0);  -- Diff_p buffer input
    i_adc_b_n : in std_logic_vector(g_ADC_B_WIDTH - 1 downto 0);  -- Diff_n buffer input

    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    o_adc_a : out std_logic_vector(g_ADC_A_WIDTH * 2 - 1 downto 0);
    o_adc_b : out std_logic_vector(g_ADC_B_WIDTH * 2 - 1 downto 0)
    );
end entity io_adc;

architecture RTL of io_adc is

  ---------------------------------------------------------------------
  -- io_adc_single
  ---------------------------------------------------------------------
  signal adc_a : std_logic_vector(o_adc_a'range);
  signal adc_b : std_logic_vector(o_adc_b'range);

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
-- output
---------------------------------------------------------------------
  o_adc_a <= adc_a;
  o_adc_b <= adc_b;

end architecture RTL;
