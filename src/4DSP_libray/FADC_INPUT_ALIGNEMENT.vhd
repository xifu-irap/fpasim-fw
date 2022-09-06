----------------------------------------------------------------------------------
-- Company  : IPN-ORSAY (DII-SEP)
-- Engineer : Beng Yun KY
-- 
-- Create Date:    16:55:21 06/25/2012 
-- Design Name:    DALTON MAIN BOARD
-- Module Name:    FADC_INPUT_ALIGNEMENT - rtl 
-- Project Name:	 DALTON_HDL
-- Target Devices: Xilinx Virtex-6 XC6VLX130T-2FF1156
-- Tool versions:  ISE 13.1
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
  use work.FMC150_package.all;

entity FADC_INPUT_ALIGNEMENT is
	Port (
		RESET 				: in  std_logic;
		CLK 					: in  std_logic;
		-- 16 FAST-ADC Maximum
		FADC_EN 				: in  std_logic_vector(1 downto 0);
		FADC_SYNC_OK 		: out std_logic_vector(1 downto 0);
		FADC_SYNC_FINISH	: out std_logic;
		--
		FADC_CHA_DATA		: out std_logic_vector(13 downto 0);
		FADC_CHB_DATA		: out std_logic_vector(13 downto 0);
		FADC_CHAB_CLK		: out std_logic;
		-- FAST ADC CLOCK/DATA BUS
		FADC_CHA_P			: in  std_logic_vector(6 downto 0);
		FADC_CHA_N			: in  std_logic_vector(6 downto 0);
		FADC_CHB_P			: in  std_logic_vector(6 downto 0);
		FADC_CHB_N			: in  std_logic_vector(6 downto 0);
		FADC_CLKAB_P		: in  std_logic;
		FADC_CLKAB_N		: in  std_logic
	);
end FADC_INPUT_ALIGNEMENT;

architecture rtl of FADC_INPUT_ALIGNEMENT is
	signal CHAB_FINISH		: std_logic;
	signal FADC_SYNC_OKi		: std_logic_vector(1 downto 0);
	signal FADC_SYNC_ERRi	: std_logic_vector(1 downto 0);
begin
	-- ---------------------------------------------------------------
	-- OUTPUT ASSIGN
	-- ---------------------------------------------------------------
	FADC_SYNC_FINISH	<= CHAB_FINISH ;	
	FADC_SYNC_OK(0)	<= FADC_SYNC_OKi(0) and (not FADC_SYNC_ERRi(0));
	FADC_SYNC_OK(1)	<= FADC_SYNC_OKi(1) and (not FADC_SYNC_ERRi(1));
	-- ---------------------------------------------------------------
	-- CHANNEL A/B Input Synchro
	-- ---------------------------------------------------------------
	chab_inst : entity work.FADC_SYNC
	Port map( 
		RESET 			=> RESET,				-- I
		CLK				=> CLK,					-- I
		--
		FINISH			=> CHAB_FINISH,		-- O
		DOUTXY_CLK		=> FADC_CHAB_CLK,		-- O
		--
		DOUTX				=> FADC_CHA_DATA,		-- O[13:0]
		CHX_EN			=> FADC_EN(0),			-- I
		CHX_SYNC_OK		=> FADC_SYNC_OKi(0),	-- O
		CHX_SYNC_ERR	=> FADC_SYNC_ERRi(0),-- O
		--
		DOUTY				=> FADC_CHB_DATA,		-- O[13:0]
		CHY_EN			=> FADC_EN(1),			-- I
		CHY_SYNC_OK		=> FADC_SYNC_OKi(1),	-- O
		CHY_SYNC_ERR	=> FADC_SYNC_ERRi(1),-- O
		-- LVDS I/O
		CLKXY_P 			=> FADC_CLKAB_P,		-- I
		CLKXY_N 			=> FADC_CLKAB_N,		-- I
		CHX_P 			=> FADC_CHA_P,			-- I[6:0]
		CHX_N 			=> FADC_CHA_N,			-- I[6:0]
		CHY_P 			=> FADC_CHB_P,			-- I[6:0]
		CHY_N 			=> FADC_CHB_N			-- I[6:0]
	);
	
end rtl;

