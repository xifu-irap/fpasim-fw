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
--   @file                   regdecode_recording_fifo.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--   @details        
--   This module can build packet of usb max packet siz
--
--   The architecture is as follows:
--   
--   i_fifo_data -> async_fifo (small) -> fifo_sync(max usb packet size) -> o_usb_fifo_data 
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_regdecode.all;
use work.pkg_utils.all;

entity regdecode_recording_fifo is
  generic (
    g_DATA_WIDTH : integer := 32
    );
  port(
    ---------------------------------------------------------------------
    -- from the user:  @i_out_clk
    ---------------------------------------------------------------------
    i_out_rst             : in  std_logic;
    i_out_clk             : in  std_logic;  -- output clock
    -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
    -- data
    o_fifo_rd             : out std_logic;  -- read fifo
    i_fifo_sof            : in  std_logic;  -- first packet sample
    i_fifo_eof            : in  std_logic;  -- last packet sample
    i_fifo_data_valid     : in  std_logic;  -- data valid
    i_fifo_data           : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0);  -- data
    i_fifo_empty          : in  std_logic;  -- fifo empty flag
    ---------------------------------------------------------------------
    -- to the usb: @i_clk
    ---------------------------------------------------------------------
    i_clk                 : in  std_logic;  -- clock
    i_rst                 : in  std_logic;  -- reset
    i_rst_status          : in  std_logic;  -- reset error flag(s)
    i_debug_pulse         : in  std_logic;
    -- data
    i_usb_fifo_rd         : in  std_logic;  -- read fifo
    o_usb_fifo_sof        : out std_logic;  -- first packet sample
    o_usb_fifo_eof        : out std_logic;  -- last packet sample
    o_usb_fifo_data_valid : out std_logic;  -- data valid
    o_usb_fifo_data       : out std_logic_vector(g_DATA_WIDTH - 1 downto 0);  -- fifo data
    o_usb_fifo_empty      : out std_logic;  -- fifo empty flag
    o_usb_wr_data_count   : out std_logic_vector(15 downto 0);
    ---------------------------------------------------------------------
    -- errors/status @ i_clk
    ---------------------------------------------------------------------
    o_errors              : out std_logic_vector(15 downto 0);  -- output errors
    o_status              : out std_logic_vector(7 downto 0)  -- output status
    );
end entity regdecode_recording_fifo;

architecture RTL of regdecode_recording_fifo is

  ---------------------------------------------------------------------
  -- fifo cross clock domain
  ---------------------------------------------------------------------
  constant c_FIFO_IDX0_L : integer := 0;
  constant c_FIFO_IDX0_H : integer := c_FIFO_IDX0_L + i_fifo_data'length - 1;

  constant c_FIFO_IDX1_L : integer := c_FIFO_IDX0_H + 1;
  constant c_FIFO_IDX1_H : integer := c_FIFO_IDX1_L + 1 - 1;

  constant c_FIFO_IDX2_L : integer := c_FIFO_IDX1_H + 1;
  constant c_FIFO_IDX2_H : integer := c_FIFO_IDX2_L + 1 - 1;

  -- find the power of 2 superior to the g_DELAY
  constant c_FIFO_DEPTH0       : integer := 16;                 --see IP
  constant c_PROG_FULL_THRESH0 : integer := c_FIFO_DEPTH0 - 6;  --see IP
  constant c_FIFO_WIDTH0       : integer := c_FIFO_IDX2_H + 1;  --see IP

  signal ready0        : std_logic;
  signal wr_rst0       : std_logic;
  signal wr_tmp0       : std_logic;
  signal wr_data_tmp0  : std_logic_vector(c_FIFO_WIDTH0 - 1 downto 0);
  signal wr_full0      : std_logic;
  signal wr_prog_full0 : std_logic;
  signal wr_rst_busy0  : std_logic;

  signal rd1          : std_logic;
  signal data_valid1  : std_logic;
  signal data_tmp1    : std_logic_vector(c_FIFO_WIDTH0 - 1 downto 0);
  signal empty1       : std_logic;
  signal rd_rst_busy1 : std_logic;

  signal errors_sync1 : std_logic_vector(3 downto 0);
  signal empty_sync1  : std_logic;

  ---------------------------------------------------------------------
  -- output fifo
  ---------------------------------------------------------------------
  -- find the power of 2 superior to the g_DELAY
  constant c_FIFO_DEPTH2          : integer := 512;                --see IP
  constant c_PROG_FULL_THRESH2    : integer := c_FIFO_DEPTH2 - 6;  --see IP
  constant c_FIFO_WIDTH2          : integer := c_FIFO_IDX2_H + 1;  --see IP
  constant c_WR_DATA_COUNT_WIDTH2 : integer := pkg_width_from_value(c_FIFO_DEPTH2) + 1;

  signal ready2         : std_logic;
  signal wr_rst2        : std_logic;
  signal wr_tmp2        : std_logic;
  signal wr_data_tmp2   : std_logic_vector(c_FIFO_WIDTH2 - 1 downto 0);
  signal wr_data_count2 : std_logic_vector(c_WR_DATA_COUNT_WIDTH2 - 1 downto 0);
  signal wr_full2       : std_logic;
  signal wr_prog_full2  : std_logic;
  signal wr_rst_busy2   : std_logic;

  signal rd3          : std_logic;
  signal data_valid3  : std_logic;
  signal data_tmp3    : std_logic_vector(c_FIFO_WIDTH2 - 1 downto 0);
  signal empty3       : std_logic;
  signal rd_rst_busy3 : std_logic;

  signal sof3  : std_logic;
  signal eof3  : std_logic;
  signal data3 : std_logic_vector(o_usb_fifo_data'range);

  signal errors_sync3 : std_logic_vector(3 downto 0);
  signal empty_sync3  : std_logic;

  ---------------------------------------------------------------------
  -- error latching
  ---------------------------------------------------------------------
  constant NB_ERRORS_c : integer := 6;
  signal error_tmp     : std_logic_vector(NB_ERRORS_c - 1 downto 0);
  signal error_tmp_bis : std_logic_vector(NB_ERRORS_c - 1 downto 0);

begin
---------------------------------------------------------------------
-- clock cross domain : @i_out_clk -> i_clk
---------------------------------------------------------------------
  p_fifo_auto_read : process (i_out_clk) is
  begin
    if rising_edge(i_out_clk) then
      ready0 <= not(wr_prog_full0);
    end if;
  end process p_fifo_auto_read;
  o_fifo_rd <= '1' when i_fifo_empty = '0' and ready0 = '1' else '0';

  wr_rst0                                          <= i_out_rst;
  wr_tmp0                                          <= i_fifo_data_valid;
  wr_data_tmp0(c_FIFO_IDX2_H)                      <= i_fifo_eof;
  wr_data_tmp0(c_FIFO_IDX1_H)                      <= i_fifo_eof;
  wr_data_tmp0(c_FIFO_IDX0_H downto c_FIFO_IDX0_L) <= i_fifo_data;

  inst_fifo_async_with_error_prog_full : entity work.fifo_async_with_error_prog_full
    generic map(
      g_CDC_SYNC_STAGES   => 2,
      g_FIFO_MEMORY_TYPE  => "auto",
      g_FIFO_READ_LATENCY => 1,
      g_FIFO_WRITE_DEPTH  => c_FIFO_DEPTH0,
      g_PROG_FULL_THRESH  => c_PROG_FULL_THRESH0,
      g_READ_DATA_WIDTH   => wr_data_tmp0'length,
      g_READ_MODE         => "std",
      g_RELATED_CLOCKS    => 0,
      g_WRITE_DATA_WIDTH  => wr_data_tmp0'length,
      g_SYNC_SIDE         => "rd"  -- define the clock side where status/errors is resynchronised. Possible value "wr" or "rd"
      )
    port map(
      ---------------------------------------------------------------------
      -- write side
      ---------------------------------------------------------------------
      i_wr_clk        => i_out_clk,
      i_wr_rst        => wr_rst0,
      i_wr_en         => wr_tmp0,
      i_wr_din        => wr_data_tmp0,
      o_wr_full       => wr_full0,
      o_wr_prog_full  => wr_prog_full0,
      o_wr_rst_busy   => wr_rst_busy0,
      ---------------------------------------------------------------------
      -- read side
      ---------------------------------------------------------------------
      i_rd_clk        => i_clk,
      i_rd_en         => rd1,
      o_rd_dout_valid => data_valid1,
      o_rd_dout       => data_tmp1,
      o_rd_empty      => empty1,
      o_rd_rst_busy   => rd_rst_busy1,
      ---------------------------------------------------------------------
      -- resynchronized errors/ empty status 
      ---------------------------------------------------------------------
      o_errors_sync   => errors_sync1,
      o_empty_sync    => empty_sync1
      );

---------------------------------------------------------------------
-- output FIFO: usb packet max size
---------------------------------------------------------------------
  p_fifo_auto_read2 : process (i_clk) is
  begin
    if rising_edge(i_clk) then
      ready2 <= not(wr_prog_full2);
    end if;
  end process p_fifo_auto_read2;
  rd1 <= '1' when empty1 = '0' and ready2 = '1' else '0';

  wr_rst2      <= i_rst;
  wr_tmp2      <= data_valid1;
  wr_data_tmp2 <= data_tmp1;

  inst_fifo_sync_with_error_prog_full_wr_count : entity work.fifo_sync_with_error_prog_full_wr_count
    generic map(
      g_FIFO_MEMORY_TYPE    => "auto",
      g_FIFO_READ_LATENCY   => 1,
      g_FIFO_WRITE_DEPTH    => c_FIFO_DEPTH2,
      g_PROG_FULL_THRESH    => c_PROG_FULL_THRESH2,
      g_READ_DATA_WIDTH     => wr_data_tmp2'length,
      g_READ_MODE           => "std",
      g_WRITE_DATA_WIDTH    => wr_data_tmp2'length,
      g_WR_DATA_COUNT_WIDTH => c_WR_DATA_COUNT_WIDTH2
      )
    port map(
      ---------------------------------------------------------------------
      -- write side
      ---------------------------------------------------------------------
      i_wr_clk        => i_clk,
      i_wr_rst        => wr_rst2,
      i_wr_en         => wr_tmp2,
      i_wr_din        => wr_data_tmp2,
      o_wr_full       => wr_full2,
      o_wr_prog_full  => wr_prog_full2,
      o_wr_data_count => wr_data_count2,
      o_wr_rst_busy   => wr_rst_busy2,
      ---------------------------------------------------------------------
      -- read side
      ---------------------------------------------------------------------
      i_rd_en         => rd3,
      o_rd_dout_valid => data_valid3,
      o_rd_dout       => data_tmp3,
      o_rd_empty      => empty3,
      o_rd_rst_busy   => rd_rst_busy3,
---------------------------------------------------------------------
      -- errors/status
      --------------------------------------------------------------------- 
      o_errors_sync   => errors_sync3,
      o_empty_sync    => empty_sync3
      );

  rd3                   <= i_usb_fifo_rd;
  sof3                  <= data_tmp3(c_FIFO_IDX2_H);
  eof3                  <= data_tmp3(c_FIFO_IDX1_H);
  data3                 <= data_tmp3(c_FIFO_IDX0_H downto c_FIFO_IDX0_L);
---------------------------------------------------------------------
-- output
---------------------------------------------------------------------
  o_usb_fifo_sof        <= sof3;
  o_usb_fifo_eof        <= eof3;
  o_usb_fifo_data_valid <= data_valid3;
  o_usb_fifo_data       <= data3;
  o_usb_fifo_empty      <= empty3;
  o_usb_wr_data_count   <= std_logic_vector(resize(unsigned(wr_data_count2), o_usb_wr_data_count'length));
---------------------------------------------------------------------
-- errors/status
---------------------------------------------------------------------
  error_tmp(5)          <= errors_sync3(2) or errors_sync3(3);  -- fifo rst error
  error_tmp(4)          <= errors_sync3(1);  -- fifo rd empty error
  error_tmp(3)          <= errors_sync3(0);  -- fifo wr full error
  error_tmp(2)          <= errors_sync1(2) or errors_sync1(3);  -- fifo rst error
  error_tmp(1)          <= errors_sync1(1);  -- fifo rd empty error
  error_tmp(0)          <= errors_sync1(0);  -- fifo wr full error
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

  o_errors(15 downto 8) <= (others => '0');
  o_errors(7)           <= '0';
  o_errors(6)           <= error_tmp_bis(5);
  o_errors(5)           <= error_tmp_bis(4);
  o_errors(4)           <= error_tmp_bis(3);
  o_errors(3)           <= '0';
  o_errors(2)           <= error_tmp_bis(2);
  o_errors(1)           <= error_tmp_bis(1);
  o_errors(0)           <= error_tmp_bis(0);

  o_status(7 downto 2) <= (others => '0');
  o_status(1)          <= empty_sync3;
  o_status(0)          <= empty_sync1;

end architecture RTL;
