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
--    @file                   pkg_log.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details                
--
-- Note: This package should be compiled into the utility_lib
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library csv_lib;
use csv_lib.pkg_csv_file.all;

library utility_lib;
use utility_lib.pkg_common.all;


package pkg_log is


  ---------------------------------------------------------------------
-- This function allows to build column label of the *.csv file
---------------------------------------------------------------------
 --  common typ = "UINT" => the std_logic_vector value is converted into unsigned int representation
 --  common typ = "INT" => the std_logic_vector value is converted into signed int representation
 --  common typ = "HEX" => the std_logic_vector value is considered as a signed vector, then it's converted into hex representation
 --  common typ = "UHEX" => the std_logic_vector value is considered as a unsigned vector, then it's converted into hex representation
 --  common typ = "STD_VEC" => the std_logic_vector value is not converted
  function column_name(constant i_NAME  : in string; constant i_DATA_COMMON_TYP  : in string := "INT") return string;


---------------------------------------------------------------------
  -- log_data_in_file1
  ---------------------------------------------------------------------
  procedure log_data_in_file1(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath                  : in string;
    i_csv_separator             : in character;
    constant i_NAME0            : in string;
    --  common typ = "UINT" => the std_logic_vector value is converted into unsigned int representation
    --  common typ = "INT" => the std_logic_vector value is converted into signed int representation
    --  common typ = "HEX" => the std_logic_vector value is considered as a signed vector, then it's converted into hex representation
    --  common typ = "UHEX" => the std_logic_vector value is considered as a unsigned vector, then it's converted into hex representation
    --  common typ = "STD_VEC" => the std_logic_vector value is not converted
    constant i_DATA0_COMMON_TYP : in string := "INT";

    ---------------------------------------------------------------------
    -- signal to log
    ---------------------------------------------------------------------
    signal i_data_valid     : in std_logic;
    signal i_data0_std_vect : in std_logic_vector
    );


  ---------------------------------------------------------------------
  -- log_data_in_file2
  ---------------------------------------------------------------------
  procedure log_data_in_file2(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath                  : in string;
    i_csv_separator             : in character;
    constant i_NAME0            : in string;
    constant i_NAME1            : in string;
    --  common typ = "UINT" => the std_logic_vector value is converted into unsigned int representation
    --  common typ = "INT" => the std_logic_vector value is converted into signed int representation
    --  common typ = "HEX" => the std_logic_vector value is converted into hex representation
    --  common typ = "STD_VEC" => the std_logic_vector value is not converted
    constant i_DATA0_COMMON_TYP : in string := "INT";
    constant i_DATA1_COMMON_TYP : in string := "INT";

    ---------------------------------------------------------------------
    -- signal to log
    ---------------------------------------------------------------------
    signal i_data_valid     : in std_logic;
    signal i_data0_std_vect : in std_logic_vector;
    signal i_data1_std_vect : in std_logic_vector
    );

---------------------------------------------------------------------
  -- log_data_in_file3
  ---------------------------------------------------------------------
  procedure log_data_in_file3(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath                  : in string;
    i_csv_separator             : in character;
    constant i_NAME0            : in string;
    constant i_NAME1            : in string;
    constant i_NAME2            : in string;
    --  common typ = "UINT" => the std_logic_vector value is converted into unsigned int representation
    --  common typ = "INT" => the std_logic_vector value is converted into signed int representation
    --  common typ = "HEX" => the std_logic_vector value is considered as a signed vector, then it's converted into hex representation
    --  common typ = "UHEX" => the std_logic_vector value is considered as a unsigned vector, then it's converted into hex representation
    --  common typ = "STD_VEC" => the std_logic_vector value is not converted
    constant i_DATA0_COMMON_TYP : in string := "INT";
    constant i_DATA1_COMMON_TYP : in string := "INT";
    constant i_DATA2_COMMON_TYP : in string := "INT";

    ---------------------------------------------------------------------
    -- signal to log
    ---------------------------------------------------------------------
    signal i_data_valid     : in std_logic;
    signal i_data0_std_vect : in std_logic_vector;
    signal i_data1_std_vect : in std_logic_vector;
    signal i_data2_std_vect : in std_logic_vector
    );

---------------------------------------------------------------------
  -- log_data_in_file4
  ---------------------------------------------------------------------
  procedure log_data_in_file4(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0            : in string;
    constant i_NAME1            : in string;
    constant i_NAME2            : in string;
    constant i_NAME3            : in string;
    --  common typ = "UINT" => the std_logic_vector value is converted into unsigned int representation
    --  common typ = "INT" => the std_logic_vector value is converted into signed int representation
    --  common typ = "HEX" => the std_logic_vector value is considered as a signed vector, then it's converted into hex representation
    --  common typ = "UHEX" => the std_logic_vector value is considered as a unsigned vector, then it's converted into hex representation
    --  common typ = "STD_VEC" => the std_logic_vector value is not converted
    constant i_DATA0_COMMON_TYP : in string := "INT";
    constant i_DATA1_COMMON_TYP : in string := "INT";
    constant i_DATA2_COMMON_TYP : in string := "INT";
    constant i_DATA3_COMMON_TYP : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal i_data_valid         : in std_logic;
    signal i_data0_std_vect     : in std_logic_vector;
    signal i_data1_std_vect     : in std_logic_vector;
    signal i_data2_std_vect     : in std_logic_vector;
    signal i_data3_std_vect     : in std_logic_vector
    );


---------------------------------------------------------------------
  -- log_data_in_file5
  ---------------------------------------------------------------------
  procedure log_data_in_file5(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0            : in string;
    constant i_NAME1            : in string;
    constant i_NAME2            : in string;
    constant i_NAME3            : in string;
    constant i_NAME4            : in string;
    --  common typ = "UINT" => the std_logic_vector value is converted into unsigned int representation
    --  common typ = "INT" => the std_logic_vector value is converted into signed int representation
    --  common typ = "HEX" => the std_logic_vector value is considered as a signed vector, then it's converted into hex representation
    --  common typ = "UHEX" => the std_logic_vector value is considered as a unsigned vector, then it's converted into hex representation
    --  common typ = "STD_VEC" => the std_logic_vector value is not converted
    constant i_DATA0_COMMON_TYP : in string := "INT";
    constant i_DATA1_COMMON_TYP : in string := "INT";
    constant i_DATA2_COMMON_TYP : in string := "INT";
    constant i_DATA3_COMMON_TYP : in string := "INT";
    constant i_DATA4_COMMON_TYP : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal i_data_valid         : in std_logic;
    signal i_data0_std_vect     : in std_logic_vector;
    signal i_data1_std_vect     : in std_logic_vector;
    signal i_data2_std_vect     : in std_logic_vector;
    signal i_data3_std_vect     : in std_logic_vector;
    signal i_data4_std_vect     : in std_logic_vector
    );

---------------------------------------------------------------------
  -- log_data_in_file6
  ---------------------------------------------------------------------
  procedure log_data_in_file6(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0            : in string;
    constant i_NAME1            : in string;
    constant i_NAME2            : in string;
    constant i_NAME3            : in string;
    constant i_NAME4            : in string;
    constant i_NAME5            : in string;
    --  common typ = "UINT" => the std_logic_vector value is converted into unsigned int representation
    --  common typ = "INT" => the std_logic_vector value is converted into signed int representation
    --  common typ = "HEX" => the std_logic_vector value is considered as a signed vector, then it's converted into hex representation
    --  common typ = "UHEX" => the std_logic_vector value is considered as a unsigned vector, then it's converted into hex representation
    --  common typ = "STD_VEC" => the std_logic_vector value is not converted
    constant i_DATA0_COMMON_TYP : in string := "INT";
    constant i_DATA1_COMMON_TYP : in string := "INT";
    constant i_DATA2_COMMON_TYP : in string := "INT";
    constant i_DATA3_COMMON_TYP : in string := "INT";
    constant i_DATA4_COMMON_TYP : in string := "INT";
    constant i_DATA5_COMMON_TYP : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal i_data_valid         : in std_logic;
    signal i_data0_std_vect     : in std_logic_vector;
    signal i_data1_std_vect     : in std_logic_vector;
    signal i_data2_std_vect     : in std_logic_vector;
    signal i_data3_std_vect     : in std_logic_vector;
    signal i_data4_std_vect     : in std_logic_vector;
    signal i_data5_std_vect     : in std_logic_vector
    );

  ---------------------------------------------------------------------
  -- log_data_in_file7
  ---------------------------------------------------------------------
  procedure log_data_in_file7(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0            : in string;
    constant i_NAME1            : in string;
    constant i_NAME2            : in string;
    constant i_NAME3            : in string;
    constant i_NAME4            : in string;
    constant i_NAME5            : in string;
    constant i_NAME6            : in string;
    --  common typ = "UINT" => the std_logic_vector value is converted into unsigned int representation
    --  common typ = "INT" => the std_logic_vector value is converted into signed int representation
    --  common typ = "HEX" => the std_logic_vector value is considered as a signed vector, then it's converted into hex representation
    --  common typ = "UHEX" => the std_logic_vector value is considered as a unsigned vector, then it's converted into hex representation
    --  common typ = "STD_VEC" => the std_logic_vector value is not converted
    constant i_DATA0_COMMON_TYP : in string := "INT";
    constant i_DATA1_COMMON_TYP : in string := "INT";
    constant i_DATA2_COMMON_TYP : in string := "INT";
    constant i_DATA3_COMMON_TYP : in string := "INT";
    constant i_DATA4_COMMON_TYP : in string := "INT";
    constant i_DATA5_COMMON_TYP : in string := "INT";
    constant i_DATA6_COMMON_TYP : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal i_data_valid         : in std_logic;
    signal i_data0_std_vect     : in std_logic_vector;
    signal i_data1_std_vect     : in std_logic_vector;
    signal i_data2_std_vect     : in std_logic_vector;
    signal i_data3_std_vect     : in std_logic_vector;
    signal i_data4_std_vect     : in std_logic_vector;
    signal i_data5_std_vect     : in std_logic_vector;
    signal i_data6_std_vect     : in std_logic_vector
    );

  ---------------------------------------------------------------------
  -- log_data_in_file8
  ---------------------------------------------------------------------
  procedure log_data_in_file8(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0            : in string;
    constant i_NAME1            : in string;
    constant i_NAME2            : in string;
    constant i_NAME3            : in string;
    constant i_NAME4            : in string;
    constant i_NAME5            : in string;
    constant i_NAME6            : in string;
    constant i_NAME7            : in string;
    --  common typ = "UINT" => the std_logic_vector value is converted into unsigned int representation
    --  common typ = "INT" => the std_logic_vector value is converted into signed int representation
    --  common typ = "HEX" => the std_logic_vector value is considered as a signed vector, then it's converted into hex representation
    --  common typ = "UHEX" => the std_logic_vector value is considered as a unsigned vector, then it's converted into hex representation
    --  common typ = "STD_VEC" => the std_logic_vector value is not converted
    constant i_DATA0_COMMON_TYP : in string := "INT";
    constant i_DATA1_COMMON_TYP : in string := "INT";
    constant i_DATA2_COMMON_TYP : in string := "INT";
    constant i_DATA3_COMMON_TYP : in string := "INT";
    constant i_DATA4_COMMON_TYP : in string := "INT";
    constant i_DATA5_COMMON_TYP : in string := "INT";
    constant i_DATA6_COMMON_TYP : in string := "INT";
    constant i_DATA7_COMMON_TYP : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal i_data_valid         : in std_logic;
    signal i_data0_std_vect     : in std_logic_vector;
    signal i_data1_std_vect     : in std_logic_vector;
    signal i_data2_std_vect     : in std_logic_vector;
    signal i_data3_std_vect     : in std_logic_vector;
    signal i_data4_std_vect     : in std_logic_vector;
    signal i_data5_std_vect     : in std_logic_vector;
    signal i_data6_std_vect     : in std_logic_vector;
    signal i_data7_std_vect     : in std_logic_vector
    );

---------------------------------------------------------------------
  -- log_data_in_file10
  ---------------------------------------------------------------------
  procedure log_data_in_file10(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0            : in string;
    constant i_NAME1            : in string;
    constant i_NAME2            : in string;
    constant i_NAME3            : in string;
    constant i_NAME4            : in string;
    constant i_NAME5            : in string;
    constant i_NAME6            : in string;
    constant i_NAME7            : in string;
    constant i_NAME8            : in string;
    constant i_NAME9            : in string;
    --  common typ = "UINT" => the std_logic_vector value is converted into unsigned int representation
    --  common typ = "INT" => the std_logic_vector value is converted into signed int representation
    --  common typ = "HEX" => the std_logic_vector value is considered as a signed vector, then it's converted into hex representation
    --  common typ = "UHEX" => the std_logic_vector value is considered as a unsigned vector, then it's converted into hex representation
    --  common typ = "STD_VEC" => the std_logic_vector value is not converted
    constant i_DATA0_COMMON_TYP : in string := "INT";
    constant i_DATA1_COMMON_TYP : in string := "INT";
    constant i_DATA2_COMMON_TYP : in string := "INT";
    constant i_DATA3_COMMON_TYP : in string := "INT";
    constant i_DATA4_COMMON_TYP : in string := "INT";
    constant i_DATA5_COMMON_TYP : in string := "INT";
    constant i_DATA6_COMMON_TYP : in string := "INT";
    constant i_DATA7_COMMON_TYP : in string := "INT";
    constant i_DATA8_COMMON_TYP : in string := "INT";
    constant i_DATA9_COMMON_TYP : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal i_data_valid         : in std_logic;
    signal i_data0_std_vect     : in std_logic_vector;
    signal i_data1_std_vect     : in std_logic_vector;
    signal i_data2_std_vect     : in std_logic_vector;
    signal i_data3_std_vect     : in std_logic_vector;
    signal i_data4_std_vect     : in std_logic_vector;
    signal i_data5_std_vect     : in std_logic_vector;
    signal i_data6_std_vect     : in std_logic_vector;
    signal i_data7_std_vect     : in std_logic_vector;
    signal i_data8_std_vect     : in std_logic_vector;
    signal i_data9_std_vect     : in std_logic_vector
    );

---------------------------------------------------------------------
  -- log_data_in_file11
  ---------------------------------------------------------------------
  procedure log_data_in_file11(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0             : in string;
    constant i_NAME1             : in string;
    constant i_NAME2             : in string;
    constant i_NAME3             : in string;
    constant i_NAME4             : in string;
    constant i_NAME5             : in string;
    constant i_NAME6             : in string;
    constant i_NAME7             : in string;
    constant i_NAME8             : in string;
    constant i_NAME9             : in string;
    constant i_NAME10            : in string;
    --  common typ = "UINT" => the std_logic_vector value is converted into unsigned int representation
    --  common typ = "INT" => the std_logic_vector value is converted into signed int representation
    --  common typ = "HEX" => the std_logic_vector value is considered as a signed vector, then it's converted into hex representation
    --  common typ = "UHEX" => the std_logic_vector value is considered as a unsigned vector, then it's converted into hex representation
    --  common typ = "STD_VEC" => the std_logic_vector value is not converted
    constant i_DATA0_COMMON_TYP  : in string := "INT";
    constant i_DATA1_COMMON_TYP  : in string := "INT";
    constant i_DATA2_COMMON_TYP  : in string := "INT";
    constant i_DATA3_COMMON_TYP  : in string := "INT";
    constant i_DATA4_COMMON_TYP  : in string := "INT";
    constant i_DATA5_COMMON_TYP  : in string := "INT";
    constant i_DATA6_COMMON_TYP  : in string := "INT";
    constant i_DATA7_COMMON_TYP  : in string := "INT";
    constant i_DATA8_COMMON_TYP  : in string := "INT";
    constant i_DATA9_COMMON_TYP  : in string := "INT";
    constant i_DATA10_COMMON_TYP : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal i_data_valid          : in std_logic;

    signal i_data0_std_vect  : in std_logic_vector;
    signal i_data1_std_vect  : in std_logic_vector;
    signal i_data2_std_vect  : in std_logic_vector;
    signal i_data3_std_vect  : in std_logic_vector;
    signal i_data4_std_vect  : in std_logic_vector;
    signal i_data5_std_vect  : in std_logic_vector;
    signal i_data6_std_vect  : in std_logic_vector;
    signal i_data7_std_vect  : in std_logic_vector;
    signal i_data8_std_vect  : in std_logic_vector;
    signal i_data9_std_vect  : in std_logic_vector;
    signal i_data10_std_vect : in std_logic_vector
    );


---------------------------------------------------------------------
  -- log_data_in_file13
  ---------------------------------------------------------------------
  procedure log_data_in_file13(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0             : in string;
    constant i_NAME1             : in string;
    constant i_NAME2             : in string;
    constant i_NAME3             : in string;
    constant i_NAME4             : in string;
    constant i_NAME5             : in string;
    constant i_NAME6             : in string;
    constant i_NAME7             : in string;
    constant i_NAME8             : in string;
    constant i_NAME9             : in string;
    constant i_NAME10            : in string;
    constant i_NAME11            : in string;
    constant i_NAME12            : in string;
    --  common typ = "UINT" => the std_logic_vector value is converted into unsigned int representation
    --  common typ = "INT" => the std_logic_vector value is converted into signed int representation
    --  common typ = "HEX" => the std_logic_vector value is considered as a signed vector, then it's converted into hex representation
    --  common typ = "UHEX" => the std_logic_vector value is considered as a unsigned vector, then it's converted into hex representation
    --  common typ = "STD_VEC" => the std_logic_vector value is not converted
    constant i_DATA0_COMMON_TYP  : in string := "INT";
    constant i_DATA1_COMMON_TYP  : in string := "INT";
    constant i_DATA2_COMMON_TYP  : in string := "INT";
    constant i_DATA3_COMMON_TYP  : in string := "INT";
    constant i_DATA4_COMMON_TYP  : in string := "INT";
    constant i_DATA5_COMMON_TYP  : in string := "INT";
    constant i_DATA6_COMMON_TYP  : in string := "INT";
    constant i_DATA7_COMMON_TYP  : in string := "INT";
    constant i_DATA8_COMMON_TYP  : in string := "INT";
    constant i_DATA9_COMMON_TYP  : in string := "INT";
    constant i_DATA10_COMMON_TYP : in string := "INT";
    constant i_DATA11_COMMON_TYP : in string := "INT";
    constant i_DATA12_COMMON_TYP : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal i_data_valid          : in std_logic;
    signal i_data0_std_vect      : in std_logic_vector;
    signal i_data1_std_vect      : in std_logic_vector;
    signal i_data2_std_vect      : in std_logic_vector;
    signal i_data3_std_vect      : in std_logic_vector;
    signal i_data4_std_vect      : in std_logic_vector;
    signal i_data5_std_vect      : in std_logic_vector;
    signal i_data6_std_vect      : in std_logic_vector;
    signal i_data7_std_vect      : in std_logic_vector;
    signal i_data8_std_vect      : in std_logic_vector;
    signal i_data9_std_vect      : in std_logic_vector;
    signal i_data10_std_vect     : in std_logic_vector;
    signal i_data11_std_vect     : in std_logic_vector;
    signal i_data12_std_vect     : in std_logic_vector
    );



end package pkg_log;

package body pkg_log is


---------------------------------------------------------------------
-- This function allows to build column label of the *.csv file
---------------------------------------------------------------------
 --  common typ = "UINT" => the std_logic_vector value is converted into unsigned int representation
 --  common typ = "INT" => the std_logic_vector value is converted into signed int representation
 --  common typ = "HEX" => the std_logic_vector value is considered as a signed vector, then it's converted into hex representation
 --  common typ = "UHEX" => the std_logic_vector value is considered as a unsigned vector, then it's converted into hex representation
 --  common typ = "STD_VEC" => the std_logic_vector value is not converted
  function column_name(constant i_NAME  : in string; constant i_DATA_COMMON_TYP  : in string := "INT") return string is
  begin
    return i_NAME & "_(" & i_DATA_COMMON_TYP & ")";
  end function;



  ---------------------------------------------------------------------
  -- log_data_in_file1
  ---------------------------------------------------------------------
  procedure log_data_in_file1(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0            : in string;
    --  common typ = "UINT" => the std_logic_vector value is converted into unsigned int representation
    --  common typ = "INT" => the std_logic_vector value is converted into signed int representation
    --  common typ = "HEX" => the std_logic_vector value is considered as a signed vector, then it's converted into hex representation
    --  common typ = "UHEX" => the std_logic_vector value is considered as a unsigned vector, then it's converted into hex representation
    --  common typ = "STD_VEC" => the std_logic_vector value is not converted
    constant i_DATA0_COMMON_TYP : in string := "INT";

    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal i_data_valid     : in std_logic;
    signal i_data0_std_vect : in std_logic_vector

    ) is
    -- this function allows to write in *.csv file the testbench output signals:
    --   . the output value data_I
    --   . the output value data_Q
    --   . the bit synchro value
    variable v_csv_file : t_csv_file_reader;

    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST  : boolean   := true;
    constant c_NAME0 : string :=  column_name(i_NAME=> i_NAME0, i_DATA_COMMON_TYP=> i_DATA0_COMMON_TYP); 

  begin

    while c_TEST loop

      case v_fsm_state is

        when E_RST =>
          v_csv_file.dispose(void);
          v_fsm_state := E_WAIT;

        when E_WAIT =>
          ---------------------------------------------------------------------
          -- wait to be sure: uvvm object are correctly initialized
          ---------------------------------------------------------------------
          if i_start = '1' then
            v_csv_file.initialize(i_filepath, Open_Kind => write_mode, csv_separator => i_csv_separator);

            ---------------------------------------------------------------------
            -- write the file header
            ---------------------------------------------------------------------
            -- build header
            v_csv_file.write_string(value => c_NAME0, csv_separator => i_csv_separator, use_csv_separator => 0);

            v_csv_file.writeline(void);
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>
          if i_data_valid = '1' then

            -- data_I
            v_csv_file.write_std_vec_as_common_typ(value => i_data0_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA0_COMMON_TYP, use_csv_separator => 0);

            v_csv_file.writeline(void);

          end if;

          --if i_start = '1' then
          v_fsm_state := E_RUN;
          --else
          -- file_close(fid);
          --v_csv_file.dispose(void);
          --v_fsm_state := E_END;
          --end if;

        when E_END =>
          -- c_TEST := false;
          v_fsm_state := E_END;

        when others => -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;

      wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure log_data_in_file1;

  ---------------------------------------------------------------------
  -- log_data_in_file2
  ---------------------------------------------------------------------
  procedure log_data_in_file2(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0            : in string;
    constant i_NAME1            : in string;
    --  common typ = "UINT" => the std_logic_vector value is converted into unsigned int representation
    --  common typ = "INT" => the std_logic_vector value is converted into signed int representation
    --  common typ = "HEX" => the std_logic_vector value is considered as a signed vector, then it's converted into hex representation
    --  common typ = "UHEX" => the std_logic_vector value is considered as a unsigned vector, then it's converted into hex representation
    --  common typ = "STD_VEC" => the std_logic_vector value is not converted
    constant i_DATA0_COMMON_TYP : in string := "INT";
    constant i_DATA1_COMMON_TYP : in string := "INT";

    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal i_data_valid     : in std_logic;
    signal i_data0_std_vect : in std_logic_vector;
    signal i_data1_std_vect : in std_logic_vector
    ) is
    -- this function allows to write in *.csv file the testbench output signals:
    --   . the output value data_I
    --   . the output value data_Q
    --   . the bit synchro value
    variable v_csv_file : t_csv_file_reader;

    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST  : boolean   := true;
    constant c_NAME0 : string :=  column_name(i_NAME=> i_NAME0, i_DATA_COMMON_TYP=> i_DATA0_COMMON_TYP);
    constant c_NAME1 : string :=  column_name(i_NAME=> i_NAME1, i_DATA_COMMON_TYP=> i_DATA1_COMMON_TYP);

  begin

    while c_TEST loop

      case v_fsm_state is

        when E_RST =>
          v_csv_file.dispose(void);
          v_fsm_state := E_WAIT;

        when E_WAIT =>
          ---------------------------------------------------------------------
          -- wait to be sure: uvvm object are correctly initialized
          ---------------------------------------------------------------------
          if i_start = '1' then
            v_csv_file.initialize(i_filepath, Open_Kind => write_mode, csv_separator => i_csv_separator);

            ---------------------------------------------------------------------
            -- write the file header
            ---------------------------------------------------------------------
            -- build header
 
            v_csv_file.write_string(value => c_NAME0, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME1, csv_separator => i_csv_separator, use_csv_separator => 0);
            v_csv_file.writeline(void);
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>
          if i_data_valid = '1' then

            -- data0
            v_csv_file.write_std_vec_as_common_typ(value => i_data0_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA0_COMMON_TYP);
            -- data1
            v_csv_file.write_std_vec_as_common_typ(value => i_data1_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA1_COMMON_TYP, use_csv_separator => 0);

            v_csv_file.writeline(void);

          end if;

          --if i_start = '1' then
          v_fsm_state := E_RUN;
          --else
          -- file_close(fid);
          --v_csv_file.dispose(void);
          --v_fsm_state := E_END;
          --end if;

        when E_END =>
          -- c_TEST := false;
          v_fsm_state := E_END;

        when others => -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;

      wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure log_data_in_file2;


---------------------------------------------------------------------
  -- log_data_in_file3
  ---------------------------------------------------------------------
  procedure log_data_in_file3(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0            : in string;
    constant i_NAME1            : in string;
    constant i_NAME2            : in string;
    --  common typ = "UINT" => the std_logic_vector value is converted into unsigned int representation
    --  common typ = "INT" => the std_logic_vector value is converted into signed int representation
    --  common typ = "HEX" => the std_logic_vector value is considered as a signed vector, then it's converted into hex representation
    --  common typ = "UHEX" => the std_logic_vector value is considered as a unsigned vector, then it's converted into hex representation
    --  common typ = "STD_VEC" => the std_logic_vector value is not converted
    constant i_DATA0_COMMON_TYP : in string := "INT";
    constant i_DATA1_COMMON_TYP : in string := "INT";
    constant i_DATA2_COMMON_TYP : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal i_data_valid         : in std_logic;
    signal i_data0_std_vect     : in std_logic_vector;
    signal i_data1_std_vect     : in std_logic_vector;
    signal i_data2_std_vect     : in std_logic_vector
    ) is
    -- this function allows to write in *.csv file the testbench output signals:
    --   . the output value data_I
    --   . the output value data_Q
    --   . the bit synchro value
    variable v_csv_file : t_csv_file_reader;

    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST  : boolean   := true;
    constant c_NAME0 : string :=  column_name(i_NAME=> i_NAME0, i_DATA_COMMON_TYP=> i_DATA0_COMMON_TYP);
    constant c_NAME1 : string :=  column_name(i_NAME=> i_NAME1, i_DATA_COMMON_TYP=> i_DATA1_COMMON_TYP);
    constant c_NAME2 : string :=  column_name(i_NAME=> i_NAME2, i_DATA_COMMON_TYP=> i_DATA2_COMMON_TYP);

  begin

    while c_TEST loop

      case v_fsm_state is

        when E_RST =>
          v_csv_file.dispose(void);
          v_fsm_state := E_WAIT;

        when E_WAIT =>
          ---------------------------------------------------------------------
          -- wait to be sure: uvvm object are correctly initialized
          ---------------------------------------------------------------------
          if i_start = '1' then
            v_csv_file.initialize(i_filepath, Open_Kind => write_mode, csv_separator => i_csv_separator);

            ---------------------------------------------------------------------
            -- write the file header
            ---------------------------------------------------------------------
            -- build header
            v_csv_file.write_string(value => c_NAME0, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME1, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME2, csv_separator => i_csv_separator, use_csv_separator => 0);
            v_csv_file.writeline(void);
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>
          if i_data_valid = '1' then

            v_csv_file.write_std_vec_as_common_typ(value => i_data0_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA0_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data1_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA1_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data2_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA2_COMMON_TYP, use_csv_separator => 0);

            v_csv_file.writeline(void);

          end if;

          --if i_start = '1' then
          v_fsm_state := E_RUN;
          --else
          -- file_close(fid);
          --v_csv_file.dispose(void);
          --v_fsm_state := E_END;
          --end if;

        when E_END =>
          -- c_TEST := false;
          v_fsm_state := E_END;

        when others => -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;

      wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure log_data_in_file3;

---------------------------------------------------------------------
  -- log_data_in_file4
  ---------------------------------------------------------------------
  procedure log_data_in_file4(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0            : in string;
    constant i_NAME1            : in string;
    constant i_NAME2            : in string;
    constant i_NAME3            : in string;
    --  common typ = "UINT" => the std_logic_vector value is converted into unsigned int representation
    --  common typ = "INT" => the std_logic_vector value is converted into signed int representation
    --  common typ = "HEX" => the std_logic_vector value is considered as a signed vector, then it's converted into hex representation
    --  common typ = "UHEX" => the std_logic_vector value is considered as a unsigned vector, then it's converted into hex representation
    --  common typ = "STD_VEC" => the std_logic_vector value is not converted
    constant i_DATA0_COMMON_TYP : in string := "INT";
    constant i_DATA1_COMMON_TYP : in string := "INT";
    constant i_DATA2_COMMON_TYP : in string := "INT";
    constant i_DATA3_COMMON_TYP : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal i_data_valid         : in std_logic;
    signal i_data0_std_vect     : in std_logic_vector;
    signal i_data1_std_vect     : in std_logic_vector;
    signal i_data2_std_vect     : in std_logic_vector;
    signal i_data3_std_vect     : in std_logic_vector
    ) is
    -- this function allows to write in *.csv file the testbench output signals:
    --   . the output value data_I
    --   . the output value data_Q
    --   . the bit synchro value
    variable v_csv_file : t_csv_file_reader;

    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST  : boolean   := true;

    constant c_NAME0 : string :=  column_name(i_NAME=> i_NAME0, i_DATA_COMMON_TYP=> i_DATA0_COMMON_TYP);
    constant c_NAME1 : string :=  column_name(i_NAME=> i_NAME1, i_DATA_COMMON_TYP=> i_DATA1_COMMON_TYP);
    constant c_NAME2 : string :=  column_name(i_NAME=> i_NAME2, i_DATA_COMMON_TYP=> i_DATA2_COMMON_TYP);
    constant c_NAME3 : string :=  column_name(i_NAME=> i_NAME3, i_DATA_COMMON_TYP=> i_DATA3_COMMON_TYP);

  begin

    while c_TEST loop

      case v_fsm_state is

        when E_RST =>
          v_csv_file.dispose(void);
          v_fsm_state := E_WAIT;

        when E_WAIT =>
          ---------------------------------------------------------------------
          -- wait to be sure: uvvm object are correctly initialized
          ---------------------------------------------------------------------
          if i_start = '1' then
            v_csv_file.initialize(i_filepath, Open_Kind => write_mode, csv_separator => i_csv_separator);

            ---------------------------------------------------------------------
            -- write the file header
            ---------------------------------------------------------------------
            -- build header
            v_csv_file.write_string(value => c_NAME0, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME1, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME2, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME3, csv_separator => i_csv_separator, use_csv_separator => 0);
            v_csv_file.writeline(void);
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>
          if i_data_valid = '1' then

            v_csv_file.write_std_vec_as_common_typ(value => i_data0_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA0_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data1_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA1_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data2_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA2_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data3_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA3_COMMON_TYP, use_csv_separator => 0);

            v_csv_file.writeline(void);

          end if;

          --if i_start = '1' then
          v_fsm_state := E_RUN;
          --else
          -- file_close(fid);
          --v_csv_file.dispose(void);
          --v_fsm_state := E_END;
          --end if;

        when E_END =>
          -- c_TEST := false;
          v_fsm_state := E_END;

        when others => -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;

      wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure log_data_in_file4;

---------------------------------------------------------------------
  -- log_data_in_file5
  ---------------------------------------------------------------------
  procedure log_data_in_file5(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0            : in string;
    constant i_NAME1            : in string;
    constant i_NAME2            : in string;
    constant i_NAME3            : in string;
    constant i_NAME4            : in string;
    --  common typ = "UINT" => the std_logic_vector value is converted into unsigned int representation
    --  common typ = "INT" => the std_logic_vector value is converted into signed int representation
    --  common typ = "HEX" => the std_logic_vector value is considered as a signed vector, then it's converted into hex representation
    --  common typ = "UHEX" => the std_logic_vector value is considered as a unsigned vector, then it's converted into hex representation
    --  common typ = "STD_VEC" => the std_logic_vector value is not converted
    constant i_DATA0_COMMON_TYP : in string := "INT";
    constant i_DATA1_COMMON_TYP : in string := "INT";
    constant i_DATA2_COMMON_TYP : in string := "INT";
    constant i_DATA3_COMMON_TYP : in string := "INT";
    constant i_DATA4_COMMON_TYP : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal i_data_valid         : in std_logic;
    signal i_data0_std_vect     : in std_logic_vector;
    signal i_data1_std_vect     : in std_logic_vector;
    signal i_data2_std_vect     : in std_logic_vector;
    signal i_data3_std_vect     : in std_logic_vector;
    signal i_data4_std_vect     : in std_logic_vector
    ) is
    -- this function allows to write in *.csv file the testbench output signals:
    --   . the output value data_I
    --   . the output value data_Q
    --   . the bit synchro value
    variable v_csv_file : t_csv_file_reader;
 

    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST  : boolean   := true;

    constant c_NAME0 : string :=  column_name(i_NAME=> i_NAME0, i_DATA_COMMON_TYP=> i_DATA0_COMMON_TYP);
    constant c_NAME1 : string :=  column_name(i_NAME=> i_NAME1, i_DATA_COMMON_TYP=> i_DATA1_COMMON_TYP);
    constant c_NAME2 : string :=  column_name(i_NAME=> i_NAME2, i_DATA_COMMON_TYP=> i_DATA2_COMMON_TYP);
    constant c_NAME3 : string :=  column_name(i_NAME=> i_NAME3, i_DATA_COMMON_TYP=> i_DATA3_COMMON_TYP);
    constant c_NAME4 : string :=  column_name(i_NAME=> i_NAME4, i_DATA_COMMON_TYP=> i_DATA4_COMMON_TYP);

  begin

    while c_TEST loop

      case v_fsm_state is

        when E_RST =>
          v_csv_file.dispose(void);
          v_fsm_state := E_WAIT;

        when E_WAIT =>
          ---------------------------------------------------------------------
          -- wait to be sure: uvvm object are correctly initialized
          ---------------------------------------------------------------------
          if i_start = '1' then
            v_csv_file.initialize(i_filepath, Open_Kind => write_mode, csv_separator => i_csv_separator);

            ---------------------------------------------------------------------
            -- write the file header
            ---------------------------------------------------------------------
            -- build header
            v_csv_file.write_string(value => c_NAME0, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME1, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME2, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME3, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME4, csv_separator => i_csv_separator, use_csv_separator => 0);
            v_csv_file.writeline(void);
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>
          if i_data_valid = '1' then

            v_csv_file.write_std_vec_as_common_typ(value => i_data0_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA0_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data1_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA1_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data2_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA2_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data3_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA3_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data4_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA4_COMMON_TYP, use_csv_separator => 0);

            v_csv_file.writeline(void);

          end if;

          --if i_start = '1' then
          v_fsm_state := E_RUN;
          --else
          -- file_close(fid);
          --v_csv_file.dispose(void);
          --v_fsm_state := E_END;
          --end if;

        when E_END =>
          -- c_TEST := false;
          v_fsm_state := E_END;

        when others => -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;

      wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure log_data_in_file5;

---------------------------------------------------------------------
  -- log_data_in_file6
  ---------------------------------------------------------------------
  procedure log_data_in_file6(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0            : in string;
    constant i_NAME1            : in string;
    constant i_NAME2            : in string;
    constant i_NAME3            : in string;
    constant i_NAME4            : in string;
    constant i_NAME5            : in string;
    --  common typ = "UINT" => the std_logic_vector value is converted into unsigned int representation
    --  common typ = "INT" => the std_logic_vector value is converted into signed int representation
    --  common typ = "HEX" => the std_logic_vector value is considered as a signed vector, then it's converted into hex representation
    --  common typ = "UHEX" => the std_logic_vector value is considered as a unsigned vector, then it's converted into hex representation
    --  common typ = "STD_VEC" => the std_logic_vector value is not converted
    constant i_DATA0_COMMON_TYP : in string := "INT";
    constant i_DATA1_COMMON_TYP : in string := "INT";
    constant i_DATA2_COMMON_TYP : in string := "INT";
    constant i_DATA3_COMMON_TYP : in string := "INT";
    constant i_DATA4_COMMON_TYP : in string := "INT";
    constant i_DATA5_COMMON_TYP : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal i_data_valid         : in std_logic;
    signal i_data0_std_vect     : in std_logic_vector;
    signal i_data1_std_vect     : in std_logic_vector;
    signal i_data2_std_vect     : in std_logic_vector;
    signal i_data3_std_vect     : in std_logic_vector;
    signal i_data4_std_vect     : in std_logic_vector;
    signal i_data5_std_vect     : in std_logic_vector
    ) is
    -- this function allows to write in *.csv file the testbench output signals:
    --   . the output value data_I
    --   . the output value data_Q
    --   . the bit synchro value
    variable v_csv_file : t_csv_file_reader;
 

    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST  : boolean   := true;

    constant c_NAME0 : string :=  column_name(i_NAME=> i_NAME0, i_DATA_COMMON_TYP=> i_DATA0_COMMON_TYP);
    constant c_NAME1 : string :=  column_name(i_NAME=> i_NAME1, i_DATA_COMMON_TYP=> i_DATA1_COMMON_TYP);
    constant c_NAME2 : string :=  column_name(i_NAME=> i_NAME2, i_DATA_COMMON_TYP=> i_DATA2_COMMON_TYP);
    constant c_NAME3 : string :=  column_name(i_NAME=> i_NAME3, i_DATA_COMMON_TYP=> i_DATA3_COMMON_TYP);
    constant c_NAME4 : string :=  column_name(i_NAME=> i_NAME4, i_DATA_COMMON_TYP=> i_DATA4_COMMON_TYP);
    constant c_NAME5 : string :=  column_name(i_NAME=> i_NAME5, i_DATA_COMMON_TYP=> i_DATA5_COMMON_TYP);

  begin

    while c_TEST loop

      case v_fsm_state is

        when E_RST =>
          v_csv_file.dispose(void);
          v_fsm_state := E_WAIT;

        when E_WAIT =>
          ---------------------------------------------------------------------
          -- wait to be sure: uvvm object are correctly initialized
          ---------------------------------------------------------------------
          if i_start = '1' then
            v_csv_file.initialize(i_filepath, Open_Kind => write_mode, csv_separator => i_csv_separator);

            ---------------------------------------------------------------------
            -- write the file header
            ---------------------------------------------------------------------
            -- build header
            v_csv_file.write_string(value => c_NAME0, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME1, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME2, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME3, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME4, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME5, csv_separator => i_csv_separator, use_csv_separator => 0);
            v_csv_file.writeline(void);
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>
          if i_data_valid = '1' then

            v_csv_file.write_std_vec_as_common_typ(value => i_data0_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA0_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data1_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA1_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data2_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA2_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data3_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA3_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data4_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA4_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data5_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA5_COMMON_TYP, use_csv_separator => 0);

            v_csv_file.writeline(void);

          end if;

          --if i_start = '1' then
          v_fsm_state := E_RUN;
          --else
          -- file_close(fid);
          --v_csv_file.dispose(void);
          --v_fsm_state := E_END;
          --end if;

        when E_END =>
          -- c_TEST := false;
          v_fsm_state := E_END;

        when others => -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;

      wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure log_data_in_file6;

---------------------------------------------------------------------
  -- log_data_in_file7
  ---------------------------------------------------------------------
  procedure log_data_in_file7(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0            : in string;
    constant i_NAME1            : in string;
    constant i_NAME2            : in string;
    constant i_NAME3            : in string;
    constant i_NAME4            : in string;
    constant i_NAME5            : in string;
    constant i_NAME6            : in string;
    --  common typ = "UINT" => the std_logic_vector value is converted into unsigned int representation
    --  common typ = "INT" => the std_logic_vector value is converted into signed int representation
    --  common typ = "HEX" => the std_logic_vector value is considered as a signed vector, then it's converted into hex representation
    --  common typ = "UHEX" => the std_logic_vector value is considered as a unsigned vector, then it's converted into hex representation
    --  common typ = "STD_VEC" => the std_logic_vector value is not converted
    constant i_DATA0_COMMON_TYP : in string := "INT";
    constant i_DATA1_COMMON_TYP : in string := "INT";
    constant i_DATA2_COMMON_TYP : in string := "INT";
    constant i_DATA3_COMMON_TYP : in string := "INT";
    constant i_DATA4_COMMON_TYP : in string := "INT";
    constant i_DATA5_COMMON_TYP : in string := "INT";
    constant i_DATA6_COMMON_TYP : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal i_data_valid         : in std_logic;
    signal i_data0_std_vect     : in std_logic_vector;
    signal i_data1_std_vect     : in std_logic_vector;
    signal i_data2_std_vect     : in std_logic_vector;
    signal i_data3_std_vect     : in std_logic_vector;
    signal i_data4_std_vect     : in std_logic_vector;
    signal i_data5_std_vect     : in std_logic_vector;
    signal i_data6_std_vect     : in std_logic_vector
    ) is
    -- this function allows to write in *.csv file the testbench output signals:
    --   . the output value data_I
    --   . the output value data_Q
    --   . the bit synchro value
    variable v_csv_file : t_csv_file_reader;
 

    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST  : boolean   := true;

    constant c_NAME0 : string :=  column_name(i_NAME=> i_NAME0, i_DATA_COMMON_TYP=> i_DATA0_COMMON_TYP);
    constant c_NAME1 : string :=  column_name(i_NAME=> i_NAME1, i_DATA_COMMON_TYP=> i_DATA1_COMMON_TYP);
    constant c_NAME2 : string :=  column_name(i_NAME=> i_NAME2, i_DATA_COMMON_TYP=> i_DATA2_COMMON_TYP);
    constant c_NAME3 : string :=  column_name(i_NAME=> i_NAME3, i_DATA_COMMON_TYP=> i_DATA3_COMMON_TYP);
    constant c_NAME4 : string :=  column_name(i_NAME=> i_NAME4, i_DATA_COMMON_TYP=> i_DATA4_COMMON_TYP);
    constant c_NAME5 : string :=  column_name(i_NAME=> i_NAME5, i_DATA_COMMON_TYP=> i_DATA5_COMMON_TYP);
    constant c_NAME6 : string :=  column_name(i_NAME=> i_NAME6, i_DATA_COMMON_TYP=> i_DATA6_COMMON_TYP);

  begin

    while c_TEST loop

      case v_fsm_state is

        when E_RST =>
          v_csv_file.dispose(void);
          v_fsm_state := E_WAIT;

        when E_WAIT =>
          ---------------------------------------------------------------------
          -- wait to be sure: uvvm object are correctly initialized
          ---------------------------------------------------------------------
          if i_start = '1' then
            v_csv_file.initialize(i_filepath, Open_Kind => write_mode, csv_separator => i_csv_separator);

            ---------------------------------------------------------------------
            -- write the file header
            ---------------------------------------------------------------------
            -- build header
            v_csv_file.write_string(value => c_NAME0, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME1, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME2, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME3, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME4, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME5, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME6, csv_separator => i_csv_separator, use_csv_separator => 0);
            v_csv_file.writeline(void);
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>
          if i_data_valid = '1' then

            v_csv_file.write_std_vec_as_common_typ(value => i_data0_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA0_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data1_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA1_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data2_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA2_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data3_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA3_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data4_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA4_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data5_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA5_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data6_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA6_COMMON_TYP, use_csv_separator => 0);

            v_csv_file.writeline(void);

          end if;

          --if i_start = '1' then
          v_fsm_state := E_RUN;
          --else
          -- file_close(fid);
          --v_csv_file.dispose(void);
          --v_fsm_state := E_END;
          --end if;

        when E_END =>
          -- c_TEST := false;
          v_fsm_state := E_END;

        when others => -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;

      wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure log_data_in_file7;

---------------------------------------------------------------------
  -- log_data_in_file8
  ---------------------------------------------------------------------
  procedure log_data_in_file8(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0            : in string;
    constant i_NAME1            : in string;
    constant i_NAME2            : in string;
    constant i_NAME3            : in string;
    constant i_NAME4            : in string;
    constant i_NAME5            : in string;
    constant i_NAME6            : in string;
    constant i_NAME7            : in string;
    --  common typ = "UINT" => the std_logic_vector value is converted into unsigned int representation
    --  common typ = "INT" => the std_logic_vector value is converted into signed int representation
    --  common typ = "HEX" => the std_logic_vector value is considered as a signed vector, then it's converted into hex representation
    --  common typ = "UHEX" => the std_logic_vector value is considered as a unsigned vector, then it's converted into hex representation
    --  common typ = "STD_VEC" => the std_logic_vector value is not converted
    constant i_DATA0_COMMON_TYP : in string := "INT";
    constant i_DATA1_COMMON_TYP : in string := "INT";
    constant i_DATA2_COMMON_TYP : in string := "INT";
    constant i_DATA3_COMMON_TYP : in string := "INT";
    constant i_DATA4_COMMON_TYP : in string := "INT";
    constant i_DATA5_COMMON_TYP : in string := "INT";
    constant i_DATA6_COMMON_TYP : in string := "INT";
    constant i_DATA7_COMMON_TYP : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal i_data_valid         : in std_logic;
    signal i_data0_std_vect     : in std_logic_vector;
    signal i_data1_std_vect     : in std_logic_vector;
    signal i_data2_std_vect     : in std_logic_vector;
    signal i_data3_std_vect     : in std_logic_vector;
    signal i_data4_std_vect     : in std_logic_vector;
    signal i_data5_std_vect     : in std_logic_vector;
    signal i_data6_std_vect     : in std_logic_vector;
    signal i_data7_std_vect     : in std_logic_vector
    ) is
    -- this function allows to write in *.csv file the testbench output signals:
    --   . the output value data_I
    --   . the output value data_Q
    --   . the bit synchro value
    variable v_csv_file : t_csv_file_reader;


    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST  : boolean   := true;

    constant c_NAME0 : string :=  column_name(i_NAME=> i_NAME0, i_DATA_COMMON_TYP=> i_DATA0_COMMON_TYP);
    constant c_NAME1 : string :=  column_name(i_NAME=> i_NAME1, i_DATA_COMMON_TYP=> i_DATA1_COMMON_TYP);
    constant c_NAME2 : string :=  column_name(i_NAME=> i_NAME2, i_DATA_COMMON_TYP=> i_DATA2_COMMON_TYP);
    constant c_NAME3 : string :=  column_name(i_NAME=> i_NAME3, i_DATA_COMMON_TYP=> i_DATA3_COMMON_TYP);
    constant c_NAME4 : string :=  column_name(i_NAME=> i_NAME4, i_DATA_COMMON_TYP=> i_DATA4_COMMON_TYP);
    constant c_NAME5 : string :=  column_name(i_NAME=> i_NAME5, i_DATA_COMMON_TYP=> i_DATA5_COMMON_TYP);
    constant c_NAME6 : string :=  column_name(i_NAME=> i_NAME6, i_DATA_COMMON_TYP=> i_DATA6_COMMON_TYP);
    constant c_NAME7 : string :=  column_name(i_NAME=> i_NAME7, i_DATA_COMMON_TYP=> i_DATA7_COMMON_TYP);

  begin

    while c_TEST loop

      case v_fsm_state is

        when E_RST =>
          v_csv_file.dispose(void);
          v_fsm_state := E_WAIT;

        when E_WAIT =>
          ---------------------------------------------------------------------
          -- wait to be sure: uvvm object are correctly initialized
          ---------------------------------------------------------------------
          if i_start = '1' then
            v_csv_file.initialize(i_filepath, Open_Kind => write_mode, csv_separator => i_csv_separator);

            ---------------------------------------------------------------------
            -- write the file header
            ---------------------------------------------------------------------
            -- build header
            v_csv_file.write_string(value => c_NAME0, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME1, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME2, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME3, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME4, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME5, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME6, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME7, csv_separator => i_csv_separator, use_csv_separator => 0);
            v_csv_file.writeline(void);
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>
          if i_data_valid = '1' then

            v_csv_file.write_std_vec_as_common_typ(value => i_data0_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA0_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data1_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA1_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data2_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA2_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data3_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA3_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data4_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA4_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data5_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA5_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data6_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA6_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data7_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA7_COMMON_TYP, use_csv_separator => 0);

            v_csv_file.writeline(void);

          end if;

          --if i_start = '1' then
          v_fsm_state := E_RUN;
          --else
          -- file_close(fid);
          --v_csv_file.dispose(void);
          --v_fsm_state := E_END;
          --end if;

        when E_END =>
          -- c_TEST := false;
          v_fsm_state := E_END;

        when others => -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;

      wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure log_data_in_file8;

---------------------------------------------------------------------
  -- log_data_in_file10
  ---------------------------------------------------------------------
  procedure log_data_in_file10(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0            : in string;
    constant i_NAME1            : in string;
    constant i_NAME2            : in string;
    constant i_NAME3            : in string;
    constant i_NAME4            : in string;
    constant i_NAME5            : in string;
    constant i_NAME6            : in string;
    constant i_NAME7            : in string;
    constant i_NAME8            : in string;
    constant i_NAME9            : in string;
    --  common typ = "UINT" => the std_logic_vector value is converted into unsigned int representation
    --  common typ = "INT" => the std_logic_vector value is converted into signed int representation
    --  common typ = "HEX" => the std_logic_vector value is considered as a signed vector, then it's converted into hex representation
    --  common typ = "UHEX" => the std_logic_vector value is considered as a unsigned vector, then it's converted into hex representation
    --  common typ = "STD_VEC" => the std_logic_vector value is not converted
    constant i_DATA0_COMMON_TYP : in string := "INT";
    constant i_DATA1_COMMON_TYP : in string := "INT";
    constant i_DATA2_COMMON_TYP : in string := "INT";
    constant i_DATA3_COMMON_TYP : in string := "INT";
    constant i_DATA4_COMMON_TYP : in string := "INT";
    constant i_DATA5_COMMON_TYP : in string := "INT";
    constant i_DATA6_COMMON_TYP : in string := "INT";
    constant i_DATA7_COMMON_TYP : in string := "INT";
    constant i_DATA8_COMMON_TYP : in string := "INT";
    constant i_DATA9_COMMON_TYP : in string := "INT";

    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal i_data_valid     : in std_logic;
    signal i_data0_std_vect : in std_logic_vector;
    signal i_data1_std_vect : in std_logic_vector;
    signal i_data2_std_vect : in std_logic_vector;
    signal i_data3_std_vect : in std_logic_vector;
    signal i_data4_std_vect : in std_logic_vector;
    signal i_data5_std_vect : in std_logic_vector;
    signal i_data6_std_vect : in std_logic_vector;
    signal i_data7_std_vect : in std_logic_vector;
    signal i_data8_std_vect : in std_logic_vector;
    signal i_data9_std_vect : in std_logic_vector
    ) is
    -- this function allows to write in *.csv file the testbench output signals:
    --   . the output value data_I
    --   . the output value data_Q
    --   . the bit synchro value
    variable v_csv_file : t_csv_file_reader;

    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST  : boolean   := true;

    constant c_NAME0 : string :=  column_name(i_NAME=> i_NAME0, i_DATA_COMMON_TYP=> i_DATA0_COMMON_TYP);
    constant c_NAME1 : string :=  column_name(i_NAME=> i_NAME1, i_DATA_COMMON_TYP=> i_DATA1_COMMON_TYP);
    constant c_NAME2 : string :=  column_name(i_NAME=> i_NAME2, i_DATA_COMMON_TYP=> i_DATA2_COMMON_TYP);
    constant c_NAME3 : string :=  column_name(i_NAME=> i_NAME3, i_DATA_COMMON_TYP=> i_DATA3_COMMON_TYP);
    constant c_NAME4 : string :=  column_name(i_NAME=> i_NAME4, i_DATA_COMMON_TYP=> i_DATA4_COMMON_TYP);
    constant c_NAME5 : string :=  column_name(i_NAME=> i_NAME5, i_DATA_COMMON_TYP=> i_DATA5_COMMON_TYP);
    constant c_NAME6 : string :=  column_name(i_NAME=> i_NAME6, i_DATA_COMMON_TYP=> i_DATA6_COMMON_TYP);
    constant c_NAME7 : string :=  column_name(i_NAME=> i_NAME7, i_DATA_COMMON_TYP=> i_DATA7_COMMON_TYP);
    constant c_NAME8 : string :=  column_name(i_NAME=> i_NAME8, i_DATA_COMMON_TYP=> i_DATA8_COMMON_TYP);
    constant c_NAME9 : string :=  column_name(i_NAME=> i_NAME9, i_DATA_COMMON_TYP=> i_DATA9_COMMON_TYP);

  begin

    while c_TEST loop

      case v_fsm_state is

        when E_RST =>
          v_csv_file.dispose(void);
          v_fsm_state := E_WAIT;

        when E_WAIT =>
          ---------------------------------------------------------------------
          -- wait to be sure: uvvm object are correctly initialized
          ---------------------------------------------------------------------
          if i_start = '1' then
            v_csv_file.initialize(i_filepath, Open_Kind => write_mode, csv_separator => i_csv_separator);

            ---------------------------------------------------------------------
            -- write the file header
            ---------------------------------------------------------------------
            -- build header
            v_csv_file.write_string(value => c_NAME0, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME1, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME2, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME3, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME4, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME5, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME6, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME7, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME8, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME9, csv_separator => i_csv_separator, use_csv_separator => 0);

            v_csv_file.writeline(void);
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>
          if i_data_valid = '1' then


            v_csv_file.write_std_vec_as_common_typ(value => i_data0_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA0_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data1_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA1_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data2_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA2_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data3_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA3_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data4_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA4_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data5_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA5_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data6_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA6_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data7_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA7_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data8_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA8_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data9_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA9_COMMON_TYP, use_csv_separator => 0);


            v_csv_file.writeline(void);

          end if;

          --if i_start = '1' then
          v_fsm_state := E_RUN;
          --else
          -- file_close(fid);
          --v_csv_file.dispose(void);
          --v_fsm_state := E_END;
          --end if;

        when E_END =>
          -- c_TEST := false;
          v_fsm_state := E_END;

        when others => -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;

      wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure log_data_in_file10;

---------------------------------------------------------------------
  -- log_data_in_file11
  ---------------------------------------------------------------------
  procedure log_data_in_file11(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0  : in string;
    constant i_NAME1  : in string;
    constant i_NAME2  : in string;
    constant i_NAME3  : in string;
    constant i_NAME4  : in string;
    constant i_NAME5  : in string;
    constant i_NAME6  : in string;
    constant i_NAME7  : in string;
    constant i_NAME8  : in string;
    constant i_NAME9  : in string;
    constant i_NAME10 : in string;

    --  common typ = "UINT" => the std_logic_vector value is converted into unsigned int representation
    --  common typ = "INT" => the std_logic_vector value is converted into signed int representation
    --  common typ = "HEX" => the std_logic_vector value is considered as a signed vector, then it's converted into hex representation
    --  common typ = "UHEX" => the std_logic_vector value is considered as a unsigned vector, then it's converted into hex representation
    --  common typ = "STD_VEC" => the std_logic_vector value is not converted
    constant i_DATA0_COMMON_TYP  : in string := "INT";
    constant i_DATA1_COMMON_TYP  : in string := "INT";
    constant i_DATA2_COMMON_TYP  : in string := "INT";
    constant i_DATA3_COMMON_TYP  : in string := "INT";
    constant i_DATA4_COMMON_TYP  : in string := "INT";
    constant i_DATA5_COMMON_TYP  : in string := "INT";
    constant i_DATA6_COMMON_TYP  : in string := "INT";
    constant i_DATA7_COMMON_TYP  : in string := "INT";
    constant i_DATA8_COMMON_TYP  : in string := "INT";
    constant i_DATA9_COMMON_TYP  : in string := "INT";
    constant i_DATA10_COMMON_TYP : in string := "INT";

    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal i_data_valid : in std_logic;
    signal i_data0_std_vect  : in std_logic_vector;
    signal i_data1_std_vect  : in std_logic_vector;
    signal i_data2_std_vect  : in std_logic_vector;
    signal i_data3_std_vect  : in std_logic_vector;
    signal i_data4_std_vect  : in std_logic_vector;
    signal i_data5_std_vect  : in std_logic_vector;
    signal i_data6_std_vect  : in std_logic_vector;
    signal i_data7_std_vect  : in std_logic_vector;
    signal i_data8_std_vect  : in std_logic_vector;
    signal i_data9_std_vect  : in std_logic_vector;
    signal i_data10_std_vect : in std_logic_vector
    ) is
    -- this function allows to write in *.csv file the testbench output signals:
    --   . the output value data_I
    --   . the output value data_Q
    --   . the bit synchro value
    variable v_csv_file : t_csv_file_reader;

    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST  : boolean   := true;

    constant c_NAME0 : string :=  column_name(i_NAME=> i_NAME0, i_DATA_COMMON_TYP=> i_DATA0_COMMON_TYP);
    constant c_NAME1 : string :=  column_name(i_NAME=> i_NAME1, i_DATA_COMMON_TYP=> i_DATA1_COMMON_TYP);
    constant c_NAME2 : string :=  column_name(i_NAME=> i_NAME2, i_DATA_COMMON_TYP=> i_DATA2_COMMON_TYP);
    constant c_NAME3 : string :=  column_name(i_NAME=> i_NAME3, i_DATA_COMMON_TYP=> i_DATA3_COMMON_TYP);
    constant c_NAME4 : string :=  column_name(i_NAME=> i_NAME4, i_DATA_COMMON_TYP=> i_DATA4_COMMON_TYP);
    constant c_NAME5 : string :=  column_name(i_NAME=> i_NAME5, i_DATA_COMMON_TYP=> i_DATA5_COMMON_TYP);
    constant c_NAME6 : string :=  column_name(i_NAME=> i_NAME6, i_DATA_COMMON_TYP=> i_DATA6_COMMON_TYP);
    constant c_NAME7 : string :=  column_name(i_NAME=> i_NAME7, i_DATA_COMMON_TYP=> i_DATA7_COMMON_TYP);
    constant c_NAME8 : string :=  column_name(i_NAME=> i_NAME8, i_DATA_COMMON_TYP=> i_DATA8_COMMON_TYP);
    constant c_NAME9 : string :=  column_name(i_NAME=> i_NAME9, i_DATA_COMMON_TYP=> i_DATA9_COMMON_TYP);
    constant c_NAME10 : string :=  column_name(i_NAME=> i_NAME10, i_DATA_COMMON_TYP=> i_DATA10_COMMON_TYP);

  begin

    while c_TEST loop

      case v_fsm_state is

        when E_RST =>
          v_csv_file.dispose(void);
          v_fsm_state := E_WAIT;

        when E_WAIT =>
          ---------------------------------------------------------------------
          -- wait to be sure: uvvm object are correctly initialized
          ---------------------------------------------------------------------
          if i_start = '1' then
            v_csv_file.initialize(i_filepath, Open_Kind => write_mode, csv_separator => i_csv_separator);

            ---------------------------------------------------------------------
            -- write the file header
            ---------------------------------------------------------------------
            -- build header
            v_csv_file.write_string(value => c_NAME0, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME1, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME2, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME3, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME4, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME5, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME6, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME7, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME8, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME9, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME10, csv_separator => i_csv_separator, use_csv_separator => 0);

            v_csv_file.writeline(void);
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>
          if i_data_valid = '1' then


            v_csv_file.write_std_vec_as_common_typ(value => i_data0_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA0_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data1_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA1_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data2_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA2_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data3_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA3_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data4_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA4_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data5_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA5_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data6_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA6_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data7_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA7_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data8_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA8_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data9_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA9_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data10_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA10_COMMON_TYP, use_csv_separator => 0);
            v_csv_file.writeline(void);

          end if;

          --if i_start = '1' then
          v_fsm_state := E_RUN;
          --else
          -- file_close(fid);
          --v_csv_file.dispose(void);
          --v_fsm_state := E_END;
          --end if;

        when E_END =>
          -- c_TEST := false;
          v_fsm_state := E_END;

        when others => -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;

      wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure log_data_in_file11;


---------------------------------------------------------------------
  -- log_data_in_file13
  ---------------------------------------------------------------------
  procedure log_data_in_file13(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0             : in string;
    constant i_NAME1             : in string;
    constant i_NAME2             : in string;
    constant i_NAME3             : in string;
    constant i_NAME4             : in string;
    constant i_NAME5             : in string;
    constant i_NAME6             : in string;
    constant i_NAME7             : in string;
    constant i_NAME8             : in string;
    constant i_NAME9             : in string;
    constant i_NAME10            : in string;
    constant i_NAME11            : in string;
    constant i_NAME12            : in string;
    --  common typ = "UINT" => the std_logic_vector value is converted into unsigned int representation
    --  common typ = "INT" => the std_logic_vector value is converted into signed int representation
    --  common typ = "HEX" => the std_logic_vector value is considered as a signed vector, then it's converted into hex representation
    --  common typ = "UHEX" => the std_logic_vector value is considered as a unsigned vector, then it's converted into hex representation
    --  common typ = "STD_VEC" => the std_logic_vector value is not converted
    constant i_DATA0_COMMON_TYP  : in string := "INT";
    constant i_DATA1_COMMON_TYP  : in string := "INT";
    constant i_DATA2_COMMON_TYP  : in string := "INT";
    constant i_DATA3_COMMON_TYP  : in string := "INT";
    constant i_DATA4_COMMON_TYP  : in string := "INT";
    constant i_DATA5_COMMON_TYP  : in string := "INT";
    constant i_DATA6_COMMON_TYP  : in string := "INT";
    constant i_DATA7_COMMON_TYP  : in string := "INT";
    constant i_DATA8_COMMON_TYP  : in string := "INT";
    constant i_DATA9_COMMON_TYP  : in string := "INT";
    constant i_DATA10_COMMON_TYP : in string := "INT";
    constant i_DATA11_COMMON_TYP : in string := "INT";
    constant i_DATA12_COMMON_TYP : in string := "INT";

    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal i_data_valid      : in std_logic;
    signal i_data0_std_vect  : in std_logic_vector;
    signal i_data1_std_vect  : in std_logic_vector;
    signal i_data2_std_vect  : in std_logic_vector;
    signal i_data3_std_vect  : in std_logic_vector;
    signal i_data4_std_vect  : in std_logic_vector;
    signal i_data5_std_vect  : in std_logic_vector;
    signal i_data6_std_vect  : in std_logic_vector;
    signal i_data7_std_vect  : in std_logic_vector;
    signal i_data8_std_vect  : in std_logic_vector;
    signal i_data9_std_vect  : in std_logic_vector;
    signal i_data10_std_vect : in std_logic_vector;
    signal i_data11_std_vect : in std_logic_vector;
    signal i_data12_std_vect : in std_logic_vector
    ) is
    -- this function allows to write in *.csv file the testbench output signals:
    --   . the output value data_I
    --   . the output value data_Q
    --   . the bit synchro value
    variable v_csv_file : t_csv_file_reader;


    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST  : boolean   := true;

    constant c_NAME0 : string :=  column_name(i_NAME=> i_NAME0, i_DATA_COMMON_TYP=> i_DATA0_COMMON_TYP);
    constant c_NAME1 : string :=  column_name(i_NAME=> i_NAME1, i_DATA_COMMON_TYP=> i_DATA1_COMMON_TYP);
    constant c_NAME2 : string :=  column_name(i_NAME=> i_NAME2, i_DATA_COMMON_TYP=> i_DATA2_COMMON_TYP);
    constant c_NAME3 : string :=  column_name(i_NAME=> i_NAME3, i_DATA_COMMON_TYP=> i_DATA3_COMMON_TYP);
    constant c_NAME4 : string :=  column_name(i_NAME=> i_NAME4, i_DATA_COMMON_TYP=> i_DATA4_COMMON_TYP);
    constant c_NAME5 : string :=  column_name(i_NAME=> i_NAME5, i_DATA_COMMON_TYP=> i_DATA5_COMMON_TYP);
    constant c_NAME6 : string :=  column_name(i_NAME=> i_NAME6, i_DATA_COMMON_TYP=> i_DATA6_COMMON_TYP);
    constant c_NAME7 : string :=  column_name(i_NAME=> i_NAME7, i_DATA_COMMON_TYP=> i_DATA7_COMMON_TYP);
    constant c_NAME8 : string :=  column_name(i_NAME=> i_NAME8, i_DATA_COMMON_TYP=> i_DATA8_COMMON_TYP);
    constant c_NAME9 : string :=  column_name(i_NAME=> i_NAME9, i_DATA_COMMON_TYP=> i_DATA9_COMMON_TYP);
    constant c_NAME10 : string :=  column_name(i_NAME=> i_NAME10, i_DATA_COMMON_TYP=> i_DATA10_COMMON_TYP);
    constant c_NAME11 : string :=  column_name(i_NAME=> i_NAME11, i_DATA_COMMON_TYP=> i_DATA11_COMMON_TYP);
    constant c_NAME12 : string :=  column_name(i_NAME=> i_NAME12, i_DATA_COMMON_TYP=> i_DATA12_COMMON_TYP);

  begin

    while c_TEST loop

      case v_fsm_state is

        when E_RST =>
          v_csv_file.dispose(void);
          v_fsm_state := E_WAIT;

        when E_WAIT =>
          ---------------------------------------------------------------------
          -- wait to be sure: uvvm object are correctly initialized
          ---------------------------------------------------------------------
          if i_start = '1' then
            v_csv_file.initialize(i_filepath, Open_Kind => write_mode, csv_separator => i_csv_separator);

            ---------------------------------------------------------------------
            -- write the file header
            ---------------------------------------------------------------------
            -- build header
            v_csv_file.write_string(value => c_NAME0, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME1, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME2, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME3, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME4, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME5, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME6, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME7, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME8, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME9, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME10, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME11, csv_separator => i_csv_separator);
            v_csv_file.write_string(value => c_NAME12, csv_separator => i_csv_separator, use_csv_separator => 0);


            v_csv_file.writeline(void);
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>
          if i_data_valid = '1' then


            v_csv_file.write_std_vec_as_common_typ(value => i_data0_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA0_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data1_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA1_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data2_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA2_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data3_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA3_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data4_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA4_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data5_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA5_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data6_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA6_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data7_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA7_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data8_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA8_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data9_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA9_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data10_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA10_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data11_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA11_COMMON_TYP);
            v_csv_file.write_std_vec_as_common_typ(value => i_data12_std_vect, csv_separator => i_csv_separator, common_typ => i_DATA12_COMMON_TYP, use_csv_separator => 0);

            v_csv_file.writeline(void);

          end if;

          --if i_start = '1' then
          v_fsm_state := E_RUN;
          --else
          -- file_close(fid);
          --v_csv_file.dispose(void);
          --v_fsm_state := E_END;
          --end if;

        when E_END =>
          -- c_TEST := false;
          v_fsm_state := E_END;

        when others => -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;

      wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure log_data_in_file13;


 

end package body pkg_log;
