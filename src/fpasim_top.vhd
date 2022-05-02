----------------------------------------------------------------------------------
--Copyright (C) 2021-2030 Paul Marbeau, IRAP Toulouse.

--This file is part of the ATHENA X-IFU DRE RAS.

--fpasim-fw is free software: you can redistribute it and/or modifyit under the terms of the GNU General Public 
--License as published bythe Free Software Foundation, either version 3 of the License, or(at your option) any 
--later version.

--This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the 
--implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for 
--more details.You should have received a copy of the GNU General Public Licensealong with this program.  

--If not, see <https://www.gnu.org/licenses/>.

--paul.marbeau@alten.com
--fpasim_top.vhd

-- Company: IRAP
-- Engineer: Paul Marbeau
-- 
-- Create Date: 12.04.2022 
-- Design Name: 
-- Module Name: fpasim_top
-- Target Devices: Opal Kelly XEM7350-410T
-- Tool Versions: 
-- Description: 
----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;

library UNIMACRO;
use UNIMACRO.vcomponents.all;

library work;
use work.FRONTPANEL.all;
use work.fpasim_pkg.all;

entity fpasim_top is
		port(
		--	Opal Kelly inouts --
		okUH      : in     STD_LOGIC_VECTOR(4 downto 0);
		okHU      : out    STD_LOGIC_VECTOR(2 downto 0);
		okUHU     : inout  STD_LOGIC_VECTOR(31 downto 0);
		okAA      : inout  STD_LOGIC;
		
		--	Global           --
		sys_clkp	: in	STD_LOGIC;		             -- System clk signal 200 MHz						
		sys_clkn	: in 	STD_LOGIC;		             -- System clk signal 200 MHz						
		
		led       : out    STD_LOGIC_VECTOR(3 downto 0)  -- Life leds

		);
end entity;

architecture RTL of fpasim_top is

---- Clock + Reset signals ----

signal sys_clk    : std_logic;      -- System clk signal 200 MHz
signal clk_adc    : std_logic;      -- Clock for ADC and DAC 250 MHz
signal clk_out    : std_logic;      -- Clock 62,5 MHz for synchro
signal clkfbout   : std_logic;      -- Loopback clock for PLL
signal pll_locked : std_logic;      -- Lock signal for PLL ('1' = PLL locked, '0' = PLL unlocked)

signal rst_gen : std_logic_vector(7 downto 0);      -- Signal to get a protected reset signal
signal sys_rst : std_logic;                         -- Reset signal

---- Leds signals  ----
signal cpt_leds : std_logic_vector(31 downto 0);    -- Counter for blinking leds

---- Opal Kelly signals ----
signal okClk : std_logic;                          -- Opal Kelly Clock
signal okHE  : std_logic_vector(112 downto 0);
signal okEH  : std_logic_vector(64 downto 0);
signal okEHx : std_logic_vector(10*65-1 downto 0);

-- wires --

signal ep00_wire : std_logic_vector(31 downto 0);      -- Opal Kelly wire in
signal ep20_wire : std_logic_vector(31 downto 0);      -- Opal Kelly wire out 
signal ep21_wire : std_logic_vector(31 downto 0);      -- Opal Kelly wire out 
signal ep22_wire : std_logic_vector(31 downto 0);      -- Opal Kelly wire out 
signal ep23_wire : std_logic_vector(31 downto 0);      -- Opal Kelly wire out 
signal ep24_wire : std_logic_vector(31 downto 0);      -- Opal Kelly wire out 
signal ep25_wire : std_logic_vector(31 downto 0);      -- Opal Kelly wire out 
signal ep26_wire : std_logic_vector(31 downto 0);      -- Opal Kelly wire out 
signal ep27_wire : std_logic_vector(31 downto 0);      -- Opal Kelly wire out 

-- pipes --

signal fifo_in_write     : std_logic;                      -- Fifo in write ('1' = Write )      
signal fifo_in_empty     : std_logic;                      -- Fifo in empty ('1' = Empty) 
signal fifo_in_empty_n   : std_logic;                      -- Fifo in not empty ('0' = Empty)
signal fifo_in_full      : std_logic;                      -- Fifo in full ('1' = Full)
signal fifo_in_read_en   : std_logic;                      -- Fifo in read enable ('1' = Read)
signal fifo_in_data      : std_logic_vector(31 downto 0);  -- Fifo in data in
signal fifo_in_data_out  : std_logic_vector(31 downto 0);  -- Fifo in data out

signal fifo_out_write       : std_logic;                     -- Fifo out write ('1' = Write )
signal fifo_out_write_count : std_logic_vector(8 downto 0);  -- Counter of data written (ex x"04" = 32*4 bits stored in the Fifo)
signal fifo_out_read_count  : std_logic_vector(8 downto 0);  -- Counter of data that has been readen (ex x"04" = 32*4 bits)
signal fifo_out_read_en     : std_logic;                     -- Fifo out read enable ('1' = Read)
-- signal fifo_out_almostempty : std_logic;                     -- Fifo out almost empty (DATA_STORED < ALMOST_EMPTY_OFFSET)
signal fifo_out_empty       : std_logic;                     -- Fifo out empty ('1' = Empty) 
signal fifo_out_full        : std_logic;                     -- Fifo out full ('1' = Full)
signal fifo_out_full_n      : std_logic;                     -- Fifo out not full ('0' = Full)
signal fifo_out_data        : std_logic_vector(31 downto 0); -- Fifo out data in
signal fifo_out_data_out    : std_logic_vector(31 downto 0); -- Fifo out data out

-- Flusher --

signal flush_data_valid : std_logic;
signal flush_data_in    : std_logic_vector(c_data_width-1 downto 0);
signal flushing         : std_logic;
signal nb_words_stored  : std_logic_vector(c_read_write_count_width-1 downto 0);

begin
----------------------------------------------------
-- Clock gen
----------------------------------------------------
	IBUFDS_sys_clk : IBUFDS  --	BUFDS (transform differential to single ended)
		generic map (
			DIFF_TERM    => FALSE, -- Differential Termination 
			IBUF_LOW_PWR => FALSE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
			IOSTANDARD   => "DEFAULT")
		port map (
			O  => sys_clk,    -- Buffer output
			I  => sys_clkp,   -- Diff_p buffer input (connect directly to top-level port)
			IB => sys_clkn    -- Diff_n buffer input (connect directly to top-level port)
		);

	clk_gen : PLLE2_BASE
	generic map (
	   BANDWIDTH      => "OPTIMIZED",  -- OPTIMIZED, HIGH, LOW
	   CLKFBOUT_MULT  => 5,            -- Multiply value for all CLKOUT, (2-64)
	   CLKFBOUT_PHASE => 0.0,          -- Phase offset in degrees of CLKFB, (-360.000-360.000).
	   CLKIN1_PERIOD  => 5.0,          -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
	   -- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
	   CLKOUT0_DIVIDE => 4,            -- Clock 250 MHz for ADC and DAC
	   CLKOUT1_DIVIDE => 16,           -- Clock 62,5 MHz 
	   CLKOUT2_DIVIDE => 1,            -- Spare 
	   CLKOUT3_DIVIDE => 1,            -- Spare
	   DIVCLK_DIVIDE  => 1,            -- Master division value, (1-56)
	   REF_JITTER1    => 0.0,          -- Reference input jitter in UI, (0.000-0.999).
	   STARTUP_WAIT   => "FALSE"       -- Delay DONE until PLL Locks, ("TRUE"/"FALSE")
	)
	port map (
	   -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
	   CLKOUT0  => clk_adc,    -- 1-bit output: CLKOUT0
	   CLKOUT1  => clk_out,    -- 1-bit output: CLKOUT1
	   CLKOUT2  => open,       -- 1-bit output: CLKOUT2
	   CLKOUT3  => open,       -- 1-bit output: CLKOUT3
	   CLKOUT4  => open,       -- 1-bit output: CLKOUT4
	   CLKOUT5  => open,       -- 1-bit output: CLKOUT5
	   -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
	   CLKFBOUT => clkfbout,   -- 1-bit output: Feedback clock
	   LOCKED   => pll_locked, -- 1-bit output: LOCK
	   CLKIN1   => sys_clk,    -- 1-bit input: Input clock
	   -- Control Ports: 1-bit (each) input: PLL control ports
	   PWRDWN   => '0',        -- 1-bit input: Power-down
	   RST      => '0',        -- 1-bit input: Reset
	   -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
	   CLKFBIN  => clkfbout    -- 1-bit input: Feedback clock
	);

----------------------------------------------------
--	Reset generator
----------------------------------------------------
sys_rst_gen : process(sys_clk)
begin
	if rising_edge(sys_clk) then 
		rst_gen <= rst_gen(rst_gen'left-1 downto 0) & pll_locked;
	end if ;
end process sys_rst_gen;

sys_rst <= not rst_gen(rst_gen'left);

----------------------------------------------------
--	LEDS
----------------------------------------------------
leds_gen : process(sys_clk)
begin
	if rising_edge(sys_clk) then 
		cpt_leds <= std_logic_vector(unsigned(cpt_leds) + 1);  -- Counter to create blinking leds
		led(3)  <= cpt_leds(cpt_leds'left-2);                  -- Blink almost every 2 second 
		led(2)  <= not(cpt_leds(cpt_leds'left-3));             -- Blink almost every second 
		led(1)  <= cpt_leds(cpt_leds'left-1);                  -- Blink almost every 4 second 
		led(0)  <= not(cpt_leds(cpt_leds'left-4));             -- Blink almost every 0.5 second 

	end if ;
end process leds_gen;

----------------------------------------------------
--	Wire updater
----------------------------------------------------
ep20_wire <= x"00000" & "000" & nb_words_stored;                    -- Returns the number of words stored in the fifo out
ep21_wire <= x"ABCDEFAB";                                           -- Test wire (Version of the firmware in future versions) #TODO
ep22_wire <= x"00000" & "000" & fifo_out_write_count;               -- Spare wire
ep23_wire <= x"00000" & "000" & fifo_out_read_count;                -- Spare wire
ep24_wire <= x"0000000" & "000" & fifo_out_read_en;                 -- Spare wire
ep25_wire <= fifo_in_data_out;                                      -- Spare wire
ep26_wire <= fifo_out_data;                                         -- Spare wire
ep27_wire <= fifo_out_data_out;                                     -- Spare wire

----------------------------------------------------
--	Opal Kelly Host
----------------------------------------------------
Opak_Kelly_Host : okHost	
port map(

	okUH	=>	okUH,
	okHU	=>	okHU,
	okUHU	=>	okUHU,
	okAA	=>	okAA,	
	okClk	=>	okClk,              -- Clock Opal Kelly generated in the okLibrary
	okHE	=>	okHE, 
	okEH	=>	okEH

); 
----------------------------------------------------
--	Opal Kelly Wire OR
----------------------------------------------------
Opak_Kelly_WireOR : okWireOR     generic map ( N => 10 )     -- N = Number of wires + pipes used
port map (
	okEH	=>	okEH, 
	okEHx	=>	okEHx
);
----------------------------------------------------
--	Opal Kelly Wire in
----------------------------------------------------
ep00 : okWireIn    
port map (
	okHE		=>	okHE,                                     
	ep_addr		=>	x"00",          -- Endpoint adress
	ep_dataout	=>	ep00_wire       -- Endpoint data in 32 bits
);
----------------------------------------------------
--	Opal Kelly Wire out
----------------------------------------------------
ep_20 : okWireOut    
	port map ( 
		okHE      => okHE, 
		okEH      => okEHx( 1*65-1 downto 0*65 ), 
		ep_addr   => x"20",         -- Endpoint adress
		ep_datain => ep20_wire      -- Endpoint data out 32 bits
		);	

ep21 : okWireOut    
	port map ( 
		okHE      => okHE, 
		okEH      => okEHx( 2*65-1 downto 1*65 ), 
		ep_addr   => x"21",         -- Endpoint adress
		ep_datain => ep21_wire      -- Endpoint data out 32 bits
		);	
	
ep22 : okWireOut    
	port map ( 
		okHE      => okHE, 
		okEH      => okEHx( 3*65-1 downto 2*65 ), 
		ep_addr   => x"22",         -- Endpoint adress
		ep_datain => ep22_wire      -- Endpoint data out 32 bits
		);	
	
ep23 : okWireOut    
	port map ( 
		okHE      => okHE, 
		okEH      => okEHx( 4*65-1 downto 3*65 ), 
		ep_addr   => x"23",         -- Endpoint adress
		ep_datain => ep23_wire      -- Endpoint data out 32 bits
		);

ep24 : okWireOut    
	port map ( 
		okHE      => okHE, 
		okEH      => okEHx( 5*65-1 downto 4*65 ), 
		ep_addr   => x"24",         -- Endpoint adress
		ep_datain => ep24_wire      -- Endpoint data out 32 bits
		);	
		
ep25 : okWireOut    
	port map ( 
	okHE      => okHE, 
	okEH      => okEHx( 6*65-1 downto 5*65 ), 
	ep_addr   => x"25",             -- Endpoint adress
	ep_datain => ep25_wire          -- Endpoint data out 32 bits
	);

ep26 : okWireOut    
	port map ( 
		okHE      => okHE, 
		okEH      => okEHx( 7*65-1 downto 6*65 ), 
		ep_addr   => x"26",         -- Endpoint adress
		ep_datain => ep26_wire      -- Endpoint data out 32 bits
		);	

ep27 : okWireOut    
	port map ( 
		okHE      => okHE, 
		okEH      => okEHx( 8*65-1 downto 7*65 ), 
		ep_addr   => x"27",         -- Endpoint adress
		ep_datain => ep27_wire      -- Endpoint data out 32 bits
		);

----------------------------------------------------
--	Opal Kelly Pipe in
----------------------------------------------------	
ep80 : okPipeIn   
port map (
	okHE	   => okHE, 
	okEH	   => okEHx( 10*65-1 downto 9*65 ),  
	ep_addr	   => x"80", 
    ep_write   => fifo_in_write, 
	ep_dataout => fifo_in_data
	);	

----------------------------------------------------
--	Opal Kelly Pipe out
----------------------------------------------------
epA0 : okPipeOut
port map (
	okHE	        =>	okHE, 
	okEH	        =>	okEHx( 9*65-1 downto 8*65 ),  
	ep_addr	        =>	x"A0", 
    ep_read	        =>	fifo_out_read_en, 
	ep_datain		=>	fifo_out_data_out 
	);		

	Fifo_in : FIFO_DUALCLOCK_MACRO
	generic map (
		DEVICE                  => "7SERIES",   -- Target Device: "VIRTEX5", "VIRTEX6", "7SERIES" 
		ALMOST_FULL_OFFSET      => X"0080",     -- Sets almost full threshold
		ALMOST_EMPTY_OFFSET     => X"0080",     -- Sets the almost empty threshold
		DATA_WIDTH              => 32,          -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
		FIFO_SIZE               => "18Kb",      -- Target BRAM, "18Kb" or "36Kb" 
		FIRST_WORD_FALL_THROUGH => FALSE)       -- Sets the FIFO FWFT to TRUE or FALSE
	port map (
		DO    => fifo_in_data_out,              -- Output data, width defined by DATA_WIDTH parameter
		EMPTY => fifo_in_empty,                 -- 1-bit output empty
		FULL  => fifo_in_full,                  -- 1-bit output full
		DI    => fifo_in_data,                  -- Input data, width defined by DATA_WIDTH parameter
		RDCLK => sys_clk,                       -- 1-bit input read clock
		RDEN  => fifo_in_read_en,               -- 1-bit input read enable
		RST   => sys_rst,                       -- 1-bit input reset
		WRCLK => okClk,                         -- 1-bit input write clock
		WREN  => fifo_in_write                  -- 1-bit input write enable
	);
	
	fifo_in_empty_n <= not(fifo_in_empty);      -- Fifo in not empty signal

	Fifo_out : FIFO_DUALCLOCK_MACRO
	generic map (
		DEVICE                  => "7SERIES",   -- Target Device: "VIRTEX5", "VIRTEX6", "7SERIES" 
		ALMOST_FULL_OFFSET      => X"0080",     -- Sets almost full threshold
		ALMOST_EMPTY_OFFSET     => X"0080",     -- Sets the almost empty threshold (range 5-1028)
		DATA_WIDTH              => 32,          -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
		FIFO_SIZE               => "18Kb",      -- Target BRAM, "18Kb" or "36Kb" 
		FIRST_WORD_FALL_THROUGH => TRUE)       -- Sets the FIFO FWFT to TRUE or FALSE
	port map (
		DO          => fifo_out_data_out,             -- Output data, width defined by DATA_WIDTH parameter
		EMPTY       => fifo_out_empty,                -- 1-bit output empty
		FULL        => fifo_out_full,                 -- 1-bit output full
		WRCOUNT     => fifo_out_write_count,          -- Output write count, width determined by FIFO depth
		RDCOUNT     => fifo_out_read_count,           -- Output read count, width determined by FIFO depth
		DI          => fifo_out_data,                 -- Input data, width defined by DATA_WIDTH parameter
		RDCLK       => okClk,                         -- 1-bit input read clock
		RDEN        => fifo_out_read_en,              -- 1-bit input read enable
		RST         => sys_rst,                       -- 1-bit input reset
		WRCLK       => sys_clk,                       -- 1-bit input write clock
		WREN        => fifo_in_read_en                -- 1-bit input write enable
	);

	fifo_out_full_n <= not(fifo_out_full);                    -- Fifo out not full signal
	fifo_out_data   <= fifo_in_data_out;                      -- Direct connexion fifo in fifo out
	fifo_in_read_en <= fifo_out_full_n and fifo_in_empty_n ;  -- Read and write for Fifos. 

----------------------------------------------------
--	Pipe out management
----------------------------------------------------

	pipe_out_mgt : entity work.pipe_mgt              -- Returns the number of words store in the FIFO    
		port map(
			i_rst              =>  sys_rst,              -- 1-bit input, Global reset 
			i_wr_clk	       =>  sys_clk,              -- 1-bit input, Global clock
			i_rd_clk           =>  okClk,                -- 1-bit input, Opal Kelly clock
			i_fifo_read        =>  fifo_out_read_en,     -- 1-bit input, Fifo Out read				
			i_fifo_write       =>  fifo_in_read_en,       -- 1-bit input, Fifo Out write 
			o_nb_words_stored  =>  nb_words_stored		 -- 9-bits output, Number of words stored in the fifo	
		);

end RTL;
