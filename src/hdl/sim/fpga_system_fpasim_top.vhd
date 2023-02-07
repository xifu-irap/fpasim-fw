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
--    @file                   fpga_system_fpasim_top.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details                
--
-- -------------------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library opal_kelly_lib;
context opal_kelly_lib.opal_kelly_context;

library common_lib;
context common_lib.common_context;


entity fpga_system_fpasim_top is
  generic (
    -- ADC
    g_ADC_VPP            : natural := 2;  -- ADC differential input voltage ( Vpp expressed in Volts)
    g_ADC_DELAY          : natural := 0;  -- ADC conversion delay
    -- DAC
    g_DAC_VPP            : natural := 2;  -- DAC differential output voltage ( Vpp expressed in Volts)
    g_DAC_DELAY          : natural := 0;  -- DAC conversion delay
    -- design parameters
    g_FPASIM_GAIN        : natural := 3;  -- 0:0.25, 1:0.5, 3:1, 4:1.5, 5:2, 6:3, 7:4
    g_MUX_SQ_FB_DELAY    : natural := 3;  -- [0;(2**6) - 1]
    g_AMP_SQ_OF_DELAY    : natural := 3;  -- [0;(2**6) - 1]
    g_ERROR_DELAY        : natural := 3;  -- [0;(2**6) - 1]
    g_RA_DELAY           : natural := 4;  -- [0;(2**6) - 1]
    g_NB_PIXEL_BY_FRAME  : natural := 34;
    g_NB_SAMPLE_BY_PIXEL : natural := 40
    );
  port (

    ---------------------------------------------------------------------
    -- command
    ---------------------------------------------------------------------
    i_make_pulse_valid : in  std_logic;
    i_make_pulse       : in  std_logic_vector(31 downto 0);
    o_auto_conf_busy   : out std_logic;
    o_ready            : out std_logic;
    ---------------------------------------------------------------------
    -- ADC
    ---------------------------------------------------------------------
    i_adc_clk_phase    : in std_logic;
    i_adc_clk          : in  std_logic;
    i_adc0_real        : in  real;
    i_adc1_real        : in  real;

    ---------------------------------------------------------------------
    -- to sync
    ---------------------------------------------------------------------
    o_ref_clk : out std_logic;
    o_sync    : out std_logic;

    ---------------------------------------------------------------------
    -- to DAC
    ---------------------------------------------------------------------
    o_dac_real_valid : out std_logic;
    o_dac_real       : out real
    );
end entity fpga_system_fpasim_top;

architecture RTL of fpga_system_fpasim_top is

  --  Opal Kelly inouts --
  signal i_okUH  : std_logic_vector(4 downto 0);
  signal o_okHU  : std_logic_vector(2 downto 0);
  signal b_okUHU : std_logic_vector(31 downto 0);
  signal b_okAA  : std_logic;


  ---------------------------------------------------------------------
  -- additional signals
  ---------------------------------------------------------------------
  -- Clocks
  signal usb_clk           : std_logic := '0';
  signal auto_conf_busy_r1 : std_logic := '1';
  signal ready_r1          : std_logic := '0';
  ---------------------------------------------------------------------
  -- Clock definition
  ---------------------------------------------------------------------
  constant c_CLK_PERIOD0   : time      := 9.99206 ns;  -- @100.8MHz (usb3 opal kelly speed)

  ---------------------------------------------------------------------
  -- USB signal definition
  ---------------------------------------------------------------------

  signal usb_wr_if0 : opal_kelly_lib.pkg_front_panel.t_internal_wr_if := (
    hi_drive   => '0',
    hi_cmd     => (others => '0'),
    hi_dataout => (others => '0')
    );

  signal usb_rd_if0 : opal_kelly_lib.pkg_front_panel.t_internal_rd_if := (
    i_clk     => '0',
    hi_busy   => '0',
    hi_datain => (others => '0')
    );

  shared variable v_front_panel_conf : opal_kelly_lib.pkg_front_panel.t_front_panel_conf;
  constant c_WIRE_NO_MASK            : std_logic_vector(31 downto 0) := x"ffff_ffff";  -- wire mask value

  function uint_to_stdv (
     constant value_p :  integer; width_p: integer
     )
     return std_logic_vector is
     variable v_value_vect : std_logic_vector(width_p - 1 downto 0);
  begin
    v_value_vect := std_logic_vector(to_unsigned(value_p,width_p));
    return v_value_vect;
  end function uint_to_stdv;

begin

---------------------------------------------------------------------
  -- Clock generation
  ---------------------------------------------------------------------
  p_usb_clk_gen : process is
  begin
    usb_clk <= '0';
    wait for c_CLK_PERIOD0 / 2;
    usb_clk <= '1';
    wait for c_CLK_PERIOD0 / 2;
  end process p_usb_clk_gen;

  ---------------------------------------------------------------------
  -- Input/Output: USB controller
  ---------------------------------------------------------------------

  opal_kelly_lib.pkg_front_panel.okHost_driver(
    i_clk            => usb_clk,
    o_okUH           => i_okUH,
    i_okHU           => o_okHU,
    b_okUHU          => b_okUHU,
    i_internal_wr_if => usb_wr_if0,
    o_internal_rd_if => usb_rd_if0
    );


  ---------------------------------------------------------------------
  -- master fsm
  ---------------------------------------------------------------------
  p_master_fsm : process is
    variable v_opal_kelly_addr : std_logic_vector(7 downto 0)                       := (others => '0');  -- address value from file
    variable v_data            : integer;  -- data value from file
    variable v_data_vect       : std_logic_vector(31 downto 0) := (others => '0');  -- data value from file
  begin
    auto_conf_busy_r1 <= '1';
    ready_r1          <= '0';

    ---------------------------------------------------------------------
    -- set Ctrl: enable reset
    ---------------------------------------------------------------------
    v_opal_kelly_addr := x"00";
    v_data_vect            := x"0000_0002";  -- reset bit to '1'
    SetWireInValue(
      i_ep               => v_opal_kelly_addr,
      i_val              => v_data_vect,
      i_mask             => c_WIRE_NO_MASK,
      b_front_panel_conf => v_front_panel_conf
      );

    UpdateWireIns(
      b_front_panel_conf => v_front_panel_conf,
      o_internal_wr_if   => usb_wr_if0,
      i_internal_rd_if   => usb_rd_if0);

    pkg_wait_nb_rising_edge_plus_margin(i_clk => usb_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    ---------------------------------------------------------------------
    -- set Ctrl: disable reset
    ---------------------------------------------------------------------
    v_opal_kelly_addr := x"00";
    v_data_vect            := x"0000_0000";  -- reset bit to '1'
    SetWireInValue(
      i_ep               => v_opal_kelly_addr,
      i_val              => v_data_vect,
      i_mask             => c_WIRE_NO_MASK,
      b_front_panel_conf => v_front_panel_conf
      );

    UpdateWireIns(
      b_front_panel_conf => v_front_panel_conf,
      o_internal_wr_if   => usb_wr_if0,
      i_internal_rd_if   => usb_rd_if0);

    ---------------------------------------------------------------------
    -- add tempo: to wait the end of the reset 
    ---------------------------------------------------------------------
    pkg_wait_nb_rising_edge_plus_margin(i_clk => usb_clk, i_nb_rising_edge => 16, i_margin => 12 ps);

     ---------------------------------------------------------------------
    -- set FPASIM_GAIN
    ---------------------------------------------------------------------
    v_opal_kelly_addr := x"02";
    v_data            := g_FPASIM_GAIN;  -- reset bit to '1'
    v_data_vect := uint_to_stdv(value_p=> v_data,width_p=> 32);
    SetWireInValue(
      i_ep               => v_opal_kelly_addr,
      i_val              => v_data_vect,
      i_mask             => c_WIRE_NO_MASK,
      b_front_panel_conf => v_front_panel_conf
      );

    UpdateWireIns(
      b_front_panel_conf => v_front_panel_conf,
      o_internal_wr_if   => usb_wr_if0,
      i_internal_rd_if   => usb_rd_if0);

    pkg_wait_nb_rising_edge_plus_margin(i_clk => usb_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    ---------------------------------------------------------------------
    -- set MUX_SQ_FB_DELAY
    ---------------------------------------------------------------------
    v_opal_kelly_addr := x"03";
    v_data            := g_MUX_SQ_FB_DELAY;
    v_data_vect := uint_to_stdv(value_p=> v_data,width_p=> 32);
    SetWireInValue(
      i_ep               => v_opal_kelly_addr,
      i_val              => v_data_vect,
      i_mask             => c_WIRE_NO_MASK,
      b_front_panel_conf => v_front_panel_conf
      );

    UpdateWireIns(
      b_front_panel_conf => v_front_panel_conf,
      o_internal_wr_if   => usb_wr_if0,
      i_internal_rd_if   => usb_rd_if0);

    pkg_wait_nb_rising_edge_plus_margin(i_clk => usb_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    ---------------------------------------------------------------------
    -- set AMP_SQ_OF_DELAY
    ---------------------------------------------------------------------
    v_opal_kelly_addr := x"04";
    v_data            := g_AMP_SQ_OF_DELAY;
    v_data_vect := uint_to_stdv(value_p=> v_data,width_p=> 32);
    SetWireInValue(
      i_ep               => v_opal_kelly_addr,
      i_val              => v_data_vect,
      i_mask             => c_WIRE_NO_MASK,
      b_front_panel_conf => v_front_panel_conf
      );

    UpdateWireIns(
      b_front_panel_conf => v_front_panel_conf,
      o_internal_wr_if   => usb_wr_if0,
      i_internal_rd_if   => usb_rd_if0);

    pkg_wait_nb_rising_edge_plus_margin(i_clk => usb_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    ---------------------------------------------------------------------
    -- set ERROR_DELAY
    ---------------------------------------------------------------------
    v_opal_kelly_addr := x"05";
    v_data            := g_ERROR_DELAY;
    v_data_vect := uint_to_stdv(value_p=> v_data,width_p=> 32);
    SetWireInValue(
      i_ep               => v_opal_kelly_addr,
      i_val              => v_data_vect,
      i_mask             => c_WIRE_NO_MASK,
      b_front_panel_conf => v_front_panel_conf
      );

    UpdateWireIns(
      b_front_panel_conf => v_front_panel_conf,
      o_internal_wr_if   => usb_wr_if0,
      i_internal_rd_if   => usb_rd_if0);

    pkg_wait_nb_rising_edge_plus_margin(i_clk => usb_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    ---------------------------------------------------------------------
    -- set RA_DELAY
    ---------------------------------------------------------------------
    v_opal_kelly_addr := x"06";
    v_data            := g_RA_DELAY;
    v_data_vect := uint_to_stdv(value_p=> v_data,width_p=> 32);
    SetWireInValue(
      i_ep               => v_opal_kelly_addr,
      i_val              => v_data_vect,
      i_mask             => c_WIRE_NO_MASK,
      b_front_panel_conf => v_front_panel_conf
      );

    UpdateWireIns(
      b_front_panel_conf => v_front_panel_conf,
      o_internal_wr_if   => usb_wr_if0,
      i_internal_rd_if   => usb_rd_if0);

    pkg_wait_nb_rising_edge_plus_margin(i_clk => usb_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    ---------------------------------------------------------------------
    -- set TES_CONF
    ---------------------------------------------------------------------
    v_opal_kelly_addr := x"07";
    v_data            := ((g_NB_PIXEL_BY_FRAME - 1) * (2**24)) + ((g_NB_SAMPLE_BY_PIXEL - 1) *(2**16)) + ((g_NB_PIXEL_BY_FRAME*g_NB_SAMPLE_BY_PIXEL - 1) );  -- reset bit to '1'
    v_data_vect := uint_to_stdv(value_p=> v_data,width_p=> 32);
    SetWireInValue(
      i_ep               => v_opal_kelly_addr,
      i_val              => v_data_vect,
      i_mask             => c_WIRE_NO_MASK,
      b_front_panel_conf => v_front_panel_conf
      );

    UpdateWireIns(
      b_front_panel_conf => v_front_panel_conf,
      o_internal_wr_if   => usb_wr_if0,
      i_internal_rd_if   => usb_rd_if0);

    pkg_wait_nb_rising_edge_plus_margin(i_clk => usb_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    ---------------------------------------------------------------------
    -- trig reg_valid bit
    ---------------------------------------------------------------------
    v_opal_kelly_addr := x"40";
    v_data_vect       := x"0000_0001";
    ActivateTriggerIn_by_data(
      i_ep             => v_opal_kelly_addr,
      i_data           => v_data_vect,
      o_internal_wr_if => usb_wr_if0,
      i_internal_rd_if => usb_rd_if0
      );

    ---------------------------------------------------------------------
    -- set Ctrl: enable
    ---------------------------------------------------------------------
    v_opal_kelly_addr := x"00";
    v_data_vect            := x"0000_0001";  -- enable bit to '1'
    SetWireInValue(
      i_ep               => v_opal_kelly_addr,
      i_val              => v_data_vect,
      i_mask             => c_WIRE_NO_MASK,
      b_front_panel_conf => v_front_panel_conf
      );

    UpdateWireIns(
      b_front_panel_conf => v_front_panel_conf,
      o_internal_wr_if   => usb_wr_if0,
      i_internal_rd_if   => usb_rd_if0);

    pkg_wait_nb_rising_edge_plus_margin(i_clk => usb_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    ---------------------------------------------------------------------
    -- trig ctrl_valid bit
    ---------------------------------------------------------------------
    v_opal_kelly_addr := x"40";
    v_data            := 2**12;
    v_data_vect := uint_to_stdv(value_p=> v_data,width_p=> 32);
    ActivateTriggerIn_by_data(
      i_ep             => v_opal_kelly_addr,
      i_data           => v_data_vect,
      o_internal_wr_if => usb_wr_if0,
      i_internal_rd_if => usb_rd_if0
      );
    pkg_wait_nb_rising_edge_plus_margin(i_clk => usb_clk, i_nb_rising_edge => 1, i_margin => 12 ps);

    auto_conf_busy_r1 <= '0';

    while true loop
      if i_make_pulse_valid = '1' then
        ready_r1          <= '0';
        ---------------------------------------------------------------------
        -- set Make pulse
        ---------------------------------------------------------------------
        v_opal_kelly_addr := x"01";
        v_data_vect            := i_make_pulse;
        SetWireInValue(
          i_ep               => v_opal_kelly_addr,
          i_val              => v_data_vect,
          i_mask             => c_WIRE_NO_MASK,
          b_front_panel_conf => v_front_panel_conf
          );

        UpdateWireIns(
          b_front_panel_conf => v_front_panel_conf,
          o_internal_wr_if   => usb_wr_if0,
          i_internal_rd_if   => usb_rd_if0);

        ---------------------------------------------------------------------
        -- trig make_pulse bit
        ---------------------------------------------------------------------
        v_opal_kelly_addr := x"40";
        v_data            := 2**4;
        v_data_vect := uint_to_stdv(value_p=> v_data,width_p=> 32);
        ActivateTriggerIn_by_data(
          i_ep             => v_opal_kelly_addr,
          i_data           => v_data_vect,
          o_internal_wr_if => usb_wr_if0,
          i_internal_rd_if => usb_rd_if0
          );

        ready_r1 <= '1';
      else
        ready_r1 <= '1';
      end if;
      pkg_wait_nb_rising_edge_plus_margin(i_clk => i_adc_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;




  end process;

  o_auto_conf_busy <= auto_conf_busy_r1;
  o_ready          <= ready_r1;

---------------------------------------------------------------------
-- system_fpasim_top
---------------------------------------------------------------------
  inst_fpga_system_fpasim : entity work.fpga_system_fpasim
    generic map(
      -- ADC
      g_ADC_VPP   => g_ADC_VPP,  -- ADC differential input voltage ( Vpp expressed in Volts)
      g_ADC_DELAY => g_ADC_DELAY,       -- ADC conversion delay
      -- DAC
      g_DAC_VPP   => g_DAC_VPP,  -- DAC differential output voltage ( Vpp expressed in Volts)
      g_DAC_DELAY => g_DAC_DELAY        -- DAC conversion delay
      )
    port map(
      --  Opal Kelly inouts --
      i_okUH           => i_okUH,
      o_okHU           => o_okHU,
      b_okUHU          => b_okUHU,
      b_okAA           => b_okAA,
      ---------------------------------------------------------------------
      -- ADC
      ---------------------------------------------------------------------
      i_adc_clk_phase  => i_adc_clk_phase,
      i_adc_clk        => i_adc_clk,
      i_adc0_real      => i_adc0_real,
      i_adc1_real      => i_adc1_real,
      ---------------------------------------------------------------------
      -- to sync
      ---------------------------------------------------------------------
      o_ref_clk        => o_ref_clk,
      o_sync           => o_sync,
      ---------------------------------------------------------------------
      -- DAC
      ---------------------------------------------------------------------
      o_dac_real_valid => o_dac_real_valid,
      o_dac_real       => o_dac_real
      );


end architecture RTL;
