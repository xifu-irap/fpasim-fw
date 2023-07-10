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
--    @file                   reset_io.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This module generates 2 pulse reset (user-defined pulse width defined by g_DEST_FF).
--
--    The architecture is as follows:
--
--                   <----2xg_DEST_FF-------->
--                   <----g_DEST_FF->
--    i_rst        | 1  0  0  0  0  0  0  0  0  0  0  0  0
--    o_io_clk_rst | 1  1  ....  1  0  0  0  0  0  0  0  0
--    o_io_rst     | 1  1  ....  1  1  ...   1  0  0  0  0
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity reset_io is
  generic (
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | DEST_SYNC_FF         | Integer            | Range: 1 - max integer value. Default value = 4.                        |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Number of register stages used to define the reset pulse width
    g_DEST_FF : integer := 8
    );
  port (

    ---------------------------------------------------------------------
    -- input
    ---------------------------------------------------------------------
    i_rst : std_logic;                  -- asynchronuous reset

    ---------------------------------------------------------------------
    -- from the mmcm
    ---------------------------------------------------------------------
    i_clk         : in  std_logic;  -- clock
    i_pll_status  : in  std_logic;  -- '1': pll locked, '0': pll unlocked
    o_io_clk_rst  : out std_logic;  -- smallest pulse width reset
    o_io_rst      : out std_logic   --  largest pulse width reset

    );
end entity reset_io;

architecture RTL of reset_io is

  ---------------------------------------------------------------------
  -- synchronous_reset_synchronizer
  ---------------------------------------------------------------------
  signal io_clk_rst_tmp1 : std_logic;
  signal io_clk_rst_tmp2 : std_logic;

  ---------------------------------------------------------------------
  -- optional pipe
  ---------------------------------------------------------------------
  signal data_pipe_tmp0  : std_logic_vector(0 downto 0);
  signal data_pipe_tmp1  : std_logic_vector(0 downto 0);
  signal io_clk_rst_tmp3 : std_logic;

  ---------------------------------------------------------------------
  -- synchronous_reset_pulse
  ---------------------------------------------------------------------
  signal io_rst_tmp3 : std_logic;

begin

---------------------------------------------------------------------
-- resynchronize i_rst/mmcm_locked @i_clk
---------------------------------------------------------------------
  io_clk_rst_tmp1 <= '1' when ((i_rst = '1') or (i_pll_status = '0')) else '0';

  inst_synchronous_reset_synchronizer_io_clk : entity work.synchronous_reset_synchronizer
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
      i_src_rst  => io_clk_rst_tmp1,    -- Source reset signal
      ---------------------------------------------------------------------
      -- destination
      ---------------------------------------------------------------------
      i_dest_clk => i_clk,         -- Destination clock.
      o_dest_rst => io_clk_rst_tmp2  -- src_rst synchronized to the destination clock domain. This output is registered.
      );

  ---------------------------------------------------------------------
  -- optional pipe
  ---------------------------------------------------------------------
  data_pipe_tmp0(0) <= io_clk_rst_tmp2;

  inst_pipeliner : entity work.pipeliner
    generic map(
      g_NB_PIPES   => 1,  -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => data_pipe_tmp0'length
      )
    port map(
      i_clk  => i_clk,
      i_data => data_pipe_tmp0,
      o_data => data_pipe_tmp1
      );

  io_clk_rst_tmp3 <= data_pipe_tmp1(0);

---------------------------------------------------------------------
-- output
---------------------------------------------------------------------
  o_io_clk_rst <= io_clk_rst_tmp3;


---------------------------------------------------------------------
-- generate usb pulse reset @i_usb_clk
---------------------------------------------------------------------
  inst_synchronous_reset_pulse_io : entity work.synchronous_reset_pulse
    generic map(
      -- +---------------------------------------------------------------------------------------------------------------------+
      -- | DEST_SYNC_FF         | Integer            | Range: 1 - max integer value. Default value = 4.                        |
      -- |---------------------------------------------------------------------------------------------------------------------|
      -- | Number of register stages used to define the reset pulse width
      g_DEST_FF => g_DEST_FF,
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
      i_clk => i_clk,
      i_rst => io_clk_rst_tmp3,
      ---------------------------------------------------------------------
      -- destination @i_clk
      ---------------------------------------------------------------------
      o_rst => io_rst_tmp3
      );

---------------------------------------------------------------------
-- output
---------------------------------------------------------------------
  o_io_rst <= io_rst_tmp3;

end architecture RTL;
