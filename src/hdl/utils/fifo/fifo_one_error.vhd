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
--    @file                   fifo_one_error.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This module checks the good utilization of a FIFO
--       Usually, the user would like to generate an error in the following cases:
--         . a write access is done on a full fifo or
--         . a read access is done on an empty fifo
--
--   2 modes of error management is defined:
--      . The transparent mode: the error is delayed by one clock cycle.
--        . If the input error is a pulse then the output error will also be a pulse.
--        . If the input error is a level then the output error will also be a level.
--      . The capture mode: if the input error is set to '1', the output error is set to '1' until a reset signal is received
--
-- -------------------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity fifo_one_error is
  port (
    i_clk         : in  std_logic; -- clock signal
    i_rst         : in  std_logic; -- reset error flag
    i_debug_pulse : in  std_logic; -- error mode (transparent vs capture). Possible values: '1': delay the error, '0': capture the error
    i_fifo_cmd    : in  std_logic; -- fifo command. (Usually: wr or rd signal)
    i_fifo_flag   : in  std_logic; -- fifo flag. (usually: full or empty signal)
    o_error      : out std_logic   -- output error (delayed or latch)
    );
end entity fifo_one_error;

architecture RTL of fifo_one_error is

  signal error_pulse_r1 : std_logic := '0'; -- error
  signal error_r2       : std_logic := '0'; -- error pulse or latched error.

begin

  ---------------------------------------------------------------------
  -- This process is constitued by 2 steps:
  --   1. Generate an error on an input condition.
  --   2. latch or not the error (user-defined).
  ---------------------------------------------------------------------
  p_detect_error : process (i_clk) is
  begin
    if rising_edge(i_clk) then
      -- step1: generate an error
      if i_fifo_cmd = '1' and i_fifo_flag = '1' then
        error_pulse_r1 <= '1';
      else
        error_pulse_r1 <= '0';
      end if;

      -- Step2 : latch or not an error
      if i_rst = '1' then
        error_r2 <= '0';
      elsif i_debug_pulse = '1' then
        -- delay an error
        error_r2 <= error_pulse_r1;
      elsif error_pulse_r1 = '1' then
        -- latch an error
        error_r2 <= '1';
      end if;
    end if;
  end process p_detect_error;

  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_error <= error_r2;

end architecture RTL;
