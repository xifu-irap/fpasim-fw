----------------------------------------------------------------------------------
-- Company       : CNRS - INSU - IRAP
-- Engineer      : Laurent Ravera, Antoine Clenet, Christophe Oziol
-- 
-- Create Date   : 07/07/2015 
-- Design Name   : DRE XIFU FPGA_BOARD
-- Module Name   : sine_generator - Behavioral 
-- Project Name  : Athena XIfu DRE
-- Target Devices: Virtex 6 LX 240
-- Tool versions : ISE-14.7
--
-- Description:		Generation of a sine wave with dds component
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.1 - File Created
-- Revision 0.2 - All DDS parameters (all signals) are function of ROM_Depth, Size_ROM_Sine and Size_ROM_delta defined in the athena_package
-- Revision 0.3 - adaptation to single DDS sinus genrator
-- Additional Comments: 
---------------------------------------oOOOo(o_o)oOOOo-----------------------------

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.athena_package.all;
  
  
entity Sine_generator is
port 	( 
--RESET
		Reset          	: in  std_logic;
		enable_sinus     	: in  std_logic;
--CLOCKs
		CLK_100MHz			: in  std_logic;
--CONTROL
		increment      	: in  unsigned(C_size_counter-1 downto 0);
		sinus_amplitude 	: in  unsigned(C_Size_sinus_amplitude-1 downto 0); -- pixel bias amplitude

		sinus_out       : out signed(C_Size_science-1 downto 0)
		);
end entity;

---------------------------------------------------------------------------------

--! @brief-- BLock diagrams schematics -- 
--! @detail file:work.sine_generator.Behavioral.svg
architecture Behavioral of Sine_generator is
---sines
signal sines 				  	: signed(C_Size_DDS-1 downto 0);
signal count_sinus    			: unsigned(C_size_counter-1 downto 0);

-- In the two following lines the +1 is needed to manage the extra MSB introduced by the
-- unsigned to signed conversion of the amplitude

signal sinus_amplitude_signed 		: signed(C_Size_sinus_amplitude-1+1 downto 0);
signal sinus_buf					: signed(C_Size_DDS+C_Size_sinus_amplitude-1+1 downto 0);

begin
----------------------------------
-- DDS input controller (phases => counters)
----------------------------------

DDS_sig_controller: entity work.dds_signals_ctrl
port map	(
			Reset 			=> Reset, 
			enable_sinus		=> enable_sinus,
			CLK_100MHz			=> CLK_100MHz,
			counter_step	=> increment,
    
			count_sinus	=> count_sinus
			);

----------------------------------
-- DDS_generic sines
----------------------------------
DDS_sines: entity work.DDS
	port map(
		Reset         => Reset,
		CLK_100MHz        => CLK_100MHz,
		counter       => count_sinus,
		dds_signal    => sines
	); 

---------------------------------------------------------------------------------

P_sine_gene: process(CLK_100MHz)
	begin

  -- According to a 2 bit counter value the dds input and output are selected.
    -- Two clock periods separate the counter input in the DDS module and the output
    -- of the corresponding value.
	if rising_edge(CLK_100MHz) then
		if Reset = '1' or enable_sinus='0' then
			sinus_amplitude_signed 	<= (others=>'0');
	        sinus_buf				<= (others=>'0');
		else
				sinus_amplitude_signed 	<= signed('0' & sinus_amplitude); -- in order to not create negative values 
	            sinus_buf 				<= sines * sinus_amplitude_signed;
	        end if;
		end if;
end process P_sine_gene;

sinus_out <= sinus_buf(C_Size_DDS-1 + C_Size_sinus_amplitude-1 downto C_Size_sinus_amplitude-1+C_Size_DDS-C_Size_science);


end Behavioral;
---------------------------------------------------------------------------------
