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
use opal_kelly_lib.pkg_front_panel.all;

use fpasim.pkg_fpasim.all;

library vunit_lib;
context vunit_lib.vunit_context;

library common_lib;
context common_lib.common_context;

entity tb_system_fpasim_top is
  generic(
    runner_cfg                    : string   := runner_cfg_default; -- vunit generic: don't touch
    output_path                   : string   := "C:/Project/fpasim-fw-hardware/"; -- vunit generic: don't touch
    ---------------------------------------------------------------------
    -- DUT generic
    ---------------------------------------------------------------------

  	---------------------------------------------------------------------
    -- simulation parameters
    ---------------------------------------------------------------------
    
    g_VUNIT_DEBUG                 : boolean  := true;
    g_TEST_NAME                   : string   := "";
    g_ENABLE_CHECK                : boolean  := true;
    g_ENABLE_LOG                  : boolean  := true
  	);
end tb_system_fpasim_top;

architecture simulate of tb_system_fpasim_top is

  constant c_INPUT_BASEPATH  : string := output_path & "inputs/";
  constant c_OUTPUT_BASEPATH : string := output_path & "outputs/";

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
  signal okUH          : std_logic_vector(4 downto 0):= (others => '0');
  signal okHU          : std_logic_vector(2 downto 0):= (others => '0');
  signal okUHU         : std_logic_vector(31 downto 0);
  signal okAA          : std_logic:= '0';
  

  ---------------------------------------------------------------------
  -- Clock definition
  ---------------------------------------------------------------------
  constant c_CLK_PERIOD0 : time := 9.259 ns;
  constant c_CLK_PERIOD1    : time := 4 ns;
  ---------------------------------------------------------------------
  -- Generate reading sequence
  ---------------------------------------------------------------------

  -- data
  signal data_start             : std_logic := '0';
  signal data_rd_valid          : std_logic := '0';
  signal data_gen_finish        : std_logic := '0';
  signal data_valid             : std_logic := '0';
  signal data_count_in          : std_logic_vector(31 downto 0);
  signal data_count_overflow_in : std_logic;

  signal data_stop : std_logic := '0';

  ---------------------------------------------------------------------
  -- filepath definition
  ---------------------------------------------------------------------
  constant c_CSV_SEPARATOR             : character := ';';

  -- input data generation
  constant c_FILENAME_DATA_VALID_IN : string := "py_data_valid_sequencer_in.csv";
  constant c_FILEPATH_DATA_VALID_IN : string := c_INPUT_BASEPATH & c_FILENAME_DATA_VALID_IN;

  constant c_FILENAME_DATA_IN : string := "py_data_in.csv";
  constant c_FILEPATH_DATA_IN : string := c_INPUT_BASEPATH & c_FILENAME_DATA_IN;


  ---------------------------------------------------------------------
  -- VUnit Scoreboard objects
  ---------------------------------------------------------------------
  -- loggers 
  constant c_LOGGER_SUMMARY     : logger_t  := get_logger("log:summary");
  -- checkers
  constant c_CHECKER_ERRORS     : checker_t := new_checker("check:errors");
  constant c_CHECKER_DATA_COUNT : checker_t := new_checker("check:data_count");
  --constant c_CHECKER_RAM1       : checker_t := new_checker("check:ram1:ram_" & g_RAM1_NAME);
  --constant c_CHECKER_RAM2       : checker_t := new_checker("check:ram2:ram_" & g_RAM2_NAME);


  --signal usb_if0 : opal_kelly_lib.pkg_front_panel.t_internal_if := opal_kelly_lib.pkg_front_panel.init_internal_if(0);
  signal usb_wr_if0 : opal_kelly_lib.pkg_front_panel.t_internal_wr_if := (
                                                                          hi_drive=> '0',
                                                                          hi_cmd => (others => '0'),
                                                                          hi_dataout => (others => '0')
                                                                          );

  signal usb_rd_if0 : opal_kelly_lib.pkg_front_panel.t_internal_rd_if := (
                                                                          i_clk => '0',
                                                                          hi_busy=> '0',
                                                                          hi_datain => (others => '0')
                                                                          );


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



  ---------------------------------------------------------------------
  -- master fsm
  ---------------------------------------------------------------------
  p_master_fsm : process is
      variable v_NO_MASK : std_logic_vector(31 downto 0) := x"ffff_ffff";
      variable v_front_panel_conf : opal_kelly_lib.pkg_front_panel.t_front_panel_conf;
      variable v_tmp32 : std_logic_vector(31 downto 0);

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


    pkg_wait_nb_rising_edge_plus_margin(i_clk=> usb_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    info("Test bench: Generic parameter values");
    info("    output_path = " & output_path);

    -- simulator paramters
    info("    g_VUNIT_DEBUG = " & to_string(g_VUNIT_DEBUG));
    info("    g_TEST_NAME = " & g_TEST_NAME);
    info("    g_ENABLE_CHECK = " & to_string(g_ENABLE_CHECK));
    info("    g_ENABLE_LOG = " & to_string(g_ENABLE_LOG));

    info("Test bench: input files");
    info("    c_FILEPATH_DATA_VALID_IN = " & c_FILEPATH_DATA_VALID_IN);
    info("    c_FILEPATH_DATA_IN = " & c_FILEPATH_DATA_IN);


    ---------------------------------------------------------------------
    -- reset
    ---------------------------------------------------------------------
    info("Reset the USB core");
    opal_kelly_lib.pkg_front_panel.FrontPanelReset(
                                                   --i_clk => usb_clk,
                                                   front_panel_conf => v_front_panel_conf,
                                                   internal_wr_if => usb_wr_if0,
                                                   internal_rd_if => usb_rd_if0
                                                   );
    info("end FrontPanelReset");
    pkg_wait_nb_rising_edge_plus_margin(i_clk=> usb_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    


    ---------------------------------------------------------------------
    -- Data Generation
    ---------------------------------------------------------------------
    info("Start data Generation");
    data_start <= '1';
    pkg_wait_nb_rising_edge_plus_margin(i_clk=> usb_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    info("Start: SetWireInValue");
    SetWireInValue(ep=>x"00" ,val=>x"0000_0001" ,mask=> v_NO_MASK ,front_panel_conf=> v_front_panel_conf);

    ---------------------------------------------------------------------
    -- Set a WireIn
    ---------------------------------------------------------------------
    info("End: SetWireInValue");
    info("Start: UpdateWireIns");
    UpdateWireIns(
                  --i_clk=>usb_clk,
                  front_panel_conf=> v_front_panel_conf,
                  internal_wr_if => usb_wr_if0,
                  internal_rd_if => usb_rd_if0);
    info("End UpdateWireIns");

    ---------------------------------------------------------------------
    -- Set a Trigger
    ---------------------------------------------------------------------
    info("Start: ActivateTriggerIn");
    ActivateTriggerIn(
                      --i_clk=> usb_clk,
                      ep=> x"40",
                      bit=>12,
                      internal_wr_if => usb_wr_if0,
                      internal_rd_if => usb_rd_if0
                   );
    info("End: ActivateTriggerIn");


    ---------------------------------------------------------------------
    -- add tempo
    ---------------------------------------------------------------------
    pkg_wait_nb_rising_edge_plus_margin(i_clk=> usb_clk, i_nb_rising_edge => 16, i_margin => 12 ps);


    ---------------------------------------------------------------------
    -- Read WireOut
    ---------------------------------------------------------------------
    info("Start: UpdateWireOuts");
    UpdateWireOuts(
        --i_clk            => usb_clk,
        front_panel_conf => v_front_panel_conf,
        internal_wr_if   => usb_wr_if0,
        internal_rd_if   => usb_rd_if0
        );
    info("End: UpdateWireOuts");

    info("Start: GetWireOutValue");
    v_tmp32:= GetWireOutValue(
        ep  => x"20",
        front_panel_conf => v_front_panel_conf);
    info("End: GetWireOutValue: " & to_string(v_tmp32) );

    ---------------------------------------------------------------------
    -- write pipe
    ---------------------------------------------------------------------
    v_front_panel_conf.pipeIn(0):= x"CA";
    v_front_panel_conf.pipeIn(1):= x"DE";
    v_front_panel_conf.pipeIn(2):= x"00";
    v_front_panel_conf.pipeIn(3):= x"00";
    WriteToPipeIn(
        --i_clk => usb_clk,
        ep    => x"80",
        length => 4,--write length expressed in bytes
        front_panel_conf => v_front_panel_conf,
        internal_wr_if   => usb_wr_if0,
        internal_rd_if   => usb_rd_if0
        );



    ---------------------------------------------------------------------
    -- End of simulation: wait few more clock cycles
    ---------------------------------------------------------------------
    info("Wait end of simulation");
    wait for 4096 * c_CLK_PERIOD0;
    data_stop <= '1';
    pkg_wait_nb_rising_edge_plus_margin(i_clk=> usb_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    ---------------------------------------------------------------------
    -- VUNIT - checking errors and summary
    ---------------------------------------------------------------------
    -- errors checking
    --info("Check results:");
    --val_v := to_integer(unsigned(o_errors));

    --check_equal(c_CHECKER_ERRORS, 0, val_v, result("checker output errors"));
    --check_equal(c_CHECKER_DATA_COUNT, data_count_in, data_count_out, result("checker input/output data count"));

    ---- summary
    --info(c_LOGGER_SUMMARY, "===Summary===" & LF &
    -- "c_CHECKER_RAM1: " & to_string(get_checker_stat(c_CHECKER_RAM1)) & LF &
    --  "c_CHECKER_RAM2: " & to_string(get_checker_stat(c_CHECKER_RAM2)) & LF &
    --   "c_CHECKER_ERRORS: " & to_string(get_checker_stat(c_CHECKER_ERRORS)) & LF &
    --    "CHECKER_DATA_COUNT_c: " & to_string(get_checker_stat(c_CHECKER_DATA_COUNT))
    --);

    pkg_wait_nb_rising_edge_plus_margin(i_clk=> usb_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

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
  --opal_kelly_lib.pkg_front_panel.okHost_driver(
  --  i_clk       => usb_clk,
  --  okUH        => okUH,
  --  okHU        => okHU,
  --  okUHU       => okUHU,
  --  internal_if => usb_if0
  --  );
  --okUH(0)          <= usb_clk;
  --okUH(1)          <= usb_if0.hi_drive;
  --okUH(4 downto 2) <= usb_if0.hi_cmd; 
  --okUHU            <= usb_if0.hi_dataout when (usb_if0.hi_drive = '1') else (others => 'Z');
  --usb_if0.hi_datain        <= okUHU;
  --usb_if0.hi_busy          <= okHU(0); 

  opal_kelly_lib.pkg_front_panel.okHost_driver(
    i_clk       => usb_clk,
    okUH        => okUH,
    okHU        => okHU,
    okUHU       => okUHU,
    internal_wr_if => usb_wr_if0,
    internal_rd_if => usb_rd_if0
    );

  -- okUH(0)          <= usb_clk;
  --okUH(1)          <= usb_wr_if0.hi_drive;
  --okUH(4 downto 2) <= usb_wr_if0.hi_cmd; 
  --okUHU            <= usb_wr_if0.hi_dataout when (usb_wr_if0.hi_drive = '1') else (others => 'Z');
  --usb_rd_if0.hi_datain        <= okUHU;
  --usb_rd_if0.hi_busy          <= okHU(0); 


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

  dut_top_fpasim_system : entity fpasim.top_fpasim_system
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


  ---------------------------------------------------------------------
  -- log: data out
  ---------------------------------------------------------------------
  gen_log : if g_ENABLE_LOG = true generate
    signal pixel_sof_vect_tmp : std_logic_vector(0 downto 0);
    signal pixel_eof_vect_tmp : std_logic_vector(0 downto 0);
    signal frame_sof_vect_tmp : std_logic_vector(0 downto 0);
    signal frame_eof_vect_tmp : std_logic_vector(0 downto 0);
  begin
    --pixel_sof_vect_tmp(0) <= o_pixel_sof;
    --pixel_eof_vect_tmp(0) <= o_pixel_eof;
    --frame_sof_vect_tmp(0) <= o_frame_sof;
    --frame_eof_vect_tmp(0) <= o_frame_eof;

    --gen_log_by_id : for i in 0 to g_NB_PIXEL_BY_FRAME - 1 generate
    --  constant c_FILEPATH_DATA_OUT : string := c_OUTPUT_BASEPATH & "vhdl_data_out" & to_string(i) & ".csv";
    --  signal data_valid            : std_logic;
    --begin
    --  data_valid <= o_pixel_valid when to_integer(unsigned(o_pixel_id)) = i else '0';

    --  inst_pkg_log_data_in_file : pkg_log_data_in_file_7(
    --    i_clk              => i_clk,
    --    i_start            => data_start,
    --    i_stop             => data_stop,
    --    ---------------------------------------------------------------------
    --    -- output file
    --    ---------------------------------------------------------------------
    --    i_filepath         => c_FILEPATH_DATA_OUT,
    --    i_csv_separator    => c_CSV_SEPARATOR,
    --    i_NAME0            => "pixel_sof",
    --    i_NAME1            => "pixel_eof",
    --    i_NAME2            => "pixel_id",
    --    i_NAME3            => "pixel_result",
    --    i_NAME4            => "frame_sof",
    --    i_NAME5            => "frame_eof",
    --    i_NAME6            => "frame_id",
    --    --  common typ = "UINT" => the std_logic_vector value is converted into unsigned int representation
    --    --  common typ = "INT" => the std_logic_vector value is converted into signed int representation
    --    --  common typ = "HEX" => the std_logic_vector value is considered as a signed vector, then it's converted into hex representation
    --    --  common typ = "UHEX" => the std_logic_vector value is considered as a unsigned vector, then it's converted into hex representation
    --    --  common typ = "STD_VEC" => the std_logic_vector value is not converted
    --    i_DATA0_COMMON_TYP => "UINT",
    --    i_DATA1_COMMON_TYP => "UINT",
    --    i_DATA2_COMMON_TYP => "UINT",
    --    i_DATA3_COMMON_TYP => "HEX",
    --    i_DATA4_COMMON_TYP => "UINT",
    --    i_DATA5_COMMON_TYP => "UINT",
    --    i_DATA6_COMMON_TYP => "UINT",
    --    ---------------------------------------------------------------------
    --    -- signals to log
    --    ---------------------------------------------------------------------
    --    i_data_valid       => data_valid,
    --    i_data0_std_vect   => pixel_sof_vect_tmp,
    --    i_data1_std_vect   => pixel_eof_vect_tmp,
    --    i_data2_std_vect   => o_pixel_id,
    --    i_data3_std_vect   => o_pixel_result,
    --    i_data4_std_vect   => frame_sof_vect_tmp,
    --    i_data5_std_vect   => frame_eof_vect_tmp,
    --    i_data6_std_vect   => o_frame_id
    --  );

    --end generate gen_log_by_id;

  end generate gen_log;

end simulate;
