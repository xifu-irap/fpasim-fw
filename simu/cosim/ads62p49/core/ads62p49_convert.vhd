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
--    @file                   ads62p49_convert.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This module converts an input float value to signed value (2's complement) + add an optional output delay
--
--    Note:
--     . This module is not synthesizable (only for simulation).
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.fixed_pkg.all;
use ieee.fixed_float_types.all;

entity ads62p49_convert is
  generic (
    g_ADC_VPP   : in natural := 2;  -- ADC differential input voltage ( Vpp expressed in Volts)
    g_ADC_RES   : in natural := 14; -- ADC resolution (expressed in bits)
    g_ADC_DELAY : in natural := 0  -- ADC conversion delay (expressed in number of clock cycles @i_clk). The range is: [0;max integer value[)
    );
  port (
    i_clk : in std_logic;

    ---------------------------------------------------------------------
    -- inputs
    ---------------------------------------------------------------------
    i_adc     : in  real; -- ADC real value
    ---------------------------------------------------------------------
    -- ddr outputs @i_clk
    ---------------------------------------------------------------------
    o_ddr_adc : out std_logic_vector(g_ADC_RES - 1 downto 0) -- ADC value
    );
end entity ads62p49_convert;

architecture RTL of ads62p49_convert is

  constant c_FACTOR : real    := real(g_ADC_VPP)/2.0;
  constant c_Q_M    : integer := 0;  -- number of bits used for the integer part of the value ( sign bit included). Possible values [0;integer_max_value[
  constant c_Q_N    : integer := o_ddr_adc'length - 1;  -- number of fraction bits. Possible values [0;integer_max_value[

---------------------------------------------------------------------
-- convert: float -> sfixed
---------------------------------------------------------------------
  signal f_adc_tmp0 : real;
  signal s_adc_tmp0 : sfixed(c_Q_M downto -c_Q_N);

---------------------------------------------------------------------
-- convert: sfixed -> std_logic_vector
---------------------------------------------------------------------
  signal adc_tmp1 : std_logic_vector(o_ddr_adc'range);
  signal adc_tmp2 : std_logic_vector(o_ddr_adc'range);

begin
  -- convert: [-g_ADC_VPP/2;g_ADC_VPP/2[ -> [-1;0.99[
  f_adc_tmp0 <= c_FACTOR * i_adc;
  --f_adc_tmp0 <= 1.0 * i_adc;
-- convert: float -> sfixed
  s_adc_tmp0 <= to_sfixed(f_adc_tmp0, s_adc_tmp0);

-- convert: sfixed -> std_logic_vector
  adc_tmp1 <= to_slv(s_adc_tmp0);

  inst_pipeliner : entity work.pipeliner
    generic map(
      g_NB_PIPES   => g_ADC_DELAY,  -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => adc_tmp1'length  -- width of the input/output data.  Possibles values: [1, integer max value[
      )
    port map(
      i_clk  => i_clk,                  -- clock signal
      i_data => adc_tmp1,               -- input data
      o_data => adc_tmp2                -- output data with/without delay
      );

---------------------------------------------------------------------
-- output
---------------------------------------------------------------------
  o_ddr_adc <= adc_tmp2;

end architecture RTL;
