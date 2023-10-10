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
--    @file                   fpga_system_fpasim.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This module wraps the fpasim function with the DAC and ADC model.
--
--    Note:
--      . This file should be used during the co-simulation phase
--      . The spi/leds signals of the system_fpasim_top are not necessary for the co-simulation with the demux
--      . This file should only be used for simulation.
--
-- -------------------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity fpga_system_fpasim is
  generic (
    -- ADC
    g_ADC_VPP   : natural := 2;  -- ADC differential input voltage ( Vpp expressed in Volts)
    g_ADC_DELAY : natural := 0;  -- ADC conversion delay (expressed in number of clock cycles @i_adc_clk). The range is: [0;max integer value[)
    -- DAC
    g_DAC_VPP   : natural := 2;  -- DAC differential output voltage ( Vpp expressed in Volts)
    g_DAC_DELAY : natural := 0  -- DAC conversion delay (expressed in number of clock cycles @i_dac_clk). The range is: [0;max integer value[)

    );
  port (

    --  Opal Kelly inouts --
    i_okUH  : in    std_logic_vector(4 downto 0);
    o_okHU  : out   std_logic_vector(2 downto 0);
    b_okUHU : inout std_logic_vector(31 downto 0);
    b_okAA  : inout std_logic;

    ---------------------------------------------------------------------
    -- ADC
    ---------------------------------------------------------------------
    i_adc_clk_phase : in std_logic;  -- adc clock (for the clock signal): i_adc_clk_phase = i_adc_clk + 90 degree
    i_adc_clk       : in std_logic;     -- adc clock (for the data)
    i_adc0_real     : in real;          --  adc0 value (mux_squid_feedback)
    i_adc1_real     : in real;  --  adc1 value (amp_squid_offset_correction)

    ---------------------------------------------------------------------
    -- to sync
    ---------------------------------------------------------------------
    o_clk_ref_p   : out std_logic;      -- differential reference clock_p
    o_clk_ref_n   : out std_logic;      -- differential reference clock_n
    o_clk_frame_p : out std_logic;  -- differential clk_frame_p pulse (at the beginning of the first pixel of a column (@o_clk_ref_P)
    o_clk_frame_n : out std_logic;  -- differential clk_frame_n pulse (at the beginning of the first pixel of a column (@o_clk_ref_P)

    ---------------------------------------------------------------------
    -- DAC
    ---------------------------------------------------------------------
    o_dac_real_valid : out std_logic;   --  dac valid
    o_dac_real       : out real         --  dac value
    );
end entity fpga_system_fpasim;

architecture RTL of fpga_system_fpasim is

---------------------------------------------------------------------
-- ads62p49_top
---------------------------------------------------------------------
  signal adc_clk_p : std_logic;         -- differential_p adc clock
  signal adc_clk_n : std_logic;         -- differential_n adc clock

  -- adc0 (channel A)
  ---------------------------------------------------------------------
  signal da0_p : std_logic;             --  differential_p adc0 (lane0)
  signal da0_n : std_logic;             --  differential_n adc0 (lane0)

  signal da2_p : std_logic;             --  differential_p adc0 (lane1)
  signal da2_n : std_logic;             --  differential_n adc0 (lane1)

  signal da4_p : std_logic;             --  differential_p adc0 (lane2)
  signal da4_n : std_logic;             --  differential_n adc0 (lane2)

  signal da6_p : std_logic;             --  differential_p adc0 (lane3)
  signal da6_n : std_logic;             --  differential_n adc0 (lane3)

  signal da8_p : std_logic;             --  differential_p adc0 (lane4)
  signal da8_n : std_logic;             --  differential_n adc0 (lane4)

  signal da10_p : std_logic;            --  differential_p adc0 (lane5)
  signal da10_n : std_logic;            --  differential_n adc0 (lane5)

  signal da12_p : std_logic;            --  differential_p adc0 (lane6)
  signal da12_n : std_logic;            --  differential_n adc0 (lane6)

  -- adc1 (channel B)
  ---------------------------------------------------------------------
  signal db0_p : std_logic;             --  differential_p adc1 (lane0)
  signal db0_n : std_logic;             --  differential_n adc1 (lane0)

  signal db2_p : std_logic;             --  differential_p adc1 (lane1)
  signal db2_n : std_logic;             --  differential_n adc1 (lane1)

  signal db4_p : std_logic;             --  differential_p adc1 (lane2)
  signal db4_n : std_logic;             --  differential_n adc1 (lane2)

  signal db6_p : std_logic;             --  differential_p adc1 (lane3)
  signal db6_n : std_logic;             --  differential_n adc1 (lane3)

  signal db8_p : std_logic;             --  differential_p adc1 (lane4)
  signal db8_n : std_logic;             --  differential_n adc1 (lane4)

  signal db10_p : std_logic;            --  differential_p adc1 (lane5)
  signal db10_n : std_logic;            --  differential_n adc1 (lane5)

  signal db12_p : std_logic;            --  differential_p adc1 (lane6)
  signal db12_n : std_logic;            --  differential_n adc1 (lane6)

---------------------------------------------------------------------
-- system_fpasim_top
---------------------------------------------------------------------
  -- board id (resistor pattern)
  signal i_hardware_id : std_logic_vector(7 downto 0);

  signal dac_clk_p : std_logic;         -- differential_p dac clock
  signal dac_clk_n : std_logic;         -- differential_n dac clock

  signal dac_frame_p : std_logic;       -- differential_p dac frame
  signal dac_frame_n : std_logic;       -- differential_n dac frame

  signal dac0_p : std_logic;            -- differential_p dac data (lane0)
  signal dac0_n : std_logic;            -- differential_n dac data (lane0)

  signal dac1_p : std_logic;            -- differential_p dac data (lane1)
  signal dac1_n : std_logic;            -- differential_n dac data (lane1)

  signal dac2_p : std_logic;            -- differential_p dac data (lane2)
  signal dac2_n : std_logic;            -- differential_n dac data (lane2)

  signal dac3_p : std_logic;            -- differential_p dac data (lane3)
  signal dac3_n : std_logic;            -- differential_n dac data (lane3)

  signal dac4_p : std_logic;            -- differential_p dac data (lane4)
  signal dac4_n : std_logic;            -- differential_n dac data (lane4)

  signal dac5_p : std_logic;            -- differential_p dac data (lane5)
  signal dac5_n : std_logic;            -- differential_n dac data (lane5)

  signal dac6_p : std_logic;            -- differential_p dac data (lane6)
  signal dac6_n : std_logic;            -- differential_n dac data (lane6)

  signal dac7_p : std_logic;            -- differential_p dac data (lane7)
  signal dac7_n : std_logic;            -- differential_n dac data (lane7)

-- common: shared link between the spi
  signal spi_sclk  : std_logic;         -- spi clock
  signal spi_sdata : std_logic;         -- spi data

  -- CDCE: SPI
  signal cdce_sdo  : std_logic := '0';  -- spi sdo (for the cdce device)
  signal cdce_n_en : std_logic;  -- spi chip select (for the cdce device)

  -- CDCE: specific signals
  signal cdce_pll_status : std_logic := '0';  -- pll_status : This pin is set high if the PLL is in lock.
  signal cdce_n_reset    : std_logic;   -- reset_n or hold_n
  signal cdce_n_pd       : std_logic;   -- power_down_n
  signal ref_en          : std_logic;   -- enable the primary reference clock

  -- ADC: SPI
  signal adc_sdo   : std_logic := '0';  -- SPI MISO
  signal adc_n_en  : std_logic;         -- SPI chip select
  -- ADC: specific signals
  signal adc_reset : std_logic;         -- adc hardware reset

  -- DAC: SPI
  signal dac_sdo        : std_logic := '0';  -- SPI MISO
  signal dac_n_en       : std_logic;    -- SPI chip select
  -- DAC: specific signal
  signal dac_tx_present : std_logic;  -- enable tx acquisition (pin of the dac device)

  -- AMC: SPI (monitoring)
  signal mon_sdo      : std_logic := '0';  -- SPI data out
  signal mon_n_en     : std_logic;      -- SPI chip select
  -- AMC : specific signals
  signal mon_n_int    : std_logic := '0';  -- galr_n: Global analog input out-of-range alarm.
  signal mon_n_reset  : std_logic;      -- reset_n: hardware reset
  -- FPGA board leds
  signal leds         : std_logic_vector(3 downto 0);  -- leds
  -- FMC firmware led
  signal led_fw       : std_logic;
  -- FMC pll locked led
  signal led_pll_lock : std_logic;

  -- first processed sample of a pulse
  signal trig_oscillo : std_logic;

  ---------------------------------------------------------------------
  -- dac3283_top
  ---------------------------------------------------------------------
  signal dac_real_valid : std_logic;    -- dac data valid (real value)
  signal dac_real       : real;         -- dac data (real value)

begin

---------------------------------------------------------------------
-- adc: model
---------------------------------------------------------------------
  inst_ads62p49_top : entity work.ads62p49_top
    generic map(
      g_ADC_VPP   => g_ADC_VPP,  -- ADC differential input voltage ( Vpp expressed in Volts)
      g_ADC_RES   => 14,                -- ADC resolution (expressed in bits)
      g_ADC_DELAY => g_ADC_DELAY  -- ADC latency (expressed in number of clock periods) @i_adc_clk. The range is [0;max integer[
      )
    port map(
      ---------------------------------------------------------------------
      -- inputs
      ---------------------------------------------------------------------
      i_adc_clk_phase => i_adc_clk_phase,
      i_adc_clk       => i_adc_clk,
      i_adc0_real     => i_adc0_real,
      i_adc1_real     => i_adc1_real,
      ---------------------------------------------------------------------
      -- outputs
      ---------------------------------------------------------------------
      o_adc_clk_p     => adc_clk_p,
      o_adc_clk_n     => adc_clk_n,
      -- adc0
      o_da0_p         => da0_p,
      o_da0_n         => da0_n,
      o_da2_p         => da2_p,
      o_da2_n         => da2_n,
      o_da4_p         => da4_p,
      o_da4_n         => da4_n,
      o_da6_p         => da6_p,
      o_da6_n         => da6_n,
      o_da8_p         => da8_p,
      o_da8_n         => da8_n,
      o_da10_p        => da10_p,
      o_da10_n        => da10_n,
      o_da12_p        => da12_p,
      o_da12_n        => da12_n,
      -- adc1
      o_db0_p         => db0_p,
      o_db0_n         => db0_n,
      o_db2_p         => db2_p,
      o_db2_n         => db2_n,
      o_db4_p         => db4_p,
      o_db4_n         => db4_n,
      o_db6_p         => db6_p,
      o_db6_n         => db6_n,
      o_db8_p         => db8_p,
      o_db8_n         => db8_n,
      o_db10_p        => db10_p,
      o_db10_n        => db10_n,
      o_db12_p        => db12_p,
      o_db12_n        => db12_n
      );

---------------------------------------------------------------------
-- system_fpasim_top
---------------------------------------------------------------------
  i_hardware_id <= std_logic_vector(to_unsigned(1, i_hardware_id'length));

  inst_system_fpasim_top : entity work.system_fpasim_top
    generic map(
      g_DEBUG => false
      )
    port map(
      --  Opal Kelly inouts --
      i_okUH         => i_okUH,
      o_okHU         => o_okHU,
      b_okUHU        => b_okUHU,
      b_okAA         => b_okAA,
      ---------------------------------------------------------------------
      -- FMC: from the card
      ---------------------------------------------------------------------
      i_hardware_id  => i_hardware_id,
      ---------------------------------------------------------------------
      -- FMC: from the adc
      ---------------------------------------------------------------------
      i_clk_ab_p     => adc_clk_p,
      i_clk_ab_n     => adc_clk_n,
      -- adc_a
      -- bit P/N: 0-1
      i_cha_00_p     => da0_p,
      i_cha_00_n     => da0_n,
      i_cha_02_p     => da2_p,
      i_cha_02_n     => da2_n,
      i_cha_04_p     => da4_p,
      i_cha_04_n     => da4_n,
      i_cha_06_p     => da6_p,
      i_cha_06_n     => da6_n,
      i_cha_08_p     => da8_p,
      i_cha_08_n     => da8_n,
      i_cha_10_p     => da10_p,
      i_cha_10_n     => da10_n,
      i_cha_12_p     => da12_p,
      i_cha_12_n     => da12_n,
      -- adc_b
      i_chb_00_p     => db0_p,
      i_chb_00_n     => db0_n,
      i_chb_02_p     => db2_p,
      i_chb_02_n     => db2_n,
      i_chb_04_p     => db4_p,
      i_chb_04_n     => db4_n,
      i_chb_06_p     => db6_p,
      i_chb_06_n     => db6_n,
      i_chb_08_p     => db8_p,
      i_chb_08_n     => db8_n,
      i_chb_10_p     => db10_p,
      i_chb_10_n     => db10_n,
      i_chb_12_p     => db12_p,
      i_chb_12_n     => db12_n,
      ---------------------------------------------------------------------
      -- FMC: to sync
      ---------------------------------------------------------------------
      o_clk_ref_p    => o_clk_ref_p,
      o_clk_ref_n    => o_clk_ref_n,
      o_clk_frame_p  => o_clk_frame_p,
      o_clk_frame_n  => o_clk_frame_n,
      ---------------------------------------------------------------------
      -- FMC: to dac
      ---------------------------------------------------------------------
      o_dac_dclk_p   => dac_clk_p,
      o_dac_dclk_n   => dac_clk_n,
      o_frame_p      => dac_frame_p,
      o_frame_n      => dac_frame_n,
      o_dac_d0_p     => dac0_p,
      o_dac_d0_n     => dac0_n,
      o_dac_d1_p     => dac1_p,
      o_dac_d1_n     => dac1_n,
      o_dac_d2_p     => dac2_p,
      o_dac_d2_n     => dac2_n,
      o_dac_d3_p     => dac3_p,
      o_dac_d3_n     => dac3_n,
      o_dac_d4_p     => dac4_p,
      o_dac_d4_n     => dac4_n,
      o_dac_d5_p     => dac5_p,
      o_dac_d5_n     => dac5_n,
      o_dac_d6_p     => dac6_p,
      o_dac_d6_n     => dac6_n,
      o_dac_d7_p     => dac7_p,
      o_dac_d7_n     => dac7_n,
      ---------------------------------------------------------------------
      -- devices: spi links + specific signals
      ---------------------------------------------------------------------
      -- common: shared link between the spi
      o_spi_sclk     => spi_sclk,         -- not connected
      o_spi_sdata    => spi_sdata,        -- not connected
      -- CDCE: SPI
      i_cdce_sdo     => cdce_sdo,         -- not connected
      o_cdce_n_en    => cdce_n_en,        -- not connected
      -- CDCE: specific signals
      i_pll_status   => cdce_pll_status,  -- not connected
      o_cdce_n_reset => cdce_n_reset,     -- not connected
      o_cdce_n_pd    => cdce_n_pd,        -- not connected
      o_ref_en       => ref_en,           -- not connected
      -- ADC: SPI
      i_adc_sdo      => adc_sdo,          -- not connected
      o_adc_n_en     => adc_n_en,         -- not connected
      -- ADC: specific signals
      o_adc_reset    => adc_reset,        -- not connected
      -- DAC: SPI
      i_dac_sdo      => dac_sdo,          -- not connected
      o_dac_n_en     => dac_n_en,         -- not connected
      -- DAC: specific signal
      o_tx_enable    => dac_tx_present,   -- not connected
      -- AMC: SPI (monitoring)
      i_mon_sdo      => mon_sdo,          -- not connected
      o_mon_n_en     => mon_n_en,         -- not connected
      -- AMC : specific signals
      i_mon_n_int    => mon_n_int,        -- not connected
      o_mon_n_reset  => mon_n_reset,      -- not connected
      ---------------------------------------------------------------------
      -- leds
      ---------------------------------------------------------------------
      o_leds         => leds,             -- not connected
      o_led_fw       => led_fw,           -- not connected
      o_led_pll_lock => led_pll_lock,     -- not connected

      ---------------------------------------------------------------------
      -- FMC: to oscillo
      ---------------------------------------------------------------------
      -- first processed sample of a pulse
      o_trig_oscillo => trig_oscillo    -- not connected
      );

---------------------------------------------------------------------
-- dac3283_top
---------------------------------------------------------------------
  inst_dac3283_top : entity work.dac3283_top
    generic map(
      g_DAC_VPP   => g_DAC_VPP,  -- DAC differential output voltage ( Vpp expressed in Volts)
      g_DAC_DELAY => g_DAC_DELAY        -- DAC conversion delay
      )
    port map(
      ---------------------------------------------------------------------
      -- from pads
      ---------------------------------------------------------------------
      i_dac_clk_p      => dac_clk_p,
      i_dac_clk_n      => dac_clk_n,
      i_dac_frame_p    => dac_frame_p,
      i_dac_frame_n    => dac_frame_n,
      i_dac0_p         => dac0_p,
      i_dac0_n         => dac0_n,
      i_dac1_p         => dac1_p,
      i_dac1_n         => dac1_n,
      i_dac2_p         => dac2_p,
      i_dac2_n         => dac2_n,
      i_dac3_p         => dac3_p,
      i_dac3_n         => dac3_n,
      i_dac4_p         => dac4_p,
      i_dac4_n         => dac4_n,
      i_dac5_p         => dac5_p,
      i_dac5_n         => dac5_n,
      i_dac6_p         => dac6_p,
      i_dac6_n         => dac6_n,
      i_dac7_p         => dac7_p,
      i_dac7_n         => dac7_n,
      ---------------------------------------------------------------------
      -- to sim
      ---------------------------------------------------------------------
      o_dac_real_valid => dac_real_valid,
      o_dac_real       => dac_real
      );

---------------------------------------------------------------------
-- output
---------------------------------------------------------------------

  o_dac_real_valid <= dac_real_valid;
  o_dac_real       <= dac_real;


end architecture RTL;
