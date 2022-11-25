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
--!   @file                   dac_data_insert.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--
-- This module inserts zeros values in the data flow. 
-- Indeed, for each read data/flag from the input FIFO, a zeroed data/flag is inserted.
--
-- Example0: for illustration purpose, we assume no latency between the input and the output ports
-- i_dac_valid |   1   1   1   1   1   1  
-- i_dac_frame |   1   0   0   0   1   0
-- i_dac       |   a0  a1  a2  a3  a4  a5
-- o_dac_valid |   1   1   1   1   1   1   1   1   1   1   1   
-- o_dac_frame |   1   0   0   0   0   0   0   0   1   0   0
-- o_dac       |   a0  0   a1  0   a2  0   a3  0  a4   0   a5
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library fpasim;

entity dac_data_insert is
  generic(
    g_DAC_WIDTH : positive := 16        -- dac bus width (expressed in bits). Possible values [1; max integer value[
  );
  port(
    ---------------------------------------------------------------------
    -- input @i_clk
    ---------------------------------------------------------------------
    i_clk         : in  std_logic;      -- clock signal
    i_rst         : in  std_logic;      -- reset signal
    i_rst_status  : in  std_logic;      -- reset error flag(s)
    i_debug_pulse : in  std_logic;      -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
    i_dac_valid   : in  std_logic;      -- input dac valid  value 
    i_dac_frame   : in  std_logic;      -- first sample of the frame
    i_dac         : in  std_logic_vector(g_DAC_WIDTH - 1 downto 0); -- dac value

    ---------------------------------------------------------------------
    -- output @i_dac_clk
    ---------------------------------------------------------------------
    i_dac_clk     : in  std_logic;      -- dac clock
    i_dac_rst     : in  std_logic;      -- reset signal
    o_dac_valid   : out std_logic;      -- valid dac value
    o_dac_frame   : out std_logic;      -- first sample of a frame
    o_dac         : out std_logic_vector(g_DAC_WIDTH - 1 downto 0); -- dac value

    ---------------------------------------------------------------------
    -- errors/status @i_clk
    ---------------------------------------------------------------------
    o_errors      : out std_logic_vector(15 downto 0); -- output errors
    o_status      : out std_logic_vector(7 downto 0) -- output status
  );
end entity dac_data_insert;

architecture RTL of dac_data_insert is
  ---------------------------------------------------------------------
  -- FIFO
  ---------------------------------------------------------------------
  constant c_IDX0_L : integer := 0;
  constant c_IDX0_H : integer := c_IDX0_L + i_dac'length - 1;

  constant c_IDX1_L : integer := c_IDX0_H + 1;
  constant c_IDX1_H : integer := c_IDX1_L + 1 - 1;

  -- find the power of 2 superior to the g_DELAY
  constant c_FIFO_DEPTH : integer := 16; --see IP
  constant c_FIFO_WIDTH : integer := c_IDX1_H + 1; --see IP

  signal wr_rst_tmp0 : std_logic;
  signal wr_tmp0     : std_logic;
  signal data_tmp0   : std_logic_vector(c_FIFO_WIDTH - 1 downto 0);
  --signal full0        : std_logic;
  --signal wr_rst_busy0 : std_logic;

  signal rd1       : std_logic;
  signal data_tmp1 : std_logic_vector(c_FIFO_WIDTH - 1 downto 0);
  signal empty1    : std_logic;
  --signal rd_rst_busy1 : std_logic;

  -- signal data_valid1 : std_logic;
  signal dac_frame1 : std_logic;
  signal dac1       : std_logic_vector(o_dac'range);

  -- resynchronized errors/status
  signal errors_sync0 : std_logic_vector(3 downto 0);
  signal empty_sync0  : std_logic;

  ---------------------------------------------------------------------
  -- fsm
  ---------------------------------------------------------------------
  type t_state is (E_RST, E_DATA_I, E_DATA_Q);
  signal sm_state      : t_state;
  signal sm_state_next : t_state;

  signal rd_next : std_logic;
  signal rd_r1   : std_logic:= '0';

  signal dac_valid_next : std_logic;
  signal dac_valid_r1   : std_logic:= '0';

  signal dac_frame_next : std_logic;
  signal dac_frame_r1   : std_logic:= '0';

  signal dac_next : std_logic_vector(o_dac'range);
  signal dac_r1   : std_logic_vector(o_dac'range):= (others => '0');

  ---------------------------------------------------------------------
  -- error latching
  ---------------------------------------------------------------------
  constant NB_ERRORS_c : integer := 3;
  signal error_tmp     : std_logic_vector(NB_ERRORS_c - 1 downto 0);
  signal error_tmp_bis : std_logic_vector(NB_ERRORS_c - 1 downto 0);

begin

  ---------------------------------------------------------------------
  -- clock domain crossing
  ---------------------------------------------------------------------
  wr_tmp0                             <= i_dac_valid;
  data_tmp0(c_IDX1_H)                 <= i_dac_frame;
  data_tmp0(c_IDX0_H downto c_IDX0_L) <= i_dac;
  wr_rst_tmp0                         <= i_rst;
  inst_fifo_async_with_error : entity fpasim.fifo_async_with_error
    generic map(
      g_CDC_SYNC_STAGES   => 2,
      g_FIFO_MEMORY_TYPE  => "distributed",
      g_FIFO_READ_LATENCY => 0,
      g_FIFO_WRITE_DEPTH  => c_FIFO_DEPTH,
      g_READ_DATA_WIDTH   => data_tmp0'length,
      g_READ_MODE         => "fwft",
      g_RELATED_CLOCKS    => 0,
      g_WRITE_DATA_WIDTH  => data_tmp0'length,
      ---------------------------------------------------------------------
      -- resynchronization: fifo errors/empty flag
      ---------------------------------------------------------------------
      g_SYNC_SIDE         => "wr"      -- define the clock side where status/errors is resynchronised. Possible value "wr" or "rd"
    )
    port map(
      ---------------------------------------------------------------------
      -- write side
      ---------------------------------------------------------------------
      i_wr_clk        => i_clk,
      i_wr_rst        => wr_rst_tmp0,
      i_wr_en         => wr_tmp0,
      i_wr_din        => data_tmp0,
      o_wr_full       => open,
      o_wr_rst_busy   => open,
      ---------------------------------------------------------------------
      -- read side
      ---------------------------------------------------------------------
      i_rd_clk        => i_dac_clk,
      i_rd_en         => rd1,
      o_rd_dout_valid => open,
      o_rd_dout       => data_tmp1,
      o_rd_empty      => empty1,
      o_rd_rst_busy   => open,
      ---------------------------------------------------------------------
      -- resynchronized errors/status 
      ---------------------------------------------------------------------
      o_errors_sync   => errors_sync0,
      o_empty_sync    => empty_sync0
    );

  rd1 <= '1' when rd_r1 = '1' else '0';

  dac_frame1 <= data_tmp1(c_IDX1_H);
  dac1       <= data_tmp1(c_IDX0_H downto c_IDX0_L);

  ---------------------------------------------------------------------
  -- fsm
  ---------------------------------------------------------------------
  p_decode_state : process(sm_state, empty1, dac1, dac_frame1, dac_r1) is
  begin
    rd_next        <= '0';
    dac_valid_next <= '0';
    dac_frame_next <= '0';
    dac_next       <= dac_r1;
    case sm_state is
      when E_RST =>
        sm_state_next <= E_DATA_I;

      when E_DATA_I =>
        dac_next <= dac1;
        if empty1 = '0' then
          rd_next        <= '1';
          dac_frame_next <= dac_frame1;
          dac_valid_next <= '1';
          sm_state_next  <= E_DATA_Q;
        else
          sm_state_next <= E_DATA_I;
        end if;

      when E_DATA_Q =>
        dac_frame_next <= '0';
        dac_valid_next <= '1';
        dac_next       <= (others => '0');
        sm_state_next  <= E_DATA_I;

      when others =>                    -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
        sm_state_next <= E_RST;
    end case;
  end process p_decode_state;

  p_state : process(i_dac_clk) is
  begin
    if rising_edge(i_dac_clk) then
      if i_dac_rst = '1' then
        sm_state <= E_RST;
      else
        sm_state <= sm_state_next;
      end if;
      rd_r1        <= rd_next;
      dac_valid_r1 <= dac_valid_next;
      dac_frame_r1 <= dac_frame_next;
      dac_r1       <= dac_next;

    end if;
  end process p_state;

  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_dac_valid <= dac_valid_r1;
  o_dac_frame <= dac_frame_r1;
  o_dac       <= dac_r1;

  ---------------------------------------------------------------------
  -- Error latching
  ---------------------------------------------------------------------
  error_tmp(2) <= errors_sync0(2) or errors_sync0(3); -- fifo rst error
  error_tmp(1) <= errors_sync0(1);      -- fifo rd empty error
  error_tmp(0) <= errors_sync0(0);      -- fifo wr full error
  error_flag_mng : for i in error_tmp'range generate
    inst_one_error_latch : entity fpasim.one_error_latch
      port map(
        i_clk         => i_clk,
        i_rst         => i_rst_status,
        i_debug_pulse => i_debug_pulse,
        i_error       => error_tmp(i),
        o_error       => error_tmp_bis(i)
      );
  end generate error_flag_mng;

  o_errors(15 downto 3) <= (others => '0');
  o_errors(2)           <= error_tmp_bis(0); -- fifo rst error
  o_errors(1)           <= error_tmp_bis(2); -- fifo rd empty error
  o_errors(0)           <= error_tmp_bis(1); -- fifo wr full error

  o_status(7 downto 1) <= (others => '0');
  o_status(0)          <= empty_sync0;

  ---------------------------------------------------------------------
  -- for simulation only
  ---------------------------------------------------------------------
  assert not (error_tmp_bis(2) = '1') report "[dac_data_insert] => FIFO is used before the end of the initialization " severity error;
  assert not (error_tmp_bis(1) = '1') report "[dac_data_insert] => FIFO read an empty FIFO" severity error;
  assert not (error_tmp_bis(0) = '1') report "[dac_data_insert] => FIFO write a full FIFO" severity error;



end architecture RTL;
