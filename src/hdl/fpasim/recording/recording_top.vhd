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
--!   @file                   recording_top.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--
-- This module is the top level of the recording functionnality
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_fpasim.all;


entity recording_top is
  generic (
    g_ADC_FIFO_OUT_DEPTH : integer := pkg_REC_ADC_FIFO_OUT_DEPTH  -- depth of the FIFO (number of words). Must be a power of 2
    );
  port (
    i_rst         : in std_logic;       -- input reset
    i_clk         : in std_logic;       -- input clock
    i_rst_status  : in std_logic;       -- reset error flag(s)
    i_debug_pulse : in std_logic;  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)

    ---------------------------------------------------------------------
    -- input
    ---------------------------------------------------------------------
    -- from regdecode
    i_adc_cmd_start             : in std_logic;  -- '1': start the acquisition of a data block, '0': do nothing
    i_adc_cmd_nb_words_by_block : in std_logic_vector(15 downto 0);  -- number of output words

    -- from adcs
    i_adc_data_valid : in  std_logic;   -- data valid
    i_adc_data1      : in  std_logic_vector(13 downto 0);  -- data1 value
    i_adc_data0      : in  std_logic_vector(13 downto 0);  -- data0 value
    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    i_fifo_adc_rd         : in  std_logic;   -- read fifo
    o_fifo_adc_data_valid : out std_logic;   -- output data valid
    o_fifo_adc_sof        : out std_logic;   -- first word of a block
    o_fifo_adc_eof        : out std_logic;   -- last word of a block
    o_fifo_adc_data       : out std_logic_vector(31 downto 0);  -- output data value
    o_fifo_adc_empty      : out std_logic;   -- fifo empty flag

    -----------------------------------------------------------------
    -- errors/status
    -----------------------------------------------------------------
    o_adc_errors : out std_logic_vector(15 downto 0);  -- output errors
    o_adc_status : out std_logic_vector(7 downto 0)    -- output status

    );
end entity recording_top;

architecture RTL of recording_top is

---------------------------------------------------------------------
-- recording_adc
---------------------------------------------------------------------
  signal adc_data0 : std_logic_vector(15 downto 0);
  signal adc_data1 : std_logic_vector(15 downto 0);

  signal fifo_adc_data_valid : std_logic;
  signal fifo_adc_sof        : std_logic;
  signal fifo_adc_eof        : std_logic;
  signal fifo_adc_data       : std_logic_vector(o_fifo_adc_data'range);
  signal fifo_adc_empty      : std_logic;
  signal adc_errors          : std_logic_vector(o_adc_errors'range);
  signal adc_status          : std_logic_vector(o_adc_status'range);

begin

  ---------------------------------------------------------------------
  -- recording_adc
  ---------------------------------------------------------------------
  -- resize vector (signed): 14 bits -> 16 bits

  adc_data0 <= std_logic_vector(resize(signed(i_adc_data0), adc_data0'length));
  adc_data1 <= std_logic_vector(resize(signed(i_adc_data1), adc_data1'length));

  inst_recording_adc : entity work.recording_adc
    generic map(
      g_ADC_FIFO_OUT_DEPTH => g_ADC_FIFO_OUT_DEPTH  -- depth of the FIFO (number of words). Must be a power of 2
      )
    port map(
      i_rst                       => i_rst,         -- input reset
      i_clk                       => i_clk,         -- input clock
      i_rst_status                => i_rst_status,  -- reset error flag(s)
      i_debug_pulse               => i_debug_pulse,  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      -- from regdecode
      i_adc_cmd_start             => i_adc_cmd_start,  -- '1': start the acquisition of a data block, '0': do nothing
      i_adc_cmd_nb_words_by_block => i_adc_cmd_nb_words_by_block,  -- number of output words
                                                                   -- from adcs
      i_adc_data_valid            => i_adc_data_valid,  -- data valid
      i_adc_data1                 => adc_data1,     -- data1 value
      i_adc_data0                 => adc_data0,     -- data0 value
      ---------------------------------------------------------------------
      -- output @out_clk
      ---------------------------------------------------------------------
      i_fifo_adc_rd                    => i_fifo_adc_rd,      -- read fifo
      o_fifo_adc_sof                   => fifo_adc_sof,       -- first word of a block
      o_fifo_adc_eof                   => fifo_adc_eof,       -- last word of a block
      o_fifo_adc_data_valid            => fifo_adc_data_valid,   -- output data valid
      o_fifo_adc_data                  => fifo_adc_data,      -- output data value
      o_fifo_adc_empty                 => fifo_adc_empty,     -- fifo empty flag
      -----------------------------------------------------------------
      -- errors/status
      -----------------------------------------------------------------
      o_adc_errors                => adc_errors,    -- output errors
      o_adc_status                => adc_status     -- output status
      );

---------------------------------------------------------------------
-- output
---------------------------------------------------------------------
  o_fifo_adc_sof        <= fifo_adc_sof;
  o_fifo_adc_eof        <= fifo_adc_eof;
  o_fifo_adc_data_valid <= fifo_adc_data_valid;
  o_fifo_adc_data       <= fifo_adc_data;
  o_fifo_adc_empty      <= fifo_adc_empty;

---------------------------------------------------------------------
-- errors/status
---------------------------------------------------------------------
  o_adc_errors          <= adc_errors;
  o_adc_status          <= adc_status;

end architecture RTL;
