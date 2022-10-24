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
--!   @file                   tb_tes_top.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use IEEE.std_logic_textio.all;

--library std;  -- @suppress "Superfluous library clause: access to library 'std' is implicit"
--use std.textio.all;

library fpasim;
use fpasim.pkg_fpasim.all;

library opal_kelly_lib;
use opal_kelly_lib.pkg_front_panel;

library vunit_lib;
context vunit_lib.vunit_context;

library csv_lib;
use csv_lib.pkg_csv_file;

library utility_lib;
context utility_lib.utility_context;

entity tb_tes_top is
  generic(

    runner_cfg : string := runner_cfg_default;  -- don't touch
    output_path: string:= "C:/Project/fpasim-fw-hardware/";
    ---------------------------------------------------------------------
    -- User generic
    ---------------------------------------------------------------------
    -- pixel
    g_PIXEL_LENGTH_WIDTH         : positive := 6;  -- bus width in order to define the number of samples by pixel
    g_PIXEL_ID_WIDTH             : positive := pkg_PIXEL_ID_WIDTH_MAX;  -- pixel id bus width (expressed in bits). Possible values [1;max integer value[
    -- frame
    g_FRAME_LENGTH_WIDTH         : positive := 11;  -- bus width in order to define the number of samples by frame
    g_FRAME_ID_WIDTH             : positive := pkg_FRAME_ID_WIDTH;  -- frame id bus width (expressed in bits). Possible values [1;max integer value[
    -- addr
    g_PULSE_SHAPE_RAM_ADDR_WIDTH : positive := pkg_TES_PULSE_SHAPE_RAM_ADDR_WIDTH;  -- address bus width (expressed in bits)
    -- output
    g_PIXEL_RESULT_OUTPUT_WIDTH  : positive := pkg_TES_MULT_SUB_Q_WIDTH_S;

    ---------------------------------------------------------------------
    -- simulation parameter
    ---------------------------------------------------------------------
    g_VUNIT_DEBUG  : boolean := true;
    g_TEST_NAME    : string  := "";
    g_ENABLE_CHECK : boolean := true;
    g_ENABLE_LOG   : boolean := true
    );
end tb_tes_top;

architecture simulate of tb_tes_top is

   constant c_INPUT_BASEPATH : string := output_path&"inputs/";
   constant c_OUTPUT_BASEPATH : string := output_path&"outputs/";

  ---------------------------------------------------------------------
  -- module input signals
  ---------------------------------------------------------------------
  signal i_clk                     : std_logic;
  signal i_rst                     : std_logic;
  signal i_rst_status              : std_logic;
  signal i_debug_pulse             : std_logic;

  -- input command: from the regdecode
  ---------------------------------------------------------------------
  signal i_en                      : std_logic;
  signal i_pixel_length            : std_logic_vector(g_PIXEL_LENGTH_WIDTH - 1 downto 0);
  signal i_frame_length            : std_logic_vector(g_FRAME_LENGTH_WIDTH - 1 downto 0);
  -- command
  signal i_cmd_valid               : std_logic;
  signal i_cmd_pulse_height        : std_logic_vector(10 downto 0);
  signal i_cmd_pixel_id            : std_logic_vector(g_PIXEL_ID_WIDTH - 1 downto 0);
  signal i_cmd_time_shift          : std_logic_vector(3 downto 0);
  -- RAM: pulse shape
  -- wr
  signal i_pulse_shape_wr_en       : std_logic;
  signal i_pulse_shape_wr_rd_addr  : std_logic_vector(g_PULSE_SHAPE_RAM_ADDR_WIDTH - 1 downto 0);
  signal i_pulse_shape_wr_data     : std_logic_vector(15 downto 0);
  -- rd
  signal i_pulse_shape_rd_en       : std_logic;
  signal o_pulse_shape_rd_valid    : std_logic;
  signal o_pulse_shape_rd_data     : std_logic_vector(15 downto 0);
  -- RAM:
  -- wr
  signal i_steady_state_wr_en      : std_logic;
  signal i_steady_state_wr_rd_addr : std_logic_vector(g_PIXEL_ID_WIDTH - 1 downto 0);
  signal i_steady_state_wr_data    : std_logic_vector(15 downto 0);
  -- rd
  signal i_steady_state_rd_en      : std_logic;
  signal o_steady_state_rd_valid   : std_logic;
  signal o_steady_state_rd_data    : std_logic_vector(15 downto 0);

  -- from the adc
  ---------------------------------------------------------------------
  signal i_data_valid              : std_logic;

  -- output
  ---------------------------------------------------------------------
  signal o_pixel_sof               : std_logic;
  signal o_pixel_eof               : std_logic;
  signal o_pixel_valid             : std_logic;
  signal o_pixel_id                : std_logic_vector(g_PIXEL_ID_WIDTH - 1 downto 0);
  signal o_pixel_result            : std_logic_vector(g_PIXEL_RESULT_OUTPUT_WIDTH - 1 downto 0);
  signal o_frame_sof               : std_logic;
  signal o_frame_eof               : std_logic;
  signal o_frame_id                : std_logic_vector(g_FRAME_ID_WIDTH - 1 downto 0);

  -- errors/status
  ---------------------------------------------------------------------
  signal o_errors                  : std_logic_vector(15 downto 0);
  signal o_status                  : std_logic_vector(7 downto 0);

  ---------------------------------------------------------------------
  -- Clock definition
  ---------------------------------------------------------------------
  constant c_CLK_PERIOD0    : time := 4 ns;

   ---------------------------------------------------------------------
  -- Generate reading sequence
  ---------------------------------------------------------------------
  -- Cmd
  signal reg_rd_valid       : std_logic := '0';
  signal i_reg_start_data : std_logic := '0';
  signal reg_gen_finish     : std_logic := '0';
  signal reg_data_valid     : std_logic;

  -- Cmd
  signal cmd_rd_valid       : std_logic := '0';
  signal cmd_start_data_inp : std_logic := '0';
  signal cmd_gen_finish     : std_logic := '0';
  signal cmd_data_valid     : std_logic;


  -- ADC
  signal data_rd_valid          : std_logic := '0';
  signal data_start_inp         : std_logic := '0';
  signal data_gen_finish        : std_logic := '0';
  signal data_count_in          : std_logic_vector(31 downto 0);
  signal data_count_overflow_in : std_logic;

  -- check
  signal data_count_out          : std_logic_vector(31 downto 0);
  signal data_count_overflow_out : std_logic;
  signal data_error_out          : std_logic_vector(1 downto 0);


  ---------------------------------------------------------------------
  -- filepath definition
  ---------------------------------------------------------------------
  constant c_CSV_SEPARATOR             : character := ';';
  constant c_PY_FILENAME_SUFFIX        : string    := "py_";
  constant c_MATLAB_FILENAME_SUFFIX    : string    := "matlab_";
  constant c_MATLAB_PY_FILENAME_SUFFIX : string    := "matlab_py_";
  constant c_VHDL_FILENAME_SUFFIX      : string    := "vhdl_";


  -- input register generation
  constant c_FILENAME_VALID_REG_IN : string := c_PY_FILENAME_SUFFIX & "valid_sequencer_reg_in.csv";
  constant c_FILEPATH_VALID_REG_IN : string := c_INPUT_BASEPATH & c_FILENAME_VALID_REG_IN;

  constant c_FILENAME_REG_IN : string := c_PY_FILENAME_SUFFIX & "register_sequence_in.csv";
  constant c_FILEPATH_REG_IN : string := c_INPUT_BASEPATH & c_FILENAME_REG_IN;

  -- input cmd generation
  constant c_FILENAME_VALID_CMD_IN : string := c_PY_FILENAME_SUFFIX & "valid_sequencer_reg_in.csv";
  constant c_FILEPATH_VALID_CMD_IN : string := c_INPUT_BASEPATH & c_FILENAME_VALID_CMD_IN;

  constant c_FILENAME_CMD_IN : string := c_PY_FILENAME_SUFFIX & "register_sequence_in.csv";
  constant c_FILEPATH_CMD_IN : string := c_INPUT_BASEPATH & c_FILENAME_CMD_IN;


---- input data generation
--  constant c_FILENAME_VALID_DATA_IN : string := c_PY_FILENAME_SUFFIX & "valid_sequencer_data_in.csv";
--  constant c_FILEPATH_VALID_DATA_IN : string := c_INPUT_BASEPATH & c_FILENAME_VALID_DATA_IN;

--  constant c_FILENAME_DATA_IN : string := c_MATLAB_FILENAME_SUFFIX & "data_in.csv";
--  constant c_FILEPATH_DATA_IN : string := c_INPUT_BASEPATH & c_FILENAME_DATA_IN;

--  -- output data log
--  constant c_FILENAME_DATA_OUT : string := c_VHDL_FILENAME_SUFFIX & "data_out.csv";
--  constant c_FILEPATH_DATA_OUT : string := c_OUTPUT_BASEPATH & c_FILENAME_DATA_OUT;

--  -- check output data
--  constant c_FILENAME_DATA_OUT_REF : string := c_MATLAB_FILENAME_SUFFIX & "data_out_ref.csv";
--  constant c_FILEPATH_DATA_OUT_REF : string := c_INPUT_BASEPATH & c_FILENAME_DATA_OUT_REF;

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

  ---------------------------------------------------------------------
  -- master fsm
  ---------------------------------------------------------------------
  p_master_fsm : process is

  variable val_v : integer := 0;

  begin
    if runner_cfg'length > 0 then
      test_runner_setup(runner, runner_cfg);
    end if;

    ---------------------------------------------------------------------
    -- VUNIT - Scoreboard object : Visibility definition
    ---------------------------------------------------------------------
    if g_VUNIT_DEBUG = true then
      -- the simulator doesn't stop on errors
      set_stop_level(failure);
    end if;
    --show(get_logger("check:data_I"), display_handler, pass); 
    --show(get_logger("check:data_Q"), display_handler, pass); 
    show(get_logger("check:errors"), display_handler, pass);
    show(get_logger("log:sim"), display_handler, pass);
    show(get_logger("check"), display_handler, pass);
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    info("c_INPUT_BASEPATH = "&c_INPUT_BASEPATH);
    info("c_OUTPUT_BASEPATH = "&c_OUTPUT_BASEPATH);
    info("c_FILEPATH_VALID_REG_IN = "&c_FILEPATH_VALID_REG_IN);
    info("g_TEST_NAME = "&g_TEST_NAME);
    info("output_path = "&output_path);
    
    ---------------------------------------------------------------------
    -- initial reset
    ---------------------------------------------------------------------
    info("Enable the reset");
    i_rst <= '1';
    i_rst_status <= '1';
    i_debug_pulse <= '0';
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    info("Disable the reset");
    i_rst <= '0';
    i_rst_status <= '0';
    i_debug_pulse <= '0';
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    ---------------------------------------------------------------------
    -- generate register values
    ---------------------------------------------------------------------
    info("Start Register configuration");
    i_reg_start_data <= '1';
    -- wait until all data from the input file are read
    --wait until reg_gen_finish = '1';
    -- set timeout for the vunit.watchdog
    --set_timeout(runner, 2 ms);

    ---------------------------------------------------------------------
    -- generate commands
    ---------------------------------------------------------------------
    info("Start command configuration");
    cmd_start_data_inp <= '1';
    -- wait until all data from the input file are read
    --wait until cmd_gen_finish = '1';



    ---------------------------------------------------------------------
    -- Ending the simulation
    ---------------------------------------------------------------------
    -- to allow some time for completion
    info("Wait end of simulation");
    wait for 4096*c_CLK_PERIOD0;      
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    ---------------------------------------------------------------------
    -- VUNIT - checking errors and summary
    ---------------------------------------------------------------------
    -- errors checking
    info("Check results:");
    val_v := to_integer(unsigned(o_errors));
    check_equal(CHECKER_ERRORS_c, 0, val_v, result("checker output errors"));

    -- summary
    info(LOGGER_SUMMARY_c, "===Summary==="
         & LF & "CHECKER_DATA_I_c: " & to_string(get_checker_stat(CHECKER_DATA_I_c))
         & LF & "CHECKER_DATA_Q_c: " & to_string(get_checker_stat(CHECKER_DATA_Q_c))
         & LF & "CHECKER_ERRORS_c: " & to_string(get_checker_stat(CHECKER_ERRORS_c))
         --& LF & "CHECKER_DATA_COUNT_c: " & to_string(get_checker_stat(CHECKER_DATA_COUNT_c))
         );

    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    if runner_cfg'length > 0 then
      test_runner_cleanup(runner);      -- Simulation ends here
    else
      std.env.stop;
    end if;
  end process;

--test_runner_watchdog(runner, 10 ms);
---------------------------------------------------------------------
-- register input - valid sequence
---------------------------------------------------------------------
--  reg_valid_sequence : valid_sequencer(
--    i_clk => i_clk,
--    i_en  => i_reg_start_data,

--    ---------------------------------------------------------------------
--    -- input file
--    ---------------------------------------------------------------------
--    i_filepath      => c_FILEPATH_VALID_REG_IN,
--    i_csv_separator => c_CSV_SEPARATOR,

--    ---------------------------------------------------------------------
--    -- command
--    ---------------------------------------------------------------------
--    o_valid => reg_rd_valid
--    );


-----------------------------------------------------------------------
---- register input - data generation
-----------------------------------------------------------------------
--  gen_reg : if true generate
--    signal sig_vect : std_logic_vector(0 downto 0);
--  begin
--    inst_reg_data_generator : data_generator3(
--      i_clk   => i_clk,
--      i_start => i_reg_start_data,

--      ---------------------------------------------------------------------
--      -- input file
--      ---------------------------------------------------------------------
--      i_filepath         => c_FILEPATH_REG_IN,
--      i_csv_separator    => c_CSV_SEPARATOR,
--      --  common typ = "UINT" => the file integer value is converted into an unsigned vector -> std_logic_vector
--      --  common typ = "INT" => the file integer value  is converted into a signed vector -> std_logic_vector
--      --  common typ = "HEX" => the hexadecimal value is converted into a std_logic_vector
--      --  common typ = "STD_VEC" (binary value) => the std_logic_vector is not converted
--      i_DATA0_COMMON_TYP => "UINT",
--      i_DATA1_COMMON_TYP => "UINT",
--      i_DATA2_COMMON_TYP => "UINT",

--      ---------------------------------------------------------------------
--      -- command
--      ---------------------------------------------------------------------
--      i_ready           => reg_rd_valid,
--      o_data_valid     => reg_data_valid,  -- not connected
--      o_data0_std_vect => sig_vect,
--      o_data1_std_vect => i_pixel_length,
--      o_data2_std_vect => i_frame_length,

--      ---------------------------------------------------------------------
--      -- status
--      ---------------------------------------------------------------------
--      o_finish => reg_gen_finish
--      );
--    i_en <= sig_vect(0);
--  end generate gen_reg;


-----------------------------------------------------------------------
---- cmd input - valid sequence
-----------------------------------------------------------------------
--  cmd_valid_sequence : valid_sequencer(
--    i_clk => i_clk,
--    i_en  => cmd_start_data_inp,

--    ---------------------------------------------------------------------
--    -- input file
--    ---------------------------------------------------------------------
--    i_filepath      => c_FILEPATH_VALID_CMD_IN,
--    i_csv_separator => c_CSV_SEPARATOR,

--    ---------------------------------------------------------------------
--    -- command
--    ---------------------------------------------------------------------
--    o_valid => cmd_rd_valid
--    );


-----------------------------------------------------------------------
---- cmd input - data generation
-----------------------------------------------------------------------
--  gen_cmd : if true generate
    
--  begin
--    inst_cmd_data_generator : data_generator3(
--      i_clk   => i_clk,
--      i_start => cmd_start_data_inp,

--      ---------------------------------------------------------------------
--      -- input file
--      ---------------------------------------------------------------------
--      i_filepath         => c_FILEPATH_CMD_IN,
--      i_csv_separator    => c_CSV_SEPARATOR,
--      --  common typ = "UINT" => the file integer value is converted into an unsigned vector -> std_logic_vector
--      --  common typ = "INT" => the file integer value  is converted into a signed vector -> std_logic_vector
--      --  common typ = "HEX" => the hexadecimal value is converted into a std_logic_vector
--      --  common typ = "STD_VEC" (binary value) => the std_logic_vector is not converted
--      i_DATA0_COMMON_TYP => "UINT",
--      i_DATA1_COMMON_TYP => "UINT",
--      i_DATA2_COMMON_TYP => "UINT",

--      ---------------------------------------------------------------------
--      -- command
--      ---------------------------------------------------------------------
--      i_ready           => cmd_rd_valid,
--      o_data_valid     => i_cmd_valid, 
--      o_data0_std_vect => i_cmd_pulse_height,
--      o_data1_std_vect => i_cmd_pixel_id,
--      o_data2_std_vect => i_cmd_time_shift,

--      ---------------------------------------------------------------------
--      -- status
--      ---------------------------------------------------------------------
--      o_finish => cmd_gen_finish
--      );

--  end generate gen_cmd;


---------------------------------------------------------------------
-- DUT
---------------------------------------------------------------------
  inst_tes_top : entity fpasim.tes_top
    generic map(
      -- pixel
      g_PIXEL_LENGTH_WIDTH         => g_PIXEL_LENGTH_WIDTH,  -- bus width in order to define the number of samples by pixel
      g_PIXEL_ID_WIDTH             => g_PIXEL_ID_WIDTH,  -- pixel id bus width (expressed in bits). Possible values [1;max integer value[
      -- frame
      g_FRAME_LENGTH_WIDTH         => g_FRAME_LENGTH_WIDTH,  -- bus width in order to define the number of samples by frame
      g_FRAME_ID_WIDTH             => g_FRAME_ID_WIDTH,  -- frame id bus width (expressed in bits). Possible values [1;max integer value[
      -- addr
      g_PULSE_SHAPE_RAM_ADDR_WIDTH => g_PULSE_SHAPE_RAM_ADDR_WIDTH,  -- address bus width (expressed in bits)
      -- output
      g_PIXEL_RESULT_OUTPUT_WIDTH  => g_PIXEL_RESULT_OUTPUT_WIDTH  -- pixel output result bus width (expressed in bit). Possible values [1;max integer value[
      )
    port map(
      i_clk                     => i_clk,          -- clock signal
      i_rst                     => i_rst,          -- reset signal
      i_rst_status              => i_rst_status,   -- reset error flag(s)
      i_debug_pulse             => i_debug_pulse,  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
      ---------------------------------------------------------------------
      -- input command: from the regdecode
      ---------------------------------------------------------------------
      i_en                      => i_en,           -- enable
      i_pixel_length            => i_pixel_length,
      i_frame_length            => i_frame_length,
      -- command
      i_cmd_valid               => i_cmd_valid,    -- valid command
      i_cmd_pulse_height        => i_cmd_pulse_height,  -- pulse height command
      i_cmd_pixel_id            => i_cmd_pixel_id,      -- pixel id command
      i_cmd_time_shift          => i_cmd_time_shift,    -- time shift command
      -- RAM: pulse shape
      -- wr
      i_pulse_shape_wr_en       => i_pulse_shape_wr_en,  -- write enable
      i_pulse_shape_wr_rd_addr  => i_pulse_shape_wr_rd_addr,   -- write address
      i_pulse_shape_wr_data     => i_pulse_shape_wr_data,    -- write data
      -- rd
      i_pulse_shape_rd_en       => i_pulse_shape_rd_en,  -- rd enable
      o_pulse_shape_rd_valid    => o_pulse_shape_rd_valid,   -- rd data valid
      o_pulse_shape_rd_data     => o_pulse_shape_rd_data,    -- rd data
      -- RAM:
      -- wr
      i_steady_state_wr_en      => i_steady_state_wr_en,     -- write enable
      i_steady_state_wr_rd_addr => i_steady_state_wr_rd_addr,  -- write address
      i_steady_state_wr_data    => i_steady_state_wr_data,   -- write data
      -- rd
      i_steady_state_rd_en      => i_steady_state_rd_en,     -- rd enable
      o_steady_state_rd_valid   => o_steady_state_rd_valid,  -- rd data valid
      o_steady_state_rd_data    => o_steady_state_rd_data,   -- read data
      ---------------------------------------------------------------------
      -- from the adc
      ---------------------------------------------------------------------
      i_data_valid              => i_data_valid,   --  input valid data
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_pixel_sof               => o_pixel_sof,    -- first pixel sample
      o_pixel_eof               => o_pixel_eof,    -- last pixel sample
      o_pixel_valid             => o_pixel_valid,  -- valid pixel sample
      o_pixel_id                => o_pixel_id,     -- output pixel id
      o_pixel_result            => o_pixel_result,      -- output pixel result
      o_frame_sof               => o_frame_sof,    -- first frame sample
      o_frame_eof               => o_frame_eof,    -- last frame sample
      o_frame_id                => o_frame_id,     -- output frame id
      ---------------------------------------------------------------------
      -- errors/status
      ---------------------------------------------------------------------
      o_errors                  => o_errors,       -- output errors
      o_status                  => o_status        -- output status
      );


end simulate;
