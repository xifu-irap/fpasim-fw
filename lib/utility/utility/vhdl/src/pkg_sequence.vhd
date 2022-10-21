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
--    @file                   pkg_sequence.vhd 
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


package pkg_sequence is


---------------------------------------------------------------------
-- this function allows to generate a output valid signal from a *.csv configuration file. Several method are
-- implemented
--   .the behaviour is provived by the input file
--   .the file has the following parameters/value
--       :param ctrl: define the mode: Possibles values are:
--               .0: continuous valid generation
--                   . min_value1, max_value1, min_value2, max_value2 values are ignored
--               .1: random short pulse generation
--                   . a positive pulse with a width of 1 clock cycle followed by
--                   . a negative pulse with a random width between min_value2 and max_value2
--               .2. constant short pulse generation
--                   . a positive pulse with a width of 1 clock cycle followed by
--                   . a negative pulse with a constant width defined by the min_value2 value
--               .3. random pulse generation
--                   . a positive pulse with a width defined by a random value between v_min_value1 and v_max_value1 followed by
--                   . a negative pulse with a width defined by a random value between v_min_value2 and max_value2_
--               .4. constant pulse generation
--                   . a positive pulse with a width defined by the v_min_value1 value followed by
--                   . a negative pulse with a width defined by the v_min_value2 value
--               others values : continuous valid generation
--       :param min_value1: define a min value for the positive pulse
--       :param max_value1: define a max value for the positive pulse
--       :param min_value2: define a min value for the negative pulse
--       :param max_value2: define a min value for the negative pulse
--       :param num_rising_edge_before_pulse_gen: define a starting offset before generating pulses
---------------------------------------------------------------------
  procedure valid_sequencer(signal i_clk    : in  std_logic;
                            signal i_en     : in  std_logic;
                            i_filepath      : in  string;
                            i_csv_separator : in  character;
                            signal o_valid : out std_logic
                            );

---------------------------------------------------------------------
-- this function allows to generate a output valid signal from input parameters. Several method are
-- implemented
--   .the parameters/values are:
--       :param ctrl: define the mode: Possibles values are:
--               .0: continuous valid generation
--                   . min_value1, max_value1, min_value2, max_value2 values are ignored
--               .1: random short pulse generation
--                   . a positive pulse with a width of 1 clock cycle followed by
--                   . a negative pulse with a random width between min_value2 and max_value2
--               .2. constant short pulse generation
--                   . a positive pulse with a width of 1 clock cycle followed by
--                   . a negative pulse with a constant width defined by the min_value2 value
--               .3. random pulse generation
--                   . a positive pulse with a width defined by a random value between v_min_value1 and v_max_value1 followed by
--                   . a negative pulse with a width defined by a random value between v_min_value2 and max_value2_
--               .4. constant pulse generation
--                   . a positive pulse with a width defined by the v_min_value1 value followed by
--                   . a negative pulse with a width defined by the v_min_value2 value
--               others values : continuous valid generation
--       :param min_value1: define a min value for the positive pulse
--       :param max_value1: define a max value for the positive pulse
--       :param min_value2: define a min value for the negative pulse
--       :param max_value2: define a min value for the negative pulse
--       :param num_rising_edge_before_pulse_gen: define a starting offset before generating pulses
  procedure valid_sequencer(signal i_clk : in std_logic;
                            signal i_en  : in std_logic;

                            constant i_ctrl                             : in integer := 0;
                            constant i_min_value1                       : in integer := 0;
                            constant i_max_value1                       : in integer := 0;
                            constant i_min_value2                       : in integer := 0;
                            constant i_max_value2                       : in integer := 0;
                            constant i_num_rising_edge_before_pulse_gen : in integer := 0;

                            signal o_valid : out std_logic
                            );


end package pkg_sequence;

package body pkg_sequence is

---------------------------------------------------------------------
-- this function allows to generate a output valid signal from a *.csv configuration file. Several method are
-- implemented
--   .the behaviour is provived by the input file
--   .the file has the following parameters/value
--       :param ctrl: define the mode: Possibles values are:
--               .0: continuous valid generation
--                   . min_value1, max_value1, min_value2, max_value2 values are ignored
--               .1: random short pulse generation
--                   . a positive pulse with a width of 1 clock cycle followed by
--                   . a negative pulse with a random width between min_value2 and max_value2
--               .2. constant short pulse generation
--                   . a positive pulse with a width of 1 clock cycle followed by
--                   . a negative pulse with a constant width defined by the min_value2 value
--               .3. random pulse generation
--                   . a positive pulse with a width defined by a random value between v_min_value1 and v_max_value1 followed by
--                   . a negative pulse with a width defined by a random value between v_min_value2 and max_value2_
--               .4. constant pulse generation
--                   . a positive pulse with a width defined by the v_min_value1 value followed by
--                   . a negative pulse with a width defined by the v_min_value2 value
--               others values : continuous valid generation
--       :param min_value1: define a min value for the positive pulse
--       :param max_value1: define a max value for the positive pulse
--       :param min_value2: define a min value for the negative pulse
--       :param max_value2: define a min value for the negative pulse
--       :param num_rising_edge_before_pulse_gen: define a starting offset before generating pulses
---------------------------------------------------------------------
  procedure valid_sequencer(signal i_clk    : in  std_logic;
                            signal i_en     : in  std_logic;
                            i_filepath      : in  string;
                            i_csv_separator : in  character;
                            signal o_valid : out std_logic
                            ) is
    type t_state is (E_RST, E_WAIT, E_RUN, E_TEMPO_NEG, E_TEMPO_POS);
    variable v_fsm_state    : t_state := E_RST;
    constant c_TEST     : boolean   := true;
    variable v_csv_file : t_csv_file_reader;

    variable v_ctrl : integer := 0;

    variable v_min_value1 : integer := 0;
    variable v_max_value1 : integer := 0;

    variable v_min_value2 : integer := 0;
    variable v_max_value2 : integer := 0;

    variable v_num_rising_edge_before_pulse_gen : integer := 0;

    variable v_tempo_pos : integer   := 0;
    variable v_tempo_neg : integer   := 0;
    variable v_valid     : std_logic := '0';

    variable v_cnt_tempo : integer := 0;

  begin
    while c_TEST loop
      case v_fsm_state is
        when E_RST =>

          v_valid := '0';
          v_fsm_state := E_WAIT;

        when E_WAIT =>
          ---------------------------------------------------------------------
          -- wait to be sure: uvvm object are correctly initialized
          ---------------------------------------------------------------------
          if i_en = '1' then
            v_csv_file.initialize(i_filepath, csv_separator => i_csv_separator);
            -- skip the header
            v_csv_file.readline;

            -- read first line
            v_csv_file.readline;
            -- get the ctrl mode
            v_ctrl                             := v_csv_file.read_integer;
            -- get the min value1
            v_min_value1                       := v_csv_file.read_integer;
            -- get the max value 1
            v_max_value1                       := v_csv_file.read_integer;
            -- get the min value2
            v_min_value2                       := v_csv_file.read_integer;
            -- get the max value2
            v_max_value2                       := v_csv_file.read_integer;
            -- get the v_num_rising_edge_before_pulse_gen
            v_num_rising_edge_before_pulse_gen := v_csv_file.read_integer;

            if v_num_rising_edge_before_pulse_gen < 0 then
              v_fsm_state := E_RUN;
            else
              v_tempo_neg := v_num_rising_edge_before_pulse_gen;
              v_fsm_state     := E_TEMPO_NEG;
            end if;

          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>

          case v_ctrl is
            when 0 =>
              -- continuous pulse signal (infinite width)
              v_valid := '1';
              v_fsm_state := E_RUN;
            when 1 =>
              -- random short pulse : 
              --   a positive pulse with a width of 1 clock cycle followed by
              --   a negative pulse with a random width between the min_value2 value and the max_value2 value
              v_valid     := '1';
              v_cnt_tempo := 1;
              v_tempo_neg := pkg_random_by_range(v_min_value2, v_max_value2);
              v_fsm_state     := E_TEMPO_NEG;
            when 2 =>
              -- constant short pulse:
              --   a positive pulse with a width of 1 clock cycle followed by
              --   a negative pulse with a constant width defined by the min_value2 value
              v_valid     := '1';
              v_cnt_tempo := 1;
              v_tempo_neg := v_min_value2;
              v_fsm_state     := E_TEMPO_NEG;

            when 3 =>
              -- random pulse : random pulse 
              --   a positive pulse with a width defined by a random value between v_min_value1 and v_max_value1 followed by
              --   a negative pulse with a width defined by a random value between v_min_value2 and v_max_value2
              v_valid     := '1';
              v_tempo_pos := pkg_random_by_range(v_min_value1, v_max_value1);
              v_tempo_neg := pkg_random_by_range(v_min_value2, v_max_value2);
              v_fsm_state     := E_TEMPO_POS;

            when 4 =>
              -- constant pulse
              --  a positive pulse with a width defined by the v_min_value1 value followed by
              --  a negative pulse with a width defined by the v_min_value2 value
              v_valid     := '1';
              v_tempo_pos := v_min_value1;
              v_tempo_neg := v_min_value2;
              v_fsm_state     := E_TEMPO_POS;

            when others =>
              -- continuous valid
              v_valid := '1';
              v_fsm_state := E_RUN;
          end case;


        when E_TEMPO_NEG =>
          v_valid := '0';
          if v_cnt_tempo = v_tempo_neg then
            v_cnt_tempo := 1;
            v_fsm_state     := E_RUN;
          else
            v_cnt_tempo := v_cnt_tempo + 1;
            v_fsm_state     := E_TEMPO_NEG;
          end if;

        when E_TEMPO_POS =>
          v_valid := '1';
          if v_cnt_tempo = v_tempo_pos then
            v_cnt_tempo := 1;
            v_fsm_state     := E_TEMPO_NEG;
          else
            v_cnt_tempo := v_cnt_tempo + 1;
            v_fsm_state     := E_TEMPO_POS;
          end if;

        when others => -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;

      o_valid <= v_valid;

      wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 0 ps);
    end loop;
  end procedure valid_sequencer;

---------------------------------------------------------------------
-- this function allows to generate a output valid signal from input parameters. Several method are
-- implemented
--   .the parameters/values are:
--       :param ctrl: define the mode: Possibles values are:
--               .0: continuous valid generation
--                   . min_value1, max_value1, min_value2, max_value2 values are ignored
--               .1: random short pulse generation
--                   . a positive pulse with a width of 1 clock cycle followed by
--                   . a negative pulse with a random width between min_value2 and max_value2
--               .2. constant short pulse generation
--                   . a positive pulse with a width of 1 clock cycle followed by
--                   . a negative pulse with a constant width defined by the min_value2 value
--               .3. random pulse generation
--                   . a positive pulse with a width defined by a random value between v_min_value1 and v_max_value1 followed by
--                   . a negative pulse with a width defined by a random value between v_min_value2 and max_value2_
--               .4. constant pulse  generation
--                   . a positive pulse with a width defined by the v_min_value1 value followed by
--                   . a negative pulse with a width defined by the v_min_value2 value
--               others values : continuous valid generation
--       :param min_value1: define a min value for the positive pulse
--       :param max_value1: define a max value for the positive pulse
--       :param min_value2: define a min value for the negative pulse
--       :param max_value2: define a min value for the negative pulse
--       :param num_rising_edge_before_pulse_gen: define a starting offset before generating pulses
---------------------------------------------------------------------
  procedure valid_sequencer(signal i_clk : in std_logic;
                            signal i_en  : in std_logic;

                            constant i_ctrl                             : in integer := 0;
                            constant i_min_value1                       : in integer := 0;
                            constant i_max_value1                       : in integer := 0;
                            constant i_min_value2                       : in integer := 0;
                            constant i_max_value2                       : in integer := 0;
                            constant i_num_rising_edge_before_pulse_gen : in integer := 0;

                            signal o_valid : out std_logic
                            ) is
    type t_state is (E_RST, E_WAIT, E_RUN, E_TEMPO_NEG, E_TEMPO_POS);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST  : boolean   := true;


    variable v_ctrl : integer := 0;

    variable v_min_value1 : integer := 0;
    variable v_max_value1 : integer := 0;

    variable v_min_value2 : integer := 0;
    variable v_max_value2 : integer := 0;

    variable v_num_rising_edge_before_pulse_gen : integer := 0;

    variable v_tempo_pos : integer   := 0;
    variable v_tempo_neg : integer   := 0;
    variable v_valid     : std_logic := '0';

    variable v_cnt_tempo : integer := 0;

  begin
    while c_TEST loop
      case v_fsm_state is
        when E_RST =>

          v_valid := '0';
          v_fsm_state := E_WAIT;

        when E_WAIT =>
          ---------------------------------------------------------------------
          -- wait to be sure: uvvm object are correctly initialized
          ---------------------------------------------------------------------
          if i_en = '1' then

            -- get the ctrl mode
            v_ctrl                             := i_ctrl;
            -- get the min value1
            v_min_value1                       := i_min_value1;
            -- get the max value 1
            v_max_value1                       := i_max_value1;
            -- get the min value2
            v_min_value2                       := i_min_value2;
            -- get the max value2
            v_max_value2                       := i_max_value2;
            -- get the v_num_rising_edge_before_pulse_gen
            v_num_rising_edge_before_pulse_gen := i_num_rising_edge_before_pulse_gen;

            if v_num_rising_edge_before_pulse_gen < 0 then
              v_fsm_state := E_RUN;
            else
              v_tempo_neg := v_num_rising_edge_before_pulse_gen;
              v_fsm_state     := E_TEMPO_NEG;
            end if;

          else
            v_fsm_state := E_WAIT;
          end if;

        when E_RUN =>

          case v_ctrl is
            when 0 =>
              -- continuous pulse signal (infinite width)
              v_valid := '1';
              v_fsm_state := E_RUN;
            when 1 =>
              -- random short pulse : 
              --   a positive pulse with a width of 1 clock cycle followed by
              --   a negative pulse with a random width between the min_value2 value and the max_value2 value
              v_valid     := '1';
              v_cnt_tempo := 0;
              v_tempo_neg := pkg_random_by_range(v_min_value2, v_max_value2);
              v_fsm_state     := E_TEMPO_NEG;
            when 2 =>
              -- constant short pulse:
              --   a positive pulse with a width of 1 clock cycle followed by
              --   a negative pulse with a constant width defined by the min_value2 value
              v_valid     := '1';
              v_cnt_tempo := 0;
              v_tempo_neg := v_min_value2;
              v_fsm_state     := E_TEMPO_NEG;

            when 3 =>
              -- random pulse : random pulse 
              --   a positive pulse with a width defined by a random value between v_min_value1 and v_max_value1 followed by
              --   a negative pulse with a width defined by a random value between v_min_value2 and v_max_value2
              v_valid     := '1';
              v_tempo_pos := pkg_random_by_range(v_min_value1, v_max_value1);
              v_tempo_neg := pkg_random_by_range(v_min_value2, v_max_value2);
              v_fsm_state     := E_TEMPO_POS;

            when 4 =>
              -- constant pulse
              --  a positive pulse with a width defined by the v_min_value1 value followed by
              --  a negative pulse with a width defined by the v_min_value2 value
              v_valid     := '1';
              v_tempo_pos := v_min_value1;
              v_tempo_neg := v_min_value2;
              v_fsm_state     := E_TEMPO_POS;

            when others =>
              -- continuous valid
              v_valid := '1';
              v_fsm_state := E_RUN;
          end case;


        when E_TEMPO_NEG =>
          v_valid := '0';
          if v_cnt_tempo = v_tempo_neg then
            v_cnt_tempo := 0;
            v_fsm_state     := E_RUN;
          else
            v_cnt_tempo := v_cnt_tempo + 1;
            v_fsm_state     := E_TEMPO_NEG;
          end if;

        when E_TEMPO_POS =>
          v_valid := '1';
          if v_cnt_tempo = v_tempo_pos then
            v_cnt_tempo := 0;
            v_fsm_state     := E_TEMPO_NEG;
          else
            v_cnt_tempo := v_cnt_tempo + 1;
            v_fsm_state     := E_TEMPO_POS;
          end if;

        when others => -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;
      end case;

      o_valid <= v_valid;

      wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 0 ps);
    end loop;
  end procedure valid_sequencer;





end package body pkg_sequence;
