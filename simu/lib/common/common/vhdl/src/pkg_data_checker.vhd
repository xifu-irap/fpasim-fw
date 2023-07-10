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
--    This simulation VHDL package defines VHDL functions/procedures in order to:
--       . compare VHDL testbench data with data from an input csv file (by using Vunit checker_t object).
--
--    Note: This package should be compiled into the common_lib
--    Dependencies:
--      . csv_lib.pkg_csv_file
--      . context vunit_lib.vunit_context
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library csv_lib;
use csv_lib.pkg_csv_file.all;

library vunit_lib;
context vunit_lib.vunit_context;

use work.pkg_common.all;

package pkg_data_checker is

  --------------------------------------------------------------------
  -- pkg_vunit_data_checker_1
  ---------------------------------------------------------------------
  procedure pkg_vunit_data_checker_1(
    signal   i_clk              : in std_logic;
    signal   i_start            : in std_logic;
    ---------------------------------------------------------------------
    -- reference file
    ---------------------------------------------------------------------
    i_filepath                  : in string;
    i_csv_separator             : in character;
    constant i_NAME0            : in string;
    --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
    --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
    --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
    --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
    --  data type = "STD_VEC" => no data convertion before writing in the output file
    constant i_DATA0_TYP : in string := "UINT";
    ---------------------------------------------------------------------
    -- Vunit Scoreboard objects
    ---------------------------------------------------------------------
    constant i_sb_data0         : in checker_t;
    ---------------------------------------------------------------------
    -- experimental signals
    ---------------------------------------------------------------------
    signal   i_data_valid       : in std_logic;
    signal   i_data0_std_vect   : in std_logic_vector;
    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal   o_error_std_vect   : out std_logic_vector(0 downto 0)
  );


end package pkg_data_checker;

package body pkg_data_checker is

  --------------------------------------------------------------------
  -- pkg_vunit_data_checker_1
  ---------------------------------------------------------------------
  procedure pkg_vunit_data_checker_1(
    signal   i_clk              : in std_logic;
    signal   i_start            : in std_logic;
    ---------------------------------------------------------------------
    -- reference file
    ---------------------------------------------------------------------
    i_filepath                  : in string;
    i_csv_separator             : in character;
    constant i_NAME0            : in string;
    --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
    --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
    --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
    --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
    --  data type = "STD_VEC" => no data convertion before writing in the output file
    constant i_DATA0_TYP : in string := "UINT";
    ---------------------------------------------------------------------
    -- Vunit Scoreboard objects
    ---------------------------------------------------------------------
    constant i_sb_data0         : in checker_t;
    ---------------------------------------------------------------------
    -- experimental signals
    ---------------------------------------------------------------------
    signal   i_data_valid       : in std_logic;
    signal   i_data0_std_vect   : in std_logic_vector;
    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal   o_error_std_vect   : out std_logic_vector(0 downto 0)
  ) is

    variable v_csv_file : t_csv_file_reader;

    type t_state is (E_RST, E_WAIT, E_RUN);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST      : boolean := true;

    variable v_data0 : std_logic_vector(i_data0_std_vect'range) := (others => '0');

    variable v_error : std_logic_vector(o_error_std_vect'range) := (others => '0');
    variable v_cnt   : integer                                  := 0;

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
            info("reference filepath : " & i_filepath);
            v_csv_file.initialize(i_filepath, i_csv_separator => i_csv_separator);
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

            v_data0 := v_csv_file.read_data_typ_as_std_vec(i_length => v_data0'length, i_data_typ => i_DATA0_TYP);

            ---------------------------------------------------------------------
            -- check values
            ---------------------------------------------------------------------
            if v_data0 /= i_data0_std_vect then
              v_error(0) := '1';
            else
              v_error(0) := '0';
            end if;
            check_equal(i_sb_data0, v_data0, i_data0_std_vect, result(i_NAME0 & ", IDX: " & to_string(v_cnt) & " (File) : " & to_string(v_data0) & ", " & i_NAME0 & " (VHDL) : " & to_string(i_data0_std_vect)));
            v_cnt := v_cnt + 1;
          end if;

          v_fsm_state := E_RUN;

        when others =>
          v_fsm_state := E_RST;
      end case;

      o_error_std_vect <= v_error;

      pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure pkg_vunit_data_checker_1;



end package body pkg_data_checker;
