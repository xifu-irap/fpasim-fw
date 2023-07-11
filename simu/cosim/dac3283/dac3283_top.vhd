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
--    @file                   dac3283_top.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This file is the top_level of the dac3283 (DAC) model.
--
--    Note
--      . It should be used only for the simulation
--
-- -------------------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity dac3283_top is
  generic (
    g_DAC_VPP   : natural := 2;  -- DAC differential output voltage ( Vpp expressed in Volts)
    g_DAC_DELAY : natural := 59  -- DAC conversion delay (expressed in number of clock cycles @i_dac_clk). The range is: [0;max integer value[)
    );
  port (
    ---------------------------------------------------------------------
    -- from pads
    ---------------------------------------------------------------------
    i_dac_clk_p : in std_logic;         -- differential_p dac clock
    i_dac_clk_n : in std_logic;         -- differential_n dac clock

    i_dac_frame_p : in std_logic;       -- differential_p dac frame
    i_dac_frame_n : in std_logic;       -- differential_n dac frame

    i_dac0_p : in std_logic;            -- differential_p dac data (lane0)
    i_dac0_n : in std_logic;            -- differential_n dac data (lane0)

    i_dac1_p : in std_logic;            -- differential_p dac data (lane1)
    i_dac1_n : in std_logic;            -- differential_n dac data (lane1)

    i_dac2_p : in std_logic;            -- differential_p dac data (lane2)
    i_dac2_n : in std_logic;            -- differential_n dac data (lane2)

    i_dac3_p : in std_logic;            -- differential_p dac data (lane3)
    i_dac3_n : in std_logic;            -- differential_n dac data (lane3)

    i_dac4_p : in std_logic;            -- differential_p dac data (lane4)
    i_dac4_n : in std_logic;            -- differential_n dac data (lane4)

    i_dac5_p : in std_logic;            -- differential_p dac data (lane5)
    i_dac5_n : in std_logic;            -- differential_n dac data (lane5)

    i_dac6_p : in std_logic;            -- differential_p dac data (lane6)
    i_dac6_n : in std_logic;            -- differential_n dac data (lane6)

    i_dac7_p : in std_logic;            -- differential_p dac data (lane7)
    i_dac7_n : in std_logic;            -- differential_n dac data (lane7)

    ---------------------------------------------------------------------
    -- to sim
    ---------------------------------------------------------------------
    o_dac_real_valid : out std_logic;   -- dac data valid
    o_dac_real       : out real         -- dac value

    );
end entity dac3283_top;

architecture RTL of dac3283_top is
---------------------------------------------------------------------
-- dac3283_io
---------------------------------------------------------------------
  signal dac_clk   : std_logic; -- input dac clock
  signal dac_frame : std_logic; -- input dac frame
  signal dac       : std_logic_vector(15 downto 0); -- input dac value

---------------------------------------------------------------------
-- dac3283_demux
---------------------------------------------------------------------
  signal dac0_valid : std_logic; -- dac0: data valid
  signal dac0       : std_logic_vector(15 downto 0); -- dac0: data

  signal dac1_valid : std_logic; -- dac1: data valid
  signal dac1       : std_logic_vector(15 downto 0);-- dac1: data

begin

---------------------------------------------------------------------
-- io
---------------------------------------------------------------------
  inst_dac3283_io : entity work.dac3283_io
    port map(
      ---------------------------------------------------------------------
      -- from pads
      ---------------------------------------------------------------------
      i_dac_clk_p   => i_dac_clk_p,
      i_dac_clk_n   => i_dac_clk_n,
      i_dac_frame_p => i_dac_frame_p,
      i_dac_frame_n => i_dac_frame_n,
      i_dac0_p      => i_dac0_p,
      i_dac0_n      => i_dac0_n,
      i_dac1_p      => i_dac1_p,
      i_dac1_n      => i_dac1_n,
      i_dac2_p      => i_dac2_p,
      i_dac2_n      => i_dac2_n,
      i_dac3_p      => i_dac3_p,
      i_dac3_n      => i_dac3_n,
      i_dac4_p      => i_dac4_p,
      i_dac4_n      => i_dac4_n,
      i_dac5_p      => i_dac5_p,
      i_dac5_n      => i_dac5_n,
      i_dac6_p      => i_dac6_p,
      i_dac6_n      => i_dac6_n,
      i_dac7_p      => i_dac7_p,
      i_dac7_n      => i_dac7_n,
      ---------------------------------------------------------------------
      -- to the user
      ---------------------------------------------------------------------
      o_dac_clk     => dac_clk,
      o_dac_frame   => dac_frame,
      o_dac         => dac
      );

---------------------------------------------------------------------
-- dac3283_demux
---------------------------------------------------------------------
  inst_dac3283_demux : entity work.dac3283_demux
    generic map(
      g_DAC_DELAY => g_DAC_DELAY        -- DAC conversion delay
      )
    port map(
      i_clk        => dac_clk,
      i_rst        => '0',
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_dac_frame  => dac_frame,
      i_dac        => dac,
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_dac0_valid => dac0_valid,
      o_dac0       => dac0,
      o_dac1_valid => dac1_valid,       -- not connected
      o_dac1       => dac1              -- not connected
      );

  ---------------------------------------------------------------------
  -- dac3283_convert
  ---------------------------------------------------------------------
  inst_dac3283_convert : entity work.dac3283_convert
    generic map(
      g_DAC_VPP => g_DAC_VPP  -- DAC differential output voltage ( Vpp expressed in Volts)
      )
    port map(

      i_data_valid      => dac0_valid,
      i_data            => dac0,
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_data_real_valid => o_dac_real_valid,
      o_data_real       => o_dac_real
      );

end architecture RTL;
