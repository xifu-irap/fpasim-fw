----------------------------------------------------------------------------------
-- Company       : CNRS - INSU - IRAP
-- Engineer      : Christophe Oziol
-- 
-- Create Date   : 14/09/2015 
-- Design Name   : 
-- Module Name   : FMC150_CONTROLER - Behavioral 
-- Project Name  : Athena XIfu DRE
-- Target Devices: Vitex 6 LX 240
-- Tool versions : ISE-14.7
-- Description   : Manage the FMC150 board placed on ML605
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
---------------------oOo(o-o)oOo-------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

  use work.FMC150_package.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity FMC150_CONTROLER is
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
end FMC150_CONTROLER;
architecture  Behavioral of FMC150_CONTROLER is
signal HW_RESETi			 : std_logic;
signal RESET_FADCi		 : std_logic;
signal CLK_4Xi				 : std_logic;
signal CLK_1Xi				 : std_logic;

-- FADC CLOCK BASED CLOCKS
signal CLK_122_88     	 : std_logic;
signal CLK_61_44			 : std_logic;
signal CLK_30_72  	    : std_logic;
signal CLK_15_36  	    : std_logic;	
signal mmcm_adac_locked  : std_logic; -- LOCKED OF THE FADC CLOCKS MANAGER
signal CLK_locked  		 : std_logic; -- LOCKED OF THE SYSTEM BOARD CLOCK
signal clkfbout          : std_logic;
--FADC CONTROL SIGNALS
signal FADC_EN           : std_logic_vector(1 downto 0);
signal FADC_SYNC_OK 		 : std_logic_vector(1 downto 0);
signal FADC_SYNC_FINISH	 : std_logic;

signal CLK_OK		  		 : std_logic; -- LOCKED OF THE SYSTEM BOARD CLOCK and the FADC CLOCK MANAGER
signal FADC_CHAB_CLKi	 : std_logic; -- FADC CLOCK 
signal FADC_CHA_DATA		 : std_logic_vector(13 downto 0); -- FADC_DATA A
signal FADC_CHB_DATA		 : std_logic_vector(13 downto 0); -- FADC DATA B
signal FADC_CHA_16i		 	: std_logic_vector(15 downto 0); -- FADC_DATA A
signal FADC_CHA_16i_signed	: signed(15 downto 0); -- FADC_DATA A
signal FADC_CHB_16i 		: std_logic_vector(15 downto 0); -- FADC DATA B
signal FADC_CHB_16i_signed 	: signed(15 downto 0); -- FADC DATA B

signal FADC_SYNC_FINISH_OK       : std_logic; -- FADC synchro finiched correctly
signal FADC_TEST_FINISH_OK       : std_logic; -- FADC synchro verification finiched correctly
  
begin

	-- ***************************************************************
	-- CLOCK MANAGER
	-- ***************************************************************
-- creation de l'horloge SYS_CLK a partir de l'horloge ML605 sert
-- au demarrage et a la configuration de la carte FMC150
clkmgr_inst : CLOCK_MANAGER
Port map(
  CPU_RESET 				=> CPU_RESET,
  SYSCLK_P 				=> SYSCLK_P,
  SYSCLK_N 				=> SYSCLK_N,
  RESET						=> HW_RESETi,
  CLK_8X					=> CLK_8X,
  CLK_4X					=> CLK_4Xi,
  CLK_2X					=> open,
  CLK_1X					=> CLK_1Xi,
  CLK_LOCKED				=> CLK_LOCKED
);

   MMCME2_BASE_inst : MMCME2_BASE
   generic map (
      BANDWIDTH => "OPTIMIZED",  -- Jitter programming (OPTIMIZED, HIGH, LOW)
      CLKFBOUT_MULT_F => 4.0,    -- Multiply value for all CLKOUT (2.000-64.000).
      CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB (-360.000-360.000).
      CLKIN1_PERIOD => 0.0,      -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
      CLKOUT1_DIVIDE => 8,
      CLKOUT2_DIVIDE => 16,
      CLKOUT3_DIVIDE => 32,
      CLKOUT4_DIVIDE => 64,
      CLKOUT5_DIVIDE => 1,
      CLKOUT6_DIVIDE => 1,
      CLKOUT0_DIVIDE_F => 1.0,   -- Divide amount for CLKOUT0 (1.000-128.000).
      -- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
      CLKOUT0_DUTY_CYCLE => 0.5,
      CLKOUT1_DUTY_CYCLE => 0.5,
      CLKOUT2_DUTY_CYCLE => 0.5,
      CLKOUT3_DUTY_CYCLE => 0.5,
      CLKOUT4_DUTY_CYCLE => 0.5,
      CLKOUT5_DUTY_CYCLE => 0.5,
      CLKOUT6_DUTY_CYCLE => 0.5,
      -- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
      CLKOUT0_PHASE => 0.0,
      CLKOUT1_PHASE => 0.0,
      CLKOUT2_PHASE => 0.0,
      CLKOUT3_PHASE => 0.0,
      CLKOUT4_PHASE => 0.0,
      CLKOUT5_PHASE => 0.0,
      CLKOUT6_PHASE => 0.0,
      CLKOUT4_CASCADE => FALSE,  -- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
      DIVCLK_DIVIDE => 1,        -- Master division value (1-106)
      REF_JITTER1 => 0.0,        -- Reference input jitter in UI (0.000-0.999).
      STARTUP_WAIT => FALSE      -- Delays DONE until MMCM is locked (FALSE, TRUE)
   )
   port map (
      -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
      CLKOUT1 => CLK_122_88,     -- 1-bit output: CLKOUT0
      CLKOUT2 => CLK_61_44,     -- 1-bit output: CLKOUT1
      CLKOUT3 => CLK_30_72,     -- 1-bit output: CLKOUT2
      CLKOUT4 => CLK_15_36,     -- 1-bit output: CLKOUT3
      
      -- Status Ports: 1-bit (each) output: MMCM status ports
	    CLKFBOUT => clkfbout,   -- 1-bit output: Feedback clock
      LOCKED => mmcm_adac_locked,       -- 1-bit output: LOCK
      -- Clock Inputs: 1-bit (each) input: Clock input
      CLKIN1 => FADC_CHAB_CLKi,       -- 1-bit input: Clock
      -- Control Ports: 1-bit (each) input: MMCM control ports
      PWRDWN => '0',       -- 1-bit input: Power-down
      RST => HW_RESETi,             -- 1-bit input: Reset
      -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
      CLKFBIN => clkfbout      -- 1-bit input: Feedback clock
   );

CLK_ADC_DIV2	<=	CLK_122_88; --122.88MHz
CLK_ADC_DIV4	<=	CLK_61_44; 	--61.44MHz
CLK_ADC_DIV8	<=	CLK_30_72; 	--30.72MHz
CLK_ADC_DIV16	<=	CLK_15_36; 	--15.36MHz
	 

CLK_OK <=  mmcm_adac_locked and CLK_LOCKED;
LOCKED <= CLK_OK;
mmcm_adac_locked_out <= mmcm_adac_locked;

-- ***************************************************************
-- FAST ADC DATA IN ALIGNEMENT CONTROLER
-- ***************************************************************

	eye_inst : entity work.FADC_INPUT_ALIGNEMENT
	Port map(
		RESET 					=> RESET_FADCi,				-- I
		CLK 						=> CLK_4Xi,				-- I
		-- 16 FAST-ADC Maximum
		FADC_EN 					=> FADC_EN,				-- I[1:0]
		FADC_SYNC_OK 			=> FADC_SYNC_OK,		-- O[1:0]
		FADC_SYNC_FINISH		=> FADC_SYNC_FINISH,	-- O
		--
		FADC_CHA_DATA			=> FADC_CHA_DATA,		-- O[13:0]
		FADC_CHB_DATA			=> FADC_CHB_DATA,		-- O[13:0]
		FADC_CHAB_CLK			=> FADC_CHAB_CLKi,		-- O
		-- FAST ADC CLOCK/DATA BUS
		FADC_CHA_P				=>   cha_p,			-- I[6:0]
		FADC_CHA_N				=>   cha_n,			-- I[6:0]
		FADC_CHB_P				=>   chb_p,			-- I[6:0]
		FADC_CHB_N				=>   chb_n,			-- I[6:0]
		FADC_CLKAB_P			=>   clk_ab_p,		-- I
		FADC_CLKAB_N			=>   clk_ab_n		-- I
	);
	

----------------------------------------------------------------------------------------------------
-- Extend FADC to 16-bit
----------------------------------------------------------------------------------------------------
process (HW_RESETi,FADC_CHAB_CLKi)
begin
	if (HW_RESETi='1') then
	FADC_CHA_16i <= (others =>'0');
	FADC_CHB_16i <= (others =>'0');
	FADC_SYNC_FINISH_OK <='0';
	FADC_EN <= "11";
	else
		if (rising_edge(FADC_CHAB_CLKi)) then
		FADC_SYNC_FINISH_OK <= FADC_SYNC_OK(1) and FADC_SYNC_OK(0) and FADC_SYNC_FINISH;
		-- Left justify the data of both channels on 16-bits
		--FADC_CHA_16i <= std_logic_vector(resize(signed(FADC_CHA_DATA),16));
		--FADC_CHB_16i <= std_logic_vector(resize(signed(FADC_CHB_DATA),16));
		FADC_CHA_16i <= FADC_CHA_DATA & "00";
		FADC_CHB_16i <= FADC_CHB_DATA & "00";
		end if;
	end if;
end process;
----------------------------------------------------------------------------------------------------
-- Reset sequencer
----------------------------------------------------------------------------------------------------
reset_sequencer_inst: entity work.FMC150_reset_sequencer
	Port Map
			(
			CPU_RESET				=> CPU_RESET,
			CLK_4X					=> CLK_4Xi,
			CLK_1X					=> CLK_1Xi,
			CLK_OK					=> CLK_OK,
			HW_RESET					=> HW_RESETi,

			--Serial Peripheral Interface (SPI)
			spi_sclk					=> spi_sclk, -- Shared SPI clock line
			spi_sdata				=> spi_sdata, -- Shared SPI sata line

			-- ADC specific signals
			adc_n_en					=> adc_n_en, 	-- SPI chip select
			adc_sdo 					=> adc_sdo,  	-- SPI data out
			adc_reset				=> adc_reset, 	-- SPI reset

			-- CDCE specific signals
			cdce_n_en				=> cdce_n_en,  -- SPI chip select
			cdce_sdo					=> cdce_sdo,  -- SPI data out
			cdce_n_reset			=> cdce_n_reset,  
			cdce_n_pd				=> cdce_n_pd,  
			ref_en					=> ref_en,  
			pll_status				=> pll_status,  

			-- DAC specific signals
			dac_n_en 				=> dac_n_en,   -- SPI chip select
			dac_sdo 					=> dac_sdo,   -- SPI data out

			-- Monitoring specific signals
			mon_n_en					=> mon_n_en,   -- SPI chip select
			mon_sdo					=> mon_sdo,   -- SPI data out
			mon_n_reset				=> mon_n_reset,  
			mon_n_int				=> mon_n_int,  

			--FMC Present status
			prsnt_m2c_l				=> prsnt_m2c_l,  
			-- Reset FADC Controler
			RESET_FADC				=> RESET_FADCi,
			FADC_SYNC_FINISH_OK 	=>	FADC_SYNC_FINISH_OK,

			
			-- End of FMC150 configuration
			FMC150_READY			=> FMC150_READY,
			rxenable					=> rxenable,  
--			txenable					=> txenable,
			
			-- Send frame synchro to DAC
--			FRAME						=> FRAME,  

			-- FADC CLOCK AND DATA INPUT FOR SYNCHRO TEST ONLY
			FADC_CHAB_CLK			=> FADC_CHAB_CLKi,   -- CLK FADC
			FADC_CHA_16				=> FADC_CHA_16i,   -- 16-bits FADC DATA used to test synchronisation
			FADC_CHB_16				=> FADC_CHB_16i   -- 16-bits FADC DATA used to test synchronisation
);
			FADC_CHAB_CLK			<= FADC_CHAB_CLKi;   -- CLK FADC transfert out
			FADC_CHA_16				<= FADC_CHA_16i;   -- 16-bits FADC DATA used to test synchronisation
			FADC_CHB_16				<= FADC_CHB_16i;   -- 16-bits FADC DATA used to test synchronisation
			HW_RESET					<= HW_RESETi;   -- 16-bits FADC DATA used to test synchronisation
			SYS_CLK					<= CLK_4Xi;   -- 16-bits FADC DATA used to test synchronisation
--			CLK_1X					<= CLK_1Xi;   -- 16-bits FADC DATA used to test synchronisation
			RESET_FADC				<= RESET_FADCi;
end Behavioral;