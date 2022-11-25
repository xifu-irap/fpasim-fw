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
--!   @file                   clocking_top.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--
-- This module instanciates a fpga specific mmcm to generate the different clocks of the design.
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;



entity clocking_top is
  port(
    ---------------------------------------------------------------------
    -- input
    ---------------------------------------------------------------------
    i_clk_p   : in  std_logic;          -- differential clock p @250MHz
    i_clk_n   : in  std_logic;          -- differential clock n @250MHZ

    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    o_adc_clk : out std_logic;          -- adc output clock @250 MHz
    o_ref_clk : out std_logic;          -- ref output clock @62.5 MHz
    o_dac_clk : out std_logic;          -- dac output clock @500 MHz
    o_clk     : out std_logic;          -- sys output clock @333.33333 MHz

    o_locked : out std_logic
  );
end entity clocking_top;

architecture RTL of clocking_top is

component fpasim_clk_wiz_0
port
 (-- Clock in ports
  -- Clock out ports
  clk_out1          : out    std_logic;
  clk_out2          : out    std_logic;
  clk_out3          : out    std_logic;
  clk_out4          : out    std_logic;
  -- Status and control signals
  locked            : out    std_logic;
  clk_in1_p         : in     std_logic;
  clk_in1_n         : in     std_logic
 );
end component;

  signal adc_clk : std_logic;
  signal ref_clk : std_logic;
  signal dac_clk : std_logic;
  signal clk : std_logic;
  signal locked : std_logic;

begin

  inst_fpasim_clk_wiz_0 : fpasim_clk_wiz_0
    port map(
      -- Clock out ports  
      clk_out1  => adc_clk,           -- output clock @250MHz
      clk_out2  => ref_clk,           -- output clock @62.5MHz
      clk_out3  => dac_clk,           -- output clock @500MHz
      clk_out4  => clk,               -- output clock @333.33333MHz
      -- Status and control signals                
      locked    => locked,
      -- Clock in ports
      clk_in1_p => i_clk_p,
      clk_in1_n => i_clk_n
    );
    o_adc_clk <= adc_clk;
    o_ref_clk <= ref_clk;
    o_dac_clk <= dac_clk;
    o_clk <= clk;
    o_locked <= locked;
end architecture RTL;
