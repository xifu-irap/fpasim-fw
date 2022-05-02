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

library UNISIM;
use UNISIM.vcomponents.all;

library UNIMACRO;
use UNIMACRO.vcomponents.all;

entity fifo is
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
end entity;

architecture RTL of fifo is

---- Clock + Reset signals ----

signal sys_clk    : std_logic;


begin
----------------------------------------------------
-- Clock gen
----------------------------------------------------
	IBUFDS_sys_clk : IBUFDS  --	BUFDS (transform differential to single ended)
		generic map (
			DIFF_TERM    => TRUE, -- Differential Termination 
			IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
			IOSTANDARD   => "DEFAULT")
		port map (
			O  => sys_clk,    -- Buffer output
			I  => sys_clkp,   -- Diff_p buffer input (connect directly to top-level port)
			IB => sys_clkn    -- Diff_n buffer input (connect directly to top-level port)
		);
	
	Fifo_out : FIFO_DUALCLOCK_MACRO
	generic map (
		DEVICE                  => "7SERIES",   -- Target Device: "VIRTEX5", "VIRTEX6", "7SERIES" 
		ALMOST_FULL_OFFSET      => X"0080",     -- Sets almost full threshold
		ALMOST_EMPTY_OFFSET     => X"0005",     -- Sets the almost empty threshold
		DATA_WIDTH              => 32,          -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
		FIFO_SIZE               => "18Kb",      -- Target BRAM, "18Kb" or "36Kb" 
		FIRST_WORD_FALL_THROUGH => TRUE)       -- Sets the FIFO FWFT to TRUE or FALSE
	port map (
		ALMOSTEMPTY => almost_empty,   -- 1-bit output almost empty
		ALMOSTFULL  => almost_full,    -- 1-bit output almost full
		DO          => data_out,       -- Output data, width defined by DATA_WIDTH parameter
		EMPTY       => empty,          -- 1-bit output empty
		FULL        => full,           -- 1-bit output full
		RDCOUNT     => read_count,     -- Output read count, width determined by FIFO depth
		RDERR       => read_error,     -- 1-bit output read error
		WRCOUNT     => write_count,    -- Output write count, width determined by FIFO depth
		WRERR       => write_error,    -- 1-bit output write error
		DI          => data_in,        -- Input data, width defined by DATA_WIDTH parameter
		RDCLK       => sys_clk,        -- 1-bit input read clock
		RDEN        => read_enable,    -- 1-bit input read enable
		RST         => sys_rst,        -- 1-bit input reset
		WRCLK       => sys_clk,        -- 1-bit input write clock
		WREN        => write_enable    -- 1-bit input write enable
		);
	
end RTL;
