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
--    @file                   system_fpasim_top.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This module is the fpga top level
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.pkg_system_fpasim_debug.all;

entity system_fpasim_top is
  generic (
    g_DEBUG : boolean := pkg_SYSTEM_FPASIM_TOP_DEBUG
    );
  port(
    --i_clk_to_fpga_p : in std_logic;
    --i_clk_to_fpga_n : in std_logic;
    --  Opal Kelly inouts --
    i_okUH  : in    std_logic_vector(4 downto 0); -- usb interface signal
    o_okHU  : out   std_logic_vector(2 downto 0); -- usb interface signal
    b_okUHU : inout std_logic_vector(31 downto 0); -- usb interface signal
    b_okAA  : inout std_logic; -- usb interface signal
    ---------------------------------------------------------------------
    -- FMC: from the card
    -- requirement: FPASIM-FW-REQ-0270
    ---------------------------------------------------------------------
    --i_hardware_id : in    std_logic_vector(7 downto 0);  -- card hardware id

    ---------------------------------------------------------------------
    -- FMC: from the adc @i_adc_clk_p
    ---------------------------------------------------------------------
    i_adc_clk_p : in std_logic;         -- differential_p clock adc @250MHz
    i_adc_clk_n : in std_logic;         -- differential_n clock adc @250MHZ
    -- adc_a
    -- bit P/N: 0-1
    i_da0_p     : in std_logic;         --  differential_p adc_a (lane0)
    i_da0_n     : in std_logic;         --  differential_n adc_a (lane0)

    i_da2_p : in std_logic;             --  differential_p adc_a (lane1)
    i_da2_n : in std_logic;             --  differential_n adc_a (lane1)

    i_da4_p : in std_logic;             --  differential_p adc_a (lane2)
    i_da4_n : in std_logic;             --  differential_n adc_a (lane2)

    i_da6_p : in std_logic;             --  differential_p adc_a (lane3)
    i_da6_n : in std_logic;             --  differential_n adc_a (lane3)

    i_da8_p : in std_logic;             --  differential_p adc_a (lane4)
    i_da8_n : in std_logic;             --  differential_n adc_a (lane4)

    i_da10_p : in std_logic;            --  differential_p adc_a (lane5)
    i_da10_n : in std_logic;            --  differential_n adc_a (lane5)

    i_da12_p : in std_logic;            --  differential_p adc_a (lane6)
    i_da12_n : in std_logic;            --  differential_n adc_a (lane6)
    -- adc_b
    i_db0_p  : in std_logic;            --  differential_p adc_b (lane0)
    i_db0_n  : in std_logic;            --  differential_n adc_b (lane0)

    i_db2_p : in std_logic;             --  differential_p adc_b (lane1)
    i_db2_n : in std_logic;             --  differential_n adc_b (lane1)

    i_db4_p : in std_logic;             --  differential_p adc_b (lane2)
    i_db4_n : in std_logic;             --  differential_n adc_b (lane2)

    i_db6_p : in std_logic;             --  differential_p adc_b (lane3)
    i_db6_n : in std_logic;             --  differential_n adc_b (lane3)

    i_db8_p : in std_logic;             --  differential_p adc_b (lane4)
    i_db8_n : in std_logic;             --  differential_n adc_b (lane4)

    i_db10_p : in std_logic;            --  differential_p adc_b (lane5)
    i_db10_n : in std_logic;            --  differential_n adc_b (lane5)

    i_db12_p : in std_logic;            --  differential_p adc_b (lane6)
    i_db12_n : in std_logic;            --  differential_n adc_b (lane6)

    ---------------------------------------------------------------------
    -- FMC: to sync
    ---------------------------------------------------------------------
    o_ref_clk   : out std_logic;        -- reference clock
    o_sync      : out std_logic;  -- pulse at the beginning of the first pixel of a column (@o_ref_clk)
    ---------------------------------------------------------------------
    -- FMC: to dac
    ---------------------------------------------------------------------
    o_dac_clk_p : out std_logic;        -- differential_p dac clock
    o_dac_clk_n : out std_logic;        -- differential_n dac clock

    o_dac_frame_p : out std_logic;      -- differential_p dac frame
    o_dac_frame_n : out std_logic;      -- differential_n dac frame

    o_dac0_p : out std_logic;           -- differential_p dac data (lane0)
    o_dac0_n : out std_logic;           -- differential_n dac data (lane0)

    o_dac1_p : out std_logic;           -- differential_p dac data (lane1)
    o_dac1_n : out std_logic;           -- differential_n dac data (lane1)

    o_dac2_p : out std_logic;           -- differential_p dac data (lane2)
    o_dac2_n : out std_logic;           -- differential_n dac data (lane2)

    o_dac3_p : out std_logic;           -- differential_p dac data (lane3)
    o_dac3_n : out std_logic;           -- differential_n dac data (lane3)

    o_dac4_p : out std_logic;           -- differential_p dac data (lane4)
    o_dac4_n : out std_logic;           -- differential_n dac data (lane4)

    o_dac5_p : out std_logic;           -- differential_p dac data (lane5)
    o_dac5_n : out std_logic;           -- differential_n dac data (lane5)

    o_dac6_p : out std_logic;           -- differential_p dac data (lane6)
    o_dac6_n : out std_logic;           -- differential_n dac data (lane6)

    o_dac7_p : out std_logic;           -- differential_p dac data (lane7)
    o_dac7_n : out std_logic;           -- differential_n dac data (lane7)

    ---------------------------------------------------------------------
    -- devices: spi links + specific signals
    ---------------------------------------------------------------------
    -- common: shared link between the spi
    o_spi_sclk  : out std_logic;        -- Shared SPI clock line
    o_spi_sdata : out std_logic;        -- Shared SPI MOSI

    -- CDCE: SPI
    i_cdce_sdo  : in  std_logic;        -- SPI MISO
    o_cdce_n_en : out std_logic;        -- SPI chip select

    -- CDCE: specific signals
    i_cdce_pll_status : in  std_logic;  -- pll_status : This pin is set high if the PLL is in lock.
    o_cdce_n_reset    : out std_logic;  -- reset_n or hold_n
    o_cdce_n_pd       : out std_logic;  -- power_down_n
    o_ref_en          : out std_logic;  -- enable the primary reference clock

    -- ADC: SPI
    i_adc_sdo   : in  std_logic;        -- SPI MISO
    o_adc_n_en  : out std_logic;        -- SPI chip select
    -- ADC: specific signals
    o_adc_reset : out std_logic;        -- adc hardware reset

    -- DAC: SPI
    i_dac_sdo        : in  std_logic;   -- SPI MISO
    o_dac_n_en       : out std_logic;   -- SPI chip select
    -- DAC: specific signal
    o_dac_tx_present : out std_logic;   -- enable tx acquisition

    -- AMC: SPI (monitoring)
    i_mon_sdo     : in  std_logic;      -- SPI data out
    o_mon_n_en    : out std_logic;      -- SPI chip select
    -- AMC : specific signals
    i_mon_n_int   : in  std_logic;  -- galr_n: Global analog input out-of-range alarm.
    o_mon_n_reset : out std_logic;      -- reset_n: hardware reset

    ---------------------------------------------------------------------
    -- leds
    ---------------------------------------------------------------------
    o_leds : out std_logic_vector(3 downto 2)  -- status leds
    );
end entity system_fpasim_top;

architecture RTL of system_fpasim_top is

  --signal hardware_id : std_logic_vector(i_board_id'range);
  -- hardware id
  signal hardware_id : std_logic_vector(7 downto 0);

  ---------------------------------------------------------------------
  -- clock generation
  ---------------------------------------------------------------------
  signal adc_clk_div         : std_logic; -- divided adc clock
  signal sync_clk            : std_logic; -- sync clock (clk frame)
  signal dac_clk             : std_logic; -- dac clock with a 0° phase
  signal dac_clk_div         : std_logic; -- divided dac clock with a 0° phase
  signal dac_clk_phase90     : std_logic; -- dac clock with a 90° phase
  signal dac_clk_div_phase90 : std_logic; -- divided dac clock with a 90° phase
  signal sys_clk             : std_logic; -- system clock
  signal mmcm_locked         : std_logic; --  MMCM PLL locked flag

  ---------------------------------------------------------------------
  -- reset generation
  ---------------------------------------------------------------------
  signal sys_rst            : std_logic; -- software reset synchronized @sys_clk

  signal adc_io_clk_rst     : std_logic; -- adc clock reset for the adc_io module
  signal adc_io_rst         : std_logic; -- adc io reset for the adc_io module

  signal dac_io_clk_rst     : std_logic; -- dac clock reset for the dac_io module (data part)
  signal dac_io_rst         : std_logic; -- dac io reset for the dac_io module (data part)

  signal dac_io_rst_phase90 : std_logic; -- dac io reset for the dac_io module (clock part)

  signal sync_io_clk_rst    : std_logic; -- sync clock reset for the adc_io module
  signal sync_io_rst        : std_logic; -- sync io reset for the adc_io module

  ---------------------------------------------------------------------
  -- fpasim_top
  ---------------------------------------------------------------------
  -- common
  signal rst_status                      : std_logic;-- reset error flag(s) (usb_rst_out synchronized @sys_clk)
  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s) (usb_rst_out synchronized @sys_clk)
  signal debug_pulse                     : std_logic;
  -- spi
  signal usb_clk                         : std_logic; -- from the usb interface: clock
  signal usb_rst                         : std_logic; -- from the usb interface: reset
  signal usb_rst_out                     : std_logic; -- to the usb interface: reset
  signal usb_rst_status                  : std_logic; -- from the usb interface: reset error flag(s)
  -- from the usb interface: error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
  signal usb_debug_pulse                 : std_logic;
  -- tx
  signal spi_rst                         : std_logic; -- reset the spi bridge
  signal spi_en                          : std_logic; -- enable the spi bridge
  signal spi_cmd_valid                   : std_logic; -- spi command valid
  signal spi_dac_tx_present              : std_logic; -- enable dac tx acquisition (spi device pin)
  signal spi_mode                        : std_logic; -- spi mode: 1:wr, 0:rd
  signal spi_id                          : std_logic_vector(1 downto 0); -- spi identifier: "00":cdece,"01": adc,"10":dac,"11":amc
  signal spi_cmd_wr_data                 : std_logic_vector(31 downto 0); -- spi command to write on the spi device
  -- rx
  signal spi_rd_data_valid               : std_logic; -- spi read data valid
  signal spi_rd_data                     : std_logic_vector(31 downto 0);  -- spi read data (device spi register value)
  --signal spi_ready                       : std_logic;
  -- status: register
  signal reg_spi_status                  : std_logic_vector(31 downto 0); -- spi status (register format)
  -- errors/status
  signal spi_errors                      : std_logic_vector(15 downto 0); -- spi errors
  signal spi_status                      : std_logic_vector(7 downto 0); -- spi status
  -- adc
   -- common data_valid for adc_amp_squid_offset_correction/adc_mux_squid_feedback
  signal adc_valid                       : std_logic;
  signal adc_amp_squid_offset_correction : std_logic_vector(13 downto 0); -- adc amp_squid offset correction
  signal adc_mux_squid_feedback          : std_logic_vector(13 downto 0); -- adc mux_squid feedback
  signal adc_errors                      : std_logic_vector(15 downto 0); -- adc errors
  signal adc_status                      : std_logic_vector(7 downto 0); -- adc status

  -- sync
  signal sync_valid  : std_logic; -- sync valid
  signal sync        : std_logic; -- sync/clk frame
  signal sync_errors : std_logic_vector(15 downto 0); -- sync errors
  signal sync_status : std_logic_vector(7 downto 0); -- sync status

  -- dac
  signal dac_valid  : std_logic; -- dac data valid
  signal dac_frame  : std_logic; -- dac frame
  signal dac1       : std_logic_vector(15 downto 0); -- data for the dac1
  signal dac0       : std_logic_vector(15 downto 0); -- data for the dac0
  signal dac_errors : std_logic_vector(15 downto 0); -- dac errors
  signal dac_status : std_logic_vector(7 downto 0); -- dac status

  ---------------------------------------------------------------------
  -- ios
  ---------------------------------------------------------------------
  -- channel A: adc data
  signal adc_a : std_logic_vector(13 downto 0);
  -- channel B: adc data
  signal adc_b : std_logic_vector(13 downto 0);

  ---------------------------------------------------------------------
  -- spi
  ---------------------------------------------------------------------
  -- common: shared link between the spi
  signal spi_sclk  : std_logic;         -- Shared SPI clock line
  signal spi_sdata : std_logic;         -- Shared SPI MOSI

  -- CDCE: SPI
  signal cdce_n_en : std_logic;         -- SPI chip select

  -- CDCE: specific signals
  signal cdce_n_reset : std_logic;      -- reset_n or hold_n
  signal cdce_n_pd    : std_logic;      -- power_down_n
  signal ref_en       : std_logic;      -- enable the primary reference clock

  -- ADC: SPI
  signal adc_n_en  : std_logic;         -- SPI chip select
  -- ADC: specific signals
  signal adc_reset : std_logic;         -- adc hardware reset

  -- DAC: SPI
  signal dac_n_en       : std_logic;    -- SPI chip select
  -- DAC: specific signal
  signal dac_tx_present : std_logic;    -- enable tx acquisition

  -- AMC: SPI (monitoring)
  signal mon_n_en    : std_logic;       -- SPI chip select
  -- AMC : specific signals
  signal mon_n_reset : std_logic;       -- reset_n: hardware reset

  ---------------------------------------------------------------------
  -- leds
  ---------------------------------------------------------------------
  -- clock period counter
  signal count_pulse_r1 : unsigned(30 downto 0) := (others => '0');
  -- pulse signal
  signal pulse          : std_logic;

begin

  ---------------------------------------------------------------------
  -- clock generation
  ---------------------------------------------------------------------
  inst_clocking_top : entity work.clocking_top
    port map(
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_clk                 => adc_clk_div,      -- clock @62.5MHz
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_ref_clk             => sync_clk,  -- sync/ref output clock @62.5 MHz
      o_sys_clk             => sys_clk,   -- sys output clock @250 MHz
      o_dac_clk             => dac_clk,   -- dac output clock @500 MHz
      o_dac_clk_div         => dac_clk_div,      -- dac output clock @125 MHz
      o_dac_clk_phase90     => dac_clk_phase90,  -- dac output clock @500 MHz with 90° phase
      o_dac_clk_div_phase90 => dac_clk_div_phase90,  -- dac output clock @125 MHz with 90° phase
      o_locked              => mmcm_locked
      );

  ---------------------------------------------------------------------
  -- reset generation
  ---------------------------------------------------------------------
  inst_reset_top : entity work.reset_top
    port map(
      ---------------------------------------------------------------------
      -- from/to the usb
      ---------------------------------------------------------------------
      i_usb_clk             => usb_clk,
      i_usb_rst             => usb_rst,
      o_usb_rst             => usb_rst_out,
      ---------------------------------------------------------------------
      -- from/to the mmcm
      ---------------------------------------------------------------------
      i_sys_clk             => sys_clk,
      i_adc_clk_div         => adc_clk_div,
      i_dac_clk_div         => dac_clk_div,
      i_dac_clk_div_phase90 => dac_clk_div_phase90,
      i_sync_clk            => sync_clk,
      i_mmcm_locked         => mmcm_locked,
      ---------------------------------------------------------------------
      -- to the user
      ---------------------------------------------------------------------
      o_sys_rst             => sys_rst,
      ---------------------------------------------------------------------
      -- to the io_adc @i_adc_clk_div
      ---------------------------------------------------------------------
      o_adc_io_clk_rst      => adc_io_clk_rst,
      o_adc_io_rst          => adc_io_rst,
      ---------------------------------------------------------------------
      -- to the io_dac @i_dac_clk_div
      ---------------------------------------------------------------------
      o_dac_io_clk_rst      => dac_io_clk_rst,  -- not connected
      o_dac_io_rst          => dac_io_rst,
      ---------------------------------------------------------------------
      -- to the io_dac @i_dac_clk_div_phase90
      ---------------------------------------------------------------------
      o_dac_io_rst_phase90  => dac_io_rst_phase90,
      ---------------------------------------------------------------------
      -- to the io_sync @i_sync_clk
      ---------------------------------------------------------------------
      o_sync_io_clk_rst     => sync_io_clk_rst,
      o_sync_io_rst         => sync_io_rst
      );

  -- TODO: connect to input port
  --hardware_id <= i_hardware_id;
  hardware_id <= (others => '0');
  ---------------------------------------------------------------------
  -- top_fpasim
  ---------------------------------------------------------------------
  inst_fpasim_top : entity work.fpasim_top
    generic map(
      g_FPASIM_DEBUG        => pkg_FPASIM_TOP_DEBUG,
      g_REGDECODE_TOP_DEBUG => pkg_REGDECODE_TOP_DEBUG
      )
    port map(
      i_clk         => sys_clk,         -- system clock
      i_rst         => sys_rst,         -- reset sync @sync_clk
      ---------------------------------------------------------------------
      -- from the usb @i_usb_clk (clock included)
      ---------------------------------------------------------------------
      i_okUH        => i_okUH,
      o_okHU        => o_okHU,
      b_okUHU       => b_okUHU,
      b_okAA        => b_okAA,
      ---------------------------------------------------------------------
      -- from the board
      ---------------------------------------------------------------------
      i_hardware_id    => hardware_id,
      ---------------------------------------------------------------------
      -- to the IOs: @i_clk
      ---------------------------------------------------------------------
      o_rst_status  => rst_status,
      o_debug_pulse => debug_pulse,

      ---------------------------------------------------------------------
      -- from/to the spi: @usb_clk
      ---------------------------------------------------------------------
      o_usb_clk                         => usb_clk,
      o_usb_rst_status                  => usb_rst_status,
      o_usb_debug_pulse                 => usb_debug_pulse,
      --tx
      o_spi_rst                         => spi_rst,
      o_spi_en                          => spi_en,
      o_spi_dac_tx_present              => spi_dac_tx_present,
      o_spi_id                          => spi_id,
      o_spi_mode                        => spi_mode,
      -- command
      o_spi_cmd_valid                   => spi_cmd_valid,
      o_spi_cmd_wr_data                 => spi_cmd_wr_data,
      -- rx
      i_spi_rd_data_valid               => spi_rd_data_valid,
      i_spi_rd_data                     => spi_rd_data,
      i_reg_spi_status                  => reg_spi_status,
      --i_spi_ready                       => spi_ready,
      -- errors/status
      i_spi_errors                      => spi_errors,
      i_spi_status                      => spi_status,
      ---------------------------------------------------------------------
      -- from/to regdecode @usb_clk
      ---------------------------------------------------------------------
      o_usb_rst                         => usb_rst,
      i_usb_rst                         => usb_rst_out,
      ---------------------------------------------------------------------
      -- from adc @i_clk
      ---------------------------------------------------------------------
      i_adc_valid                       => adc_valid,
      i_adc_amp_squid_offset_correction => adc_amp_squid_offset_correction,
      i_adc_mux_squid_feedback          => adc_mux_squid_feedback,
      i_adc_errors                      => adc_errors,
      i_adc_status                      => adc_status,
      ---------------------------------------------------------------------
      -- output sync @i_clk
      ---------------------------------------------------------------------
      o_sync_valid                      => sync_valid,
      o_sync                            => sync,
      i_sync_errors                     => sync_errors,
      i_sync_status                     => sync_status,
      ---------------------------------------------------------------------
      -- output dac @i_clk
      ---------------------------------------------------------------------
      o_dac_valid                       => dac_valid,
      o_dac_frame                       => dac_frame,
      o_dac1                            => dac1,
      o_dac0                            => dac0,
      i_dac_errors                      => dac_errors,
      i_dac_status                      => dac_status
      );

  adc_amp_squid_offset_correction <= adc_b;
  adc_mux_squid_feedback          <= adc_a;

  ---------------------------------------------------------------------
  -- Xilinx IOs
  ---------------------------------------------------------------------
  inst_io_top : entity work.io_top
    port map(
      -- from the mmcm
      i_sys_clk             => sys_clk,
      i_sync_clk            => sync_clk,
      i_dac_clk             => dac_clk,
      i_dac_clk_div         => dac_clk_div,
      i_dac_clk_phase90     => dac_clk_phase90,
      i_dac_clk_div_phase90 => dac_clk_div_phase90,
      -- to mmcm
      o_adc_clk_div         => adc_clk_div,

      -- from the user: @i_sys_clk
      i_rst_status  => rst_status,
      i_debug_pulse => debug_pulse,

      ---------------------------------------------------------------------
      -- adc
      ---------------------------------------------------------------------
      -- from the reset_top: @i_adc_clk_div
      i_adc_io_clk_rst => adc_io_clk_rst,
      i_adc_io_rst     => adc_io_rst,
      -- from the fpga pads
      i_adc_clk_p      => i_adc_clk_p,
      i_adc_clk_n      => i_adc_clk_n,
      -- from fpga pads: adc_a  @i_adc_clk_p/n
      i_da0_p          => i_da0_p,
      i_da0_n          => i_da0_n,
      i_da2_p          => i_da2_p,
      i_da2_n          => i_da2_n,
      i_da4_p          => i_da4_p,
      i_da4_n          => i_da4_n,
      i_da6_p          => i_da6_p,
      i_da6_n          => i_da6_n,
      i_da8_p          => i_da8_p,
      i_da8_n          => i_da8_n,
      i_da10_p         => i_da10_p,
      i_da10_n         => i_da10_n,
      i_da12_p         => i_da12_p,
      i_da12_n         => i_da12_n,
      -- from fpga pads: adc_b @i_adc_clk_p/n
      i_db0_p          => i_db0_p,
      i_db0_n          => i_db0_n,
      i_db2_p          => i_db2_p,
      i_db2_n          => i_db2_n,
      i_db4_p          => i_db4_p,
      i_db4_n          => i_db4_n,
      i_db6_p          => i_db6_p,
      i_db6_n          => i_db6_n,
      i_db8_p          => i_db8_p,
      i_db8_n          => i_db8_n,
      i_db10_p         => i_db10_p,
      i_db10_n         => i_db10_n,
      i_db12_p         => i_db12_p,
      i_db12_n         => i_db12_n,

      -- to user: @i_sys_clk
      o_adc_valid       => adc_valid,
      o_adc_a           => adc_a,
      o_adc_b           => adc_b,
      o_adc_errors      => adc_errors,
      o_adc_status      => adc_status,
      ---------------------------------------------------------------------
      -- sync
      ---------------------------------------------------------------------
      -- from the reset_top: @sync_clk
      i_sync_io_clk_rst => sync_io_clk_rst,
      i_sync_io_rst     => sync_io_rst,

      -- from/to the user: @sys_clk
      i_sync_rst    => sys_rst,
      i_sync_valid  => sync_valid,
      i_sync        => sync,
      o_sync_errors => sync_errors,
      o_sync_status => sync_status,

      -- to the fpga pads: @sync_clk
      o_sync_clk   => o_ref_clk,
      o_sync       => o_sync,
      ---------------------------------------------------------------------
      -- dac
      ---------------------------------------------------------------------
      -- from the user
      i_dac_rst    => sys_rst,
      i_dac_valid  => dac_valid,
      i_dac_frame  => dac_frame,
      i_dac1       => dac1,
      i_dac0       => dac0,
      o_dac_errors => dac_errors,
      o_dac_status => dac_status,

      -- from the reset_top: @i_dac_clk_div
      i_dac_io_rst         => dac_io_rst,
      -- from the reset_top: @i_dac_clk_div_phase90
      i_dac_io_rst_phase90 => dac_io_rst_phase90,

      -- to the fpga pads: @i_dac_clk
      -- dac clock @i_dac_clk
      o_dac_clk_p   => o_dac_clk_p,
      o_dac_clk_n   => o_dac_clk_n,
      -- dac frame flag @i_dac_clk
      o_dac_frame_p => o_dac_frame_p,
      o_dac_frame_n => o_dac_frame_n,
      -- dac data @i_dac_clk
      o_dac0_p      => o_dac0_p,
      o_dac0_n      => o_dac0_n,
      o_dac1_p      => o_dac1_p,
      o_dac1_n      => o_dac1_n,
      o_dac2_p      => o_dac2_p,
      o_dac2_n      => o_dac2_n,
      o_dac3_p      => o_dac3_p,
      o_dac3_n      => o_dac3_n,
      o_dac4_p      => o_dac4_p,
      o_dac4_n      => o_dac4_n,
      o_dac5_p      => o_dac5_p,
      o_dac5_n      => o_dac5_n,
      o_dac6_p      => o_dac6_p,
      o_dac6_n      => o_dac6_n,
      o_dac7_p      => o_dac7_p,
      o_dac7_n      => o_dac7_n
      );

  ---------------------------------------------------------------------
  -- spi interface
  ---------------------------------------------------------------------
  inst_spi_top : entity work.spi_top
    generic map(
      g_DEBUG => pkg_SPI_TOP_DEBUG
      )
    port map(
      i_clk                => usb_clk,  -- clock
      i_rst                => spi_rst,  -- reset
      i_rst_status         => usb_rst_status,  -- reset error flag(s)
      i_debug_pulse        => usb_debug_pulse,  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
      ---------------------------------------------------------------------
      -- command
      ---------------------------------------------------------------------
      -- input
      i_spi_en             => spi_en,
      i_spi_dac_tx_present => spi_dac_tx_present,  -- 1:enable data tx, 0: otherwise
      i_spi_mode           => spi_mode,     -- 1:wr, 0:rd
      i_spi_id             => spi_id,  -- spi identifier: "00":cdece,"01": adc,"10":dac,"11":amc
      i_spi_cmd_valid      => spi_cmd_valid,   -- command valid
      i_spi_cmd_wr_data    => spi_cmd_wr_data,  -- data to write
      -- output
      o_spi_rd_data_valid  => spi_rd_data_valid,  -- read data valid
      o_spi_rd_data        => spi_rd_data,  -- read data
      o_spi_ready          => open,  -- 1: all spi links are ready,0: one of the spi link is busy
      o_reg_spi_status     => reg_spi_status,  -- 1: all spi links are ready,0: one of the spi link is busy
      ---------------------------------------------------------------------
      -- errors/status
      ---------------------------------------------------------------------
      o_errors             => spi_errors,
      o_status             => spi_status,
      ---------------------------------------------------------------------
      -- from/to the IOs
      ---------------------------------------------------------------------
      -- common: shared link between the spi
      o_spi_sclk           => spi_sclk,     -- Shared SPI clock line
      o_spi_sdata          => spi_sdata,    -- Shared SPI MOSI
      -- CDCE: SPI
      i_cdce_sdo           => i_cdce_sdo,   -- SPI MISO
      o_cdce_n_en          => cdce_n_en,    -- SPI chip select
      -- CDCE: specific signals
      i_cdce_pll_status    => i_cdce_pll_status,  -- pll_status : This pin is set high if the PLL is in lock.
      o_cdce_n_reset       => cdce_n_reset,    -- reset_n or hold_n
      o_cdce_n_pd          => cdce_n_pd,    -- power_down_n
      o_ref_en             => ref_en,   -- enable the primary reference clock
      -- ADC: SPI
      i_adc_sdo            => i_adc_sdo,    -- SPI MISO
      o_adc_n_en           => adc_n_en,     -- SPI chip select
      -- ADC: specific signals
      o_adc_reset          => adc_reset,    -- adc hardware reset
      -- DAC: SPI
      i_dac_sdo            => i_dac_sdo,    -- SPI MISO
      o_dac_n_en           => dac_n_en,     -- SPI chip select
      -- DAC: specific signal
      o_dac_tx_present     => dac_tx_present,  -- enable tx acquisition
      -- AMC: SPI (monitoring)
      i_mon_sdo            => i_mon_sdo,    -- SPI data out
      o_mon_n_en           => mon_n_en,     -- SPI chip select
      -- AMC : specific signals
      i_mon_n_int          => i_mon_n_int,  -- galr_n: Global analog input out-of-range alarm.
      o_mon_n_reset        => mon_n_reset   -- reset_n: hardware reset
      );

---------------------------------------------------------------------
-- output
---------------------------------------------------------------------
-- common: shared link between the spi
  o_spi_sclk     <= spi_sclk;           -- Shared SPI clock line
  o_spi_sdata    <= spi_sdata;          -- Shared SPI MOSI
--cdce
  o_cdce_n_en    <= cdce_n_en;          -- SPI chip select
  o_cdce_n_reset <= cdce_n_reset;       -- reset_n or hold_n
  o_cdce_n_pd    <= cdce_n_pd;          -- power_down_n
  o_ref_en       <= ref_en;             -- enable the primary reference clock

--adc
  o_adc_n_en  <= adc_n_en;              -- SPI chip select
  o_adc_reset <= adc_reset;             -- adc hardware reset

--dac
  o_dac_n_en       <= dac_n_en;         -- SPI chip select
  o_dac_tx_present <= dac_tx_present;   -- enable tx acquisition

--amc
  o_mon_n_en    <= mon_n_en;            -- SPI chip select
  o_mon_n_reset <= mon_n_reset;         -- reset_n: hardware reset

---------------------------------------------------------------------
-- leds
---------------------------------------------------------------------
  p_clock : process (adc_clk_div) is
  begin
    if rising_edge(adc_clk_div) then
      count_pulse_r1 <= count_pulse_r1 + 1;
    end if;
  end process p_clock;
  pulse <= count_pulse_r1(count_pulse_r1'high);

  o_leds(3) <= pulse;
  o_leds(2) <= mmcm_locked;
--o_leds(1) <= '0'; -- TODO: temporary used by o_sync
--o_leds(0) <= '0'; -- TODO: temporary used by o_ref_clk

---------------------------------------------------------------------
-- debug
---------------------------------------------------------------------
  gen_debug : if g_DEBUG = true generate
    signal count_r1 : unsigned(31 downto 0) := (others => '0');
    signal pulse_r1 : std_logic             := '0';


  begin

    ---------------------------------------------------------------------
    -- count the number of clock peridods
    ---------------------------------------------------------------------
    p_count : process (adc_clk_div) is
    begin
      if rising_edge(adc_clk_div) then
        count_r1 <= count_r1 + 1;
        pulse_r1 <= not(pulse_r1);
      end if;
    end process p_count;

    inst_system_fpasim_top_ila : entity work.system_fpasim_top_ila
      port map(
        clk                 => usb_clk,
        -- probe0
        probe0(32)          => pulse_r1,
        probe0(31 downto 0) => std_logic_vector(count_r1),

        -- probe1
        probe1(1) => usb_rst_out,
        probe1(0) => sys_rst
        );



  end generate gen_debug;

end architecture RTL;
