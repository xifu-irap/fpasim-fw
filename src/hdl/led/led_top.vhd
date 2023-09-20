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
--    @file                   led_top.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This module is the top level of the led manager.
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity led_top is
  port (

    ---------------------------------------------------------------------
    -- from/to the usb
    ---------------------------------------------------------------------
    i_usb_clk : in std_logic;           -- clock @usb_clk

    ---------------------------------------------------------------------
    -- from/to the mmcm
    ---------------------------------------------------------------------
    i_sys_clk     : in  std_logic;      -- system clock
    i_mmcm_locked : in  std_logic;      -- mmcm locked signal
    ---------------------------------------------------------------------
    -- to the XEM7350
    ---------------------------------------------------------------------
    -- leds of the FPGA board
    o_leds        : out std_logic_vector(3 downto 0);

    ---------------------------------------------------------------------
    -- to FMC
    ---------------------------------------------------------------------
    -- status of the firmware programmation. 1: programmed , 0: otherwise
    o_led_fw       : out std_logic;
    -- status of the PLL. '1': ADC clock alive (programmed spi devices), 0: otherwise
    o_led_pll_lock : out std_logic

    );
end entity led_top;

architecture RTL of led_top is

-- status ON of the firmware.
  constant c_FIRMWARE_ON : std_logic := '1';

---------------------------------------------------------------------
-- usb led_pulse
---------------------------------------------------------------------
  signal usb_pulse : std_logic;

---------------------------------------------------------------------
-- sys led_pulse
---------------------------------------------------------------------
  signal sys_pulse : std_logic;

begin

---------------------------------------------------------------------
-- generate pulse @i_usb_clk
---------------------------------------------------------------------
  inst_led_pulse_usb : entity work.led_pulse
    generic map(
      -- pulse period expressed in number of clock cycle. Should be a multiple of 2. The range is [2;inf[
      g_NB_CLK_OF_PULSE_PERIOD => 125_000_000,
      -- additional optional output delay
      g_OUTPUT_DELAY           => 1
      )
    port map(
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_clk   => i_usb_clk,             -- clock
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_pulse => usb_pulse              -- output pulse
      );

---------------------------------------------------------------------
-- generate pulse @i_sys_clk
---------------------------------------------------------------------
  inst_led_pulse_sys : entity work.led_pulse
    generic map(
      -- pulse period expressed in number of clock cycle. Should be a multiple of 2. The range is [2;inf[
      g_NB_CLK_OF_PULSE_PERIOD => 250_000_000,
      -- additional optional output delay
      g_OUTPUT_DELAY           => 1
      )
    port map(
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_clk   => i_sys_clk,             -- clock
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_pulse => sys_pulse              -- output pulse
      );


---------------------------------------------------------------------
-- output
---------------------------------------------------------------------
  o_leds(3) <= sys_pulse;
  o_leds(2) <= usb_pulse;
  o_leds(1) <= i_mmcm_locked;
  o_leds(0) <= c_FIRMWARE_ON;


  o_led_pll_lock <= i_mmcm_locked;
  o_led_fw       <= c_FIRMWARE_ON;


end architecture RTL;
