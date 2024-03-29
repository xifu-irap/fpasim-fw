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
--    @file                   pkg_ram_check.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--    This simulation VHDL package defines VHDL functions/procedures in order to
--      . write and check True dual port RAM
--        . A first input csv file is used to write the RAM-like content
--        . A second input csv file is used to check the RAM-like content.
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

package pkg_ram_check is

  ---------------------------------------------------------------------
  -- pkg_memory_wr_tdpram_and_check
  ---------------------------------------------------------------------
  procedure pkg_memory_wr_tdpram_and_check(
    signal   i_clk             : in std_logic; -- clock
    signal   i_start_wr        : in std_logic; -- start procedure: read and output data from file
    signal   i_start_rd        : in std_logic; -- start procedure: read data from file and check input data
    ---------------------------------------------------------------------
    -- input file
    ---------------------------------------------------------------------
    i_filepath_wr             : in string; -- input *.csv filepath (data to read and to output)
    i_filepath_rd             : in string; -- input *.csv filepath (data to read and to check with the input)
    i_csv_separator           : in character; -- *.csv file separator
    constant i_RD_NAME1        : in string; -- read message
    --  data type = "UINT" => the read data from the file are converted: uint -> std_logic_vector
    --  data type = "INT" => the read data from the file are converted: int -> std_logic_vector
    --  data type = "HEX" => the read data from the file are converted: hex-> int -> std_logic_vector
    --  data type = "UHEX" => the read data from the file are converted: hex-> uint -> std_logic_vector
    --  data type = "STD_VEC" => the read data from the file aren't converted : std_logic_vector -> std_logic_vector
    constant i_WR_RD_ADDR_TYP  : in string := "HEX"; -- data format of the input csv file: column0 (data to output)
    constant i_WR_DATA_TYP     : in string := "HEX"; -- data format of the input csv file: column1 (data to output)
    constant i_RD_DATA_TYP     : in string := "HEX"; -- data format of the input csv file: column0 (data checking)
    ---------------------------------------------------------------------
    -- Vunit Scoreboard objects
    ---------------------------------------------------------------------
    constant i_data_sb         : in checker_t; -- vunit checker object
    signal   i_rd_ready        : in std_logic; -- read a new data from file (data checking)
    signal   i_wr_ready        : in std_logic; -- read a new data from file (data to output)
    ---------------------------------------------------------------------
    -- command
    ---------------------------------------------------------------------
    signal   o_wr_data_valid   : out std_logic; -- output data valid (data to output)
    signal   o_rd_data_valid   : out std_logic; -- output data valid (data checking)
    signal   o_wr_rd_addr_vect : out std_logic_vector; -- output address (data to output)
    signal   o_wr_data_vect    : out std_logic_vector; -- output data (data to output)
    -- read value
    signal   i_rd_data_valid   : in std_logic; -- input data valid (data checking)
    signal   i_rd_data_vect    : in std_logic_vector; -- input data (data checking)
    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal   o_wr_finish       : out std_logic; -- end of the file processing (data to output)
    signal   o_rd_finish       : out std_logic; -- end of the file processing (data checking)
    signal   o_error           : out std_logic_vector(0 downto 0) -- error during the data checking (data file /= data input?)
  );

end package pkg_ram_check;

package body pkg_ram_check is

  ---------------------------------------------------------------------
  -- pkg_memory_wr_tdpram_and_check
  ---------------------------------------------------------------------
  procedure pkg_memory_wr_tdpram_and_check(
    signal   i_clk             : in std_logic; -- clock
    signal   i_start_wr        : in std_logic; -- start procedure: read and output data from file
    signal   i_start_rd        : in std_logic; -- start procedure: read data from file and check input data
    ---------------------------------------------------------------------
    -- input file
    ---------------------------------------------------------------------
    i_filepath_wr             : in string; -- input *.csv filepath (data to read and to output)
    i_filepath_rd             : in string; -- input *.csv filepath (data to read and to check with the input)
    i_csv_separator           : in character; -- *.csv file separator
    constant i_RD_NAME1        : in string; -- read message
    --  data type = "UINT" => the read data from the file are converted: uint -> std_logic_vector
    --  data type = "INT" => the read data from the file are converted: int -> std_logic_vector
    --  data type = "HEX" => the read data from the file are converted: hex-> int -> std_logic_vector
    --  data type = "UHEX" => the read data from the file are converted: hex-> uint -> std_logic_vector
    --  data type = "STD_VEC" => the read data from the file aren't converted : std_logic_vector -> std_logic_vector
    constant i_WR_RD_ADDR_TYP  : in string := "HEX"; -- data format of the input csv file: column0 (data to output)
    constant i_WR_DATA_TYP     : in string := "HEX"; -- data format of the input csv file: column1 (data to output)
    constant i_RD_DATA_TYP     : in string := "HEX"; -- data format of the input csv file: column0 (data checking)
    ---------------------------------------------------------------------
    -- Vunit Scoreboard objects
    ---------------------------------------------------------------------
    constant i_data_sb         : in checker_t; -- vunit checker object
    signal   i_rd_ready        : in std_logic; -- read a new data from file (data checking)
    signal   i_wr_ready        : in std_logic; -- read a new data from file (data to output)
    ---------------------------------------------------------------------
    -- command
    ---------------------------------------------------------------------
    signal   o_wr_data_valid   : out std_logic; -- output data valid (data to output)
    signal   o_rd_data_valid   : out std_logic; -- output data valid (data checking)
    signal   o_wr_rd_addr_vect : out std_logic_vector; -- output address (data to output)
    signal   o_wr_data_vect    : out std_logic_vector; -- output data (data to output)
    -- read value
    signal   i_rd_data_valid   : in std_logic; -- input data valid (data checking)
    signal   i_rd_data_vect    : in std_logic_vector; -- input data (data checking)
    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal   o_wr_finish       : out std_logic; -- end of the file processing (data to output)
    signal   o_rd_finish       : out std_logic; -- end of the file processing (data checking)
    signal   o_error           : out std_logic_vector(0 downto 0) -- error during the data checking (data file /= data input?)
  ) is

    -- csv object
    variable v_csv_file : t_csv_file_reader;

    -- fsm type declaration
    type t_state is (E_RST, E_WAIT_WR, E_RUN_WR, E_WAIT_RD, E_RUN_RD0, E_RUN_RD1, E_END);
    -- state
    variable v_fsm_state : t_state := E_RST;
    -- test condition for the infinite loop
    constant c_TEST      : boolean := true;

    -- output data valid (data to output)
    variable v_wr_data_valid : std_logic                                 := '0';
    -- output address (data to output)
    variable v_wr_rd_addr    : std_logic_vector(o_wr_rd_addr_vect'range) := (others => '0');
    -- output data (data to output)
    variable v_wr_data       : std_logic_vector(o_wr_data_vect'range)    := (others => '0');
    -- end of the file processing (data to output)
    variable v_wr_finish     : std_logic                                 := '0';

    -- output data valid (data checking)
    variable v_rd_data_valid : std_logic                              := '0';
    -- read data from file (data checking)
    variable v_rd_data       : std_logic_vector(i_rd_data_vect'range) := (others => '0');
    -- end of the file processing (data checking)
    variable v_rd_finish     : std_logic                              := '0';

    -- count the number of checked values.
    variable v_cnt : integer := 0;

     -- error during the data checking (data file /= data input?)
    variable v_error : std_logic_vector(o_error'range) := (others => '0');

  begin

    while c_TEST loop

      case v_fsm_state is

        when E_RST =>

          v_wr_data_valid := '0';
          v_wr_finish     := '0';
          v_rd_data_valid := '0';
          v_rd_finish     := '0';
          v_error         := (others => '0');
          v_fsm_state     := E_WAIT_WR;

        when E_WAIT_WR =>

          if i_start_wr = '1' then

            v_csv_file.initialize(i_filepath_wr, i_csv_separator => i_csv_separator);
            -- skip the header
            v_csv_file.readline(void);

            if v_csv_file.end_of_file(void) = true then
              v_wr_finish := '1';
              v_csv_file.dispose(void);
              v_fsm_state := E_WAIT_RD;
            else
              v_wr_finish := '0';
              v_fsm_state := E_RUN_WR;
            end if;
          else
            v_fsm_state := E_WAIT_WR;
          end if;

        when E_RUN_WR =>

          if i_wr_ready = '1' then
            v_csv_file.readline(void);
            v_wr_data_valid := '1';
            v_wr_rd_addr    := v_csv_file.read_data_typ_as_std_vec(i_length => v_wr_rd_addr'length, i_data_typ => i_WR_RD_ADDR_TYP);
            v_wr_data       := v_csv_file.read_data_typ_as_std_vec(i_length => v_wr_data'length, i_data_typ => i_WR_DATA_TYP);

            if v_csv_file.end_of_file(void) = true then
              v_wr_finish := '1';
              v_csv_file.dispose(void);
              v_fsm_state := E_WAIT_RD;
            else
              v_wr_finish := '0';
              v_fsm_state := E_RUN_WR;
            end if;
          else

            v_wr_data_valid := '0';
            v_fsm_state     := E_RUN_WR;
          end if;

        when E_WAIT_RD =>

          v_wr_data := (others => '0');

          v_wr_data_valid := '0';
          if i_start_rd = '1' then

            v_csv_file.initialize(i_filepath_rd, i_csv_separator => i_csv_separator);
            -- skip the header
            v_csv_file.readline(void);

            v_rd_data_valid := '0';
            if v_csv_file.end_of_file(void) = true then
              v_rd_finish := '1';
              v_csv_file.dispose(void);
              v_fsm_state := E_END;
            else
              v_rd_finish := '0';
              v_fsm_state := E_RUN_RD0;
            end if;
          else
            v_fsm_state := E_WAIT_RD;
          end if;

        when E_RUN_RD0 =>

          if i_rd_ready = '1' then
            v_csv_file.readline(void);
            v_rd_data_valid := '1';
            v_wr_rd_addr    := v_csv_file.read_data_typ_as_std_vec(i_length => v_wr_rd_addr'length, i_data_typ => i_WR_RD_ADDR_TYP);
            v_rd_data       := v_csv_file.read_data_typ_as_std_vec(i_length => v_rd_data'length, i_data_typ => i_RD_DATA_TYP);
            v_fsm_state     := E_RUN_RD1;
          else

            v_rd_data_valid := '0';
            v_fsm_state     := E_RUN_RD0;
          end if;

        when E_RUN_RD1 =>
          v_rd_data_valid := '0';
          if i_rd_data_valid = '1' then

            if v_rd_data /= i_rd_data_vect then
              v_error(0) := '1';
            else
              v_error(0) := '0';
            end if;
            check_equal(i_data_sb, v_rd_data, i_rd_data_vect,
                        result(i_RD_NAME1 & ", index:" & to_string(v_cnt) & ", (file) : " & to_string(v_rd_data) & ", " &
                               i_RD_NAME1 & " (VHDL) : " & to_string(i_rd_data_vect)));
            v_cnt := v_cnt + 1;
            if v_csv_file.end_of_file(void) = true then
              v_rd_finish := '1';
              v_csv_file.dispose(void);
              v_fsm_state := E_END;
            else
              v_rd_finish := '0';
              v_fsm_state := E_RUN_RD0;
            end if;
          else
            v_fsm_state := E_RUN_RD1;
          end if;

        when E_END =>

          v_wr_data_valid := '0';
          v_rd_data_valid := '0';
          v_wr_finish     := '1';
          v_rd_finish     := '1';
          v_fsm_state     := E_END;

        when others =>
          v_fsm_state := E_RST;

      end case;

      o_wr_data_valid   <= v_wr_data_valid;
      o_wr_rd_addr_vect <= v_wr_rd_addr;
      o_wr_data_vect    <= v_wr_data;

      --
      o_rd_data_valid <= v_rd_data_valid;

      ---------------------------------------------------------------------
      -- status
      ---------------------------------------------------------------------
      o_wr_finish <= v_wr_finish;
      o_rd_finish <= v_rd_finish;
      o_error     <= v_error;

      pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure pkg_memory_wr_tdpram_and_check;

end package body pkg_ram_check;
