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
--    @file                   spi_dac3283.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This module provides a spi link in order to configure the dac3283 of the FMC150 board of abaco system.
--    The specific additional pins of the device are also configured.
--
--    Note:
--     . The user must build the full SPI words (typically: addr + data)
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.pkg_spi.all;

entity spi_dac3283 is
  generic (
    g_DATA_WIDTH       : natural := 16; -- data width (expressed in bits)
    g_TX_PRESENT_DELAY : natural := 0   -- delay on the tx_present signal (expressed in clock cycle).Possible values : [0; max integer range[
    );
  port (
    i_clk : in std_logic;  -- clock
    i_rst : in std_logic;  -- reset

    ---------------------------------------------------------------------
    -- command
    ---------------------------------------------------------------------
    -- input
    i_spi_dac_tx_present: in  std_logic; -- 1:wr, 0:rd
    i_spi_mode          : in  std_logic;  -- 1:wr, 0:rd
    i_spi_cmd_valid     : in  std_logic;  -- command valid
    i_spi_cmd_wr_data   : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0);  -- data to write
    -- output
    o_spi_rd_data_valid : out std_logic;  -- read data valid
    o_spi_rd_data       : out std_logic_vector(g_DATA_WIDTH - 1 downto 0);  -- read data
    o_spi_ready         : out std_logic;  -- 1: the spi link is ready,0: the spi link is busy
    o_spi_finish        : out std_logic;  -- the reading or writting on the spi link is completed (pulse)

    ---------------------------------------------------------------------
    -- from/to IOs @o_spi_clk
    ---------------------------------------------------------------------
    -- spi
    i_dac_sdo   : in  std_logic; -- SPI MISO
    o_spi_sclk  : out std_logic; -- SPI clock
    o_dac_n_en  : out std_logic; -- SPI chip select
    o_spi_sdata : out std_logic; -- SPI MOSI

    -- specifi signals
    o_dac_tx_present : out std_logic    -- enable dac acquisition (device pin)

    );
end entity spi_dac3283;

architecture RTL of spi_dac3283 is

---------------------------------------------------------------------
-- spi
---------------------------------------------------------------------
  signal spi_ready     : std_logic; -- spi bridge: ready
  signal spi_finish    : std_logic; -- spi bridge: finish
  signal rx_data_valid : std_logic; -- read data valid
  signal rx_data       : std_logic_vector(o_spi_rd_data'range); -- read data

  signal spi_mosi : std_logic; -- spi: mosi
  signal spi_cs_n : std_logic; -- spi: chip select
  signal spi_clk  : std_logic; -- spi: clock

  ---------------------------------------------------------------------
  -- optional: pipe
  ---------------------------------------------------------------------
  -- temporary input pipe
  signal data_pipe_tmp0  : std_logic_vector(0 downto 0);
  -- temporary output pipe
  signal data_pipe_tmp1  : std_logic_vector(0 downto 0);
  -- enable dac acquisition
  signal dac_tx_present1 : std_logic;

begin

---------------------------------------------------------------------
-- spi master
---------------------------------------------------------------------
  inst_spi_master : entity work.spi_master
    generic map(
      g_CPOL                 => pkg_SPI_DAC_CPOL,        -- clock polarity
      g_CPHA                 => pkg_SPI_DAC_CPHA,        -- clock phase
      g_SYSTEM_FREQUENCY_HZ  => pkg_SPI_DAC_SYSTEM_FREQUENCY_HZ,  -- input system clock frequency  (expressed in Hz). The range is ]2*g_SPI_FREQUENCY_MAX_HZ: max_integer_value]
      g_SPI_FREQUENCY_MAX_HZ => pkg_SPI_DAC_SPI_FREQUENCY_MAX_HZ,  -- output max spi clock frequency (expressed in Hz)
      g_MOSI_DELAY           => pkg_SPI_DAC_MOSI_DELAY,  -- Number of clock period for mosi signal delay from state machine to the output
      g_MISO_DELAY           => pkg_SPI_DAC_MISO_DELAY,  -- Number of clock period for miso signal delay from spi pin input to spi master input
      g_DATA_WIDTH           => i_spi_cmd_wr_data'length  -- Data bus size
      )
    port map(
      i_clk           => i_clk, -- Clock
      i_rst           => i_rst, -- Reset
      -- write side
      i_wr_rd         => i_spi_mode,    -- 1:wr , 0:rd
      i_tx_msb_first  => '1',  -- 1: MSB bits sent first, 0: LSB bits sent first
      i_tx_data_valid => i_spi_cmd_valid,  -- Start transmit ('0' = Inactive, '1' = Active)
      i_tx_data       => i_spi_cmd_wr_data,  -- Data to transmit (stall on MSB)
      o_ready         => spi_ready,  -- Transmit link busy ('0' = Busy, '1' = Not Busy)
      o_finish        => spi_finish,    -- pulse wr finish
      -- rd side
      o_rx_data_valid => rx_data_valid,    -- received data valid
      o_rx_data       => rx_data,       -- received data
      ---------------------------------------------------------------------
      -- spi interface
      ---------------------------------------------------------------------
      i_miso          => i_dac_sdo,  -- SPI MISO (Master Input - Slave Output)
      o_sclk          => spi_clk,    -- SPI Serial Clock
      o_cs_n          => spi_cs_n,  -- SPI Chip Select ('0' = Active, '1' = Inactive)
      o_mosi          => spi_mosi   -- SPI MOSI (Master Output - Slave Input)
      );

  ---------------------------------------------------------------------
  -- optional: pipe
  ---------------------------------------------------------------------
  data_pipe_tmp0(0) <= i_spi_dac_tx_present;
  inst_pipeliner_tx : entity work.pipeliner
    generic map(
      g_NB_PIPES   => g_TX_PRESENT_DELAY,
      g_DATA_WIDTH => data_pipe_tmp0'length
      )
    port map(
      i_clk  => i_clk,
      i_data => data_pipe_tmp0,
      o_data => data_pipe_tmp1
      );
  dac_tx_present1 <= data_pipe_tmp1(0);

  ---------------------------------------------------------------------
  -- output: to the user
  ---------------------------------------------------------------------
  o_spi_rd_data_valid <= rx_data_valid;
  o_spi_rd_data       <= rx_data;
  o_spi_ready         <= spi_ready;
  o_spi_finish        <= spi_finish;

  ---------------------------------------------------------------------
  -- output: to the IOs
  ---------------------------------------------------------------------
  -- spi
  o_spi_sclk  <= spi_clk;  -- SPI Serial Clock
  o_dac_n_en  <= spi_cs_n;  -- SPI Chip Select ('0' = Active, '1' = Inactive)
  o_spi_sdata <= spi_mosi;  -- SPI MOSI (Master Output - Slave Input)

  -- specific signals
  o_dac_tx_present <= dac_tx_present1;

end architecture RTL;
