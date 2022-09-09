----------------------------------------------------------------------------------
-- Company       : CNRS - INSU - IRAP
-- Engineer      : Antoine CLENET 
-- 
-- Create Date   : 12:14:36 05/26/2015 
-- Design Name   : DRE XIFU ML605
-- Module Name   : RHF1201_CONTROLER - Behavioral 
-- Project Name  : Athena XIfu DRE
-- Target Devices: Vitex 6 LX 240
-- Tool versions : ISE-14.7
-- Description   : data science Filter for data sciences from Test Bias
--
-- Dependencies: Integrator_CIC,
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
---------------------------------------oOOOo(o_o)oOOOo-----------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.FMC150_package.all;


entity science_filter_CIC is
	 generic	( 
				size_in  	: positive := 16;
				size_out 	: positive := 16
			   );
    Port 	(
--				CLK_4X		 			: in STD_LOGIC;
				CLK_IN 					: in STD_LOGIC;		--- clock 245MHz
				CLK_OUT					: in STD_LOGIC;				--- Clopck 15.36M
				reset    				: in STD_LOGIC;
				START_STOP				: in std_logic;

				data_in  				: in signed(size_in-1 downto 0);
--				rfd 	  					: out STD_LOGIC;
--				rdy      				: out STD_LOGIC;
				data_out 				: out signed(size_out-1 downto 0)
				);
--				data_out_Core			: out signed(size_in-1 downto 0));
end science_filter_CIC;

architecture Behavioral of science_filter_CIC is


signal data_in_buff	: signed(27 downto 0);

signal Int_out_dat_1 : signed(26 downto 0);
signal Int_out_dat_2 : signed(23 downto 0);
signal Int_out_dat_3 : signed(20 downto 0);


signal Comb_out_dat_1 : signed(19 downto 0);
signal Comb_out_dat_2 : signed(18 downto 0);
signal Comb_out_dat_3 : signed(17 downto 0);



begin

	data_in_buff<=resize (data_in,28);

-- Instantiation integrator1
   Integr1: Integrator_CIC
	Generic map	(
					size_in 			=> 28,
					size_out 		=> 27
					)	
	port map 	(
					--CLK_4X			=> CLK_4X,
					CLK_IN 			=> CLK_IN,
					reset 			=> reset,
					START_STOP		=> START_STOP,
					Int_out_dat 	=> Int_out_dat_1,
					Int_in_dat 		=> data_in_buff
        );
-- Instantiation integrator2
   Integr2: Integrator_CIC
	Generic map	(
					size_in 			=> 27,
					size_out 		=> 24
					)	
	port map 	(
					--CLK_4X			=> CLK_4X,
					CLK_IN 			=> CLK_IN,
					START_STOP		=> START_STOP,
					reset 			=> reset,
					Int_out_dat 	=> Int_out_dat_2,
					Int_in_dat 		=> Int_out_dat_1
					);
-- Instantiation integrator3
   Integr3: Integrator_CIC
	Generic map	(
					size_in 			=> 24,
					size_out 		=> 21
					)	
	port map 	(
					--CLK_4X			=> CLK_4X,
					CLK_IN 			=> 	CLK_IN,
					START_STOP		=> START_STOP,
					reset 			=> reset,
					Int_out_dat		=> Int_out_dat_3,
					Int_in_dat 		=> Int_out_dat_2
        );
		  
		  
-- Instantiation comb1
   Comb1: Comb_CIC 
	Generic map	(
					size_in 					=> 21,
					size_out 				=> 20
					)	
	port map 	(
					--CLK_4X					=> CLK_4X,
					CLK_OUT					=> CLK_OUT,
					reset 					=> reset,
					comb_in_dat 			=> Int_out_dat_3,
					comb_out_dat 			=> Comb_out_dat_1
					);
		  
-- Instantiation comb2
   Comb2: Comb_CIC 
	Generic map	(
					size_in 					=> 20,
					size_out 				=> 19
					)	
	port map 	(
					--CLK_4X					=> CLK_4X,
					CLK_OUT					=> CLK_OUT,
					reset 					=> reset,
					comb_in_dat 			=> Comb_out_dat_1,
					comb_out_dat 			=> Comb_out_dat_2
        );		  

	-- Instantiation comb3
   Comb3: Comb_CIC 
	Generic map	(
					size_in 					=> 19,
					size_out 				=> 18
					)	
	port map 	(
					reset 					=> reset,
					--CLK_4X					=> CLK_4X,
					CLK_OUT					=> CLK_OUT,
					comb_in_dat 			=> Comb_out_dat_2,
					comb_out_dat 			=> Comb_out_dat_3
        );
	  
data_out <= resize(Comb_out_dat_3(17 downto 2),16);		  
  
end Behavioral;
