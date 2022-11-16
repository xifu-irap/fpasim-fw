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

library fpasim;
use fpasim.pkg_fpasim.all;

library vunit_lib;
context vunit_lib.vunit_context;

library common_lib;
context common_lib.common_context;

entity tb_tes_top is
  generic(
    runner_cfg                   : string   := runner_cfg_default; -- vunit generic: don't touch
    output_path                  : string   := "C:/Project/fpasim-fw-hardware/";-- vunit generic: don't touch
    ---------------------------------------------------------------------
    -- DUT generic
    ---------------------------------------------------------------------
    -- pixel
    g_PIXEL_LENGTH_WIDTH         : positive := 6; -- bus width in order to define the number of samples by pixel
    g_PIXEL_ID_WIDTH             : positive := pkg_PIXEL_ID_WIDTH_MAX; -- pixel id bus width (expressed in bits). Possible values [1;max integer value[
    -- frame
    g_FRAME_LENGTH_WIDTH         : positive := 11; -- bus width in order to define the number of samples by frame
    g_FRAME_ID_WIDTH             : positive := pkg_FRAME_ID_WIDTH; -- frame id bus width (expressed in bits). Possible values [1;max integer value[
    -- addr
    g_PULSE_SHAPE_RAM_ADDR_WIDTH : positive := pkg_TES_PULSE_SHAPE_RAM_ADDR_WIDTH; -- address bus width (expressed in bits)
    -- output
    g_PIXEL_RESULT_OUTPUT_WIDTH  : positive := pkg_TES_MULT_SUB_Q_WIDTH_S;
    
    ---------------------------------------------------------------------
    -- simulation parameters
    ---------------------------------------------------------------------
    g_NB_PIXEL_BY_FRAME          : positive := 1;
    g_NB_FRAME_BY_PULSE          : positive := pkg_FRAME_NB_BY_PULSE;
    
    g_VUNIT_DEBUG                : boolean  := true;
    g_TEST_NAME                  : string   := "";
    g_ENABLE_CHECK               : boolean  := true;
    g_ENABLE_LOG                 : boolean  := true;
    -- RAM1
    g_RAM1_NAME                  : string   := "tes_pulse_shape";
    g_RAM1_CHECK                 : boolean  := true;
    g_RAM1_VERBOSITY             : integer  := 0;
    -- RAM2
    g_RAM2_NAME                  : string   := "tes_steady_state";
    g_RAM2_CHECK                 : boolean  := true;
    g_RAM2_VERBOSITY             : integer  := 0
  );
end tb_tes_top;

architecture simulate of tb_tes_top is

  constant c_INPUT_BASEPATH  : string := output_path & "inputs/";
  constant c_OUTPUT_BASEPATH : string := output_path & "outputs/";

  ---------------------------------------------------------------------
  -- module input signals
  ---------------------------------------------------------------------
  signal i_clk         : std_logic := '0';
  signal i_rst         : std_logic := '0';
  signal i_rst_status  : std_logic := '0';
  signal i_debug_pulse : std_logic := '0';

  -- input command: from the regdecode
  ---------------------------------------------------------------------
  signal i_en                      : std_logic;
  signal i_pixel_length            : std_logic_vector(g_PIXEL_LENGTH_WIDTH - 1 downto 0);
  signal i_pixel_nb                : std_logic_vector(g_PIXEL_ID_WIDTH - 1 downto 0);
  signal i_frame_length            : std_logic_vector(g_FRAME_LENGTH_WIDTH - 1 downto 0);
  -- command
  signal i_cmd_valid               : std_logic;
  signal i_cmd_pulse_height        : std_logic_vector(10 downto 0);
  signal i_cmd_pixel_id            : std_logic_vector(g_PIXEL_ID_WIDTH - 1 downto 0);
  signal i_cmd_time_shift          : std_logic_vector(3 downto 0);
  signal o_cmd_ready          : std_logic;
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
  signal i_data_valid : std_logic;

  -- output
  ---------------------------------------------------------------------
  signal o_pixel_sof    : std_logic;
  signal o_pixel_eof    : std_logic;
  signal o_pixel_valid  : std_logic;
  signal o_pixel_id     : std_logic_vector(g_PIXEL_ID_WIDTH - 1 downto 0);
  signal o_pixel_result : std_logic_vector(g_PIXEL_RESULT_OUTPUT_WIDTH - 1 downto 0);
  signal o_frame_sof    : std_logic;
  signal o_frame_eof    : std_logic;
  signal o_frame_id     : std_logic_vector(g_FRAME_ID_WIDTH - 1 downto 0);

  -- errors/status
  ---------------------------------------------------------------------
  signal o_errors : std_logic_vector(15 downto 0);
  signal o_status : std_logic_vector(7 downto 0);

  ---------------------------------------------------------------------
  -- Clock definition
  ---------------------------------------------------------------------
  constant c_CLK_PERIOD0 : time := 4 ns;

  ---------------------------------------------------------------------
  -- Generate reading sequence
  ---------------------------------------------------------------------
  -- reg
  signal reg_start      : std_logic := '0';
  signal reg_rd_valid   : std_logic := '0';
  signal reg_gen_finish : std_logic := '0';
  signal reg_valid      : std_logic;

  -- Cmd
  signal cmd_start      : std_logic := '0';
  signal cmd_rd_valid   : std_logic := '0';
  signal cmd_gen_finish : std_logic := '0';

  -- data
  signal data_start             : std_logic := '0';
  signal data_rd_valid          : std_logic := '0';
  signal data_gen_finish        : std_logic := '0';
  signal data_valid             : std_logic := '0';
  signal data_count_in          : std_logic_vector(31 downto 0);
  signal data_count_overflow_in : std_logic;

  -- ram tes pulse shape
  signal ram1_wr_start      : std_logic                    := '0';
  signal ram1_rd_start      : std_logic                    := '0';
  signal ram1_rd_valid      : std_logic                    := '0';
  signal ram1_wr_gen_finish : std_logic                    := '0';
  signal ram1_rd_gen_finish : std_logic                    := '0';
  signal ram1_error         : std_logic_vector(0 downto 0) := (others => '0');

  -- ram tes steady state
  signal ram2_wr_start      : std_logic                    := '0';
  signal ram2_rd_start      : std_logic                    := '0';
  signal ram2_rd_valid      : std_logic                    := '0';
  signal ram2_wr_gen_finish : std_logic                    := '0';
  signal ram2_rd_gen_finish : std_logic                    := '0';
  signal ram2_error         : std_logic_vector(0 downto 0) := (others => '0');

  -- check
  signal data_count_out          : std_logic_vector(31 downto 0);
  signal data_count_overflow_out : std_logic;
  signal data_error_out          : std_logic_vector(1 downto 0);

  signal data_stop : std_logic := '0';

  ---------------------------------------------------------------------
  -- filepath definition
  ---------------------------------------------------------------------
  constant c_CSV_SEPARATOR             : character := ';';

  -- input register generation
  constant c_FILENAME_REG_VALID_IN : string := "py_reg_valid_sequencer_in.csv";
  constant c_FILEPATH_REG_VALID_IN : string := c_INPUT_BASEPATH & c_FILENAME_REG_VALID_IN;

  constant c_FILENAME_REG_IN : string := "py_reg_in.csv";
  constant c_FILEPATH_REG_IN : string := c_INPUT_BASEPATH & c_FILENAME_REG_IN;

  -- input cmd generation
  constant c_FILENAME_CMD_VALID_IN : string := "py_cmd_valid_sequencer_in.csv";
  constant c_FILEPATH_CMD_VALID_IN : string := c_INPUT_BASEPATH & c_FILENAME_CMD_VALID_IN;

  constant c_FILENAME_CMD_IN : string := "py_cmd_in.csv";
  constant c_FILEPATH_CMD_IN : string := c_INPUT_BASEPATH & c_FILENAME_CMD_IN;

  -- input data generation
  constant c_FILENAME_DATA_VALID_IN : string := "py_data_valid_sequencer_in.csv";
  constant c_FILEPATH_DATA_VALID_IN : string := c_INPUT_BASEPATH & c_FILENAME_DATA_VALID_IN;

  constant c_FILENAME_DATA_IN : string := "py_data_in.csv";
  constant c_FILEPATH_DATA_IN : string := c_INPUT_BASEPATH & c_FILENAME_DATA_IN;

  -- input ram tes pulse shape
  constant c_FILENAME_RAM1_VALID_IN : string := "py_ram_tes_shape_valid_sequencer_in.csv";
  constant c_FILEPATH_RAM1_VALID_IN : string := c_INPUT_BASEPATH & c_FILENAME_RAM1_VALID_IN;

  constant c_FILENAME_RAM1_IN : string := "py_ram_tes_shape.csv";
  constant c_FILEPATH_RAM1_IN : string := c_INPUT_BASEPATH & c_FILENAME_RAM1_IN;

  -- input ram tes steady state
  constant c_FILENAME_RAM2_VALID_IN : string := "py_ram_tes_steady_state_valid_sequencer_in.csv";
  constant c_FILEPATH_RAM2_VALID_IN : string := c_INPUT_BASEPATH & c_FILENAME_RAM2_VALID_IN;

  constant c_FILENAME_RAM2_IN : string := "py_ram_tes_steady_state.csv";
  constant c_FILEPATH_RAM2_IN : string := c_INPUT_BASEPATH & c_FILENAME_RAM2_IN;

  -- output data log
  constant c_FILENAME_DATA_OUT : string := "vhd_data_out.csv";
  --constant c_FILEPATH_DATA_OUT : string := c_OUTPUT_BASEPATH & c_FILENAME_DATA_OUT;

  ---------------------------------------------------------------------
  -- VUnit Scoreboard objects
  ---------------------------------------------------------------------
  -- loggers 
  constant c_LOGGER_SUMMARY     : logger_t  := get_logger("log:summary");
  -- checkers
  constant c_CHECKER_ERRORS     : checker_t := new_checker("check:errors");
  constant c_CHECKER_DATA_COUNT : checker_t := new_checker("check:data_count");
  constant c_CHECKER_RAM1       : checker_t := new_checker("check:ram1:ram_" & g_RAM1_NAME);
  constant c_CHECKER_RAM2       : checker_t := new_checker("check:ram2:ram_" & g_RAM2_NAME);

begin

  ---------------------------------------------------------------------
  -- Clock generation
  ---------------------------------------------------------------------
  p_i_clk_gen : process is
  begin
    i_clk <= '0';
    wait for c_CLK_PERIOD0 / 2;
    i_clk <= '1';
    wait for c_CLK_PERIOD0 / 2;
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
      -- the simulator doesn't stop on errors => stop on failure
      set_stop_level(failure);
    end if;

    show(get_logger("log:summary"), display_handler, pass);
    show(get_logger("check:data_count"), display_handler, pass);
    show(get_logger("check:errors"), display_handler, pass);
    if g_RAM1_VERBOSITY > 0 then
      show(get_logger("check:ram1"), display_handler, pass);
    end if;
    if g_RAM2_VERBOSITY > 0 then
      show(get_logger("check:ram2"), display_handler, pass);
    end if;
    
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    info("Test bench: Generic parameter values");
    info("    output_path = " & output_path);
    ---------------------------------------------------------------------
    -- DUT GENERIC
    ---------------------------------------------------------------------
    info("    g_PIXEL_LENGTH_WIDTH = " & to_string(g_PIXEL_LENGTH_WIDTH));
    info("    g_PIXEL_ID_WIDTH = " & to_string(g_PIXEL_ID_WIDTH));
    info("    g_FRAME_LENGTH_WIDTH = " & to_string(g_FRAME_LENGTH_WIDTH));
    info("    g_FRAME_ID_WIDTH = " & to_string(g_FRAME_ID_WIDTH));
    info("    g_PULSE_SHAPE_RAM_ADDR_WIDTH = " & to_string(g_PULSE_SHAPE_RAM_ADDR_WIDTH));
    info("    g_PIXEL_RESULT_OUTPUT_WIDTH = " & to_string(g_PIXEL_RESULT_OUTPUT_WIDTH));
    info("    g_NB_PIXEL_BY_FRAME = " & to_string(g_NB_PIXEL_BY_FRAME));
    info("    g_NB_FRAME_BY_PULSE = " & to_string(g_NB_FRAME_BY_PULSE));
    -- simulator paramters
    info("    g_VUNIT_DEBUG = " & to_string(g_VUNIT_DEBUG));
    info("    g_TEST_NAME = " & g_TEST_NAME);
    info("    g_ENABLE_CHECK = " & to_string(g_ENABLE_CHECK));
    info("    g_ENABLE_LOG = " & to_string(g_ENABLE_LOG));
    -- RAM1
    info("    g_RAM1_NAME = " & g_RAM1_NAME);
    info("    g_RAM1_CHECK = " & to_string(g_RAM1_CHECK));
    info("    g_RAM1_VERBOSITY = " & to_string(g_RAM1_VERBOSITY));
    -- RAM2
    info("    g_RAM2_NAME = " & g_RAM2_NAME);
    info("    g_RAM2_CHECK = " & to_string(g_RAM2_CHECK));
    info("    g_RAM2_VERBOSITY = " & to_string(g_RAM2_VERBOSITY));

    info("Test bench: input files");
    info("    c_FILEPATH_REG_VALID_IN = " & c_FILEPATH_REG_VALID_IN);
    info("    c_FILEPATH_REG_IN = " & c_FILEPATH_REG_IN);
    info("    c_FILEPATH_CMD_VALID_IN = " & c_FILEPATH_CMD_VALID_IN);
    info("    c_FILEPATH_CMD_IN = " & c_FILEPATH_CMD_IN);
    info("    c_FILEPATH_DATA_VALID_IN = " & c_FILEPATH_DATA_VALID_IN);
    info("    c_FILEPATH_DATA_IN = " & c_FILEPATH_DATA_IN);
    info("    c_FILEPATH_RAM1_VALID_IN = " & c_FILEPATH_RAM1_VALID_IN);
    info("    c_FILEPATH_RAM1_IN = " & c_FILEPATH_RAM1_IN);
    info("    c_FILEPATH_RAM2_VALID_IN = " & c_FILEPATH_RAM2_VALID_IN);
    info("    c_FILEPATH_RAM2_IN = " & c_FILEPATH_RAM2_IN);

    ---------------------------------------------------------------------
    -- reset
    ---------------------------------------------------------------------
    info("Enable the reset");
    i_rst         <= '1';
    i_rst_status  <= '1';
    i_debug_pulse <= '0';
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    info("Disable the reset");
    i_rst         <= '0';
    i_rst_status  <= '0';
    i_debug_pulse <= '0';
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    ---------------------------------------------------------------------
    -- Register Configuration
    ---------------------------------------------------------------------
    info("Start Register configuration");
    reg_start <= '1';
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    -- wait until all data from the input file are read
    wait until rising_edge(i_clk) and reg_gen_finish = '1';
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    -- set timeout for the vunit.watchdog
    --set_timeout(runner, 2 ms);

    ---------------------------------------------------------------------
    -- RAM1 Configuration
    ---------------------------------------------------------------------
    info("Start RAM configuration (wr): " & g_RAM1_NAME);
    ram1_wr_start <= '1';
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    wait until rising_edge(i_clk) and ram1_wr_gen_finish = '1';
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    ---------------------------------------------------------------------
    -- RAM2 Configuration
    ---------------------------------------------------------------------
    info("Start RAM configuration (wr): " & g_RAM2_NAME);
    ram2_wr_start <= '1';
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    wait until rising_edge(i_clk) and ram2_wr_gen_finish = '1';
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    ---------------------------------------------------------------------
    -- Command Configuration
    ---------------------------------------------------------------------
    info("Start command configuration");
    cmd_start <= '1';
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    wait until rising_edge(i_clk) and cmd_gen_finish = '1';
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    ---------------------------------------------------------------------
    -- Data Generation
    ---------------------------------------------------------------------
    info("Start data Generation");
    data_start <= '1';
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    ---------------------------------------------------------------------
    -- RAM Check: RAM1
    ---------------------------------------------------------------------
    if g_RAM1_CHECK = true then
      info("Start RAM reading: " & g_RAM1_NAME);
      ram1_rd_start <= '1';
      pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
      info("wait RAM reading");
      wait until rising_edge(i_clk) and ram1_rd_gen_finish = '1';
    end if;

    ---------------------------------------------------------------------
    -- RAM Check: RAM2
    ---------------------------------------------------------------------
    if g_RAM2_CHECK = true then
      info("Start RAM reading: " & g_RAM2_NAME);
      ram2_rd_start <= '1';
      pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
      info("wait RAM reading");
      wait until rising_edge(i_clk) and ram2_rd_gen_finish = '1';
    end if;

    ---------------------------------------------------------------------
    -- Wait end of input data generation
    ---------------------------------------------------------------------
    info("wait end of data generation");
    wait until rising_edge(i_clk) and data_gen_finish = '1';
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    ---------------------------------------------------------------------
    -- End of simulation: wait few more clock cycles
    ---------------------------------------------------------------------
    info("Wait end of simulation");
    wait for 4096 * c_CLK_PERIOD0;
    data_stop <= '1';
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    ---------------------------------------------------------------------
    -- VUNIT - checking errors and summary
    ---------------------------------------------------------------------
    -- errors checking
    info("Check results:");
    val_v := to_integer(unsigned(o_errors));

    check_equal(c_CHECKER_ERRORS, 0, val_v, result("checker output errors"));
    check_equal(c_CHECKER_DATA_COUNT, data_count_in, data_count_out, result("checker input/output data count"));

    -- summary
    info(c_LOGGER_SUMMARY, "===Summary===" & LF &
     "c_CHECKER_ERRORS: " & to_string(get_checker_stat(c_CHECKER_ERRORS)) & LF &
     "c_CHECKER_DATA_COUNT: " & to_string(get_checker_stat(c_CHECKER_DATA_COUNT))  & LF &
     "c_CHECKER_RAM1: " & to_string(get_checker_stat(c_CHECKER_RAM1)) & LF &
     "c_CHECKER_RAM2: " & to_string(get_checker_stat(c_CHECKER_RAM2))
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
  -- Input: Register Configuration
  ---------------------------------------------------------------------
  gen_reg : if true generate
    signal sig_vect : std_logic_vector(0 downto 0);

  begin

    -- valid sequence
    ---------------------------------------------------------------------
    inst_pkg_valid_sequencer : pkg_valid_sequencer(
      i_clk           => i_clk,
      i_en            => reg_start,
      ---------------------------------------------------------------------
      -- input file
      ---------------------------------------------------------------------
      i_filepath      => c_FILEPATH_REG_VALID_IN,
      i_csv_separator => c_CSV_SEPARATOR,
      ---------------------------------------------------------------------
      -- command
      ---------------------------------------------------------------------
      o_valid         => reg_rd_valid
    );

    -- data generation
    ---------------------------------------------------------------------
    inst_pkg_data_generator : pkg_data_generator_4(
      i_clk              => i_clk,
      i_start            => reg_start,
      ---------------------------------------------------------------------
      -- input file
      ---------------------------------------------------------------------
      i_filepath         => c_FILEPATH_REG_IN,
      i_csv_separator    => c_CSV_SEPARATOR,
      --  common typ = "UINT" => the file integer value is converted into an unsigned vector -> std_logic_vector
      --  common typ = "INT" => the file integer value  is converted into a signed vector -> std_logic_vector
      --  common typ = "HEX" => the hexadecimal value is converted into a std_logic_vector
      --  common typ = "STD_VEC" (binary value) => the std_logic_vector is not converted
      i_DATA0_COMMON_TYP => "UINT",
      i_DATA1_COMMON_TYP => "UINT",
      i_DATA2_COMMON_TYP => "UINT",
      i_DATA3_COMMON_TYP => "UINT",
      ---------------------------------------------------------------------
      -- command
      ---------------------------------------------------------------------
      i_ready            => reg_rd_valid,
      o_data_valid       => reg_valid,  -- not connected
      o_data0_std_vect   => sig_vect,
      o_data1_std_vect   => i_pixel_length,
      o_data2_std_vect   => i_pixel_nb,
      o_data3_std_vect   => i_frame_length,
      ---------------------------------------------------------------------
      -- status
      ---------------------------------------------------------------------
      o_finish           => reg_gen_finish
    );
    i_en <= sig_vect(0);
  end generate gen_reg;

  ---------------------------------------------------------------------
  -- Input: Command Configuration
  ---------------------------------------------------------------------
  gen_cmd : if true generate
   signal cmd_ready : std_logic;
  begin

    --  valid sequence
    ---------------------------------------------------------------------
    inst_pkg_valid_sequencer : pkg_valid_sequencer(
      i_clk           => i_clk,
      i_en            => cmd_start,
      ---------------------------------------------------------------------
      -- input file
      ---------------------------------------------------------------------
      i_filepath      => c_FILEPATH_CMD_VALID_IN,
      i_csv_separator => c_CSV_SEPARATOR,
      ---------------------------------------------------------------------
      -- command
      ---------------------------------------------------------------------
      o_valid         => cmd_rd_valid
    );
    cmd_ready <= '1' when cmd_rd_valid = '1' and o_cmd_ready = '1' else '0';
    --  data generation
    ---------------------------------------------------------------------
    inst_pkg_data_generator : pkg_data_generator_3(
      i_clk              => i_clk,
      i_start            => cmd_start,
      ---------------------------------------------------------------------
      -- input file
      ---------------------------------------------------------------------
      i_filepath         => c_FILEPATH_CMD_IN,
      i_csv_separator    => c_CSV_SEPARATOR,
      --  common typ = "UINT" => the file integer value is converted into an unsigned vector -> std_logic_vector
      --  common typ = "INT" => the file integer value  is converted into a signed vector -> std_logic_vector
      --  common typ = "HEX" => the hexadecimal value is converted into a std_logic_vector
      --  common typ = "STD_VEC" (binary value) => the std_logic_vector is not converted
      i_DATA0_COMMON_TYP => "UINT",
      i_DATA1_COMMON_TYP => "UINT",
      i_DATA2_COMMON_TYP => "UINT",
      ---------------------------------------------------------------------
      -- command
      ---------------------------------------------------------------------
      i_ready            => cmd_ready,
      o_data_valid       => i_cmd_valid,
      o_data0_std_vect   => i_cmd_pulse_height,
      o_data1_std_vect   => i_cmd_pixel_id,
      o_data2_std_vect   => i_cmd_time_shift,
      ---------------------------------------------------------------------
      -- status
      ---------------------------------------------------------------------
      o_finish           => cmd_gen_finish
    );

  end generate gen_cmd;

  ---------------------------------------------------------------------
  -- Input: RAM1 Configuration
  ---------------------------------------------------------------------
  gen_ram1 : if true generate

  begin

    -- valid sequence
    ---------------------------------------------------------------------
    inst_pkg_valid_sequencer : pkg_valid_sequencer(
      i_clk           => i_clk,
      i_en            => ram1_wr_start,
      ---------------------------------------------------------------------
      -- input file
      ---------------------------------------------------------------------
      i_filepath      => c_FILEPATH_RAM1_VALID_IN,
      i_csv_separator => c_CSV_SEPARATOR,
      ---------------------------------------------------------------------
      -- command
      ---------------------------------------------------------------------
      o_valid         => ram1_rd_valid
    );

    -- Data RAM Generation
    ---------------------------------------------------------------------
    inst_pkg_memory_wr_tdpram_and_check : pkg_memory_wr_tdpram_and_check(
      i_clk                   => i_clk,
      i_start_wr              => ram1_wr_start,
      i_start_rd              => ram1_rd_start,
      ---------------------------------------------------------------------
      -- input file
      ---------------------------------------------------------------------
      i_filepath_wr           => c_FILEPATH_RAM1_IN,
      i_filepath_rd           => c_FILEPATH_RAM1_IN,
      i_csv_separator         => c_CSV_SEPARATOR,
      i_RD_NAME1              => "ram_" & g_RAM1_NAME,
      --  common typ = "UINT" => the file integer value is converted into an unsigned vector -> std_logic_vector
      --  common typ = "INT" => the file integer value  is converted into a signed vector -> std_logic_vector
      --  common typ = "HEX" => the hexadecimal value is converted into a std_logic_vector
      --  common typ = "STD_VEC" (binary value) => the std_logic_vector is not converted
      i_WR_RD_ADDR_COMMON_TYP => "UINT",
      i_WR_DATA_COMMON_TYP    => "UINT",
      i_RD_DATA_COMMON_TYP    => "UINT",
      ---------------------------------------------------------------------
      -- Vunit Scoreboard objects
      ---------------------------------------------------------------------
      i_data_sb               => c_CHECKER_RAM1,
      i_rd_ready              => ram1_rd_valid,
      i_wr_ready              => ram1_rd_valid,
      ---------------------------------------------------------------------
      -- command
      ---------------------------------------------------------------------
      o_wr_data_valid         => i_pulse_shape_wr_en,
      o_rd_data_valid         => i_pulse_shape_rd_en,
      o_wr_rd_addr_vect       => i_pulse_shape_wr_rd_addr,
      o_wr_data_vect          => i_pulse_shape_wr_data,
      -- read value
      i_rd_data_valid         => o_pulse_shape_rd_valid,
      i_rd_data_vect          => o_pulse_shape_rd_data,
      ---------------------------------------------------------------------
      -- status
      ---------------------------------------------------------------------
      o_wr_finish             => ram1_wr_gen_finish,
      o_rd_finish             => ram1_rd_gen_finish,
      o_error                 => ram1_error
    );

  end generate gen_ram1;

  ---------------------------------------------------------------------
  -- Input: RAM2 Configuration
  ---------------------------------------------------------------------
  gen_ram2 : if true generate

  begin

    -- valid sequence generation
    ---------------------------------------------------------------------
    inst_pkg_valid_sequencer : pkg_valid_sequencer(
      i_clk           => i_clk,
      i_en            => ram2_wr_start,
      ---------------------------------------------------------------------
      -- input file
      ---------------------------------------------------------------------
      i_filepath      => c_FILEPATH_RAM2_VALID_IN,
      i_csv_separator => c_CSV_SEPARATOR,
      ---------------------------------------------------------------------
      -- command
      ---------------------------------------------------------------------
      o_valid         => ram2_rd_valid
    );

    -- Data RAM generation
    ---------------------------------------------------------------------
    inst_pkg_memory_wr_tdpram_and_check : pkg_memory_wr_tdpram_and_check(
      i_clk                   => i_clk,
      i_start_wr              => ram2_wr_start,
      i_start_rd              => ram2_rd_start,
      ---------------------------------------------------------------------
      -- input file
      ---------------------------------------------------------------------
      i_filepath_wr           => c_FILEPATH_RAM2_IN,
      i_filepath_rd           => c_FILEPATH_RAM2_IN,
      i_csv_separator         => c_CSV_SEPARATOR,
      i_RD_NAME1              => "ram_" & g_RAM2_NAME,
      --  common typ = "UINT" => the file integer value is converted into an unsigned vector -> std_logic_vector
      --  common typ = "INT" => the file integer value  is converted into a signed vector -> std_logic_vector
      --  common typ = "HEX" => the hexadecimal value is converted into a std_logic_vector
      --  common typ = "STD_VEC" (binary value) => the std_logic_vector is not converted
      i_WR_RD_ADDR_COMMON_TYP => "UINT",
      i_WR_DATA_COMMON_TYP    => "UINT",
      i_RD_DATA_COMMON_TYP    => "UINT",
      ---------------------------------------------------------------------
      -- Vunit Scoreboard objects
      ---------------------------------------------------------------------
      i_data_sb               => c_CHECKER_RAM2,
      i_rd_ready              => ram2_rd_valid,
      i_wr_ready              => ram2_rd_valid,
      ---------------------------------------------------------------------
      -- command
      ---------------------------------------------------------------------
      o_wr_data_valid         => i_steady_state_wr_en,
      o_rd_data_valid         => i_steady_state_rd_en,
      o_wr_rd_addr_vect       => i_steady_state_wr_rd_addr,
      o_wr_data_vect          => i_steady_state_wr_data,
      -- read value
      i_rd_data_valid         => o_steady_state_rd_valid,
      i_rd_data_vect          => o_steady_state_rd_data,
      ---------------------------------------------------------------------
      -- status
      ---------------------------------------------------------------------
      o_wr_finish             => ram2_wr_gen_finish,
      o_rd_finish             => ram2_rd_gen_finish,
      o_error                 => ram2_error
    );

  end generate gen_ram2;

  ---------------------------------------------------------------------
  -- Input: data generation
  ---------------------------------------------------------------------
  gen_data : if true generate
    signal vect_tmp : std_logic_vector(0 downto 0);
  begin

    -- valid sequence generation
    ---------------------------------------------------------------------
    inst_pkg_valid_sequencer : pkg_valid_sequencer(
      i_clk           => i_clk,
      i_en            => data_start,
      ---------------------------------------------------------------------
      -- input file
      ---------------------------------------------------------------------
      i_filepath      => c_FILEPATH_DATA_VALID_IN,
      i_csv_separator => c_CSV_SEPARATOR,
      ---------------------------------------------------------------------
      -- command
      ---------------------------------------------------------------------
      o_valid         => data_rd_valid
    );

    -- data generation
    ---------------------------------------------------------------------
    inst_pkg_data_generator : pkg_data_generator_1(
      i_clk              => i_clk,
      i_start            => data_start,
      ---------------------------------------------------------------------
      -- input file
      ---------------------------------------------------------------------
      i_filepath         => c_FILEPATH_DATA_IN,
      i_csv_separator    => c_CSV_SEPARATOR,
      --  common typ = "UINT" => the file integer value is converted into an unsigned vector -> std_logic_vector
      --  common typ = "INT" => the file integer value  is converted into a signed vector -> std_logic_vector
      --  common typ = "HEX" => the hexadecimal value is converted into a std_logic_vector
      --  common typ = "STD_VEC" (binary value) => the std_logic_vector is not converted
      i_DATA0_COMMON_TYP => "UINT",
      ---------------------------------------------------------------------
      -- command
      ---------------------------------------------------------------------
      i_ready            => data_rd_valid,
      o_data_valid       => data_valid,
      o_data0_std_vect   => vect_tmp,   -- not connected

      ---------------------------------------------------------------------
      -- status
      ---------------------------------------------------------------------
      o_finish           => data_gen_finish
    );

    i_data_valid <= data_valid;

    -- count input data
    ---------------------------------------------------------------------
    inst_pkg_data_valid_counter_in : pkg_data_valid_counter(
      i_clk        => i_clk,
      -- input
      i_start      => data_start,
      i_data_valid => data_valid,
      -- output
      o_count      => data_count_in,
      o_overflow   => data_count_overflow_in
    );

  end generate gen_data;

  ---------------------------------------------------------------------
  -- DUT
  ---------------------------------------------------------------------
  inst_dut_tes_top : entity fpasim.tes_top
    generic map(
      -- pixel
      g_PIXEL_LENGTH_WIDTH         => g_PIXEL_LENGTH_WIDTH, -- bus width in order to define the number of samples by pixel
      g_PIXEL_ID_WIDTH             => o_pixel_id'length, -- pixel id bus width (expressed in bits). Possible values [1;max integer value[
      -- frame
      g_FRAME_LENGTH_WIDTH         => g_FRAME_LENGTH_WIDTH, -- bus width in order to define the number of samples by frame
      g_FRAME_ID_WIDTH             => o_frame_id'length, -- frame id bus width (expressed in bits). Possible values [1;max integer value[
      g_FRAME_NB_BY_PULSE          => g_NB_FRAME_BY_PULSE, -- frame id bus width (expressed in bits). Possible values [1;max integer value[
      -- addr
      g_PULSE_SHAPE_RAM_ADDR_WIDTH => g_PULSE_SHAPE_RAM_ADDR_WIDTH, -- address bus width (expressed in bits)
      -- output
      g_PIXEL_RESULT_OUTPUT_WIDTH  => g_PIXEL_RESULT_OUTPUT_WIDTH -- pixel output result bus width (expressed in bit). Possible values [1;max integer value[
    )
    port map(
      i_clk                     => i_clk, -- clock signal
      i_rst                     => i_rst, -- reset signal
      i_rst_status              => i_rst_status, -- reset error flag(s)
      i_debug_pulse             => i_debug_pulse, -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
      ---------------------------------------------------------------------
      -- input command: from the regdecode
      ---------------------------------------------------------------------
      i_en                      => i_en, -- enable
      i_pixel_length            => i_pixel_length,
      i_pixel_nb                => i_pixel_nb,
      i_frame_length            => i_frame_length,
      -- command
      i_cmd_valid               => i_cmd_valid, -- valid command
      i_cmd_pulse_height        => i_cmd_pulse_height, -- pulse height command
      i_cmd_pixel_id            => i_cmd_pixel_id, -- pixel id command
      i_cmd_time_shift          => i_cmd_time_shift, -- time shift command
      o_cmd_ready               => o_cmd_ready,
      -- RAM: pulse shape
      -- wr
      i_pulse_shape_wr_en       => i_pulse_shape_wr_en, -- write enable
      i_pulse_shape_wr_rd_addr  => i_pulse_shape_wr_rd_addr, -- write address
      i_pulse_shape_wr_data     => i_pulse_shape_wr_data, -- write data
      -- rd
      i_pulse_shape_rd_en       => i_pulse_shape_rd_en, -- rd enable
      o_pulse_shape_rd_valid    => o_pulse_shape_rd_valid, -- rd data valid
      o_pulse_shape_rd_data     => o_pulse_shape_rd_data, -- rd data
      -- RAM:
      -- wr
      i_steady_state_wr_en      => i_steady_state_wr_en, -- write enable
      i_steady_state_wr_rd_addr => i_steady_state_wr_rd_addr, -- write address
      i_steady_state_wr_data    => i_steady_state_wr_data, -- write data
      -- rd
      i_steady_state_rd_en      => i_steady_state_rd_en, -- rd enable
      o_steady_state_rd_valid   => o_steady_state_rd_valid, -- rd data valid
      o_steady_state_rd_data    => o_steady_state_rd_data, -- read data
      ---------------------------------------------------------------------
      -- from the adc
      ---------------------------------------------------------------------
      i_data_valid              => i_data_valid, --  input valid data
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_pixel_sof               => o_pixel_sof, -- first pixel sample
      o_pixel_eof               => o_pixel_eof, -- last pixel sample
      o_pixel_valid             => o_pixel_valid, -- valid pixel sample
      o_pixel_id                => o_pixel_id, --  pixel id
      o_pixel_result            => o_pixel_result, --  pixel result
      o_frame_sof               => o_frame_sof, -- first frame sample
      o_frame_eof               => o_frame_eof, -- last frame sample
      o_frame_id                => o_frame_id, --  frame id
      ---------------------------------------------------------------------
      -- errors/status
      ---------------------------------------------------------------------
      o_errors                  => o_errors, -- output errors
      o_status                  => o_status -- output status
    );

  -- count output data
  ---------------------------------------------------------------------
  inst_pkg_data_valid_counter_out : pkg_data_valid_counter(
    i_clk        => i_clk,
    -- input
    i_start      => data_start,
    i_data_valid => o_pixel_valid,
    -- output
    o_count      => data_count_out,
    o_overflow   => data_count_overflow_out
  );

  ---------------------------------------------------------------------
  -- log: data out
  ---------------------------------------------------------------------
  gen_log : if g_ENABLE_LOG = true generate
    signal pixel_sof_vect_tmp : std_logic_vector(0 downto 0);
    signal pixel_eof_vect_tmp : std_logic_vector(0 downto 0);
    signal frame_sof_vect_tmp : std_logic_vector(0 downto 0);
    signal frame_eof_vect_tmp : std_logic_vector(0 downto 0);
  begin
    pixel_sof_vect_tmp(0) <= o_pixel_sof;
    pixel_eof_vect_tmp(0) <= o_pixel_eof;
    frame_sof_vect_tmp(0) <= o_frame_sof;
    frame_eof_vect_tmp(0) <= o_frame_eof;

    gen_log_by_id : for i in 0 to g_NB_PIXEL_BY_FRAME - 1 generate
      constant c_FILEPATH_DATA_OUT : string := c_OUTPUT_BASEPATH & "vhdl_data_out" & to_string(i) & ".csv";
      signal data_valid            : std_logic;
    begin
      data_valid <= o_pixel_valid when to_integer(unsigned(o_pixel_id)) = i else '0';

      inst_pkg_log_data_in_file : pkg_log_data_in_file_7(
        i_clk              => i_clk,
        i_start            => data_start,
        i_stop             => data_stop,
        ---------------------------------------------------------------------
        -- output file
        ---------------------------------------------------------------------
        i_filepath         => c_FILEPATH_DATA_OUT,
        i_csv_separator    => c_CSV_SEPARATOR,
        i_NAME0            => "pixel_sof",
        i_NAME1            => "pixel_eof",
        i_NAME2            => "pixel_id",
        i_NAME3            => "pixel_result",
        i_NAME4            => "frame_sof",
        i_NAME5            => "frame_eof",
        i_NAME6            => "frame_id",
        --  common typ = "UINT" => the std_logic_vector value is converted into unsigned int representation
        --  common typ = "INT" => the std_logic_vector value is converted into signed int representation
        --  common typ = "HEX" => the std_logic_vector value is considered as a signed vector, then it's converted into hex representation
        --  common typ = "UHEX" => the std_logic_vector value is considered as a unsigned vector, then it's converted into hex representation
        --  common typ = "STD_VEC" => the std_logic_vector value is not converted
        i_DATA0_COMMON_TYP => "UINT",
        i_DATA1_COMMON_TYP => "UINT",
        i_DATA2_COMMON_TYP => "UINT",
        i_DATA3_COMMON_TYP => "UINT",
        i_DATA4_COMMON_TYP => "UINT",
        i_DATA5_COMMON_TYP => "UINT",
        i_DATA6_COMMON_TYP => "UINT",
        ---------------------------------------------------------------------
        -- signals to log
        ---------------------------------------------------------------------
        i_data_valid       => data_valid,
        i_data0_std_vect   => pixel_sof_vect_tmp,
        i_data1_std_vect   => pixel_eof_vect_tmp,
        i_data2_std_vect   => o_pixel_id,
        i_data3_std_vect   => o_pixel_result,
        i_data4_std_vect   => frame_sof_vect_tmp,
        i_data5_std_vect   => frame_eof_vect_tmp,
        i_data6_std_vect   => o_frame_id
      );

    end generate gen_log_by_id;

  end generate gen_log;

end simulate;
