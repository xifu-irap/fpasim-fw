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
--    @file                   pkg_data_generator.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--   @details
--   This simulation VHDL package defines VHDL functions/procedures in order to
--      . generate data from an input csv file.
--
--   Note: This package should be compiled into the common_lib
--   Dependencies:
--      . csv_lib.pkg_csv_file
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library csv_lib;
use csv_lib.pkg_csv_file.all;

use work.pkg_common.all;

package pkg_data_generator is

  ---------------------------------------------------------------------
  -- pkg_data_generator_1
  ---------------------------------------------------------------------
  procedure pkg_data_generator_1(
    signal   i_clk            : in std_logic; -- clock
    signal   i_start          : in std_logic; -- start file processing
    ---------------------------------------------------------------------
    -- input file
    ---------------------------------------------------------------------
    i_filepath              : in string; -- input *.csv filepath
    i_csv_separator         : in character; -- *.csv file separator
    --  data type = "UINT" => the read data from the file are converted: uint -> std_logic_vector
    --  data type = "INT" => the read data from the file are converted: int -> std_logic_vector
    --  data type = "HEX" => the read data from the file are converted: hex-> int -> std_logic_vector
    --  data type = "UHEX" => the read data from the file are converted: hex-> uint -> std_logic_vector
    --  data type = "STD_VEC" => the read data from the file aren't converted : std_logic_vector -> std_logic_vector
    constant i_DATA0_TYP      : in string := "HEX"; -- data format of the input csv file: column0
    ---------------------------------------------------------------------
    -- command
    ---------------------------------------------------------------------
    signal   i_ready          : in std_logic; -- read a new data from file
    signal   o_data_valid     : out std_logic; -- output data valid
    signal   o_data0_std_vect : out std_logic_vector; -- output data0
    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal   o_finish         : out std_logic -- end of the file processing
  );


  ---------------------------------------------------------------------
  -- pkg_data_generator_3
  ---------------------------------------------------------------------
  procedure pkg_data_generator_3(
    signal   i_clk            : in std_logic; -- clock
    signal   i_start          : in std_logic; -- start file processing
    ---------------------------------------------------------------------
    -- input file
    ---------------------------------------------------------------------
    i_filepath              : in string; -- input *.csv filepath
    i_csv_separator         : in character; -- *.csv file separator
    --  data type = "UINT" => the read data from the file are converted: uint -> std_logic_vector
    --  data type = "INT" => the read data from the file are converted: int -> std_logic_vector
    --  data type = "HEX" => the read data from the file are converted: hex-> int -> std_logic_vector
    --  data type = "UHEX" => the read data from the file are converted: hex-> uint -> std_logic_vector
    --  data type = "STD_VEC" => the read data from the file aren't converted : std_logic_vector -> std_logic_vector
    constant i_DATA0_TYP      : in string := "HEX"; -- data format of the input csv file: column0
    constant i_DATA1_TYP      : in string := "HEX"; -- data format of the input csv file: column1
    constant i_DATA2_TYP      : in string := "HEX"; -- data format of the input csv file: column2
    ---------------------------------------------------------------------
    -- command
    ---------------------------------------------------------------------
    signal   i_ready          : in std_logic; -- read a new data from file
    signal   o_data_valid     : out std_logic; -- output data valid
    signal   o_data0_std_vect : out std_logic_vector; -- output data0
    signal   o_data1_std_vect : out std_logic_vector; -- output data1
    signal   o_data2_std_vect : out std_logic_vector; -- output data2
    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal   o_finish         : out std_logic -- end of the file processing
  );

  ---------------------------------------------------------------------
  -- pkg_data_generator_4
  ---------------------------------------------------------------------
  procedure pkg_data_generator_4(
    signal   i_clk            : in std_logic; -- clock
    signal   i_start          : in std_logic; -- start file processing
    ---------------------------------------------------------------------
    -- input file
    ---------------------------------------------------------------------
    i_filepath              : in string; -- input *.csv filepath
    i_csv_separator         : in character; -- *.csv file separator
    --  data type = "UINT" => the read data from the file are converted: uint -> std_logic_vector
    --  data type = "INT" => the read data from the file are converted: int -> std_logic_vector
    --  data type = "HEX" => the read data from the file are converted: hex-> int -> std_logic_vector
    --  data type = "UHEX" => the read data from the file are converted: hex-> uint -> std_logic_vector
    --  data type = "STD_VEC" => the read data from the file aren't converted : std_logic_vector -> std_logic_vector
    constant i_DATA0_TYP      : in string := "HEX"; -- data format of the input csv file: column0
    constant i_DATA1_TYP      : in string := "HEX"; -- data format of the input csv file: column1
    constant i_DATA2_TYP      : in string := "HEX"; -- data format of the input csv file: column2
    constant i_DATA3_TYP      : in string := "HEX"; -- data format of the input csv file: column3
    ---------------------------------------------------------------------
    -- command
    ---------------------------------------------------------------------
    signal   i_ready          : in std_logic; -- read a new data from file
    signal   o_data_valid     : out std_logic; -- output data valid
    signal   o_data0_std_vect : out std_logic_vector;  -- output data0
    signal   o_data1_std_vect : out std_logic_vector;  -- output data1
    signal   o_data2_std_vect : out std_logic_vector;  -- output data2
    signal   o_data3_std_vect : out std_logic_vector;  -- output data3
    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal   o_finish         : out std_logic  -- end of the file processing
  );


  ---------------------------------------------------------------------
  -- pkg_data_generator_8
  ---------------------------------------------------------------------

  procedure pkg_data_generator_8(
    signal   i_clk            : in std_logic; -- clock
    signal   i_start          : in std_logic; -- start file processing
    ---------------------------------------------------------------------
    -- input file
    ---------------------------------------------------------------------
    i_filepath              : in string; -- input *.csv filepath
    i_csv_separator         : in character; -- *.csv file separator
    --  data type = "UINT" => the read data from the file are converted: uint -> std_logic_vector
    --  data type = "INT" => the read data from the file are converted: int -> std_logic_vector
    --  data type = "HEX" => the read data from the file are converted: hex-> int -> std_logic_vector
    --  data type = "UHEX" => the read data from the file are converted: hex-> uint -> std_logic_vector
    --  data type = "STD_VEC" => the read data from the file aren't converted : std_logic_vector -> std_logic_vector
    constant i_DATA0_TYP      : in string := "HEX";  -- data format of the input csv file: column0
    constant i_DATA1_TYP      : in string := "HEX";  -- data format of the input csv file: column1
    constant i_DATA2_TYP      : in string := "HEX";  -- data format of the input csv file: column2
    constant i_DATA3_TYP      : in string := "HEX";  -- data format of the input csv file: column3
    constant i_DATA4_TYP      : in string := "HEX";  -- data format of the input csv file: column4
    constant i_DATA5_TYP      : in string := "HEX";  -- data format of the input csv file: column5
    constant i_DATA6_TYP      : in string := "HEX";  -- data format of the input csv file: column6
    constant i_DATA7_TYP      : in string := "HEX";  -- data format of the input csv file: column7
    ---------------------------------------------------------------------
    -- command
    ---------------------------------------------------------------------
    signal   i_ready          : in std_logic; -- read a new data from file
    signal   o_data_valid     : out std_logic; -- output data valid
    signal   o_data0_std_vect : out std_logic_vector;  -- output data0
    signal   o_data1_std_vect : out std_logic_vector;  -- output data1
    signal   o_data2_std_vect : out std_logic_vector;  -- output data2
    signal   o_data3_std_vect : out std_logic_vector;  -- output data3
    signal   o_data4_std_vect : out std_logic_vector;  -- output data4
    signal   o_data5_std_vect : out std_logic_vector;  -- output data5
    signal   o_data6_std_vect : out std_logic_vector;  -- output data6
    signal   o_data7_std_vect : out std_logic_vector;  -- output data7
    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal   o_finish         : out std_logic -- end of the file processing
  );


end package pkg_data_generator;

package body pkg_data_generator is

  ---------------------------------------------------------------------
  -- pkg_data_generator_1
  -- this function allows retrieving from file (*.csv) an input data I and Q
  ---------------------------------------------------------------------
  procedure pkg_data_generator_1(
    signal   i_clk            : in std_logic; -- clock
    signal   i_start          : in std_logic; -- start file processing
    ---------------------------------------------------------------------
    -- input file
    ---------------------------------------------------------------------
    i_filepath              : in string; -- input *.csv filepath
    i_csv_separator         : in character; -- *.csv file separator
    --  data type = "UINT" => the read data from the file are converted: uint -> std_logic_vector
    --  data type = "INT" => the read data from the file are converted: int -> std_logic_vector
    --  data type = "HEX" => the read data from the file are converted: hex-> int -> std_logic_vector
    --  data type = "UHEX" => the read data from the file are converted: hex-> uint -> std_logic_vector
    --  data type = "STD_VEC" => the read data from the file aren't converted : std_logic_vector -> std_logic_vector
    constant i_DATA0_TYP      : in string := "HEX"; -- data format of the input csv file: column0
    ---------------------------------------------------------------------
    -- command
    ---------------------------------------------------------------------
    signal   i_ready          : in std_logic; -- read a new data from file
    signal   o_data_valid     : out std_logic; -- output data valid
    signal   o_data0_std_vect : out std_logic_vector; -- output data0
    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal   o_finish         : out std_logic -- end of the file processing
  ) is
    -- csv object
    variable v_csv_file : t_csv_file_reader;

    -- fsm type declaration
    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    -- state
    variable v_fsm_state : t_state := E_RST;
    -- test condition for the infinite loop
    constant c_TEST      : boolean := true;

    -- output data valid
    variable v_data_valid : std_logic                                := '0';
    -- output data: read data from the input file
    variable v_data0      : std_logic_vector(o_data0_std_vect'range) := (others => '0');
    -- end of the processing: end of the file reading
    variable v_finish     : std_logic                                := '0';

  begin

    while c_TEST loop

      case v_fsm_state is

        when E_RST =>

          v_data_valid := '0';

          v_fsm_state := E_WAIT;

        when E_WAIT =>

          if i_start = '1' then

            v_csv_file.initialize(i_filepath, i_csv_separator => i_csv_separator);
            -- skip the header
            v_csv_file.readline(void);
            v_data_valid := '0';
            v_finish     := '0';
            if v_csv_file.end_of_file(void) = true then
              v_csv_file.dispose(void);
              v_fsm_state := E_END;
            else
              v_fsm_state := E_RUN;
            end if;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>

          if i_ready = '1' then
            v_csv_file.readline(void);
            v_data_valid := '1';
            v_data0      := v_csv_file.read_data_typ_as_std_vec(i_length => v_data0'length, i_data_typ => i_DATA0_TYP);
            if v_csv_file.end_of_file(void) = true then
              v_csv_file.dispose(void);
              v_fsm_state := E_END;
            else
              v_fsm_state := E_RUN;
            end if;
          else

            v_data_valid := '0';
            v_fsm_state  := E_RUN;
          end if;

        when E_END =>

          v_data_valid := '0';
          v_finish     := '1';
          v_fsm_state  := E_END;

        when others =>
          v_fsm_state := E_RST;
      end case;

      o_data_valid     <= v_data_valid;
      o_data0_std_vect <= v_data0;
      o_finish         <= v_finish;

      pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure pkg_data_generator_1;



  ---------------------------------------------------------------------
  -- pkg_data_generator_3
  ---------------------------------------------------------------------
  procedure pkg_data_generator_3(
    signal   i_clk            : in std_logic; -- clock
    signal   i_start          : in std_logic; -- start file processing
    ---------------------------------------------------------------------
    -- input file
    ---------------------------------------------------------------------
    i_filepath              : in string; -- input *.csv filepath
    i_csv_separator         : in character; -- *.csv file separator
    --  data type = "UINT" => the read data from the file are converted: uint -> std_logic_vector
    --  data type = "INT" => the read data from the file are converted: int -> std_logic_vector
    --  data type = "HEX" => the read data from the file are converted: hex-> int -> std_logic_vector
    --  data type = "UHEX" => the read data from the file are converted: hex-> uint -> std_logic_vector
    --  data type = "STD_VEC" => the read data from the file aren't converted : std_logic_vector -> std_logic_vector
    constant i_DATA0_TYP      : in string := "HEX"; -- data format of the input csv file: column0
    constant i_DATA1_TYP      : in string := "HEX"; -- data format of the input csv file: column1
    constant i_DATA2_TYP      : in string := "HEX"; -- data format of the input csv file: column2
    ---------------------------------------------------------------------
    -- command
    ---------------------------------------------------------------------
    signal   i_ready          : in std_logic; -- read a new data from file
    signal   o_data_valid     : out std_logic; -- output data valid
    signal   o_data0_std_vect : out std_logic_vector; -- output data0
    signal   o_data1_std_vect : out std_logic_vector; -- output data1
    signal   o_data2_std_vect : out std_logic_vector; -- output data2
    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal   o_finish         : out std_logic -- end of the file processing
  ) is

    -- csv object
    variable v_csv_file : t_csv_file_reader;

    -- fsm type declaration
    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    -- state
    variable v_fsm_state : t_state := E_RST;
    -- test condition for the infinite loop
    constant c_TEST      : boolean := true;

    -- output data valid
    variable v_data_valid : std_logic                                := '0';
    -- output data0: read data from the input file
    variable v_data0      : std_logic_vector(o_data0_std_vect'range) := (others => '0');
    -- output data1: read data from the input file
    variable v_data1      : std_logic_vector(o_data1_std_vect'range) := (others => '0');
    -- output data2: read data from the input file
    variable v_data2      : std_logic_vector(o_data2_std_vect'range) := (others => '0');
    -- end of the processing: end of the file reading
    variable v_finish     : std_logic                                := '0';


  begin

    while c_TEST loop

      case v_fsm_state is

        when E_RST =>
          v_data_valid := '0';
          v_fsm_state  := E_WAIT;

        when E_WAIT =>

          if i_start = '1' then

            v_csv_file.initialize(i_filepath, i_csv_separator => i_csv_separator);
            -- skip the header
            v_csv_file.readline(void);
            v_data_valid := '0';
            v_finish     := '0';
            if v_csv_file.end_of_file(void) = true then
              v_csv_file.dispose(void);
              v_fsm_state := E_END;
            else
              v_fsm_state := E_RUN;
            end if;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>

          if i_ready = '1' then
            v_csv_file.readline(void);
            v_data_valid := '1';

            v_data0 := v_csv_file.read_data_typ_as_std_vec(i_length => v_data0'length, i_data_typ => i_DATA0_TYP);
            v_data1 := v_csv_file.read_data_typ_as_std_vec(i_length => v_data1'length, i_data_typ => i_DATA1_TYP);
            v_data2 := v_csv_file.read_data_typ_as_std_vec(i_length => v_data2'length, i_data_typ => i_DATA2_TYP);

            if v_csv_file.end_of_file(void) = true then
              v_csv_file.dispose(void);
              v_fsm_state := E_END;
            else
              v_fsm_state := E_RUN;
            end if;
          else

            v_data_valid := '0';
            v_fsm_state  := E_RUN;
          end if;

        when E_END =>
          v_data_valid := '0';
          v_finish     := '1';
          v_fsm_state  := E_END;

        when others =>
          v_fsm_state := E_RST;
      end case;

      o_data_valid     <= v_data_valid;
      o_data0_std_vect <= v_data0;
      o_data1_std_vect <= v_data1;
      o_data2_std_vect <= v_data2;
      o_finish         <= v_finish;

      pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure pkg_data_generator_3;

  ---------------------------------------------------------------------
  -- pkg_data_generator_4
  ---------------------------------------------------------------------
  procedure pkg_data_generator_4(
    signal   i_clk            : in std_logic; -- clock
    signal   i_start          : in std_logic; -- start file processing
    ---------------------------------------------------------------------
    -- input file
    ---------------------------------------------------------------------
    i_filepath              : in string; -- input *.csv filepath
    i_csv_separator         : in character; -- *.csv file separator
    --  data type = "UINT" => the read data from the file are converted: uint -> std_logic_vector
    --  data type = "INT" => the read data from the file are converted: int -> std_logic_vector
    --  data type = "HEX" => the read data from the file are converted: hex-> int -> std_logic_vector
    --  data type = "UHEX" => the read data from the file are converted: hex-> uint -> std_logic_vector
    --  data type = "STD_VEC" => the read data from the file aren't converted : std_logic_vector -> std_logic_vector
    constant i_DATA0_TYP      : in string := "HEX"; -- data format of the input csv file: column0
    constant i_DATA1_TYP      : in string := "HEX"; -- data format of the input csv file: column1
    constant i_DATA2_TYP      : in string := "HEX"; -- data format of the input csv file: column2
    constant i_DATA3_TYP      : in string := "HEX"; -- data format of the input csv file: column3
    ---------------------------------------------------------------------
    -- command
    ---------------------------------------------------------------------
    signal   i_ready          : in std_logic; -- read a new data from file
    signal   o_data_valid     : out std_logic; -- output data valid
    signal   o_data0_std_vect : out std_logic_vector;  -- output data0
    signal   o_data1_std_vect : out std_logic_vector;  -- output data1
    signal   o_data2_std_vect : out std_logic_vector;  -- output data2
    signal   o_data3_std_vect : out std_logic_vector;  -- output data3
    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal   o_finish         : out std_logic  -- end of the file processing
  ) is

    -- csv object
    variable v_csv_file : t_csv_file_reader;

    -- fsm type declaration
    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    -- state
    variable v_fsm_state : t_state := E_RST;
    -- test condition for the infinite loop
    constant c_TEST      : boolean := true;

    -- output data valid
    variable v_data_valid : std_logic                                := '0';
    -- output data0: read data from the input file
    variable v_data0      : std_logic_vector(o_data0_std_vect'range) := (others => '0');
    -- output data1: read data from the input file
    variable v_data1      : std_logic_vector(o_data1_std_vect'range) := (others => '0');
    -- output data2: read data from the input file
    variable v_data2      : std_logic_vector(o_data2_std_vect'range) := (others => '0');
    -- output data3: read data from the input file
    variable v_data3      : std_logic_vector(o_data3_std_vect'range) := (others => '0');
    -- end of the processing: end of the file reading
    variable v_finish     : std_logic                                := '0';


  begin

    while c_TEST loop

      case v_fsm_state is

        when E_RST =>
          v_data_valid := '0';
          v_fsm_state  := E_WAIT;

        when E_WAIT =>

          if i_start = '1' then

            v_csv_file.initialize(i_filepath, i_csv_separator => i_csv_separator);
            -- skip the header
            v_csv_file.readline(void);
            v_data_valid := '0';
            v_finish     := '0';
            if v_csv_file.end_of_file(void) = true then
              v_csv_file.dispose(void);
              v_fsm_state := E_END;
            else
              v_fsm_state := E_RUN;
            end if;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>

          if i_ready = '1' then
            v_csv_file.readline(void);
            v_data_valid := '1';

            v_data0 := v_csv_file.read_data_typ_as_std_vec(i_length => v_data0'length, i_data_typ => i_DATA0_TYP);
            v_data1 := v_csv_file.read_data_typ_as_std_vec(i_length => v_data1'length, i_data_typ => i_DATA1_TYP);
            v_data2 := v_csv_file.read_data_typ_as_std_vec(i_length => v_data2'length, i_data_typ => i_DATA2_TYP);
            v_data3 := v_csv_file.read_data_typ_as_std_vec(i_length => v_data3'length, i_data_typ => i_DATA3_TYP);

            if v_csv_file.end_of_file(void) = true then
              v_csv_file.dispose(void);
              v_fsm_state := E_END;
            else
              v_fsm_state := E_RUN;
            end if;
          else

            v_data_valid := '0';
            v_fsm_state  := E_RUN;
          end if;

        when E_END =>
          v_data_valid := '0';
          v_finish     := '1';
          v_fsm_state  := E_END;

        when others =>
          v_fsm_state := E_RST;
      end case;

      o_data_valid     <= v_data_valid;
      o_data0_std_vect <= v_data0;
      o_data1_std_vect <= v_data1;
      o_data2_std_vect <= v_data2;
      o_data3_std_vect <= v_data3;
      o_finish         <= v_finish;

      pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure pkg_data_generator_4;



  ---------------------------------------------------------------------
  -- pkg_data_generator_8
  ---------------------------------------------------------------------
  procedure pkg_data_generator_8(
    signal   i_clk            : in std_logic; -- clock
    signal   i_start          : in std_logic; -- start file processing
    ---------------------------------------------------------------------
    -- input file
    ---------------------------------------------------------------------
    i_filepath              : in string; -- input *.csv filepath
    i_csv_separator         : in character; -- *.csv file separator
    --  data type = "UINT" => the read data from the file are converted: uint -> std_logic_vector
    --  data type = "INT" => the read data from the file are converted: int -> std_logic_vector
    --  data type = "HEX" => the read data from the file are converted: hex-> int -> std_logic_vector
    --  data type = "UHEX" => the read data from the file are converted: hex-> uint -> std_logic_vector
    --  data type = "STD_VEC" => the read data from the file aren't converted : std_logic_vector -> std_logic_vector
    constant i_DATA0_TYP      : in string := "HEX";  -- data format of the input csv file: column0
    constant i_DATA1_TYP      : in string := "HEX";  -- data format of the input csv file: column1
    constant i_DATA2_TYP      : in string := "HEX";  -- data format of the input csv file: column2
    constant i_DATA3_TYP      : in string := "HEX";  -- data format of the input csv file: column3
    constant i_DATA4_TYP      : in string := "HEX";  -- data format of the input csv file: column4
    constant i_DATA5_TYP      : in string := "HEX";  -- data format of the input csv file: column5
    constant i_DATA6_TYP      : in string := "HEX";  -- data format of the input csv file: column6
    constant i_DATA7_TYP      : in string := "HEX";  -- data format of the input csv file: column7
    ---------------------------------------------------------------------
    -- command
    ---------------------------------------------------------------------
    signal   i_ready          : in std_logic; -- read a new data from file
    signal   o_data_valid     : out std_logic; -- output data valid
    signal   o_data0_std_vect : out std_logic_vector;  -- output data0
    signal   o_data1_std_vect : out std_logic_vector;  -- output data1
    signal   o_data2_std_vect : out std_logic_vector;  -- output data2
    signal   o_data3_std_vect : out std_logic_vector;  -- output data3
    signal   o_data4_std_vect : out std_logic_vector;  -- output data4
    signal   o_data5_std_vect : out std_logic_vector;  -- output data5
    signal   o_data6_std_vect : out std_logic_vector;  -- output data6
    signal   o_data7_std_vect : out std_logic_vector;  -- output data7
    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal   o_finish         : out std_logic -- end of the file processing
  ) is

    -- csv object
    variable v_csv_file : t_csv_file_reader;

    -- fsm type declaration
    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    -- state
    variable v_fsm_state : t_state := E_RST;
    -- test condition for the infinite loop
    constant c_TEST      : boolean := true;

    -- output data valid
    variable v_data_valid : std_logic                                := '0';
    -- output data0: read data from the input file
    variable v_data0      : std_logic_vector(o_data0_std_vect'range) := (others => '0');
    -- output data1: read data from the input file
    variable v_data1      : std_logic_vector(o_data1_std_vect'range) := (others => '0');
    -- output data2: read data from the input file
    variable v_data2      : std_logic_vector(o_data2_std_vect'range) := (others => '0');
    -- output data3: read data from the input file
    variable v_data3      : std_logic_vector(o_data3_std_vect'range) := (others => '0');
    -- output data4: read data from the input file
    variable v_data4      : std_logic_vector(o_data4_std_vect'range) := (others => '0');
    -- output data5: read data from the input file
    variable v_data5      : std_logic_vector(o_data5_std_vect'range) := (others => '0');
    -- output data6: read data from the input file
    variable v_data6      : std_logic_vector(o_data6_std_vect'range) := (others => '0');
    -- output data7: read data from the input file
    variable v_data7      : std_logic_vector(o_data7_std_vect'range) := (others => '0');
    -- end of the processing: end of the file reading
    variable v_finish     : std_logic                                := '0';

  begin

    while c_TEST loop

      case v_fsm_state is

        when E_RST =>
          v_data_valid := '0';
          v_fsm_state  := E_WAIT;

        when E_WAIT =>

          if i_start = '1' then

            v_csv_file.initialize(i_filepath, i_csv_separator => i_csv_separator);
            -- skip the header
            v_csv_file.readline(void);
            v_data_valid := '0';
            v_finish     := '0';
            if v_csv_file.end_of_file(void) = true then
              v_csv_file.dispose(void);
              v_fsm_state := E_END;
            else
              v_fsm_state := E_RUN;
            end if;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>

          if i_ready = '1' then
            v_csv_file.readline(void);
            v_data_valid := '1';

            v_data0 := v_csv_file.read_data_typ_as_std_vec(i_length => v_data0'length, i_data_typ => i_DATA0_TYP);
            v_data1 := v_csv_file.read_data_typ_as_std_vec(i_length => v_data1'length, i_data_typ => i_DATA1_TYP);
            v_data2 := v_csv_file.read_data_typ_as_std_vec(i_length => v_data2'length, i_data_typ => i_DATA2_TYP);
            v_data3 := v_csv_file.read_data_typ_as_std_vec(i_length => v_data3'length, i_data_typ => i_DATA3_TYP);
            v_data4 := v_csv_file.read_data_typ_as_std_vec(i_length => v_data4'length, i_data_typ => i_DATA4_TYP);
            v_data5 := v_csv_file.read_data_typ_as_std_vec(i_length => v_data5'length, i_data_typ => i_DATA5_TYP);
            v_data6 := v_csv_file.read_data_typ_as_std_vec(i_length => v_data6'length, i_data_typ => i_DATA6_TYP);
            v_data7 := v_csv_file.read_data_typ_as_std_vec(i_length => v_data7'length, i_data_typ => i_DATA7_TYP);
            if v_csv_file.end_of_file(void) = true then
              v_csv_file.dispose(void);
              v_fsm_state := E_END;
            else
              v_fsm_state := E_RUN;
            end if;
          else

            v_data_valid := '0';
            v_fsm_state  := E_RUN;
          end if;

        when E_END =>

          v_data_valid := '0';
          v_finish     := '1';
          v_fsm_state  := E_END;

        when others =>
          v_fsm_state := E_RST;
      end case;

      o_data_valid     <= v_data_valid;
      o_data0_std_vect <= v_data0;
      o_data1_std_vect <= v_data1;
      o_data2_std_vect <= v_data2;
      o_data3_std_vect <= v_data3;
      o_data4_std_vect <= v_data4;
      o_data5_std_vect <= v_data5;
      o_data6_std_vect <= v_data6;
      o_data7_std_vect <= v_data7;
      o_finish         <= v_finish;

      pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure pkg_data_generator_8;



end package body pkg_data_generator;
