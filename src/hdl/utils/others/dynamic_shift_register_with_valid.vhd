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
--    @file                   dynamic_shift_register_with_valid.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This module dynamically adds 1 or several consecutive registers on the data path.
--    It has the following characteristics:
--       . The pipeline depth is defined by (2**i_addr)
--       . if i_data_valid = '1' then
--             . the input data is shifted (to the left)
--             . the number of registers (delay) between the input data port and the output data port is defined by (i_addr + 1)
--       . if i_data_valid = '0' then no change is applied.
--
--    Example0:
--      .i_addr       |  0                                   |
--      .i_data_valid |  1  0  1  0  1  0  1  0  1  0  1  0  |
--      .i_data       |  a0    a1    a2    a3    a4    a5    |
--      .o_data       |  xx    a0    a1    a2    a3    a4    |
--
--    Example1:
--      .i_addr       |  1                                   |
--      .i_data_valid |  1  0  1  0  1  0  1  0  1  0  1  0  |
--      .i_data       |  a0    a1    a2    a3    a4    a5    |
--      .o_data       |  xx    xx    a0    a1    a2    a3    |
--
--    Example2:
--      .i_addr       |  2                                   |
--      .i_data_valid |  1  0  1  0  1  0  1  0  1  0  1  0  |
--      .i_data       |  a0    a1    a2    a3    a4    a5    |
--      .o_data       |  xx    xx    xx    a0    a1    a2    |
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity dynamic_shift_register_with_valid is
  generic (
    g_ADDR_WIDTH : positive := 7; -- width of the address. Possibles values: [2, integer max value[
    g_DATA_WIDTH : positive := 1  -- width of the input/output data.  Possibles values: [1, integer max value[
    );
  port (
    i_clk        : in std_logic; -- clock signal
    i_data_valid : in std_logic; -- input data valid
    i_data       : in std_logic_vector(g_DATA_WIDTH - 1 downto 0); -- input data
    i_addr       : in std_logic_vector(g_ADDR_WIDTH - 1 downto 0); -- input address (dynamically select the depth of the pipeline)

    o_data : out std_logic_vector(g_DATA_WIDTH - 1 downto 0)  -- output data with/without delay
    );
end entity dynamic_shift_register_with_valid;

architecture RTL of dynamic_shift_register_with_valid is

  signal addr_r : std_logic_vector(i_addr'range) := (others => '0');
  signal srl_tmp : std_logic_vector(g_DATA_WIDTH-1 downto 0):= (others => '0');  -- intermediate signal between srl and register

  type t_array_slv is array (g_DATA_WIDTH-1 downto 0) of std_logic_vector(2**i_addr'length-1 downto 0);
  signal shift_r : t_array_slv:= (others => (others => '0'));

  signal srl_r2 : std_logic_vector(o_data'range):= (others => '0');

  -- fpga specific attribute
  attribute shreg_extract : string;
  attribute shreg_extract of srl_r2 : signal is "no";

begin
  -- shift the input data on the data valid
  p_shift_input_data: process (i_clk)
  begin
    if rising_edge(i_clk) then
      addr_r <= i_addr;
      if i_data_valid = '1' then
        for i in 0 to g_DATA_WIDTH - 1 loop
          shift_r(i) <= shift_r(i)(2**i_addr'length-2 downto 0) & i_data(i);
        end loop;
      end if;
    end if;
  end process p_shift_input_data;

  -- select the output register to output
  p_select_pipe_position: process(shift_r, addr_r)
  begin
    for i in 0 to g_DATA_WIDTH-1 loop
      srl_tmp(i) <= shift_r(i)(to_integer(unsigned(addr_r)));
    end loop;
  end process p_select_pipe_position;

  -- output register (performance reason)
  p_output_delay: process(i_clk)
  begin
    if rising_edge(i_clk) then
      srl_r2 <= srl_tmp;
    end if;
  end process p_output_delay;

  o_data <= srl_r2;

end architecture RTL;
