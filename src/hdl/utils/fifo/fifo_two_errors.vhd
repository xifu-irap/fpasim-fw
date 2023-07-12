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
--    @file                   fifo_two_errors.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--   This module checks the good utilization of a FIFO
--      Usually, the user would like to generate an error for each possible case:
--        . a write access is done on a full fifo
--        . a read access is done on an empty fifo
--
--   2 modes of error management is defined:
--      . The transparent mode: the error is delayed by one clock cycle.
--        . If the input error is a pulse then the output error will also be a pulse.
--        . If the input error is a level then the output error will also be a level.
--      . The capture mode: if the input error is set to '1', the output error is set to '1' until a reset signal is received.
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


entity fifo_two_errors is
  port (
    i_clk : in std_logic; -- clock signal
    i_rst : in std_logic; -- reset error flag(s)

    i_debug_pulse : in std_logic;-- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)

    i_fifo_cmd0   : in std_logic;-- fifo command. (Usually: wr or rd signal)
    i_fifo_flag0  : in std_logic;-- fifo flag. (usually: full or empty signal)

    i_fifo_cmd1   : in std_logic;-- fifo command. (Usually: wr or rd signal)
    i_fifo_flag1  : in std_logic;-- fifo flag. (usually: full or empty signal)

    o_error : out std_logic_vector(1 downto 0) -- output errors
    );
end entity fifo_two_errors;

architecture RTL of fifo_two_errors is

  signal error0 : std_logic:= '0'; -- output error0
  signal error1 : std_logic:= '0'; -- output error1

begin

  -- manage the error associated to (i_fifo_cmd0,i_fifo_flag0)
  inst_fifo_one_error1 : entity work.fifo_one_error
  port map(
    i_clk         => i_clk,
    i_rst         => i_rst,
    i_debug_pulse => i_debug_pulse,
    i_fifo_cmd    => i_fifo_cmd0,
    i_fifo_flag   => i_fifo_flag0,
    o_error       => error0
    );

    -- manage the error associated to (i_fifo_cmd1, i_fifo_flag1)
    inst_fifo_one_error2 : entity work.fifo_one_error
    port map(
      i_clk         => i_clk,
      i_rst         => i_rst,
      i_debug_pulse => i_debug_pulse,
      i_fifo_cmd    => i_fifo_cmd1,
      i_fifo_flag   => i_fifo_flag1,
      o_error      => error1
      );

  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_error(1) <= error1;
  o_error(0) <= error0;

end architecture RTL;
