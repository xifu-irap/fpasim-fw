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
--    @file                   ads62p49_io.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details                
--
--    This module sends data to the IOs.
--
-- -------------------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library UNISIM;
use UNISIM.vcomponents.all;


entity ads62p49_io is
  port (
    i_clk_phase : in  std_logic; -- adc clock (for the clock path): i_clk_phase = i_clk + 90 degree
    i_clk       : in  std_logic; -- adc clock (for the data path)
    ---------------------------------------------------------------------
    -- from the user: inputs
    ---------------------------------------------------------------------
    i_adc0      : in  std_logic_vector(13 downto 0); -- adc0 value
    i_adc1      : in  std_logic_vector(13 downto 0); -- adc1 value
    ---------------------------------------------------------------------
    -- to the pads: @i_clk
    ---------------------------------------------------------------------
    o_adc_clk_p : out std_logic; -- differential_p clock adc
    o_adc_clk_n : out std_logic; -- differential_n clock adc
    -- adc0
    o_da0_p     : out std_logic; --  differential_p adc_a (lane0)
    o_da0_n     : out std_logic; --  differential_n adc_a (lane0)

    o_da2_p     : out std_logic; --  differential_p adc_a (lane1)
    o_da2_n     : out std_logic; --  differential_n adc_a (lane1)

    o_da4_p     : out std_logic; --  differential_p adc_a (lane2)
    o_da4_n     : out std_logic; --  differential_n adc_a (lane2)

    o_da6_p     : out std_logic; --  differential_p adc_a (lane3)
    o_da6_n     : out std_logic; --  differential_n adc_a (lane3)

    o_da8_p     : out std_logic; --  differential_p adc_a (lane4)
    o_da8_n     : out std_logic; --  differential_n adc_a (lane4)

    o_da10_p    : out std_logic; --  differential_p adc_a (lane5)
    o_da10_n    : out std_logic; --  differential_n adc_a (lane5)

    o_da12_p    : out std_logic; --  differential_p adc_a (lane6)
    o_da12_n    : out std_logic; --  differential_n adc_a (lane5)

    -- adc1
    o_db0_p  : out std_logic; --  differential_p adc_b (lane0)
    o_db0_n  : out std_logic; --  differential_n adc_b (lane0)

    o_db2_p  : out std_logic; --  differential_p adc_b (lane1)
    o_db2_n  : out std_logic; --  differential_n adc_b (lane1)

    o_db4_p  : out std_logic; --  differential_p adc_b (lane2)
    o_db4_n  : out std_logic; --  differential_n adc_b (lane2)

    o_db6_p  : out std_logic; --  differential_p adc_b (lane3)
    o_db6_n  : out std_logic; --  differential_n adc_b (lane3)

    o_db8_p  : out std_logic; --  differential_p adc_b (lane4)
    o_db8_n  : out std_logic; --  differential_n adc_b (lane4)

    o_db10_p : out std_logic; --  differential_p adc_b (lane5)
    o_db10_n : out std_logic; --  differential_n adc_b (lane5)

    o_db12_p : out std_logic; --  differential_p adc_b (lane6)
    o_db12_n : out std_logic --  differential_n adc_b (lane6)
    );
end entity ads62p49_io;

architecture RTL of ads62p49_io is



begin

---------------------------------------------------------------------
-- from the user to the pads
---------------------------------------------------------------------
-- clock
  gen_user_to_pads_clk : if true generate
    signal clk_fwd_out : std_logic;
    signal clk_tmp_p   : std_logic;
    signal clk_tmp_n   : std_logic;
  begin
    inst_oddr : unisim.vcomponents.ODDR
      generic map(
        DDR_CLK_EDGE   => "SAME_EDGE",
        INIT           => '0',
        IS_C_INVERTED  => '0',
        IS_D1_INVERTED => '0',
        IS_D2_INVERTED => '0',
        SRTYPE         => "ASYNC"
        )
      port map (  -- @suppress "The order of the associations is different from the declaration order"
        C  => i_clk_phase,
        CE => '1',
        D1 => '1',
        D2 => '0',
        Q  => clk_fwd_out,
        R  => '0',
        S  => '0'
        );

    inst_OBUFDS : OBUFDS
      generic map (  -- @suppress "Generic map uses default values. Missing optional actuals: CAPACITANCE"
        IOSTANDARD => "DEFAULT",        -- Specify the output I/O standard
        SLEW       => "SLOW")           -- Specify the output slew rate
      port map (
        O  => clk_tmp_p,  -- Diff_p output (connect directly to top-level port)
        OB => clk_tmp_n,  -- Diff_n output (connect directly to top-level port)
        I  => clk_fwd_out               -- Buffer input 
        );

    o_adc_clk_p <= clk_tmp_p;
    o_adc_clk_n <= clk_tmp_n;
  end generate gen_user_to_pads_clk;

-- adc0
  gen_adc0_user_to_pads : if true generate
    signal data_in_even : std_logic_vector(6 downto 0);
    signal data_in_odd  : std_logic_vector(6 downto 0);
    signal data_tmp     : std_logic_vector(6 downto 0);

    signal data_out_p : std_logic_vector(6 downto 0);
    signal data_out_n : std_logic_vector(6 downto 0);
  begin
    -- rising_edge: even bits
    -- falling_edge: odd bits
    data_in_even(6) <= i_adc0(12);
    data_in_even(5) <= i_adc0(10);
    data_in_even(4) <= i_adc0(8);
    data_in_even(3) <= i_adc0(6);
    data_in_even(2) <= i_adc0(4);
    data_in_even(1) <= i_adc0(2);
    data_in_even(0) <= i_adc0(0);

    data_in_odd(6) <= i_adc0(13);
    data_in_odd(5) <= i_adc0(11);
    data_in_odd(4) <= i_adc0(9);
    data_in_odd(3) <= i_adc0(7);
    data_in_odd(2) <= i_adc0(5);
    data_in_odd(1) <= i_adc0(3);
    data_in_odd(0) <= i_adc0(1);

    gen_io : for i in data_in_even'range generate

      inst_ODDR : ODDR
        generic map(
          DDR_CLK_EDGE => "OPPOSITE_EDGE",  -- "OPPOSITE_EDGE" or "SAME_EDGE" 
          INIT         => '0',  -- Initial value for Q port ('1' or '0')
          SRTYPE       => "SYNC")       -- Reset Type ("ASYNC" or "SYNC")
        port map (
          Q  => data_tmp(i),            -- 1-bit DDR output
          C  => i_clk,                  -- 1-bit clock input
          CE => '1',                    -- 1-bit clock enable input
          D1 => data_in_odd(i),         -- 1-bit data input (positive edge)
          D2 => data_in_even(i),        -- 1-bit data input (negative edge)
          --D1 => data_in_even(i),  -- 1-bit data input (positive edge)
          --D2 => data_in_odd(i),  -- 1-bit data input (negative edge)
          R  => '0',                    -- 1-bit reset input
          S  => '0'                     -- 1-bit set input
          );

      inst_OBUFDS : OBUFDS
        generic map (  -- @suppress "Generic map uses default values. Missing optional actuals: CAPACITANCE"
          IOSTANDARD => "DEFAULT",      -- Specify the output I/O standard
          SLEW       => "SLOW")         -- Specify the output slew rate
        port map (
          O  => data_out_p(i),  -- Diff_p output (connect directly to top-level port)
          OB => data_out_n(i),  -- Diff_n output (connect directly to top-level port)
          I  => data_tmp(i)             -- Buffer input 
          );
    end generate gen_io;


    o_da12_p <= data_out_p(6);
    o_da12_n <= data_out_n(6);

    o_da10_p <= data_out_p(5);
    o_da10_n <= data_out_n(5);

    o_da8_p <= data_out_p(4);
    o_da8_n <= data_out_n(4);

    o_da6_p <= data_out_p(3);
    o_da6_n <= data_out_n(3);

    o_da4_p <= data_out_p(2);
    o_da4_n <= data_out_n(2);

    o_da2_p <= data_out_p(1);
    o_da2_n <= data_out_n(1);

    o_da0_p <= data_out_p(0);
    o_da0_n <= data_out_n(0);

  end generate gen_adc0_user_to_pads;


-- adc1
  gen_adc1_user_to_pads : if true generate
    signal data_in_even : std_logic_vector(6 downto 0);
    signal data_in_odd  : std_logic_vector(6 downto 0);
    signal data_tmp     : std_logic_vector(6 downto 0);

    signal data_out_p : std_logic_vector(6 downto 0);
    signal data_out_n : std_logic_vector(6 downto 0);
  begin
    -- rising_edge: even bits
    -- falling_edge: odd bits
    data_in_even(6) <= i_adc1(12);
    data_in_even(5) <= i_adc1(10);
    data_in_even(4) <= i_adc1(8);
    data_in_even(3) <= i_adc1(6);
    data_in_even(2) <= i_adc1(4);
    data_in_even(1) <= i_adc1(2);
    data_in_even(0) <= i_adc1(0);

    data_in_odd(6) <= i_adc1(13);
    data_in_odd(5) <= i_adc1(11);
    data_in_odd(4) <= i_adc1(9);
    data_in_odd(3) <= i_adc1(7);
    data_in_odd(2) <= i_adc1(5);
    data_in_odd(1) <= i_adc1(3);
    data_in_odd(0) <= i_adc1(1);

    gen_io : for i in data_in_even'range generate

      inst_ODDR : ODDR
        generic map(
          DDR_CLK_EDGE => "OPPOSITE_EDGE",  -- "OPPOSITE_EDGE" or "SAME_EDGE" 
          INIT         => '0',  -- Initial value for Q port ('1' or '0')
          SRTYPE       => "SYNC")       -- Reset Type ("ASYNC" or "SYNC")
        port map (
          Q  => data_tmp(i),            -- 1-bit DDR output
          C  => i_clk,                  -- 1-bit clock input
          CE => '1',                    -- 1-bit clock enable input
          --D1 => data_in_even(i),  -- 1-bit data input (positive edge)
          --D2 => data_in_odd(i),  -- 1-bit data input (negative edge)
          D1 => data_in_odd(i),         -- 1-bit data input (positive edge)
          D2 => data_in_even(i),        -- 1-bit data input (negative edge)
          R  => '0',                    -- 1-bit reset input
          S  => '0'                     -- 1-bit set input
          );

      inst_OBUFDS : OBUFDS
        generic map (  -- @suppress "Generic map uses default values. Missing optional actuals: CAPACITANCE"
          IOSTANDARD => "DEFAULT",      -- Specify the output I/O standard
          SLEW       => "SLOW")         -- Specify the output slew rate
        port map (
          O  => data_out_p(i),  -- Diff_p output (connect directly to top-level port)
          OB => data_out_n(i),  -- Diff_n output (connect directly to top-level port)
          I  => data_tmp(i)             -- Buffer input 
          );
    end generate gen_io;

    o_db12_p <= data_out_p(6);
    o_db12_n <= data_out_n(6);

    o_db10_p <= data_out_p(5);
    o_db10_n <= data_out_n(5);

    o_db8_p <= data_out_p(4);
    o_db8_n <= data_out_n(4);

    o_db6_p <= data_out_p(3);
    o_db6_n <= data_out_n(3);

    o_db4_p <= data_out_p(2);
    o_db4_n <= data_out_n(2);

    o_db2_p <= data_out_p(1);
    o_db2_n <= data_out_n(1);

    o_db0_p <= data_out_p(0);
    o_db0_n <= data_out_n(0);


  end generate gen_adc1_user_to_pads;





end architecture RTL;
