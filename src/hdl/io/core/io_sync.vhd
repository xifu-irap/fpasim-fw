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
--!   @file                   io_sync.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--
-- This module generates fpga specific IO component with an optional user-defined latency

-- Example0:
--   Input ports -> optionnal latency -> fpga specific IO generation -> output port
--
-- -------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library fpasim;

Library UNISIM;
use UNISIM.vcomponents.all;

entity io_sync is
   generic(
      g_OUTPUT_LATENCY : natural := 0 -- add latency before the output IO. Possible values: [0; max integer values[
   );
   port(
      i_clk      : in  std_logic;       -- clock
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_sync     : in  std_logic;
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_sync_clk : out std_logic;
      o_sync     : out std_logic
   );
end entity io_sync;

architecture RTL of io_sync is

   ---------------------------------------------------------------------
   -- optionnally add latency
   ---------------------------------------------------------------------
   signal sync_rx : std_logic;

   ---------------------------------------------------------------------
   -- oddr
   ---------------------------------------------------------------------
   signal sync_tmp : std_logic;
   signal clk_tmp  : std_logic;

begin

   ---------------------------------------------------------------------
   -- output: optionnally add latency before output IOs
   ---------------------------------------------------------------------
   inst_pipeliner_add_output_latency : entity fpasim.pipeliner
      generic map(
         g_NB_PIPES   => g_OUTPUT_LATENCY, -- number of consecutives registers. Possibles values: [0, integer max value[
         g_DATA_WIDTH => 1              -- width of the input/output data.  Possibles values: [1, integer max value[
      )
      port map(
         i_clk     => i_clk,            -- clock signal
         i_data(0) => i_sync,           -- input data
         o_data(0) => sync_rx           -- output data with/without delay
      );

   ---------------------------------------------------------------------
   -- oddr
   ---------------------------------------------------------------------
   inst_ODDR_sync : ODDR
      generic map(                      -- @suppress "Generic map uses default values. Missing optional actuals: IS_C_INVERTED, IS_D1_INVERTED, IS_D2_INVERTED"
         DDR_CLK_EDGE => "SAME_EDGE",   -- "OPPOSITE_EDGE" or "SAME_EDGE" 
         INIT         => '0',           -- Initial value for Q port ('1' or '0')
         SRTYPE       => "SYNC")        -- Reset Type ("ASYNC" or "SYNC")
      port map(
         Q  => sync_tmp,                -- 1-bit DDR output
         C  => i_clk,                   -- 1-bit clock input
         CE => '1',                     -- 1-bit clock enable input
         D1 => sync_rx,                 -- 1-bit data input (positive edge)
         D2 => sync_rx,                 -- 1-bit data input (negative edge)
         R  => '0',                     -- 1-bit reset input
         S  => '0'                      -- 1-bit set input
      );

   -- add oddr on clock to have the same logic on the FPGA pads as the data path
   inst_ODDR_clk : ODDR
      generic map(                      -- @suppress "Generic map uses default values. Missing optional actuals: IS_C_INVERTED, IS_D1_INVERTED, IS_D2_INVERTED"
         DDR_CLK_EDGE => "SAME_EDGE",   -- "OPPOSITE_EDGE" or "SAME_EDGE" 
         INIT         => '0',           -- Initial value for Q port ('1' or '0')
         SRTYPE       => "SYNC")        -- Reset Type ("ASYNC" or "SYNC")
      port map(
         Q  => clk_tmp,                 -- 1-bit DDR output
         C  => i_clk,                   -- 1-bit clock input
         CE => '1',                     -- 1-bit clock enable input
         D1 => '1',                     -- 1-bit data input (positive edge)
         D2 => '0',                     -- 1-bit data input (negative edge)
         R  => '0',                     -- 1-bit reset input
         S  => '0'                      -- 1-bit set input
      );

   ---------------------------------------------------------------------
   -- output
   ---------------------------------------------------------------------
   o_sync_clk <= clk_tmp;
   o_sync     <= sync_tmp;

end architecture RTL;
