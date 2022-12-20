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
--!   @file                   pkg_spi.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
-- This package defines all constant used by the fpasim function. 
-- These constants configure the bus width of the differents functions.
--
-- Note: Frame and column are interchangeable
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;


package pkg_spi is

  -- user-defined : usb_clock frequency
  constant pkg_USB_SYSTEM_FREQUENCY_HZ : positive := 100_800_000;

  -------------------------------------------------------------------
  -- CDCE72010
  --   .see: https://www.analog.com/en/analog-dialogue/articles/introduction-to-spi-interface.html 
  -------------------------------------------------------------------
  -- user-defined : SPI clock polarity
  constant pkg_SPI_CDCE_CPOL                 : std_logic := '0';
  -- user-defined : SPI clock phase 
  constant pkg_SPI_CDCE_CPHA                 : std_logic := '0';
  -- auto-computed : input clock frequency of the module (expressed in Hz). (possible values: ]2*g_SPI_FREQUENCY_MAX_HZ: max_integer_value])
  constant pkg_SPI_CDCE_SYSTEM_FREQUENCY_HZ  : positive  := pkg_USB_SYSTEM_FREQUENCY_HZ;
  -- user-defined : spi output clock frequency to generate (expressed in Hz)
  constant pkg_SPI_CDCE_SPI_FREQUENCY_MAX_HZ : positive  := 15_000_000; -- 20 MHz max
  -- user-defined : Number of clock period for mosi signal delay from the internal state machine to the output (possible values [0;max_integer_value[)
  constant pkg_SPI_CDCE_MOSI_DELAY           : natural   := 0;
  -- user-defined : Number of clock period for miso signal delay from spi pin input to spi master input (possible values [0;max_integer_value[)
  constant pkg_SPI_CDCE_MISO_DELAY           : natural   := 0;

  -------------------------------------------------------------------
  -- ADC (ADS62p49)
  --   .see: https://www.analog.com/en/analog-dialogue/articles/introduction-to-spi-interface.html 
  -------------------------------------------------------------------
  -- user-defined : SPI clock polarity
  constant pkg_SPI_ADC_CPOL                 : std_logic := '1';
  -- user-defined : SPI clock phase
  constant pkg_SPI_ADC_CPHA                 : std_logic := '1';
  -- auto-computed : input clock frequency of the module (expressed in Hz). (possible values: ]2*g_SPI_FREQUENCY_MAX_HZ: max_integer_value])
  constant pkg_SPI_ADC_SYSTEM_FREQUENCY_HZ  : positive  := pkg_USB_SYSTEM_FREQUENCY_HZ;
  -- user-defined : spi output clock frequency to generate (expressed in Hz)
  constant pkg_SPI_ADC_SPI_FREQUENCY_MAX_HZ : positive  := 15_000_000; -- 20 MHz max
  -- user-defined : Number of clock period for mosi signal delay from the internal state machine to the output (possible values [0;max_integer_value[)
  constant pkg_SPI_ADC_MOSI_DELAY           : natural   := 0;
  -- user-defined : Number of clock period for miso signal delay from spi pin input to spi master input (possible values [0;max_integer_value[)
  constant pkg_SPI_ADC_MISO_DELAY           : natural   := 0;


  -------------------------------------------------------------------
  -- DAC3283
  --   .see: https://www.analog.com/en/analog-dialogue/articles/introduction-to-spi-interface.html 
  -------------------------------------------------------------------
  -- user-defined : SPI clock polarity
  constant pkg_SPI_DAC_CPOL                 : std_logic := '0';
  -- user-defined : SPI clock phase
  constant pkg_SPI_DAC_CPHA                 : std_logic := '0';
  -- auto-computed : input clock frequency of the module (expressed in Hz). (possible values: ]2*g_SPI_FREQUENCY_MAX_HZ: max_integer_value])
  constant pkg_SPI_DAC_SYSTEM_FREQUENCY_HZ  : positive  := pkg_USB_SYSTEM_FREQUENCY_HZ;
  -- user-defined : spi output clock frequency to generate (expressed in Hz)
  constant pkg_SPI_DAC_SPI_FREQUENCY_MAX_HZ : positive  := 5_000_000; -- 10 MHz max
  -- user-defined : Number of clock period for mosi signal delay from the internal state machine to the output (possible values [0;max_integer_value[)
  constant pkg_SPI_DAC_MOSI_DELAY           : natural   := 0;
  -- user-defined : Number of clock period for miso signal delay from spi pin input to spi master input (possible values [0;max_integer_value[)
  constant pkg_SPI_DAC_MISO_DELAY           : natural   := 0;

  -------------------------------------------------------------------
  -- AMC7823
  --   .see: https://www.analog.com/en/analog-dialogue/articles/introduction-to-spi-interface.html 
  -------------------------------------------------------------------
  -- user-defined : SPI clock polarity
  constant pkg_SPI_AMC_CPOL                 : std_logic := '0';
  -- user-defined : SPI clock phase
  constant pkg_SPI_AMC_CPHA                 : std_logic := '1';
  -- auto-computed : input clock frequency of the module (expressed in Hz). (possible values: ]2*g_SPI_FREQUENCY_MAX_HZ: max_integer_value])
  constant pkg_SPI_AMC_SYSTEM_FREQUENCY_HZ  : positive  := pkg_USB_SYSTEM_FREQUENCY_HZ;
  -- user-defined : spi output clock frequency to generate (expressed in Hz)
  constant pkg_SPI_AMC_SPI_FREQUENCY_MAX_HZ : positive  := 6_000_000; -- 12 MHz max
  -- user-defined : Number of clock period for mosi signal delay from the internal state machine to the output (possible values [0;max_integer_value[)
  constant pkg_SPI_AMC_MOSI_DELAY           : natural   := 0;
  -- user-defined : Number of clock period for miso signal delay from spi pin input to spi master input (possible values [0;max_integer_value[)
  constant pkg_SPI_AMC_MISO_DELAY           : natural   := 0;


end pkg_spi;

