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
--    @file                   io_top.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details                
--
--    This module is the top_level of the fpga specific IO component generation
--
-- -------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use work.pkg_fpasim.all;

entity io_top is
  port(
    -- from the mmcm
    i_clk                 : in  std_logic;  -- system clock
    i_sync_clk            : in  std_logic;  -- sync/ref clock
    i_dac_clk             : in  std_logic;  -- dac clock
    i_dac_clk_div         : in  std_logic;
    i_dac_clk_phase90     : in  std_logic;
    i_dac_clk_div_phase90 : in  std_logic;
    -- to the MMCM
    o_adc_clk_div         : out std_logic;
    -- from the FPGA pads
    i_adc_clk_p           : in  std_logic;  -- adc clock_p
    i_adc_clk_n           : in  std_logic;  -- adc clock_n

    -- from the user: @i_clk
    i_rst_status  : in std_logic;       -- reset error flag(s)
    i_debug_pulse : in std_logic;  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)

    ---------------------------------------------------------------------
    -- adc
    ---------------------------------------------------------------------
    -- from the reset_top: @adc_clk
    i_adc_io_clk_rst : in  std_logic;  -- Clock reset: Reset connected to clocking elements in the circuit
    i_adc_io_rst     : in  std_logic;  -- Reset connected to all other elements in the circuit
    -- from fpga pads: adc_a  @adc_clk
    i_da0_p          : in  std_logic;
    i_da0_n          : in  std_logic;
    i_da2_p          : in  std_logic;
    i_da2_n          : in  std_logic;
    i_da4_p          : in  std_logic;
    i_da4_n          : in  std_logic;
    i_da6_p          : in  std_logic;
    i_da6_n          : in  std_logic;
    i_da8_p          : in  std_logic;
    i_da8_n          : in  std_logic;
    i_da10_p         : in  std_logic;
    i_da10_n         : in  std_logic;
    i_da12_p         : in  std_logic;
    i_da12_n         : in  std_logic;
    -- from fpga pads: adc_b @adc_clk
    i_db0_p          : in  std_logic;
    i_db0_n          : in  std_logic;
    i_db2_p          : in  std_logic;
    i_db2_n          : in  std_logic;
    i_db4_p          : in  std_logic;
    i_db4_n          : in  std_logic;
    i_db6_p          : in  std_logic;
    i_db6_n          : in  std_logic;
    i_db8_p          : in  std_logic;
    i_db8_n          : in  std_logic;
    i_db10_p         : in  std_logic;
    i_db10_n         : in  std_logic;
    i_db12_p         : in  std_logic;
    i_db12_n         : in  std_logic;
    -- to user: @i_clk
    o_adc_valid      : out std_logic;   -- adc data valid
    o_adc_a          : out std_logic_vector(13 downto 0);  -- adc data (channel a)
    o_adc_b          : out std_logic_vector(13 downto 0);  -- adc data (channel b)
    o_adc_errors     : out std_logic_vector(15 downto 0);  -- adc errors
    o_adc_status     : out std_logic_vector(7 downto 0);   -- adc status

    ---------------------------------------------------------------------
    -- sync
    ---------------------------------------------------------------------
    -- from the reset_top: @sync_clk
    i_sync_io_clk_rst : in std_logic;  -- Clock reset: Reset connected to clocking elements in the circuit
    i_sync_io_rst     : in std_logic;  -- Reset connected to all other elements in the circuit

    -- input: from/to the user @i_clk
    i_sync_rst    : in  std_logic;                      -- sync reset
    i_sync_valid  : in  std_logic;                      -- sync data valid
    i_sync        : in  std_logic;                      -- sync data
    o_sync_errors : out std_logic_vector(15 downto 0);  -- sync errors
    o_sync_status : out std_logic_vector(7 downto 0);   -- sync status

    -- to the fpga pads : @sync_clk
    o_sync_clk : out std_logic;         -- sync/ref clock
    o_sync     : out std_logic;         -- sync signal value

    ---------------------------------------------------------------------
    -- dac
    ---------------------------------------------------------------------
    -- from/to the user: @i_clk
    i_dac_rst    : in  std_logic;
    i_dac_valid  : in  std_logic;                      -- dac data valid
    i_dac_frame  : in  std_logic;                      -- dac frame flag
    i_dac        : in  std_logic_vector(15 downto 0);  -- dac data value
    o_dac_errors : out std_logic_vector(15 downto 0);  -- dac errors
    o_dac_status : out std_logic_vector(7 downto 0);   -- dac status

    -- from the reset_top: @i_dac_clk
    i_dac_io_clk_rst : in std_logic;  -- Clock reset: Reset connected to clocking elements in the circuit
    i_dac_io_rst     : in std_logic;  -- Reset connected to all other elements in the circuit
    i_dac_rst_out    : in std_logic;    -- Reset (application)

    -- to the fpga pads: @i_dac_clk
    -- dac clock @i_dac_clk
    o_dac_clk_p   : out std_logic;
    o_dac_clk_n   : out std_logic;
    -- dac frame flag @i_dac_clk
    o_dac_frame_p : out std_logic;
    o_dac_frame_n : out std_logic;
    -- dac data @i_dac_clk
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
  -- io_adc_top
  ---------------------------------------------------------------------
  -- input
  signal adc_a_tmp0_p            : std_logic_vector(6 downto 0);
  signal adc_a_tmp0_n            : std_logic_vector(6 downto 0);
  signal adc_b_tmp0_p            : std_logic_vector(6 downto 0);
  signal adc_b_tmp0_n            : std_logic_vector(6 downto 0);

  -- output
  signal adc_clk_div : std_logic;
  signal adc_valid   : std_logic;
  signal adc_a       : std_logic_vector(o_adc_a'range);
  signal adc_b       : std_logic_vector(o_adc_b'range);

  signal adc_errors : std_logic_vector(o_adc_errors'range);
  signal adc_status : std_logic_vector(o_adc_status'range);

  ---------------------------------------------------------------------
  -- io_sync_top
  ---------------------------------------------------------------------
  signal sync_errors : std_logic_vector(o_sync_errors'range);
  signal sync_status : std_logic_vector(o_sync_status'range);

  ---------------------------------------------------------------------
  -- io_dac_top
  ---------------------------------------------------------------------
  signal dac_errors : std_logic_vector(o_dac_errors'range);
  signal dac_status : std_logic_vector(o_dac_status'range);

begin

---------------------------------------------------------------------
-- io_adc
---------------------------------------------------------------------
  -- adc_a
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

  -- adc_b
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

  inst_io_adc : entity work.io_adc
    generic map(
      g_ADC_A_WIDTH   => adc_a_tmp0_p'length,  -- adc bus width (expressed in bits).Possible values [1;max integer value[
      g_ADC_B_WIDTH   => adc_b_tmp0_p'length,  -- adc bus width (expressed in bits).Possible values [1;max integer value[
      g_INPUT_LATENCY => c_ADC_INPUT_LATENCY  -- add latency after the input IO. Possible values: [0; max integer value[
      )
    port map(
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      --
      i_clk_p      => i_adc_clk_p,      -- clock
      i_clk_n      => i_adc_clk_n,      -- clock
      -- from reset_top: @i_clk
      i_io_clk_rst => i_adc_io_clk_rst,
      i_io_rst     => i_adc_io_rst,
      -- adc_a
      i_adc_a_p    => adc_a_tmp0_p,     -- Diff_p buffer input
      i_adc_a_n    => adc_a_tmp0_n,     -- Diff_n buffer input
      -- adc_b
      i_adc_b_p    => adc_b_tmp0_p,     -- Diff_p buffer input
      i_adc_b_n    => adc_b_tmp0_n,     -- Diff_n buffer input

      o_clk_div     => adc_clk_div,
      ---------------------------------------------------------------------
      -- output@ i_out_clk
      ---------------------------------------------------------------------
      i_out_clk     => i_clk,
      i_rst_status  => i_rst_status,
      i_debug_pulse => i_debug_pulse,
      o_adc_valid   => adc_valid,
      o_adc_a       => adc_a,
      o_adc_b       => adc_b,

      ---------------------------------------------------------------------
      -- errors/status: @i_out_clk
      ---------------------------------------------------------------------
      o_errors => adc_errors,
      o_status => adc_status
      );

  -- to the user
  o_adc_clk_div <= adc_clk_div;
  o_adc_valid   <= adc_valid;
  o_adc_a       <= adc_a;
  o_adc_b       <= adc_b;

  o_adc_errors <= adc_errors;
  o_adc_status <= adc_status;



  ---------------------------------------------------------------------
  -- sync
  ---------------------------------------------------------------------
  inst_io_sync : entity work.io_sync
    generic map(
      g_OUTPUT_LATENCY => c_SYNC_OUTPUT_LATENCY
      )
    port map(

      ---------------------------------------------------------------------
      -- input: @i_clk
      ---------------------------------------------------------------------
      i_clk         => i_clk,
      i_rst         => i_sync_rst,
      i_rst_status  => i_rst_status,
      i_debug_pulse => i_debug_pulse,
      i_sync_valid  => i_sync_valid,
      i_sync        => i_sync,

      ---------------------------------------------------------------------
      -- output: @i_out_clk
      ---------------------------------------------------------------------
      i_out_clk    => i_sync_clk,       -- clock
      -- from reset_top: @i_sync_clk
      i_io_clk_rst => i_sync_io_clk_rst,
      i_io_rst     => i_sync_io_rst,
      -- data
      o_sync_clk   => o_sync_clk,
      o_sync       => o_sync,
      ---------------------------------------------------------------------
      -- errors/status
      ---------------------------------------------------------------------
      o_errors     => sync_errors,
      o_status     => sync_status
      );

  -- output
  o_sync_errors <= sync_errors;
  o_sync_status <= sync_status;

  ---------------------------------------------------------------------
  -- dac
  ---------------------------------------------------------------------
  inst_io_dac : entity work.io_dac
    generic map(
      g_OUTPUT_LATENCY => c_DAC_OUTPUT_LATENCY
      )
    port map(
      ---------------------------------------------------------------------
      -- input: @i_clk
      ---------------------------------------------------------------------
      i_clk         => i_clk,           -- clock
      i_rst         => i_dac_rst,
      i_rst_status  => i_rst_status,
      i_debug_pulse => i_debug_pulse,
      i_dac_valid   => i_dac_valid,
      i_dac_frame   => i_dac_frame,
      i_dac         => i_dac,

      ---------------------------------------------------------------------
      -- output: i_out_clk
      ---------------------------------------------------------------------
      i_out_clk             => i_dac_clk,
      i_out_clk_div         => i_dac_clk_div,
      i_out_clk_phase90     => i_dac_clk_phase90,
      i_out_clk_div_phase90 => i_dac_clk_div_phase90,

      i_out_rst     => i_dac_rst_out,
      -- from reset_top: @i_dac_clk
      i_io_clk_rst  => i_dac_io_clk_rst,
      i_io_rst      => i_dac_io_rst,
      -- to pads:
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
      o_dac7_n      => o_dac7_n,
      ---------------------------------------------------------------------
      -- output/status: @i_clk
      ---------------------------------------------------------------------
      o_errors      => dac_errors,
      o_status      => dac_status
      );

  -- output
  o_dac_errors <= dac_errors;
  o_dac_status <= dac_status;
end architecture RTL;
