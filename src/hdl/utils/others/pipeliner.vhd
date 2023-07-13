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
--    @file                   pipeliner.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This module adds 0 or several consecutive registers on the data path.
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity pipeliner is
  generic(
    g_NB_PIPES   : natural  := 1;  -- number of consecutives registers. Possibles values: [0, integer max value[
    g_DATA_WIDTH : positive := 1  -- width of the input/output data.  Possibles values: [1, integer max value[
    );
  port(
    i_clk  : in  std_logic;             -- clock signal
    i_data : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0);  -- input data
    o_data : out std_logic_vector(g_DATA_WIDTH - 1 downto 0)  -- output data with/without delay
    );
end entity pipeliner;

architecture RTL of pipeliner is

  -- delayed data
  signal data_r   : std_logic_vector(i_data'range) := (others => '0');
  -- output data
  signal sync_tmp : std_logic_vector(i_data'range) := (others => '0');

begin

  -- add no register on the data path (<=> wire)
  gen_no_pipeline : if g_NB_PIPES = 0 generate
  begin
    sync_tmp <= i_data;
  end generate gen_no_pipeline;

  -- add 1 register on the data path
  gen_one_pipeline : if g_NB_PIPES = 1 generate
  begin
    ---------------------------------------------------------------------
    -- delayed the input data
    ---------------------------------------------------------------------
    p_pipe_data:process(i_clk)
    begin
      if rising_edge(i_clk) then
        data_r <= i_data;
      end if;
    end process p_pipe_data;
    sync_tmp <= data_r;
  end generate gen_one_pipeline;

  -- add 2 or more registers on the data path
  gen_multiple_pipeline : if g_NB_PIPES > 1 generate
    type t_pipeline is array (g_NB_PIPES - 1 downto 0) of std_logic_vector(i_data'range);
    signal data_pipe_r : t_pipeline := (others => (others => '0'));
  begin
    ---------------------------------------------------------------------
    -- shift the input data to the left
    ---------------------------------------------------------------------
    p_shift_data: process(i_clk)
    begin
      if rising_edge(i_clk) then
        data_pipe_r <= data_pipe_r(data_pipe_r'high - 1 downto 0) & i_data;
      end if;
    end process p_shift_data;

    sync_tmp <= data_pipe_r(data_pipe_r'high);
  end generate gen_multiple_pipeline;

  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_data <= sync_tmp;

end architecture RTL;
