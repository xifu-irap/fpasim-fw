----------------------------------------------------------------------------------
-- Company       : CNRS - INSU - IRAP
-- Engineer      : Laurent Ravera, Antoine Clenet, Christophe Oziol
-- 
-- Create Date   : 09/07/2015 
-- Design Name   : DRE XIFU FPGA_BOARD
-- Module Name   : dds_signals_ctrl - Behavioral 
-- Project Name  : Athena XIfu DRE
-- Target Devices: Virtex 6 LX 240
-- Tool versions : ISE-14.7
-- Description: 	Setting of the DDS inputs (counter values) for the different 
--					sine waves needed for the processing of the BBFB of a canal
--					according to the signal phases.
--
-- Dependencies	 : 
--
-- Revision: 
-- Revision 0.1 - File Created
-- Revision 0.2 - All DDS parameters (all signals) are function of ROM_Depth, Size_ROM_Sine and Size_ROM_delta defined in the athena_package
--
---------------------------------------oOOOo(o_o)oOOOo-----------------------------

library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.athena_package.all;



entity dds_signals_ctrl is	
port	(
--RESET
		Reset         	: in std_logic; 
		enable_sinus   	: in std_logic;
--CLOCKs
		CLK_100MHz			: in std_logic;

--CONTROL
		counter_step  	: in unsigned(C_size_counter-1 downto 0); 
    
		count_sinus 	: out unsigned(C_size_counter-1 downto 0)
		);
end entity;


--! @brief-- BLock diagrams schematics -- 
--! @detail file:work.dds_signals_ctrl.Behavioral.svg
architecture Behavioral of dds_signals_ctrl is

signal counter				: unsigned(C_size_counter-1 downto 0);		-- DDS counter for one pixel
signal addrs				: unsigned(C_REF_SINE_Depth-1 downto 0);			-- ROM address part of the counter,
signal intrp				: unsigned(C_Size_intrp-1 downto 0);			-- Interpolation part of the counter



begin

P_counter: process(CLK_100MHz)
	begin
-- counter increased with steps equal to counter_step
-- high values of the counter step give a fast rises of the counter and high DDS frequencies
		if rising_edge (CLK_100MHz) then
			if (Reset = '1' or enable_sinus ='0') then
					counter 		<= (others=>'0');
					count_sinus 	<= (addrs - C_REF_SINE_length/4 & intrp);
			else
					counter 	<= (counter + counter_step);
--------------------------------------------------------
-- The DDS uses a reference sine wave made of C_REF_SINE_length=2**C_ROM_Depth values.
-- A quarter of the period only (C_REF_SINE_length/4 values)  is stored in the DDS memory.
-- An address offset of C_REF_SINE_length/4 makes a 90 deg phase shift.
-- An address offset of C_REF_SINE_length/2 makes a 180 deg phase shift.
-- and so on ...
--------------------------------------------------------

-- Computation of sinus counter
				count_sinus 	<= 	(addrs - C_REF_SINE_length/4 & intrp) ;

				end if;
			end if;
end process P_counter; 	

addrs <= counter(C_size_counter-1 downto C_size_counter - C_REF_SINE_Depth);
intrp <= counter(C_size_counter - C_REF_SINE_Depth - 1 downto C_size_counter - C_REF_SINE_Depth - C_Size_intrp);

end Behavioral;
---------------------------------------------------------------------------------
