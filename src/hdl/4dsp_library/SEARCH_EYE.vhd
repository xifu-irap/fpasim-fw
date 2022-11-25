----------------------------------------------------------------------------------
-- Company:  IPNO - SEP
-- Engineer: Bengyun Ky
-- 
-- Create Date:    15:10:06 11/16/2011 
-- Design Name:    DALTON MAIN BOARD
-- Module Name:    Search_Eye - rtl 
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
--use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SEARCH_EYE is
	Generic (
		C_DELAY_INDEX	: integer := 16
	);
	Port (
		RESET 		: in  std_logic;
		CLK 			: in  std_logic;
		FADC_CLK		: in  std_logic;
		FINISH		: out std_logic;
		EN 			: in  std_logic;
		DIN 			: in  std_logic_vector(13 downto 0);
		SYNC_OK 		: out std_logic;
		SYNC_ERROR 	: out std_logic;
		DELAY_INC 	: out std_logic;
		DELAY_RST 	: out std_logic
	);
end SEARCH_EYE;

architecture rtl of SEARCH_EYE is
--	function GET_MIDDLE_EYE5(A : std_logic_vector) return integer is
--		variable S	: integer;
--		variable AA	: std_logic_vector(A'high+4 downto 0);
--	begin
--		AA(A'high downto 0)	:= A;
--		AA(A'high+1)	:= A(0);
--		AA(A'high+2)	:= A(1);
--		AA(A'high+3)	:= A(2);
--		AA(A'high+4)	:= A(3);
--		S := 63;
--		L0 : for i in 0 to 32 loop
--			if AA(i+4 downto i) = "00000" then
--				S := i + 2;
--				exit;
--			end if;
--		end loop L0;
--		if S = 34 then
--			S	:= 32;
--		end if;
--		return S;
--	end GET_MIDDLE_EYE5;
	
	type TYPE_SEQEYE is (IDLE,SEARCH_0,SEARCH_1,SEARCH_2,SEARCH_3,
								INC_DELAY,RESET_DELAY,GOBACK,ANALYSE,ANALYSE_OK,ANALYSE_ERR);
	signal SEQEYE			: TYPE_SEQEYE;
	signal NEXTSEQEYE		: TYPE_SEQEYE;
	
	signal SYNC				: std_logic;
	signal RST				: std_logic;
	signal INC				: std_logic;
	signal COUNT			: std_logic_vector(16 downto 0);
	signal ERROR			: std_logic;
	signal CMP_EN			: std_logic;
	signal CLR_COUNT		: std_logic;
	signal BIT_ERR			: std_logic_vector(34 downto 0);
begin
	RST			<= RESET or (not EN);
	SYNC_OK		<= SYNC;
	DELAY_INC	<= INC;
	--
	-- Process Search Delay Counter
	--
	process(CLK,RST,INC,CLR_COUNT)
	begin
		if RST = '1' or INC = '1' or CLR_COUNT = '1' then
			COUNT		<= (others=>'0');
			CMP_EN	<= '0';
		elsif rising_edge(CLK) then
			if SYNC = '0' then
				COUNT		<= COUNT + 1;
			end if;
			if COUNT(2) = '1' then
				CMP_EN	<= '1';
			end if;
		end if;
	end process;
	--
	-- Process Verify if DIN = 0x1555 or 0x2AAA
	--
	process(FADC_CLK,RST,INC,CLR_COUNT)
	begin
		if RST = '1' or INC = '1' or CLR_COUNT = '1' then
			ERROR		<= '0';
		elsif rising_edge(FADC_CLK) then
			if DIN /= X"1555" and DIN /= X"2AAA"  and CMP_EN = '1' then
				ERROR	<= '1';
			end if;
		end if;
	end process;
	--
	-- Process Search EYE
	--
	process(CLK,RST)
		variable DELAY_STEP	: integer range 0 to 31;
		variable i				: integer range 0 to 34;
		variable j				: integer range 0 to 31;
	begin
		if RST = '1' then
			SYNC			<= '0';
			DELAY_RST	<= '0';
			INC			<= '0';
			SYNC_ERROR	<= '0';
			CLR_COUNT	<= '0';
			FINISH		<= '0';
			DELAY_STEP	:= 0;
			i				:= 0;
			j				:= 0;
			BIT_ERR		<= (others=>'0');
			SEQEYE		<= IDLE;
			NEXTSEQEYE	<= IDLE;
		elsif rising_edge(CLK) then
			case SEQEYE is
				when IDLE =>
					SYNC					<= '0';
					SYNC_ERROR			<= '0';
					DELAY_STEP			:= 0;
					INC					<= '0';
					CLR_COUNT			<= '0';
					FINISH				<= '0';
					BIT_ERR				<= (others=>'0');
					SEQEYE				<= RESET_DELAY;
					NEXTSEQEYE			<= SEARCH_0;
				when SEARCH_0 =>
					if COUNT(C_DELAY_INDEX) = '1' then
						BIT_ERR(DELAY_STEP)	<= ERROR;
						if DELAY_STEP < 31 then
							SEQEYE		<= INC_DELAY;
							NEXTSEQEYE	<= SEARCH_0;
						else
							SEQEYE		<= SEARCH_1;
						end if;
					end if;
				when SEARCH_1 =>	-- 
					BIT_ERR(34 downto 32)	<= BIT_ERR(2 downto 0);
					i						:= 0;
					j						:= 0;
					SEQEYE				<= ANALYSE;
				when SEARCH_2 =>	-- 
					if i = 0 then
						INC				<= '0';
						SYNC				<= '1';
						SYNC_ERROR		<= '0';
						SEQEYE			<= SEARCH_3;						
					else
						INC				<= '1';
						i					:= i - 1;
					end if;
				when SEARCH_3 =>	-- 					
					FINISH				<= '1';
					SEQEYE				<= SEARCH_3;
				-- SUB-ROUTINES ----------------
				when INC_DELAY =>
					INC				<= '1';
					DELAY_STEP		:= DELAY_STEP + 1;
					SEQEYE			<= GOBACK;
				when RESET_DELAY =>
					DELAY_RST			<= '1';
					CLR_COUNT			<= '1';
					DELAY_STEP			:= 0;
					SEQEYE				<= GOBACK;					
				when GOBACK =>
					INC					<= '0';
					CLR_COUNT			<= '0';
					DELAY_RST			<= '0';
					SEQEYE				<= NEXTSEQEYE;
				--
				when ANALYSE =>
					if BIT_ERR(i) = '0' then
						j					:= j + 1;
					else
						if j > 3 then
							SEQEYE		<= ANALYSE_OK;
						else
							j				:= 0;
						end if;
					end if;
					if i = 34 then
						if j > 3 then
							SEQEYE		<= ANALYSE_OK;
						else
							SEQEYE		<= ANALYSE_ERR;
						end if;
					end if;
					i						:= i + 1;
				when ANALYSE_OK =>
					i						:= i - (j / 2);
					SEQEYE				<= SEARCH_2;
				when ANALYSE_ERR =>
					SYNC					<= '0';
					SYNC_ERROR			<= '1';
					SEQEYE				<= SEARCH_3;
--				when others =>
--					SEQEYE				<= IDLE;
			end case;
		end if;
	end process;
end rtl;