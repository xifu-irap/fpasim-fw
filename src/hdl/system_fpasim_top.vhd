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
--!   @file                   system_fpasim_top.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
-- This module is the fpga top level
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity system_fpasim_top is
  port(
    --  Opal Kelly inouts --
    i_okUH          : in    std_logic_vector(4 downto 0);
    o_okHU          : out   std_logic_vector(2 downto 0);
    b_okUHU         : inout std_logic_vector(31 downto 0);
    b_okAA          : inout std_logic;
    ---------------------------------------------------------------------
    -- FMC: from the card
    ---------------------------------------------------------------------
    -- TODO
    i_board_id     : in std_logic_vector(7 downto 0); -- card board id 
    ---------------------------------------------------------------------
    -- FMC: from the adc
    ---------------------------------------------------------------------
    i_adc_clk_p   : in    std_logic;    -- differential clock p @250MHz
    i_adc_clk_n   : in    std_logic;    -- differential clock n @250MHZ
    -- adc_a
    -- bit P/N: 0-1
    i_da0_p       : in    std_logic;
    i_da0_n       : in    std_logic;
    i_da2_p       : in    std_logic;
    i_da2_n       : in    std_logic;
    i_da4_p       : in    std_logic;
    i_da4_n       : in    std_logic;
    i_da6_p       : in    std_logic;
    i_da6_n       : in    std_logic;
    i_da8_p       : in    std_logic;
    i_da8_n       : in    std_logic;
    i_da10_p      : in    std_logic;
    i_da10_n      : in    std_logic;
    i_da12_p      : in    std_logic;
    i_da12_n      : in    std_logic;
    -- adc_b
    i_db0_p       : in    std_logic;
    i_db0_n       : in    std_logic;
    i_db2_p       : in    std_logic;
    i_db2_n       : in    std_logic;
    i_db4_p       : in    std_logic;
    i_db4_n       : in    std_logic;
    i_db6_p       : in    std_logic;
    i_db6_n       : in    std_logic;
    i_db8_p       : in    std_logic;
    i_db8_n       : in    std_logic;
    i_db10_p      : in    std_logic;
    i_db10_n      : in    std_logic;
    i_db12_p      : in    std_logic;
    i_db12_n      : in    std_logic;
    ---------------------------------------------------------------------
    -- FMC: to sync
    ---------------------------------------------------------------------
    o_ref_clk     : out   std_logic;
    o_sync        : out   std_logic;
    ---------------------------------------------------------------------
    -- FMC: to dac
    ---------------------------------------------------------------------
    o_dac_clk_p   : out   std_logic;
    o_dac_clk_n   : out   std_logic;
    o_dac_frame_p : out   std_logic;
    o_dac_frame_n : out   std_logic;
    o_dac0_p      : out   std_logic;
    o_dac0_n      : out   std_logic;
    o_dac1_p      : out   std_logic;
    o_dac1_n      : out   std_logic;
    o_dac2_p      : out   std_logic;
    o_dac2_n      : out   std_logic;
    o_dac3_p      : out   std_logic;
    o_dac3_n      : out   std_logic;
    o_dac4_p      : out   std_logic;
    o_dac4_n      : out   std_logic;
    o_dac5_p      : out   std_logic;
    o_dac5_n      : out   std_logic;
    o_dac6_p      : out   std_logic;
    o_dac6_n      : out   std_logic;
    o_dac7_p      : out   std_logic;
    o_dac7_n      : out   std_logic
  );
end entity system_fpasim_top;

architecture RTL of system_fpasim_top is

  ---------------------------------------------------------------------
  -- clock generation
  ---------------------------------------------------------------------
  signal adc_clk : std_logic;
  signal ref_clk : std_logic;
  signal dac_clk : std_logic;
  signal clk     : std_logic;
  signal locked  : std_logic;

  ---------------------------------------------------------------------
  -- fpasim_top
  ---------------------------------------------------------------------
  -- adc
  signal adc_valid                       : std_logic;
  signal adc_amp_squid_offset_correction : std_logic_vector(13 downto 0);
  signal adc_mux_squid_feedback          : std_logic_vector(13 downto 0);

  -- sync
  signal sync : std_logic;

  signal dac_valid : std_logic;
  signal dac_frame : std_logic;
  signal dac       : std_logic_vector(15 downto 0);

  ---------------------------------------------------------------------
  -- ios
  ---------------------------------------------------------------------
  signal adc_a : std_logic_vector(13 downto 0);
  signal adc_b : std_logic_vector(13 downto 0);

begin

  ---------------------------------------------------------------------
  -- clock generation
  ---------------------------------------------------------------------
  inst_clocking_top : entity work.clocking_top
    port map(
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_clk_p   => i_adc_clk_p,         -- differential clock p @250MHz
      i_clk_n   => i_adc_clk_n,         -- differential clock n @250MHZ
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_adc_clk => adc_clk,             -- adc output clock @250 MHz
      o_ref_clk => ref_clk,             -- ref output clock @62.5 MHz
      o_dac_clk => dac_clk,             -- dac output clock @500 MHz
      o_clk     => clk,                 -- sys output clock @333.33333 MHz
      o_locked  => locked               -- not connected
    );

  ---------------------------------------------------------------------
  -- top_fpasim
  ---------------------------------------------------------------------
  inst_fpasim_top : entity work.fpasim_top
    generic map(
      g_DEBUG => false
    )
    port map(
      i_clk                             => clk, -- system clock
      i_adc_clk                         => adc_clk, -- adc clock
      i_ref_clk                         => ref_clk, -- reference clock
      i_dac_clk                         => dac_clk, -- dac clock
      ---------------------------------------------------------------------
      -- from the usb @i_usb_clk (clock included)
      ---------------------------------------------------------------------
      i_okUH                            => i_okUH,
      o_okHU                            => o_okHU,
      b_okUHU                           => b_okUHU,
      b_okAA                            => b_okAA,
      ---------------------------------------------------------------------
      -- from the board
      ---------------------------------------------------------------------
      i_board_id                        => i_board_id,
      ---------------------------------------------------------------------
      -- from adc
      ---------------------------------------------------------------------
      i_adc_valid                       => adc_valid,
      i_adc_amp_squid_offset_correction => adc_amp_squid_offset_correction,
      i_adc_mux_squid_feedback          => adc_mux_squid_feedback,
      ---------------------------------------------------------------------
      -- output sync @clk_ref
      ---------------------------------------------------------------------
      o_sync                            => sync,
      ---------------------------------------------------------------------
      -- output dac @i_clk_dac
      ---------------------------------------------------------------------
      o_dac_valid                       => dac_valid, -- not connected
      o_dac_frame                       => dac_frame,
      o_dac                             => dac
    );

  adc_amp_squid_offset_correction <= adc_a;
  adc_mux_squid_feedback          <= adc_b;

  ---------------------------------------------------------------------
  -- Xilinx IOs
  ---------------------------------------------------------------------

  inst_io_top : entity work.io_top
    port map(
      ---------------------------------------------------------------------
      -- adc
      ---------------------------------------------------------------------
      -- from MMCM 
      i_adc_clk     => adc_clk,
      -- from fpga pads: adc_a 
      i_da0_p       => i_da0_p,
      i_da0_n       => i_da0_n,
      i_da2_p       => i_da2_p,
      i_da2_n       => i_da2_n,
      i_da4_p       => i_da4_p,
      i_da4_n       => i_da4_n,
      i_da6_p       => i_da6_p,
      i_da6_n       => i_da6_n,
      i_da8_p       => i_da8_p,
      i_da8_n       => i_da8_n,
      i_da10_p      => i_da10_p,
      i_da10_n      => i_da10_n,
      i_da12_p      => i_da12_p,
      i_da12_n      => i_da12_n,
      -- from fpga pads: adc_b
      i_db0_p       => i_db0_p,
      i_db0_n       => i_db0_n,
      i_db2_p       => i_db2_p,
      i_db2_n       => i_db2_n,
      i_db4_p       => i_db4_p,
      i_db4_n       => i_db4_n,
      i_db6_p       => i_db6_p,
      i_db6_n       => i_db6_n,
      i_db8_p       => i_db8_p,
      i_db8_n       => i_db8_n,
      i_db10_p      => i_db10_p,
      i_db10_n      => i_db10_n,
      i_db12_p      => i_db12_p,
      i_db12_n      => i_db12_n,


      -- to user :
      o_adc_valid   => adc_valid,
      o_adc_a       => adc_a,
      o_adc_b       => adc_b,
      ---------------------------------------------------------------------
      -- sync
      ---------------------------------------------------------------------
      -- from the user: @clk_ref 
      i_ref_clk     => ref_clk,
      i_sync        => sync,
      -- to the fpga pads 
      o_ref_clk     => o_ref_clk,
      o_sync        => o_sync,
      ---------------------------------------------------------------------
      -- dac
      ---------------------------------------------------------------------
      -- from the user
      i_dac_clk     => dac_clk,
      i_dac_frame   => dac_frame,
      i_dac         => dac,
      -- to the fpga pads
      o_dac_clk_p   => o_dac_clk_p,
      o_dac_clk_n   => o_dac_clk_n,
      o_dac_frame_p => o_dac_frame_p,
      o_dac_frame_n => o_dac_frame_n,
      o_dac0_p      => o_dac0_p,
      o_dac0_n      => o_dac0_n,
      o_dac1_p      => o_dac1_p,
      o_dac1_n      => o_dac1_n,
      o_dac2_p      => o_dac2_p,
      o_dac2_n      => o_dac2_n,
      o_dac3_p      => o_dac3_p,
      o_dac3_n      => o_dac3_n,
      o_dac4_p      => o_dac4_p,
      o_dac4_n      => o_dac4_n,
      o_dac5_p      => o_dac5_p,
      o_dac5_n      => o_dac5_n,
      o_dac6_p      => o_dac6_p,
      o_dac6_n      => o_dac6_n,
      o_dac7_p      => o_dac7_p,
      o_dac7_n      => o_dac7_n
    );

end architecture RTL;
