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
--!   @file                   regdecode_wire_wr_rd.vhd 
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

entity regdecode_wire_wr_rd is
  generic(
    g_DATA_WIDTH_OUT : positive := 15   -- define the RAM address width
  );
  port(
    ---------------------------------------------------------------------
    -- from the regdecode: input @i_clk
    ---------------------------------------------------------------------
    i_clk             : in  std_logic;
    i_rst             : in  std_logic;
    -- data
    i_data_valid      : in  std_logic;
    i_data            : in  std_logic_vector(g_DATA_WIDTH_OUT - 1 downto 0);
    ---------------------------------------------------------------------
    -- from/to the user:  @i_out_clk
    ---------------------------------------------------------------------
    i_out_clk         : in  std_logic;
    i_rst_status      : in  std_logic;
    i_debug_pulse     : in  std_logic;
    -- ram: wr
    o_data_valid      : out std_logic;
    o_data            : out std_logic_vector(g_DATA_WIDTH_OUT - 1 downto 0);
    ---------------------------------------------------------------------
    -- to the regdecode: @i_clk
    ---------------------------------------------------------------------
    i_fifo_rd         : in  std_logic;
    o_fifo_data_valid : out std_logic;
    o_fifo_data       : out std_logic_vector(g_DATA_WIDTH_OUT - 1 downto 0);
    o_fifo_empty      : out std_logic;
    ---------------------------------------------------------------------
    -- errors/status @ i_out_clk
    ---------------------------------------------------------------------
    o_errors          : out std_logic_vector(15 downto 0);
    o_status          : out std_logic_vector(7 downto 0)
  );
end entity regdecode_wire_wr_rd;

architecture RTL of regdecode_wire_wr_rd is
  constant c_WR_TO_RD_DELAY : integer := 0;

  ---------------------------------------------------------------------
  -- cross clock domain: redecode to user
  ---------------------------------------------------------------------
  constant c_FIFO_IDX0_L : integer := 0;
  constant c_FIFO_IDX0_H : integer := c_FIFO_IDX0_L + i_data'length - 1;

  constant c_FIFO_DEPTH0 : integer := 16; --see IP
  constant c_FIFO_WIDTH0 : integer := c_FIFO_IDX0_H + 1; --see IP

  signal wr_rst_tmp0  : std_logic;
  signal wr_tmp0      : std_logic;
  signal data_tmp0    : std_logic_vector(c_FIFO_WIDTH0 - 1 downto 0);
  signal full0        : std_logic;
  signal wr_rst_busy0 : std_logic;

  signal rd1          : std_logic;
  signal data_tmp1    : std_logic_vector(c_FIFO_WIDTH0 - 1 downto 0);
  signal empty1       : std_logic;
  signal data_valid1  : std_logic;
  signal rd_rst_busy1 : std_logic;

  signal data1 : std_logic_vector(i_data'range);

  signal error_status1 : std_logic_vector(1 downto 0);

  -- cross clock domain of error fifo flags : i_clk -> i_out_clk
  signal errors_tmp0      : std_logic_vector(1 downto 0);
  signal errors_tmp0_sync : std_logic_vector(1 downto 0);

  ---------------------------------------------------------------------
  -- sync with the rd RAM output 
  ---------------------------------------------------------------------
  constant c_PIPE_IDX0_L : integer := 0;
  constant c_PIPE_IDX0_H : integer := c_PIPE_IDX0_L + i_data'length - 1;

  constant c_PIPE_IDX1_L : integer := c_PIPE_IDX0_H + 1;
  constant c_PIPE_IDX1_H : integer := c_PIPE_IDX1_L + 1 - 1;

  signal data_pipe_tmp0 : std_logic_vector(c_PIPE_IDX1_H downto 0);
  signal data_pipe_tmp1 : std_logic_vector(c_PIPE_IDX1_H downto 0);

  signal data_valid_sync_rx : std_logic;
  signal data_sync_rx       : std_logic_vector(o_data'range);

  ---------------------------------------------------------------------
  -- cross clock domain: user to regdecode
  ---------------------------------------------------------------------
  constant c_FIFO_DEPTH2     : integer := 32; --see IP
  constant c_FIFO_WIDTH2     : integer := c_FIFO_IDX0_H + 1; --see IP


  signal wr_tmp2      : std_logic;
  signal data_tmp2    : std_logic_vector(c_FIFO_WIDTH2 - 1 downto 0);
  signal full2        : std_logic;
  signal wr_rst_busy2 : std_logic;

  signal rd3          : std_logic;
  signal data_tmp3    : std_logic_vector(c_FIFO_WIDTH2 - 1 downto 0);
  signal empty3       : std_logic;
  signal data_valid3  : std_logic;
  signal rd_rst_busy3 : std_logic;

  signal data3 : std_logic_vector(i_data'range);

  signal error_status3 : std_logic_vector(1 downto 0);

  -- cross clock domain of error fifo flags: i_clk -> i_out_clk
  signal errors_tmp3      : std_logic_vector(2 downto 0);
  signal errors_tmp3_sync : std_logic_vector(2 downto 0);


  ---------------------------------------------------------------------
  -- error latching
  ---------------------------------------------------------------------
  constant NB_ERRORS_c : integer := 6;
  signal error_tmp     : std_logic_vector(NB_ERRORS_c - 1 downto 0);
  signal error_tmp_bis : std_logic_vector(NB_ERRORS_c - 1 downto 0);

begin

  ---------------------------------------------------------------------
  -- wr fifo: cross clock domain
  --    .from the regdecode clock domain to the user clock domain
  ---------------------------------------------------------------------
  wr_rst_tmp0                                   <= i_rst;
  wr_tmp0                                       <= i_data_valid;
  data_tmp0(c_FIFO_IDX0_H downto c_FIFO_IDX0_L) <= i_data;

  inst_fifo_async_regdecode_to_user : entity fpasim.fifo_async
    generic map(
      g_CDC_SYNC_STAGES   => 2,
      g_FIFO_MEMORY_TYPE  => "auto",
      g_FIFO_READ_LATENCY => 1,
      g_FIFO_WRITE_DEPTH  => c_FIFO_DEPTH0,
      g_READ_DATA_WIDTH   => data_tmp0'length,
      g_READ_MODE         => "std",
      g_RELATED_CLOCKS    => 0,
      g_WRITE_DATA_WIDTH  => data_tmp0'length
    )
    port map(
      ---------------------------------------------------------------------
      -- write side
      ---------------------------------------------------------------------
      i_wr_clk        => i_clk,         -- write clock
      i_wr_rst        => wr_rst_tmp0,   -- write reset 
      i_wr_en         => wr_tmp0,       -- write enable
      i_wr_din        => data_tmp0,     -- write data
      o_wr_full       => full0,         -- When asserted, this signal indicates that the FIFO is full (not destructive to the contents of the FIFO.)
      o_wr_rst_busy   => wr_rst_busy0,  -- Active-High indicator that the FIFO write domain is currently in a reset state
      ---------------------------------------------------------------------
      -- read side
      ---------------------------------------------------------------------
      i_rd_clk        => i_out_clk,
      i_rd_en         => rd1,           -- read enable (Must be held active-low when rd_rst_busy is active high)
      o_rd_dout_valid => data_valid1,   -- When asserted, this signal indicates that valid data is available on the output bus
      o_rd_dout       => data_tmp1,
      o_rd_empty      => empty1,        -- When asserted, this signal indicates that the FIFO is full (not destructive to the contents of the FIFO.)
      o_rd_rst_busy   => rd_rst_busy1   -- Active-High indicator that the FIFO read domain is currently in a reset state
    );

  rd1 <= '1' when empty1 = '0' else '0';

  data1 <= data_tmp1(c_FIFO_IDX0_H downto c_FIFO_IDX0_L);

  ---------------------------------------------------------------------
  -- synchronize error fifo flags: i_clk -> i_out_clk
  ---------------------------------------------------------------------
  errors_tmp0(1) <= '1' when wr_tmp0 = '1' and wr_rst_busy0 = '1' else '0';
  errors_tmp0(0) <= '1' when wr_tmp0 = '1' and full0 = '1' else '0';
  gen_errors_sync_fifo0 : for i in errors_tmp0'range generate
    inst_single_bit_synchronizer_fifo0 : entity fpasim.single_bit_synchronizer
      generic map(
        g_DEST_SYNC_FF  => 2,
        g_SRC_INPUT_REG => 1
      )
      port map(
        ---------------------------------------------------------------------
        -- source
        ---------------------------------------------------------------------
        i_src_clk  => i_clk,            -- source clock
        i_src      => errors_tmp0(i),   -- input signal to be synchronized to dest_clk domain
        ---------------------------------------------------------------------
        -- destination
        ---------------------------------------------------------------------
        i_dest_clk => i_out_clk,        -- destination clock domain
        o_dest     => errors_tmp0_sync(i) -- src_in synchronized to the destination clock domain. This output is registered.   
      );

  end generate gen_errors_sync_fifo0;

  ---------------------------------------------------------------------
  -- to the user: output
  ---------------------------------------------------------------------
  o_data_valid <= data_valid1;
  o_data       <= data1;

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
  data_valid_sync_rx                                 <= data_pipe_tmp1(c_PIPE_IDX1_H);
  data_sync_rx                                       <= data_pipe_tmp1(c_PIPE_IDX0_H downto c_PIPE_IDX0_L);

  ---------------------------------------------------------------------
  -- cross clock domain: 
  --  from the user clock domain to the regdecode clock domain
  ---------------------------------------------------------------------
  wr_tmp2                                       <= data_valid_sync_rx;
  data_tmp2(c_FIFO_IDX0_H downto c_FIFO_IDX0_L) <= data_sync_rx;

  inst_fifo_async_with_error_user_to_regdecode : entity fpasim.fifo_async_with_error
    generic map(
      g_CDC_SYNC_STAGES   => 2,
      g_FIFO_MEMORY_TYPE  => "auto",
      g_FIFO_READ_LATENCY => 1,
      g_FIFO_WRITE_DEPTH  => c_FIFO_DEPTH2,
      g_READ_DATA_WIDTH   => data_tmp2'length,
      g_READ_MODE         => "std",
      g_RELATED_CLOCKS    => 0,
      g_WRITE_DATA_WIDTH  => data_tmp2'length

    )
    port map(
      ---------------------------------------------------------------------
      -- write side
      ---------------------------------------------------------------------
      i_wr_clk        => i_out_clk,     -- write clock
      i_wr_rst        => i_rst,         -- write reset 
      i_wr_en         => wr_tmp2,       -- write enable
      i_wr_din        => data_tmp2,     -- write data
      o_wr_full       => full2,         -- When asserted, this signal indicates that the FIFO is full (not destructive to the contents of the FIFO.)
      o_wr_rst_busy   => wr_rst_busy2,  -- Active-High indicator that the FIFO write domain is currently in a reset state
      ---------------------------------------------------------------------
      -- read side
      ---------------------------------------------------------------------
      i_rd_clk        => i_clk,
      i_rd_en         => rd3,           -- read enable (Must be held active-low when rd_rst_busy is active high)
      o_rd_dout_valid => data_valid3,   -- When asserted, this signal indicates that valid data is available on the output bus
      o_rd_dout       => data_tmp3,
      o_rd_empty      => empty3,        -- When asserted, this signal indicates that the FIFO is full (not destructive to the contents of the FIFO.)
      o_rd_rst_busy   => rd_rst_busy3   -- Active-High indicator that the FIFO read domain is currently in a reset state
      
    );

  rd3   <= i_fifo_rd;
  data3 <= data_tmp3(c_FIFO_IDX0_H downto c_FIFO_IDX0_L);

  ---------------------------------------------------------------------
  -- synchronize error fifo flags: i_clk -> i_out_clk
  ---------------------------------------------------------------------
  errors_tmp3(2) <= empty3;
  errors_tmp3(1) <= '1' when rd3 = '1' and rd_rst_busy3 = '1' else '0';
  errors_tmp3(0) <= '1' when rd3 = '1' and empty3 = '1' else '0';
  gen_errors_sync_fifo2 : for i in errors_tmp3'range generate
    inst_single_bit_synchronizer_fifo2 : entity fpasim.single_bit_synchronizer
      generic map(
        g_DEST_SYNC_FF  => 2,
        g_SRC_INPUT_REG => 1
      )
      port map(
        ---------------------------------------------------------------------
        -- source
        ---------------------------------------------------------------------
        i_src_clk  => i_clk,            -- source clock
        i_src      => errors_tmp3(i),   -- input signal to be synchronized to dest_clk domain
        ---------------------------------------------------------------------
        -- destination
        ---------------------------------------------------------------------
        i_dest_clk => i_out_clk,        -- destination clock domain
        o_dest     => errors_tmp3_sync(i) -- src_in synchronized to the destination clock domain. This output is registered.   
      );

  end generate gen_errors_sync_fifo2;

  ---------------------------------------------------------------------
  -- to the regdecode: output
  ---------------------------------------------------------------------
  o_fifo_data_valid <= data_valid3;
  o_fifo_data       <= data3;
  o_fifo_empty      <= empty3;

  ---------------------------------------------------------------------
  -- Error latching
  ---------------------------------------------------------------------
  error_tmp(5) <= errors_tmp3_sync(0);  -- fifo2: empty error
  error_tmp(4) <= wr_tmp2 and full2;    -- fifo2: full error
  error_tmp(3) <= (wr_tmp2 and wr_rst_busy2) or errors_tmp3_sync(1); -- fifo2: rst error
  error_tmp(2) <= rd1 and empty1;       -- fifo0: error empty
  error_tmp(1) <= errors_tmp0_sync(0);  -- fifo0: error full
  error_tmp(0) <= errors_tmp0_sync(1) or (rd1 and rd_rst_busy1); -- fifo0: rst error
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

  -- error remapping
  error_status3(1) <= error_tmp_bis(5); -- fifo2: empty error
  error_status3(0) <= error_tmp_bis(4); -- fifo2: full error

  error_status1(1) <= error_tmp_bis(2); -- fifo0: empty error
  error_status1(0) <= error_tmp_bis(1); -- fifo0: full error

  o_errors(15 downto 6) <= (others => '0');
  o_errors(5)           <= error_tmp_bis(3); -- fifo2: rst error
  o_errors(4)           <= error_tmp_bis(0); -- fifo0: rst error
  o_errors(2)           <= error_status3(1); -- fifo2: empty error
  o_errors(2)           <= error_status3(0); -- fifo2: full error
  o_errors(1)           <= error_status1(1); -- fifo0: empty error
  o_errors(0)           <= error_status1(0); -- fifo0: full error

  o_status(7 downto 2) <= (others => '0');
  o_status(1)          <= errors_tmp3_sync(2); -- fifo2: empty
  o_status(0)          <= empty1;

  ---------------------------------------------------------------------
  -- for simulation only
  ---------------------------------------------------------------------
  assert not (error_tmp_bis(3) = '1') report "[regdecode_wire_wr_rd] => FIFO2 is used before the end of the initialization " severity error;
  assert not (error_tmp_bis(0) = '1') report "[regdecode_wire_wr_rd] => FIFO0 is used before the end of the initialization " severity error;

  assert not (error_status3(0) = '1') report "[regdecode_wire_wr_rd] => FIFO2 write a full FIFO" severity error;
  assert not (error_status3(1) = '1') report "[regdecode_wire_wr_rd] => FIFO2 read an empty FIFO" severity error;

  assert not (error_status1(0) = '1') report "[regdecode_wire_wr_rd] => FIFO0 write a full FIFO" severity error;
  assert not (error_status1(1) = '1') report "[regdecode_wire_wr_rd] => FIFO0 read an empty FIFO" severity error;

end architecture RTL;
