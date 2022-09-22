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
--!   @file                   io_top.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--
-- This module is the top_level of the fpga specific IO component generation
--
-- -------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library UNISIM;
use UNISIM.vcomponents.all;

library fpasim;
use fpasim.pkg_fpasim.all;

entity io_top is
  port(
    ---------------------------------------------------------------------
    -- adc
    ---------------------------------------------------------------------
    -- from MMCM 
    i_adc_clk     : in  std_logic;
    -- from fpga pads: adc_a 
    i_da0_p       : in  std_logic;
    i_da0_n       : in  std_logic;
    i_da2_p       : in  std_logic;
    i_da2_n       : in  std_logic;
    i_da4_p       : in  std_logic;
    i_da4_n       : in  std_logic;
    i_da6_p       : in  std_logic;
    i_da6_n       : in  std_logic;
    i_da8_p       : in  std_logic;
    i_da8_n       : in  std_logic;
    i_da10_p      : in  std_logic;
    i_da10_n      : in  std_logic;
    i_da12_p      : in  std_logic;
    i_da12_n      : in  std_logic;
    -- from fpga pads: adc_b
    i_db0_p       : in  std_logic;
    i_db0_n       : in  std_logic;
    i_db2_p       : in  std_logic;
    i_db2_n       : in  std_logic;
    i_db4_p       : in  std_logic;
    i_db4_n       : in  std_logic;
    i_db6_p       : in  std_logic;
    i_db6_n       : in  std_logic;
    i_db8_p       : in  std_logic;
    i_db8_n       : in  std_logic;
    i_db10_p      : in  std_logic;
    i_db10_n      : in  std_logic;
    i_db12_p      : in  std_logic;
    i_db12_n      : in  std_logic;
    -- to user : adc_a
    o_adc_a       : out std_logic_vector(13 downto 0);
    -- to user : adc_b
    o_adc_b       : out std_logic_vector(13 downto 0);
    ---------------------------------------------------------------------
    -- sync
    ---------------------------------------------------------------------
    -- from the user: @clk_ref 
    i_ref_clk     : in  std_logic;
    i_sync        : in  std_logic;
    -- to the fpga pads 
    o_ref_clk     : out std_logic;
    o_sync        : out std_logic;
    ---------------------------------------------------------------------
    -- dac
    ---------------------------------------------------------------------
    -- from the user
    i_dac_clk     : in  std_logic;
    i_dac_frame   : in  std_logic;
    i_dac         : in  std_logic_vector(15 downto 0);
    -- to the fpga pads
    o_dac_clk_p   : out std_logic;
    o_dac_clk_n   : out std_logic;
    o_dac_frame_p : out std_logic;
    o_dac_frame_n : out std_logic;
    o_dac0_p      : out std_logic;
    o_dac0_n      : out std_logic;
    o_dac1_p      : out std_logic;
    o_dac1_n      : out std_logic;
    o_dac2_p      : out std_logic;
    o_dac2_n      : out std_logic;
    o_dac3_p      : out std_logic;
    o_dac3_n      : out std_logic;
    o_dac4_p      : out std_logic;
    o_dac4_n      : out std_logic;
    o_dac5_p      : out std_logic;
    o_dac5_n      : out std_logic;
    o_dac6_p      : out std_logic;
    o_dac6_n      : out std_logic;
    o_dac7_p      : out std_logic;
    o_dac7_n      : out std_logic
  );
end entity io_top;

architecture RTL of io_top is
  constant c_ADC_INPUT_LATENCY   : natural := pkg_IO_ADC_LATENCY;
  constant c_SYNC_OUTPUT_LATENCY : natural := pkg_IO_SYNC_LATENCY;
  constant c_DAC_OUTPUT_LATENCY  : natural := pkg_IO_DAC_LATENCY;
  ---------------------------------------------------------------------
  -- adc_a
  ---------------------------------------------------------------------
  signal adc_a_tmp0_p            : std_logic_vector(6 downto 0);
  signal adc_a_tmp0_n            : std_logic_vector(6 downto 0);
  signal adc_a_tmp1              : std_logic_vector(o_adc_a'range);

  ---------------------------------------------------------------------
  -- adc_b
  ---------------------------------------------------------------------
  signal adc_b_tmp0_p : std_logic_vector(6 downto 0);
  signal adc_b_tmp0_n : std_logic_vector(6 downto 0);
  signal adc_b_tmp1   : std_logic_vector(o_adc_b'range);

begin

  ---------------------------------------------------------------------
  -- adc_a
  ---------------------------------------------------------------------
  adc_a_tmp0_p(6) <= i_da12_p;
  adc_a_tmp0_n(6) <= i_da12_n;

  adc_a_tmp0_p(5) <= i_da10_p;
  adc_a_tmp0_n(5) <= i_da10_n;

  adc_a_tmp0_p(4) <= i_da8_p;
  adc_a_tmp0_n(4) <= i_da8_n;

  adc_a_tmp0_p(3) <= i_da6_p;
  adc_a_tmp0_n(3) <= i_da6_n;

  adc_a_tmp0_p(2) <= i_da4_p;
  adc_a_tmp0_n(2) <= i_da4_n;

  adc_a_tmp0_p(1) <= i_da2_p;
  adc_a_tmp0_n(1) <= i_da2_n;

  adc_a_tmp0_p(0) <= i_da0_p;
  adc_a_tmp0_n(0) <= i_da0_n;

  inst_io_adc_a : entity fpasim.io_adc
    generic map(
      g_ADC_WIDTH     => adc_a_tmp0_p'length,
      g_INPUT_LATENCY => c_ADC_INPUT_LATENCY
    )
    port map(
      i_clk   => i_adc_clk,             -- clock
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_adc_p => adc_a_tmp0_p,          -- Diff_p buffer input
      i_adc_n => adc_a_tmp0_n,          -- Diff_n buffer input
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_adc   => adc_a_tmp1
    );
  o_adc_a <= adc_a_tmp1;

  ---------------------------------------------------------------------
  -- adc_b
  ---------------------------------------------------------------------
  adc_b_tmp0_p(6) <= i_db12_p;
  adc_b_tmp0_n(6) <= i_db12_n;

  adc_b_tmp0_p(5) <= i_db10_p;
  adc_b_tmp0_n(5) <= i_db10_n;

  adc_b_tmp0_p(4) <= i_db8_p;
  adc_b_tmp0_n(4) <= i_db8_n;

  adc_b_tmp0_p(3) <= i_db6_p;
  adc_b_tmp0_n(3) <= i_db6_n;

  adc_b_tmp0_p(2) <= i_db4_p;
  adc_b_tmp0_n(2) <= i_db4_n;

  adc_b_tmp0_p(1) <= i_db2_p;
  adc_b_tmp0_n(1) <= i_db2_n;

  adc_b_tmp0_p(0) <= i_db0_p;
  adc_b_tmp0_n(0) <= i_db0_n;

  inst_io_adc_b : entity fpasim.io_adc
    generic map(
      g_ADC_WIDTH     => adc_b_tmp0_p'length,
      g_INPUT_LATENCY => c_ADC_INPUT_LATENCY
    )
    port map(
      i_clk   => i_adc_clk,             -- clock
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_adc_p => adc_b_tmp0_p,          -- Diff_p buffer input
      i_adc_n => adc_b_tmp0_n,          -- Diff_n buffer input
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_adc   => adc_b_tmp1
    );
  o_adc_b <= adc_b_tmp1;

  ---------------------------------------------------------------------
  -- sync
  ---------------------------------------------------------------------
  inst_io_sync : entity fpasim.io_sync
    generic map(
      g_OUTPUT_LATENCY => c_SYNC_OUTPUT_LATENCY
    )
    port map(
      i_clk      => i_ref_clk,          -- clock
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_sync     => i_sync,
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_sync_clk => o_ref_clk,
      o_sync     => o_sync
    );

  ---------------------------------------------------------------------
  -- dac
  ---------------------------------------------------------------------
  inst_io_dac : entity fpasim.io_dac
    generic map(
      g_OUTPUT_LATENCY => c_DAC_OUTPUT_LATENCY
    )
    port map(
      i_clk         => i_dac_clk,       -- clock
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_dac_frame   => i_dac_frame,
      i_dac         => i_dac,
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
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
