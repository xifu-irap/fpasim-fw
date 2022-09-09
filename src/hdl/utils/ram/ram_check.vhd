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


entity ram_check is
  generic (
    g_WR_ADDR_WIDTH : positive := 16;
    g_RD_ADDR_WIDTH : positive := 16
    );
  port (
    i_clk : in std_logic;

    ---------------------------------------------------------------------
    -- input
    ---------------------------------------------------------------------
    i_wr      : in std_logic;
    i_wr_addr : in std_logic_vector(g_WR_ADDR_WIDTH - 1 downto 0);

    i_rd      : in std_logic;
    i_rd_addr : in std_logic_vector(g_RD_ADDR_WIDTH - 1 downto 0);

    ---------------------------------------------------------------------
    -- Errors
    ---------------------------------------------------------------------
    o_error_pulse : out std_logic
    );
end entity ram_check;

architecture RTL of ram_check is
constant c_SHIFT_ADDR0 : integer := g_WR_ADDR_WIDTH - g_RD_ADDR_WIDTH;
constant c_SHIFT_ADDR1 : integer := g_RD_ADDR_WIDTH - g_WR_ADDR_WIDTH;

-- length(wr_addr) = length(rd_addr)
signal wr_addr_tmp : unsigned(i_wr_addr'range);
signal rd_addr_tmp : unsigned(i_rd_addr'range);

-- length(wr_addr) < length(rd_addr)
signal rd_addr_tmp0 : unsigned(i_wr_addr'range);
-- length(wr_addr) > length(rd_addr)
signal wr_addr_tmp0 : unsigned(i_rd_addr'range);

---------------------------------------------------------------------
-- p_check_addr
---------------------------------------------------------------------
  signal wr_r         : std_logic:= '0';
  signal rd_r         : std_logic:= '0';
  signal error_addr_r : std_logic := '0';

---------------------------------------------------------------------
-- p_error
---------------------------------------------------------------------
  signal error_r2 : std_logic := '0';

begin
---------------------------------------------------------------------
-- RAM: symetric address on the write and read side
---------------------------------------------------------------------
gen_sym_addr_width: if g_WR_ADDR_WIDTH = g_RD_ADDR_WIDTH generate
  wr_addr_tmp <= unsigned(i_wr_addr);
  rd_addr_tmp <= unsigned(i_rd_addr);

  p_check_addr : process (i_clk) is
  begin
    if rising_edge(i_clk) then
      wr_r <= i_wr;
      rd_r <= i_rd;

      if wr_addr_tmp = rd_addr_tmp then
        error_addr_r <= '1';
      else
        error_addr_r <= '0';
      end if;
    end if;
  end process p_check_addr;
end generate gen_sym_addr_width;

---------------------------------------------------------------------
-- RAM : asymetric address on the write and the read side
--       g_WR_ADDR_WIDTH < g_RD_ADDR_WIDTH 
---------------------------------------------------------------------
gen_asym_wr_addr_inf_rd_addr_width_g: if g_WR_ADDR_WIDTH < g_RD_ADDR_WIDTH generate
  wr_addr_tmp <= unsigned(i_wr_addr);
  rd_addr_tmp0 <= resize(unsigned(i_rd_addr) srl c_SHIFT_ADDR1, wr_addr_tmp'length);

  p_check_addr : process (i_clk) is
  begin
    if rising_edge(i_clk) then
      wr_r <= i_wr;
      rd_r <= i_rd;

      if wr_addr_tmp = rd_addr_tmp0 then
        error_addr_r <= '1';
      else
        error_addr_r <= '0';
      end if;
    end if;
  end process p_check_addr;
end generate gen_asym_wr_addr_inf_rd_addr_width_g;

---------------------------------------------------------------------
-- RAM : asymetric address on the write and the read side
--       g_WR_ADDR_WIDTH < g_RD_ADDR_WIDTH
---------------------------------------------------------------------
gen_asym_wr_addr_sup_rd_addr_width: if g_WR_ADDR_WIDTH > g_RD_ADDR_WIDTH generate
  wr_addr_tmp0 <= resize(unsigned(i_wr_addr) srl c_SHIFT_ADDR0,rd_addr_tmp'length);
  rd_addr_tmp  <= unsigned(i_rd_addr);
  
  p_check_addr : process (i_clk) is
  begin
    if rising_edge(i_clk) then
      wr_r <= i_wr;
      rd_r <= i_rd;

      if wr_addr_tmp0 = rd_addr_tmp then
        error_addr_r <= '1';
      else
        error_addr_r <= '0';
      end if;
    end if;
  end process p_check_addr;
end generate gen_asym_wr_addr_sup_rd_addr_width;

---------------------------------------------------------------------
-- p_error
---------------------------------------------------------------------
  p_error : process (i_clk) is
  begin
    if rising_edge(i_clk) then
      if wr_r = '1' and rd_r = '1' and error_addr_r = '1' then
        error_r2 <= '1';
      else
        error_r2 <= '0';
      end if;
    end if;
  end process p_error;

  o_error_pulse <= error_r2;

---------------------------------------------------------------------
-- for simulation only
---------------------------------------------------------------------
  assert not(error_r2 = '1') report "[ram_check] => possible data corruption" severity error;



end architecture RTL;
