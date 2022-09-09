----------------------------------------------------------------------------------
-- Company:  IPNO - SEP
-- Engineer: Bengyun Ky
-- 
-- Create Date:    10:43:56 05/03/2011 
-- Design Name:    DALTON MAIN BOARD
-- Module Name:    ADS62P49_IOBUF - rtl 
-- Project Name:	 DALTON_HDL
-- Target Devices: Xilinx Virtex-6 XC6VLX130T-2FF1156
-- Tool versions:  ISE 13.1
-- Description: modification spéc pour lvds25
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
--use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity FADC_IOBUF is
	Generic (
		C_CHX_IDELAY	: integer := 0;
		C_CHY_IDELAY	: integer := 0
	);
	Port (
		RESET 			: in  std_logic;
		CLK				: in  std_logic;
		FADC_CLK 		: out std_logic;
		--
		CHX_DOUT			: out std_logic_vector(13 downto 0);
		CHX_INC			: in  std_logic;
		CHX_DELAY_RST	: in  std_logic;
		--
		CHY_DOUT			: out std_logic_vector(13 downto 0);
		CHY_INC			: in  std_logic;
		CHY_DELAY_RST	: in  std_logic;
		--
		CLKXY_P 			: in  std_logic;
		CLKXY_N 			: in  std_logic;
		CHX_P 			: in  std_logic_vector(6 downto 0);
		CHX_N 			: in  std_logic_vector(6 downto 0);
		CHY_P 			: in  std_logic_vector(6 downto 0);
		CHY_N 			: in  std_logic_vector(6 downto 0)
	);
end FADC_IOBUF;

architecture rtl of FADC_IOBUF is
	signal CLKXY			: std_logic;
	signal CLKXY_LVTTL	: std_logic;
	signal CHX_SDR			: std_logic_vector(13 downto 0);
	signal CHY_SDR			: std_logic_vector(13 downto 0);
	signal CEX				: std_logic;
	signal CEY				: std_logic;
	signal CHX_DDR			: std_logic_vector(6 downto 0);
	signal CHY_DDR			: std_logic_vector(6 downto 0);
	signal CHX_DDR_DLY	: std_logic_vector(6 downto 0);
	signal CHY_DDR_DLY	: std_logic_vector(6 downto 0);
	signal IDELAYX_RST	: std_logic;
	signal IDELAYY_RST	: std_logic;
begin
	FADC_CLK	<= CLKXY;
	CHX_DOUT	<= CHX_SDR;
	CHY_DOUT	<= CHY_SDR;
	-- ---------------------------------
	-- CLOCK INPUT
	-- ---------------------------------
	clk_ibufds_inst : ibufgds
	generic map (
	IOSTANDARD => "LVDS_25",
	DIFF_TERM  => TRUE
	)
	Port map (
		i		=> CLKXY_P,
		ib		=> CLKXY_N,
		o		=> CLKXY
	);
--	clk_bufg_inst : bufg
--	Port map (
--		i		=> CLKXY_LVTTL,
--		o		=> CLKXY
--	);
	-- ---------------------------------
	-- DATA_X INPUT
	-- ---------------------------------
	CEX			<= CHX_INC;
	IDELAYX_RST	<= CHX_DELAY_RST or RESET;
	
	data_x : for i in 0 to 6 generate
		data_x_ibufds_inst : ibufds
		generic map (
		IOSTANDARD => "LVDS_25",
		DIFF_TERM  => TRUE
		)
		Port map (
			i		=> CHX_P(i),
			ib		=> CHX_N(i),
			o		=> CHX_DDR(i)
		);
		--
		data_x_iodelay_inst : iodelaye1
		Generic map (
			IDELAY_TYPE  	=> "VAR_LOADABLE",		-- "FIXED","VARIABLE"
			IDELAY_VALUE	=> C_CHX_IDELAY,
			DELAY_SRC    	=> "I"
		)
		Port map (
			dataout 		=> CHX_DDR_DLY(i),
			idatain		=> CHX_DDR(i),

			c 				=> CLK,
			ce 			=> CEX,
			inc 			=> CHX_INC,
			datain 		=> '0',
			odatain 		=> '0',
			clkin 		=> '0',
			rst 			=> IDELAYX_RST,
			cntvaluein 	=> conv_std_logic_vector(C_CHX_IDELAY, 5),
			cinvctrl 	=> '0',
			t 				=> '1'
		);
		-- DDR to SDR
		data_a_iddr_inst : iddr
		Generic map (
			DDR_CLK_EDGE => "SAME_EDGE_PIPELINED"
		)
		Port map (
			q1 	=> CHX_SDR(2*i),
			q2 	=> CHX_SDR(2*i+1),
			c  	=> CLKXY,
			ce 	=> '1',
			d  	=> CHX_DDR_DLY(i),
			r  	=> '0',
			s  	=> '0'
		);
	end generate data_x;
	-- ---------------------------------
	-- DATA_Y INPUT
	-- ---------------------------------
	CEY			<= CHY_INC;
	IDELAYY_RST	<= CHY_DELAY_RST or RESET;
	
	data_y : for i in 0 to 6 generate
		data_y_ibufds_inst : ibufds
		generic map (
		IOSTANDARD => "LVDS_25",
		DIFF_TERM  => TRUE
		)
		Port map (
			i		=> CHY_P(i),
			ib		=> CHY_N(i),
			o		=> CHY_DDR(i)
		);
		--
		data_y_iodelay_inst : iodelaye1
		Generic map (
			IDELAY_TYPE  	=> "VARIABLE",		--"FIXED",
			IDELAY_VALUE	=> C_CHY_IDELAY,
			DELAY_SRC    	=> "I"
		)
		Port map (
			dataout 		=> CHY_DDR_DLY(i),
			idatain		=> CHY_DDR(i),

			c 				=> CLK,
			ce 			=> CEY,
			inc 			=> CHY_INC,
			datain 		=> '0',
			odatain 		=> '0',
			clkin 		=> '0',
			rst 			=> IDELAYY_RST,
			cntvaluein 	=> conv_std_logic_vector(C_CHY_IDELAY, 5),
			cinvctrl 	=> '0',
			t 				=> '1'
		);
		-- DDR to SDR
		data_a_iddr_inst : iddr
		Generic map (
			DDR_CLK_EDGE => "SAME_EDGE_PIPELINED"
		)
		Port map (
			q1 	=> CHY_SDR(2*i),
			q2 	=> CHY_SDR(2*i+1),
			c  	=> CLKXY,
			ce 	=> '1',
			d  	=> CHY_DDR_DLY(i),
			r  	=> '0',
			s  	=> '0'
		);
	end generate data_y;
end rtl;

