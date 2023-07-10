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
--      . generate a software reset (user-defined pulse width) usb_rst @i_usb_clk
--      . resynchronized the software reset for the IOs:
--          . ADC IOs
--          . DAC IOs
--          . SYNC IOs
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity reset_top is
  port (

    ---------------------------------------------------------------------
    -- from/to the usb
    ---------------------------------------------------------------------
    i_usb_clk : in  std_logic;  -- clock @usb_clk
    i_usb_rst : in  std_logic;  -- reset @usb_clk
    o_usb_rst : out std_logic;  -- output reset with user-defined pulse_width @usb_clk

    ---------------------------------------------------------------------
    -- from/to the mmcm
    ---------------------------------------------------------------------
    i_sys_clk             : in  std_logic;  -- system clock
    i_adc_clk_div         : in  std_logic;  -- adc div clock
    i_dac_clk_div         : in  std_logic;  -- dac div clock
    i_dac_clk_div_phase90 : in  std_logic;  -- dac div phase90 clock
    i_sync_clk            : in  std_logic;  -- sync/reference clock
    i_mmcm_locked         : in  std_logic;  -- mmcm locked signal
    ---------------------------------------------------------------------
    -- to the user
    ---------------------------------------------------------------------
    o_sys_rst             : out std_logic;  -- output reset @i_sys_clk

    ---------------------------------------------------------------------
    -- to the io_adc @i_adc_clk
    ---------------------------------------------------------------------
    o_adc_io_clk_rst : out std_logic;   -- ADC: small reset pulse width
    o_adc_io_rst     : out std_logic;   -- ADC: large reset pulse width

    ---------------------------------------------------------------------
    -- to the io_dac @i_dac_clk_div
    ---------------------------------------------------------------------
    o_dac_io_clk_rst     : out std_logic;  -- DAC: small reset pulse width
    o_dac_io_rst         : out std_logic;  -- DAC: large reset pulse width
    ---------------------------------------------------------------------
    -- to the io_dac @i_dac_clk_div_phase90
    ---------------------------------------------------------------------
    o_dac_io_rst_phase90 : out std_logic;  -- ADC: large reset pulse width

    ---------------------------------------------------------------------
    -- to the io_sync @i_sync_clk
    ---------------------------------------------------------------------
    o_sync_io_clk_rst : out std_logic;  -- SYNC: small reset pulse width
    o_sync_io_rst     : out std_logic   -- SYNC: large reset pulse width

    );
end entity reset_top;

architecture RTL of reset_top is

  ---------------------------------------------------------------------
  -- usb_reset
  ---------------------------------------------------------------------
  signal usb_rst_tmp2 : std_logic;

  ---------------------------------------------------------------------
  -- user reset
  ---------------------------------------------------------------------
  signal mmcm_rst_tmp1 : std_logic;
  signal sys_rst_tmp2  : std_logic;

  ---------------------------------------------------------------------
  -- io_adc
  ---------------------------------------------------------------------
  signal adc_rst_tmp1       : std_logic;
  signal adc_io_clk_rst     : std_logic;
  signal adc_io_rst         : std_logic;
  signal adc_io_rst_phase90 : std_logic;

  ---------------------------------------------------------------------
  -- io_dac
  ---------------------------------------------------------------------
  signal dac_rst_tmp1   : std_logic;
  signal dac_io_clk_rst : std_logic;
  signal dac_io_rst     : std_logic;

  ---------------------------------------------------------------------
  -- io_sync
  ---------------------------------------------------------------------
  signal sync_rst_tmp1   : std_logic;
  signal sync_io_clk_rst : std_logic;
  signal sync_io_rst     : std_logic;


begin

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
      i_clk => i_usb_clk,
      i_rst => i_usb_rst,
      ---------------------------------------------------------------------
      -- destination @i_clk
      ---------------------------------------------------------------------
      o_rst => usb_rst_tmp2
      );

  -- output
  o_usb_rst <= usb_rst_tmp2;

---------------------------------------------------------------------
-- resynchronize usb_rst/mmcm_locked @i_mmcm_clk
---------------------------------------------------------------------
  mmcm_rst_tmp1 <= '1' when ((usb_rst_tmp2 = '1') or (i_mmcm_locked = '0')) else '0';

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
      i_dest_clk => i_sys_clk,          -- Destination clock.
      o_dest_rst => sys_rst_tmp2  -- src_rst synchronized to the destination clock domain. This output is registered.
      );

  -- output
  o_sys_rst <= sys_rst_tmp2;

  ---------------------------------------------------------------------
  -- to io_adc
  ---------------------------------------------------------------------
  adc_rst_tmp1 <= usb_rst_tmp2;
  inst_reset_io_adc : entity work.reset_io
    generic map(
      -- +---------------------------------------------------------------------------------------------------------------------+
      -- | DEST_SYNC_FF         | Integer            | Range: 1 - max integer value. Default value = 4.                        |
      -- |---------------------------------------------------------------------------------------------------------------------|
      -- | Number of register stages used to define the reset pulse width
      g_DEST_FF => 8
      )
    port map(
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_rst        => adc_rst_tmp1,     -- asynchronuous reset
      ---------------------------------------------------------------------
      -- from the mmcm
      ---------------------------------------------------------------------
      i_clk        => i_adc_clk_div,
      i_pll_status => i_mmcm_locked,
      o_io_clk_rst => adc_io_clk_rst,   -- not used
      o_io_rst     => adc_io_rst
      );
  -- output
  o_adc_io_clk_rst <= '0';  -- must be independant of i_mmcm_adc_clk because this clock is generated by io_adc (otherwise perpetual reset)
  o_adc_io_rst     <= adc_io_rst;

  ---------------------------------------------------------------------
  -- to io_dac (data part)
  ---------------------------------------------------------------------
  dac_rst_tmp1 <= usb_rst_tmp2;
  inst_reset_io_dac : entity work.reset_io
    generic map(
      -- +---------------------------------------------------------------------------------------------------------------------+
      -- | DEST_SYNC_FF         | Integer            | Range: 1 - max integer value. Default value = 4.                        |
      -- |---------------------------------------------------------------------------------------------------------------------|
      -- | Number of register stages used to define the reset pulse width
      g_DEST_FF => 8
      )
    port map(
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_rst        => dac_rst_tmp1,     -- asynchronuous reset
      ---------------------------------------------------------------------
      -- from the mmcm
      ---------------------------------------------------------------------
      i_clk        => i_dac_clk_div,
      i_pll_status => i_mmcm_locked,
      o_io_clk_rst => dac_io_clk_rst,
      o_io_rst     => dac_io_rst
      );
  -- output
  o_dac_io_clk_rst <= dac_io_clk_rst;
  o_dac_io_rst     <= dac_io_rst;

  ---------------------------------------------------------------------
  -- to io_dac (clock part)
  ---------------------------------------------------------------------
  inst_reset_io_dac_phase90 : entity work.reset_io
    generic map(
      -- +---------------------------------------------------------------------------------------------------------------------+
      -- | DEST_SYNC_FF         | Integer            | Range: 1 - max integer value. Default value = 4.                        |
      -- |---------------------------------------------------------------------------------------------------------------------|
      -- | Number of register stages used to define the reset pulse width
      g_DEST_FF => 8
      )
    port map(
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_rst        => dac_rst_tmp1,     -- asynchronuous reset
      ---------------------------------------------------------------------
      -- from the mmcm
      ---------------------------------------------------------------------
      i_clk        => i_dac_clk_div_phase90,
      i_pll_status => i_mmcm_locked,
      o_io_clk_rst => open,
      o_io_rst     => adc_io_rst_phase90
      );
  -- output
  o_dac_io_rst_phase90 <= adc_io_rst_phase90;


  ---------------------------------------------------------------------
  -- to io_sync
  ---------------------------------------------------------------------
  sync_rst_tmp1 <= usb_rst_tmp2;
  inst_reset_io_sync : entity work.reset_io
    generic map(
      -- +---------------------------------------------------------------------------------------------------------------------+
      -- | DEST_SYNC_FF         | Integer            | Range: 1 - max integer value. Default value = 4.                        |
      -- |---------------------------------------------------------------------------------------------------------------------|
      -- | Number of register stages used to define the reset pulse width
      g_DEST_FF => 8
      )
    port map(
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_rst        => sync_rst_tmp1,    -- asynchronuous reset
      ---------------------------------------------------------------------
      -- from the mmcm
      ---------------------------------------------------------------------
      i_clk        => i_sync_clk,
      i_pll_status => i_mmcm_locked,
      o_io_clk_rst => sync_io_clk_rst,
      o_io_rst     => sync_io_rst
      );
  -- output
  o_sync_io_clk_rst <= sync_io_clk_rst;
  o_sync_io_rst     <= sync_io_rst;

end architecture RTL;
