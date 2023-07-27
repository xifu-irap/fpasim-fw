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
--    @file                   recording_adc.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This module generates flags to tags
--     . the first block sample
--     . the last block sample
--     The block size is defined by the i_nb_samples_by_block input port
--
--    Example0: (i_adc_cmd_nb_words_by_block = 4) with continuous i_adc_data_valid signal
--    data valid | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
--    sof        | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0 |
--    eof        | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 1 |
--
--    Example1: (i_adc_cmd_nb_words_by_block = 4)  with non-continuous i_adc_data_valid signal
--    data valid | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 |
--    sof        | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
--    eof        | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 |
--
--   Note: The State Machine of this module doesn't manage the data flow. So, the user must provide enough space in the output FIFO (by reading it)
--         before sending a command to store a new data block. Otherwise, an error will be fired.
--   Remark:
--     . The output fifo is configured as standard (1 clock cycle delay between the i_fifo_adc_rd and the o_fifo_adc_data_valid). The user
--     needs to be careful in the management.
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_fpasim.all;


entity recording_adc is
  generic (
    g_ADC_FIFO_OUT_DEPTH : integer := pkg_REC_ADC_FIFO_OUT_DEPTH  -- depth of the FIFO (number of words). Must be a power of 2
    );
  port (
    i_rst         : in std_logic;       -- input reset
    i_clk         : in std_logic;       -- input clock
    i_rst_status  : in std_logic;       -- reset error flag(s)
    i_debug_pulse : in std_logic;  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)

    ---------------------------------------------------------------------
    -- input
    ---------------------------------------------------------------------
    -- from regdecode
    i_adc_cmd_start             : in std_logic;  -- '1': start the acquisition of a data block, '0': do nothing
    i_adc_cmd_nb_words_by_block : in std_logic_vector(15 downto 0);  -- number of output words

    -- from adcs
    i_adc_data_valid : in  std_logic;   -- data valid
    i_adc_data1      : in  std_logic_vector(15 downto 0);  -- data1 value
    i_adc_data0      : in  std_logic_vector(15 downto 0);  -- data0 value
    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    i_fifo_adc_rd         : in  std_logic;   -- read fifo
    o_fifo_adc_sof        : out std_logic;   -- first word of a block
    o_fifo_adc_eof        : out std_logic;   -- last word of a block
    o_fifo_adc_data_valid : out std_logic;   -- output data valid
    o_fifo_adc_data       : out std_logic_vector(31 downto 0);  -- output data value
    o_fifo_adc_empty      : out std_logic;   -- fifo empty flag

    -----------------------------------------------------------------
    -- errors/status
    -----------------------------------------------------------------
    o_adc_errors : out std_logic_vector(15 downto 0);  -- output errors
    o_adc_status : out std_logic_vector(7 downto 0)    -- output status

    );
end entity recording_adc;

architecture RTL of recording_adc is

  ---------------------------------------------------------------------
  -- FIFO
  ---------------------------------------------------------------------
  constant c_IDX0_L : integer := 0; -- index0: low
  constant c_IDX0_H : integer := c_IDX0_L + o_fifo_adc_data'length - 1; --index0: high

  constant c_IDX1_L : integer := c_IDX0_H + 1; -- index1: low
  constant c_IDX1_H : integer := c_IDX1_L + 1 - 1; --index1: high

  constant c_IDX2_L : integer := c_IDX1_H + 1; -- index2: low
  constant c_IDX2_H : integer := c_IDX2_L + 1 - 1; --index2: high

  -- FIFO depth (expressed in number of words)
  constant c_FIFO_DEPTH        : integer := g_ADC_FIFO_OUT_DEPTH;
  -- FIFO width (expressed in bits)
  constant c_FIFO_WIDTH        : integer := c_IDX2_H + 1;
  -- FIFO latency (in reading)
  constant c_FIFO_READ_LATENCY : integer := 2;

  ---------------------------------------------------------------------
  -- state machine
  ---------------------------------------------------------------------
  -- fsm type declaration
  type t_state is (E_RST, E_WAIT, E_RUN);
  signal sm_state_next : t_state; -- state (registered)
  signal sm_state_r1   : t_state := E_RST; -- state

  signal data_valid_next : std_logic; -- data valid
  signal data_valid_r1   : std_logic := '0'; -- data valid (registered)

  signal sof_next : std_logic; -- first word flag
  signal sof_r1   : std_logic := '0'; -- first word flag (registered)

  signal eof_next : std_logic; -- last word flag
  signal eof_r1   : std_logic := '0'; -- last word flag (registered)

  -- count number of words
  signal cnt_sample_next : unsigned(i_adc_cmd_nb_words_by_block'range);
  -- count number of words (registered)
  signal cnt_sample_r1    : unsigned(i_adc_cmd_nb_words_by_block'range) := (others => '0');

  -- max number of words
  signal cnt_sample_max_next : unsigned(i_adc_cmd_nb_words_by_block'range);
  -- max number of words (registered)
  signal cnt_sample_max_r1    : unsigned(i_adc_cmd_nb_words_by_block'range) := (others => '0');

  -- data1 (registered)
  signal data1_r1 : std_logic_vector(i_adc_data1'range);
  -- data0 (registered)
  signal data0_r1 : std_logic_vector(i_adc_data0'range);

  -- temporary data: data1 & data0
  signal data_tmp2    : std_logic_vector(o_fifo_adc_data'range);
  ---------------------------------------------------------------------
  -- step2
  ---------------------------------------------------------------------
  -- fifo write side
  -- fifo: reset
  signal wr_rst_tmp0  : std_logic;
  -- fifo: write
  signal wr_tmp0      : std_logic;
  -- fifo: data_in
  signal data_tmp0    : std_logic_vector(c_FIFO_WIDTH - 1 downto 0);
  -- fifo: full flag
  --signal full0        : std_logic;
  -- fifo: rst_busy flag
  signal wr_rst_busy0 : std_logic;

  -- fifo read side
  -- fifo: read
  signal rd1          : std_logic;
  -- fifo: data_out
  signal data_tmp1    : std_logic_vector(c_FIFO_WIDTH - 1 downto 0);
  -- fifo: empty flag
  signal empty1       : std_logic;
  -- fifo: rst_busy flag
  signal rd_rst_busy1 : std_logic;

  -- temporary first word
  signal sof_tmp1        : std_logic;
  -- temporary last word
  signal eof_tmp1        : std_logic;
  -- temporary data valid
  signal data_valid_tmp1 : std_logic;
  -- temporary data
  signal data1           : std_logic_vector(o_fifo_adc_data'range);

  -- resynchronized errors
  signal errors_sync1 : std_logic_vector(3 downto 0);
  -- resynchronized empty flag
  signal empty_sync1  : std_logic;

  ---------------------------------------------------------------------
  -- error latching
  ---------------------------------------------------------------------
  constant c_NB_ERRORS : integer := 3; -- define the width of the temporary errors signals
  signal error_tmp     : std_logic_vector(c_NB_ERRORS - 1 downto 0); -- temporary input errors
  signal error_tmp_bis : std_logic_vector(c_NB_ERRORS - 1 downto 0); -- temporary output errors

begin

---------------------------------------------------------------------
-- state machine:
--   for each start comand, it build a bloc of ADC Samples
---------------------------------------------------------------------
  p_decode_state : process(cnt_sample_max_r1, cnt_sample_r1,
                           i_adc_cmd_nb_words_by_block, i_adc_cmd_start, i_adc_data_valid,
                           sm_state_r1) is
  begin
    -- default value

    data_valid_next     <= '0';
    sof_next            <= '0';
    eof_next            <= '0';
    cnt_sample_next     <= cnt_sample_r1;
    cnt_sample_max_next <= cnt_sample_max_r1;

    case sm_state_r1 is
      when E_RST =>

        sm_state_next <= E_WAIT;

      when E_WAIT =>

        if i_adc_data_valid = '1' and i_adc_cmd_start = '1' then
          data_valid_next     <= i_adc_data_valid;

          sof_next            <= '1';
          cnt_sample_next     <= to_unsigned(0, i_adc_cmd_nb_words_by_block'length);
          cnt_sample_max_next <= unsigned(i_adc_cmd_nb_words_by_block) - 1;  --susbract - 1 to anticipate

          -- special case: frame of one sample
          if unsigned(i_adc_cmd_nb_words_by_block) = to_unsigned(0, i_adc_cmd_nb_words_by_block'length) then
            eof_next      <= '1';
            sm_state_next <= E_WAIT;
          else
            sm_state_next <= E_RUN;
          end if;
        else
          sm_state_next <= E_WAIT;
        end if;

      when E_RUN =>

        if i_adc_data_valid = '1' then
          data_valid_next <= '1';
          cnt_sample_next <= cnt_sample_r1 + 1;
          if cnt_sample_r1 = cnt_sample_max_r1 then
            eof_next      <= '1';
            sm_state_next <= E_WAIT;
          else
            sm_state_next <= E_RUN;
          end if;
        else
          data_valid_next <= '0';
          sm_state_next   <= E_RUN;
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
      cnt_sample_r1     <= cnt_sample_next;
      cnt_sample_max_r1 <= cnt_sample_max_next;

      sof_r1        <= sof_next;
      eof_r1        <= eof_next;
      data_valid_r1 <= data_valid_next;

      ---------------------------------------------------------------------
      -- pipe
      ---------------------------------------------------------------------
      data1_r1 <= i_adc_data1;
      data0_r1 <= i_adc_data0;
    end if;
  end process p_state_proc;

  ---------------------------------------------------------------------
  -- build output word
  ---------------------------------------------------------------------
  data_tmp2(31 downto 16) <= data1_r1;
  data_tmp2(15 downto 0)  <= data0_r1;

  ---------------------------------------------------------------------
  -- output FIFO
  ---------------------------------------------------------------------
  wr_rst_tmp0 <= i_rst;

  wr_tmp0                             <= data_valid_r1;
  data_tmp0(c_IDX2_H)                 <= sof_r1;
  data_tmp0(c_IDX1_H)                 <= eof_r1;
  data_tmp0(c_IDX0_H downto c_IDX0_L) <= data_tmp2;

  inst_fifo_sync_with_error : entity work.fifo_sync_with_error
    generic map(
      g_FIFO_MEMORY_TYPE  => "auto",
      g_FIFO_READ_LATENCY => c_FIFO_READ_LATENCY,
      g_FIFO_WRITE_DEPTH  => c_FIFO_DEPTH,
      g_READ_DATA_WIDTH   => data_tmp0'length,
      g_READ_MODE         => "std",
      g_WRITE_DATA_WIDTH  => data_tmp0'length
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
      o_wr_rst_busy   => wr_rst_busy0,
      ---------------------------------------------------------------------
      -- read side
      ---------------------------------------------------------------------
      i_rd_en         => rd1,
      o_rd_dout_valid => data_valid_tmp1,
      o_rd_dout       => data_tmp1,
      o_rd_empty      => empty1,
      o_rd_rst_busy   => rd_rst_busy1,  -- not connected
      ---------------------------------------------------------------------
      -- resynchronized errors/status
      ---------------------------------------------------------------------
      o_errors_sync   => errors_sync1,
      o_empty_sync    => empty_sync1
      );

  rd1 <= '1' when i_fifo_adc_rd = '1' and rd_rst_busy1 = '0' else '0';

  sof_tmp1         <= data_tmp1(c_IDX2_H);
  eof_tmp1         <= data_tmp1(c_IDX1_H);
  data1            <= data_tmp1(c_IDX0_H downto c_IDX0_L);
  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_fifo_adc_data_valid <= data_valid_tmp1;
  o_fifo_adc_sof        <= sof_tmp1;
  o_fifo_adc_eof        <= eof_tmp1;
  o_fifo_adc_data       <= data1;
  o_fifo_adc_empty      <= empty1;


  ---------------------------------------------------------------------
  -- Error latching
  ---------------------------------------------------------------------
  error_tmp(2) <= errors_sync1(2) or errors_sync1(3);  -- fifo rst error
  error_tmp(1) <= errors_sync1(1);                     -- fifo rd empty error
  error_tmp(0) <= errors_sync1(0);                     -- fifo wr full error
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

  o_adc_errors(15 downto 3) <= (others => '0');
  o_adc_errors(2)           <= error_tmp_bis(2);  -- fifo rst error
  o_adc_errors(1)           <= error_tmp_bis(1);  -- fifo rd empty error
  o_adc_errors(0)           <= error_tmp_bis(0);  -- fifo wr full error

  o_adc_status(7 downto 1) <= (others => '0');
  o_adc_status(0)          <= empty_sync1;  -- fifo empty

  ---------------------------------------------------------------------
  -- for simulation only
  ---------------------------------------------------------------------
  assert not (error_tmp_bis(2) = '1') report "[recording_adc] => fifo is used before the end of the initialization " severity error;
  assert not (error_tmp_bis(1) = '1') report "[recording_adc] => fifo read an empty FIFO" severity error;
  assert not (error_tmp_bis(0) = '1') report "[recording_adc] => fifo write a full FIFO" severity error;


end architecture RTL;
