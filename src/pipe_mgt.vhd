----------------------------------------------------------------------------------
--Copyright (C) 2021-2030 Paul Marbeau, IRAP Toulouse.

--This file is part of the ATHENA X-IFU DRE RAS.

--fpasim-fw is free software: you can redistribute it and/or modifyit under the terms of the GNU General Public 
--License as published bythe Free Software Foundation, either version 3 of the License, or(at your option) any 
--later version.

--This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the 
--implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for 
--more details.You should have received a copy of the GNU General Public Licensealong with this program.  

--If not, see <https://www.gnu.org/licenses/>.

--paul.marbeau@alten.com
--pipe_mgt.vhd

-- Company: IRAP
-- Engineer: Paul Marbeau
-- 
-- Create Date: 20.04.2022 
-- Design Name: 
-- Module Name: pipe_mgt
-- Target Devices: Opal Kelly XEM7350 
-- Tool Versions: 
-- Description: 
----------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use work.fpasim_pkg.all;

entity pipe_mgt is
		port(
			i_rst              : in std_logic;
			i_wr_clk	       : in std_logic;
			i_rd_clk         : in std_logic;
			i_fifo_read        : in std_logic;						
			i_fifo_write       : in std_logic;
			o_nb_words_stored  : out std_logic_vector(c_read_write_count_width-1 downto 0)						
		);
end entity;

architecture RTL of pipe_mgt is

---- Signals ----
signal s_fifo_read_count   : std_logic_vector(c_read_write_count_width downto 0);
signal s_cpt_read_count    : std_logic_vector(c_read_write_count_width-1 downto 0);
signal s_fifo_write_count  : std_logic_vector(c_read_write_count_width downto 0);
signal s_cpt_write_count   : std_logic_vector(c_read_write_count_width-1 downto 0);
signal s_nb_words_stored   : std_logic_vector(c_read_write_count_width downto 0);

begin

	s_fifo_read_count  <= '0' & s_cpt_read_count;
	s_fifo_write_count <= '1' & s_cpt_write_count;
	s_nb_words_stored  <= std_logic_vector(unsigned(s_fifo_write_count)-unsigned(s_fifo_read_count));
	o_nb_words_stored  <= s_nb_words_stored(c_read_write_count_width-1 downto 0);

	words_stored : process(i_rst, i_wr_clk, i_rd_clk)
	begin
	if i_rst ='1' then
			s_cpt_read_count   <= (others => '0');
			s_cpt_write_count  <= (others => '0');
		else
		if rising_edge(i_rd_clk) then 
			if i_fifo_read = '1' then
				s_cpt_read_count <= std_logic_vector(unsigned(s_cpt_read_count) + 1);
			end if;
		end if;
		if rising_edge(i_wr_clk) then
			if i_fifo_write = '1' then
                s_cpt_write_count <= std_logic_vector(unsigned(s_cpt_write_count) + 1);
			end if;
		end if;
	end if;
	end process words_stored;	
	
end RTL;
