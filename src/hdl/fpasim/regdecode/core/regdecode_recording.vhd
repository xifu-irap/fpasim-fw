-- -------------------------------------------------------------------------------------------------------------
--                              Copyright (C) 2022-2030 Ken-ji de la Rosa, IRAP Toulouse.
-- -------------------------------------------------------------------------------------------------------------
--                              This file is part of the ATHENA X-IFU DRE Focal Plane Assembly simulator.
--
--                              fpasim-fw is free software: you can redistribute it and/or modifyh
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
-- -------------------------------------------------------------------------------------------------------------
--    email                   kenji.delarosa@alten.com
--    @file                   regdecode_recording.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--    This module manage the recording registers as well as the pipe_out link
--    The architecture principle is as follows:
--         @i_clk clock domain                          |                   @ i_out_clk clock domain
--         i_rec_ctrl/i_rec_conf0 -----------------> async_fifo -----------> o_rec_ctrl/o_rec_conf0
--                                                                        |
--         o_usb_rec_ctrl/o_usb_rec_conf0 <---------  async_fifo <---------
--
--         o_usb_fifo_adc_data   <---------------- sync_FIFO <-- async_fifo <-------------- i_fifo_adc_data
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_regdecode.all;

entity regdecode_recording is
  generic (
    g_DATA_WIDTH : integer := 32
    );
  port(
    ---------------------------------------------------------------------
    -- from the regdecode/usb: input @i_clk
    ---------------------------------------------------------------------
    i_clk                        : in  std_logic;  -- clock
    i_rst                        : in  std_logic;  -- reset
    i_rst_status                 : in  std_logic;  -- reset error flag(s)
    i_debug_pulse                : in  std_logic;  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
    -- data
    i_rec_valid                  : in  std_logic;  -- register data valid
    i_rec_ctrl                   : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0);  -- register ctrl value
    i_rec_conf0                  : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0);  -- register conf0 value
    ---------------------------------------------------------------------
    -- from/to the user:  @i_out_clk
    ---------------------------------------------------------------------
    i_out_clk                    : in  std_logic;  -- output clock
    i_out_rst                    : in  std_logic;  -- reset @i_out_clk
    -- register
    o_rec_valid                  : out std_logic;  -- register data valid
    o_rec_ctrl                   : out std_logic_vector(g_DATA_WIDTH - 1 downto 0);  -- register ctrl value
    o_rec_conf0                  : out std_logic_vector(g_DATA_WIDTH - 1 downto 0);  -- register conf0 value
    -- data
    o_fifo_adc_rd                : out std_logic; -- fifo read enable
    i_fifo_adc_sof               : in  std_logic; -- fifo first sample
    i_fifo_adc_eof               : in  std_logic; -- fifo last sample
    i_fifo_adc_data_valid        : in  std_logic; -- fifo data valid
    i_fifo_adc_data              : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0); -- fifo data
    i_fifo_adc_empty             : in  std_logic; -- fifo empty flag
    ---------------------------------------------------------------------
    -- to the regdecode/usb: @i_clk
    ---------------------------------------------------------------------
    -- register
    o_usb_rec_valid              : out std_logic;  -- register data valid
    o_usb_rec_ctrl               : out std_logic_vector(g_DATA_WIDTH - 1 downto 0);  -- register ctrl value
    o_usb_rec_conf0              : out std_logic_vector(g_DATA_WIDTH - 1 downto 0);  -- register conf0 value
    -- data
    i_usb_fifo_adc_rd            : in  std_logic;  -- fifo read enable
    o_usb_fifo_adc_sof           : out std_logic;  -- fifo first sample
    o_usb_fifo_adc_eof           : out std_logic;  -- fifo last sample
    o_usb_fifo_adc_data_valid    : out std_logic;  -- fifo data valid
    o_usb_fifo_adc_data          : out std_logic_vector(g_DATA_WIDTH - 1 downto 0);  -- fifo data
    o_usb_fifo_adc_empty         : out std_logic;  -- fifo empty flag
    o_usb_fifo_adc_wr_data_count : out std_logic_vector(15 downto 0);  -- fifo wr data count
    ---------------------------------------------------------------------
    -- usb_errors/usb_status @ i_clk
    ---------------------------------------------------------------------
    o_errors1                    : out std_logic_vector(15 downto 0);  -- output errors1
    o_errors0                    : out std_logic_vector(15 downto 0);  -- output errors0
    o_status1                    : out std_logic_vector(7 downto 0);  -- output status1
    o_status0                    : out std_logic_vector(7 downto 0)  -- output status0
    );
end entity regdecode_recording;

architecture RTL of regdecode_recording is
  ---------------------------------------------------------------------
  -- register management
  ---------------------------------------------------------------------
  constant c_IDX0_L : integer := 0; -- index0: low
  constant c_IDX0_H : integer := c_IDX0_L + i_rec_conf0'length - 1; -- index0: high

  constant c_IDX1_L : integer := c_IDX0_H + 1; -- index1: low
  constant c_IDX1_H : integer := c_IDX1_L + i_rec_ctrl'length - 1; -- index1: high

  signal data_valid_tmp0 : std_logic; -- input data valid
  signal data_tmp0       : std_logic_vector(c_IDX1_H downto 0); -- input data

  signal data_valid_tmp2 : std_logic; -- temporary output data valid
  signal data_tmp2       : std_logic_vector(c_IDX1_H downto 0); -- temporary outpu data

  -- fifo: read
  signal rd_tmp1         : std_logic;
  -- fifo: data_valid flag
  signal data_valid_tmp1 : std_logic;
  -- fifo: data
  signal data_tmp1       : std_logic_vector(c_IDX1_H downto 0);
  -- fifo: empty flag
  signal empty_tmp1      : std_logic;

  signal errors_tmp1 : std_logic_vector(o_errors0'range); -- errors
  signal status_tmp1 : std_logic_vector(o_status0'range); -- status

  ---------------------------------------------------------------------
  -- data management
  ---------------------------------------------------------------------
  signal fifo_rd                 : std_logic;
  signal usb_adc_fifo_sof        : std_logic; -- fifo first sample
  signal usb_adc_fifo_eof        : std_logic; -- fifo last sample
  signal usb_adc_fifo_data_valid : std_logic; -- fifo data valid
  signal usb_adc_fifo_data       : std_logic_vector(o_usb_fifo_adc_data'range); -- fifo data
  signal usb_adc_fifo_empty      : std_logic; -- fifo empty flag
  signal usb_adc_wr_data_count   : std_logic_vector(15 downto 0); -- fifo write data count
  signal usb_errors              : std_logic_vector(15 downto 0); -- errors
  signal usb_status              : std_logic_vector(7 downto 0); -- status

begin


  ---------------------------------------------------------------------
  -- register management
  ---------------------------------------------------------------------
  data_valid_tmp0                     <= i_rec_valid;
  data_tmp0(c_IDX1_H downto c_IDX1_L) <= i_rec_ctrl;
  data_tmp0(c_IDX0_H downto c_IDX0_L) <= i_rec_conf0;

  inst_regdecode_wire_wr_rd : entity work.regdecode_wire_wr_rd
    generic map(
      g_DATA_WIDTH_OUT   => data_tmp0'length,  -- define the RAM address width
      g_FIFO_WRITE_DEPTH => 16  -- define the cross clock domain FIFO depth
      )
    port map(
      ---------------------------------------------------------------------
      -- from the regdecode: input @i_clk
      ---------------------------------------------------------------------
      i_clk             => i_clk,
      i_rst             => i_rst,
      i_rst_status      => i_rst_status,
      i_debug_pulse     => i_debug_pulse,
      -- data
      i_data_valid      => data_valid_tmp0,
      i_data            => data_tmp0,
      ---------------------------------------------------------------------
      -- from/to the user:  @i_out_clk
      ---------------------------------------------------------------------
      i_out_clk         => i_out_clk,
      i_out_rst         => i_out_rst,
      -- ram: wr
      o_data_valid      => data_valid_tmp2,
      o_data            => data_tmp2,
      ---------------------------------------------------------------------
      -- to the regdecode: @i_clk
      ---------------------------------------------------------------------
      i_fifo_rd         => rd_tmp1,
      o_fifo_data_valid => data_valid_tmp1,
      o_fifo_data       => data_tmp1,
      o_fifo_empty      => empty_tmp1,
      ---------------------------------------------------------------------
      -- usb_errors/usb_status @ i_clk
      ---------------------------------------------------------------------
      o_errors          => errors_tmp1,        -- output usb_errors
      o_status          => status_tmp1  -- output usb_status
      );

  -- fifo auto-reading
  rd_tmp1 <= '1' when empty_tmp1 = '0' else '0';

  -- output: to USB
  ---------------------------------------------------------------------
  o_usb_rec_valid <= data_valid_tmp1;
  o_usb_rec_ctrl  <= data_tmp1(c_IDX1_H downto c_IDX1_L);
  o_usb_rec_conf0 <= data_tmp1(c_IDX0_H downto c_IDX0_L);

  -- output: to the user
  ---------------------------------------------------------------------
  o_rec_valid <= data_valid_tmp2;
  o_rec_ctrl  <= data_tmp2(c_IDX1_H downto c_IDX1_L);
  o_rec_conf0 <= data_tmp2(c_IDX0_H downto c_IDX0_L);

---------------------------------------------------------------------
-- data management
---------------------------------------------------------------------
  inst_regdecode_recording_fifo : entity work.regdecode_recording_fifo
    generic map(
      g_DATA_WIDTH => i_fifo_adc_data'length
      )
    port map(
      ---------------------------------------------------------------------
      -- from the user:  @i_out_clk
      ---------------------------------------------------------------------
      i_out_clk             => i_out_clk,                -- output clock
      i_out_rst             => i_out_rst,
      -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
      -- data
      o_fifo_rd             => fifo_rd,                  -- read fifo
      i_fifo_sof            => i_fifo_adc_sof,           -- first packet sample
      i_fifo_eof            => i_fifo_adc_eof,           -- last packet sample
      i_fifo_data_valid     => i_fifo_adc_data_valid,    -- data valid
      i_fifo_data           => i_fifo_adc_data,          -- data
      i_fifo_empty          => i_fifo_adc_empty,         -- fifo empty flag
      ---------------------------------------------------------------------
      -- to the usb: @i_clk
      ---------------------------------------------------------------------
      i_clk                 => i_clk,                    -- clock
      i_rst                 => i_rst,                    -- reset
      i_rst_status          => i_rst_status,             -- reset error flag(s)
      i_debug_pulse         => i_debug_pulse,
      -- data
      i_usb_fifo_rd         => i_usb_fifo_adc_rd,        -- read fifo
      o_usb_fifo_sof        => usb_adc_fifo_sof,         -- first packet sample
      o_usb_fifo_eof        => usb_adc_fifo_eof,         -- last packet sample
      o_usb_fifo_data_valid => usb_adc_fifo_data_valid,  -- data valid
      o_usb_fifo_data       => usb_adc_fifo_data,        -- fifo data
      o_usb_fifo_empty      => usb_adc_fifo_empty,       -- fifo empty flag
      o_usb_wr_data_count   => usb_adc_wr_data_count,
      ---------------------------------------------------------------------
      -- usb_errors/usb_status @ i_clk
      ---------------------------------------------------------------------
      o_errors              => usb_errors,               -- output usb_errors
      o_status              => usb_status                -- output usb_status
      );
  ---------------------------------------------------------------------
  -- output: to user @i_out_clk
  ---------------------------------------------------------------------
  o_fifo_adc_rd <= fifo_rd;

  ---------------------------------------------------------------------
  -- output: to usb @i_clk
  ---------------------------------------------------------------------
  o_usb_fifo_adc_sof           <= usb_adc_fifo_sof;
  o_usb_fifo_adc_eof           <= usb_adc_fifo_eof;
  o_usb_fifo_adc_data_valid    <= usb_adc_fifo_data_valid;
  o_usb_fifo_adc_data          <= usb_adc_fifo_data;
  o_usb_fifo_adc_empty         <= usb_adc_fifo_empty;
  o_usb_fifo_adc_wr_data_count <= usb_adc_wr_data_count;
  ---------------------------------------------------------------------
  -- usb_errors/usb_status @ i_clk
  ---------------------------------------------------------------------
  o_errors1                    <= usb_errors;
  o_status1                    <= usb_status;
  o_errors0                    <= errors_tmp1;
  o_status0                    <= status_tmp1;

end architecture RTL;
