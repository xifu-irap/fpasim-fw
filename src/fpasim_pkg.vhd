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
--fpasim_pkg.vhd

-- Company: IRAP
-- Engineer: Paul Marbeau
-- 
-- Create Date: 20.04.2022 
-- Design Name: 
-- Module Name: fpasim_pkg
-- Target Devices: Opal Kelly XEM7350 
-- Tool Versions: 
-- Description: 
----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

package fpasim_pkg is
	
	constant c_read_write_count_width : positive := 9;
	constant c_data_width : positive := 32;
	constant c_flush_command : std_logic_vector(c_data_width-1 downto 0) := x"fffefffe";

end fpasim_pkg;