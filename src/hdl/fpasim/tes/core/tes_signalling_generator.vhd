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
--!   @file                   tes_signalling_generator.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--
-- This module generates flags to tags
--  . the first frame sample
--  . the last frame sample
--  The frame length is defined by the i_length input port
-- And for each frame, an frame id is incremented until the i_id_size - 1 value.
-- Then the frame id rolls back to 0

-- Example0: (length = 4, id_size = 3) with continuous i_data_valid signal
-- data valid | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
-- id         |            0  |          1    |      2        |   0           |
-- sof        | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0 |
-- eof        | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 1 |
--
-- Example1: (length = 4, id_size = 3)  with non-continuous i_data_valid signal
-- data valid | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 |
-- id         |             0                 |          1                    |              2                |           0                   |
-- sof        | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
-- eof        | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 |
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fpasim;

entity tes_signalling_generator is
  generic(
    g_LENGTH_WIDTH : positive := 16;    -- frame bus width (expressed in bits). Possible values: [1; integer max value[
    g_ID_WIDTH     : positive := 11;    -- ID bus width (expressed in bits). . Possible values: [1; integer max value[
    g_LATENCY_OUT  : natural  := 0      -- add output latency. Possible values: [0; integer max value[
  );
  port(
    i_clk        : in  std_logic;       -- clock signal
    i_rst        : in  std_logic;       -- reset signal
    ---------------------------------------------------------------------
    -- Commands
    ---------------------------------------------------------------------
    i_start      : in  std_logic;       -- start the generation (pulse)
    i_length     : in  std_logic_vector(g_LENGTH_WIDTH - 1 downto 0); -- number of samples by frame
    i_id_size    : in  std_logic_vector(g_ID_WIDTH - 1 downto 0); -- max id value

    ---------------------------------------------------------------------
    -- Input data
    ---------------------------------------------------------------------
    i_data_valid : in  std_logic;       -- input valid data

    ---------------------------------------------------------------------
    -- Output data
    ---------------------------------------------------------------------
    o_sof        : out std_logic;       -- first frame sample
    o_eof        : out std_logic;       -- last frame sample
    o_id         : out std_logic_vector(g_ID_WIDTH - 1 downto 0); -- id value
    o_data_valid : out std_logic        -- valid output frame sample

  );
end entity tes_signalling_generator;

architecture RTL of tes_signalling_generator is

  ---------------------------------------------------------------------
  -- state machine
  ---------------------------------------------------------------------
  type t_state is (E_RST, E_WAIT, E_START, E_RUN);
  signal sm_state_next : t_state;
  signal sm_state_r1   : t_state := E_RST;

  signal data_valid_next : std_logic;
  signal data_valid_r1   : std_logic := '0';

  signal sof_next : std_logic;
  signal sof_r1   : std_logic := '0';

  signal eof_next : std_logic;
  signal eof_r1   : std_logic;

  signal cnt_frame_next : unsigned(i_length'range) := (others => '0');
  signal cnt_frame_r1   : unsigned(i_length'range) := (others => '0');

  signal cnt_frame_max_next : unsigned(i_length'range);
  signal cnt_frame_max_r1   : unsigned(i_length'range) := (others => '0');

  signal cnt_id_next : unsigned(i_id_size'range) := (others => '0');
  signal cnt_id_r1   : unsigned(i_id_size'range) := (others => '0');

  ---------------------------------------------------------------------
  -- step2
  ---------------------------------------------------------------------
  constant c_IDX0_L : integer := 0;
  constant c_IDX0_H : integer := c_IDX0_L + i_id_size'length - 1;

  constant c_IDX1_L : integer := c_IDX0_H + 1;
  constant c_IDX1_H : integer := c_IDX1_L + 1 - 1;

  constant c_IDX2_L : integer := c_IDX1_H + 1;
  constant c_IDX2_H : integer := c_IDX2_L + 1 - 1;

  constant c_IDX3_L : integer := c_IDX2_H + 1;
  constant c_IDX3_H : integer := c_IDX3_L + 1 - 1;

  signal data_tmp0 : std_logic_vector(c_IDX3_H downto 0);
  signal data_tmp1 : std_logic_vector(c_IDX3_H downto 0);

  signal data_valid1 : std_logic := '0';
  signal sof1        : std_logic := '0';
  signal eof1        : std_logic := '0';
  signal id1         : std_logic_vector(i_id_size'range);

begin

  p_decode_state : process(i_start, cnt_frame_max_r1, cnt_frame_r1, cnt_id_r1, i_length, i_id_size, i_data_valid, sm_state_r1) is
  begin
    -- default value

    data_valid_next    <= '0';
    sof_next           <= '0';
    eof_next           <= '0';
    cnt_frame_next     <= cnt_frame_r1;
    cnt_frame_max_next <= cnt_frame_max_r1;
    cnt_id_next        <= cnt_id_r1;

    case sm_state_r1 is
      when E_RST =>

        sm_state_next <= E_WAIT;

      when E_WAIT =>
        cnt_id_next <= (others => '1');

        if i_start = '1' then
          sm_state_next <= E_START;
        else
          sm_state_next <= E_WAIT;
        end if;

      when E_START =>

        if i_data_valid = '1' then
          if cnt_id_r1 = unsigned(i_id_size) then
            cnt_id_next <= to_unsigned(0, i_id_size'length);
          else
            cnt_id_next <= cnt_id_r1 + 1;
          end if;
          data_valid_next <= i_data_valid;

          sof_next       <= '1';
          cnt_frame_next <= to_unsigned(0, i_length'length);
          -- special case: frame of one sample
          if unsigned(i_length) = to_unsigned(0, i_length'length) then
            eof_next      <= '1';
            sm_state_next <= E_START;
          else
            cnt_frame_max_next <= unsigned(i_length) - 1; --susbract - 1 to anticipate
            sm_state_next      <= E_RUN;
          end if;
        else
          sm_state_next <= E_START;
        end if;

      when E_RUN =>

        if i_data_valid = '1' then
          data_valid_next <= '1';
          cnt_frame_next  <= cnt_frame_r1 + 1;
          if cnt_frame_r1 = cnt_frame_max_r1 then
            eof_next      <= '1';
            sm_state_next <= E_START;
          else
            sm_state_next <= E_RUN;
          end if;
        else
          data_valid_next <= '0';
          sm_state_next   <= E_RUN;
        end if;

        --when others =>
        --  state_next <= E_RST;
    end case;
  end process p_decode_state;

  p_state_proc : process(i_clk) is
  begin
    if rising_edge(i_clk) then
      if i_rst = '1' then
        sm_state_r1 <= E_RST;
      else
        sm_state_r1 <= sm_state_next;
      end if;
      cnt_frame_r1     <= cnt_frame_next;
      cnt_frame_max_r1 <= cnt_frame_max_next;
      cnt_id_r1        <= cnt_id_next;

      sof_r1        <= sof_next;
      eof_r1        <= eof_next;
      data_valid_r1 <= data_valid_next;

    end if;
  end process p_state_proc;

  ---------------------------------------------------------------------
  -- optionnal: add output latency
  ---------------------------------------------------------------------
  data_tmp0(c_IDX3_H)                 <= sof_r1;
  data_tmp0(c_IDX2_H)                 <= eof_r1;
  data_tmp0(c_IDX1_H)                 <= data_valid_r1;
  data_tmp0(c_IDX0_H downto c_IDX0_L) <= std_logic_vector(cnt_id_r1);

  inst_pipeliner_add_latency : entity fpasim.pipeliner
    generic map(
      g_NB_PIPES   => g_LATENCY_OUT,
      g_DATA_WIDTH => data_tmp0'length
    )
    port map(
      i_clk  => i_clk,
      i_data => data_tmp0,
      o_data => data_tmp1
    );
  sof1        <= data_tmp1(c_IDX3_H);
  eof1        <= data_tmp1(c_IDX2_H);
  data_valid1 <= data_tmp1(c_IDX1_H);
  id1         <= data_tmp1(c_IDX0_H downto c_IDX0_L);

  ---------------------------------------------------------------------
  -- Output
  ---------------------------------------------------------------------
  o_sof        <= sof1;
  o_eof        <= eof1;
  o_data_valid <= data_valid1;
  o_id         <= id1;

end architecture RTL;
