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
--    @file                   amp_squid_top.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This module is the top level of the amp_squid function
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.pkg_fpasim.all;

entity amp_squid_top is
  generic(
    -- pixel
    g_PIXEL_ID_WIDTH              : positive := pkg_NB_PIXEL_BY_FRAME_MAX_WIDTH;  -- pixel id bus width (expressed in bits). Possible values [1; max integer value[
    -- frame
    g_FRAME_ID_WIDTH              : positive := pkg_NB_FRAME_BY_PULSE_SHAPE_WIDTH;  -- frame id bus width (expressed in bits). Possible values [1; max integer value[
    -- address
    g_AMP_SQUID_TF_RAM_ADDR_WIDTH : positive := pkg_AMP_SQUID_TF_RAM_ADDR_WIDTH;  -- address bus width (expressed in bits)
    -- computation
    g_PIXEL_RESULT_INPUT_WIDTH    : positive := pkg_MUX_SQUID_MULT_ADD_Q_WIDTH_S;  -- pixel input result bus width (expressed in bits). Possible values [1; max integer value[
    g_PIXEL_RESULT_OUTPUT_WIDTH   : positive := pkg_AMP_SQUID_Q_WIDTH  -- pixel output bus width (expressed in bits). Possible values [1; max integer value[
    );
  port(
    i_clk         : in std_logic;       -- clock
    i_rst_status  : in std_logic;       -- reset error flag(s)
    i_debug_pulse : in std_logic;  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)

    ---------------------------------------------------------------------
    -- input command: from the regdecode
    ---------------------------------------------------------------------
    -- RAM: amp_squid_tf
    -- wr
    i_amp_squid_tf_wr_en      : in  std_logic;  -- write enable
    i_amp_squid_tf_wr_rd_addr : in  std_logic_vector(g_AMP_SQUID_TF_RAM_ADDR_WIDTH - 1 downto 0);  -- write/read address
    i_amp_squid_tf_wr_data    : in  std_logic_vector(15 downto 0);  -- write data
    -- rd
    i_amp_squid_tf_rd_en      : in  std_logic;  -- read enable
    o_amp_squid_tf_rd_valid   : out std_logic;  -- read data valid
    o_amp_squid_tf_rd_data    : out std_logic_vector(15 downto 0);  -- read data

    ---------------------------------------------------------------------
    -- input1
    ---------------------------------------------------------------------
    i_pixel_sof    : in std_logic;      -- first pixel sample
    i_pixel_eof    : in std_logic;      -- last pixel sample
    i_pixel_valid  : in std_logic;      -- valid pixel sample
    i_pixel_id     : in std_logic_vector(g_PIXEL_ID_WIDTH - 1 downto 0);  -- pixel id
    i_pixel_result : in std_logic_vector(g_PIXEL_RESULT_INPUT_WIDTH - 1 downto 0);  -- pixel result
    i_frame_sof    : in std_logic;      -- first frame sample
    i_frame_eof    : in std_logic;      -- last frame sample
    i_frame_id     : in std_logic_vector(g_FRAME_ID_WIDTH - 1 downto 0);  -- frame id

    ---------------------------------------------------------------------
    -- input2
    ---------------------------------------------------------------------
    i_amp_squid_offset_correction : in  std_logic_vector(13 downto 0);  -- amp squid offset value (from adc)
    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    o_pixel_sof                   : out std_logic;  -- first pixel sample
    o_pixel_eof                   : out std_logic;  -- last pixel sample
    o_pixel_valid                 : out std_logic;  -- valid pixel sample
    o_pixel_id                    : out std_logic_vector(g_PIXEL_ID_WIDTH - 1 downto 0);  -- pixel id
    o_pixel_result                : out std_logic_vector(g_PIXEL_RESULT_OUTPUT_WIDTH - 1 downto 0);  -- pixel result
    o_frame_sof                   : out std_logic;  -- first frame sample
    o_frame_eof                   : out std_logic;  -- last frame sample
    o_frame_id                    : out std_logic_vector(g_FRAME_ID_WIDTH - 1 downto 0);  -- frame id
    ---------------------------------------------------------------------
    -- errors/status
    ---------------------------------------------------------------------
    o_errors                      : out std_logic_vector(15 downto 0);  -- output errors
    o_status                      : out std_logic_vector(7 downto 0)  -- output status
    );
end entity amp_squid_top;

architecture RTL of amp_squid_top is

  ---------------------------------------------------------------------
  -- mux_squid
  ---------------------------------------------------------------------
  signal amp_squid_tf_rd_valid : std_logic; -- ram read data valid
  signal amp_squid_tf_rd_data  : std_logic_vector(o_amp_squid_tf_rd_data'range); -- ram read data

  signal pixel_sof    : std_logic; -- first pixel sample
  signal pixel_eof    : std_logic; -- last pixel sample
  signal pixel_valid  : std_logic; -- valid pixel sample
  signal pixel_id     : std_logic_vector(o_pixel_id'range); -- pixel id
  signal pixel_result : std_logic_vector(o_pixel_result'range); -- pixel result value

  signal errors : std_logic_vector(o_errors'range); -- errors
  signal status : std_logic_vector(o_status'range); -- status

  ---------------------------------------------------------------------
  -- sync with sub_sfixed_mux_squid out
  ---------------------------------------------------------------------
  constant c_IDX0_L : integer := 0; -- index0: low
  constant c_IDX0_H : integer := c_IDX0_L + i_frame_id'length - 1; -- index0: high

  constant c_IDX1_L : integer := c_IDX0_H + 1; -- index1: low
  constant c_IDX1_H : integer := c_IDX1_L + 1 - 1; -- index1: high

  constant c_IDX2_L : integer := c_IDX1_H + 1; -- index2: low
  constant c_IDX2_H : integer := c_IDX2_L + 1 - 1; -- index2: high

  -- temporary input pipe
  signal data_pipe_tmp0 : std_logic_vector(c_IDX2_H downto 0);
  -- temporary output pipe
  signal data_pipe_tmp1 : std_logic_vector(c_IDX2_H downto 0);

  signal frame_sof : std_logic; -- first frame sample
  signal frame_eof : std_logic; -- last frame sample
  signal frame_id  : std_logic_vector(i_frame_id'range); -- frame id

begin

  inst_amp_squid : entity work.amp_squid
    generic map(
      -- pixel
      g_PIXEL_ID_WIDTH              => i_pixel_id'length,
      -- address
      g_AMP_SQUID_TF_RAM_ADDR_WIDTH => i_amp_squid_tf_wr_rd_addr'length,
      -- computation
      g_PIXEL_RESULT_INPUT_WIDTH    => i_pixel_result'length,
      g_PIXEL_RESULT_OUTPUT_WIDTH   => pixel_result'length,
      -- RAM configuration filename
      g_AMP_SQUID_TF_RAM_MEMORY_INIT_FILE => pkg_AMP_SQUID_TF_RAM_MEMORY_INIT_FILE
      )
    port map(
      i_clk                         => i_clk,
      i_rst_status                  => i_rst_status,
      i_debug_pulse                 => i_debug_pulse,
      ---------------------------------------------------------------------
      -- input command: from the regdecode
      ---------------------------------------------------------------------
      -- RAM: amp_squid_tf
      -- wr
      i_amp_squid_tf_wr_en          => i_amp_squid_tf_wr_en,
      i_amp_squid_tf_wr_rd_addr     => i_amp_squid_tf_wr_rd_addr,
      i_amp_squid_tf_wr_data        => i_amp_squid_tf_wr_data,
      -- rd
      i_amp_squid_tf_rd_en          => i_amp_squid_tf_rd_en,
      o_amp_squid_tf_rd_valid       => amp_squid_tf_rd_valid,
      o_amp_squid_tf_rd_data        => amp_squid_tf_rd_data,
      ---------------------------------------------------------------------
      -- input1
      ---------------------------------------------------------------------
      i_pixel_sof                   => i_pixel_sof,
      i_pixel_eof                   => i_pixel_eof,
      i_pixel_valid                 => i_pixel_valid,
      i_pixel_id                    => i_pixel_id,
      i_pixel_result                => i_pixel_result,
      ---------------------------------------------------------------------
      -- input2
      ---------------------------------------------------------------------
      i_amp_squid_offset_correction => i_amp_squid_offset_correction,
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_pixel_sof                   => pixel_sof,
      o_pixel_eof                   => pixel_eof,
      o_pixel_valid                 => pixel_valid,
      o_pixel_id                    => pixel_id,
      o_pixel_result                => pixel_result,
      ---------------------------------------------------------------------
      -- errors/status
      ---------------------------------------------------------------------
      o_errors                      => errors,
      o_status                      => status
      );

  -----------------------------------------------------------------
  -- sync with amp_squid out
  -----------------------------------------------------------------
  data_pipe_tmp0(c_IDX2_H)                 <= i_frame_sof;
  data_pipe_tmp0(c_IDX1_H)                 <= i_frame_eof;
  data_pipe_tmp0(c_IDX0_H downto c_IDX0_L) <= i_frame_id;
  inst_pipeliner_sync_with_amp_squid_out : entity work.pipeliner
    generic map(
      g_NB_PIPES   => pkg_AMP_SQUID_LATENCY,  -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => data_pipe_tmp0'length  -- width of the input/output data.  Possibles values: [1, integer max value[
      )
    port map(
      i_clk  => i_clk,                  -- clock signal
      i_data => data_pipe_tmp0,         -- input data
      o_data => data_pipe_tmp1          -- output data with/without delay
      );

  frame_sof <= data_pipe_tmp1(c_IDX2_H);
  frame_eof <= data_pipe_tmp1(c_IDX1_H);
  frame_id  <= data_pipe_tmp1(c_IDX0_H downto c_IDX0_L);

  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  -- rd amp squid tf
  o_amp_squid_tf_rd_valid <= amp_squid_tf_rd_valid;
  o_amp_squid_tf_rd_data  <= amp_squid_tf_rd_data;

  o_pixel_sof    <= pixel_sof;
  o_pixel_eof    <= pixel_eof;
  o_pixel_valid  <= pixel_valid;
  o_pixel_id     <= pixel_id;
  o_pixel_result <= pixel_result;
  o_frame_sof    <= frame_sof;
  o_frame_eof    <= frame_eof;
  o_frame_id     <= frame_id;

  o_errors <= errors;
  o_status <= status;

end architecture RTL;
