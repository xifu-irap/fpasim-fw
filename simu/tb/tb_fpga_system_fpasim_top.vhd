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
--    @file                   tb_fpga_system_fpasim_top.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--     Testbench of the fpga_system_fpasim_top module.
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
use common_lib.pkg_common.all;

use ieee.fixed_pkg.all;
use ieee.fixed_float_types.all;

entity tb_fpga_system_fpasim_top is
  generic(
    runner_cfg           : string  := runner_cfg_default;  -- vunit generic: don't touch
    output_path          : string  := "C:/Project/fpasim-fw-hardware/";  -- vunit generic: don't touch
    ---------------------------------------------------------------------
    -- DUT generic
    ---------------------------------------------------------------------
    -- ADC
    g_ADC_VPP            : natural := 2;  -- ADC differential input voltage ( Vpp expressed in Volts)
    g_ADC_DELAY          : natural := 0;  -- ADC conversion delay
    -- DAC
    g_DAC_VPP            : natural := 2;  -- DAC differential output voltage ( Vpp expressed in Volts)
    g_DAC_DELAY          : natural := 0;  -- DAC conversion delay
    -- design parameters
    g_FPASIM_GAIN        : natural := 3;  -- 0:0.25, 1:0.5, 3:1, 4:1.5, 5:2, 6:3, 7:4
    g_MUX_SQ_FB_DELAY    : natural := 0;  -- [0;(2**6) - 1]
    g_AMP_SQ_OF_DELAY    : natural := 1;  -- [0;(2**6) - 1]
    g_ERROR_DELAY        : natural := 4;  -- [0;(2**6) - 1]
    g_RA_DELAY           : natural := 4;  -- [0;(2**6) - 1]
    g_INTER_SQUID_GAIN   : natural := 255;  -- inter squid gain. The range is: [0;(2**8) - 1]
    g_NB_PIXEL_BY_FRAME  : natural := 34; -- number of pixel by frame. The range is : [1;pkg_MUX_FACT_MAX(64)]
    g_NB_SAMPLE_BY_PIXEL : natural := 40; -- number of sample by pixel. The range is [1;pkg_NB_SAMPLE_BY_PIXEL_MAX(64)]

    ---------------------------------------------------------------------
    -- simulation parameters
    ---------------------------------------------------------------------
    g_VUNIT_DEBUG : boolean  := true; -- true: stop simulator on failures, false: stop the simulator on errors.
    g_TEST_NAME   : string   := ""; -- name of the test
    g_ENABLE_CHECK: boolean  := true;-- true: compare the simulation output with the reference one, false: do nothing.
    g_ENABLE_LOG  : boolean  := true-- true: save simulation data in files, false: don't save simulation data in files
    );
end tb_fpga_system_fpasim_top;

architecture Simulation of tb_fpga_system_fpasim_top is


  ---------------------------------------------------------------------
  -- command
  ---------------------------------------------------------------------
  -- valid make_pulse command
  signal i_make_pulse_valid : std_logic                     := '0';
  -- make_pulse command value
  signal i_make_pulse       : std_logic_vector(31 downto 0) := (others => '0');
  -- busy: '1' processing in progress, '0': otherwise
  signal o_auto_conf_busy   : std_logic;
  -- ready
  signal o_ready            : std_logic;
  ---------------------------------------------------------------------
  -- ADC
  ---------------------------------------------------------------------
  -- adc clock associated to the data
  signal adc_clk            : std_logic;
  -- adc clock
  signal adc_clk_phase      : std_logic;
  -- adc0 data (real value)
  signal i_adc0_real        : real;
  -- adc1 data (real value)
  signal i_adc1_real        : real;
  ---------------------------------------------------------------------
  -- to sync
  ---------------------------------------------------------------------
  -- ref clock
  signal o_ref_clk          : std_logic;
  -- clk_frame (sync signal)
  signal o_sync             : std_logic;
  ---------------------------------------------------------------------
  -- to DAC
  ---------------------------------------------------------------------
  -- dac valid
  signal o_dac_real_valid   : std_logic;
  -- dac data (real value)
  signal o_dac_real         : real;

  ---------------------------------------------------------------------
  -- additional signals
  ---------------------------------------------------------------------
  -- Clocks
  -- data0 to generate
  signal data0 : unsigned(13 downto 0) := (others => '0');
  -- data1 to generate
  signal data1 : unsigned(13 downto 0) := (others => '0');

  -- data0 (sfixed representation)
  signal s_data0 : sfixed(0 downto -13) := (others => '0');
  -- data1 (sfixed representation)
  signal s_data1 : sfixed(0 downto -13) := (others => '0');

  ---------------------------------------------------------------------
  -- Clock definition
  ---------------------------------------------------------------------
  -- clock period duration.
  constant c_CLK_PERIOD0 : time := 4 ns;


begin

  ---------------------------------------------------------------------
  -- ADC data clock generation
  ---------------------------------------------------------------------
  p_adc_clk : process is
  begin
    adc_clk <= '0';
    wait for c_CLK_PERIOD0 / 2;
    adc_clk <= '1';
    wait for c_CLK_PERIOD0 / 2;
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
      wait for 1*c_CLK_PERIOD0 / 4;
    end if;
    adc_clk_phase <= '0';
    -- on the rising edge, keep only the even bit
    wait for c_CLK_PERIOD0 / 2;

    adc_clk_phase <= '1';
    -- on the rising edge, keep only the even bit
    wait for c_CLK_PERIOD0 / 2;

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

    pkg_wait_nb_rising_edge_plus_margin(i_clk => adc_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    info("Test bench: Generic parameter values");
    info("    output_path = " & output_path);
    info("    g_ADC_VPP = " & to_string(g_ADC_VPP));
    info("    g_ADC_DELAY = " & to_string(g_ADC_DELAY));
    info("    g_DAC_VPP = " & to_string(g_DAC_VPP));
    info("    g_DAC_DELAY = " & to_string(g_DAC_DELAY));
    info("    g_FPASIM_GAIN = " & to_string(g_FPASIM_GAIN));
    info("    g_MUX_SQ_FB_DELAY = " & to_string(g_MUX_SQ_FB_DELAY));
    info("    g_AMP_SQ_OF_DELAY = " & to_string(g_AMP_SQ_OF_DELAY));
    info("    g_ERROR_DELAY = " & to_string(g_ERROR_DELAY));
    info("    g_RA_DELAY = " & to_string(g_RA_DELAY));
    info("    g_NB_PIXEL_BY_FRAME = " & to_string(g_NB_PIXEL_BY_FRAME));
    info("    g_NB_SAMPLE_BY_PIXEL = " & to_string(g_NB_SAMPLE_BY_PIXEL));

    -- simulator paramters
    info("    g_VUNIT_DEBUG = " & to_string(g_VUNIT_DEBUG));
    info("    g_TEST_NAME = " & g_TEST_NAME);
    info("    g_ENABLE_CHECK = " & to_string(g_ENABLE_CHECK));
    info("    g_ENABLE_LOG = " & to_string(g_ENABLE_LOG));

    ---------------------------------------------------------------------
    -- add tempo
    ---------------------------------------------------------------------
    pkg_wait_nb_rising_edge_plus_margin(i_clk => adc_clk, i_nb_rising_edge => 16, i_margin => 12 ps);

    ---------------------------------------------------------------------
    -- End of simulation: wait few more clock cycles
    ---------------------------------------------------------------------
    info("Wait end of simulation");
    wait for 16368 * c_CLK_PERIOD0;

    pkg_wait_nb_rising_edge_plus_margin(i_clk => adc_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    if runner_cfg'length > 0 then
      test_runner_cleanup(runner);      -- Simulation ends here
    else
      std.env.stop;
    end if;
  end process p_master_fsm;

  ---------------------------------------------------------------------
  -- Data Generation
  --   .pattern generation on adc0 and adc1
  ---------------------------------------------------------------------
  p_data_gen : process is
    -- state value (to alternate 2 values)
    variable v_first : integer := 0;
  begin
    -- alternate values:
    --    "01010101010101"
    --    "10101010101010"
    if v_first = 0 then
      data0   <= "01010101010101";
      v_first := 1;
    else
      data0   <= "10101010101010";
      v_first := 0;
    end if;
    -- counter
    data1 <= data1 + 1;

    wait until rising_edge(adc_clk);
    wait for 12 ps;
  end process p_data_gen;

-- convert std_logic_vector to sfixed [-1;0.99[
  s_data0 <= sfixed(data0);
  s_data1 <= sfixed(data1);

-- convert to float with upscale
  gen_convert : if true generate
    -- multiplicator factor
    constant c_FACTOR : real := real(g_ADC_VPP)/2.0;
  begin
    i_adc0_real <= c_FACTOR * To_real(s_data0);
    i_adc1_real <= c_FACTOR * To_real(s_data1);

  end generate gen_convert;


  ---------------------------------------------------------------------
  -- DUT
  ---------------------------------------------------------------------
  inst_fpga_system_fpasim_top : entity fpasim.fpga_system_fpasim_top
    generic map(
      -- ADC
      g_ADC_VPP            => g_ADC_VPP,  -- ADC differential input voltage ( Vpp expressed in Volts)
      g_ADC_DELAY          => g_ADC_DELAY,    -- ADC conversion delay
      -- DAC
      g_DAC_VPP            => g_DAC_VPP,  -- DAC differential output voltage ( Vpp expressed in Volts)
      g_DAC_DELAY          => g_DAC_DELAY,    -- DAC conversion delay
      -- design parameters
      g_FPASIM_GAIN        => g_FPASIM_GAIN,  -- 0:0.25, 1:0.5, 3:1, 4:1.5, 5:2, 6:3, 7:4
      g_MUX_SQ_FB_DELAY    => g_MUX_SQ_FB_DELAY,  -- [0;(2**6) - 1]
      g_AMP_SQ_OF_DELAY    => g_AMP_SQ_OF_DELAY,  -- [0;(2**6) - 1]
      g_ERROR_DELAY        => g_ERROR_DELAY,  -- [0;(2**6) - 1]
      g_RA_DELAY           => g_RA_DELAY,     -- [0;(2**6) - 1]
      g_INTER_SQUID_GAIN   => g_INTER_SQUID_GAIN,
      g_NB_PIXEL_BY_FRAME  => g_NB_PIXEL_BY_FRAME,
      g_NB_SAMPLE_BY_PIXEL => g_NB_SAMPLE_BY_PIXEL
      )
    port map(
      ---------------------------------------------------------------------
      -- command
      ---------------------------------------------------------------------
      i_make_pulse_valid => i_make_pulse_valid,
      i_make_pulse       => i_make_pulse,
      o_auto_conf_busy   => o_auto_conf_busy,
      o_ready            => o_ready,
      ---------------------------------------------------------------------
      -- ADC
      ---------------------------------------------------------------------
      i_adc_clk_phase    => adc_clk_phase,
      i_adc_clk          => adc_clk,
      i_adc0_real        => i_adc0_real,
      i_adc1_real        => i_adc1_real,
      ---------------------------------------------------------------------
      -- to sync
      ---------------------------------------------------------------------
      o_ref_clk          => o_ref_clk,
      o_sync             => o_sync,
      ---------------------------------------------------------------------
      -- to DAC
      ---------------------------------------------------------------------
      o_dac_real_valid   => o_dac_real_valid,
      o_dac_real         => o_dac_real
      );





end Simulation;
