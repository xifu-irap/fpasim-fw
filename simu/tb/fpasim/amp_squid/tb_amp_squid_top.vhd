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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fpasim;
use fpasim.pkg_fpasim.all;

library vunit_lib;
context vunit_lib.vunit_context;

library common_lib;
context common_lib.common_context;

entity tb_amp_squid_top is
  generic(
    runner_cfg                    : string   := runner_cfg_default; -- vunit generic: don't touch
    output_path                   : string   := "C:/Project/fpasim-fw-hardware/"; -- vunit generic: don't touch
    ---------------------------------------------------------------------
    -- DUT generic
    ---------------------------------------------------------------------
    -- pixel
    g_PIXEL_ID_WIDTH              : positive := pkg_PIXEL_ID_WIDTH_MAX; -- pixel id bus width (expressed in bits). Possible values: [1; max integer value[
    -- frame
    g_FRAME_ID_WIDTH              : positive := pkg_FRAME_ID_WIDTH; -- frame id bus width (expressed in bits). Possible values: [1; max integer value[
    -- address        
    g_AMP_SQUID_TF_RAM_ADDR_WIDTH : positive := pkg_AMP_SQUID_TF_RAM_ADDR_WIDTH; -- address bus width (expressed in bits)
    -- computation 
    g_PIXEL_RESULT_INPUT_WIDTH    : positive := pkg_MUX_SQUID_ADD_Q_WIDTH_S; -- pixel input result bus width (expressed in bits). Possible values [1; max integer value[
    g_PIXEL_RESULT_OUTPUT_WIDTH   : positive := pkg_AMP_SQUID_MULT_Q_WIDTH;
    ---------------------------------------------------------------------
    -- simulation parameters
    ---------------------------------------------------------------------
    g_NB_PIXEL_BY_FRAME           : positive := 1;
    g_VUNIT_DEBUG                 : boolean  := true;
    g_TEST_NAME                   : string   := "";
    g_ENABLE_CHECK                : boolean  := true;
    g_ENABLE_LOG                  : boolean  := true;
    -- RAM1
    g_RAM1_NAME                   : string   := "amp_squid_tf";
    g_RAM1_CHECK                  : boolean  := true;
    g_RAM1_VERBOSITY              : integer  := 0;
    -- FPAGAIN Register
    g_FPAGAIN                     : integer  := 0
  );
end tb_amp_squid_top;

architecture simulate of tb_amp_squid_top is

  constant c_INPUT_BASEPATH  : string := output_path & "inputs/";
  constant c_OUTPUT_BASEPATH : string := output_path & "outputs/";

  ---------------------------------------------------------------------
  -- module input signals
  ---------------------------------------------------------------------
  signal i_clk         : std_logic := '0';
  signal i_rst_status  : std_logic := '0';
  signal i_debug_pulse : std_logic := '0';

  -- input command: from the regdecode
  ---------------------------------------------------------------------
  -- RAM: amp_squid_tf
  -- wr
  signal i_amp_squid_tf_wr_en      : std_logic;
  signal i_amp_squid_tf_wr_rd_addr : std_logic_vector(g_AMP_SQUID_TF_RAM_ADDR_WIDTH - 1 downto 0);
  signal i_amp_squid_tf_wr_data    : std_logic_vector(15 downto 0);
  -- rd
  signal i_amp_squid_tf_rd_en      : std_logic;
  signal o_amp_squid_tf_rd_valid   : std_logic;
  signal o_amp_squid_tf_rd_data    : std_logic_vector(15 downto 0);
  -- gain
  signal i_fpasim_gain             : std_logic_vector(2 downto 0);

  -- input1
  ---------------------------------------------------------------------
  signal i_pixel_sof    : std_logic;
  signal i_pixel_eof    : std_logic;
  signal i_pixel_valid  : std_logic;
  signal i_pixel_id     : std_logic_vector(g_PIXEL_ID_WIDTH - 1 downto 0);
  signal i_pixel_result : std_logic_vector(g_PIXEL_RESULT_INPUT_WIDTH - 1 downto 0);
  signal i_frame_sof    : std_logic;
  signal i_frame_eof    : std_logic;
  signal i_frame_id     : std_logic_vector(g_FRAME_ID_WIDTH - 1 downto 0);

  -- input2
  ---------------------------------------------------------------------
  signal i_amp_squid_offset_correction : std_logic_vector(13 downto 0);

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
  signal o_status : std_logic_vector(7 downto 0); -- @suppress "signal o_status is never read"

  ---------------------------------------------------------------------
  -- Clock definition
  ---------------------------------------------------------------------
  constant c_CLK_PERIOD0 : time := 4 ns;

  ---------------------------------------------------------------------
  -- Generate reading sequence
  ---------------------------------------------------------------------
  -- data
  signal data_start             : std_logic := '0';
  signal data_rd_valid          : std_logic := '0';
  signal data_gen_finish        : std_logic := '0';
  signal data_valid             : std_logic := '0';
  signal data_count_in          : std_logic_vector(31 downto 0);
  signal data_count_overflow_in : std_logic; -- @suppress "signal data_count_overflow_in is never read"

  -- ram tes pulse shape
  signal ram1_wr_start      : std_logic                    := '0';
  signal ram1_rd_start      : std_logic                    := '0';
  signal ram1_rd_valid      : std_logic                    := '0';
  signal ram1_wr_gen_finish : std_logic                    := '0';
  signal ram1_rd_gen_finish : std_logic                    := '0';
  signal ram1_error         : std_logic_vector(0 downto 0) := (others => '0'); -- @suppress "signal ram1_error is never read"

  -- check
  signal data_count_out          : std_logic_vector(31 downto 0);
  signal data_count_overflow_out : std_logic; -- @suppress "signal data_count_overflow_out is never read"

  signal data_stop : std_logic := '0';
  signal data_out_error : std_logic_vector(0 downto 0);

  ---------------------------------------------------------------------
  -- filepath definition
  ---------------------------------------------------------------------
  constant c_CSV_SEPARATOR : character := ';';

  -- input data generation
  constant c_FILENAME_DATA_VALID_IN : string := "py_data_valid_sequencer_in.csv";
  constant c_FILEPATH_DATA_VALID_IN : string := c_INPUT_BASEPATH & c_FILENAME_DATA_VALID_IN;

  constant c_FILENAME_DATA_IN : string := "py_data_in.csv";
  constant c_FILEPATH_DATA_IN : string := c_INPUT_BASEPATH & c_FILENAME_DATA_IN;

  -- input ram tes pulse shape
  constant c_FILENAME_RAM1_VALID_IN : string := "py_ram_amp_squid_tf_valid_sequencer_in.csv";
  constant c_FILEPATH_RAM1_VALID_IN : string := c_INPUT_BASEPATH & c_FILENAME_RAM1_VALID_IN;

  constant c_FILENAME_RAM1_IN  : string := "py_ram_amp_squid_tf.csv";
  constant c_FILEPATH_RAM1_IN  : string := c_INPUT_BASEPATH & c_FILENAME_RAM1_IN;

  -- output check data
  constant c_FILENAME_CHECK_DATA_OUT : string := "py_check_data_out.csv";
  constant c_FILEPATH_CHECK_DATA_OUT : string := c_INPUT_BASEPATH & c_FILENAME_CHECK_DATA_OUT;

  ---------------------------------------------------------------------
  -- VUnit Scoreboard objects
  ---------------------------------------------------------------------
  -- loggers 
  constant c_LOGGER_SUMMARY     : logger_t  := get_logger("log:summary"); -- @suppress "Expression does not result in a constant"
  -- checkers
  constant c_CHECKER_ERRORS     : checker_t := new_checker("check:errors"); -- @suppress "Expression does not result in a constant"
  constant c_CHECKER_DATA_COUNT : checker_t := new_checker("check:data_count"); -- @suppress "Expression does not result in a constant"
  constant c_CHECKER_RAM1       : checker_t := new_checker("check:ram1:ram_" & g_RAM1_NAME); -- @suppress "Expression does not result in a constant"
  constant c_CHECKER_DATA       : checker_t := new_checker("check:out:data_out"); -- @suppress "Expression does not result in a constant"

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
    if g_VUNIT_DEBUG = true then        -- @suppress "Redundant boolean equality check with true"
      -- the simulator doesn't stop on errors => stop on failure
      set_stop_level(failure);
    end if;

    show(get_logger("log:summary"), display_handler, pass);
    show(get_logger("check:data_count"), display_handler, pass);
    show(get_logger("check:errors"), display_handler, pass);
    if g_RAM1_VERBOSITY > 0 then
      show(get_logger("check:ram1"), display_handler, pass);
    end if;
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    info("Test bench: Generic parameter values");
    info("    output_path = " & output_path);
    ---------------------------------------------------------------------
    -- DUT GENERIC
    ---------------------------------------------------------------------
    info("    g_PIXEL_ID_WIDTH = " & to_string(g_PIXEL_ID_WIDTH));
    info("    g_FRAME_ID_WIDTH = " & to_string(g_FRAME_ID_WIDTH));
    info("    g_AMP_SQUID_TF_RAM_ADDR_WIDTH = " & to_string(g_AMP_SQUID_TF_RAM_ADDR_WIDTH));
    info("    g_PIXEL_RESULT_INPUT_WIDTH = " & to_string(g_PIXEL_RESULT_INPUT_WIDTH));
    info("    g_PIXEL_RESULT_OUTPUT_WIDTH = " & to_string(g_PIXEL_RESULT_OUTPUT_WIDTH));

    -- simulator paramters
    info("    g_VUNIT_DEBUG = " & to_string(g_VUNIT_DEBUG));
    info("    g_TEST_NAME = " & g_TEST_NAME);
    info("    g_ENABLE_CHECK = " & to_string(g_ENABLE_CHECK));
    info("    g_ENABLE_LOG = " & to_string(g_ENABLE_LOG));
    -- RAM1
    info("    g_RAM1_NAME = " & g_RAM1_NAME);
    info("    g_RAM1_CHECK = " & to_string(g_RAM1_CHECK));
    info("    g_RAM1_VERBOSITY = " & to_string(g_RAM1_VERBOSITY));
    info("    g_FPAGAIN = " & to_string(g_FPAGAIN));

    info("Test bench: input files");
    info("    c_FILEPATH_DATA_VALID_IN = " & c_FILEPATH_DATA_VALID_IN);
    info("    c_FILEPATH_DATA_IN = " & c_FILEPATH_DATA_IN);
    info("    c_FILEPATH_RAM1_VALID_IN = " & c_FILEPATH_RAM1_VALID_IN);
    info("    c_FILEPATH_RAM1_IN = " & c_FILEPATH_RAM1_IN);

    ---------------------------------------------------------------------
    -- reset
    ---------------------------------------------------------------------
    i_fpasim_gain <= (others => '0');
    info("Enable the reset");
    i_rst_status  <= '1';
    i_debug_pulse <= '0';
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    info("Disable the reset");
    i_rst_status  <= '0';
    i_debug_pulse <= '0';
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    ---------------------------------------------------------------------
    -- Register configuration
    ---------------------------------------------------------------------
    info("Start Register configuration: FPAGAIN");
    i_fpasim_gain <= std_logic_vector(to_unsigned(g_FPAGAIN, i_fpasim_gain'length));
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    ---------------------------------------------------------------------
    -- RAM1 Configuration
    ---------------------------------------------------------------------
    info("Start RAM configuration (wr): " & g_RAM1_NAME);
    ram1_wr_start <= '1';
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    wait until rising_edge(i_clk) and ram1_wr_gen_finish = '1';
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
    if g_RAM1_CHECK = true then         -- @suppress "Redundant boolean equality check with true"
      info("Start RAM reading: " & g_RAM1_NAME);
      ram1_rd_start <= '1';
      pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
      info("wait RAM reading");
      wait until rising_edge(i_clk) and ram1_rd_gen_finish = '1';
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
     "c_CHECKER_DATA: " & to_string(get_checker_stat(c_CHECKER_DATA)) & LF &
     "c_CHECKER_ERRORS: " & to_string(get_checker_stat(c_CHECKER_ERRORS)) & LF &
     "c_CHECKER_DATA_COUNT: " & to_string(get_checker_stat(c_CHECKER_DATA_COUNT)) & LF &
     "c_CHECKER_RAM1: " & to_string(get_checker_stat(c_CHECKER_RAM1))
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
  -- Input: RAM1 Configuration
  ---------------------------------------------------------------------
  gen_ram1 : if true generate

  begin

    -- valid sequence generation
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
      i_clk             => i_clk,
      i_start_wr        => ram1_wr_start,
      i_start_rd        => ram1_rd_start,
      ---------------------------------------------------------------------
      -- input file
      ---------------------------------------------------------------------
      i_filepath_wr     => c_FILEPATH_RAM1_IN,
      i_filepath_rd     => c_FILEPATH_RAM1_IN,
      i_csv_separator   => c_CSV_SEPARATOR,
      i_RD_NAME1        => "ram_" & g_RAM1_NAME,
      --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
      --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
      --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
      --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
      --  data type = "STD_VEC" => no data convertion before writing in the output file
      i_WR_RD_ADDR_TYP  => "UINT",
      i_WR_DATA_TYP     => "UINT",
      i_RD_DATA_TYP     => "UINT",
      ---------------------------------------------------------------------
      -- Vunit Scoreboard objects
      ---------------------------------------------------------------------
      i_data_sb         => c_CHECKER_RAM1,
      i_rd_ready        => ram1_rd_valid,
      i_wr_ready        => ram1_rd_valid,
      ---------------------------------------------------------------------
      -- command
      ---------------------------------------------------------------------
      o_wr_data_valid   => i_amp_squid_tf_wr_en,
      o_rd_data_valid   => i_amp_squid_tf_rd_en,
      o_wr_rd_addr_vect => i_amp_squid_tf_wr_rd_addr,
      o_wr_data_vect    => i_amp_squid_tf_wr_data,
      -- read value
      i_rd_data_valid   => o_amp_squid_tf_rd_valid,
      i_rd_data_vect    => o_amp_squid_tf_rd_data,
      ---------------------------------------------------------------------
      -- status
      ---------------------------------------------------------------------
      o_wr_finish       => ram1_wr_gen_finish,
      o_rd_finish       => ram1_rd_gen_finish,
      o_error           => ram1_error
    );

  end generate gen_ram1;

  ---------------------------------------------------------------------
  -- Input: data generation
  ---------------------------------------------------------------------
  gen_data : if true generate
    signal pixel_sof_vect_tmp : std_logic_vector(0 downto 0);
    signal pixel_eof_vect_tmp : std_logic_vector(0 downto 0);
    signal frame_sof_vect_tmp : std_logic_vector(0 downto 0);
    signal frame_eof_vect_tmp : std_logic_vector(0 downto 0);
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
    inst_pkg_data_generator : pkg_data_generator_8(
      i_clk            => i_clk,
      i_start          => data_start,
      ---------------------------------------------------------------------
      -- input file
      ---------------------------------------------------------------------
      i_filepath       => c_FILEPATH_DATA_IN,
      i_csv_separator  => c_CSV_SEPARATOR,
      --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
      --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
      --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
      --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
      --  data type = "STD_VEC" => no data convertion before writing in the output file
      i_DATA0_TYP      => "UINT",
      i_DATA1_TYP      => "UINT",
      i_DATA2_TYP      => "UINT",
      i_DATA3_TYP      => "UINT",
      i_DATA4_TYP      => "UINT",
      i_DATA5_TYP      => "UINT",
      i_DATA6_TYP      => "UINT",
      i_DATA7_TYP      => "UINT",
      ---------------------------------------------------------------------
      -- command
      ---------------------------------------------------------------------
      i_ready          => data_rd_valid,
      o_data_valid     => data_valid,
      o_data0_std_vect => pixel_sof_vect_tmp,
      o_data1_std_vect => pixel_eof_vect_tmp,
      o_data2_std_vect => i_pixel_id,
      o_data3_std_vect => i_pixel_result,
      o_data4_std_vect => frame_sof_vect_tmp,
      o_data5_std_vect => frame_eof_vect_tmp,
      o_data6_std_vect => i_frame_id,
      o_data7_std_vect => i_amp_squid_offset_correction,
      ---------------------------------------------------------------------
      -- status
      ---------------------------------------------------------------------
      o_finish         => data_gen_finish
    );

    i_pixel_valid <= data_valid;
    i_pixel_sof   <= pixel_sof_vect_tmp(0);
    i_pixel_eof   <= pixel_eof_vect_tmp(0);
    i_frame_sof   <= frame_sof_vect_tmp(0);
    i_frame_eof   <= frame_eof_vect_tmp(0);

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
  dut_amp_squid_top : entity fpasim.amp_squid_top
    generic map(
      -- pixel
      g_PIXEL_ID_WIDTH              => g_PIXEL_ID_WIDTH, -- pixel id bus width (expressed in bits). Possible values [1; max integer value[
      -- frame
      g_FRAME_ID_WIDTH              => g_FRAME_ID_WIDTH, -- frame id bus width (expressed in bits). Possible values [1; max integer value[
      -- address        
      g_AMP_SQUID_TF_RAM_ADDR_WIDTH => g_AMP_SQUID_TF_RAM_ADDR_WIDTH, -- address bus width (expressed in bits)
      -- computation 
      g_PIXEL_RESULT_INPUT_WIDTH    => g_PIXEL_RESULT_INPUT_WIDTH, -- pixel input result bus width (expressed in bits). Possible values [1; max integer value[
      g_PIXEL_RESULT_OUTPUT_WIDTH   => g_PIXEL_RESULT_OUTPUT_WIDTH -- pixel output bus width (expressed in bits). Possible values [1; max integer value[
    )
    port map(
      i_clk                         => i_clk, -- clock
      i_rst_status                  => i_rst_status, -- reset error flag(s)
      i_debug_pulse                 => i_debug_pulse, -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
      ---------------------------------------------------------------------
      -- input command: from the regdecode
      ---------------------------------------------------------------------
      -- RAM: amp_squid_tf
      -- wr
      i_amp_squid_tf_wr_en          => i_amp_squid_tf_wr_en, -- write enable
      i_amp_squid_tf_wr_rd_addr     => i_amp_squid_tf_wr_rd_addr, -- write address
      i_amp_squid_tf_wr_data        => i_amp_squid_tf_wr_data, -- write data
      -- rd
      i_amp_squid_tf_rd_en          => i_amp_squid_tf_rd_en, -- rd enable
      o_amp_squid_tf_rd_valid       => o_amp_squid_tf_rd_valid, -- rd data valid
      o_amp_squid_tf_rd_data        => o_amp_squid_tf_rd_data, -- read data
      -- gain
      i_fpasim_gain                 => i_fpasim_gain, -- gain value
      ---------------------------------------------------------------------
      -- input1
      ---------------------------------------------------------------------
      i_pixel_sof                   => i_pixel_sof, -- first pixel sample
      i_pixel_eof                   => i_pixel_eof, -- last pixel sample
      i_pixel_valid                 => i_pixel_valid, -- valid pixel sample
      i_pixel_id                    => i_pixel_id, -- pixel id
      i_pixel_result                => i_pixel_result, -- pixel result
      i_frame_sof                   => i_frame_sof, -- first frame sample
      i_frame_eof                   => i_frame_eof, -- last frame sample
      i_frame_id                    => i_frame_id, -- frame id
      ---------------------------------------------------------------------
      -- input2
      ---------------------------------------------------------------------
      i_amp_squid_offset_correction => i_amp_squid_offset_correction, -- amp squid offset value
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_pixel_sof                   => o_pixel_sof, -- first pixel sample
      o_pixel_eof                   => o_pixel_eof, -- last pixel sample
      o_pixel_valid                 => o_pixel_valid, -- valid pixel sample
      o_pixel_id                    => o_pixel_id, --  pixel id
      o_pixel_result                => o_pixel_result, --  pixel result
      o_frame_sof                   => o_frame_sof, -- first frame sample
      o_frame_eof                   => o_frame_eof, -- last frame sample
      o_frame_id                    => o_frame_id, --  frame id
      ---------------------------------------------------------------------
      -- errors/status
      ---------------------------------------------------------------------
      o_errors                      => o_errors, -- output errors
      o_status                      => o_status -- output status
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
  gen_log : if g_ENABLE_LOG = true generate -- @suppress "Redundant boolean equality check with true"
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
        i_clk            => i_clk,
        i_start          => data_start,
        i_stop           => data_stop,
        ---------------------------------------------------------------------
        -- output file
        ---------------------------------------------------------------------
        i_filepath       => c_FILEPATH_DATA_OUT,
        i_csv_separator  => c_CSV_SEPARATOR,
        i_NAME0          => "pixel_sof",
        i_NAME1          => "pixel_eof",
        i_NAME2          => "pixel_id",
        i_NAME3          => "pixel_result",
        i_NAME4          => "frame_sof",
        i_NAME5          => "frame_eof",
        i_NAME6          => "frame_id",
        --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
        --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
        --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
        --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
        --  data type = "STD_VEC" => no data convertion before writing in the output file
        i_DATA0_TYP      => "UINT",
        i_DATA1_TYP      => "UINT",
        i_DATA2_TYP      => "UINT",
        i_DATA3_TYP      => "UINT",
        i_DATA4_TYP      => "UINT",
        i_DATA5_TYP      => "UINT",
        i_DATA6_TYP      => "UINT",
        ---------------------------------------------------------------------
        -- signals to log
        ---------------------------------------------------------------------
        i_data_valid     => data_valid,
        i_data0_std_vect => pixel_sof_vect_tmp,
        i_data1_std_vect => pixel_eof_vect_tmp,
        i_data2_std_vect => o_pixel_id,
        i_data3_std_vect => o_pixel_result,
        i_data4_std_vect => frame_sof_vect_tmp,
        i_data5_std_vect => frame_eof_vect_tmp,
        i_data6_std_vect => o_frame_id
      );

    end generate gen_log_by_id;

  end generate gen_log;

   ---------------------------------------------------------------------
 -- check data
 ---------------------------------------------------------------------
  gen_check_data : if g_ENABLE_CHECK = true generate -- @suppress "Redundant boolean equality check with true"
  begin

    inst_pkg_vunit_data_checker : pkg_vunit_data_checker_1(
      i_clk            => i_clk,
      i_start          => data_start,
      ---------------------------------------------------------------------
      -- reference file
      ---------------------------------------------------------------------
      i_filepath       => c_FILEPATH_CHECK_DATA_OUT,
      i_csv_separator  => c_CSV_SEPARATOR,
      i_NAME0          => "mux_squid_out",
      --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
      --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
      --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
      --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
      --  data type = "STD_VEC" => no data convertion before writing in the output file
      i_DATA0_TYP      => "UINT",
      ---------------------------------------------------------------------
      -- Vunit Scoreboard objects
      ---------------------------------------------------------------------
      i_sb_data0       => c_CHECKER_DATA,
      ---------------------------------------------------------------------
      -- experimental signals
      ---------------------------------------------------------------------
      i_data_valid     => o_pixel_valid,
      i_data0_std_vect => o_pixel_result,
      ---------------------------------------------------------------------
      -- status
      ---------------------------------------------------------------------
      o_error_std_vect => data_out_error
    );

  end generate gen_check_data;

end simulate;
