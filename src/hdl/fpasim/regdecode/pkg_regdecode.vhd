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
--!   @file                   pkg_regdecode.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--!
--! This package defines all constants used by the regdecode function. 
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fpasim;
use fpasim.pkg_utils;
use fpasim.pkg_fpasim.all;

PACKAGE pkg_regdecode IS

    ---------------------------------------------------------------------
    -- 
    ---------------------------------------------------------------------
    -- user-defined: FPGA version
    constant pkg_FPGA_VERSION_VALUE : integer := 0;

    -- user-defined: FPGA ID (name)
    constant pkg_FPGA_ID_CHAR3 : character := 'f'; -- ascii character
    constant pkg_FPGA_ID_CHAR2 : character := 'p'; -- ascii character
    constant pkg_FPGA_ID_CHAR1 : character := 'a'; -- ascii character
    constant pkg_FPGA_ID_CHAR0 : character := ' '; -- ascii character

    -- auto-computed: fpga id
    constant pkg_FPGA_ID      : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(character'pos(pkg_FPGA_ID_CHAR3), 8)) & std_logic_vector(to_unsigned(character'pos(pkg_FPGA_ID_CHAR2), 8)) & std_logic_vector(to_unsigned(character'pos(pkg_FPGA_ID_CHAR1), 8)) & std_logic_vector(to_unsigned(character'pos(pkg_FPGA_ID_CHAR0), 8));
    -- auto-computed: fpga version
    constant pkg_FPGA_VERSION : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(pkg_FPGA_VERSION_VALUE, 32));

    -------------------------------------------------------------------
    -- pipe
    -- the following constants define the address range associated to each RAM
    -- in order to decode the data flow from the Opal Kelly pipe in
    -------------------------------------------------------------------
    -- user-defined: address width of the register 
    constant pkg_REG_ADDR_WIDTH : positive := 16;

    -- user-defined : minimal address value associated to the tes_pulse_shape ram
    constant pkg_TES_PULSE_SHAPE_ADDR_RANGE_MIN : std_logic_vector(pkg_REG_ADDR_WIDTH - 1 downto 0) := x"0000";
    -- user-defined : maximal address value associated to the tes_pulse_shape ram
    constant pkg_TES_PULSE_SHAPE_ADDR_RANGE_MAX : std_logic_vector(pkg_REG_ADDR_WIDTH - 1 downto 0) := x"7FFF";

    -- user-defined : minimal address value associated to the amp_squid_tf ram
    constant pkg_AMP_SQUID_TF_ADDR_RANGE_MIN : std_logic_vector(pkg_REG_ADDR_WIDTH - 1 downto 0) := x"8000";
    -- user-defined : maximal address value associated to the amp_squid_tf ram
    constant pkg_AMP_SQUID_TF_ADDR_RANGE_MAX : std_logic_vector(pkg_REG_ADDR_WIDTH - 1 downto 0) := x"BFFF";

    -- user-defined : minimal address value associated to the mux_squid_tf ram
    constant pkg_MUX_SQUID_TF_ADDR_RANGE_MIN : std_logic_vector(pkg_REG_ADDR_WIDTH - 1 downto 0) := x"C000";
    -- user-defined : maximal address value associated to the mux_squid_tf ram
    constant pkg_MUX_SQUID_TF_ADDR_RANGE_MAX : std_logic_vector(pkg_REG_ADDR_WIDTH - 1 downto 0) := x"DFFF";

    -- user-defined : minimal address value associated to the tes_std_state ram
    constant pkg_TES_STD_STATE_ADDR_RANGE_MIN : std_logic_vector(pkg_REG_ADDR_WIDTH - 1 downto 0) := x"E000";
    -- user-defined : maximal address value associated to the tes_std_state ram
    constant pkg_TES_STD_STATE_ADDR_RANGE_MAX : std_logic_vector(pkg_REG_ADDR_WIDTH - 1 downto 0) := x"E03F";

    -- user-defined : minimal address value associated to the mux_squid_offset ram
    constant pkg_MUX_SQUID_OFFSET_ADDR_RANGE_MIN : std_logic_vector(pkg_REG_ADDR_WIDTH - 1 downto 0) := x"E040";
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
    -- user-defined: debug valid (bit index)
    constant pkg_TRIGIN_DEBUG_VALID_IDX_H : integer := 16;

    -- user-defined: ctrl valid (bit index)
    constant pkg_TRIGIN_CTRL_VALID_IDX_H : integer := 12;

    -- user-defined: read all (bit index)
    constant pkg_TRIGIN_READ_ALL_VALID_IDX_H : integer := 8;

    -- user-defined: make pulse valid (bit index)
    constant pkg_TRIGIN_MAKE_PULSE_VALID_IDX_H : integer := 4;

    -- user-defined: reg valid (bit index)
    constant pkg_TRIGIN_REG_VALID_IDX_H : integer := 0;

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

    -- user-defined: pixel id (bit index high)
    constant pkg_MAKE_PULSE_PIXEL_ID_IDX_H : integer := 29;
    -- user-defined: pixel id (bit index low)
    constant pkg_MAKE_PULSE_PIXEL_ID_IDX_L : integer := 24;
    -- auto-computed: pixel id width
    constant pkg_MAKE_PULSE_PIXEL_ID_WIDTH : integer := fpasim.pkg_utils.pkg_width_from_indexes(i_idx_high => pkg_MAKE_PULSE_PIXEL_ID_IDX_H, i_idx_low => pkg_MAKE_PULSE_PIXEL_ID_IDX_L);

    -- user-defined: time shift (bit index high)
    constant pkg_MAKE_PULSE_TIME_SHIFT_IDX_H : integer := 19;
    -- user-defined: time shift (bit index low)
    constant pkg_MAKE_PULSE_TIME_SHIFT_IDX_L : integer := 16;
    -- auto-computed: time shift width
    constant pkg_MAKE_PULSE_TIME_SHIFT_WIDTH : integer := fpasim.pkg_utils.pkg_width_from_indexes(i_idx_high => pkg_MAKE_PULSE_TIME_SHIFT_IDX_H, i_idx_low => pkg_MAKE_PULSE_TIME_SHIFT_IDX_L);

    -- user-defined: pulse height (bit index high)
    constant pkg_MAKE_PULSE_PULSE_HEIGHT_IDX_H : integer := 10;
    -- user-defined: pulse height (bit index low)
    constant pkg_MAKE_PULSE_PULSE_HEIGHT_IDX_L : integer := 0;
    -- auto-computed: pulse height width
    constant pkg_MAKE_PULSE_PULSE_HEIGHT_WIDTH : integer := fpasim.pkg_utils.pkg_width_from_indexes(i_idx_high => pkg_MAKE_PULSE_PULSE_HEIGHT_IDX_H, i_idx_low => pkg_MAKE_PULSE_PULSE_HEIGHT_IDX_L);

    -- user-defined: fpasim_gain
    ---------------------------------------------------------------------
    -- user-defined: fpasim_gain (bit index high)
    constant pkg_FPASIM_GAIN_IDX_H : integer := 2;
    -- user-defined: fpasim_gain (bit index low)
    constant pkg_FPASIM_GAIN_IDX_L : integer := 0;
    -- auto-computed: fpasim_gain width
    constant pkg_FPASIM_GAIN_WIDTH : integer := fpasim.pkg_utils.pkg_width_from_indexes(i_idx_high => pkg_FPASIM_GAIN_IDX_H, i_idx_low => pkg_FPASIM_GAIN_IDX_L);

    -- user-defined: mux_sq_fb_delay
    ---------------------------------------------------------------------
    -- user-defined: mux_sq_fb_delay (bit index high)
    constant pkg_MUX_SQ_FB_DELAY_IDX_H : integer := 5;
    -- user-defined: mux_sq_fb_delay (bit index low)
    constant pkg_MUX_SQ_FB_DELAY_IDX_L : integer := 0;
    -- auto-computed: mux_sq_fb_delay width
    constant pkg_MUX_SQ_FB_DELAY_WIDTH : integer := fpasim.pkg_utils.pkg_width_from_indexes(i_idx_high => pkg_MUX_SQ_FB_DELAY_IDX_H, i_idx_low => pkg_MUX_SQ_FB_DELAY_IDX_L);

    -- user-defined: amp_sq_of_delay
    ---------------------------------------------------------------------
    -- user-defined: amp_sq_of_delay (bit index high)
    constant pkg_AMP_SQ_OF_DELAY_IDX_H : integer := 5;
    -- user-defined: amp_sq_of_delay (bit index low)
    constant pkg_AMP_SQ_OF_DELAY_IDX_L : integer := 0;
    -- auto-computed: amp_sq_of_delay width
    constant pkg_AMP_SQ_OF_DELAY_WIDTH : integer := fpasim.pkg_utils.pkg_width_from_indexes(i_idx_high => pkg_AMP_SQ_OF_DELAY_IDX_H, i_idx_low => pkg_AMP_SQ_OF_DELAY_IDX_L);

    ---------------------------------------------------------------------
    -- user-defined: error_delay
    ---------------------------------------------------------------------
    -- user-defined: error_delay (bit index high)
    constant pkg_ERROR_DELAY_IDX_H : integer := 5;
    -- user-defined: error_delay (bit index low)
    constant pkg_ERROR_DELAY_IDX_L : integer := 0;
    -- auto-computed: error_delay width
    constant pkg_ERROR_DELAY_WIDTH : integer := fpasim.pkg_utils.pkg_width_from_indexes(i_idx_high => pkg_ERROR_DELAY_IDX_H, i_idx_low => pkg_ERROR_DELAY_IDX_L);

    ---------------------------------------------------------------------
    -- user-defined: ra_delay
    ---------------------------------------------------------------------
    -- user-defined: ra_delay (bit index high)
    constant pkg_RA_DELAY_IDX_H : integer := 5;
    -- user-defined: ra_delay (bit index low)
    constant pkg_RA_DELAY_IDX_L : integer := 0;
    -- auto-computed: ra_delay width
    constant pkg_RA_DELAY_WIDTH : integer := fpasim.pkg_utils.pkg_width_from_indexes(i_idx_high => pkg_RA_DELAY_IDX_H, i_idx_low => pkg_RA_DELAY_IDX_L);

    -- user-defined: tes_conf 
    ---------------------------------------------------------------------
    -- user-defined: pixel_nb (bit index high)
    constant pkg_TES_CONF_PIXEL_NB_IDX_H : integer := 29;
    -- user-defined: pixel_nb (bit index low)
    constant pkg_TES_CONF_PIXEL_NB_IDX_L : integer := 24;
    -- auto-computed: pixel_nb width
    constant pkg_TES_CONF_PIXEL_NB_WIDTH : integer := fpasim.pkg_utils.pkg_width_from_indexes(i_idx_high => pkg_TES_CONF_PIXEL_NB_IDX_H, i_idx_low => pkg_TES_CONF_PIXEL_NB_IDX_L);

    -- user-defined: pixel_length (bit index high)
    constant pkg_TES_CONF_PIXEL_LENGTH_IDX_H : integer := 22;
    -- user-defined: pixel_length (bit index low)
    constant pkg_TES_CONF_PIXEL_LENGTH_IDX_L : integer := 16;
    -- auto-computed: pixel_length width
    constant pkg_TES_CONF_PIXEL_LENGTH_WIDTH : integer := fpasim.pkg_utils.pkg_width_from_indexes(i_idx_high => pkg_TES_CONF_PIXEL_LENGTH_IDX_H, i_idx_low => pkg_TES_CONF_PIXEL_LENGTH_IDX_L);

    -- user-defined: frame_length (bit index high)
    constant pkg_TES_CONF_FRAME_LENGTH_IDX_H : integer := 12;
    -- user-defined: frame_length (bit index low)
    constant pkg_TES_CONF_FRAME_LENGTH_IDX_L : integer := 0;
    -- auto-computed: frame_length width
    constant pkg_TES_CONF_FRAME_LENGTH_WIDTH : integer := fpasim.pkg_utils.pkg_width_from_indexes(i_idx_high => pkg_TES_CONF_FRAME_LENGTH_IDX_H, i_idx_low => pkg_TES_CONF_FRAME_LENGTH_IDX_L);

    -- user-defined: debug_ctrl 
    ---------------------------------------------------------------------
    -- user-defined: debug_pulse (bit index)
    constant pkg_DEBUG_CTRL_DEBUG_PULSE_IDX_H : integer := 0;
    -- user-defined: rst_status (bit index)
    constant pkg_DEBUG_CTRL_RST_STATUS_IDX_H  : integer := 1;

    -- user-defined: error_sel
    ---------------------------------------------------------------------
    -- user-defined: error_sel (bit index high)
    constant pkg_ERROR_SEL_IDX_H : integer := 2;
    -- user-defined: error_sel (bit index low)
    constant pkg_ERROR_SEL_IDX_L : integer := 0;
    -- auto-computed: error_sel width
    constant pkg_ERROR_SEL_WIDTH : integer := fpasim.pkg_utils.pkg_width_from_indexes(i_idx_high => pkg_ERROR_SEL_IDX_H, i_idx_low => pkg_ERROR_SEL_IDX_L);

END pkg_regdecode;

