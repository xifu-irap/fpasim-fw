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
--!   @file                   pkg_fpasim.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
-- This package defines all constant used by the fpasim function. 
-- These constants configure the bus width of the differents functions.
--
-- Note: Frame and column are interchangeable
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.math_real.all;

library fpasim;
use fpasim.pkg_utils;

PACKAGE pkg_fpasim IS

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
  -- hardcoded : latency of the dynamic shif register when its input delay is set to 0
  constant pkg_DYNAMIC_SHIFT_REGISTER_WITH_DELAY0_LATENCY : natural := 1;

  -- pixel
  -- user-defined: maximal number of pixels by column authorized by the design (must be a power of 2)
  constant pkg_MUX_FACT_MAX           : positive := 64;
  -- parameter renaming
  constant pkg_NB_PIXEL_BY_FRAME_MAX           : positive := pkg_MUX_FACT_MAX;
  -- user-defined: maximum number of samples by pixel authorized by the design (must be a power of 2)
  --   IMPORTANT: the corresponding time depends on the data sampling frequency and the expected pixel frequency.
  constant pkg_NB_SAMPLE_BY_PIXEL_MAX         : positive := 64;
  -- auto-computed:  minimal bus width (expressed in bits) to represent the pkg_PIXEL_SIZE value
  constant pkg_NB_SAMPLE_BY_PIXEL_MAX_WIDTH        : natural  := fpasim.pkg_utils.pkg_width_from_value(pkg_NB_SAMPLE_BY_PIXEL_MAX);
  -- user-defined: number of frames by pulse_shape
  --   Note: This value is equal to the number of value of a pulse shape
  constant pkg_NB_FRAME_BY_PULSE_SHAPE               : positive := 2048;
  -- user-defined: define the oversample factor of each word of the pulse shape memory
  constant pkg_PULSE_SHAPE_OVERSAMPLE : natural  := 16;

    -- auto-computed:  minimal bus width (expressed in bits) to represent the c_MUX_FACT value
    constant pkg_NB_PIXEL_BY_FRAME_MAX_WIDTH : natural := fpasim.pkg_utils.pkg_width_from_value(pkg_NB_PIXEL_BY_FRAME_MAX);

    -- frame
    -- auto-computed:  minimal bus width (expressed in bits) to represent the pkg_FRAME_NB value
    constant pkg_NB_FRAME_BY_PULSE_SHAPE_WIDTH : natural  := fpasim.pkg_utils.pkg_width_from_value(pkg_NB_FRAME_BY_PULSE_SHAPE);
    -- auto-computed : number of samples by frame
    constant pkg_NB_SAMPLE_BY_FRAME     : positive := pkg_NB_PIXEL_BY_FRAME_MAX * pkg_NB_SAMPLE_BY_PIXEL_MAX;
    -- auto-computed: minimal bus width (expressed in bits) to represent the pkg_FRAME_SIZE value
    constant pkg_NB_SAMPLE_BY_FRAME_WIDTH    : natural  := fpasim.pkg_utils.pkg_width_from_value(pkg_NB_SAMPLE_BY_FRAME);

  ---------------------------------------------------------------------
  -- RAM
  ---------------------------------------------------------------------
  -- pulse shape
  -- user-defined: read latency of the RAM (port A). Possible values: [2; max integer value[
  constant pkg_TES_PULSE_SHAPE_RAM_A_RD_LATENCY : natural  := 3;
  -- user-defined: read latency of the RAM (port B). Possible values: [2; max integer value[
  constant pkg_TES_PULSE_SHAPE_RAM_B_RD_LATENCY : natural  := 2;
  -- auto-computed: number of words
  constant pkg_TES_PULSE_SHAPE_RAM_NB_WORDS     : positive := pkg_PULSE_SHAPE_OVERSAMPLE * pkg_NB_FRAME_BY_PULSE_SHAPE;
  -- auto-computed: ram address bus width
  constant pkg_TES_PULSE_SHAPE_RAM_ADDR_WIDTH   : positive := fpasim.pkg_utils.pkg_width_from_value(pkg_TES_PULSE_SHAPE_RAM_NB_WORDS);
  -- user-defined: ram data bus width
  constant pkg_TES_PULSE_SHAPE_RAM_DATA_WIDTH   : positive := 16;

  -- std state
  -- auto-computed: read latency of the RAM (port A). Possible values: [2; max integer value[. Indeed, by design, memory are in parallel. So, we fixe the same latency
  constant pkg_TES_STD_STATE_RAM_A_RD_LATENCY : natural  := 3;
  -- auto-computed: read latency of the RAM (port B). Possible values: [2; max integer value[. Indeed, by design, memory are in parallel. So, we fixe the same latency
  constant pkg_TES_STD_STATE_RAM_B_RD_LATENCY : natural  := pkg_TES_PULSE_SHAPE_RAM_B_RD_LATENCY;
  -- auto-computed: number of words. The number of words should accomodate the maximal number of pixels
  constant pkg_TES_STD_STATE_RAM_NB_WORDS     : positive := pkg_NB_PIXEL_BY_FRAME_MAX;
  -- auto-computed: ram address bus width
  constant pkg_TES_STD_STATE_RAM_ADDR_WIDTH   : positive := fpasim.pkg_utils.pkg_width_from_value(pkg_TES_STD_STATE_RAM_NB_WORDS);
  -- user-defined: ram data bus width
  constant pkg_TES_STD_STATE_RAM_DATA_WIDTH   : positive := 16;

  -- mux squid offset
  -- user-defined: read latency of the RAM (port A). Possible values: [2; max integer value[
  constant pkg_MUX_SQUID_OFFSET_RAM_A_RD_LATENCY : natural  := 3;
  -- user-defined: read latency of the RAM (port B). Possible values: [2; max integer value[
  constant pkg_MUX_SQUID_OFFSET_RAM_B_RD_LATENCY : natural  := 2;
  -- auto-computed: number of words. The number of words should accomodate the maximal number of pixels
  constant pkg_MUX_SQUID_OFFSET_RAM_NB_WORDS     : positive := pkg_NB_PIXEL_BY_FRAME_MAX;
  -- auto-computed: ram address bus width
  constant pkg_MUX_SQUID_OFFSET_RAM_ADDR_WIDTH   : positive := fpasim.pkg_utils.pkg_width_from_value(pkg_NB_PIXEL_BY_FRAME_MAX);
  -- user-defined: data bus width
  constant pkg_MUX_SQUID_OFFSET_RAM_DATA_WIDTH   : positive := 16;

  -- mux squid tf
  -- user-defined: read latency of the RAM (port A). Possible values: [2; max integer value[.
  constant pkg_MUX_SQUID_TF_RAM_A_RD_LATENCY : natural  := 3;
  -- user-defined: read latency of the RAM (port B). Possible values: [2; max integer value[.
  constant pkg_MUX_SQUID_TF_RAM_B_RD_LATENCY : natural  := 2;
  -- user-defined: number of words.
  constant pkg_MUX_SQUID_TF_RAM_NB_WORDS     : positive := 2 ** 13;
  -- auto-computed: ram address bus width
  constant pkg_MUX_SQUID_TF_RAM_ADDR_WIDTH   : positive := fpasim.pkg_utils.pkg_width_from_value(pkg_MUX_SQUID_TF_RAM_NB_WORDS);
  -- user-defined: ram data bus width
  constant pkg_MUX_SQUID_TF_RAM_DATA_WIDTH   : positive := 16;

  -- amp squid tf
  -- user-defined: read latency of the RAM (port A). Possible values: [2; max integer value[
  constant pkg_AMP_SQUID_TF_RAM_A_RD_LATENCY : natural := 3;
  -- user-defined: read latency of the RAM (port B). Possible values: [2; max integer value[
  constant pkg_AMP_SQUID_TF_RAM_B_RD_LATENCY : natural := 2;
  -- user-defined: number of words.
  constant pkg_AMP_SQUID_TF_RAM_NB_WORDS     : natural := 2 ** 14;
  -- auto-computed: ram address bus width
  constant pkg_AMP_SQUID_TF_RAM_ADDR_WIDTH   : natural := fpasim.pkg_utils.pkg_width_from_value(pkg_AMP_SQUID_TF_RAM_NB_WORDS);
  -- user-defined: ram data bus width
  constant pkg_AMP_SQUID_TF_RAM_DATA_WIDTH   : natural := 16;

  ---------------------------------------------------------------------
  -- regdecode
  ---------------------------------------------------------------------
  -- hardcoded: latency of the fsm of the "regdecode_pipe_addr_decode_check_addr_range" module
  constant pkg_REGDECODE_PIPE_ADDR_DECODE_CHECK_ADDR_RANGE_LATENCY : natural := 2;

  ---------------------------------------------------------------------
  -- adc_top
  ---------------------------------------------------------------------
  -- user defined: Read FIFO latency. Possible values : [1, max integer value[ 
  --   IMPORTANT: cross clock domain latency is not taken into account.
  constant pkg_ADC_FIFO_READ_LATENCY              : natural := 1;
  -- auto-computed: latency of the dynamic_shift_register module when the input delay is set to 0
  constant pkg_ADC_DYNAMIC_SHIFT_REGISTER_LATENCY : natural := pkg_DYNAMIC_SHIFT_REGISTER_WITH_DELAY0_LATENCY;
  -- auto-computed: minimum latency of the "adc_top" module
  --    IMPORTANT: cross clock domain latency is not taken into account
  constant pkg_ADC_TOP_LATENCY                    : natural := pkg_ADC_FIFO_READ_LATENCY + pkg_ADC_DYNAMIC_SHIFT_REGISTER_LATENCY;

  -------------------------------------------------------------------
  -- tes
  -------------------------------------------------------------------

  -- tes_signalling_generator parameters
  ----------------------------------------------------------------------



  -- hardcoded: latency of the fsm of the "tes_signalling_generator" module
  constant pkg_TES_SIGNALLING_GENERATOR_FSM_LATENCY : natural := 1;
  -- user-defined : add an additionnal output latency
  constant pkg_TES_SIGNALLING_GENERATOR_OUT_LATENCY : natural := 0;
  -- auto-computed: latency of the "tes_signalling_generator" module
  constant pkg_TES_SIGNALLING_GENERATOR_LATENCY     : natural := pkg_TES_SIGNALLING_GENERATOR_FSM_LATENCY + pkg_TES_SIGNALLING_GENERATOR_OUT_LATENCY; -- number of pipes of the "tes_signalling_generator"

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
  -- user-defined: number of bits used for the integer part of the value ( sign bit included)
  constant pkg_TES_MULT_SUB_Q_M_A     : positive := 17;
  -- user-defined: number of fraction bits
  constant pkg_TES_MULT_SUB_Q_N_A     : natural  := 0;
  -- auto-computed: bus width of the TES_Q_A
  constant pkg_TES_MULT_SUB_Q_WIDTH_A : positive := pkg_TES_MULT_SUB_Q_M_A + pkg_TES_MULT_SUB_Q_N_A;

  -- pulse heigth
  -- user-defined: number of bits used for the integer part of the value ( sign bit included)
  constant pkg_TES_MULT_SUB_Q_M_B     : positive := 1;
  -- user-defined: number of fraction bits
  constant pkg_TES_MULT_SUB_Q_N_B     : natural  := 16;
  -- auto-computed: bus width of the TES_Q_B
  constant pkg_TES_MULT_SUB_Q_WIDTH_B : positive := pkg_TES_MULT_SUB_Q_M_B + pkg_TES_MULT_SUB_Q_N_B;

  -- steady state
  -- user-defined: number of bits used for the integer part of the value ( sign bit included)
  constant pkg_TES_MULT_SUB_Q_M_C     : positive := 17;
  -- user-defined: number of fraction bits
  constant pkg_TES_MULT_SUB_Q_N_C     : natural  := 0;
  -- auto-computed: bus width of the TES_Q_C
  constant pkg_TES_MULT_SUB_Q_WIDTH_C : positive := pkg_TES_MULT_SUB_Q_M_C + pkg_TES_MULT_SUB_Q_N_C;

  -- result: steady state - (pulse heigth*pulse shape)
  -- user-defined: number of bits used for the integer part of the value ( sign bit included)
  constant pkg_TES_MULT_SUB_Q_M_S     : positive := 16;
  -- user-defined: number of fraction bits
  constant pkg_TES_MULT_SUB_Q_N_S     : natural  := 0;
  -- auto-computed: bus width of the TES_Q_S
  constant pkg_TES_MULT_SUB_Q_WIDTH_S : positive := pkg_TES_MULT_SUB_Q_M_S + pkg_TES_MULT_SUB_Q_N_S;

  -- hardcode: latency of the "mult_sub_sfixed" module
  constant pkg_TES_PULSE_MANAGER_COMPUTATION_LATENCY : natural := pkg_MULT_SUB_SFIXED_LATENCY; -- number of pipes to compute the result

  -- user-defined: enable the overflow checking
  constant pkg_TES_PULSE_MANAGER_COMPUTATION_SIM_EN : boolean := TRUE;

  -- auto-computed: latency of the "tes_pulse_manager" module
  constant pkg_TES_PULSE_MANAGER_LATENCY : natural := pkg_TES_PULSE_MANAGER_FSM_LATENCY + pkg_TES_PULSE_MANAGER_ADDR_COMPUTE_LATENCY + pkg_TES_PULSE_SHAPE_RAM_B_RD_LATENCY + pkg_TES_PULSE_MANAGER_COMPUTATION_LATENCY;

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
  constant pkg_MUX_SQUID_SUB_Q_M_B     : positive := 14;
  -- user-defined: number of fraction bits
  constant pkg_MUX_SQUID_SUB_Q_N_B     : natural  := 0;
  -- auto-computed: bus width
  constant pkg_MUX_SQUID_SUB_Q_WIDTH_B : positive := pkg_MUX_SQUID_SUB_Q_M_B + pkg_MUX_SQUID_SUB_Q_N_B;

  -- result
  -- user-defined: number of bits used for the integer part of the value ( sign bit included)
  constant pkg_MUX_SQUID_SUB_Q_M_S     : positive := 13;
  -- user-defined: number of fraction bits
  constant pkg_MUX_SQUID_SUB_Q_N_S     : natural  := 0;
  -- auto-computed: bus width
  constant pkg_MUX_SQUID_SUB_Q_WIDTH_S : positive := pkg_MUX_SQUID_SUB_Q_M_S + pkg_MUX_SQUID_SUB_Q_N_S;

  -- auto-computed: rename the "sub_sfixed" module latency
  constant pkg_MUX_SQUID_SUB_LATENCY : natural := pkg_SUB_SFIXED_LATENCY;

  -- add
  -- mux_squid_offset
  -- user-defined: number of bits used for the integer part of the value ( sign bit included)
  constant pkg_MUX_SQUID_ADD_Q_M_A     : positive := 16;
  -- user-defined: number of fraction bits
  constant pkg_MUX_SQUID_ADD_Q_N_A     : natural  := 0;
  -- auto-computed: bus width
  constant pkg_MUX_SQUID_ADD_Q_WIDTH_A : positive := pkg_MUX_SQUID_ADD_Q_M_A + pkg_MUX_SQUID_ADD_Q_N_A;

  -- mux_squid_tf
  -- user-defined: number of bits used for the integer part of the value ( sign bit included)
  constant pkg_MUX_SQUID_ADD_Q_M_B     : positive := 16;
  -- user-defined: number of fraction bits
  constant pkg_MUX_SQUID_ADD_Q_N_B     : natural  := 0;
  -- auto-computed: bus width
  constant pkg_MUX_SQUID_ADD_Q_WIDTH_B : positive := pkg_MUX_SQUID_ADD_Q_M_B + pkg_MUX_SQUID_ADD_Q_N_B;

  -- result
  -- user-defined: number of bits used for the integer part of the value ( sign bit included)
  constant pkg_MUX_SQUID_ADD_Q_M_S     : positive := 34;
  -- user-defined: number of fraction bits
  constant pkg_MUX_SQUID_ADD_Q_N_S     : natural  := 0;
  -- auto-computed: bus width
  constant pkg_MUX_SQUID_ADD_Q_WIDTH_S : positive := pkg_MUX_SQUID_ADD_Q_M_S + pkg_MUX_SQUID_ADD_Q_N_S;

  -- auto-computed: rename the "add_sfixed" module latency
  constant pkg_MUX_SQUID_ADD_LATENCY : natural := pkg_ADD_SFIXED_LATENCY;

  -- auto-computed: latency of the "mux_squid" module
  constant pkg_MUX_SQUID_LATENCY     : natural := pkg_MUX_SQUID_SUB_LATENCY + pkg_MUX_SQUID_TF_RAM_B_RD_LATENCY + pkg_MUX_SQUID_ADD_LATENCY;
  -- auto-computed: latency of the "mux_squid_top" module
  constant pkg_MUX_SQUID_TOP_LATENCY : natural := pkg_MUX_SQUID_LATENCY;

  ---------------------------------------------------------------------
  -- amp squid
  ---------------------------------------------------------------------

  -- sub
  -- pixel_result
  -- user-defined: number of bits used for the integer part of the value ( sign bit included)
  constant pkg_AMP_SQUID_SUB_Q_M_A     : positive := pkg_MUX_SQUID_ADD_Q_M_S;
  -- user-defined: number of fraction bits
  constant pkg_AMP_SQUID_SUB_Q_N_A     : natural  := pkg_MUX_SQUID_ADD_Q_N_S;
  -- auto-computed: bus width
  constant pkg_AMP_SQUID_SUB_Q_WIDTH_A : natural  := pkg_AMP_SQUID_SUB_Q_M_A + pkg_AMP_SQUID_SUB_Q_N_A;

  -- mux_squid_feedback
  -- user-defined: number of bits used for the integer part of the value ( sign bit included)
  constant pkg_AMP_SQUID_SUB_Q_M_B     : positive := 14;
  -- user-defined: number of fraction bits
  constant pkg_AMP_SQUID_SUB_Q_N_B     : natural  := 0;
  -- auto-computed: bus width
  constant pkg_AMP_SQUID_SUB_Q_WIDTH_B : positive := pkg_AMP_SQUID_SUB_Q_M_B + pkg_AMP_SQUID_SUB_Q_N_B;

  -- result: pixel_result - mux_squid_feedback
  -- user-defined: number of bits used for the integer part of the value ( sign bit included)
  constant pkg_AMP_SQUID_SUB_Q_M_S     : positive := 14;
  -- user-defined: number of fraction bits
  constant pkg_AMP_SQUID_SUB_Q_N_S     : natural  := 0;
  -- auto-computed: bus width
  constant pkg_AMP_SQUID_SUB_Q_WIDTH_S : positive := pkg_AMP_SQUID_SUB_Q_M_S + pkg_AMP_SQUID_SUB_Q_N_S;

  constant pkg_AMP_SQUID_SUB_LATENCY : natural := pkg_SUB_SFIXED_LATENCY;

  -- mult
  -- result
  -- user-defined: number of bits used for the integer part of the value ( sign bit included)
  constant pkg_AMP_SQUID_MULT_Q_M_A     : positive := 17; -- user defined: number of bits used for the integer part of the value ( sign bit included)
  -- user-defined: number of fraction bits
  constant pkg_AMP_SQUID_MULT_Q_N_A     : natural  := 0; -- user defined: number of fraction bits
  -- auto-computed: bus width
  constant pkg_AMP_SQUID_MULT_Q_WIDTH_A : positive := pkg_AMP_SQUID_MULT_Q_M_A + pkg_AMP_SQUID_MULT_Q_N_A;

  -- fpasim_gain
  -- user-defined: number of bits used for the integer part of the value ( sign bit included)
  constant pkg_AMP_SQUID_MULT_Q_M_B     : positive := 4;
  -- user-defined: number of fraction bits
  constant pkg_AMP_SQUID_MULT_Q_N_B     : natural  := 2;
  -- auto-computed: bus width
  constant pkg_AMP_SQUID_MULT_Q_WIDTH_B : positive := pkg_AMP_SQUID_MULT_Q_M_B + pkg_AMP_SQUID_MULT_Q_N_B;

  -- result
  -- user-defined: number of bits used for the integer part of the value ( sign bit included)
  constant pkg_AMP_SQUID_MULT_Q_M_S   : positive := 16;
  -- user-defined: number of fraction bits
  constant pkg_AMP_SQUID_MULT_Q_N_S   : natural  := 0;
  -- auto-computed: bus width
  constant pkg_AMP_SQUID_MULT_Q_WIDTH : positive := pkg_AMP_SQUID_MULT_Q_M_S + pkg_AMP_SQUID_MULT_Q_N_S;

  -- auto-computed: latency of the mult_sfixed
  constant pkg_AMP_SQUID_MULT_LATENCY              : natural := pkg_MULT_SFIXED_LATENCY;
  -- user-defined: FSM latency of the "amp_squid_fpagain_table" moduble
  constant pkg_AMP_SQUID_FPAGAIN_TABLE_FSM_LATENCY : natural := 1;
  -- user-defined: optionnal: add output latency to the "amp_squid_fpagain_table" moduble
  constant pkg_AMP_SQUID_FPAGAIN_TABLE_OUT_LATENCY : natural := pkg_AMP_SQUID_SUB_LATENCY + pkg_MUX_SQUID_TF_RAM_B_RD_LATENCY - pkg_AMP_SQUID_FPAGAIN_TABLE_FSM_LATENCY;
  -- auto-computed: latency of the "amp_squid_fpagain_table" module
  constant pkg_AMP_SQUID_FPAGAIN_TABLE_LATENCY     : natural := pkg_AMP_SQUID_FPAGAIN_TABLE_FSM_LATENCY + pkg_AMP_SQUID_FPAGAIN_TABLE_OUT_LATENCY;
  -- auto-computed: latency of the "amp_squid" module
  constant pkg_AMP_SQUID_LATENCY                   : natural := pkg_AMP_SQUID_SUB_LATENCY + pkg_AMP_SQUID_TF_RAM_B_RD_LATENCY + pkg_AMP_SQUID_MULT_LATENCY;
  -- auto-computed: latency of the "amp_squid_top" module
  constant pkg_AMP_SQUID_TOP_LATENCY               : natural := pkg_AMP_SQUID_LATENCY;

  ---------------------------------------------------------------------
  -- dac_top
  ---------------------------------------------------------------------
  -- user-defined: number of samples of a dac frame.
  constant pkg_DAC_FRAME_SIZE                     : positive := 8;
  -- auto-computed: latency of the dynamic_shift_register module when the input delay is set to 0
  constant pkg_DAC_DYNAMIC_SHIFT_REGISTER_LATENCY : natural  := pkg_DYNAMIC_SHIFT_REGISTER_WITH_DELAY0_LATENCY;
  -- hardcoded: latency of the "dac_frame_generator" module. This latency is equal to the "dynamic_shift_register" module when delay is 0
  constant pkg_DAC_FRAME_GENERATOR_LATENCY        : natural  := 1;

  -- hardcoded: latency of the "dac_data_insert" module.
  --   IMPORTANT: cross clock domain latency is not taken into account.
  constant pkg_DAC_DATA_INSERT_LATENCY    : natural := 1;
  -- hardcoded: latency of the "dac_check_dataflow" module.
  --   Note: Don't contribute to the data path
  constant pkg_DAC_CHECK_DATAFLOW_LATENCY : natural := 1;
  -- auto-computed: minimum latency of the "dac_top" module
  --    IMPORTANT: cross clock domain latency is not taken into account
  constant pkg_DAC_TOP_LATENCY            : natural := pkg_DAC_DYNAMIC_SHIFT_REGISTER_LATENCY + pkg_DAC_FRAME_GENERATOR_LATENCY + pkg_DAC_DATA_INSERT_LATENCY;

  ---------------------------------------------------------------------
  -- sync_top
  ---------------------------------------------------------------------
  -- user-defined: width of the sync pulse (expressed in number of clock cycles). Possible values: [1;integer max value[
  constant pkg_SYNC_PULSE_DURATION                 : positive := 1;
  -- auto-computed: latency of the dynamic_shift_register module when the input delay is set to 0
  constant pkg_SYNC_DYNAMIC_SHIFT_REGISTER_LATENCY : natural  := pkg_DYNAMIC_SHIFT_REGISTER_WITH_DELAY0_LATENCY;
  -- hardcoded: latency of the "sync_pulse_generator" module
  constant pkg_SYNC_PULSE_GENERATOR_LATENCY        : natural  := 1;
  -- user-defined: Read FIFO latency. Possible values : [1, max integer value[
  constant pkg_SYNC_FIFO_READ_LATENCY              : natural  := 1;
  -- user-defined: optionnal output latency
  constant pkg_SYNC_OUT_LATENCY                    : natural  := 0;
  -- auto-computed: minimum latency of the "sync_top" module.
  --    IMPORTANT: cross clock domain latency is not taken into account
  constant pkg_SYNC_TOP_LATENCY                    : natural  := pkg_SYNC_DYNAMIC_SHIFT_REGISTER_LATENCY + pkg_SYNC_PULSE_GENERATOR_LATENCY + pkg_SYNC_FIFO_READ_LATENCY + pkg_SYNC_OUT_LATENCY;

  -------------------------------------------------------------------
  -- IOs
  -------------------------------------------------------------------
  -- user-defined: add latency after the input IOs. Possible values: [0;max integer value[
  constant pkg_IO_ADC_LATENCY  : natural := 1;
  -- user-defined: add latency before the output IOs. Possible values: [0;max integer value[
  constant pkg_IO_DAC_LATENCY  : natural := 1;
  -- user-defined: add latency before the output IOs. Possible values: [0;max integer value[
  constant pkg_IO_SYNC_LATENCY : natural := 1;

  ---------------------------------------------------------------------
  -- Recording
  ---------------------------------------------------------------------
  -- user-defined: number of 32 bit-words in the output FIFO (must be a multiple of the usb3 minimum packet size)
  constant pkg_REC_ADC_FIFO_OUT_DEPTH : integer := 16384;

END pkg_fpasim;

