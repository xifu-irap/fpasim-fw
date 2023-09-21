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
--    @file                   tb_system_fpasim.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--     Testbench of the system_fpasim_top module.
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
    g_VUNIT_DEBUG  : boolean := true;  -- true: stop simulator on failures, false: stop the simulator on errors.
    g_TEST_NAME    : string  := "";     -- name of the test
    g_ENABLE_CHECK : boolean := true;  -- true: compare the simulation output with the reference one, false: do nothing.
    g_ENABLE_LOG   : boolean := true  -- true: save simulation data in files, false: don't save simulation data in files
    );
end tb_system_fpasim_top;

architecture Simulation of tb_system_fpasim_top is

  -- simulation output path for the testbench input files
  constant c_INPUT_BASEPATH  : string := output_path & "inputs/";
  -- simulation output path for the testbench output files
  constant c_OUTPUT_BASEPATH : string := output_path & "outputs/";

  ---------------------------------------------------------------------
  -- module input signals
  ---------------------------------------------------------------------
  --  Opal Kelly inouts --
  signal i_okUH  : std_logic_vector(4 downto 0) := (others => '0');  -- usb signals
  signal o_okHU  : std_logic_vector(2 downto 0) := (others => '0');  -- usb signals
  signal b_okUHU : std_logic_vector(31 downto 0);        -- usb signals
  signal b_okAA  : std_logic                    := '0';  -- usb signals

  -- FMC: from the card
  -- board_id
  --signal i_board_id  : std_logic_vector(7 downto 0) := (others => '0');
  ---------------------------------------------------------------------
  -- FMC: from the adc
  ---------------------------------------------------------------------
  signal i_adc_clk_p : std_logic := '0';  --  differential clock p @250MHz
  signal i_adc_clk_n : std_logic := '1';  --  differential clock n @250MHZ
  -- adc_a
  -- bit P/N: 0-1
  signal i_da0_p     : std_logic;         -- adc bit0_p: channel A
  signal i_da0_n     : std_logic;         -- adc bit0_n: channel A

  signal i_da2_p : std_logic;           -- adc bit2_p: channel A
  signal i_da2_n : std_logic;           -- adc bit2_n: channel A

  signal i_da4_p : std_logic;           -- adc bit4_p: channel A
  signal i_da4_n : std_logic;           -- adc bit4_n: channel A

  signal i_da6_p : std_logic;           -- adc bit6_p: channel A
  signal i_da6_n : std_logic;           -- adc bit6_n: channel A

  signal i_da8_p : std_logic;           -- adc bit8_p: channel A
  signal i_da8_n : std_logic;           -- adc bit8_n: channel A

  signal i_da10_p : std_logic;          -- adc bit10_p: channel A
  signal i_da10_n : std_logic;          -- adc bit10_n: channel A

  signal i_da12_p : std_logic;          -- adc bit12_p: channel A
  signal i_da12_n : std_logic;          -- adc bit12_n: channel A
  -- adc_b
  signal i_db0_p  : std_logic;          -- adc bit0_p: channel B
  signal i_db0_n  : std_logic;          -- adc bit0_n: channel B

  signal i_db2_p : std_logic;           -- adc bit2_p: channel B
  signal i_db2_n : std_logic;           -- adc bit2_n: channel B

  signal i_db4_p : std_logic;           -- adc bit4_p: channel B
  signal i_db4_n : std_logic;           -- adc bit4_n: channel B

  signal i_db6_p : std_logic;           -- adc bit6_p: channel B
  signal i_db6_n : std_logic;           -- adc bit6_n: channel B

  signal i_db8_p : std_logic;           -- adc bit8_p: channel B
  signal i_db8_n : std_logic;           -- adc bit8_n: channel B

  signal i_db10_p : std_logic;          -- adc bit10_p: channel B
  signal i_db10_n : std_logic;          -- adc bit10_n: channel B

  signal i_db12_p : std_logic;          -- adc bit12_p: channel B
  signal i_db12_n : std_logic;          -- adc bit12_n: channel B

  -- FMC: to sync
  ---------------------------------------------------------------------
  signal o_ref_clk : std_logic;         -- clock reference
  signal o_sync    : std_logic;         -- clock frame

  -- FMC: to dac
  ---------------------------------------------------------------------
  signal o_dac_clk_p : std_logic;       -- dac clock_p
  signal o_dac_clk_n : std_logic;       -- dac clock_n

  signal o_dac_frame_p : std_logic;     -- dac frame_p
  signal o_dac_frame_n : std_logic;     -- dac frame_n

  signal o_dac0_p : std_logic;          -- dac bit0_p
  signal o_dac0_n : std_logic;          -- dac bit0_n

  signal o_dac1_p : std_logic;          -- dac bit1_p
  signal o_dac1_n : std_logic;          -- dac bit1_n

  signal o_dac2_p : std_logic;          -- dac bit2_p
  signal o_dac2_n : std_logic;          -- dac bit2_n

  signal o_dac3_p : std_logic;          -- dac bit3_p
  signal o_dac3_n : std_logic;          -- dac bit3_n

  signal o_dac4_p : std_logic;          -- dac bit4_p
  signal o_dac4_n : std_logic;          -- dac bit4_n

  signal o_dac5_p : std_logic;          -- dac bit5_p
  signal o_dac5_n : std_logic;          -- dac bit5_n

  signal o_dac6_p : std_logic;          -- dac bit6_p
  signal o_dac6_n : std_logic;          -- dac bit6_n

  signal o_dac7_p : std_logic;          -- dac bit7_p
  signal o_dac7_n : std_logic;          -- dac bit7_n

  ---------------------------------------------------------------------
  -- devices: spi links + specific signals
  ---------------------------------------------------------------------
  -- common: shared link between the spi
  signal o_spi_sclk        : std_logic;  --  Shared SPI clock line
  signal o_spi_sdata       : std_logic;  --  Shared SPI MOSI
  -- CDCE: SPI
  signal i_cdce_sdo        : std_logic := '0';  --  SPI MISO
  signal o_cdce_n_en       : std_logic;  --  SPI chip select
  -- CDCE: specific signals
  signal i_cdce_pll_status : std_logic := '1';  --  pll_status : This pin is set high if the PLL is in lock.
  signal o_cdce_n_reset    : std_logic;  --  reset_n or hold_n
  signal o_cdce_n_pd       : std_logic;  --  power_down_n
  signal o_ref_en          : std_logic;  --  enable the primary reference clock
  -- ADC: SPI
  signal i_adc_sdo         : std_logic := '0';  --  SPI MISO
  signal o_adc_n_en        : std_logic;  --  SPI chip select
  -- ADC: specific signals
  signal o_adc_reset       : std_logic;  --  adc hardware reset
  -- DAC: SPI
  signal i_dac_sdo         : std_logic := '0';  --  SPI MISO
  signal o_dac_n_en        : std_logic;  --  SPI chip select
  -- DAC: specific signal
  signal o_dac_tx_present  : std_logic;  --  enable tx acquisition
  -- AMC: SPI (monitoring)
  signal i_mon_sdo         : std_logic := '0';  --  SPI data out
  signal o_mon_n_en        : std_logic;  --  SPI chip select
  -- AMC : specific signals
  signal i_mon_n_int       : std_logic := '0';  --  galr_n: Global analog input out-of-range alarm.
  signal o_mon_n_reset     : std_logic;  --  reset_n: hardware reset

  -- FPGA BOARD leds
  signal o_leds         : std_logic_vector(3 downto 0);
  -- FMC firmware led
  signal o_led_fw       : std_logic;
  -- FMC PLL lock led
  signal o_led_pll_lock : std_logic;

  -- first processed sample of a pulse
  signal o_trig_oscillo : std_logic;

  ---------------------------------------------------------------------
  -- additional signals
  ---------------------------------------------------------------------
  -- Clocks
  -- usb clock
  signal usb_clk : std_logic := '0';
  -- adc clock
  signal adc_clk : std_logic := '0';

  -- channel A: adc0
  signal data0 : unsigned(13 downto 0) := (others => '0');
  -- channel B: adc0
  signal data1 : unsigned(13 downto 0) := (others => '0');

  ---------------------------------------------------------------------
  -- Clock definition
  ---------------------------------------------------------------------
  -- clock period duration (@usb_clk)
  constant c_CLK_PERIOD0    : time                         := 9.99206 ns;  -- @100.8MHz (usb3 opal kelly speed)
  -- clock period duration (@adc_clk)
  constant c_CLK_PERIOD1    : time                         := 4 ns;
  ---------------------------------------------------------------------
  -- Generate reading sequence
  ---------------------------------------------------------------------
  -- data
  -- start the usb configuration
  signal data_start         : std_logic                    := '0';
  -- read valid for the usb configuration (modulate the file reading speed)
  signal data_rd_valid      : std_logic                    := '0';
  -- end of the usb configuration
  signal data_wr_gen_finish : std_logic                    := '0';
  -- detect error on the usb confiuration (bad file)
  signal data_wr_error      : std_logic_vector(0 downto 0) := (others => '0');
  -- stop the logging.
  signal data_stop          : std_logic                    := '0';

  -- register id read from a file (for simulation purpose only)
  signal o_reg_id     : integer                       := 0;
  -- register/ram value to write
  signal o_data       : std_logic_vector(31 downto 0) := (others => '0');
  -- regsiter/ram data valid
  signal o_data_valid : std_logic                     := '0';

  ---------------------------------------------------------------------
  -- filepath definition
  ---------------------------------------------------------------------
  -- csv file separator
  constant c_CSV_SEPARATOR : character := ';';

  -- input data generation
  -- filename associated to the usb access
  constant c_FILENAME_DATA_IN : string := "py_usb_data.csv";
  -- filepath associated to the usb access
  constant c_FILEPATH_DATA_IN : string := c_INPUT_BASEPATH & c_FILENAME_DATA_IN;

  -- filename: store the tes_pulse_shape RAM content to write
  constant c_FILENAME_DATA_OUT0 : string := "vhdl_tes_pulse_shape_out.csv";
  -- filepath: store the tes_pulse_shape RAM content to write
  constant c_FILEPATH_DATA_OUT0 : string := c_OUTPUT_BASEPATH & c_FILENAME_DATA_OUT0;

  -- filename: store the amp_squid_tf RAM content to write
  constant c_FILENAME_DATA_OUT1 : string := "vhdl_amp_squid_tf.csv";
  -- filepath: store the amp_squid_tf RAM content to write
  constant c_FILEPATH_DATA_OUT1 : string := c_OUTPUT_BASEPATH & c_FILENAME_DATA_OUT1;

  -- filename: store the mux_squid_tf RAM content to write
  constant c_FILENAME_DATA_OUT2 : string := "vhdl_mux_squid_tf.csv";
  -- filepath: store the mux_squid_tf RAM content to write
  constant c_FILEPATH_DATA_OUT2 : string := c_OUTPUT_BASEPATH & c_FILENAME_DATA_OUT2;

  -- filename: store the tes_steady_state RAM content to write
  constant c_FILENAME_DATA_OUT3 : string := "vhdl_tes_steady_state.csv";
  -- filepath: store the tes_steady_state RAM content to write
  constant c_FILEPATH_DATA_OUT3 : string := c_OUTPUT_BASEPATH & c_FILENAME_DATA_OUT3;

  -- filename: store the mux_squid_offset RAM content to write
  constant c_FILENAME_DATA_OUT4 : string := "vhdl_mux_squid_offset.csv";
  -- filepath: store the mux_squid_offset RAM content to write
  constant c_FILEPATH_DATA_OUT4 : string := c_OUTPUT_BASEPATH & c_FILENAME_DATA_OUT4;

  ---------------------------------------------------------------------
  -- VUnit Scoreboard objects
  ---------------------------------------------------------------------
  -- loggers
  -- Vunit logger for the summary
  constant c_LOGGER_SUMMARY               : logger_t  := get_logger("log:summary");
  -- checkers
  -- vunit checker associated to the registers
  constant c_CHECKER_REG                  : checker_t := new_checker("check:reg:data");
  -- vunit checker associated to the tes_pulse_shape RAM
  constant c_CHECKER_RAM_TES_PULSE_SHAPE  : checker_t := new_checker("check:ram:tes_pulse_shape");
  -- vunit checker associated to the amp_squid_tf RAM
  constant c_CHECKER_RAM_AMP_SQUID_TF     : checker_t := new_checker("check:ram:amp_squid_tf");
  -- vunit checker associated to the mux_squid_tf RAM
  constant c_CHECKER_RAM_MUX_SQUID_TF     : checker_t := new_checker("check:ram:mux_squid_tf");
  -- vunit checker associated to the tes_steady_state RAM
  constant c_CHECKER_RAM_TES_STEADY_STATE : checker_t := new_checker("check:ram:tes_steady_state");
  -- vunit checker associated to the mux_squid_offset RAM
  constant c_CHECKER_RAM_MUX_SQUID_OFFSET : checker_t := new_checker("check:ram:mux_squid_offset");

  -- opal kelly: write interface
  signal usb_wr_if0 : opal_kelly_lib.pkg_front_panel.t_internal_wr_if := (
    hi_drive   => '0',
    hi_cmd     => (others => '0'),
    hi_dataout => (others => '0')
    );

  -- opal kelly: read interface
  signal usb_rd_if0 : opal_kelly_lib.pkg_front_panel.t_internal_rd_if := (
    i_clk     => '0',
    hi_busy   => '0',
    hi_datain => (others => '0')
    );

  -- opal kelly: shared variable interface
  shared variable v_front_panel_conf : opal_kelly_lib.pkg_front_panel.t_front_panel_conf;

begin

  ---------------------------------------------------------------------
  -- USB Clock generation
  ---------------------------------------------------------------------
  p_usb_clk_gen : process is
  begin
    usb_clk <= '0';
    wait for c_CLK_PERIOD0 / 2;
    usb_clk <= '1';
    wait for c_CLK_PERIOD0 / 2;
  end process p_usb_clk_gen;

  ---------------------------------------------------------------------
  -- ADC data clock generation
  ---------------------------------------------------------------------
  p_adc_clk : process is
  begin
    adc_clk <= '0';
    wait for c_CLK_PERIOD1 / 2;
    adc_clk <= '1';
    wait for c_CLK_PERIOD1 / 2;
  end process p_adc_clk;

---------------------------------------------------------------------
-- ADC sampling clock generation
---------------------------------------------------------------------
  p_adc_clk_phase : process is
    -- enable one time an instruction: add a phase
    variable v_first : integer := 1;
  begin
    -- add an initial: 90 degree phase
    if v_first = 1 then
      v_first := 0;
      wait for 1*c_CLK_PERIOD1 / 4;
    end if;
    i_adc_clk_p <= '0';
    i_adc_clk_n <= '1';
    -- on the rising edge, keep only the even bit
    wait for c_CLK_PERIOD1 / 2;

    i_adc_clk_p <= '1';
    i_adc_clk_n <= '0';
    -- on the rising edge, keep only the even bit
    wait for c_CLK_PERIOD1 / 2;

  end process p_adc_clk_phase;

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
    if g_VUNIT_DEBUG = true then
      -- the simulator doesn't stop on errors => stop on failure
      set_stop_level(failure);
    end if;

    show(get_logger("log:summary"), display_handler, pass);
    show(get_logger("check:data_count"), display_handler, pass);
    show(get_logger("check:errors"), display_handler, pass);
    --show(get_logger("check:reg:data"), display_handler, pass);

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
  end process p_master_fsm;

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
  --   .pattern generation on adc0 and adc1
  ---------------------------------------------------------------------
  p_data_gen : process is
    -- state value (to alternate 2 values)
    variable v_first : integer := 0;
  begin
    -- counter
    data0 <= data0 + 1;

    -- alternate values:
    --    "01010101010101"
    --    "10101010101010"
    if v_first = 0 then
      data1   <= "01010101010101";
      v_first := 1;
    else
      data1   <= "10101010101010";
      v_first := 0;
    end if;

    wait until rising_edge(adc_clk);
    wait for 12 ps;
  end process p_data_gen;

---------------------------------------------------------------------
-- Select bits according to the edge clock
---------------------------------------------------------------------
  p_data_select_bits_by_edge_clk : process is
  begin
    -- on rising_edge: set the even bits
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
    -- on falling_edge: set the even bits
    i_da0_p  <= data0(1);
    i_da0_n  <= not(data0(1));
    i_da2_p  <= data0(3);
    i_da2_n  <= not(data0(3));
    i_da4_p  <= data0(5);
    i_da4_n  <= not(data0(5));
    i_da6_p  <= data0(7);
    i_da6_n  <= not(data0(7));
    i_da8_p  <= data0(9);
    i_da8_n  <= not(data0(9));
    i_da10_p <= data0(11);
    i_da10_n <= not(data0(11));
    i_da12_p <= data0(13);
    i_da12_n <= not(data0(13));

    i_db0_p  <= data1(1);
    i_db0_n  <= not(data1(1));
    i_db2_p  <= data1(3);
    i_db2_n  <= not(data1(3));
    i_db4_p  <= data1(5);
    i_db4_n  <= not(data1(5));
    i_db6_p  <= data1(7);
    i_db6_n  <= not(data1(7));
    i_db8_p  <= data1(9);
    i_db8_n  <= not(data1(9));
    i_db10_p <= data1(11);
    i_db10_n <= not(data1(11));
    i_db12_p <= data1(13);
    i_db12_n <= not(data1(13));

    wait until falling_edge(adc_clk);


  end process p_data_select_bits_by_edge_clk;


  ---------------------------------------------------------------------
  -- DUT
  ---------------------------------------------------------------------
  inst_system_fpasim_top : entity fpasim.system_fpasim_top
    generic map (
      g_DEBUG => false
      )
    port map(
      --  Opal Kelly inouts --
      i_okUH         => i_okUH,
      o_okHU         => o_okHU,
      b_okUHU        => b_okUHU,
      b_okAA         => b_okAA,
      ---------------------------------------------------------------------
      -- FMC: from the card
      ---------------------------------------------------------------------
      --i_board_id        => i_board_id,  -- card board id
      ---------------------------------------------------------------------
      -- FMC: from the adc
      ---------------------------------------------------------------------
      i_clk_ab_p     => i_adc_clk_p,    -- differential clock p @250MHz
      i_clk_ab_n     => i_adc_clk_n,    -- differential clock n @250MHZ
      -- adc_a
      -- bit P/N: 0-1
      i_cha_00_p     => i_da0_p,
      i_cha_00_n     => i_da0_n,
      i_cha_02_p     => i_da2_p,
      i_cha_02_n     => i_da2_n,
      i_cha_04_p     => i_da4_p,
      i_cha_04_n     => i_da4_n,
      i_cha_06_p     => i_da6_p,
      i_cha_06_n     => i_da6_n,
      i_cha_08_p     => i_da8_p,
      i_cha_08_n     => i_da8_n,
      i_cha_10_p     => i_da10_p,
      i_cha_10_n     => i_da10_n,
      i_cha_12_p     => i_da12_p,
      i_cha_12_n     => i_da12_n,
      -- adc_b
      i_chb_00_p     => i_db0_p,
      i_chb_00_n     => i_db0_n,
      i_chb_02_p     => i_db2_p,
      i_chb_02_n     => i_db2_n,
      i_chb_04_p     => i_db4_p,
      i_chb_04_n     => i_db4_n,
      i_chb_06_p     => i_db6_p,
      i_chb_06_n     => i_db6_n,
      i_chb_08_p     => i_db8_p,
      i_chb_08_n     => i_db8_n,
      i_chb_10_p     => i_db10_p,
      i_chb_10_n     => i_db10_n,
      i_chb_12_p     => i_db12_p,
      i_chb_12_n     => i_db12_n,
      ---------------------------------------------------------------------
      -- FMC: to sync
      ---------------------------------------------------------------------
      o_clk_ref      => o_ref_clk,
      o_clk_frame    => o_sync,
      ---------------------------------------------------------------------
      -- FMC: to dac
      ---------------------------------------------------------------------
      o_dac_dclk_p   => o_dac_clk_p,
      o_dac_dclk_n   => o_dac_clk_n,
      o_frame_p      => o_dac_frame_p,
      o_frame_n      => o_dac_frame_n,
      o_dac_d0_p     => o_dac0_p,
      o_dac_d0_n     => o_dac0_n,
      o_dac_d1_p     => o_dac1_p,
      o_dac_d1_n     => o_dac1_n,
      o_dac_d2_p     => o_dac2_p,
      o_dac_d2_n     => o_dac2_n,
      o_dac_d3_p     => o_dac3_p,
      o_dac_d3_n     => o_dac3_n,
      o_dac_d4_p     => o_dac4_p,
      o_dac_d4_n     => o_dac4_n,
      o_dac_d5_p     => o_dac5_p,
      o_dac_d5_n     => o_dac5_n,
      o_dac_d6_p     => o_dac6_p,
      o_dac_d6_n     => o_dac6_n,
      o_dac_d7_p     => o_dac7_p,
      o_dac_d7_n     => o_dac7_n,
      ---------------------------------------------------------------------
      -- devices: spi links + specific signals
      ---------------------------------------------------------------------
      -- common: shared link between the spi
      o_spi_sclk     => o_spi_sclk,     -- Shared SPI clock line
      o_spi_sdata    => o_spi_sdata,    -- Shared SPI MOSI
      -- CDCE: SPI
      i_cdce_sdo     => i_cdce_sdo,     -- SPI MISO
      o_cdce_n_en    => o_cdce_n_en,    -- SPI chip select
      -- CDCE: specific signals
      i_pll_status   => i_cdce_pll_status,  -- pll_status : This pin is set high if the PLL is in lock.
      o_cdce_n_reset => o_cdce_n_reset,     -- reset_n or hold_n
      o_cdce_n_pd    => o_cdce_n_pd,    -- power_down_n
      o_ref_en       => o_ref_en,       -- enable the primary reference clock
      -- ADC: SPI
      i_adc_sdo      => i_adc_sdo,      -- SPI MISO
      o_adc_n_en     => o_adc_n_en,     -- SPI chip select
      -- ADC: specific signals
      o_adc_reset    => o_adc_reset,    -- adc hardware reset
      -- DAC: SPI
      i_dac_sdo      => i_dac_sdo,      -- SPI MISO
      o_dac_n_en     => o_dac_n_en,     -- SPI chip select
      -- DAC: specific signal
      o_tx_enable    => o_dac_tx_present,   -- enable tx acquisition
      -- AMC: SPI (monitoring)
      i_mon_sdo      => i_mon_sdo,      -- SPI data out
      o_mon_n_en     => o_mon_n_en,     -- SPI chip select
      -- AMC : specific signals
      i_mon_n_int    => i_mon_n_int,  -- galr_n: Global analog input out-of-range alarm.
      o_mon_n_reset  => o_mon_n_reset,  -- reset_n: hardware reset

      ---------------------------------------------------------------------
      -- leds
      ---------------------------------------------------------------------
      o_leds         => o_leds,
      o_led_fw       => o_led_fw,
      o_led_pll_lock => o_led_pll_lock,

      ---------------------------------------------------------------------
      -- FMC: to oscillo
      ---------------------------------------------------------------------
      -- first processed sample of a pulse
      o_trig_oscillo => o_trig_oscillo
      );

---------------------------------------------------------------------
-- spi management
---------------------------------------------------------------------
  gen_SPI_READBACK : if true generate
    -- output value
    signal data_tmp0 : std_logic;
  begin

    inst_pipeliner : entity fpasim.pipeliner
      generic map(
        g_NB_PIPES   => 1,
        g_DATA_WIDTH => 1
        )
      port map(
        i_clk     => i_adc_clk_p,
        i_data(0) => o_spi_sdata,
        o_data(0) => data_tmp0
        );

    i_cdce_sdo <= data_tmp0;
    i_adc_sdo  <= data_tmp0;
    i_dac_sdo  <= data_tmp0;
    i_mon_sdo  <= data_tmp0;


  end generate gen_SPI_READBACK;


  ---------------------------------------------------------------------
  -- log: data out
  ---------------------------------------------------------------------
  gen_log_ram_pulse_shape : if g_ENABLE_LOG = true generate
    -- ram address
    signal addr       : std_logic_vector(15 downto 0);
    -- ram data
    signal data       : std_logic_vector(15 downto 0);
    -- ram data valid
    signal data_valid : std_logic;
  begin
    addr       <= o_data(31 downto 16);
    data       <= o_data(15 downto 0);
    data_valid <= o_data_valid when o_reg_id = 0 else '0';

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

  gen_log_ram_amp_squid_tf : if g_ENABLE_LOG = true generate
    -- ram address
    signal addr       : std_logic_vector(15 downto 0);
    -- ram data
    signal data       : std_logic_vector(15 downto 0);
    -- ram data valid
    signal data_valid : std_logic;
  begin
    addr       <= o_data(31 downto 16);
    data       <= o_data(15 downto 0);
    data_valid <= o_data_valid when o_reg_id = 1 else '0';

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
      i_DATA1_TYP      => "INT",
      ---------------------------------------------------------------------
      -- signals to log
      ---------------------------------------------------------------------
      i_data_valid     => data_valid,
      i_data0_std_vect => addr,
      i_data1_std_vect => data
      );

  end generate gen_log_ram_amp_squid_tf;

  gen_log_ram_mux_squid_tf : if g_ENABLE_LOG = true generate
    -- ram address
    signal addr       : std_logic_vector(15 downto 0);
    -- ram data
    signal data       : std_logic_vector(15 downto 0);
    -- ram data valid
    signal data_valid : std_logic;
  begin
    addr       <= o_data(31 downto 16);
    data       <= o_data(15 downto 0);
    data_valid <= o_data_valid when o_reg_id = 2 else '0';

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

  gen_log_ram_tes_steady_state : if g_ENABLE_LOG = true generate
    -- ram address
    signal addr       : std_logic_vector(15 downto 0);
    -- ram data
    signal data       : std_logic_vector(15 downto 0);
    -- ram data valid
    signal data_valid : std_logic;
  begin
    addr       <= o_data(31 downto 16);
    data       <= o_data(15 downto 0);
    data_valid <= o_data_valid when o_reg_id = 3 else '0';

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

  gen_log_ram_mux_squid_offset : if g_ENABLE_LOG = true generate
    -- ram address
    signal addr       : std_logic_vector(15 downto 0);
    -- ram data
    signal data       : std_logic_vector(15 downto 0);
    -- ram data valid
    signal data_valid : std_logic;
  begin
    addr       <= o_data(31 downto 16);
    data       <= o_data(15 downto 0);
    data_valid <= o_data_valid when o_reg_id = 4 else '0';

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
      i_DATA1_TYP      => "INT",
      ---------------------------------------------------------------------
      -- signals to log
      ---------------------------------------------------------------------
      i_data_valid     => data_valid,
      i_data0_std_vect => addr,
      i_data1_std_vect => data
      );

  end generate gen_log_ram_mux_squid_offset;

end Simulation;
