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
--!   @file                   sub_sfixed.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--
-- This module computes the following formula: s = a - b (sfixed point representation)
-- It performs the following steps:
--   . According the generic parameters, convert its 2 input operands (a, b) into sfixed type
--   . s = a * b
--   . According the generic parameter values, extract the corresponding bitss from s and convert it into an output std_logic_vector vector
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;


entity sub_sfixed is
  generic(
    -- port A: AMD Q notation (fixed point)
    g_Q_M_A : in positive := 15; -- number of bits used for the integer part of the value ( sign bit included). Possible values [0;integer_max_value[
    g_Q_N_A : in natural := 0; -- number of fraction bits. Possible values [0;integer_max_value[ 
    -- port B: AMD Q notation (fixed point)
    g_Q_M_B : in positive := 15; -- number of bits used for the integer part of the value ( sign bit included). Possible values [0;integer_max_value[
    g_Q_N_B : in natural := 0; -- number of fraction bits. Possible values [0;integer_max_value[
    -- port S: AMD Q notation (fixed point)
    g_Q_M_S  : in positive := 16; -- number of bits used for the integer part of the value ( sign bit included). Possible values [0;integer_max_value[
    g_Q_N_S  : in natural := 0 -- number of fraction bits. Possible values [0;integer_max_value[
  );
  port (
       i_clk : in std_logic;

       --------------------------------------------------------------
        -- input
        --------------------------------------------------------------
        i_a   : in  std_logic_vector(g_Q_M_A + g_Q_N_A - 1 downto 0);
        i_b   : in  std_logic_vector(g_Q_M_B + g_Q_N_B - 1 downto 0);

        --------------------------------------------------------------
        -- output : S = a - B
        --------------------------------------------------------------
        o_s   : out std_logic_vector(g_Q_M_S + g_Q_N_S - 1 downto 0)

     ) ;
end entity sub_sfixed;

architecture RTL of sub_sfixed is

    signal a_tmp : sfixed(g_Q_M_A - 1 downto -g_Q_N_A);
    signal b_tmp : sfixed(g_Q_M_B - 1 downto -g_Q_N_B);

    -----------------------------------------------------------------
    -- step1: add 1 sign bit
    -----------------------------------------------------------------
    signal a_r1    : sfixed(a_tmp'high downto a_tmp'low);
    signal b_r1    : sfixed(b_tmp'high downto b_tmp'low);

    ---------------------------------------------------------------------
    -- step3:
    --   res_r2 = a_r1 - b_r1
    ---------------------------------------------------------------------
    signal res_r2 : sfixed(sfixed_high(a_r1, '-', b_r1) downto sfixed_low(a_r1, '-', b_r1));

    -----------------------------------------------------------------
    -- truncate: 
    --   extract sfixed range
    --   sfixed -> ufixed conversion
    -----------------------------------------------------------------
    signal res_tmp3 : sfixed(g_Q_M_S - 1 downto -g_Q_N_S);

begin

  a_tmp <= sfixed(i_a);
  b_tmp <= sfixed(i_b);
  -----------------------------------------------------------------
  -- compute : S = A - B
  -----------------------------------------------------------------
  p_computation : process(i_clk)
  begin
      if rising_edge(i_clk) then
          -------------------------------------------------------------
          -- step1 : ufixed to sfixed conversion (because of the latter negate operation)
          -------------------------------------------------------------
          a_r1    <= sfixed(a_tmp);
          b_r1    <= sfixed(b_tmp);
          -------------------------------------------------------------
          -- step2
          -------------------------------------------------------------
          res_r2  <= a_r1 - b_r1;
      end if;
  end process p_computation;
  -----------------------------------------------------------------
  -- conversion:
  --   extract range from sfixed vector
  -----------------------------------------------------------------
  res_tmp3 <= resize(res_r2, res_tmp3'high, res_tmp3'low);

  -------------------------------------------------------------------
  -- output
  -------------------------------------------------------------------
  o_s <= to_slv(res_tmp3);

end architecture RTL;