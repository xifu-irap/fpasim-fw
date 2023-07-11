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
--    @file                   fpasim_top.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This module is the top_level of the fpasim functionnality
--
--    Note: the application reset is managed in the reset_top module in the upper level.
--       o_usb_rst -> reset_top -> i_rst
--       o_usb_rst -> reset_top -> i_usb_rst
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_fpasim.all;
use work.pkg_regdecode.all;

entity fpasim_top is
  generic(
    g_FPASIM_DEBUG        : boolean := false;  -- true: instantiate ILA, false: do nothing
    g_REGDECODE_TOP_DEBUG : boolean := false  -- true: instantiate ILA, false: do nothing
    );
  port(
    i_clk      : in    std_logic;       -- system clock
    i_rst      : in    std_logic;       -- reset
    ---------------------------------------------------------------------
    -- from the usb @usb_clk (clock included)
    ---------------------------------------------------------------------
    --  Opal Kelly inouts --
    i_okUH     : in    std_logic_vector(4 downto 0);
    o_okHU     : out   std_logic_vector(2 downto 0);
    b_okUHU    : inout std_logic_vector(31 downto 0);
    b_okAA     : inout std_logic;
    ---------------------------------------------------------------------
    -- from the board
    ---------------------------------------------------------------------
    i_board_id : in    std_logic_vector(7 downto 0);  -- board id

    ---------------------------------------------------------------------
    -- to the IOs:@i_clk
    ---------------------------------------------------------------------
    o_rst_status  : out std_logic;      -- reset error flag(s)
    o_debug_pulse : out std_logic;  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)

    ---------------------------------------------------------------------
    -- from/to the spi: @usb_clk
    ---------------------------------------------------------------------
    o_usb_clk            : out std_logic;  -- clock @usb_clk
    -- tx
    o_spi_rst            : out std_logic;  -- reset the spi module
    o_spi_en             : out std_logic;  -- enable the spi module
    o_spi_dac_tx_present : out std_logic;  -- enable the dac
    o_spi_mode           : out std_logic;  --
    o_spi_id             : out std_logic_vector(1 downto 0);  -- select the spi module
    o_spi_cmd_valid      : out std_logic;  -- spi command valid
    o_spi_cmd_wr_data    : out std_logic_vector(31 downto 0);  -- spi command value
    -- rx
    i_spi_rd_data_valid  : in  std_logic;  -- spi read valid
    i_spi_rd_data        : in  std_logic_vector(31 downto 0);  -- spi read value
    i_reg_spi_status     : in  std_logic_vector(31 downto 0);  -- spi status for the register
    -- others
    o_usb_rst_status     : out std_logic;  -- rst status signal @i_usb_clk
    o_usb_debug_pulse    : out std_logic;  -- debug pulse signal @i_usb_clk
    -- errors/status
    i_spi_errors         : in  std_logic_vector(15 downto 0);  -- spi errors
    i_spi_status         : in  std_logic_vector(7 downto 0);  -- spi status

    ---------------------------------------------------------------------
    -- from/to regdecode @usb_clk
    ---------------------------------------------------------------------
    o_usb_rst : out std_logic;          -- reset @clk_usb (from register)
    i_usb_rst : in  std_logic;          -- reset @clk_usb to used

    ---------------------------------------------------------------------
    -- from adc @i_clk
    ---------------------------------------------------------------------
    i_adc_valid                       : in  std_logic;  -- adc valid
    i_adc_amp_squid_offset_correction : in  std_logic_vector(13 downto 0);  -- adc_amp_squid_offset_correction value
    i_adc_mux_squid_feedback          : in  std_logic_vector(13 downto 0);  -- adc_mux_squid_feedback value
    ---------------------------------------------------------------------
    -- from the ios
    ---------------------------------------------------------------------
    i_adc_errors                      : in  std_logic_vector(15 downto 0);  -- errors
    i_adc_status                      : in  std_logic_vector(7 downto 0);  -- status
    ---------------------------------------------------------------------
    -- output sync @i_clk
    ---------------------------------------------------------------------
    o_sync_valid                      : out std_logic;  -- sync valid signal
    o_sync                            : out std_logic;  -- sync value (pulse)

    i_sync_errors : in  std_logic_vector(15 downto 0);  -- sync_errors value
    i_sync_status : in  std_logic_vector(7 downto 0);   -- sync_status value
    ---------------------------------------------------------------------
    -- output dac @i_clk
    ---------------------------------------------------------------------
    o_dac_valid   : out std_logic;                      -- dac valid
    o_dac_frame   : out std_logic;                      -- dac frame
    o_dac1        : out std_logic_vector(15 downto 0);  -- output dac1
    o_dac0        : out std_logic_vector(15 downto 0);  -- output dac0
    ---------------------------------------------------------------------
    -- from the ios @i_clk
    ---------------------------------------------------------------------
    i_dac_errors  : in  std_logic_vector(15 downto 0);  -- errors
    i_dac_status  : in  std_logic_vector(7 downto 0)    -- status
    );
end entity fpasim_top;

architecture RTL of fpasim_top is

  ---------------------------------------------------------------------
  -- regdecode
  ---------------------------------------------------------------------
  -- usb clock
  signal usb_clk         : std_logic;
  signal usb_rst_status  : std_logic;
  signal usb_debug_pulse : std_logic;
  signal usb_rst         : std_logic;

  -- ctrl register
  --signal rst : std_logic;
  signal en : std_logic;

  -- make_pulse register
  signal cmd_valid        : std_logic;
  signal cmd_pixel_id     : std_logic_vector(pkg_MAKE_PULSE_PIXEL_ID_WIDTH - 1 downto 0);
  signal cmd_time_shift   : std_logic_vector(pkg_MAKE_PULSE_TIME_SHIFT_WIDTH - 1 downto 0);
  signal cmd_pulse_height : std_logic_vector(pkg_MAKE_PULSE_PULSE_HEIGHT_WIDTH - 1 downto 0);
  signal cmd_ready        : std_logic;
  signal fpasim_gain      : std_logic_vector(pkg_FPASIM_GAIN_WIDTH - 1 downto 0);

  -- mux_sq_fb_delay register
  signal adc1_delay : std_logic_vector(pkg_MUX_SQ_FB_DELAY_WIDTH - 1 downto 0);
  -- amp_sq_of_delay register
  signal adc0_delay : std_logic_vector(pkg_AMP_SQ_OF_DELAY_WIDTH - 1 downto 0);

  -- error_delay register
  signal dac_delay : std_logic_vector(pkg_ERROR_DELAY_WIDTH - 1 downto 0);

  -- ra_delay register
  signal sync_delay : std_logic_vector(pkg_RA_DELAY_WIDTH - 1 downto 0);

  -- tes_conf register
  signal nb_pixel_by_frame  : std_logic_vector(pkg_TES_CONF_NB_PIXEL_BY_FRAME_WIDTH - 1 downto 0);
  signal nb_sample_by_pixel : std_logic_vector(pkg_TES_CONF_NB_SAMPLE_BY_PIXEL_WIDTH - 1 downto 0);
  signal nb_sample_by_frame : std_logic_vector(pkg_TES_CONF_NB_SAMPLE_BY_FRAME_WIDTH - 1 downto 0);

  -- conf0 register
  signal inter_squid_gain : std_logic_vector(pkg_CONF0_INTER_SQUID_GAIN_WIDTH - 1 downto 0);

  -- debug_ctrl register
  signal rst_status           : std_logic;
  signal debug_pulse          : std_logic;
  signal dac_en_pattern : std_logic;

  -- RAM configuration
  ---------------------------------------------------------------------
  -- tes_pulse_shape
  -- ram: wr
  signal tes_pulse_shape_ram_wr_en          : std_logic;
  signal tes_pulse_shape_ram_wr_rd_addr     : std_logic_vector(15 downto 0);
  signal tes_pulse_shape_ram_wr_data        : std_logic_vector(15 downto 0);
  signal tes_pulse_shape_ram_wr_rd_addr_tmp : std_logic_vector(pkg_TES_PULSE_SHAPE_RAM_ADDR_WIDTH - 1 downto 0);
  -- ram: rd
  signal tes_pulse_shape_ram_rd_en          : std_logic;
  signal tes_pulse_shape_ram_rd_valid       : std_logic;
  signal tes_pulse_shape_ram_rd_data        : std_logic_vector(15 downto 0);

  -- amp_squid_tf
  -- ram: wr
  signal amp_squid_tf_ram_wr_en              : std_logic;
  signal amp_squid_tf_ram_wr_rd_addr         : std_logic_vector(15 downto 0);
  signal amp_squid_tf_ram_wr_data            : std_logic_vector(15 downto 0);
  signal amp_squid_tf_ram_wr_rd_addr_tmp     : std_logic_vector(pkg_AMP_SQUID_TF_RAM_ADDR_WIDTH - 1 downto 0);
  -- ram: rd
  signal amp_squid_tf_ram_rd_en              : std_logic;
  signal amp_squid_tf_ram_rd_valid           : std_logic;
  signal amp_squid_tf_ram_rd_data            : std_logic_vector(15 downto 0);
  -- mux_squid_tf
  -- ram: wr
  signal mux_squid_tf_ram_wr_en              : std_logic;
  signal mux_squid_tf_ram_wr_rd_addr         : std_logic_vector(15 downto 0);
  signal mux_squid_tf_ram_wr_data            : std_logic_vector(15 downto 0);
  signal mux_squid_tf_ram_wr_rd_addr_tmp     : std_logic_vector(pkg_MUX_SQUID_TF_RAM_ADDR_WIDTH - 1 downto 0);
  -- ram: rd
  signal mux_squid_tf_ram_rd_en              : std_logic;
  signal mux_squid_tf_ram_rd_valid           : std_logic;
  signal mux_squid_tf_ram_rd_data            : std_logic_vector(15 downto 0);
  -- tes_std_state
  -- ram: wr
  signal tes_std_state_ram_wr_en             : std_logic;
  signal tes_std_state_ram_wr_rd_addr        : std_logic_vector(15 downto 0);
  signal tes_std_state_ram_wr_data           : std_logic_vector(15 downto 0);
  signal tes_std_state_ram_wr_rd_addr_tmp    : std_logic_vector(pkg_NB_PIXEL_BY_FRAME_MAX_WIDTH - 1 downto 0);
  -- ram: rd
  signal tes_std_state_ram_rd_en             : std_logic;
  signal tes_std_state_ram_rd_valid          : std_logic;
  signal tes_std_state_ram_rd_data           : std_logic_vector(15 downto 0);
  -- mux_squid_offset
  -- ram: wr
  signal mux_squid_offset_ram_wr_en          : std_logic;
  signal mux_squid_offset_ram_wr_rd_addr     : std_logic_vector(15 downto 0);
  signal mux_squid_offset_ram_wr_data        : std_logic_vector(15 downto 0);
  signal mux_squid_offset_ram_wr_rd_addr_tmp : std_logic_vector(pkg_NB_PIXEL_BY_FRAME_MAX_WIDTH - 1 downto 0);
  -- ram: rd
  signal mux_squid_offset_ram_rd_en          : std_logic;
  signal mux_squid_offset_ram_rd_valid       : std_logic;
  signal mux_squid_offset_ram_rd_data        : std_logic_vector(15 downto 0);

  -- Register configuration
  ---------------------------------------------------------------------
  -- common register
  signal reg_valid               : std_logic;  -- register valid
  signal reg_fpasim_gain         : std_logic_vector(31 downto 0);
  signal reg_mux_sq_fb_delay     : std_logic_vector(31 downto 0);
  signal reg_amp_sq_of_delay     : std_logic_vector(31 downto 0);
  signal reg_error_delay         : std_logic_vector(31 downto 0);
  signal reg_ra_delay            : std_logic_vector(31 downto 0);
  signal reg_tes_conf            : std_logic_vector(31 downto 0);
  signal reg_conf0               : std_logic_vector(31 downto 0);
  -- ctrl register
  signal reg_ctrl_valid          : std_logic;  -- register ctrl valid
  signal reg_ctrl                : std_logic_vector(31 downto 0);
  -- debug ctrl register
  signal reg_debug_ctrl_valid    : std_logic;  -- register debug_ctrl valid
  signal reg_debug_ctrl          : std_logic_vector(31 downto 0);
  -- make pulse register
  signal reg_make_sof            : std_logic;  -- first sample
  signal reg_make_eof            : std_logic;  -- last sample
  signal reg_make_pulse_valid    : std_logic;
  signal reg_make_pulse          : std_logic_vector(31 downto 0);
  signal reg_make_pulse_ready    : std_logic;
  -- fpasim_status register
  signal reg_fpasim_status_valid : std_logic;
  signal reg_fpasim_status       : std_logic_vector(31 downto 0);

  -- recording register
  signal reg_rec_valid : std_logic;
  signal reg_rec_ctrl  : std_logic_vector(31 downto 0);
  signal reg_rec_conf0 : std_logic_vector(31 downto 0);

  -- to the user @usb_clk
  signal reg_spi_valid   : std_logic;
  signal reg_spi_ctrl    : std_logic_vector(31 downto 0);
  signal reg_spi_conf0   : std_logic_vector(31 downto 0);
  signal reg_spi_conf1   : std_logic_vector(31 downto 0);
  signal reg_spi_wr_data : std_logic_vector(31 downto 0);

  signal reg_wire_errors3 : std_logic_vector(31 downto 0);
  signal reg_wire_errors2 : std_logic_vector(31 downto 0);
  signal reg_wire_errors1 : std_logic_vector(31 downto 0);
  signal reg_wire_errors0 : std_logic_vector(31 downto 0);

  signal reg_wire_status3 : std_logic_vector(31 downto 0);
  signal reg_wire_status2 : std_logic_vector(31 downto 0);
  signal reg_wire_status1 : std_logic_vector(31 downto 0);
  signal reg_wire_status0 : std_logic_vector(31 downto 0);

  ---------------------------------------------------------------------
  -- adc_top
  ---------------------------------------------------------------------
  signal adc_valid_tmp0                       : std_logic;
  signal adc_mux_squid_feedback_tmp0          : std_logic_vector(i_adc_mux_squid_feedback'range);
  signal adc_amp_squid_offset_correction_tmp0 : std_logic_vector(i_adc_amp_squid_offset_correction'range);

  signal adc_valid0                       : std_logic;
  signal adc_mux_squid_feedback0          : std_logic_vector(i_adc_mux_squid_feedback'range);
  signal adc_amp_squid_offset_correction0 : std_logic_vector(i_adc_amp_squid_offset_correction'range);

  ---------------------------------------------------------------------
  -- tes_top
  ---------------------------------------------------------------------
  signal pulse_sof1    : std_logic; -- first processed sample of a pulse
  signal pulse_eof1    : std_logic; -- last processed sample of a pulse
  signal pixel_sof1    : std_logic; -- first pixel sample
  signal pixel_eof1    : std_logic; -- last pixel sample
  signal pixel_valid1  : std_logic; -- valid pixel sample
  signal pixel_id1     : std_logic_vector(pkg_NB_PIXEL_BY_FRAME_MAX_WIDTH - 1 downto 0); -- pixel id
  signal pixel_result1 : std_logic_vector(pkg_TES_MULT_SUB_Q_WIDTH_S - 1 downto 0); -- pixel result
  signal frame_sof1    : std_logic; -- first frame sample
  signal frame_eof1    : std_logic;  -- last frame sample
  signal frame_id1     : std_logic_vector(pkg_NB_FRAME_BY_PULSE_SHAPE_WIDTH - 1 downto 0); --  frame id

  signal tes_pixel_neg_out_valid1    : std_logic;
  signal tes_pixel_neg_out_error1    : std_logic;
  signal tes_pixel_neg_out_pixel_id1 : std_logic_vector(pkg_NB_PIXEL_BY_FRAME_MAX_WIDTH - 1 downto 0);

  signal tes_errors0 : std_logic_vector(15 downto 0); -- errors from the tes_top module
  signal tes_status0 : std_logic_vector(7 downto 0); -- status from the tes_top module

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
  signal pixel_sof2        : std_logic;-- first pixel sample
  signal pixel_eof2        : std_logic;-- last pixel sample
  signal pixel_valid2      : std_logic;-- valid pixel sample
  signal pixel_id2         : std_logic_vector(pkg_NB_PIXEL_BY_FRAME_MAX_WIDTH - 1 downto 0); -- pixel id
  signal pixel_result2     : std_logic_vector(pkg_MUX_SQUID_MULT_ADD_Q_WIDTH_S - 1 downto 0);-- pixel result
  signal frame_sof2        : std_logic;-- first frame sample
  signal frame_eof2        : std_logic;-- last frame sample
  signal frame_id2         : std_logic_vector(pkg_NB_FRAME_BY_PULSE_SHAPE_WIDTH - 1 downto 0);--  frame id
  signal mux_squid_errors0 : std_logic_vector(15 downto 0); -- errors from the mux_squid_top module
  signal mux_squid_status0 : std_logic_vector(7 downto 0); -- status from the mux_squid_top module

  -- signals synchronization with mux_squid_top
  ---------------------------------------------------------------------
  signal amp_squid_offset_correction2 : std_logic_vector(i_adc_amp_squid_offset_correction'range);

  ---------------------------------------------------------------------
  -- amp_squid_top
  ---------------------------------------------------------------------
  signal pixel_sof3        : std_logic;-- first pixel sample
  signal pixel_eof3        : std_logic;-- last pixel sample
  signal pixel_valid3      : std_logic;-- valid pixel sample
  signal pixel_id3         : std_logic_vector(pkg_NB_PIXEL_BY_FRAME_MAX_WIDTH - 1 downto 0);-- pixel id
  signal pixel_result3     : std_logic_vector(15 downto 0);-- pixel result
  signal frame_sof3        : std_logic;-- first frame sample
  signal frame_eof3        : std_logic;-- last frame sample
  signal frame_id3         : std_logic_vector(pkg_NB_FRAME_BY_PULSE_SHAPE_WIDTH - 1 downto 0);--  frame id
  signal amp_squid_errors0 : std_logic_vector(15 downto 0); -- errors from the amp_squidt_top module
  signal amp_squid_status0 : std_logic_vector(7 downto 0); -- status from the amp_squidt_top module

  ---------------------------------------------------------------------
  -- dac_top
  ---------------------------------------------------------------------
  signal dac_pattern0 : std_logic_vector(7 downto 0);
  signal dac_pattern1 : std_logic_vector(7 downto 0);
  signal dac_pattern2 : std_logic_vector(7 downto 0);
  signal dac_pattern3 : std_logic_vector(7 downto 0);
  signal dac_pattern4 : std_logic_vector(7 downto 0);
  signal dac_pattern5 : std_logic_vector(7 downto 0);
  signal dac_pattern6 : std_logic_vector(7 downto 0);
  signal dac_pattern7 : std_logic_vector(7 downto 0);

  signal dac_valid4 : std_logic; -- dac valid
  signal dac_frame4 : std_logic; -- dac frame
  signal dac1_4     : std_logic_vector(o_dac1'range); -- dac1: data
  signal dac0_4     : std_logic_vector(o_dac0'range); -- dac0: data

  ---------------------------------------------------------------------
  -- sync_top
  ---------------------------------------------------------------------
  signal sync_valid5      : std_logic; -- sync valid
  signal sync5            : std_logic; -- sync value
  signal sync_errors0_tmp : std_logic_vector(15 downto 0);

  signal sync_errors0 : std_logic_vector(15 downto 0); -- errors from the sync_top module
  signal sync_status0 : std_logic_vector(7 downto 0);  -- status from the sync_top module

  ---------------------------------------------------------------------
  -- recording
  ---------------------------------------------------------------------
  signal rec_adc_cmd_valid             : std_logic;
  signal rec_adc_cmd_nb_words_by_block : std_logic_vector(15 downto 0);

  signal fifo_rec_adc_rd         : std_logic;
  signal fifo_rec_adc_sof        : std_logic;
  signal fifo_rec_adc_eof        : std_logic;
  signal fifo_rec_adc_data_valid : std_logic;
  signal fifo_rec_adc_data       : std_logic_vector(31 downto 0);
  signal fifo_rec_adc_empty      : std_logic;

  signal rec_adc_errors0 : std_logic_vector(15 downto 0);
  signal rec_adc_status0 : std_logic_vector(7 downto 0);

  ---------------------------------------------------------------------
  -- debug
  ---------------------------------------------------------------------
  signal debug_dac_pattern_sel : std_logic:= '0';
  signal debug_dac_pattern0    : std_logic_vector(7 downto 0);
  signal debug_dac_pattern1    : std_logic_vector(7 downto 0);
  signal debug_dac_pattern2    : std_logic_vector(7 downto 0);
  signal debug_dac_pattern3    : std_logic_vector(7 downto 0);
  signal debug_dac_pattern4    : std_logic_vector(7 downto 0);
  signal debug_dac_pattern5    : std_logic_vector(7 downto 0);
  signal debug_dac_pattern6    : std_logic_vector(7 downto 0);
  signal debug_dac_pattern7    : std_logic_vector(7 downto 0);

  signal debug_adc_sel                         : std_logic := '0';
  signal debug_adc_mux_squid_feedback          : std_logic_vector(i_adc_mux_squid_feedback'range);
  signal debug_adc_amp_squid_offset_correction : std_logic_vector(i_adc_amp_squid_offset_correction'range);
  signal debug_dac_sel                         : std_logic;
  signal debug_dac1                            : std_logic_vector(15 downto 0);
  signal debug_dac0                            : std_logic_vector(15 downto 0);

begin

  ---------------------------------------------------------------------
  -- RegDecode
  ---------------------------------------------------------------------
  inst_regdecode_top : entity work.regdecode_top
    generic map(
      g_DEBUG => g_REGDECODE_TOP_DEBUG
      )
    port map(
      ---------------------------------------------------------------------
      -- from the usb @i_clk (clock included)
      ---------------------------------------------------------------------
      --  Opal Kelly inouts --
      i_okUH  => i_okUH,
      o_okHU  => o_okHU,
      b_okUHU => b_okUHU,
      b_okAA  => b_okAA,

      ---------------------------------------------------------------------
      -- from/to the user @usb_clk
      ---------------------------------------------------------------------
      o_usb_clk               => usb_clk,
      o_usb_rst_status        => usb_rst_status,
      o_usb_debug_pulse       => usb_debug_pulse,
      -- tx
      o_reg_spi_valid         => reg_spi_valid,
      o_reg_spi_ctrl          => reg_spi_ctrl,
      o_reg_spi_conf0         => reg_spi_conf0,
      o_reg_spi_conf1         => reg_spi_conf1,
      o_reg_spi_wr_data       => reg_spi_wr_data,
      -- rx
      i_reg_spi_rd_data_valid => i_spi_rd_data_valid,
      i_reg_spi_rd_data       => i_spi_rd_data,
      i_reg_spi_status        => i_reg_spi_status,

      -- errors/status
      i_spi_errors => i_spi_errors,
      i_spi_status => i_spi_status,

      -- to/from reset_top
      i_usb_rst => i_usb_rst,
      o_usb_rst => usb_rst,

      ---------------------------------------------------------------------
      -- from the board
      ---------------------------------------------------------------------
      i_board_id => i_board_id,
      ---------------------------------------------------------------------
      -- from/to the user: @i_out_clk
      ---------------------------------------------------------------------
      i_out_rst  => i_rst,              -- reset @i_clk
      i_out_clk  => i_clk,              -- clock (user side)

      -- RAM configuration
      ---------------------------------------------------------------------
      -- tes_pulse_shape
      -- ram: wr
      o_tes_pulse_shape_ram_wr_en       => tes_pulse_shape_ram_wr_en,
      o_tes_pulse_shape_ram_wr_rd_addr  => tes_pulse_shape_ram_wr_rd_addr,
      o_tes_pulse_shape_ram_wr_data     => tes_pulse_shape_ram_wr_data,
      -- ram: rd
      o_tes_pulse_shape_ram_rd_en       => tes_pulse_shape_ram_rd_en,
      i_tes_pulse_shape_ram_rd_valid    => tes_pulse_shape_ram_rd_valid,
      i_tes_pulse_shape_ram_rd_data     => tes_pulse_shape_ram_rd_data,
      -- amp_squid_tf
      -- ram: wr
      o_amp_squid_tf_ram_wr_en          => amp_squid_tf_ram_wr_en,
      o_amp_squid_tf_ram_wr_rd_addr     => amp_squid_tf_ram_wr_rd_addr,
      o_amp_squid_tf_ram_wr_data        => amp_squid_tf_ram_wr_data,
      -- ram: rd
      o_amp_squid_tf_ram_rd_en          => amp_squid_tf_ram_rd_en,
      i_amp_squid_tf_ram_rd_valid       => amp_squid_tf_ram_rd_valid,
      i_amp_squid_tf_ram_rd_data        => amp_squid_tf_ram_rd_data,
      -- mux_squid_tf
      -- ram: wr
      o_mux_squid_tf_ram_wr_en          => mux_squid_tf_ram_wr_en,
      o_mux_squid_tf_ram_wr_rd_addr     => mux_squid_tf_ram_wr_rd_addr,
      o_mux_squid_tf_ram_wr_data        => mux_squid_tf_ram_wr_data,
      -- ram: rd
      o_mux_squid_tf_ram_rd_en          => mux_squid_tf_ram_rd_en,
      i_mux_squid_tf_ram_rd_valid       => mux_squid_tf_ram_rd_valid,
      i_mux_squid_tf_ram_rd_data        => mux_squid_tf_ram_rd_data,
      -- tes_std_state
      -- ram: wr
      o_tes_std_state_ram_wr_en         => tes_std_state_ram_wr_en,
      o_tes_std_state_ram_wr_rd_addr    => tes_std_state_ram_wr_rd_addr,
      o_tes_std_state_ram_wr_data       => tes_std_state_ram_wr_data,
      -- ram: rd
      o_tes_std_state_ram_rd_en         => tes_std_state_ram_rd_en,
      i_tes_std_state_ram_rd_valid      => tes_std_state_ram_rd_valid,
      i_tes_std_state_ram_rd_data       => tes_std_state_ram_rd_data,
      -- mux_squid_offset
      -- ram: wr
      o_mux_squid_offset_ram_wr_en      => mux_squid_offset_ram_wr_en,
      o_mux_squid_offset_ram_wr_rd_addr => mux_squid_offset_ram_wr_rd_addr,
      o_mux_squid_offset_ram_wr_data    => mux_squid_offset_ram_wr_data,
      -- ram: rd
      o_mux_squid_offset_ram_rd_en      => mux_squid_offset_ram_rd_en,
      i_mux_squid_offset_ram_rd_valid   => mux_squid_offset_ram_rd_valid,
      i_mux_squid_offset_ram_rd_data    => mux_squid_offset_ram_rd_data,
      -- Register configuration
      ---------------------------------------------------------------------
      -- common register
      o_reg_valid                       => reg_valid,
      o_reg_fpasim_gain                 => reg_fpasim_gain,
      o_reg_mux_sq_fb_delay             => reg_mux_sq_fb_delay,
      o_reg_amp_sq_of_delay             => reg_amp_sq_of_delay,
      o_reg_error_delay                 => reg_error_delay,
      o_reg_ra_delay                    => reg_ra_delay,
      o_reg_tes_conf                    => reg_tes_conf,
      o_reg_conf0                       => reg_conf0,
      -- ctrl register
      o_reg_ctrl_valid                  => reg_ctrl_valid,
      o_reg_ctrl                        => reg_ctrl,
      -- debug ctrl register
      o_reg_debug_ctrl_valid            => reg_debug_ctrl_valid,
      o_reg_debug_ctrl                  => reg_debug_ctrl,
      -- make pulse register
      o_reg_make_sof                    => reg_make_sof,
      o_reg_make_eof                    => reg_make_eof,
      o_reg_make_pulse_valid            => reg_make_pulse_valid,
      o_reg_make_pulse                  => reg_make_pulse,
      i_reg_make_pulse_ready            => reg_make_pulse_ready,

      -- fpasim_status
      i_reg_fpasim_status_valid => reg_fpasim_status_valid,
      i_reg_fpasim_status       => reg_fpasim_status,

      -- recording: register
      o_reg_rec_valid => reg_rec_valid,
      o_reg_rec_ctrl  => reg_rec_ctrl,
      o_reg_rec_conf0 => reg_rec_conf0,

      -- recording: data
      ---------------------------------------------------------------------
      o_reg_fifo_rec_adc_rd         => fifo_rec_adc_rd,
      i_reg_fifo_rec_adc_sof        => fifo_rec_adc_sof,
      i_reg_fifo_rec_adc_eof        => fifo_rec_adc_eof,
      i_reg_fifo_rec_adc_data_valid => fifo_rec_adc_data_valid,
      i_reg_fifo_rec_adc_data       => fifo_rec_adc_data,
      i_reg_fifo_rec_adc_empty      => fifo_rec_adc_empty,

      -- to the usb
      ---------------------------------------------------------------------
      -- errors
      i_reg_wire_errors3 => reg_wire_errors3,
      i_reg_wire_errors2 => reg_wire_errors2,
      i_reg_wire_errors1 => reg_wire_errors1,
      i_reg_wire_errors0 => reg_wire_errors0,
      -- status
      i_reg_wire_status3 => reg_wire_status3,
      i_reg_wire_status2 => reg_wire_status2,
      i_reg_wire_status1 => reg_wire_status1,
      i_reg_wire_status0 => reg_wire_status0
      );

  -- ctrl register: extract fields
  -- rst <= reg_ctrl(c_CTRL_RST_IDX_H); -- this reset is managed by the reset_top module
  en <= reg_ctrl(pkg_CTRL_EN_IDX_H);

  -- make_pulse register: extract fields
  cmd_valid            <= reg_make_pulse_valid;
  cmd_pixel_id         <= reg_make_pulse(pkg_MAKE_PULSE_PIXEL_ID_IDX_H downto pkg_MAKE_PULSE_PIXEL_ID_IDX_L);
  cmd_time_shift       <= reg_make_pulse(pkg_MAKE_PULSE_TIME_SHIFT_IDX_H downto pkg_MAKE_PULSE_TIME_SHIFT_IDX_L);
  cmd_pulse_height     <= reg_make_pulse(pkg_MAKE_PULSE_PULSE_HEIGHT_IDX_H downto pkg_MAKE_PULSE_PULSE_HEIGHT_IDX_L);
  reg_make_pulse_ready <= cmd_ready;

  -- reg_fpasim_gain register: extract fields
  fpasim_gain <= reg_fpasim_gain(pkg_FPASIM_GAIN_IDX_H downto pkg_FPASIM_GAIN_IDX_L);

  -- reg_mux_sq_fb_delay register: extract fields
  adc0_delay <= reg_mux_sq_fb_delay(pkg_MUX_SQ_FB_DELAY_IDX_H downto pkg_MUX_SQ_FB_DELAY_IDX_L);
  -- reg_amp_sq_of_delay register: extract fields
  adc1_delay <= reg_amp_sq_of_delay(pkg_AMP_SQ_OF_DELAY_IDX_H downto pkg_AMP_SQ_OF_DELAY_IDX_L);

  -- error_delay register: extract fields
  dac_delay <= reg_error_delay(pkg_ERROR_DELAY_IDX_H downto pkg_ERROR_DELAY_IDX_L);

  -- ra_delay register: extract fields
  sync_delay <= reg_ra_delay(pkg_RA_DELAY_IDX_H downto pkg_RA_DELAY_IDX_L);

  -- tes_conf register: extract fields
  nb_pixel_by_frame  <= reg_tes_conf(pkg_TES_CONF_NB_PIXEL_BY_FRAME_IDX_H downto pkg_TES_CONF_NB_PIXEL_BY_FRAME_IDX_L);
  nb_sample_by_pixel <= reg_tes_conf(pkg_TES_CONF_NB_SAMPLE_BY_PIXEL_IDX_H downto pkg_TES_CONF_NB_SAMPLE_BY_PIXEL_IDX_L);
  nb_sample_by_frame <= reg_tes_conf(pkg_TES_CONF_NB_SAMPLE_BY_FRAME_IDX_H downto pkg_TES_CONF_NB_SAMPLE_BY_FRAME_IDX_L);

  -- conf0 register
  inter_squid_gain <= reg_conf0(pkg_CONF0_INTER_SQUID_GAIN_IDX_H downto pkg_CONF0_INTER_SQUID_GAIN_IDX_L);

  -- debug_ctrl register
  dac_en_pattern       <= reg_debug_ctrl(pkg_DEBUG_CTRL_DAC_EN_PATTERN_IDX_H);
  debug_pulse          <= reg_debug_ctrl(pkg_DEBUG_CTRL_DEBUG_PULSE_IDX_H);
  rst_status           <= reg_debug_ctrl(pkg_DEBUG_CTRL_RST_STATUS_IDX_H);

  -- fpasim_status register
  reg_fpasim_status_valid        <= tes_pixel_neg_out_valid1;
  reg_fpasim_status(31 downto 9) <= (others => '0');
  reg_fpasim_status(8)           <= tes_pixel_neg_out_error1;
  reg_fpasim_status(7 downto 0)  <= std_logic_vector(resize(unsigned(tes_pixel_neg_out_pixel_id1), 8));

  -- recording:
  rec_adc_cmd_valid             <= reg_rec_valid and reg_rec_ctrl(pkg_REC_CTRL_ADC_EN_IDX_H);
  rec_adc_cmd_nb_words_by_block <= reg_rec_conf0(pkg_REC_CONF0_ADC_NB_WORD32b_IDX_H downto pkg_REC_CONF0_ADC_NB_WORD32b_IDX_L);

  -- spi:
  o_usb_clk            <= usb_clk;
  o_spi_rst            <= reg_spi_ctrl(pkg_SPI_CTRL_RST_IDX_H);
  o_spi_en             <= reg_spi_ctrl(pkg_SPI_CTRL_EN_IDX_H);
  o_spi_cmd_valid      <= reg_spi_valid;
  o_spi_dac_tx_present <= reg_spi_conf1(pkg_SPI_CONF1_DAC_TX_ENABLE_IDX_H);
  o_spi_mode           <= reg_spi_conf0(pkg_SPI_CONF0_MODE_IDX_H);
  o_spi_id             <= reg_spi_conf0(pkg_SPI_CONF0_ID_IDX_H downto pkg_SPI_CONF0_ID_IDX_L);
  o_spi_cmd_wr_data    <= reg_spi_wr_data;

  o_usb_rst_status  <= usb_rst_status;
  o_usb_debug_pulse <= usb_debug_pulse;

  -- to the reset_top
  o_usb_rst <= usb_rst;

  -- to the io_top
  o_rst_status  <= rst_status;
  o_debug_pulse <= debug_pulse;

  -- concatenate errors
  sync_errors0(15 downto 5) <= i_sync_errors(15 downto 5);
  sync_errors0(4)           <= sync_errors0_tmp(0);
  sync_errors0(3 downto 0)  <= i_sync_errors(3 downto 0);
  sync_status0              <= i_sync_status;



  -- errors
  reg_wire_errors3(31 downto 16) <= (others => '0');
  reg_wire_errors3(15 downto 0)  <= rec_adc_errors0;  -- recording

  reg_wire_errors2(31 downto 16) <= sync_errors0;  -- sync top
  reg_wire_errors2(15 downto 0)  <= i_dac_errors;  -- dac

  reg_wire_errors1(31 downto 16) <= amp_squid_errors0;  -- amp squid
  reg_wire_errors1(15 downto 0)  <= mux_squid_errors0;  -- mux squid

  reg_wire_errors0(31 downto 16) <= tes_errors0;   -- tes
  reg_wire_errors0(15 downto 0)  <= i_adc_errors;  -- adc

  -- status
  reg_wire_status3(31 downto 24) <= (others => '0');
  reg_wire_status3(23 downto 16) <= (others => '0');
  reg_wire_status3(15 downto 8)  <= (others => '0');
  reg_wire_status3(7 downto 0)   <= rec_adc_status0;  -- recording

  reg_wire_status2(31 downto 24) <= (others => '0');
  reg_wire_status2(23 downto 16) <= sync_status0;  -- sync top
  reg_wire_status2(15 downto 8)  <= (others => '0');
  reg_wire_status2(7 downto 0)   <= i_dac_status;  -- dac

  reg_wire_status1(31 downto 24) <= (others => '0');
  reg_wire_status1(23 downto 16) <= amp_squid_status0;  -- amp squid
  reg_wire_status1(15 downto 8)  <= (others => '0');
  reg_wire_status1(7 downto 0)   <= mux_squid_status0;  -- mux squid

  reg_wire_status0(31 downto 24) <= (others => '0');
  reg_wire_status0(23 downto 16) <= tes_status0;   -- tes
  reg_wire_status0(15 downto 8)  <= (others => '0');
  reg_wire_status0(7 downto 0)   <= i_adc_status;  -- adc

  gen_not_adc_debug : if g_FPASIM_DEBUG = false generate
  begin
    adc_valid_tmp0                       <= i_adc_valid;
    adc_mux_squid_feedback_tmp0          <= i_adc_mux_squid_feedback;
    adc_amp_squid_offset_correction_tmp0 <= i_adc_amp_squid_offset_correction;
  end generate gen_not_adc_debug;

  gen_adc_debug : if g_FPASIM_DEBUG = true generate
  begin
    select_path : process (i_clk) is
    begin
      if rising_edge(i_clk) then
        adc_valid_tmp0 <= i_adc_valid;
        if debug_adc_sel = '1' then
          adc_mux_squid_feedback_tmp0          <= debug_adc_mux_squid_feedback;
          adc_amp_squid_offset_correction_tmp0 <= debug_adc_amp_squid_offset_correction;

        else
          adc_mux_squid_feedback_tmp0          <= i_adc_mux_squid_feedback;
          adc_amp_squid_offset_correction_tmp0 <= i_adc_amp_squid_offset_correction;
        end if;
      end if;
    end process select_path;
  end generate gen_adc_debug;


  ---------------------------------------------------------------------
  -- adc
  ---------------------------------------------------------------------
  inst_adc_top : entity work.adc_top
    generic map(
      g_ADC1_WIDTH       => adc_amp_squid_offset_correction_tmp0'length,
      g_ADC0_WIDTH       => adc_mux_squid_feedback_tmp0'length,
      g_ADC1_DELAY_WIDTH => adc1_delay'length,
      g_ADC0_DELAY_WIDTH => adc0_delay'length
      )
    port map(
      i_clk        => i_clk,
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_adc_valid  => adc_valid_tmp0,
      i_adc1       => adc_amp_squid_offset_correction_tmp0,
      i_adc0       => adc_mux_squid_feedback_tmp0,
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      -- from regdecode
      -----------------------------------------------------------------
      i_en         => en,
      i_adc1_delay => adc1_delay,
      i_adc0_delay => adc0_delay,
      -- output
      -----------------------------------------------------------------
      o_adc_valid  => adc_valid0,
      o_adc1       => adc_amp_squid_offset_correction0,
      o_adc0       => adc_mux_squid_feedback0
      );

  ---------------------------------------------------------------------
  -- tes
  ---------------------------------------------------------------------
  -- extract LSB address bits
  tes_pulse_shape_ram_wr_rd_addr_tmp <= tes_pulse_shape_ram_wr_rd_addr(tes_pulse_shape_ram_wr_rd_addr_tmp'range);
  tes_std_state_ram_wr_rd_addr_tmp   <= tes_std_state_ram_wr_rd_addr(tes_std_state_ram_wr_rd_addr_tmp'range);

  inst_tes_top : entity work.tes_top
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
      g_NB_FRAME_BY_PULSE_SHAPE       => pkg_NB_FRAME_BY_PULSE_SHAPE,
      -- addr
      g_PULSE_SHAPE_RAM_ADDR_WIDTH    => tes_pulse_shape_ram_wr_rd_addr_tmp'length,
      -- output
      g_PIXEL_RESULT_OUTPUT_WIDTH     => pixel_result1'length
      )
    port map(
      i_clk                        => i_clk,
      i_rst                        => i_rst,
      i_rst_status                 => rst_status,
      i_debug_pulse                => debug_pulse,
      ---------------------------------------------------------------------
      -- input command: from the regdecode
      ---------------------------------------------------------------------
      i_en                         => en,
      i_nb_sample_by_pixel         => nb_sample_by_pixel,
      i_nb_pixel_by_frame          => nb_pixel_by_frame,
      i_nb_sample_by_frame         => nb_sample_by_frame,
      -- command
      i_cmd_valid                  => cmd_valid,
      i_cmd_pulse_height           => cmd_pulse_height,
      i_cmd_pixel_id               => cmd_pixel_id,
      i_cmd_time_shift             => cmd_time_shift,
      o_cmd_ready                  => cmd_ready,
      -- RAM: pulse shape
      -- wr
      i_pulse_shape_wr_en          => tes_pulse_shape_ram_wr_en,
      i_pulse_shape_wr_rd_addr     => tes_pulse_shape_ram_wr_rd_addr_tmp,
      i_pulse_shape_wr_data        => tes_pulse_shape_ram_wr_data,
      -- rd
      i_pulse_shape_rd_en          => tes_pulse_shape_ram_rd_en,
      o_pulse_shape_rd_valid       => tes_pulse_shape_ram_rd_valid,
      o_pulse_shape_rd_data        => tes_pulse_shape_ram_rd_data,
      -- RAM:
      -- wr
      i_steady_state_wr_en         => tes_std_state_ram_wr_en,
      i_steady_state_wr_rd_addr    => tes_std_state_ram_wr_rd_addr_tmp,
      i_steady_state_wr_data       => tes_std_state_ram_wr_data,
      -- rd
      i_steady_state_rd_en         => tes_std_state_ram_rd_en,
      o_steady_state_rd_valid      => tes_std_state_ram_rd_valid,
      o_steady_state_rd_data       => tes_std_state_ram_rd_data,
      ---------------------------------------------------------------------
      -- from the adc
      ---------------------------------------------------------------------
      i_data_valid                 => adc_valid0,
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_pulse_sof                  => pulse_sof1,         -- not connected
      o_pulse_eof                  => pulse_eof1,         -- not connected
      o_pixel_sof                  => pixel_sof1,
      o_pixel_eof                  => pixel_eof1,
      o_pixel_valid                => pixel_valid1,
      o_pixel_id                   => pixel_id1,
      o_pixel_result               => pixel_result1,
      o_frame_sof                  => frame_sof1,
      o_frame_eof                  => frame_eof1,
      o_frame_id                   => frame_id1,
      ---------------------------------------------------------------------
      -- output: detect negative output value
      ---------------------------------------------------------------------
      o_tes_pixel_neg_out_valid    => tes_pixel_neg_out_valid1,
      o_tes_pixel_neg_out_error    => tes_pixel_neg_out_error1,
      o_tes_pixel_neg_out_pixel_id => tes_pixel_neg_out_pixel_id1,
      ---------------------------------------------------------------------
      -- errors/status
      ---------------------------------------------------------------------
      o_errors                     => tes_errors0,
      o_status                     => tes_status0
      );

  -- sync with inst_tes_top out
  -----------------------------------------------------------------
  data_pipe_tmp0(c_IDX1_H downto c_IDX1_L) <= adc_mux_squid_feedback0;
  data_pipe_tmp0(c_IDX0_H downto c_IDX0_L) <= adc_amp_squid_offset_correction0;
  inst_pipeliner_sync_with_tes_top_out : entity work.pipeliner
    generic map(
      g_NB_PIPES   => pkg_TES_TOP_LATENCY,
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

  inst_mux_squid_top : entity work.mux_squid_top
    generic map(
      -- command
      g_INTER_SQUID_GAIN_WIDTH      => inter_squid_gain'length,
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
      i_inter_squid_gain            => inter_squid_gain,
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
  inst_pipeliner_sync_with_mux_squid_top_out : entity work.pipeliner
    generic map(
      g_NB_PIPES   => pkg_MUX_SQUID_TOP_LATENCY,  -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => amp_squid_offset_correction1'length  -- width of the input/output data.  Possibles values: [1, integer max value[
      )
    port map(
      i_clk  => i_clk,                  -- clock signal
      i_data => amp_squid_offset_correction1,     -- input data
      o_data => amp_squid_offset_correction2  -- output data with/without delay
      );

  ---------------------------------------------------------------------
  -- amp squid
  ---------------------------------------------------------------------
  -- extract LSB address bits
  amp_squid_tf_ram_wr_rd_addr_tmp <= amp_squid_tf_ram_wr_rd_addr(amp_squid_tf_ram_wr_rd_addr_tmp'range);

  inst_amp_squid_top : entity work.amp_squid_top
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
      i_clk         => i_clk,           -- clock
      i_rst_status  => rst_status,      -- reset error flags
      i_debug_pulse => debug_pulse,  -- '1': delayed error, '0': latched error

      ---------------------------------------------------------------------
      -- input command: from the regdecode
      ---------------------------------------------------------------------
      -- RAM: amp_squid_tf
      -- wr
      i_amp_squid_tf_wr_en      => amp_squid_tf_ram_wr_en,     -- write enable
      i_amp_squid_tf_wr_rd_addr => amp_squid_tf_ram_wr_rd_addr_tmp,  -- write address
      i_amp_squid_tf_wr_data    => amp_squid_tf_ram_wr_data,   -- write data
      -- rd
      i_amp_squid_tf_rd_en      => amp_squid_tf_ram_rd_en,     -- read enable
      o_amp_squid_tf_rd_valid   => amp_squid_tf_ram_rd_valid,  -- read valid
      o_amp_squid_tf_rd_data    => amp_squid_tf_ram_rd_data,   -- read data

      -- gain
      i_fpasim_gain                 => fpasim_gain,  -- gain value
      ---------------------------------------------------------------------
      -- input1
      ---------------------------------------------------------------------
      i_pixel_sof                   => pixel_sof2,   -- first sample of a pixel
      i_pixel_eof                   => pixel_eof2,   -- last sample of a pixel
      i_pixel_valid                 => pixel_valid2,  -- valid sample of a pixel
      i_pixel_id                    => pixel_id2,    -- id of a pixel
      i_pixel_result                => pixel_result2,
      i_frame_sof                   => frame_sof2,   -- first sample of a frame
      i_frame_eof                   => frame_eof2,   -- last sample of a frame
      i_frame_id                    => frame_id2,    -- id of a frame
      ---------------------------------------------------------------------
      -- input2
      ---------------------------------------------------------------------
      i_amp_squid_offset_correction => amp_squid_offset_correction2,
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_pixel_sof                   => pixel_sof3,   -- not connected
      o_pixel_eof                   => pixel_eof3,   -- not connected
      o_pixel_valid                 => pixel_valid3,
      o_pixel_id                    => pixel_id3,    -- not connected
      o_pixel_result                => pixel_result3,
      o_frame_sof                   => frame_sof3,
      o_frame_eof                   => frame_eof3,   -- not connected
      o_frame_id                    => frame_id3,    -- not connected
      ---------------------------------------------------------------------
      -- errors/status
      ---------------------------------------------------------------------
      o_errors                      => amp_squid_errors0,  -- output errors
      o_status                      => amp_squid_status0   -- output status
      );

  ---------------------------------------------------------------------
  -- dac_top
  ---------------------------------------------------------------------
  not_gen_debug_pattern : if g_FPASIM_DEBUG = false generate
    dac_pattern0 <= pkg_DAC_PATTERN0;
    dac_pattern1 <= pkg_DAC_PATTERN1;
    dac_pattern2 <= pkg_DAC_PATTERN2;
    dac_pattern3 <= pkg_DAC_PATTERN3;
    dac_pattern4 <= pkg_DAC_PATTERN4;
    dac_pattern5 <= pkg_DAC_PATTERN5;
    dac_pattern6 <= pkg_DAC_PATTERN6;
    dac_pattern7 <= pkg_DAC_PATTERN7;
  end generate not_gen_debug_pattern;

  gen_debug_pattern : if g_FPASIM_DEBUG = true generate
    p_select_debug_pattern : process (i_clk) is
    begin
      if rising_edge(i_clk) then
        if debug_dac_pattern_sel = '1' then
          dac_pattern0 <= debug_dac_pattern0;
          dac_pattern1 <= debug_dac_pattern1;
          dac_pattern2 <= debug_dac_pattern2;
          dac_pattern3 <= debug_dac_pattern3;
          dac_pattern4 <= debug_dac_pattern4;
          dac_pattern5 <= debug_dac_pattern5;
          dac_pattern6 <= debug_dac_pattern6;
          dac_pattern7 <= debug_dac_pattern7;
        else
          dac_pattern0 <= pkg_DAC_PATTERN0;
          dac_pattern1 <= pkg_DAC_PATTERN1;
          dac_pattern2 <= pkg_DAC_PATTERN2;
          dac_pattern3 <= pkg_DAC_PATTERN3;
          dac_pattern4 <= pkg_DAC_PATTERN4;
          dac_pattern5 <= pkg_DAC_PATTERN5;
          dac_pattern6 <= pkg_DAC_PATTERN6;
          dac_pattern7 <= pkg_DAC_PATTERN7;
        end if;
      end if;
    end process p_select_debug_pattern;

  end generate gen_debug_pattern;

  inst_dac_top : entity work.dac_top
    generic map(
      g_DAC_DELAY_WIDTH => dac_delay'length
      )
    port map(
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_clk            => i_clk,
      i_rst            => i_rst,
      -- from regdecode
      -----------------------------------------------------------------
      i_dac_en_pattern => dac_en_pattern,
      i_dac_pattern0   => dac_pattern0,
      i_dac_pattern1   => dac_pattern1,
      i_dac_pattern2   => dac_pattern2,
      i_dac_pattern3   => dac_pattern3,
      i_dac_pattern4   => dac_pattern4,
      i_dac_pattern5   => dac_pattern5,
      i_dac_pattern6   => dac_pattern6,
      i_dac_pattern7   => dac_pattern7,
      -- delay
      i_dac_delay      => dac_delay,
      -- input data
      ---------------------------------------------------------------------
      i_dac_valid      => pixel_valid3,
      i_dac            => pixel_result3,
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_dac_valid      => dac_valid4,
      o_dac_frame      => dac_frame4,
      o_dac1           => dac1_4,
      o_dac0           => dac0_4
      );

  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------


  gen_not_dac_debug : if g_FPASIM_DEBUG = false generate
  begin
    o_dac_valid <= dac_valid4;
    o_dac_frame <= dac_frame4;
    o_dac1      <= dac1_4;
    o_dac0      <= dac0_4;
  end generate gen_not_dac_debug;

  gen_dac_debug : if g_FPASIM_DEBUG = true generate
  begin
    select_path : process (i_clk) is
    begin
      if rising_edge(i_clk) then
        o_dac_valid <= dac_valid4;
        o_dac_frame <= dac_frame4;

        if debug_dac_sel = '1' then
          o_dac1 <= debug_dac1;
          o_dac0 <= debug_dac0;
        else
          o_dac1 <= dac1_4;
          o_dac0 <= dac0_4;
        end if;
      end if;
    end process select_path;
  end generate gen_dac_debug;
  ---------------------------------------------------------------------
  -- sync_top
  ---------------------------------------------------------------------
  inst_sync_top : entity work.sync_top
    generic map(
      g_PULSE_DURATION   => pkg_SYNC_PULSE_DURATION,  -- duration of the output pulse. Possible values [1;integer max value[
      g_SYNC_DELAY_WIDTH => sync_delay'length
      )
    port map(
      ---------------------------------------------------------------------
      -- input @i_clk
      ---------------------------------------------------------------------
      i_clk         => i_clk,
      i_rst         => i_rst,
      -- from regdecode
      -----------------------------------------------------------------
      i_rst_status  => rst_status,
      i_debug_pulse => debug_pulse,
      i_sync_delay  => sync_delay,
      -- input data
      ---------------------------------------------------------------------
      i_sync_valid  => pixel_valid3,
      -- requirement: FPASIM-FW-REQ-0080
      i_sync        => frame_sof3,
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_sync_valid  => sync_valid5,
      o_sync        => sync5,
      ---------------------------------------------------------------------
      -- errors/status
      ---------------------------------------------------------------------
      o_errors      => sync_errors0_tmp
      );

  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_sync_valid <= sync_valid5;
  o_sync       <= sync5;

  ---------------------------------------------------------------------
  -- Recording
  ---------------------------------------------------------------------
  inst_recording_top : entity work.recording_top
    generic map(
      g_ADC_FIFO_OUT_DEPTH => pkg_REC_ADC_FIFO_OUT_DEPTH  -- depth of the FIFO (number of words). Must be a power of 2
      )
    port map(
      i_rst                       => i_rst,
      i_clk                       => i_clk,
      i_rst_status                => rst_status,
      i_debug_pulse               => debug_pulse,
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      -- from regdecode
      i_adc_cmd_start             => rec_adc_cmd_valid,
      i_adc_cmd_nb_words_by_block => rec_adc_cmd_nb_words_by_block,
      -- from adcs
      i_adc_data_valid            => adc_valid0,
      i_adc_data1                 => adc_mux_squid_feedback0,
      i_adc_data0                 => adc_amp_squid_offset_correction0,
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      i_fifo_adc_rd               => fifo_rec_adc_rd,
      o_fifo_adc_data_valid       => fifo_rec_adc_data_valid,
      o_fifo_adc_sof              => fifo_rec_adc_sof,
      o_fifo_adc_eof              => fifo_rec_adc_eof,
      o_fifo_adc_data             => fifo_rec_adc_data,
      o_fifo_adc_empty            => fifo_rec_adc_empty,
      -----------------------------------------------------------------
      -- errors/status
      -----------------------------------------------------------------
      o_adc_errors                => rec_adc_errors0,
      o_adc_status                => rec_adc_status0
      );


  ---------------------------------------------------------------------
  -- debug
  ---------------------------------------------------------------------
  gen_debug : if g_FPASIM_DEBUG = true generate

    signal debug_frame_id_pulse_sof_r1 : std_logic_vector(frame_id1'range);
    signal debug_frame_id_pulse_eof_r1 : std_logic_vector(frame_id1'range);

    signal debug_pulse_cnt_r1     : unsigned(23 downto 0)         := (others => '0');
    signal debug_pulse_cnt_r1_tmp : std_logic_vector(23 downto 0) := (others => '0');

    signal debug_trig  : std_logic;
    signal debug_en_r1 : std_logic := '0';

    signal debug_sample_pixel_cnt_r1  : unsigned(15 downto 0);
    signal debug_sample_pixel_cnt_tmp : std_logic_vector(15 downto 0);
    signal debug_sample_frame_cnt_r1  : unsigned(15 downto 0);
    signal debug_sample_frame_cnt_tmp : std_logic_vector(15 downto 0);

  begin

    debug_trig <= '1' when unsigned(pixel_id1) = to_unsigned(0, pixel_id1'length) else '0';

    p_statistics : process (i_clk) is
    begin
      if rising_edge(i_clk) then
        if pulse_sof1 = '1' and debug_trig = '1' then
          debug_frame_id_pulse_sof_r1 <= frame_id1;
        end if;

        if pulse_eof1 = '1' and debug_trig = '1' then
          debug_frame_id_pulse_eof_r1 <= frame_id1;
        end if;

        if pulse_sof1 = '1' and debug_trig = '1' and pixel_valid1 = '1' then
          debug_en_r1        <= '1';
          debug_pulse_cnt_r1 <= (others => '0');
        elsif pulse_eof1 = '1' and debug_trig = '1' then
          debug_en_r1 <= '0';
        elsif pixel_valid1 = '1' and debug_en_r1 = '1' then
          debug_pulse_cnt_r1 <= debug_pulse_cnt_r1 + 1;
        end if;

        if pixel_sof1 = '1' then
          debug_sample_pixel_cnt_r1 <= (others => '0');
        elsif pixel_valid1 = '1' then
          debug_sample_pixel_cnt_r1 <= debug_sample_pixel_cnt_r1 + 1;
        end if;

        if frame_sof1 = '1' then
          debug_sample_frame_cnt_r1 <= (others => '0');
        elsif pixel_valid1 = '1' then
          debug_sample_frame_cnt_r1 <= debug_sample_frame_cnt_r1 + 1;
        end if;

      end if;
    end process p_statistics;

    debug_pulse_cnt_r1_tmp     <= std_logic_vector(debug_pulse_cnt_r1);
    debug_sample_pixel_cnt_tmp <= std_logic_vector(debug_sample_pixel_cnt_r1);
    debug_sample_frame_cnt_tmp <= std_logic_vector(debug_sample_frame_cnt_r1);

    inst_fpasim_top_ila_0 : entity work.fpasim_top_ila_0
      port map(
        clk => i_clk,

        -- probe0
        probe0(36)          => dac_en_pattern,
        probe0(35)          => tes_pixel_neg_out_valid1,
        probe0(34)          => fifo_rec_adc_rd,
        probe0(33)          => fifo_rec_adc_sof,
        probe0(32)          => fifo_rec_adc_eof,
        probe0(31)          => fifo_rec_adc_data_valid,
        probe0(30)          => fifo_rec_adc_empty,
        probe0(29)          => rec_adc_cmd_valid,
        probe0(28)          => cmd_ready,
        probe0(27)          => cmd_valid,
        probe0(26)          => adc_valid0,
        probe0(25)          => i_rst,
        probe0(24)          => sync5,
        probe0(23)          => sync_valid5,
        probe0(22)          => dac_valid4,
        probe0(21)          => pixel_sof3,
        probe0(20)          => pixel_eof3,
        probe0(19)          => pixel_valid3,
        probe0(18)          => frame_sof3,
        probe0(17)          => frame_eof3,
        probe0(16 downto 6) => frame_id3,
        probe0(5 downto 0)  => pixel_id3,

        -- probe1
        probe1(56)           => dac_frame4,
        probe1(55 downto 48) => inter_squid_gain,
        probe1(47 downto 32) => dac1_4,
        probe1(31 downto 16) => dac0_4,
        probe1(15 downto 0)  => pixel_result3,

        -- probe2
        probe2(27 downto 14) => adc_amp_squid_offset_correction0,
        probe2(13 downto 0)  => adc_mux_squid_feedback0,

        -- probe3
        probe3(24)          => debug_en_r1,
        probe3(23)          => pulse_sof1,
        probe3(22)          => pulse_eof1,
        probe3(21)          => pixel_sof1,
        probe3(20)          => pixel_eof1,
        probe3(19)          => pixel_valid1,
        probe3(18)          => frame_sof1,
        probe3(17)          => frame_eof1,
        probe3(16 downto 6) => frame_id1,
        probe3(5 downto 0)  => pixel_id1,

        -- probe4
        probe4(45 downto 22) => debug_pulse_cnt_r1_tmp,
        probe4(21 downto 11) => debug_frame_id_pulse_sof_r1,
        probe4(10 downto 0)  => debug_frame_id_pulse_eof_r1,
        -- probe5
        probe5(31 downto 16) => debug_sample_pixel_cnt_tmp,
        probe5(15 downto 0)  => debug_sample_frame_cnt_tmp,

        -- probe6
        probe6(32)           => tes_pixel_neg_out_error1,
        probe6(31 downto 26) => tes_pixel_neg_out_pixel_id1,
        probe6(25 downto 10) => cmd_pulse_height,
        probe6(9 downto 4)   => cmd_pixel_id,
        probe6(3 downto 0)   => cmd_time_shift,

        -- probe7
        probe7(47 downto 32) => rec_adc_cmd_nb_words_by_block,
        probe7(31 downto 0)  => fifo_rec_adc_data

        );

    inst_fpasim_top_vio_0 : entity work.fpasim_top_vio_0
      port map (
        clk           => i_clk,
        probe_out0(0) => debug_adc_sel,
        probe_out1    => debug_adc_mux_squid_feedback,
        probe_out2    => debug_adc_amp_squid_offset_correction,
        probe_out3(0) => debug_dac_sel,
        probe_out4    => debug_dac0,
        probe_out5    => debug_dac1,
        probe_out6(0) => debug_dac_pattern_sel,
        probe_out7    => debug_dac_pattern0,
        probe_out8    => debug_dac_pattern1,
        probe_out9    => debug_dac_pattern2,
        probe_out10   => debug_dac_pattern3,
        probe_out11   => debug_dac_pattern4,
        probe_out12   => debug_dac_pattern5,
        probe_out13   => debug_dac_pattern6,
        probe_out14   => debug_dac_pattern7
        );

  end generate gen_debug;



end architecture RTL;
