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
--    @file                   clocking_top.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details                
--
-- This module instanciates a fpga specific mmcm to generate some design clocks.
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


entity clocking_top is
  port(
    ---------------------------------------------------------------------
    -- input
    ---------------------------------------------------------------------
    i_clk : in std_logic;               -- differential clock @62.5MHz

    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    o_ref_clk : out std_logic;          -- ref output clock @62.5 MHz
    o_clk     : out std_logic;          -- sys output clock @300 MHz

    o_dac_clk             : out std_logic;  -- dac output clock @500 MHz
    o_dac_clk_div         : out std_logic;  -- dac output clock @125 MHz
    o_dac_clk_phase90     : out std_logic;  -- dac output clock @500 MHz with 90° phase
    o_dac_clk_div_phase90 : out std_logic;  -- dac output clock @125 MHz with 90° phase

    o_locked : out std_logic
    );
end entity clocking_top;

architecture RTL of clocking_top is

  signal locked0              : std_logic;
  ---------------------------------------------------------------------
  -- inst_fpasim_clk_wiz_0
  ---------------------------------------------------------------------
  signal adc_clk             : std_logic;
  signal ref_clk             : std_logic;
  signal dac_clk             : std_logic;
  signal dac_clk_div         : std_logic;
  signal dac_clk_phase90     : std_logic;
  signal dac_clk_div_phase90 : std_logic;
  signal clk                 : std_logic;
  signal locked              : std_logic;

begin

--inst_fpasim_clk_wiz_sys : entity work.fpasim_clk_wiz_sys
--    port map(
--      -- Clock out ports  
--      clk_out1 => clk,                  -- output clock @300MHz
--      -- Status and control signals                
--      locked   => locked0,
--      -- Clock in ports
--      clk_in1  => i_clk                 -- input @62.5MHz
--      );

  inst_fpasim_clk_wiz_0 : entity work.fpasim_clk_wiz_0
    port map(
      -- Clock out ports  
      clk_out1 => ref_clk,              -- output clock @62.5MHz
      clk_out2 => clk,                  -- output clock @333.33333MHz
      clk_out3 => dac_clk,      -- output clock @500MHz with no output buffer
      clk_out4 => dac_clk_phase90,  -- output clock @500MHz with 90° phase with no output buffer
      clk_out5 => dac_clk_div,  -- output clock @125Mhz with no output buffer
      clk_out6 => dac_clk_div_phase90,  -- output clock @125MHz with 90° phase with no output buffer
      -- Status and control signals                
      locked   => locked,
      -- Clock in ports
      clk_in1  => i_clk                 -- input @62.5MHz
      );

  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_ref_clk             <= ref_clk;
  o_clk                 <= clk;
  o_dac_clk             <= dac_clk;
  o_dac_clk_div         <= dac_clk_div;
  o_dac_clk_phase90     <= dac_clk_phase90;
  o_dac_clk_div_phase90 <= dac_clk_div_phase90;
  o_locked              <= locked;

end architecture RTL;
