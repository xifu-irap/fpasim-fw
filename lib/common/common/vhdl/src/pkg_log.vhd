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
--    This simulation VHDL package defines VHDL functions/procedures in order to
--      . save data in an output csv file.              
--
--    Note: This package should be compiled into the common_lib
--    Dependencies: 
--      . csv_lib.pkg_csv_file
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library csv_lib;
use csv_lib.pkg_csv_file.all;

use work.pkg_common.all;

package pkg_log is

  ---------------------------------------------------------------------
  -- This function allows to build column label of the *.csv file
  ---------------------------------------------------------------------
  --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
  --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
  --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
  --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
  --  data type = "STD_VEC" => no data convertion before writing in the output file
  function pkg_column_name(constant i_NAME : in string; constant i_DATA_TYP : in string := "INT") return string;

  ---------------------------------------------------------------------
  -- pkg_log_data_in_file_1
  ---------------------------------------------------------------------
  procedure pkg_log_data_in_file_1(
    signal   i_clk            : in std_logic;
    signal   i_start          : in std_logic;
    signal   i_stop           : in std_logic;
    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath              : in string;
    i_csv_separator         : in character;
    constant i_NAME0          : in string;
    --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
    --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
    --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
    --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
    --  data type = "STD_VEC" => no data convertion before writing in the output file
    constant i_DATA0_TYP      : in string := "INT";
    ---------------------------------------------------------------------
    -- signal to log
    ---------------------------------------------------------------------
    signal   i_data_valid     : in std_logic;
    signal   i_data0_std_vect : in std_logic_vector
  );

  ---------------------------------------------------------------------
  -- pkg_log_data_in_file_2
  ---------------------------------------------------------------------
  procedure pkg_log_data_in_file_2(
    signal   i_clk            : in std_logic;
    signal   i_start          : in std_logic;
    signal   i_stop           : in std_logic;
    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath              : in string;
    i_csv_separator         : in character;
    constant i_NAME0          : in string;
    constant i_NAME1          : in string;
    --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
    --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
    --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
    --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
    --  data type = "STD_VEC" => no data convertion before writing in the output file
    constant i_DATA0_TYP      : in string := "INT";
    constant i_DATA1_TYP      : in string := "INT";
    ---------------------------------------------------------------------
    -- signal to log
    ---------------------------------------------------------------------
    signal   i_data_valid     : in std_logic;
    signal   i_data0_std_vect : in std_logic_vector;
    signal   i_data1_std_vect : in std_logic_vector
  );

  ---------------------------------------------------------------------
  -- pkg_log_data_in_file_3
  ---------------------------------------------------------------------
  procedure pkg_log_data_in_file_3(
    signal   i_clk            : in std_logic;
    signal   i_start          : in std_logic;
    signal   i_stop           : in std_logic;
    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath              : in string;
    i_csv_separator         : in character;
    constant i_NAME0          : in string;
    constant i_NAME1          : in string;
    constant i_NAME2          : in string;
    --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
    --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
    --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
    --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
    --  data type = "STD_VEC" => no data convertion before writing in the output file
    constant i_DATA0_TYP      : in string := "INT";
    constant i_DATA1_TYP      : in string := "INT";
    constant i_DATA2_TYP      : in string := "INT";
    ---------------------------------------------------------------------
    -- signal to log
    ---------------------------------------------------------------------
    signal   i_data_valid     : in std_logic;
    signal   i_data0_std_vect : in std_logic_vector;
    signal   i_data1_std_vect : in std_logic_vector;
    signal   i_data2_std_vect : in std_logic_vector
  );

  ---------------------------------------------------------------------
  -- pkg_log_data_in_file_4
  ---------------------------------------------------------------------
  procedure pkg_log_data_in_file_4(
    signal   i_clk            : in std_logic;
    signal   i_start          : in std_logic;
    signal   i_stop           : in std_logic;
    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath              : in string;
    i_csv_separator         : in character;
    constant i_NAME0          : in string;
    constant i_NAME1          : in string;
    constant i_NAME2          : in string;
    constant i_NAME3          : in string;
    --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
    --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
    --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
    --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
    --  data type = "STD_VEC" => no data convertion before writing in the output file
    constant i_DATA0_TYP      : in string := "INT";
    constant i_DATA1_TYP      : in string := "INT";
    constant i_DATA2_TYP      : in string := "INT";
    constant i_DATA3_TYP      : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal   i_data_valid     : in std_logic;
    signal   i_data0_std_vect : in std_logic_vector;
    signal   i_data1_std_vect : in std_logic_vector;
    signal   i_data2_std_vect : in std_logic_vector;
    signal   i_data3_std_vect : in std_logic_vector
  );

  ---------------------------------------------------------------------
  -- pkg_log_data_in_file_5
  ---------------------------------------------------------------------
  procedure pkg_log_data_in_file_5(
    signal   i_clk            : in std_logic;
    signal   i_start          : in std_logic;
    signal   i_stop           : in std_logic;
    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath              : in string;
    i_csv_separator         : in character;
    constant i_NAME0          : in string;
    constant i_NAME1          : in string;
    constant i_NAME2          : in string;
    constant i_NAME3          : in string;
    constant i_NAME4          : in string;
    --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
    --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
    --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
    --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
    --  data type = "STD_VEC" => no data convertion before writing in the output file
    constant i_DATA0_TYP      : in string := "INT";
    constant i_DATA1_TYP      : in string := "INT";
    constant i_DATA2_TYP      : in string := "INT";
    constant i_DATA3_TYP      : in string := "INT";
    constant i_DATA4_TYP      : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal   i_data_valid     : in std_logic;
    signal   i_data0_std_vect : in std_logic_vector;
    signal   i_data1_std_vect : in std_logic_vector;
    signal   i_data2_std_vect : in std_logic_vector;
    signal   i_data3_std_vect : in std_logic_vector;
    signal   i_data4_std_vect : in std_logic_vector
  );

  ---------------------------------------------------------------------
  -- pkg_log_data_in_file_6
  ---------------------------------------------------------------------
  procedure pkg_log_data_in_file_6(
    signal   i_clk            : in std_logic;
    signal   i_start          : in std_logic;
    signal   i_stop           : in std_logic;
    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath              : in string;
    i_csv_separator         : in character;
    constant i_NAME0          : in string;
    constant i_NAME1          : in string;
    constant i_NAME2          : in string;
    constant i_NAME3          : in string;
    constant i_NAME4          : in string;
    constant i_NAME5          : in string;
    --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
    --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
    --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
    --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
    --  data type = "STD_VEC" => no data convertion before writing in the output file
    constant i_DATA0_TYP      : in string := "INT";
    constant i_DATA1_TYP      : in string := "INT";
    constant i_DATA2_TYP      : in string := "INT";
    constant i_DATA3_TYP      : in string := "INT";
    constant i_DATA4_TYP      : in string := "INT";
    constant i_DATA5_TYP      : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal   i_data_valid     : in std_logic;
    signal   i_data0_std_vect : in std_logic_vector;
    signal   i_data1_std_vect : in std_logic_vector;
    signal   i_data2_std_vect : in std_logic_vector;
    signal   i_data3_std_vect : in std_logic_vector;
    signal   i_data4_std_vect : in std_logic_vector;
    signal   i_data5_std_vect : in std_logic_vector
  );

  ---------------------------------------------------------------------
  -- pkg_log_data_in_file_7
  ---------------------------------------------------------------------
  procedure pkg_log_data_in_file_7(
    signal   i_clk            : in std_logic;
    signal   i_start          : in std_logic;
    signal   i_stop           : in std_logic;
    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath              : in string;
    i_csv_separator         : in character;
    constant i_NAME0          : in string;
    constant i_NAME1          : in string;
    constant i_NAME2          : in string;
    constant i_NAME3          : in string;
    constant i_NAME4          : in string;
    constant i_NAME5          : in string;
    constant i_NAME6          : in string;
    --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
    --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
    --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
    --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
    --  data type = "STD_VEC" => no data convertion before writing in the output file
    constant i_DATA0_TYP      : in string := "INT";
    constant i_DATA1_TYP      : in string := "INT";
    constant i_DATA2_TYP      : in string := "INT";
    constant i_DATA3_TYP      : in string := "INT";
    constant i_DATA4_TYP      : in string := "INT";
    constant i_DATA5_TYP      : in string := "INT";
    constant i_DATA6_TYP      : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal   i_data_valid     : in std_logic;
    signal   i_data0_std_vect : in std_logic_vector;
    signal   i_data1_std_vect : in std_logic_vector;
    signal   i_data2_std_vect : in std_logic_vector;
    signal   i_data3_std_vect : in std_logic_vector;
    signal   i_data4_std_vect : in std_logic_vector;
    signal   i_data5_std_vect : in std_logic_vector;
    signal   i_data6_std_vect : in std_logic_vector
  );

  ---------------------------------------------------------------------
  -- pkg_log_data_in_file_8
  ---------------------------------------------------------------------
  procedure pkg_log_data_in_file_8(
    signal   i_clk            : in std_logic;
    signal   i_start          : in std_logic;
    signal   i_stop           : in std_logic;
    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath              : in string;
    i_csv_separator         : in character;
    constant i_NAME0          : in string;
    constant i_NAME1          : in string;
    constant i_NAME2          : in string;
    constant i_NAME3          : in string;
    constant i_NAME4          : in string;
    constant i_NAME5          : in string;
    constant i_NAME6          : in string;
    constant i_NAME7          : in string;
    --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
    --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
    --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
    --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
    --  data type = "STD_VEC" => no data convertion before writing in the output file
    constant i_DATA0_TYP      : in string := "INT";
    constant i_DATA1_TYP      : in string := "INT";
    constant i_DATA2_TYP      : in string := "INT";
    constant i_DATA3_TYP      : in string := "INT";
    constant i_DATA4_TYP      : in string := "INT";
    constant i_DATA5_TYP      : in string := "INT";
    constant i_DATA6_TYP      : in string := "INT";
    constant i_DATA7_TYP      : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal   i_data_valid     : in std_logic;
    signal   i_data0_std_vect : in std_logic_vector;
    signal   i_data1_std_vect : in std_logic_vector;
    signal   i_data2_std_vect : in std_logic_vector;
    signal   i_data3_std_vect : in std_logic_vector;
    signal   i_data4_std_vect : in std_logic_vector;
    signal   i_data5_std_vect : in std_logic_vector;
    signal   i_data6_std_vect : in std_logic_vector;
    signal   i_data7_std_vect : in std_logic_vector
  );

  ---------------------------------------------------------------------
  -- pkg_log_data_in_file_10
  ---------------------------------------------------------------------
  procedure pkg_log_data_in_file_10(
    signal   i_clk            : in std_logic;
    signal   i_start          : in std_logic;
    signal   i_stop           : in std_logic;
    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath              : in string;
    i_csv_separator         : in character;
    constant i_NAME0          : in string;
    constant i_NAME1          : in string;
    constant i_NAME2          : in string;
    constant i_NAME3          : in string;
    constant i_NAME4          : in string;
    constant i_NAME5          : in string;
    constant i_NAME6          : in string;
    constant i_NAME7          : in string;
    constant i_NAME8          : in string;
    constant i_NAME9          : in string;
    --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
    --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
    --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
    --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
    --  data type = "STD_VEC" => no data convertion before writing in the output file
    constant i_DATA0_TYP      : in string := "INT";
    constant i_DATA1_TYP      : in string := "INT";
    constant i_DATA2_TYP      : in string := "INT";
    constant i_DATA3_TYP      : in string := "INT";
    constant i_DATA4_TYP      : in string := "INT";
    constant i_DATA5_TYP      : in string := "INT";
    constant i_DATA6_TYP      : in string := "INT";
    constant i_DATA7_TYP      : in string := "INT";
    constant i_DATA8_TYP      : in string := "INT";
    constant i_DATA9_TYP      : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal   i_data_valid     : in std_logic;
    signal   i_data0_std_vect : in std_logic_vector;
    signal   i_data1_std_vect : in std_logic_vector;
    signal   i_data2_std_vect : in std_logic_vector;
    signal   i_data3_std_vect : in std_logic_vector;
    signal   i_data4_std_vect : in std_logic_vector;
    signal   i_data5_std_vect : in std_logic_vector;
    signal   i_data6_std_vect : in std_logic_vector;
    signal   i_data7_std_vect : in std_logic_vector;
    signal   i_data8_std_vect : in std_logic_vector;
    signal   i_data9_std_vect : in std_logic_vector
  );

  ---------------------------------------------------------------------
  -- pkg_log_data_in_file_11
  ---------------------------------------------------------------------
  procedure pkg_log_data_in_file_11(
    signal   i_clk             : in std_logic;
    signal   i_start           : in std_logic;
    signal   i_stop            : in std_logic;
    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath               : in string;
    i_csv_separator          : in character;
    constant i_NAME0           : in string;
    constant i_NAME1           : in string;
    constant i_NAME2           : in string;
    constant i_NAME3           : in string;
    constant i_NAME4           : in string;
    constant i_NAME5           : in string;
    constant i_NAME6           : in string;
    constant i_NAME7           : in string;
    constant i_NAME8           : in string;
    constant i_NAME9           : in string;
    constant i_NAME10          : in string;
    --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
    --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
    --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
    --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
    --  data type = "STD_VEC" => no data convertion before writing in the output file
    constant i_DATA0_TYP       : in string := "INT";
    constant i_DATA1_TYP       : in string := "INT";
    constant i_DATA2_TYP       : in string := "INT";
    constant i_DATA3_TYP       : in string := "INT";
    constant i_DATA4_TYP       : in string := "INT";
    constant i_DATA5_TYP       : in string := "INT";
    constant i_DATA6_TYP       : in string := "INT";
    constant i_DATA7_TYP       : in string := "INT";
    constant i_DATA8_TYP       : in string := "INT";
    constant i_DATA9_TYP       : in string := "INT";
    constant i_DATA10_TYP      : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal   i_data_valid      : in std_logic;
    signal   i_data0_std_vect  : in std_logic_vector;
    signal   i_data1_std_vect  : in std_logic_vector;
    signal   i_data2_std_vect  : in std_logic_vector;
    signal   i_data3_std_vect  : in std_logic_vector;
    signal   i_data4_std_vect  : in std_logic_vector;
    signal   i_data5_std_vect  : in std_logic_vector;
    signal   i_data6_std_vect  : in std_logic_vector;
    signal   i_data7_std_vect  : in std_logic_vector;
    signal   i_data8_std_vect  : in std_logic_vector;
    signal   i_data9_std_vect  : in std_logic_vector;
    signal   i_data10_std_vect : in std_logic_vector
  );

  ---------------------------------------------------------------------
  -- pkg_log_data_in_file_13
  ---------------------------------------------------------------------
  procedure pkg_log_data_in_file_13(
    signal   i_clk             : in std_logic;
    signal   i_start           : in std_logic;
    signal   i_stop            : in std_logic;
    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath               : in string;
    i_csv_separator          : in character;
    constant i_NAME0           : in string;
    constant i_NAME1           : in string;
    constant i_NAME2           : in string;
    constant i_NAME3           : in string;
    constant i_NAME4           : in string;
    constant i_NAME5           : in string;
    constant i_NAME6           : in string;
    constant i_NAME7           : in string;
    constant i_NAME8           : in string;
    constant i_NAME9           : in string;
    constant i_NAME10          : in string;
    constant i_NAME11          : in string;
    constant i_NAME12          : in string;
    --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
    --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
    --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
    --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
    --  data type = "STD_VEC" => no data convertion before writing in the output file
    constant i_DATA0_TYP       : in string := "INT";
    constant i_DATA1_TYP       : in string := "INT";
    constant i_DATA2_TYP       : in string := "INT";
    constant i_DATA3_TYP       : in string := "INT";
    constant i_DATA4_TYP       : in string := "INT";
    constant i_DATA5_TYP       : in string := "INT";
    constant i_DATA6_TYP       : in string := "INT";
    constant i_DATA7_TYP       : in string := "INT";
    constant i_DATA8_TYP       : in string := "INT";
    constant i_DATA9_TYP       : in string := "INT";
    constant i_DATA10_TYP      : in string := "INT";
    constant i_DATA11_TYP      : in string := "INT";
    constant i_DATA12_TYP      : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal   i_data_valid      : in std_logic;
    signal   i_data0_std_vect  : in std_logic_vector;
    signal   i_data1_std_vect  : in std_logic_vector;
    signal   i_data2_std_vect  : in std_logic_vector;
    signal   i_data3_std_vect  : in std_logic_vector;
    signal   i_data4_std_vect  : in std_logic_vector;
    signal   i_data5_std_vect  : in std_logic_vector;
    signal   i_data6_std_vect  : in std_logic_vector;
    signal   i_data7_std_vect  : in std_logic_vector;
    signal   i_data8_std_vect  : in std_logic_vector;
    signal   i_data9_std_vect  : in std_logic_vector;
    signal   i_data10_std_vect : in std_logic_vector;
    signal   i_data11_std_vect : in std_logic_vector;
    signal   i_data12_std_vect : in std_logic_vector
  );

end package pkg_log;

package body pkg_log is

  ---------------------------------------------------------------------
  -- This function allows to build column label of the *.csv file
  ---------------------------------------------------------------------
  --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
  --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
  --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
  --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
  --  data type = "STD_VEC" => no data convertion before writing in the output file
  function pkg_column_name(constant i_NAME : in string; constant i_DATA_TYP : in string := "INT") return string is
  begin
    return i_NAME & "_" & i_DATA_TYP & "";
  end function;

  ---------------------------------------------------------------------
  -- pkg_log_data_in_file_1
  ---------------------------------------------------------------------
  procedure pkg_log_data_in_file_1(
    signal   i_clk            : in std_logic;
    signal   i_start          : in std_logic;
    signal   i_stop           : in std_logic;
    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath              : in string;
    i_csv_separator         : in character;
    constant i_NAME0          : in string;
    --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
    --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
    --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
    --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
    --  data type = "STD_VEC" => no data convertion before writing in the output file
    constant i_DATA0_TYP      : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal   i_data_valid     : in std_logic;
    signal   i_data0_std_vect : in std_logic_vector
  ) is

    variable v_csv_file : t_csv_file_reader;

    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST      : boolean := true;
    constant c_NAME0     : string  := pkg_column_name(i_NAME => i_NAME0, i_DATA_TYP => i_DATA0_TYP);

  begin

    while c_TEST loop

      case v_fsm_state is

        when E_RST =>
          v_csv_file.dispose(void);
          v_fsm_state := E_WAIT;

        when E_WAIT =>

          if i_start = '1' then
            v_csv_file.initialize(i_filepath, i_open_kind => write_mode, i_csv_separator => i_csv_separator);

            ---------------------------------------------------------------------
            -- write the file header
            ---------------------------------------------------------------------
            -- build header
            v_csv_file.write_string(i_value => c_NAME0, i_csv_separator => i_csv_separator, i_use_csv_separator => 0);

            v_csv_file.writeline(void);
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>
          if i_data_valid = '1' then

            -- data_I
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data0_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA0_TYP, i_use_csv_separator => 0);

            v_csv_file.writeline(void);

          end if;

          if i_stop = '1' then
            v_csv_file.dispose(void);
            v_fsm_state := E_END;
          else
            v_fsm_state := E_RUN;
          end if;

        when E_END =>
          v_fsm_state := E_END;

        when others =>                  -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;

      pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure pkg_log_data_in_file_1;

  ---------------------------------------------------------------------
  -- pkg_log_data_in_file_2
  ---------------------------------------------------------------------
  procedure pkg_log_data_in_file_2(
    signal   i_clk            : in std_logic;
    signal   i_start          : in std_logic;
    signal   i_stop           : in std_logic;
    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath              : in string;
    i_csv_separator         : in character;
    constant i_NAME0          : in string;
    constant i_NAME1          : in string;
    --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
    --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
    --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
    --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
    --  data type = "STD_VEC" => no data convertion before writing in the output file
    constant i_DATA0_TYP      : in string := "INT";
    constant i_DATA1_TYP      : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal   i_data_valid     : in std_logic;
    signal   i_data0_std_vect : in std_logic_vector;
    signal   i_data1_std_vect : in std_logic_vector
  ) is

    variable v_csv_file : t_csv_file_reader;

    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST      : boolean := true;
    constant c_NAME0     : string  := pkg_column_name(i_NAME => i_NAME0, i_DATA_TYP => i_DATA0_TYP);
    constant c_NAME1     : string  := pkg_column_name(i_NAME => i_NAME1, i_DATA_TYP => i_DATA1_TYP);

  begin

    while c_TEST loop

      case v_fsm_state is

        when E_RST =>
          v_csv_file.dispose(void);
          v_fsm_state := E_WAIT;

        when E_WAIT =>

          if i_start = '1' then
            v_csv_file.initialize(i_filepath, i_open_kind => write_mode, i_csv_separator => i_csv_separator);

            ---------------------------------------------------------------------
            -- write the file header
            ---------------------------------------------------------------------
            -- build header

            v_csv_file.write_string(i_value => c_NAME0, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME1, i_csv_separator => i_csv_separator, i_use_csv_separator => 0);
            v_csv_file.writeline(void);
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>
          if i_data_valid = '1' then

            -- data0
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data0_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA0_TYP);
            -- data1
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data1_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA1_TYP, i_use_csv_separator => 0);

            v_csv_file.writeline(void);

          end if;

          if i_stop = '1' then
            v_csv_file.dispose(void);
            v_fsm_state := E_END;
          else
            v_fsm_state := E_RUN;
          end if;

        when E_END =>
          v_fsm_state := E_END;

        when others =>                  -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;

      pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure pkg_log_data_in_file_2;

  ---------------------------------------------------------------------
  -- pkg_log_data_in_file_3
  ---------------------------------------------------------------------
  procedure pkg_log_data_in_file_3(
    signal   i_clk            : in std_logic;
    signal   i_start          : in std_logic;
    signal   i_stop           : in std_logic;
    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath              : in string;
    i_csv_separator         : in character;
    constant i_NAME0          : in string;
    constant i_NAME1          : in string;
    constant i_NAME2          : in string;
    --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
    --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
    --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
    --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
    --  data type = "STD_VEC" => no data convertion before writing in the output file
    constant i_DATA0_TYP      : in string := "INT";
    constant i_DATA1_TYP      : in string := "INT";
    constant i_DATA2_TYP      : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal   i_data_valid     : in std_logic;
    signal   i_data0_std_vect : in std_logic_vector;
    signal   i_data1_std_vect : in std_logic_vector;
    signal   i_data2_std_vect : in std_logic_vector
  ) is

    variable v_csv_file : t_csv_file_reader;

    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST      : boolean := true;
    constant c_NAME0     : string  := pkg_column_name(i_NAME => i_NAME0, i_DATA_TYP => i_DATA0_TYP);
    constant c_NAME1     : string  := pkg_column_name(i_NAME => i_NAME1, i_DATA_TYP => i_DATA1_TYP);
    constant c_NAME2     : string  := pkg_column_name(i_NAME => i_NAME2, i_DATA_TYP => i_DATA2_TYP);

  begin

    while c_TEST loop

      case v_fsm_state is

        when E_RST =>
          v_csv_file.dispose(void);
          v_fsm_state := E_WAIT;

        when E_WAIT =>

          if i_start = '1' then
            v_csv_file.initialize(i_filepath, i_open_kind => write_mode, i_csv_separator => i_csv_separator);

            ---------------------------------------------------------------------
            -- write the file header
            ---------------------------------------------------------------------
            -- build header
            v_csv_file.write_string(i_value => c_NAME0, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME1, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME2, i_csv_separator => i_csv_separator, i_use_csv_separator => 0);
            v_csv_file.writeline(void);
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>
          if i_data_valid = '1' then

            v_csv_file.write_std_vec_as_data_typ(i_value => i_data0_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA0_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data1_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA1_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data2_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA2_TYP, i_use_csv_separator => 0);

            v_csv_file.writeline(void);

          end if;

          if i_stop = '1' then
            v_csv_file.dispose(void);
            v_fsm_state := E_END;
          else
            v_fsm_state := E_RUN;
          end if;

        when E_END =>
          v_fsm_state := E_END;

        when others =>                  -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;

      pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure pkg_log_data_in_file_3;

  ---------------------------------------------------------------------
  -- pkg_log_data_in_file_4
  ---------------------------------------------------------------------
  procedure pkg_log_data_in_file_4(
    signal   i_clk            : in std_logic;
    signal   i_start          : in std_logic;
    signal   i_stop           : in std_logic;
    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath              : in string;
    i_csv_separator         : in character;
    constant i_NAME0          : in string;
    constant i_NAME1          : in string;
    constant i_NAME2          : in string;
    constant i_NAME3          : in string;
    --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
    --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
    --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
    --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
    --  data type = "STD_VEC" => no data convertion before writing in the output file
    constant i_DATA0_TYP      : in string := "INT";
    constant i_DATA1_TYP      : in string := "INT";
    constant i_DATA2_TYP      : in string := "INT";
    constant i_DATA3_TYP      : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal   i_data_valid     : in std_logic;
    signal   i_data0_std_vect : in std_logic_vector;
    signal   i_data1_std_vect : in std_logic_vector;
    signal   i_data2_std_vect : in std_logic_vector;
    signal   i_data3_std_vect : in std_logic_vector
  ) is

    variable v_csv_file : t_csv_file_reader;

    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST      : boolean := true;

    constant c_NAME0 : string := pkg_column_name(i_NAME => i_NAME0, i_DATA_TYP => i_DATA0_TYP);
    constant c_NAME1 : string := pkg_column_name(i_NAME => i_NAME1, i_DATA_TYP => i_DATA1_TYP);
    constant c_NAME2 : string := pkg_column_name(i_NAME => i_NAME2, i_DATA_TYP => i_DATA2_TYP);
    constant c_NAME3 : string := pkg_column_name(i_NAME => i_NAME3, i_DATA_TYP => i_DATA3_TYP);

  begin

    while c_TEST loop

      case v_fsm_state is

        when E_RST =>
          v_csv_file.dispose(void);
          v_fsm_state := E_WAIT;

        when E_WAIT =>

          if i_start = '1' then
            v_csv_file.initialize(i_filepath, i_open_kind => write_mode, i_csv_separator => i_csv_separator);

            ---------------------------------------------------------------------
            -- write the file header
            ---------------------------------------------------------------------
            -- build header
            v_csv_file.write_string(i_value => c_NAME0, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME1, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME2, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME3, i_csv_separator => i_csv_separator, i_use_csv_separator => 0);
            v_csv_file.writeline(void);
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>
          if i_data_valid = '1' then

            v_csv_file.write_std_vec_as_data_typ(i_value => i_data0_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA0_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data1_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA1_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data2_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA2_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data3_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA3_TYP, i_use_csv_separator => 0);

            v_csv_file.writeline(void);

          end if;

          if i_stop = '1' then
            v_csv_file.dispose(void);
            v_fsm_state := E_END;
          else
            v_fsm_state := E_RUN;
          end if;

        when E_END =>
          v_fsm_state := E_END;

        when others =>                  -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;

      pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure pkg_log_data_in_file_4;

  ---------------------------------------------------------------------
  -- pkg_log_data_in_file_5
  ---------------------------------------------------------------------
  procedure pkg_log_data_in_file_5(
    signal   i_clk            : in std_logic;
    signal   i_start          : in std_logic;
    signal   i_stop           : in std_logic;
    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath              : in string;
    i_csv_separator         : in character;
    constant i_NAME0          : in string;
    constant i_NAME1          : in string;
    constant i_NAME2          : in string;
    constant i_NAME3          : in string;
    constant i_NAME4          : in string;
    --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
    --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
    --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
    --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
    --  data type = "STD_VEC" => no data convertion before writing in the output file
    constant i_DATA0_TYP      : in string := "INT";
    constant i_DATA1_TYP      : in string := "INT";
    constant i_DATA2_TYP      : in string := "INT";
    constant i_DATA3_TYP      : in string := "INT";
    constant i_DATA4_TYP      : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal   i_data_valid     : in std_logic;
    signal   i_data0_std_vect : in std_logic_vector;
    signal   i_data1_std_vect : in std_logic_vector;
    signal   i_data2_std_vect : in std_logic_vector;
    signal   i_data3_std_vect : in std_logic_vector;
    signal   i_data4_std_vect : in std_logic_vector
  ) is

    variable v_csv_file : t_csv_file_reader;

    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST      : boolean := true;

    constant c_NAME0 : string := pkg_column_name(i_NAME => i_NAME0, i_DATA_TYP => i_DATA0_TYP);
    constant c_NAME1 : string := pkg_column_name(i_NAME => i_NAME1, i_DATA_TYP => i_DATA1_TYP);
    constant c_NAME2 : string := pkg_column_name(i_NAME => i_NAME2, i_DATA_TYP => i_DATA2_TYP);
    constant c_NAME3 : string := pkg_column_name(i_NAME => i_NAME3, i_DATA_TYP => i_DATA3_TYP);
    constant c_NAME4 : string := pkg_column_name(i_NAME => i_NAME4, i_DATA_TYP => i_DATA4_TYP);

  begin

    while c_TEST loop

      case v_fsm_state is

        when E_RST =>
          v_csv_file.dispose(void);
          v_fsm_state := E_WAIT;

        when E_WAIT =>

          if i_start = '1' then
            v_csv_file.initialize(i_filepath, i_open_kind => write_mode, i_csv_separator => i_csv_separator);

            ---------------------------------------------------------------------
            -- write the file header
            ---------------------------------------------------------------------
            -- build header
            v_csv_file.write_string(i_value => c_NAME0, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME1, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME2, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME3, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME4, i_csv_separator => i_csv_separator, i_use_csv_separator => 0);
            v_csv_file.writeline(void);
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>
          if i_data_valid = '1' then

            v_csv_file.write_std_vec_as_data_typ(i_value => i_data0_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA0_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data1_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA1_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data2_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA2_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data3_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA3_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data4_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA4_TYP, i_use_csv_separator => 0);

            v_csv_file.writeline(void);

          end if;

          if i_stop = '1' then
            v_csv_file.dispose(void);
            v_fsm_state := E_END;
          else
            v_fsm_state := E_RUN;
          end if;

        when E_END =>
          v_fsm_state := E_END;

        when others =>                  -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;

      pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure pkg_log_data_in_file_5;

  ---------------------------------------------------------------------
  -- pkg_log_data_in_file_6
  ---------------------------------------------------------------------
  procedure pkg_log_data_in_file_6(
    signal   i_clk            : in std_logic;
    signal   i_start          : in std_logic;
    signal   i_stop           : in std_logic;
    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath              : in string;
    i_csv_separator         : in character;
    constant i_NAME0          : in string;
    constant i_NAME1          : in string;
    constant i_NAME2          : in string;
    constant i_NAME3          : in string;
    constant i_NAME4          : in string;
    constant i_NAME5          : in string;
    --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
    --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
    --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
    --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
    --  data type = "STD_VEC" => no data convertion before writing in the output file
    constant i_DATA0_TYP      : in string := "INT";
    constant i_DATA1_TYP      : in string := "INT";
    constant i_DATA2_TYP      : in string := "INT";
    constant i_DATA3_TYP      : in string := "INT";
    constant i_DATA4_TYP      : in string := "INT";
    constant i_DATA5_TYP      : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal   i_data_valid     : in std_logic;
    signal   i_data0_std_vect : in std_logic_vector;
    signal   i_data1_std_vect : in std_logic_vector;
    signal   i_data2_std_vect : in std_logic_vector;
    signal   i_data3_std_vect : in std_logic_vector;
    signal   i_data4_std_vect : in std_logic_vector;
    signal   i_data5_std_vect : in std_logic_vector
  ) is

    variable v_csv_file : t_csv_file_reader;

    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST      : boolean := true;

    constant c_NAME0 : string := pkg_column_name(i_NAME => i_NAME0, i_DATA_TYP => i_DATA0_TYP);
    constant c_NAME1 : string := pkg_column_name(i_NAME => i_NAME1, i_DATA_TYP => i_DATA1_TYP);
    constant c_NAME2 : string := pkg_column_name(i_NAME => i_NAME2, i_DATA_TYP => i_DATA2_TYP);
    constant c_NAME3 : string := pkg_column_name(i_NAME => i_NAME3, i_DATA_TYP => i_DATA3_TYP);
    constant c_NAME4 : string := pkg_column_name(i_NAME => i_NAME4, i_DATA_TYP => i_DATA4_TYP);
    constant c_NAME5 : string := pkg_column_name(i_NAME => i_NAME5, i_DATA_TYP => i_DATA5_TYP);

  begin

    while c_TEST loop

      case v_fsm_state is

        when E_RST =>
          v_csv_file.dispose(void);
          v_fsm_state := E_WAIT;

        when E_WAIT =>

          if i_start = '1' then
            v_csv_file.initialize(i_filepath, i_open_kind => write_mode, i_csv_separator => i_csv_separator);

            ---------------------------------------------------------------------
            -- write the file header
            ---------------------------------------------------------------------
            -- build header
            v_csv_file.write_string(i_value => c_NAME0, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME1, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME2, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME3, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME4, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME5, i_csv_separator => i_csv_separator, i_use_csv_separator => 0);
            v_csv_file.writeline(void);
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>
          if i_data_valid = '1' then

            v_csv_file.write_std_vec_as_data_typ(i_value => i_data0_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA0_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data1_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA1_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data2_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA2_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data3_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA3_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data4_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA4_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data5_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA5_TYP, i_use_csv_separator => 0);

            v_csv_file.writeline(void);

          end if;

          if i_stop = '1' then
            v_csv_file.dispose(void);
            v_fsm_state := E_END;
          else
            v_fsm_state := E_RUN;
          end if;

        when E_END =>
          v_fsm_state := E_END;

        when others =>                  -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;

      pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure pkg_log_data_in_file_6;

  ---------------------------------------------------------------------
  -- pkg_log_data_in_file_7
  ---------------------------------------------------------------------
  procedure pkg_log_data_in_file_7(
    signal   i_clk            : in std_logic;
    signal   i_start          : in std_logic;
    signal   i_stop           : in std_logic;
    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath              : in string;
    i_csv_separator         : in character;
    constant i_NAME0          : in string;
    constant i_NAME1          : in string;
    constant i_NAME2          : in string;
    constant i_NAME3          : in string;
    constant i_NAME4          : in string;
    constant i_NAME5          : in string;
    constant i_NAME6          : in string;
    --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
    --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
    --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
    --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
    --  data type = "STD_VEC" => no data convertion before writing in the output file
    constant i_DATA0_TYP      : in string := "INT";
    constant i_DATA1_TYP      : in string := "INT";
    constant i_DATA2_TYP      : in string := "INT";
    constant i_DATA3_TYP      : in string := "INT";
    constant i_DATA4_TYP      : in string := "INT";
    constant i_DATA5_TYP      : in string := "INT";
    constant i_DATA6_TYP      : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal   i_data_valid     : in std_logic;
    signal   i_data0_std_vect : in std_logic_vector;
    signal   i_data1_std_vect : in std_logic_vector;
    signal   i_data2_std_vect : in std_logic_vector;
    signal   i_data3_std_vect : in std_logic_vector;
    signal   i_data4_std_vect : in std_logic_vector;
    signal   i_data5_std_vect : in std_logic_vector;
    signal   i_data6_std_vect : in std_logic_vector
  ) is

    variable v_csv_file : t_csv_file_reader;

    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST      : boolean := true;

    constant c_NAME0 : string := pkg_column_name(i_NAME => i_NAME0, i_DATA_TYP => i_DATA0_TYP);
    constant c_NAME1 : string := pkg_column_name(i_NAME => i_NAME1, i_DATA_TYP => i_DATA1_TYP);
    constant c_NAME2 : string := pkg_column_name(i_NAME => i_NAME2, i_DATA_TYP => i_DATA2_TYP);
    constant c_NAME3 : string := pkg_column_name(i_NAME => i_NAME3, i_DATA_TYP => i_DATA3_TYP);
    constant c_NAME4 : string := pkg_column_name(i_NAME => i_NAME4, i_DATA_TYP => i_DATA4_TYP);
    constant c_NAME5 : string := pkg_column_name(i_NAME => i_NAME5, i_DATA_TYP => i_DATA5_TYP);
    constant c_NAME6 : string := pkg_column_name(i_NAME => i_NAME6, i_DATA_TYP => i_DATA6_TYP);

  begin

    while c_TEST loop

      case v_fsm_state is

        when E_RST =>
          v_csv_file.dispose(void);
          v_fsm_state := E_WAIT;

        when E_WAIT =>

          if i_start = '1' then
            v_csv_file.initialize(i_filepath, i_open_kind => write_mode, i_csv_separator => i_csv_separator);

            ---------------------------------------------------------------------
            -- write the file header
            ---------------------------------------------------------------------
            -- build header
            v_csv_file.write_string(i_value => c_NAME0, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME1, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME2, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME3, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME4, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME5, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME6, i_csv_separator => i_csv_separator, i_use_csv_separator => 0);
            v_csv_file.writeline(void);
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>
          if i_data_valid = '1' then

            v_csv_file.write_std_vec_as_data_typ(i_value => i_data0_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA0_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data1_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA1_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data2_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA2_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data3_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA3_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data4_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA4_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data5_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA5_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data6_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA6_TYP, i_use_csv_separator => 0);

            v_csv_file.writeline(void);

          end if;

          if i_stop = '1' then
            v_csv_file.dispose(void);
            v_fsm_state := E_END;
          else
            v_fsm_state := E_RUN;
          end if;

        when E_END =>
          v_fsm_state := E_END;

        when others =>                  -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;

      pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure pkg_log_data_in_file_7;

  ---------------------------------------------------------------------
  -- pkg_log_data_in_file_8
  ---------------------------------------------------------------------
  procedure pkg_log_data_in_file_8(
    signal   i_clk            : in std_logic;
    signal   i_start          : in std_logic;
    signal   i_stop           : in std_logic;
    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath              : in string;
    i_csv_separator         : in character;
    constant i_NAME0          : in string;
    constant i_NAME1          : in string;
    constant i_NAME2          : in string;
    constant i_NAME3          : in string;
    constant i_NAME4          : in string;
    constant i_NAME5          : in string;
    constant i_NAME6          : in string;
    constant i_NAME7          : in string;
    --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
    --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
    --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
    --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
    --  data type = "STD_VEC" => no data convertion before writing in the output file
    constant i_DATA0_TYP      : in string := "INT";
    constant i_DATA1_TYP      : in string := "INT";
    constant i_DATA2_TYP      : in string := "INT";
    constant i_DATA3_TYP      : in string := "INT";
    constant i_DATA4_TYP      : in string := "INT";
    constant i_DATA5_TYP      : in string := "INT";
    constant i_DATA6_TYP      : in string := "INT";
    constant i_DATA7_TYP      : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal   i_data_valid     : in std_logic;
    signal   i_data0_std_vect : in std_logic_vector;
    signal   i_data1_std_vect : in std_logic_vector;
    signal   i_data2_std_vect : in std_logic_vector;
    signal   i_data3_std_vect : in std_logic_vector;
    signal   i_data4_std_vect : in std_logic_vector;
    signal   i_data5_std_vect : in std_logic_vector;
    signal   i_data6_std_vect : in std_logic_vector;
    signal   i_data7_std_vect : in std_logic_vector
  ) is

    variable v_csv_file : t_csv_file_reader;

    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST      : boolean := true;

    constant c_NAME0 : string := pkg_column_name(i_NAME => i_NAME0, i_DATA_TYP => i_DATA0_TYP);
    constant c_NAME1 : string := pkg_column_name(i_NAME => i_NAME1, i_DATA_TYP => i_DATA1_TYP);
    constant c_NAME2 : string := pkg_column_name(i_NAME => i_NAME2, i_DATA_TYP => i_DATA2_TYP);
    constant c_NAME3 : string := pkg_column_name(i_NAME => i_NAME3, i_DATA_TYP => i_DATA3_TYP);
    constant c_NAME4 : string := pkg_column_name(i_NAME => i_NAME4, i_DATA_TYP => i_DATA4_TYP);
    constant c_NAME5 : string := pkg_column_name(i_NAME => i_NAME5, i_DATA_TYP => i_DATA5_TYP);
    constant c_NAME6 : string := pkg_column_name(i_NAME => i_NAME6, i_DATA_TYP => i_DATA6_TYP);
    constant c_NAME7 : string := pkg_column_name(i_NAME => i_NAME7, i_DATA_TYP => i_DATA7_TYP);

  begin

    while c_TEST loop

      case v_fsm_state is

        when E_RST =>
          v_csv_file.dispose(void);
          v_fsm_state := E_WAIT;

        when E_WAIT =>

          if i_start = '1' then
            v_csv_file.initialize(i_filepath, i_open_kind => write_mode, i_csv_separator => i_csv_separator);

            ---------------------------------------------------------------------
            -- write the file header
            ---------------------------------------------------------------------
            -- build header
            v_csv_file.write_string(i_value => c_NAME0, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME1, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME2, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME3, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME4, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME5, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME6, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME7, i_csv_separator => i_csv_separator, i_use_csv_separator => 0);
            v_csv_file.writeline(void);
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>
          if i_data_valid = '1' then

            v_csv_file.write_std_vec_as_data_typ(i_value => i_data0_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA0_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data1_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA1_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data2_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA2_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data3_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA3_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data4_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA4_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data5_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA5_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data6_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA6_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data7_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA7_TYP, i_use_csv_separator => 0);

            v_csv_file.writeline(void);

          end if;

          if i_stop = '1' then
            v_csv_file.dispose(void);
            v_fsm_state := E_END;
          else
            v_fsm_state := E_RUN;
          end if;

        when E_END =>
          v_fsm_state := E_END;

        when others =>                  -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;

      pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure pkg_log_data_in_file_8;

  ---------------------------------------------------------------------
  -- pkg_log_data_in_file_10
  ---------------------------------------------------------------------
  procedure pkg_log_data_in_file_10(
    signal   i_clk            : in std_logic;
    signal   i_start          : in std_logic;
    signal   i_stop           : in std_logic;
    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath              : in string;
    i_csv_separator         : in character;
    constant i_NAME0          : in string;
    constant i_NAME1          : in string;
    constant i_NAME2          : in string;
    constant i_NAME3          : in string;
    constant i_NAME4          : in string;
    constant i_NAME5          : in string;
    constant i_NAME6          : in string;
    constant i_NAME7          : in string;
    constant i_NAME8          : in string;
    constant i_NAME9          : in string;
    --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
    --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
    --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
    --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
    --  data type = "STD_VEC" => no data convertion before writing in the output file
    constant i_DATA0_TYP      : in string := "INT";
    constant i_DATA1_TYP      : in string := "INT";
    constant i_DATA2_TYP      : in string := "INT";
    constant i_DATA3_TYP      : in string := "INT";
    constant i_DATA4_TYP      : in string := "INT";
    constant i_DATA5_TYP      : in string := "INT";
    constant i_DATA6_TYP      : in string := "INT";
    constant i_DATA7_TYP      : in string := "INT";
    constant i_DATA8_TYP      : in string := "INT";
    constant i_DATA9_TYP      : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal   i_data_valid     : in std_logic;
    signal   i_data0_std_vect : in std_logic_vector;
    signal   i_data1_std_vect : in std_logic_vector;
    signal   i_data2_std_vect : in std_logic_vector;
    signal   i_data3_std_vect : in std_logic_vector;
    signal   i_data4_std_vect : in std_logic_vector;
    signal   i_data5_std_vect : in std_logic_vector;
    signal   i_data6_std_vect : in std_logic_vector;
    signal   i_data7_std_vect : in std_logic_vector;
    signal   i_data8_std_vect : in std_logic_vector;
    signal   i_data9_std_vect : in std_logic_vector
  ) is

    variable v_csv_file : t_csv_file_reader;

    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST      : boolean := true;

    constant c_NAME0 : string := pkg_column_name(i_NAME => i_NAME0, i_DATA_TYP => i_DATA0_TYP);
    constant c_NAME1 : string := pkg_column_name(i_NAME => i_NAME1, i_DATA_TYP => i_DATA1_TYP);
    constant c_NAME2 : string := pkg_column_name(i_NAME => i_NAME2, i_DATA_TYP => i_DATA2_TYP);
    constant c_NAME3 : string := pkg_column_name(i_NAME => i_NAME3, i_DATA_TYP => i_DATA3_TYP);
    constant c_NAME4 : string := pkg_column_name(i_NAME => i_NAME4, i_DATA_TYP => i_DATA4_TYP);
    constant c_NAME5 : string := pkg_column_name(i_NAME => i_NAME5, i_DATA_TYP => i_DATA5_TYP);
    constant c_NAME6 : string := pkg_column_name(i_NAME => i_NAME6, i_DATA_TYP => i_DATA6_TYP);
    constant c_NAME7 : string := pkg_column_name(i_NAME => i_NAME7, i_DATA_TYP => i_DATA7_TYP);
    constant c_NAME8 : string := pkg_column_name(i_NAME => i_NAME8, i_DATA_TYP => i_DATA8_TYP);
    constant c_NAME9 : string := pkg_column_name(i_NAME => i_NAME9, i_DATA_TYP => i_DATA9_TYP);

  begin

    while c_TEST loop

      case v_fsm_state is

        when E_RST =>
          v_csv_file.dispose(void);
          v_fsm_state := E_WAIT;

        when E_WAIT =>

          if i_start = '1' then
            v_csv_file.initialize(i_filepath, i_open_kind => write_mode, i_csv_separator => i_csv_separator);

            ---------------------------------------------------------------------
            -- write the file header
            ---------------------------------------------------------------------
            -- build header
            v_csv_file.write_string(i_value => c_NAME0, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME1, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME2, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME3, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME4, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME5, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME6, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME7, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME8, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME9, i_csv_separator => i_csv_separator, i_use_csv_separator => 0);

            v_csv_file.writeline(void);
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>
          if i_data_valid = '1' then

            v_csv_file.write_std_vec_as_data_typ(i_value => i_data0_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA0_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data1_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA1_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data2_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA2_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data3_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA3_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data4_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA4_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data5_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA5_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data6_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA6_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data7_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA7_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data8_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA8_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data9_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA9_TYP, i_use_csv_separator => 0);

            v_csv_file.writeline(void);

          end if;

          if i_stop = '1' then
            v_csv_file.dispose(void);
            v_fsm_state := E_END;
          else
            v_fsm_state := E_RUN;
          end if;
        when E_END =>
          v_fsm_state := E_END;

        when others =>                  -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;

      pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure pkg_log_data_in_file_10;

  ---------------------------------------------------------------------
  -- pkg_log_data_in_file_11
  ---------------------------------------------------------------------
  procedure pkg_log_data_in_file_11(
    signal   i_clk             : in std_logic;
    signal   i_start           : in std_logic;
    signal   i_stop            : in std_logic;
    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath               : in string;
    i_csv_separator          : in character;
    constant i_NAME0           : in string;
    constant i_NAME1           : in string;
    constant i_NAME2           : in string;
    constant i_NAME3           : in string;
    constant i_NAME4           : in string;
    constant i_NAME5           : in string;
    constant i_NAME6           : in string;
    constant i_NAME7           : in string;
    constant i_NAME8           : in string;
    constant i_NAME9           : in string;
    constant i_NAME10          : in string;
    --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
    --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
    --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
    --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
    --  data type = "STD_VEC" => no data convertion before writing in the output file
    constant i_DATA0_TYP       : in string := "INT";
    constant i_DATA1_TYP       : in string := "INT";
    constant i_DATA2_TYP       : in string := "INT";
    constant i_DATA3_TYP       : in string := "INT";
    constant i_DATA4_TYP       : in string := "INT";
    constant i_DATA5_TYP       : in string := "INT";
    constant i_DATA6_TYP       : in string := "INT";
    constant i_DATA7_TYP       : in string := "INT";
    constant i_DATA8_TYP       : in string := "INT";
    constant i_DATA9_TYP       : in string := "INT";
    constant i_DATA10_TYP      : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal   i_data_valid      : in std_logic;
    signal   i_data0_std_vect  : in std_logic_vector;
    signal   i_data1_std_vect  : in std_logic_vector;
    signal   i_data2_std_vect  : in std_logic_vector;
    signal   i_data3_std_vect  : in std_logic_vector;
    signal   i_data4_std_vect  : in std_logic_vector;
    signal   i_data5_std_vect  : in std_logic_vector;
    signal   i_data6_std_vect  : in std_logic_vector;
    signal   i_data7_std_vect  : in std_logic_vector;
    signal   i_data8_std_vect  : in std_logic_vector;
    signal   i_data9_std_vect  : in std_logic_vector;
    signal   i_data10_std_vect : in std_logic_vector
  ) is

    variable v_csv_file : t_csv_file_reader;

    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST      : boolean := true;

    constant c_NAME0  : string := pkg_column_name(i_NAME => i_NAME0, i_DATA_TYP => i_DATA0_TYP);
    constant c_NAME1  : string := pkg_column_name(i_NAME => i_NAME1, i_DATA_TYP => i_DATA1_TYP);
    constant c_NAME2  : string := pkg_column_name(i_NAME => i_NAME2, i_DATA_TYP => i_DATA2_TYP);
    constant c_NAME3  : string := pkg_column_name(i_NAME => i_NAME3, i_DATA_TYP => i_DATA3_TYP);
    constant c_NAME4  : string := pkg_column_name(i_NAME => i_NAME4, i_DATA_TYP => i_DATA4_TYP);
    constant c_NAME5  : string := pkg_column_name(i_NAME => i_NAME5, i_DATA_TYP => i_DATA5_TYP);
    constant c_NAME6  : string := pkg_column_name(i_NAME => i_NAME6, i_DATA_TYP => i_DATA6_TYP);
    constant c_NAME7  : string := pkg_column_name(i_NAME => i_NAME7, i_DATA_TYP => i_DATA7_TYP);
    constant c_NAME8  : string := pkg_column_name(i_NAME => i_NAME8, i_DATA_TYP => i_DATA8_TYP);
    constant c_NAME9  : string := pkg_column_name(i_NAME => i_NAME9, i_DATA_TYP => i_DATA9_TYP);
    constant c_NAME10 : string := pkg_column_name(i_NAME => i_NAME10, i_DATA_TYP => i_DATA10_TYP);

  begin

    while c_TEST loop

      case v_fsm_state is

        when E_RST =>
          v_csv_file.dispose(void);
          v_fsm_state := E_WAIT;

        when E_WAIT =>

          if i_start = '1' then
            v_csv_file.initialize(i_filepath, i_open_kind => write_mode, i_csv_separator => i_csv_separator);

            ---------------------------------------------------------------------
            -- write the file header
            ---------------------------------------------------------------------
            -- build header
            v_csv_file.write_string(i_value => c_NAME0, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME1, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME2, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME3, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME4, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME5, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME6, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME7, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME8, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME9, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME10, i_csv_separator => i_csv_separator, i_use_csv_separator => 0);

            v_csv_file.writeline(void);
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>
          if i_data_valid = '1' then

            v_csv_file.write_std_vec_as_data_typ(i_value => i_data0_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA0_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data1_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA1_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data2_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA2_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data3_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA3_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data4_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA4_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data5_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA5_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data6_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA6_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data7_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA7_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data8_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA8_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data9_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA9_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data10_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA10_TYP, i_use_csv_separator => 0);
            v_csv_file.writeline(void);

          end if;

          if i_stop = '1' then
            v_csv_file.dispose(void);
            v_fsm_state := E_END;
          else
            v_fsm_state := E_RUN;
          end if;

        when E_END =>
          v_fsm_state := E_END;

        when others =>                  -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;

      pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure pkg_log_data_in_file_11;

  ---------------------------------------------------------------------
  -- pkg_log_data_in_file_13
  ---------------------------------------------------------------------
  procedure pkg_log_data_in_file_13(
    signal   i_clk             : in std_logic;
    signal   i_start           : in std_logic;
    signal   i_stop            : in std_logic;
    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath               : in string;
    i_csv_separator          : in character;
    constant i_NAME0           : in string;
    constant i_NAME1           : in string;
    constant i_NAME2           : in string;
    constant i_NAME3           : in string;
    constant i_NAME4           : in string;
    constant i_NAME5           : in string;
    constant i_NAME6           : in string;
    constant i_NAME7           : in string;
    constant i_NAME8           : in string;
    constant i_NAME9           : in string;
    constant i_NAME10          : in string;
    constant i_NAME11          : in string;
    constant i_NAME12          : in string;
    --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
    --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
    --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
    --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
    --  data type = "STD_VEC" => no data convertion before writing in the output file
    constant i_DATA0_TYP       : in string := "INT";
    constant i_DATA1_TYP       : in string := "INT";
    constant i_DATA2_TYP       : in string := "INT";
    constant i_DATA3_TYP       : in string := "INT";
    constant i_DATA4_TYP       : in string := "INT";
    constant i_DATA5_TYP       : in string := "INT";
    constant i_DATA6_TYP       : in string := "INT";
    constant i_DATA7_TYP       : in string := "INT";
    constant i_DATA8_TYP       : in string := "INT";
    constant i_DATA9_TYP       : in string := "INT";
    constant i_DATA10_TYP      : in string := "INT";
    constant i_DATA11_TYP      : in string := "INT";
    constant i_DATA12_TYP      : in string := "INT";
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal   i_data_valid      : in std_logic;
    signal   i_data0_std_vect  : in std_logic_vector;
    signal   i_data1_std_vect  : in std_logic_vector;
    signal   i_data2_std_vect  : in std_logic_vector;
    signal   i_data3_std_vect  : in std_logic_vector;
    signal   i_data4_std_vect  : in std_logic_vector;
    signal   i_data5_std_vect  : in std_logic_vector;
    signal   i_data6_std_vect  : in std_logic_vector;
    signal   i_data7_std_vect  : in std_logic_vector;
    signal   i_data8_std_vect  : in std_logic_vector;
    signal   i_data9_std_vect  : in std_logic_vector;
    signal   i_data10_std_vect : in std_logic_vector;
    signal   i_data11_std_vect : in std_logic_vector;
    signal   i_data12_std_vect : in std_logic_vector
  ) is

    variable v_csv_file : t_csv_file_reader;

    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST      : boolean := true;

    constant c_NAME0  : string := pkg_column_name(i_NAME => i_NAME0, i_DATA_TYP => i_DATA0_TYP);
    constant c_NAME1  : string := pkg_column_name(i_NAME => i_NAME1, i_DATA_TYP => i_DATA1_TYP);
    constant c_NAME2  : string := pkg_column_name(i_NAME => i_NAME2, i_DATA_TYP => i_DATA2_TYP);
    constant c_NAME3  : string := pkg_column_name(i_NAME => i_NAME3, i_DATA_TYP => i_DATA3_TYP);
    constant c_NAME4  : string := pkg_column_name(i_NAME => i_NAME4, i_DATA_TYP => i_DATA4_TYP);
    constant c_NAME5  : string := pkg_column_name(i_NAME => i_NAME5, i_DATA_TYP => i_DATA5_TYP);
    constant c_NAME6  : string := pkg_column_name(i_NAME => i_NAME6, i_DATA_TYP => i_DATA6_TYP);
    constant c_NAME7  : string := pkg_column_name(i_NAME => i_NAME7, i_DATA_TYP => i_DATA7_TYP);
    constant c_NAME8  : string := pkg_column_name(i_NAME => i_NAME8, i_DATA_TYP => i_DATA8_TYP);
    constant c_NAME9  : string := pkg_column_name(i_NAME => i_NAME9, i_DATA_TYP => i_DATA9_TYP);
    constant c_NAME10 : string := pkg_column_name(i_NAME => i_NAME10, i_DATA_TYP => i_DATA10_TYP);
    constant c_NAME11 : string := pkg_column_name(i_NAME => i_NAME11, i_DATA_TYP => i_DATA11_TYP);
    constant c_NAME12 : string := pkg_column_name(i_NAME => i_NAME12, i_DATA_TYP => i_DATA12_TYP);

  begin

    while c_TEST loop

      case v_fsm_state is

        when E_RST =>
          v_csv_file.dispose(void);
          v_fsm_state := E_WAIT;

        when E_WAIT =>

          if i_start = '1' then
            v_csv_file.initialize(i_filepath, i_open_kind => write_mode, i_csv_separator => i_csv_separator);

            ---------------------------------------------------------------------
            -- write the file header
            ---------------------------------------------------------------------
            -- build header
            v_csv_file.write_string(i_value => c_NAME0, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME1, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME2, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME3, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME4, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME5, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME6, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME7, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME8, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME9, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME10, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME11, i_csv_separator => i_csv_separator);
            v_csv_file.write_string(i_value => c_NAME12, i_csv_separator => i_csv_separator, i_use_csv_separator => 0);

            v_csv_file.writeline(void);
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>
          if i_data_valid = '1' then

            v_csv_file.write_std_vec_as_data_typ(i_value => i_data0_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA0_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data1_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA1_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data2_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA2_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data3_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA3_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data4_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA4_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data5_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA5_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data6_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA6_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data7_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA7_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data8_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA8_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data9_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA9_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data10_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA10_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data11_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA11_TYP);
            v_csv_file.write_std_vec_as_data_typ(i_value => i_data12_std_vect, i_csv_separator => i_csv_separator, i_data_typ => i_DATA12_TYP, i_use_csv_separator => 0);

            v_csv_file.writeline(void);

          end if;

          if i_stop = '1' then
            v_csv_file.dispose(void);
            v_fsm_state := E_END;
          else
            v_fsm_state := E_RUN;
          end if;

        when E_END =>
          v_fsm_state := E_END;

        when others =>                  -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;

      pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure pkg_log_data_in_file_13;

end package body pkg_log;
