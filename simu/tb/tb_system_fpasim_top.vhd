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
--!   @file                   tb_system_fpasim.vhd 
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

library opal_kelly_lib;
context opal_kelly_lib.opal_kelly_context;

use fpasim.pkg_fpasim.all;

library vunit_lib;
context vunit_lib.vunit_context;

library common_lib;
context common_lib.common_context;

entity tb_system_fpasim_top is
  generic(
    runner_cfg  : string := runner_cfg_default;  -- vunit generic: don't touch
    output_path : string := "C:/Project/fpasim-fw-hardware/";  -- vunit generic: don't touch
    ---------------------------------------------------------------------
    -- DUT generic
    ---------------------------------------------------------------------

    ---------------------------------------------------------------------
    -- simulation parameters
    ---------------------------------------------------------------------
    g_VUNIT_DEBUG  : boolean := true;
    g_TEST_NAME    : string  := "";
    g_ENABLE_CHECK : boolean := true;
    g_ENABLE_LOG   : boolean := true
    );
end tb_system_fpasim_top;

architecture simulate of tb_system_fpasim_top is

  constant c_INPUT_BASEPATH  : string := output_path & "inputs/";
  constant c_OUTPUT_BASEPATH : string := output_path & "outputs/";

  signal i_clk_to_fpga_p : std_logic;
  signal i_clk_to_fpga_n : std_logic;

  ---------------------------------------------------------------------
  -- module input signals
  ---------------------------------------------------------------------
  --  Opal Kelly inouts --
  signal i_okUH  : std_logic_vector(4 downto 0) := (others => '0');
  signal o_okHU  : std_logic_vector(2 downto 0) := (others => '0');
  signal b_okUHU : std_logic_vector(31 downto 0);
  signal b_okAA  : std_logic                    := '0';

  -- FMC: from the card
  signal i_board_id  : std_logic_vector(7 downto 0) := (others => '0'); -- @suppress "signal i_board_id is never written"
  ---------------------------------------------------------------------
  -- FMC: from the adc
  ---------------------------------------------------------------------
  signal i_adc_clk_p : std_logic;       --  differential clock p @250MHz
  signal i_adc_clk_n : std_logic;       --  differential clock n @250MHZ
  -- adc_a
  -- bit P/N: 0-1
  signal i_da0_p     : std_logic;
  signal i_da0_n     : std_logic;
  signal i_da2_p     : std_logic;
  signal i_da2_n     : std_logic;
  signal i_da4_p     : std_logic;
  signal i_da4_n     : std_logic;
  signal i_da6_p     : std_logic;
  signal i_da6_n     : std_logic;
  signal i_da8_p     : std_logic;
  signal i_da8_n     : std_logic;
  signal i_da10_p    : std_logic;
  signal i_da10_n    : std_logic;
  signal i_da12_p    : std_logic;
  signal i_da12_n    : std_logic;
  -- adc_b
  signal i_db0_p     : std_logic;
  signal i_db0_n     : std_logic;
  signal i_db2_p     : std_logic;
  signal i_db2_n     : std_logic;
  signal i_db4_p     : std_logic;
  signal i_db4_n     : std_logic;
  signal i_db6_p     : std_logic;
  signal i_db6_n     : std_logic;
  signal i_db8_p     : std_logic;
  signal i_db8_n     : std_logic;
  signal i_db10_p    : std_logic;
  signal i_db10_n    : std_logic;
  signal i_db12_p    : std_logic;
  signal i_db12_n    : std_logic;

  -- FMC: to sync
  ---------------------------------------------------------------------
  signal o_ref_clk : std_logic;  -- @suppress "signal o_ref_clk is never read"
  signal o_sync    : std_logic;  -- @suppress "signal o_sync is never read"

  -- FMC: to dac
  ---------------------------------------------------------------------
  signal o_dac_clk_p   : std_logic;  -- @suppress "signal o_dac_clk_p is never read"
  signal o_dac_clk_n   : std_logic;  -- @suppress "signal o_dac_clk_n is never read"
  signal o_dac_frame_p : std_logic;  -- @suppress "signal o_dac_frame_p is never read"
  signal o_dac_frame_n : std_logic;  -- @suppress "signal o_dac_frame_n is never read"
  signal o_dac0_p      : std_logic;  -- @suppress "signal o_dac0_p is never read"
  signal o_dac0_n      : std_logic;  -- @suppress "signal o_dac0_n is never read"
  signal o_dac1_p      : std_logic;  -- @suppress "signal o_dac1_p is never read"
  signal o_dac1_n      : std_logic;  -- @suppress "signal o_dac1_n is never read"
  signal o_dac2_p      : std_logic;  -- @suppress "signal o_dac2_p is never read"
  signal o_dac2_n      : std_logic;  -- @suppress "signal o_dac2_n is never read"
  signal o_dac3_p      : std_logic;  -- @suppress "signal o_dac3_p is never read"
  signal o_dac3_n      : std_logic;  -- @suppress "signal o_dac3_n is never read"
  signal o_dac4_p      : std_logic;  -- @suppress "signal o_dac4_p is never read"
  signal o_dac4_n      : std_logic;  -- @suppress "signal o_dac4_n is never read"
  signal o_dac5_p      : std_logic;  -- @suppress "signal o_dac5_p is never read"
  signal o_dac5_n      : std_logic;  -- @suppress "signal o_dac5_n is never read"
  signal o_dac6_p      : std_logic;  -- @suppress "signal o_dac6_p is never read"
  signal o_dac6_n      : std_logic;  -- @suppress "signal o_dac6_n is never read"
  signal o_dac7_p      : std_logic;  -- @suppress "signal o_dac7_p is never read"
  signal o_dac7_n      : std_logic;  -- @suppress "signal o_dac7_n is never read"

  ---------------------------------------------------------------------
  -- devices: spi links + specific signals
  ---------------------------------------------------------------------
  -- common: shared link between the spi
  signal o_spi_sclk        : std_logic;   -- @suppress "signal o_spi_sclk is never read"
  signal o_spi_sdata       : std_logic;   -- @suppress "signal o_spi_sdata is never read"
  -- CDCE: SPI
  signal i_cdce_sdo        : std_logic := '0';  -- @suppress "signal i_cdce_sdo is never written"
  signal o_cdce_n_en       : std_logic;  -- @suppress "signal o_cdce_n_en is never read"
  -- CDCE: specific signals
  signal i_cdce_pll_status : std_logic := '1';   -- @suppress "signal i_cdce_pll_status is never written"
  signal o_cdce_n_reset    : std_logic;   -- @suppress "signal o_cdce_n_reset is never read"
  signal o_cdce_n_pd       : std_logic;  -- @suppress "signal o_cdce_n_pd is never read"
  signal o_ref_en          : std_logic;   -- @suppress "signal o_ref_en is never read"
  -- ADC: SPI
  signal i_adc_sdo         : std_logic := '0'; -- @suppress "signal i_adc_sdo is never written"
  signal o_adc_n_en        : std_logic;  -- @suppress "signal o_adc_n_en is never read"
  -- ADC: specific signals
  signal o_adc_reset       : std_logic; -- @suppress "signal o_adc_reset is never read"
  -- DAC: SPI
  signal i_dac_sdo         : std_logic := '0';   -- @suppress "signal i_dac_sdo is never written"
  signal o_dac_n_en        : std_logic;   -- @suppress "signal o_dac_n_en is never read"
  -- DAC: specific signal
  signal o_dac_tx_present  : std_logic;   -- @suppress "signal o_dac_tx_present is never read"
  -- AMC: SPI (monitoring)
  signal i_mon_sdo         : std_logic := '0';  -- @suppress "signal i_mon_sdo is never written"
  signal o_mon_n_en        : std_logic;   -- @suppress "signal o_mon_n_en is never read"
  -- AMC : specific signals
  signal i_mon_n_int       : std_logic := '0';  -- @suppress "signal i_mon_n_int is never written"
  signal o_mon_n_reset     : std_logic;  -- @suppress "signal o_mon_n_reset is never read"

  signal o_leds : std_logic_vector(3 downto 2); -- @suppress "signal o_leds is never read"

  ---------------------------------------------------------------------
  -- additional signals
  ---------------------------------------------------------------------
  -- Clocks
  signal usb_clk : std_logic := '0';
  signal adc_clk : std_logic := '0';

  signal data0 : unsigned(13 downto 0) := (others => '0');
  signal data1 : unsigned(13 downto 0) := (others => '0');

  signal data0_r1 : unsigned(13 downto 0) := (others => '0');
  signal data1_r1 : unsigned(13 downto 0) := (others => '0');

  ---------------------------------------------------------------------
  -- Clock definition
  ---------------------------------------------------------------------
  constant c_CLK_PERIOD0    : time                         := 9.99206 ns;  -- @100.8MHz (usb3 opal kelly speed)
  constant c_CLK_PERIOD1    : time                         := 4 ns;
  ---------------------------------------------------------------------
  -- Generate reading sequence
  ---------------------------------------------------------------------
  -- data
  signal data_start         : std_logic                    := '0';
  signal data_rd_valid      : std_logic                    := '0';
  signal data_wr_gen_finish : std_logic                    := '0';
  signal data_wr_error      : std_logic_vector(0 downto 0) := (others => '0');  -- @suppress "signal data_wr_error is never read"
  signal data_stop          : std_logic                    := '0';

  signal o_reg_id     : integer                       := 0;
  signal o_data       : std_logic_vector(31 downto 0) := (others => '0');
  signal o_data_valid : std_logic                     := '0';

  ---------------------------------------------------------------------
  -- filepath definition
  ---------------------------------------------------------------------
  constant c_CSV_SEPARATOR : character := ';';

  -- input data generation
  constant c_FILENAME_DATA_IN : string := "py_usb_data.csv";
  constant c_FILEPATH_DATA_IN : string := c_INPUT_BASEPATH & c_FILENAME_DATA_IN;

  constant c_FILENAME_DATA_OUT0 : string := "vhdl_tes_pulse_shape_out.csv";
  constant c_FILEPATH_DATA_OUT0 : string := c_OUTPUT_BASEPATH & c_FILENAME_DATA_OUT0;

  constant c_FILENAME_DATA_OUT1 : string := "vhdl_amp_squid_tf.csv";
  constant c_FILEPATH_DATA_OUT1 : string := c_OUTPUT_BASEPATH & c_FILENAME_DATA_OUT1;

  constant c_FILENAME_DATA_OUT2 : string := "vhdl_mux_squid_tf.csv";
  constant c_FILEPATH_DATA_OUT2 : string := c_OUTPUT_BASEPATH & c_FILENAME_DATA_OUT2;

  constant c_FILENAME_DATA_OUT3 : string := "vhdl_tes_steady_state.csv";
  constant c_FILEPATH_DATA_OUT3 : string := c_OUTPUT_BASEPATH & c_FILENAME_DATA_OUT3;

  constant c_FILENAME_DATA_OUT4 : string := "vhdl_mux_squid_offset.csv";
  constant c_FILEPATH_DATA_OUT4 : string := c_OUTPUT_BASEPATH & c_FILENAME_DATA_OUT4;

  ---------------------------------------------------------------------
  -- VUnit Scoreboard objects
  ---------------------------------------------------------------------
  -- loggers 
  constant c_LOGGER_SUMMARY               : logger_t  := get_logger("log:summary");  -- @suppress "Expression does not result in a constant"
  -- checkers
  constant c_CHECKER_REG                  : checker_t := new_checker("check:reg:data");  -- @suppress "Expression does not result in a constant"
  constant c_CHECKER_RAM_TES_PULSE_SHAPE  : checker_t := new_checker("check:ram:tes_pulse_shape");  -- @suppress "Expression does not result in a constant"
  constant c_CHECKER_RAM_AMP_SQUID_TF     : checker_t := new_checker("check:ram:amp_squid_tf");  -- @suppress "Expression does not result in a constant"
  constant c_CHECKER_RAM_MUX_SQUID_TF     : checker_t := new_checker("check:ram:mux_squid_tf");  -- @suppress "Expression does not result in a constant"
  constant c_CHECKER_RAM_TES_STEADY_STATE : checker_t := new_checker("check:ram:tes_steady_state");  -- @suppress "Expression does not result in a constant"
  constant c_CHECKER_RAM_MUX_SQUID_OFFSET : checker_t := new_checker("check:ram:mux_squid_offset");  -- @suppress "Expression does not result in a constant"

  -- constant c_CHECKER_REG_CTRL            : checker_t := new_checker("check:reg:ctrl");  -- @suppress "Expression does not result in a constant"
  -- constant c_CHECKER_REG_FPASIM_GAIN     : checker_t := new_checker("check:reg:fpasim_gain");  -- @suppress "Expression does not result in a constant"
  -- constant c_CHECKER_REG_MUX_SQ_FB_DELAY : checker_t := new_checker("check:reg:mux_sq_fb_delay");  -- @suppress "Expression does not result in a constant"
  -- constant c_CHECKER_REG_AMP_SQ_OF_DELAY : checker_t := new_checker("check:reg:amp_sq_of_delay");  -- @suppress "Expression does not result in a constant"
  -- constant c_CHECKER_REG_ERROR_DELAY     : checker_t := new_checker("check:reg:error_delay");  -- @suppress "Expression does not result in a constant"
  -- constant c_CHECKER_REG_RA_DELAY        : checker_t := new_checker("check:reg:ra_delay");  -- @suppress "Expression does not result in a constant"

  signal usb_wr_if0 : opal_kelly_lib.pkg_front_panel.t_internal_wr_if := (
    hi_drive   => '0',
    hi_cmd     => (others => '0'),
    hi_dataout => (others => '0')
    );

  signal usb_rd_if0 : opal_kelly_lib.pkg_front_panel.t_internal_rd_if := (
    i_clk     => '0',
    hi_busy   => '0',
    hi_datain => (others => '0')
    );

  shared variable v_front_panel_conf : opal_kelly_lib.pkg_front_panel.t_front_panel_conf;

begin

  ---------------------------------------------------------------------
  -- Clock generation
  ---------------------------------------------------------------------
  p_usb_clk_gen : process is
  begin
    usb_clk <= '0';
    wait for c_CLK_PERIOD0 / 2;
    usb_clk <= '1';
    wait for c_CLK_PERIOD0 / 2;
  end process p_usb_clk_gen;

  p_adc_clk : process is
  begin
    adc_clk <= '0';
    i_adc_clk_p <= '0';
    i_adc_clk_n <= '1';
    wait for c_CLK_PERIOD1 / 2;
    adc_clk <= '1';
    i_adc_clk_p <= '1';
    i_adc_clk_n <= '0';
    wait for c_CLK_PERIOD1 / 2;
  end process p_adc_clk;

  ---------------------------------------------------------------------
  -- master fsm
  ---------------------------------------------------------------------
  p_master_fsm : process is

  begin
    if runner_cfg'length > 0 then
      test_runner_setup(runner, runner_cfg);
    end if;

    ---------------------------------------------------------------------
    -- VUNIT - Scoreboard object : Visibility definition
    ---------------------------------------------------------------------
    if g_VUNIT_DEBUG = true then  -- @suppress "Redundant boolean equality check with true"
      -- the simulator doesn't stop on errors => stop on failure
      set_stop_level(failure);
    end if;

    show(get_logger("log:summary"), display_handler, pass);
    show(get_logger("check:data_count"), display_handler, pass);
    show(get_logger("check:errors"), display_handler, pass);

    pkg_wait_nb_rising_edge_plus_margin(i_clk => usb_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    info("Test bench: Generic parameter values");
    info("    output_path = " & output_path);

    -- simulator paramters
    info("    g_VUNIT_DEBUG = " & to_string(g_VUNIT_DEBUG));
    info("    g_TEST_NAME = " & g_TEST_NAME);
    info("    g_ENABLE_CHECK = " & to_string(g_ENABLE_CHECK));
    info("    g_ENABLE_LOG = " & to_string(g_ENABLE_LOG));

    info("Test bench: input files");
    info("    c_FILEPATH_DATA_IN = " & c_FILEPATH_DATA_IN);
    info("    c_FILEPATH_DATA_OUT0 = " & c_FILEPATH_DATA_OUT0);
    info("    c_FILEPATH_DATA_OUT1 = " & c_FILEPATH_DATA_OUT1);
    info("    c_FILEPATH_DATA_OUT2 = " & c_FILEPATH_DATA_OUT2);
    info("    c_FILEPATH_DATA_OUT3 = " & c_FILEPATH_DATA_OUT3);
    info("    c_FILEPATH_DATA_OUT4 = " & c_FILEPATH_DATA_OUT4);

    ---------------------------------------------------------------------
    -- add tempo
    ---------------------------------------------------------------------
    pkg_wait_nb_rising_edge_plus_margin(i_clk => usb_clk, i_nb_rising_edge => 16, i_margin => 12 ps);

    ---------------------------------------------------------------------
    -- conf RAM
    ---------------------------------------------------------------------
    info("Start: USB configuration");
    data_start <= '1';
    wait on usb_clk until data_wr_gen_finish = '1';
    info("End: USB confiuration");

    ---------------------------------------------------------------------
    -- End of simulation: wait few more clock cycles
    ---------------------------------------------------------------------
    info("Wait end of simulation");
    wait for 4096 * c_CLK_PERIOD0;
    data_stop <= '1';
    pkg_wait_nb_rising_edge_plus_margin(i_clk => usb_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    ---------------------------------------------------------------------
    -- VUNIT - checking errors and summary
    ---------------------------------------------------------------------
    -- summary
    info(c_LOGGER_SUMMARY,
         "===Summary===" & LF &
         "c_CHECKER_REG: " & to_string(get_checker_stat(c_CHECKER_REG)) & LF &
         "c_CHECKER_RAM_TES_PULSE_SHAPE: " & to_string(get_checker_stat(c_CHECKER_RAM_TES_PULSE_SHAPE)) & LF &
         "c_CHECKER_RAM_AMP_SQUID_TF: " & to_string(get_checker_stat(c_CHECKER_RAM_AMP_SQUID_TF)) & LF &
         "c_CHECKER_RAM_MUX_SQUID_TF: " & to_string(get_checker_stat(c_CHECKER_RAM_MUX_SQUID_TF)) & LF &
         "c_CHECKER_RAM_TES_STEADY_STATE: " & to_string(get_checker_stat(c_CHECKER_RAM_TES_STEADY_STATE)) & LF &
         "c_CHECKER_RAM_MUX_SQUID_OFFSET: " & to_string(get_checker_stat(c_CHECKER_RAM_MUX_SQUID_OFFSET)) & LF
         );

    pkg_wait_nb_rising_edge_plus_margin(i_clk => usb_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    if runner_cfg'length > 0 then
      test_runner_cleanup(runner);      -- Simulation ends here
    else
      std.env.stop;
    end if;
  end process;

  --test_runner_watchdog(runner, 10 ms);

  ---------------------------------------------------------------------
  -- Input/Output: USB controller
  ---------------------------------------------------------------------

  opal_kelly_lib.pkg_front_panel.okHost_driver(
    i_clk            => usb_clk,
    o_okUH           => i_okUH,
    i_okHU           => o_okHU,
    b_okUHU          => b_okUHU,
    i_internal_wr_if => usb_wr_if0,
    o_internal_rd_if => usb_rd_if0
    );

  ---------------------------------------------------------------------
  -- wr conf
  ---------------------------------------------------------------------
  data_rd_valid <= '1';
  gen_conf_RAM : if true generate

  begin
    pkg_usb_wr(
      i_clk                     => usb_clk,
      i_start_wr                => data_start,
      ---------------------------------------------------------------------
      -- input file
      ---------------------------------------------------------------------
      i_filepath_wr             => c_FILEPATH_DATA_IN,
      i_csv_separator           => c_CSV_SEPARATOR,
      --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
      --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
      --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
      --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
      --  data type = "STD_VEC" => no data convertion before writing in the output file
      i_USB_WR_ADDR_TYP         => "HEX",
      i_USB_WR_DATA_TYP         => "HEX",
      ---------------------------------------------------------------------
      -- command
      ---------------------------------------------------------------------
      i_wr_ready                => data_rd_valid,
      ---------------------------------------------------------------------
      -- usb
      ---------------------------------------------------------------------
      b_front_panel_conf        => v_front_panel_conf,
      o_internal_wr_if          => usb_wr_if0,
      i_internal_rd_if          => usb_rd_if0,
      ---------------------------------------------------------------------
      -- Vunit Scoreboard objects
      ---------------------------------------------------------------------
      i_sb_reg_data             => c_CHECKER_REG,
      i_sb_ram_tes_pulse_shape  => c_CHECKER_RAM_TES_PULSE_SHAPE,
      i_sb_ram_amp_squid_tf     => c_CHECKER_RAM_AMP_SQUID_TF,
      i_sb_ram_mux_squid_tf     => c_CHECKER_RAM_MUX_SQUID_TF,
      i_sb_ram_tes_steady_state => c_CHECKER_RAM_TES_STEADY_STATE,
      i_sb_ram_mux_offset       => c_CHECKER_RAM_MUX_SQUID_OFFSET,
      ---------------------------------------------------------------------
      -- data
      ---------------------------------------------------------------------
      o_reg_id                  => o_reg_id,
      o_data_valid              => o_data_valid,
      o_data                    => o_data,
      ---------------------------------------------------------------------
      -- status
      ---------------------------------------------------------------------
      o_wr_finish               => data_wr_gen_finish,
      o_error                   => data_wr_error
      );
  end generate gen_conf_RAM;

  ---------------------------------------------------------------------
  -- Data Generation
  --  the data computation is done on the rising edge.
  --  the i_adc clock and the computation clock is dephased by 90 degree
  ---------------------------------------------------------------------
  data_gen : process is
  begin
      -- compute a new value on the rising_edge
      data0 <= data0 + 1;
      data1 <= data1 + 2;
      -- save the value
      data0_r1 <= data0;
      data1_r1 <= data1;
      -- on the rising edge, keep only the even bit
      i_da0_p  <= data0(0);
      i_da0_n  <= not(data0(0));
      i_da2_p  <= data0(2);
      i_da2_n  <= not(data0(2));
      i_da4_p  <= data0(4);
      i_da4_n  <= not(data0(4));
      i_da6_p  <= data0(6);
      i_da6_n  <= not(data0(6));
      i_da8_p  <= data0(8);
      i_da8_n  <= not(data0(8));
      i_da10_p <= data0(10);
      i_da10_n <= not(data0(10));
      i_da12_p <= data0(12);
      i_da12_n <= not(data0(12));

      i_db0_p  <= data1(0);
      i_db0_n  <= not(data1(0));
      i_db2_p  <= data1(2);
      i_db2_n  <= not(data1(2));
      i_db4_p  <= data1(4);
      i_db4_n  <= not(data1(4));
      i_db6_p  <= data1(6);
      i_db6_n  <= not(data1(6));
      i_db8_p  <= data1(8);
      i_db8_n  <= not(data1(8));
      i_db10_p <= data1(10);
      i_db10_n <= not(data1(10));
      i_db12_p <= data1(12);
      i_db12_n <= not(data1(12));

      wait until rising_edge(adc_clk);
      -- add 90 degree dephasage
      wait for c_CLK_PERIOD1 / 4;
      -- on the falling edge, keep only the odd bit (previously computed)
      i_da0_p  <= data0_r1(1);
      i_da0_n  <= not(data0_r1(1));
      i_da2_p  <= data0_r1(3);
      i_da2_n  <= not(data0_r1(3));
      i_da4_p  <= data0_r1(5);
      i_da4_n  <= not(data0_r1(5));
      i_da6_p  <= data0_r1(7);
      i_da6_n  <= not(data0_r1(7));
      i_da8_p  <= data0_r1(9);
      i_da8_n  <= not(data0_r1(9));
      i_da10_p <= data0_r1(11);
      i_da10_n <= not(data0_r1(11));
      i_da12_p <= data0_r1(13);
      i_da12_n <= not(data0_r1(13));

      i_db0_p  <= data1_r1(1);
      i_db0_n  <= not(data1_r1(1));
      i_db2_p  <= data1_r1(3);
      i_db2_n  <= not(data1_r1(3));
      i_db4_p  <= data1_r1(5);
      i_db4_n  <= not(data1_r1(5));
      i_db6_p  <= data1_r1(7);
      i_db6_n  <= not(data1_r1(7));
      i_db8_p  <= data1_r1(9);
      i_db8_n  <= not(data1_r1(9));
      i_db10_p <= data1_r1(11);
      i_db10_n <= not(data1_r1(11));
      i_db12_p <= data1_r1(13);
      i_db12_n <= not(data1_r1(13));

      wait until falling_edge(adc_clk);
      -- add 90 degree dephasage
      wait for c_CLK_PERIOD1 / 4;

  end process data_gen;


  ---------------------------------------------------------------------
  -- DUT
  ---------------------------------------------------------------------
  dut_system_fpasim_top : entity fpasim.system_fpasim_top
    generic map (
      g_DEBUG => false
    )
    port map( -- @suppress "Port map uses default values. Missing optional actuals: o_leds"
     -- i_clk_to_fpga_p => i_clk_to_fpga_p,
     -- i_clk_to_fpga_n => i_clk_to_fpga_n,
      --  Opal Kelly inouts --
      i_okUH            => i_okUH,
      o_okHU            => o_okHU,
      b_okUHU           => b_okUHU,
      b_okAA            => b_okAA,
      ---------------------------------------------------------------------
      -- FMC: from the card
      ---------------------------------------------------------------------
      --i_board_id        => i_board_id,  -- card board id 
      ---------------------------------------------------------------------
      -- FMC: from the adc
      ---------------------------------------------------------------------
      i_adc_clk_p       => i_adc_clk_p,  -- differential clock p @250MHz
      i_adc_clk_n       => i_adc_clk_n,  -- differential clock n @250MHZ
      -- adc_a
      -- bit P/N: 0-1
      i_da0_p           => i_da0_p,
      i_da0_n           => i_da0_n,
      i_da2_p           => i_da2_p,
      i_da2_n           => i_da2_n,
      i_da4_p           => i_da4_p,
      i_da4_n           => i_da4_n,
      i_da6_p           => i_da6_p,
      i_da6_n           => i_da6_n,
      i_da8_p           => i_da8_p,
      i_da8_n           => i_da8_n,
      i_da10_p          => i_da10_p,
      i_da10_n          => i_da10_n,
      i_da12_p          => i_da12_p,
      i_da12_n          => i_da12_n,
      -- adc_b
      i_db0_p           => i_db0_p,
      i_db0_n           => i_db0_n,
      i_db2_p           => i_db2_p,
      i_db2_n           => i_db2_n,
      i_db4_p           => i_db4_p,
      i_db4_n           => i_db4_n,
      i_db6_p           => i_db6_p,
      i_db6_n           => i_db6_n,
      i_db8_p           => i_db8_p,
      i_db8_n           => i_db8_n,
      i_db10_p          => i_db10_p,
      i_db10_n          => i_db10_n,
      i_db12_p          => i_db12_p,
      i_db12_n          => i_db12_n,
      ---------------------------------------------------------------------
      -- FMC: to sync
      ---------------------------------------------------------------------
      o_ref_clk         => o_ref_clk,
      o_sync            => o_sync,
      ---------------------------------------------------------------------
      -- FMC: to dac
      ---------------------------------------------------------------------
      o_dac_clk_p       => o_dac_clk_p,
      o_dac_clk_n       => o_dac_clk_n,
      o_dac_frame_p     => o_dac_frame_p,
      o_dac_frame_n     => o_dac_frame_n,
      o_dac0_p          => o_dac0_p,
      o_dac0_n          => o_dac0_n,
      o_dac1_p          => o_dac1_p,
      o_dac1_n          => o_dac1_n,
      o_dac2_p          => o_dac2_p,
      o_dac2_n          => o_dac2_n,
      o_dac3_p          => o_dac3_p,
      o_dac3_n          => o_dac3_n,
      o_dac4_p          => o_dac4_p,
      o_dac4_n          => o_dac4_n,
      o_dac5_p          => o_dac5_p,
      o_dac5_n          => o_dac5_n,
      o_dac6_p          => o_dac6_p,
      o_dac6_n          => o_dac6_n,
      o_dac7_p          => o_dac7_p,
      o_dac7_n          => o_dac7_n,
      ---------------------------------------------------------------------
      -- devices: spi links + specific signals
      ---------------------------------------------------------------------
      -- common: shared link between the spi
      o_spi_sclk        => o_spi_sclk,  -- Shared SPI clock line
      o_spi_sdata       => o_spi_sdata,  -- Shared SPI MOSI
      -- CDCE: SPI
      i_cdce_sdo        => i_cdce_sdo,  -- SPI MISO
      o_cdce_n_en       => o_cdce_n_en,  -- SPI chip select
      -- CDCE: specific signals
      i_cdce_pll_status => i_cdce_pll_status,  -- pll_status : This pin is set high if the PLL is in lock.
      o_cdce_n_reset    => o_cdce_n_reset,     -- reset_n or hold_n
      o_cdce_n_pd       => o_cdce_n_pd,  -- power_down_n
      o_ref_en          => o_ref_en,    -- enable the primary reference clock
      -- ADC: SPI
      i_adc_sdo         => i_adc_sdo,   -- SPI MISO
      o_adc_n_en        => o_adc_n_en,  -- SPI chip select
      -- ADC: specific signals
      o_adc_reset       => o_adc_reset,  -- adc hardware reset
      -- DAC: SPI
      i_dac_sdo         => i_dac_sdo,   -- SPI MISO
      o_dac_n_en        => o_dac_n_en,  -- SPI chip select
      -- DAC: specific signal
      o_dac_tx_present  => o_dac_tx_present,   -- enable tx acquisition
      -- AMC: SPI (monitoring)
      i_mon_sdo         => i_mon_sdo,   -- SPI data out
      o_mon_n_en        => o_mon_n_en,  -- SPI chip select
      -- AMC : specific signals
      i_mon_n_int       => i_mon_n_int,  -- galr_n: Global analog input out-of-range alarm.
      o_mon_n_reset     => o_mon_n_reset,       -- reset_n: hardware reset

      ---------------------------------------------------------------------
    -- leds
    ---------------------------------------------------------------------
    o_leds => o_leds
      );


  ---------------------------------------------------------------------
  -- log: data out
  ---------------------------------------------------------------------
  gen_log_ram_pulse_shape : if g_ENABLE_LOG = true generate  -- @suppress "Redundant boolean equality check with true"
    signal addr       : std_logic_vector(15 downto 0);
    signal data       : std_logic_vector(15 downto 0);
    signal data_valid : std_logic;
  begin
    addr       <= o_data(31 downto 16);
    data       <= o_data(15 downto 0);
    data_valid <= o_data_valid when o_reg_id = 32 else '0';

    inst_pkg_log_data_in_file : pkg_log_data_in_file_2(
      i_clk            => usb_clk,
      i_start          => data_start,
      i_stop           => data_stop,
      ---------------------------------------------------------------------
      -- output file
      ---------------------------------------------------------------------
      i_filepath       => c_FILEPATH_DATA_OUT0,
      i_csv_separator  => c_CSV_SEPARATOR,
      i_NAME0          => "addr",
      i_NAME1          => "data",
      --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
      --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
      --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
      --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
      --  data type = "STD_VEC" => no data convertion before writing in the output file
      i_DATA0_TYP      => "UINT",
      i_DATA1_TYP      => "UINT",
      ---------------------------------------------------------------------
      -- signals to log
      ---------------------------------------------------------------------
      i_data_valid     => data_valid,
      i_data0_std_vect => addr,
      i_data1_std_vect => data
      );

  end generate gen_log_ram_pulse_shape;

  gen_log_ram_amp_squid_tf : if g_ENABLE_LOG = true generate  -- @suppress "Redundant boolean equality check with true"
    signal addr       : std_logic_vector(15 downto 0);
    signal data       : std_logic_vector(15 downto 0);
    signal data_valid : std_logic;
  begin
    addr       <= o_data(31 downto 16);
    data       <= o_data(15 downto 0);
    data_valid <= o_data_valid when o_reg_id = 33 else '0';

    inst_pkg_log_data_in_file : pkg_log_data_in_file_2(
      i_clk            => usb_clk,
      i_start          => data_start,
      i_stop           => data_stop,
      ---------------------------------------------------------------------
      -- output file
      ---------------------------------------------------------------------
      i_filepath       => c_FILEPATH_DATA_OUT1,
      i_csv_separator  => c_CSV_SEPARATOR,
      i_NAME0          => "addr",
      i_NAME1          => "data",
      --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
      --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
      --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
      --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
      --  data type = "STD_VEC" => no data convertion before writing in the output file
      i_DATA0_TYP      => "UINT",
      i_DATA1_TYP      => "UINT",
      ---------------------------------------------------------------------
      -- signals to log
      ---------------------------------------------------------------------
      i_data_valid     => data_valid,
      i_data0_std_vect => addr,
      i_data1_std_vect => data
      );

  end generate gen_log_ram_amp_squid_tf;

  gen_log_ram_mux_squid_tf : if g_ENABLE_LOG = true generate  -- @suppress "Redundant boolean equality check with true"
    signal addr       : std_logic_vector(15 downto 0);
    signal data       : std_logic_vector(15 downto 0);
    signal data_valid : std_logic;
  begin
    addr       <= o_data(31 downto 16);
    data       <= o_data(15 downto 0);
    data_valid <= o_data_valid when o_reg_id = 34 else '0';

    inst_pkg_log_data_in_file : pkg_log_data_in_file_2(
      i_clk            => usb_clk,
      i_start          => data_start,
      i_stop           => data_stop,
      ---------------------------------------------------------------------
      -- output file
      ---------------------------------------------------------------------
      i_filepath       => c_FILEPATH_DATA_OUT2,
      i_csv_separator  => c_CSV_SEPARATOR,
      i_NAME0          => "addr",
      i_NAME1          => "data",
      --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
      --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
      --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
      --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
      --  data type = "STD_VEC" => no data convertion before writing in the output file
      i_DATA0_TYP      => "UINT",
      i_DATA1_TYP      => "UINT",
      ---------------------------------------------------------------------
      -- signals to log
      ---------------------------------------------------------------------
      i_data_valid     => data_valid,
      i_data0_std_vect => addr,
      i_data1_std_vect => data
      );

  end generate gen_log_ram_mux_squid_tf;

  gen_log_ram_tes_steady_state : if g_ENABLE_LOG = true generate  -- @suppress "Redundant boolean equality check with true"
    signal addr       : std_logic_vector(15 downto 0);
    signal data       : std_logic_vector(15 downto 0);
    signal data_valid : std_logic;
  begin
    addr       <= o_data(31 downto 16);
    data       <= o_data(15 downto 0);
    data_valid <= o_data_valid when o_reg_id = 35 else '0';

    inst_pkg_log_data_in_file : pkg_log_data_in_file_2(
      i_clk            => usb_clk,
      i_start          => data_start,
      i_stop           => data_stop,
      ---------------------------------------------------------------------
      -- output file
      ---------------------------------------------------------------------
      i_filepath       => c_FILEPATH_DATA_OUT3,
      i_csv_separator  => c_CSV_SEPARATOR,
      i_NAME0          => "addr",
      i_NAME1          => "data",
      --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
      --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
      --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
      --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
      --  data type = "STD_VEC" => no data convertion before writing in the output file
      i_DATA0_TYP      => "UINT",
      i_DATA1_TYP      => "UINT",
      ---------------------------------------------------------------------
      -- signals to log
      ---------------------------------------------------------------------
      i_data_valid     => data_valid,
      i_data0_std_vect => addr,
      i_data1_std_vect => data
      );

  end generate gen_log_ram_tes_steady_state;

  gen_log_ram_mux_squid_offset : if g_ENABLE_LOG = true generate  -- @suppress "Redundant boolean equality check with true"
    signal addr       : std_logic_vector(15 downto 0);
    signal data       : std_logic_vector(15 downto 0);
    signal data_valid : std_logic;
  begin
    addr       <= o_data(31 downto 16);
    data       <= o_data(15 downto 0);
    data_valid <= o_data_valid when o_reg_id = 35 else '0';

    inst_pkg_log_data_in_file : pkg_log_data_in_file_2(
      i_clk            => usb_clk,
      i_start          => data_start,
      i_stop           => data_stop,
      ---------------------------------------------------------------------
      -- output file
      ---------------------------------------------------------------------
      i_filepath       => c_FILEPATH_DATA_OUT4,
      i_csv_separator  => c_CSV_SEPARATOR,
      i_NAME0          => "addr",
      i_NAME1          => "data",
      --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
      --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
      --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
      --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
      --  data type = "STD_VEC" => no data convertion before writing in the output file
      i_DATA0_TYP      => "UINT",
      i_DATA1_TYP      => "UINT",
      ---------------------------------------------------------------------
      -- signals to log
      ---------------------------------------------------------------------
      i_data_valid     => data_valid,
      i_data0_std_vect => addr,
      i_data1_std_vect => data
      );

  end generate gen_log_ram_mux_squid_offset;

end simulate;
