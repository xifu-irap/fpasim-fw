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
--!   @file                   regdecode_wire_make_pulse.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
-- This module is used to drive a RAM. 2 modes are available according the value of the i_start_auto_rd and i_data_valid signals.
--   . to configure the RAM content
--   . to auto-generate the read address in order to read the RAM content
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fpasim;

entity regdecode_wire_make_pulse is
  generic(
    g_DATA_WIDTH_OUT : positive := 15   -- define the RAM address width
  );
  port(
    ---------------------------------------------------------------------
    -- from the regdecode: input @i_clk
    ---------------------------------------------------------------------
    i_clk              : in  std_logic; -- clock
    i_rst              : in  std_logic; -- reset
    -- conf
    i_pixel_nb         : in  std_logic_vector(5 downto 0); -- number of pixels. Possibles values: [0,63]
    -- data
    i_data_valid       : in  std_logic; -- data valid
    i_data             : in  std_logic_vector(g_DATA_WIDTH_OUT - 1 downto 0); -- data value
    ---------------------------------------------------------------------
    -- from/to the user:  @i_out_clk
    ---------------------------------------------------------------------
    i_out_clk          : in  std_logic; -- output clock
    i_rst_status       : in  std_logic; -- reset error flag(s)
    i_debug_pulse      : in  std_logic; -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
    -- extracted command
    o_cmd_sof          : out std_logic;
    o_cmd_eof          : out std_logic;
    o_cmd_data_valid   : out std_logic; -- data valid
    o_cmd_pixel_id     : out std_logic_vector(5 downto 0); -- output pixel id
    o_cmd_time_shift   : out std_logic_vector(3 downto 0); -- output time shift
    o_cmd_pulse_heigth : out std_logic_vector(10 downto 0); -- output pulse heigth
    ---------------------------------------------------------------------
    -- to the regdecode: @i_clk
    ---------------------------------------------------------------------
    o_data_valid       : out std_logic; -- fifo data valid
    o_data             : out std_logic_vector(g_DATA_WIDTH_OUT - 1 downto 0); -- fifo data
    ---------------------------------------------------------------------
    -- errors/status @ i_out_clk
    ---------------------------------------------------------------------
    o_errors           : out std_logic_vector(15 downto 0); -- output errors
    o_status           : out std_logic_vector(7 downto 0) -- output status
  );
end entity regdecode_wire_make_pulse;

architecture RTL of regdecode_wire_make_pulse is
  constant c_PIXEL_ALL_IDX      : integer := 31;
  constant c_PIXEL_ID_IDX_H     : integer := 29;
  constant c_PIXEL_ID_IDX_L     : integer := 24;
  constant c_TIME_SHIFT_IDX_H   : integer := 19;
  constant c_TIME_SHIFT_IDX_L   : integer := 16;
  constant c_PULSE_HEIGHT_IDX_H : integer := 10;
  constant c_PULSE_HEIGHT_IDX_L : integer := 0;

  ---------------------------------------------------------------------
  -- fsm
  ---------------------------------------------------------------------
  signal pixel_all_tmp    : std_logic;
  signal pixel_id_tmp     : std_logic_vector(o_cmd_pixel_id'range);
  signal time_shift_tmp   : std_logic_vector(o_cmd_time_shift'range);
  signal pulse_heigth_tmp : std_logic_vector(o_cmd_pulse_heigth'range);

  type t_state is (E_RST, E_WAIT, E_GEN_PIXEL_ID);
  signal sm_state_next : t_state := E_RST;
  signal sm_state_r1   : t_state := E_RST;

  signal sof_next : std_logic;
  signal sof_r1   : std_logic;

  signal eof_next : std_logic;
  signal eof_r1   : std_logic;

  signal data_valid_next : std_logic;
  signal data_valid_r1   : std_logic;

  signal error_next : std_logic;
  signal error_r1   : std_logic;

  signal pixel_id_next : unsigned(o_cmd_pixel_id'range);
  signal pixel_id_r1   : unsigned(o_cmd_pixel_id'range);

  signal pixel_id_max_next : unsigned(o_cmd_pixel_id'range);
  signal pixel_id_max_r1   : unsigned(o_cmd_pixel_id'range);

  signal time_shift_r1   : std_logic_vector(o_cmd_time_shift'range);
  signal pulse_heigth_r1 : std_logic_vector(o_cmd_pulse_heigth'range);

  ---------------------------------------------------------------------
  -- FIFO
  ---------------------------------------------------------------------
  constant c_IDX0_L : integer := 0;
  constant c_IDX0_H : integer := c_IDX0_L + o_cmd_pulse_heigth'length - 1;

  constant c_IDX1_L : integer := c_IDX0_H + 1;
  constant c_IDX1_H : integer := c_IDX1_L + o_cmd_time_shift'length - 1;

  constant c_IDX2_L : integer := c_IDX1_H + 1;
  constant c_IDX2_H : integer := c_IDX2_L + o_cmd_pixel_id'length - 1;

  constant c_IDX3_L : integer := c_IDX2_H + 1;
  constant c_IDX3_H : integer := c_IDX3_L + 1 - 1;

  constant c_IDX4_L : integer := c_IDX3_H + 1;
  constant c_IDX4_H : integer := c_IDX4_L + 1 - 1;

  constant c_FIFO_DEPTH0 : integer := 16; --see IP
  constant c_FIFO_WIDTH0 : integer := c_IDX4_H + 1; --see IP

  signal wr_rst_tmp0 : std_logic;
  signal wr_tmp0     : std_logic;
  signal data_tmp0   : std_logic_vector(c_FIFO_WIDTH0 - 1 downto 0);
  --signal full0        : std_logic;
  --signal wr_rst_busy0 : std_logic;

  signal rd1       : std_logic;
  signal data_tmp1 : std_logic_vector(c_FIFO_WIDTH0 - 1 downto 0);
  signal empty1    : std_logic;
  --signal rd_rst_busy1 : std_logic;

  signal data_valid_tmp1 : std_logic;

  signal errors_sync1 : std_logic_vector(3 downto 0);
  signal empty_sync1  : std_logic;

  ---------------------------------------------------------------------
  -- copy the input data
  ---------------------------------------------------------------------
  signal data_valid_copy_r1 : std_logic;
  signal data_copy_r1       : std_logic_vector(i_data'range);

  ---------------------------------------------------------------------
  -- error latching
  ---------------------------------------------------------------------
  constant NB_ERRORS_c : integer := 3;
  signal error_tmp     : std_logic_vector(NB_ERRORS_c - 1 downto 0);
  signal error_tmp_bis : std_logic_vector(NB_ERRORS_c - 1 downto 0);

begin

  pixel_all_tmp    <= i_data(c_PIXEL_ALL_IDX);
  pixel_id_tmp     <= i_data(c_PIXEL_ID_IDX_H downto c_PIXEL_ID_IDX_L);
  time_shift_tmp   <= i_data(c_TIME_SHIFT_IDX_H downto c_TIME_SHIFT_IDX_L);
  pulse_heigth_tmp <= i_data(c_PULSE_HEIGHT_IDX_H downto c_PULSE_HEIGHT_IDX_L);

  ---------------------------------------------------------------------
  -- fsm
  ---------------------------------------------------------------------
  p_decode_state : process(i_data_valid, i_pixel_nb, pixel_all_tmp, pixel_id_tmp, pixel_id_max_r1, pixel_id_r1, sm_state_r1) is
  begin
    sof_next          <= '0';
    eof_next          <= '0';
    data_valid_next   <= '0';
    pixel_id_max_next <= pixel_id_max_r1;
    pixel_id_next     <= pixel_id_r1;

    case sm_state_r1 is
      when E_RST =>
        sm_state_next <= E_WAIT;

      when E_WAIT =>
        if i_data_valid = '1' then
          data_valid_next   <= '1';
          pixel_id_max_next <= unsigned(i_pixel_nb) - 1;

          if pixel_all_tmp = '1' then
            sof_next      <= '1';
            pixel_id_next <= (others => '0');
            if unsigned(i_pixel_nb) = to_unsigned(0, i_pixel_nb'length) then
              -- special case: one pixel
              eof_next      <= '1';
              sm_state_next <= E_WAIT;
            else
              -- more than one pixel
              eof_next      <= '0';
              sm_state_next <= E_GEN_PIXEL_ID;
            end if;
          else
            pixel_id_next <= unsigned(pixel_id_tmp);
            sof_next      <= '1';
            eof_next      <= '1';
            sm_state_next <= E_WAIT;
          end if;
        else
          sm_state_next <= E_WAIT;
        end if;
      when E_GEN_PIXEL_ID =>

        if i_data_valid = '1' then
          error_next <= '1';
        else
          error_next <= '0';
        end if;
        pixel_id_next   <= pixel_id_r1 + 1;
        data_valid_next <= '1';
        if pixel_id_max_r1 = pixel_id_r1 then
          eof_next      <= '1';
          sm_state_next <= E_WAIT;
        else
          sm_state_next <= E_GEN_PIXEL_ID;
        end if;
      when others =>                    -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
        sm_state_next <= E_RST;
    end case;
  end process p_decode_state;

  p_state : process(i_clk) is
  begin
    if rising_edge(i_clk) then
      if i_rst = '1' then
        sm_state_r1 <= E_RST;
      else
        sm_state_r1 <= sm_state_next;
      end if;
      sof_r1          <= sof_next;
      eof_r1          <= eof_next;
      data_valid_r1   <= data_valid_next;
      pixel_id_r1     <= pixel_id_next;
      error_r1        <= error_next;
      pixel_id_max_r1 <= pixel_id_max_next;

    end if;
  end process p_state;

  ---------------------------------------------------------------------
  -- sync with fsm out
  ---------------------------------------------------------------------
  p_sync_with_fsm_out : process(i_clk) is
  begin
    if rising_edge(i_clk) then
      time_shift_r1   <= time_shift_tmp;
      pulse_heigth_r1 <= pulse_heigth_tmp;
    end if;
  end process p_sync_with_fsm_out;

  ---------------------------------------------------------------------
  -- clock domain crossing
  -- note: the "pixel all" bit is not copied
  ---------------------------------------------------------------------
  wr_tmp0                             <= data_valid_r1;
  data_tmp0(c_IDX4_H)                 <= sof_r1;
  data_tmp0(c_IDX3_H)                 <= eof_r1;
  data_tmp0(c_IDX2_H downto c_IDX2_L) <= std_logic_vector(pixel_id_r1);
  data_tmp0(c_IDX1_H downto c_IDX1_L) <= time_shift_r1;
  data_tmp0(c_IDX0_H downto c_IDX0_L) <= pulse_heigth_r1;
  wr_rst_tmp0                         <= i_rst;

  inst_fifo_async_with_error : entity fpasim.fifo_async_with_error
    generic map(
      g_CDC_SYNC_STAGES   => 2,
      g_FIFO_MEMORY_TYPE  => "auto",
      g_FIFO_READ_LATENCY => 1,
      g_FIFO_WRITE_DEPTH  => c_FIFO_DEPTH0,
      g_READ_DATA_WIDTH   => data_tmp0'length,
      g_READ_MODE         => "std",
      g_RELATED_CLOCKS    => 0,
      g_WRITE_DATA_WIDTH  => data_tmp0'length,
      ---------------------------------------------------------------------
      -- resynchronization: fifo errors/empty flag
      ---------------------------------------------------------------------
      g_SYNC_SIDE         => "rd",      -- define the clock side where status/errors is resynchronised. Possible value "wr" or "rd"
      g_DEST_SYNC_FF      => 2,         -- Number of register stages used to synchronize signal in the destination clock domain.   
      g_SRC_INPUT_REG     => 1          -- 0- Do not register input (src_in), 1- Register input (src_in) once using src_clk 

    )
    port map(
      ---------------------------------------------------------------------
      -- write side
      ---------------------------------------------------------------------
      i_wr_clk        => i_clk,
      i_wr_rst        => wr_rst_tmp0,
      i_wr_en         => wr_tmp0,
      i_wr_din        => data_tmp0,
      o_wr_full       => open,          -- not connected
      o_wr_rst_busy   => open,          -- not connected
      ---------------------------------------------------------------------
      -- read side
      ---------------------------------------------------------------------
      i_rd_clk        => i_out_clk,
      i_rd_en         => rd1,
      o_rd_dout_valid => data_valid_tmp1,
      o_rd_dout       => data_tmp1,
      o_rd_empty      => empty1,
      o_rd_rst_busy   => open,          -- not connected
      ---------------------------------------------------------------------
      -- resynchronized errors/status 
      ---------------------------------------------------------------------
      o_errors_sync   => errors_sync1,
      o_empty_sync    => empty_sync1
    );

  rd1 <= '1' when empty1 = '0' else '0';

  ---------------------------------------------------------------------
  -- output
  -- Note: the "pixel all" bit is not output
  ---------------------------------------------------------------------
  o_cmd_data_valid   <= data_valid_tmp1;
  o_cmd_eof          <= data_tmp1(c_IDX4_H);
  o_cmd_sof          <= data_tmp1(c_IDX3_H);
  o_cmd_pixel_id     <= data_tmp1(c_IDX2_H downto c_IDX2_L);
  o_cmd_time_shift   <= data_tmp1(c_IDX1_H downto c_IDX1_L);
  o_cmd_pulse_heigth <= data_tmp1(c_IDX0_H downto c_IDX0_L);

  ---------------------------------------------------------------------
  -- copy the input data
  ---------------------------------------------------------------------
  p_copy_input_data : process(i_clk) is
  begin
    if rising_edge(i_clk) then
      data_valid_copy_r1 <= i_data_valid;
      if i_data_valid = '1' then
        data_copy_r1 <= i_data;
      end if;
    end if;
  end process p_copy_input_data;
  o_data_valid <= data_valid_copy_r1;
  o_data       <= data_copy_r1;

  ---------------------------------------------------------------------
  -- Error latching
  ---------------------------------------------------------------------
  error_tmp(2) <= errors_sync1(2) or errors_sync1(3); -- fifo rst error
  error_tmp(1) <= errors_sync1(1);      -- fifo rd empty error
  error_tmp(0) <= errors_sync1(0);      -- fifo wr full error
  gen_errors_latch : for i in error_tmp'range generate
    inst_one_error_latch : entity fpasim.one_error_latch
      port map(
        i_clk         => i_clk,
        i_rst         => i_rst_status,
        i_debug_pulse => i_debug_pulse,
        i_error       => error_tmp(i),
        o_error       => error_tmp_bis(i)
      );
  end generate gen_errors_latch;

  o_errors(15 downto 3) <= (others => '0');
  o_errors(2)           <= error_tmp_bis(2); -- fifo rst error
  o_errors(1)           <= error_tmp_bis(1); -- fifo rd empty error
  o_errors(0)           <= error_tmp_bis(0); -- fifo wr full error

  o_status(7 downto 1) <= (others => '0');
  o_status(0)          <= empty_sync1;

  ---------------------------------------------------------------------
  -- for simulation only
  ---------------------------------------------------------------------
  assert not (error_tmp_bis(2) = '1') report "[regdecode_wire_make_pulse] => FIFO is used before the end of the initialization " severity error;
  assert not (error_tmp_bis(1) = '1') report "[regdecode_wire_make_pulse] => FIFO read an empty FIFO" severity error;
  assert not (error_tmp_bis(0) = '1') report "[regdecode_wire_make_pulse] => FIFO write a full FIFO" severity error;

end architecture RTL;
