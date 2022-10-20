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
--!   @file                   dac_frame_generator.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--
-- This module generates flags to tags
--  . the first frame sample
--  . the last frame sample
-- The frame length is defined by the g_FRAME_SIZE generic parameters
--
--  Example0: continuous data valid signal
--  g_frame_size |                   4                                   |
--  i_data_valid |   1   1   1   1   1   1   1   1   1   1   1   1   0   |   
--  o_sof        |   x   1   0   0   0   1   0   0   0   1   0   0   0   |
--  o_eof        |   x   0   0   0   1   0   0   0   1   0   0   0   1   |  
--  o_data_valid |   x   1   1   1   1   1   1   1   1   1   1   1   1   |
--
--  Example1: non-continuous data valid signal
--  g_frame_size |                   4                                                           |
--  i_data_valid |   1   0   1   0   1   0   1   0   1   0   1   0   1   0   1   0   1    0   1  |   
--  o_sof        |   1   0   0   0   0   0   0   0   1   0   0   0   0   0   0   0   1    0   0  |
--  o_eof        |   0   0   0   0   0   0   1   0   0   0   0   0   0   0   1   0   0    0   0  |  
--  o_data_valid |   1   0   1   0   1   0   1   0   1   0   1   0   1   0   1   0   1    0   1  |
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fpasim;
use fpasim.pkg_utils;

entity dac_frame_generator is
  generic(
    g_FRAME_SIZE : positive := 2        -- frame size. Possible values: [2;integer max value[
  );
  port(
    i_clk        : in  std_logic;       -- clock signal
    i_rst        : in  std_logic;       -- reset signal
    ---------------------------------------------------------------------
    -- input
    ---------------------------------------------------------------------
    i_data_valid : in  std_logic;       -- input valid sample

    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    o_sof        : out std_logic;       -- first sample of the frame
    o_eof        : out std_logic;       -- last sample of the frame
    o_data_valid : out std_logic        -- output valid sample
  );
end entity dac_frame_generator;

architecture RTL of dac_frame_generator is
  constant c_CNT_WIDTH : integer                            := fpasim.pkg_utils.pkg_width_from_value(g_FRAME_SIZE);
  constant c_CNT_MAX   : unsigned(c_CNT_WIDTH - 1 downto 0) := to_unsigned(g_FRAME_SIZE - 1, c_CNT_WIDTH);

  type t_state is (E_RST, E_WAIT, E_RUN);
  signal sm_state      : t_state;
  signal sm_state_next : t_state;

  signal sof_next : std_logic;
  signal sof_r1   : std_logic;

  signal eof_next : std_logic;
  signal eof_r1   : std_logic;

  signal data_valid_next : std_logic;
  signal data_valid_r1   : std_logic;

  signal cnt_next : unsigned(c_CNT_WIDTH - 1 downto 0);
  signal cnt_r1   : unsigned(c_CNT_WIDTH - 1 downto 0);

begin

  -- check generic range
  assert not (g_FRAME_SIZE < 2) report "[dac_frame_generator]: the g_FRAME_SIZE generic port value must be >= 2" severity error;

  -------------------------------------------------------------------
  -- fsm
  -------------------------------------------------------------------
  p_decode_state : process(sm_state, i_data_valid, cnt_r1) is
  begin
    sof_next        <= '0';
    eof_next        <= '0';
    data_valid_next <= '0';
    cnt_next        <= cnt_r1;
    case sm_state is
      when E_RST =>
        cnt_next      <= (others => '0');
        sm_state_next <= E_WAIT;
      when E_WAIT =>
        if i_data_valid = '1' then
          sof_next        <= '1';
          data_valid_next <= i_data_valid;
          cnt_next        <= cnt_r1 + 1;
          sm_state_next   <= E_RUN;
        else
          sm_state_next <= E_WAIT;
        end if;
      when E_RUN =>
        if i_data_valid = '1' then
          data_valid_next <= i_data_valid;
          if cnt_r1 = c_CNT_MAX then
            eof_next      <= '1';
            cnt_next      <= (others => '0');
            sm_state_next <= E_WAIT;
          else
            cnt_next      <= cnt_r1 + 1;
            sm_state_next <= E_RUN;
          end if;
        else
          sm_state_next <= E_RUN;
        end if;

      when others =>                    -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
        sm_state_next <= E_RST;
    end case;
  end process p_decode_state;

  p_state : process(i_clk) is
  begin
    if rising_edge(i_clk) then
      if i_rst = '1' then
        sm_state <= E_RST;
      else
        sm_state <= sm_state_next;
      end if;
      sof_r1        <= sof_next;
      eof_r1        <= eof_next;
      data_valid_r1 <= data_valid_next;
      cnt_r1        <= cnt_next;

    end if;
  end process p_state;

  -------------------------------------------------------------------
  -- output
  -------------------------------------------------------------------
  o_sof        <= sof_r1;
  o_eof        <= eof_r1;
  o_data_valid <= data_valid_r1;
end architecture RTL;
