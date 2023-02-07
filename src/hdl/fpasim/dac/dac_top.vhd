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
--    @file                   dac_top.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--   @details                
--
--   This module generates frame flags.
--
--   The output data flow has the following structure:
--
--   Example0: After the startup, we assume the dac frame is inserte only once
--     i_dac_valid:   1   1   1   1   1   1   1   1   
--     i_dac      :   a1  a2  a3  a4  a5  a6  a7  a8  
--     o_dac_valid:   1   1   1   1   1   1   1   1  
--     o_dac_frame:   1   0   0   0   0   0   0   0   
--     o_dac      :   a1  a2  a3  a4  a5  a6  a7  a8  
--
-- -------------------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

use work.pkg_fpasim.all;


entity dac_top is
  generic(
    g_DAC_DELAY_WIDTH : positive := 6  -- delay bus width (expressed in bits). Possible values [1; max integer value[
    );
  port(
    ---------------------------------------------------------------------
    -- input
    ---------------------------------------------------------------------
    i_clk       : in  std_logic;        -- clock
    i_rst       : in  std_logic;        -- reset
    -- from regdecode
    -----------------------------------------------------------------
    i_dac_delay : in  std_logic_vector(g_DAC_DELAY_WIDTH - 1 downto 0);  -- delay to apply on the data path.
    -- input data 
    ---------------------------------------------------------------------
    i_dac_valid : in  std_logic;        -- valid dac sample flag
    i_dac       : in  std_logic_vector(15 downto 0);  -- dac sample
    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    o_dac_valid : out std_logic;        -- valid dac sample
    o_dac_frame : out std_logic;        -- first sample of a frame
    o_dac       : out std_logic_vector(15 downto 0)   -- output dac sample
    );
end entity dac_top;

architecture RTL of dac_top is
  
  constant c_LATENCY_OUT       : natural := pkg_DAC_OUT_LATENCY;

  ---------------------------------------------------------------------
  -- dac_frame_generator
  ---------------------------------------------------------------------
  signal dac_frame_r1 : std_logic;
  signal dac_valid_r1 : std_logic;
  signal dac_r1       : std_logic_vector(i_dac'range);

  ---------------------------------------------------------------------
  -- dynamic_shift_register
  ---------------------------------------------------------------------
  constant c_IDX0_L : integer := 0;
  constant c_IDX0_H : integer := c_IDX0_L + i_dac'length - 1;

  constant c_IDX1_L : integer := c_IDX0_H + 1;
  constant c_IDX1_H : integer := c_IDX1_L + 1 - 1;

  constant c_IDX2_L : integer := c_IDX1_H + 1;
  constant c_IDX2_H : integer := c_IDX2_L + 1 - 1;

  signal data_pipe_tmp0 : std_logic_vector(c_IDX2_H downto 0);
  signal data_pipe_tmp1 : std_logic_vector(c_IDX2_H downto 0);

  signal dac_valid_rx : std_logic;
  signal dac_frame_rx : std_logic;
  signal dac_rx       : std_logic_vector(i_dac'range);

   ---------------------------------------------------------------------
  -- output pipe
  ---------------------------------------------------------------------
  signal data_pipe_tmp2 : std_logic_vector(c_IDX2_H downto 0);
  signal data_pipe_tmp3 : std_logic_vector(c_IDX2_H downto 0);

  signal dac_valid_ry : std_logic;
  signal dac_frame_ry : std_logic;
  signal dac_ry       : std_logic_vector(i_dac'range);


begin


  ---------------------------------------------------------------------
  -- build the frame signal
  ---------------------------------------------------------------------
  inst_dac_frame_generator : entity work.dac_frame_generator
    generic map (
       g_DATA_WIDTH => i_dac'length
       )
    port map(
      i_clk        => i_clk,            -- clock signal
      i_rst        => i_rst,
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_data_valid => i_dac_valid,      -- input valid sample
      i_data       => i_dac,
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_sof        => dac_frame_r1,     -- first sample of the frame
      o_data_valid => dac_valid_r1,      -- output valid sample
      o_data       => dac_r1
      );


  ---------------------------------------------------------------------
  -- apply a dynamic delay on the data path
  --   . the latency is 1 clock cycle when i_dac_delay = 0
  ---------------------------------------------------------------------
  data_pipe_tmp0(c_IDX2_H)                 <= dac_valid_r1;
  data_pipe_tmp0(c_IDX1_H)                 <= dac_frame_r1;
  data_pipe_tmp0(c_IDX0_H downto c_IDX0_L) <= dac_r1;

  inst_dynamic_shift_register_dac : entity work.dynamic_shift_register
    generic map(
      g_ADDR_WIDTH => i_dac_delay'length,  -- width of the address. Possibles values: [2, integer max value[ 
      g_DATA_WIDTH => data_pipe_tmp0'length  -- width of the input/output data.  Possibles values: [1, integer max value[
      )
    port map(
      i_clk  => i_clk,                  -- clock signal
      i_data => data_pipe_tmp0,         -- input data
      i_addr => i_dac_delay,  -- input address (dynamically select the depth of the pipeline)
      o_data => data_pipe_tmp1          -- output data with/without delay
      );

  dac_valid_rx <= data_pipe_tmp1(c_IDX2_H);
  dac_frame_rx <= data_pipe_tmp1(c_IDX1_H);
  dac_rx       <= data_pipe_tmp1(c_IDX0_H downto c_IDX0_L);


  ---------------------------------------------------------------------
  -- optionnal output pipe
  ---------------------------------------------------------------------
  data_pipe_tmp2(c_IDX2_H)                 <= dac_valid_rx;
  data_pipe_tmp2(c_IDX1_H)                 <= dac_frame_rx;
  data_pipe_tmp2(c_IDX0_H downto c_IDX0_L) <= dac_rx;
  inst_pipeliner : entity work.pipeliner
    generic map(
      g_NB_PIPES   => c_LATENCY_OUT,
      g_DATA_WIDTH => data_pipe_tmp2'length
    )
    port map(
      i_clk  => i_clk,
      i_data => data_pipe_tmp2,
      o_data => data_pipe_tmp3
    );
  dac_valid_ry  <= data_pipe_tmp3(c_IDX2_H);
  dac_frame_ry  <= data_pipe_tmp3(c_IDX1_H);
  dac_ry        <= data_pipe_tmp3(c_IDX0_H downto c_IDX0_L);



  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_dac_valid <= dac_valid_ry;
  o_dac_frame <= dac_frame_ry;
  o_dac       <= dac_ry;
end architecture RTL;
