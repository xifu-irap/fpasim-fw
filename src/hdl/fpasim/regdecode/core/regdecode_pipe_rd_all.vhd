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
--    @file                   regdecode_pipe_rd_all.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This module multiplexes its 5 inputs into an output FIFO.
--
--
--    The architecture is as follows:
--
--         i_fifo_addr0/i_fifo_data0-------|
--         i_fifo_addr1/i_fifo_data1-------|
--         i_fifo_addr2/i_fifo_data2-------|--- FSM ----->  sync_fifo -----------> o_fifo_data
--         i_fifo_addr3/i_fifo_data3-------|
--         i_fifo_addr4/i_fifo_data4-------|
--
--    Note:
--      . each input path are fully read until the associated eof flags is reached before passing to the next input.
--      . the FSM manages the output data flow via the output fifo flag. So, the output data flow can be paused.
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regdecode_pipe_rd_all is
  generic(
    g_ADDR_WIDTH      : integer := 16;  -- define the address bus width
    g_DATA_WIDTH      : integer := 16  -- define the data bus width
    );
  port(
    i_clk         : in std_logic;       -- clock
    i_rst         : in std_logic;       -- reset
    i_rst_status  : in std_logic;       -- reset error flag(s)
    i_debug_pulse : in std_logic;  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)

    -- input0
    o_fifo_rd0         : out std_logic;  -- fifo read enable
    i_fifo_sof0        : in  std_logic;  -- fifo first sample
    i_fifo_eof0        : in  std_logic;  -- fifo last sample
    i_fifo_data_valid0 : in  std_logic;  -- fifo data valid
    i_fifo_addr0       : in  std_logic_vector(g_ADDR_WIDTH - 1 downto 0);  -- address value
    i_fifo_data0       : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0);  -- data value
    i_fifo_empty0      : in  std_logic;  -- fifo empty flag
    -- input1
    o_fifo_rd1         : out std_logic;  -- fifo read enable
    i_fifo_sof1        : in  std_logic;  -- fifo first sample
    i_fifo_eof1        : in  std_logic;  -- fifo last sample
    i_fifo_data_valid1 : in  std_logic;  -- fifo data valid
    i_fifo_addr1       : in  std_logic_vector(g_ADDR_WIDTH - 1 downto 0);  -- address value
    i_fifo_data1       : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0);  -- data value
    i_fifo_empty1      : in  std_logic;  -- fifo empty flag
    -- input2
    o_fifo_rd2         : out std_logic;  -- fifo read enable
    i_fifo_sof2        : in  std_logic;  -- fifo first sample
    i_fifo_eof2        : in  std_logic;  -- fifo last sample
    i_fifo_data_valid2 : in  std_logic;  -- fifo data valid
    i_fifo_addr2       : in  std_logic_vector(g_ADDR_WIDTH - 1 downto 0);  -- address value
    i_fifo_data2       : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0);  -- data value
    i_fifo_empty2      : in  std_logic;  -- fifo empty flag
    -- input3
    o_fifo_rd3         : out std_logic;  -- fifo read enable
    i_fifo_sof3        : in  std_logic;  -- fifo first sample
    i_fifo_eof3        : in  std_logic;  -- fifo last sample
    i_fifo_data_valid3 : in  std_logic;  -- fifo data valid
    i_fifo_addr3       : in  std_logic_vector(g_ADDR_WIDTH - 1 downto 0);  -- address value
    i_fifo_data3       : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0);  -- data value
    i_fifo_empty3      : in  std_logic;  -- fifo empty flag
    -- input4
    o_fifo_rd4         : out std_logic;  -- fifo read enable
    i_fifo_sof4        : in  std_logic;  -- fifo first sample
    i_fifo_eof4        : in  std_logic;  -- fifo last sample
    i_fifo_data_valid4 : in  std_logic;  -- fifo data valid
    i_fifo_addr4       : in  std_logic_vector(g_ADDR_WIDTH - 1 downto 0);  -- address value
    i_fifo_data4       : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0);  -- data value
    i_fifo_empty4      : in  std_logic;  -- fifo empty flag
    ---------------------------------------------------------------------
    -- to the pipe out: @i_clk
    ---------------------------------------------------------------------
    i_fifo_rd          : in  std_logic;  -- fifo read enable
    o_fifo_sof         : out std_logic;  -- fifo first sample
    o_fifo_eof         : out std_logic;  -- fifo last sample
    o_fifo_data_valid  : out std_logic;  -- fifo data valid
    o_fifo_addr        : out std_logic_vector(g_ADDR_WIDTH - 1 downto 0);  -- address value
    o_fifo_data        : out std_logic_vector(g_DATA_WIDTH - 1 downto 0);  -- data value
    o_fifo_data_count  : out std_logic_vector(15 downto 0);  -- data value
    o_fifo_empty       : out std_logic;  -- fifo empty flag
    ---------------------------------------------------------------------
    -- errors/status @i_clk
    ---------------------------------------------------------------------
    o_errors           : out std_logic_vector(15 downto 0);  -- output errors
    o_status           : out std_logic_vector(7 downto 0)    -- output status
    );
end entity regdecode_pipe_rd_all;

architecture RTL of regdecode_pipe_rd_all is

  ---------------------------------------------------------------------
  -- fsm
  ---------------------------------------------------------------------
  type t_state is (E_RST, E_WAIT, E_RUN0, E_RUN1, E_RUN2, E_RUN3, E_RUN4);
  signal sm_state_next : t_state := E_RST; -- state
  signal sm_state_r1   : t_state := E_RST; -- state (registered)

  -- fifo0: read
  signal rd0_next : std_logic;
  -- signal rd0_r1   : std_logic;

  -- fifo1: read
  signal rd1_next : std_logic;
  -- signal rd1_r1   : std_logic;

  -- fifo2: read
  signal rd2_next : std_logic;
  -- signal rd2_r1   : std_logic;

  -- fifo3: read
  signal rd3_next : std_logic;
  -- signal rd3_r1   : std_logic;

  -- fifo4: read
  signal rd4_next : std_logic;
  -- signal rd4_r1   : std_logic;

  -- select FIFO
  signal sel_next : std_logic_vector(2 downto 0);
  -- select FIFO (registered)
  signal sel_r1   : std_logic_vector(2 downto 0);

  ---------------------------------------------------------------------
  -- select the input path
  ---------------------------------------------------------------------
  signal sof_rx        : std_logic; -- first word
  signal eof_rx        : std_logic; -- last word
  signal data_valid_rx : std_logic; -- data valid
  signal addr_rx       : std_logic_vector(o_fifo_addr'range); -- address
  signal data_rx       : std_logic_vector(o_fifo_data'range); -- data

  ---------------------------------------------------------------------
  -- output FIFO
  ---------------------------------------------------------------------
  constant c_FIFO_IDX0_L : integer := 0; -- index0: low
  constant c_FIFO_IDX0_H : integer := c_FIFO_IDX0_L + o_fifo_data'length - 1; -- index0: high

  constant c_FIFO_IDX1_L : integer := c_FIFO_IDX0_H + 1; -- index1: low
  constant c_FIFO_IDX1_H : integer := c_FIFO_IDX1_L + o_fifo_addr'length - 1; -- index1: high

  constant c_FIFO_IDX2_L : integer := c_FIFO_IDX1_H + 1; -- index2: low
  constant c_FIFO_IDX2_H : integer := c_FIFO_IDX2_L + 1 - 1; -- index2: high

  constant c_FIFO_IDX3_L : integer := c_FIFO_IDX2_H + 1; -- index3: low
  constant c_FIFO_IDX3_H : integer := c_FIFO_IDX3_L + 1 - 1; -- index3: high

  -- FIFO depth (expressed in number of words)
  constant c_FIFO_DEPTH0          : integer := 1024;
  -- FIFO prog_full threshold (expressed in words)
  constant c_PROG_FULL_THRESH0    : integer := c_FIFO_DEPTH0 - 6;
  -- FIFO width (expressed in bits)
  constant c_FIFO_WIDTH0          : integer := c_FIFO_IDX3_H + 1;
  -- FIFO write data count width (expressed in bits)
  constant c_WR_DATA_COUNT_WIDTH0 : integer := work.pkg_utils.pkg_width_from_value(c_FIFO_DEPTH0) + 1;  --see IP

  -- fifo: write side
  -- fifo: write
  signal wr_tmp0        : std_logic;
  -- fifo: data in
  signal data_tmp0      : std_logic_vector(c_FIFO_WIDTH0 - 1 downto 0);
  -- fifo: write data count
  signal wr_data_count0 : std_logic_vector(c_WR_DATA_COUNT_WIDTH0 - 1 downto 0);
  -- fifo: full flag
  -- signal full0        : std_logic;
  -- fifo: prog full flag
  signal prog_full0     : std_logic;
  -- signal wr_rst_busy0 : std_logic;

  -- fifo: read side
  -- fifo: read
  signal rd1         : std_logic;
  -- fifo: data out
  signal data_tmp1   : std_logic_vector(c_FIFO_WIDTH0 - 1 downto 0);
  -- fifo: empty flag
  signal empty1      : std_logic;
  -- fifo: data valid
  signal data_valid1 : std_logic;
  -- fifo: rst busy flag
  -- signal rd_rst_busy1 : std_logic;

  -- first word
  signal fifo_sof1  : std_logic;
  -- last word
  signal fifo_eof1  : std_logic;
  -- address
  signal fifo_addr1 : std_logic_vector(o_fifo_addr'range);
  -- data
  signal fifo_data1 : std_logic_vector(o_fifo_data'range);

  -- resynchronized errors
  signal errors_sync : std_logic_vector(3 downto 0);
  -- resynchronized empty flag
  signal empty_sync  : std_logic;

  ---------------------------------------------------------------------
  -- error latching
  ---------------------------------------------------------------------
  constant c_NB_ERRORS : integer := 3; -- define the width of the temporary errors signals
  signal error_tmp     : std_logic_vector(c_NB_ERRORS - 1 downto 0); -- temporary input errors
  signal error_tmp_bis : std_logic_vector(c_NB_ERRORS - 1 downto 0); -- temporary output errors

begin

  ---------------------------------------------------------------------
  -- This process multiplexes the input FIFOs into an output FIFO in the following order:
  --   . fifo0
  --   . fifo1
  --   . fifo2
  --   . fifo3
  --   . fifo4
  ---------------------------------------------------------------------
  p_decode_state : process(i_fifo_data_valid0, i_fifo_data_valid1, i_fifo_data_valid2, i_fifo_data_valid3, i_fifo_data_valid4,
                          i_fifo_empty0, i_fifo_empty1, i_fifo_empty2, i_fifo_empty3, i_fifo_empty4,
                           i_fifo_eof0, i_fifo_eof1, i_fifo_eof2, i_fifo_eof3, i_fifo_eof4,
                           prog_full0, sel_r1, sm_state_r1) is
  begin
    rd0_next <= '0';
    rd1_next <= '0';
    rd2_next <= '0';
    rd3_next <= '0';
    rd4_next <= '0';
    sel_next <= sel_r1;
    case sm_state_r1 is
      when E_RST =>
        sm_state_next <= E_WAIT;

      when E_WAIT =>
        if i_fifo_empty0 = '0' and prog_full0 = '0' then
          sel_next      <= std_logic_vector(to_unsigned(0, sel_next'length));
          rd0_next      <= '1';
          sm_state_next <= E_RUN0;
        else
          rd0_next      <= '0';
          sm_state_next <= E_WAIT;
        end if;

      when E_RUN0 =>
        if i_fifo_data_valid0 = '1' and i_fifo_eof0 = '1' then
          sel_next      <= std_logic_vector(to_unsigned(1, sel_next'length));
          sm_state_next <= E_RUN1;
        else
          sm_state_next <= E_RUN0;
        end if;

        if i_fifo_empty0 = '0' and prog_full0 = '0' then
          rd0_next <= '1';
        else
          rd0_next <= '0';
        end if;

      when E_RUN1 =>
        if i_fifo_data_valid1 = '1' and i_fifo_eof1 = '1' then
          sel_next      <= std_logic_vector(to_unsigned(2, sel_next'length));
          sm_state_next <= E_RUN2;
        else
          sm_state_next <= E_RUN1;
        end if;

        if i_fifo_empty1 = '0' and prog_full0 = '0' then
          rd1_next <= '1';
        else
          rd1_next <= '0';
        end if;

      when E_RUN2 =>
        if i_fifo_data_valid2 = '1' and i_fifo_eof2 = '1' then
          sel_next      <= std_logic_vector(to_unsigned(3, sel_next'length));
          sm_state_next <= E_RUN3;
        else
          sm_state_next <= E_RUN2;
        end if;

        if i_fifo_empty2 = '0' and prog_full0 = '0' then
          rd2_next <= '1';
        else
          rd2_next <= '0';
        end if;

      when E_RUN3 =>
        if i_fifo_data_valid3 = '1' and i_fifo_eof3 = '1' then
          sel_next      <= std_logic_vector(to_unsigned(4, sel_next'length));
          sm_state_next <= E_RUN4;
        else
          sm_state_next <= E_RUN3;
        end if;

        if i_fifo_empty3 = '0' and prog_full0 = '0' then
          rd3_next <= '1';
        else
          rd3_next <= '0';
        end if;

      when E_RUN4 =>
        if i_fifo_data_valid4 = '1' and i_fifo_eof4 = '1' then
          sm_state_next <= E_WAIT;
        else
          sm_state_next <= E_RUN4;
        end if;

        if i_fifo_empty4 = '0' and prog_full0 = '0' then
          rd4_next <= '1';
        else
          rd4_next <= '0';
        end if;

      when others =>
        sm_state_next <= E_RST;
    end case;
  end process p_decode_state;

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
      -- rd0_r1 <= rd0_next;
      -- rd1_r1 <= rd1_next;
      -- rd2_r1 <= rd2_next;
      -- rd3_r1 <= rd3_next;
      -- rd4_r1 <= rd4_next;
      sel_r1 <= sel_next;
    end if;
  end process p_state;

  -- output
  o_fifo_rd0 <= rd0_next;
  o_fifo_rd1 <= rd1_next;
  o_fifo_rd2 <= rd2_next;
  o_fifo_rd3 <= rd3_next;
  o_fifo_rd4 <= rd4_next;

  ---------------------------------------------------------------------
  -- select the input
  ---------------------------------------------------------------------
  p_select_input : process(i_clk) is
  begin
    if rising_edge(i_clk) then
      case sel_r1 is
        when "000" =>
          sof_rx        <= i_fifo_sof0;
          eof_rx        <= i_fifo_eof0;
          data_valid_rx <= i_fifo_data_valid0;
          addr_rx       <= i_fifo_addr0;
          data_rx       <= i_fifo_data0;
        when "001" =>
          sof_rx        <= i_fifo_sof1;
          eof_rx        <= i_fifo_eof1;
          data_valid_rx <= i_fifo_data_valid1;
          addr_rx       <= i_fifo_addr1;
          data_rx       <= i_fifo_data1;
        when "010" =>
          sof_rx        <= i_fifo_sof2;
          eof_rx        <= i_fifo_eof2;
          data_valid_rx <= i_fifo_data_valid2;
          addr_rx       <= i_fifo_addr2;
          data_rx       <= i_fifo_data2;
        when "011" =>
          sof_rx        <= i_fifo_sof3;
          eof_rx        <= i_fifo_eof3;
          data_valid_rx <= i_fifo_data_valid3;
          addr_rx       <= i_fifo_addr3;
          data_rx       <= i_fifo_data3;
        when "100" =>
          sof_rx        <= i_fifo_sof4;
          eof_rx        <= i_fifo_eof4;
          data_valid_rx <= i_fifo_data_valid4;
          addr_rx       <= i_fifo_addr4;
          data_rx       <= i_fifo_data4;
        when others =>
          sof_rx        <= '0';
          eof_rx        <= '0';
          data_valid_rx <= '0';
          addr_rx       <= addr_rx;
          data_rx       <= data_rx;
      end case;
    end if;
  end process p_select_input;

  ---------------------------------------------------------------------
  -- output FIFO
  -- mandatory: the fifo read enable must arrive one clock cycle before the fifo read data
  ---------------------------------------------------------------------
  wr_tmp0                                       <= data_valid_rx;
  data_tmp0(c_FIFO_IDX3_H)                      <= sof_rx;
  data_tmp0(c_FIFO_IDX2_H)                      <= eof_rx;
  data_tmp0(c_FIFO_IDX1_H downto c_FIFO_IDX1_L) <= addr_rx;
  data_tmp0(c_FIFO_IDX0_H downto c_FIFO_IDX0_L) <= data_rx;

  inst_fifo_sync_with_error_prog_full_wr_count : entity work.fifo_sync_with_error_prog_full_wr_count
    generic map(
      g_FIFO_MEMORY_TYPE    => "auto",
      g_FIFO_READ_LATENCY   => 1,
      g_FIFO_WRITE_DEPTH    => c_FIFO_DEPTH0,
      g_PROG_FULL_THRESH    => c_PROG_FULL_THRESH0,
      g_READ_DATA_WIDTH     => data_tmp0'length,
      g_READ_MODE           => "std",
      g_WRITE_DATA_WIDTH    => data_tmp0'length,
      g_WR_DATA_COUNT_WIDTH => c_WR_DATA_COUNT_WIDTH0
      )
    port map(
      ---------------------------------------------------------------------
      -- write side
      ---------------------------------------------------------------------
      i_wr_clk        => i_clk,
      i_wr_rst        => i_rst,
      i_wr_en         => wr_tmp0,
      i_wr_din        => data_tmp0,
      o_wr_full       => open,
      o_wr_prog_full  => prog_full0,
      o_wr_data_count => wr_data_count0,
      o_wr_rst_busy   => open,
      ---------------------------------------------------------------------
      -- read side
      ---------------------------------------------------------------------
      i_rd_en         => rd1,
      o_rd_dout_valid => data_valid1,
      o_rd_dout       => data_tmp1,
      o_rd_empty      => empty1,
      o_rd_rst_busy   => open,
      ---------------------------------------------------------------------
      --  errors/status
      ---------------------------------------------------------------------
      o_errors_sync   => errors_sync,
      o_empty_sync    => empty_sync
      );
  rd1        <= i_fifo_rd;
  fifo_sof1  <= data_tmp1(c_FIFO_IDX3_H);
  fifo_eof1  <= data_tmp1(c_FIFO_IDX2_H);
  fifo_addr1 <= data_tmp1(c_FIFO_IDX1_H downto c_FIFO_IDX1_L);
  fifo_data1 <= data_tmp1(c_FIFO_IDX0_H downto c_FIFO_IDX0_L);

  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_fifo_sof        <= fifo_sof1;
  o_fifo_eof        <= fifo_eof1;
  o_fifo_data_valid <= data_valid1;
  o_fifo_addr       <= fifo_addr1;
  o_fifo_data       <= fifo_data1;
  o_fifo_empty      <= empty1;
  o_fifo_data_count <= std_logic_vector(resize(unsigned(wr_data_count0), o_fifo_data_count'length));

  ---------------------------------------------------------------------
  -- Error latching
  ---------------------------------------------------------------------
  error_tmp(2) <= errors_sync(2) or errors_sync(3);  -- fifo rst error
  error_tmp(1) <= errors_sync(1);                    -- fifo rd empty error
  error_tmp(0) <= errors_sync(0);                    -- fifo wr full error
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

  o_errors(15 downto 6) <= (others => '0');
  o_errors(5)           <= '0';
  o_errors(4)           <= '0';
  o_errors(3)           <= '0';
  o_errors(2)           <= error_tmp_bis(2);  -- fifo rst error
  o_errors(1)           <= error_tmp_bis(1);  -- fifo rd empty error
  o_errors(0)           <= error_tmp_bis(0);  -- fifo wr full error

  o_status(7 downto 1) <= (others => '0');
  o_status(0)          <= empty_sync;   -- fifo empty

  ---------------------------------------------------------------------
  -- for simulation only
  ---------------------------------------------------------------------
  assert not (error_tmp_bis(2) = '1') report "[regdecode_pipe_rd_all] => fifo is used before the end of the initialization " severity error;
  assert not (error_tmp_bis(1) = '1') report "[regdecode_pipe_rd_all] => fifo read an empty FIFO" severity error;
  assert not (error_tmp_bis(0) = '1') report "[regdecode_pipe_rd_all] => fifo write a full FIFO" severity error;

end architecture RTL;
