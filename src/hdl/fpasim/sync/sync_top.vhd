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
--!   @file                   sync_top.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--
-- This module can dynamically delays the input pulse sync signal by a user-defined value.
-- Then it generates from it a pulse with a static user-defined duration.
--
-- Example0:
--  g_PULSE_DURATION |   3 
--  i_sync_valid     |   1   1   1   1   1   1   1   1   1   1
--  i_sync           |   1   0   0   0   0   1   0   0   0   0
--  o_sync_valid     |   x   1   1   1   0   0   1   1   1   0
--  o_sync           |   x   1   1   1   0   0   1   1   1   0
--
-- -------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library fpasim;
use fpasim.pkg_fpasim.all;

entity sync_top is
  generic(
    g_PULSE_DURATION   : positive := 2; -- duration of the output pulse. Possible values [1;integer max value[
    g_SYNC_DELAY_WIDTH : positive := 6  -- delay bus width (expressed in bits). Possible values [1;integer max value[
  );
  port(
    ---------------------------------------------------------------------
    -- input @i_clk
    ---------------------------------------------------------------------
    i_clk         : in  std_logic;      -- clock
    i_rst         : in  std_logic;      -- reset
    -- from regdecode
    -----------------------------------------------------------------
    i_rst_status  : in  std_logic;      -- reset error flag(s)
    i_debug_pulse : in  std_logic;      -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
    i_sync_delay  : in  std_logic_vector(g_SYNC_DELAY_WIDTH - 1 downto 0); -- delay to apply on the data path.
    -- input data 
    ---------------------------------------------------------------------
    i_sync_valid  : in  std_logic;      -- valid sync sample
    i_sync        : in  std_logic;      -- sync sample
    ---------------------------------------------------------------------
    -- output @i_ref_clk
    ---------------------------------------------------------------------
    i_ref_clk     : in  std_logic;      -- destination clock
    o_sync_valid  : out std_logic;      -- valid sync sample
    o_sync        : out std_logic;      -- sync sample
    ---------------------------------------------------------------------
    -- errors/status @i_clk
    --------------------------------------------------------------------- 
    o_errors      : out std_logic_vector(15 downto 0); -- output errors
    o_status      : out std_logic_vector(7 downto 0) -- output status
  );
end entity sync_top;

architecture RTL of sync_top is
  constant c_DELAY_LATENCY     : natural := pkg_SYNC_DYNAMIC_SHIFT_REGISTER_LATENCY;
  constant c_FIFO_READ_LATENCY : natural := pkg_SYNC_FIFO_READ_LATENCY;
  constant c_LATENCY_OUT       : natural := pkg_SYNC_OUT_LATENCY;

  ---------------------------------------------------------------------
  -- apply delay
  ---------------------------------------------------------------------
  signal sync_valid_r1 : std_logic;
  signal sync_rx       : std_logic;

  ---------------------------------------------------------------------
  -- sync_pulse_generator
  ---------------------------------------------------------------------
  signal sync_valid_r2            : std_logic;
  signal sync_ry                  : std_logic;
  signal error_pulse_generator_r2 : std_logic;

  ---------------------------------------------------------------------
  -- FIFO
  ---------------------------------------------------------------------
  constant c_IDX0_L : integer := 0;
  constant c_IDX0_H : integer := c_IDX0_L + 1 - 1;

  constant c_FIFO_DEPTH : integer := 16; --see IP
  constant c_FIFO_WIDTH : integer := c_IDX0_H + 1; --see IP

  signal wr_rst_tmp0 : std_logic;
  signal wr_tmp0     : std_logic;
  signal data_tmp0   : std_logic_vector(c_FIFO_WIDTH - 1 downto 0);
  --signal full0        : std_logic;
  --signal wr_rst_busy0 : std_logic;

  signal errors_sync0 : std_logic_vector(3 downto 0);
  signal empty_sync0  : std_logic;

  signal rd1       : std_logic;
  signal data_tmp1 : std_logic_vector(c_FIFO_WIDTH - 1 downto 0);
  signal empty1    : std_logic;
  --signal rd_rst_busy1 : std_logic;

  signal sync_valid1 : std_logic;
  signal sync1       : std_logic;

  ---------------------------------------------------------------------
  -- output pipe
  ---------------------------------------------------------------------
  constant c_PIPE_IDX0_L : integer := 0;
  constant c_PIPE_IDX0_H : integer := c_PIPE_IDX0_L + 1 - 1;

  constant c_PIPE_IDX1_L : integer := c_PIPE_IDX0_H + 1;
  constant c_PIPE_IDX1_H : integer := c_PIPE_IDX1_L + 1 - 1;

  signal data_pipe_tmp1 : std_logic_vector(c_PIPE_IDX1_H downto 0);
  signal data_pipe_tmp2 : std_logic_vector(c_PIPE_IDX1_H downto 0);

  signal sync_valid2 : std_logic;
  signal sync2       : std_logic;

  ---------------------------------------------------------------------
  -- error latching
  ---------------------------------------------------------------------
  constant NB_ERRORS_c : integer := 3;
  signal error_tmp     : std_logic_vector(NB_ERRORS_c - 1 downto 0);
  signal error_tmp_bis : std_logic_vector(NB_ERRORS_c - 1 downto 0);

begin

  ---------------------------------------------------------------------
  -- apply a delay on the input data
  ---------------------------------------------------------------------
  inst_dynamic_shift_register_dac : entity fpasim.dynamic_shift_register
    generic map(
      g_ADDR_WIDTH => i_sync_delay'length, -- width of the address. Possibles values: [2, integer max value[ 
      g_DATA_WIDTH => 1                 -- width of the input/output data.  Possibles values: [1, integer max value[
    )
    port map(
      i_clk        => i_clk,            -- clock signal
      i_data_valid => i_sync_valid,     -- input data valid
      i_data(0)    => i_sync,           -- input data
      i_addr       => i_sync_delay,     -- input address (dynamically select the depth of the pipeline)
      o_data(0)    => sync_rx           -- output data with/without delay
    );

  inst_pipeliner_sync_with_dynamic_shift_register_when_delay_eq_0 : entity fpasim.pipeliner
    generic map(
      g_NB_PIPES   => c_DELAY_LATENCY,  -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => 1                 -- width of the input/output data.  Possibles values: [1, integer max value[
    )
    port map(
      i_clk     => i_clk,               -- clock signal
      i_data(0) => i_sync_valid,        -- input data
      o_data(0) => sync_valid_r1        -- output data with/without delay
    );

  -----------------------------------------------------------------
  -- build pulse
  -----------------------------------------------------------------
  inst_sync_pulse_generator : entity fpasim.sync_pulse_generator
    generic map(
      g_PULSE_DURATION => g_PULSE_DURATION -- duration of the pulse. Possible values [1;integer max value[
    )
    port map(
      i_clk         => i_clk,
      i_rst         => i_rst,
      i_rst_status  => i_rst_status,
      i_debug_pulse => i_debug_pulse,
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_sync_valid  => sync_valid_r1,
      i_sync        => sync_rx,
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_sync_valid  => sync_valid_r2,
      o_sync        => sync_ry,
      ---------------------------------------------------------------------
      -- errors
      ---------------------------------------------------------------------
      o_error       => error_pulse_generator_r2
    );

  ---------------------------------------------------------------------
  -- clock domain crossing: 16 bits -> 8 bits
  ---------------------------------------------------------------------
  wr_tmp0             <= sync_valid_r2;
  data_tmp0(c_IDX0_H) <= sync_ry;
  wr_rst_tmp0         <= i_rst;
  inst_fifo_async_with_error : entity fpasim.fifo_async_with_error
    generic map(
      g_CDC_SYNC_STAGES   => 2,
      g_FIFO_MEMORY_TYPE  => "auto",
      g_FIFO_READ_LATENCY => c_FIFO_READ_LATENCY,
      g_FIFO_WRITE_DEPTH  => c_FIFO_DEPTH,
      g_READ_DATA_WIDTH   => data_tmp1'length,
      g_READ_MODE         => "std",
      g_RELATED_CLOCKS    => 0,
      g_WRITE_DATA_WIDTH  => data_tmp0'length,
      ---------------------------------------------------------------------
      -- resynchronization: fifo errors/empty flag
      ---------------------------------------------------------------------
      g_SYNC_SIDE         => "wr",      -- define the clock side where status/errors is resynchronised. Possible value "wr" or "rd"
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
      o_wr_full       => open,
      o_wr_rst_busy   => open,
      ---------------------------------------------------------------------
      -- read side
      ---------------------------------------------------------------------
      i_rd_clk        => i_ref_clk,
      i_rd_en         => rd1,
      o_rd_dout_valid => sync_valid1,
      o_rd_dout       => data_tmp1,
      o_rd_empty      => empty1,
      o_rd_rst_busy   => open,
      ---------------------------------------------------------------------
      -- resynchronized errors/status 
      ---------------------------------------------------------------------
      o_errors_sync   => errors_sync0,
      o_empty_sync    => empty_sync0
    );

  rd1 <= '1' when empty1 = '0' else '0';

  sync1 <= data_tmp1(c_IDX0_H) and sync_valid1;

  ---------------------------------------------------------------------
  -- optionnal output pipe
  ---------------------------------------------------------------------
  data_pipe_tmp1(c_PIPE_IDX1_H) <= sync_valid1;
  data_pipe_tmp1(c_PIPE_IDX0_H) <= sync1;
  inst_pipeliner : entity fpasim.pipeliner
    generic map(
      g_NB_PIPES   => c_LATENCY_OUT,
      g_DATA_WIDTH => data_pipe_tmp1'length
    )
    port map(
      i_clk  => i_ref_clk,
      i_data => data_pipe_tmp1,
      o_data => data_pipe_tmp2
    );
  sync_valid2                   <= data_pipe_tmp2(c_PIPE_IDX1_H);
  sync2                         <= data_pipe_tmp2(c_PIPE_IDX0_H);

  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_sync_valid <= sync_valid2;
  o_sync       <= sync2;

  ---------------------------------------------------------------------
  -- Error latching
  ---------------------------------------------------------------------
  error_tmp(2) <= errors_sync0(2) or errors_sync0(3); -- fifo rst error
  error_tmp(1) <= errors_sync0(1);      -- fifo rd empty error
  error_tmp(0) <= errors_sync0(0);      -- fifo wr full error
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

  o_errors(15 downto 9) <= (others => '0');
  o_errors(8)           <= error_pulse_generator_r2;
  o_errors(7 downto 5)  <= (others => '0');
  o_errors(4)           <= error_tmp_bis(2); -- fifo rst error
  o_errors(3 downto 2)  <= (others => '0');
  o_errors(1)           <= error_tmp_bis(1); -- fifo rd empty error
  o_errors(0)           <= error_tmp_bis(0); -- fifo wr full error

  o_status(7 downto 1) <= (others => '0');
  o_status(0)          <= empty_sync0;

  ---------------------------------------------------------------------
  -- for simulation only
  ---------------------------------------------------------------------
  assert not (error_pulse_generator_r2 = '1') report "[sync_top] => detect a input pulse during the output pulse generation " severity error;
  assert not (error_tmp_bis(2) = '1') report "[sync_top] => FIFO is used before the end of the initialization " severity error;

  assert not (error_tmp_bis(1) = '1') report "[sync_top] => FIFO read an empty FIFO" severity error;
  assert not (error_tmp_bis(0) = '1') report "[sync_top] => FIFO write a full FIFO" severity error;

end architecture RTL;
