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
--    @file                   recording_dac_word_builder.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This module generate an output data as follows:
--    i_data_valid | 1 | 1 | 1 | 1
--    i_data       | a0   |a1     |a2    |a3     | a4   |a5     |a6    |a7
--    o_data_valid | 0    |1      |0     |1      | 0    |1      |0     |1
--    o_data       | N/A  |a1&a0  |N/A   |a3&a2  | N/A  |a5&a4  |N/A   |a7&a6
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity recording_dac_word_builder is
  port (
    i_rst : in std_logic;               -- input reset
    i_clk : in std_logic;               -- input clock

    ---------------------------------------------------------------------
    -- input
    ---------------------------------------------------------------------
    -- from dac
    i_data_valid : in  std_logic;                      -- data valid
    i_data       : in  std_logic_vector(15 downto 0);  -- data value
    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    o_data_valid : out std_logic;                      -- output data valid
    o_data       : out std_logic_vector(31 downto 0)   -- output data value
    );
end entity recording_dac_word_builder;

architecture RTL of recording_dac_word_builder is

  ---------------------------------------------------------------------
  -- state machine
  ---------------------------------------------------------------------
  -- fsm type declaration
  type t_state is (E_RST, E_DATA0, E_DATA1);
  signal sm_state_next : t_state; -- state
  signal sm_state_r1   : t_state := E_RST;  -- state (registered)

  signal data_valid_next : std_logic; -- data valid
  signal data_valid_r1   : std_logic := '0'; -- data valid (registered)

  signal data1_next : std_logic_vector(i_data'range); -- dac1 data
  signal data1_r1   : std_logic_vector(i_data'range); -- dac1 data (registered)

  signal data0_next : std_logic_vector(i_data'range); -- dac0 data
  signal data0_r1   : std_logic_vector(i_data'range); -- dac0 data (registered)

begin

---------------------------------------------------------------------
-- state machine
--  it demux the input data into 2 output data:
--    . data0
--    . data1
---------------------------------------------------------------------
  p_decode_state : process(data0_r1, data1_r1, i_data, i_data_valid, sm_state_r1) is
  begin
    -- default value
    data_valid_next <= '0';
    data1_next      <= data1_r1;
    data0_next      <= data0_r1;
    case sm_state_r1 is
      when E_RST =>

        sm_state_next <= E_DATA0;

      when E_DATA0 =>

        if i_data_valid = '1' then
          data0_next    <= i_data;
          sm_state_next <= E_DATA1;
        else
          sm_state_next <= E_DATA0;
        end if;

      when E_DATA1 =>

        if i_data_valid = '1' then
          data_valid_next <= '1';
          data1_next      <= i_data;
          data_valid_next <= '1';
          sm_state_next   <= E_DATA0;
        else
          data_valid_next <= '0';
          sm_state_next   <= E_DATA1;
        end if;

      when others =>
        sm_state_next <= E_RST;

    end case;
  end process p_decode_state;

  ---------------------------------------------------------------------
  -- State process : register signals
  ---------------------------------------------------------------------
  p_state_proc : process(i_clk) is
  begin
    if rising_edge(i_clk) then
      if i_rst = '1' then
        sm_state_r1 <= E_RST;
      else
        sm_state_r1 <= sm_state_next;
      end if;
      data_valid_r1 <= data_valid_next;
      data1_r1      <= data1_next;
      data0_r1      <= data0_next;

    end if;
  end process p_state_proc;

---------------------------------------------------------------------
-- output
---------------------------------------------------------------------
  o_data_valid         <= data_valid_r1;
  o_data(31 downto 16) <= data1_r1;
  o_data(15 downto 0)  <= data0_r1;
end architecture RTL;
