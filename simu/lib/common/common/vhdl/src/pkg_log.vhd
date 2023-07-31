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
  --  data type = "UINT"
  --  data type = "INT"
  --  data type = "HEX"
  --  data type = "UHEX"
  --  data type = "STD_VEC"
  function pkg_get_column_name(
            -- column name
           constant i_NAME : in string;
           -- data type of the column
           constant i_DATA_TYP : in string := "INT"
           ) return string;


  ---------------------------------------------------------------------
  -- pkg_log_data_in_file_2
  ---------------------------------------------------------------------
  procedure pkg_log_data_in_file_2(
    signal   i_clk            : in std_logic; -- clock
    signal   i_start          : in std_logic; -- start procedure
    signal   i_stop           : in std_logic; -- stop procedure
    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath              : in string; -- input *.csv filepath
    i_csv_separator         : in character; -- *.csv file separator
    constant i_NAME0          : in string; -- csv column name to write in the file: column0
    constant i_NAME1          : in string; -- csv column name to write in the file: column1
    --  data type = "UINT" => the data to write in the file are converted: std_logic_vector -> uint
    --  data type = "INT" => the data to write in the file are converted: std_logic_vector -> int
    --  data type = "HEX" => the data to write in the file are converted: std_logic_vector -> int -> hex
    --  data type = "UHEX" => the data to write in the file are converted: std_logic_vector -> uint -> hex
    --  data type = "STD_VEC" => the data to write in the file aren't converted : std_logic_vector -> std_logic_vector
    constant i_DATA0_TYP      : in string := "INT";  -- data format of the output csv file: column0
    constant i_DATA1_TYP      : in string := "INT";  -- data format of the output csv file: column1
    ---------------------------------------------------------------------
    -- signal to log
    ---------------------------------------------------------------------
    signal   i_data_valid     : in std_logic; -- input data valid
    signal   i_data0_std_vect : in std_logic_vector; -- input data0
    signal   i_data1_std_vect : in std_logic_vector  -- input data1
  );



  ---------------------------------------------------------------------
  -- pkg_log_data_in_file_7
  ---------------------------------------------------------------------
  procedure pkg_log_data_in_file_7(
    signal   i_clk            : in std_logic; -- clock
    signal   i_start          : in std_logic; -- start procedure
    signal   i_stop           : in std_logic; -- stop procedure
    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath              : in string; -- input *.csv filepath
    i_csv_separator         : in character; -- *.csv file separator
    constant i_NAME0          : in string;  -- csv column name to write in the file: column0
    constant i_NAME1          : in string;  -- csv column name to write in the file: column1
    constant i_NAME2          : in string;  -- csv column name to write in the file: column2
    constant i_NAME3          : in string;  -- csv column name to write in the file: column3
    constant i_NAME4          : in string;  -- csv column name to write in the file: column4
    constant i_NAME5          : in string;  -- csv column name to write in the file: column5
    constant i_NAME6          : in string;  -- csv column name to write in the file: column6
    --  data type = "UINT" => the data to write in the file are converted: std_logic_vector -> uint
    --  data type = "INT" => the data to write in the file are converted: std_logic_vector -> int
    --  data type = "HEX" => the data to write in the file are converted: std_logic_vector -> int -> hex
    --  data type = "UHEX" => the data to write in the file are converted: std_logic_vector -> uint -> hex
    --  data type = "STD_VEC" => the data to write in the file aren't converted : std_logic_vector -> std_logic_vector
    constant i_DATA0_TYP      : in string := "INT"; -- data format of the output csv file: column0
    constant i_DATA1_TYP      : in string := "INT"; -- data format of the output csv file: column1
    constant i_DATA2_TYP      : in string := "INT"; -- data format of the output csv file: column2
    constant i_DATA3_TYP      : in string := "INT"; -- data format of the output csv file: column3
    constant i_DATA4_TYP      : in string := "INT"; -- data format of the output csv file: column4
    constant i_DATA5_TYP      : in string := "INT"; -- data format of the output csv file: column5
    constant i_DATA6_TYP      : in string := "INT"; -- data format of the output csv file: column6
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal   i_data_valid     : in std_logic; -- input data valid
    signal   i_data0_std_vect : in std_logic_vector; -- input data0
    signal   i_data1_std_vect : in std_logic_vector; -- input data1
    signal   i_data2_std_vect : in std_logic_vector; -- input data2
    signal   i_data3_std_vect : in std_logic_vector; -- input data3
    signal   i_data4_std_vect : in std_logic_vector; -- input data4
    signal   i_data5_std_vect : in std_logic_vector; -- input data5
    signal   i_data6_std_vect : in std_logic_vector -- input data6
  );



end package pkg_log;

package body pkg_log is

  ---------------------------------------------------------------------
  -- This function allows to build column label of the *.csv file
  ---------------------------------------------------------------------
  --  data type = "UINT"
  --  data type = "INT"
  --  data type = "HEX"
  --  data type = "UHEX"
  --  data type = "STD_VEC"
  function pkg_get_column_name(
    -- column name
    constant i_NAME : in string;
    -- data type of the column
    constant i_DATA_TYP : in string := "INT"
    ) return string is
  begin
    return i_NAME & "_" & i_DATA_TYP & "";
  end function;


  ---------------------------------------------------------------------
  -- pkg_log_data_in_file_2
  ---------------------------------------------------------------------
  procedure pkg_log_data_in_file_2(
    signal   i_clk            : in std_logic; -- clock
    signal   i_start          : in std_logic; -- start procedure
    signal   i_stop           : in std_logic; -- stop procedure
    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath              : in string; -- input *.csv filepath
    i_csv_separator         : in character; -- *.csv file separator
    constant i_NAME0          : in string; -- csv column name to write in the file: column0
    constant i_NAME1          : in string; -- csv column name to write in the file: column1
    --  data type = "UINT" => the data to write in the file are converted: std_logic_vector -> uint
    --  data type = "INT" => the data to write in the file are converted: std_logic_vector -> int
    --  data type = "HEX" => the data to write in the file are converted: std_logic_vector -> int -> hex
    --  data type = "UHEX" => the data to write in the file are converted: std_logic_vector -> uint -> hex
    --  data type = "STD_VEC" => the data to write in the file aren't converted : std_logic_vector -> std_logic_vector
    constant i_DATA0_TYP      : in string := "INT";  -- data format of the output csv file: column0
    constant i_DATA1_TYP      : in string := "INT";  -- data format of the output csv file: column1
    ---------------------------------------------------------------------
    -- signal to log
    ---------------------------------------------------------------------
    signal   i_data_valid     : in std_logic; -- input data valid
    signal   i_data0_std_vect : in std_logic_vector; -- input data0
    signal   i_data1_std_vect : in std_logic_vector  -- input data1
  ) is

    -- csv object
    variable v_csv_file : t_csv_file_reader;

    -- fsm type declaration
    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    -- state
    variable v_fsm_state : t_state := E_RST;
    -- test condition for the infinite loop
    constant c_TEST      : boolean := true;
    -- column name: column0
    constant c_NAME0     : string  := pkg_get_column_name(i_NAME => i_NAME0, i_DATA_TYP => i_DATA0_TYP);
    -- column name: column1
    constant c_NAME1     : string  := pkg_get_column_name(i_NAME => i_NAME1, i_DATA_TYP => i_DATA1_TYP);

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

        when others =>
          v_fsm_state := E_RST;
      end case;

      pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure pkg_log_data_in_file_2;



  ---------------------------------------------------------------------
  -- pkg_log_data_in_file_7
  ---------------------------------------------------------------------
  procedure pkg_log_data_in_file_7(
    signal   i_clk            : in std_logic; -- clock
    signal   i_start          : in std_logic; -- start procedure
    signal   i_stop           : in std_logic; -- stop procedure
    ---------------------------------------------------------------------
    -- output file
    ---------------------------------------------------------------------
    i_filepath              : in string; -- input *.csv filepath
    i_csv_separator         : in character; -- *.csv file separator
    constant i_NAME0          : in string;  -- csv column name to write in the file: column0
    constant i_NAME1          : in string;  -- csv column name to write in the file: column1
    constant i_NAME2          : in string;  -- csv column name to write in the file: column2
    constant i_NAME3          : in string;  -- csv column name to write in the file: column3
    constant i_NAME4          : in string;  -- csv column name to write in the file: column4
    constant i_NAME5          : in string;  -- csv column name to write in the file: column5
    constant i_NAME6          : in string;  -- csv column name to write in the file: column6
    --  data type = "UINT" => the data to write in the file are converted: std_logic_vector -> uint
    --  data type = "INT" => the data to write in the file are converted: std_logic_vector -> int
    --  data type = "HEX" => the data to write in the file are converted: std_logic_vector -> int -> hex
    --  data type = "UHEX" => the data to write in the file are converted: std_logic_vector -> uint -> hex
    --  data type = "STD_VEC" => the data to write in the file aren't converted : std_logic_vector -> std_logic_vector
    constant i_DATA0_TYP      : in string := "INT"; -- data format of the output csv file: column0
    constant i_DATA1_TYP      : in string := "INT"; -- data format of the output csv file: column1
    constant i_DATA2_TYP      : in string := "INT"; -- data format of the output csv file: column2
    constant i_DATA3_TYP      : in string := "INT"; -- data format of the output csv file: column3
    constant i_DATA4_TYP      : in string := "INT"; -- data format of the output csv file: column4
    constant i_DATA5_TYP      : in string := "INT"; -- data format of the output csv file: column5
    constant i_DATA6_TYP      : in string := "INT"; -- data format of the output csv file: column6
    ---------------------------------------------------------------------
    -- signals to log
    ---------------------------------------------------------------------
    signal   i_data_valid     : in std_logic; -- input data valid
    signal   i_data0_std_vect : in std_logic_vector; -- input data0
    signal   i_data1_std_vect : in std_logic_vector; -- input data1
    signal   i_data2_std_vect : in std_logic_vector; -- input data2
    signal   i_data3_std_vect : in std_logic_vector; -- input data3
    signal   i_data4_std_vect : in std_logic_vector; -- input data4
    signal   i_data5_std_vect : in std_logic_vector; -- input data5
    signal   i_data6_std_vect : in std_logic_vector -- input data6
  ) is

    -- csv object
    variable v_csv_file : t_csv_file_reader;

    -- fsm type declaration
    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    -- state
    variable v_fsm_state : t_state := E_RST;
    -- test condition for the infinite loop
    constant c_TEST      : boolean := true;
    -- column name: column0
    constant c_NAME0     : string  := pkg_get_column_name(i_NAME => i_NAME0, i_DATA_TYP => i_DATA0_TYP);
    -- column name: column1
    constant c_NAME1     : string  := pkg_get_column_name(i_NAME => i_NAME1, i_DATA_TYP => i_DATA1_TYP);
    -- column name: column2
    constant c_NAME2 : string := pkg_get_column_name(i_NAME => i_NAME2, i_DATA_TYP => i_DATA2_TYP);
    -- column name: column3
    constant c_NAME3 : string := pkg_get_column_name(i_NAME => i_NAME3, i_DATA_TYP => i_DATA3_TYP);
    -- column name: column4
    constant c_NAME4 : string := pkg_get_column_name(i_NAME => i_NAME4, i_DATA_TYP => i_DATA4_TYP);
    -- column name: column5
    constant c_NAME5 : string := pkg_get_column_name(i_NAME => i_NAME5, i_DATA_TYP => i_DATA5_TYP);
    -- column name: column6
    constant c_NAME6 : string := pkg_get_column_name(i_NAME => i_NAME6, i_DATA_TYP => i_DATA6_TYP);

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

        when others =>
          v_fsm_state := E_RST;
      end case;

      pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure pkg_log_data_in_file_7;



end package body pkg_log;
