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
--    @file                   led_pulse.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This module generates a user-defined pulse width with a 50% of cycle ratio.
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_utils.all;

entity led_pulse is
  generic (
     -- pulse period expressed in number of clock cycle. Should be a multiple of 2. The range is [2;inf[
     g_NB_CLK_OF_PULSE_PERIOD : integer;
     -- additional optional output delay
     g_OUTPUT_DELAY : integer := 1
     );
  port (

    ---------------------------------------------------------------------
    -- input
    ---------------------------------------------------------------------
    i_clk : in  std_logic;  -- clock

    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    o_pulse: out std_logic -- output pulse

    );
end entity led_pulse;

architecture RTL of led_pulse is

 -- counter width minimal in order to represent the g_OUTPUT_PULSE_PERIOD value
 constant c_CNT_WIDTH : integer := pkg_width_from_value(i_value=> g_NB_CLK_OF_PULSE_PERIOD);

 -- counter value
 signal cnt_r1 : unsigned(c_CNT_WIDTH - 1 downto 0):= (others => '0');

 -- pulse: change state every 0.5 periods
 signal pulse_tmp1 : std_logic;

 -- delayed pulse
 signal pulse_rx : std_logic;

begin

-- count the number of clock cycles
p_count_period_sample: process (i_clk) is
begin
  if rising_edge(i_clk) then
    cnt_r1 <= cnt_r1 + 1;
  end if;
end process p_count_period_sample;
-- pulse change state every 0.5 period
pulse_tmp1 <= cnt_r1(cnt_r1'high);

---------------------------------------------------------------------
-- optional output pipe
---------------------------------------------------------------------
gen_pulse: if true generate
  -- temorary input pipe
  signal data_tmp0 : std_logic_vector(0 downto 0);
  -- temorary output pipe
  signal data_tmp1 : std_logic_vector(0 downto 0);

  begin
    data_tmp0(0) <= pulse_tmp1;

    inst_pipeliner_pulse : entity work.pipeliner
        generic map(
          g_NB_PIPES   => g_OUTPUT_DELAY,  -- number of consecutives registers. Possibles values: [0, integer max value[
          g_DATA_WIDTH => data_tmp0'length  -- width of the input/output data.  Possibles values: [1, integer max value[
          )
        port map(
          i_clk  => i_clk,                  -- clock signal
          i_data => data_tmp0,     -- input data
          o_data => data_tmp1  -- output data with/without delay
          );

    pulse_rx <= data_tmp1(0);
end generate gen_pulse;

---------------------------------------------------------------------
-- output
---------------------------------------------------------------------
o_pulse <= pulse_rx;

end architecture RTL;
