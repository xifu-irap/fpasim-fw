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

library work;
use work.fpasim_pkg.all;

entity top_test is
		port(
			sys_clkp	      : in std_logic;								
			sys_clkn	      : in std_logic;
			okClk    	      : in std_logic;
			sys_rst           : in std_logic;
			fifo_in_data      : in std_logic_vector(c_data_width-1 downto 0);
			fifo_in_write     : in std_logic;
			fifo_out_read_en  : in std_logic;
			fifo_out_data_out : out	std_logic_vector(c_data_width-1 downto 0)						
		);
end entity;

architecture RTL of top_test is

---- Clock + Reset signals ----

signal  fifo_in_full : std_logic;
signal  fifo_in_data_out : std_logic_vector(c_data_width-1 downto 0);
signal  fifo_in_empty : std_logic;
signal  fifo_in_empty_n : std_logic;
signal  flush_data_valid : std_logic;
signal  fifo_out_almostempty : std_logic;
signal  fifo_out_empty : std_logic;
signal  fifo_out_full : std_logic;
signal  fifo_out_full_n : std_logic;
signal  flush_data_in : std_logic_vector(c_data_width-1 downto 0);
signal  fifo_out_write_count : std_logic_vector(c_read_write_count_width-1 downto 0);
signal  fifo_out_read_count : std_logic_vector(c_read_write_count_width-1 downto 0);
signal  fifo_out_data : std_logic_vector(c_data_width-1 downto 0);
signal  fifo_out_write : std_logic;
signal  flushing : std_logic;
signal  nb_words_stored : std_logic_vector(c_read_write_count_width-1 downto 0);
signal  sys_clk    : std_logic;
signal  ep20_wire : std_logic_vector(31 downto 0);      -- Opal Kelly wire out 

begin

	----------------------------------------------------
	-- Clock gen
	----------------------------------------------------
	IBUFDS_sys_clk : IBUFDS  --	BUFDS (transform differential to single ended)
	generic map (
		DIFF_TERM    => FALSE, -- Differential Termination 
		IBUF_LOW_PWR => FALSE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
		IOSTANDARD   => "DEFAULT")
	port map (
		O  => sys_clk,    -- Buffer output
		I  => sys_clkp,   -- Diff_p buffer input (connect directly to top-level port)
		IB => sys_clkn    -- Diff_n buffer input (connect directly to top-level port)
	);
	ep20_wire <= x"00000" & "000" & nb_words_stored;
	Fifo_in : FIFO_DUALCLOCK_MACRO
	generic map (
		DEVICE                  => "7SERIES",   -- Target Device: "VIRTEX5", "VIRTEX6", "7SERIES" 
		ALMOST_FULL_OFFSET      => X"0080",     -- Sets almost full threshold
		ALMOST_EMPTY_OFFSET     => X"0080",     -- Sets the almost empty threshold
		DATA_WIDTH              => 32,          -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
		FIFO_SIZE               => "18Kb",      -- Target BRAM, "18Kb" or "36Kb" 
		FIRST_WORD_FALL_THROUGH => TRUE)       -- Sets the FIFO FWFT to TRUE or FALSE
	port map (
		DO    => fifo_in_data_out,              -- Output data, width defined by DATA_WIDTH parameter
		EMPTY => fifo_in_empty,                 -- 1-bit output empty
		FULL  => fifo_in_full,                  -- 1-bit output full
		DI    => fifo_in_data,                  -- Input data, width defined by DATA_WIDTH parameter
		RDCLK => sys_clk,                       -- 1-bit input read clock
		RDEN  => flush_data_valid,              -- 1-bit input read enable
		RST   => sys_rst,                       -- 1-bit input reset
		WRCLK => okClk,                         -- 1-bit input write clock
		WREN  => fifo_in_write                  -- 1-bit input write enable
	);
	
	fifo_in_empty_n <= not(fifo_in_empty);      -- Fifo in not empty signal

	Fifo_out : FIFO_DUALCLOCK_MACRO
	generic map (
		DEVICE                  => "7SERIES",   -- Target Device: "VIRTEX5", "VIRTEX6", "7SERIES" 
		ALMOST_FULL_OFFSET      => X"0080",     -- Sets almost full threshold
		ALMOST_EMPTY_OFFSET     => X"0080",     -- Sets the almost empty threshold (range 5-1028)
		DATA_WIDTH              => 32,          -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
		FIFO_SIZE               => "18Kb",      -- Target BRAM, "18Kb" or "36Kb" 
		FIRST_WORD_FALL_THROUGH => TRUE)       -- Sets the FIFO FWFT to TRUE or FALSE
	port map (
		DO          => fifo_out_data_out,             -- Output data, width defined by DATA_WIDTH parameter
		EMPTY       => fifo_out_empty,                -- 1-bit output empty
		FULL        => fifo_out_full,                 -- 1-bit output full
		WRCOUNT     => fifo_out_write_count,          -- Output write count, width determined by FIFO depth
		RDCOUNT     => fifo_out_read_count,           -- Output read count, width determined by FIFO depth
		DI          => fifo_out_data,                 -- Input data, width defined by DATA_WIDTH parameter
		RDCLK       => okClk,                         -- 1-bit input read clock
		RDEN        => fifo_out_read_en,              -- 1-bit input read enable
		RST         => sys_rst,                       -- 1-bit input reset
		WRCLK       => sys_clk,                         -- 1-bit input write clock
		WREN        => fifo_out_write                 -- 1-bit input write enable
	);

	fifo_out_full_n <= not(fifo_out_full);      -- Fifo out not full signal

	flusher : entity work.fifo_flusher 
	port map(
		i_clk	           => sys_clk,
		i_rst              => sys_rst,
		i_fifo_read_clock  => okClk,
		i_fifo_read        => fifo_out_read_en,
		i_fifo_full        => fifo_out_full,
		i_data_valid       => flush_data_valid,						
		i_data_in          => flush_data_in,
		o_fifo_write       => fifo_out_write,
		o_flush            => flushing,
		o_data_out         => fifo_out_data,
		o_nb_words_stored  => nb_words_stored						
	);

	flush_data_in    <= fifo_in_data_out;
	flush_data_valid <= fifo_in_empty_n and not(flushing);

end RTL;
