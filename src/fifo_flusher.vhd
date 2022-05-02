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
--fifo_flusher.vhd

-- Company: IRAP
-- Engineer: Paul Marbeau
-- 
-- Create Date: 20.04.2022 
-- Design Name: 
-- Module Name: fifo_flusher
-- Target Devices: Opal Kelly XEM7350 
-- Tool Versions: 
-- Description: 
----------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use work.fpasim_pkg.all;

entity fifo_flusher is
		port(
			i_clk	           : in std_logic;
			i_rst              : in std_logic;	
			i_fifo_read_clock  : in std_logic;
			i_fifo_read        : in std_logic;
			i_fifo_full        : in std_logic;
			i_data_valid       : in std_logic;						
			i_data_in          : in std_logic_vector(c_data_width-1 downto 0);
			o_fifo_write       : out std_logic;
			o_flush            : out std_logic;
			o_data_out         : out std_logic_vector(c_data_width-1 downto 0);
			o_nb_words_stored  : out std_logic_vector(c_read_write_count_width-1 downto 0)						
		);
end entity;

architecture RTL of fifo_flusher is

---- Signals ----
signal s_fifo_read_count  : std_logic_vector(c_read_write_count_width downto 0);
signal s_cpt_read_count   : std_logic_vector(c_read_write_count_width-1 downto 0);
signal s_fifo_write_count : std_logic_vector(c_read_write_count_width downto 0);
signal s_cpt_write_count  : std_logic_vector(c_read_write_count_width-1 downto 0);
signal s_nb_words_stored  : std_logic_vector(c_read_write_count_width downto 0);
signal s_fifo_write       : std_logic;
signal s_flush            : std_logic;
signal s_tamp_done        : std_logic;

begin

	s_fifo_read_count  <= '0' & s_cpt_read_count;
	s_fifo_write_count <= '1' & s_cpt_write_count;
	o_nb_words_stored  <= s_nb_words_stored(c_read_write_count_width-1 downto 0);
	o_fifo_write <= s_fifo_write;
	o_flush <= s_flush;
	s_nb_words_stored <= std_logic_vector(unsigned(s_fifo_write_count)-unsigned(s_fifo_read_count));

	words_stored : process(i_rst, i_fifo_read_clock,i_clk)
	begin
	if i_rst ='1' then
			s_cpt_read_count   <= (others => '0');
			s_cpt_write_count  <= (others => '0');
		else
		if rising_edge(i_fifo_read_clock) then
			if i_fifo_read = '1' then
				s_cpt_read_count <= std_logic_vector(unsigned(s_cpt_read_count) + 1);
			end if;
		end if;
		if rising_edge(i_clk) then
			if s_fifo_write = '1' then
                s_cpt_write_count <= std_logic_vector(unsigned(s_cpt_write_count) + 1);
			end if;
		end if;
	end if;
	end process words_stored;

	flusher : process(i_rst, i_clk)
		begin
		if i_rst='1' then
			s_fifo_write <= '0' ;
			o_data_out   <= (others =>'0');
			s_flush      <= '0' ;
			s_tamp_done  <= '0';
		elsif rising_edge(i_clk) then
			if i_data_valid = '1' or s_flush='1' then 
				if i_data_in = c_flush_command or s_flush ='1' then
					if s_nb_words_stored(c_read_write_count_width-1 downto 0) < '0' & x"03" then
						if s_nb_words_stored(c_read_write_count_width-1 downto 0) = "000000000" then
							s_fifo_write <= '0';
							s_flush <= '0';
							s_tamp_done  <= '0';
						else
							if s_tamp_done = '0' then
								s_flush      <= '1';
								s_fifo_write <= '1';
								o_data_out   <= x"cafecafe";
							end if;
						end if ;
					else 
						s_flush      <= '1';
						s_tamp_done  <= '1';
						s_fifo_write <= '0';
					end if;
				else 
					s_fifo_write <= '1';
					o_data_out   <= i_data_in;
				end if;
			else
				s_fifo_write <= '0';
			end if;
		end if;
	end process flusher;

	
	
end RTL;
