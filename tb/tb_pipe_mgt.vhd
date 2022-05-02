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
--fifo.vhd

-- Company: IRAP
-- Engineer: Paul Marbeau
-- 
-- Create Date: 12.04.2022 
-- Design Name: 
-- Module Name: fifo
-- Target Devices: Opal Kelly XEM7350 
-- Tool Versions: 
-- Description: 
----------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use work.fpasim_pkg.all;

entity tb_pipe_mgt is
end entity tb_pipe_mgt;

architecture RTL of tb_pipe_mgt is

	component pipe_mgt 
	port(
		i_rst              : in std_logic;
		i_wr_clk	       : in std_logic;
		i_rd_clk         : in std_logic;
		i_fifo_read        : in std_logic;						
		i_fifo_write       : in std_logic;
		o_nb_words_stored  : out std_logic_vector(c_read_write_count_width-1 downto 0)						
	);
	end component ;

signal  s_rst                : std_logic :='1';
signal  s_wr_clk             : std_logic := '0';
signal  s_rd_clk             : std_logic := '1';
signal  s_fifo_read          : std_logic := '0';
signal  s_fifo_write         : std_logic := '0';
signal  s_nb_words_stored    : std_logic_vector(8 downto 0) := "000000000";
signal  endsim               : boolean := false;

begin

	wr_clk_gen : process
	begin 
		if endsim = false then 
			wait for 2500 ps;
			s_wr_clk <= not(s_wr_clk);
		else 
			wait ;
		end if;
	end process wr_clk_gen;

	rd_clk_gen : process
	begin 
		if endsim = false then 
			wait for 5000 ps;
			s_rd_clk <= not(s_rd_clk);
		else 
			wait ;
		end if;
	end process rd_clk_gen;

	time_window : process 
	begin
		wait for 160000 ns;
		endsim <= true ;
	end process time_window;

	reset : process 
	begin 
		if s_rst  ='1' then
			wait for 100ns ;
			s_rst <='0' ;
		else
			wait;
		end if;
	end process;

	stimulus : process 
	begin 
	        wait for 100ns;
			wait until rising_edge(s_wr_clk);
			s_fifo_write <= '1';
			wait for 50 ns;
			s_fifo_write <= '0';
			s_fifo_read  <='1';
			wait for 40 ns;
			s_fifo_read <='0';
			wait for 1000 ns;
		end process stimulus;

	gen_fifo : pipe_mgt
	Port map
	(
		i_rst              =>  s_rst,
		i_wr_clk	       =>  s_wr_clk,
		i_rd_clk           =>  s_rd_clk,
		i_fifo_read        =>  s_fifo_read,					
		i_fifo_write       =>  s_fifo_write,
		o_nb_words_stored  =>  s_nb_words_stored					
	);

end RTL;