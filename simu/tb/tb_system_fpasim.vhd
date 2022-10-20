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
use ieee.std_logic_textio.all;

library std;  -- @suppress "Superfluous library clause: access to library 'std' is implicit"
use std.textio.all;

library fpasim;

library opal_kelly_lib;
use opal_kelly_lib.pkg_front_panel;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_system_fpasim is
  generic(
  	runner_cfg : string := ""; -- don't touch
    input_basepath_g  : string := "C:/Project/fpasim-fw-hardware/Inputs/";
    output_basepath_g : string := "C:/Project/fpasim-fw-hardware/Outputs/";

  	---------------------------------------------------------------------
    -- simulation parameter
    ---------------------------------------------------------------------
    VUNIT_DEBUG_g  : boolean := true;
    TEST_NAME_g    : string  := "";
    ENABLE_CHECK_g : boolean := true;
    ENABLE_LOG_g   : boolean := true
  	);
end tb_system_fpasim;

architecture simulate of tb_system_fpasim is

  ---------------------------------------------------------------------
  -- module input signals
  ---------------------------------------------------------------------
  
  -- FMC: from the adc
  ---------------------------------------------------------------------
  signal i_adc_clk_p   : std_logic;     --  differential clock p @250MHz
  signal i_adc_clk_n   : std_logic;     --  differential clock n @250MHZ
  -- adc_a
  -- bit P/N: 0-1
  signal i_da0_p       : std_logic;
  signal i_da0_n       : std_logic;
  signal i_da2_p       : std_logic;
  signal i_da2_n       : std_logic;
  signal i_da4_p       : std_logic;
  signal i_da4_n       : std_logic;
  signal i_da6_p       : std_logic;
  signal i_da6_n       : std_logic;
  signal i_da8_p       : std_logic;
  signal i_da8_n       : std_logic;
  signal i_da10_p      : std_logic;
  signal i_da10_n      : std_logic;
  signal i_da12_p      : std_logic;
  signal i_da12_n      : std_logic;
  -- adc_b
  signal i_db0_p       : std_logic;
  signal i_db0_n       : std_logic;
  signal i_db2_p       : std_logic;
  signal i_db2_n       : std_logic;
  signal i_db4_p       : std_logic;
  signal i_db4_n       : std_logic;
  signal i_db6_p       : std_logic;
  signal i_db6_n       : std_logic;
  signal i_db8_p       : std_logic;
  signal i_db8_n       : std_logic;
  signal i_db10_p      : std_logic;
  signal i_db10_n      : std_logic;
  signal i_db12_p      : std_logic;
  signal i_db12_n      : std_logic;

  -- FMC: to sync
  ---------------------------------------------------------------------
  signal o_ref_clk     : std_logic;
  signal o_sync        : std_logic;

  -- FMC: to dac
  ---------------------------------------------------------------------
  signal o_dac_clk_p   : std_logic;
  signal o_dac_clk_n   : std_logic;
  signal o_dac_frame_p : std_logic;
  signal o_dac_frame_n : std_logic;
  signal o_dac0_p      : std_logic;
  signal o_dac0_n      : std_logic;
  signal o_dac1_p      : std_logic;
  signal o_dac1_n      : std_logic;
  signal o_dac2_p      : std_logic;
  signal o_dac2_n      : std_logic;
  signal o_dac3_p      : std_logic;
  signal o_dac3_n      : std_logic;
  signal o_dac4_p      : std_logic;
  signal o_dac4_n      : std_logic;
  signal o_dac5_p      : std_logic;
  signal o_dac5_n      : std_logic;
  signal o_dac6_p      : std_logic;
  signal o_dac6_n      : std_logic;
  signal o_dac7_p      : std_logic;
  signal o_dac7_n      : std_logic;

  signal data0 : unsigned(13 downto 0) := (others => '0');
  signal data1 : unsigned(13 downto 0) := (others => '0');

  ---------------------------------------------------------------------
  -- additional signals
  ---------------------------------------------------------------------
  -- Clocks
  signal usb_clk : std_logic := '0';
  signal sys_clk : std_logic := '0';

  --  Opal Kelly inouts --
  signal okUH          : std_logic_vector(4 downto 0);
  signal okHU          : std_logic_vector(2 downto 0);
  signal okUHU         : std_logic_vector(31 downto 0);
  signal okAA          : std_logic;

  ---------------------------------------------------------------------
  -- Clock definition
  ---------------------------------------------------------------------
  constant c_CLK_PERIOD0    : time := 5 ns;
  constant c_CLK_PERIOD1    : time := 5 ns;

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


  signal usb_if1 : opal_kelly_lib.pkg_front_panel.t_internal_if := opal_kelly_lib.pkg_front_panel.init_internal_if(0);


begin

  ---------------------------------------------------------------------
  -- Clock generation
  ---------------------------------------------------------------------
  p_usb_clk_gen : process is
  begin
    usb_clk <= '0';
    wait for c_CLK_PERIOD0/2;
    usb_clk <= '1';
    wait for c_CLK_PERIOD0/2;
  end process p_usb_clk_gen;

  p_sys_clk : process is
  begin
    sys_clk <= '0';
    wait for c_CLK_PERIOD1/2;
    sys_clk <= '1';
    wait for c_CLK_PERIOD1/2;
  end process p_sys_clk;

  -- Simulation Process
  sim_process : process is
    constant BlockDelayStates1 : integer := 5;
    constant ReadyCheckDelay1  : integer := 5;
    constant PostReadyDelay1   : integer := 5;
    constant pipeInSize1       : integer := 5;
    constant pipeOutSize1      : integer := 5;
    constant registerSetSize1  : integer := 5;

    variable front_panel_conf1 : opal_kelly_lib.pkg_front_panel.t_front_panel_conf(
      pipeIn(0 to pipeInSize1 - 1),
      pipeOut(0 to pipeOutSize1 - 1),
      WireIns(0 to 31),
      WireOuts(0 to 31),
      Triggered(0 to 31),
      u32Address(0 to registerSetSize1 - 1),
      u32Data(0 to registerSetSize1 - 1)) := opal_kelly_lib.pkg_front_panel.init_front_panel_conf(
        BlockDelayStates => BlockDelayStates1,
        ReadyCheckDelay  => ReadyCheckDelay1,
        PostReadyDelay   => PostReadyDelay1,
        pipeInSize       => pipeInSize1,
        pipeOutSize      => pipeOutSize1,
        registerSetSize  => registerSetSize1
        );

  begin
    if runner_cfg'length > 0 then
      test_runner_setup(runner, runner_cfg);
    end if;

    ---------------------------------------------------------------------
    -- VUNIT - Scoreboard object : Visibility definition
    ---------------------------------------------------------------------
    if VUNIT_DEBUG_g = true then
      -- the simulator doesn't stop on errors
      set_stop_level(failure);
    end if;

    opal_kelly_lib.pkg_front_panel.FrontPanelReset(i_clk => usb_clk, front_panel_conf => front_panel_conf1, internal_if => usb_if1);
    wait for 1 ns;

    -- Reset LFSR
    --SetWireInValue(x"00", x"0000_0001", NO_MASK);
    --UpdateWireIns;
    --SetWireInValue(x"00", x"0000_0000", NO_MASK);
    --UpdateWireIns;

    --for j in 0 to 2 loop
    --  -- Select mode as LFSR to periodically read pseudo-random values
    --  Check_LFSR(MODE_LFSR);

    --  -- Select mode as Counter
    --  Check_LFSR(MODE_Counter);
    --end loop;

    ---- Read LFSR values in sequence using pipes
    --Check_PipeOut(MODE_LFSR);

    ---- Read Counter values in sequence using pipes
    --Check_PipeOut(MODE_COUNTER);

    ---- Send piped values back to FPGA
    --for i in 0 to pipeInSize - 1 loop
    --  pipeIn(i) := pipeOut(i);
    --end loop;
    --WriteToPipeIn(x"80", pipeInSize);

    ---- Send values to FPGA for storage and read them back
    --Check_Registers;

    wait for 10 us;
    if runner_cfg'length > 0 then
      test_runner_cleanup(runner);      -- Simulation ends here
    else
      std.env.stop;
    end if;
  end process;

  opal_kelly_lib.pkg_front_panel.okHost_driver(
    i_clk       => usb_clk,
    okUH        => okUH,
    okHU        => okHU,
    okUHU       => okUHU,
    internal_if => usb_if1
    );

  data_gen : process (sys_clk) is
  begin
    if rising_edge(sys_clk) then
      data0 <= data0 + 1;
      data1 <= data1 + 2;
    end if;
  end process data_gen;


  i_da0_p  <= data0(0);
  i_da0_n  <= data0(1);
  i_da2_p  <= data0(2);
  i_da2_n  <= data0(3);
  i_da4_p  <= data0(4);
  i_da4_n  <= data0(5);
  i_da6_p  <= data0(6);
  i_da6_n  <= data0(7);
  i_da8_p  <= data0(8);
  i_da8_n  <= data0(9);
  i_da10_p <= data0(10);
  i_da10_n <= data0(11);
  i_da12_p <= data0(12);
  i_da12_n <= data0(13);

  i_db0_p  <= data1(0);
  i_db0_n  <= data1(1);
  i_db2_p  <= data1(2);
  i_db2_n  <= data1(3);
  i_db4_p  <= data1(4);
  i_db4_n  <= data1(5);
  i_db6_p  <= data1(6);
  i_db6_n  <= data1(7);
  i_db8_p  <= data1(8);
  i_db8_n  <= data1(9);
  i_db10_p <= data1(10);
  i_db10_n <= data1(11);
  i_db12_p <= data1(12);
  i_db12_n <= data1(13);

  ---------------------------------------------------------------------
  -- DUT
  ---------------------------------------------------------------------
  i_adc_clk_p <= sys_clk;
  i_adc_clk_n <= not(sys_clk);

  top_fpasim_system_INST : entity fpasim.top_fpasim_system
    port map(
      --  Opal Kelly inouts --
      okUH          => okUH,
      okHU          => okHU,
      okUHU         => okUHU,
      okAA          => okAA,
      ---------------------------------------------------------------------
      -- FMC: from the adc
      ---------------------------------------------------------------------
      i_adc_clk_p   => i_adc_clk_p,     -- differential clock p @250MHz
      i_adc_clk_n   => i_adc_clk_n,     -- differential clock n @250MHZ
      -- adc_a
      -- bit P/N: 0-1
      i_da0_p       => i_da0_p,
      i_da0_n       => i_da0_n,
      i_da2_p       => i_da2_p,
      i_da2_n       => i_da2_n,
      i_da4_p       => i_da4_p,
      i_da4_n       => i_da4_n,
      i_da6_p       => i_da6_p,
      i_da6_n       => i_da6_n,
      i_da8_p       => i_da8_p,
      i_da8_n       => i_da8_n,
      i_da10_p      => i_da10_p,
      i_da10_n      => i_da10_n,
      i_da12_p      => i_da12_p,
      i_da12_n      => i_da12_n,
      -- adc_b
      i_db0_p       => i_db0_p,
      i_db0_n       => i_db0_n,
      i_db2_p       => i_db2_p,
      i_db2_n       => i_db2_n,
      i_db4_p       => i_db4_p,
      i_db4_n       => i_db4_n,
      i_db6_p       => i_db6_p,
      i_db6_n       => i_db6_n,
      i_db8_p       => i_db8_p,
      i_db8_n       => i_db8_n,
      i_db10_p      => i_db10_p,
      i_db10_n      => i_db10_n,
      i_db12_p      => i_db12_p,
      i_db12_n      => i_db12_n,
      ---------------------------------------------------------------------
      -- FMC: to sync
      ---------------------------------------------------------------------
      o_ref_clk     => o_ref_clk,
      o_sync        => o_sync,
      ---------------------------------------------------------------------
      -- FMC: to dac
      ---------------------------------------------------------------------
      o_dac_clk_p   => o_dac_clk_p,
      o_dac_clk_n   => o_dac_clk_n,
      o_dac_frame_p => o_dac_frame_p,
      o_dac_frame_n => o_dac_frame_n,
      o_dac0_p      => o_dac0_p,
      o_dac0_n      => o_dac0_n,
      o_dac1_p      => o_dac1_p,
      o_dac1_n      => o_dac1_n,
      o_dac2_p      => o_dac2_p,
      o_dac2_n      => o_dac2_n,
      o_dac3_p      => o_dac3_p,
      o_dac3_n      => o_dac3_n,
      o_dac4_p      => o_dac4_p,
      o_dac4_n      => o_dac4_n,
      o_dac5_p      => o_dac5_p,
      o_dac5_n      => o_dac5_n,
      o_dac6_p      => o_dac6_p,
      o_dac6_n      => o_dac6_n,
      o_dac7_p      => o_dac7_p,
      o_dac7_n      => o_dac7_n
      );

end simulate;
