----------------------------------------------------------------------------------
-- Company : 
-- Engineer: Bengyun Ky
-- 
-- Create Date:    06:22:41 05/05/2011 
-- Design Name: 
-- Module Name:    FADC_Sync - rtl 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
  use work.FMC150_package.all;

entity FADC_SYNC is
	Port ( 
		RESET 			: in  std_logic;
		CLK				: in  std_logic;
		--
		FINISH			: out std_logic;
		DOUTXY_CLK		: out std_logic;
		--
		DOUTX				: out std_logic_vector(13 downto 0);
		CHX_EN			: in  std_logic;
		CHX_SYNC_OK		: out std_logic;
		CHX_SYNC_ERR	: out std_logic;
		--
		DOUTY				: out std_logic_vector(13 downto 0);
		CHY_EN			: in  std_logic;
		CHY_SYNC_OK		: out std_logic;
		CHY_SYNC_ERR	: out std_logic;
		-- LVDS I/O
		CLKXY_P 			: in  std_logic;
		CLKXY_N 			: in  std_logic;
		CHX_P 			: in  std_logic_vector(6 downto 0);
		CHX_N 			: in  std_logic_vector(6 downto 0);
		CHY_P 			: in  std_logic_vector(6 downto 0);
		CHY_N 			: in  std_logic_vector(6 downto 0)
	);
end FADC_SYNC;

architecture rtl of FADC_SYNC is
	component icon is
	Port (
		CONTROL0 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		CONTROL1 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		CONTROL2 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0));
	end component;
	component ila is
	Port (
		CONTROL 	: INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		CLK 		: IN STD_LOGIC;
		TRIG0 	: IN STD_LOGIC_VECTOR(255 DOWNTO 0));
	end component;
	signal CONTROL0		: std_logic_vector(35 downto 0);
	signal ila_adc_trig0		: std_logic_vector(255 downto 0);
	
	constant C_GND			: std_logic_vector(255 downto 0) := (others=>'0');
	signal FADC_CLK		: std_logic;
	signal CHX_FINISH		: std_logic;
	signal CHY_FINISH		: std_logic;
	signal CHX_DOUT		: std_logic_vector(13 downto 0);
	signal CHX_INC			: std_logic;
	signal XSYNC_OK		: std_logic;
	signal CHX_DELAY_RST	: std_logic;
	signal CHY_DOUT		: std_logic_vector(13 downto 0);
	signal CHY_INC			: std_logic;
	signal CHY_DELAY_RST	: std_logic;
	signal YSYNC_OK		: std_logic;
begin
	DOUTXY_CLK	<= FADC_CLK;
	DOUTX			<= CHX_DOUT;
	DOUTY			<= CHY_DOUT;
	CHX_SYNC_OK	<= XSYNC_OK;
	CHY_SYNC_OK	<= YSYNC_OK;
	FINISH		<= (CHX_FINISH or (not CHX_EN)) and
						(CHY_FINISH or (not CHY_EN));
--	
---- ICON
------------------------------------------------------------------------------------------------------
--icon_inst : icon
--port map (
--  control0 => control0,
--    control1 => open,
--  control2 => open
--  );
--ila_adc_inst : ila
--port map (
--  clk     => CLK,
--  trig0   => ila_adc_trig0,
--  control => control0
--);
--
---- ILA Mapping
--
--ila_adc_trig0 <= C_GND(220 downto 0) & CHX_SYNC_ERR & CHY_SYNC_ERR & CHX_INC & CHY_INC;

	fadcio_inst : entity work.FADC_IOBUF
	Generic map(
		C_CHX_IDELAY	=> 0,
		C_CHY_IDELAY	=> 0
	)
	Port map(
		RESET 			=> RESET,			-- I
		CLK				=> CLK,				-- I
		FADC_CLK 		=> FADC_CLK,		-- O
		--
		CHX_DOUT			=> CHX_DOUT,		-- O[13:0]
		CHX_INC			=> CHX_INC,			-- I
		CHX_DELAY_RST	=> CHX_DELAY_RST,	-- I
		--
		CHY_DOUT			=> CHY_DOUT,		-- O[13:0]
		CHY_INC			=> CHY_INC,			-- I
		CHY_DELAY_RST	=> CHY_DELAY_RST,	-- I
		--
		CLKXY_P 			=> CLKXY_P,			-- I
		CLKXY_N 			=> CLKXY_N,			-- I
		CHX_P 			=> CHX_P,			-- I[6:0]
		CHX_N 			=> CHX_N,			-- I[6:0]
		CHY_P 			=> CHY_P,			-- I[6:0]
		CHY_N 			=> CHY_N				-- I[6:0]
	);
	--
	-- Search Eye Component
	--
	eyex_inst : entity work.Search_Eye
	Generic map(
		C_DELAY_INDEX	=> 16
	)
	Port map(
		RESET 			=> RESET,			-- I
		CLK				=> CLK,				-- I
		FADC_CLK			=> FADC_CLK,		-- I
		FINISH			=> CHX_FINISH,		-- O
		EN 				=> CHX_EN,			-- I
		DIN 				=> CHX_DOUT,		-- I[13:0]
		SYNC_OK 			=> XSYNC_OK,		-- O
		SYNC_ERROR 		=> CHX_SYNC_ERR,	-- O
		DELAY_INC 		=> CHX_INC,			-- O
		DELAY_RST 		=> CHX_DELAY_RST	-- O
	);
	eyey_inst : entity work.Search_Eye
	Generic map(
		C_DELAY_INDEX	=> 16
	)
	Port map(
		RESET 			=> RESET,			-- I
		CLK				=> CLK,				-- I
		FADC_CLK			=> FADC_CLK,		-- I
		FINISH			=> CHY_FINISH,		-- O
		EN 				=> CHY_EN,			-- I
		DIN 				=> CHY_DOUT,		-- I[13:0]
		SYNC_OK 			=> YSYNC_OK,		-- O
		SYNC_ERROR 		=> CHY_SYNC_ERR,	-- O
		DELAY_INC 		=> CHY_INC,			-- O
		DELAY_RST 		=> CHY_DELAY_RST	-- O
	);
	
end rtl;

