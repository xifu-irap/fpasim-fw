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
--    @file                   io_sync.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This module does the following steps:
--      . add an optional delay
--
--    The architecture is as follows:
--      Input ports -> optionnal latency -> fpga specific IO generation -> output port
--
-- -------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use work.pkg_io.all;

entity io_pulse is
  port(

    -- clock
    i_clk       : in std_logic;
    ---------------------------------------------------------------------
    -- input @i_clk
    ---------------------------------------------------------------------
    -- first processed sample of a pulse
    i_pulse_sof : in std_logic;

    ---------------------------------------------------------------------
    -- output @i_clk
    ---------------------------------------------------------------------
    -- first processed sample of a pulse
    o_pulse_sof : out std_logic
    );
end entity io_pulse;

architecture RTL of io_pulse is

---------------------------------------------------------------------
-- additional optional output pipeline
---------------------------------------------------------------------
  -- temporary input pipe
  signal data_pipe_tmp0 : std_logic_vector(0 downto 0);
  -- temporary output pipe
  signal data_pipe_tmp1 : std_logic_vector(0 downto 0);

  signal pulse_sof1 : std_logic;

begin

  ---------------------------------------------------------------------
  -- optional output delay
  ---------------------------------------------------------------------
  data_pipe_tmp0(0) <= i_pulse_sof;

  inst_pipeliner_out : entity work.pipeliner
    generic map(
      g_NB_PIPES   => pkg_IO_PULSE_OUT_LATENCY,  -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => data_pipe_tmp0'length  -- width of the input/output data.  Possibles values: [1, integer max value[
      )
    port map(
      i_clk  => i_clk,                  -- clock signal
      i_data => data_pipe_tmp0,         -- input data
      o_data => data_pipe_tmp1          -- output data with/without delay
      );

  pulse_sof1 <= data_pipe_tmp1(0);

---------------------------------------------------------------------
-- output
---------------------------------------------------------------------
  o_pulse_sof <= pulse_sof1;

end architecture RTL;
