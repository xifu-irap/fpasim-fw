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
--    @file                   pkg_regdecode.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--  This package defines all constants associtated to the regdecode function and its sub-functions.
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


use work.pkg_utils;
use work.pkg_fpasim.all;

package pkg_regdecode is

  ---------------------------------------------------------------------
  --
  ---------------------------------------------------------------------
  -- user-defined: Firmware version
  -- requirement: FPASIM-FW-REQ-0290
  constant pkg_FIRMWARE_VERSION_VALUE : integer := 9;

  -- user-defined: FIRMWARE ID (name)
  -- requirement: FPASIM-FW-REQ-0280
  constant pkg_FIRMWARE_ID_CHAR3 : character := 'F';  -- ascii character
  constant pkg_FIRMWARE_ID_CHAR2 : character := 'P';  -- ascii character
  constant pkg_FIRMWARE_ID_CHAR1 : character := 'A';  -- ascii character
  constant pkg_FIRMWARE_ID_CHAR0 : character := 's';  -- ascii character

  -- auto-computed: fpga id
  constant pkg_FIRMWARE_ID      : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(character'pos(pkg_FIRMWARE_ID_CHAR3), 8)) &
                                                                   std_logic_vector(to_unsigned(character'pos(pkg_FIRMWARE_ID_CHAR2), 8)) &
                                                                   std_logic_vector(to_unsigned(character'pos(pkg_FIRMWARE_ID_CHAR1), 8)) &
                                                                   std_logic_vector(to_unsigned(character'pos(pkg_FIRMWARE_ID_CHAR0), 8));
  -- auto-computed: fpga version
  constant pkg_FIRMWARE_VERSION : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(pkg_FIRMWARE_VERSION_VALUE, 32));

  -------------------------------------------------------------------
  -- pipe
  -- the following constants define the address range associated to each RAM
  -- in order to decode the data flow from the Opal Kelly pipe in
  -------------------------------------------------------------------
  -- user-defined: address width of the register
  constant pkg_REG_ADDR_WIDTH : positive := 16;

  -- requirement: FPASIM-FW-REQ-0100
  -- user-defined : minimal address value associated to the tes_pulse_shape ram
  constant pkg_TES_PULSE_SHAPE_ADDR_RANGE_MIN : std_logic_vector(pkg_REG_ADDR_WIDTH - 1 downto 0) := x"0000";
  -- requirement: FPASIM-FW-REQ-0100
  -- user-defined : maximal address value associated to the tes_pulse_shape ram
  constant pkg_TES_PULSE_SHAPE_ADDR_RANGE_MAX : std_logic_vector(pkg_REG_ADDR_WIDTH - 1 downto 0) := x"7FFF";

  -- requirement: FPASIM-FW-REQ-0160
  -- user-defined : minimal address value associated to the amp_squid_tf ram
  constant pkg_AMP_SQUID_TF_ADDR_RANGE_MIN : std_logic_vector(pkg_REG_ADDR_WIDTH - 1 downto 0) := x"8000";
  -- requirement: FPASIM-FW-REQ-0160
  -- user-defined : maximal address value associated to the amp_squid_tf ram
  constant pkg_AMP_SQUID_TF_ADDR_RANGE_MAX : std_logic_vector(pkg_REG_ADDR_WIDTH - 1 downto 0) := x"BFFF";

  -- requirement: FPASIM-FW-REQ-0130
  -- user-defined : minimal address value associated to the mux_squid_tf ram
  constant pkg_MUX_SQUID_TF_ADDR_RANGE_MIN : std_logic_vector(pkg_REG_ADDR_WIDTH - 1 downto 0) := x"C000";
  -- requirement: FPASIM-FW-REQ-0130
  -- user-defined : maximal address value associated to the mux_squid_tf ram
  constant pkg_MUX_SQUID_TF_ADDR_RANGE_MAX : std_logic_vector(pkg_REG_ADDR_WIDTH - 1 downto 0) := x"DFFF";

  -- requirement: FPASIM-FW-REQ-0090
  -- user-defined : minimal address value associated to the tes_std_state ram
  constant pkg_TES_STD_STATE_ADDR_RANGE_MIN : std_logic_vector(pkg_REG_ADDR_WIDTH - 1 downto 0) := x"E000";
  -- requirement: FPASIM-FW-REQ-0090
  -- user-defined : maximal address value associated to the tes_std_state ram
  constant pkg_TES_STD_STATE_ADDR_RANGE_MAX : std_logic_vector(pkg_REG_ADDR_WIDTH - 1 downto 0) := x"E03F";

  -- requirement: FPASIM-FW-REQ-0140
  -- user-defined : minimal address value associated to the mux_squid_offset ram
  constant pkg_MUX_SQUID_OFFSET_ADDR_RANGE_MIN : std_logic_vector(pkg_REG_ADDR_WIDTH - 1 downto 0) := x"E040";
  -- requirement: FPASIM-FW-REQ-0140
  -- user-defined : maximal address value associated to the mux_squid_offset ram
  constant pkg_MUX_SQUID_OFFSET_ADDR_RANGE_MAX : std_logic_vector(pkg_REG_ADDR_WIDTH - 1 downto 0) := x"E07F";

  ---------------------------------------------------------------------
  -- register field definition
  -- The following constants define the bit range of each register field.
  -- Note:
  --   .the bit range should match the bit range of the api_registre_fpasim.xlsx file
  --   . when the field is composed by 1 bit, only 1 XXX_IDX_H constant is defined
  --   . When the field is composed by 2 bits or more, 2 constants are defined:
  --      . XXX_IDX_H
  --      . XXX_IDX_L
  ---------------------------------------------------------------------

  -- trig in
  ---------------------------------------------------------------------
  -- user-defined: spi_valid (bit index)
  constant pkg_TRIGIN_SPI_VALID_IDX_H        : integer := 24;
  -- user-defined: rec_valid (bit index)
  constant pkg_TRIGIN_REC_VALID_IDX_H        : integer := 20;
  -- user-defined: debug_valid (bit index)
  constant pkg_TRIGIN_DEBUG_VALID_IDX_H      : integer := 16;
  -- user-defined: ctrl_valid (bit index)
  constant pkg_TRIGIN_CTRL_VALID_IDX_H       : integer := 12;
  -- user-defined: read_all (bit index)
  -- requirement: FPASIM-FW-REQ-0260
  constant pkg_TRIGIN_READ_ALL_VALID_IDX_H   : integer := 8;
  -- user-defined: make_pulse valid (bit index)
  constant pkg_TRIGIN_MAKE_PULSE_VALID_IDX_H : integer := 4;
  -- user-defined: reg_valid (bit index)
  constant pkg_TRIGIN_REG_VALID_IDX_H        : integer := 0;

  -- wire in/wire out
  -----------------------------------------------------------------

  -- user-defined: ctrl en (bit index)
  constant pkg_CTRL_EN_IDX_H  : integer := 0;
  -- user-defined: ctrl rst (bit index)
  constant pkg_CTRL_RST_IDX_H : integer := 1;

  -- make pulse
  ---------------------------------------------------------------------
  -- user-defined: pixel all (bit index)
  constant pkg_MAKE_PULSE_PIXEL_ALL_IDX_H : integer := 31;

  -- requirement: FPASIM-FW-REQ-0110
  -- user-defined: pixel id (bit index low)
  constant pkg_MAKE_PULSE_PIXEL_ID_IDX_L : integer := 24;
  -- requirement: FPASIM-FW-REQ-0110
  -- auto-computed: pixel id width
  constant pkg_MAKE_PULSE_PIXEL_ID_WIDTH : integer := pkg_NB_SAMPLE_BY_PIXEL_MAX_WIDTH;
  -- auto-computed : pixel id (bit index high)
  constant pkg_MAKE_PULSE_PIXEL_ID_IDX_H : integer := pkg_MAKE_PULSE_PIXEL_ID_IDX_L + pkg_MAKE_PULSE_PIXEL_ID_WIDTH - 1;


  -- requirement: FPASIM-FW-REQ-0110
  -- user-defined: time shift (bit index low)
  constant pkg_MAKE_PULSE_TIME_SHIFT_IDX_L : integer := 16;
  -- requirement: FPASIM-FW-REQ-0110
  -- auto-computed: time shift width
  constant pkg_MAKE_PULSE_TIME_SHIFT_WIDTH : integer := work.pkg_utils.pkg_width_from_value(pkg_PULSE_SHAPE_OVERSAMPLE);
  -- auto-computed : time shift (bit index high)
  constant pkg_MAKE_PULSE_TIME_SHIFT_IDX_H : integer := pkg_MAKE_PULSE_TIME_SHIFT_IDX_L + pkg_MAKE_PULSE_TIME_SHIFT_WIDTH - 1;


  -- requirement: FPASIM-FW-REQ-0110
  -- user-defined: pulse height (bit index low)
  constant pkg_MAKE_PULSE_PULSE_HEIGHT_IDX_L : integer := 0;
  -- requirement: FPASIM-FW-REQ-0110
  -- auto-computed: pulse height width
  constant pkg_MAKE_PULSE_PULSE_HEIGHT_WIDTH : integer := pkg_TES_MULT_SUB_Q_WIDTH_B - 1;  -- we substract 1 because one bit was added to pass from unsigned -> signed value
  -- auto-computed: pulse height (bit index high)
  constant pkg_MAKE_PULSE_PULSE_HEIGHT_IDX_H : integer := pkg_MAKE_PULSE_PULSE_HEIGHT_IDX_L + pkg_MAKE_PULSE_PULSE_HEIGHT_WIDTH - 1;

  -- user-defined: mux_sq_fb_delay
  ---------------------------------------------------------------------
  -- requirement: FPASIM-FW-REQ-0210
  -- user-defined: mux_sq_fb_delay (bit index high)
  constant pkg_MUX_SQ_FB_DELAY_IDX_H : integer := 5;
  -- requirement: FPASIM-FW-REQ-0210
  -- user-defined: mux_sq_fb_delay (bit index low)
  constant pkg_MUX_SQ_FB_DELAY_IDX_L : integer := 0;
  -- auto-computed: mux_sq_fb_delay width
  constant pkg_MUX_SQ_FB_DELAY_WIDTH : integer := work.pkg_utils.pkg_width_from_indexes(i_idx_high => pkg_MUX_SQ_FB_DELAY_IDX_H, i_idx_low => pkg_MUX_SQ_FB_DELAY_IDX_L);

  -- user-defined: amp_sq_of_delay
  ---------------------------------------------------------------------
  -- requirement: FPASIM-FW-REQ-0220
  -- user-defined: amp_sq_of_delay (bit index high)
  constant pkg_AMP_SQ_OF_DELAY_IDX_H : integer := 5;
  -- requirement: FPASIM-FW-REQ-0220
  -- user-defined: amp_sq_of_delay (bit index low)
  constant pkg_AMP_SQ_OF_DELAY_IDX_L : integer := 0;
  -- auto-computed: amp_sq_of_delay width
  constant pkg_AMP_SQ_OF_DELAY_WIDTH : integer := work.pkg_utils.pkg_width_from_indexes(i_idx_high => pkg_AMP_SQ_OF_DELAY_IDX_H, i_idx_low => pkg_AMP_SQ_OF_DELAY_IDX_L);

  ---------------------------------------------------------------------
  -- user-defined: error_delay
  ---------------------------------------------------------------------
  -- requirement: FPASIM-FW-REQ-0230
  -- user-defined: error_delay (bit index high)
  constant pkg_ERROR_DELAY_IDX_H : integer := 5;
  -- requirement: FPASIM-FW-REQ-0230
  -- user-defined: error_delay (bit index low)
  constant pkg_ERROR_DELAY_IDX_L : integer := 0;
  -- auto-computed: error_delay width
  constant pkg_ERROR_DELAY_WIDTH : integer := work.pkg_utils.pkg_width_from_indexes(i_idx_high => pkg_ERROR_DELAY_IDX_H, i_idx_low => pkg_ERROR_DELAY_IDX_L);

  ---------------------------------------------------------------------
  -- user-defined: ra_delay
  ---------------------------------------------------------------------
  -- requirement: FPASIM-FW-REQ-0240
  -- user-defined: ra_delay (bit index high)
  constant pkg_RA_DELAY_IDX_H : integer := 5;
  -- requirement: FPASIM-FW-REQ-0240
  -- user-defined: ra_delay (bit index low)
  constant pkg_RA_DELAY_IDX_L : integer := 0;
  -- auto-computed: ra_delay width
  constant pkg_RA_DELAY_WIDTH : integer :=
     work.pkg_utils.pkg_width_from_indexes(i_idx_high => pkg_RA_DELAY_IDX_H, i_idx_low => pkg_RA_DELAY_IDX_L);

  -- user-defined: tes_conf
  ---------------------------------------------------------------------
  -- requirement: FPASIM-FW-REQ-0030
  -- user-defined: pixel_nb (bit index high)
  constant pkg_TES_CONF_NB_PIXEL_BY_FRAME_IDX_H : integer := 29;
  -- requirement: FPASIM-FW-REQ-0030
  -- user-defined: pixel_nb (bit index low)
  constant pkg_TES_CONF_NB_PIXEL_BY_FRAME_IDX_L : integer := 24;
  -- auto-computed: pixel_nb width
  constant pkg_TES_CONF_NB_PIXEL_BY_FRAME_WIDTH : integer :=
     work.pkg_utils.pkg_width_from_indexes(i_idx_high => pkg_TES_CONF_NB_PIXEL_BY_FRAME_IDX_H, i_idx_low => pkg_TES_CONF_NB_PIXEL_BY_FRAME_IDX_L);

  -- requirement: FPASIM-FW-REQ-0060
  -- user-defined: pixel_length (bit index high)
  constant pkg_TES_CONF_NB_SAMPLE_BY_PIXEL_IDX_H : integer := 22;
  -- requirement: FPASIM-FW-REQ-0060
  -- user-defined: pixel_length (bit index low)
  constant pkg_TES_CONF_NB_SAMPLE_BY_PIXEL_IDX_L : integer := 16;
  -- auto-computed: pixel_length width
  constant pkg_TES_CONF_NB_SAMPLE_BY_PIXEL_WIDTH : integer :=
      work.pkg_utils.pkg_width_from_indexes(i_idx_high => pkg_TES_CONF_NB_SAMPLE_BY_PIXEL_IDX_H, i_idx_low => pkg_TES_CONF_NB_SAMPLE_BY_PIXEL_IDX_L);

  -- user-defined: frame_length (bit index high)
  constant pkg_TES_CONF_NB_SAMPLE_BY_FRAME_IDX_H : integer := 12;
  -- user-defined: frame_length (bit index low)
  constant pkg_TES_CONF_NB_SAMPLE_BY_FRAME_IDX_L : integer := 0;
  -- auto-computed: frame_length width
  constant pkg_TES_CONF_NB_SAMPLE_BY_FRAME_WIDTH : integer :=
      work.pkg_utils.pkg_width_from_indexes(i_idx_high => pkg_TES_CONF_NB_SAMPLE_BY_FRAME_IDX_H, i_idx_low => pkg_TES_CONF_NB_SAMPLE_BY_FRAME_IDX_L);

  ---------------------------------------------------------------------
  -- user-defined: conf0
  ---------------------------------------------------------------------
  -- requirement: FPASIM-FW-REQ-0135
  -- user-defined: inter_squid_gain (bit index high)
  constant pkg_CONF0_INTER_SQUID_GAIN_IDX_H : integer := 7;
  -- requirement: FPASIM-FW-REQ-0135
  -- user-defined: inter_squid_gain (bit index low)
  constant pkg_CONF0_INTER_SQUID_GAIN_IDX_L : integer := 0;
  -- auto-computed: inter_squid_gain width
  constant pkg_CONF0_INTER_SQUID_GAIN_WIDTH : integer := work.pkg_utils.pkg_width_from_indexes(i_idx_high => pkg_CONF0_INTER_SQUID_GAIN_IDX_H, i_idx_low => pkg_CONF0_INTER_SQUID_GAIN_IDX_L);

  -- user-defined: rec_ctrl
  ---------------------------------------------------------------------
  -- user-defined: rec_adc_en (bit index high)
  constant pkg_REC_CTRL_ADC_EN_IDX_H : integer := 0;

  -- user-defined: rec_conf0
  ---------------------------------------------------------------------
  -- user-defined: rec_adc_nb_word32b (bit index high)
  constant pkg_REC_CONF0_ADC_NB_WORD32b_IDX_H : integer := 15;
  -- user-defined: rec_adc_nb_word32b (bit index low)
  constant pkg_REC_CONF0_ADC_NB_WORD32b_IDX_L : integer := 0;
  -- auto-computed: rec_adc_nb_word32b width
  constant pkg_REC_CONF0_ADC_NB_WORD32b_WIDTH : integer := work.pkg_utils.pkg_width_from_indexes(i_idx_high => pkg_REC_CONF0_ADC_NB_WORD32b_IDX_H, i_idx_low => pkg_REC_CONF0_ADC_NB_WORD32b_IDX_L);

  -- user-defined: spi_ctrl
  ---------------------------------------------------------------------
  -- user-defined: spi_mode (bit index high)
  constant pkg_SPI_CTRL_EN_IDX_H  : integer := 0;
  constant pkg_SPI_CTRL_RST_IDX_H : integer := 1;

  -- user-defined: spi_conf0
  ---------------------------------------------------------------------
  -- user-defined: spi_mode (bit index high)
  constant pkg_SPI_CONF0_MODE_IDX_H : integer := 0;

  -- user-defined: spi_id (bit index high)
  constant pkg_SPI_CONF0_ID_IDX_H : integer := 5;
  -- user-defined: spi_id (bit index low)
  constant pkg_SPI_CONF0_ID_IDX_L : integer := 4;
  -- auto-computed: spi_id width
  constant pkg_SPI_CONF0_ID_WIDTH : integer := work.pkg_utils.pkg_width_from_indexes(i_idx_high => pkg_SPI_CONF0_ID_IDX_H, i_idx_low => pkg_SPI_CONF0_ID_IDX_L);

  -- user-defined: spi_conf1
  ---------------------------------------------------------------------
  -- user-defined: dac_tx_enable (bit index high)
  constant pkg_SPI_CONF1_DAC_TX_ENABLE_IDX_H : integer := 0;


  -- user-defined: debug_ctrl
  ---------------------------------------------------------------------
  -- user-defined: debug_pulse (bit index)
  constant pkg_DEBUG_CTRL_DEBUG_PULSE_IDX_H : integer := 0;
  -- user-defined: rst_status (bit index)
  constant pkg_DEBUG_CTRL_RST_STATUS_IDX_H  : integer := 1;
  -- user-defined: dac_en_pattern (bit index)
  constant pkg_DEBUG_CTRL_DAC_EN_PATTERN_IDX_H  : integer := 4;

  -- user-defined: error_sel
  ---------------------------------------------------------------------
  -- user-defined: error_sel (bit index high)
  constant pkg_ERROR_SEL_IDX_H : integer := 3;
  -- user-defined: error_sel (bit index low)
  constant pkg_ERROR_SEL_IDX_L : integer := 0;
  -- auto-computed: error_sel width
  constant pkg_ERROR_SEL_WIDTH : integer := work.pkg_utils.pkg_width_from_indexes(i_idx_high => pkg_ERROR_SEL_IDX_H, i_idx_low => pkg_ERROR_SEL_IDX_L);


end pkg_regdecode;

