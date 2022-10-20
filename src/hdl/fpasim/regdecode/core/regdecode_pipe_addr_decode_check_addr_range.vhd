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
--!   @file                   regdecode_pipe_addr_decode_check_addr_range.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--!
--!   This modules outputs a write enable (o_data_valid) if i_addr_min <= i_addr <= i_addr_range_max when i_data_valid = '1'
--!
--!   Note:
-- -------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regdecode_pipe_addr_decode_check_addr_range is
  generic(
    g_ADDR_RANGE_WIDTH : integer := 16; -- input address bus range width
    g_ADDR_WIDTH       : integer := 16  -- input address bus width
  );
  port(
    i_clk            : in  std_logic;   -- clock
    ---------------------------------------------------------------------
    -- command
    ---------------------------------------------------------------------
    i_addr_range_min : in  std_logic_vector(g_ADDR_RANGE_WIDTH - 1 downto 0); -- define the lowest possible address
    i_addr_range_max : in  std_logic_vector(g_ADDR_RANGE_WIDTH - 1 downto 0); -- define the highest possible address
    ---------------------------------------------------------------------
    -- input data
    ---------------------------------------------------------------------
    i_data_valid     : in  std_logic;   -- input address valid
    i_addr           : in  std_logic_vector(g_ADDR_WIDTH - 1 downto 0); -- address value
    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    o_data_valid     : out std_logic    -- write enable
  );
end entity regdecode_pipe_addr_decode_check_addr_range;

architecture RTL of regdecode_pipe_addr_decode_check_addr_range is

  signal addr_tmp : std_logic_vector(i_addr_range_min'range);

  ---------------------------------------------------------------------
  -- performs 2 address check:
  --  1. i_addr_range_min <= i_addr
  --  2. i_addr <= i_addr_range_max
  ---------------------------------------------------------------------
  signal data_valid_low_r1  : std_logic;
  signal data_valid_high_r1 : std_logic;

  ---------------------------------------------------------------------
  -- combine address => check if i_addr_min <= i_addr <= i_addr_range_max
  ---------------------------------------------------------------------
  signal data_valid_r2 : std_logic;

begin

  ---------------------------------------------------------------------
  -- check configuration
  ---------------------------------------------------------------------

  --assert not (g_ADDR_WIDTH >= g_ADDR_RANGE_WIDTH) report "[regdecode_pipe_addr_decode_check_addr_range]: address range width should be inferior to equal to the input address bus width" severity error;

  ---------------------------------------------------------------------
  -- if g_ADDR_RANGE_WIDTH < g_ADDR_WIDTH then we assume the MSB bits are used to define a range which will be compared to i_addr_range_min and i_addr_range_max.
  -- So the MSB bits of i_addr are extracted.
  -- if g_ADDR_RANGE_WIDTH = g_ADDR_WIDTH. No change are necessary.
  ---------------------------------------------------------------------
  -- extract MSB bits of i_add
  addr_tmp <= i_addr(i_addr'high downto i_addr'high - i_addr_range_min'high);

  ---------------------------------------------------------------------
  -- performs 2 address check:
  --  1. i_addr_range_min <= i_addr
  --  2. i_addr <= i_addr_range_max
  ---------------------------------------------------------------------

  p_check_address_range : process(i_clk) is
  begin
    if rising_edge(i_clk) then
      -- wr_en_low = 1 if i_addr_range_min <= i_addr
      if i_data_valid = '1' then
        if unsigned(i_addr_range_min) <= unsigned(addr_tmp) then
          data_valid_low_r1 <= '1';
        else
          data_valid_low_r1 <= '0';
        end if;
      else
        data_valid_low_r1 <= '0';
      end if;

      -- wr_en_high = 1 if  i_addr <= i_addr_range_max
      if i_data_valid = '1' then
        if unsigned(addr_tmp) <= unsigned(i_addr_range_max) then
          data_valid_high_r1 <= '1';
        else
          data_valid_high_r1 <= '0';
        end if;
      else
        data_valid_high_r1 <= '0';
      end if;

    end if;
  end process p_check_address_range;

  ---------------------------------------------------------------------
  -- combine address check => check if i_addr_min <= i_addr <= i_addr_range_max
  ---------------------------------------------------------------------
  p_combine_address_check : process(i_clk) is
  begin
    if rising_edge(i_clk) then
      data_valid_r2 <= data_valid_low_r1 and data_valid_high_r1;
    end if;
  end process p_combine_address_check;

  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_data_valid <= data_valid_r2;

end architecture RTL;
