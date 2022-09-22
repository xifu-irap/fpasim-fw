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
--!   @file                   io_adc.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--
-- This module generates fpga specific IO component with an optional user-defined latency
--
-- Example0:
--   Input ports ->  fpga specific IO generation -> optionnal latency -> output ports
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

Library UNISIM;
use UNISIM.vcomponents.all;

library fpasim;

entity io_adc is
   generic(
      g_ADC_WIDTH     : positive := 7; -- adc bus width (expressed in bits).Possible values [1;max integer value[
      g_INPUT_LATENCY : natural := 0  -- add latency after the input IO. Possible values: [0; max integer value[
   );
   port(
      i_clk   : in  std_logic;          -- clock
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_adc_p : in  std_logic_vector(g_ADC_WIDTH - 1 downto 0); -- Diff_p buffer input
      i_adc_n : in  std_logic_vector(g_ADC_WIDTH - 1 downto 0); -- Diff_n buffer input

      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_adc   : out std_logic_vector(g_ADC_WIDTH * 2 - 1 downto 0)
   );
end entity io_adc;

architecture RTL of io_adc is

   signal adc_tmp0 : std_logic_vector(i_adc_p'range);
   signal adc_tmp1 : std_logic_vector(o_adc'range);

   ---------------------------------------------------------------------
   -- add pipeline
   ---------------------------------------------------------------------
   signal adc_tmp2 : std_logic_vector(o_adc'range);

begin

   gen_adc_io : for i in i_adc_p'range generate
      inst_IBUFDS_adc : IBUFDS
         generic map(                   -- @suppress "Generic map uses default values. Missing optional actuals: CAPACITANCE, DQS_BIAS, IBUF_DELAY_VALUE, IFD_DELAY_VALUE"
            DIFF_TERM    => FALSE,      -- Differential Termination 
            IBUF_LOW_PWR => FALSE,      -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
            IOSTANDARD   => "LVDS")
         port map(
            O  => adc_tmp0(i),          -- Buffer output
            I  => i_adc_p(i),           -- Diff_p buffer input (connect directly to top-level port)
            IB => i_adc_n(i)            -- Diff_n buffer input (connect directly to top-level port)
         );

      -- In the SAME_EDGE_PIPELINED mode, the data is presented into the FPGA logic on the same clock edge.
      inst_IDDR_adc : IDDR
         generic map(                   -- @suppress "Generic map uses default values. Missing optional actuals: IS_C_INVERTED, IS_D_INVERTED"
            DDR_CLK_EDGE => "SAME_EDGE_PIPELINED", -- "OPPOSITE_EDGE", "SAME_EDGE" 
            -- or "SAME_EDGE_PIPELINED" 
            INIT_Q1      => '0',        -- Initial value of Q1: '0' or '1'
            INIT_Q2      => '0',        -- Initial value of Q2: '0' or '1'
            SRTYPE       => "SYNC")     -- Set/Reset type: "SYNC" or "ASYNC" 
         port map(
            Q1 => adc_tmp1(2 * i),      -- 1-bit output for positive edge of clock 
            Q2 => adc_tmp1(2 * i + 1),  -- 1-bit output for negative edge of clock
            C  => i_clk,                -- 1-bit clock input
            CE => '1',                  -- 1-bit clock enable input
            D  => adc_tmp0(i),          -- 1-bit DDR data input
            R  => '0',                  -- 1-bit reset
            S  => '0'                   -- 1-bit set
         );

   end generate gen_adc_io;

   ---------------------------------------------------------------------
   -- optionnally add latency after input IO
   ---------------------------------------------------------------------
   inst_pipeliner_add_input_latency : entity fpasim.pipeliner
      generic map(
         g_NB_PIPES   => g_INPUT_LATENCY, -- number of consecutives registers. Possibles values: [0, integer max value[
         g_DATA_WIDTH => adc_tmp1'length -- width of the input/output data.  Possibles values: [1, integer max value[
      )
      port map(
         i_clk  => i_clk,               -- clock signal
         i_data => adc_tmp1,            -- input data
         o_data => adc_tmp2             -- output data with/without delay
      );

   ---------------------------------------------------------------------
   -- output
   ---------------------------------------------------------------------
   o_adc <= adc_tmp2;

end architecture RTL;
