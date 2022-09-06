----------------------------------------------------------------------------------
-- Company       : CNRS - INSU - IRAP
-- Engineer      : Christophe Oziol
-- 
-- Create Date   : 14/09/2015 
-- Design Name   : 
-- Module Name   : FMC150_reset_sequencer - Behavioral 
-- Project Name  : Athena XIfu DRE
-- Target Devices: Vitex 6 LX 240
-- Tool versions : ISE-14.7
-- Description   : RESET the FMC150 board placed on ML605, sequencer of the startup configuration
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
---------------------oOo(o-o)oOo-------------------------------------------------------------
library ieee;
--  use ieee.std_logic_unsigned.all;
--  use ieee.std_logic_misc.all;
--  use ieee.std_logic_arith.all;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


  use work.FMC150_package.all;



entity FMC150_reset_sequencer is
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
end FMC150_reset_sequencer;


architecture  Behavioral of FMC150_reset_sequencer is

signal testA_FINISH      		: std_logic;
signal testB_FINISH      		: std_logic;
signal tstA_ERROR        		: std_logic;
signal tstB_ERROR        		: std_logic;
signal FADC_TEST_FINISH	      : std_logic;
signal FADC_TEST_FINISH_OK    : std_logic;
signal FADC_TESTA_FINISH_OK   : std_logic;
signal FADC_TESTB_FINISH_OK   : std_logic;
signal START_TEST_SYNC_ADC    : std_logic;

signal txenable_int		 : std_logic;
signal rxenable_int      : std_logic;

signal rd_n_wr           : std_logic;
signal addr              : std_logic_vector(15 downto 0):= (others => '0');
signal idata             : std_logic_vector(31 downto 0):= (others => '0');
signal odata             : std_logic_vector(31 downto 0):= (others => '0');
signal busy              : std_logic;
signal cdce72010_valid   : std_logic;
signal ads62p49_valid    : std_logic;
signal dac3283_valid     : std_logic;
signal amc7823_valid     : std_logic;

signal init_done		    : std_logic;
signal external_clock    : std_logic;
--spy stratup state machine
signal state_trace_i : std_logic_vector(7 downto 0) := (others => '0');

-- spy SPI
signal spi_sclk_int 			 :  std_logic;
signal spi_sdata_int        :  std_logic;
signal adc_n_en_int         :   std_logic;
signal adc_sdo_int          :   std_logic;
signal adc_reset_int        :   std_logic;

type TYPE_SEQSTART is (IDLE,WAIT_END_FADC_SYNC,WAIT_END_TEST_SYNC_ADC,DATA_IN_ADC_ON,SEND_ADCA_CONFIG_DATA,
	WAIT_BUSY_A,SEND_ADCB_CONFIG_DATA,WAIT_BUSY_B,END_ADC_CONFIG,ADC_ERROR);

signal SEQSTART			: TYPE_SEQSTART;
signal NEXTSEQSTART		: TYPE_SEQSTART;


begin

cdce72010_valid <= '0';
dac3283_valid   <= '0';
amc7823_valid   <= '0';
--txenable <= txenable_int;
----------------------------------------------------------------------------------------------------
-- Configuring the FMC150 card
----------------------------------------------------------------------------------------------------
-- the fmc150_spi_ctrl component configures the devices on the FMC150 card through the Serial
-- Peripheral Interfaces (SPI) and some additional direct control signals.
----------------------------------------------------------------------------------------------------
fmc150_spi_ctrl_inst : fmc150_spi_ctrl
port map (
  addr            => addr,
  idata           => idata,
  rd_n_wr         => rd_n_wr,
  cdce72010_valid => cdce72010_valid,
  ads62p49_valid  => ads62p49_valid,
  dac3283_valid   => dac3283_valid,
  amc7823_valid   => amc7823_valid,

  odata           => odata,
  busy            => busy,
  init_done			=> init_done,

  external_clock  => external_clock,

  rst             => HW_RESET,
  clk             => CLK_4X,
  spi_sclk        => spi_sclk_int,
  spi_sdata       => spi_sdata_int,
  adc_n_en        => adc_n_en_int,
  adc_sdo         => adc_sdo_int,
  adc_reset       => adc_reset_int,
  cdce_n_en       => cdce_n_en,
  cdce_sdo        => cdce_sdo,
  cdce_n_reset    => cdce_n_reset,
  cdce_n_pd       => cdce_n_pd,
  ref_en          => ref_en,
  pll_status      => pll_status,
  dac_n_en        => dac_n_en,
  dac_sdo         => dac_sdo,
  mon_n_en        => mon_n_en,
  mon_sdo         => mon_sdo,
  mon_n_reset     => mon_n_reset,
  mon_n_int       => mon_n_int,
  prsnt_m2c_l     => prsnt_m2c_l
);
spi_sclk 		<=	spi_sclk_int;
spi_sdata		<=	spi_sdata_int;
adc_n_en			<=	adc_n_en_int;
adc_sdo_int		<= adc_sdo;
adc_reset		<=	adc_reset_int;


----------------------------------------------------------------------------------------------------
-- Reset sequencer
----------------------------------------------------------------------------------------------------
	--
	-- Process RESET sequencer 
	--SEQSTART_TRACE is used for test only
--SEQSTART_trace : process (SEQSTART) is 
-- begin 
-- case SEQSTART is 
-- when IDLE => state_trace_i <= 						"00000000";--0
-- when WAIT_END_FADC_SYNC => state_trace_i <= 	"00000001";--1
-- when WAIT_END_TEST_SYNC_ADC => state_trace_i<= "00000010";--2 
-- when DATA_IN_ADC_ON => state_trace_i <= 			"00000011";--3 
-- when SEND_ADCA_CONFIG_DATA => state_trace_i <= "00000100";--4 
-- when WAIT_BUSY_A 	 => state_trace_i <= 		"00000101";--5
-- when SEND_ADCB_CONFIG_DATA => state_trace_i <= "00000110";--6 
-- when WAIT_BUSY_B	 => state_trace_i <= 			"00000111";--7
-- when END_ADC_CONFIG => state_trace_i <= 			"00001000";--8 
-- when ADC_ERROR => state_trace_i <= 				"10000000";--80 
-- 
-- when others => state_trace_i <= "11111111"; 
-- -- others shouldn't happen, but assign a diff trace 
-- -- # to catch it if it does 
-- end case; 
-- end process SEQSTART_trace; 


process (HW_RESET, CLK_4X)
  variable cnt : integer range 0 to 1023 := 0;

begin


 -- wait for clock FPGA Synchro and the end of primary serial configuration (ADC are in sync line mode and all spi config)
 
  if (HW_RESET = '1') then
 			cnt := 0;
 
    RESET_FADC <= '1';
    rxenable_int <= '0';
	 ads62p49_valid <='0';
	 addr <= x"0000";
	 idata <= x"00000000";
	 rd_n_wr <= '0';
	START_TEST_SYNC_ADC <= '0';
	SEQSTART <= IDLE;
	external_clock <= '0';

  elsif (rising_edge(CLK_4X)) then
		case SEQSTART is
			when IDLE =>
				RESET_FADC <= '1';
 				if (CLK_OK='1') then
					SEQSTART <= WAIT_END_FADC_SYNC;

				else 
					SEQSTART <= IDLE;
				end if;
			
			when WAIT_END_FADC_SYNC =>
				cnt:= cnt + 1;
 				RESET_FADC <= '1';
				if (cnt = 1023) then
					RESET_FADC <= '0';
					SEQSTART <= WAIT_END_TEST_SYNC_ADC;--WAIT_END_TEST_SYNC_ADC;
				else 
					SEQSTART <= WAIT_END_FADC_SYNC;
				end if;
				
			when WAIT_END_TEST_SYNC_ADC =>
				RESET_FADC <= '0';
				if (FADC_SYNC_FINISH_OK = '1') then
					START_TEST_SYNC_ADC <= '1';
					if (FADC_TEST_FINISH = '1') then
						if (FADC_TEST_FINISH_OK	= '1') then
							rxenable_int <= '1';
							SEQSTART <= DATA_IN_ADC_ON;
						else 
							rxenable_int <= '0';
							SEQSTART <= ADC_ERROR;
						end if;
					else SEQSTART <=  WAIT_END_TEST_SYNC_ADC;
					end if;
				else SEQSTART <=  WAIT_END_TEST_SYNC_ADC;
				end if;
			when DATA_IN_ADC_ON =>
					RESET_FADC <= '0';
					addr <= x"0062";
					idata <= x"00000000";
					rd_n_wr <= '0';
					START_TEST_SYNC_ADC <= '1';
					SEQSTART <= SEND_ADCA_CONFIG_DATA;
			when SEND_ADCA_CONFIG_DATA =>
					RESET_FADC <= '0';
					ads62p49_valid <='1';
					addr <= x"0062";
					idata <= x"00000000";
					rd_n_wr <= '0';
					START_TEST_SYNC_ADC <= '1';
					if (busy ='1') then
						SEQSTART <= WAIT_BUSY_A;
					else 
						SEQSTART <= SEND_ADCA_CONFIG_DATA;
					end if;
			when WAIT_BUSY_A	=>
				RESET_FADC <= '0';
					addr <= x"0062";
					idata <= x"00000000";
					rd_n_wr <= '0';
					ads62p49_valid <='1';
					START_TEST_SYNC_ADC <= '1';
					if (busy ='1') then
						SEQSTART <= WAIT_BUSY_A;
					else 
						ads62p49_valid <='0';
						addr <= x"0075";
						idata <= x"00000000";
						rd_n_wr <= '0';
						SEQSTART <= SEND_ADCB_CONFIG_DATA;
					end if;
			when SEND_ADCB_CONFIG_DATA =>
					RESET_FADC <= '0';
					ads62p49_valid <='1';
					addr <= x"0075";
					idata <= x"00000000";
					rd_n_wr <= '0';
					START_TEST_SYNC_ADC <= '1';
					if (busy ='1') then
						SEQSTART <= WAIT_BUSY_B;
					else 
						SEQSTART <= SEND_ADCB_CONFIG_DATA;
					end if;
			when WAIT_BUSY_B	=>
					RESET_FADC <= '0';
					addr <= x"0075";
					idata <= x"00000000";
					rd_n_wr <= '0';
					START_TEST_SYNC_ADC <= '1';
					if (busy ='1') then
						ads62p49_valid <='0';
						SEQSTART <= WAIT_BUSY_B;
					else 
						SEQSTART <= END_ADC_CONFIG;
					end if;
			when END_ADC_CONFIG =>
					RESET_FADC <= '0';
					ads62p49_valid <='0';
					addr <= x"0000";
					idata <= x"00000000";
					rd_n_wr <= '0';
					START_TEST_SYNC_ADC <= '1';
					SEQSTART <= END_ADC_CONFIG;
			when ADC_ERROR =>
				SEQSTART <= ADC_ERROR;
			end case;
		end if;
end process;

----------------------------------------------------------
-- subprocess Test of good FADC SYNCHRO for 1024 Clk of FADC A
----------------------------------------------------------
process(HW_RESET,FADC_CHAB_CLK)
  variable cnt : integer range 0 to 1023 := 0;
begin
  if (HW_RESET='1') then
			cnt := 0;
         tstA_ERROR <= '0';
			testA_finish <='0';
			FADC_TESTA_FINISH_OK <='0';
  elsif rising_edge(FADC_CHAB_CLK) then
     if (START_TEST_SYNC_ADC = '1') then 
		if (testA_finish ='0') then
			if (FADC_CHA_16 = "1010101010101000" or FADC_CHA_16 = "0101010101010100") then
				cnt:= cnt + 1;
				tstA_ERROR <='0';
			else
				tstA_ERROR <= '1';
			end if;
			if (cnt = 1023) then 
				testA_finish <='1';
				cnt:=cnt;
				if (tstA_ERROR ='0') then 
					FADC_TESTA_FINISH_OK <='1';
				else 
					FADC_TESTA_FINISH_OK <='0';
				end if;
			else testA_finish <='0';
			end if;
		end if;
	  end if;
  end if;
end process; 

----------------------------------------------------------
-- subprocess Test of good FADC SYNCHRO for 1024 Clk of FADC B
----------------------------------------------------------
process(HW_RESET,FADC_CHAB_CLK)
  variable cnt : integer range 0 to 1023 := 0;
begin
  if (HW_RESET = '1') then
			cnt := 0;
         tstB_ERROR <= '0';
			testB_finish <='0';
			FADC_TESTB_FINISH_OK <='0';
  elsif rising_edge(FADC_CHAB_CLK) then
	if (START_TEST_SYNC_ADC = '1') then 
		if (testB_finish ='0') then
			if ((FADC_CHB_16 = "1010101010101000" or FADC_CHB_16 = "0101010101010100")) then
				cnt:= cnt + 1;
				tstB_ERROR <= '0';
			else
				tstB_ERROR <= '1';
			end if;
			if (cnt = 1023) then 
				testB_finish <='1';
				cnt:=cnt;
				if (tstB_ERROR ='0') then 
					FADC_TESTB_FINISH_OK <='1';
				else 
					FADC_TESTB_FINISH_OK <='0';
				end if;
			else testB_finish <='0';
			end if;
		end if;
	end if;
  end if;
end process; 

FADC_TEST_FINISH_OK 	<= FADC_TESTA_FINISH_OK and FADC_TESTB_FINISH_OK;
FADC_TEST_FINISH 		<= testA_finish and testB_finish;

-- process (HW_RESET,CLK_1X)
  -- variable cnt : integer range 0 to 1023 := 0;
-- begin
   -- if (HW_RESET='1') then
		-- frame <= '0';
		-- txenable_int <= '0';
		-- cnt := 0;
		-- FMC150_READY <='0';

	-- elsif (rising_edge(CLK_1X)) then
		-- if (SEQSTART /= END_ADC_CONFIG) then
			-- frame <= '0';
			-- txenable_int <= '0';
			-- cnt := 0;
			-- FMC150_READY <='0';
		-- else
			-- if (cnt < 1023) then
				-- cnt := cnt + 1;
			-- else
				-- cnt := cnt;
			-- end if;
		-- -- Then a frame pulse is transmitted to the DAC...
			-- if (cnt = 511) then
				-- frame <= '1';
			-- else
				-- frame <= '0';
			-- end if;
		-- -- Finally the TX enable for the DAC can by pulled high.
			-- if (cnt = 1023) then
				-- txenable_int <= '1';
				-- FMC150_READY <='1';
			-- end if;
		-- end if;
  -- end if;
-- end process;

--txenable <= txenable_int;
rxenable	<= rxenable_int;
end Behavioral;
