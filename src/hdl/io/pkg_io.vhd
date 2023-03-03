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
--    @file                   pkg_io.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details                
--    This package defines all constant used by the io_top function. 
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.math_real.all;

use work.pkg_utils;

package pkg_io is
  ---------------------------------------------------------------------
  -- SPI Device
  ---------------------------------------------------------------------
  -- hardcoded : latency of the "ads62p49" ADC (see datasheet page 11) @250 MHz
  constant pkg_SPI_ADC62P49_LATENCY : natural := 22 + 1;
  -- hardcoded : latency of the "dac3283" (see datasheet page 8): 1x interpolation @250MHz? or @500 MHz?
  constant pkg_SPI_DAC3283_LATENCY  : natural := 59;


  -------------------------------------------------------------------
  -- IOs: ADC
  -------------------------------------------------------------------

  -- user-defined: add latency after the input IOs. Possible values: [0;max integer value[
  constant pkg_IO_ADC_IN_LATENCY        : natural := 1;
  -- user-defined: Number of cdc stage of the cross clock domain FIFO. [2 - 8]. Must be <5 if FIFO_WRITE_DEPTH = 16
  constant pkg_IO_ADC_FIFO_CDC_STAGE    : natural := 2;
  -- user-defined: Read FIFO latency. Possible values : [1, max integer value[
  constant pkg_IO_ADC_FIFO_READ_LATENCY : natural := 2;
  -- auto-computed: Estimation of the FIFO latency (rough estimation: because of different frequencies)
  constant pkg_IO_ADC_FIFO              : natural := pkg_IO_ADC_FIFO_CDC_STAGE + pkg_IO_ADC_FIFO_READ_LATENCY;
  -- auto-computed: latency of the io_adc module (rough estimation: because of different frequencies)
  constant pkg_IO_ADC_LATENCY           : natural := pkg_IO_ADC_IN_LATENCY + pkg_IO_ADC_FIFO;

  -------------------------------------------------------------------
  -- IOs: DAC
  -- to align the o_dac_frame_p port with the o_sync port => pkg_IO_DAC_OUT_LATENCY = pkg_IO_SYNC_OUT_LATENCY + 6;
  -------------------------------------------------------------------
  -- user-defined: Number of cdc stage of the cross clock domain FIFO. [2 - 8]. Must be <5 if FIFO_WRITE_DEPTH = 16
  constant pkg_IO_DAC_FIFO_CDC_STAGE      : natural := 2;
  -- user-defined: Read FIFO latency. Possible values : [1, max integer value[
  constant pkg_IO_DAC_FIFO_READ_LATENCY   : natural := 1;
  -- auto-computed: Estimation of the FIFO latency (rough estimation: because of different frequencies)
  constant pkg_IO_DAC_FIFO                : natural := pkg_IO_DAC_FIFO_CDC_STAGE + pkg_IO_DAC_FIFO_READ_LATENCY;
  -- auto-computed: latency of the io_dac_data_insert module
  constant pkg_IO_DAC_DATA_INSERT_LATENCY : natural := pkg_IO_DAC_FIFO;
  -- user-defined: add latency before the output IOs. Possible values: [0;max integer value[
  constant pkg_IO_DAC_OUT_LATENCY         : natural := 1 + 6; -- 
  -- auto-computed: latency of the io_dac module
  constant pkg_IO_DAC_LATENCY             : natural := pkg_IO_DAC_DATA_INSERT_LATENCY + pkg_IO_DAC_OUT_LATENCY;  -- fifo CDC + fifo read latency

  -------------------------------------------------------------------
  -- IOs: SYNC
  -- to align the o_dac_frame_p port with the o_sync port => pkg_IO_DAC_OUT_LATENCY = pkg_IO_SYNC_OUT_LATENCY + 6;
  -------------------------------------------------------------------
  -- user-defined: Number of cdc stage of the cross clock domain FIFO. [2 - 8]. Must be <5 if FIFO_WRITE_DEPTH = 16
  constant pkg_IO_SYNC_FIFO_CDC_STAGE    : natural := 2;
  -- user-defined: Read FIFO latency. Possible values : [1, max integer value[
  constant pkg_IO_SYNC_FIFO_READ_LATENCY : natural := 1;
  -- auto-computed: Estimation of the FIFO latency (rough estimation: because of different frequencies)
  constant pkg_IO_SYNC_FIFO              : natural := pkg_IO_SYNC_FIFO_CDC_STAGE + pkg_IO_SYNC_FIFO_READ_LATENCY;
  -- user-defined: add latency before the output IOs. Possible values: [0;max integer value[
  constant pkg_IO_SYNC_OUT_LATENCY       : natural := 1;
  -- auto-computed: latency of the IO_SYNC module
  constant pkg_IO_SYNC_LATENCY           : natural := pkg_IO_SYNC_FIFO + pkg_IO_SYNC_OUT_LATENCY;


end pkg_io;

