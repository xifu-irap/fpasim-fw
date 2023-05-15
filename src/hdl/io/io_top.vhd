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
--    This module does the following steps:
--      . ADC:
--         . deserializes data on ADC IO from @i_adc_clk to @o_adc_clk_div
--         . pass data word from @o_adc_clk_div to the @sys_clk (async FIFO)
--      . DAC:
--         . pass data words from @sys_clk to the @dac_clk_div (async FIFO)
--         . serializes data words from @dac_clk_div to the IOs (@dac_clk)
--         . generate "clock word" @dac_clk_div_phase90
--         . serializes "clock word" from @dac_clk_div_phase90 to the IOs (@dac_clk_phase90)
--      . SYNC:
--         . pass data words from @sys_clk to the @sync_clk
--         . send data to the IOs (@sync_clk)
--         . send clock to the IOs (@sync_clk)
--
-- -------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;


entity io_top is
  port(
    -- from the mmcm
    i_sys_clk             : in  std_logic;  -- system clock
    i_sync_clk            : in  std_logic;  -- sync/ref clock
    i_dac_clk             : in  std_logic;  -- dac data clock (IO pin side)
    i_dac_clk_div         : in  std_logic;  -- dac data div clock (IO user side)
    i_dac_clk_phase90     : in  std_logic;  -- dac clock (IO pin side)
    i_dac_clk_div_phase90 : in  std_logic;  -- dac div clock (IO user side)
    -- to the MMCM
    o_adc_clk_div         : out std_logic;  -- adc div data clock (IO user side)

    -- from the user: @i_sys_clk
    i_rst_status  : in std_logic;       -- reset error flag(s)
    i_debug_pulse : in std_logic;  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)

    ---------------------------------------------------------------------
    -- adc
    ---------------------------------------------------------------------
    -- from the reset_top: @i_adc_clk_div
    i_adc_io_clk_rst : in std_logic;    -- small pulse reset
    i_adc_io_rst     : in std_logic;    -- large pulse reset

    -- from the FPGA pads
    i_adc_clk_p : in std_logic;  -- differential_p clock adc (IO pin side)
    i_adc_clk_n : in std_logic;  -- differential_n clock adc (IO pin side)
    -- from fpga pads: adc_a  @i_adc_clk_p/n
    i_da0_p     : in std_logic;         --  differential_p adc_a (lane0)
    i_da0_n     : in std_logic;         --  differential_n adc_a (lane0)

    i_da2_p : in std_logic;             --  differential_p adc_a (lane1)
    i_da2_n : in std_logic;             --  differential_n adc_a (lane1)

    i_da4_p : in std_logic;             --  differential_p adc_a (lane2)
    i_da4_n : in std_logic;             --  differential_n adc_a (lane2)

    i_da6_p : in std_logic;             --  differential_p adc_a (lane3)
    i_da6_n : in std_logic;             --  differential_n adc_a (lane3)

    i_da8_p : in std_logic;             --  differential_p adc_a (lane4)
    i_da8_n : in std_logic;             --  differential_n adc_a (lane4)

    i_da10_p : in std_logic;            --  differential_p adc_a (lane5)
    i_da10_n : in std_logic;            --  differential_n adc_a (lane5)

    i_da12_p : in std_logic;            --  differential_p adc_a (lane6)
    i_da12_n : in std_logic;            --  differential_n adc_a (lane6)

    -- from fpga pads: adc_b @i_adc_clk_p/n
    i_db0_p : in std_logic;             --  differential_p adc_b (lane0)
    i_db0_n : in std_logic;             --  differential_n adc_b (lane0)

    i_db2_p : in std_logic;             --  differential_p adc_b (lane1)
    i_db2_n : in std_logic;             --  differential_n adc_b (lane1)

    i_db4_p : in std_logic;             --  differential_p adc_b (lane2)
    i_db4_n : in std_logic;             --  differential_n adc_b (lane2)

    i_db6_p : in std_logic;             --  differential_p adc_b (lane3)
    i_db6_n : in std_logic;             --  differential_n adc_b (lane3)

    i_db8_p : in std_logic;             --  differential_p adc_b (lane4)
    i_db8_n : in std_logic;             --  differential_n adc_b (lane4)

    i_db10_p : in std_logic;            --  differential_p adc_b (lane5)
    i_db10_n : in std_logic;            --  differential_n adc_b (lane5)

    i_db12_p     : in  std_logic;       --  differential_p adc_b (lane6)
    i_db12_n     : in  std_logic;       --  differential_n adc_b (lane6)
    -- to user: @i_sys_clk
    o_adc_valid  : out std_logic;       -- adc data valid
    o_adc_a      : out std_logic_vector(13 downto 0);  -- adc data (channel a)
    o_adc_b      : out std_logic_vector(13 downto 0);  -- adc data (channel b)
    o_adc_errors : out std_logic_vector(15 downto 0);  -- adc errors
    o_adc_status : out std_logic_vector(7 downto 0);   -- adc status

    ---------------------------------------------------------------------
    -- sync
    ---------------------------------------------------------------------
    -- from the reset_top: @sync_clk
    i_sync_io_clk_rst : in std_logic;   -- small pulse reset
    i_sync_io_rst     : in std_logic;   -- large pulse reset

    -- input: from/to the user @i_sys_clk
    i_sync_rst    : in  std_logic;                      -- sync reset
    i_sync_valid  : in  std_logic;                      -- sync data valid
    i_sync        : in  std_logic;                      -- sync data
    o_sync_errors : out std_logic_vector(15 downto 0);  -- sync errors
    o_sync_status : out std_logic_vector(7 downto 0);   -- sync status

    -- to the fpga pads : @sync_clk
    o_sync_clk_p : out std_logic;         -- differential sync/ref clock p
    o_sync_clk_n : out std_logic;         -- differential sync/ref clock n
    o_sync_p     : out std_logic;         -- differential sync_p
    o_sync_n     : out std_logic;         -- differential sync_n

    ---------------------------------------------------------------------
    -- dac
    ---------------------------------------------------------------------
    -- from/to the user: @i_clk
    i_dac_rst    : in  std_logic;
    i_dac_valid  : in  std_logic;                      -- dac data valid
    i_dac_frame  : in  std_logic;                      -- dac frame flag
    i_dac1       : in  std_logic_vector(15 downto 0);  -- dac1 data value
    i_dac0       : in  std_logic_vector(15 downto 0);  -- dac0 data value
    o_dac_errors : out std_logic_vector(15 downto 0);  -- dac errors
    o_dac_status : out std_logic_vector(7 downto 0);   -- dac status

    -- from the reset_top: @i_dac_clk_div
    i_dac_io_rst         : in std_logic;  -- large pulse reset
    -- from the reset_top: @i_dac_clk_div_phase90
    i_dac_io_rst_phase90 : in std_logic;  -- large pulse reset

    -- to the fpga pads: @i_dac_clk
    -- dac clock @i_dac_clk
    o_dac_clk_p   : out std_logic;      --  differential_p dac clock
    o_dac_clk_n   : out std_logic;      --  differential_n dac clock
    -- dac frame flag @i_dac_clk
    o_dac_frame_p : out std_logic;      --  differential_p dac frame
    o_dac_frame_n : out std_logic;      --  differential_n dac frame
    -- dac data @i_dac_clk
    o_dac0_p      : out std_logic;      --  differential_p dac data (lane0)
    o_dac0_n      : out std_logic;      --  differential_n dac data (lane0)

    o_dac1_p : out std_logic;           --  differential_p dac data (lane1)
    o_dac1_n : out std_logic;           --  differential_n dac data (lane1)

    o_dac2_p : out std_logic;           --  differential_p dac data (lane2)
    o_dac2_n : out std_logic;           --  differential_n dac data (lane2)

    o_dac3_p : out std_logic;           --  differential_p dac data (lane3)
    o_dac3_n : out std_logic;           --  differential_n dac data (lane3)

    o_dac4_p : out std_logic;           --  differential_p dac data (lane4)
    o_dac4_n : out std_logic;           --  differential_n dac data (lane4)

    o_dac5_p : out std_logic;           --  differential_p dac data (lane5)
    o_dac5_n : out std_logic;           --  differential_n dac data (lane5)

    o_dac6_p : out std_logic;           --  differential_p dac data (lane6)
    o_dac6_n : out std_logic;           --  differential_n dac data (lane6)

    o_dac7_p : out std_logic;           --  differential_p dac data (lane7)
    o_dac7_n : out std_logic;           --  differential_n dac data (lane7)

    ---------------------------------------------------------------------
    -- pulse
    ---------------------------------------------------------------------
    -- input: from/to the user @i_sys_clk
    -- first processed sample of a pulse
    i_pulse_sof : in std_logic;

    -- to the fpga pads : @i_sys_clk
    -- first processed sample of a pulse
    o_pulse_sof : out std_logic
    );
end entity io_top;

architecture RTL of io_top is

  ---------------------------------------------------------------------
  -- io_adc_top
  ---------------------------------------------------------------------
  -- input
  -- differential adc data_p (channel A)
  signal adc_a_tmp0_p : std_logic_vector(6 downto 0);
  -- differential adc data_n (channel A)
  signal adc_a_tmp0_n : std_logic_vector(6 downto 0);

  -- differential adc data_p (channel B)
  signal adc_b_tmp0_p : std_logic_vector(6 downto 0);
  -- differential adc data_n (channel B)
  signal adc_b_tmp0_n : std_logic_vector(6 downto 0);

  -- output
  -- divided adc clock
  signal adc_clk_div : std_logic;
  -- adc data valid
  signal adc_valid   : std_logic;
  -- adc data (channel A)
  signal adc_a       : std_logic_vector(o_adc_a'range);
  -- adc data (channel B)
  signal adc_b       : std_logic_vector(o_adc_b'range);

  -- io adc errors
  signal adc_errors : std_logic_vector(o_adc_errors'range);
  -- io adc status
  signal adc_status : std_logic_vector(o_adc_status'range);

  ---------------------------------------------------------------------
  -- io_sync_top
  ---------------------------------------------------------------------
  -- io sync errors
  signal sync_errors : std_logic_vector(o_sync_errors'range);
  -- io sync status
  signal sync_status : std_logic_vector(o_sync_status'range);

  ---------------------------------------------------------------------
  -- io_dac_top
  ---------------------------------------------------------------------
  -- io dac errors
  signal dac_errors : std_logic_vector(o_dac_errors'range);
  -- io dac status
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
      g_ADC_A_WIDTH => adc_a_tmp0_p'length,  -- adc bus width (expressed in bits).Possible values [1;max integer value[
      g_ADC_B_WIDTH => adc_b_tmp0_p'length  -- adc bus width (expressed in bits).Possible values [1;max integer value[
      )
    port map(
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      --
      i_adc_clk_p => i_adc_clk_p,       -- clock
      i_adc_clk_n => i_adc_clk_n,       -- clock
      -- adc_a
      i_adc_a_p   => adc_a_tmp0_p,      -- Diff_p buffer input
      i_adc_a_n   => adc_a_tmp0_n,      -- Diff_n buffer input
      -- adc_b
      i_adc_b_p   => adc_b_tmp0_p,      -- Diff_p buffer input
      i_adc_b_n   => adc_b_tmp0_n,      -- Diff_n buffer input

      -- from reset_top: @i_adc_clk_div
      i_io_clk_rst  => i_adc_io_clk_rst,
      i_io_rst      => i_adc_io_rst,
      o_adc_clk_div => adc_clk_div,
      ---------------------------------------------------------------------
      -- output@ i_out_clk
      ---------------------------------------------------------------------
      i_out_clk     => i_sys_clk,
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
    port map(

      ---------------------------------------------------------------------
      -- input: @i_clk
      ---------------------------------------------------------------------
      i_clk         => i_sys_clk,
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
      o_sync_clk_p   => o_sync_clk_p,
      o_sync_clk_n   => o_sync_clk_n,
      o_sync_p       => o_sync_p,
      o_sync_n       => o_sync_n,
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
    port map(
      ---------------------------------------------------------------------
      -- input: @i_clk
      ---------------------------------------------------------------------
      i_clk         => i_sys_clk,       -- clock
      i_rst         => i_dac_rst,
      i_rst_status  => i_rst_status,
      i_debug_pulse => i_debug_pulse,
      i_dac_valid   => i_dac_valid,
      i_dac_frame   => i_dac_frame,
      i_dac1        => i_dac1,
      i_dac0        => i_dac0,

      ---------------------------------------------------------------------
      -- output: i_out_clk
      ---------------------------------------------------------------------
      i_out_clk             => i_dac_clk,
      i_out_clk_div         => i_dac_clk_div,
      i_out_clk_phase90     => i_dac_clk_phase90,
      i_out_clk_div_phase90 => i_dac_clk_div_phase90,

      -- from reset_top: @i_out_clk_div
      i_io_rst         => i_dac_io_rst,
      -- from reset_top: @i_out_clk_div_phase90
      i_io_rst_phase90 => i_dac_io_rst_phase90,
      -- to pads:
      o_dac_clk_p      => o_dac_clk_p,
      o_dac_clk_n      => o_dac_clk_n,
      o_dac_frame_p    => o_dac_frame_p,
      o_dac_frame_n    => o_dac_frame_n,
      o_dac0_p         => o_dac0_p,
      o_dac0_n         => o_dac0_n,
      o_dac1_p         => o_dac1_p,
      o_dac1_n         => o_dac1_n,
      o_dac2_p         => o_dac2_p,
      o_dac2_n         => o_dac2_n,
      o_dac3_p         => o_dac3_p,
      o_dac3_n         => o_dac3_n,
      o_dac4_p         => o_dac4_p,
      o_dac4_n         => o_dac4_n,
      o_dac5_p         => o_dac5_p,
      o_dac5_n         => o_dac5_n,
      o_dac6_p         => o_dac6_p,
      o_dac6_n         => o_dac6_n,
      o_dac7_p         => o_dac7_p,
      o_dac7_n         => o_dac7_n,
      ---------------------------------------------------------------------
      -- output/status: @i_clk
      ---------------------------------------------------------------------
      o_errors         => dac_errors,
      o_status         => dac_status
      );

  -- output
  o_dac_errors <= dac_errors;
  o_dac_status <= dac_status;


  ---------------------------------------------------------------------
  -- pulse
  ---------------------------------------------------------------------
  inst_io_pulse : entity work.io_pulse
    port map(
      -- clock
      i_clk       => i_sys_clk,
      ---------------------------------------------------------------------
      -- input @i_clk
      ---------------------------------------------------------------------
      -- first processed sample of a pulse
      i_pulse_sof => i_pulse_sof,
      ---------------------------------------------------------------------
      -- output @i_clk
      ---------------------------------------------------------------------
      -- first processed sample of a pulse
      o_pulse_sof => o_pulse_sof
      );


end architecture RTL;
