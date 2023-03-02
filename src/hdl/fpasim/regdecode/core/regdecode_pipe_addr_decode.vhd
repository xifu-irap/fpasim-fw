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
--!   @file                   regdecode_pipe_addr_decode.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--!
--!   This modules outputs a write enable (ex: o_tes_pulse_shape_wr_en) for each expected RAM
--!
--!   Note:
--!     . the o_addr/o_data are delayed in order to be aligned with the write enable generation. 
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


use work.pkg_fpasim.all;
use work.pkg_regdecode.all;

entity regdecode_pipe_addr_decode is
  generic(
    g_ADDR_WIDTH : integer := 16;       -- address bus width
    g_DATA_WIDTH : integer := 16        -- data bus width
    );
  port(
    i_clk                    : in  std_logic;  -- clock
    ---------------------------------------------------------------------
    -- input data
    ---------------------------------------------------------------------
    i_data_valid             : in  std_logic;  -- data valid
    i_addr                   : in  std_logic_vector(g_ADDR_WIDTH - 1 downto 0);  -- address value
    i_data                   : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0);  -- data value
    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    o_tes_pulse_shape_wr_en  : out std_logic;  -- tes pulse shape write enable
    o_amp_squid_tf_wr_en     : out std_logic;  -- amp squid tf write enable
    o_mux_squid_tf_wr_en     : out std_logic;  -- mux squid tf write enable
    o_tes_std_state_wr_en    : out std_logic;  -- tes std state write enable
    o_mux_squid_offset_wr_en : out std_logic;  -- mux squid offset write enable
    o_addr                   : out std_logic_vector(g_ADDR_WIDTH - 1 downto 0);  -- address value
    o_data                   : out std_logic_vector(g_DATA_WIDTH - 1 downto 0)  -- data value
    );
end entity regdecode_pipe_addr_decode;

architecture RTL of regdecode_pipe_addr_decode is

  constant c_PIPE_DELAY         : integer := pkg_REGDECODE_PIPE_ADDR_DECODE_CHECK_ADDR_RANGE_LATENCY;
  ---------------------------------------------------------------------
  -- check address range
  ---------------------------------------------------------------------
  signal tes_pulse_shape_wr_en  : std_logic;
  signal amp_squid_tf_wr_en     : std_logic;
  signal mux_squid_tf_wr_en     : std_logic;
  signal tes_std_state_wr_en    : std_logic;
  signal mux_squid_offset_wr_en : std_logic;

  ---------------------------------------------------------------------
  -- sync with wr en signals
  ---------------------------------------------------------------------
  constant c_PIPE_IDX0_L : integer := 0;
  constant c_PIPE_IDX0_H : integer := c_PIPE_IDX0_L + i_data'length - 1;

  constant c_PIPE_IDX1_L : integer := c_PIPE_IDX0_H + 1;
  constant c_PIPE_IDX1_H : integer := c_PIPE_IDX1_L + i_addr'length - 1;

  signal data_pipe_tmp0 : std_logic_vector(c_PIPE_IDX1_H downto 0);
  signal data_pipe_tmp1 : std_logic_vector(c_PIPE_IDX1_H downto 0);

  signal addr_rx : std_logic_vector(i_addr'range);
  signal data_rx : std_logic_vector(i_data'range);

begin

  ---------------------------------------------------------------------
  -- check address range
  ---------------------------------------------------------------------
  -- check address range of tes_pulse_shape
  inst_regdecode_pipe_addr_decode_check_addr_range_tes_pulse_shape : entity work.regdecode_pipe_addr_decode_check_addr_range
    generic map(
      g_ADDR_RANGE_WIDTH => pkg_TES_PULSE_SHAPE_ADDR_RANGE_MIN'length,  -- input address bus range width
      g_ADDR_WIDTH       => i_addr'length  -- input address bus width
      )
    port map(
      i_clk            => i_clk,
      ---------------------------------------------------------------------
      -- command
      ---------------------------------------------------------------------
      i_addr_range_min => pkg_TES_PULSE_SHAPE_ADDR_RANGE_MIN,  -- define the lowest possible address
      i_addr_range_max => pkg_TES_PULSE_SHAPE_ADDR_RANGE_MAX,  -- define the highest possible address
      ---------------------------------------------------------------------
      -- input data
      ---------------------------------------------------------------------
      i_data_valid     => i_data_valid,    -- input address valid
      i_addr           => i_addr,       -- address value
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_data_valid     => tes_pulse_shape_wr_en              -- write enable
      );

  -- check address range of amp_squid_tf
  inst_regdecode_pipe_addr_decode_check_addr_range_amp_squid_tf : entity work.regdecode_pipe_addr_decode_check_addr_range
    generic map(
      g_ADDR_RANGE_WIDTH => pkg_AMP_SQUID_TF_ADDR_RANGE_MIN'length,  -- input address bus range width
      g_ADDR_WIDTH       => i_addr'length  -- input address bus width
      )
    port map(
      i_clk            => i_clk,
      ---------------------------------------------------------------------
      -- command
      ---------------------------------------------------------------------
      i_addr_range_min => pkg_AMP_SQUID_TF_ADDR_RANGE_MIN,  -- define the lowest possible address
      i_addr_range_max => pkg_AMP_SQUID_TF_ADDR_RANGE_MAX,  -- define the highest possible address
      ---------------------------------------------------------------------
      -- input data
      ---------------------------------------------------------------------
      i_data_valid     => i_data_valid,    -- input address valid
      i_addr           => i_addr,       -- address value
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_data_valid     => amp_squid_tf_wr_en              -- write enable
      );

  -- check address range of mux_squid_tf
  inst_regdecode_pipe_addr_decode_check_addr_range_mux_squid_tf : entity work.regdecode_pipe_addr_decode_check_addr_range
    generic map(
      g_ADDR_RANGE_WIDTH => pkg_MUX_SQUID_TF_ADDR_RANGE_MIN'length,  -- input address bus range width
      g_ADDR_WIDTH       => i_addr'length  -- input address bus width
      )
    port map(
      i_clk            => i_clk,
      ---------------------------------------------------------------------
      -- command
      ---------------------------------------------------------------------
      i_addr_range_min => pkg_MUX_SQUID_TF_ADDR_RANGE_MIN,  -- define the lowest possible address
      i_addr_range_max => pkg_MUX_SQUID_TF_ADDR_RANGE_MAX,  -- define the highest possible address
      ---------------------------------------------------------------------
      -- input data
      ---------------------------------------------------------------------
      i_data_valid     => i_data_valid,    -- input address valid
      i_addr           => i_addr,       -- address value
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_data_valid     => mux_squid_tf_wr_en              -- write enable
      );

  -- check address range of tes_std_state
  inst_regdecode_pipe_addr_decode_check_addr_range_tes_std_state : entity work.regdecode_pipe_addr_decode_check_addr_range
    generic map(
      g_ADDR_RANGE_WIDTH => pkg_TES_STD_STATE_ADDR_RANGE_MIN'length,  -- input address bus range width
      g_ADDR_WIDTH       => i_addr'length  -- input address bus width
      )
    port map(
      i_clk            => i_clk,
      ---------------------------------------------------------------------
      -- command
      ---------------------------------------------------------------------
      i_addr_range_min => pkg_TES_STD_STATE_ADDR_RANGE_MIN,  -- define the lowest possible address
      i_addr_range_max => pkg_TES_STD_STATE_ADDR_RANGE_MAX,  -- define the highest possible address
      ---------------------------------------------------------------------
      -- input data
      ---------------------------------------------------------------------
      i_data_valid     => i_data_valid,    -- input address valid
      i_addr           => i_addr,       -- address value
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_data_valid     => tes_std_state_wr_en              -- write enable
      );

  -- check address range of mux_squid_offset
  inst_regdecode_pipe_addr_decode_check_addr_range_mux_squid_offset : entity work.regdecode_pipe_addr_decode_check_addr_range
    generic map(
      g_ADDR_RANGE_WIDTH => pkg_MUX_SQUID_OFFSET_ADDR_RANGE_MIN'length,  -- input address bus range width
      g_ADDR_WIDTH       => i_addr'length  -- input address bus width
      )
    port map(
      i_clk            => i_clk,
      ---------------------------------------------------------------------
      -- command
      ---------------------------------------------------------------------
      i_addr_range_min => pkg_MUX_SQUID_OFFSET_ADDR_RANGE_MIN,  -- define the lowest possible address
      i_addr_range_max => pkg_MUX_SQUID_OFFSET_ADDR_RANGE_MAX,  -- define the highest possible address
      ---------------------------------------------------------------------
      -- input data
      ---------------------------------------------------------------------
      i_data_valid     => i_data_valid,    -- input address valid
      i_addr           => i_addr,       -- address value
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_data_valid     => mux_squid_offset_wr_en              -- write enable
      );

  ---------------------------------------------------------------------
  -- sync with wr en signalq
  ---------------------------------------------------------------------
  data_pipe_tmp0(c_PIPE_IDX1_H downto c_PIPE_IDX1_L) <= i_addr;
  data_pipe_tmp0(c_PIPE_IDX0_H downto c_PIPE_IDX0_L) <= i_data;
  inst_pipeliner_sync_with_wr_en_out : entity work.pipeliner
    generic map(
      g_NB_PIPES   => c_PIPE_DELAY,
      g_DATA_WIDTH => data_pipe_tmp0'length
      )
    port map(
      i_clk  => i_clk,
      i_data => data_pipe_tmp0,
      o_data => data_pipe_tmp1
      );

  addr_rx <= data_pipe_tmp1(c_PIPE_IDX1_H downto c_PIPE_IDX1_L);
  data_rx <= data_pipe_tmp1(c_PIPE_IDX0_H downto c_PIPE_IDX0_L);

  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_tes_pulse_shape_wr_en  <= tes_pulse_shape_wr_en;
  o_amp_squid_tf_wr_en     <= amp_squid_tf_wr_en;
  o_mux_squid_tf_wr_en     <= mux_squid_tf_wr_en;
  o_tes_std_state_wr_en    <= tes_std_state_wr_en;
  o_mux_squid_offset_wr_en <= mux_squid_offset_wr_en;

  o_addr <= addr_rx;
  o_data <= data_rx;

end architecture RTL;
