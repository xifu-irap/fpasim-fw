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
--    @file                   io_sync.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This module does the following steps:
--      . SYNC:
--         . pass data words (i_sync) from @sys_clk to the @sync_clk
--         . send data to the IOs (@sync_clk)
--         . generate clock to the IOs (@sync_clk)
--
--    The architecture is as follows:
--      Input ports -> optionnal latency -> fpga specific IO generation -> output port
--
-- -------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use work.pkg_io.all;

entity io_sync is
  port(

    ---------------------------------------------------------------------
    -- input
    ---------------------------------------------------------------------
    i_clk         : in std_logic;       -- clock
    i_rst         : in std_logic;       -- reset
    i_rst_status  : in std_logic;       -- reset error flag(s)
    i_debug_pulse : in std_logic;  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
    i_sync_valid  : in std_logic;       -- sync valid
    i_sync        : in std_logic;       -- sync value

    ---------------------------------------------------------------------
    -- output @i_out_clk
    ---------------------------------------------------------------------
    i_out_clk : in std_logic;           -- output clock

    -- from reset_top: @i_out_clk
    i_io_clk_rst : in  std_logic;       -- small reset pulse width
    i_io_rst     : in  std_logic;       -- large reset pulse width
    -- data
    o_sync_clk_p   : out std_logic;       -- differential sync clock_p
    o_sync_clk_n   : out std_logic;       -- differential sync clock_n
    o_sync_p       : out std_logic;       -- differential sync_p pulse
    o_sync_n       : out std_logic;       -- differential sync_n pulse

    ---------------------------------------------------------------------
    -- errors/status @i_clk
    ---------------------------------------------------------------------
    o_errors : out std_logic_vector(15 downto 0);  -- output errors
    o_status : out std_logic_vector(7 downto 0)    -- output status
    );
end entity io_sync;

architecture RTL of io_sync is

   -- Add an additional output latency (expressed in clock periods)
  constant c_OUTPUT_LATENCY    : natural := pkg_IO_SYNC_OUT_LATENCY;
  -- FIFO: latency of the CDC mechanism (expressed in clock periods)
  constant c_FIFO_CDC_LATENCY  : natural := pkg_IO_SYNC_FIFO_CDC_STAGE;
  -- FIFO: read latency (expressed in clock periods)
  constant c_FIFO_READ_LATENCY : natural := pkg_IO_SYNC_FIFO_READ_LATENCY;
  ---------------------------------------------------------------------
  -- FIFO
  ---------------------------------------------------------------------
  constant c_IDX0_L            : integer := 0; -- index0: low
  constant c_IDX0_H            : integer := c_IDX0_L + 1 - 1; -- index0: high

  -- FIFO depth (expressed in number of words)
  constant c_FIFO_DEPTH : integer := 16;
  -- FIFO: data width (write side: expressed in bits)
  constant c_FIFO_WIDTH : integer := c_IDX0_H + 1;

  -- fifo: write side
  -- fifo: rst
  signal wr_rst_tmp0 : std_logic;
  -- fifo: write
  signal wr_tmp0     : std_logic;
  -- fifo: data_in
  signal data_tmp0   : std_logic_vector(c_FIFO_WIDTH - 1 downto 0);
  -- fifo: full flag
  --signal full0        : std_logic;
  -- fifo: rst_busy flag
  --signal wr_rst_busy0 : std_logic;

  -- resynchronized errors
  signal errors_sync0 : std_logic_vector(3 downto 0);
  -- resynchronized empty flag
  signal empty_sync0  : std_logic;

  -- fifo: read side
  -- fifo: read
  signal rd1          : std_logic;
  -- fifo: data_out
  signal data_tmp1    : std_logic_vector(c_FIFO_WIDTH - 1 downto 0);
  -- fifo: empty flag
  signal empty1       : std_logic;
  -- fifo: rst_busy flag
  signal rd_rst_busy1 : std_logic;

  -- sync valid
  signal sync_valid1 : std_logic;
  -- sync value
  signal sync1       : std_logic;

  ---------------------------------------------------------------------
  -- optionnally add latency
  ---------------------------------------------------------------------
  -- sync value
  signal sync_rx : std_logic;

  ---------------------------------------------------------------------
  -- oddr
  ---------------------------------------------------------------------
  -- temporary differential sync pulse p
  signal sync_p_tmp : std_logic;
  -- temporary differential sync pulse n
  signal sync_n_tmp : std_logic;
  -- temporary differential clock p
  signal clk_p_tmp  : std_logic;
  -- temporary differential clock n
  signal clk_n_tmp  : std_logic;

  ---------------------------------------------------------------------
  -- error latching
  ---------------------------------------------------------------------
  constant c_NB_ERRORS : integer := 3; -- define the width of the temporary errors signals
  signal error_tmp     : std_logic_vector(c_NB_ERRORS - 1 downto 0); -- temporary input errors
  signal error_tmp_bis : std_logic_vector(c_NB_ERRORS - 1 downto 0); -- temporary output errors


begin
---------------------------------------------------------------------
  -- clock domain crossing
  ---------------------------------------------------------------------
  wr_rst_tmp0         <= i_rst;
  wr_tmp0             <= i_sync_valid;
  data_tmp0(c_IDX0_H) <= i_sync;

  inst_fifo_async_with_error : entity work.fifo_async_with_error
    generic map(
      g_CDC_SYNC_STAGES   => c_FIFO_CDC_LATENCY,
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
      g_SYNC_SIDE         => "wr"  -- define the clock side where status/errors is resynchronised. Possible value "wr" or "rd"

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
      i_rd_clk        => i_out_clk,
      i_rd_en         => rd1,
      o_rd_dout_valid => sync_valid1,
      o_rd_dout       => data_tmp1,
      o_rd_empty      => empty1,
      o_rd_rst_busy   => rd_rst_busy1,
      ---------------------------------------------------------------------
      -- resynchronized errors/status
      ---------------------------------------------------------------------
      o_errors_sync   => errors_sync0,
      o_empty_sync    => empty_sync0
      );

  rd1 <= '1' when empty1 = '0' and rd_rst_busy1 = '0' else '0';

  sync1 <= data_tmp1(c_IDX0_H) and sync_valid1;


  ---------------------------------------------------------------------
  -- output: optionnally add latency before output IOs
  ---------------------------------------------------------------------
  inst_pipeliner_add_output_latency : entity work.pipeliner
    generic map(
      g_NB_PIPES   => c_OUTPUT_LATENCY,  -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => 1  -- width of the input/output data.  Possibles values: [1, integer max value[
      )
    port map(
      i_clk     => i_out_clk,           -- clock signal
      i_data(0) => sync1,               -- input data
      o_data(0) => sync_rx              -- output data with/without delay
      );

  ---------------------------------------------------------------------
  -- I/O interface
  ---------------------------------------------------------------------
  gen_io_sync : if true generate
    -- sync pulse
    signal data_tmp0 : std_logic_vector(0 downto 0);
    -- differential sync pulse p
    signal data_p_tmp1 : std_logic_vector(0 downto 0);
    -- differential sync pulse n
    signal data_n_tmp1 : std_logic_vector(0 downto 0);
  begin
    data_tmp0(0) <= sync_rx;
    inst_selectio_wiz_sync : entity work.selectio_wiz_sync
      port map(
        data_out_from_device => data_tmp0,
        data_out_to_pins_p   => data_p_tmp1,
        data_out_to_pins_n   => data_n_tmp1,
        clk_to_pins_p        => clk_p_tmp,
        clk_to_pins_n        => clk_n_tmp,
        clk_in               => i_out_clk,
        clk_reset            => i_io_clk_rst,
        io_reset             => i_io_rst
        );
    sync_p_tmp <= data_p_tmp1(0);
    sync_n_tmp <= data_n_tmp1(0);
  end generate gen_io_sync;

  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_sync_clk_p   <= clk_p_tmp;
  o_sync_clk_n   <= clk_n_tmp;
  o_sync_p       <= sync_p_tmp;
  o_sync_n       <= sync_n_tmp;


  ---------------------------------------------------------------------
  -- Error latching
  ---------------------------------------------------------------------
  error_tmp(2) <= errors_sync0(2) or errors_sync0(3);  -- fifo rst error
  error_tmp(1) <= errors_sync0(1);                     -- fifo rd empty error
  error_tmp(0) <= errors_sync0(0);                     -- fifo wr full error
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

  o_errors(15 downto 3) <= (others => '0');
  o_errors(2)           <= error_tmp_bis(2);  -- fifo rst error
  o_errors(1)           <= error_tmp_bis(1);  -- fifo rd empty error
  o_errors(0)           <= error_tmp_bis(0);  -- fifo wr full error

  o_status(7 downto 1) <= (others => '0');
  o_status(0)          <= empty_sync0;

  ---------------------------------------------------------------------
  -- for simulation only
  ---------------------------------------------------------------------
  assert not (error_tmp_bis(2) = '1') report "[io_sync] => FIFO is used before the end of the initialization " severity error;
  assert not (error_tmp_bis(1) = '1') report "[io_sync] => FIFO read an empty FIFO" severity error;
  assert not (error_tmp_bis(0) = '1') report "[io_sync] => FIFO write a full FIFO" severity error;

end architecture RTL;
