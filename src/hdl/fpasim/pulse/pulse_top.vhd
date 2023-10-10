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
--    @file                   pulse_top.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    From an input pulse, this module generates an output pulse with a user-defined pulse width.
--
--    Example0:
--     g_PULSE_DURATION |   3
--     i_pulse_valid     |   1   1   1   1   1   1   1   1   1   1
--     i_pulse           |   1   0   0   0   0   1   0   0   0   0
--     o_pulse_valid     |   x   1   1   1   0   0   1   1   1   0
--     o_pulse           |   x   1   1   1   0   0   1   1   1   0
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_fpasim.all;


entity pulse_top is
  generic(
    g_PULSE_DURATION : positive := 1  -- duration of the pulse. Possible values [1;integer max value[
    );
  port(
    -- clock
    i_clk         : in  std_logic;
    -- reset
    i_rst         : in  std_logic;
    -- reset error flag(s)
    i_rst_status  : in  std_logic;
    -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
    i_debug_pulse : in  std_logic;
    ---------------------------------------------------------------------
    -- input
    ---------------------------------------------------------------------
    -- pulse valid
    i_pulse_valid : in  std_logic;
    -- pulse sof
    i_pulse_sof   : in  std_logic;
    -- pulse eof
    i_pulse_eof   : in  std_logic;
    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    -- output pulse valid
    o_pulse_valid : out std_logic;
    -- output pulse sof with user-defined width
    o_pulse_sof   : out std_logic;
    -- output pulse eof with user-defined width
    o_pulse_eof   : out std_logic;
    ---------------------------------------------------------------------
    -- errors
    ---------------------------------------------------------------------
    o_errors      : out std_logic_vector(15 downto 0)  -- output error
    );
end entity pulse_top;

architecture RTL of pulse_top is

---------------------------------------------------------------------
-- pulse generator (sof)
---------------------------------------------------------------------
-- pulse valid
signal pulse_valid0     : std_logic;
-- pulse sof (user-defined pulse width)
signal pulse_sof0       : std_logic;
-- associated pulse generator error
signal pulse_error_sof0 : std_logic;

---------------------------------------------------------------------
-- pulse generator
---------------------------------------------------------------------
-- pulse eof (user-defined pulse width)
signal pulse_eof0       : std_logic;
-- associated pulse generator error
signal pulse_error_eof0 : std_logic;

---------------------------------------------------------------------
-- additional optional output pipeline
---------------------------------------------------------------------
-- temporary input pipe
signal data_pipe_tmp0 : std_logic_vector(2 downto 0);
-- temporary output pipe
signal data_pipe_tmp1 : std_logic_vector(2 downto 0);

-- delayed pulse valid
signal pulse_valid1 : std_logic;
-- delayed pulse_sof
signal pulse_sof1   : std_logic;
-- delayed pulse_eof
signal pulse_eof1   : std_logic;

begin

  inst_pulse_generator_sof : entity work.pulse_generator
    generic map(
      g_PULSE_DURATION => g_PULSE_DURATION  -- duration of the pulse. Possible values [1;integer max value[
      )
    port map(
      i_clk         => i_clk,           -- clock
      i_rst         => i_rst,           -- reset
      i_rst_status  => i_rst_status,    -- reset error flag(s)
      i_debug_pulse => i_debug_pulse,  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_pulse_valid => i_pulse_valid,   -- pulse valid
      i_pulse       => i_pulse_sof,     -- pulse (1 clock cycle)
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_pulse_valid => pulse_valid0,    -- output pulse valid
      o_pulse       => pulse_sof0,      -- output pulse with user-defined width
      ---------------------------------------------------------------------
      -- errors
      ---------------------------------------------------------------------
      o_error       => pulse_error_sof0     -- output error
      );

  inst_pulse_generator_eof : entity work.pulse_generator
    generic map(
      g_PULSE_DURATION => g_PULSE_DURATION  -- duration of the pulse. Possible values [1;integer max value[
      )
    port map(
      i_clk         => i_clk,           -- clock
      i_rst         => i_rst,           -- reset
      i_rst_status  => i_rst_status,    -- reset error flag(s)
      i_debug_pulse => i_debug_pulse,  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_pulse_valid => i_pulse_valid,   -- pulse valid
      i_pulse       => i_pulse_eof,     -- pulse (1 clock cycle)
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_pulse_valid => open,            -- output pulse valid
      o_pulse       => pulse_eof0,      -- output pulse with user-defined width
      ---------------------------------------------------------------------
      -- errors
      ---------------------------------------------------------------------
      o_error       => pulse_error_eof0     -- output error
      );

  ---------------------------------------------------------------------
  -- optional output delay
  ---------------------------------------------------------------------
  data_pipe_tmp0(2) <= pulse_valid0;
  data_pipe_tmp0(1) <= pulse_sof0;
  data_pipe_tmp0(0) <= pulse_eof0;

  inst_pipeliner_out : entity work.pipeliner
    generic map(
      g_NB_PIPES   => pkg_PULSE_OUTPUT_LATENCY,  -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => data_pipe_tmp0'length  -- width of the input/output data.  Possibles values: [1, integer max value[
      )
    port map(
      i_clk  => i_clk,                  -- clock signal
      i_data => data_pipe_tmp0,         -- input data
      o_data => data_pipe_tmp1          -- output data with/without delay
      );

  pulse_valid1 <= data_pipe_tmp1(2);
  pulse_sof1   <= data_pipe_tmp1(1);
  pulse_eof1   <= data_pipe_tmp1(0);

---------------------------------------------------------------------
-- output
---------------------------------------------------------------------
  o_pulse_valid <= pulse_valid1;
  o_pulse_sof   <= pulse_sof1;
  o_pulse_eof   <= pulse_eof1;

---------------------------------------------------------------------
-- errors
---------------------------------------------------------------------
  o_errors(15 downto 2) <= (others => '0');
  o_errors(1)           <= pulse_error_sof0;
  o_errors(0)           <= pulse_error_eof0;

-----------------------------------------------------------------------
---- for simulation only
-----------------------------------------------------------------------
  assert not (pulse_error_sof0 = '1') report "[pulse_top] => detect an input pulse during the output pulse generation (sof) " severity error;
  assert not (pulse_error_eof0 = '1') report "[pulse_top] => detect an input pulse during the output pulse generation (eof) " severity error;

end architecture RTL;
