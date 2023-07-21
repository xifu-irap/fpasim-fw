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
--    @file                   pkg_fpasim.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This package defines all constants associted to the fpasim function and its sub-functions.
--
--
--    Note: Frame and column names are interchangeable
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;

use work.pkg_utils;

package pkg_fpasim is

  -------------------------------------------------------------------
  -- common
  -------------------------------------------------------------------
  -- hardcoded : latency of the "sub_sfixed" module
  constant pkg_SUB_SFIXED_LATENCY                         : natural := 2;
  -- hardcoded : latency of the "add_sfixed" module
  constant pkg_ADD_SFIXED_LATENCY                         : natural := 2;
  -- hardcoded : latency of the "mult_sfixed" module
  constant pkg_MULT_SFIXED_LATENCY                        : natural := 4;
  -- hardcoded : latency of the "mult_sub_sfixed" module
  constant pkg_MULT_SUB_SFIXED_LATENCY                    : natural := 3;
  -- hardcoded : latency of the "mult_add_ufixed" module
  constant pkg_MULT_ADD_UFIXED_LATENCY                    : natural := 3;
  -- hardcoded : latency of the "mult_add_sfixed" module
  constant pkg_MULT_ADD_SFIXED_LATENCY                    : natural := 3;
  -- hardcoded : latency of the dynamic shif register when its input delay is set to 0
  constant pkg_DYNAMIC_SHIFT_REGISTER_WITH_DELAY0_LATENCY : natural := 1;

  -- pixel:
  -- requirement: FPASIM-FW-REQ-0030
  -- user-defined: maximal number of pixels by column authorized by the design (must be a power of 2)
  constant pkg_MUX_FACT_MAX                 : positive := 64;
  -- parameter renaming
  constant pkg_NB_PIXEL_BY_FRAME_MAX        : positive := pkg_MUX_FACT_MAX;

  -- requirement: FPASIM-FW-REQ-0060
  -- user-defined: maximum number of samples by pixel authorized by the design (must be a power of 2)
  --   IMPORTANT: the corresponding time depends on the data sampling frequency and the expected pixel frequency.
  constant pkg_NB_SAMPLE_BY_PIXEL_MAX       : positive := 64;
  -- auto-computed:  minimal bus width (expressed in bits) to represent the pkg_PIXEL_SIZE value
  constant pkg_NB_SAMPLE_BY_PIXEL_MAX_WIDTH : natural  := work.pkg_utils.pkg_width_from_value(pkg_NB_SAMPLE_BY_PIXEL_MAX);
  -- requirement: FPASIM-FW-REQ-0100
  -- user-defined: number of frames by pulse_shape
  --   Note: This value is equal to the number of value of a pulse shape
  constant pkg_NB_FRAME_BY_PULSE_SHAPE      : positive := 2048;
  -- requirement: FPASIM-FW-REQ-0100
  -- user-defined: define the oversample factor of each word of the pulse shape memory
  constant pkg_PULSE_SHAPE_OVERSAMPLE       : natural  := 16;

  -- auto-computed:  minimal bus width (expressed in bits) to represent the c_MUX_FACT value
  constant pkg_NB_PIXEL_BY_FRAME_MAX_WIDTH : natural := work.pkg_utils.pkg_width_from_value(pkg_NB_PIXEL_BY_FRAME_MAX);

  -- frame
  -- auto-computed:  minimal bus width (expressed in bits) to represent the pkg_FRAME_NB value
  constant pkg_NB_FRAME_BY_PULSE_SHAPE_WIDTH : natural  := work.pkg_utils.pkg_width_from_value(pkg_NB_FRAME_BY_PULSE_SHAPE);
  -- auto-computed : number of samples by frame
  constant pkg_NB_SAMPLE_BY_FRAME            : positive := pkg_NB_PIXEL_BY_FRAME_MAX * pkg_NB_SAMPLE_BY_PIXEL_MAX;
  -- auto-computed: minimal bus width (expressed in bits) to represent the pkg_FRAME_SIZE value
  constant pkg_NB_SAMPLE_BY_FRAME_WIDTH      : natural  := work.pkg_utils.pkg_width_from_value(pkg_NB_SAMPLE_BY_FRAME);

  ---------------------------------------------------------------------
  -- RAM
  ---------------------------------------------------------------------
  -- tes: en_table, pulse_heigth_table, time_shift_table, cnt_sample_pulse_shape_table
  -- user-defined: read latency of the RAM. Possible values: [1; max integer value[
  constant pkg_TES_TABLE_RAM_RD_LATENCY : natural := 1;
  -- Note:
  --  . The other RAM parameters are auto-computed.

  -- tes: pulse shape
  -- user-defined: read latency of the RAM (port A). Possible values: [2; max integer value[
  constant pkg_TES_PULSE_SHAPE_RAM_A_RD_LATENCY     : natural  := 3;
  -- user-defined: read latency of the RAM (port B). Possible values: [2; max integer value[
  constant pkg_TES_PULSE_SHAPE_RAM_B_RD_LATENCY     : natural  := 2;
  -- auto-computed: number of words
  constant pkg_TES_PULSE_SHAPE_RAM_NB_WORDS         : positive := pkg_PULSE_SHAPE_OVERSAMPLE * pkg_NB_FRAME_BY_PULSE_SHAPE;
  -- auto-computed: ram address bus width
  constant pkg_TES_PULSE_SHAPE_RAM_ADDR_WIDTH       : positive := work.pkg_utils.pkg_width_from_value(pkg_TES_PULSE_SHAPE_RAM_NB_WORDS);
  -- requirement: FPASIM-FW-REQ-0100
  -- user-defined: ram data bus width
  constant pkg_TES_PULSE_SHAPE_RAM_DATA_WIDTH       : positive := 16;
  -- user-defined: ram configuration file
  constant pkg_TES_PULSE_SHAPE_RAM_MEMORY_INIT_FILE : string   := "tes_pulse_shape.mem";

  -- tes: std state
  -- auto-computed: read latency of the RAM (port A). Possible values: [2; max integer value[. Indeed, by design, memory are in parallel. So, we fixe the same latency
  constant pkg_TES_STD_STATE_RAM_A_RD_LATENCY     : natural  := 3;
  -- auto-computed: read latency of the RAM (port B). Possible values: [2; max integer value[. Indeed, by design, memory are in parallel. So, we fixe the same latency
  constant pkg_TES_STD_STATE_RAM_B_RD_LATENCY     : natural  := pkg_TES_PULSE_SHAPE_RAM_B_RD_LATENCY;
  -- requirement: FPASIM-FW-REQ-0090
  -- auto-computed: number of words. The number of words should accomodate the maximal number of pixels
  constant pkg_TES_STD_STATE_RAM_NB_WORDS         : positive := pkg_NB_PIXEL_BY_FRAME_MAX;
  -- auto-computed: ram address bus width
  constant pkg_TES_STD_STATE_RAM_ADDR_WIDTH       : positive := work.pkg_utils.pkg_width_from_value(pkg_TES_STD_STATE_RAM_NB_WORDS);
  -- requirement: FPASIM-FW-REQ-0090
  -- user-defined: ram data bus width
  constant pkg_TES_STD_STATE_RAM_DATA_WIDTH       : positive := 16;
  -- user-defined: ram configuration file
  constant pkg_TES_STD_STATE_RAM_MEMORY_INIT_FILE : string   := "tes_std_state.mem";

  -- mux squid offset
  -- user-defined: read latency of the RAM (port A). Possible values: [2; max integer value[
  constant pkg_MUX_SQUID_OFFSET_RAM_A_RD_LATENCY     : natural  := 3;
  -- user-defined: read latency of the RAM (port B). Possible values: [2; max integer value[
  constant pkg_MUX_SQUID_OFFSET_RAM_B_RD_LATENCY     : natural  := 2;
  -- requirement: FPASIM-FW-REQ-0140
  -- auto-computed: number of words. The number of words should accomodate the maximal number of pixels
  constant pkg_MUX_SQUID_OFFSET_RAM_NB_WORDS         : positive := pkg_NB_PIXEL_BY_FRAME_MAX;
  -- auto-computed: ram address bus width
  constant pkg_MUX_SQUID_OFFSET_RAM_ADDR_WIDTH       : positive := work.pkg_utils.pkg_width_from_value(pkg_NB_PIXEL_BY_FRAME_MAX);
  -- requirement: FPASIM-FW-REQ-0140
  -- user-defined: data bus width
  constant pkg_MUX_SQUID_OFFSET_RAM_DATA_WIDTH       : positive := 16;
  -- user-defined: ram configuration file
  constant pkg_MUX_SQUID_OFFSET_RAM_MEMORY_INIT_FILE : string   := "mux_squid_offset.mem";

  -- mux squid tf
  -- user-defined: read latency of the RAM (port A). Possible values: [2; max integer value[.
  constant pkg_MUX_SQUID_TF_RAM_A_RD_LATENCY     : natural  := 3;
  -- user-defined: read latency of the RAM (port B). Possible values: [2; max integer value[.
  constant pkg_MUX_SQUID_TF_RAM_B_RD_LATENCY     : natural  := 2;
  -- requirement: FPASIM-FW-REQ-0130
  -- user-defined: number of words.
  constant pkg_MUX_SQUID_TF_RAM_NB_WORDS         : positive := 2 ** 13;
  -- auto-computed: ram address bus width
  constant pkg_MUX_SQUID_TF_RAM_ADDR_WIDTH       : positive := work.pkg_utils.pkg_width_from_value(pkg_MUX_SQUID_TF_RAM_NB_WORDS);
  -- requirement: FPASIM-FW-REQ-0130
  -- user-defined: ram data bus width
  constant pkg_MUX_SQUID_TF_RAM_DATA_WIDTH       : positive := 16;
  -- user-defined: ram configuration file
  constant pkg_MUX_SQUID_TF_RAM_MEMORY_INIT_FILE : string   := "mux_squid_tf.mem";
  --constant pkg_MUX_SQUID_TF_RAM_MEMORY_INIT_FILE   : string := "mux_squid_linear_tf.mem";

  -- amp squid tf
  -- user-defined: read latency of the RAM (port A). Possible values: [2; max integer value[
  constant pkg_AMP_SQUID_TF_RAM_A_RD_LATENCY     : natural := 3;
  -- user-defined: read latency of the RAM (port B). Possible values: [2; max integer value[
  constant pkg_AMP_SQUID_TF_RAM_B_RD_LATENCY     : natural := 2;
  -- requirement: FPASIM-FW-REQ-0160
  -- user-defined: number of words.
  constant pkg_AMP_SQUID_TF_RAM_NB_WORDS         : natural := 2 ** 14;
  -- auto-computed: ram address bus width
  constant pkg_AMP_SQUID_TF_RAM_ADDR_WIDTH       : natural := work.pkg_utils.pkg_width_from_value(pkg_AMP_SQUID_TF_RAM_NB_WORDS);
  -- requirement: FPASIM-FW-REQ-0160
  -- user-defined: ram data bus width
  constant pkg_AMP_SQUID_TF_RAM_DATA_WIDTH       : natural := 16;
  -- user-defined: ram configuration file
  constant pkg_AMP_SQUID_TF_RAM_MEMORY_INIT_FILE : string  := "amp_squid_tf.mem";
  --constant pkg_AMP_SQUID_TF_RAM_MEMORY_INIT_FILE   : string := "amp_squid_linear_tf.mem";

  ---------------------------------------------------------------------
  -- regdecode
  ---------------------------------------------------------------------
  -- hardcoded: latency of the fsm of the "regdecode_pipe_addr_decode_check_addr_range" module
  constant pkg_REGDECODE_PIPE_ADDR_DECODE_CHECK_ADDR_RANGE_LATENCY : natural := 2;

  ---------------------------------------------------------------------
  -- adc_top
  ---------------------------------------------------------------------

  -- auto-computed: latency of the dynamic_shift_register module when the input delay is set to 0
  constant pkg_ADC_DYNAMIC_SHIFT_REGISTER_LATENCY : natural := pkg_DYNAMIC_SHIFT_REGISTER_WITH_DELAY0_LATENCY;
  -- auto-computed: minimum latency of the "adc_top" module
  --    IMPORTANT: cross clock domain latency is not taken into account
  constant pkg_ADC_TOP_LATENCY                    : natural := pkg_ADC_DYNAMIC_SHIFT_REGISTER_LATENCY;

  -------------------------------------------------------------------
  -- tes
  -------------------------------------------------------------------

  -- tes_signalling_generator parameters
  ----------------------------------------------------------------------

  -- hardcoded: latency of the fsm of the "tes_signalling_generator" module
  constant pkg_TES_SIGNALLING_GENERATOR_FSM_LATENCY : natural := 2;
  -- user-defined : add an additionnal output latency
  constant pkg_TES_SIGNALLING_GENERATOR_OUT_LATENCY : natural := 0;
  -- auto-computed: latency of the "tes_signalling_generator" module
  constant pkg_TES_SIGNALLING_GENERATOR_LATENCY     : natural := pkg_TES_SIGNALLING_GENERATOR_FSM_LATENCY +
                                                                 pkg_TES_SIGNALLING_GENERATOR_OUT_LATENCY;

  -- auto-computed: latency of the "tes_signalling" module
  constant pkg_TES_SIGNALLING_LATENCY : natural := pkg_TES_SIGNALLING_GENERATOR_LATENCY;

  -- tes_pulse_manager
  ---------------------------------------------------------------------
  -- hardcoded: latency of the fsm of the "tes_pulse_manager" module
  constant pkg_TES_PULSE_MANAGER_FSM_LATENCY          : natural := 1;
  -- auto-computed: latency of the address computation of the "tes_pulse_manager" module
  constant pkg_TES_PULSE_MANAGER_ADDR_COMPUTE_LATENCY : natural := pkg_MULT_ADD_UFIXED_LATENCY;

  -- tes_pulse_manager_computation parameters
  ---------------------------------------------------------------------

  -- pulse shape
  -- requirement: FPASIM-FW-REQ-0100
  -- user-defined: number of bits used for the integer part of the value ( sign bit included)
  constant pkg_TES_MULT_SUB_Q_M_A     : positive := 17;
  -- requirement: FPASIM-FW-REQ-0100
  -- user-defined: number of fraction bits
  constant pkg_TES_MULT_SUB_Q_N_A     : natural  := 0;
  -- auto-computed: bus width of the TES_Q_A
  constant pkg_TES_MULT_SUB_Q_WIDTH_A : positive := pkg_TES_MULT_SUB_Q_M_A + pkg_TES_MULT_SUB_Q_N_A;

  -- pulse heigth
  -- requirement: FPASIM-FW-REQ-0110
  -- user-defined: number of bits used for the integer part of the value ( sign bit included)
  constant pkg_TES_MULT_SUB_Q_M_B     : positive := 1;
  -- requirement: FPASIM-FW-REQ-0110
  -- user-defined: number of fraction bits
  constant pkg_TES_MULT_SUB_Q_N_B     : natural  := 16;
  -- auto-computed: bus width of the TES_Q_B
  constant pkg_TES_MULT_SUB_Q_WIDTH_B : positive := pkg_TES_MULT_SUB_Q_M_B + pkg_TES_MULT_SUB_Q_N_B;

  -- steady state
  -- requirement: FPASIM-FW-REQ-0090
  -- user-defined: number of bits used for the integer part of the value ( sign bit included)
  constant pkg_TES_MULT_SUB_Q_M_C     : positive := 17;
  -- requirement: FPASIM-FW-REQ-0090
  -- user-defined: number of fraction bits
  constant pkg_TES_MULT_SUB_Q_N_C     : natural  := 0;
  -- auto-computed: bus width of the TES_Q_C
  constant pkg_TES_MULT_SUB_Q_WIDTH_C : positive := pkg_TES_MULT_SUB_Q_M_C + pkg_TES_MULT_SUB_Q_N_C;

  -- result: steady state - (pulse heigth*pulse shape)
  -- requirement: FPASIM-FW-REQ-0120
  -- user-defined: number of bits used for the integer part of the value ( sign bit included)
  constant pkg_TES_MULT_SUB_Q_M_S     : positive := 17;
  -- requirement: FPASIM-FW-REQ-0120
  -- user-defined: number of fraction bits
  constant pkg_TES_MULT_SUB_Q_N_S     : natural  := 0;
  -- auto-computed: bus width of the TES_Q_S
  constant pkg_TES_MULT_SUB_Q_WIDTH_S : positive := pkg_TES_MULT_SUB_Q_M_S + pkg_TES_MULT_SUB_Q_N_S;

  -- hardcoded: latency of the "mult_sub_sfixed" module
  constant pkg_TES_PULSE_MANAGER_COMPUTATION_LATENCY : natural := pkg_MULT_SUB_SFIXED_LATENCY;  -- number of pipes to compute the result

  -- hardcoded: latency to force the output value when negative.
  constant pkg_TES_FORCE_OUTPUT_LATENCY : positive := 1;

  -- auto-computed: latency of the "tes_pulse_manager" module
  constant pkg_TES_PULSE_MANAGER_LATENCY : natural := pkg_TES_TABLE_RAM_RD_LATENCY +
                                                      pkg_TES_PULSE_MANAGER_FSM_LATENCY +
                                                      pkg_TES_PULSE_MANAGER_ADDR_COMPUTE_LATENCY +
                                                      pkg_TES_PULSE_SHAPE_RAM_B_RD_LATENCY +
                                                      pkg_TES_PULSE_MANAGER_COMPUTATION_LATENCY +
                                                      pkg_TES_FORCE_OUTPUT_LATENCY;

  -- auto-computed: max number of samples between pixel_sof, pixel_eof
  -- the last one constants values are defined:
  --    . 1 (E_WAIT -> E_RUN) : FSM
  --    . 1 (E_RUN) : FSM
  --    . 1 (write memory latency)
  constant pkg_TES_PULSE_MANAGER_SOF_EOF_NB_SAMPLES_MIN : natural := pkg_TES_TABLE_RAM_RD_LATENCY +
                                                                     pkg_TES_PULSE_MANAGER_FSM_LATENCY + 1 + 1 + 1;
  -- auto-commputed: latency of the "tes_top" module
  constant pkg_TES_TOP_LATENCY : natural := pkg_TES_SIGNALLING_LATENCY + pkg_TES_PULSE_MANAGER_LATENCY;

  ---------------------------------------------------------------------
  -- mux_squid
  ---------------------------------------------------------------------

  -- sub
  -- pixel_result
  -- user-defined: number of bits used for the integer part of the value ( sign bit included)
  constant pkg_MUX_SQUID_SUB_Q_M_A     : positive := 17;
  -- user-defined: number of fraction bits
  constant pkg_MUX_SQUID_SUB_Q_N_A     : natural  := 0;
  -- auto-computed: bus width
  constant pkg_MUX_SQUID_SUB_Q_WIDTH_A : positive := pkg_MUX_SQUID_SUB_Q_M_A + pkg_MUX_SQUID_SUB_Q_N_A;

  -- mux_squid_feedback
  -- user-defined: number of bits used for the integer part of the value ( sign bit included)
  constant pkg_MUX_SQUID_SUB_Q_M_B     : positive := 16;
  -- user-defined: number of fraction bits
  constant pkg_MUX_SQUID_SUB_Q_N_B     : natural  := 0;
  -- auto-computed: bus width
  constant pkg_MUX_SQUID_SUB_Q_WIDTH_B : positive := pkg_MUX_SQUID_SUB_Q_M_B + pkg_MUX_SQUID_SUB_Q_N_B;

  -- result
  -- user-defined: number of bits used for the integer part of the value ( sign bit included)
  --   => this value must be equal to log2(pkg_MUX_SQUID_TF_RAM_NB_WORDS)
  constant pkg_MUX_SQUID_SUB_Q_M_S     : positive := 13;
  -- user-defined: number of fraction bits
  constant pkg_MUX_SQUID_SUB_Q_N_S     : natural  := 0;
  -- auto-computed: bus width
  constant pkg_MUX_SQUID_SUB_Q_WIDTH_S : positive := pkg_MUX_SQUID_SUB_Q_M_S + pkg_MUX_SQUID_SUB_Q_N_S;

  -- auto-computed: rename the "sub_sfixed" module latency
  --constant pkg_MUX_SQUID_SUB_LATENCY : natural := pkg_SUB_SFIXED_LATENCY;

  -- mult_add
  -- inter_squid_gain
  -- requirement: FPASIM-FW-REQ-0135
  -- user-defined: number of bits used for the integer part of the value ( sign bit included)
  constant pkg_MUX_SQUID_MULT_ADD_Q_M_A     : positive := 1;
  -- requirement: FPASIM-FW-REQ-0135
  -- user-defined: number of fraction bits
  constant pkg_MUX_SQUID_MULT_ADD_Q_N_A     : natural  := 8;
  -- auto-computed: bus width
  constant pkg_MUX_SQUID_MULT_ADD_Q_WIDTH_A : positive := pkg_MUX_SQUID_MULT_ADD_Q_M_A + pkg_MUX_SQUID_MULT_ADD_Q_N_A;

  -- mux_squid_tf
  -- requirement: FPASIM-FW-REQ-0130
  -- user-defined: number of bits used for the integer part of the value ( sign bit included)
  constant pkg_MUX_SQUID_MULT_ADD_Q_M_B     : positive := 17;
  -- requirement: FPASIM-FW-REQ-0130
  -- user-defined: number of fraction bits
  constant pkg_MUX_SQUID_MULT_ADD_Q_N_B     : natural  := 0;
  -- auto-computed: bus width
  constant pkg_MUX_SQUID_MULT_ADD_Q_WIDTH_B : positive := pkg_MUX_SQUID_MULT_ADD_Q_M_B + pkg_MUX_SQUID_MULT_ADD_Q_N_B;

  -- mux_squid_offset
  -- requirement: FPASIM-FW-REQ-0140
  -- user-defined: number of bits used for the integer part of the value ( sign bit included)
  constant pkg_MUX_SQUID_MULT_ADD_Q_M_C     : positive := 16;
  -- requirement: FPASIM-FW-REQ-0140
  -- user-defined: number of fraction bits
  constant pkg_MUX_SQUID_MULT_ADD_Q_N_C     : natural  := 0;
  -- auto-computed: bus width
  constant pkg_MUX_SQUID_MULT_ADD_Q_WIDTH_C : positive := pkg_MUX_SQUID_MULT_ADD_Q_M_C + pkg_MUX_SQUID_MULT_ADD_Q_N_C;

  -- result
  -- requirement: FPASIM-FW-REQ-0150
  -- user-defined: number of bits used for the integer part of the value ( sign bit included)
  constant pkg_MUX_SQUID_MULT_ADD_Q_M_S     : positive := 18;
  -- requirement: FPASIM-FW-REQ-0150
  -- user-defined: number of fraction bits
  constant pkg_MUX_SQUID_MULT_ADD_Q_N_S     : natural  := 0;
  -- auto-computed: bus width
  constant pkg_MUX_SQUID_MULT_ADD_Q_WIDTH_S : positive := pkg_MUX_SQUID_MULT_ADD_Q_M_S + pkg_MUX_SQUID_MULT_ADD_Q_N_S;

  -- auto-computed: rename the "add_sfixed" module latency
  --constant pkg_MUX_SQUID_ADD_LATENCY : natural := pkg_ADD_SFIXED_LATENCY;

  -- auto-computed: latency of the "mux_squid" module
  constant pkg_MUX_SQUID_LATENCY     : natural := pkg_SUB_SFIXED_LATENCY + pkg_MUX_SQUID_TF_RAM_B_RD_LATENCY + pkg_ADD_SFIXED_LATENCY;
  -- auto-computed: latency of the "mux_squid_top" module
  constant pkg_MUX_SQUID_TOP_LATENCY : natural := pkg_MUX_SQUID_LATENCY;

  ---------------------------------------------------------------------
  -- amp squid
  ---------------------------------------------------------------------

  -- sub
  -- pixel_result
  -- user-defined: number of bits used for the integer part of the value ( sign bit included)
  constant pkg_AMP_SQUID_SUB_Q_M_A     : positive := pkg_MUX_SQUID_MULT_ADD_Q_M_S;
  -- user-defined: number of fraction bits
  constant pkg_AMP_SQUID_SUB_Q_N_A     : natural  := pkg_MUX_SQUID_MULT_ADD_Q_N_S;
  -- auto-computed: bus width
  constant pkg_AMP_SQUID_SUB_Q_WIDTH_A : natural  := pkg_AMP_SQUID_SUB_Q_M_A + pkg_AMP_SQUID_SUB_Q_N_A;

  -- mux_squid_feedback
  -- user-defined: number of bits used for the integer part of the value ( sign bit included)
  constant pkg_AMP_SQUID_SUB_Q_M_B     : positive := 15;
  -- user-defined: number of fraction bits
  constant pkg_AMP_SQUID_SUB_Q_N_B     : natural  := 0;
  -- auto-computed: bus width
  constant pkg_AMP_SQUID_SUB_Q_WIDTH_B : positive := pkg_AMP_SQUID_SUB_Q_M_B + pkg_AMP_SQUID_SUB_Q_N_B;

  -- result: pixel_result - mux_squid_feedback
  -- user-defined: number of bits used for the integer part of the value ( sign bit included)
  --   => this value must be equal to log2(pkg_AMP_SQUID_TF_RAM_NB_WORDS)
  constant pkg_AMP_SQUID_SUB_Q_M_S     : positive := 14;
  -- user-defined: number of fraction bits
  constant pkg_AMP_SQUID_SUB_Q_N_S     : natural  := 0;
  -- auto-computed: bus width
  constant pkg_AMP_SQUID_SUB_Q_WIDTH_S : positive := pkg_AMP_SQUID_SUB_Q_M_S + pkg_AMP_SQUID_SUB_Q_N_S;

  constant pkg_AMP_SQUID_SUB_LATENCY : natural := pkg_SUB_SFIXED_LATENCY;

  -- user-defined: add an additional output latency
  constant pkg_AMP_SQUID_OUT_LATENCY              : natural := 0;

  -- result: output
  -- user-defined: number of bits used for the integer part of the value ( sign bit included)
  constant pkg_AMP_SQUID_Q_M_S   : positive := 16;
  -- user-defined: number of fraction bits
  constant pkg_AMP_SQUID_Q_N_S   : natural  := 0;
  -- auto-computed: bus width
  constant pkg_AMP_SQUID_Q_WIDTH : positive := pkg_AMP_SQUID_Q_M_S + pkg_AMP_SQUID_Q_N_S;

  -- auto-computed: latency of the "amp_squid" module
  constant pkg_AMP_SQUID_LATENCY                   : natural := pkg_AMP_SQUID_SUB_LATENCY + pkg_AMP_SQUID_TF_RAM_B_RD_LATENCY + pkg_AMP_SQUID_OUT_LATENCY;
  -- auto-computed: latency of the "amp_squid_top" module
  constant pkg_AMP_SQUID_TOP_LATENCY               : natural := pkg_AMP_SQUID_LATENCY;

  ---------------------------------------------------------------------
  -- dac_top
  ---------------------------------------------------------------------
  -- hardcoded: latency of the "dac_frame_generator" module. This latency is equal to the "dynamic_shift_register" module when delay is 0
  constant pkg_DAC_FRAME_GENERATOR_LATENCY        : natural := 1;
  -- auto-computed: latency of the dynamic_shift_register module when the input delay is set to 0
  constant pkg_DAC_DYNAMIC_SHIFT_REGISTER_LATENCY : natural := pkg_DYNAMIC_SHIFT_REGISTER_WITH_DELAY0_LATENCY;
  -- auto-computed: latency of the "dac_top" from the input port to the input of the last pipeliner.
  constant pkg_DAC_LATENCY_TMP                    : natural := pkg_DAC_FRAME_GENERATOR_LATENCY + pkg_DAC_DYNAMIC_SHIFT_REGISTER_LATENCY;

  -- user-defined: dac_pattern0 (see dac3283 datasheet figure 34)
  constant pkg_DAC_PATTERN0 : std_logic_vector(7 downto 0):= x"55";

  -- user-defined: dac_pattern1 (see dac3283 datasheet figure 34)
  constant pkg_DAC_PATTERN1 : std_logic_vector(7 downto 0):= x"55";

  -- user-defined: dac_pattern2 (see dac3283 datasheet figure 34)
  constant pkg_DAC_PATTERN2 : std_logic_vector(7 downto 0):= x"01";

  -- user-defined: dac_pattern3 (see dac3283 datasheet figure 34)
  constant pkg_DAC_PATTERN3 : std_logic_vector(7 downto 0):= x"02";

  -- user-defined: dac_pattern4 (see dac3283 datasheet figure 34)
  constant pkg_DAC_PATTERN4 : std_logic_vector(7 downto 0):= x"AA";

  -- user-defined: dac_pattern5 (see dac3283 datasheet figure 34)
  constant pkg_DAC_PATTERN5 : std_logic_vector(7 downto 0):= x"AA";

  -- user-defined: dac_pattern6 (see dac3283 datasheet figure 34)
  constant pkg_DAC_PATTERN6 : std_logic_vector(7 downto 0):= x"03";

  -- user-defined: dac_pattern7 (see dac3283 datasheet figure 34)
  constant pkg_DAC_PATTERN7 : std_logic_vector(7 downto 0):= x"04";

  ---------------------------------------------------------------------
  -- sync_top
  ---------------------------------------------------------------------
  -- FPASIM-FW-REQ-0080
  -- user-defined: width of the sync pulse (expressed in number of clock cycles) on the FPGA pin. Possible values: [1;integer max value[
  constant pkg_SYNC_PULSE_DURATION                 : positive := 4;
  -- hardcoded: latency of the "sync_pulse_generator" module
  constant pkg_SYNC_PULSE_GENERATOR_LATENCY        : natural  := 1;
  -- auto-computed: latency of the dynamic_shift_register module when the input delay is set to 0
  constant pkg_SYNC_DYNAMIC_SHIFT_REGISTER_LATENCY : natural  := pkg_DYNAMIC_SHIFT_REGISTER_WITH_DELAY0_LATENCY;

  -- auto-computed: latency of the "sync_top" from the input port to the input of the last pipeliner.
  constant pkg_SYNC_LATENCY_TMP : natural := pkg_SYNC_DYNAMIC_SHIFT_REGISTER_LATENCY + pkg_SYNC_PULSE_GENERATOR_LATENCY;

  ---------------------------------------------------------------------
  -- to facilitate the debugging, sync_top and dac_top should have the
  -- same latency when the delay(dynamic_shift_register) = 0
  -- So, the latency of the dac_top output pipeliner must take into account:
  --    . the latency of the dac_top upstream function
  --    . the latency of the sync_top upstream function
  -- And, the latency of the sync_top output pipeliner must take into account:
  --    . the latency of the dac_top upstream function
  --    . the latency of the sync_top upstream function
  ---------------------------------------------------------------------
  -- auto-computed: latency of the dac_top output pipeliner to be synchronized to the sync_top ouptput
  constant pkg_DAC_OUT_LATENCY : natural := abs(pkg_DAC_LATENCY_TMP - work.pkg_utils.max(pkg_DAC_LATENCY_TMP, pkg_SYNC_LATENCY_TMP));
  -- auto-computed: latency of the "dac_top" module.
  --constant pkg_DAC_TOP_LATENCY            : natural := pkg_DAC_FRAME_GENERATOR_LATENCY + pkg_DAC_DYNAMIC_SHIFT_REGISTER_LATENCY;
  constant pkg_DAC_TOP_LATENCY : natural := pkg_DAC_LATENCY_TMP + pkg_DAC_OUT_LATENCY;

  -- auto-computed: latency of the sync_top output pipeliner to be synchronized to the dac_top ouptput
  constant pkg_SYNC_OUT_LATENCY : natural := abs(pkg_SYNC_LATENCY_TMP - work.pkg_utils.max(pkg_DAC_LATENCY_TMP, pkg_SYNC_LATENCY_TMP));
  -- auto-computed: latency of the "sync_top" module.
  --constant pkg_SYNC_TOP_LATENCY                    : natural  := pkg_SYNC_DYNAMIC_SHIFT_REGISTER_LATENCY + pkg_SYNC_PULSE_GENERATOR_LATENCY + pkg_SYNC_OUT_LATENCY;
  constant pkg_SYNC_TOP_LATENCY : natural := pkg_SYNC_LATENCY_TMP + pkg_SYNC_OUT_LATENCY;

  ---------------------------------------------------------------------
  -- Recording
  ---------------------------------------------------------------------
  -- user-defined: number of 32 bit-words in the output FIFO (must be a multiple of the usb3 minimum packet size)
  constant pkg_REC_ADC_FIFO_OUT_DEPTH : integer := 16384;

end pkg_fpasim;

