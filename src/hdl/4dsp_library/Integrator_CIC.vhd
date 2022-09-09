----------------------------------------------------------------------------------
-- Company       : CNRS - INSU - IRAP
-- Engineer      : Antoine CLENET 
-- 
-- Create Date   : 12:14:36 05/26/2015 
-- Design Name   : DRE XIFU ML605
-- Module Name   : Integrator_CIC - Behavioral 
-- Project Name  : Athena XIfu DRE
-- Target Devices: Vitex 6 LX 240
-- Tool versions : ISE-14.7
-- Description   : Integrator for the CIC filter
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
---------------------------------------oOOOo(o_o)oOOOo-----------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Integrator_CIC is
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
end Integrator_CIC;

architecture Behavioral of Integrator_CIC is

signal add_buf : signed(size_in-1 downto 0);

begin
process(reset,CLK_IN)
	begin
	if reset = '1' then
		add_buf  <= (others => '0');
	
	else
		if (rising_edge (CLK_IN)) then
--			if (ENABLE_CLK_1X ='1') then
				if (START_STOP = '1') then
					add_buf <= add_buf + Int_in_dat;
				else 
					add_buf <=  (others => '0');
				end if;
			else
			add_buf <= add_buf;
		--end if;
	end if;
end if;

end process;

Int_out_dat <= add_buf(size_in-1 downto size_in-size_out);

end Behavioral;

