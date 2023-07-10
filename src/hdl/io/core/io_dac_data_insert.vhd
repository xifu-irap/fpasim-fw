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
--    @file                   io_dac_data_insert.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This module does the following steps:
--       . pass data words from @sys_clk to the @i_dac_clk (async FIFO)
--    At the output of the internal async fifo,
--       .for each channel and word, the corresponding dac data bytes are splitted in order to send the MSB bytes first (see dac3283 datasheet).
--       .for each word, the dac_frame bit is duplicated.
--
--    The architecture is as follows:
--      @i_clk                              -------->     @i_dac_clk                  ---->  output
--      i_dac1 (16 bits) & i_dac0(16 bits)  -------->     ASYNC_FIFO                  ---->  64 bit-word
--      i_dac_frame (1 bits)                -------->                (duplicate bits) ---->  8 bit-word
--
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.pkg_io.all;

entity io_dac_data_insert is
  port(
    ---------------------------------------------------------------------
    -- input @i_clk
    ---------------------------------------------------------------------
    i_clk         : in std_logic;       -- clock signal
    i_rst         : in std_logic;       -- reset signal
    i_rst_status  : in std_logic;       -- reset error flag(s)
    i_debug_pulse : in std_logic;  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
    i_dac_valid   : in std_logic;       -- input dac valid  value
    i_dac_frame   : in std_logic;       -- first sample of the frame
    i_dac1        : in std_logic_vector(15 downto 0);  -- dac0 value
    i_dac0        : in std_logic_vector(15 downto 0);  -- dac0 value

    ---------------------------------------------------------------------
    -- output @i_dac_clk
    ---------------------------------------------------------------------
    i_dac_clk   : in  std_logic;        -- dac clock
    o_dac_valid : out std_logic;        -- valid dac value
    o_dac_frame : out std_logic_vector(7 downto 0);  -- first sample of a frame
    o_dac       : out std_logic_vector(63 downto 0);  -- dac value

    ---------------------------------------------------------------------
    -- errors/status @i_clk
    ---------------------------------------------------------------------
    o_errors : out std_logic_vector(15 downto 0);  -- output errors
    o_status : out std_logic_vector(7 downto 0)    -- output status
    );
end entity io_dac_data_insert;

architecture RTL of io_dac_data_insert is
  constant c_FIFO_CDC_LATENCY  : natural := pkg_IO_DAC_FIFO_CDC_STAGE;
  constant c_FIFO_READ_LATENCY : natural := pkg_IO_DAC_FIFO_READ_LATENCY;

  ---------------------------------------------------------------------
  -- FIFO
  ---------------------------------------------------------------------
  constant c_WR_IDX0_L : integer := 0;
  constant c_WR_IDX0_H : integer := c_WR_IDX0_L + i_dac0'length - 1;

  constant c_WR_IDX1_L : integer := c_WR_IDX0_H + 1;
  constant c_WR_IDX1_H : integer := c_WR_IDX1_L + i_dac1'length - 1;

  constant c_WR_IDX2_L : integer := c_WR_IDX1_H + 1;
  constant c_WR_IDX2_H : integer := c_WR_IDX2_L + 1 - 1;

  -- find the power of 2 superior to the g_DELAY
  constant c_FIFO_DEPTH    : integer := 512;  --see IP
  constant c_WR_FIFO_WIDTH : integer := c_WR_IDX2_H + 1;
  constant c_RD_FIFO_WIDTH : integer := c_WR_FIFO_WIDTH*2;

  signal wr_rst_tmp0 : std_logic;
  signal wr_tmp0     : std_logic;
  signal data_tmp0   : std_logic_vector(c_WR_FIFO_WIDTH - 1 downto 0);
  --signal full0        : std_logic;
  --signal wr_rst_busy0 : std_logic;

  signal rd1             : std_logic;
  signal data_valid_tmp1 : std_logic;
  signal data_tmp1       : std_logic_vector(c_RD_FIFO_WIDTH - 1 downto 0);
  signal empty1          : std_logic;
  signal rd_rst_busy1    : std_logic;

  signal word0 : std_logic_vector(32 downto 0);
  signal word1 : std_logic_vector(32 downto 0);

  -- signal data_valid1 : std_logic;

  -- word0
  signal dac_frame_word0 : std_logic;
  signal dac1_word0      : std_logic_vector(i_dac0'range);
  signal dac0_word0      : std_logic_vector(i_dac0'range);

  -- word1
  signal dac_frame_word1 : std_logic;
  signal dac1_word1      : std_logic_vector(i_dac1'range);
  signal dac0_word1      : std_logic_vector(i_dac1'range);

  -- resynchronized errors/status
  signal errors_sync0 : std_logic_vector(3 downto 0);
  signal empty_sync0  : std_logic;

  ---------------------------------------------------------------------
  -- bit mapping
  ---------------------------------------------------------------------
  signal dac_tmp       : std_logic_vector(o_dac'range);
  signal dac_frame_tmp : std_logic_vector(o_dac_frame'range);

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
  wr_tmp0                                   <= i_dac_valid;
  data_tmp0(c_WR_IDX2_H)                    <= i_dac_frame;
  data_tmp0(c_WR_IDX1_H downto c_WR_IDX1_L) <= i_dac1;
  data_tmp0(c_WR_IDX0_H downto c_WR_IDX0_L) <= i_dac0;
  wr_rst_tmp0                               <= i_rst;
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
      i_rd_clk        => i_dac_clk,
      i_rd_en         => rd1,
      o_rd_dout_valid => data_valid_tmp1,
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

  word1 <= data_tmp1(65 downto 33);
  word0 <= data_tmp1(32 downto 0);

  -- word1
  dac_frame_word1 <= word1(32);
  dac1_word1      <= word1(31 downto 16);
  dac0_word1      <= word1(15 downto 0);
  -- word0
  dac_frame_word0 <= word0(32);
  dac1_word0      <= word0(31 downto 16);
  dac0_word0      <= word0(15 downto 0);

  ---------------------------------------------------------------------
  -- bit mapping of the dac data
  --  with data_tmp(i) <= dac0/1(j)
  --     i: the index is taken from ip/xilinx/coregen/selectio_wiz_dac/selectio_wiz_dac_sim_netlist
  --     j: the index must follows the dac datasheet (dac3283)
  --  example:
  --   .serial link0, data: bit8 -> bit0
  --       dac_tmp(56) <= dac1_word1(0);-- bit0 dac channel1 word1
  --       dac_tmp(48) <= dac1_word1(8);-- bit8 dac channel1 word1
  --       dac_tmp(40) <= dac0_word1(0);-- bit0 dac channel0 word1
  --       dac_tmp(32) <= dac0_word1(8);-- bit8 dac channel0 word1
  --       dac_tmp(24) <= dac1_word0(0);-- bit0 dac channel1 word0
  --       dac_tmp(16) <= dac1_word0(8);-- bit8 dac channel1 word0
  --       dac_tmp(8)  <= dac0_word0(0);-- bit0 dac channel0 word0
  --       dac_tmp(0)  <= dac0_word0(8);-- bit8 dac channel0 word0
  --   .serial link1, data: bit9 -> bit1
  --       dac_tmp(57) <= dac1_word1(1);-- bit1 dac channel1 word1
  --       dac_tmp(49) <= dac1_word1(9);-- bit9 dac channel1 word1
  --       dac_tmp(41) <= dac0_word1(1);-- bit1 dac channel0 word1
  --       dac_tmp(33) <= dac0_word1(9);-- bit9 dac channel0 word1
  --       dac_tmp(25) <= dac1_word0(1);-- bit1 dac channel1 word0
  --       dac_tmp(17) <= dac1_word0(9);-- bit9 dac channel1 word0
  --       dac_tmp(9)  <= dac0_word0(1);-- bit1 dac channel0 word0
  --       dac_tmp(1)  <= dac0_word0(9);-- bit9 dac channel0 word0
  ---------------------------------------------------------------------
  -- j = number of serial links
  gen_serial_index : for i in 0 to 7 generate
    -- the bytes will be sent in the following order (see the dac3283 datasheet):
    --   1.dac0_word0_byte1
    --   2.dac0_word0_byte0
    --   3.dac1_word0_byte1
    --   4.dac1_word0_byte0
    --   5.dac0_word1_byte1
    --   6.dac0_word1_byte0
    --   7.dac1_word1_byte1
    --   8.dac1_word1_byte0
    dac_tmp(i+56) <= dac1_word1(i+0);   -- byte0 dac channel1 word1
    dac_tmp(i+48) <= dac1_word1(i+8);   -- byte1 dac channel1 word1
    dac_tmp(i+40) <= dac0_word1(i+0);   -- byte0 dac channel0 word1
    dac_tmp(i+32) <= dac0_word1(i+8);   -- byte1 dac channel0 word1
    dac_tmp(i+24) <= dac1_word0(i+0);   -- byte0 dac channel1 word0
    dac_tmp(i+16) <= dac1_word0(i+8);   -- byte1 dac channel1 word0
    dac_tmp(i+8)  <= dac0_word0(i+0);   -- byte0 dac channel0 word0
    dac_tmp(i+0)  <= dac0_word0(i+8);   -- byte1 dac channel0 word0
  end generate gen_serial_index;

  ---------------------------------------------------------------------
  -- bit mapping of the dac_frame
  -- the bits will be sent in the following order:
  --   1.dac_frame_word0
  --   2.dac_frame_word0
  --   3.dac_frame_word0
  --   4.dac_frame_word0
  --   5.dac_frame_word1
  --   6.dac_frame_word1
  --   7.dac_frame_word1
  --   8.dac_frame_word1
  ---------------------------------------------------------------------
  dac_frame_tmp(7) <= dac_frame_word1;  -- 4th bit from the dac_frame word1 (duplicated)
  dac_frame_tmp(6) <= dac_frame_word1;  -- 3th bit from the dac_frame word1 (duplicated)
  dac_frame_tmp(5) <= dac_frame_word1;  -- 4th bit from the dac_frame word1 (duplicated)
  dac_frame_tmp(4) <= dac_frame_word1;  -- 3th bit from the dac_frame word1
  dac_frame_tmp(3) <= dac_frame_word0;  -- 2nd bit from the dac_frame word0 (duplicated)
  dac_frame_tmp(2) <= dac_frame_word0;  -- 1st bit from the dac_frame word0 (duplicated)
  dac_frame_tmp(1) <= dac_frame_word0;  -- 2nd bit from the dac_frame word0 (duplicated)
  dac_frame_tmp(0) <= dac_frame_word0;  -- 1st bit from the dac_frame word0

  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_dac_valid  <= data_valid_tmp1;
  o_dac_frame  <= dac_frame_tmp;
  o_dac        <= dac_tmp;
  ---------------------------------------------------------------------
  -- Error latching
  ---------------------------------------------------------------------
  error_tmp(2) <= errors_sync0(2) or errors_sync0(3);  -- fifo rst error
  error_tmp(1) <= errors_sync0(1);                     -- fifo rd empty error
  error_tmp(0) <= errors_sync0(0);                     -- fifo wr full error
  error_flag_mng : for i in error_tmp'range generate
    inst_one_error_latch : entity work.one_error_latch
      port map(
        i_clk         => i_clk,
        i_rst         => i_rst_status,
        i_debug_pulse => i_debug_pulse,
        i_error       => error_tmp(i),
        o_error       => error_tmp_bis(i)
        );
  end generate error_flag_mng;

  o_errors(15 downto 3) <= (others => '0');
  o_errors(2)           <= error_tmp_bis(0);  -- fifo rst error
  o_errors(1)           <= error_tmp_bis(2);  -- fifo rd empty error
  o_errors(0)           <= error_tmp_bis(1);  -- fifo wr full error

  o_status(7 downto 1) <= (others => '0');
  o_status(0)          <= empty_sync0;

  ---------------------------------------------------------------------
  -- for simulation only
  ---------------------------------------------------------------------
  assert not (error_tmp_bis(2) = '1') report "[io_dac_data_insert] => FIFO is used before the end of the initialization " severity error;
  assert not (error_tmp_bis(1) = '1') report "[io_dac_data_insert] => FIFO read an empty FIFO" severity error;
  assert not (error_tmp_bis(0) = '1') report "[io_dac_data_insert] => FIFO write a full FIFO" severity error;



end architecture RTL;
