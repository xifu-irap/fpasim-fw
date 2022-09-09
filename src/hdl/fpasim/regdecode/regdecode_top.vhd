library ieee;
use ieee.std_logic_1164.all;


entity regdecode_top is
  port (
       --	Opal Kelly inouts --
		okUH      : in     STD_LOGIC_VECTOR(4 downto 0);
		okHU      : out    STD_LOGIC_VECTOR(2 downto 0);
		okUHU     : inout  STD_LOGIC_VECTOR(31 downto 0);
		okAA      : inout  STD_LOGIC;

		---------------------------------------------------------------------
		-- from/to the user
		---------------------------------------------------------------------

     ) ;
end entity regdecode_top;

architecture RTL of regdecode_top is

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


begin

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


end architecture RTL;