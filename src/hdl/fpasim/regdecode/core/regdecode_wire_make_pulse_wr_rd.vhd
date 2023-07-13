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
--    @file                   regdecode_wire_make_pulse_wr_rd.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This module synchronizes a data bus from a source clock domain (@i_clk) to a destination clock domain(@i_out_clk).
--    Then, the output synchronized data bus is read back from the destination clock domain to the source clock domain.
--
--    The architecture principle is as follows:
--         @i_clk clock domain        |                   @ i_out_clk clock domain
--         i_data ---------------> async_fifo -----------> o_data
--                                                       |
--         o_fifo_data <---------  async_fifo <----------
--
--    Note: The read back of the synchronized data bus allows to check the clock domain crossing integrity.
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity regdecode_wire_make_pulse_wr_rd is
  generic(
    g_DATA_WIDTH_OUT : positive := 15   -- define the RAM address width
    );
  port(
    ---------------------------------------------------------------------
    -- from the regdecode: input @i_clk
    ---------------------------------------------------------------------
    i_clk             : in  std_logic;  -- clock
    i_rst             : in  std_logic;  -- rst
    i_rst_status      : in  std_logic;  -- reset error flag(s)
    i_debug_pulse     : in  std_logic;  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
    -- data
    i_data_valid      : in  std_logic;  -- data valid
    i_data            : in  std_logic_vector(g_DATA_WIDTH_OUT - 1 downto 0);  -- data value
    o_ready           : out std_logic; -- fifo ready
    o_wr_data_count   : out std_logic_vector(15 downto 0); -- fifo write data count
    ---------------------------------------------------------------------
    -- from/to the user:  @i_out_clk
    ---------------------------------------------------------------------
    i_out_clk         : in  std_logic;  -- output clock
    i_out_rst         : in std_logic; -- reset @i_out_clk
    -- ram: wr
    i_data_rd         : in  std_logic;  -- fifo read
    o_data_valid      : out std_logic;  -- fifo data valid out
    o_data            : out std_logic_vector(g_DATA_WIDTH_OUT - 1 downto 0);  -- fifo data out
    o_empty           : out std_logic; -- fifo empty
    ---------------------------------------------------------------------
    -- to the regdecode: @i_clk
    ---------------------------------------------------------------------
    i_fifo_rd         : in  std_logic;  -- fifo read enable
    o_fifo_data_valid : out std_logic;  -- fifo data valid
    o_fifo_data       : out std_logic_vector(g_DATA_WIDTH_OUT - 1 downto 0);  -- fifo data
    o_fifo_empty      : out std_logic;  -- fifo empty flag
    ---------------------------------------------------------------------
    -- errors/status @ i_clk
    ---------------------------------------------------------------------
    o_errors          : out std_logic_vector(15 downto 0);  -- output errors
    o_status          : out std_logic_vector(7 downto 0)    -- output status
    );
end entity regdecode_wire_make_pulse_wr_rd;

architecture RTL of regdecode_wire_make_pulse_wr_rd is

  -- additional latency before writing in the fifo for the regdecode side.
  constant c_WR_TO_RD_DELAY    : integer := 0;
  -- fifo: latency (in reading: expressed in clock periods on the read side)
  constant c_FIFO_READ_LATENCY : integer := 2;

  ---------------------------------------------------------------------
  -- cross clock domain: redecode to user
  ---------------------------------------------------------------------
  constant c_FIFO_IDX0_L : integer := 0; -- index0: low
  constant c_FIFO_IDX0_H : integer := c_FIFO_IDX0_L + i_data'length - 1; -- index0: high

  -- FIFO depth (expressed in number of words)
  constant c_FIFO_DEPTH0         : integer := 16;
  -- FIFO prog_full threshold (expressed in words)
  constant c_FIFO_PROG_FULL0     : integer := c_FIFO_DEPTH0 - 4;
  -- FIFO width (expressed in bits)
  constant c_FIFO_WIDTH0         : integer := c_FIFO_IDX0_H + 1;
  -- FIFO write data count width (expressed in bits)
  constant c_FIFO_WR_DATA_WIDTH0 : integer := integer(log2(real(c_FIFO_DEPTH0))) + 1;

  -- fifo: write side
  -- fifo: rst
  signal wr_rst_tmp0    : std_logic;
  -- fifo: write
  signal wr_tmp0        : std_logic;
  -- fifo: data_in
  signal data_tmp0      : std_logic_vector(c_FIFO_WIDTH0 - 1 downto 0);
  -- fifo: full flag
  -- signal full0        : std_logic;
  -- fifo: prog_full flag
  signal prog_full0     : std_logic;
  -- fifo: write data count
  signal wr_data_count0 : std_logic_vector(c_FIFO_WR_DATA_WIDTH0 - 1 downto 0);
  -- fifo: rst_busy flag
  -- signal wr_rst_busy0 : std_logic;

  -- fifo: read side
  -- fifo: read
  signal rd1          : std_logic;
  -- fifo: data_out
  signal data_tmp1    : std_logic_vector(c_FIFO_WIDTH0 - 1 downto 0);
  -- fifo: empty flag
  signal empty1       : std_logic;
  -- fifo: data_valid flag
  signal data_valid1  : std_logic;
  -- fifo: rst_busy flag
  signal rd_rst_busy1 : std_logic;

  -- fifo: data_out
  signal data1 : std_logic_vector(i_data'range);

  -- resynchronized errors
  signal errors_sync1 : std_logic_vector(3 downto 0);
  -- resynchronized empty flag
  signal empty_sync1  : std_logic;

  -- fifo: ready
  signal ready_r1 : std_logic := '0';

  ---------------------------------------------------------------------
  -- sync with the rd RAM output
  ---------------------------------------------------------------------
  constant c_PIPE_IDX0_L : integer := 0; -- index0: low
  constant c_PIPE_IDX0_H : integer := c_PIPE_IDX0_L + i_data'length - 1; -- index0: high

  constant c_PIPE_IDX1_L : integer := c_PIPE_IDX0_H + 1; -- index1: low
  constant c_PIPE_IDX1_H : integer := c_PIPE_IDX1_L + 1 - 1; -- index1: high

  signal data_pipe_tmp0 : std_logic_vector(c_PIPE_IDX1_H downto 0); -- temporary input pipe
  signal data_pipe_tmp1 : std_logic_vector(c_PIPE_IDX1_H downto 0); -- temporary output pipe

  signal data_valid_sync_rx : std_logic; -- delayed data_valid
  signal data_sync_rx       : std_logic_vector(o_data'range);-- delayed data

  ---------------------------------------------------------------------
  -- cross clock domain: user to regdecode
  ---------------------------------------------------------------------
  -- FIFO depth (expressed in number of words)
  constant c_FIFO_DEPTH2 : integer := 16;
  -- FIFO width (expressed in bits)
  constant c_FIFO_WIDTH2 : integer := c_FIFO_IDX0_H + 1;

  -- fifo: write side
  -- fifo: write
  signal wr_tmp2   : std_logic;
  -- fifo: data_in
  signal data_tmp2 : std_logic_vector(c_FIFO_WIDTH2 - 1 downto 0);
  -- fifo: full flag
  -- signal full2        : std_logic;
  -- fifo: rst_busy flag
  -- signal wr_rst_busy2 : std_logic;

  -- resynchronized errors
  signal errors_sync2 : std_logic_vector(3 downto 0);
  -- resynchronized empty flag
  signal empty_sync2  : std_logic;

  -- fifo: read side
  -- fifo: read
  signal rd3          : std_logic;
  -- fifo: data_out
  signal data_tmp3    : std_logic_vector(c_FIFO_WIDTH2 - 1 downto 0);
  -- fifo: empty flag
  signal empty3       : std_logic;
  -- fifo: data_valid flag
  signal data_valid3  : std_logic;
  -- fifo: rst_busy flag
  signal rd_rst_busy3 : std_logic;

  -- fifo: data_out
  signal data3 : std_logic_vector(i_data'range);

  ---------------------------------------------------------------------
  -- error latching
  ---------------------------------------------------------------------
  constant c_NB_ERRORS : integer := 6; -- define the width of the temporary errors signals
  signal error_tmp     : std_logic_vector(c_NB_ERRORS - 1 downto 0); -- temporary input errors
  signal error_tmp_bis : std_logic_vector(c_NB_ERRORS - 1 downto 0); -- temporary output errors

begin

  ---------------------------------------------------------------------
  -- wr fifo: cross clock domain
  --    .from the i_clk clock domain to the i_out_clk domain
  ---------------------------------------------------------------------
  wr_rst_tmp0                                   <= i_rst;
  wr_tmp0                                       <= i_data_valid;
  data_tmp0(c_FIFO_IDX0_H downto c_FIFO_IDX0_L) <= i_data;

  inst_fifo_async_with_error_prog_full_wr_count_regdecode_to_user : entity work.fifo_async_with_error_prog_full_wr_count
    generic map(
      g_CDC_SYNC_STAGES     => 2,
      g_FIFO_MEMORY_TYPE    => "auto",
      g_FIFO_READ_LATENCY   => c_FIFO_READ_LATENCY,
      g_FIFO_WRITE_DEPTH    => c_FIFO_DEPTH0,
      g_PROG_FULL_THRESH    => c_FIFO_PROG_FULL0,
      g_READ_DATA_WIDTH     => data_tmp0'length,
      g_READ_MODE           => "std",
      g_RELATED_CLOCKS      => 0,
      g_WRITE_DATA_WIDTH    => data_tmp0'length,
      g_WR_DATA_COUNT_WIDTH => c_FIFO_WR_DATA_WIDTH0,
      ---------------------------------------------------------------------
      -- resynchronization: fifo errors/empty flag
      ---------------------------------------------------------------------
      g_SYNC_SIDE           => "wr"  -- define the clock side where status/errors is resynchronised. Possible value "wr" or "rd"
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
      o_wr_prog_full  => prog_full0,
      o_wr_data_count => wr_data_count0,
      o_wr_rst_busy   => open,
      ---------------------------------------------------------------------
      -- read side
      ---------------------------------------------------------------------
      i_rd_clk        => i_out_clk,
      i_rd_en         => rd1,
      o_rd_dout_valid => data_valid1,
      o_rd_dout       => data_tmp1,
      o_rd_empty      => empty1,
      o_rd_rst_busy   => rd_rst_busy1,
      ---------------------------------------------------------------------
      -- resynchronized errors/status
      ---------------------------------------------------------------------
      o_errors_sync   => errors_sync1,
      o_empty_sync    => empty_sync1
      );

  rd1 <= i_data_rd when rd_rst_busy1 = '0' else '0';

  data1 <= data_tmp1(c_FIFO_IDX0_H downto c_FIFO_IDX0_L);

  ---------------------------------------------------------------------
  -- generate fifo ready signal (wr side)
  ---------------------------------------------------------------------
  p_wr_ready : process(i_clk) is
  begin
    if rising_edge(i_clk) then
      ready_r1 <= not (prog_full0);
    end if;
  end process p_wr_ready;
  ---------------------------------------------------------------------
  -- to the usb: output
  ---------------------------------------------------------------------
  o_wr_data_count <= std_logic_vector(resize(unsigned(wr_data_count0), o_wr_data_count'length));
  o_ready         <= ready_r1;
  ---------------------------------------------------------------------
  -- to the user: output
  ---------------------------------------------------------------------
  o_data_valid    <= data_valid1;
  o_data          <= data1;
  o_empty         <= empty1;

  ---------------------------------------------------------------------
  -- optional: add latency before writing
  ---------------------------------------------------------------------
  data_pipe_tmp0(c_PIPE_IDX1_H)                      <= data_valid1;
  data_pipe_tmp0(c_PIPE_IDX0_H downto c_PIPE_IDX0_L) <= data1;
  inst_pipeliner_sync_with_rd_ram_out : entity work.pipeliner
    generic map(
      g_NB_PIPES   => c_WR_TO_RD_DELAY,
      g_DATA_WIDTH => data_pipe_tmp0'length
      )
    port map(
      i_clk  => i_out_clk,
      i_data => data_pipe_tmp0,
      o_data => data_pipe_tmp1
      );
  data_valid_sync_rx <= data_pipe_tmp1(c_PIPE_IDX1_H);
  data_sync_rx       <= data_pipe_tmp1(c_PIPE_IDX0_H downto c_PIPE_IDX0_L);

  ---------------------------------------------------------------------
  -- cross clock domain:
  --  from the i_out_clk clock domain to the i_clk clock domain
  ---------------------------------------------------------------------
  wr_tmp2                                       <= data_valid_sync_rx;
  data_tmp2(c_FIFO_IDX0_H downto c_FIFO_IDX0_L) <= data_sync_rx;

  inst_fifo_async_with_error_user_to_regdecode : entity work.fifo_async_with_error
    generic map(
      g_CDC_SYNC_STAGES   => 2,
      g_FIFO_MEMORY_TYPE  => "auto",
      g_FIFO_READ_LATENCY => c_FIFO_READ_LATENCY,
      g_FIFO_WRITE_DEPTH  => c_FIFO_DEPTH2,
      g_READ_DATA_WIDTH   => data_tmp2'length,
      g_READ_MODE         => "std",
      g_RELATED_CLOCKS    => 0,
      g_WRITE_DATA_WIDTH  => data_tmp2'length,
      ---------------------------------------------------------------------
      -- resynchronization: fifo errors/empty flag
      ---------------------------------------------------------------------
      g_SYNC_SIDE         => "rd"  -- define the clock side where status/errors is resynchronised. Possible value "wr" or "rd"

      )
    port map(
      ---------------------------------------------------------------------
      -- write side
      ---------------------------------------------------------------------
      i_wr_clk        => i_out_clk,
      i_wr_rst        => i_out_rst,
      i_wr_en         => wr_tmp2,
      i_wr_din        => data_tmp2,
      o_wr_full       => open,
      o_wr_rst_busy   => open,
      ---------------------------------------------------------------------
      -- read side
      ---------------------------------------------------------------------
      i_rd_clk        => i_clk,
      i_rd_en         => rd3,
      o_rd_dout_valid => data_valid3,
      o_rd_dout       => data_tmp3,
      o_rd_empty      => empty3,
      o_rd_rst_busy   => rd_rst_busy3,
      ---------------------------------------------------------------------
      -- resynchronized errors/status
      ---------------------------------------------------------------------
      o_errors_sync   => errors_sync2,
      o_empty_sync    => empty_sync2
      );

  rd3   <= i_fifo_rd when rd_rst_busy3 = '0' else '0';
  data3 <= data_tmp3(c_FIFO_IDX0_H downto c_FIFO_IDX0_L);

  ---------------------------------------------------------------------
  -- to the regdecode: output
  ---------------------------------------------------------------------
  o_fifo_data_valid <= data_valid3;
  o_fifo_data       <= data3;
  o_fifo_empty      <= empty3;

  ---------------------------------------------------------------------
  -- Error latching
  ---------------------------------------------------------------------
  error_tmp(5) <= errors_sync2(2) or errors_sync2(3);  -- fifo2: fifo rst error
  error_tmp(4) <= errors_sync2(1);                     -- fifo2: fifo rd empty
  error_tmp(3) <= errors_sync2(0);                     -- fifo2: fifo wr error
  error_tmp(2) <= errors_sync1(2) or errors_sync1(3);  -- fifo0: fifo rst error
  error_tmp(1) <= errors_sync1(1);                     -- fifo0: fifo rd empty
  error_tmp(0) <= errors_sync1(0);                     -- fifo0: fifo wr full
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

  o_errors(15 downto 7) <= (others => '0');
  o_errors(6)           <= error_tmp_bis(5);  -- fifo2: rst error
  o_errors(5)           <= error_tmp_bis(4);  -- fifo2: fifo rd empty error
  o_errors(4)           <= error_tmp_bis(3);  -- fifo2: fifo wr full error
  o_errors(3)           <= '0';
  o_errors(2)           <= error_tmp_bis(2);  -- fifo0: rst error
  o_errors(1)           <= error_tmp_bis(1);  -- fifo0: fifo rd empty error
  o_errors(0)           <= error_tmp_bis(0);  -- fifo0: fifo wr full error

  o_status(7 downto 2) <= (others => '0');
  o_status(1)          <= empty_sync2;  -- fifo2: empty
  o_status(0)          <= empty_sync1;  -- fifo0: empty
  ---------------------------------------------------------------------
  -- for simulation only
  ---------------------------------------------------------------------
  assert not (error_tmp_bis(5) = '1') report "[regdecode_wire_make_pulse_wr_rd] => FIFO0 is used before the end of the initialization " severity error;
  assert not (error_tmp_bis(4) = '1') report "[regdecode_wire_make_pulse_wr_rd] => FIFO2 read an empty FIFO" severity error;
  assert not (error_tmp_bis(3) = '1') report "[regdecode_wire_make_pulse_wr_rd] => FIFO2 write a full FIFO" severity error;

  assert not (error_tmp_bis(2) = '1') report "[regdecode_wire_make_pulse_wr_rd] => FIFO2 is used before the end of the initialization " severity error;
  assert not (error_tmp_bis(1) = '1') report "[regdecode_wire_make_pulse_wr_rd] => FIFO0 read an empty FIFO" severity error;
  assert not (error_tmp_bis(0) = '1') report "[regdecode_wire_make_pulse_wr_rd] => FIFO0 write a full FIFO" severity error;

end architecture RTL;
