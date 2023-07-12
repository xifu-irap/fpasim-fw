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
--    @file                   tes_top.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This module is the top_level of the tes funcion
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_fpasim.all;
use work.pkg_regdecode.all;

entity tes_top is
  generic(
    -- command
    g_CMD_PULSE_HEIGHT_WIDTH        : positive := pkg_MAKE_PULSE_PULSE_HEIGHT_WIDTH;  -- pulse_heigth bus width (expressed in bits). Possible values [1;max integer value[
    g_CMD_TIME_SHIFT_WIDTH          : positive := pkg_MAKE_PULSE_TIME_SHIFT_WIDTH;  -- time_shift bus width (expressed in bits). Possible values [1;max integer value[
    g_CMD_PIXEL_ID_WIDTH            : positive := pkg_MAKE_PULSE_PIXEL_ID_WIDTH;  -- pixel id bus width (expressed in bits). Possible values [1;max integer value[
    -- pixel
    g_NB_SAMPLE_BY_PIXEL_WIDTH      : positive := 6;  -- bus width in order to define the number of samples by pixel
    -- frame
    g_NB_SAMPLE_BY_FRAME_WIDTH      : positive := 11;  -- bus width in order to define the number of samples by frame
    g_NB_FRAME_BY_PULSE_SHAPE_WIDTH : positive := pkg_NB_FRAME_BY_PULSE_SHAPE_WIDTH;  -- frame id bus width (expressed in bits). Possible values [1;max integer value[
    g_NB_FRAME_BY_PULSE_SHAPE       : positive := pkg_NB_FRAME_BY_PULSE_SHAPE;  -- number of frame by pulse shape
    -- addr
    g_PULSE_SHAPE_RAM_ADDR_WIDTH    : positive := pkg_TES_PULSE_SHAPE_RAM_ADDR_WIDTH;  -- address bus width (expressed in bits)
    -- output
    g_PIXEL_RESULT_OUTPUT_WIDTH     : positive := pkg_TES_MULT_SUB_Q_WIDTH_S  -- pixel output result bus width (expressed in bit). Possible values [1;max integer value[
    );

  port(
    i_clk : in std_logic;               -- clock signal
    i_rst : in std_logic;               -- reset signal

    i_rst_status  : in std_logic;       -- reset error flag(s)
    i_debug_pulse : in std_logic;  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)

    ---------------------------------------------------------------------
    -- input command: from the regdecode
    ---------------------------------------------------------------------
    i_en                     : in  std_logic;  -- enable
    i_nb_sample_by_pixel     : in  std_logic_vector(g_NB_SAMPLE_BY_PIXEL_WIDTH - 1 downto 0);  -- number of samples by pixel
    i_nb_pixel_by_frame      : in  std_logic_vector(g_CMD_PIXEL_ID_WIDTH - 1 downto 0);  -- number of pixel by frame (column)
    i_nb_sample_by_frame     : in  std_logic_vector(g_NB_SAMPLE_BY_FRAME_WIDTH - 1 downto 0);  -- number of samples by frame (column)
    -- command
    i_cmd_valid              : in  std_logic;  -- valid command
    i_cmd_pulse_height       : in  std_logic_vector(g_CMD_PULSE_HEIGHT_WIDTH - 1 downto 0);  -- pulse height command
    i_cmd_pixel_id           : in  std_logic_vector(g_CMD_PIXEL_ID_WIDTH - 1 downto 0);  -- pixel id command
    i_cmd_time_shift         : in  std_logic_vector(g_CMD_TIME_SHIFT_WIDTH - 1 downto 0);  -- time shift command
    o_cmd_ready              : out std_logic; -- ready to receive a new command
    -- RAM: pulse shape
    -- wr
    i_pulse_shape_wr_en      : in  std_logic;  -- RAM write enable
    i_pulse_shape_wr_rd_addr : in  std_logic_vector(g_PULSE_SHAPE_RAM_ADDR_WIDTH - 1 downto 0);  -- RAM write address
    i_pulse_shape_wr_data    : in  std_logic_vector(15 downto 0);  -- RAM write data
    -- rd
    i_pulse_shape_rd_en      : in  std_logic;  -- RAM read enable
    o_pulse_shape_rd_valid   : out std_logic;  -- RAM read data valid
    o_pulse_shape_rd_data    : out std_logic_vector(15 downto 0);  -- RAM read data

    -- RAM:
    -- wr
    i_steady_state_wr_en      : in  std_logic;  -- RAM write enable
    i_steady_state_wr_rd_addr : in  std_logic_vector(g_CMD_PIXEL_ID_WIDTH - 1 downto 0);  -- RAM write address
    i_steady_state_wr_data    : in  std_logic_vector(15 downto 0);  -- RAM write data
    -- rd
    i_steady_state_rd_en      : in  std_logic;  -- RAM read enable
    o_steady_state_rd_valid   : out std_logic;  -- RAM read data valid
    o_steady_state_rd_data    : out std_logic_vector(15 downto 0);  -- RAM read data

    ---------------------------------------------------------------------
    -- from the adc
    ---------------------------------------------------------------------
    i_data_valid : in std_logic;        --  input valid data

    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    o_pulse_sof    : out std_logic;     -- first processed sample of a pulse
    o_pulse_eof    : out std_logic;     -- last processed sample of a pulse
    o_pixel_sof    : out std_logic;     -- first pixel sample
    o_pixel_eof    : out std_logic;     -- last pixel sample
    o_pixel_valid  : out std_logic;     -- valid pixel sample
    o_pixel_id     : out std_logic_vector(g_CMD_PIXEL_ID_WIDTH - 1 downto 0);  -- output pixel id
    o_pixel_result : out std_logic_vector(g_PIXEL_RESULT_OUTPUT_WIDTH - 1 downto 0);  -- output pixel result
    o_frame_sof    : out std_logic;     -- first frame sample
    o_frame_eof    : out std_logic;     -- last frame sample
    o_frame_id     : out std_logic_vector(g_NB_FRAME_BY_PULSE_SHAPE_WIDTH - 1 downto 0);  -- output frame id

    ---------------------------------------------------------------------
    -- output: detect negative output value
    ---------------------------------------------------------------------
    o_tes_pixel_neg_out_valid    : out std_logic; -- valid negative output
    o_tes_pixel_neg_out_error    : out std_logic; -- negative output detection
    o_tes_pixel_neg_out_pixel_id : out std_logic_vector(g_CMD_PIXEL_ID_WIDTH - 1 downto 0); -- pixel id when a negative output is detected

    ---------------------------------------------------------------------
    -- errors/status
    ---------------------------------------------------------------------
    o_errors : out std_logic_vector(15 downto 0);  -- output errors
    o_status : out std_logic_vector(7 downto 0)    -- output status
    );
end entity tes_top;

architecture RTL of tes_top is

  -- number of frame by pulse shape
  constant c_NB_FRAME_BY_PULSE_SHAPE : positive                           := g_NB_FRAME_BY_PULSE_SHAPE;
  -- Number of frame max by pulse_shape (start @0)
  constant c_FRAME_ID_SIZE           : std_logic_vector(o_frame_id'range) := std_logic_vector(to_unsigned(g_NB_FRAME_BY_PULSE_SHAPE - 1, o_frame_id'length));
  ---------------------------------------------------------------------
  -- tes_signalling
  ---------------------------------------------------------------------
  signal pixel_sof0                  : std_logic; -- first pixel sample
  signal pixel_eof0                  : std_logic; -- last pixel sample
  signal pixel_id0                   : std_logic_vector(o_pixel_id'range); -- pixel id
  signal pixel_valid0                : std_logic; -- valid pixel sample

  signal frame_sof0 : std_logic; -- first frame sample
  signal frame_eof0 : std_logic; -- last frame sample
  signal frame_id0  : std_logic_vector(o_frame_id'range); -- frame id

  ---------------------------------------------------------------------
  -- tes_pulse_shape_manager
  ---------------------------------------------------------------------
  signal cmd_ready             : std_logic;  -- ready to receive a new command
  signal pulse_shape_rd_valid1 : std_logic;  -- ram read valid
  signal pulse_shape_rd_data1  : std_logic_vector(o_pulse_shape_rd_data'range); -- ram read value

  signal steady_state_rd_valid1 : std_logic; -- ram read valid
  signal steady_state_rd_data1  : std_logic_vector(o_steady_state_rd_data'range); -- ram read value

  signal pulse_sof1    : std_logic;-- first processed sample of a pulse
  signal pulse_eof1    : std_logic;-- last processed sample of a pulse
  signal pixel_sof1    : std_logic; -- first pixel sample
  signal pixel_eof1    : std_logic; -- last pixel sample
  signal pixel_id1     : std_logic_vector(o_pixel_id'range); -- pixel_id
  signal pixel_valid1  : std_logic; -- valid pixel sample
  signal pixel_result1 : std_logic_vector(o_pixel_result'range);-- pixel result

  signal tes_pixel_neg_out_valid1    : std_logic; -- valid negative output
  signal tes_pixel_neg_out_error1    : std_logic; -- negative output detection
  signal tes_pixel_neg_out_pixel_id1 : std_logic_vector(o_tes_pixel_neg_out_pixel_id'range); -- pixel id when a negative output is detected

  signal status1 : std_logic_vector(o_status'range); -- status
  signal errors1 : std_logic_vector(o_errors'range); -- errors

  ---------------------------------------------------------------------
  -- sync with the tes_pulse_shape_manager out
  ---------------------------------------------------------------------
  constant c_IDX0_L : integer := 0; -- index0: low
  constant c_IDX0_H : integer := c_IDX0_L + o_frame_id'length - 1; -- index0: high

  constant c_IDX1_L : integer := c_IDX0_H + 1; -- index1: low
  constant c_IDX1_H : integer := c_IDX1_L + 1 - 1; -- index1: high

  constant c_IDX2_L : integer := c_IDX1_H + 1; -- index2: low
  constant c_IDX2_H : integer := c_IDX2_L + 1 - 1; -- index2: high

  -- temporary input pipe
  signal data_pipe_tmp0 : std_logic_vector(c_IDX2_H downto 0);
  -- temporary output pipe
  signal data_pipe_tmp1 : std_logic_vector(c_IDX2_H downto 0);

  signal frame_sof1 : std_logic; -- first frame sample
  signal frame_eof1 : std_logic; -- last frame sample
  signal frame_id1  : std_logic_vector(o_frame_id'range);-- frame_id

begin

  -------------------------------------------------------------------
  -- Generate pixel and frame flags
  -------------------------------------------------------------------
  inst_tes_signalling : entity work.tes_signalling
    generic map(
      -- pixel
      g_NB_SAMPLE_BY_PIXEL_WIDTH      => i_nb_sample_by_pixel'length,
      g_NB_PIXEL_BY_FRAME_WIDTH       => pixel_id0'length,
      -- frame
      g_NB_SAMPLE_BY_FRAME_WIDTH      => i_nb_sample_by_frame'length,
      g_NB_FRAME_BY_PULSE_SHAPE_WIDTH => frame_id0'length
      )
    port map(
      i_clk                => i_clk,
      i_rst                => i_rst,
      ---------------------------------------------------------------------
      -- Commands
      ---------------------------------------------------------------------
      i_start              => i_en,
      i_nb_sample_by_pixel => i_nb_sample_by_pixel,
      i_nb_pixel_by_frame  => i_nb_pixel_by_frame,
      i_nb_sample_by_frame => i_nb_sample_by_frame,
      i_nb_frame           => c_FRAME_ID_SIZE,
      ---------------------------------------------------------------------
      -- Input data
      ---------------------------------------------------------------------
      i_data_valid         => i_data_valid,
      ---------------------------------------------------------------------
      -- Output data
      ---------------------------------------------------------------------
      o_pixel_sof          => pixel_sof0,
      o_pixel_eof          => pixel_eof0,
      o_pixel_id           => pixel_id0,
      o_pixel_valid        => pixel_valid0,
      o_frame_sof          => frame_sof0,
      o_frame_eof          => frame_eof0,
      o_frame_id           => frame_id0
      );

  -----------------------------------------------------------------
  -- tes computation
  -----------------------------------------------------------------
  inst_tes_pulse_shape_manager : entity work.tes_pulse_shape_manager
    generic map(
      -- command
      g_CMD_PULSE_HEIGHT_WIDTH               => i_cmd_pulse_height'length,
      g_CMD_TIME_SHIFT_WIDTH                 => i_cmd_time_shift'length,
      g_CMD_PIXEL_ID_WIDTH                   => pixel_id0'length,
      -- frame
      g_NB_FRAME_BY_PULSE_SHAPE              => c_NB_FRAME_BY_PULSE_SHAPE,
      g_NB_SAMPLE_BY_FRAME_WIDTH             => pkg_NB_SAMPLE_BY_FRAME_WIDTH,
      -- addr
      g_PULSE_SHAPE_RAM_ADDR_WIDTH           => i_pulse_shape_wr_rd_addr'length,
      -- output
      g_PIXEL_RESULT_OUTPUT_WIDTH            => pixel_result1'length,
      -- RAM configuration filename
      g_TES_PULSE_SHAPE_RAM_MEMORY_INIT_FILE => pkg_TES_PULSE_SHAPE_RAM_MEMORY_INIT_FILE,
      g_TES_STD_STATE_RAM_MEMORY_INIT_FILE   => pkg_TES_STD_STATE_RAM_MEMORY_INIT_FILE
      )
    port map(
      i_clk                     => i_clk,        -- clock signal
      i_rst                     => i_rst,        -- reset signal
      i_rst_status              => i_rst_status,   -- reset error flags
      i_debug_pulse             => i_debug_pulse,  -- '1': delay error, '0': latch error
      ---------------------------------------------------------------------
      -- input command: from the regdecode
      ---------------------------------------------------------------------
      i_cmd_valid               => i_cmd_valid,  -- '1': command is valid, '0': otherwise
      i_cmd_pulse_height        => i_cmd_pulse_height,  -- pulse height value
      i_cmd_pixel_id            => i_cmd_pixel_id,      -- pixel id
      i_cmd_time_shift          => i_cmd_time_shift,    -- time shift value
      o_cmd_ready               => cmd_ready,
      -- RAM: pulse shape
      -- wr
      i_pulse_shape_wr_en       => i_pulse_shape_wr_en,     -- write enable
      i_pulse_shape_wr_rd_addr  => i_pulse_shape_wr_rd_addr,   -- write address
      i_pulse_shape_wr_data     => i_pulse_shape_wr_data,   -- write data
      -- rd
      i_pulse_shape_rd_en       => i_pulse_shape_rd_en,     -- read enable
      o_pulse_shape_rd_valid    => pulse_shape_rd_valid1,   -- read data valid
      o_pulse_shape_rd_data     => pulse_shape_rd_data1,    -- read data
      -- RAM:
      -- wr
      i_steady_state_wr_en      => i_steady_state_wr_en,    -- write enable
      i_steady_state_wr_rd_addr => i_steady_state_wr_rd_addr,  -- write address
      i_steady_state_wr_data    => i_steady_state_wr_data,  -- write data
      -- rd
      i_steady_state_rd_en      => i_steady_state_rd_en,    -- read enable
      o_steady_state_rd_valid   => steady_state_rd_valid1,  -- read data valid
      o_steady_state_rd_data    => steady_state_rd_data1,   -- read data

      ---------------------------------------------------------------------
      -- input data
      ---------------------------------------------------------------------
      i_pixel_sof                  => pixel_sof0,  -- tag the first sample of the pixel
      i_pixel_eof                  => pixel_eof0,  -- tag the last sample of the pixel
      i_pixel_id                   => pixel_id0,   -- id of the pixel
      i_pixel_valid                => pixel_valid0,   -- valid pixel sample
      ---------------------------------------------------------------------
      -- output data
      ---------------------------------------------------------------------
      o_pulse_sof                  => pulse_sof1,
      o_pulse_eof                  => pulse_eof1,
      o_pixel_sof                  => pixel_sof1,  -- tag the first sample of the pixel
      o_pixel_eof                  => pixel_eof1,  -- tag the last sample of the pixel
      o_pixel_id                   => pixel_id1,   -- id of the pixel
      o_pixel_valid                => pixel_valid1,   -- valid pixel result
      o_pixel_result               => pixel_result1,  -- pixel result
      ---------------------------------------------------------------------
      -- output: detect negative output value
      ---------------------------------------------------------------------
      o_tes_pixel_neg_out_valid    => tes_pixel_neg_out_valid1,
      o_tes_pixel_neg_out_error    => tes_pixel_neg_out_error1,
      o_tes_pixel_neg_out_pixel_id => tes_pixel_neg_out_pixel_id1,
      -----------------------------------------------------------------
      -- errors/status
      -----------------------------------------------------------------
      o_errors                     => errors1,
      o_status                     => status1
      );

  o_cmd_ready                              <= cmd_ready;
  ---------------------------------------------------------------------
  -- sync with the tes_pulse_shape_manager out
  ---------------------------------------------------------------------
  data_pipe_tmp0(c_IDX2_H)                 <= frame_sof0;
  data_pipe_tmp0(c_IDX1_H)                 <= frame_eof0;
  data_pipe_tmp0(c_IDX0_H downto c_IDX0_L) <= frame_id0;
  inst_pipeliner_sync_with_tes_pulse_manager_out : entity work.pipeliner
    generic map(
      g_NB_PIPES   => pkg_TES_PULSE_MANAGER_LATENCY,  -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => data_pipe_tmp0'length  -- width of the input/output data.  Possibles values: [1, integer max value[
      )
    port map(
      i_clk  => i_clk,                  -- clock signal
      i_data => data_pipe_tmp0,         -- input data
      o_data => data_pipe_tmp1          -- output data with/without delay
      );

  frame_sof1 <= data_pipe_tmp1(c_IDX2_H);
  frame_eof1 <= data_pipe_tmp1(c_IDX1_H);
  frame_id1  <= data_pipe_tmp1(c_IDX0_H downto c_IDX0_L);

  ---------------------------------------------------------------------
  -- negative output detection
  ---------------------------------------------------------------------

  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  -- rd pulse shape
  o_pulse_shape_rd_valid <= pulse_shape_rd_valid1;
  o_pulse_shape_rd_data  <= pulse_shape_rd_data1;

  -- rd steady state
  o_steady_state_rd_valid <= steady_state_rd_valid1;
  o_steady_state_rd_data  <= steady_state_rd_data1;
  -- output data
  o_pulse_sof             <= pulse_sof1;
  o_pulse_eof             <= pulse_eof1;
  o_pixel_sof             <= pixel_sof1;
  o_pixel_eof             <= pixel_eof1;
  o_pixel_valid           <= pixel_valid1;
  o_pixel_id              <= pixel_id1;
  o_pixel_result          <= pixel_result1;
  o_frame_sof             <= frame_sof1;
  o_frame_eof             <= frame_eof1;
  o_frame_id              <= frame_id1;

  -- output: detect negative output value
  o_tes_pixel_neg_out_valid    <= tes_pixel_neg_out_valid1;
  o_tes_pixel_neg_out_error    <= tes_pixel_neg_out_error1;
  o_tes_pixel_neg_out_pixel_id <= tes_pixel_neg_out_pixel_id1;

  -- errors/status
  o_errors <= errors1;
  o_status <= status1;

end architecture RTL;
