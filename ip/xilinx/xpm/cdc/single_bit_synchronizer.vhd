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
--    @file                   single_bit_synchronizer.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This modules synchronizes a data bit from a source clock domain to a destination clock domain
--    The architecture is as follows:
--         @i_src_clk clock domain             |                    @ i_dest_clk clock domain
--         i_src ---------------------> xpm_cdc_single -----------> o_dest
--
--    Note: the following header documentation is an extract of the associated XPM Xilinx header
--
-- -------------------------------------------------------------------------------------------------------------

-- -------------------------------------------------------------------------------------------------------------
-- XPM_CDC instantiation template for Single-bit Synchronizer configurations
-- Refer to the targeted device family architecture libraries guide for XPM_CDC documentation
-- =======================================================================================================================

-- Parameter usage table, organized as follows:
-- +---------------------------------------------------------------------------------------------------------------------+
-- | Parameter name       | Data type          | Restrictions, if applicable                                             |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Description                                                                                                         |
-- +---------------------------------------------------------------------------------------------------------------------+
-- +---------------------------------------------------------------------------------------------------------------------+
-- | DEST_SYNC_FF         | Integer            | Range: 2 - 10. Default value = 4.                                       |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Number of register stages used to synchronize signal in the destination clock domain.                               |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | INIT_SYNC_FF         | Integer            | Allowed values: 0, 1. Default value = 0.                                |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | 0- Disable behavioral simulation initialization value(s) on synchronization registers.                              |
-- | 1- Enable behavioral simulation initialization value(s) on synchronization registers.                               |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | SIM_ASSERT_CHK       | Integer            | Allowed values: 0, 1. Default value = 0.                                |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | 0- Disable simulation message reporting. Messages related to potential misuse will not be reported.                 |
-- | 1- Enable simulation message reporting. Messages related to potential misuse will be reported.                      |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | SRC_INPUT_REG        | Integer            | Allowed values: 1, 0. Default value = 1.                                |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | 0- Do not register input (src_in)                                                                                   |
-- | 1- Register input (src_in) once using src_clk                                                                       |
-- +---------------------------------------------------------------------------------------------------------------------+

-- Port usage table, organized as follows:
-- +---------------------------------------------------------------------------------------------------------------------+
-- | Port name      | Direction | Size, in bits                         | Domain  | Sense       | Handling if unused     |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Description                                                                                                         |
-- +---------------------------------------------------------------------------------------------------------------------+
-- +---------------------------------------------------------------------------------------------------------------------+
-- | dest_clk       | Input     | 1                                     | NA      | Rising edge | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Clock signal for the destination clock domain.                                                                      |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | dest_out       | Output    | 1                                     | dest_clk| NA          | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | src_in synchronized to the destination clock domain. This output is registered.                                     |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | src_clk        | Input     | 1                                     | NA      | Rising edge | Tie to 1'b0            |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Input clock signal for src_in if SRC_INPUT_REG = 1.                                                                 |
-- | Unused when SRC_INPUT_REG = 0.                                                                                      |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | src_in         | Input     | 1                                     | src_clk | NA          | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Input signal to be synchronized to dest_clk domain.                                                                 |
-- +---------------------------------------------------------------------------------------------------------------------+

library ieee;
use ieee.std_logic_1164.all;

library xpm;
use xpm.vcomponents.all;

entity single_bit_synchronizer is
   generic(
      -- +---------------------------------------------------------------------------------------------------------------------+
      -- | DEST_SYNC_FF         | Integer            | Range: 2 - 10. Default value = 4.                                       |
      -- |---------------------------------------------------------------------------------------------------------------------|
      -- | Number of register stages used to synchronize signal in the destination clock domain.
      g_DEST_SYNC_FF  : integer := 4;
      -- +---------------------------------------------------------------------------------------------------------------------+
      -- | SRC_INPUT_REG        | Integer            | Allowed values: 1, 0. Default value = 1.                                |
      -- |---------------------------------------------------------------------------------------------------------------------|
      -- | 0- Do not register input (src_in)                                                                                   |
      -- | 1- Register input (src_in) once using src_clk
      g_SRC_INPUT_REG : integer := 0
   );
   port(
      ---------------------------------------------------------------------
      -- source
      ---------------------------------------------------------------------
      i_src_clk  : in  std_logic;       -- source clock
      i_src      : in  std_logic;       -- input signal to be synchronized to dest_clk domain
      ---------------------------------------------------------------------
      -- destination
      ---------------------------------------------------------------------
      i_dest_clk : in  std_logic;       -- destination clock domain
      o_dest     : out std_logic        -- src_in synchronized to the destination clock domain. This output is registered.

   );
end entity single_bit_synchronizer;

architecture RTL of single_bit_synchronizer is

   signal dest : std_logic;

begin

   inst_xpm_cdc_single : xpm_cdc_single
      generic map(
         DEST_SYNC_FF   => g_DEST_SYNC_FF, -- DECIMAL; range: 2-10
         INIT_SYNC_FF   => 1,           -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
         SIM_ASSERT_CHK => 1,           -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
         SRC_INPUT_REG  => g_SRC_INPUT_REG -- DECIMAL; 0=do not register input, 1=register input
      )
      port map(
         dest_out => dest,              -- 1-bit output: src_in synchronized to the destination clock domain. This output
         -- is registered.

         dest_clk => i_dest_clk,        -- 1-bit input: Clock signal for the destination clock domain.
         src_clk  => i_src_clk,         -- 1-bit input: optional; required when SRC_INPUT_REG = 1
         src_in   => i_src              -- 1-bit input: Input signal to be synchronized to dest_clk domain.
      );

   o_dest <= dest;

end architecture RTL;
