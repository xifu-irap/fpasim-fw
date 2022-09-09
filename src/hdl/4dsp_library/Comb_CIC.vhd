----------------------------------------------------------------------------------
-- Company       : CNRS - INSU - IRAP
-- Engineer      : Antoine CLENET 
-- 
-- Create Date   : 12:14:36 05/26/2015 
-- Design Name   : DRE XIFU ML605
-- Module Name   : Comb_CIC - Behavioral 
-- Project Name  : Athena XIfu DRE
-- Target Devices: Vitex 6 LX 240
-- Tool versions : ISE-14.7
-- Description   : Comb_CIC module
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

entity Comb_CIC is
	 Generic ( 
				size_in  : positive := 16;
				size_out : positive := 17
				);
    Port		(
--				CLK_IN		 			: in STD_LOGIC;
				CLK_OUT					: in STD_LOGIC;
				reset 					: in 	std_logic;
				comb_in_dat 			: in  signed(size_in-1 downto 0);
				comb_out_dat			: out signed(size_out-1 downto 0)
				);
end Comb_CIC;

architecture Behavioral of Comb_CIC is

signal inv_add_buf1 	: signed(size_in-1 downto 0);
signal out_add_buf 	: signed(size_in-1 downto 0);

begin
process(reset,CLK_OUT)
	begin
	if reset = '1' then
		inv_add_buf1  <= (others => '0');
		out_add_buf   <= (others => '0');
	
	else
		if rising_edge (CLK_OUT) then
--			if (ENABLE_CLK_1X_DIV128 ='1') then
				out_add_buf  <= resize(comb_in_dat,size_in) - resize(inv_add_buf1,size_in);
				inv_add_buf1 <= comb_in_dat;
--			end if;
		end if;
	end if;
end process;

comb_out_dat <= out_add_buf(size_in-1 downto size_in-size_out);

end Behavioral;

