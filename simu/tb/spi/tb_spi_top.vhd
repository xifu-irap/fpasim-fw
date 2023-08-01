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
--    @file                   tb_spi_top.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--   @details
--
--   Testbench of the spi_top module.
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library fpasim;
use fpasim.pkg_fpasim.all;
use fpasim.pkg_regdecode.all;

library vunit_lib;
context vunit_lib.vunit_context;

library common_lib;
context common_lib.common_context;


entity tb_spi_top is
  generic(
    runner_cfg      : string   := runner_cfg_default;  -- vunit generic: don't touch
    output_path     : string   := "C:/Project/fpasim-fw-hardware/";  -- vunit generic: don't touch
    ---------------------------------------------------------------------
    -- simulation parameter
    ---------------------------------------------------------------------
    g_RD_DELAY_CDCE : positive := 2; -- CDCE: delay on the spi bridge read path
    g_RD_DELAY_ADC  : positive := 2; -- ADC: delay on the spi bridge read path
    g_RD_DELAY_DAC  : positive := 2; -- DAC: delay on the spi bridge read path
    g_RD_DELAY_AMC  : positive := 2; -- AMC: delay on the spi bridge read path

    ---------------------------------------------------------------------
    -- simulation parameters
    ---------------------------------------------------------------------
    g_VUNIT_DEBUG  : boolean := true; -- set the simulation stop level
    g_TEST_NAME    : string  := ""; -- name of the test
    g_ENABLE_CHECK : boolean := true; -- not used
    g_ENABLE_LOG   : boolean := true -- not used
    );
end tb_spi_top;

architecture Simulation of tb_spi_top is

  signal i_clk                : std_logic;  --  clock
  signal i_rst                : std_logic                     := '0';  --  reset
  signal i_rst_status         : std_logic                     := '0';  --  reset error flag(s)
  signal i_debug_pulse        : std_logic                     := '0';  --  error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
  ---------------------------------------------------------------------
  -- command
  ---------------------------------------------------------------------
  -- input
  signal i_spi_en             : std_logic                     := '0';  --  enable the spi
  signal i_spi_dac_tx_present : std_logic                     := '0';  --  1:enable dac data tx, 0: otherwise
  signal i_spi_mode           : std_logic                     := '0';  --  1:wr, 0:rd
  signal i_spi_id             : std_logic_vector(1 downto 0)  := (others => '0');  --  spi identifier: "00":cdece,"01": adc,"10":dac,"11":amc
  signal i_spi_cmd_valid      : std_logic                     := '0';  --  command valid
  signal i_spi_cmd_wr_data    : std_logic_vector(31 downto 0) := (others => '0');  --  data to write
  -- output
  signal o_spi_rd_data_valid  : std_logic;  --  read data valid
  signal o_spi_rd_data        : std_logic_vector(31 downto 0);  --  read data
  signal o_spi_ready          : std_logic;  --  1: all spi links are ready,0: one of the spi link is busy
  signal o_reg_spi_status     : std_logic_vector(31 downto 0); -- spi status (register format)
  ---------------------------------------------------------------------
  -- errors/status
  ---------------------------------------------------------------------
  signal o_errors             : std_logic_vector(15 downto 0); -- errors
  signal o_status             : std_logic_vector(7 downto 0); -- status
  ---------------------------------------------------------------------
  -- from/to the IOs
  ---------------------------------------------------------------------
  -- common: shared link between the spi
  signal o_spi_sclk           : std_logic;  --  Shared SPI clock line
  signal o_spi_sdata          : std_logic;  --  Shared SPI MOSI
  -- CDCE: SPI
  signal i_cdce_sdo           : std_logic;  --  SPI MISO
  signal o_cdce_n_en          : std_logic;  --  SPI chip select
  -- CDCE: specific signals
  signal i_cdce_pll_status    : std_logic;  --  pll_status : This pin is set high if the PLL is in lock.
  signal o_cdce_n_reset       : std_logic;  --  reset_n or hold_n
  signal o_cdce_n_pd          : std_logic;  --  power_down_n
  signal o_ref_en             : std_logic;  --  enable the primary reference clock
  -- ADC: SPI
  signal i_adc_sdo            : std_logic;  --  SPI MISO
  signal o_adc_n_en           : std_logic;  --  SPI chip select
  -- ADC: specific signals
  signal o_adc_reset          : std_logic;  --  adc hardware reset
  -- DAC: SPI
  signal i_dac_sdo            : std_logic;  --  SPI MISO
  signal o_dac_n_en           : std_logic;  --  SPI chip select
  -- DAC: specific signal
  signal o_dac_tx_present     : std_logic;  --  enable tx acquisition
  -- AMC: SPI (monitoring)
  signal i_mon_sdo            : std_logic;  --  SPI data out
  signal o_mon_n_en           : std_logic;  --  SPI chip select
  -- AMC : specific signals
  signal i_mon_n_int          : std_logic;  --  galr_n: Global analog input out-of-range alarm.
  signal o_mon_n_reset        : std_logic;  --  reset_n: hardware reset

  ---------------------------------------------------------------------
  -- Clock definition
  ---------------------------------------------------------------------
  -- clock period duration
  constant c_CLK_PERIOD0 : time := 5 ns;  -- 200M

  ---------------------------------------------------------------------
  -- VUnit Scoreboard objects
  ---------------------------------------------------------------------
  -- Vunit logger for the summary
  constant c_LOGGER_SUMMARY      : logger_t  := get_logger("log:summary");
  -- checkers
  -- vunit checker associated to the errors
  constant c_CHECKER_ERRORS      : checker_t := new_checker("check:errors");
  -- vunit checker associated to the errors for the cdce spi link
  constant c_CHECKER_ERRORS_CDCE : checker_t := new_checker("check:errors:cdce");
  -- vunit checker associated to the errors for the adc spi link
  constant c_CHECKER_ERRORS_ADC  : checker_t := new_checker("check:errors:adc");
  -- vunit checker associated to the errors for the dac spi link
  constant c_CHECKER_ERRORS_DAC  : checker_t := new_checker("check:errors:dac");
  -- vunit checker associated to the errors for the amc spi link
  constant c_CHECKER_ERRORS_AMC  : checker_t := new_checker("check:errors:amc");

begin

  ---------------------------------------------------------------------
  -- Clock generation
  ---------------------------------------------------------------------
  p_clk0_gen : process is
  begin
    i_clk <= '0';
    wait for c_CLK_PERIOD0 / 2;
    i_clk <= '1';
    wait for c_CLK_PERIOD0 / 2;
  end process p_clk0_gen;

  ---------------------------------------------------------------------
  -- master fsm
  ---------------------------------------------------------------------
  p_master_fsm : process is
    -- data value
    variable v_val : std_logic_vector(31 downto 0);

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
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    info("Test bench: Generic parameter values");
    info("    output_path = " & output_path);
    ---------------------------------------------------------------------
    -- DUT GENERIC
    ---------------------------------------------------------------------
    -- simulator paramters
    info("    g_VUNIT_DEBUG = " & to_string(g_VUNIT_DEBUG));
    info("    g_TEST_NAME = " & g_TEST_NAME);
    info("    g_ENABLE_CHECK = " & to_string(g_ENABLE_CHECK));
    info("    g_ENABLE_LOG = " & to_string(g_ENABLE_LOG));

    ---------------------------------------------------------------------
    -- reset
    ---------------------------------------------------------------------
    info("Enable the reset");
    i_rst         <= '1';
    i_rst_status  <= '1';
    i_debug_pulse <= '0';
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    info("Disable the reset");
    i_rst        <= '0';
    i_rst_status <= '0';
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);


    info("Start SPI");
    i_spi_en             <= '1';
    i_spi_dac_tx_present <= '0';
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 2, i_margin => 12 ps);

    info("wait ready on");
    wait on i_clk until o_spi_ready = '1';

    ---------------------------------------------------------------------
    -- CDCE
    ---------------------------------------------------------------------
    info("Configuration0: CDCE (reading)");
    i_spi_mode        <= '0';           -- 1:wr, 0:rd
    i_spi_id          <= (others => '0');  -- spi identifier: "00":cdece,"01": adc,"10":dac,"11":amc
    i_spi_cmd_valid   <= '1';
    v_val             := x"9876_4321";
    i_spi_cmd_wr_data <= v_val;
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    i_spi_cmd_valid <= '0';
    info("RD: wait end of reading access");
    wait on i_clk until o_spi_rd_data_valid = '1';
    if o_spi_rd_data_valid = '1' then
      check_equal(c_CHECKER_ERRORS_CDCE, v_val, o_spi_rd_data, result("CDCE: checker output errors"));
    end if;

    info("wait ready on");
    wait on i_clk until o_spi_ready = '1';

    ---------------------------------------------------------------------
    -- ADC
    ---------------------------------------------------------------------
    info("Configuration1: ADC (reading)");
    i_spi_mode        <= '0';           -- 1:wr, 0:rd
    i_spi_id          <= "01";  -- spi identifier: "00":cdece,"01": adc,"10":dac,"11":amc
    i_spi_cmd_valid   <= '1';
    v_val             := x"0000_9781";
    i_spi_cmd_wr_data <= v_val;
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    i_spi_cmd_valid <= '0';
    info("RD: wait end of reading access");
    wait on i_clk until o_spi_rd_data_valid = '1';
    if o_spi_rd_data_valid = '1' then
      check_equal(c_CHECKER_ERRORS_ADC, v_val, o_spi_rd_data, result("ADC: checker output errors"));
    end if;
    info("wait ready on");
    wait on i_clk until o_spi_ready = '1';

    ---------------------------------------------------------------------
    -- DAC
    ---------------------------------------------------------------------
    info("Configuration2: DAC (reading)");
    i_spi_mode        <= '0';           -- 1:wr, 0:rd
    i_spi_id          <= "10";  -- spi identifier: "00":cdece,"01": adc,"10":dac,"11":amc
    i_spi_cmd_valid   <= '1';
    v_val             := x"0000_9871";
    i_spi_cmd_wr_data <= v_val;
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    i_spi_cmd_valid <= '0';
    info("RD: wait end of reading access");
    wait on i_clk until o_spi_rd_data_valid = '1';
    if o_spi_rd_data_valid = '1' then
      check_equal(c_CHECKER_ERRORS_DAC, v_val, o_spi_rd_data, result("DAC: checker output errors"));
    end if;
    info("wait ready on");
    wait on i_clk until o_spi_ready = '1';

    ---------------------------------------------------------------------
    -- AMC
    ---------------------------------------------------------------------
    info("Configuration3: AMC (reading)");
    i_spi_mode        <= '0';           -- 1:wr, 0:rd
    i_spi_id          <= (others => '1');  -- spi identifier: "00":cdece,"01": adc,"10":dac,"11":amc
    i_spi_cmd_valid   <= '1';
    v_val             := x"9321_4321";
    i_spi_cmd_wr_data <= v_val;
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    i_spi_cmd_valid <= '0';
    info("RD: wait end of reading access");
    wait on i_clk until o_spi_rd_data_valid = '1';
    if o_spi_rd_data_valid = '1' then
      check_equal(c_CHECKER_ERRORS_AMC, v_val, o_spi_rd_data, result("AMC: checker output errors"));
    end if;
    info("wait ready on");
    wait on i_clk until o_spi_ready = '1';


    ---------------------------------------------------------------------
    -- CDCE
    ---------------------------------------------------------------------
    info("Configuration4: CDCE (reading)");
    i_spi_mode        <= '0';           -- 1:wr, 0:rd
    i_spi_id          <= (others => '0');  -- spi identifier: "00":cdece,"01": adc,"10":dac,"11":amc
    i_spi_cmd_valid   <= '1';
    v_val             := x"ABCD_EF01";
    i_spi_cmd_wr_data <= v_val;
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    i_spi_cmd_valid <= '0';
    info("RD: wait end of reading access");
    wait on i_clk until o_spi_rd_data_valid = '1';
    if o_spi_rd_data_valid = '1' then
      check_equal(c_CHECKER_ERRORS_CDCE, v_val, o_spi_rd_data, result("CDCE: checker output errors"));
    end if;
    info("wait ready on");
    wait on i_clk until o_spi_ready = '1';

    ---------------------------------------------------------------------
    -- CDCE
    ---------------------------------------------------------------------
    info("Configuration5: CDCE (reading)");
    i_spi_mode        <= '0';           -- 1:wr, 0:rd
    i_spi_id          <= (others => '0');  -- spi identifier: "00":cdece,"01": adc,"10":dac,"11":amc
    i_spi_cmd_valid   <= '1';
    v_val             := x"9BCD_EF01";
    i_spi_cmd_wr_data <= v_val;
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    i_spi_cmd_valid <= '0';
    info("RD: wait end of reading access");
    wait on i_clk until o_spi_rd_data_valid = '1';
    if o_spi_rd_data_valid = '1' then
      check_equal(c_CHECKER_ERRORS_CDCE, v_val, o_spi_rd_data, result("CDCE: checker output errors"));
    end if;
    info("wait ready on");
    wait on i_clk until o_spi_ready = '1';


    ---------------------------------------------------------------------
    -- ADC
    ---------------------------------------------------------------------
    info("Configuration6: ADC (reading)");
    i_spi_mode        <= '0';           -- 1:wr, 0:rd
    i_spi_id          <= "01";  -- spi identifier: "00":cdece,"01": adc,"10":dac,"11":amc
    i_spi_cmd_valid   <= '1';
    v_val             := x"0000_ABCD";
    i_spi_cmd_wr_data <= v_val;
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    i_spi_cmd_valid <= '0';
    info("RD: wait end of reading access");
    wait on i_clk until o_spi_rd_data_valid = '1';
    if o_spi_rd_data_valid = '1' then
      check_equal(c_CHECKER_ERRORS_ADC, v_val, o_spi_rd_data, result("ADC: checker output errors"));
    end if;
    info("wait ready on");
    wait on i_clk until o_spi_ready = '1';

    ---------------------------------------------------------------------
    -- ADC
    ---------------------------------------------------------------------
    info("Configuration7: ADC (reading)");
    i_spi_mode        <= '0';           -- 1:wr, 0:rd
    i_spi_id          <= "01";  -- spi identifier: "00":cdece,"01": adc,"10":dac,"11":amc
    i_spi_cmd_valid   <= '1';
    v_val             := x"0000_9871";
    i_spi_cmd_wr_data <= v_val;
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    i_spi_cmd_valid <= '0';
    info("RD: wait end of reading access");
    wait on i_clk until o_spi_rd_data_valid = '1';
    if o_spi_rd_data_valid = '1' then
      check_equal(c_CHECKER_ERRORS_ADC, v_val, o_spi_rd_data, result("ADC: checker output errors"));
    end if;
    info("wait ready on");
    wait on i_clk until o_spi_ready = '1';

    ---------------------------------------------------------------------
    -- DAC
    ---------------------------------------------------------------------
    info("Configuration8: DAC (reading)");
    i_spi_mode        <= '0';           -- 1:wr, 0:rd
    i_spi_id          <= "10";  -- spi identifier: "00":cdece,"01": adc,"10":dac,"11":amc
    i_spi_cmd_valid   <= '1';
    v_val             := x"0000_FBCE";
    i_spi_cmd_wr_data <= v_val;
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    i_spi_cmd_valid <= '0';
    info("RD: wait end of reading access");
    wait on i_clk until o_spi_rd_data_valid = '1';
    if o_spi_rd_data_valid = '1' then
      check_equal(c_CHECKER_ERRORS_DAC, v_val, o_spi_rd_data, result("DAC: checker output errors"));
    end if;
    info("wait ready on");
    wait on i_clk until o_spi_ready = '1';

    ---------------------------------------------------------------------
    -- DAC
    ---------------------------------------------------------------------
    info("Configuration9: DAC (reading)");
    i_spi_mode        <= '0';           -- 1:wr, 0:rd
    i_spi_id          <= "10";  -- spi identifier: "00":cdece,"01": adc,"10":dac,"11":amc
    i_spi_cmd_valid   <= '1';
    v_val             := x"0000_7801";
    i_spi_cmd_wr_data <= v_val;
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    i_spi_cmd_valid <= '0';
    info("RD: wait end of reading access");
    wait on i_clk until o_spi_rd_data_valid = '1';
    if o_spi_rd_data_valid = '1' then
      check_equal(c_CHECKER_ERRORS_DAC, v_val, o_spi_rd_data, result("DAC: checker output errors"));
    end if;
    info("wait ready on");
    wait on i_clk until o_spi_ready = '1';

    ---------------------------------------------------------------------
    -- AMC
    ---------------------------------------------------------------------
    info("Configuration10: AMC (reading)");
    i_spi_mode        <= '0';           -- 1:wr, 0:rd
    i_spi_id          <= (others => '1');  -- spi identifier: "00":cdece,"01": adc,"10":dac,"11":amc
    i_spi_cmd_valid   <= '1';
    v_val             := x"9BCD_EF01";
    i_spi_cmd_wr_data <= v_val;
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    i_spi_cmd_valid <= '0';
    info("RD: wait end of reading access");
    wait on i_clk until o_spi_rd_data_valid = '1';
    if o_spi_rd_data_valid = '1' then
      check_equal(c_CHECKER_ERRORS_AMC, v_val, o_spi_rd_data, result("AMC: checker output errors"));
    end if;
    info("wait ready on");
    wait on i_clk until o_spi_ready = '1';

    ---------------------------------------------------------------------
    -- AMC
    ---------------------------------------------------------------------
    info("Configuration11: AMC (reading)");
    i_spi_mode        <= '0';           -- 1:wr, 0:rd
    i_spi_id          <= (others => '1');  -- spi identifier: "00":cdece,"01": adc,"10":dac,"11":amc
    i_spi_cmd_valid   <= '1';
    v_val             := x"ABCD_4321";
    i_spi_cmd_wr_data <= v_val;
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    i_spi_cmd_valid <= '0';
    info("RD: wait end of reading access");
    wait on i_clk until o_spi_rd_data_valid = '1';
    if o_spi_rd_data_valid = '1' then
      check_equal(c_CHECKER_ERRORS_AMC, v_val, o_spi_rd_data, result("AMC: checker output errors"));
    end if;
    info("wait ready on");
    wait on i_clk until o_spi_ready = '1';





    ---------------------------------------------------------------------
    -- End of simulation: wait few more clock cycles
    ---------------------------------------------------------------------
    info("Wait end of simulation");
    wait for (2**16)*8* c_CLK_PERIOD0;
    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    ---------------------------------------------------------------------
    -- VUNIT - checking errors and summary
    ---------------------------------------------------------------------
    -- errors checking
    check_equal(c_CHECKER_ERRORS, 0, o_errors, result("checker output errors"));

    -- summary
    info(c_LOGGER_SUMMARY, "===Summary===" & LF &
         "c_CHECKER_ERRORS: " & to_string(get_checker_stat(c_CHECKER_ERRORS)) & LF &
         "c_CHECKER_ERRORS_CDCE: " & to_string(get_checker_stat(c_CHECKER_ERRORS_CDCE)) & LF &
         "c_CHECKER_ERRORS_ADC: " & to_string(get_checker_stat(c_CHECKER_ERRORS_ADC)) & LF &
         "c_CHECKER_ERRORS_DAC: " & to_string(get_checker_stat(c_CHECKER_ERRORS_DAC)) & LF &
         "c_CHECKER_ERRORS_AMC: " & to_string(get_checker_stat(c_CHECKER_ERRORS_AMC))
         );


    pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    if runner_cfg'length > 0 then
      test_runner_cleanup(runner);      -- Simulation ends here
    else
      std.env.stop;
    end if;
  end process p_master_fsm;

---------------------------------------------------------------------
-- DUT
---------------------------------------------------------------------
  inst_spi_top : entity fpasim.spi_top
    generic map(
      g_DEBUG => false
    )
    port map(
      i_clk                => i_clk,    -- clock
      i_rst                => i_rst,    -- reset
      i_rst_status         => i_rst_status,   -- reset error flag(s)
      i_debug_pulse        => i_debug_pulse,  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
      ---------------------------------------------------------------------
      -- command
      ---------------------------------------------------------------------
      -- input
      i_spi_en             => i_spi_en,  -- enable the spi
      i_spi_dac_tx_present => i_spi_dac_tx_present,  -- 1:enable dac data tx, 0: otherwise
      i_spi_mode           => i_spi_mode,   -- 1:wr, 0:rd
      i_spi_id             => i_spi_id,  -- spi identifier: "00":cdece,"01": adc,"10":dac,"11":amc
      i_spi_cmd_valid      => i_spi_cmd_valid,    -- command valid
      i_spi_cmd_wr_data    => i_spi_cmd_wr_data,  -- data to write
      -- output
      o_spi_rd_data_valid  => o_spi_rd_data_valid,   -- read data valid
      o_spi_rd_data        => o_spi_rd_data,  -- read data
      o_spi_ready          => o_spi_ready,  -- 1: all spi links are ready,0: one of the spi link is busy
      o_reg_spi_status     => o_reg_spi_status,
      ---------------------------------------------------------------------
      -- errors/status
      ---------------------------------------------------------------------
      o_errors             => o_errors,
      o_status             => o_status,
      ---------------------------------------------------------------------
      -- from/to the IOs
      ---------------------------------------------------------------------
      -- common: shared link between the spi
      o_spi_sclk           => o_spi_sclk,   -- Shared SPI clock line
      o_spi_sdata          => o_spi_sdata,  -- Shared SPI MOSI
      -- CDCE: SPI
      i_cdce_sdo           => i_cdce_sdo,   -- SPI MISO
      o_cdce_n_en          => o_cdce_n_en,  -- SPI chip select
      -- CDCE: specific signals
      i_cdce_pll_status    => i_cdce_pll_status,  -- pll_status : This pin is set high if the PLL is in lock.
      o_cdce_n_reset       => o_cdce_n_reset,     -- reset_n or hold_n
      o_cdce_n_pd          => o_cdce_n_pd,  -- power_down_n
      o_ref_en             => o_ref_en,  -- enable the primary reference clock
      -- ADC: SPI
      i_adc_sdo            => i_adc_sdo,    -- SPI MISO
      o_adc_n_en           => o_adc_n_en,   -- SPI chip select
      -- ADC: specific signals
      o_adc_reset          => o_adc_reset,  -- adc hardware reset
      -- DAC: SPI
      i_dac_sdo            => i_dac_sdo,    -- SPI MISO
      o_dac_n_en           => o_dac_n_en,   -- SPI chip select
      -- DAC: specific signal
      o_dac_tx_present     => o_dac_tx_present,   -- enable tx acquisition
      -- AMC: SPI (monitoring)
      i_mon_sdo            => i_mon_sdo,    -- SPI data out
      o_mon_n_en           => o_mon_n_en,   -- SPI chip select
      -- AMC : specific signals
      i_mon_n_int          => i_mon_n_int,  -- galr_n: Global analog input out-of-range alarm.
      o_mon_n_reset        => o_mon_n_reset   -- reset_n: hardware reset
      );

---------------------------------------------------------------------
-- reading:
--   loopback for the reading
---------------------------------------------------------------------

-- CDCE
---------------------------------------------------------------------
  gen_rd_loopback_cdce : if true generate
    -- input data
    signal data_tmp0 : std_logic_vector(0 downto 0);
    -- output data
    signal data_tmp1 : std_logic_vector(0 downto 0);
  begin
    data_tmp0(0) <= o_spi_sdata;
    inst_pipeliner : entity fpasim.pipeliner
      generic map(
        g_NB_PIPES   => g_RD_DELAY_CDCE,  -- number of consecutives registers. Possibles values: [0, integer max value[
        g_DATA_WIDTH => data_tmp0'length  -- width of the input/output data.  Possibles values: [1, integer max value[
        )
      port map(
        i_clk  => i_clk,
        i_data => data_tmp0,
        o_data => data_tmp1
        );
    i_cdce_sdo <= data_tmp1(0);
  end generate gen_rd_loopback_cdce;

-- ADC
---------------------------------------------------------------------
  gen_rd_loopback_adc : if true generate
    -- input data
    signal data_tmp0 : std_logic_vector(0 downto 0);
    -- output data
    signal data_tmp1 : std_logic_vector(0 downto 0);
  begin
    data_tmp0(0) <= o_spi_sdata;
    inst_pipeliner : entity fpasim.pipeliner
      generic map(
        g_NB_PIPES   => g_RD_DELAY_ADC,  -- number of consecutives registers. Possibles values: [0, integer max value[
        g_DATA_WIDTH => data_tmp0'length  -- width of the input/output data.  Possibles values: [1, integer max value[
        )
      port map(
        i_clk  => i_clk,
        i_data => data_tmp0,
        o_data => data_tmp1
        );
    i_adc_sdo <= data_tmp1(0);
  end generate gen_rd_loopback_adc;

-- DAC
---------------------------------------------------------------------
  gen_rd_loopback_dac : if true generate
    -- input data
    signal data_tmp0 : std_logic_vector(0 downto 0);
    -- output data
    signal data_tmp1 : std_logic_vector(0 downto 0);
  begin
    data_tmp0(0) <= o_spi_sdata;
    inst_pipeliner : entity fpasim.pipeliner
      generic map(
        g_NB_PIPES   => g_RD_DELAY_DAC,  -- number of consecutives registers. Possibles values: [0, integer max value[
        g_DATA_WIDTH => data_tmp0'length  -- width of the input/output data.  Possibles values: [1, integer max value[
        )
      port map(
        i_clk  => i_clk,
        i_data => data_tmp0,
        o_data => data_tmp1
        );
    i_dac_sdo <= data_tmp1(0);
  end generate gen_rd_loopback_dac;

-- AMC
---------------------------------------------------------------------
  gen_rd_loopback_amc : if true generate
    -- input data
    signal data_tmp0 : std_logic_vector(0 downto 0);
    -- output data
    signal data_tmp1 : std_logic_vector(0 downto 0);
  begin
    data_tmp0(0) <= o_spi_sdata;
    inst_pipeliner : entity fpasim.pipeliner
      generic map(
        g_NB_PIPES   => g_RD_DELAY_AMC,  -- number of consecutives registers. Possibles values: [0, integer max value[
        g_DATA_WIDTH => data_tmp0'length  -- width of the input/output data.  Possibles values: [1, integer max value[
        )
      port map(
        i_clk  => i_clk,
        i_data => data_tmp0,
        o_data => data_tmp1
        );
    i_mon_sdo <= data_tmp1(0);
  end generate gen_rd_loopback_amc;

end Simulation;
