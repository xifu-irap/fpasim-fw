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
--    @file                   synchronous_reset_pulse.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This module generate an output user-defined reset pulse width from a synchronized input reset.
--
--    The architecture principle is as follows:
--        @i_clk: source clock domain
--                         <--------g_DEST_FF------>
--         i_rst ---------------------------------->
--                         |        |              |
--         not(g_INIT) -> FF  -->  FF --> ... --> FF ---> o_rst
--
--    Note: we assume the input reset (i_rst) is already synchronized to @i_clk
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity synchronous_reset_pulse is
  generic (
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | DEST_SYNC_FF         | Integer            | Range: 1 - max integer value. Default value = 4.                        |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Number of register stages used to define the reset pulse width
    g_DEST_FF : integer := 4;
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | INIT                 | Integer            | Allowed values: 1, 0. Default value = 1.                                |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | 0- Initializes registers to 0                                                                                       |
    -- | 1- Initializes registers to 1                                                                                       |
    g_INIT    : integer := 1
    );
  port (
    ---------------------------------------------------------------------
    -- source
    ---------------------------------------------------------------------
    i_clk : in  std_logic; -- clock
    i_rst : in  std_logic; -- reset
    ---------------------------------------------------------------------
    -- destination @i_clk
    ---------------------------------------------------------------------
    o_rst : out std_logic -- output reset with a user-defined pulse_width
    );
end entity synchronous_reset_pulse;

architecture RTL of synchronous_reset_pulse is

  -- register value on reset signal
  constant c_RST_INIT : std_logic := to_unsigned(g_INIT, 1)(0);

  -- shift register
  signal rst_pipe     : std_logic_vector(g_DEST_FF - 1 downto 0):= (others => c_RST_INIT);

begin

  ---------------------------------------------------------------------
  -- shift registers
  --   On reset signal, all registers are set to the c_RST_INIT value
  ---------------------------------------------------------------------
  p_rst_ff : process (i_clk) is
  begin
    if rising_edge(i_clk) then
      if i_rst = '1' then
        rst_pipe <= (others => c_RST_INIT);
      else
        rst_pipe <= rst_pipe(rst_pipe'high - 1 downto 0) & not(c_RST_INIT);
      end if;
    end if;
  end process p_rst_ff;

---------------------------------------------------------------------
-- output
---------------------------------------------------------------------
  o_rst <= rst_pipe(rst_pipe'high);

end architecture RTL;
