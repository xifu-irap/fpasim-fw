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
--    @file                   mult_add_ufixed.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details                
--
--    This module computes the following formula: s = c + (a * b) (ufixed point representation).
--    It performs the following steps:
--      . convert its 3 input operands (a, b, c) into ufixed type (see generic parameters).
--      . s = c + (a * b)
--      . extract ufixed range bits from s (see generic parameters).
--      . convert the extracted bits into a std_logic_vector vector.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;
use ieee.fixed_float_types.all;


entity mult_add_ufixed is
    generic(
        -- port A: ARM Q notation (fixed point)
        g_UQ_M_A : in positive := 15;
        g_UQ_N_A : in natural := 0;
        -- port B: ARM Q notation (fixed point)
        g_UQ_M_B : in positive := 15;
        g_UQ_N_B : in natural := 0;
        -- port C: AMC Q notation (fixed point)
        g_UQ_M_C : in positive := 15;
        g_UQ_N_C : in natural := 0;
        -- port S: ARM Q notation (fixed point)
        g_UQ_M_S  : in positive := 15;
        g_UQ_N_S  : in natural := 0
    );
    port(
        i_clk : in  std_logic;
        --------------------------------------------------------------
        -- input
        --------------------------------------------------------------
        i_a   : in  std_logic_vector(g_UQ_M_A + g_UQ_N_A - 1 downto 0);
        i_b   : in  std_logic_vector(g_UQ_M_B + g_UQ_N_B - 1 downto 0);
        i_c   : in  std_logic_vector(g_UQ_M_C + g_UQ_N_C - 1 downto 0);
        --------------------------------------------------------------
        -- output : S = C + A*B
        --------------------------------------------------------------
        o_s   : out std_logic_vector(g_UQ_M_S + g_UQ_N_S - 1 downto 0)
    );
end entity mult_add_ufixed;

architecture RTL of mult_add_ufixed is
    -----------------------------------------------------------------
    -- step0: 
    -----------------------------------------------------------------
    signal a_tmp : ufixed(g_UQ_M_A - 1 downto -g_UQ_N_A);
    signal b_tmp : ufixed(g_UQ_M_B - 1 downto -g_UQ_N_B);
    signal c_tmp : ufixed(g_UQ_M_C - 1 downto -g_UQ_N_C);

    -----------------------------------------------------------------
    -- step1: pipe
    -----------------------------------------------------------------
    signal a_r1    : ufixed(a_tmp'range):= (others => '0');
    signal b_r1    : ufixed(b_tmp'range):= (others => '0');
    signal c_r1    : ufixed(c_tmp'range):= (others => '0');
    ---------------------------------------------------------------------
    -- step2: 
    --    mult_r2 = a*b
    --    c_r2 = c_r1
    ---------------------------------------------------------------------
    signal mult_r2 : ufixed(ufixed_high(a_r1, '*', b_r1) downto ufixed_low(a_r1, '*', b_r1)):= (others => '0');
    signal c_r2    : ufixed(c_r1'range):= (others => '0');

    ---------------------------------------------------------------------
    -- step3:
    --   res_r3 = c_r2 + mult_r2
    ---------------------------------------------------------------------
    signal res_r3 : ufixed(ufixed_high(c_r2, '+', mult_r2) downto ufixed_low(c_r2, '+', mult_r2)):= (others => '0');

    -----------------------------------------------------------------
    -- truncate: 
    --   extract sfixed range
    --   sfixed -> std_logic_vector conversion
    -----------------------------------------------------------------
    signal res_tmp4 : ufixed(g_UQ_M_S - 1 downto -g_UQ_N_S);

begin
    a_tmp <= ufixed(i_a);
    b_tmp <= ufixed(i_b);
    c_tmp <= ufixed(i_c);
    -----------------------------------------------------------------
    -- compute : S = C - A*B
    -----------------------------------------------------------------
    p_computation : process(i_clk)
    begin
        if rising_edge(i_clk) then
            -------------------------------------------------------------
            -- step1
            -------------------------------------------------------------
            a_r1    <= a_tmp;
            b_r1    <= b_tmp;
            c_r1    <= c_tmp;
            -------------------------------------------------------------
            -- step2
            -------------------------------------------------------------
            mult_r2 <= a_r1 * b_r1;
            c_r2    <= c_r1;
            -------------------------------------------------------------
            -- step3: C + (A * B)
            -------------------------------------------------------------
            res_r3  <= c_r2 + mult_r2;
        end if;
    end process p_computation;
    -----------------------------------------------------------------
    -- conversion:
    --   extract range from sfixed vector
    -----------------------------------------------------------------
    res_tmp4 <= resize(res_r3, res_tmp4'high, res_tmp4'low,overflow_style=> FIXED_WRAP,round_style=> FIXED_TRUNCATE);

    -----------------------------------------------------------------
    -- output
    -----------------------------------------------------------------
    o_s <= to_slv(res_tmp4);



end architecture RTL;
