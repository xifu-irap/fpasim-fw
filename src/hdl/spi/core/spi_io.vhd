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
--    @file                   spi_io.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details                
--
-- -------------------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library unisim;


entity spi_io is
  port (
    i_clk       : in  std_logic;
    i_io_rst    : in  std_logic;
    ---------------------------------------------------------------------
    -- from/to the pads
    ---------------------------------------------------------------------
    -- common: shared link between the spi
    o_spi_sclk  : out std_logic;        -- Shared SPI clock line
    o_spi_sdata : out std_logic;        -- Shared SPI MOSI

    -- CDCE: SPI
    i_cdce_sdo  : in  std_logic;        -- SPI MISO
    o_cdce_n_en : out std_logic;        -- SPI chip select

    -- CDCE: specific signals
    i_cdce_pll_status : in  std_logic;  -- pll_status : This pin is set high if the PLL is in lock.
    o_cdce_n_reset    : out std_logic;  -- reset_n or hold_n
    o_cdce_n_pd       : out std_logic;  -- power_down_n
    o_ref_en          : out std_logic;  -- enable the primary reference clock

    -- ADC: SPI
    i_adc_sdo   : in  std_logic;        -- SPI MISO
    o_adc_n_en  : out std_logic;        -- SPI chip select
    -- ADC: specific signals
    o_adc_reset : out std_logic;        -- adc hardware reset

    -- DAC: SPI
    i_dac_sdo        : in  std_logic;   -- SPI MISO
    o_dac_n_en       : out std_logic;   -- SPI chip select
    -- DAC: specific signal
    o_dac_tx_present : out std_logic;   -- enable tx acquisition

    -- AMC: SPI (monitoring)
    i_mon_sdo     : in  std_logic;      -- SPI data out
    o_mon_n_en    : out std_logic;      -- SPI chip select
    -- AMC : specific signals
    i_mon_n_int   : in  std_logic;  -- galr_n: Global analog input out-of-range alarm.
    o_mon_n_reset : out std_logic;

    ---------------------------------------------------------------------
    -- from/to the user
    ---------------------------------------------------------------------
    -- common: shared link between the spi
    i_spi_sclk  : in std_logic;         -- Shared SPI clock line
    i_spi_sdata : in std_logic;         -- Shared SPI MOSI

    -- CDCE: SPI
    o_cdce_sdo  : out std_logic;        -- SPI MISO
    i_cdce_n_en : in  std_logic;        -- SPI chip select

    -- CDCE: specific signals
    o_cdce_pll_status : out std_logic;  -- pll_status : This pin is set high if the PLL is in lock.
    i_cdce_n_reset    : in  std_logic;  -- reset_n or hold_n
    i_cdce_n_pd       : in  std_logic;  -- power_down_n
    i_ref_en          : in  std_logic;  -- enable the primary reference clock

    -- ADC: SPI
    o_adc_sdo   : out std_logic;        -- SPI MISO
    i_adc_n_en  : in  std_logic;        -- SPI chip select
    -- ADC: specific signals
    i_adc_reset : in  std_logic;        -- adc hardware reset

    -- DAC: SPI
    o_dac_sdo        : out std_logic;   -- SPI MISO
    i_dac_n_en       : in  std_logic;   -- SPI chip select
    -- DAC: specific signal
    i_dac_tx_present : in  std_logic;   -- enable tx acquisition

    -- AMC: SPI (monitoring)
    o_mon_sdo     : out std_logic;      -- SPI data out
    i_mon_n_en    : in  std_logic;      -- SPI chip select
    -- AMC : specific signals
    o_mon_n_int   : out std_logic;  -- galr_n: Global analog input out-of-range alarm.
    i_mon_n_reset : in  std_logic


    );
end entity spi_io;

architecture RTL of spi_io is


begin
---------------------------------------------------------------------
-- from the pads to the user
---------------------------------------------------------------------
  gen_pads_to_user : if true generate
    signal data_in  : std_logic_vector(5 downto 0);
    signal data_out : std_logic_vector(5 downto 0);

    signal data_in2  : std_logic_vector(5 downto 0);
    signal data_out2 : std_logic_vector(5 downto 0);
  begin

    data_in(5) <= i_mon_n_int;
    data_in(4) <= i_mon_sdo;
    data_in(3) <= i_dac_sdo;
    data_in(2) <= i_adc_sdo;
    data_in(1) <= i_cdce_pll_status;
    data_in(0) <= i_cdce_sdo;

    inst_pipeliner_IO_BUF : entity work.pipeliner
      generic map(
        g_NB_PIPES   => 1,  -- number of consecutives registers. Possibles values: [0, integer max value[
        g_DATA_WIDTH => data_in'length  -- width of the input/output data.  Possibles values: [1, integer max value[
        )
      port map(
        i_clk  => i_clk,                -- clock signal
        i_data => data_in,              -- input data
        o_data => data_out              -- output data with/without delay
        );


    data_in2 <= data_out;

    inst_synchronizer_input : entity work.synchronizer
      generic map(
        g_INIT            => '0',  -- Initial value of synchronizer registers upon startup, 1'b0 or 1'b1.
        g_SYNC_STAGES     => 2,  -- Integer value for number of synchronizing registers, must be 2 or higher
        g_PIPELINE_STAGES => 0,  -- Integer value for number of registers on the output of the synchronizer for the purpose of improving performance. Possible values: [1; integer max value [
        g_DATA_WIDTH      => data_in2'length  -- data width expressed in bits
        )
      port map(
        i_clk        => i_clk,          -- clock signal
        i_async_data => data_in2,       -- async input
        o_data       => data_out2       -- output data with/without delay
        );

    o_mon_n_int       <= data_out2(5);
    o_mon_sdo         <= data_out2(4);
    o_dac_sdo         <= data_out2(3);
    o_adc_sdo         <= data_out2(2);
    o_cdce_pll_status <= data_out2(1);
    o_cdce_sdo        <= data_out2(0);

  end generate gen_pads_to_user;
---------------------------------------------------------------------
-- from the user to the pads
---------------------------------------------------------------------
-- clock
  gen_user_to_pads_clk : if true generate
    signal clk_fwd_out : std_logic;
    signal clk_to_pins : std_logic;
  begin
    inst_oddr : unisim.vcomponents.ODDR
      generic map(
        DDR_CLK_EDGE   => "SAME_EDGE",
        INIT           => '0',
        IS_C_INVERTED  => '0',
        IS_D1_INVERTED => '0',
        IS_D2_INVERTED => '0',
        SRTYPE         => "ASYNC"
        )
      port map (  
        C  => i_clk,
        CE => '1',
        D1 => i_spi_sclk,
        D2 => i_spi_sclk,
        Q  => clk_fwd_out,
        R  => i_io_rst,
        S  => '0'
        );

    inst_obuf : unisim.vcomponents.OBUF  
      port map (  
        I => clk_fwd_out,
        O => clk_to_pins
        );
    o_spi_sclk <= clk_to_pins;
  end generate gen_user_to_pads_clk;

-- data
  gen_user_to_pads : if true generate
    signal data_in  : std_logic_vector(3 downto 0);
    signal data_out : std_logic_vector(3 downto 0);
  begin
    data_in(3) <= i_dac_tx_present;
    data_in(2) <= i_adc_reset;
    data_in(1) <= i_ref_en;
    data_in(0) <= i_spi_sdata;

    inst_pipeliner_with_init : entity work.pipeliner_with_init
      generic map(
        g_INIT       => '0',
        g_NB_PIPES   => 1,  -- number of consecutives registers. Possibles values: [0, integer max value[
        g_DATA_WIDTH => data_in'length  -- width of the input/output data.  Possibles values: [1, integer max value[
        )
      port map(
        i_clk  => i_clk,
        i_data => data_in,
        o_data => data_out
        );

    o_dac_tx_present <= data_out(3);
    o_adc_reset      <= data_out(2);
    o_ref_en         <= data_out(1);
    o_spi_sdata      <= data_out(0);

  end generate gen_user_to_pads;

  gen_user_to_pads_n : if true generate
    signal data_in  : std_logic_vector(6 downto 0);
    signal data_out : std_logic_vector(6 downto 0);
  begin
    data_in(6) <= i_mon_n_reset;
    data_in(5) <= i_cdce_n_pd;
    data_in(4) <= i_cdce_n_reset;
    data_in(3) <= i_mon_n_en;
    data_in(2) <= i_dac_n_en;
    data_in(1) <= i_adc_n_en;
    data_in(0) <= i_cdce_n_en;

    inst_pipeliner_with_init : entity work.pipeliner_with_init
      generic map(
        g_INIT       => '1',
        g_NB_PIPES   => 1,  -- number of consecutives registers. Possibles values: [0, integer max value[
        g_DATA_WIDTH => data_in'length  -- width of the input/output data.  Possibles values: [1, integer max value[
        )
      port map(
        i_clk  => i_clk,
        i_data => data_in,
        o_data => data_out
        );

    o_mon_n_reset  <= data_out(6);
    o_cdce_n_pd    <= data_out(5);
    o_cdce_n_reset <= data_out(4);
    o_mon_n_en     <= data_out(3);
    o_dac_n_en     <= data_out(2);
    o_adc_n_en     <= data_out(1);
    o_cdce_n_en    <= data_out(0);


  end generate gen_user_to_pads_n;



end architecture RTL;
