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
--!   @file                   tb_amp_squid_top.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--
-- -------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;

library std;  -- @suppress "Superfluous library clause: access to library 'std' is implicit"
use std.textio.all;

library fpasim;
use fpasim.pkg_fpasim.all;

library opal_kelly_lib;
use opal_kelly_lib.pkg_front_panel;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_amp_squid_top is
  generic(

    runner_cfg                   : string   := runner_cfg_default;  -- don't touch
    input_basepath_g             : string   := "C:/Project/fpasim-fw-hardware/Inputs/";
    output_basepath_g            : string   := "C:/Project/fpasim-fw-hardware/Outputs/";
    ---------------------------------------------------------------------
    -- User generic
    ---------------------------------------------------------------------
    -- pixel
    g_PIXEL_ID_WIDTH              : positive := pkg_PIXEL_ID_WIDTH_MAX;  -- pixel id bus width (expressed in bits). Possible values [1; max integer value[
    -- frame
    g_FRAME_ID_WIDTH              : positive := pkg_FRAME_ID_WIDTH;  -- frame id bus width (expressed in bits). Possible values [1; max integer value[
    -- address        
    g_AMP_SQUID_TF_RAM_ADDR_WIDTH : positive := pkg_AMP_SQUID_TF_RAM_ADDR_WIDTH;  -- address bus width (expressed in bits)
    -- computation 
    g_PIXEL_RESULT_INPUT_WIDTH    : positive := pkg_MUX_SQUID_ADD_Q_WIDTH_S;  -- pixel input result bus width (expressed in bits). Possible values [1; max integer value[
    g_PIXEL_RESULT_OUTPUT_WIDTH   : positive := pkg_AMP_SQUID_MULT_Q_WIDTH;

    ---------------------------------------------------------------------
    -- simulation parameter
    ---------------------------------------------------------------------
    VUNIT_DEBUG_g  : boolean := true;
    TEST_NAME_g    : string  := "";
    ENABLE_CHECK_g : boolean := true;
    ENABLE_LOG_g   : boolean := true
    );
end tb_amp_squid_top;

architecture simulate of tb_amp_squid_top is

  ---------------------------------------------------------------------
  -- module input signals
  ---------------------------------------------------------------------
  signal i_clk                         : std_logic;
  signal i_rst_status                  : std_logic;
  signal i_debug_pulse                 : std_logic;
  
  -- input command: from the regdecode
  ---------------------------------------------------------------------
  -- RAM: amp_squid_tf
  -- wr
  signal i_amp_squid_tf_wr_en          : std_logic;
  signal i_amp_squid_tf_wr_rd_addr     : std_logic_vector(g_AMP_SQUID_TF_RAM_ADDR_WIDTH - 1 downto 0);
  signal i_amp_squid_tf_wr_data        : std_logic_vector(15 downto 0);
  -- rd
  signal i_amp_squid_tf_rd_en          : std_logic;
  signal o_amp_squid_tf_rd_valid       : std_logic;
  signal o_amp_squid_tf_rd_data        : std_logic_vector(15 downto 0);
  -- gain
  signal i_fpasim_gain                 : std_logic_vector(2 downto 0);

  -- input1
  ---------------------------------------------------------------------
  signal i_pixel_sof                   : std_logic;
  signal i_pixel_eof                   : std_logic;
  signal i_pixel_valid                 : std_logic;
  signal i_pixel_id                    : std_logic_vector(g_PIXEL_ID_WIDTH - 1 downto 0);
  signal i_pixel_result                : std_logic_vector(g_PIXEL_RESULT_INPUT_WIDTH - 1 downto 0);  -- pixel result
  signal i_frame_sof                   : std_logic;
  signal i_frame_eof                   : std_logic;
  signal i_frame_id                    : std_logic_vector(g_FRAME_ID_WIDTH - 1 downto 0);

  -- input2
  ---------------------------------------------------------------------
  signal i_amp_squid_offset_correction : std_logic_vector(13 downto 0);

  -- output
  ---------------------------------------------------------------------
  signal o_pixel_sof                   : std_logic;
  signal o_pixel_eof                   : std_logic;
  signal o_pixel_valid                 : std_logic;
  signal o_pixel_id                    : std_logic_vector(g_PIXEL_ID_WIDTH - 1 downto 0);
  signal o_pixel_result                : std_logic_vector(g_PIXEL_RESULT_OUTPUT_WIDTH - 1 downto 0);  --  pixel result
  signal o_frame_sof                   : std_logic;
  signal o_frame_eof                   : std_logic;
  signal o_frame_id                    : std_logic_vector(g_FRAME_ID_WIDTH - 1 downto 0);

  -- errors/status
  ---------------------------------------------------------------------
  signal o_errors                      : std_logic_vector(15 downto 0);
  signal o_status                      : std_logic_vector(7 downto 0);

  ---------------------------------------------------------------------
  -- Clock definition
  ---------------------------------------------------------------------
  constant c_CLK_PERIOD0 : time := 4 ns;

  ---------------------------------------------------------------------
  -- filepath definition
  ---------------------------------------------------------------------
--  constant c_CSV_SEPARATOR             : character := ';';
--  constant c_PY_FILENAME_SUFFIX        : string    := "py_";
--  constant c_MATLAB_FILENAME_SUFFIX    : string    := "matlab_";
--  constant c_MATLAB_PY_FILENAME_SUFFIX : string    := "matlab_py_";
--  constant c_VHDL_FILENAME_SUFFIX      : string    := "vhdl_";


--  -- input register generation
--  constant c_FILENAME_VALID_REG_IN : string := TEST_NAME_g & c_PY_FILENAME_SUFFIX & "valid_sequencer_reg_in.csv";
--  constant c_FILEPATH_VALID_REG_IN : string := input_basepath_g & c_FILENAME_VALID_REG_IN;

--  constant c_FILENAME_REG_IN : string := TEST_NAME_g & c_PY_FILENAME_SUFFIX & "register_sequence_in.csv";
--  constant c_FILEPATH_REG_IN : string := input_basepath_g & c_FILENAME_REG_IN;

---- input data generation
--  constant c_FILENAME_VALID_DATA_IN : string := TEST_NAME_g & c_PY_FILENAME_SUFFIX & "valid_sequencer_data_in.csv";
--  constant c_FILEPATH_VALID_DATA_IN : string := input_basepath_g & c_FILENAME_VALID_DATA_IN;

--  constant c_FILENAME_DATA_IN : string := TEST_NAME_g & c_MATLAB_FILENAME_SUFFIX & "data_in.csv";
--  constant c_FILEPATH_DATA_IN : string := input_basepath_g & c_FILENAME_DATA_IN;

--  -- output data log
--  constant c_FILENAME_DATA_OUT : string := TEST_NAME_g & c_VHDL_FILENAME_SUFFIX & "data_out.csv";
--  constant c_FILEPATH_DATA_OUT : string := output_basepath_g & c_FILENAME_DATA_OUT;

--  -- check output data
--  constant c_FILENAME_DATA_OUT_REF : string := TEST_NAME_g & c_MATLAB_FILENAME_SUFFIX & "data_out_ref.csv";
--  constant c_FILEPATH_DATA_OUT_REF : string := input_basepath_g & c_FILENAME_DATA_OUT_REF;

  ---------------------------------------------------------------------
  -- VUnit Scoreboard objects
  ---------------------------------------------------------------------
  -- loggers 
  constant LOGGER_SUMMARY_c     : logger_t  := get_logger("log:summary");
  -- checkers
  constant CHECKER_DATA_I_c     : checker_t := new_checker("check:data_I");
  constant CHECKER_DATA_Q_c     : checker_t := new_checker("check:data_Q");
  constant CHECKER_ERRORS_c     : checker_t := new_checker("check:errors");
  constant CHECKER_DATA_COUNT_c : checker_t := new_checker("check:data_count");



begin

  ---------------------------------------------------------------------
  -- Clock generation
  ---------------------------------------------------------------------
  p_i_clk_gen : process is
  begin
    i_clk <= '0';
    wait for c_CLK_PERIOD0/2;
    i_clk <= '1';
    wait for c_CLK_PERIOD0/2;
  end process p_i_clk_gen;

  -- Simulation Process
  sim_process : process is

  begin
    if runner_cfg'length > 0 then
      test_runner_setup(runner, runner_cfg);
    end if;
    wait for 1 ns;



    wait for 10 us;
    if runner_cfg'length > 0 then
      test_runner_cleanup(runner);      -- Simulation ends here
    else
      std.env.stop;
    end if;
  end process;

---------------------------------------------------------------------
-- DUT
---------------------------------------------------------------------
  inst_amp_squid_top : entity fpasim.amp_squid_top
    generic map(
      -- pixel
      g_PIXEL_ID_WIDTH              => g_PIXEL_ID_WIDTH,  -- pixel id bus width (expressed in bits). Possible values [1; max integer value[
      -- frame
      g_FRAME_ID_WIDTH              => g_FRAME_ID_WIDTH,  -- frame id bus width (expressed in bits). Possible values [1; max integer value[
      -- address        
      g_AMP_SQUID_TF_RAM_ADDR_WIDTH => g_AMP_SQUID_TF_RAM_ADDR_WIDTH,  -- address bus width (expressed in bits)
      -- computation 
      g_PIXEL_RESULT_INPUT_WIDTH    => g_PIXEL_RESULT_INPUT_WIDTH,  -- pixel input result bus width (expressed in bits). Possible values [1; max integer value[
      g_PIXEL_RESULT_OUTPUT_WIDTH   => g_PIXEL_RESULT_OUTPUT_WIDTH  -- pixel output bus width (expressed in bits). Possible values [1; max integer value[
      )
    port map(
      i_clk                         => i_clk,          -- clock
      i_rst_status                  => i_rst_status,   -- reset error flag(s)
      i_debug_pulse                 => i_debug_pulse,  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
      ---------------------------------------------------------------------
      -- input command: from the regdecode
      ---------------------------------------------------------------------
      -- RAM: amp_squid_tf
      -- wr
      i_amp_squid_tf_wr_en          => i_amp_squid_tf_wr_en,  -- write enable
      i_amp_squid_tf_wr_rd_addr     => i_amp_squid_tf_wr_rd_addr,  -- write address
      i_amp_squid_tf_wr_data        => i_amp_squid_tf_wr_data,   -- write data
      -- rd
      i_amp_squid_tf_rd_en          => i_amp_squid_tf_rd_en,  -- rd enable
      o_amp_squid_tf_rd_valid       => o_amp_squid_tf_rd_valid,  -- rd data valid
      o_amp_squid_tf_rd_data        => o_amp_squid_tf_rd_data,   -- read data
      -- gain
      i_fpasim_gain                 => i_fpasim_gain,  -- gain value
      ---------------------------------------------------------------------
      -- input1
      ---------------------------------------------------------------------
      i_pixel_sof                   => i_pixel_sof,    -- first pixel sample
      i_pixel_eof                   => i_pixel_eof,    -- last pixel sample
      i_pixel_valid                 => i_pixel_valid,  -- valid pixel sample
      i_pixel_id                    => i_pixel_id,     -- pixel id
      i_pixel_result                => i_pixel_result,    -- pixel result
      i_frame_sof                   => i_frame_sof,    -- first frame sample
      i_frame_eof                   => i_frame_eof,    -- last frame sample
      i_frame_id                    => i_frame_id,     -- frame id
      ---------------------------------------------------------------------
      -- input2
      ---------------------------------------------------------------------
      i_amp_squid_offset_correction => i_amp_squid_offset_correction,  -- amp squid offset value
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_pixel_sof                   => o_pixel_sof,    -- first pixel sample
      o_pixel_eof                   => o_pixel_eof,    -- last pixel sample
      o_pixel_valid                 => o_pixel_valid,  -- valid pixel sample
      o_pixel_id                    => o_pixel_id,     -- pixel id
      o_pixel_result                => o_pixel_result,    -- pixel result
      o_frame_sof                   => o_frame_sof,    -- first frame sample
      o_frame_eof                   => o_frame_eof,    -- last frame sample
      o_frame_id                    => o_frame_id,     -- frame id
      ---------------------------------------------------------------------
      -- errors/status
      ---------------------------------------------------------------------
      o_errors                      => o_errors,       -- output errors
      o_status                      => o_status        -- output status
      );



end simulate;
