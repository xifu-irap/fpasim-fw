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
--    @file                   reset_top.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details                
--    
--    This module manages reset mechanism   
--    It performs the following steps:
--      . synchronized the board reset @i_usb_clk
--      . generate a user-defined pulse usb_rst @i_usb_clk
--      . re-synchronized the usb_rst pulse at the mmcm slowest clock (by taking into account the mmcm locked)
--          . this reset can be used by all clock generated by the MMCM (based on the Xilinx pg164 (processor system reset))
--    
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity reset_top is
  port (
    ---------------------------------------------------------------------
    -- from the board
    ---------------------------------------------------------------------
    i_reset   : in  std_logic; -- asynchronuous reset
    ---------------------------------------------------------------------
    -- from/to the usb
    ---------------------------------------------------------------------
    i_usb_clk : in  std_logic; -- clock @usb_clk
    i_usb_rst : in  std_logic; -- reset @usb_clk
    o_usb_rst : out std_logic; -- output reset with user-defined pulse_width @usb_clk

    ---------------------------------------------------------------------
    -- from/to the mmcm
    ---------------------------------------------------------------------
    i_mmcm_slowest_clk : in  std_logic; -- mmcm_clk (clock)
    i_mmcm_locked      : in  std_logic; -- mmcm locked signal
    o_mmcm_rst         : out std_logic -- output reset @i_mmcm_slowest_clk

    );
end entity reset_top;

architecture RTL of reset_top is

  ---------------------------------------------------------------------
  -- usb_reset
  ---------------------------------------------------------------------
  signal usb_rst_tmp1 : std_logic;
  signal usb_rst_r1   : std_logic;
  signal usb_rst_tmp2 : std_logic;

  ---------------------------------------------------------------------
  -- mmcm reset
  ---------------------------------------------------------------------
  signal mmcm_rst_tmp1 : std_logic;
  signal mmcm_rst_tmp2 : std_logic;

begin
---------------------------------------------------------------------
-- resynchronize board reset
---------------------------------------------------------------------
  inst_synchronous_reset_synchronizer_board : entity work.synchronous_reset_synchronizer
    generic map(
      -- +---------------------------------------------------------------------------------------------------------------------+
      -- | DEST_SYNC_FF         | Integer            | Range: 2 - 10. Default value = 4.                                       |
      -- |---------------------------------------------------------------------------------------------------------------------|
      -- | Number of register stages used to synchronize signal in the destination clock domain.                               |
      g_DEST_SYNC_FF => 4,
      -- +---------------------------------------------------------------------------------------------------------------------+
      -- | INIT                 | Integer            | Allowed values: 1, 0. Default value = 1.                                |
      -- |---------------------------------------------------------------------------------------------------------------------|
      -- | 0- Initializes synchronization registers to 0                                                                       |
      -- | 1- Initializes synchronization registers to 1                                                                       |
      -- | The option to initialize the synchronization registers means that there is no complete x-propagation behavior       |
      -- | modeled in this macro. For complete x-propagation modelling, use the xpm_cdc_single macro.                          |
      g_INIT         => 1
      )
    port map(
      ---------------------------------------------------------------------
      -- source
      ---------------------------------------------------------------------
      i_src_rst  => i_reset,            -- Source reset signal
      ---------------------------------------------------------------------
      -- destination
      ---------------------------------------------------------------------
      i_dest_clk => i_usb_clk,          -- Destination clock.
      o_dest_rst => usb_rst_tmp1  -- src_rst synchronized to the destination clock domain. This output is registered.
      );

  p_rst_usb : process (i_usb_clk) is
  begin
    if rising_edge(i_usb_clk) then
      usb_rst_r1 <= usb_rst_tmp1 or i_usb_rst;
    end if;
  end process p_rst_usb;

---------------------------------------------------------------------
-- generate usb pulse reset @i_usb_clk
---------------------------------------------------------------------
  inst_synchronous_reset_pulse_usb : entity work.synchronous_reset_pulse
    generic map(
      -- +---------------------------------------------------------------------------------------------------------------------+
      -- | DEST_SYNC_FF         | Integer            | Range: 1 - max integer value. Default value = 4.                                       |
      -- |---------------------------------------------------------------------------------------------------------------------|
      -- | Number of register stages used to define the reset pulse width
      g_DEST_FF => 16,
      -- +---------------------------------------------------------------------------------------------------------------------+
      -- | INIT                 | Integer            | Allowed values: 1, 0. Default value = 1.                                |
      -- |---------------------------------------------------------------------------------------------------------------------|
      -- | 0- Initializes registers to 0                                                                       |
      -- | 1- Initializes registers to 1                                                                       |
      g_INIT    => 1
      )
    port map(
      ---------------------------------------------------------------------
      -- source
      ---------------------------------------------------------------------
      i_clk              => i_usb_clk,
      i_rst              => usb_rst_r1,
      ---------------------------------------------------------------------
      -- destination @i_clk
      ---------------------------------------------------------------------
      o_rst              => usb_rst_tmp2
      );

  o_usb_rst <= usb_rst_tmp2;

---------------------------------------------------------------------
-- resynchronize usb_rst/mmcm_locked @i_mmcm_slowest_clk
---------------------------------------------------------------------
  mmcm_rst_tmp1 <= usb_rst_tmp2 or not(i_mmcm_locked);

  inst_synchronous_reset_synchronizer_mmcm : entity work.synchronous_reset_synchronizer
    generic map(
      -- +---------------------------------------------------------------------------------------------------------------------+
      -- | DEST_SYNC_FF         | Integer            | Range: 2 - 10. Default value = 4.                                       |
      -- |---------------------------------------------------------------------------------------------------------------------|
      -- | Number of register stages used to synchronize signal in the destination clock domain.                               |
      g_DEST_SYNC_FF => 4,
      -- +---------------------------------------------------------------------------------------------------------------------+
      -- | INIT                 | Integer            | Allowed values: 1, 0. Default value = 1.                                |
      -- |---------------------------------------------------------------------------------------------------------------------|
      -- | 0- Initializes synchronization registers to 0                                                                       |
      -- | 1- Initializes synchronization registers to 1                                                                       |
      -- | The option to initialize the synchronization registers means that there is no complete x-propagation behavior       |
      -- | modeled in this macro. For complete x-propagation modelling, use the xpm_cdc_single macro.                          |
      g_INIT         => 1
      )
    port map(
      ---------------------------------------------------------------------
      -- source
      ---------------------------------------------------------------------
      i_src_rst  => mmcm_rst_tmp1,      -- Source reset signal
      ---------------------------------------------------------------------
      -- destination
      ---------------------------------------------------------------------
      i_dest_clk => i_mmcm_slowest_clk,  -- Destination clock.
      o_dest_rst => mmcm_rst_tmp2  -- src_rst synchronized to the destination clock domain. This output is registered.
      );

  o_mmcm_rst <= mmcm_rst_tmp2;

end architecture RTL;