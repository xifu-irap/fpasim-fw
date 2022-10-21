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
--    @file                   pkg_data_checker.vhd 
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

library vunit_lib;
context vunit_lib.vunit_context;

library utility_lib;
use utility_lib.pkg_common.all;


package pkg_data_checker is



  --------------------------------------------------------------------
-- vunit_data_checker_1
---------------------------------------------------------------------
  procedure vunit_data_checker_1(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- reference file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0 : in string;

    --  common typ = "UINT" => the file integer value is converted into an unsigned vector -> std_logic_vector
    --  common typ = "INT" => the file integer value  is converted into a signed vector -> std_logic_vector
    --  common typ = "HEX" => the hexadecimal value is converted into a std_logic_vector
    --  common typ = "STD_VEC" (binary value) => the std_logic_vector is not converted
    constant i_DATA0_COMMON_TYP : in string := "UINT";

    ---------------------------------------------------------------------
    -- Vunit Scoreboard objects
    ---------------------------------------------------------------------
    constant i_data0_sb : in checker_t;

    ---------------------------------------------------------------------
    -- experimental signals
    ---------------------------------------------------------------------
    signal i_data_valid     : in std_logic;
    signal i_data0_std_vect : in std_logic_vector;

    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal o_error_std_vect : out std_logic_vector(0 downto 0)
    );

  --------------------------------------------------------------------
-- vunit_data_checker_2
---------------------------------------------------------------------
  procedure vunit_data_checker_2(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- reference file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0 : in string;
    constant i_NAME1 : in string;

    --  common typ = "UINT" => the file integer value is converted into an unsigned vector -> std_logic_vector
    --  common typ = "INT" => the file integer value  is converted into a signed vector -> std_logic_vector
    --  common typ = "HEX" => the hexadecimal value is converted into a std_logic_vector
    --  common typ = "STD_VEC" (binary value) => the std_logic_vector is not converted
    constant i_DATA0_COMMON_TYP : in string := "UINT";
    constant i_DATA1_COMMON_TYP : in string := "UINT";

    ---------------------------------------------------------------------
    -- Vunit Scoreboard objects
    ---------------------------------------------------------------------
    constant i_data0_sb : in checker_t;
    constant i_data1_sb : in checker_t;

    ---------------------------------------------------------------------
    -- experimental signals
    ---------------------------------------------------------------------
    signal i_data_valid : in std_logic;

    signal i_data0_std_vect : in std_logic_vector;
    signal i_data1_std_vect : in std_logic_vector;

    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal o_error_std_vect : out std_logic_vector(1 downto 0)
    );

  --------------------------------------------------------------------
-- vunit_data_checker_3
---------------------------------------------------------------------
  procedure vunit_data_checker_3(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- reference file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0 : in string;
    constant i_NAME1 : in string;
    constant i_NAME2 : in string;

    --  common typ = "UINT" => the file integer value is converted into an unsigned vector -> std_logic_vector
    --  common typ = "INT" => the file integer value  is converted into a signed vector -> std_logic_vector
    --  common typ = "HEX" => the hexadecimal value is converted into a std_logic_vector
    --  common typ = "STD_VEC" (binary value) => the std_logic_vector is not converted
    constant i_DATA0_COMMON_TYP : in string := "UINT";
    constant i_DATA1_COMMON_TYP : in string := "UINT";
    constant i_DATA2_COMMON_TYP : in string := "UINT";

    ---------------------------------------------------------------------
    -- Vunit Scoreboard objects
    ---------------------------------------------------------------------
    constant i_data0_sb : in checker_t;
    constant i_data1_sb : in checker_t;
    constant i_data2_sb : in checker_t;

    ---------------------------------------------------------------------
    -- experimental signals
    ---------------------------------------------------------------------
    signal i_data_valid : in std_logic;

    signal i_data0_std_vect : in std_logic_vector;
    signal i_data1_std_vect : in std_logic_vector;
    signal i_data2_std_vect : in std_logic_vector;

    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal o_error_std_vect : out std_logic_vector(2 downto 0)
    );

--------------------------------------------------------------------
-- vunit_data_checker_4
---------------------------------------------------------------------
  procedure vunit_data_checker_4(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- reference file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0 : in string;
    constant i_NAME1 : in string;
    constant i_NAME2 : in string;
    constant i_NAME3 : in string;

    --  common typ = "UINT" => the file integer value is converted into an unsigned vector -> std_logic_vector
    --  common typ = "INT" => the file integer value  is converted into a signed vector -> std_logic_vector
    --  common typ = "HEX" => the hexadecimal value is converted into a std_logic_vector
    --  common typ = "STD_VEC" (binary value) => the std_logic_vector is not converted
    constant i_DATA0_COMMON_TYP : in string := "UINT";
    constant i_DATA1_COMMON_TYP : in string := "UINT";
    constant i_DATA2_COMMON_TYP : in string := "UINT";
    constant i_DATA3_COMMON_TYP : in string := "UINT";

    ---------------------------------------------------------------------
    -- Vunit Scoreboard objects
    ---------------------------------------------------------------------
    constant i_data0_sb : in checker_t;
    constant i_data1_sb : in checker_t;
    constant i_data2_sb : in checker_t;
    constant i_data3_sb : in checker_t;

    ---------------------------------------------------------------------
    -- experimental signals
    ---------------------------------------------------------------------
    signal i_data_valid : in std_logic;

    signal i_data0_std_vect : in std_logic_vector;
    signal i_data1_std_vect : in std_logic_vector;
    signal i_data2_std_vect : in std_logic_vector;
    signal i_data3_std_vect : in std_logic_vector;

    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal o_error_std_vect : out std_logic_vector(3 downto 0)
    );

--------------------------------------------------------------------
-- vunit_data_checker_5
---------------------------------------------------------------------
  procedure vunit_data_checker_5(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- reference file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0 : in string;
    constant i_NAME1 : in string;
    constant i_NAME2 : in string;
    constant i_NAME3 : in string;
    constant i_NAME4 : in string;

    --  common typ = "UINT" => the file integer value is converted into an unsigned vector -> std_logic_vector
    --  common typ = "INT" => the file integer value  is converted into a signed vector -> std_logic_vector
    --  common typ = "HEX" => the hexadecimal value is converted into a std_logic_vector
    --  common typ = "STD_VEC" (binary value) => the std_logic_vector is not converted
    constant i_DATA0_COMMON_TYP : in string := "UINT";
    constant i_DATA1_COMMON_TYP : in string := "UINT";
    constant i_DATA2_COMMON_TYP : in string := "UINT";
    constant i_DATA3_COMMON_TYP : in string := "UINT";
    constant i_DATA4_COMMON_TYP : in string := "UINT";

    ---------------------------------------------------------------------
    -- Vunit Scoreboard objects
    ---------------------------------------------------------------------
    constant i_data0_sb : in checker_t;
    constant i_data1_sb : in checker_t;
    constant i_data2_sb : in checker_t;
    constant i_data3_sb : in checker_t;
    constant i_data4_sb : in checker_t;

    ---------------------------------------------------------------------
    -- experimental signals
    ---------------------------------------------------------------------
    signal i_data_valid : in std_logic;

    signal i_data0_std_vect : in std_logic_vector;
    signal i_data1_std_vect : in std_logic_vector;
    signal i_data2_std_vect : in std_logic_vector;
    signal i_data3_std_vect : in std_logic_vector;
    signal i_data4_std_vect : in std_logic_vector;

    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal o_error_std_vect : out std_logic_vector(4 downto 0)
    );

  --------------------------------------------------------------------
-- vunit_data_checker_10
---------------------------------------------------------------------
  procedure vunit_data_checker_10(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- reference file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0 : in string;
    constant i_NAME1 : in string;
    constant i_NAME2 : in string;
    constant i_NAME3 : in string;
    constant i_NAME4 : in string;
    constant i_NAME5 : in string;
    constant i_NAME6 : in string;
    constant i_NAME7 : in string;
    constant i_NAME8 : in string;
    constant i_NAME9 : in string;

    --  common typ = "UINT" => the file integer value is converted into an unsigned vector -> std_logic_vector
    --  common typ = "INT" => the file integer value  is converted into a signed vector -> std_logic_vector
    --  common typ = "HEX" => the hexadecimal value is converted into a std_logic_vector
    --  common typ = "STD_VEC" (binary value) => the std_logic_vector is not converted
    constant i_DATA0_COMMON_TYP : in string := "UINT";
    constant i_DATA1_COMMON_TYP : in string := "UINT";
    constant i_DATA2_COMMON_TYP : in string := "UINT";
    constant i_DATA3_COMMON_TYP : in string := "UINT";
    constant i_DATA4_COMMON_TYP : in string := "UINT";
    constant i_DATA5_COMMON_TYP : in string := "UINT";
    constant i_DATA6_COMMON_TYP : in string := "UINT";
    constant i_DATA7_COMMON_TYP : in string := "UINT";
    constant i_DATA8_COMMON_TYP : in string := "UINT";
    constant i_DATA9_COMMON_TYP : in string := "UINT";

    ---------------------------------------------------------------------
    -- Vunit Scoreboard objects
    ---------------------------------------------------------------------
    constant i_data0_sb : in checker_t;
    constant i_data1_sb : in checker_t;
    constant i_data2_sb : in checker_t;
    constant i_data3_sb : in checker_t;
    constant i_data4_sb : in checker_t;
    constant i_data5_sb : in checker_t;
    constant i_data6_sb : in checker_t;
    constant i_data7_sb : in checker_t;
    constant i_data8_sb : in checker_t;
    constant i_data9_sb : in checker_t;

    ---------------------------------------------------------------------
    -- experimental signals
    ---------------------------------------------------------------------
    signal i_data_valid : in std_logic;

    signal i_data0_std_vect : in std_logic_vector;
    signal i_data1_std_vect : in std_logic_vector;
    signal i_data2_std_vect : in std_logic_vector;
    signal i_data3_std_vect : in std_logic_vector;
    signal i_data4_std_vect : in std_logic_vector;
    signal i_data5_std_vect : in std_logic_vector;
    signal i_data6_std_vect : in std_logic_vector;
    signal i_data7_std_vect : in std_logic_vector;
    signal i_data8_std_vect : in std_logic_vector;
    signal i_data9_std_vect : in std_logic_vector;

    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal o_error_std_vect : out std_logic_vector(9 downto 0)
    );
--------------------------------------------------------------------
-- vunit_data_checker_13
---------------------------------------------------------------------
  procedure vunit_data_checker_13(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- reference file
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
    constant i_NAME11 : in string;
    constant i_NAME12 : in string;

    --  common typ = "UINT" => the file integer value is converted into an unsigned vector -> std_logic_vector
    --  common typ = "INT" => the file integer value  is converted into a signed vector -> std_logic_vector
    --  common typ = "HEX" => the hexadecimal value is converted into a std_logic_vector
    --  common typ = "STD_VEC" (binary value) => the std_logic_vector is not converted
    constant i_DATA0_COMMON_TYP  : in string := "UINT";
    constant i_DATA1_COMMON_TYP  : in string := "UINT";
    constant i_DATA2_COMMON_TYP  : in string := "UINT";
    constant i_DATA3_COMMON_TYP  : in string := "UINT";
    constant i_DATA4_COMMON_TYP  : in string := "UINT";
    constant i_DATA5_COMMON_TYP  : in string := "UINT";
    constant i_DATA6_COMMON_TYP  : in string := "UINT";
    constant i_DATA7_COMMON_TYP  : in string := "UINT";
    constant i_DATA8_COMMON_TYP  : in string := "UINT";
    constant i_DATA9_COMMON_TYP  : in string := "UINT";
    constant i_DATA10_COMMON_TYP : in string := "UINT";
    constant i_DATA11_COMMON_TYP : in string := "UINT";
    constant i_DATA12_COMMON_TYP : in string := "UINT";

    ---------------------------------------------------------------------
    -- Vunit Scoreboard objects
    ---------------------------------------------------------------------

    constant i_data0_sb  : in checker_t;
    constant i_data1_sb  : in checker_t;
    constant i_data2_sb  : in checker_t;
    constant i_data3_sb  : in checker_t;
    constant i_data4_sb  : in checker_t;
    constant i_data5_sb  : in checker_t;
    constant i_data6_sb  : in checker_t;
    constant i_data7_sb  : in checker_t;
    constant i_data8_sb  : in checker_t;
    constant i_data9_sb  : in checker_t;
    constant i_data10_sb : in checker_t;
    constant i_data11_sb : in checker_t;
    constant i_data12_sb : in checker_t;

    ---------------------------------------------------------------------
    -- experimental signals
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
    signal i_data10_std_vect : in std_logic_vector;
    signal i_data11_std_vect : in std_logic_vector;
    signal i_data12_std_vect : in std_logic_vector;

    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal o_error_std_vect : out std_logic_vector(12 downto 0)
    );


end package pkg_data_checker;

package body pkg_data_checker is


--------------------------------------------------------------------
-- vunit_data_checker_1
---------------------------------------------------------------------
  procedure vunit_data_checker_1(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- reference file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0 : in string;

    --  common typ = "UINT" => the file integer value is converted into an unsigned vector -> std_logic_vector
    --  common typ = "INT" => the file integer value  is converted into a signed vector -> std_logic_vector
    --  common typ = "HEX" => the hexadecimal value is converted into a std_logic_vector
    --  common typ = "STD_VEC" (binary value) => the std_logic_vector is not converted
    constant i_DATA0_COMMON_TYP : in string := "UINT";

    ---------------------------------------------------------------------
    -- Vunit Scoreboard objects
    ---------------------------------------------------------------------
    constant i_data0_sb : in checker_t;

    ---------------------------------------------------------------------
    -- experimental signals
    ---------------------------------------------------------------------
    signal i_data_valid     : in std_logic;
    signal i_data0_std_vect : in std_logic_vector;

    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal o_error_std_vect : out std_logic_vector(0 downto 0)
    ) is

    variable v_csv_file : t_csv_file_reader;

    type t_state is (E_RST, E_WAIT, E_RUN);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST  : boolean   := true;

    variable v_data0 : std_logic_vector(i_data0_std_vect'range) := (others => '0');

    variable v_error : std_logic_vector(o_error_std_vect'range) := (others => '0');
    variable v_cnt   : integer                                     := 0;

  begin

    while c_TEST loop
      -- default value
      v_error := (others => '0');

      case v_fsm_state is

        when E_RST =>
          v_fsm_state := E_WAIT;
        when E_WAIT =>
          v_cnt := 0;

          if i_start = '1' then
            info("reference filepath : "&i_filepath);
            v_csv_file.initialize(i_filepath, csv_separator => i_csv_separator);
            -- skip the header
            v_csv_file.readline(void);
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>
          if i_data_valid = '1' then
            -- read data in file
            v_csv_file.readline(void);

            v_data0 := v_csv_file.read_common_typ_as_std_vec(length => v_data0'length, common_typ => i_DATA0_COMMON_TYP);


            ---------------------------------------------------------------------
            -- check values
            ---------------------------------------------------------------------
            if v_data0 /= i_data0_std_vect then
              v_error(0) := '1';
            else
              v_error(0) := '0';
            end if;
            check_equal(i_data0_sb, v_data0, i_data0_std_vect, result(i_NAME0 &" (Matlab) : " & to_string(v_data0) & ", " & i_NAME0 & " (VHDL) : "& to_string(i_data0_std_vect) & " , IDX: " & to_string(v_cnt)));
            v_cnt := v_cnt + 1;
          end if;

          v_fsm_state := E_RUN;


        when others => -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;

      o_error_std_vect <= v_error;

      wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure vunit_data_checker_1;

  --------------------------------------------------------------------
-- vunit_data_checker_2
---------------------------------------------------------------------
  procedure vunit_data_checker_2(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- reference file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0 : in string;
    constant i_NAME1 : in string;

    --  common typ = "UINT" => the file integer value is converted into an unsigned vector -> std_logic_vector
    --  common typ = "INT" => the file integer value  is converted into a signed vector -> std_logic_vector
    --  common typ = "HEX" => the hexadecimal value is converted into a std_logic_vector
    --  common typ = "STD_VEC" (binary value) => the std_logic_vector is not converted
    constant i_DATA0_COMMON_TYP : in string := "UINT";
    constant i_DATA1_COMMON_TYP : in string := "UINT";

    ---------------------------------------------------------------------
    -- Vunit Scoreboard objects
    ---------------------------------------------------------------------
    constant i_data0_sb : in checker_t;
    constant i_data1_sb : in checker_t;

    ---------------------------------------------------------------------
    -- experimental signals
    ---------------------------------------------------------------------
    signal i_data_valid : in std_logic;

    signal i_data0_std_vect : in std_logic_vector;
    signal i_data1_std_vect : in std_logic_vector;

    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal o_error_std_vect : out std_logic_vector(1 downto 0)
    ) is

    variable v_csv_file : t_csv_file_reader;

    type t_state is (E_RST, E_WAIT, E_RUN);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST  : boolean   := true;

    variable v_data0 : std_logic_vector(i_data0_std_vect'range) := (others => '0');
    variable v_data1 : std_logic_vector(i_data1_std_vect'range) := (others => '0');

    variable v_error : std_logic_vector(o_error_std_vect'range) := (others => '0');
    variable v_cnt   : integer                                     := 0;


  begin

    while c_TEST loop
      -- default value
      v_error := (others => '0');

      case v_fsm_state is

        when E_RST =>

          v_fsm_state := E_WAIT;
        when E_WAIT =>
          v_cnt := 0;

          if i_start = '1' then
            info("reference filepath : "&i_filepath);
            v_csv_file.initialize(i_filepath, csv_separator => i_csv_separator);
            -- skip the header
            v_csv_file.readline(void);
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>
          if i_data_valid = '1' then
            -- read data in file
            v_csv_file.readline(void);

            v_data0 := v_csv_file.read_common_typ_as_std_vec(length => v_data0'length, common_typ => i_DATA0_COMMON_TYP);
            v_data1 := v_csv_file.read_common_typ_as_std_vec(length => v_data1'length, common_typ => i_DATA1_COMMON_TYP);

            ---------------------------------------------------------------------
            -- check values
            ---------------------------------------------------------------------
            if v_data0 /= i_data0_std_vect then
              v_error(0) := '1';
            else
              v_error(0) := '0';
            end if;
            if v_data1 /= i_data1_std_vect then
              v_error(1) := '1';
            else
              v_error(1) := '0';
            end if;
            check_equal(i_data0_sb, v_data0, i_data0_std_vect, result(i_NAME0 &" (Matlab) : " & to_string(v_data0) & ", " & i_NAME0 & " (VHDL) : "& to_string(i_data0_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data1_sb, v_data1, i_data1_std_vect, result(i_NAME1 &" (Matlab) : " & to_string(v_data1) & ", " & i_NAME1 & " (VHDL) : "& to_string(i_data1_std_vect) & " , IDX: " & to_string(v_cnt)));
            v_cnt := v_cnt + 1;
          end if;

          v_fsm_state := E_RUN;


        when others => -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;

      o_error_std_vect <= v_error;

      wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure vunit_data_checker_2;


  --------------------------------------------------------------------
-- vunit_data_checker_3
---------------------------------------------------------------------
  procedure vunit_data_checker_3(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- reference file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0 : in string;
    constant i_NAME1 : in string;
    constant i_NAME2 : in string;

    --  common typ = "UINT" => the file integer value is converted into an unsigned vector -> std_logic_vector
    --  common typ = "INT" => the file integer value  is converted into a signed vector -> std_logic_vector
    --  common typ = "HEX" => the hexadecimal value is converted into a std_logic_vector
    --  common typ = "STD_VEC" (binary value) => the std_logic_vector is not converted
    constant i_DATA0_COMMON_TYP : in string := "UINT";
    constant i_DATA1_COMMON_TYP : in string := "UINT";
    constant i_DATA2_COMMON_TYP : in string := "UINT";

    ---------------------------------------------------------------------
    -- Vunit Scoreboard objects
    ---------------------------------------------------------------------
    constant i_data0_sb : in checker_t;
    constant i_data1_sb : in checker_t;
    constant i_data2_sb : in checker_t;

    ---------------------------------------------------------------------
    -- experimental signals
    ---------------------------------------------------------------------
    signal i_data_valid : in std_logic;

    signal i_data0_std_vect : in std_logic_vector;
    signal i_data1_std_vect : in std_logic_vector;
    signal i_data2_std_vect : in std_logic_vector;

    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal o_error_std_vect : out std_logic_vector(2 downto 0)
    ) is

    variable v_csv_file : t_csv_file_reader;

    type t_state is (E_RST, E_WAIT, E_RUN);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST  : boolean   := true;

    variable v_data0 : std_logic_vector(i_data0_std_vect'range) := (others => '0');
    variable v_data1 : std_logic_vector(i_data1_std_vect'range) := (others => '0');
    variable v_data2 : std_logic_vector(i_data2_std_vect'range) := (others => '0');

    variable v_error : std_logic_vector(o_error_std_vect'range) := (others => '0');
    variable v_cnt   : integer                                     := 0;

  begin

    while c_TEST loop
      -- default value
      v_error := (others => '0');

      case v_fsm_state is

        when E_RST =>

          v_fsm_state := E_WAIT;
        when E_WAIT =>

          if i_start = '1' then
            v_cnt   := 0;
            info("reference filepath : "&i_filepath);
            v_csv_file.initialize(i_filepath, csv_separator => i_csv_separator);
            -- skip the header
            v_csv_file.readline(void);
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>
          if i_data_valid = '1' then
            -- read data in file
            v_csv_file.readline(void);

            v_data0 := v_csv_file.read_common_typ_as_std_vec(length => v_data0'length, common_typ => i_DATA0_COMMON_TYP);
            v_data1 := v_csv_file.read_common_typ_as_std_vec(length => v_data1'length, common_typ => i_DATA1_COMMON_TYP);
            v_data2 := v_csv_file.read_common_typ_as_std_vec(length => v_data2'length, common_typ => i_DATA2_COMMON_TYP);


            ---------------------------------------------------------------------
            -- check values
            ---------------------------------------------------------------------
            if v_data0 /= i_data0_std_vect then
              v_error(0) := '1';
            else
              v_error(0) := '0';
            end if;

            if v_data1 /= i_data1_std_vect then
              v_error(1) := '1';
            else
              v_error(1) := '0';
            end if;

            if v_data2 /= i_data2_std_vect then
              v_error(2) := '1';
            else
              v_error(2) := '0';
            end if;

            check_equal(i_data0_sb, v_data0, i_data0_std_vect, result(i_NAME0 &" (Matlab) : " & to_string(v_data0) & ", " & i_NAME0 & " (VHDL) : "& to_string(i_data0_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data1_sb, v_data1, i_data1_std_vect, result(i_NAME1 &" (Matlab) : " & to_string(v_data1) & ", " & i_NAME1 & " (VHDL) : "& to_string(i_data1_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data2_sb, v_data2, i_data2_std_vect, result(i_NAME2 &" (Matlab) : " & to_string(v_data2) & ", " & i_NAME2 & " (VHDL) : "& to_string(i_data2_std_vect) & " , IDX: " & to_string(v_cnt)));
            v_cnt := v_cnt + 1;
          end if;

          v_fsm_state := E_RUN;


        when others => -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;
      o_error_std_vect <= v_error;

      wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure vunit_data_checker_3;

  --------------------------------------------------------------------
-- vunit_data_checker_4
---------------------------------------------------------------------
  procedure vunit_data_checker_4(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- reference file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0 : in string;
    constant i_NAME1 : in string;
    constant i_NAME2 : in string;
    constant i_NAME3 : in string;

    --  common typ = "UINT" => the file integer value is converted into an unsigned vector -> std_logic_vector
    --  common typ = "INT" => the file integer value  is converted into a signed vector -> std_logic_vector
    --  common typ = "HEX" => the hexadecimal value is converted into a std_logic_vector
    --  common typ = "STD_VEC" (binary value) => the std_logic_vector is not converted
    constant i_DATA0_COMMON_TYP : in string := "UINT";
    constant i_DATA1_COMMON_TYP : in string := "UINT";
    constant i_DATA2_COMMON_TYP : in string := "UINT";
    constant i_DATA3_COMMON_TYP : in string := "UINT";

    ---------------------------------------------------------------------
    -- Vunit Scoreboard objects
    ---------------------------------------------------------------------
    constant i_data0_sb : in checker_t;
    constant i_data1_sb : in checker_t;
    constant i_data2_sb : in checker_t;
    constant i_data3_sb : in checker_t;

    ---------------------------------------------------------------------
    -- experimental signals
    ---------------------------------------------------------------------
    signal i_data_valid : in std_logic;

    signal i_data0_std_vect : in std_logic_vector;
    signal i_data1_std_vect : in std_logic_vector;
    signal i_data2_std_vect : in std_logic_vector;
    signal i_data3_std_vect : in std_logic_vector;

    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal o_error_std_vect : out std_logic_vector(3 downto 0)
    ) is

    variable v_csv_file : t_csv_file_reader;

    type t_state is (E_RST, E_WAIT, E_RUN);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST  : boolean   := true;

    variable v_data0 : std_logic_vector(i_data0_std_vect'range) := (others => '0');
    variable v_data1 : std_logic_vector(i_data1_std_vect'range) := (others => '0');
    variable v_data2 : std_logic_vector(i_data2_std_vect'range) := (others => '0');
    variable v_data3 : std_logic_vector(i_data3_std_vect'range) := (others => '0');

    variable v_error : std_logic_vector(o_error_std_vect'range) := (others => '0');
    variable v_cnt   : integer                                     := 0;

  begin

    while c_TEST loop
      -- default value
      v_error := (others => '0');

      case v_fsm_state is

        when E_RST =>
          v_fsm_state := E_WAIT;
        when E_WAIT =>
          v_cnt := 0;

          if i_start = '1' then
            info("reference filepath : "&i_filepath);
            v_csv_file.initialize(i_filepath, csv_separator => i_csv_separator);
            -- skip the header
            v_csv_file.readline(void);
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>
          if i_data_valid = '1' then
            -- read data in file
            v_csv_file.readline(void);

            v_data0 := v_csv_file.read_common_typ_as_std_vec(length => v_data0'length, common_typ => i_DATA0_COMMON_TYP);
            v_data1 := v_csv_file.read_common_typ_as_std_vec(length => v_data1'length, common_typ => i_DATA1_COMMON_TYP);
            v_data2 := v_csv_file.read_common_typ_as_std_vec(length => v_data2'length, common_typ => i_DATA2_COMMON_TYP);
            v_data3 := v_csv_file.read_common_typ_as_std_vec(length => v_data3'length, common_typ => i_DATA3_COMMON_TYP);


            ---------------------------------------------------------------------
            -- check values
            ---------------------------------------------------------------------
            if v_data0 /= i_data0_std_vect then
              v_error(0) := '1';
            else
              v_error(0) := '0';
            end if;

            if v_data1 /= i_data1_std_vect then
              v_error(1) := '1';
            else
              v_error(1) := '0';
            end if;

            if v_data2 /= i_data2_std_vect then
              v_error(2) := '1';
            else
              v_error(2) := '0';
            end if;

            if v_data3 /= i_data3_std_vect then
              v_error(3) := '1';
            else
              v_error(3) := '0';
            end if;

            check_equal(i_data0_sb, v_data0, i_data0_std_vect, result(i_NAME0 &" (Matlab) : " & to_string(v_data0) & ", " & i_NAME0 & " (VHDL) : "& to_string(i_data0_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data1_sb, v_data1, i_data1_std_vect, result(i_NAME1 &" (Matlab) : " & to_string(v_data1) & ", " & i_NAME1 & " (VHDL) : "& to_string(i_data1_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data2_sb, v_data2, i_data2_std_vect, result(i_NAME2 &" (Matlab) : " & to_string(v_data2) & ", " & i_NAME2 & " (VHDL) : "& to_string(i_data2_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data3_sb, v_data3, i_data3_std_vect, result(i_NAME3 &" (Matlab) : " & to_string(v_data3) & ", " & i_NAME3 & " (VHDL) : "& to_string(i_data3_std_vect) & " , IDX: " & to_string(v_cnt)));
            v_cnt := v_cnt + 1;
          end if;

          v_fsm_state := E_RUN;


        when others => -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;
      o_error_std_vect <= v_error;

      wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure vunit_data_checker_4;

--------------------------------------------------------------------
-- vunit_data_checker_5
---------------------------------------------------------------------
  procedure vunit_data_checker_5(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- reference file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0 : in string;
    constant i_NAME1 : in string;
    constant i_NAME2 : in string;
    constant i_NAME3 : in string;
    constant i_NAME4 : in string;

    --  common typ = "UINT" => the file integer value is converted into an unsigned vector -> std_logic_vector
    --  common typ = "INT" => the file integer value  is converted into a signed vector -> std_logic_vector
    --  common typ = "HEX" => the hexadecimal value is converted into a std_logic_vector
    --  common typ = "STD_VEC" (binary value) => the std_logic_vector is not converted
    constant i_DATA0_COMMON_TYP : in string := "UINT";
    constant i_DATA1_COMMON_TYP : in string := "UINT";
    constant i_DATA2_COMMON_TYP : in string := "UINT";
    constant i_DATA3_COMMON_TYP : in string := "UINT";
    constant i_DATA4_COMMON_TYP : in string := "UINT";

    ---------------------------------------------------------------------
    -- Vunit Scoreboard objects
    ---------------------------------------------------------------------
    constant i_data0_sb : in checker_t;
    constant i_data1_sb : in checker_t;
    constant i_data2_sb : in checker_t;
    constant i_data3_sb : in checker_t;
    constant i_data4_sb : in checker_t;

    ---------------------------------------------------------------------
    -- experimental signals
    ---------------------------------------------------------------------
    signal i_data_valid : in std_logic;

    signal i_data0_std_vect : in std_logic_vector;
    signal i_data1_std_vect : in std_logic_vector;
    signal i_data2_std_vect : in std_logic_vector;
    signal i_data3_std_vect : in std_logic_vector;
    signal i_data4_std_vect : in std_logic_vector;

    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal o_error_std_vect : out std_logic_vector(4 downto 0)

    ) is

    variable v_csv_file : t_csv_file_reader;

    type t_state is (E_RST, E_WAIT, E_RUN);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST  : boolean   := true;

    variable v_data0 : std_logic_vector(i_data0_std_vect'range) := (others => '0');
    variable v_data1 : std_logic_vector(i_data1_std_vect'range) := (others => '0');
    variable v_data2 : std_logic_vector(i_data2_std_vect'range) := (others => '0');
    variable v_data3 : std_logic_vector(i_data3_std_vect'range) := (others => '0');
    variable v_data4 : std_logic_vector(i_data4_std_vect'range) := (others => '0');

    variable v_error : std_logic_vector(o_error_std_vect'range) := (others => '0');
    variable v_cnt   : integer                                     := 0;


  begin

    while c_TEST loop
      -- default value
      v_error := (others => '0');

      case v_fsm_state is

        when E_RST =>
          v_fsm_state := E_WAIT;
        when E_WAIT =>
          v_cnt := 0;

          if i_start = '1' then
            info("reference filepath : "&i_filepath);
            v_csv_file.initialize(i_filepath, csv_separator => i_csv_separator);
            -- skip the header
            v_csv_file.readline(void);
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>
          if i_data_valid = '1' then
            -- read data in file
            v_csv_file.readline(void);

            v_data0 := v_csv_file.read_common_typ_as_std_vec(length => v_data0'length, common_typ => i_DATA0_COMMON_TYP);
            v_data1 := v_csv_file.read_common_typ_as_std_vec(length => v_data1'length, common_typ => i_DATA1_COMMON_TYP);
            v_data2 := v_csv_file.read_common_typ_as_std_vec(length => v_data2'length, common_typ => i_DATA2_COMMON_TYP);
            v_data3 := v_csv_file.read_common_typ_as_std_vec(length => v_data3'length, common_typ => i_DATA3_COMMON_TYP);
            v_data4 := v_csv_file.read_common_typ_as_std_vec(length => v_data4'length, common_typ => i_DATA4_COMMON_TYP);


            ---------------------------------------------------------------------
            -- check values
            ---------------------------------------------------------------------
            if v_data0 /= i_data0_std_vect then
              v_error(0) := '1';
            else
              v_error(0) := '0';
            end if;

            if v_data1 /= i_data1_std_vect then
              v_error(1) := '1';
            else
              v_error(1) := '0';
            end if;

            if v_data2 /= i_data2_std_vect then
              v_error(2) := '1';
            else
              v_error(2) := '0';
            end if;

            if v_data3 /= i_data3_std_vect then
              v_error(3) := '1';
            else
              v_error(3) := '0';
            end if;

            if v_data4 /= i_data4_std_vect then
              v_error(4) := '1';
            else
              v_error(4) := '0';
            end if;
            check_equal(i_data0_sb, v_data0, i_data0_std_vect, result(i_NAME0 &" (Matlab) : " & to_string(v_data0) & ", " & i_NAME0 & " (VHDL) : "& to_string(i_data0_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data1_sb, v_data1, i_data1_std_vect, result(i_NAME1 &" (Matlab) : " & to_string(v_data1) & ", " & i_NAME1 & " (VHDL) : "& to_string(i_data1_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data2_sb, v_data2, i_data2_std_vect, result(i_NAME2 &" (Matlab) : " & to_string(v_data2) & ", " & i_NAME2 & " (VHDL) : "& to_string(i_data2_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data3_sb, v_data3, i_data3_std_vect, result(i_NAME3 &" (Matlab) : " & to_string(v_data3) & ", " & i_NAME3 & " (VHDL) : "& to_string(i_data3_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data4_sb, v_data4, i_data4_std_vect, result(i_NAME4 &" (Matlab) : " & to_string(v_data4) & ", " & i_NAME4 & " (VHDL) : "& to_string(i_data4_std_vect) & " , IDX: " & to_string(v_cnt)));
            v_cnt := v_cnt + 1;
          end if;

          v_fsm_state := E_RUN;


        when others => -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;

      o_error_std_vect <= v_error;

      wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure vunit_data_checker_5;

  --------------------------------------------------------------------
-- vunit_data_checker_10
---------------------------------------------------------------------
  procedure vunit_data_checker_10(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- reference file
    ---------------------------------------------------------------------
    i_filepath      : in string;
    i_csv_separator : in character;

    constant i_NAME0 : in string;
    constant i_NAME1 : in string;
    constant i_NAME2 : in string;
    constant i_NAME3 : in string;
    constant i_NAME4 : in string;
    constant i_NAME5 : in string;
    constant i_NAME6 : in string;
    constant i_NAME7 : in string;
    constant i_NAME8 : in string;
    constant i_NAME9 : in string;

    --  common typ = "UINT" => the file integer value is converted into an unsigned vector -> std_logic_vector
    --  common typ = "INT" => the file integer value  is converted into a signed vector -> std_logic_vector
    --  common typ = "HEX" => the hexadecimal value is converted into a std_logic_vector
    --  common typ = "STD_VEC" (binary value) => the std_logic_vector is not converted
    constant i_DATA0_COMMON_TYP : in string := "UINT";
    constant i_DATA1_COMMON_TYP : in string := "UINT";
    constant i_DATA2_COMMON_TYP : in string := "UINT";
    constant i_DATA3_COMMON_TYP : in string := "UINT";
    constant i_DATA4_COMMON_TYP : in string := "UINT";
    constant i_DATA5_COMMON_TYP : in string := "UINT";
    constant i_DATA6_COMMON_TYP : in string := "UINT";
    constant i_DATA7_COMMON_TYP : in string := "UINT";
    constant i_DATA8_COMMON_TYP : in string := "UINT";
    constant i_DATA9_COMMON_TYP : in string := "UINT";

    ---------------------------------------------------------------------
    -- Vunit Scoreboard objects
    ---------------------------------------------------------------------
    constant i_data0_sb : in checker_t;
    constant i_data1_sb : in checker_t;
    constant i_data2_sb : in checker_t;
    constant i_data3_sb : in checker_t;
    constant i_data4_sb : in checker_t;
    constant i_data5_sb : in checker_t;
    constant i_data6_sb : in checker_t;
    constant i_data7_sb : in checker_t;
    constant i_data8_sb : in checker_t;
    constant i_data9_sb : in checker_t;

    ---------------------------------------------------------------------
    -- experimental signals
    ---------------------------------------------------------------------
    signal i_data_valid : in std_logic;

    signal i_data0_std_vect : in std_logic_vector;
    signal i_data1_std_vect : in std_logic_vector;
    signal i_data2_std_vect : in std_logic_vector;
    signal i_data3_std_vect : in std_logic_vector;
    signal i_data4_std_vect : in std_logic_vector;
    signal i_data5_std_vect : in std_logic_vector;
    signal i_data6_std_vect : in std_logic_vector;
    signal i_data7_std_vect : in std_logic_vector;
    signal i_data8_std_vect : in std_logic_vector;
    signal i_data9_std_vect : in std_logic_vector;

    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal o_error_std_vect : out std_logic_vector(9 downto 0)
    ) is

    variable v_csv_file : t_csv_file_reader;

    type t_state is (E_RST, E_WAIT, E_RUN);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST  : boolean   := true;

    variable v_data0 : std_logic_vector(i_data0_std_vect'range) := (others => '0');
    variable v_data1 : std_logic_vector(i_data1_std_vect'range) := (others => '0');
    variable v_data2 : std_logic_vector(i_data2_std_vect'range) := (others => '0');
    variable v_data3 : std_logic_vector(i_data3_std_vect'range) := (others => '0');
    variable v_data4 : std_logic_vector(i_data4_std_vect'range) := (others => '0');
    variable v_data5 : std_logic_vector(i_data5_std_vect'range) := (others => '0');
    variable v_data6 : std_logic_vector(i_data6_std_vect'range) := (others => '0');
    variable v_data7 : std_logic_vector(i_data7_std_vect'range) := (others => '0');
    variable v_data8 : std_logic_vector(i_data8_std_vect'range) := (others => '0');
    variable v_data9 : std_logic_vector(i_data9_std_vect'range) := (others => '0');

    variable v_error : std_logic_vector(o_error_std_vect'range) := (others => '0');
    variable v_cnt   : integer                                     := 0;

  begin

    while c_TEST loop
      -- default value
      v_error := (others => '0');

      case v_fsm_state is

        when E_RST =>
          v_fsm_state := E_WAIT;
        when E_WAIT =>
          v_cnt := 0;
          if i_start = '1' then
            info("reference filepath : "&i_filepath);
            v_csv_file.initialize(i_filepath, csv_separator => i_csv_separator);
            -- skip the header
            v_csv_file.readline(void);
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>
          if i_data_valid = '1' then
            -- read data in file
            v_csv_file.readline(void);

            v_data0 := v_csv_file.read_common_typ_as_std_vec(length => v_data0'length, common_typ => i_DATA0_COMMON_TYP);
            v_data1 := v_csv_file.read_common_typ_as_std_vec(length => v_data1'length, common_typ => i_DATA1_COMMON_TYP);
            v_data2 := v_csv_file.read_common_typ_as_std_vec(length => v_data2'length, common_typ => i_DATA2_COMMON_TYP);
            v_data3 := v_csv_file.read_common_typ_as_std_vec(length => v_data3'length, common_typ => i_DATA3_COMMON_TYP);
            v_data4 := v_csv_file.read_common_typ_as_std_vec(length => v_data4'length, common_typ => i_DATA4_COMMON_TYP);
            v_data5 := v_csv_file.read_common_typ_as_std_vec(length => v_data5'length, common_typ => i_DATA5_COMMON_TYP);
            v_data6 := v_csv_file.read_common_typ_as_std_vec(length => v_data6'length, common_typ => i_DATA6_COMMON_TYP);
            v_data7 := v_csv_file.read_common_typ_as_std_vec(length => v_data7'length, common_typ => i_DATA7_COMMON_TYP);
            v_data8 := v_csv_file.read_common_typ_as_std_vec(length => v_data8'length, common_typ => i_DATA8_COMMON_TYP);
            v_data9 := v_csv_file.read_common_typ_as_std_vec(length => v_data9'length, common_typ => i_DATA9_COMMON_TYP);


            ---------------------------------------------------------------------
            -- check values
            ---------------------------------------------------------------------
            if v_data0 /= i_data0_std_vect then
              v_error(0) := '1';
            else
              v_error(0) := '0';
            end if;
            if v_data1 /= i_data1_std_vect then
              v_error(1) := '1';
            else
              v_error(1) := '0';
            end if;

            if v_data2 /= i_data2_std_vect then
              v_error(2) := '1';
            else
              v_error(2) := '0';
            end if;

            if v_data3 /= i_data3_std_vect then
              v_error(3) := '1';
            else
              v_error(3) := '0';
            end if;

            if v_data4 /= i_data4_std_vect then
              v_error(4) := '1';
            else
              v_error(4) := '0';
            end if;

            if v_data5 /= i_data5_std_vect then
              v_error(5) := '1';
            else
              v_error(5) := '0';
            end if;

            if v_data6 /= i_data6_std_vect then
              v_error(6) := '1';
            else
              v_error(6) := '0';
            end if;

            if v_data7 /= i_data7_std_vect then
              v_error(7) := '1';
            else
              v_error(7) := '0';
            end if;

            if v_data8 /= i_data8_std_vect then
              v_error(8) := '1';
            else
              v_error(8) := '0';
            end if;

            if v_data9 /= i_data9_std_vect then
              v_error(9) := '1';
            else
              v_error(9) := '0';
            end if;

            check_equal(i_data0_sb, v_data0, i_data0_std_vect, result(i_NAME0 &" (Matlab) : " & to_string(v_data0) & ", " & i_NAME0 & " (VHDL) : "& to_string(i_data0_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data1_sb, v_data1, i_data1_std_vect, result(i_NAME1 &" (Matlab) : " & to_string(v_data1) & ", " & i_NAME1 & " (VHDL) : "& to_string(i_data1_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data2_sb, v_data2, i_data2_std_vect, result(i_NAME2 &" (Matlab) : " & to_string(v_data2) & ", " & i_NAME2 & " (VHDL) : "& to_string(i_data2_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data3_sb, v_data3, i_data3_std_vect, result(i_NAME3 &" (Matlab) : " & to_string(v_data3) & ", " & i_NAME3 & " (VHDL) : "& to_string(i_data3_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data4_sb, v_data4, i_data4_std_vect, result(i_NAME4 &" (Matlab) : " & to_string(v_data4) & ", " & i_NAME4 & " (VHDL) : "& to_string(i_data4_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data5_sb, v_data5, i_data5_std_vect, result(i_NAME5 &" (Matlab) : " & to_string(v_data5) & ", " & i_NAME5 & " (VHDL) : "& to_string(i_data5_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data6_sb, v_data6, i_data6_std_vect, result(i_NAME6 &" (Matlab) : " & to_string(v_data6) & ", " & i_NAME6 & " (VHDL) : "& to_string(i_data6_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data7_sb, v_data7, i_data7_std_vect, result(i_NAME7 &" (Matlab) : " & to_string(v_data7) & ", " & i_NAME7 & " (VHDL) : "& to_string(i_data7_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data8_sb, v_data8, i_data8_std_vect, result(i_NAME8 &" (Matlab) : " & to_string(v_data8) & ", " & i_NAME8 & " (VHDL) : "& to_string(i_data8_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data9_sb, v_data9, i_data9_std_vect, result(i_NAME9 &" (Matlab) : " & to_string(v_data9) & ", " & i_NAME9 & " (VHDL) : "& to_string(i_data9_std_vect) & " , IDX: " & to_string(v_cnt)));
            v_cnt := v_cnt + 1;
          end if;

          v_fsm_state := E_RUN;


        when others => -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;

      o_error_std_vect <= v_error;

      wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure vunit_data_checker_10;

  --------------------------------------------------------------------
-- vunit_data_checker_13
---------------------------------------------------------------------
  procedure vunit_data_checker_13(
    signal i_clk   : in std_logic;
    signal i_start : in std_logic;

    ---------------------------------------------------------------------
    -- reference file
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
    constant i_NAME11 : in string;
    constant i_NAME12 : in string;

    --  common typ = "UINT" => the file integer value is converted into an unsigned vector -> std_logic_vector
    --  common typ = "INT" => the file integer value  is converted into a signed vector -> std_logic_vector
    --  common typ = "HEX" => the hexadecimal value is converted into a std_logic_vector
    --  common typ = "STD_VEC" (binary value) => the std_logic_vector is not converted
    constant i_DATA0_COMMON_TYP  : in string := "UINT";
    constant i_DATA1_COMMON_TYP  : in string := "UINT";
    constant i_DATA2_COMMON_TYP  : in string := "UINT";
    constant i_DATA3_COMMON_TYP  : in string := "UINT";
    constant i_DATA4_COMMON_TYP  : in string := "UINT";
    constant i_DATA5_COMMON_TYP  : in string := "UINT";
    constant i_DATA6_COMMON_TYP  : in string := "UINT";
    constant i_DATA7_COMMON_TYP  : in string := "UINT";
    constant i_DATA8_COMMON_TYP  : in string := "UINT";
    constant i_DATA9_COMMON_TYP  : in string := "UINT";
    constant i_DATA10_COMMON_TYP : in string := "UINT";
    constant i_DATA11_COMMON_TYP : in string := "UINT";
    constant i_DATA12_COMMON_TYP : in string := "UINT";

    ---------------------------------------------------------------------
    -- Vunit Scoreboard objects
    ---------------------------------------------------------------------

    constant i_data0_sb  : in checker_t;
    constant i_data1_sb  : in checker_t;
    constant i_data2_sb  : in checker_t;
    constant i_data3_sb  : in checker_t;
    constant i_data4_sb  : in checker_t;
    constant i_data5_sb  : in checker_t;
    constant i_data6_sb  : in checker_t;
    constant i_data7_sb  : in checker_t;
    constant i_data8_sb  : in checker_t;
    constant i_data9_sb  : in checker_t;
    constant i_data10_sb : in checker_t;
    constant i_data11_sb : in checker_t;
    constant i_data12_sb : in checker_t;

    ---------------------------------------------------------------------
    -- experimental signals
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
    signal i_data10_std_vect : in std_logic_vector;
    signal i_data11_std_vect : in std_logic_vector;
    signal i_data12_std_vect : in std_logic_vector;

    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal o_error_std_vect : out std_logic_vector(12 downto 0)
    ) is

    variable v_csv_file : t_csv_file_reader;

    type t_state is (E_RST, E_WAIT, E_RUN);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST  : boolean   := true;

    variable v_data0  : std_logic_vector(i_data0_std_vect'range)  := (others => '0');
    variable v_data1  : std_logic_vector(i_data1_std_vect'range)  := (others => '0');
    variable v_data2  : std_logic_vector(i_data2_std_vect'range)  := (others => '0');
    variable v_data3  : std_logic_vector(i_data3_std_vect'range)  := (others => '0');
    variable v_data4  : std_logic_vector(i_data4_std_vect'range)  := (others => '0');
    variable v_data5  : std_logic_vector(i_data5_std_vect'range)  := (others => '0');
    variable v_data6  : std_logic_vector(i_data6_std_vect'range)  := (others => '0');
    variable v_data7  : std_logic_vector(i_data7_std_vect'range)  := (others => '0');
    variable v_data8  : std_logic_vector(i_data8_std_vect'range)  := (others => '0');
    variable v_data9  : std_logic_vector(i_data9_std_vect'range)  := (others => '0');
    variable v_data10 : std_logic_vector(i_data10_std_vect'range) := (others => '0');
    variable v_data11 : std_logic_vector(i_data10_std_vect'range) := (others => '0');
    variable v_data12 : std_logic_vector(i_data10_std_vect'range) := (others => '0');

    variable v_error : std_logic_vector(o_error_std_vect'range) := (others => '0');
    variable v_cnt   : integer                                     := 0;

  begin

    while c_TEST = true loop -- @suppress "Redundant boolean equality check with true"
      -- default value
      v_error := (others => '0');

      case v_fsm_state is

        when E_RST =>

          v_fsm_state := E_WAIT;
        when E_WAIT =>
          v_cnt := 0;
          if i_start = '1' then
            info("reference filepath : "&i_filepath);
            v_csv_file.initialize(i_filepath, csv_separator => i_csv_separator);
            -- skip the header
            v_csv_file.readline(void);
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>
          if i_data_valid = '1' then
            -- read data in file
            v_csv_file.readline(void);
            -- v_data
            v_data0  := v_csv_file.read_common_typ_as_std_vec(length => v_data0'length, common_typ => i_DATA0_COMMON_TYP);
            v_data1  := v_csv_file.read_common_typ_as_std_vec(length => v_data1'length, common_typ => i_DATA1_COMMON_TYP);
            v_data2  := v_csv_file.read_common_typ_as_std_vec(length => v_data2'length, common_typ => i_DATA2_COMMON_TYP);
            v_data3  := v_csv_file.read_common_typ_as_std_vec(length => v_data3'length, common_typ => i_DATA3_COMMON_TYP);
            v_data4  := v_csv_file.read_common_typ_as_std_vec(length => v_data4'length, common_typ => i_DATA4_COMMON_TYP);
            v_data5  := v_csv_file.read_common_typ_as_std_vec(length => v_data5'length, common_typ => i_DATA5_COMMON_TYP);
            v_data6  := v_csv_file.read_common_typ_as_std_vec(length => v_data6'length, common_typ => i_DATA6_COMMON_TYP);
            v_data7  := v_csv_file.read_common_typ_as_std_vec(length => v_data7'length, common_typ => i_DATA7_COMMON_TYP);
            v_data8  := v_csv_file.read_common_typ_as_std_vec(length => v_data8'length, common_typ => i_DATA8_COMMON_TYP);
            v_data9  := v_csv_file.read_common_typ_as_std_vec(length => v_data9'length, common_typ => i_DATA9_COMMON_TYP);
            v_data10 := v_csv_file.read_common_typ_as_std_vec(length => v_data10'length, common_typ => i_DATA10_COMMON_TYP);
            v_data11 := v_csv_file.read_common_typ_as_std_vec(length => v_data11'length, common_typ => i_DATA11_COMMON_TYP);
            v_data12 := v_csv_file.read_common_typ_as_std_vec(length => v_data12'length, common_typ => i_DATA12_COMMON_TYP);


            ---------------------------------------------------------------------
            -- check values
            ---------------------------------------------------------------------
            if v_data0 /= i_data0_std_vect then
              v_error(0) := '1';
            else
              v_error(0) := '0';
            end if;

            if v_data1 /= i_data1_std_vect then
              v_error(1) := '1';
            else
              v_error(1) := '0';
            end if;

            if v_data2 /= i_data2_std_vect then
              v_error(2) := '1';
            else
              v_error(2) := '0';
            end if;

            if v_data3 /= i_data3_std_vect then
              v_error(3) := '1';
            else
              v_error(3) := '0';
            end if;

            if v_data4 /= i_data4_std_vect then
              v_error(4) := '1';
            else
              v_error(4) := '0';
            end if;

            if v_data5 /= i_data5_std_vect then
              v_error(5) := '1';
            else
              v_error(5) := '0';
            end if;

            if v_data6 /= i_data6_std_vect then
              v_error(6) := '1';
            else
              v_error(6) := '0';
            end if;

            if v_data7 /= i_data7_std_vect then
              v_error(7) := '1';
            else
              v_error(7) := '0';
            end if;

            if v_data8 /= i_data8_std_vect then
              v_error(8) := '1';
            else
              v_error(8) := '0';
            end if;

            if v_data9 /= i_data9_std_vect then
              v_error(9) := '1';
            else
              v_error(9) := '0';
            end if;

            if v_data10 /= i_data10_std_vect then
              v_error(10) := '1';
            else
              v_error(10) := '0';
            end if;

            if v_data11 /= i_data11_std_vect then
              v_error(11) := '1';
            else
              v_error(11) := '0';
            end if;

            if v_data12 /= i_data12_std_vect then
              v_error(12) := '1';
            else
              v_error(12) := '0';
            end if;

            check_equal(i_data0_sb, v_data0, i_data0_std_vect, result(i_NAME0 &" (Matlab) : " & to_string(v_data0) & ", " & i_NAME0 & " (VHDL) : "& to_string(i_data0_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data1_sb, v_data1, i_data1_std_vect, result(i_NAME1 &" (Matlab) : " & to_string(v_data1) & ", " & i_NAME1 & " (VHDL) : "& to_string(i_data1_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data2_sb, v_data2, i_data2_std_vect, result(i_NAME2 &" (Matlab) : " & to_string(v_data2) & ", " & i_NAME2 & " (VHDL) : "& to_string(i_data2_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data3_sb, v_data3, i_data3_std_vect, result(i_NAME3 &" (Matlab) : " & to_string(v_data3) & ", " & i_NAME3 & " (VHDL) : "& to_string(i_data3_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data4_sb, v_data4, i_data4_std_vect, result(i_NAME4 &" (Matlab) : " & to_string(v_data4) & ", " & i_NAME4 & " (VHDL) : "& to_string(i_data4_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data5_sb, v_data5, i_data5_std_vect, result(i_NAME5 &" (Matlab) : " & to_string(v_data5) & ", " & i_NAME5 & " (VHDL) : "& to_string(i_data5_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data6_sb, v_data6, i_data6_std_vect, result(i_NAME6 &" (Matlab) : " & to_string(v_data6) & ", " & i_NAME6 & " (VHDL) : "& to_string(i_data6_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data7_sb, v_data7, i_data7_std_vect, result(i_NAME7 &" (Matlab) : " & to_string(v_data7) & ", " & i_NAME7 & " (VHDL) : "& to_string(i_data7_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data8_sb, v_data8, i_data8_std_vect, result(i_NAME8 &" (Matlab) : " & to_string(v_data8) & ", " & i_NAME8 & " (VHDL) : "& to_string(i_data8_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data9_sb, v_data9, i_data9_std_vect, result(i_NAME9 &" (Matlab) : " & to_string(v_data9) & ", " & i_NAME9 & " (VHDL) : "& to_string(i_data9_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data10_sb, v_data10, i_data10_std_vect, result(i_NAME10 &" (Matlab) : " & to_string(v_data10) & ", " & i_NAME10 & " (VHDL) : "& to_string(i_data10_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data11_sb, v_data11, i_data11_std_vect, result(i_NAME11 &" (Matlab) : " & to_string(v_data11) & ", " & i_NAME11 & " (VHDL) : "& to_string(i_data11_std_vect) & " , IDX: " & to_string(v_cnt)));
            check_equal(i_data12_sb, v_data12, i_data12_std_vect, result(i_NAME12 &" (Matlab) : " & to_string(v_data12) & ", " & i_NAME12 & " (VHDL) : "& to_string(i_data12_std_vect) & " , IDX: " & to_string(v_cnt)));

            v_cnt := v_cnt + 1;
          end if;

          v_fsm_state := E_RUN;


        when others => -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;
      o_error_std_vect <= v_error;

      wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure vunit_data_checker_13;


end package body pkg_data_checker;
