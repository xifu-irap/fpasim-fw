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

entity tb_top_test is
end entity tb_top_test;

architecture RTL of tb_top_test is

	component top_test 
	port(
		sys_clkp	      : in std_logic;								
		sys_clkn	      : in std_logic;
		okClk    	      : in std_logic;
		sys_rst           : in std_logic;
		fifo_in_data      : in std_logic_vector(31 downto 0);
		fifo_in_write     : in std_logic;
		fifo_out_read_en  : in std_logic;
		fifo_out_data_out : out	std_logic_vector(31 downto 0)						
	);
	end component ;

signal  s_sys_clkp           : std_logic := '0';
signal  s_sys_clkn           : std_logic := '1';
signal  s_okClk              : std_logic := '0';
signal  s_sys_rst            : std_logic := '1';
signal  s_fifo_in_data       : std_logic_vector(31 downto 0) := x"00000000";
signal  s_fifo_in_write      : std_logic :='0';
signal  s_fifo_out_read_en     : std_logic :='0';
signal  s_fifo_out_data_out  : std_logic_vector(31 downto 0) := x"00000000";

signal  endsim               : boolean := false;

begin

	sys_clk_gen : process
	begin 
		if endsim = false then 
			wait for 2500 ps;
			s_sys_clkp <= not(s_sys_clkp);
			s_sys_clkn <= not(s_sys_clkn);
		else 
			wait ;
		end if;
	end process sys_clk_gen;

	okClk_gen : process
	begin 
		if endsim = false then 
			wait for 5 ns;
			s_okClk <= not(s_okClk);
		else 
			wait ;
		end if;
	end process okClk_gen;

	time_window : process 
	begin
		wait for 160000 ns;
		endsim <= true ;
	end process time_window;

	reset : process 
	begin 
		if s_sys_rst  ='1' then
			wait for 100ns ;
			s_sys_rst <='0' ;
		else
			wait;
		end if;
	end process;

	stimulus : process 
	begin 
	        wait for 100ns;
			wait until rising_edge(s_okClk) ;
			s_fifo_in_data <= x"AABBCCDD";
			s_fifo_in_write <='1';
			wait until rising_edge(s_okClk) ;
			s_fifo_in_data <= x"FFFEFFFE";
			wait until rising_edge(s_okClk) ;
			s_fifo_in_data <= x"EEFF0011";
			wait until rising_edge(s_okClk) ;
			s_fifo_in_data <= x"EEFF0012";
			wait until rising_edge(s_okClk) ;
			s_fifo_in_write <='0';
			wait for 50ns;
			wait until rising_edge(s_okClk) ;
			s_fifo_out_read_en <='1';
			wait for 40ns;
			wait until rising_edge(s_okClk) ;
			s_fifo_out_read_en <='0';
			wait for 200ns;
		end process stimulus;

	gen_fifo : top_test
	Port map
	(
		sys_clkp	      => s_sys_clkp,								
		sys_clkn	      => s_sys_clkn,
		okClk    	      => s_okClk,	
		sys_rst           => s_sys_rst,	
		fifo_in_data      => s_fifo_in_data,	
		fifo_in_write     => s_fifo_in_write,	
		fifo_out_read_en  => s_fifo_out_read_en,	
		fifo_out_data_out => s_fifo_out_data_out							
	);

end RTL;