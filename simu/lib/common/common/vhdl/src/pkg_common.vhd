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
--    @file                   pkg_common.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--    This VHDL package defines commonly used simulaton VHDL functions/procedures.
--
--    Dependencies:
--      . csv_lib.pkg_csv_file
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library csv_lib;
use csv_lib.pkg_csv_file.all;

package pkg_common is

  ------------------------------------------------------
  -- this procedure allows to wait a number of rising edge
  -- then a margin is applied, if any
  ------------------------------------------------------
  procedure pkg_wait_nb_rising_edge_plus_margin(
    signal   i_clk            : in std_logic; -- clock
    constant i_nb_rising_edge : in natural; -- number of clock rising edge to skip
    constant i_margin         : in time -- additional time
  );

  ---------------------------------------------------------------------
  -- This function allows to convert a std_logic signal into an integer
  ---------------------------------------------------------------------
  function pkg_to_integer(s : std_logic) return integer;

  ---------------------------------------------------------------------
  -- This procedure generates a integer random_by_range value
  --  between i_min_value and i_max_value
  ---------------------------------------------------------------------
  procedure pkg_random_by_range(
    constant i_min_value : in integer; -- random min value
    constant i_max_value : in integer; -- random max value
    variable v_seed1     : inout positive; -- random generator: seed1
    variable v_seed2     : inout positive; -- random generator: seed1
    variable v_result    : out integer -- output random value
  );

  ---------------------------------------------------------------------
  -- this function generates an uniform random value between min_value and max_value
  ---------------------------------------------------------------------
  procedure pkg_random_uniform_by_range(
    constant i_min_value : in integer; -- random min value
    constant i_max_value : in integer; -- random max value
    variable v_seed1     : inout positive; -- random generator: seed1
    variable v_seed2     : inout positive; -- random generator: seed1
    variable v_result    : out integer -- output random value
  );

  ---------------------------------------------------------------------
  -- This procedure counts the i_data_valid signal duration (expressed in clock cycles)
  -- Note:
  --   . The last counter bit is used to detect an overflow.
  ---------------------------------------------------------------------
  procedure pkg_data_valid_counter(
    signal i_clk        : in std_logic; -- clock
    -- input
    signal i_start      : in std_logic; -- start the procedure
    signal i_data_valid : in std_logic; -- input data valid
    -- output
    signal o_count      : out std_logic_vector; -- count the number of data valid samples
    signal o_overflow   : out std_logic -- detect if the counter roll back
  );

  ---------------------------------------------------------------------
  -- This procedure counts the i_data_valid signal duration (expressed in clock cycles)
  -- if the i_load is set to '1', then i_load_data is load in the counter
  -- Note:
  --   . The last counter bit is used to detect an overflow.
  ---------------------------------------------------------------------
  procedure pkg_data_valid_counter_with_load(
    signal i_clk        : in std_logic; -- clock
    -- input
    signal i_start      : in std_logic; -- start the procedure
    signal i_data_valid : in std_logic; -- input data valid
    signal i_load       : in std_logic; -- load valid
    signal i_load_data  : in std_logic_vector; -- data to load in the counter
    -- output
    signal o_count      : out std_logic_vector;  -- count the number of data valid samples
    signal o_overflow   : out std_logic -- detect if the counter roll back
  );

  ---------------------------------------------------------------------
  -- frame_flags_builder_file
  -- This function allows allows to generate (sof, eof) flags
  ---------------------------------------------------------------------
  procedure pkg_frame_flags_builder(
    signal i_clk        : in std_logic; -- clock
    signal i_start      : in std_logic; -- start the procedure
    signal i_data_valid : in std_logic; -- input data valid
    i_filepath          : in string; -- input *.csv file
    i_csv_separator     : in character; -- *.csv file separator
    signal o_sof        : out std_logic; -- first data
    signal o_eof        : out std_logic; -- last data
    signal o_index      : out integer;   -- data index
    signal o_finish     : out std_logic -- end of processing: file reading
  );

  ---------------------------------------------------------------------
  -- frame_flags_builder_cst
  -- This function allows allows to generate (sof, eof) flags
  ---------------------------------------------------------------------
  procedure pkg_frame_flags_builder(
    signal i_clk        : in std_logic; -- clock
    signal i_start      : in std_logic; -- start the procedure
    signal i_data_valid : in std_logic; -- input data valid
    constant i_frame_size : in integer; -- maximum number of samples to count before roll back.
    signal o_sof        : out std_logic; -- first data
    signal o_eof        : out std_logic; -- last data
    signal o_index      : out integer;   -- data index
    signal o_finish     : out std_logic -- end of processing
  );

end package pkg_common;

package body pkg_common is

  ------------------------------------------------------
  -- this procedure allows to wait a number of rising edge
  -- then a margin is applied, if any
  ------------------------------------------------------
  procedure pkg_wait_nb_rising_edge_plus_margin(
    signal   i_clk            : in std_logic; -- clock
    constant i_nb_rising_edge : in natural; -- number of clock rising edge to skip
    constant i_margin         : in time -- additional time
  ) is
  begin
    -- Wait for number of rising edges
    --   if the number of rising edges = 0 => only the margin is applied, if any
    if i_nb_rising_edge /= 0 then
      for i in 1 to i_nb_rising_edge loop
        wait until rising_edge(i_clk);
      end loop;
    end if;
    -- Wait for i_margin time, if any
    wait for i_margin;
  end procedure;

  ---------------------------------------------------------------------
  -- This function allows to convert a std_logic signal into an integer
  ---------------------------------------------------------------------
  function pkg_to_integer(s : std_logic) return integer is
  begin
    if s = '1' then
      return 1;
    else
      return 0;
    end if;
  end function;

  ---------------------------------------------------------------------
  -- This procedure generates an integer random value
  --  between i_min_value and i_max_value
  ---------------------------------------------------------------------
  procedure pkg_random_by_range(
    constant i_min_value : in integer; -- random min value
    constant i_max_value : in integer; -- random max value
    variable v_seed1     : inout positive; -- random generator: seed1
    variable v_seed2     : inout positive; -- random generator: seed1
    variable v_result    : out integer -- output random value

  ) is
  begin
    pkg_random_uniform_by_range(i_min_value, i_max_value, v_seed1, v_seed2, v_result);
  end;

  ---------------------------------------------------------------------
  -- this function generates an uniform random value between min_value and max_value
  ---------------------------------------------------------------------
  procedure pkg_random_uniform_by_range(
    constant i_min_value : in integer; -- random min value
    constant i_max_value : in integer; -- random max value
    variable v_seed1     : inout positive; -- random generator: seed1
    variable v_seed2     : inout positive; -- random generator: seed1
    variable v_result    : out integer -- output random value
  ) is
    -- random value
    variable v_rand : real;
  begin
    -- generate a uniform real random_uniform_by_range value between [0;1.0]
    uniform(v_seed1, v_seed2, v_rand);
    -- Scale to a random_uniform_by_range integer between min_value and max_value
    v_result := integer(real(i_min_value) + trunc(v_rand * (1.0 + real(i_max_value) - real(i_min_value))));
  end;

  ---------------------------------------------------------------------
  -- This procedure counts the i_data_valid signal duration (expressed in clock cycles)
  -- Note:
  --   . The last counter bit is used to detect an overflow.
  ---------------------------------------------------------------------
  procedure pkg_data_valid_counter(
    signal i_clk        : in std_logic; -- clock
    -- input
    signal i_start      : in std_logic; -- start the procedure
    signal i_data_valid : in std_logic; -- input data valid
    -- output
    signal o_count      : out std_logic_vector; -- count the number of data valid samples
    signal o_overflow   : out std_logic -- detect if the counter roll back
  ) is
    -- fsm type declaration
    type t_state is (E_RST, E_WAIT, E_RUN);
    -- state
    variable v_fsm_state : t_state := E_RST;
    -- test condition for the infinite loop
    constant c_TEST      : boolean := true;

    -- count the number of valid samples
    variable v_cnt          : unsigned(o_count'high + 1 downto 0) := (others => '0'); -- add 1 to detect an overflow
    -- Last MSB bit value of the counter
    variable v_MSB_bit_last : std_logic                           := '0';
    -- Current MSB bit value of the counter
    variable v_MSB_bit      : std_logic                           := '0';
    -- overflow flag, 1: if the counter reach its max value
    variable v_overflow     : std_logic                           := '0';
  begin
    while c_TEST loop
      case v_fsm_state is
        when E_RST =>

          v_cnt          := (others => '0');
          v_overflow     := '0';
          v_MSB_bit      := '0';
          v_MSB_bit_last := '0';
          v_fsm_state    := E_WAIT;

        when E_WAIT =>
          ---------------------------------------------------------------------
          -- wait to be sure: uvvm object are correctly initialized
          ---------------------------------------------------------------------
          if i_start = '1' then
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>

          if i_data_valid = '1' then
            v_cnt := v_cnt + 1;
          end if;
          --
          v_MSB_bit      := v_cnt(v_cnt'high);
          if v_MSB_bit /= v_MSB_bit_last then
            v_overflow := '1';
          end if;
          v_MSB_bit_last := v_MSB_bit;

          v_fsm_state := E_RUN;

        when others =>
          v_fsm_state := E_RST;
      end case;
      o_overflow <= v_overflow;
      o_count    <= std_logic_vector(v_cnt(o_count'range));

      pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 0 ps);
    end loop;
  end procedure pkg_data_valid_counter;

  ---------------------------------------------------------------------
  -- This procedure counts the i_data_valid signal duration (expressed in clock cycles)
  -- if the i_load is set to '1', then i_load_data is load in the counter
  -- Note:
  --   . The last counter bit is used to detect an overflow.
  ---------------------------------------------------------------------
  procedure pkg_data_valid_counter_with_load(
    signal i_clk        : in std_logic; -- clock
    -- input
    signal i_start      : in std_logic; -- start the procedure
    signal i_data_valid : in std_logic; -- input data valid
    signal i_load       : in std_logic; -- load valid
    signal i_load_data  : in std_logic_vector; -- data to load in the counter
    -- output
    signal o_count      : out std_logic_vector;  -- count the number of data valid samples
    signal o_overflow   : out std_logic -- detect if the counter roll back
  ) is
    -- fsm type declaration
    type t_state is (E_RST, E_WAIT, E_RUN);
    -- state
    variable v_fsm_state : t_state := E_RST;
    -- test condition for the infinite loop
    constant c_TEST      : boolean := true;

    -- count the number of valid samples
    variable v_cnt          : unsigned(o_count'high + 1 downto 0) := (others => '0'); -- add 1 to detect an overflow
    -- Last MSB bit value of the counter
    variable v_MSB_bit_last : std_logic                           := '0';
    -- Current MSB bit value of the counter
    variable v_MSB_bit      : std_logic                           := '0';
    -- overflow flag, 1: if the counter reach its max value
    variable v_overflow     : std_logic                           := '0';
  begin
    while c_TEST loop
      case v_fsm_state is
        when E_RST =>

          v_cnt          := (others => '0');
          v_overflow     := '0';
          v_MSB_bit      := '0';
          v_MSB_bit_last := '0';
          v_fsm_state    := E_WAIT;

        when E_WAIT =>
          ---------------------------------------------------------------------
          -- wait to be sure: uvvm object are correctly initialized
          ---------------------------------------------------------------------
          if i_start = '1' then
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>

          if i_data_valid = '1' then
            if i_load = '1' then
              v_cnt := unsigned(i_load_data);
            else
              v_cnt := v_cnt + 1;
            end if;
          end if;
          --
          v_MSB_bit      := v_cnt(v_cnt'high);
          if v_MSB_bit /= v_MSB_bit_last then
            v_overflow := '1';
          end if;
          v_MSB_bit_last := v_MSB_bit;

          v_fsm_state := E_RUN;

        when others =>
          v_fsm_state := E_RST;
      end case;
      o_overflow <= v_overflow;
      o_count    <= std_logic_vector(v_cnt(o_count'range));

      pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 0 ps);
    end loop;
  end procedure pkg_data_valid_counter_with_load;

  ---------------------------------------------------------------------
  -- frame_flags_builder_file
  -- This function allows allows to generate (sof, eof) flags
  ---------------------------------------------------------------------
  procedure pkg_frame_flags_builder(
    signal i_clk        : in std_logic; -- clock
    signal i_start      : in std_logic; -- start the procedure
    signal i_data_valid : in std_logic; -- input data valid
    i_filepath          : in string; -- input *.csv file
    i_csv_separator     : in character; -- *.csv file separator
    signal o_sof        : out std_logic; -- first data
    signal o_eof        : out std_logic; -- last data
    signal o_index      : out integer;   -- data index
    signal o_finish     : out std_logic -- end of processing: file reading
  ) is
    -- csv object
    variable v_csv_file : t_csv_file_reader;

    -- fsm type declaration
    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    -- state
    variable v_fsm_state : t_state := E_RST;
    -- test condition for the infinite loop
    constant c_TEST      : boolean := true;

    -- count the number of valid samples
    variable v_cnt     : integer   := 0;
    -- max value of the counter
    variable v_cnt_max : integer   := 0;
    -- flag for the first counter value
    variable v_sof     : std_logic := '0';
    -- flag for the last counter value
    variable v_eof     : std_logic := '0';
    -- finish: end of the processing
    variable v_finish  : std_logic := '0';
    -- first iteration flag
    variable v_first   : integer   := 1;
    -- index value (start @0)
    variable v_index   : integer   := 0;

  begin

    while c_TEST loop

      case v_fsm_state is

        when E_RST =>
          v_fsm_state := E_WAIT;

        when E_WAIT =>
          ---------------------------------------------------------------------
          -- wait to be sure: uvvm object are correctly initialized
          ---------------------------------------------------------------------
          if i_start = '1' then
            v_cnt   := 0;
            v_index := 0;
            v_csv_file.initialize(i_filepath, i_csv_separator => i_csv_separator);
            -- skip the header
            v_csv_file.readline(void);

            v_finish := '0';
            if v_csv_file.end_of_file(void) = true then
              v_csv_file.dispose(void);
              v_fsm_state := E_END;
            else
              -- read the first data
              v_csv_file.readline(void);
              v_cnt_max := v_csv_file.read_integer(void);
              if v_csv_file.end_of_file(void) = true then
                -- check if only one value in the file => stop all further reading with the v_first flag
                v_csv_file.dispose(void);
                v_first := 0;
              end if;
              v_fsm_state := E_RUN;
            end if;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>

          if i_data_valid = '1' then
            -- generate sof flag
            if v_cnt = 0 then
              v_sof := '1';
            else
              v_sof := '0';
            end if;

            -- generate eof flag
            if v_cnt = v_cnt_max then
              v_eof := '1';
            else
              v_eof := '0';
            end if;

            v_index := v_cnt;

            if v_cnt = v_cnt_max then
              v_cnt := 0;
              if v_first = 1 then
                -- file is not empty, read a new value
                v_csv_file.readline(void);
                v_cnt_max := v_csv_file.read_integer(void);
                if v_csv_file.end_of_file(void) = true then
                  --- stop all further reading because the file is finished
                  v_csv_file.dispose(void);
                  v_first := 0;
                end if;
              end if;

            else
              v_cnt := v_cnt + 1;
            end if;

            v_fsm_state := E_RUN;
          else
            v_sof       := '0';
            v_eof       := '0';
            v_fsm_state := E_RUN;
          end if;

        when E_END =>

          v_finish    := '1';
          v_fsm_state := E_END;

        when others =>
          v_fsm_state := E_RST;
      end case;

      o_sof    <= v_sof;
      o_eof    <= v_eof;
      o_index  <= v_index;
      o_finish <= v_finish;

      pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure pkg_frame_flags_builder;

  ---------------------------------------------------------------------
  -- frame_flags_builder_cst
  -- This function allows allows to generate (sof, eof) flags
  ---------------------------------------------------------------------
  procedure pkg_frame_flags_builder(
    signal i_clk        : in std_logic; -- clock
    signal i_start      : in std_logic; -- start the procedure
    signal i_data_valid : in std_logic; -- input data valid
    constant i_frame_size : in integer; -- maximum number of samples to count before roll back.
    signal o_sof        : out std_logic; -- first data
    signal o_eof        : out std_logic; -- last data
    signal o_index      : out integer;   -- data index
    signal o_finish     : out std_logic -- end of processing
  ) is

    -- fsm type declaration
    type t_state is (E_RST, E_WAIT, E_RUN, E_END);
    -- state
    variable v_fsm_state : t_state := E_RST;
    -- test condition for the infinite loop
    constant c_TEST      : boolean := true;

    -- count the number of valid samples
    variable v_cnt     : integer   := 0;
    -- max value of the counter
    variable v_cnt_max : integer   := 0;
    -- flag for the first counter value
    variable v_sof     : std_logic := '0';
    -- flag for the last counter value
    variable v_eof     : std_logic := '0';
    -- finish: end of the processing
    variable v_finish  : std_logic := '0';
    -- index value (start @0)
    variable v_index   : integer   := 0;

  begin

    while c_TEST loop

      case v_fsm_state is

        when E_RST =>
          v_fsm_state := E_WAIT;

        when E_WAIT =>
          ---------------------------------------------------------------------
          -- wait to be sure: uvvm object are correctly initialized
          ---------------------------------------------------------------------
          if i_start = '1' then
            v_cnt       := 0;
            v_index     := 0;
            v_cnt_max   := i_frame_size;
            v_finish    := '0';
            v_fsm_state := E_RUN;
          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>

          if i_data_valid = '1' then
            -- generate sof flag
            if v_cnt = 0 then
              v_sof := '1';
            else
              v_sof := '0';
            end if;

            -- generate eof flag
            if v_cnt = v_cnt_max then
              v_eof := '1';
            else
              v_eof := '0';
            end if;

            v_index := v_cnt;

            if v_cnt = v_cnt_max then
              v_cnt := 0;
            else
              v_cnt := v_cnt + 1;
            end if;
            v_fsm_state := E_RUN;
          else
            v_sof       := '0';
            v_eof       := '0';
            v_fsm_state := E_RUN;
          end if;

        when E_END =>

          v_finish    := '1';
          v_fsm_state := E_END;

        when others =>
          v_fsm_state := E_RST;
      end case;

      o_sof    <= v_sof;
      o_eof    <= v_eof;
      o_index  <= v_index;
      o_finish <= v_finish;

      pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure pkg_frame_flags_builder;

end package body pkg_common;
