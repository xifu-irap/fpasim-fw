----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:56:10 04/01/2015 
-- Design Name: 
-- Module Name:    athena_package - Behavioral 
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
  use ieee.numeric_std.all;
--use ieee.std_logic_signed.all;
--use ieee.std_logic_arith.all;
--use std.textio.all;

---------------------------------------------------------------
--
-- PACKAGE
--
---------------------------------------------------------------
package fmc150_package is
Component CLOCK_MANAGER 
	Port (		CPU_RESET 			: in  std_logic;		SYSCLK_P 			: in  std_logic;		SYSCLK_N 			: in  std_logic;
		RESET					: out std_logic;
		CLK_8X				: out std_logic;
		CLK_4X				: out std_logic;
		CLK_2X				: out std_logic;
		CLK_1X				: out std_logic;
		CLK_LOCKED			: out std_logic
	);
end component CLOCK_MANAGER;

Component FADC_INPUT_ALIGNEMENT
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
end Component FADC_INPUT_ALIGNEMENT;

Component FMC150_CONTROLER
	Port (
  cpu_reset		    : in    std_logic; -- RESET switch
  HW_RESET      	 : out   std_logic; -- RESET harware from System CLOCK MMCM
  LOCKED	      	 : out   std_logic; -- ALL CLOCK MMCM LOCKED
  SYSCLK_P		    : in    std_logic; -- SYSTEM CLOCK FROM ML605 BOARD
  SYSCLK_N		    : in    std_logic; -- SYSTEM CLOCK FROM ML605 BOARD
--Clock/Data connection to ADC on FMC150 (ADS62P49)
  clk_ab_p         : in    std_logic;
  clk_ab_n         : in    std_logic;
  cha_p            : in    std_logic_vector(6 downto 0);
  cha_n            : in    std_logic_vector(6 downto 0);
  chb_p            : in    std_logic_vector(6 downto 0);
  chb_n            : in    std_logic_vector(6 downto 0);
  rxenable         : out   std_logic;

  -- --Clock/Data connection to DAC on FMC150 (DAC3283)
  -- dac_dclk_p       : out   std_logic;
  -- dac_dclk_n       : out   std_logic;
  -- dac_data_p       : out   std_logic_vector(7 downto 0);
  -- dac_data_n       : out   std_logic_vector(7 downto 0);
  -- txenable         : out   std_logic;

--  --Clock/Trigger connection to FMC150
--  clk_to_fpga_p    : in    std_logic;
--  clk_to_fpga_n    : in    std_logic;
--  ext_trigger_p    : in    std_logic;
--  ext_trigger_n    : in    std_logic;

  --Serial Peripheral Interface (SPI)
  spi_sclk         : out   std_logic; -- Shared SPI clock line
  spi_sdata        : out   std_logic; -- Shared SPI sata line

  -- ADC specific signals
  adc_n_en         : out   std_logic; -- SPI chip select
  adc_sdo          : in    std_logic; -- SPI data out
  adc_reset        : out   std_logic; -- SPI reset

  -- CDCE specific signals
  cdce_n_en        : out   std_logic; -- SPI chip select
  cdce_sdo         : in    std_logic; -- SPI data out
  cdce_n_reset     : out   std_logic;
  cdce_n_pd        : out   std_logic;
  ref_en           : out   std_logic;
  pll_status       : in    std_logic;

  -- DAC specific signals
  dac_n_en         : out   std_logic; -- SPI chip select
  dac_sdo          : in    std_logic; -- SPI data out

  -- Monitoring specific signals
  mon_n_en         : out   std_logic; -- SPI chip select
  mon_sdo          : in    std_logic; -- SPI data out
  mon_n_reset      : out   std_logic;
  mon_n_int        : in    std_logic;

  --FMC Present status
  prsnt_m2c_l      : in    std_logic;
  
  -- FMC init OUTPUT
  RESET_FADC		  : out 	 std_logic;
	-- End of FMC150 configuration
	FMC150_READY	  : out 	 std_logic;
	-- Send Frame synchro to DAC
--	FRAME				  : out 	 std_logic;
	-- Clock from system input clock 
	SYS_CLK			 : out 	 std_logic;  
	CLK_8X			 : out 	 std_logic; 
--	CLK_1X			 : out 	 std_logic; 
	-- Clock from ADC input clock 
	CLK_ADC_DIV2	 	: out 	 std_logic; --122.88MHz
	CLK_ADC_DIV4	 	: out 	 std_logic; --61.44MHz
	CLK_ADC_DIV8	 	: out 	 std_logic; --30.72MHz
	CLK_ADC_DIV16	 	: out 	 std_logic; --15.36MHz
	mmcm_adac_locked_out: out 	 std_logic; 
	
 --RECONSTRUCTED Clock/Data FROM FADC on FMC150 (ADS62P49)
  FADC_CHAB_CLK    : out   std_logic;
  FADC_CHA_16      : out   std_logic_vector(15 downto 0);
  FADC_CHB_16      : out   std_logic_vector(15 downto 0)

);
end component;
component mmcm is
port (
  -- Clock in ports
  clk_in1_p : in  std_logic;
  clk_in1_n : in  std_logic;
  -- Clock out ports
  clk_out1  : out std_logic;
  clk_out2  : out std_logic;
  -- Status and control signals
  reset     : in  std_logic;
  locked    : out std_logic
);
end component mmcm;

component mmcm_FADC_clock
port
 (-- Clock in ports
  CLK_IN1           : in     std_logic;
  -- Clock out ports
  CLK_OUT1          : out    std_logic;
  CLK_OUT2          : out    std_logic;
  CLK_OUT3          : out    std_logic;
  CLK_OUT4          : out    std_logic;
  -- Status and control signals
  RESET             : in     std_logic;
  LOCKED            : out    std_logic
 );
end component;

component fmc150_spi_ctrl is
port (
  -- VIO command interface
  rd_n_wr          : in    std_logic;
  addr             : in    std_logic_vector(15 downto 0);
  idata            : in    std_logic_vector(31 downto 0);
  odata            : out   std_logic_vector(31 downto 0);
  busy             : out   std_logic;
  init_done			 :	out std_logic;
  
  cdce72010_valid  : in    std_logic;
  ads62p49_valid   : in    std_logic;
  dac3283_valid    : in    std_logic;
  amc7823_valid    : in    std_logic;

  external_clock   : in    std_logic;

  -- Global signals
  rst              : in    std_logic;
  clk              : in    std_logic;

  -- External signals
  spi_sclk         : out   std_logic;
  spi_sdata        : out   std_logic;

  adc_n_en         : out   std_logic;
  adc_sdo          : in    std_logic;
  adc_reset        : out   std_logic;

  cdce_n_en        : out   std_logic;
  cdce_sdo         : in    std_logic;
  cdce_n_reset     : out   std_logic;
  cdce_n_pd        : out   std_logic;
  ref_en           : out   std_logic;
  pll_status       : in    std_logic;

  dac_n_en         : out   std_logic;
  dac_sdo          : in    std_logic;

  mon_n_en         : out   std_logic;
  mon_sdo          : in    std_logic;
  mon_n_reset      : out   std_logic;
  mon_n_int        : in    std_logic;

  prsnt_m2c_l      : in    std_logic

);
end component fmc150_spi_ctrl;

Component FMC150_reset_sequencer 
	Port (
			CPU_RESET 		  : in 	 std_logic;
			CLK_4X	 		  : in 	 std_logic;
			CLK_1X	 		  : in 	 std_logic;
			HW_RESET   		  : in 	 std_logic;
			CLK_OK			  : in 	 std_logic;

			--Serial Peripheral Interface (SPI)
			spi_sclk         : out   std_logic; -- Shared SPI clock line
			spi_sdata        : out   std_logic; -- Shared SPI sata line

			-- ADC specific signals
			adc_n_en         : out   std_logic; -- SPI chip select
			adc_sdo          : in    std_logic; -- SPI data out
			adc_reset        : out   std_logic; -- SPI reset

			-- CDCE specific signals
			cdce_n_en        : out   std_logic; -- SPI chip select
			cdce_sdo         : in    std_logic; -- SPI data out
			cdce_n_reset     : out   std_logic;
			cdce_n_pd        : out   std_logic;
			ref_en           : out   std_logic;
			pll_status       : in    std_logic;

			-- DAC specific signals
			dac_n_en         : out   std_logic; -- SPI chip select
			dac_sdo          : in    std_logic; -- SPI data out

			-- Monitoring specific signals
			mon_n_en         : out   std_logic; -- SPI chip select
			mon_sdo          : in    std_logic; -- SPI data out
			mon_n_reset      : out   std_logic;
			mon_n_int        : in    std_logic;

			--FMC Present status
			prsnt_m2c_l      : in    std_logic;
			-- Reset FADC Controler
			RESET_FADC		  		: out 	 std_logic;
			FADC_SYNC_FINISH_OK 	: in    std_logic;
			-- End of FMC150 configuration
			FMC150_READY	  : out 	 std_logic; 
			rxenable			  : out 	 std_logic; 
--			txenable			  : out 	 std_logic; 
			-- SEND FRAME SYNCHRO TO DAC
--			FRAME	  : out 	 std_logic; 

			-- FADC CLOCK AND DATA
			FADC_CHAB_CLK    : in std_logic; -- CLK FADC
			FADC_CHA_16      : in std_logic_vector(15 downto 0); -- 16-bits FADC DATA used to test synchronisation
			FADC_CHB_16      : in std_logic_vector(15 downto 0) -- 16-bits FADC DATA used to test synchronisation
);
end component;

component DAC_serdes_manager 
	Port 
		(
		RESET			: in std_logic;
		CLK_2X		: in std_logic;
		CLK_1X 		: in std_logic;
	-- DAC control signal
		DAC_ON		: in unsigned (1 downto 0);
		txenable		: in std_logic;
		FRAME			: in std_logic;
	-- DAC DATA TO SEND
		DATA_OUT_A	: in std_logic_vector (15 downto 0);
		DATA_OUT_B  : in std_logic_vector (15 downto 0);
	-- DAC io Ports
		dac_dclk_p	: out std_logic;
		dac_dclk_n	: out std_logic;
		dac_frame_p	: out std_logic;
		dac_frame_n	: out std_logic;
		dac_data_p  : out   std_logic_vector(7 downto 0);
		dac_data_n  : out   std_logic_vector(7 downto 0)

);
end component;

----------------------------------------------------------------------------
-- Science filter 
----------------------------------------------------------------------------

component science_filter_CIC is
	 generic
		(
		size_in  				: positive := 30;
		size_out 				: positive := 16
		);
    Port 
		(
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
end component;

component Integrator_CIC is
	 Generic	(
				size_in  		: positive := 16;
				size_out 		: positive :=17
				);
    Port 	(
				--CLK_4X			: in std_logic;
				CLK_IN			: in std_logic;
				reset 			: in std_logic;
				START_STOP		: in std_logic;
				Int_in_dat 		: in signed(size_in-1 downto 0);
				Int_out_dat 	: out signed(size_out-1 downto 0));
end component;

-- Declaration comb_CIC
component Comb_CIC
	 generic
		( 
		size_in  				: positive := 52;
		size_out 				: positive := 52
		);
    Port
		(
				CLK_OUT					: in STD_LOGIC;
				reset 					: in 	std_logic;
				comb_in_dat 			: in  signed(size_in-1 downto 0);
				comb_out_dat			: out signed(size_out-1 downto 0)
      );
    end component;



end FMC150_package;