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
--                              but WITHOUT ANY WARRANTY; without even the implied warranty ofh
--                              MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--                              GNU General Public License for more details.
--
--                              You should have received a copy of the GNU General Public License
--                              along with this program.  If not, see <https://www.gnu.org/licenses/>.
-- -------------------------------------------------------------------------------------------------------------
--    email                   kenji.delarosa@alten.com
--    @file                   spi_device_select.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This module distributes spi commands to the different devices of the FMC150 board (abaco system)
--    In particular, it manages the shared spi links (o_spi_sclk and o_spi_sdata) between the different devices.
--
--    Note:
--     . For the different devices, the user must build the corresponding full SPI words (typically: addr + data).
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity spi_device_select is
  generic (
    g_DEBUG : boolean := false
    );
  port (
    i_clk         : in std_logic;       -- clock
    i_rst         : in std_logic;       -- reset
    i_rst_status  : in std_logic;       -- reset error flag(s)
    i_debug_pulse : in std_logic;  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)

    ---------------------------------------------------------------------
    -- command
    ---------------------------------------------------------------------
    -- input
    i_spi_en             : in  std_logic;  -- enable the spi
    i_spi_dac_tx_present : in  std_logic;  -- 1:enable dac data tx, 0: otherwise
    i_spi_mode           : in  std_logic;  -- 1:wr, 0:rd
    i_spi_id             : in  std_logic_vector(1 downto 0);  -- spi identifier: "00":cdece,"01": adc,"10":dac,"11":amc
    i_spi_cmd_valid      : in  std_logic;  -- command valid
    i_spi_cmd_wr_data    : in  std_logic_vector(31 downto 0);  -- data to write
    -- output
    o_spi_rd_data_valid  : out std_logic;  -- read data valid
    o_spi_rd_data        : out std_logic_vector(31 downto 0);  -- read data (device spi register value).
    o_spi_ready          : out std_logic;  -- 1: all spi links are ready,0: one of the spi link is busy

    o_reg_spi_status : out std_logic_vector(31 downto 0);  -- spi status (register format)
    ---------------------------------------------------------------------
    -- errors/status
    ---------------------------------------------------------------------
    o_errors         : out std_logic_vector(15 downto 0); -- errors
    o_status         : out std_logic_vector(7 downto 0); -- status

    ---------------------------------------------------------------------
    -- from/to the IOs
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
    o_mon_n_reset : out std_logic       -- reset_n: hardware reset

    );
end entity spi_device_select;

architecture RTL of spi_device_select is

---------------------------------------------------------------------
-- state machine
---------------------------------------------------------------------
  type t_state is (E_RST, E_WAIT_READY_ALL, E_WAIT_CMD, E_WAIT_CDCE, E_WAIT_ADC, E_WAIT_DAC, E_WAIT_AMC);
  signal sm_state_next : t_state; -- state
  signal sm_state_r1   : t_state := E_RST; -- state (registered)

  -- cdce: data_valid
  signal cdce_data_valid_next : std_logic;
  -- cdce: data_valid (registered)
  signal cdce_data_valid_r1   : std_logic;

  -- adc: data_valid
  signal adc_data_valid_next : std_logic;
  -- adc: data_valid (registered)
  signal adc_data_valid_r1   : std_logic;

  -- dac: data_valid
  signal dac_data_valid_next : std_logic;
  -- dac: data_valid (registered)
  signal dac_data_valid_r1   : std_logic;

  -- amc: data_valid
  signal amc_data_valid_next : std_logic;
  -- amc: data_valid (registered)
  signal amc_data_valid_r1   : std_logic;

  -- spi: clock
  signal spi_clk_next : std_logic;
  -- spi: clock (registered)
  signal spi_clk_r1   : std_logic := '0';

  -- spi: mosi
  signal spi_mosi_next : std_logic;
  -- spi: mosi (registered)
  signal spi_mosi_r1   : std_logic := '0';

  -- read_valid
  signal rd_data_valid_next : std_logic;
  -- read_valid (registered)
  signal rd_data_valid_r1   : std_logic := '0';

  -- read data
  signal rd_data_next : std_logic_vector(o_spi_rd_data'range);
  -- read data (registered)
  signal rd_data_r1   : std_logic_vector(o_spi_rd_data'range) := (others => '0');

  -- spi mode: read/write (registered)
  signal tx_wr_rd_en_r1        : std_logic;

  -- dac tx_present pin (registered)
  signal dac_spi_tx_present_r1 : std_logic;
  -- spi: command to write (registered)
  signal tx_data_r1            : std_logic_vector(i_spi_cmd_wr_data'range);

  -- error flag
  signal error_next : std_logic;
  -- error flag (registered)
  signal error_r1   : std_logic;

  -- ready flag
  signal ready_next : std_logic;
  -- ready flag (registered)
  signal ready_r1   : std_logic := '0';

  ---------------------------------------------------------------------
  -- sync with fsm output
  ---------------------------------------------------------------------
  -- cdce: chip select
  signal cdce_spi_cs_n_en1 : std_logic;
  -- adc: chip select
  signal adc_spi_cs_n1     : std_logic;
  -- dac: chip select
  signal dac_spi_cs_n1     : std_logic;
  -- amc: chip select
  signal amc_spi_cs_n1     : std_logic;
  -- cdce: reset_n
  signal cdce_n_reset1     : std_logic;
  -- cdce: power_down_n
  signal cdce_n_pd1        : std_logic;
  -- cdce: enable the primary reference clock
  signal cdce_ref_en1      : std_logic;
  -- adc: hardware reset
  signal adc_reset1        : std_logic;
  -- dac: enable tx acquisition pin
  signal dac_tx_present1   : std_logic;
  -- amc: hardware reset
  signal amc_mon_n_reset1  : std_logic;

---------------------------------------------------------------------
-- CDCE
---------------------------------------------------------------------
  -- cmd
  -- cdce spi bridge: write data valid
  signal cdce_spi_cmd_wr_data_valid : std_logic;
  -- cdce spi bridge: mode (write/read)
  signal cdce_spi_mode              : std_logic;
  -- cdce spi bridge: write data
  signal cdce_spi_cmd_wr_data       : std_logic_vector(31 downto 0);
  -- cdce spi bridge: read data valid
  signal cdce_spi_rd_data_valid     : std_logic;
  -- cdce spi bridge: read data
  signal cdce_spi_rd_data           : std_logic_vector(31 downto 0);
  -- cdce spi bridge: ready
  signal cdce_spi_ready             : std_logic;
  -- cdce spi bridge: finish
  signal cdce_spi_finish            : std_logic;
  -- status
  signal cdce_status                : std_logic_vector(7 downto 0);
  -- spi
  signal cdce_spi_clk               : std_logic;  -- SPI clock
  signal cdce_spi_cs_n_en           : std_logic;  -- SPI chip select
  signal cdce_spi_mosi              : std_logic;  -- SPI MOSI
  -- specific signals
  signal cdce_n_reset               : std_logic;  -- reset_n or hold_n
  signal cdce_n_pd                  : std_logic;  -- power_down_n
  signal cdce_ref_en                : std_logic;  -- enable the primary reference clock

  ---------------------------------------------------------------------
  -- ADC
  ---------------------------------------------------------------------
  -- cmd
  -- adc spi bridge: write data valid
  signal adc_spi_cmd_wr_data_valid : std_logic;
  -- adc spi bridge: mode (write/read)
  signal adc_spi_mode              : std_logic;
  -- adc spi bridge: write data
  signal adc_spi_cmd_wr_data       : std_logic_vector(15 downto 0);
  -- adc spi bridge: read data valid
  signal adc_spi_rd_data_valid     : std_logic;
  -- adc spi bridge: read data
  signal adc_spi_rd_data           : std_logic_vector(15 downto 0);
  -- adc spi bridge: ready
  signal adc_spi_ready             : std_logic;
  -- adc spi bridge: finish
  signal adc_spi_finish            : std_logic;
  -- spi
  signal adc_spi_clk               : std_logic;  -- SPI clock
  signal adc_spi_cs_n              : std_logic;  -- SPI chip select
  signal adc_spi_mosi              : std_logic;  -- SPI MOSI
  -- specific signals
  signal adc_reset                 : std_logic;  -- adc reset

  ---------------------------------------------------------------------
  -- DAC
  ---------------------------------------------------------------------
  -- dac
  -- dac spi bridge: write data valid
  signal dac_spi_cmd_wr_data_valid : std_logic;
  -- dac spi bridge: mode (write/read)
  signal dac_spi_mode              : std_logic;
  -- dac spi bridge: write data
  signal dac_spi_cmd_wr_data       : std_logic_vector(15 downto 0);
  -- dac spi bridge: read data valid
  signal dac_spi_rd_data_valid     : std_logic;
  -- dac spi bridge: read data
  signal dac_spi_rd_data           : std_logic_vector(15 downto 0);
  -- dac spi bridge: ready
  signal dac_spi_ready             : std_logic;
  -- dac spi bridge: finish
  signal dac_spi_finish            : std_logic;
  -- spi
  signal dac_spi_clk               : std_logic;  -- SPI clock
  signal dac_spi_cs_n              : std_logic;  -- SPI chip select
  signal dac_spi_mosi              : std_logic;  -- SPI MOSI
  -- specific signal
  signal dac_tx_present            : std_logic;  -- SPI MOSI

  ---------------------------------------------------------------------
  -- AMC
  ---------------------------------------------------------------------
  -- cmd
  -- amc spi bridge: write data valid
  signal amc_spi_cmd_wr_data_valid : std_logic;
  -- amc spi bridge: mode (write/read)
  signal amc_spi_mode              : std_logic;
  -- amc spi bridge: write data
  signal amc_spi_cmd_wr_data       : std_logic_vector(31 downto 0);
  -- amc spi bridge: read data valid
  signal amc_spi_rd_data_valid     : std_logic;
  -- amc spi bridge: read data
  signal amc_spi_rd_data           : std_logic_vector(31 downto 0);
  -- amc spi bridge: ready
  signal amc_spi_ready             : std_logic;
  -- amc spi bridge: finish
  signal amc_spi_finish            : std_logic;
  -- amc spi bridge: status
  signal amc_status                : std_logic_vector(7 downto 0);

  -- spi
  signal amc_spi_clk     : std_logic;   -- SPI clock
  signal amc_spi_cs_n    : std_logic;   -- SPI chip select
  signal amc_spi_mosi    : std_logic;   -- SPI MOSI
  -- specific signals
  signal amc_mon_n_reset : std_logic;   -- reset_n

---------------------------------------------------------------------
  -- error latching
  ---------------------------------------------------------------------
  constant c_NB_ERRORS : integer := 1; -- define the width of the temporary errors signals
  signal error_tmp     : std_logic_vector(c_NB_ERRORS - 1 downto 0); -- temporary input errors
  signal error_tmp_bis : std_logic_vector(c_NB_ERRORS - 1 downto 0); -- temporary output errors

  ---------------------------------------------------------------------
  -- debug
  ---------------------------------------------------------------------
  -- debug: control signal for the cdce_n_reset pin
  signal debug_cdce_n_reset1 : std_logic;
  -- debug: control signal for the cdce_n_pd pin
  signal debug_cdce_n_pd1    : std_logic;
  -- debug: control signal for the cdce_ref_en pin
  signal debug_cdce_ref_en1  : std_logic;

begin

---------------------------------------------------------------------
-- state machine
--  It manages 2 steps:
--   1. It demux the input command to one of the spi engine (writting)
--   2. wait the spi engine response (reading)
---------------------------------------------------------------------
  p_decode_state : process (adc_spi_finish, adc_spi_rd_data,
                            adc_spi_rd_data_valid, adc_spi_ready, adc_spi_clk,
                            adc_spi_mosi, amc_spi_finish, amc_spi_rd_data,
                            amc_spi_rd_data_valid, amc_spi_ready, amc_spi_clk,
                            amc_spi_mosi, cdce_spi_finish, cdce_spi_rd_data,
                            cdce_spi_rd_data_valid, cdce_spi_ready,
                            cdce_spi_clk, cdce_spi_mosi, dac_spi_finish,
                            dac_spi_rd_data, dac_spi_rd_data_valid,
                            dac_spi_ready, dac_spi_clk, dac_spi_mosi, i_spi_id,
                            i_spi_cmd_valid, rd_data_r1, ready_r1, sm_state_r1,
                            spi_clk_r1, spi_mosi_r1, i_spi_en) is
  begin
    cdce_data_valid_next <= '0';
    adc_data_valid_next  <= '0';
    dac_data_valid_next  <= '0';
    amc_data_valid_next  <= '0';
    spi_clk_next         <= spi_clk_r1;
    spi_mosi_next        <= spi_mosi_r1;
    rd_data_valid_next   <= '0';
    rd_data_next         <= rd_data_r1;
    error_next           <= '0';
    ready_next           <= ready_r1;
    case sm_state_r1 is
      when E_RST =>
        ready_next    <= '0';
        sm_state_next <= E_WAIT_READY_ALL;

      when E_WAIT_READY_ALL =>
        if i_spi_cmd_valid = '1' then
          error_next <= '1';
        else
          error_next <= '0';
        end if;

        if cdce_spi_ready = '1' and adc_spi_ready = '1' and dac_spi_ready = '1' and amc_spi_ready = '1' then
          sm_state_next <= E_WAIT_CMD;
        else
          sm_state_next <= E_WAIT_READY_ALL;
        end if;

      when E_WAIT_CMD =>
        if i_spi_cmd_valid = '1' and i_spi_en = '1' then
          ready_next <= '0';

          case i_spi_id is
            when "00" =>                -- cdce
              cdce_data_valid_next <= '1';
              sm_state_next        <= E_WAIT_CDCE;
            when "01" =>                -- adc
              adc_data_valid_next <= '1';
              sm_state_next       <= E_WAIT_ADC;
            when "10" =>                -- dac
              dac_data_valid_next <= '1';
              sm_state_next       <= E_WAIT_DAC;
            when others =>              --11
              amc_data_valid_next <= '1';
              sm_state_next       <= E_WAIT_AMC;
          end case;
        else
          ready_next    <= '1';
          sm_state_next <= E_WAIT_CMD;

        end if;

      when E_WAIT_CDCE =>
        if i_spi_cmd_valid = '1' then
          error_next <= '1';
        else
          error_next <= '0';
        end if;

        spi_clk_next       <= cdce_spi_clk;
        spi_mosi_next      <= cdce_spi_mosi;
        rd_data_valid_next <= cdce_spi_rd_data_valid;
        rd_data_next       <= cdce_spi_rd_data;

        if cdce_spi_finish = '1' then
          sm_state_next <= E_WAIT_CMD;
        else
          sm_state_next <= E_WAIT_CDCE;
        end if;

      when E_WAIT_ADC =>
        if i_spi_cmd_valid = '1' then
          error_next <= '1';
        else
          error_next <= '0';
        end if;
        spi_clk_next       <= adc_spi_clk;
        spi_mosi_next      <= adc_spi_mosi;
        rd_data_valid_next <= adc_spi_rd_data_valid;
        rd_data_next       <= std_logic_vector(resize(unsigned(adc_spi_rd_data), rd_data_next'length));

        if adc_spi_finish = '1' then
          sm_state_next <= E_WAIT_CMD;
        else
          sm_state_next <= E_WAIT_ADC;
        end if;

      when E_WAIT_DAC =>
        if i_spi_cmd_valid = '1' then
          error_next <= '1';
        else
          error_next <= '0';
        end if;
        spi_clk_next       <= dac_spi_clk;
        spi_mosi_next      <= dac_spi_mosi;
        rd_data_valid_next <= dac_spi_rd_data_valid;
        rd_data_next       <= std_logic_vector(resize(unsigned(dac_spi_rd_data), rd_data_next'length));

        if dac_spi_finish = '1' then
          sm_state_next <= E_WAIT_CMD;
        else
          sm_state_next <= E_WAIT_DAC;
        end if;

      when E_WAIT_AMC =>
        if i_spi_cmd_valid = '1' then
          error_next <= '1';
        else
          error_next <= '0';
        end if;
        spi_clk_next       <= amc_spi_clk;
        spi_mosi_next      <= amc_spi_mosi;
        rd_data_valid_next <= amc_spi_rd_data_valid;
        rd_data_next       <= amc_spi_rd_data;

        if amc_spi_finish = '1' then
          sm_state_next <= E_WAIT_CMD;
        else
          sm_state_next <= E_WAIT_AMC;
        end if;
      when others =>
        sm_state_next <= E_RST;
    end case;
  end process p_decode_state;

  ---------------------------------------------------------------------
  -- State process : register signals
  ---------------------------------------------------------------------
  p_state : process (i_clk) is
  begin
    if rising_edge(i_clk) then
      if i_rst = '1' then
        sm_state_r1 <= E_RST;
      else
        sm_state_r1 <= sm_state_next;
      end if;
      cdce_data_valid_r1 <= cdce_data_valid_next;
      adc_data_valid_r1  <= adc_data_valid_next;
      dac_data_valid_r1  <= dac_data_valid_next;
      amc_data_valid_r1  <= amc_data_valid_next;
      spi_clk_r1         <= spi_clk_next;
      spi_mosi_r1        <= spi_mosi_next;
      rd_data_valid_r1   <= rd_data_valid_next;
      rd_data_r1         <= rd_data_next;
      error_r1           <= error_next;
      ready_r1           <= ready_next;

      -- pipe
      tx_wr_rd_en_r1        <= i_spi_mode;
      tx_data_r1            <= i_spi_cmd_wr_data;
      dac_spi_tx_present_r1 <= i_spi_dac_tx_present;
    end if;
  end process p_state;

  o_spi_ready <= ready_r1;

  -- to the regdecode
  o_spi_rd_data_valid           <= rd_data_valid_r1;
  o_spi_rd_data                 <= rd_data_r1;
  o_reg_spi_status(31 downto 9) <= (others => '0');
  o_reg_spi_status(8)           <= amc_status(0);
  o_reg_spi_status(7 downto 5)  <= (others => '0');
  o_reg_spi_status(4)           <= cdce_status(0);
  o_reg_spi_status(3 downto 1)  <= (others => '0');
  o_reg_spi_status(0)           <= ready_r1;

  ---------------------------------------------------------------------
  -- tx pipeline
  ---------------------------------------------------------------------
  -- init path with zeros (according the signal see the corresponding spi_xxx module)
  gen_tx_pipe_with_init_0 : if true generate
    signal tx_data_tmp0 : std_logic_vector(1 downto 0);
    signal tx_data_tmp1 : std_logic_vector(1 downto 0);
  begin
    tx_data_tmp0(1) <= dac_tx_present;
    tx_data_tmp0(0) <= adc_reset;
    inst_pipeliner_sync_with_fsm_out : entity work.pipeliner
      generic map(
        g_NB_PIPES   => 1,
        g_DATA_WIDTH => tx_data_tmp0'length
        )
      port map(
        i_clk  => i_clk,
        i_data => tx_data_tmp0,
        o_data => tx_data_tmp1
        );
    dac_tx_present1 <= tx_data_tmp1(1);
    adc_reset1      <= tx_data_tmp1(0);
  end generate gen_tx_pipe_with_init_0;

  -- init path with ones  (according the signal see the corresponding spi_xxx module)
  gen_tx_pipe_with_init_1 : if true generate
    signal tx_data_tmp0 : std_logic_vector(7 downto 0);
    signal tx_data_tmp1 : std_logic_vector(7 downto 0);
  begin
    tx_data_tmp0(7) <= amc_mon_n_reset;
    tx_data_tmp0(6) <= cdce_n_reset;
    tx_data_tmp0(5) <= cdce_n_pd;
    tx_data_tmp0(4) <= cdce_ref_en;
    -- spi_cs_n
    tx_data_tmp0(3) <= amc_spi_cs_n;
    tx_data_tmp0(2) <= dac_spi_cs_n;
    tx_data_tmp0(1) <= adc_spi_cs_n;
    tx_data_tmp0(0) <= cdce_spi_cs_n_en;

    inst_pipeliner_sync_with_fsm_out : entity work.pipeliner_with_init
      generic map(
        g_INIT       => '1',
        g_NB_PIPES   => 1,
        g_DATA_WIDTH => tx_data_tmp0'length
        )
      port map(
        i_clk  => i_clk,
        i_data => tx_data_tmp0,
        o_data => tx_data_tmp1
        );
    -- specific signals
    amc_mon_n_reset1 <= tx_data_tmp1(7);

    cdce_n_reset1     <= tx_data_tmp1(6);
    cdce_n_pd1        <= tx_data_tmp1(5);
    cdce_ref_en1      <= tx_data_tmp1(4);
    -- spi_cs_n
    amc_spi_cs_n1     <= tx_data_tmp1(3);
    dac_spi_cs_n1     <= tx_data_tmp1(2);
    adc_spi_cs_n1     <= tx_data_tmp1(1);
    cdce_spi_cs_n_en1 <= tx_data_tmp1(0);

  end generate gen_tx_pipe_with_init_1;


  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  -- common: shared link between the spi
  o_spi_sclk  <= spi_clk_r1;
  o_spi_sdata <= spi_mosi_r1;

  -- CDCE: spi
  o_cdce_n_en <= cdce_spi_cs_n_en1;
  -- CDCE: specific signals
  not_gen_vio_debug : if g_DEBUG = false generate
    o_cdce_n_reset <= cdce_n_reset1;
    o_cdce_n_pd    <= cdce_n_pd1;
    o_ref_en       <= cdce_ref_en1;
  end generate not_gen_vio_debug;

  gen_vio_debug : if g_DEBUG = true generate
    o_cdce_n_reset <= debug_cdce_n_reset1;
    o_cdce_n_pd    <= debug_cdce_n_pd1;
    o_ref_en       <= debug_cdce_ref_en1;
  end generate gen_vio_debug;


  -- ADC: spi
  o_adc_n_en  <= adc_spi_cs_n1;
  -- ADC: specific signals
  o_adc_reset <= adc_reset1;

  -- DAC: spi
  o_dac_n_en       <= dac_spi_cs_n1;
  o_dac_tx_present <= dac_tx_present1;

  -- AMC: spi
  o_mon_n_en    <= amc_spi_cs_n1;
  -- AMC: specific signals
  o_mon_n_reset <= amc_mon_n_reset1;


---------------------------------------------------------------------
-- CDCE
---------------------------------------------------------------------
  cdce_spi_cmd_wr_data_valid <= cdce_data_valid_r1;
  cdce_spi_mode              <= tx_wr_rd_en_r1;
  cdce_spi_cmd_wr_data       <= tx_data_r1;
  inst_spi_cdce72010 : entity work.spi_cdce72010
    generic map(
      g_DATA_WIDTH  => cdce_spi_cmd_wr_data'length,
      g_INPUT_DELAY => 1
      )
    port map(
      i_clk               => i_clk,
      i_rst               => i_rst,
      ---------------------------------------------------------------------
      -- command
      ---------------------------------------------------------------------
      -- input
      i_spi_mode          => cdce_spi_mode,
      i_spi_cmd_valid     => cdce_spi_cmd_wr_data_valid,
      i_spi_cmd_wr_data   => cdce_spi_cmd_wr_data,
      -- output
      o_spi_rd_data_valid => cdce_spi_rd_data_valid,
      o_spi_rd_data       => cdce_spi_rd_data,
      o_spi_ready         => cdce_spi_ready,
      o_spi_finish        => cdce_spi_finish,
      ---------------------------------------------------------------------
      -- status
      ---------------------------------------------------------------------
      o_status            => cdce_status,
      ---------------------------------------------------------------------
      -- from/to IOs @o_spi_clk
      ---------------------------------------------------------------------
      -- spi signal
      i_cdce_sdo          => i_cdce_sdo,  -- SPI MISO
      o_spi_sclk          => cdce_spi_clk,       -- SPI clock
      o_cdce_n_en         => cdce_spi_cs_n_en,   -- SPI chip select
      o_spi_sdata         => cdce_spi_mosi,      -- SPI MOSI
      -- CDCE specific signals
      i_cdce_pll_status   => i_cdce_pll_status,  -- pll_status : This pin is set high if the PLL is in lock.
      o_cdce_n_reset      => cdce_n_reset,       -- reset_n or hold_n
      o_cdce_n_pd         => cdce_n_pd,   -- power_down_n
      o_ref_en            => cdce_ref_en  -- enable the primary reference clock
      );

---------------------------------------------------------------------
-- ADC
---------------------------------------------------------------------
  adc_spi_cmd_wr_data_valid <= adc_data_valid_r1;
  adc_spi_mode              <= tx_wr_rd_en_r1;
  adc_spi_cmd_wr_data       <= tx_data_r1(15 downto 0);
  inst_spi_ads62p49 : entity work.spi_ads62p49
    generic map(
      g_DATA_WIDTH => adc_spi_cmd_wr_data'length

      )
    port map(
      i_clk               => i_clk,
      i_rst               => i_rst,
      ---------------------------------------------------------------------
      -- command
      ---------------------------------------------------------------------
      -- input
      i_spi_mode          => adc_spi_mode,
      i_spi_cmd_valid     => adc_spi_cmd_wr_data_valid,
      i_spi_cmd_wr_data   => adc_spi_cmd_wr_data,
      -- output
      o_spi_rd_data_valid => adc_spi_rd_data_valid,
      o_spi_rd_data       => adc_spi_rd_data,
      o_spi_ready         => adc_spi_ready,
      o_spi_finish        => adc_spi_finish,
      ---------------------------------------------------------------------
      -- from/to IOs @o_spi_clk
      ---------------------------------------------------------------------
      i_adc_sdo           => i_adc_sdo,  -- SPI MISO (high-impedance available)
      o_spi_sclk          => adc_spi_clk,   -- SPI clock
      o_adc_n_en          => adc_spi_cs_n,  -- SPI chip select
      o_spi_sdata         => adc_spi_mosi,  -- SPI MOSI
      -- ADC specific signals
      o_adc_reset         => adc_reset  -- adc reset
      );

---------------------------------------------------------------------
-- DAC
---------------------------------------------------------------------
  dac_spi_cmd_wr_data_valid <= dac_data_valid_r1;
  dac_spi_mode              <= tx_wr_rd_en_r1;
  dac_spi_cmd_wr_data       <= tx_data_r1(15 downto 0);
  inst_spi_dac3283 : entity work.spi_dac3283
    generic map(
      g_DATA_WIDTH       => dac_spi_cmd_wr_data'length,
      g_TX_PRESENT_DELAY => 1
      )
    port map(
      i_clk                => i_clk,
      i_rst                => i_rst,
      ---------------------------------------------------------------------
      -- command
      ---------------------------------------------------------------------
      -- input
      i_spi_dac_tx_present => dac_spi_tx_present_r1,
      i_spi_mode           => dac_spi_mode,
      i_spi_cmd_valid      => dac_spi_cmd_wr_data_valid,
      i_spi_cmd_wr_data    => dac_spi_cmd_wr_data,
      -- output
      o_spi_rd_data_valid  => dac_spi_rd_data_valid,
      o_spi_rd_data        => dac_spi_rd_data,
      o_spi_ready          => dac_spi_ready,
      o_spi_finish         => dac_spi_finish,

      ---------------------------------------------------------------------
      -- from/to IOs @o_spi_clk
      ---------------------------------------------------------------------
      -- spi
      i_dac_sdo        => i_dac_sdo,     -- SPI MISO
      o_spi_sclk       => dac_spi_clk,   -- SPI clock
      o_dac_n_en       => dac_spi_cs_n,  -- SPI chip select
      o_spi_sdata      => dac_spi_mosi,  -- SPI MOSI
      -- specific signal
      o_dac_tx_present => dac_tx_present
      );

---------------------------------------------------------------------
-- AMC
---------------------------------------------------------------------
  amc_spi_cmd_wr_data_valid <= amc_data_valid_r1;
  amc_spi_mode              <= tx_wr_rd_en_r1;
  amc_spi_cmd_wr_data       <= tx_data_r1;

  inst_spi_amc7823 : entity work.spi_amc7823
    generic map(
      g_DATA_WIDTH  => amc_spi_cmd_wr_data'length,
      g_INPUT_DELAY => 1
      )
    port map(
      i_clk               => i_clk,
      i_rst               => i_rst,
      ---------------------------------------------------------------------
      -- command
      ---------------------------------------------------------------------
      -- input
      i_spi_mode          => amc_spi_mode,
      i_spi_cmd_valid     => amc_spi_cmd_wr_data_valid,
      i_spi_cmd_wr_data   => amc_spi_cmd_wr_data,
      -- output
      o_spi_rd_data_valid => amc_spi_rd_data_valid,
      o_spi_rd_data       => amc_spi_rd_data,
      o_spi_ready         => amc_spi_ready,
      o_spi_finish        => amc_spi_finish,
      ---------------------------------------------------------------------
      -- status
      ---------------------------------------------------------------------
      o_status            => amc_status,
      ---------------------------------------------------------------------
      -- from/to IOs
      ---------------------------------------------------------------------
      i_mon_n_int         => i_mon_n_int,  -- galr_n
      i_mon_sdo           => i_mon_sdo,    -- SPI MISO

      o_spi_sclk    => amc_spi_clk,     -- SPI clock
      o_mon_n_en    => amc_spi_cs_n,    -- SPI chip select
      o_spi_sdata   => amc_spi_mosi,    -- SPI MOSI
      o_mon_n_reset => amc_mon_n_reset  -- reset_n
      );

---------------------------------------------------------------------
  -- Error latching
  ---------------------------------------------------------------------
  error_tmp(0) <= error_r1;  -- error: a new command is received during a SPI transaction
  gen_errors_latch : for i in error_tmp'range generate
    inst_one_error_latch : entity work.one_error_latch
      port map(
        i_clk         => i_clk,
        i_rst         => i_rst_status,
        i_debug_pulse => i_debug_pulse,
        i_error       => error_tmp(i),
        o_error       => error_tmp_bis(i)
        );
  end generate gen_errors_latch;

  o_errors(15 downto 1) <= (others => '0');
  o_errors(0)           <= error_tmp_bis(0);

  o_status(7 downto 3) <= (others => '0');
  o_status(2)          <= cdce_status(0);
  o_status(1)          <= amc_status(0);
  o_status(0)          <= ready_r1;

  ---------------------------------------------------------------------
  -- for simulation only
  ---------------------------------------------------------------------
  assert not (error_tmp_bis(0) = '1') report "[spi_device_select] => a new command is received during a SPI transaction" severity error;

---------------------------------------------------------------------
-- debug
---------------------------------------------------------------------
  gen_debug : if g_DEBUG = true generate

  begin

    inst_fpasim_spi_device_select_vio : entity work.fpasim_spi_device_select_vio
      port map (
        CLK           => i_clk,
        probe_out0(0) => debug_cdce_n_reset1,
        probe_out1(0) => debug_cdce_n_pd1,
        probe_out2(0) => debug_cdce_ref_en1
        );


    inst_fpasim_spi_device_select_ila : entity work.fpasim_spi_device_select_ila
      port map(
        clk                 => i_clk,
        -- probe0
        probe0(8)           => dac_tx_present,
        probe0(7)           => rd_data_valid_r1,
        probe0(6)           => i_rst,
        probe0(5)           => i_spi_en,
        probe0(4)           => i_spi_cmd_valid,
        probe0(3)           => cdce_data_valid_r1,
        probe0(2)           => adc_data_valid_r1,
        probe0(1)           => dac_data_valid_r1,
        probe0(0)           => amc_data_valid_r1,
        -- probe1
        probe1(11)          => i_dac_sdo,
        probe1(10)          => i_adc_sdo,
        probe1(9)           => i_cdce_sdo,
        probe1(8)           => amc_spi_cs_n1,
        probe1(7)           => dac_spi_cs_n1,
        probe1(6)           => cdce_spi_cs_n_en1,
        probe1(5)           => adc_spi_cs_n1,
        probe1(4)           => i_mon_sdo,
        probe1(3 downto 2)  => i_spi_id,
        probe1(1)           => spi_clk_r1,
        probe1(0)           => spi_mosi_r1,
        -- probe2
        probe2(31 downto 0) => rd_data_r1

        );

  end generate gen_debug;

end architecture RTL;
