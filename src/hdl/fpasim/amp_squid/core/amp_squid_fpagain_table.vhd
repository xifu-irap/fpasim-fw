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
--    @file                   amp_squid_fpagain_table.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
-- This module outputs a pre-defined fpasim_gain value from a user-defined command
--
-- Note:
--   . The gain table is stored into a ROM.
--   . By design, the selected gain value is registered on the first pixel sample of each pixel.
--     So, the gain value is stable on the pixel duration.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

entity amp_squid_fpagain_table is
  generic(
    -- port S: AMD Q notation (fixed point)
    g_Q_M_S        : in positive := 4;   -- number of bits used for the integer part of the value ( sign bit included). Possible values [0;integer_max_value[
    g_Q_N_S        : in natural := 2;   -- number of fraction bits. Possible values [0;integer_max_value[
    g_LATENCY_OUT : in natural := 0 -- optional: add output latency. Possible values [0;integer_max_value[
  );
  port(
    i_clk         : in  std_logic;      -- clock signal

    ---------------------------------------------------------------------
    -- from regdecode
    ---------------------------------------------------------------------
    i_fpasim_gain : in  std_logic_vector(2 downto 0); -- fpagain selector

    ---------------------------------------------------------------------
    -- input
    ---------------------------------------------------------------------
    i_pixel_sof   : in  std_logic;      -- first pixel sample
    i_pixel_valid : in  std_logic;      -- valid pixel sample
    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    o_fpasim_gain : out std_logic_vector(g_Q_M_S + g_Q_N_S - 1 downto 0) -- output fpagain
  );
end entity amp_squid_fpagain_table;

architecture RTL of amp_squid_fpagain_table is
  signal gain_r1   : sfixed(g_Q_M_S - 1 downto -g_Q_N_S):= (others => '0');
  signal gain_tmp0 : std_logic_vector(o_fpasim_gain'range);
  signal gain_tmp1 : std_logic_vector(o_fpasim_gain'range);

begin

---------------------------------------------------------------------
-- convert command to fpasim_gain
-- requirement: FPASIM-FW-REQ-0190
---------------------------------------------------------------------
  p_table : process(i_clk) is
  begin
    if rising_edge(i_clk) then
      if i_pixel_valid = '1' and i_pixel_sof = '1' then
        case i_fpasim_gain is
          when "000" =>                 -- 0
            gain_r1 <= to_sfixed(0.25, gain_r1);
          when "001" =>                 -- 1
            gain_r1 <= to_sfixed(0.5, gain_r1);
          when "010" =>                 -- 2
            gain_r1 <= to_sfixed(0.75, gain_r1);
          when "011" =>                 -- 3
            gain_r1 <= to_sfixed(1, gain_r1);
          when "100" =>                 -- 4
            gain_r1 <= to_sfixed(1.5, gain_r1);
          when "101" =>                 -- 5
            gain_r1 <= to_sfixed(2, gain_r1);
          when "110" =>                 -- 6
            gain_r1 <= to_sfixed(3, gain_r1);
          when others =>                 -- 7
            gain_r1 <= to_sfixed(4, gain_r1);
        end case;
      end if;
    end if;
  end process p_table;

  gain_tmp0 <= to_slv(gain_r1);

  -------------------------------------------------------------------
  -- optionnal: add output latency
  -------------------------------------------------------------------
  inst_pipeliner_gain_out : entity work.pipeliner
    generic map(
      g_NB_PIPES   => g_LATENCY_OUT,   -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => gain_tmp0'length  -- width of the input/output data.  Possibles values: [1, integer max value[
    )
    port map(
      i_clk  => i_clk,                  -- clock signal
      i_data => gain_tmp0,              -- input data
      o_data => gain_tmp1               -- output data with/without delay
    );

  o_fpasim_gain <= gain_tmp1;

end architecture RTL;
