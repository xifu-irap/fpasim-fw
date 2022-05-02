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

entity tb_fifo is
end entity tb_fifo;

architecture RTL of tb_fifo is

	component fifo 
		port(
			sys_clkp	   : in	std_logic;								
			sys_clkn	   : in std_logic;
			almost_empty   : out std_logic;
			almost_full	   : out std_logic;
			empty	       : out std_logic;
			full	       : out std_logic;
			read_count	   : out std_logic_vector(8 downto 0);
			read_error	   : out std_logic;
			write_count	   : out std_logic_vector(8 downto 0);
			write_error	   : out std_logic;
			data_out	   : out std_logic_vector(31 downto 0);
			data_in	       : in	std_logic_vector(31 downto 0);
			read_enable	   : in	std_logic;
			write_enable   : in std_logic;
			sys_rst        : in std_logic							
		);
	end component ;

signal  s_sys_clkp           : std_logic := '0' ;
signal  s_sys_clkn           : std_logic := '1' ;
signal  s_almost_empty       : std_logic := '0' ;
signal  s_almost_full        : std_logic := '0' ;
signal  s_full               : std_logic := '0' ;
signal  s_empty              : std_logic := '0' ;
signal  s_read_count         : std_logic_vector(8 downto 0) := "000000000";
signal  s_read_error         : std_logic := '0';
signal  s_write_error        : std_logic := '0';
signal  s_write_count        : std_logic_vector(8 downto 0) := "000000000";
signal  s_data_out           : std_logic_vector(31 downto 0) := x"00000000";
signal  s_data_in            : std_logic_vector(31 downto 0) := x"00000000";
signal  s_read_enable        : std_logic :='0';
signal  s_write_enable       : std_logic :='0';
signal  s_sys_rst            : std_logic :='1';

signal  dephasage            : std_logic :='0' ;
signal  endsim               : boolean := false;

begin

	sys_clk_gen : process
	begin 
		if endsim = false then 
			wait for 5 ns;
			s_sys_clkp <= not(s_sys_clkp);
			s_sys_clkn <= not(s_sys_clkn);
		else 
			wait ;
		end if;
	end process sys_clk_gen;

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
			wait until rising_edge(s_sys_clkp) ;
			s_data_in <= x"AABBCCDD";
			s_write_enable <='1';
			wait until rising_edge(s_sys_clkp) ;
			s_write_enable <='0';
			wait for 50ns;
			wait until rising_edge(s_sys_clkp) ;
			s_data_in <= x"CCDDEEFF";
			s_write_enable <='1';
			wait until rising_edge(s_sys_clkp) ;
			s_write_enable <='0';
			wait for 50ns;
			wait until rising_edge(s_sys_clkp) ;
			s_data_in <= x"EEFF0011";
			s_write_enable <='1';
			wait until rising_edge(s_sys_clkp) ;
			s_write_enable <='0';
			wait for 50ns;
			wait until rising_edge(s_sys_clkp) ;
			s_read_enable <='0';
		end process stimulus;

	gen_fifo : fifo
	Port map
		(
			sys_clkp       =>  s_sys_clkp,
			sys_clkn       =>  s_sys_clkn,
			almost_empty   =>  s_almost_empty,
			almost_full    =>  s_almost_full,
			empty          =>  s_empty,
			full           =>  s_full,
			read_count     =>  s_read_count,
			read_error     =>  s_read_error,
			write_count    =>  s_write_count,
			data_out       =>  s_data_out,
			data_in        =>  s_data_in,
			read_enable    =>  s_read_enable,
			write_enable   =>  s_write_enable,
			sys_rst        =>  s_sys_rst
		);

end RTL;