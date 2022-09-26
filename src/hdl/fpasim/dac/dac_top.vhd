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
--!   @file                   dac_top.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--
-- This module generates frame flags and inserts zeros after each FIFO read.
-- The output data flow has the following structure:
--
-- Example0: we assume the dac frame is generated every 8 input dac samples and no latency between the input and the output
-- i_dac_valid:   1   1   1   1   1   1   1   1   
-- i_dac      :   a1  a2  a3  a4  a5  a6  a7  a8  
-- o_dac_valid:   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1
-- o_dac_frame:   1   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   1
-- o_dac      :   a1  0   a2  0   a3  0   a4  0   a5  0   a6  0   a7  0   a8  0   a9 
--
-- -------------------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library fpasim;

entity dac_top is
  generic(
    g_DAC_DELAY_WIDTH : positive := 6 -- delay bus width (expressed in bits). Possible values [1; max integer value[
  );
  port(
    ---------------------------------------------------------------------
    -- input @i_clk
    ---------------------------------------------------------------------
    i_clk         : in  std_logic;      -- clock
    i_rst         : in  std_logic;      -- reset
    -- from regdecode
    -----------------------------------------------------------------
    i_rst_status  : in  std_logic;      -- reset error flag(s)
    i_debug_pulse : in  std_logic;      -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
    i_en          : in  std_logic;      -- enable
    i_dac_delay   : in  std_logic_vector(g_DAC_DELAY_WIDTH - 1 downto 0); -- delay to apply on the data path.
    -- input data 
    ---------------------------------------------------------------------
    i_dac_valid   : in  std_logic;      -- valid dac sample flag
    i_dac         : in  std_logic_vector(15 downto 0); -- dac sample
    ---------------------------------------------------------------------
    -- output @i_clk_dac
    ---------------------------------------------------------------------
    i_dac_clk     : in  std_logic;      -- dac clock
    o_dac_valid   : out std_logic;      -- valid dac sample
    o_dac_frame   : out std_logic;      -- first sample of a frame
    o_dac         : out std_logic_vector(15 downto 0); -- output dac sample
    ---------------------------------------------------------------------
    -- errors/status @i_clk
    --------------------------------------------------------------------- 
    o_errors      : out std_logic_vector(15 downto 0); -- output errors
    o_status      : out std_logic_vector(7 downto 0) -- output status
  );
end entity dac_top;

architecture RTL of dac_top is
  constant c_DAC_FRAME_SIZE : positive := fpasim.pkg_fpasim.pkg_DAC_FRAME_SIZE;

  -------------------------------------------------------------------
  -- cross clock domain
  -------------------------------------------------------------------
  signal rst_sync : std_logic;

  ---------------------------------------------------------------------
  -- apply delay
  ---------------------------------------------------------------------
  signal dac_sof_r1   : std_logic;
  signal dac_valid_r1 : std_logic;
  signal dac_rx       : std_logic_vector(i_dac'range);

  ---------------------------------------------------------------------
  -- dac_data_insert
  ---------------------------------------------------------------------
  signal dac_valid2 : std_logic;
  signal dac_frame2 : std_logic;
  signal dac2       : std_logic_vector(o_dac'range);
  signal errors2    : std_logic_vector(o_errors'range);
  signal status2    : std_logic_vector(o_status'range);

  ---------------------------------------------------------------------
  -- dac_data_insert
  ---------------------------------------------------------------------
  signal error3 : std_logic;

begin
  -------------------------------------------------------------------
  -- cross clock domain
  -------------------------------------------------------------------
  inst_synchronous_reset_synchronizer_rst_dac : entity work.synchronous_reset_synchronizer
    generic map(
      g_DEST_SYNC_FF => 2,
      g_INIT         => 1
    )
    port map(
      ---------------------------------------------------------------------
      -- source
      ---------------------------------------------------------------------
      i_src_rst  => i_rst,              -- Source reset signal
      ---------------------------------------------------------------------
      -- destination
      ---------------------------------------------------------------------
      i_dest_clk => i_dac_clk,          -- Destination clock.
      o_dest_rst => rst_sync            -- src_rst synchronized to the destination clock domain. This output is registered.
    );


  ---------------------------------------------------------------------
  -- apply a dynamic delay on the data path
  --   . the latency is 1 clock cycle when i_dac_delay = 0
  ---------------------------------------------------------------------
  inst_dynamic_shift_register_dac : entity work.dynamic_shift_register
    generic map(
      g_ADDR_WIDTH => i_dac_delay'length, -- width of the address. Possibles values: [2, integer max value[ 
      g_DATA_WIDTH => i_dac'length    -- width of the input/output data.  Possibles values: [1, integer max value[
    )
    port map(
      i_clk        => i_clk,            -- clock signal
      i_data_valid => i_dac_valid,      -- input data valid
      i_data       => i_dac,          -- input data
      i_addr       => i_dac_delay,      -- input address (dynamically select the depth of the pipeline)
      o_data       => dac_rx            -- output data with/without delay
    );

  ---------------------------------------------------------------------
  -- build a frame:
  --   . 1 clock latency
  --   . the dac_valid_r1 is synchronized with dac_rx when i_dac_delay = 0
  ---------------------------------------------------------------------
  dac_frame_generator_INST : entity fpasim.dac_frame_generator
    generic map(
      g_FRAME_SIZE => c_DAC_FRAME_SIZE  -- frame size. Possible values: [2;integer max value[
    )
    port map(
      i_clk        => i_clk,            -- clock signal
      i_rst        => i_rst,
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_data_valid => i_dac_valid,      -- input valid sample
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_sof        => dac_sof_r1,       -- first sample of the frame
      o_eof        => open,             -- last sample of the frame
      o_data_valid => dac_valid_r1      -- output valid sample
    );

  inst_dac_data_insert : entity fpasim.dac_data_insert
    generic map(
      g_DAC_WIDTH => dac_rx'length
    )
    port map(
      ---------------------------------------------------------------------
      -- input @i_clk
      ---------------------------------------------------------------------
      i_clk         => i_clk,
      i_rst         => i_rst,
      i_rst_status  => i_rst_status,
      i_debug_pulse => i_debug_pulse,
      i_dac_valid   => dac_valid_r1,
      i_dac_frame   => dac_sof_r1,
      i_dac         => dac_rx,
      ---------------------------------------------------------------------
      -- output @i_dac_ckl
      ---------------------------------------------------------------------
      i_dac_clk     => i_dac_clk,
      i_dac_rst     => rst_sync,
      o_dac_valid   => dac_valid2,
      o_dac_frame   => dac_frame2,
      o_dac         => dac2,
      ---------------------------------------------------------------------
      -- errors/status @i_clk
      ---------------------------------------------------------------------
      o_errors      => errors2,
      o_status      => status2
    );

---------------------------------------------------------------------
-- check if no hole in the output data flow
---------------------------------------------------------------------
  inst_dac_check_dataflow : entity fpasim.dac_check_dataflow
    port map(
      ---------------------------------------------------------------------
      -- input @i_dac_clk
      ---------------------------------------------------------------------
      i_dac_clk     => i_dac_clk,
      i_dac_rst     => rst_sync,
      i_dac_valid   => dac_valid2,
      ---------------------------------------------------------------------
      -- error @i_clk
      ---------------------------------------------------------------------
      i_clk         => i_clk,
      i_rst_status  => i_rst_status,
      i_debug_pulse => i_debug_pulse,
      i_en          => i_en,
      o_error       => error3
    );

  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_dac_valid <= dac_valid2;
  o_dac_frame <= dac_frame2;
  o_dac       <= dac2;

  o_errors(15)          <= error3;
  o_errors(14 downto 0) <= errors2(14 downto 0);
  o_status              <= status2;

end architecture RTL;
