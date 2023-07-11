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
--    @file                   io_dac.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This module does the following steps:
--       . pass data words from @sys_clk to the @dac_clk_div (async FIFO) and reorder bytes.
--       . serializes data words from @dac_clk_div to the IOs (@dac_clk)
--       . generate "clock word" @dac_clk_div_phase90
--       . serializes "clock word" from @dac_clk_div_phase90 to the IOs (@dac_clk_phase90)
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.pkg_io.all;

entity io_dac is
  port(
    ---------------------------------------------------------------------
    -- input: @i_clk
    ---------------------------------------------------------------------
    i_clk                 : in std_logic;  -- clock
    i_rst                 : in std_logic;  -- reset
    i_rst_status          : in std_logic;  -- reset error flag(s)
    i_debug_pulse         : in std_logic;  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
    i_dac_valid           : in std_logic;  -- dac data valid
    i_dac_frame           : in std_logic;  -- data frame flag
    i_dac1                : in std_logic_vector(15 downto 0);  -- dac1 data value
    i_dac0                : in std_logic_vector(15 downto 0);  -- dac0 data value
    ---------------------------------------------------------------------
    -- output @i_out_clk
    ---------------------------------------------------------------------
    i_out_clk             : in std_logic;  -- data clock (IO pin side)
    i_out_clk_div         : in std_logic;  -- data clock @i_out_clk/4 (DDR mode) (IO user side)
    i_out_clk_phase90     : in std_logic;  -- clock signal (@i_out_clk + add 90 degree phase) (IO pin side)
    i_out_clk_div_phase90 : in std_logic;  -- clock signal (i_out_clk divided by 2 + add 90 degree phase) (IO user side)

    -- from reset_top: @i_out_clk
    i_io_rst         : in  std_logic;   -- large reset pulse width
    -- from reset_top: @i_out_clk_phase90
    i_io_rst_phase90 : in  std_logic;   -- large reset pulse width
    -- to pads:
    -- clock
    o_dac_clk_p      : out std_logic;   -- output differential_p dac clock
    o_dac_clk_n      : out std_logic;   -- output differential_n dac clock
    -- frame flag
    o_dac_frame_p    : out std_logic;   -- output differential_p dac frame
    o_dac_frame_n    : out std_logic;   -- output differential_n dac frame
    -- data
    o_dac0_p         : out std_logic;  -- output differential_p dac data (bit0)
    o_dac0_n         : out std_logic;  -- output differential_n dac data (bit0)

    o_dac1_p : out std_logic;  -- output differential_p dac data (bit1)
    o_dac1_n : out std_logic;  -- output differential_n dac data (bit1)

    o_dac2_p : out std_logic;  -- output differential_p dac data (bit2)
    o_dac2_n : out std_logic;  -- output differential_n dac data (bit2)

    o_dac3_p : out std_logic;  -- output differential_p dac data (bit3)
    o_dac3_n : out std_logic;  -- output differential_n dac data (bit3)

    o_dac4_p : out std_logic;  -- output differential_p dac data (bit4)
    o_dac4_n : out std_logic;  -- output differential_n dac data (bit4)

    o_dac5_p : out std_logic;  -- output differential_p dac data (bit5)
    o_dac5_n : out std_logic;  -- output differential_n dac data (bit5)

    o_dac6_p : out std_logic;  -- output differential_p dac data (bit6)
    o_dac6_n : out std_logic;  -- output differential_n dac data (bit6)

    o_dac7_p : out std_logic;  -- output differential_p dac data (bit7)
    o_dac7_n : out std_logic;  -- output differential_n dac data (bit7)

    ---------------------------------------------------------------------
    -- output/status: @i_clk
    ---------------------------------------------------------------------
    o_errors : out std_logic_vector(15 downto 0);  -- output errors
    o_status : out std_logic_vector(7 downto 0)    -- output status
    );
end entity io_dac;

architecture RTL of io_dac is

  -- add an additional output latency (expressed in number of clock periods)
  constant c_OUTPUT_LATENCY   : natural := pkg_IO_DAC_OUT_LATENCY;
  -- output dac width (expressed in bits)
  constant c_DAC_OUTPUT_WIDTH : integer := 8;  -- number of output differential pairs

  ---------------------------------------------------------------------
  -- dac_data_insert
  ---------------------------------------------------------------------
  -- dac_valid
  signal dac_valid_tmp0 : std_logic;
  -- dac_frame
  signal dac_frame_tmp0 : std_logic_vector(7 downto 0);
  -- dac data
  signal dac_tmp0       : std_logic_vector(63 downto 0);

  signal errors_tmp0 : std_logic_vector(o_errors'range); -- errors
  signal status_tmp0 : std_logic_vector(o_status'range); -- status

  ---------------------------------------------------------------------
  -- optionnally add latency
  ---------------------------------------------------------------------
  constant c_IDX0_L : integer := 0; -- index0: low
  constant c_IDX0_H : integer := c_IDX0_L + dac_tmp0'length - 1; -- index0: high

  constant c_IDX1_L : integer := c_IDX0_H + 1; -- index1: low
  constant c_IDX1_H : integer := c_IDX1_L + dac_frame_tmp0'length - 1; -- index1: high

  constant c_IDX2_L : integer := c_IDX1_H + 1; -- index2: low
  constant c_IDX2_H : integer := c_IDX2_L + 1 - 1; -- index2: high

  -- temporary input pipe
  signal data_pipe_tmp0 : std_logic_vector(c_IDX2_H downto 0);
  -- temporary output pipe
  signal data_pipe_tmp1 : std_logic_vector(c_IDX2_H downto 0);

  -- data_valid
  signal dac_valid_tmp1 : std_logic;
  -- dac_frame
  signal dac_frame_tmp1 : std_logic_vector(7 downto 0);
  -- dac value
  signal dac_tmp1       : std_logic_vector(63 downto 0);

  ---------------------------------------------------------------------
  -- oddr
  ---------------------------------------------------------------------
  -- dac clock_p
  signal dac_clk_p : std_logic;
  -- dac clock_n
  signal dac_clk_n : std_logic;

  -- dac frame_p
  signal dac_frame_p : std_logic;
  -- dac frame_n
  signal dac_frame_n : std_logic;

  -- dac_p
  signal dac_p : std_logic_vector(c_DAC_OUTPUT_WIDTH - 1 downto 0);
  -- dac_n
  signal dac_n : std_logic_vector(c_DAC_OUTPUT_WIDTH - 1 downto 0);

begin

  inst_io_dac_data_insert : entity work.io_dac_data_insert
    port map(
      ---------------------------------------------------------------------
      -- input @i_clk
      ---------------------------------------------------------------------
      i_clk         => i_clk,
      i_rst         => i_rst,
      i_rst_status  => i_rst_status,
      i_debug_pulse => i_debug_pulse,
      i_dac_valid   => i_dac_valid,
      i_dac_frame   => i_dac_frame,
      i_dac1        => i_dac1,
      i_dac0        => i_dac0,
      ---------------------------------------------------------------------
      -- output @i_dac_clk
      ---------------------------------------------------------------------
      i_dac_clk     => i_out_clk_div,
      o_dac_valid   => dac_valid_tmp0,
      o_dac_frame   => dac_frame_tmp0,
      o_dac         => dac_tmp0,
      ---------------------------------------------------------------------
      -- errors/status @i_clk
      ---------------------------------------------------------------------
      o_errors      => errors_tmp0,
      o_status      => status_tmp0
      );



  ---------------------------------------------------------------------
  -- optionnally add latency before output IOs
  ---------------------------------------------------------------------
  data_pipe_tmp0(c_IDX2_H)                 <= dac_valid_tmp0;
  data_pipe_tmp0(c_IDX1_H downto c_IDX1_L) <= dac_frame_tmp0;
  data_pipe_tmp0(c_IDX0_H downto c_IDX0_L) <= dac_tmp0;
  inst_pipeliner_add_output_latency : entity work.pipeliner
    generic map(
      g_NB_PIPES   => c_OUTPUT_LATENCY,  -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => data_pipe_tmp0'length  -- width of the input/output data.  Possibles values: [1, integer max value[
      )
    port map(
      i_clk  => i_out_clk_div,
      i_data => data_pipe_tmp0,
      o_data => data_pipe_tmp1
      );

  dac_valid_tmp1 <= data_pipe_tmp1(c_IDX2_H);
  dac_frame_tmp1 <= data_pipe_tmp1(c_IDX1_H downto c_IDX1_L);
  dac_tmp1       <= data_pipe_tmp1(c_IDX0_H downto c_IDX0_L);

---------------------------------------------------------------------
-- generate io_dac_clk
---------------------------------------------------------------------
  gen_io_dac_clk : if true generate
    signal dac_tmp2   : std_logic_vector(7 downto 0);
    signal clk_p_tmp2 : std_logic_vector(0 downto 0);
    signal clk_n_tmp2 : std_logic_vector(0 downto 0);
  begin

    dac_tmp2(7) <= '0';                 -- clock value at the 4th neg edge
    dac_tmp2(6) <= '1';                 -- clock value at the 4th pos edge
    dac_tmp2(5) <= '0';                 -- clock value at the 3rd neg edge
    dac_tmp2(4) <= '1';                 -- clock value at the 3rd pos edge
    dac_tmp2(3) <= '0';                 -- clock value at the 2nd neg edge
    dac_tmp2(2) <= '1';                 -- clock value at the 2nd pos edge
    dac_tmp2(1) <= '0';                 -- clock value at the 1st neg edge
    dac_tmp2(0) <= '1';                 -- clock value at the 1st pos edge

    inst_selectio_wiz_dac_clk : entity work.selectio_wiz_dac_clk
      port map
      (
        data_out_from_device => dac_tmp2,
        data_out_to_pins_p   => clk_p_tmp2,
        data_out_to_pins_n   => clk_n_tmp2,
        clk_in               => i_out_clk_phase90,
        clk_div_in           => i_out_clk_div_phase90,
        io_reset             => i_io_rst_phase90
        );

    dac_clk_p <= clk_p_tmp2(0);
    dac_clk_n <= clk_n_tmp2(0);
  end generate gen_io_dac_clk;

---------------------------------------------------------------------
-- generate io_dac
---------------------------------------------------------------------
  gen_io_dac : if true generate
    signal dac_tmp2 : std_logic_vector(dac_tmp1'range);
  begin
    dac_tmp2 <= dac_tmp1;
    inst_selectio_wiz_dac : entity work.selectio_wiz_dac
      port map(
        data_out_from_device => dac_tmp2,
        data_out_to_pins_p   => dac_p,
        data_out_to_pins_n   => dac_n,

        clk_in     => i_out_clk,
        clk_div_in => i_out_clk_div,
        io_reset   => i_io_rst
        );

  end generate gen_io_dac;

---------------------------------------------------------------------
-- generate io_dac_frame
---------------------------------------------------------------------
  gen_io_dac_frame : if true generate
    signal dac_tmp2         : std_logic_vector(7 downto 0);
    signal dac_frame_p_tmp2 : std_logic_vector(0 downto 0);
    signal dac_frame_n_tmp2 : std_logic_vector(0 downto 0);
  begin
    dac_tmp2 <= dac_frame_tmp1;

    inst_selectio_wiz_dac_frame : entity work.selectio_wiz_dac_frame
      port map(
        data_out_from_device => dac_tmp2,
        data_out_to_pins_p   => dac_frame_p_tmp2,
        data_out_to_pins_n   => dac_frame_n_tmp2,
        clk_in               => i_out_clk,
        clk_div_in           => i_out_clk_div,
        io_reset             => i_io_rst
        );

    dac_frame_p <= dac_frame_p_tmp2(0);
    dac_frame_n <= dac_frame_n_tmp2(0);
  end generate gen_io_dac_frame;

  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  -- dac: clk
  o_dac_clk_p <= dac_clk_p;
  o_dac_clk_n <= dac_clk_n;

  -- dac: frame
  o_dac_frame_p <= dac_frame_p;
  o_dac_frame_n <= dac_frame_n;

  -- dac: bit0
  o_dac0_p <= dac_p(0);
  o_dac0_n <= dac_n(0);

  -- dac: bit1
  o_dac1_p <= dac_p(1);
  o_dac1_n <= dac_n(1);

  -- dac: bit2
  o_dac2_p <= dac_p(2);
  o_dac2_n <= dac_n(2);

  -- dac: bit3
  o_dac3_p <= dac_p(3);
  o_dac3_n <= dac_n(3);

  -- dac: bit4
  o_dac4_p <= dac_p(4);
  o_dac4_n <= dac_n(4);

  -- dac: bit5
  o_dac5_p <= dac_p(5);
  o_dac5_n <= dac_n(5);

  -- dac: bit6
  o_dac6_p <= dac_p(6);
  o_dac6_n <= dac_n(6);

  -- dac: bit7
  o_dac7_p <= dac_p(7);
  o_dac7_n <= dac_n(7);


  ---------------------------------------------------------------------
  -- errors/status
  ---------------------------------------------------------------------
  o_errors(15 downto 0) <= errors_tmp0(15 downto 0);
  o_status              <= status_tmp0;

end architecture RTL;
