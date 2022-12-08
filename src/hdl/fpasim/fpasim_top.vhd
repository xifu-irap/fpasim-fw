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
--!   @file                   fpasim_top.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
-- This module is the top_level of the fpasim
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fpasim;
use fpasim.pkg_fpasim.all;
use fpasim.pkg_regdecode.all;

entity fpasim_top is
  generic(
    g_DEBUG : boolean := true
  );
  port(
    i_clk                             : in  std_logic; -- system clock
    i_adc_clk                         : in  std_logic; -- adc clock
    i_ref_clk                         : in  std_logic; -- reference clock
    i_dac_clk                         : in  std_logic; -- dac clock
    --i_usb_clk                         : in  std_logic; -- usb clock
    ---------------------------------------------------------------------
    -- from the usb @i_usb_clk (clock included)
    ---------------------------------------------------------------------
    --  Opal Kelly inouts --
    i_okUH                          : in    std_logic_vector(4 downto 0);
    o_okHU                          : out   std_logic_vector(2 downto 0);
    b_okUHU                         : inout std_logic_vector(31 downto 0);
    b_okAA                          : inout std_logic;

    ---------------------------------------------------------------------
    -- from the board
    ---------------------------------------------------------------------
    i_board_id : in std_logic_vector(7 downto 0);

    ---------------------------------------------------------------------
    -- from adc
    ---------------------------------------------------------------------
    i_adc_valid                       : in  std_logic; -- adc valid
    i_adc_amp_squid_offset_correction : in  std_logic_vector(13 downto 0); -- adc_amp_squid_offset_correction value
    i_adc_mux_squid_feedback          : in  std_logic_vector(13 downto 0); -- adc_mux_squid_feedback value
    ---------------------------------------------------------------------
    -- output sync @clk_ref
    ---------------------------------------------------------------------
    o_sync                            : out std_logic; -- synchronization signal (pulse)
    ---------------------------------------------------------------------
    -- output dac @i_clk_dac
    ---------------------------------------------------------------------
    o_dac_valid                       : out std_logic; -- dac valid
    o_dac_frame                       : out std_logic; -- dac frame
    o_dac                             : out std_logic_vector(15 downto 0) -- dac data
  );
end entity fpasim_top;

architecture RTL of fpasim_top is
  constant c_NB_PIXEL_BY_FRAME_MAX_WIDTH   : integer := pkg_NB_PIXEL_BY_FRAME_MAX_WIDTH;
  constant c_NB_FRAME_BY_PULSE_SHAPE_WIDTH : integer := pkg_NB_FRAME_BY_PULSE_SHAPE_WIDTH;
  constant c_NB_FRAME_BY_PULSE_SHAPE       : integer := pkg_NB_FRAME_BY_PULSE_SHAPE;

  constant c_TES_TOP_LATENCY                : integer  := pkg_TES_TOP_LATENCY;
  constant c_MUX_SQUID_TOP_LATENCY          : integer  := pkg_MUX_SQUID_TOP_LATENCY;
  constant c_SYNC_PULSE_DURATION            : integer  := pkg_SYNC_PULSE_DURATION;
  constant c_MUX_SQUID_ADD_Q_WIDTH_S        : integer  := pkg_MUX_SQUID_ADD_Q_WIDTH_S;
  constant c_TES_MULT_SUB_Q_WIDTH_S         : integer  := pkg_TES_MULT_SUB_Q_WIDTH_S;
  constant c_TES_PULSE_SHAPE_RAM_ADDR_WIDTH : positive := pkg_TES_PULSE_SHAPE_RAM_ADDR_WIDTH;
  constant c_AMP_SQUID_TF_RAM_ADDR_WIDTH    : positive := pkg_AMP_SQUID_TF_RAM_ADDR_WIDTH;
  constant c_MUX_SQUID_TF_RAM_ADDR_WIDTH    : positive := pkg_MUX_SQUID_TF_RAM_ADDR_WIDTH;

  -- ctrl 
  ---------------------------------------------------------------------
  constant c_CTRL_EN_IDX_H  : integer := pkg_CTRL_EN_IDX_H;
  constant c_CTRL_RST_IDX_H : integer := pkg_CTRL_RST_IDX_H;

  -- make pulse
  ---------------------------------------------------------------------
  -- pixel all
  constant pkg_MAKE_PULSE_PIXEL_ALL_IDX_H : integer := 31; -- @suppress "Unused declaration"

  -- pixel id
  constant c_MAKE_PULSE_PIXEL_ID_IDX_H : integer := pkg_MAKE_PULSE_PIXEL_ID_IDX_H;
  constant c_MAKE_PULSE_PIXEL_ID_IDX_L : integer := pkg_MAKE_PULSE_PIXEL_ID_IDX_L;
  constant c_MAKE_PULSE_PIXEL_ID_WIDTH : integer := pkg_MAKE_PULSE_PIXEL_ID_WIDTH;

  -- time shift
  constant c_MAKE_PULSE_TIME_SHIFT_IDX_H : integer := pkg_MAKE_PULSE_TIME_SHIFT_IDX_H;
  constant c_MAKE_PULSE_TIME_SHIFT_IDX_L : integer := pkg_MAKE_PULSE_TIME_SHIFT_IDX_L;
  constant c_MAKE_PULSE_TIME_SHIFT_WIDTH : integer := pkg_MAKE_PULSE_TIME_SHIFT_WIDTH;

  -- pulse height
  constant c_MAKE_PULSE_PULSE_HEIGHT_IDX_H : integer := pkg_MAKE_PULSE_PULSE_HEIGHT_IDX_H;
  constant c_MAKE_PULSE_PULSE_HEIGHT_IDX_L : integer := pkg_MAKE_PULSE_PULSE_HEIGHT_IDX_L;
  constant c_MAKE_PULSE_PULSE_HEIGHT_WIDTH : integer := pkg_MAKE_PULSE_PULSE_HEIGHT_WIDTH;

  -- fpasim_gain
  ---------------------------------------------------------------------
  constant c_FPASIM_GAIN_IDX_H : integer := pkg_FPASIM_GAIN_IDX_H;
  constant c_FPASIM_GAIN_IDX_L : integer := pkg_FPASIM_GAIN_IDX_L;
  constant c_FPASIM_GAIN_WIDTH : integer := pkg_FPASIM_GAIN_WIDTH;

  -- mux_sq_fb_delay
  ---------------------------------------------------------------------
  constant c_MUX_SQ_FB_DELAY_IDX_H : integer := pkg_MUX_SQ_FB_DELAY_IDX_H;
  constant c_MUX_SQ_FB_DELAY_IDX_L : integer := pkg_MUX_SQ_FB_DELAY_IDX_L;
  constant c_MUX_SQ_FB_DELAY_WIDTH : integer := pkg_MUX_SQ_FB_DELAY_WIDTH;

  -- mux_sq_fb_delay
  ---------------------------------------------------------------------
  constant c_AMP_SQ_OF_DELAY_IDX_H : integer := pkg_AMP_SQ_OF_DELAY_IDX_H;
  constant c_AMP_SQ_OF_DELAY_IDX_L : integer := pkg_AMP_SQ_OF_DELAY_IDX_L;
  constant c_AMP_SQ_OF_DELAY_WIDTH : integer := pkg_AMP_SQ_OF_DELAY_WIDTH;

  ---------------------------------------------------------------------
  -- error_delay
  ---------------------------------------------------------------------
  constant c_ERROR_DELAY_IDX_H : integer := pkg_ERROR_DELAY_IDX_H;
  constant c_ERROR_DELAY_IDX_L : integer := pkg_ERROR_DELAY_IDX_L;
  constant c_ERROR_DELAY_WIDTH : integer := pkg_ERROR_DELAY_WIDTH;

  ---------------------------------------------------------------------
  -- ra_delay
  ---------------------------------------------------------------------
  constant c_RA_DELAY_IDX_H : integer := pkg_RA_DELAY_IDX_H;
  constant c_RA_DELAY_IDX_L : integer := pkg_RA_DELAY_IDX_L;
  constant c_RA_DELAY_WIDTH : integer := pkg_RA_DELAY_WIDTH;

  -- tes_conf 
  ---------------------------------------------------------------------
  constant c_TES_CONF_NB_PIXEL_BY_FRAME_IDX_H : integer := pkg_TES_CONF_NB_PIXEL_BY_FRAME_IDX_H;
  constant c_TES_CONF_NB_PIXEL_BY_FRAME_IDX_L : integer := pkg_TES_CONF_NB_PIXEL_BY_FRAME_IDX_L;
  constant c_TES_CONF_NB_PIXEL_BY_FRAME_WIDTH : integer := pkg_TES_CONF_NB_PIXEL_BY_FRAME_WIDTH;

  constant c_TES_CONF_NB_SAMPLE_BY_PIXEL_IDX_H : integer := pkg_TES_CONF_NB_SAMPLE_BY_PIXEL_IDX_H;
  constant c_TES_CONF_NB_SAMPLE_BY_PIXEL_IDX_L : integer := pkg_TES_CONF_NB_SAMPLE_BY_PIXEL_IDX_L;
  constant c_TES_CONF_NB_SAMPLE_BY_PIXEL_WIDTH : integer := pkg_TES_CONF_NB_SAMPLE_BY_PIXEL_WIDTH;

  constant c_TES_CONF_NB_SAMPLE_BY_FRAME_IDX_H : integer := pkg_TES_CONF_NB_SAMPLE_BY_FRAME_IDX_H;
  constant c_TES_CONF_NB_SAMPLE_BY_FRAME_IDX_L : integer := pkg_TES_CONF_NB_SAMPLE_BY_FRAME_IDX_L;
  constant c_TES_CONF_NB_SAMPLE_BY_FRAME_WIDTH : integer := pkg_TES_CONF_NB_SAMPLE_BY_FRAME_WIDTH;

  -- debug_ctrl
  ---------------------------------------------------------------------
  constant c_DEBUG_CTRL_DEBUG_PULSE_IDX_H : integer := pkg_DEBUG_CTRL_DEBUG_PULSE_IDX_H;
  constant c_DEBUG_CTRL_RST_STATUS_IDX_H  : integer := pkg_DEBUG_CTRL_RST_STATUS_IDX_H;

  ---------------------------------------------------------------------
  -- regdecode
  ---------------------------------------------------------------------
  -- ctrl register
  signal rst : std_logic;
  signal en  : std_logic;

  -- make_pulse register
  signal cmd_valid        : std_logic;
  signal cmd_pixel_id     : std_logic_vector(c_MAKE_PULSE_PIXEL_ID_WIDTH - 1 downto 0);
  signal cmd_time_shift   : std_logic_vector(c_MAKE_PULSE_TIME_SHIFT_WIDTH - 1 downto 0);
  signal cmd_pulse_height : std_logic_vector(c_MAKE_PULSE_PULSE_HEIGHT_WIDTH - 1 downto 0);
  signal cmd_ready        : std_logic;
  signal fpasim_gain      : std_logic_vector(c_FPASIM_GAIN_WIDTH - 1 downto 0);

  -- mux_sq_fb_delay register
  signal adc1_delay : std_logic_vector(c_MUX_SQ_FB_DELAY_WIDTH - 1 downto 0);
  -- amp_sq_of_delay register
  signal adc0_delay : std_logic_vector(c_AMP_SQ_OF_DELAY_WIDTH - 1 downto 0);

  -- error_delay register
  signal dac_delay : std_logic_vector(c_ERROR_DELAY_WIDTH - 1 downto 0);

  -- ra_delay register
  signal sync_delay : std_logic_vector(c_RA_DELAY_WIDTH - 1 downto 0);

  -- tes_conf register
  signal nb_pixel_by_frame  : std_logic_vector(c_TES_CONF_NB_PIXEL_BY_FRAME_WIDTH - 1 downto 0);
  signal nb_sample_by_pixel : std_logic_vector(c_TES_CONF_NB_SAMPLE_BY_PIXEL_WIDTH - 1 downto 0);
  signal nb_sample_by_frame : std_logic_vector(c_TES_CONF_NB_SAMPLE_BY_FRAME_WIDTH - 1 downto 0);

  -- debug_ctrl register
  signal rst_status  : std_logic;
  signal debug_pulse : std_logic;

  -- RAM configuration 
  ---------------------------------------------------------------------
  -- tes_pulse_shape
  -- ram: wr
  signal tes_pulse_shape_ram_wr_en          : std_logic;
  signal tes_pulse_shape_ram_wr_rd_addr     : std_logic_vector(15 downto 0);
  signal tes_pulse_shape_ram_wr_data        : std_logic_vector(15 downto 0);
  signal tes_pulse_shape_ram_wr_rd_addr_tmp : std_logic_vector(c_TES_PULSE_SHAPE_RAM_ADDR_WIDTH - 1 downto 0);
  -- ram: rd
  signal tes_pulse_shape_ram_rd_en          : std_logic;
  signal tes_pulse_shape_ram_rd_valid       : std_logic;
  signal tes_pulse_shape_ram_rd_data        : std_logic_vector(15 downto 0);

  -- amp_squid_tf
  -- ram: wr
  signal amp_squid_tf_ram_wr_en              : std_logic;
  signal amp_squid_tf_ram_wr_rd_addr         : std_logic_vector(15 downto 0);
  signal amp_squid_tf_ram_wr_data            : std_logic_vector(15 downto 0);
  signal amp_squid_tf_ram_wr_rd_addr_tmp     : std_logic_vector(c_AMP_SQUID_TF_RAM_ADDR_WIDTH - 1 downto 0);
  -- ram: rd
  signal amp_squid_tf_ram_rd_en              : std_logic;
  signal amp_squid_tf_ram_rd_valid           : std_logic;
  signal amp_squid_tf_ram_rd_data            : std_logic_vector(15 downto 0);
  -- mux_squid_tf
  -- ram: wr
  signal mux_squid_tf_ram_wr_en              : std_logic;
  signal mux_squid_tf_ram_wr_rd_addr         : std_logic_vector(15 downto 0);
  signal mux_squid_tf_ram_wr_data            : std_logic_vector(15 downto 0);
  signal mux_squid_tf_ram_wr_rd_addr_tmp     : std_logic_vector(c_MUX_SQUID_TF_RAM_ADDR_WIDTH - 1 downto 0);
  -- ram: rd
  signal mux_squid_tf_ram_rd_en              : std_logic;
  signal mux_squid_tf_ram_rd_valid           : std_logic;
  signal mux_squid_tf_ram_rd_data            : std_logic_vector(15 downto 0);
  -- tes_std_state
  -- ram: wr
  signal tes_std_state_ram_wr_en             : std_logic;
  signal tes_std_state_ram_wr_rd_addr        : std_logic_vector(15 downto 0);
  signal tes_std_state_ram_wr_data           : std_logic_vector(15 downto 0);
  signal tes_std_state_ram_wr_rd_addr_tmp    : std_logic_vector(c_NB_PIXEL_BY_FRAME_MAX_WIDTH - 1 downto 0);
  -- ram: rd
  signal tes_std_state_ram_rd_en             : std_logic;
  signal tes_std_state_ram_rd_valid          : std_logic;
  signal tes_std_state_ram_rd_data           : std_logic_vector(15 downto 0);
  -- mux_squid_offset
  -- ram: wr
  signal mux_squid_offset_ram_wr_en          : std_logic;
  signal mux_squid_offset_ram_wr_rd_addr     : std_logic_vector(15 downto 0);
  signal mux_squid_offset_ram_wr_data        : std_logic_vector(15 downto 0);
  signal mux_squid_offset_ram_wr_rd_addr_tmp : std_logic_vector(c_NB_PIXEL_BY_FRAME_MAX_WIDTH - 1 downto 0);
  -- ram: rd
  signal mux_squid_offset_ram_rd_en          : std_logic;
  signal mux_squid_offset_ram_rd_valid       : std_logic;
  signal mux_squid_offset_ram_rd_data        : std_logic_vector(15 downto 0);

  -- Register configuration
  ---------------------------------------------------------------------
  -- common register
  signal reg_valid            : std_logic; -- register valid -- @suppress "signal reg_valid is never read"
  signal reg_fpasim_gain      : std_logic_vector(31 downto 0); -- register fpasim_gain value
  signal reg_mux_sq_fb_delay  : std_logic_vector(31 downto 0); -- register mux_sq_fb_delay value
  signal reg_amp_sq_of_delay  : std_logic_vector(31 downto 0); -- register amp_sq_of_delay value
  signal reg_error_delay      : std_logic_vector(31 downto 0); -- register error_delay value
  signal reg_ra_delay         : std_logic_vector(31 downto 0); -- register ra_delay value
  signal reg_tes_conf         : std_logic_vector(31 downto 0); -- register tes_conf value
  -- ctrl register
  signal reg_ctrl_valid       : std_logic; -- register ctrl valid -- @suppress "signal reg_ctrl_valid is never read"
  signal reg_ctrl             : std_logic_vector(31 downto 0); -- register ctrl value
  -- debug ctrl register
  signal reg_debug_ctrl_valid : std_logic; -- register debug_ctrl valid -- @suppress "signal reg_debug_ctrl_valid is never read"
  signal reg_debug_ctrl       : std_logic_vector(31 downto 0); -- register debug_ctrl value
  -- make pulse register
  signal reg_make_sof         : std_logic; -- first sample -- @suppress "signal reg_make_sof is never read"
  signal reg_make_eof         : std_logic; -- last sample -- @suppress "signal reg_make_eof is never read"
  signal reg_make_pulse_valid : std_logic; -- register make_pulse valid
  signal reg_make_pulse       : std_logic_vector(31 downto 0);
  signal reg_make_pulse_ready : std_logic;

  signal pipe_errors5 : std_logic_vector(15 downto 0);
  signal pipe_errors4 : std_logic_vector(15 downto 0);
  signal pipe_errors3 : std_logic_vector(15 downto 0);
  signal pipe_errors2 : std_logic_vector(15 downto 0);
  signal pipe_errors1 : std_logic_vector(15 downto 0);
  signal pipe_errors0 : std_logic_vector(15 downto 0);

  signal pipe_status5 : std_logic_vector(7 downto 0);
  signal pipe_status4 : std_logic_vector(7 downto 0);
  signal pipe_status3 : std_logic_vector(7 downto 0);
  signal pipe_status2 : std_logic_vector(7 downto 0);
  signal pipe_status1 : std_logic_vector(7 downto 0);
  signal pipe_status0 : std_logic_vector(7 downto 0);

  signal reg_errors0 : std_logic_vector(15 downto 0);
  signal reg_status0 : std_logic_vector(7 downto 0);

  signal ctrl_errors0 : std_logic_vector(15 downto 0);
  signal ctrl_status0 : std_logic_vector(7 downto 0);

  signal debug_ctrl_errors0 : std_logic_vector(15 downto 0);
  signal debug_ctrl_status0 : std_logic_vector(7 downto 0);

  signal make_pulse_errors0 : std_logic_vector(15 downto 0);
  signal make_pulse_status0 : std_logic_vector(7 downto 0);

  signal reg_wire_errors7 : std_logic_vector(31 downto 0);
  signal reg_wire_errors6 : std_logic_vector(31 downto 0);
  signal reg_wire_errors5 : std_logic_vector(31 downto 0);
  signal reg_wire_errors4 : std_logic_vector(31 downto 0);
  signal reg_wire_errors3 : std_logic_vector(31 downto 0);
  signal reg_wire_errors2 : std_logic_vector(31 downto 0);
  signal reg_wire_errors1 : std_logic_vector(31 downto 0);
  signal reg_wire_errors0 : std_logic_vector(31 downto 0);

  signal reg_wire_status7 : std_logic_vector(31 downto 0);
  signal reg_wire_status6 : std_logic_vector(31 downto 0);
  signal reg_wire_status5 : std_logic_vector(31 downto 0);
  signal reg_wire_status4 : std_logic_vector(31 downto 0);
  signal reg_wire_status3 : std_logic_vector(31 downto 0);
  signal reg_wire_status2 : std_logic_vector(31 downto 0);
  signal reg_wire_status1 : std_logic_vector(31 downto 0);
  signal reg_wire_status0 : std_logic_vector(31 downto 0);

  ---------------------------------------------------------------------
  -- adc_top
  ---------------------------------------------------------------------

  signal adc_valid0                       : std_logic;
  signal adc_mux_squid_feedback0          : std_logic_vector(i_adc_mux_squid_feedback'range);
  signal adc_amp_squid_offset_correction0 : std_logic_vector(i_adc_amp_squid_offset_correction'range);
  signal adc_errors0                      : std_logic_vector(15 downto 0);
  signal adc_status0                      : std_logic_vector(7 downto 0);

  ---------------------------------------------------------------------
  -- tes_top
  ---------------------------------------------------------------------
  signal pixel_sof1    : std_logic;
  signal pixel_eof1    : std_logic;
  signal pixel_valid1  : std_logic;
  signal pixel_id1     : std_logic_vector(c_NB_PIXEL_BY_FRAME_MAX_WIDTH - 1 downto 0);
  signal pixel_result1 : std_logic_vector(c_TES_MULT_SUB_Q_WIDTH_S - 1 downto 0);
  signal frame_sof1    : std_logic;
  signal frame_eof1    : std_logic;
  signal frame_id1     : std_logic_vector(c_NB_FRAME_BY_PULSE_SHAPE_WIDTH - 1 downto 0);
  signal tes_errors0   : std_logic_vector(15 downto 0);
  signal tes_status0   : std_logic_vector(7 downto 0);

  -- signals synchronization with tes_top output
  ---------------------------------------------------------------------
  constant c_IDX0_L : integer := 0;
  constant c_IDX0_H : integer := c_IDX0_L + i_adc_amp_squid_offset_correction'length - 1;

  constant c_IDX1_L : integer := c_IDX0_H + 1;
  constant c_IDX1_H : integer := c_IDX1_L + i_adc_mux_squid_feedback'length - 1;

  signal data_pipe_tmp0 : std_logic_vector(c_IDX1_H downto 0);
  signal data_pipe_tmp1 : std_logic_vector(c_IDX1_H downto 0);

  signal mux_squid_feedback1          : std_logic_vector(i_adc_mux_squid_feedback'range);
  signal amp_squid_offset_correction1 : std_logic_vector(i_adc_amp_squid_offset_correction'range);

  ---------------------------------------------------------------------
  -- mux_squid_top
  ---------------------------------------------------------------------
  signal pixel_sof2        : std_logic;
  signal pixel_eof2        : std_logic;
  signal pixel_valid2      : std_logic;
  signal pixel_id2         : std_logic_vector(c_NB_PIXEL_BY_FRAME_MAX_WIDTH - 1 downto 0);
  signal pixel_result2     : std_logic_vector(c_MUX_SQUID_ADD_Q_WIDTH_S - 1 downto 0);
  signal frame_sof2        : std_logic;
  signal frame_eof2        : std_logic;
  signal frame_id2         : std_logic_vector(c_NB_FRAME_BY_PULSE_SHAPE_WIDTH - 1 downto 0);
  signal mux_squid_errors0 : std_logic_vector(15 downto 0);
  signal mux_squid_status0 : std_logic_vector(7 downto 0);

  -- signals synchronization with mux_squid_top
  ---------------------------------------------------------------------
  signal amp_squid_offset_correction2 : std_logic_vector(i_adc_amp_squid_offset_correction'range);

  ---------------------------------------------------------------------
  -- amp_squid_top
  ---------------------------------------------------------------------
  signal pixel_sof3        : std_logic; -- @suppress "signal pixel_sof3 is never read"
  signal pixel_eof3        : std_logic; -- @suppress "signal pixel_eof3 is never read"
  signal pixel_valid3      : std_logic;
  signal pixel_id3         : std_logic_vector(c_NB_PIXEL_BY_FRAME_MAX_WIDTH - 1 downto 0); -- @suppress "signal pixel_id3 is never read"
  signal pixel_result3     : std_logic_vector(15 downto 0);
  signal frame_sof3        : std_logic;
  signal frame_eof3        : std_logic; -- @suppress "signal frame_eof3 is never read"
  signal frame_id3         : std_logic_vector(c_NB_FRAME_BY_PULSE_SHAPE_WIDTH - 1 downto 0); -- @suppress "signal frame_id3 is never read"
  signal amp_squid_errors0 : std_logic_vector(15 downto 0);
  signal amp_squid_status0 : std_logic_vector(7 downto 0);

  ---------------------------------------------------------------------
  -- dac_top
  ---------------------------------------------------------------------
  signal dac_valid4  : std_logic;
  signal dac_frame4  : std_logic;
  signal dac4        : std_logic_vector(o_dac'range);
  signal dac_errors0 : std_logic_vector(15 downto 0);
  signal dac_status0 : std_logic_vector(7 downto 0);

  ---------------------------------------------------------------------
  -- sync_top
  ---------------------------------------------------------------------
  signal sync_valid5  : std_logic; -- @suppress "signal sync_valid5 is never read"
  signal sync5        : std_logic;
  signal sync_errors0 : std_logic_vector(15 downto 0);
  signal sync_status0 : std_logic_vector(7 downto 0);

begin

  ---------------------------------------------------------------------
  -- RegDecode
  ---------------------------------------------------------------------
  inst_regdecode_top : entity fpasim.regdecode_top
    generic map(
      g_DEBUG => false
    )
    port map( -- @suppress "The order of the associations is different from the declaration order"
      ---------------------------------------------------------------------
      -- from the usb @i_clk (clock included)
      ---------------------------------------------------------------------
      i_rst                             => '0',
      --  Opal Kelly inouts --
      i_okUH                            => i_okUH,
      o_okHU                            => o_okHU,
      b_okUHU                           => b_okUHU,
      b_okAA                            => b_okAA,
      ---------------------------------------------------------------------
      -- from/to the user: @i_out_clk
      ---------------------------------------------------------------------
      i_out_clk                         => i_clk, -- clock (user side)
      i_rst_status                      => rst_status, -- reset error flag(s)
      i_debug_pulse                     => debug_pulse, -- error mode (transparent vs capture). Possib
      -- RAM configuration 
      ---------------------------------------------------------------------
      -- tes_pulse_shape
      -- ram: wr
      o_tes_pulse_shape_ram_wr_en       => tes_pulse_shape_ram_wr_en, -- output write enable
      o_tes_pulse_shape_ram_wr_rd_addr  => tes_pulse_shape_ram_wr_rd_addr, -- output address (shared by the writting and the reading)
      o_tes_pulse_shape_ram_wr_data     => tes_pulse_shape_ram_wr_data, -- output data
      -- ram: rd
      o_tes_pulse_shape_ram_rd_en       => tes_pulse_shape_ram_rd_en, -- output read enable
      i_tes_pulse_shape_ram_rd_valid    => tes_pulse_shape_ram_rd_valid, -- input read valid
      i_tes_pulse_shape_ram_rd_data     => tes_pulse_shape_ram_rd_data, -- input data
      -- amp_squid_tf
      -- ram: wr
      o_amp_squid_tf_ram_wr_en          => amp_squid_tf_ram_wr_en, -- output write enable
      o_amp_squid_tf_ram_wr_rd_addr     => amp_squid_tf_ram_wr_rd_addr, -- output address (shared by the writting and the reading)
      o_amp_squid_tf_ram_wr_data        => amp_squid_tf_ram_wr_data, -- output data
      -- ram: rd
      o_amp_squid_tf_ram_rd_en          => amp_squid_tf_ram_rd_en, -- output read enable
      i_amp_squid_tf_ram_rd_valid       => amp_squid_tf_ram_rd_valid, -- input read valid
      i_amp_squid_tf_ram_rd_data        => amp_squid_tf_ram_rd_data, -- input read data
      -- mux_squid_tf
      -- ram: wr
      o_mux_squid_tf_ram_wr_en          => mux_squid_tf_ram_wr_en, -- output write enable
      o_mux_squid_tf_ram_wr_rd_addr     => mux_squid_tf_ram_wr_rd_addr, -- output address (shared by the writting and the reading)
      o_mux_squid_tf_ram_wr_data        => mux_squid_tf_ram_wr_data, -- output data
      -- ram: rd
      o_mux_squid_tf_ram_rd_en          => mux_squid_tf_ram_rd_en, -- output read enable
      i_mux_squid_tf_ram_rd_valid       => mux_squid_tf_ram_rd_valid, -- input read valid
      i_mux_squid_tf_ram_rd_data        => mux_squid_tf_ram_rd_data, -- input read data
      -- tes_std_state
      -- ram: wr
      o_tes_std_state_ram_wr_en         => tes_std_state_ram_wr_en, -- output write enable
      o_tes_std_state_ram_wr_rd_addr    => tes_std_state_ram_wr_rd_addr, -- output address (shared by the writting and the reading)
      o_tes_std_state_ram_wr_data       => tes_std_state_ram_wr_data, -- output data
      -- ram: rd
      o_tes_std_state_ram_rd_en         => tes_std_state_ram_rd_en, -- output read enable
      i_tes_std_state_ram_rd_valid      => tes_std_state_ram_rd_valid, -- input read valid
      i_tes_std_state_ram_rd_data       => tes_std_state_ram_rd_data, -- input read data
      -- mux_squid_offset
      -- ram: wr
      o_mux_squid_offset_ram_wr_en      => mux_squid_offset_ram_wr_en, -- output write enable
      o_mux_squid_offset_ram_wr_rd_addr => mux_squid_offset_ram_wr_rd_addr, -- output address (shared by the writting and the reading)
      o_mux_squid_offset_ram_wr_data    => mux_squid_offset_ram_wr_data, -- output data
      -- ram: rd
      o_mux_squid_offset_ram_rd_en      => mux_squid_offset_ram_rd_en, -- output read enable
      i_mux_squid_offset_ram_rd_valid   => mux_squid_offset_ram_rd_valid, -- input read valid
      i_mux_squid_offset_ram_rd_data    => mux_squid_offset_ram_rd_data, -- input read data
      -- Register configuration
      ---------------------------------------------------------------------
      -- common register
      o_reg_valid                       => reg_valid, -- register valid
      o_reg_fpasim_gain                 => reg_fpasim_gain, -- register fpasim_gain value
      o_reg_mux_sq_fb_delay             => reg_mux_sq_fb_delay, -- register mux_sq_fb_delay value
      o_reg_amp_sq_of_delay             => reg_amp_sq_of_delay, -- register amp_sq_of_delay value
      o_reg_error_delay                 => reg_error_delay, -- register error_delay value
      o_reg_ra_delay                    => reg_ra_delay, -- register ra_delay value
      o_reg_tes_conf                    => reg_tes_conf, -- register tes_conf value
      -- ctrl register
      o_reg_ctrl_valid                  => reg_ctrl_valid, -- register ctrl valid
      o_reg_ctrl                        => reg_ctrl, -- register ctrl value
      -- debug ctrl register
      o_reg_debug_ctrl_valid            => reg_debug_ctrl_valid, -- register debug_ctrl valid
      o_reg_debug_ctrl                  => reg_debug_ctrl, -- register debug_ctrl value
      -- make pulse register
      o_reg_make_sof                    => reg_make_sof, -- first sample
      o_reg_make_eof                    => reg_make_eof, -- last sample
      o_reg_make_pulse_valid            => reg_make_pulse_valid, -- register make_pulse valid
      o_reg_make_pulse                  => reg_make_pulse, -- register make_pulse value
      i_reg_make_pulse_ready            => reg_make_pulse_ready,
      -- to the usb 
      ---------------------------------------------------------------------
      -- errors
      i_reg_wire_errors7                => reg_wire_errors7,
      i_reg_wire_errors6                => reg_wire_errors6,
      i_reg_wire_errors5                => reg_wire_errors5,
      i_reg_wire_errors4                => reg_wire_errors4,
      i_reg_wire_errors3                => reg_wire_errors3,
      i_reg_wire_errors2                => reg_wire_errors2,
      i_reg_wire_errors1                => reg_wire_errors1,
      i_reg_wire_errors0                => reg_wire_errors0,
      -- status
      i_reg_wire_status7                => reg_wire_status7,
      i_reg_wire_status6                => reg_wire_status6,
      i_reg_wire_status5                => reg_wire_status5,
      i_reg_wire_status4                => reg_wire_status4,
      i_reg_wire_status3                => reg_wire_status3,
      i_reg_wire_status2                => reg_wire_status2,
      i_reg_wire_status1                => reg_wire_status1,
      i_reg_wire_status0                => reg_wire_status0,
      -- to the user: errors/status
      ---------------------------------------------------------------------
      -- pipe errors
      o_pipe_errors5                    => pipe_errors5, -- rd all: output errors
      o_pipe_errors4                    => pipe_errors4, -- mux squid offset: output errors
      o_pipe_errors3                    => pipe_errors3, -- tes std state: output errors
      o_pipe_errors2                    => pipe_errors2, -- mux squid tf: output errors
      o_pipe_errors1                    => pipe_errors1, -- amp squid tf: output errors
      o_pipe_errors0                    => pipe_errors0, -- tes pulse shape: output errors

      -- pipe status
      o_pipe_status5                    => pipe_status5, -- rd all: output status
      o_pipe_status4                    => pipe_status4, -- mux squid offset: output status
      o_pipe_status3                    => pipe_status3, -- tes std state: output status
      o_pipe_status2                    => pipe_status2, -- mux squid tf: output status
      o_pipe_status1                    => pipe_status1, -- amp squid tf: output status
      o_pipe_status0                    => pipe_status0, -- tes pulse shape: output status

      -- reg errors/status
      o_reg_errors0                     => reg_errors0, -- common register errors
      o_reg_status0                     => reg_status0, -- common register status

      -- ctrl errors/status
      o_ctrl_errors0                    => ctrl_errors0, -- register ctrl errors
      o_ctrl_status0                    => ctrl_status0, -- register ctrl status

      -- debug_ctrl errors/status
      o_debug_ctrl_errors0              => debug_ctrl_errors0, -- register debug_ctrl errors
      o_debug_ctrl_status0              => debug_ctrl_status0, -- register debug_ctrl status

      -- make_pulse errors/status
      o_make_pulse_errors0              => make_pulse_errors0, -- register make_pulse errors
      o_make_pulse_status0              => make_pulse_status0 -- register make_pulse status
    );

  -- extract fields from the ctrl register
  rst <= reg_ctrl(c_CTRL_RST_IDX_H);
  en  <= reg_ctrl(c_CTRL_EN_IDX_H);

  -- extract fields from the make_pulse register
  cmd_valid            <= reg_make_pulse_valid;
  cmd_pixel_id         <= reg_make_pulse(c_MAKE_PULSE_PIXEL_ID_IDX_H downto c_MAKE_PULSE_PIXEL_ID_IDX_L);
  cmd_time_shift       <= reg_make_pulse(c_MAKE_PULSE_TIME_SHIFT_IDX_H downto c_MAKE_PULSE_TIME_SHIFT_IDX_L);
  cmd_pulse_height     <= reg_make_pulse(c_MAKE_PULSE_PULSE_HEIGHT_IDX_H downto c_MAKE_PULSE_PULSE_HEIGHT_IDX_L);
  reg_make_pulse_ready <= cmd_ready;

  -- extract fields from the reg_fpasim_gain
  fpasim_gain <= reg_fpasim_gain(c_FPASIM_GAIN_IDX_H downto c_FPASIM_GAIN_IDX_L); -- @suppress "Incorrect array size in assignment: expected (<pkg_FPASIM_GAIN_WIDTH>) but was (<3>)"

  -- extract fields from the reg_mux_sq_fb_delay
  adc0_delay <= reg_mux_sq_fb_delay(c_MUX_SQ_FB_DELAY_IDX_H downto c_MUX_SQ_FB_DELAY_IDX_L); -- @suppress "Incorrect array size in assignment: expected (<pkg_AMP_SQ_OF_DELAY_WIDTH>) but was (<6>)"
  -- extract fields from the reg_amp_sq_of_delay
  adc1_delay <= reg_amp_sq_of_delay(c_AMP_SQ_OF_DELAY_IDX_H downto c_AMP_SQ_OF_DELAY_IDX_L); -- @suppress "Incorrect array size in assignment: expected (<pkg_MUX_SQ_FB_DELAY_WIDTH>) but was (<6>)"

  -- extract fields from the error_delay
  dac_delay <= reg_error_delay(c_ERROR_DELAY_IDX_H downto c_ERROR_DELAY_IDX_L); -- @suppress "Incorrect array size in assignment: expected (<pkg_ERROR_DELAY_WIDTH>) but was (<6>)"

  -- extract fields from the ra_delay
  sync_delay <= reg_ra_delay(c_RA_DELAY_IDX_H downto c_RA_DELAY_IDX_L); -- @suppress "Incorrect array size in assignment: expected (<pkg_RA_DELAY_WIDTH>) but was (<6>)"

  -- extract fields from the tes_conf
  nb_pixel_by_frame  <= reg_tes_conf(c_TES_CONF_NB_PIXEL_BY_FRAME_IDX_H downto c_TES_CONF_NB_PIXEL_BY_FRAME_IDX_L); -- @suppress "Incorrect array size in assignment: expected (<pkg_TES_CONF_NB_PIXEL_BY_FRAME_WIDTH>) but was (<6>)"
  nb_sample_by_pixel <= reg_tes_conf(c_TES_CONF_NB_SAMPLE_BY_PIXEL_IDX_H downto c_TES_CONF_NB_SAMPLE_BY_PIXEL_IDX_L); -- @suppress "Incorrect array size in assignment: expected (<pkg_TES_CONF_NB_SAMPLE_BY_PIXEL_WIDTH>) but was (<7>)"
  nb_sample_by_frame <= reg_tes_conf(c_TES_CONF_NB_SAMPLE_BY_FRAME_IDX_H downto c_TES_CONF_NB_SAMPLE_BY_FRAME_IDX_L); -- @suppress "Incorrect array size in assignment: expected (<pkg_TES_CONF_NB_SAMPLE_BY_FRAME_WIDTH>) but was (<13>)"

  -- extract fields from the debug_ctrl register
  debug_pulse <= reg_debug_ctrl(c_DEBUG_CTRL_DEBUG_PULSE_IDX_H);
  rst_status  <= reg_debug_ctrl(c_DEBUG_CTRL_RST_STATUS_IDX_H);

  -- errors
  reg_wire_errors7(31 downto 16) <= pipe_errors5; -- rd all: output errors
  reg_wire_errors7(15 downto 0)  <= pipe_errors4; -- mux squid offset: output errors

  reg_wire_errors6(31 downto 16) <= pipe_errors3; -- tes std state: output errors
  reg_wire_errors6(15 downto 0)  <= pipe_errors2; -- mux squid tf: output errors

  reg_wire_errors5(31 downto 16) <= pipe_errors1; -- amp squid tf: output errors
  reg_wire_errors5(15 downto 0)  <= pipe_errors0; -- tes pulse shape: output errors

  reg_wire_errors4(31 downto 16) <= debug_ctrl_errors0; -- debug ctrl register
  reg_wire_errors4(15 downto 0)  <= reg_errors0; -- reg register

  reg_wire_errors3(31 downto 16) <= make_pulse_errors0; -- make pulse register
  reg_wire_errors3(15 downto 0)  <= ctrl_errors0; -- ctrl register

  reg_wire_errors2(31 downto 16) <= sync_errors0; -- sync top
  reg_wire_errors2(15 downto 0)  <= dac_errors0; -- dac

  reg_wire_errors1(31 downto 16) <= amp_squid_errors0; -- amp squid
  reg_wire_errors1(15 downto 0)  <= mux_squid_errors0; -- mux squid

  reg_wire_errors0(31 downto 16) <= tes_errors0; -- tes
  reg_wire_errors0(15 downto 0)  <= adc_errors0; -- adc

  -- status
  reg_wire_status7(31 downto 24) <= (others => '0');
  reg_wire_status7(23 downto 16) <= pipe_status5; -- rd all: output status
  reg_wire_status7(15 downto 8)  <= (others => '0');
  reg_wire_status7(7 downto 0)   <= pipe_status4; -- mux squid offset: output status

  reg_wire_status6(31 downto 24) <= (others => '0');
  reg_wire_status6(23 downto 16) <= pipe_status3; -- tes std state: output status
  reg_wire_status6(15 downto 8)  <= (others => '0');
  reg_wire_status6(7 downto 0)   <= pipe_status2; -- mux squid tf: output status

  reg_wire_status5(31 downto 24) <= (others => '0');
  reg_wire_status5(23 downto 16) <= pipe_status1; -- amp squid tf: output status
  reg_wire_status5(15 downto 8)  <= (others => '0');
  reg_wire_status5(7 downto 0)   <= pipe_status0; -- tes pulse shape: output status

  reg_wire_status4(31 downto 24) <= (others => '0');
  reg_wire_status4(23 downto 16) <= debug_ctrl_status0; -- debug ctrl register
  reg_wire_status4(15 downto 8)  <= (others => '0');
  reg_wire_status4(7 downto 0)   <= reg_status0; -- reg register

  reg_wire_status3(31 downto 24) <= (others => '0');
  reg_wire_status3(23 downto 16) <= make_pulse_status0; -- make pulse
  reg_wire_status3(15 downto 8)  <= (others => '0');
  reg_wire_status3(7 downto 0)   <= ctrl_status0; -- ctrl register

  reg_wire_status2(31 downto 24) <= (others => '0');
  reg_wire_status2(23 downto 16) <= sync_status0; -- sync top
  reg_wire_status2(15 downto 8)  <= (others => '0');
  reg_wire_status2(7 downto 0)   <= dac_status0; -- dac

  reg_wire_status1(31 downto 24) <= (others => '0');
  reg_wire_status1(23 downto 16) <= amp_squid_status0; -- amp squid
  reg_wire_status1(15 downto 8)  <= (others => '0');
  reg_wire_status1(7 downto 0)   <= mux_squid_status0; -- mux squid

  reg_wire_status0(31 downto 24) <= (others => '0');
  reg_wire_status0(23 downto 16) <= tes_status0; -- tes
  reg_wire_status0(15 downto 8)  <= (others => '0');
  reg_wire_status0(7 downto 0)   <= adc_status0; -- adc

  ---------------------------------------------------------------------
  -- adc
  ---------------------------------------------------------------------
  inst_adc_top : entity fpasim.adc_top
    generic map(
      g_ADC1_WIDTH       => i_adc_mux_squid_feedback'length,
      g_ADC0_WIDTH       => i_adc_amp_squid_offset_correction'length,
      g_ADC1_DELAY_WIDTH => adc1_delay'length,
      g_ADC0_DELAY_WIDTH => adc0_delay'length
    )
    port map(
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_adc_clk     => i_adc_clk,
      i_adc_valid   => i_adc_valid,
      i_adc1        => i_adc_mux_squid_feedback,
      i_adc0        => i_adc_amp_squid_offset_correction,
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      i_clk         => i_clk,
      -- from regdecode
      -----------------------------------------------------------------
      i_rst_status  => rst_status,
      i_debug_pulse => debug_pulse,
      i_en          => en,
      i_adc1_delay  => adc1_delay,
      i_adc0_delay  => adc0_delay,
      -- output
      -----------------------------------------------------------------
      o_adc_valid   => adc_valid0,
      o_adc1        => adc_mux_squid_feedback0,
      o_adc0        => adc_amp_squid_offset_correction0,
      ---------------------------------------------------------------------
      -- errors/status
      --------------------------------------------------------------------- 
      o_errors      => adc_errors0,
      o_status      => adc_status0
    );

  ---------------------------------------------------------------------
  -- tes
  ---------------------------------------------------------------------
  -- extract LSB address bits
  tes_pulse_shape_ram_wr_rd_addr_tmp <= tes_pulse_shape_ram_wr_rd_addr(tes_pulse_shape_ram_wr_rd_addr_tmp'range);
  tes_std_state_ram_wr_rd_addr_tmp   <= tes_std_state_ram_wr_rd_addr(tes_std_state_ram_wr_rd_addr_tmp'range);

  inst_tes_top : entity fpasim.tes_top
    generic map(
      -- command
      g_CMD_PULSE_HEIGHT_WIDTH        => cmd_pulse_height'length,
      g_CMD_TIME_SHIFT_WIDTH          => cmd_time_shift'length,
      g_CMD_PIXEL_ID_WIDTH            => cmd_pixel_id'length,
      -- pixel
      g_NB_SAMPLE_BY_PIXEL_WIDTH      => nb_sample_by_pixel'length,
      -- frame
      g_NB_SAMPLE_BY_FRAME_WIDTH      => nb_sample_by_frame'length,
      g_NB_FRAME_BY_PULSE_SHAPE_WIDTH => frame_id1'length,
      g_NB_FRAME_BY_PULSE_SHAPE       => c_NB_FRAME_BY_PULSE_SHAPE,
      -- addr
      g_PULSE_SHAPE_RAM_ADDR_WIDTH    => tes_pulse_shape_ram_wr_rd_addr_tmp'length,
      -- output
      g_PIXEL_RESULT_OUTPUT_WIDTH     => pixel_result1'length
    )
    port map(
      i_clk                     => i_clk,
      i_rst                     => rst,
      i_rst_status              => rst_status,
      i_debug_pulse             => debug_pulse,
      ---------------------------------------------------------------------
      -- input command: from the regdecode
      ---------------------------------------------------------------------
      i_en                      => en,
      i_nb_sample_by_pixel      => nb_sample_by_pixel,
      i_nb_pixel_by_frame       => nb_pixel_by_frame, -- @suppress "Incorrect array size in assignment: expected (<pkg_NB_SAMPLE_BY_PIXEL_MAX_WIDTH>) but was (<pkg_TES_CONF_NB_PIXEL_BY_FRAME_WIDTH>)"
      i_nb_sample_by_frame      => nb_sample_by_frame,
      -- command
      i_cmd_valid               => cmd_valid,
      i_cmd_pulse_height        => cmd_pulse_height,
      i_cmd_pixel_id            => cmd_pixel_id,
      i_cmd_time_shift          => cmd_time_shift,
      o_cmd_ready               => cmd_ready,
      -- RAM: pulse shape
      -- wr
      i_pulse_shape_wr_en       => tes_pulse_shape_ram_wr_en,
      i_pulse_shape_wr_rd_addr  => tes_pulse_shape_ram_wr_rd_addr_tmp,
      i_pulse_shape_wr_data     => tes_pulse_shape_ram_wr_data,
      -- rd
      i_pulse_shape_rd_en       => tes_pulse_shape_ram_rd_en,
      o_pulse_shape_rd_valid    => tes_pulse_shape_ram_rd_valid,
      o_pulse_shape_rd_data     => tes_pulse_shape_ram_rd_data,
      -- RAM:
      -- wr
      i_steady_state_wr_en      => tes_std_state_ram_wr_en,
      i_steady_state_wr_rd_addr => tes_std_state_ram_wr_rd_addr_tmp, -- @suppress "Incorrect array size in assignment: expected (<pkg_NB_SAMPLE_BY_PIXEL_MAX_WIDTH>) but was (<pkg_NB_PIXEL_BY_FRAME_MAX_WIDTH>)"
      i_steady_state_wr_data    => tes_std_state_ram_wr_data,
      -- rd
      i_steady_state_rd_en      => tes_std_state_ram_rd_en,
      o_steady_state_rd_valid   => tes_std_state_ram_rd_valid,
      o_steady_state_rd_data    => tes_std_state_ram_rd_data,
      ---------------------------------------------------------------------
      -- from the adc
      ---------------------------------------------------------------------
      i_data_valid              => adc_valid0,
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_pixel_sof               => pixel_sof1,
      o_pixel_eof               => pixel_eof1,
      o_pixel_valid             => pixel_valid1,
      o_pixel_id                => pixel_id1, -- @suppress "Incorrect array size in assignment: expected (<pkg_NB_SAMPLE_BY_PIXEL_MAX_WIDTH>) but was (<pkg_NB_PIXEL_BY_FRAME_MAX_WIDTH>)"
      o_pixel_result            => pixel_result1,
      o_frame_sof               => frame_sof1,
      o_frame_eof               => frame_eof1,
      o_frame_id                => frame_id1,
      ---------------------------------------------------------------------
      -- errors/status
      ---------------------------------------------------------------------
      o_errors                  => tes_errors0,
      o_status                  => tes_status0
    );

  -- sync with inst_tes_top out
  -----------------------------------------------------------------
  data_pipe_tmp0(c_IDX1_H downto c_IDX1_L) <= adc_mux_squid_feedback0;
  data_pipe_tmp0(c_IDX0_H downto c_IDX0_L) <= adc_amp_squid_offset_correction0;
  inst_pipeliner_sync_with_tes_top_out : entity fpasim.pipeliner
    generic map(
      g_NB_PIPES   => c_TES_TOP_LATENCY,
      g_DATA_WIDTH => data_pipe_tmp0'length
    )
    port map(
      i_clk  => i_clk,
      i_data => data_pipe_tmp0,
      o_data => data_pipe_tmp1
    );

  mux_squid_feedback1          <= data_pipe_tmp1(c_IDX1_H downto c_IDX1_L);
  amp_squid_offset_correction1 <= data_pipe_tmp1(c_IDX0_H downto c_IDX0_L);

  ---------------------------------------------------------------------
  -- mux squid
  ---------------------------------------------------------------------
  -- extract LSB address bits
  mux_squid_tf_ram_wr_rd_addr_tmp     <= mux_squid_tf_ram_wr_rd_addr(mux_squid_tf_ram_wr_rd_addr_tmp'range);
  mux_squid_offset_ram_wr_rd_addr_tmp <= mux_squid_offset_ram_wr_rd_addr(mux_squid_offset_ram_wr_rd_addr_tmp'range);

  inst_mux_squid_top : entity fpasim.mux_squid_top
    generic map(
      -- pixel
      g_PIXEL_ID_WIDTH              => pixel_id1'length,
      -- frame
      g_FRAME_ID_WIDTH              => frame_id1'length,
      -- address
      g_MUX_SQUID_TF_RAM_ADDR_WIDTH => mux_squid_tf_ram_wr_rd_addr_tmp'length,
      -- computation
      g_PIXEL_RESULT_INPUT_WIDTH    => pixel_result1'length,
      g_PIXEL_RESULT_OUTPUT_WIDTH   => pixel_result2'length
    )
    port map(
      i_clk                         => i_clk,
      i_rst_status                  => rst_status,
      i_debug_pulse                 => debug_pulse,
      ---------------------------------------------------------------------
      -- input command: from the regdecode
      ---------------------------------------------------------------------
      -- RAM: mux_squid_offset
      -- wr
      i_mux_squid_offset_wr_en      => mux_squid_offset_ram_wr_en,
      i_mux_squid_offset_wr_rd_addr => mux_squid_offset_ram_wr_rd_addr_tmp,
      i_mux_squid_offset_wr_data    => mux_squid_offset_ram_wr_data,
      -- rd
      i_mux_squid_offset_rd_en      => mux_squid_offset_ram_rd_en,
      o_mux_squid_offset_rd_valid   => mux_squid_offset_ram_rd_valid,
      o_mux_squid_offset_rd_data    => mux_squid_offset_ram_rd_data,
      -- RAM: mux_squid_tf
      -- wr
      i_mux_squid_tf_wr_en          => mux_squid_tf_ram_wr_en,
      i_mux_squid_tf_wr_rd_addr     => mux_squid_tf_ram_wr_rd_addr_tmp,
      i_mux_squid_tf_wr_data        => mux_squid_tf_ram_wr_data,
      -- rd
      i_mux_squid_tf_rd_en          => mux_squid_tf_ram_rd_en,
      o_mux_squid_tf_rd_valid       => mux_squid_tf_ram_rd_valid,
      o_mux_squid_tf_rd_data        => mux_squid_tf_ram_rd_data,
      ---------------------------------------------------------------------
      -- input1
      ---------------------------------------------------------------------
      i_pixel_sof                   => pixel_sof1,
      i_pixel_eof                   => pixel_eof1,
      i_pixel_valid                 => pixel_valid1,
      i_pixel_id                    => pixel_id1,
      i_pixel_result                => pixel_result1,
      i_frame_sof                   => frame_sof1,
      i_frame_eof                   => frame_eof1,
      i_frame_id                    => frame_id1,
      ---------------------------------------------------------------------
      -- input2
      ---------------------------------------------------------------------
      i_mux_squid_feedback          => mux_squid_feedback1,
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_pixel_sof                   => pixel_sof2,
      o_pixel_eof                   => pixel_eof2,
      o_pixel_valid                 => pixel_valid2,
      o_pixel_id                    => pixel_id2,
      o_pixel_result                => pixel_result2,
      o_frame_sof                   => frame_sof2,
      o_frame_eof                   => frame_eof2,
      o_frame_id                    => frame_id2,
      ---------------------------------------------------------------------
      -- errors/status
      ---------------------------------------------------------------------
      o_errors                      => mux_squid_errors0,
      o_status                      => mux_squid_status0
    );

  -- sync with inst_mux_squid_top out
  -----------------------------------------------------------------
  inst_pipeliner_sync_with_mux_squid_top_out : entity fpasim.pipeliner
    generic map(
      g_NB_PIPES   => c_MUX_SQUID_TOP_LATENCY, -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => amp_squid_offset_correction1'length -- width of the input/output data.  Possibles values: [1, integer max value[
    )
    port map(
      i_clk  => i_clk,                  -- clock signal
      i_data => amp_squid_offset_correction1, -- input data
      o_data => amp_squid_offset_correction2 -- output data with/without delay
    );

  ---------------------------------------------------------------------
  -- amp squid
  ---------------------------------------------------------------------
  -- extract LSB address bits
  amp_squid_tf_ram_wr_rd_addr_tmp <= amp_squid_tf_ram_wr_rd_addr(amp_squid_tf_ram_wr_rd_addr_tmp'range);

  inst_amp_squid_top : entity fpasim.amp_squid_top
    generic map(
      -- pixel
      g_PIXEL_ID_WIDTH              => pixel_id1'length,
      -- frame
      g_FRAME_ID_WIDTH              => frame_id1'length,
      -- address
      g_AMP_SQUID_TF_RAM_ADDR_WIDTH => amp_squid_tf_ram_wr_rd_addr_tmp'length,
      -- computation
      g_PIXEL_RESULT_INPUT_WIDTH    => pixel_result2'length,
      g_PIXEL_RESULT_OUTPUT_WIDTH   => pixel_result3'length
    )
    port map(
      i_clk                         => i_clk, -- clock
      i_rst_status                  => rst_status, -- reset error flags
      i_debug_pulse                 => debug_pulse, -- '1': delayed error, '0': latched error

      ---------------------------------------------------------------------
      -- input command: from the regdecode
      ---------------------------------------------------------------------
      -- RAM: amp_squid_tf
      -- wr
      i_amp_squid_tf_wr_en          => amp_squid_tf_ram_wr_en, -- write enable
      i_amp_squid_tf_wr_rd_addr     => amp_squid_tf_ram_wr_rd_addr_tmp, -- write address
      i_amp_squid_tf_wr_data        => amp_squid_tf_ram_wr_data, -- write data
      -- rd
      i_amp_squid_tf_rd_en          => amp_squid_tf_ram_rd_en, -- read enable
      o_amp_squid_tf_rd_valid       => amp_squid_tf_ram_rd_valid, -- read valid
      o_amp_squid_tf_rd_data        => amp_squid_tf_ram_rd_data, -- read data

      -- gain
      i_fpasim_gain                 => fpasim_gain, -- gain value -- @suppress "Incorrect array size in assignment: expected (<3>) but was (<pkg_FPASIM_GAIN_WIDTH>)"
      ---------------------------------------------------------------------
      -- input1
      ---------------------------------------------------------------------
      i_pixel_sof                   => pixel_sof2, -- first sample of a pixel
      i_pixel_eof                   => pixel_eof2, -- last sample of a pixel
      i_pixel_valid                 => pixel_valid2, -- valid sample of a pixel
      i_pixel_id                    => pixel_id2, -- id of a pixel
      i_pixel_result                => pixel_result2,
      i_frame_sof                   => frame_sof2, -- first sample of a frame
      i_frame_eof                   => frame_eof2, -- last sample of a frame
      i_frame_id                    => frame_id2, -- id of a frame
      ---------------------------------------------------------------------
      -- input2
      ---------------------------------------------------------------------
      i_amp_squid_offset_correction => amp_squid_offset_correction2,
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_pixel_sof                   => pixel_sof3, -- not connected
      o_pixel_eof                   => pixel_eof3, -- not connected
      o_pixel_valid                 => pixel_valid3,
      o_pixel_id                    => pixel_id3, -- not connected
      o_pixel_result                => pixel_result3,
      o_frame_sof                   => frame_sof3,
      o_frame_eof                   => frame_eof3, -- not connected
      o_frame_id                    => frame_id3, -- not connected
      ---------------------------------------------------------------------
      -- errors/status
      ---------------------------------------------------------------------
      o_errors                      => amp_squid_errors0, -- output errors
      o_status                      => amp_squid_status0 -- output status
    );

  ---------------------------------------------------------------------
  -- dac_top
  ---------------------------------------------------------------------
  inst_dac_top : entity fpasim.dac_top
    generic map(
      g_DAC_DELAY_WIDTH => dac_delay'length
    )
    port map(
      ---------------------------------------------------------------------
      -- input @i_clk
      ---------------------------------------------------------------------
      i_clk         => i_clk,
      i_rst         => rst,
      -- from regdecode
      -----------------------------------------------------------------
      i_rst_status  => rst_status,
      i_debug_pulse => debug_pulse,
      i_en          => en,
      i_dac_delay   => dac_delay,
      -- input data 
      ---------------------------------------------------------------------
      i_dac_valid   => pixel_valid3,
      i_dac         => pixel_result3,
      ---------------------------------------------------------------------
      -- output @i_clk_dac
      ---------------------------------------------------------------------
      i_dac_clk     => i_dac_clk,
      o_dac_valid   => dac_valid4,
      o_dac_frame   => dac_frame4,
      o_dac         => dac4,
      ---------------------------------------------------------------------
      -- errors/status @i_clk
      --------------------------------------------------------------------- 
      o_errors      => dac_errors0,
      o_status      => dac_status0
    );

  ---------------------------------------------------------------------
  -- sync_top
  ---------------------------------------------------------------------
  inst_sync_top : entity fpasim.sync_top
    generic map(
      g_PULSE_DURATION   => c_SYNC_PULSE_DURATION, -- duration of the output pulse. Possible values [1;integer max value[
      g_SYNC_DELAY_WIDTH => sync_delay'length
    )
    port map(
      ---------------------------------------------------------------------
      -- input @i_clk
      ---------------------------------------------------------------------
      i_clk         => i_clk,           -- clock
      i_rst         => rst,             -- reset
      -- from regdecode
      -----------------------------------------------------------------
      i_rst_status  => rst_status,
      i_debug_pulse => debug_pulse,
      i_sync_delay  => sync_delay,
      -- input data 
      ---------------------------------------------------------------------
      i_sync_valid  => pixel_valid3,
      i_sync        => frame_sof3,
      ---------------------------------------------------------------------
      -- output @i_ref_clk
      ---------------------------------------------------------------------
      i_ref_clk     => i_ref_clk,
      o_sync_valid  => sync_valid5,     -- not connected
      o_sync        => sync5,
      ---------------------------------------------------------------------
      -- errors/status @i_clk
      --------------------------------------------------------------------- 
      o_errors      => sync_errors0,
      o_status      => sync_status0
    );

  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  -- @i_clk_dac
  o_dac_valid <= dac_valid4;
  o_dac_frame <= dac_frame4;
  o_dac       <= dac4;
  -- @i_ref_clk
  o_sync      <= sync5;

  ---------------------------------------------------------------------
  -- debug
  ---------------------------------------------------------------------
  gen_debug : if g_DEBUG = true generate -- @suppress "Redundant boolean equality check with true"
    -- inst_fpasim_top_ila_0 : entity fpasim.fpasim_top_ila_0
    --   port map(
    --     clk                 => i_clk,
    --     probe0              => pixel_result3,
    --     probe1(21)          => pixel_sof3,
    --     probe1(20)          => pixel_eof3,
    --     probe1(19)          => pixel_valid3,
    --     probe1(18)          => frame_sof3,
    --     probe1(17)          => frame_eof3,
    --     probe1(16 downto 6) => frame_id3,
    --     probe1(5 downto 0)  => pixel_id3
    --   );
  end generate gen_debug;

end architecture RTL;
