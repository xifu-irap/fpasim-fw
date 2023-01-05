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
--    @file                   io_adc_single.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details                
--
--    This module generates fpga specific IO component with an optional user-defined latency
--
--    Example0:
--      i_adc_p/n ->  fpga specific IO generation -> optionnal latency -> o_adc
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


entity io_adc_single is
  generic(
    g_ADC_WIDTH     : positive := 7;  -- adc bus width (expressed in bits).Possible values [1;max integer value[
    g_INPUT_LATENCY : natural  := 0  -- add latency after the input IO. Possible values: [0; max integer value[
    );
  port(
    i_clk : in std_logic;               -- clock

    -- from reset_top: @i_clk
    i_io_clk_rst : in std_logic;  -- Clock reset: Reset connected to clocking elements in the circuit
    i_io_rst     : in std_logic;  -- Reset connected to all other elements in the circuit
    ---------------------------------------------------------------------
    -- input
    ---------------------------------------------------------------------
    i_adc_p      : in std_logic_vector(g_ADC_WIDTH - 1 downto 0);  -- Diff_p buffer input
    i_adc_n      : in std_logic_vector(g_ADC_WIDTH - 1 downto 0);  -- Diff_n buffer input

    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    o_adc : out std_logic_vector(g_ADC_WIDTH * 2 - 1 downto 0)
    );
end entity io_adc_single;

architecture RTL of io_adc_single is

  signal adc_tmp0 : std_logic_vector(o_adc'range);
  signal adc_tmp1 : std_logic_vector(o_adc'range);

  ---------------------------------------------------------------------
  -- add pipeline
  ---------------------------------------------------------------------
  signal adc_tmp2 : std_logic_vector(o_adc'range);

begin

  inst_selectio_wiz_adc : entity work.selectio_wiz_adc
    port map(
      data_in_from_pins_p => i_adc_p,
      data_in_from_pins_n => i_adc_n,
      data_in_to_device   => adc_tmp0,
      clk_in              => i_clk,
      --sync_reset          => i_io_clk_rst,
      io_reset            => i_io_rst
      );

  ---------------------------------------------------------------------
  -- I/O interface:
  -- bit remapping : see the ip/xilinx/coregen/selectio_wiz_adc/selectio_wiz_adc_sim_netlist.vhdl from Xilinx ip compilation.
  -- adc_tmp1(0) <= adc_tmp0(0); -- pos edge
  -- adc_tmp1(1) <= adc_tmp0(7); -- neg edge
  -- adc_tmp1(2) <= adc_tmp0(1); -- pos edge
  -- adc_tmp1(3) <= adc_tmp0(8); -- neg edge
  -- and so on
  ---------------------------------------------------------------------
  remapp_bit : for i in i_adc_p'range generate
    adc_tmp1(2 * i)     <= adc_tmp0(i);
    adc_tmp1(2 * i + 1) <= adc_tmp0(i + 7);
  end generate remapp_bit;

  ---------------------------------------------------------------------
  -- optionnally add latency after input IO
  ---------------------------------------------------------------------
  inst_pipeliner_add_input_latency : entity work.pipeliner
    generic map(
      g_NB_PIPES   => g_INPUT_LATENCY,  -- number of consecutives registers. Possibles values: [0, integer max value[
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
  o_adc <= adc_tmp2;

end architecture RTL;
