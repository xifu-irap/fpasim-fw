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
--    @file                   ads62p49_top.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details                
--
-- -------------------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity ads62p49_top is
  generic (
    g_ADC_VPP   : in natural := 2;  -- ADC differential input voltage ( Vpp expressed in Volts)
    g_ADC_RES   : in natural := 14;    -- ADC resolution
    g_ADC_DELAY : in natural := 0      -- adc latency
    );
  port (

    ---------------------------------------------------------------------
    -- inputs
    ---------------------------------------------------------------------
    i_adc_clk_phase : in std_logic;
    i_adc_clk : in std_logic;
    i_adc0_real : in real;
    i_adc1_real : in real;

    ---------------------------------------------------------------------
    -- outputs
    ---------------------------------------------------------------------
    o_adc_clk_p : out std_logic;
    o_adc_clk_n : out std_logic;
    -- adc0
    o_da0_p     : out std_logic;
    o_da0_n     : out std_logic;
    o_da2_p     : out std_logic;
    o_da2_n     : out std_logic;
    o_da4_p     : out std_logic;
    o_da4_n     : out std_logic;
    o_da6_p     : out std_logic;
    o_da6_n     : out std_logic;
    o_da8_p     : out std_logic;
    o_da8_n     : out std_logic;
    o_da10_p    : out std_logic;
    o_da10_n    : out std_logic;
    o_da12_p    : out std_logic;
    o_da12_n    : out std_logic;

    -- adc1
    o_db0_p  : out std_logic;
    o_db0_n  : out std_logic;
    o_db2_p  : out std_logic;
    o_db2_n  : out std_logic;
    o_db4_p  : out std_logic;
    o_db4_n  : out std_logic;
    o_db6_p  : out std_logic;
    o_db6_n  : out std_logic;
    o_db8_p  : out std_logic;
    o_db8_n  : out std_logic;
    o_db10_p : out std_logic;
    o_db10_n : out std_logic;
    o_db12_p : out std_logic;
    o_db12_n : out std_logic
    );
end entity ads62p49_top;

architecture RTL of ads62p49_top is

  signal ddr_adc0 : std_logic_vector(13 downto 0);
  signal ddr_adc1 : std_logic_vector(13 downto 0);

begin

---------------------------------------------------------------------
-- ADC0
---------------------------------------------------------------------
  inst_ads62p49_convert_adc0 : entity work.ads62p49_convert
    generic map(
      g_ADC_VPP   => g_ADC_VPP,  -- ADC differential input voltage ( Vpp expressed in Volts)
      g_ADC_RES   => g_ADC_RES,         -- ADC resolution
      g_ADC_DELAY => g_ADC_DELAY        -- adc latency
      )
    port map(
      i_clk     => i_adc_clk,
      ---------------------------------------------------------------------
      -- inputs
      ---------------------------------------------------------------------
      i_adc     => i_adc0_real,
      ---------------------------------------------------------------------
      -- outputs @i_clk
      ---------------------------------------------------------------------
      o_ddr_adc => ddr_adc0
      );

---------------------------------------------------------------------
-- ADC1
---------------------------------------------------------------------
  inst_ads62p49_convert_adc1 : entity work.ads62p49_convert
    generic map(
      g_ADC_VPP   => g_ADC_VPP,  -- ADC differential input voltage ( Vpp expressed in Volts)
      g_ADC_RES   => g_ADC_RES,         -- ADC resolution
      g_ADC_DELAY => g_ADC_DELAY        -- adc latency
      )
    port map(
      i_clk     => i_adc_clk,
      ---------------------------------------------------------------------
      -- inputs
      ---------------------------------------------------------------------
      i_adc     => i_adc1_real,
      ---------------------------------------------------------------------
      -- outputs @i_clk
      ---------------------------------------------------------------------
      o_ddr_adc => ddr_adc1
      );

---------------------------------------------------------------------
-- output
---------------------------------------------------------------------
  inst_ads62p49_io : entity work.ads62p49_io
    port map(
      i_clk_phase       => i_adc_clk_phase,
      i_clk       => i_adc_clk,
      ---------------------------------------------------------------------
      -- inputs
      ---------------------------------------------------------------------
      i_adc0      => ddr_adc0,
      i_adc1      => ddr_adc1,
      ---------------------------------------------------------------------
      -- outputs @i_clk
      ---------------------------------------------------------------------
      o_adc_clk_p => o_adc_clk_p,
      o_adc_clk_n => o_adc_clk_n,
      -- adc0
      o_da0_p     => o_da0_p,
      o_da0_n     => o_da0_n,
      o_da2_p     => o_da2_p,
      o_da2_n     => o_da2_n,
      o_da4_p     => o_da4_p,
      o_da4_n     => o_da4_n,
      o_da6_p     => o_da6_p,
      o_da6_n     => o_da6_n,
      o_da8_p     => o_da8_p,
      o_da8_n     => o_da8_n,
      o_da10_p    => o_da10_p,
      o_da10_n    => o_da10_n,
      o_da12_p    => o_da12_p,
      o_da12_n    => o_da12_n,
      -- adc1
      o_db0_p     => o_db0_p,
      o_db0_n     => o_db0_n,
      o_db2_p     => o_db2_p,
      o_db2_n     => o_db2_n,
      o_db4_p     => o_db4_p,
      o_db4_n     => o_db4_n,
      o_db6_p     => o_db6_p,
      o_db6_n     => o_db6_n,
      o_db8_p     => o_db8_p,
      o_db8_n     => o_db8_n,
      o_db10_p    => o_db10_p,
      o_db10_n    => o_db10_n,
      o_db12_p    => o_db12_p,
      o_db12_n    => o_db12_n
      );


end architecture RTL;
