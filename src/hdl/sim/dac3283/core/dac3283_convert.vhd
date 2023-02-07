-- -------------------------------------------------------------------------------------------------------------
--                              Copyright (C) 2022-2030 Ken-ji de la Rosa, IRAP Toulouse.
-- -------------------------------------------------------------------------------------------------------------
--                              This file is part of the ATHENA X-IFU DRE Focal Plane Assembly simulator.
--
--                              fpasim-fw is free software: you can redistribute it and/or modify
--                              it under the terms of the GNU General Public License as published by
--                              the Free Software Foundation, either version 3 of the License, or
--                              (at your option) any later version.
--
--                              This program is distributed in the hope that it will be useful,
--                              but WITHOUT ANY WARRANTY; without even the implied warranty of
--                              MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--                              GNU General Public License for more details.
--
--                              You should have received a copy of the GNU General Public License
--                              along with this program.  If not, see <https://www.gnu.org/licenses/>.
-- -------------------------------------------------------------------------------------------------------------
--    email                   kenji.delarosa@alten.com
--    @file                   dac3283_convert.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details                
--
--    
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.fixed_pkg.all;
use ieee.fixed_float_types.all;


entity dac3283_convert is
  generic (
    g_DAC_VPP : natural := 2  -- DAC differential output voltage ( Vpp expressed in Volts)
    );
  port (


    i_data_valid : in std_logic;
    i_data       : in std_logic_vector(15 downto 0);

    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    o_data_real_valid : out std_logic;
    o_data_real       : out real
    );
end entity dac3283_convert;

architecture RTL of dac3283_convert is

---------------------------------------------------------------------
-- convert: i_data -> fixed between : [-1,0.99[
--  S0 = sfixed(i_data) : real between
---------------------------------------------------------------------
  signal data_tmp : sfixed(0 downto -15);

---------------------------------------------------------------------
-- rescaling:
-- s1 = DAC_VPP * real(data_tmp)
---------------------------------------------------------------------
  signal s1 : real;

begin

---------------------------------------------------------------------
-- convert: i_data -> fixed between : [-1,0.99[
---------------------------------------------------------------------
  data_tmp <= sfixed(i_data);

---------------------------------------------------------------------
-- rescaling:
-- s1 = DAC_VPP * real(data_tmp)
---------------------------------------------------------------------
  s1 <= real(g_DAC_VPP) * To_real(data_tmp);

---------------------------------------------------------------------
-- output
---------------------------------------------------------------------
  o_data_real_valid <= i_data_valid;
  o_data_real       <= s1;

end architecture RTL;
