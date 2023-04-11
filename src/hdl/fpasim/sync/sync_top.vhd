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
--    @file                   sync_top.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details                
--
--    This module can dynamically delays the input pulse sync signal by a user-defined value.
--    Then it generates from it a pulse with a static user-defined duration.
--
--    Example0:
--     g_PULSE_DURATION |   3 
--     i_sync_valid     |   1   1   1   1   1   1   1   1   1   1
--     i_sync           |   1   0   0   0   0   1   0   0   0   0
--     o_sync_valid     |   x   1   1   1   0   0   1   1   1   0
--     o_sync           |   x   1   1   1   0   0   1   1   1   0
--
-- -------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use work.pkg_fpasim.all;

entity sync_top is
  generic(
    g_PULSE_DURATION   : positive := 2; -- duration of the output pulse. Possible values [1;integer max value[
    g_SYNC_DELAY_WIDTH : positive := 6  -- delay bus width (expressed in bits). Possible values [1;integer max value[
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
    i_sync_delay  : in  std_logic_vector(g_SYNC_DELAY_WIDTH - 1 downto 0); -- delay to apply on the data path.

    -- input data 
    ---------------------------------------------------------------------
    i_sync_valid  : in  std_logic;      -- valid sync sample
    i_sync        : in  std_logic;      -- sync sample
    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    o_sync_valid  : out std_logic;      -- valid sync sample
    o_sync        : out std_logic;      -- sync sample
    ---------------------------------------------------------------------
    -- errors
    --------------------------------------------------------------------- 
    o_errors      : out std_logic_vector(15 downto 0) -- output errors
  );
end entity sync_top;

architecture RTL of sync_top is

  constant c_LATENCY_OUT       : natural := pkg_SYNC_OUT_LATENCY;

  ---------------------------------------------------------------------
  -- sync_pulse_generator
  ---------------------------------------------------------------------
  signal sync_valid_r1            : std_logic;
  signal sync_r1                  : std_logic;
  signal error_pulse_generator_r1 : std_logic;

  ---------------------------------------------------------------------
  -- dynamic_shift_register
  ---------------------------------------------------------------------
  constant c_IDX0_L : integer := 0;
  constant c_IDX0_H : integer := c_IDX0_L + 1 - 1;

  constant c_IDX1_L : integer := c_IDX0_H + 1;
  constant c_IDX1_H : integer := c_IDX1_L + 1 - 1;


  signal data_pipe_tmp0 : std_logic_vector(c_IDX1_H downto 0);
  signal data_pipe_tmp1 : std_logic_vector(c_IDX1_H downto 0);

  signal sync_valid_rx : std_logic;
  signal sync_rx       : std_logic;

  ---------------------------------------------------------------------
  -- output pipe
  ---------------------------------------------------------------------
  signal data_pipe_tmp2 : std_logic_vector(c_IDX1_H downto 0);
  signal data_pipe_tmp3 : std_logic_vector(c_IDX1_H downto 0);

  signal sync_valid_ry : std_logic;
  signal sync_ry       : std_logic;



begin

 -----------------------------------------------------------------
  -- build pulse
  -----------------------------------------------------------------
  inst_sync_pulse_generator : entity work.sync_pulse_generator
    generic map(
      g_PULSE_DURATION => g_PULSE_DURATION -- duration of the pulse. Possible values [1;integer max value[
    )
    port map(
      i_clk         => i_clk,
      i_rst         => i_rst,
      i_rst_status  => i_rst_status,
      i_debug_pulse => i_debug_pulse,
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_sync_valid  => i_sync_valid,
      i_sync        => i_sync,
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_sync_valid  => sync_valid_r1,
      o_sync        => sync_r1,
      ---------------------------------------------------------------------
      -- errors
      ---------------------------------------------------------------------
      o_error       => error_pulse_generator_r1
    );


  ---------------------------------------------------------------------
  -- apply a dynamic delay on the data path
  --   . the latency is 1 clock cycle when i_sync_delay = 0
  -- requirement: FPASIM-FW-REQ-0240
  ---------------------------------------------------------------------
  data_pipe_tmp0(c_IDX1_H) <= sync_valid_r1;
  data_pipe_tmp0(c_IDX0_H) <= sync_r1;

  inst_dynamic_shift_register_with_valid_sync : entity work.dynamic_shift_register
    generic map(
      g_ADDR_WIDTH => i_sync_delay'length, -- width of the address. Possibles values: [2, integer max value[ 
      g_DATA_WIDTH => data_pipe_tmp0'length                 -- width of the input/output data.  Possibles values: [1, integer max value[
    )
    port map(
      i_clk     => i_clk,            -- clock signal
      i_data    => data_pipe_tmp0,           -- input data
      i_addr    => i_sync_delay,     -- input address (dynamically select the depth of the pipeline)
      o_data    => data_pipe_tmp1           -- output data with/without delay
    );

 sync_valid_rx <= data_pipe_tmp1(c_IDX1_H);
 sync_rx       <= data_pipe_tmp1(c_IDX0_H);
  ---------------------------------------------------------------------
  -- optionnal output pipe
  ---------------------------------------------------------------------
  data_pipe_tmp2(c_IDX1_H) <= sync_valid_rx;
  data_pipe_tmp2(c_IDX0_H) <= sync_rx;

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

  sync_valid_ry  <= data_pipe_tmp3(c_IDX1_H);
  sync_ry        <= data_pipe_tmp3(c_IDX0_H);

  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_sync_valid <= sync_valid_ry;
  o_sync       <= sync_ry;

  ---------------------------------------------------------------------
  -- errors
  ---------------------------------------------------------------------
  o_errors(15 downto 1) <= (others => '0');
  o_errors(0)           <= error_pulse_generator_r1;

  -----------------------------------------------------------------------
  ---- for simulation only
  -----------------------------------------------------------------------
  assert not (error_pulse_generator_r1 = '1') report "[sync_top] => detect a input pulse during the output pulse generation " severity error;

end architecture RTL;
