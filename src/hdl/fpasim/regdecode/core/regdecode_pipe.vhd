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
--!   @file                   regdecode_pipe.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--!   This module has the following functionnalities:
--!      . de-multiplexes the input data flow (i_addr/i_data) in order to configure each RAM
--!      . multiplexe the reading of each RAM into the output data flow (o_fifo_addr/o_fifo_data)
--!      . for each ram, it automatically generates read address in order to retrieve the RAM contents by taking into account
--!        the different RAM depth.
--!        
--!   The architecture is as follows:
--! @i_clk source clock domain                                         |    @ i_out_clk destination clock domain
--!                                                  |--- fsm ---- fifo_async -------------- RAM0
--!                                                  |--- fsm ---- fifo_async ----------- RAM1 |
--!    i_addr/i_data    ----> addr_decode----------> |--- fsm ---- fifo_async ------- RAM2  |  |
--!                                                  |--- fsm ---- fifo_async ---- RAM3 |   |  |
--!                                                  |--- fsm ---- fifo_async - RAM4 |  |   |  |
--!                                                                              |   |  |   |  |
--!                                        |------------------------fifo_async----   |  |   |  |                        
--!                                        |------------------------fifo_async--------  |   |  |                          
--!   o_fifo_addr/o_fifo_data <--fsm <---- |------------------------fifo_async----------    |  |
--!                                        |------------------------fifo_async--------------   | 
--!                                        |------------------------fifo_async-----------------
--!     
--!     
--!     
--!     
--!   Note:
--!     . In all cases, the module manages the clock domain crossing.
-- -------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fpasim;
use fpasim.pkg_regdecode.all;
use fpasim.pkg_fpasim.all;

entity regdecode_pipe is
  generic(
    g_ADDR_WIDTH : integer := 16;       -- define the address bus width
    g_DATA_WIDTH : integer := 16        -- define the data bus width
  );
  port(
    ---------------------------------------------------------------------
    -- input @i_clk
    ---------------------------------------------------------------------
    i_clk                             : in  std_logic; -- clock
    i_rst                             : in  std_logic; -- reset

    -- from the trig in
    i_start_auto_rd                   : in  std_logic; -- enable the auto generation of memory reading address

    -- from the pipe in
    i_data_valid                      :     std_logic; -- write enable
    i_addr                            :     std_logic_vector(g_ADDR_WIDTH - 1 downto 0); -- input address
    i_data                            :     std_logic_vector(g_DATA_WIDTH - 1 downto 0); -- input data

    ---------------------------------------------------------------------
    -- to the pipe out: @i_clk
    ---------------------------------------------------------------------
    i_fifo_rd                         : in  std_logic;
    o_fifo_sof                        : out std_logic; -- first sample of one of memories
    o_fifo_eof                        : out std_logic; -- last sample of one of memories
    o_fifo_data_valid                 : out std_logic; -- data valid
    o_fifo_addr                       : out std_logic_vector(g_ADDR_WIDTH - 1 downto 0); -- address
    o_fifo_data                       : out std_logic_vector(g_DATA_WIDTH - 1 downto 0); -- data
    o_fifo_empty                      : out std_logic; -- fifo empty flag
    o_fifo_data_count                 : out std_logic_vector(15 downto 0);
    ---------------------------------------------------------------------
    -- to the user: @i_out_clk
    ---------------------------------------------------------------------
    i_out_clk                         : in  std_logic;
    i_rst_status                      : in  std_logic; -- reset error flag(s)
    i_debug_pulse                     : in  std_logic; -- error mode (transparent vs capture). Possib

    -- tes_pulse_shape
    -- ram: wr
    o_tes_pulse_shape_ram_wr_en       : out std_logic; -- output write enable
    o_tes_pulse_shape_ram_wr_rd_addr  : out std_logic_vector(g_ADDR_WIDTH - 1 downto 0); -- output address (shared by the writting and the reading)
    o_tes_pulse_shape_ram_wr_data     : out std_logic_vector(g_DATA_WIDTH - 1 downto 0); -- output data
    -- ram: rd
    o_tes_pulse_shape_ram_rd_en       : out std_logic; -- output read enable
    i_tes_pulse_shape_ram_rd_valid    : in  std_logic; -- input read valid
    i_tes_pulse_shape_ram_rd_data     : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0); -- input data

    -- amp_squid_tf
    -- ram: wr
    o_amp_squid_tf_ram_wr_en          : out std_logic; -- output write enable
    o_amp_squid_tf_ram_wr_rd_addr     : out std_logic_vector(g_ADDR_WIDTH - 1 downto 0); -- output address (shared by the writting and the reading)
    o_amp_squid_tf_ram_wr_data        : out std_logic_vector(g_DATA_WIDTH - 1 downto 0); -- output data
    -- ram: rd
    o_amp_squid_tf_ram_rd_en          : out std_logic; -- output read enable
    i_amp_squid_tf_ram_rd_valid       : in  std_logic; -- input read valid
    i_amp_squid_tf_ram_rd_data        : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0);
    -- mux_squid_tf
    -- ram: wr
    o_mux_squid_tf_ram_wr_en          : out std_logic; -- output write enable
    o_mux_squid_tf_ram_wr_rd_addr     : out std_logic_vector(g_ADDR_WIDTH - 1 downto 0); -- output address (shared by the writting and the reading)
    o_mux_squid_tf_ram_wr_data        : out std_logic_vector(g_DATA_WIDTH - 1 downto 0); -- output data
    -- ram: rd
    o_mux_squid_tf_ram_rd_en          : out std_logic; -- output read enable
    i_mux_squid_tf_ram_rd_valid       : in  std_logic; -- input read valid
    i_mux_squid_tf_ram_rd_data        : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0);
    -- tes_std_state
    -- ram: wr
    o_tes_std_state_ram_wr_en         : out std_logic; -- output write enable
    o_tes_std_state_ram_wr_rd_addr    : out std_logic_vector(g_ADDR_WIDTH - 1 downto 0); -- output address (shared by the writting and the reading)
    o_tes_std_state_ram_wr_data       : out std_logic_vector(g_DATA_WIDTH - 1 downto 0); -- output data
    -- ram: rd
    o_tes_std_state_ram_rd_en         : out std_logic; -- output read enable
    i_tes_std_state_ram_rd_valid      : in  std_logic; -- input read valid
    i_tes_std_state_ram_rd_data       : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0);
    -- mux_squid_offset
    -- ram: wr
    o_mux_squid_offset_ram_wr_en      : out std_logic; -- output write enable
    o_mux_squid_offset_ram_wr_rd_addr : out std_logic_vector(g_ADDR_WIDTH - 1 downto 0); -- output address (shared by the writting and the reading)
    o_mux_squid_offset_ram_wr_data    : out std_logic_vector(g_DATA_WIDTH - 1 downto 0); -- output data
    -- ram: rd
    o_mux_squid_offset_ram_rd_en      : out std_logic; -- output read enable
    i_mux_squid_offset_ram_rd_valid   : in  std_logic; -- input read valid
    i_mux_squid_offset_ram_rd_data    : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0);
    ---------------------------------------------------------------------
    -- errors/status @i_out_clk
    ---------------------------------------------------------------------
    -- errors
    o_errors5                         : out std_logic_vector(15 downto 0); -- rd all: output errors
    o_errors4                         : out std_logic_vector(15 downto 0); -- mux squid offset: output errors
    o_errors3                         : out std_logic_vector(15 downto 0); -- tes std state: output errors
    o_errors2                         : out std_logic_vector(15 downto 0); -- mux squid tf: output errors
    o_errors1                         : out std_logic_vector(15 downto 0); -- amp squid tf: output errors
    o_errors0                         : out std_logic_vector(15 downto 0); -- tes pulse shape: output errors
    -- status
    o_status5                         : out std_logic_vector(7 downto 0); -- rd all: output status
    o_status4                         : out std_logic_vector(7 downto 0); -- mux squid offset: output status
    o_status3                         : out std_logic_vector(7 downto 0); -- tes std state: output status
    o_status2                         : out std_logic_vector(7 downto 0); -- mux squid tf: output status
    o_status1                         : out std_logic_vector(7 downto 0); -- amp squid tf: output status
    o_status0                         : out std_logic_vector(7 downto 0) -- tes pulse shape: output status
  );
end entity regdecode_pipe;

architecture RTL of regdecode_pipe is
  -- tes_pulse_shape
  constant c_TES_PULSE_SHAPE_RAM_NB_WORDS   : integer := pkg_TES_PULSE_SHAPE_RAM_NB_WORDS;
  constant c_TES_PULSE_SHAPE_RAM_RD_LATENCY : integer := pkg_TES_PULSE_SHAPE_RAM_RD_LATENCY;

  constant c_TES_PULSE_SHAPE_ADDR_RANGE_MIN : std_logic_vector(pkg_TES_PULSE_SHAPE_ADDR_RANGE_MIN'range) := pkg_TES_PULSE_SHAPE_ADDR_RANGE_MIN;

  -- amp_squid_tf
  constant c_AMP_SQUID_TF_RAM_NB_WORDS   : integer := pkg_AMP_SQUID_TF_RAM_NB_WORDS;
  constant c_AMP_SQUID_TF_RAM_RD_LATENCY : integer := pkg_AMP_SQUID_TF_RAM_RD_LATENCY;

  constant c_AMP_SQUID_TF_ADDR_RANGE_MIN : std_logic_vector(pkg_AMP_SQUID_TF_ADDR_RANGE_MIN'range) := pkg_AMP_SQUID_TF_ADDR_RANGE_MIN;

  -- mux_squid_tf
  constant c_MUX_SQUID_TF_RAM_NB_WORDS   : integer := pkg_MUX_SQUID_TF_RAM_NB_WORDS;
  constant c_MUX_SQUID_TF_RAM_RD_LATENCY : integer := pkg_MUX_SQUID_TF_RAM_RD_LATENCY;

  constant c_MUX_SQUID_TF_ADDR_RANGE_MIN : std_logic_vector(pkg_MUX_SQUID_TF_ADDR_RANGE_MIN'range) := pkg_MUX_SQUID_TF_ADDR_RANGE_MIN;

  -- tes_std_state
  constant c_TES_STD_STATE_RAM_NB_WORDS   : integer := pkg_TES_STD_STATE_RAM_NB_WORDS;
  constant c_TES_STD_STATE_RAM_RD_LATENCY : integer := pkg_TES_STD_STATE_RAM_RD_LATENCY;

  constant c_TES_STD_STATE_ADDR_RANGE_MIN : std_logic_vector(pkg_TES_STD_STATE_ADDR_RANGE_MIN'range) := pkg_TES_STD_STATE_ADDR_RANGE_MIN;

  -- mux_squid_offset
  constant c_MUX_SQUID_OFFSET_RAM_NB_WORDS   : integer := pkg_MUX_SQUID_OFFSET_RAM_NB_WORDS;
  constant c_MUX_SQUID_OFFSET_RAM_RD_LATENCY : integer := pkg_MUX_SQUID_OFFSET_RAM_RD_LATENCY;

  constant c_MUX_SQUID_OFFSET_ADDR_RANGE_MIN : std_logic_vector(pkg_MUX_SQUID_OFFSET_ADDR_RANGE_MIN'range) := pkg_MUX_SQUID_OFFSET_ADDR_RANGE_MIN;

  ---------------------------------------------------------------------
  -- addr decode
  ---------------------------------------------------------------------
  signal tes_pulse_shape_wr_en0  : std_logic;
  signal amp_squid_tf_wr_en0     : std_logic;
  signal mux_squid_tf_wr_en0     : std_logic;
  signal tes_std_state_wr_en0    : std_logic;
  signal mux_squid_offset_wr_en0 : std_logic;

  signal addr0 : std_logic_vector(i_addr'range);
  signal data0 : std_logic_vector(i_data'range);

  ---------------------------------------------------------------------
  -- tes pulse shape
  ---------------------------------------------------------------------
  -- ram: wr
  signal tes_pulse_shape_ram_wr_en      : std_logic;
  signal tes_pulse_shape_ram_wr_rd_addr : std_logic_vector(o_tes_pulse_shape_ram_wr_rd_addr'range);
  signal tes_pulse_shape_ram_wr_data    : std_logic_vector(o_tes_pulse_shape_ram_wr_data'range);
  -- ram: rd
  signal tes_pulse_shape_ram_rd_en      : std_logic;

  -- to the regdecode: @i_clk
  ---------------------------------------------------------------------
  signal tes_pulse_shape_fifo_rd         : std_logic;
  signal tes_pulse_shape_fifo_sof        : std_logic;
  signal tes_pulse_shape_fifo_eof        : std_logic;
  signal tes_pulse_shape_fifo_data_valid : std_logic;
  signal tes_pulse_shape_fifo_addr       : std_logic_vector(i_addr'range);
  signal tes_pulse_shape_fifo_data       : std_logic_vector(i_data'range);
  signal tes_pulse_shape_fifo_empty      : std_logic;

  -- errors/status @ i_out_clk
  ---------------------------------------------------------------------
  signal tes_pulse_shape_errors : std_logic_vector(15 downto 0);
  signal tes_pulse_shape_status : std_logic_vector(7 downto 0);

  ---------------------------------------------------------------------
  -- amp_squid_tf
  ---------------------------------------------------------------------
  -- ram: wr
  signal amp_squid_tf_ram_wr_en      : std_logic;
  signal amp_squid_tf_ram_wr_rd_addr : std_logic_vector(o_amp_squid_tf_ram_wr_rd_addr'range);
  signal amp_squid_tf_ram_wr_data    : std_logic_vector(o_amp_squid_tf_ram_wr_data'range);
  -- ram: rd
  signal amp_squid_tf_ram_rd_en      : std_logic;

  -- to the regdecode: @i_clk
  ---------------------------------------------------------------------
  signal amp_squid_tf_fifo_rd         : std_logic;
  signal amp_squid_tf_fifo_sof        : std_logic;
  signal amp_squid_tf_fifo_eof        : std_logic;
  signal amp_squid_tf_fifo_data_valid : std_logic;
  signal amp_squid_tf_fifo_addr       : std_logic_vector(i_addr'range);
  signal amp_squid_tf_fifo_data       : std_logic_vector(i_data'range);
  signal amp_squid_tf_fifo_empty      : std_logic;

  -- errors/status @ i_out_clk
  ---------------------------------------------------------------------
  signal amp_squid_tf_errors : std_logic_vector(15 downto 0);
  signal amp_squid_tf_status : std_logic_vector(7 downto 0);

  ---------------------------------------------------------------------
  -- mux_squid_tf
  ---------------------------------------------------------------------
  -- ram: wr
  signal mux_squid_tf_ram_wr_en      : std_logic;
  signal mux_squid_tf_ram_wr_rd_addr : std_logic_vector(o_mux_squid_tf_ram_wr_rd_addr'range);
  signal mux_squid_tf_ram_wr_data    : std_logic_vector(o_mux_squid_tf_ram_wr_data'range);
  -- ram: rd
  signal mux_squid_tf_ram_rd_en      : std_logic;

  -- to the regdecode: @i_clk
  ---------------------------------------------------------------------
  signal mux_squid_tf_fifo_rd         : std_logic;
  signal mux_squid_tf_fifo_sof        : std_logic;
  signal mux_squid_tf_fifo_eof        : std_logic;
  signal mux_squid_tf_fifo_data_valid : std_logic;
  signal mux_squid_tf_fifo_addr       : std_logic_vector(i_addr'range);
  signal mux_squid_tf_fifo_data       : std_logic_vector(i_data'range);
  signal mux_squid_tf_fifo_empty      : std_logic;

  -- errors/status @ i_out_clk
  ---------------------------------------------------------------------
  signal mux_squid_tf_errors : std_logic_vector(15 downto 0);
  signal mux_squid_tf_status : std_logic_vector(7 downto 0);

  ---------------------------------------------------------------------
  -- tes_std_state
  ---------------------------------------------------------------------
  -- ram: wr
  signal tes_std_state_ram_wr_en      : std_logic;
  signal tes_std_state_ram_wr_rd_addr : std_logic_vector(o_tes_std_state_ram_wr_rd_addr'range);
  signal tes_std_state_ram_wr_data    : std_logic_vector(o_tes_std_state_ram_wr_data'range);
  -- ram: rd
  signal tes_std_state_ram_rd_en      : std_logic;

  -- to the regdecode: @i_clk
  ---------------------------------------------------------------------
  signal tes_std_state_fifo_rd         : std_logic;
  signal tes_std_state_fifo_sof        : std_logic;
  signal tes_std_state_fifo_eof        : std_logic;
  signal tes_std_state_fifo_data_valid : std_logic;
  signal tes_std_state_fifo_addr       : std_logic_vector(i_addr'range);
  signal tes_std_state_fifo_data       : std_logic_vector(i_data'range);
  signal tes_std_state_fifo_empty      : std_logic;

  -- errors/status @ i_out_clk
  ---------------------------------------------------------------------
  signal tes_std_state_errors : std_logic_vector(15 downto 0);
  signal tes_std_state_status : std_logic_vector(7 downto 0);

  ---------------------------------------------------------------------
  -- mux_squid_offset
  ---------------------------------------------------------------------
  -- ram: wr
  signal mux_squid_offset_ram_wr_en      : std_logic;
  signal mux_squid_offset_ram_wr_rd_addr : std_logic_vector(o_mux_squid_offset_ram_wr_rd_addr'range);
  signal mux_squid_offset_ram_wr_data    : std_logic_vector(o_mux_squid_offset_ram_wr_data'range);
  -- ram: rd
  signal mux_squid_offset_ram_rd_en      : std_logic;

  -- to the regdecode: @i_clk
  ---------------------------------------------------------------------
  signal mux_squid_offset_fifo_rd         : std_logic;
  signal mux_squid_offset_fifo_sof        : std_logic;
  signal mux_squid_offset_fifo_eof        : std_logic;
  signal mux_squid_offset_fifo_data_valid : std_logic;
  signal mux_squid_offset_fifo_addr       : std_logic_vector(i_addr'range);
  signal mux_squid_offset_fifo_data       : std_logic_vector(i_data'range);
  signal mux_squid_offset_fifo_empty      : std_logic;

  -- errors/status @ i_out_clk
  ---------------------------------------------------------------------
  signal mux_squid_offset_errors : std_logic_vector(15 downto 0);
  signal mux_squid_offset_status : std_logic_vector(7 downto 0);

  ---------------------------------------------------------------------
  -- regdecode_pipe_rd_all
  ---------------------------------------------------------------------
  signal fifo_sof        : std_logic;
  signal fifo_eof        : std_logic;
  signal fifo_data_valid : std_logic;
  signal fifo_addr       : std_logic_vector(o_fifo_addr'range);
  signal fifo_data       : std_logic_vector(o_fifo_data'range);
  signal fifo_data_count : std_logic_vector(15 downto 0);
  signal fifo_empty      : std_logic;

  signal pipe_rd_all_errors : std_logic_vector(15 downto 0);
  signal pipe_rd_all_status : std_logic_vector(7 downto 0);

begin

  ---------------------------------------------------------------------
  -- select the memory to write
  ---------------------------------------------------------------------
  inst_regdecode_pipe_addr_decode : entity fpasim.regdecode_pipe_addr_decode
    generic map(
      g_ADDR_WIDTH => i_addr'length,
      g_DATA_WIDTH => i_data'length
    )
    port map(
      i_clk                    => i_clk,
      ---------------------------------------------------------------------
      -- input data
      ---------------------------------------------------------------------
      i_data_valid             => i_data_valid,
      i_addr                   => i_addr,
      i_data                   => i_data,
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_tes_pulse_shape_wr_en  => tes_pulse_shape_wr_en0,
      o_amp_squid_tf_wr_en     => amp_squid_tf_wr_en0,
      o_mux_squid_tf_wr_en     => mux_squid_tf_wr_en0,
      o_tes_std_state_wr_en    => tes_std_state_wr_en0,
      o_mux_squid_offset_wr_en => mux_squid_offset_wr_en0,
      o_addr                   => addr0,
      o_data                   => data0
    );

  ---------------------------------------------------------------------
  -- tes pulse shape
  ---------------------------------------------------------------------
  inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape : entity fpasim.regdecode_pipe_wr_rd_ram_manager
    generic map(
      -- RAM
      g_RAM_NB_WORDS   => c_TES_PULSE_SHAPE_RAM_NB_WORDS,
      g_RAM_RD_LATENCY => c_TES_PULSE_SHAPE_RAM_RD_LATENCY, -- define the RAM latency during the reading
      -- input
      g_ADDR_WIDTH     => addr0'length, -- define the input address bus width
      g_DATA_WIDTH     => data0'length  -- define the input data bus width
    )
    port map(
      ---------------------------------------------------------------------
      -- from the regdecode: input @i_clk
      ---------------------------------------------------------------------
      i_clk             => i_clk,       -- clock
      i_rst             => i_rst,       -- reset
      -- command
      i_start_auto_rd   => i_start_auto_rd, -- start the auto address generation for the reading of the RAM
      i_addr_range_min  => c_TES_PULSE_SHAPE_ADDR_RANGE_MIN, -- minimal address range
      -- data
      i_data_valid      => tes_pulse_shape_wr_en0, -- input data valid
      i_addr            => addr0,       -- input address
      i_data            => data0,       -- input data
      ---------------------------------------------------------------------
      -- from/to the user:  @i_out_clk
      ---------------------------------------------------------------------
      i_out_clk         => i_out_clk,   -- output clock
      i_rst_status      => i_rst_status, -- reset error flag(s)
      i_debug_pulse     => i_debug_pulse, -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
      -- ram: wr
      o_ram_wr_en       => tes_pulse_shape_ram_wr_en, -- output write enable
      o_ram_wr_rd_addr  => tes_pulse_shape_ram_wr_rd_addr, -- output address (shared by the writting and the reading)
      o_ram_wr_data     => tes_pulse_shape_ram_wr_data, -- output data
      -- ram: rd
      o_ram_rd_en       => tes_pulse_shape_ram_rd_en, -- output read enable
      i_ram_rd_valid    => i_tes_pulse_shape_ram_rd_valid, -- input read valid
      i_ram_rd_data     => i_tes_pulse_shape_ram_rd_data, -- input data
      ---------------------------------------------------------------------
      -- to the regdecode: @i_clk
      ---------------------------------------------------------------------
      i_fifo_rd         => tes_pulse_shape_fifo_rd,
      o_fifo_sof        => tes_pulse_shape_fifo_sof,
      o_fifo_eof        => tes_pulse_shape_fifo_eof,
      o_fifo_data_valid => tes_pulse_shape_fifo_data_valid,
      o_fifo_addr       => tes_pulse_shape_fifo_addr,
      o_fifo_data       => tes_pulse_shape_fifo_data,
      o_fifo_empty      => tes_pulse_shape_fifo_empty,
      ---------------------------------------------------------------------
      -- errors/status @ i_out_clk
      ---------------------------------------------------------------------
      o_errors          => tes_pulse_shape_errors,
      o_status          => tes_pulse_shape_status
    );

  -- output
  -- ram: wr
  o_tes_pulse_shape_ram_wr_en      <= tes_pulse_shape_ram_wr_en;
  o_tes_pulse_shape_ram_wr_rd_addr <= tes_pulse_shape_ram_wr_rd_addr;
  o_tes_pulse_shape_ram_wr_data    <= tes_pulse_shape_ram_wr_data;
  -- ram: rd
  o_tes_pulse_shape_ram_rd_en      <= tes_pulse_shape_ram_rd_en;

  o_errors0 <= tes_pulse_shape_errors;
  o_status0 <= tes_pulse_shape_status;

  ---------------------------------------------------------------------
  -- amp_squid_tf
  ---------------------------------------------------------------------
  inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf : entity fpasim.regdecode_pipe_wr_rd_ram_manager
    generic map(
      -- RAM
      g_RAM_NB_WORDS   => c_AMP_SQUID_TF_RAM_NB_WORDS,
      g_RAM_RD_LATENCY => c_AMP_SQUID_TF_RAM_RD_LATENCY, -- define the RAM latency during the reading
      -- input
      g_ADDR_WIDTH     => addr0'length, -- define the input address bus width
      g_DATA_WIDTH     => data0'length  -- define the input data bus width
    )
    port map(
      ---------------------------------------------------------------------
      -- from the regdecode: input @i_clk
      ---------------------------------------------------------------------
      i_clk             => i_clk,       -- clock
      i_rst             => i_rst,       -- reset
      -- command
      i_start_auto_rd   => i_start_auto_rd, -- start the auto address generation for the reading of the RAM
      i_addr_range_min  => c_AMP_SQUID_TF_ADDR_RANGE_MIN, -- minimal address range
      -- data
      i_data_valid      => amp_squid_tf_wr_en0, -- input data valid
      i_addr            => addr0,       -- input address
      i_data            => data0,       -- input data
      ---------------------------------------------------------------------
      -- from/to the user:  @i_out_clk
      ---------------------------------------------------------------------
      i_out_clk         => i_out_clk,   -- output clock
      i_rst_status      => i_rst_status, -- reset error flag(s)
      i_debug_pulse     => i_debug_pulse, -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
      -- ram: wr
      o_ram_wr_en       => amp_squid_tf_ram_wr_en, -- output write enable
      o_ram_wr_rd_addr  => amp_squid_tf_ram_wr_rd_addr, -- output address (shared by the writting and the reading)
      o_ram_wr_data     => amp_squid_tf_ram_wr_data, -- output data
      -- ram: rd
      o_ram_rd_en       => amp_squid_tf_ram_rd_en, -- output read enable
      i_ram_rd_valid    => i_amp_squid_tf_ram_rd_valid, -- input read valid
      i_ram_rd_data     => i_amp_squid_tf_ram_rd_data, -- input data
      ---------------------------------------------------------------------
      -- to the regdecode: @i_clk
      ---------------------------------------------------------------------
      i_fifo_rd         => amp_squid_tf_fifo_rd,
      o_fifo_sof        => amp_squid_tf_fifo_sof,
      o_fifo_eof        => amp_squid_tf_fifo_eof,
      o_fifo_data_valid => amp_squid_tf_fifo_data_valid,
      o_fifo_addr       => amp_squid_tf_fifo_addr,
      o_fifo_data       => amp_squid_tf_fifo_data,
      o_fifo_empty      => amp_squid_tf_fifo_empty,
      ---------------------------------------------------------------------
      -- errors/status @ i_out_clk
      ---------------------------------------------------------------------
      o_errors          => amp_squid_tf_errors,
      o_status          => amp_squid_tf_status
    );

  -- output
  -- ram: wr
  o_amp_squid_tf_ram_wr_en      <= amp_squid_tf_ram_wr_en;
  o_amp_squid_tf_ram_wr_rd_addr <= amp_squid_tf_ram_wr_rd_addr;
  o_amp_squid_tf_ram_wr_data    <= amp_squid_tf_ram_wr_data;
  -- ram: rd
  o_amp_squid_tf_ram_rd_en      <= amp_squid_tf_ram_rd_en;

  o_errors1 <= amp_squid_tf_errors;
  o_status1 <= amp_squid_tf_status;

  ---------------------------------------------------------------------
  -- mux_squid_tf
  ---------------------------------------------------------------------
  inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf : entity fpasim.regdecode_pipe_wr_rd_ram_manager
    generic map(
      -- RAM
      g_RAM_NB_WORDS   => c_MUX_SQUID_TF_RAM_NB_WORDS,
      g_RAM_RD_LATENCY => c_MUX_SQUID_TF_RAM_RD_LATENCY, -- define the RAM latency during the reading
      -- input
      g_ADDR_WIDTH     => addr0'length, -- define the input address bus width
      g_DATA_WIDTH     => data0'length
    )
    port map(
      ---------------------------------------------------------------------
      -- from the regdecode: input @i_clk
      ---------------------------------------------------------------------
      i_clk             => i_clk,       -- clock
      i_rst             => i_rst,       -- reset
      -- command
      i_start_auto_rd   => i_start_auto_rd, -- start the auto address generation for the reading of the RAM
      i_addr_range_min  => c_MUX_SQUID_TF_ADDR_RANGE_MIN, -- minimal address range
      -- data
      i_data_valid      => mux_squid_tf_wr_en0, -- input data valid
      i_addr            => addr0,       -- input address
      i_data            => data0,       -- input data
      ---------------------------------------------------------------------
      -- from/to the user:  @i_out_clk
      ---------------------------------------------------------------------
      i_out_clk         => i_out_clk,   -- output clock
      i_rst_status      => i_rst_status, -- reset error flag(s)
      i_debug_pulse     => i_debug_pulse, -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
      -- ram: wr
      o_ram_wr_en       => mux_squid_tf_ram_wr_en, -- output write enable
      o_ram_wr_rd_addr  => mux_squid_tf_ram_wr_rd_addr, -- output address (shared by the writting and the reading)
      o_ram_wr_data     => mux_squid_tf_ram_wr_data, -- output data
      -- ram: rd
      o_ram_rd_en       => mux_squid_tf_ram_rd_en, -- output read enable
      i_ram_rd_valid    => i_mux_squid_tf_ram_rd_valid, -- input read valid
      i_ram_rd_data     => i_mux_squid_tf_ram_rd_data, -- input data
      ---------------------------------------------------------------------
      -- to the regdecode: @i_clk
      ---------------------------------------------------------------------
      i_fifo_rd         => mux_squid_tf_fifo_rd,
      o_fifo_sof        => mux_squid_tf_fifo_sof,
      o_fifo_eof        => mux_squid_tf_fifo_eof,
      o_fifo_data_valid => mux_squid_tf_fifo_data_valid,
      o_fifo_addr       => mux_squid_tf_fifo_addr,
      o_fifo_data       => mux_squid_tf_fifo_data,
      o_fifo_empty      => mux_squid_tf_fifo_empty,
      ---------------------------------------------------------------------
      -- errors/status @ i_out_clk
      ---------------------------------------------------------------------
      o_errors          => mux_squid_tf_errors,
      o_status          => mux_squid_tf_status
    );

  -- output
  -- ram: wr
  o_mux_squid_tf_ram_wr_en      <= mux_squid_tf_ram_wr_en;
  o_mux_squid_tf_ram_wr_rd_addr <= mux_squid_tf_ram_wr_rd_addr;
  o_mux_squid_tf_ram_wr_data    <= mux_squid_tf_ram_wr_data;
  -- ram: rd
  o_mux_squid_tf_ram_rd_en      <= mux_squid_tf_ram_rd_en;

  o_errors2 <= mux_squid_tf_errors;
  o_status2 <= mux_squid_tf_status;

  ---------------------------------------------------------------------
  -- tes_std_state
  ---------------------------------------------------------------------
  inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state : entity fpasim.regdecode_pipe_wr_rd_ram_manager
    generic map(
      -- RAM
      g_RAM_NB_WORDS   => c_TES_STD_STATE_RAM_NB_WORDS,
      g_RAM_RD_LATENCY => c_TES_STD_STATE_RAM_RD_LATENCY, -- define the RAM latency during the reading
      -- input
      g_ADDR_WIDTH     => addr0'length, -- define the input address bus width
      g_DATA_WIDTH     => data0'length
    )
    port map(
      ---------------------------------------------------------------------
      -- from the regdecode: input @i_clk
      ---------------------------------------------------------------------
      i_clk             => i_clk,       -- clock
      i_rst             => i_rst,       -- reset
      -- command
      i_start_auto_rd   => i_start_auto_rd, -- start the auto address generation for the reading of the RAM
      i_addr_range_min  => c_TES_STD_STATE_ADDR_RANGE_MIN, -- minimal address range
      -- data
      i_data_valid      => tes_std_state_wr_en0, -- input data valid
      i_addr            => addr0,       -- input address
      i_data            => data0,       -- input data
      ---------------------------------------------------------------------
      -- from/to the user:  @i_out_clk
      ---------------------------------------------------------------------
      i_out_clk         => i_out_clk,   -- output clock
      i_rst_status      => i_rst_status, -- reset error flag(s)
      i_debug_pulse     => i_debug_pulse, -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
      -- ram: wr
      o_ram_wr_en       => tes_std_state_ram_wr_en, -- output write enable
      o_ram_wr_rd_addr  => tes_std_state_ram_wr_rd_addr, -- output address (shared by the writting and the reading)
      o_ram_wr_data     => tes_std_state_ram_wr_data, -- output data
      -- ram: rd
      o_ram_rd_en       => tes_std_state_ram_rd_en, -- output read enable
      i_ram_rd_valid    => i_tes_std_state_ram_rd_valid, -- input read valid
      i_ram_rd_data     => i_tes_std_state_ram_rd_data, -- input data
      ---------------------------------------------------------------------
      -- to the regdecode: @i_clk
      ---------------------------------------------------------------------
      i_fifo_rd         => tes_std_state_fifo_rd,
      o_fifo_sof        => tes_std_state_fifo_sof,
      o_fifo_eof        => tes_std_state_fifo_eof,
      o_fifo_data_valid => tes_std_state_fifo_data_valid,
      o_fifo_addr       => tes_std_state_fifo_addr,
      o_fifo_data       => tes_std_state_fifo_data,
      o_fifo_empty      => tes_std_state_fifo_empty,
      ---------------------------------------------------------------------
      -- errors/status @ i_out_clk
      ---------------------------------------------------------------------
      o_errors          => tes_std_state_errors,
      o_status          => tes_std_state_status
    );

  -- output
  -- ram: wr
  o_tes_std_state_ram_wr_en      <= tes_std_state_ram_wr_en;
  o_tes_std_state_ram_wr_rd_addr <= tes_std_state_ram_wr_rd_addr;
  o_tes_std_state_ram_wr_data    <= tes_std_state_ram_wr_data;
  -- ram: rd
  o_tes_std_state_ram_rd_en      <= tes_std_state_ram_rd_en;

  o_errors3 <= tes_std_state_errors;
  o_status3 <= tes_std_state_status;

  ---------------------------------------------------------------------
  -- mux_squid_offset
  ---------------------------------------------------------------------
  inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset : entity fpasim.regdecode_pipe_wr_rd_ram_manager
    generic map(
      -- RAM
      g_RAM_NB_WORDS   => c_MUX_SQUID_OFFSET_RAM_NB_WORDS,
      g_RAM_RD_LATENCY => c_MUX_SQUID_OFFSET_RAM_RD_LATENCY, -- define the RAM latency during the reading
      -- input
      g_ADDR_WIDTH     => addr0'length, -- define the input address bus width
      g_DATA_WIDTH     => data0'length
    )
    port map(
      ---------------------------------------------------------------------
      -- from the regdecode: input @i_clk
      ---------------------------------------------------------------------
      i_clk             => i_clk,       -- clock
      i_rst             => i_rst,       -- reset
      -- command
      i_start_auto_rd   => i_start_auto_rd, -- start the auto address generation for the reading of the RAM
      i_addr_range_min  => c_MUX_SQUID_OFFSET_ADDR_RANGE_MIN, -- minimal address range
      -- data
      i_data_valid      => mux_squid_offset_wr_en0, -- input data valid
      i_addr            => addr0,       -- input address
      i_data            => data0,       -- input data
      ---------------------------------------------------------------------
      -- from/to the user:  @i_out_clk
      ---------------------------------------------------------------------
      i_out_clk         => i_out_clk,   -- output clock
      i_rst_status      => i_rst_status, -- reset error flag(s)
      i_debug_pulse     => i_debug_pulse, -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
      -- ram: wr
      o_ram_wr_en       => mux_squid_offset_ram_wr_en, -- output write enable
      o_ram_wr_rd_addr  => mux_squid_offset_ram_wr_rd_addr, -- output address (shared by the writting and the reading)
      o_ram_wr_data     => mux_squid_offset_ram_wr_data, -- output data
      -- ram: rd
      o_ram_rd_en       => mux_squid_offset_ram_rd_en, -- output read enable
      i_ram_rd_valid    => i_mux_squid_offset_ram_rd_valid, -- input read valid
      i_ram_rd_data     => i_mux_squid_offset_ram_rd_data, -- input data
      ---------------------------------------------------------------------
      -- to the regdecode: @i_clk
      ---------------------------------------------------------------------
      i_fifo_rd         => mux_squid_offset_fifo_rd,
      o_fifo_sof        => mux_squid_offset_fifo_sof,
      o_fifo_eof        => mux_squid_offset_fifo_eof,
      o_fifo_data_valid => mux_squid_offset_fifo_data_valid,
      o_fifo_addr       => mux_squid_offset_fifo_addr,
      o_fifo_data       => mux_squid_offset_fifo_data,
      o_fifo_empty      => mux_squid_offset_fifo_empty,
      ---------------------------------------------------------------------
      -- errors/status @ i_out_clk
      ---------------------------------------------------------------------
      o_errors          => mux_squid_offset_errors,
      o_status          => mux_squid_offset_status
    );

  -- output
  -- ram: wr
  o_mux_squid_offset_ram_wr_en      <= mux_squid_offset_ram_wr_en;
  o_mux_squid_offset_ram_wr_rd_addr <= mux_squid_offset_ram_wr_rd_addr;
  o_mux_squid_offset_ram_wr_data    <= mux_squid_offset_ram_wr_data;
  -- ram: rd
  o_mux_squid_offset_ram_rd_en      <= mux_squid_offset_ram_rd_en;

  o_errors4 <= mux_squid_offset_errors;
  o_status4 <= mux_squid_offset_status;

  ---------------------------------------------------------------------
  -- to pipe_out, read sequencially and complety the 5 inputs
  ---------------------------------------------------------------------
  inst_regdecode_pipe_rd_all : entity fpasim.regdecode_pipe_rd_all
    generic map(
      g_ADDR_WIDTH    => fifo_addr'length,
      g_DATA_WIDTH    => fifo_data'length,
      -- resynchronized errors bits
      g_DEST_SYNC_FF  => 2,
      g_SRC_INPUT_REG => 1
    )
    port map(
      i_clk              => i_clk,
      i_rst              => i_rst,
      -- input0
      o_fifo_rd0         => tes_pulse_shape_fifo_rd,
      i_fifo_sof0        => tes_pulse_shape_fifo_sof,
      i_fifo_eof0        => tes_pulse_shape_fifo_eof,
      i_fifo_data_valid0 => tes_pulse_shape_fifo_data_valid,
      i_fifo_addr0       => tes_pulse_shape_fifo_addr,
      i_fifo_data0       => tes_pulse_shape_fifo_data,
      i_fifo_empty0      => tes_pulse_shape_fifo_empty,
      -- input1
      o_fifo_rd1         => amp_squid_tf_fifo_rd,
      i_fifo_sof1        => amp_squid_tf_fifo_sof,
      i_fifo_eof1        => amp_squid_tf_fifo_eof,
      i_fifo_data_valid1 => amp_squid_tf_fifo_data_valid,
      i_fifo_addr1       => amp_squid_tf_fifo_addr,
      i_fifo_data1       => amp_squid_tf_fifo_data,
      i_fifo_empty1      => amp_squid_tf_fifo_empty,
      -- input2
      o_fifo_rd2         => mux_squid_tf_fifo_rd,
      i_fifo_sof2        => mux_squid_tf_fifo_sof,
      i_fifo_eof2        => mux_squid_tf_fifo_eof,
      i_fifo_data_valid2 => mux_squid_tf_fifo_data_valid,
      i_fifo_addr2       => mux_squid_tf_fifo_addr,
      i_fifo_data2       => mux_squid_tf_fifo_data,
      i_fifo_empty2      => mux_squid_tf_fifo_empty,
      -- input3
      o_fifo_rd3         => tes_std_state_fifo_rd,
      i_fifo_sof3        => tes_std_state_fifo_sof,
      i_fifo_eof3        => tes_std_state_fifo_eof,
      i_fifo_data_valid3 => tes_std_state_fifo_data_valid,
      i_fifo_addr3       => tes_std_state_fifo_addr,
      i_fifo_data3       => tes_std_state_fifo_data,
      i_fifo_empty3      => tes_std_state_fifo_empty,
      -- input4
      o_fifo_rd4         => mux_squid_offset_fifo_rd,
      i_fifo_sof4        => mux_squid_offset_fifo_sof,
      i_fifo_eof4        => mux_squid_offset_fifo_eof,
      i_fifo_data_valid4 => mux_squid_offset_fifo_data_valid,
      i_fifo_addr4       => mux_squid_offset_fifo_addr,
      i_fifo_data4       => mux_squid_offset_fifo_data,
      i_fifo_empty4      => mux_squid_offset_fifo_empty,
      ---------------------------------------------------------------------
      -- to the pipe out: @i_clk
      ---------------------------------------------------------------------
      i_fifo_rd          => i_fifo_rd,
      o_fifo_sof         => fifo_sof,
      o_fifo_eof         => fifo_eof,
      o_fifo_data_valid  => fifo_data_valid,
      o_fifo_addr        => fifo_addr,
      o_fifo_data        => fifo_data,
      o_fifo_data_count  => fifo_data_count,
      o_fifo_empty       => fifo_empty,
      ---------------------------------------------------------------------
      -- errors/status @i_out_clk
      ---------------------------------------------------------------------
      i_out_clk          => i_out_clk,
      i_rst_status       => i_rst_status,
      i_debug_pulse      => i_debug_pulse,
      o_errors           => pipe_rd_all_errors,
      o_status           => pipe_rd_all_status
    );

  ---------------------------------------------------------------------
  -- output: to the pipe out
  ---------------------------------------------------------------------
  o_fifo_sof        <= fifo_sof;
  o_fifo_eof        <= fifo_eof;
  o_fifo_data_valid <= fifo_data_valid;
  o_fifo_addr       <= fifo_addr;
  o_fifo_data       <= fifo_data;
  o_fifo_empty      <= fifo_empty;
  o_fifo_data_count <= fifo_data_count;

  o_errors5 <= pipe_rd_all_errors;
  o_status5 <= pipe_rd_all_status;

end architecture RTL;
