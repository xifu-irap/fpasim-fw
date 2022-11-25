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
--!   @file                   synchronous_reset_synchronizer.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--!   
--!   This modules synchronizes a reset signal from a source clock domain to a destination clock domain 
--!   The architecture is as follows:
--!        @src_clk clock domain(implicite)       |                     @ i_dest_clk clock domain
--!        i_src_rst -------------------> xpm_cdc_sync_rst -----------> o_dest_rst
--!   Note: the following header documentation is an extract of the associated XPM Xilinx header        
-- -------------------------------------------------------------------------------------------------------------

-- -------------------------------------------------------------------------------------------------------------
-- XPM_CDC instantiation template for Synchronous Reset Synchronizer configurations
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
-- | INIT                 | Integer            | Allowed values: 1, 0. Default value = 1.                                |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | 0- Initializes synchronization registers to 0                                                                       |
-- | 1- Initializes synchronization registers to 1                                                                       |
-- | The option to initialize the synchronization registers means that there is no complete x-propagation behavior       |
-- | modeled in this macro. For complete x-propagation modelling, use the xpm_cdc_single macro.                          |
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

-- Port usage table, organized as follows:
-- +---------------------------------------------------------------------------------------------------------------------+
-- | Port name      | Direction | Size, in bits                         | Domain  | Sense       | Handling if unused     |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Description                                                                                                         |
-- +---------------------------------------------------------------------------------------------------------------------+
-- +---------------------------------------------------------------------------------------------------------------------+
-- | dest_clk       | Input     | 1                                     | NA      | Rising edge | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Destination clock.                                                                                                  |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | dest_rst       | Output    | 1                                     | dest_clk| NA          | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | src_rst synchronized to the destination clock domain. This output is registered.                                    |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | src_rst        | Input     | 1                                     | NA      | NA          | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Source reset signal.                                                                                                |
-- +---------------------------------------------------------------------------------------------------------------------+

library ieee;
use ieee.std_logic_1164.all;

library xpm;
use xpm.vcomponents.all;

entity synchronous_reset_synchronizer is
   generic(
      -- +---------------------------------------------------------------------------------------------------------------------+
      -- | DEST_SYNC_FF         | Integer            | Range: 2 - 10. Default value = 4.                                       |
      -- |---------------------------------------------------------------------------------------------------------------------|
      -- | Number of register stages used to synchronize signal in the destination clock domain.                               |
      g_DEST_SYNC_FF : integer := 2;
      -- +---------------------------------------------------------------------------------------------------------------------+
      -- | INIT                 | Integer            | Allowed values: 1, 0. Default value = 1.                                |
      -- |---------------------------------------------------------------------------------------------------------------------|
      -- | 0- Initializes synchronization registers to 0                                                                       |
      -- | 1- Initializes synchronization registers to 1                                                                       |
      -- | The option to initialize the synchronization registers means that there is no complete x-propagation behavior       |
      -- | modeled in this macro. For complete x-propagation modelling, use the xpm_cdc_single macro.                          |
      g_INIT         : integer := 1
      -- +---------------------------------------------------------------------------------------------------------------------+
      -- | INIT_SYNC_FF         | Integer            | Allowed values: 0, 1. Default value = 0.                                |
      -- |---------------------------------------------------------------------------------------------------------------------|
      -- | 0- Disable behavioral simulation initialization value(s) on synchronization registers.                              |
      -- | 1- Enable behavioral simulation initialization value(s) on synchronization registers.                               |
      --g_INIT_SYNC_FF : integer := 1;
      -- +---------------------------------------------------------------------------------------------------------------------+
      -- | SIM_ASSERT_CHK       | Integer            | Allowed values: 0, 1. Default value = 0.                                |
      -- |---------------------------------------------------------------------------------------------------------------------|
      -- | 0- Disable simulation message reporting. Messages related to potential misuse will not be reported.                 |
      -- | 1- Enable simulation message reporting. Messages related to potential misuse will be reported.                      |
      -- +---------------------------------------------------------------------------------------------------------------------+
      --g_SIM_ASSERT_CHK : integer := 0;

   );
   port(
      ---------------------------------------------------------------------
      -- source
      ---------------------------------------------------------------------
      i_src_rst  : in  std_logic;       -- Source reset signal
      ---------------------------------------------------------------------
      -- destination
      ---------------------------------------------------------------------
      i_dest_clk : in  std_logic;       -- Destination clock.
      o_dest_rst : out std_logic        -- src_rst synchronized to the destination clock domain. This output is registered.

   );
end entity synchronous_reset_synchronizer;

architecture RTL of synchronous_reset_synchronizer is

   signal dest_rst : std_logic;

begin

   inst_xpm_cdc_sync_rst : xpm_cdc_sync_rst
      generic map(
         DEST_SYNC_FF   => g_DEST_SYNC_FF, -- DECIMAL; range: 2-10
         INIT           => g_INIT,      -- DECIMAL; 0=initialize synchronization registers to 0, 1=initialize synchronization registers to 1
         INIT_SYNC_FF   => 1,           -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
         SIM_ASSERT_CHK => 1            -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      )
      port map(                         -- @suppress "The order of the associations is different from the declaration order"
         dest_rst => dest_rst,          -- 1-bit output: src_rst synchronized to the destination clock domain. This output
                                        -- is registered.

         dest_clk => i_dest_clk,        -- 1-bit input: Destination clock.
         src_rst  => i_src_rst          -- 1-bit input: Source reset signal.
      );

   o_dest_rst <= dest_rst;

end architecture RTL;
