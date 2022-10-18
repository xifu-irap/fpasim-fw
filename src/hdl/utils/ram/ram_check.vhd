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
--!   @file                   ram_check.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--
-- This module checks the good utilization of a RAM.
-- Usually, RAM doesn't support write and read access on the same memory slot at the same time.
-- So, the module generates an error if a RAM is accessed in reading and in writing at the same time.
--
-- Note: 
--   . if the write address width = read address width then an immediate comparison is done
--   . if the write address width < read address width then the read side address is converted 
--     => before comparison, the read address is shifted to the right to get the same representation as the write side (word representation)
--   . if the write address width > read address width then the write side address is converted
--     => before comparison, the write address is shifted to the right to get the same representation as the read side (word representation)
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fpasim;

entity ram_check is
  generic(
    g_WR_ADDR_WIDTH : positive := 16;
    g_RD_ADDR_WIDTH : positive := 16
  );
  port(
    i_clk         : in  std_logic;
    ---------------------------------------------------------------------
    -- input
    ---------------------------------------------------------------------
    i_wr          : in  std_logic;
    i_wr_addr     : in  std_logic_vector(g_WR_ADDR_WIDTH - 1 downto 0);
    i_rd          : in  std_logic;
    i_rd_addr     : in  std_logic_vector(g_RD_ADDR_WIDTH - 1 downto 0);
    ---------------------------------------------------------------------
    -- Errors
    ---------------------------------------------------------------------
    o_error_pulse : out std_logic
  );
end entity ram_check;

architecture RTL of ram_check is
  constant c_SHIFT_ADDR0 : integer := g_WR_ADDR_WIDTH - g_RD_ADDR_WIDTH;
  constant c_SHIFT_ADDR1 : integer := g_RD_ADDR_WIDTH - g_WR_ADDR_WIDTH;

  ---------------------------------------------------------------------
  -- pipeline
  ---------------------------------------------------------------------
  constant c_IDX0_L : integer := 0;
  constant c_IDX0_H : integer := c_IDX0_L + i_wr_addr'length - 1;

  constant c_IDX1_L : integer := c_IDX0_H + 1;
  constant c_IDX1_H : integer := c_IDX1_L + i_rd_addr'length - 1;

  constant c_IDX2_L : integer := c_IDX1_H + 1;
  constant c_IDX2_H : integer := c_IDX2_L + 1 - 1;

  constant c_IDX3_L : integer := c_IDX2_H + 1;
  constant c_IDX3_H : integer := c_IDX3_L + 1 - 1;

  signal data_pipe_tmp0 : std_logic_vector(c_IDX3_H downto 0);
  signal data_pipe_tmp1 : std_logic_vector(c_IDX3_H downto 0);

  signal wr1      : std_logic;
  signal wr_addr1 : std_logic_vector(i_wr_addr'range);

  signal rd1      : std_logic;
  signal rd_addr1 : std_logic_vector(i_rd_addr'range);

  ---------------------------------------------------------------------
  -- p_error
  ---------------------------------------------------------------------
  signal error_r2 : std_logic := '0';

begin

  data_pipe_tmp0(c_IDX3_H)                 <= i_rd;
  data_pipe_tmp0(c_IDX2_H)                 <= i_wr;
  data_pipe_tmp0(c_IDX1_H downto c_IDX1_L) <= i_rd_addr;
  data_pipe_tmp0(c_IDX0_H downto c_IDX0_L) <= i_wr_addr;
  inst_pipeliner : entity fpasim.pipeliner
    generic map(
      g_NB_PIPES   => 1,
      g_DATA_WIDTH => data_pipe_tmp0'length
    )
    port map(
      i_clk  => i_clk,
      i_data => data_pipe_tmp0,
      o_data => data_pipe_tmp1
    );

  rd1      <= data_pipe_tmp1(c_IDX3_H);
  wr1      <= data_pipe_tmp1(c_IDX2_H);
  rd_addr1 <= data_pipe_tmp1(c_IDX1_H downto c_IDX1_L);
  wr_addr1 <= data_pipe_tmp1(c_IDX0_H downto c_IDX0_L);

  ---------------------------------------------------------------------
  -- RAM: symetric address on the write and read side
  ---------------------------------------------------------------------
  gen_sym_addr_width : if g_WR_ADDR_WIDTH = g_RD_ADDR_WIDTH generate
    signal wr_addr_tmp : unsigned(i_wr_addr'range);
    signal rd_addr_tmp : unsigned(i_rd_addr'range);

    signal wr_addr_r : unsigned(i_wr_addr'range):= (others => '0');
    signal rd_addr_r : unsigned(i_rd_addr'range):= (others => '0');

    signal trig_r : std_logic := '0';
  begin
    wr_addr_tmp <= unsigned(wr_addr1);
    rd_addr_tmp <= unsigned(rd_addr1);

    p_check_addr : process(i_clk) is
    begin
      if rising_edge(i_clk) then
        trig_r <= wr1 and rd1;
        if wr1 = '1' then
          wr_addr_r <= wr_addr_tmp;
        end if;
        if rd1 = '1' then
          rd_addr_r <= rd_addr_tmp;
        end if;
      end if;
    end process p_check_addr;

    p_error : process(i_clk) is
    begin
      if rising_edge(i_clk) then
        if wr_addr_r = rd_addr_r then
          error_r2 <= trig_r;
        else
          error_r2 <= '0';
        end if;
      end if;
    end process p_error;

  end generate gen_sym_addr_width;

  ---------------------------------------------------------------------
  -- RAM : asymetric address on the write and the read side
  --       g_WR_ADDR_WIDTH < g_RD_ADDR_WIDTH 
  ---------------------------------------------------------------------
  gen_asym_wr_addr_inf_rd_addr_width_g : if g_WR_ADDR_WIDTH < g_RD_ADDR_WIDTH generate
    signal wr_addr_tmp : unsigned(i_wr_addr'range);
    signal rd_addr_tmp : unsigned(i_wr_addr'range);

    signal wr_addr_r : unsigned(i_wr_addr'range):= (others => '0');
    signal rd_addr_r : unsigned(i_wr_addr'range):= (others => '0');

    signal trig_r : std_logic := '0';

  begin
    wr_addr_tmp <= unsigned(wr_addr1);
    rd_addr_tmp <= resize(unsigned(rd_addr1) srl c_SHIFT_ADDR1, wr_addr_tmp'length);

    p_check_addr : process(i_clk) is
    begin
      if rising_edge(i_clk) then
        trig_r <= wr1 and rd1;
        if wr1 = '1' then
          wr_addr_r <= wr_addr_tmp;
        end if;
        if rd1 = '1' then
          rd_addr_r <= rd_addr_tmp;
        end if;
      end if;
    end process p_check_addr;

    p_error : process(i_clk) is
    begin
      if rising_edge(i_clk) then
        if wr_addr_r = rd_addr_r then
          error_r2 <= trig_r;
        else
          error_r2 <= '0';
        end if;
      end if;
    end process p_error;

  end generate gen_asym_wr_addr_inf_rd_addr_width_g;

  ---------------------------------------------------------------------
  -- RAM : asymetric address on the write and the read side
  --       g_WR_ADDR_WIDTH < g_RD_ADDR_WIDTH
  ---------------------------------------------------------------------
  gen_asym_wr_addr_sup_rd_addr_width : if g_WR_ADDR_WIDTH > g_RD_ADDR_WIDTH generate
    signal wr_addr_tmp : unsigned(i_rd_addr'range);
    signal rd_addr_tmp : unsigned(i_rd_addr'range);

    signal wr_addr_r : unsigned(i_rd_addr'range):= (others => '0');
    signal rd_addr_r : unsigned(i_rd_addr'range):= (others => '0');

    signal trig_r : std_logic := '0';
  begin
    wr_addr_tmp <= resize(unsigned(wr_addr1) srl c_SHIFT_ADDR0, rd_addr_tmp'length);
    rd_addr_tmp <= unsigned(rd_addr1);

    p_check_addr : process(i_clk) is
    begin
      if rising_edge(i_clk) then
        trig_r <= wr1 and rd1;
        if wr1 = '1' then
          wr_addr_r <= wr_addr_tmp;
        end if;
        if rd1 = '1' then
          rd_addr_r <= rd_addr_tmp;
        end if;
      end if;
    end process p_check_addr;

    p_error : process(i_clk) is
    begin
      if rising_edge(i_clk) then
        if wr_addr_r = rd_addr_r then
          error_r2 <= trig_r;
        else
          error_r2 <= '0';
        end if;
      end if;
    end process p_error;

  end generate gen_asym_wr_addr_sup_rd_addr_width;

  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_error_pulse <= error_r2;

  ---------------------------------------------------------------------
  -- for simulation only
  ---------------------------------------------------------------------
  assert not (error_r2 = '1') report "[ram_check] => possible data corruption" severity error;

end architecture RTL;
