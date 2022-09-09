----------------------------------------------------------------------------------
-- Company  : IPN-ORSAY (DII-SEP)
-- Engineer : Beng Yun KY
-- 
-- Create Date:    09:16:51 06/22/2012 
-- Design Name:    DALTON MAIN BOARD
-- Module Name:    CLOCK_MANAGER - rtl 
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
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.all;
--use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
Library UNISIM;
use UNISIM.vcomponents.all;
-- use work.FMC150_package.all;

entity CLOCK_MANAGER is
	Port (
		CPU_RESET 			: in  std_logic;
		SYSCLK_P 			: in  std_logic;
		SYSCLK_N 			: in  std_logic;
		RESET					: out std_logic;
		CLK_8X				: out std_logic;
		CLK_4X				: out std_logic;
		CLK_2X				: out std_logic;
		CLK_1X				: out std_logic;
		CLK_LOCKED			: out std_logic
	);
end CLOCK_MANAGER;

architecture rtl of CLOCK_MANAGER is
	signal CLK200				: std_logic;
	signal IDELAY_RDY			: std_logic;
	signal LOCKED				: std_logic;
	signal CLKLOCKEDi			: std_logic;
	signal RESETi				: std_logic;
begin
	-- ***************************************************************
	-- OUTPUT ASSIGN
	-- ***************************************************************
	RESET			<= RESETi or (not IDELAY_RDY);
	CLK_LOCKED	<= CLKLOCKEDi;
	-- ***************************************************************
	-- LOCAL ASSIGN
	-- ***************************************************************
	CLKLOCKEDi	<= LOCKED and IDELAY_RDY;
	RESETi		<= CPU_RESET or (not LOCKED);

	clk_inst : entity work.CLK_CORE
	port map 
		(
		-- Clock in ports
		clk_in_n 	=> SYSCLK_N,-- 200 MHz
		clk_in_p 	=> SYSCLK_p,-- 200 MHz
		
		-- Clock out ports
		clk_out1	=> CLK200, 	-- 200 MHz
		clk_out2 	=> CLK_4X,	--100 MHz
		clk_out3 	=> CLK_2X,	--50 MHz
		clk_out4 	=> CLK_1X,	--25 MHz
		
		-- Status and control signals
		reset  		=> CPU_RESET,
		locked 		=> LOCKED
		);
		
		CLK_8X	<= CLK200;

	-- ***************************************************************
	-- IDELAYCTRL
	-- ***************************************************************
	idelayctrl_inst : idelayctrl
	Port map (
		rst    		=> RESETi,
		refclk 		=> CLK200,
		rdy    		=> IDELAY_RDY
	);

end rtl;

