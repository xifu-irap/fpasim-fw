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
--!   @file                   tes_top.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--
-- This module is the top_level of the tes funcion
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library fpasim;
use fpasim.pkg_fpasim.all;

entity tes_top is
  generic(
    -- pixel
    g_PIXEL_FRAME_WIDTH : positive := 16;
    g_PIXEL_ID_WIDTH            : positive := pkg_PIXEL_ID_WIDTH; -- pixel id bus width (expressed in bits). Possible values [1;max integer value[
    -- frame
    g_FRAME_FRAME_WIDTH : positive := 16;
    g_FRAME_ID_WIDTH            : positive := pkg_FRAME_ID_WIDTH; -- frame id bus width (expressed in bits). Possible values [1;max integer value[
    -- output
    g_PIXEL_RESULT_OUTPUT_WIDTH : positive := pkg_TES_MULT_SUB_Q_WIDTH_S -- pixel output result bus width (expressed in bit). Possible values [1;max integer value[
  );

  port(
    i_clk                     : in  std_logic; -- clock signal
    i_rst                     : in  std_logic; -- reset signal

    i_rst_status              : in  std_logic; -- reset error flag(s)
    i_debug_pulse             : in  std_logic; -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)

    ---------------------------------------------------------------------
    -- input command: from the regdecode
    ---------------------------------------------------------------------
    i_en                      : in  std_logic; -- enable
    i_pixel_frame_size : in std_logic_vector(g_PIXEL_FRAME_WIDTH - 1 downto 0);
    i_frame_frame_size : in std_logic_vector(g_FRAME_FRAME_WIDTH - 1 downto 0);
    
    -- command
    i_cmd_valid               : in  std_logic; -- valid command
    i_cmd_pulse_height        : in  std_logic_vector(10 downto 0); -- pulse height command
    i_cmd_pixel_id            : in  std_logic_vector(g_PIXEL_ID_WIDTH - 1 downto 0); -- pixel id command
    i_cmd_time_shift          : in  std_logic_vector(3 downto 0); -- time shift command

    -- RAM: pulse shape
    -- wr
    i_pulse_shape_wr_en       : in  std_logic; -- write enable
    i_pulse_shape_wr_rd_addr  : in  std_logic_vector(14 downto 0); -- write address
    i_pulse_shape_wr_data     : in  std_logic_vector(15 downto 0); -- write data
    -- rd
    i_pulse_shape_rd_en       : in  std_logic; -- rd enable
    o_pulse_shape_rd_valid    : out std_logic; -- rd data valid
    o_pulse_shape_rd_data     : out std_logic_vector(15 downto 0); -- rd data

    -- RAM:
    -- wr
    i_steady_state_wr_en      : in  std_logic; -- write enable
    i_steady_state_wr_rd_addr : in  std_logic_vector(g_PIXEL_ID_WIDTH - 1 downto 0); -- write address
    i_steady_state_wr_data    : in  std_logic_vector(15 downto 0); -- write data
    -- rd
    i_steady_state_rd_en      : in  std_logic; -- rd enable
    o_steady_state_rd_valid   : out std_logic; -- rd data valid
    o_steady_state_rd_data    : out std_logic_vector(15 downto 0); -- read data

    ---------------------------------------------------------------------
    -- from the adc
    ---------------------------------------------------------------------
    i_data_valid              : in  std_logic; --  input valid data

    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    o_pixel_sof               : out std_logic; -- first pixel sample
    o_pixel_eof               : out std_logic; -- last pixel sample
    o_pixel_valid             : out std_logic; -- valid pixel sample
    o_pixel_id                : out std_logic_vector(g_PIXEL_ID_WIDTH - 1 downto 0); -- output pixel id
    o_pixel_result            : out std_logic_vector(g_PIXEL_RESULT_OUTPUT_WIDTH - 1 downto 0); -- output pixel result
    o_frame_sof               : out std_logic; -- first frame sample
    o_frame_eof               : out std_logic; -- last frame sample
    o_frame_id                : out std_logic_vector(g_FRAME_ID_WIDTH - 1 downto 0); -- output frame id
    ---------------------------------------------------------------------
    -- errors/status
    ---------------------------------------------------------------------
    o_errors                  : out std_logic_vector(15 downto 0); -- output errors
    o_status                  : out std_logic_vector(7 downto 0) -- output status
  );
end entity tes_top;

architecture RTL of tes_top is
  constant c_FRAME_SIZE  : positive := pkg_FRAME_SIZE;
  constant c_FRAME_WIDTH : positive := pkg_FRAME_WIDTH;
  ---------------------------------------------------------------------
  -- tes_signalling
  ---------------------------------------------------------------------
  signal pixel_sof0      : std_logic;
  signal pixel_eof0      : std_logic;
  signal pixel_id0       : std_logic_vector(o_pixel_id'range);
  signal pixel_valid0    : std_logic;

  signal frame_sof0 : std_logic;
  signal frame_eof0 : std_logic;
  signal frame_id0  : std_logic_vector(o_frame_id'range);

  ---------------------------------------------------------------------
  -- tes_pulse_shape_manager
  ---------------------------------------------------------------------
  signal pulse_shape_rd_valid1 : std_logic;
  signal pulse_shape_rd_data1  : std_logic_vector(o_pulse_shape_rd_data'range);

  signal steady_state_rd_valid1 : std_logic;
  signal steady_state_rd_data1  : std_logic_vector(o_steady_state_rd_data'range);

  signal pixel_sof1    : std_logic;
  signal pixel_eof1    : std_logic;
  signal pixel_id1     : std_logic_vector(o_pixel_id'range);
  signal pixel_valid1  : std_logic;
  signal pixel_result1 : std_logic_vector(o_pixel_result'range);

  signal status1 : std_logic_vector(o_status'range);
  signal errors1 : std_logic_vector(o_errors'range);

  ---------------------------------------------------------------------
  -- sync with the tes_pulse_shape_manager out
  ---------------------------------------------------------------------
  constant c_IDX0_L : integer := 0;
  constant c_IDX0_H : integer := c_IDX0_L + o_frame_id'length - 1;

  constant c_IDX1_L : integer := c_IDX0_H + 1;
  constant c_IDX1_H : integer := c_IDX1_L + 1 - 1;

  constant c_IDX2_L : integer := c_IDX1_H + 1;
  constant c_IDX2_H : integer := c_IDX2_L + 1 - 1;

  signal data_pipe_tmp0 : std_logic_vector(c_IDX2_H downto 0);
  signal data_pipe_tmp1 : std_logic_vector(c_IDX2_H downto 0);

  signal frame_sof1 : std_logic;
  signal frame_eof1 : std_logic;
  signal frame_id1  : std_logic_vector(o_frame_id'range);

begin

  inst_tes_signalling : entity fpasim.tes_signalling
    generic map(
      -- pixel
      g_PIXEL_FRAME_WIDTH => i_pixel_frame_size'length,
      g_PIXEL_ID_WIDTH => g_PIXEL_ID_WIDTH,
      -- frame
      g_FRAME_FRAME_WIDTH=> i_frame_frame_size'length,
      g_FRAME_ID_WIDTH => g_FRAME_ID_WIDTH
    )
    port map(
      i_clk         => i_clk,
      i_rst         => i_rst,
      ---------------------------------------------------------------------
      -- Commands
      ---------------------------------------------------------------------
      i_start       => i_en,
      i_pixel_frame_size =>  i_pixel_frame_size,
        i_frame_frame_size =>         i_frame_frame_size,
      ---------------------------------------------------------------------
      -- Input data
      ---------------------------------------------------------------------
      i_data_valid  => i_data_valid,
      ---------------------------------------------------------------------
      -- Output data
      ---------------------------------------------------------------------
      o_pixel_sof   => pixel_sof0,
      o_pixel_eof   => pixel_eof0,
      o_pixel_id    => pixel_id0,
      o_pixel_valid => pixel_valid0,
      o_frame_sof   => frame_sof0,
      o_frame_eof   => frame_eof0,
      o_frame_id    => frame_id0
    );

  inst_tes_pulse_shape_manager : entity fpasim.tes_pulse_shape_manager
    generic map(
      g_FRAME_SIZE                => c_FRAME_SIZE,
      g_FRAME_WIDTH               => c_FRAME_WIDTH,
      g_PIXEL_ID_WIDTH            => pixel_id0'length,
      g_PIXEL_RESULT_OUTPUT_WIDTH => pixel_result1'length
    )
    port map(
      i_clk                     => i_clk, -- clock signal
      i_rst                     => i_rst, -- reset signal
      i_rst_status              => i_rst_status, -- reset error flags
      i_debug_pulse             => i_debug_pulse, -- '1': delay error, '0': latch error
      ---------------------------------------------------------------------
      -- input command: from the regdecode
      ---------------------------------------------------------------------
      i_cmd_valid               => i_cmd_valid, -- '1': command is valid, '0': otherwise
      i_cmd_pulse_height        => i_cmd_pulse_height, -- pulse height value
      i_cmd_pixel_id            => i_cmd_pixel_id, -- pixel id
      i_cmd_time_shift          => i_cmd_time_shift, -- time shift value
      -- RAM: pulse shape
      -- wr
      i_pulse_shape_wr_en       => i_pulse_shape_wr_en, -- write enable
      i_pulse_shape_wr_rd_addr  => i_pulse_shape_wr_rd_addr, -- write address
      i_pulse_shape_wr_data     => i_pulse_shape_wr_data, -- write data
      -- rd
      i_pulse_shape_rd_en       => i_pulse_shape_rd_en,
      o_pulse_shape_rd_valid    => pulse_shape_rd_valid1,
      o_pulse_shape_rd_data     => pulse_shape_rd_data1,
      -- RAM:
      -- wr
      i_steady_state_wr_en      => i_steady_state_wr_en, -- write enable
      i_steady_state_wr_rd_addr => i_steady_state_wr_rd_addr, -- write address
      i_steady_state_wr_data    => i_steady_state_wr_data, -- write data
      -- rd
      i_steady_state_rd_en      => i_steady_state_rd_en, -- write enable
      o_steady_state_rd_valid   => steady_state_rd_valid1, -- write address
      o_steady_state_rd_data    => steady_state_rd_data1, -- write data

      ---------------------------------------------------------------------
      -- input data
      ---------------------------------------------------------------------
      i_pixel_sof               => pixel_sof0, -- tag the first sample of the pixel
      i_pixel_eof               => pixel_eof0, -- tag the last sample of the pixel
      i_pixel_id                => pixel_id0, -- id of the pixel
      i_pixel_valid             => pixel_valid0, -- valid pixel sample
      ---------------------------------------------------------------------
      -- output data
      ---------------------------------------------------------------------
      o_pixel_sof               => pixel_sof1, -- tag the first sample of the pixel
      o_pixel_eof               => pixel_eof1, -- tag the last sample of the pixel
      o_pixel_id                => pixel_id1, -- id of the pixel
      o_pixel_valid             => pixel_valid1, -- valid pixel result
      o_pixel_result            => pixel_result1, -- pixel result
      -----------------------------------------------------------------
      -- errors/status
      -----------------------------------------------------------------
      o_errors                  => errors1,
      o_status                  => status1
    );

  ---------------------------------------------------------------------
  -- sync with the tes_pulse_shape_manager out
  ---------------------------------------------------------------------
  data_pipe_tmp0(c_IDX2_H)                 <= frame_sof0;
  data_pipe_tmp0(c_IDX1_H)                 <= frame_eof0;
  data_pipe_tmp0(c_IDX0_H downto c_IDX0_L) <= frame_id0;
  inst_pipeliner_sync_with_tes_pulse_manager_out : entity fpasim.pipeliner
    generic map(
      g_NB_PIPES   => pkg_TES_PULSE_MANAGER_LATENCY, -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => data_pipe_tmp0'length -- width of the input/output data.  Possibles values: [1, integer max value[
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
  -- output
  ---------------------------------------------------------------------
  -- rd pulse shape
  o_pulse_shape_rd_valid <= pulse_shape_rd_valid1;
  o_pulse_shape_rd_data  <= pulse_shape_rd_data1;

  -- rd steady state
  o_steady_state_rd_valid <= steady_state_rd_valid1;
  o_steady_state_rd_data  <= steady_state_rd_data1;

  o_pixel_sof    <= pixel_sof1;
  o_pixel_eof    <= pixel_eof1;
  o_pixel_valid  <= pixel_valid1;
  o_pixel_id     <= pixel_id1;
  o_pixel_result <= pixel_result1;
  o_frame_sof    <= frame_sof1;
  o_frame_eof    <= frame_eof1;
  o_frame_id     <= frame_id1;

  o_errors <= errors1;
  o_status <= status1;

end architecture RTL;
