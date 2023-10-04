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
--    @file                   pulse_generator.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    From an input pulse, this module generates an output pulse with a user-defined pulse width.
--
--    Example0:
--     g_PULSE_DURATION |   3
--     i_pulse_valid     |   1   1   1   1   1   1   1   1   1   1
--     i_pulse           |   1   0   0   0   0   1   0   0   0   0
--     o_pulse_valid     |   x   1   1   1   0   0   1   1   1   0
--     o_pulse           |   x   1   1   1   0   0   1   1   1   0
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_utils;

entity pulse_generator is
  generic(
    g_PULSE_DURATION : positive := 1  -- duration of the pulse. Possible values [1;integer max value[
    );
  port(
    i_clk         : in  std_logic;      -- clock
    i_rst         : in  std_logic;      -- reset
    i_rst_status  : in  std_logic;      -- reset error flag(s)
    i_debug_pulse : in  std_logic;  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
    ---------------------------------------------------------------------
    -- input
    ---------------------------------------------------------------------
    i_pulse_valid : in  std_logic;      -- pulse valid
    i_pulse       : in  std_logic;      -- pulse (1 clock cycle)
    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    o_pulse_valid : out std_logic;      -- output pulse valid
    o_pulse       : out std_logic;      -- output pulse with user-defined width
    ---------------------------------------------------------------------
    -- errors
    ---------------------------------------------------------------------
    o_error       : out std_logic       -- output error
    );
end entity pulse_generator;

architecture RTL of pulse_generator is

  -- width of the clock period counter (expressed in bits)
  constant c_CNT_WIDTH : integer                            := work.pkg_utils.pkg_width_from_value(g_PULSE_DURATION);
  -- value max of the clock period counter
  constant c_CNT_MAX   : unsigned(c_CNT_WIDTH - 1 downto 0) := to_unsigned(g_PULSE_DURATION - 1, c_CNT_WIDTH);

  -- trigger
  signal trig_tmp : std_logic;

  ---------------------------------------------------------------------
  -- fsm
  ---------------------------------------------------------------------
  -- fsm type declaration
  type t_state is (E_RST, E_WAIT, E_RUN);
  signal sm_state_next : t_state;           -- state
  signal sm_state_r1   : t_state := E_RST;  -- state (registered)

  signal data_valid_next : std_logic;         -- data_valid
  signal data_valid_r1   : std_logic := '0';  -- data_valid (registered)

  signal data_next : std_logic;         -- data
  signal data_r1   : std_logic := '0';  -- data (registered)

  -- clock period counter
  signal cnt_next : unsigned(c_CNT_WIDTH - 1 downto 0);
  -- clock period counter (registered)
  signal cnt_r1   : unsigned(c_CNT_WIDTH - 1 downto 0) := (others => '0');

  -- error flag
  signal error_next : std_logic;
  -- error flag (registered)
  signal error_r1   : std_logic := '0';

  ---------------------------------------------------------------------
  -- error latching
  ---------------------------------------------------------------------
  constant c_NB_ERRORS : integer := 1;  -- define the width of the temporary errors signals
  signal error_tmp     : std_logic_vector(c_NB_ERRORS - 1 downto 0);  -- temporary input errors
  signal error_tmp_bis : std_logic_vector(c_NB_ERRORS - 1 downto 0);  -- temporary output errors

begin

  -- valid and flag detection
  trig_tmp <= '1' when i_pulse_valid = '1' and i_pulse = '1' else '0';

  ---------------------------------------------------------------------
  -- fsm
  --   It generate an user-defined pulse width
  ---------------------------------------------------------------------
  p_state_decode : process(cnt_r1, data_r1, sm_state_r1, trig_tmp) is
  begin
    data_valid_next <= '0';
    cnt_next        <= cnt_r1;
    data_next       <= data_r1;
    error_next      <= '0';
    case sm_state_r1 is
      when E_RST =>
        cnt_next      <= (others => '0');
        sm_state_next <= E_WAIT;

      when E_WAIT =>
        if trig_tmp = '1' then
          cnt_next        <= cnt_r1 + 1;
          data_valid_next <= '1';
          data_next       <= '1';
          if c_CNT_MAX = to_unsigned(0, c_CNT_MAX'length) then
            sm_state_next <= E_WAIT;
          else
            sm_state_next <= E_RUN;
          end if;
        else
          cnt_next      <= (others => '0');
          data_next     <= '0';
          sm_state_next <= E_WAIT;
        end if;

      when E_RUN =>
        if trig_tmp = '1' then
          -- error if a trig is detected during the pulse generation
          -- => the pulse width > frame size
          error_next <= '1';
        else
          error_next <= '0';
        end if;
        data_valid_next <= '1';
        if cnt_r1 = c_CNT_MAX then
          cnt_next      <= (others => '0');
          sm_state_next <= E_WAIT;
        else
          cnt_next      <= cnt_r1 + 1;
          sm_state_next <= E_RUN;
        end if;

      when others =>
        sm_state_next <= E_RST;
    end case;
  end process p_state_decode;

  ---------------------------------------------------------------------
  -- State process : register signals
  ---------------------------------------------------------------------
  p_state : process(i_clk) is
  begin
    if rising_edge(i_clk) then
      if i_rst = '1' then
        sm_state_r1 <= E_RST;
      else
        sm_state_r1 <= sm_state_next;
      end if;
      data_valid_r1 <= data_valid_next;
      data_r1       <= data_next;
      cnt_r1        <= cnt_next;
      error_r1      <= error_next;
    end if;
  end process p_state;

  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_pulse_valid <= data_valid_r1;
  o_pulse       <= data_r1;

  ---------------------------------------------------------------------
  -- Error latching
  ---------------------------------------------------------------------
  error_tmp(0) <= error_r1;
  gen_errors_latch : for i in error_tmp'range generate
    inst_one_error_latch : entity work.one_error_latch
      port map(
        i_clk         => i_clk,
        i_rst         => i_rst_status,
        i_debug_pulse => i_debug_pulse,
        i_error       => error_tmp(i),
        o_error       => error_tmp_bis(i)
        );
  end generate gen_errors_latch;

  o_error <= error_tmp_bis(0);

  ---------------------------------------------------------------------
  -- for simulation only
  ---------------------------------------------------------------------
  assert not (error_r1 = '1') report "[pulse_generator] => A new trig is detected during the pulse generation" severity error;

end architecture RTL;
