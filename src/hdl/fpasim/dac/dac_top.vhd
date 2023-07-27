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
--    @file                   dac_top.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--   @details
--
--   This module generates frame flags.
--   It has 2 modes:
--     . normal mode (i_dac_en_pattern=0):
--        . After the startup, on the first sample, it generates a pulse on the sof signal one time.
--        . the input data flow are duplicated on the o_data0 and o_data1 signals
--     . pattern mode (i_dac_en_pattern=1): (see dac3283 datasheet (figure 34)).
--        . After the startup, on the first sample, it generates a pulse on the sof signal one time.
--        . The input data is ignored
--        . The input data valid drive the pattern generation.
--        . It periodically generates the following 2 sequences:
--           . sequence0: it generate a pulse on the sof signal
--              . o_dac0(15 downto 8) <= pkg_DAC_PATTERN0;
--              . o_dac0(7 downto 0) <= pkg_DAC_PATTERN1;
--              . o_dac1(15 downto 8) <= pkg_DAC_PATTERN2;
--              . o_dac1(7 downto 0) <= pkg_DAC_PATTERN3;
--           . sequence1:
--              . o_dac0(15 downto 8) <= pkg_DAC_PATTERN4;
--              . o_dac0(7 downto 0) <= pkg_DAC_PATTERN5;
--              . o_dac1(15 downto 8) <= pkg_DAC_PATTERN6;
--              . o_dac1(7 downto 0) <= pkg_DAC_PATTERN7;
--
--   The output data flow has the following structure:
--
--   Example0: normal mode
--     i_dac_valid:   1   1   1   1   1   1   1   1
--     i_dac      :   a1  a2  a3  a4  a5  a6  a7  a8
--     o_dac_valid:   1   1   1   1   1   1   1   1
--     o_dac_frame:   1   0   0   0   0   0   0   0
--     o_dac0      :  a1  a2  a3  a4  a5  a6  a7  a8
--     o_dac1      :  a1  a2  a3  a4  a5  a6  a7  a8
--
--   Example1: pattern mode (input data is ignored)
--     i_dac_valid      :   1              1           1         1
--     i_dac            :   a1             a2          a3        a4
--     o_dac_valid      :   1              1           1         1
--     o_dac_frame      :   1              0           0         0
--     o_dac0 (MSB-LSB) :  pat0-pat1  pat4-pat5  pat0-pat1  pat4-pat5
--     o_dac1 (MSB-LSB) :  pat2-pat3  pat6-pat7  pat2-pat3  pat6-pat7
--
-- -------------------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

use work.pkg_fpasim.all;


entity dac_top is
  generic(
    g_DAC_DELAY_WIDTH : positive := 6  -- delay bus width (expressed in bits). Possible values [1; max integer value[
    );
  port(
    ---------------------------------------------------------------------
    -- input
    ---------------------------------------------------------------------
    i_clk            : in  std_logic;   -- clock
    i_rst            : in  std_logic;   -- reset
    -- from regdecode
    -----------------------------------------------------------------
    i_dac_en_pattern : in  std_logic;  --'1': enable dac pattern generation, '0': normal mode:use the input data flow
    i_dac_pattern0   : in  std_logic_vector(7 downto 0);  -- pattern0 value
    i_dac_pattern1   : in  std_logic_vector(7 downto 0);  -- pattern1 value
    i_dac_pattern2   : in  std_logic_vector(7 downto 0);  -- pattern2 value
    i_dac_pattern3   : in  std_logic_vector(7 downto 0);  -- pattern3 value
    i_dac_pattern4   : in  std_logic_vector(7 downto 0);  -- pattern4 value
    i_dac_pattern5   : in  std_logic_vector(7 downto 0);  -- pattern5 value
    i_dac_pattern6   : in  std_logic_vector(7 downto 0);  -- pattern6 value
    i_dac_pattern7   : in  std_logic_vector(7 downto 0);  -- pattern7 value
    -- delay
    i_dac_delay      : in  std_logic_vector(g_DAC_DELAY_WIDTH - 1 downto 0);  -- delay to apply on the data path.
    -- input data
    ---------------------------------------------------------------------
    i_dac_valid      : in  std_logic;   -- valid dac sample flag
    i_dac            : in  std_logic_vector(15 downto 0);  -- dac sample
    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    o_dac_valid      : out std_logic;   -- valid dac sample
    o_dac_frame      : out std_logic;   -- first sample of a frame
    o_dac1           : out std_logic_vector(15 downto 0);  -- output dac1 sample
    o_dac0           : out std_logic_vector(15 downto 0)  -- output dac0 sample
    );
end entity dac_top;

architecture RTL of dac_top is

  -- optional output latency
  constant c_LATENCY_OUT : natural := pkg_DAC_OUT_LATENCY;

  ---------------------------------------------------------------------
  -- dac_frame_generator
  ---------------------------------------------------------------------
  signal dac_frame_r1 : std_logic; -- dac frame valid
  signal dac_valid_r1 : std_logic; -- dac data valid
  signal dac0_r1      : std_logic_vector(i_dac'range); -- dac0 value
  signal dac1_r1      : std_logic_vector(i_dac'range); -- dac1 value

  ---------------------------------------------------------------------
  -- dynamic_shift_register
  ---------------------------------------------------------------------
  constant c_IDX0_L : integer := 0;-- index0: low
  constant c_IDX0_H : integer := c_IDX0_L + i_dac'length - 1;-- index0: high

  constant c_IDX1_L : integer := c_IDX0_H + 1;-- index1: low
  constant c_IDX1_H : integer := c_IDX1_L + i_dac'length - 1;-- index1: high

  constant c_IDX2_L : integer := c_IDX1_H + 1;-- index2: low
  constant c_IDX2_H : integer := c_IDX2_L + 1 - 1;-- index2: high

  constant c_IDX3_L : integer := c_IDX2_H + 1;-- index3: low
  constant c_IDX3_H : integer := c_IDX3_L + 1 - 1;-- index3: high

  signal data_pipe_tmp0 : std_logic_vector(c_IDX3_H downto 0);-- temporary input pipe
  signal data_pipe_tmp1 : std_logic_vector(c_IDX3_H downto 0);-- temporary output pipe

  signal dac_valid_rx : std_logic; -- dac data value
  signal dac_frame_rx : std_logic; -- dac frame
  signal dac0_rx      : std_logic_vector(i_dac'range); -- dac0 value
  signal dac1_rx      : std_logic_vector(i_dac'range); -- dac1 value

  ---------------------------------------------------------------------
  -- output pipe
  ---------------------------------------------------------------------
  signal data_pipe_tmp2 : std_logic_vector(c_IDX3_H downto 0); -- temporary input pipe
  signal data_pipe_tmp3 : std_logic_vector(c_IDX3_H downto 0); -- temporary output pipe

  signal dac_valid_ry : std_logic; -- dac data value
  signal dac_frame_ry : std_logic; -- dac frame
  signal dac0_ry      : std_logic_vector(i_dac'range); -- dac0 value
  signal dac1_ry      : std_logic_vector(i_dac'range); -- dac1 value


begin


  ---------------------------------------------------------------------
  -- build the frame signal
  ---------------------------------------------------------------------
  inst_dac_frame_generator : entity work.dac_frame_generator
    port map(
      i_clk => i_clk,                   -- clock signal
      i_rst => i_rst,
      ---------------------------------------------------------------------
      -- command
      ---------------------------------------------------------------------
      i_dac_en_pattern => i_dac_en_pattern,
      i_dac_pattern0   => i_dac_pattern0,
      i_dac_pattern1   => i_dac_pattern1,
      i_dac_pattern2   => i_dac_pattern2,
      i_dac_pattern3   => i_dac_pattern3,
      i_dac_pattern4   => i_dac_pattern4,
      i_dac_pattern5   => i_dac_pattern5,
      i_dac_pattern6   => i_dac_pattern6,
      i_dac_pattern7   => i_dac_pattern7,
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_data_valid     => i_dac_valid,   -- input valid sample
      i_data           => i_dac,
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_sof            => dac_frame_r1,  -- first sample of the frame
      o_data_valid     => dac_valid_r1,  -- output valid sample
      o_data1          => dac1_r1,
      o_data0          => dac0_r1
      );


  ---------------------------------------------------------------------
  -- apply a dynamic delay on the data path
  --   . the latency is 1 clock cycle when i_dac_delay = 0
  -- requirement: FPASIM-FW-REQ-0230
  ---------------------------------------------------------------------
  data_pipe_tmp0(c_IDX3_H)                 <= dac_valid_r1;
  data_pipe_tmp0(c_IDX2_H)                 <= dac_frame_r1;
  data_pipe_tmp0(c_IDX1_H downto c_IDX1_L) <= dac1_r1;
  data_pipe_tmp0(c_IDX0_H downto c_IDX0_L) <= dac0_r1;

  inst_dynamic_shift_register_dac : entity work.dynamic_shift_register
    generic map(
      g_ADDR_WIDTH => i_dac_delay'length,  -- width of the address. Possibles values: [2, integer max value[
      g_DATA_WIDTH => data_pipe_tmp0'length  -- width of the input/output data.  Possibles values: [1, integer max value[
      )
    port map(
      i_clk  => i_clk,                  -- clock signal
      i_data => data_pipe_tmp0,         -- input data
      i_addr => i_dac_delay,  -- input address (dynamically select the depth of the pipeline)
      o_data => data_pipe_tmp1          -- output data with/without delay
      );

  dac_valid_rx <= data_pipe_tmp1(c_IDX3_H);
  dac_frame_rx <= data_pipe_tmp1(c_IDX2_H);
  dac1_rx      <= data_pipe_tmp1(c_IDX1_H downto c_IDX1_L);
  dac0_rx      <= data_pipe_tmp1(c_IDX0_H downto c_IDX0_L);


  ---------------------------------------------------------------------
  -- optionnal output pipe
  ---------------------------------------------------------------------
  data_pipe_tmp2(c_IDX3_H)                 <= dac_valid_rx;
  data_pipe_tmp2(c_IDX2_H)                 <= dac_frame_rx;
  data_pipe_tmp2(c_IDX1_H downto c_IDX1_L) <= dac1_rx;
  data_pipe_tmp2(c_IDX0_H downto c_IDX0_L) <= dac0_rx;

  inst_pipeliner : entity work.pipeliner
    generic map(
      g_NB_PIPES   => c_LATENCY_OUT,
      g_DATA_WIDTH => data_pipe_tmp2'length
      )
    port map(
      i_clk  => i_clk,
      i_data => data_pipe_tmp2,
      o_data => data_pipe_tmp3
      );
  dac_valid_ry <= data_pipe_tmp3(c_IDX3_H);
  dac_frame_ry <= data_pipe_tmp3(c_IDX2_H);
  dac1_ry      <= data_pipe_tmp3(c_IDX1_H downto c_IDX1_L);
  dac0_ry      <= data_pipe_tmp3(c_IDX0_H downto c_IDX0_L);



  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_dac_valid <= dac_valid_ry;
  o_dac_frame <= dac_frame_ry;
  o_dac1      <= dac1_ry;
  o_dac0      <= dac0_ry;

end architecture RTL;
