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
--                              but WITHOUT ANY WARRANTY; without even the implied warranty ofh
--                              MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--                              GNU General Public License for more details.
--
--                              You should have received a copy of the GNU General Public License
--                              along with this program.  If not, see <https://www.gnu.org/licenses/>.
-- -------------------------------------------------------------------------------------------------------------
--    email                   kenji.delarosa@alten.com
--    @file                   spi_top.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details                
-- 
--    This module distributes spi commands to the different devices of the FMC150 board (abaco system)
--    In particular, it manages the shared spi links (o_spi_sclk and o_spi_sdata) between the different devices.
--    
--    Note: 
--     . For the different devices, the user must build the corresponding full SPI words (typically: addr + data).
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity spi_top is
  generic (
    g_DEBUG : boolean := false
    );
  port (
    i_clk         : in std_logic;       -- clock
    i_rst         : in std_logic;       -- reset
    i_rst_status  : in std_logic;       -- reset error flag(s)
    i_debug_pulse : in std_logic;  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)

    ---------------------------------------------------------------------
    -- command
    ---------------------------------------------------------------------
    -- input
    i_spi_en             : in  std_logic;  -- enable the spi
    i_spi_dac_tx_present : in  std_logic;  -- 1:enable dac data tx, 0: otherwise
    i_spi_mode           : in  std_logic;  -- 1:wr, 0:rd
    i_spi_id             : in  std_logic_vector(1 downto 0);  -- spi identifier: "00":cdece,"01": adc,"10":dac,"11":amc
    i_spi_cmd_valid      : in  std_logic;  -- command valid
    i_spi_cmd_wr_data    : in  std_logic_vector(31 downto 0);  -- data to write
    -- output
    o_spi_rd_data_valid  : out std_logic;  -- read data valid
    o_spi_rd_data        : out std_logic_vector(31 downto 0);  -- read data
    o_spi_ready          : out std_logic;  -- 1: all spi links are ready,0: one of the spi link is busy

    o_reg_spi_status : out std_logic_vector(31 downto 0);
    ---------------------------------------------------------------------
    -- errors/status
    ---------------------------------------------------------------------
    o_errors         : out std_logic_vector(15 downto 0);
    o_status         : out std_logic_vector(7 downto 0);

    ---------------------------------------------------------------------
    -- from/to the IOs
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
    o_mon_n_reset : out std_logic       -- reset_n: hardware reset

    );
end entity spi_top;

architecture RTL of spi_top is

---------------------------------------------------------------------
-- spi_io
---------------------------------------------------------------------
-- spi:common
  signal io_spi_sclk       : std_logic;
  signal io_spi_sdata      : std_logic;
-- cdce
  signal io_cdce_n_en      : std_logic;
-- cdce: specific
  signal io_cdce_n_reset   : std_logic;
  signal io_cdce_n_pd      : std_logic;
  signal io_ref_en         : std_logic;
-- adc
  signal io_adc_n_en       : std_logic;
-- adc: specific
  signal io_adc_reset      : std_logic;
-- dac
  signal io_dac_n_en       : std_logic;
-- dac: specific
  signal io_dac_tx_present : std_logic;
-- amc
  signal io_mon_n_en       : std_logic;
-- amc: specific
  signal io_mon_n_reset    : std_logic;

---------------------------------------------------------------------
-- spi_device_select
---------------------------------------------------------------------
-- command
  signal spi_rd_data_valid : std_logic;
  signal spi_rd_data       : std_logic_vector(o_spi_rd_data'range);
  signal spi_ready         : std_logic;
-- status
  signal reg_spi_status    : std_logic_vector(o_reg_spi_status'range);
  signal errors            : std_logic_vector(o_errors'range);
  signal status            : std_logic_vector(o_status'range);

-- spi:common
  signal spi_sclk        : std_logic;
  signal spi_sdata       : std_logic;
-- cdce
  signal cdce_n_en       : std_logic;
  signal cdce_sdo        : std_logic;
-- cdce: specific
  signal cdce_pll_status : std_logic;
  signal cdce_n_reset    : std_logic;
  signal cdce_n_pd       : std_logic;
  signal ref_en          : std_logic;
-- adc
  signal adc_sdo         : std_logic;
  signal adc_n_en        : std_logic;
-- adc: specific
  signal adc_reset       : std_logic;
-- dac
  signal dac_sdo         : std_logic;
  signal dac_n_en        : std_logic;
-- dac: specific
  signal dac_tx_present  : std_logic;
-- amc
  signal mon_sdo         : std_logic;
  signal mon_n_en        : std_logic;
-- amc: specific
  signal mon_n_int       : std_logic;
  signal mon_n_reset     : std_logic;



begin


  inst_spi_io : entity work.spi_io
    port map(
      i_clk             => i_clk,
      i_io_rst          => '0',
      ---------------------------------------------------------------------
      -- from/to the pads
      ---------------------------------------------------------------------
      -- common: shared link between the spi
      o_spi_sclk        => io_spi_sclk,  -- Shared SPI clock line
      o_spi_sdata       => io_spi_sdata,     -- Shared SPI MOSI
      -- CDCE: SPI
      i_cdce_sdo        => i_cdce_sdo,  -- SPI MISO
      o_cdce_n_en       => io_cdce_n_en,     -- SPI chip select
      -- CDCE: specific signals
      i_cdce_pll_status => i_cdce_pll_status,  -- pll_status : This pin is set high if the PLL is in lock.
      o_cdce_n_reset    => io_cdce_n_reset,  -- reset_n or hold_n
      o_cdce_n_pd       => io_cdce_n_pd,     -- power_down_n
      o_ref_en          => io_ref_en,   -- enable the primary reference clock
      -- ADC: SPI
      i_adc_sdo         => i_adc_sdo,   -- SPI MISO
      o_adc_n_en        => io_adc_n_en,  -- SPI chip select
      -- ADC: specific signals
      o_adc_reset       => io_adc_reset,     -- adc hardware reset
      -- DAC: SPI
      i_dac_sdo         => i_dac_sdo,   -- SPI MISO
      o_dac_n_en        => io_dac_n_en,  -- SPI chip select
      -- DAC: specific signal
      o_dac_tx_present  => io_dac_tx_present,  -- enable tx acquisition
      -- AMC: SPI (monitoring)
      i_mon_sdo         => i_mon_sdo,   -- SPI data out
      o_mon_n_en        => io_mon_n_en,  -- SPI chip select
      -- AMC : specific signals
      i_mon_n_int       => i_mon_n_int,  -- galr_n: Global analog input out-of-range alarm.
      o_mon_n_reset     => io_mon_n_reset,
      ---------------------------------------------------------------------
      -- from/to the user
      ---------------------------------------------------------------------
      -- common: shared link between the spi
      i_spi_sclk        => spi_sclk,    -- Shared SPI clock line
      i_spi_sdata       => spi_sdata,   -- Shared SPI MOSI
      -- CDCE: SPI
      o_cdce_sdo        => cdce_sdo,    -- SPI MISO
      i_cdce_n_en       => cdce_n_en,   -- SPI chip select
      -- CDCE: specific signals
      o_cdce_pll_status => cdce_pll_status,  -- pll_status : This pin is set high if the PLL is in lock.
      i_cdce_n_reset    => cdce_n_reset,     -- reset_n or hold_n
      i_cdce_n_pd       => cdce_n_pd,   -- power_down_n
      i_ref_en          => ref_en,      -- enable the primary reference clock
      -- ADC: SPI
      o_adc_sdo         => adc_sdo,     -- SPI MISO
      i_adc_n_en        => adc_n_en,    -- SPI chip select
      -- ADC: specific signals
      i_adc_reset       => adc_reset,   -- adc hardware reset
      -- DAC: SPI
      o_dac_sdo         => dac_sdo,     -- SPI MISO
      i_dac_n_en        => dac_n_en,    -- SPI chip select
      -- DAC: specific signal
      i_dac_tx_present  => dac_tx_present,   -- enable tx acquisition
      -- AMC: SPI (monitoring)
      o_mon_sdo         => mon_sdo,     -- SPI data out
      i_mon_n_en        => mon_n_en,    -- SPI chip select
      -- AMC : specific signals
      o_mon_n_int       => mon_n_int,  -- galr_n: Global analog input out-of-range alarm.
      i_mon_n_reset     => mon_n_reset

      );



---------------------------------------------------------------------
-- spi_device_select
---------------------------------------------------------------------
  inst_spi_device_select : entity work.spi_device_select
    generic map(
      g_DEBUG => g_DEBUG
      )
    port map(
      i_clk                => i_clk,    -- clock
      i_rst                => i_rst,    -- reset
      i_rst_status         => i_rst_status,   -- reset error flag(s)
      i_debug_pulse        => i_debug_pulse,  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
      ---------------------------------------------------------------------
      -- command
      ---------------------------------------------------------------------
      -- input
      i_spi_en             => i_spi_en,  -- enable the spi
      i_spi_dac_tx_present => i_spi_dac_tx_present,  -- 1:enable dac data tx, 0: otherwise
      i_spi_mode           => i_spi_mode,     -- 1:wr, 0:rd
      i_spi_id             => i_spi_id,  -- spi identifier: "00":cdece,"01": adc,"10":dac,"11":amc
      i_spi_cmd_valid      => i_spi_cmd_valid,  -- command valid
      i_spi_cmd_wr_data    => i_spi_cmd_wr_data,     -- data to write
      -- output
      o_spi_rd_data_valid  => spi_rd_data_valid,     -- read data valid
      o_spi_rd_data        => spi_rd_data,    -- read data
      o_spi_ready          => spi_ready,  -- 1: all spi links are ready,0: one of the spi link is busy
      o_reg_spi_status     => reg_spi_status,
      ---------------------------------------------------------------------
      -- errors/status
      ---------------------------------------------------------------------
      o_errors             => errors,
      o_status             => status,
      ---------------------------------------------------------------------
      -- from/to the IOs
      ---------------------------------------------------------------------
      -- common: shared link between the spi
      o_spi_sclk           => spi_sclk,  -- Shared SPI clock line
      o_spi_sdata          => spi_sdata,  -- Shared SPI MOSI
      -- CDCE: SPI
      i_cdce_sdo           => cdce_sdo,  -- SPI MISO
      o_cdce_n_en          => cdce_n_en,  -- SPI chip select
      -- CDCE: specific signals
      i_cdce_pll_status    => cdce_pll_status,  -- pll_status : This pin is set high if the PLL is in lock.
      o_cdce_n_reset       => cdce_n_reset,   -- reset_n or hold_n
      o_cdce_n_pd          => cdce_n_pd,  -- power_down_n
      o_ref_en             => ref_en,   -- enable the primary reference clock
      -- ADC: SPI
      i_adc_sdo            => adc_sdo,  -- SPI MISO
      o_adc_n_en           => adc_n_en,  -- SPI chip select
      -- ADC: specific signals
      o_adc_reset          => adc_reset,  -- adc hardware reset
      -- DAC: SPI
      i_dac_sdo            => dac_sdo,  -- SPI MISO
      o_dac_n_en           => dac_n_en,  -- SPI chip select
      -- DAC: specific signal
      o_dac_tx_present     => dac_tx_present,   -- enable tx acquisition
      -- AMC: SPI (monitoring)
      i_mon_sdo            => mon_sdo,  -- SPI data out
      o_mon_n_en           => mon_n_en,  -- SPI chip select
      -- AMC : specific signals
      i_mon_n_int          => mon_n_int,  -- galr_n: Global analog input out-of-range alarm.
      o_mon_n_reset        => mon_n_reset     -- reset_n: hardware reset
      );


---------------------------------------------------------------------
-- output
---------------------------------------------------------------------
  o_spi_rd_data_valid <= spi_rd_data_valid;
  o_spi_rd_data       <= spi_rd_data;
  o_spi_ready         <= spi_ready;
  o_reg_spi_status    <= reg_spi_status;

  o_errors         <= errors;
  o_status         <= status;
-- spi:common
  o_spi_sclk       <= io_spi_sclk;
  o_spi_sdata      <= io_spi_sdata;
-- cdce
  o_cdce_n_en      <= io_cdce_n_en;
-- cdce: specific
  o_cdce_n_reset   <= io_cdce_n_reset;
  o_cdce_n_pd      <= io_cdce_n_pd;
  o_ref_en         <= io_ref_en;
-- adc
  o_adc_n_en       <= io_adc_n_en;
-- adc: specific
  o_adc_reset      <= io_adc_reset;
-- dac
  o_dac_n_en       <= io_dac_n_en;
-- dac: specific
  o_dac_tx_present <= io_dac_tx_present;
-- amc
  o_mon_n_en       <= io_mon_n_en;
-- amc: specific
  o_mon_n_reset    <= io_mon_n_reset;

end architecture RTL;
