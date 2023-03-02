-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
-- Date        : Mon Jan  9 12:03:51 2023
-- Host        : PC-PAUL running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim -rename_top selectio_wiz_adc -prefix
--               selectio_wiz_adc_ selectio_wiz_adc_sim_netlist.vhdl
-- Design      : selectio_wiz_adc
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7k160tffg676-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity selectio_wiz_adc_selectio_wiz_adc_selectio_wiz is
  port (
    data_in_from_pins_p : in STD_LOGIC_VECTOR ( 13 downto 0 );
    data_in_from_pins_n : in STD_LOGIC_VECTOR ( 13 downto 0 );
    data_in_to_device : out STD_LOGIC_VECTOR ( 111 downto 0 );
    bitslip : in STD_LOGIC_VECTOR ( 13 downto 0 );
    clk_in_p : in STD_LOGIC;
    clk_in_n : in STD_LOGIC;
    clk_div_out : out STD_LOGIC;
    clk_reset : in STD_LOGIC;
    io_reset : in STD_LOGIC
  );
  attribute DEV_W : integer;
  attribute DEV_W of selectio_wiz_adc_selectio_wiz_adc_selectio_wiz : entity is 112;
  attribute SYS_W : integer;
  attribute SYS_W of selectio_wiz_adc_selectio_wiz_adc_selectio_wiz : entity is 14;
  attribute num_serial_bits : integer;
  attribute num_serial_bits of selectio_wiz_adc_selectio_wiz_adc_selectio_wiz : entity is 8;
end selectio_wiz_adc_selectio_wiz_adc_selectio_wiz;

architecture STRUCTURE of selectio_wiz_adc_selectio_wiz_adc_selectio_wiz is
  signal \^clk_div_out\ : STD_LOGIC;
  signal clk_in_int : STD_LOGIC;
  signal clk_in_int_buf : STD_LOGIC;
  signal data_in_from_pins_int_0 : STD_LOGIC;
  signal data_in_from_pins_int_1 : STD_LOGIC;
  signal data_in_from_pins_int_10 : STD_LOGIC;
  signal data_in_from_pins_int_11 : STD_LOGIC;
  signal data_in_from_pins_int_12 : STD_LOGIC;
  signal data_in_from_pins_int_13 : STD_LOGIC;
  signal data_in_from_pins_int_2 : STD_LOGIC;
  signal data_in_from_pins_int_3 : STD_LOGIC;
  signal data_in_from_pins_int_4 : STD_LOGIC;
  signal data_in_from_pins_int_5 : STD_LOGIC;
  signal data_in_from_pins_int_6 : STD_LOGIC;
  signal data_in_from_pins_int_7 : STD_LOGIC;
  signal data_in_from_pins_int_8 : STD_LOGIC;
  signal data_in_from_pins_int_9 : STD_LOGIC;
  signal \NLW_pins[0].iserdese2_master_O_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[0].iserdese2_master_SHIFTOUT1_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[0].iserdese2_master_SHIFTOUT2_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[10].iserdese2_master_O_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[10].iserdese2_master_SHIFTOUT1_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[10].iserdese2_master_SHIFTOUT2_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[11].iserdese2_master_O_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[11].iserdese2_master_SHIFTOUT1_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[11].iserdese2_master_SHIFTOUT2_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[12].iserdese2_master_O_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[12].iserdese2_master_SHIFTOUT1_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[12].iserdese2_master_SHIFTOUT2_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[13].iserdese2_master_O_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[13].iserdese2_master_SHIFTOUT1_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[13].iserdese2_master_SHIFTOUT2_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[1].iserdese2_master_O_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[1].iserdese2_master_SHIFTOUT1_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[1].iserdese2_master_SHIFTOUT2_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[2].iserdese2_master_O_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[2].iserdese2_master_SHIFTOUT1_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[2].iserdese2_master_SHIFTOUT2_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[3].iserdese2_master_O_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[3].iserdese2_master_SHIFTOUT1_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[3].iserdese2_master_SHIFTOUT2_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[4].iserdese2_master_O_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[4].iserdese2_master_SHIFTOUT1_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[4].iserdese2_master_SHIFTOUT2_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[5].iserdese2_master_O_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[5].iserdese2_master_SHIFTOUT1_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[5].iserdese2_master_SHIFTOUT2_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[6].iserdese2_master_O_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[6].iserdese2_master_SHIFTOUT1_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[6].iserdese2_master_SHIFTOUT2_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[7].iserdese2_master_O_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[7].iserdese2_master_SHIFTOUT1_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[7].iserdese2_master_SHIFTOUT2_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[8].iserdese2_master_O_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[8].iserdese2_master_SHIFTOUT1_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[8].iserdese2_master_SHIFTOUT2_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[9].iserdese2_master_O_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[9].iserdese2_master_SHIFTOUT1_UNCONNECTED\ : STD_LOGIC;
  signal \NLW_pins[9].iserdese2_master_SHIFTOUT2_UNCONNECTED\ : STD_LOGIC;
  attribute BOX_TYPE : string;
  attribute BOX_TYPE of bufio_inst : label is "PRIMITIVE";
  attribute BOX_TYPE of clkout_buf_inst : label is "PRIMITIVE";
  attribute BOX_TYPE of ibufds_clk_inst : label is "PRIMITIVE";
  attribute CAPACITANCE : string;
  attribute CAPACITANCE of ibufds_clk_inst : label is "DONT_CARE";
  attribute IBUF_DELAY_VALUE : string;
  attribute IBUF_DELAY_VALUE of ibufds_clk_inst : label is "0";
  attribute IFD_DELAY_VALUE : string;
  attribute IFD_DELAY_VALUE of ibufds_clk_inst : label is "AUTO";
  attribute BOX_TYPE of \pins[0].ibufds_inst\ : label is "PRIMITIVE";
  attribute CAPACITANCE of \pins[0].ibufds_inst\ : label is "DONT_CARE";
  attribute IBUF_DELAY_VALUE of \pins[0].ibufds_inst\ : label is "0";
  attribute IFD_DELAY_VALUE of \pins[0].ibufds_inst\ : label is "AUTO";
  attribute BOX_TYPE of \pins[0].iserdese2_master\ : label is "PRIMITIVE";
  attribute OPT_MODIFIED : string;
  attribute OPT_MODIFIED of \pins[0].iserdese2_master\ : label is "MLO";
  attribute BOX_TYPE of \pins[10].ibufds_inst\ : label is "PRIMITIVE";
  attribute CAPACITANCE of \pins[10].ibufds_inst\ : label is "DONT_CARE";
  attribute IBUF_DELAY_VALUE of \pins[10].ibufds_inst\ : label is "0";
  attribute IFD_DELAY_VALUE of \pins[10].ibufds_inst\ : label is "AUTO";
  attribute BOX_TYPE of \pins[10].iserdese2_master\ : label is "PRIMITIVE";
  attribute OPT_MODIFIED of \pins[10].iserdese2_master\ : label is "MLO";
  attribute BOX_TYPE of \pins[11].ibufds_inst\ : label is "PRIMITIVE";
  attribute CAPACITANCE of \pins[11].ibufds_inst\ : label is "DONT_CARE";
  attribute IBUF_DELAY_VALUE of \pins[11].ibufds_inst\ : label is "0";
  attribute IFD_DELAY_VALUE of \pins[11].ibufds_inst\ : label is "AUTO";
  attribute BOX_TYPE of \pins[11].iserdese2_master\ : label is "PRIMITIVE";
  attribute OPT_MODIFIED of \pins[11].iserdese2_master\ : label is "MLO";
  attribute BOX_TYPE of \pins[12].ibufds_inst\ : label is "PRIMITIVE";
  attribute CAPACITANCE of \pins[12].ibufds_inst\ : label is "DONT_CARE";
  attribute IBUF_DELAY_VALUE of \pins[12].ibufds_inst\ : label is "0";
  attribute IFD_DELAY_VALUE of \pins[12].ibufds_inst\ : label is "AUTO";
  attribute BOX_TYPE of \pins[12].iserdese2_master\ : label is "PRIMITIVE";
  attribute OPT_MODIFIED of \pins[12].iserdese2_master\ : label is "MLO";
  attribute BOX_TYPE of \pins[13].ibufds_inst\ : label is "PRIMITIVE";
  attribute CAPACITANCE of \pins[13].ibufds_inst\ : label is "DONT_CARE";
  attribute IBUF_DELAY_VALUE of \pins[13].ibufds_inst\ : label is "0";
  attribute IFD_DELAY_VALUE of \pins[13].ibufds_inst\ : label is "AUTO";
  attribute BOX_TYPE of \pins[13].iserdese2_master\ : label is "PRIMITIVE";
  attribute OPT_MODIFIED of \pins[13].iserdese2_master\ : label is "MLO";
  attribute BOX_TYPE of \pins[1].ibufds_inst\ : label is "PRIMITIVE";
  attribute CAPACITANCE of \pins[1].ibufds_inst\ : label is "DONT_CARE";
  attribute IBUF_DELAY_VALUE of \pins[1].ibufds_inst\ : label is "0";
  attribute IFD_DELAY_VALUE of \pins[1].ibufds_inst\ : label is "AUTO";
  attribute BOX_TYPE of \pins[1].iserdese2_master\ : label is "PRIMITIVE";
  attribute OPT_MODIFIED of \pins[1].iserdese2_master\ : label is "MLO";
  attribute BOX_TYPE of \pins[2].ibufds_inst\ : label is "PRIMITIVE";
  attribute CAPACITANCE of \pins[2].ibufds_inst\ : label is "DONT_CARE";
  attribute IBUF_DELAY_VALUE of \pins[2].ibufds_inst\ : label is "0";
  attribute IFD_DELAY_VALUE of \pins[2].ibufds_inst\ : label is "AUTO";
  attribute BOX_TYPE of \pins[2].iserdese2_master\ : label is "PRIMITIVE";
  attribute OPT_MODIFIED of \pins[2].iserdese2_master\ : label is "MLO";
  attribute BOX_TYPE of \pins[3].ibufds_inst\ : label is "PRIMITIVE";
  attribute CAPACITANCE of \pins[3].ibufds_inst\ : label is "DONT_CARE";
  attribute IBUF_DELAY_VALUE of \pins[3].ibufds_inst\ : label is "0";
  attribute IFD_DELAY_VALUE of \pins[3].ibufds_inst\ : label is "AUTO";
  attribute BOX_TYPE of \pins[3].iserdese2_master\ : label is "PRIMITIVE";
  attribute OPT_MODIFIED of \pins[3].iserdese2_master\ : label is "MLO";
  attribute BOX_TYPE of \pins[4].ibufds_inst\ : label is "PRIMITIVE";
  attribute CAPACITANCE of \pins[4].ibufds_inst\ : label is "DONT_CARE";
  attribute IBUF_DELAY_VALUE of \pins[4].ibufds_inst\ : label is "0";
  attribute IFD_DELAY_VALUE of \pins[4].ibufds_inst\ : label is "AUTO";
  attribute BOX_TYPE of \pins[4].iserdese2_master\ : label is "PRIMITIVE";
  attribute OPT_MODIFIED of \pins[4].iserdese2_master\ : label is "MLO";
  attribute BOX_TYPE of \pins[5].ibufds_inst\ : label is "PRIMITIVE";
  attribute CAPACITANCE of \pins[5].ibufds_inst\ : label is "DONT_CARE";
  attribute IBUF_DELAY_VALUE of \pins[5].ibufds_inst\ : label is "0";
  attribute IFD_DELAY_VALUE of \pins[5].ibufds_inst\ : label is "AUTO";
  attribute BOX_TYPE of \pins[5].iserdese2_master\ : label is "PRIMITIVE";
  attribute OPT_MODIFIED of \pins[5].iserdese2_master\ : label is "MLO";
  attribute BOX_TYPE of \pins[6].ibufds_inst\ : label is "PRIMITIVE";
  attribute CAPACITANCE of \pins[6].ibufds_inst\ : label is "DONT_CARE";
  attribute IBUF_DELAY_VALUE of \pins[6].ibufds_inst\ : label is "0";
  attribute IFD_DELAY_VALUE of \pins[6].ibufds_inst\ : label is "AUTO";
  attribute BOX_TYPE of \pins[6].iserdese2_master\ : label is "PRIMITIVE";
  attribute OPT_MODIFIED of \pins[6].iserdese2_master\ : label is "MLO";
  attribute BOX_TYPE of \pins[7].ibufds_inst\ : label is "PRIMITIVE";
  attribute CAPACITANCE of \pins[7].ibufds_inst\ : label is "DONT_CARE";
  attribute IBUF_DELAY_VALUE of \pins[7].ibufds_inst\ : label is "0";
  attribute IFD_DELAY_VALUE of \pins[7].ibufds_inst\ : label is "AUTO";
  attribute BOX_TYPE of \pins[7].iserdese2_master\ : label is "PRIMITIVE";
  attribute OPT_MODIFIED of \pins[7].iserdese2_master\ : label is "MLO";
  attribute BOX_TYPE of \pins[8].ibufds_inst\ : label is "PRIMITIVE";
  attribute CAPACITANCE of \pins[8].ibufds_inst\ : label is "DONT_CARE";
  attribute IBUF_DELAY_VALUE of \pins[8].ibufds_inst\ : label is "0";
  attribute IFD_DELAY_VALUE of \pins[8].ibufds_inst\ : label is "AUTO";
  attribute BOX_TYPE of \pins[8].iserdese2_master\ : label is "PRIMITIVE";
  attribute OPT_MODIFIED of \pins[8].iserdese2_master\ : label is "MLO";
  attribute BOX_TYPE of \pins[9].ibufds_inst\ : label is "PRIMITIVE";
  attribute CAPACITANCE of \pins[9].ibufds_inst\ : label is "DONT_CARE";
  attribute IBUF_DELAY_VALUE of \pins[9].ibufds_inst\ : label is "0";
  attribute IFD_DELAY_VALUE of \pins[9].ibufds_inst\ : label is "AUTO";
  attribute BOX_TYPE of \pins[9].iserdese2_master\ : label is "PRIMITIVE";
  attribute OPT_MODIFIED of \pins[9].iserdese2_master\ : label is "MLO";
begin
  clk_div_out <= \^clk_div_out\;
bufio_inst: unisim.vcomponents.BUFIO
     port map (
      I => clk_in_int,
      O => clk_in_int_buf
    );
clkout_buf_inst: unisim.vcomponents.BUFR
    generic map(
      BUFR_DIVIDE => "4",
      SIM_DEVICE => "7SERIES"
    )
        port map (
      CE => '1',
      CLR => clk_reset,
      I => clk_in_int,
      O => \^clk_div_out\
    );
ibufds_clk_inst: unisim.vcomponents.IBUFDS
     port map (
      I => clk_in_p,
      IB => clk_in_n,
      O => clk_in_int
    );
\pins[0].ibufds_inst\: unisim.vcomponents.IBUFDS
     port map (
      I => data_in_from_pins_p(0),
      IB => data_in_from_pins_n(0),
      O => data_in_from_pins_int_0
    );
\pins[0].iserdese2_master\: unisim.vcomponents.ISERDESE2
    generic map(
      DATA_RATE => "DDR",
      DATA_WIDTH => 8,
      DYN_CLKDIV_INV_EN => "FALSE",
      DYN_CLK_INV_EN => "FALSE",
      INIT_Q1 => '0',
      INIT_Q2 => '0',
      INIT_Q3 => '0',
      INIT_Q4 => '0',
      INTERFACE_TYPE => "NETWORKING",
      IOBDELAY => "NONE",
      IS_CLKB_INVERTED => '1',
      IS_CLKDIVP_INVERTED => '0',
      IS_CLKDIV_INVERTED => '0',
      IS_CLK_INVERTED => '0',
      IS_D_INVERTED => '0',
      IS_OCLKB_INVERTED => '0',
      IS_OCLK_INVERTED => '0',
      NUM_CE => 2,
      OFB_USED => "FALSE",
      SERDES_MODE => "MASTER",
      SRVAL_Q1 => '0',
      SRVAL_Q2 => '0',
      SRVAL_Q3 => '0',
      SRVAL_Q4 => '0'
    )
        port map (
      BITSLIP => bitslip(0),
      CE1 => '1',
      CE2 => '1',
      CLK => clk_in_int_buf,
      CLKB => clk_in_int_buf,
      CLKDIV => \^clk_div_out\,
      CLKDIVP => '0',
      D => data_in_from_pins_int_0,
      DDLY => '0',
      DYNCLKDIVSEL => '0',
      DYNCLKSEL => '0',
      O => \NLW_pins[0].iserdese2_master_O_UNCONNECTED\,
      OCLK => '0',
      OCLKB => '0',
      OFB => '0',
      Q1 => data_in_to_device(98),
      Q2 => data_in_to_device(84),
      Q3 => data_in_to_device(70),
      Q4 => data_in_to_device(56),
      Q5 => data_in_to_device(42),
      Q6 => data_in_to_device(28),
      Q7 => data_in_to_device(14),
      Q8 => data_in_to_device(0),
      RST => io_reset,
      SHIFTIN1 => '0',
      SHIFTIN2 => '0',
      SHIFTOUT1 => \NLW_pins[0].iserdese2_master_SHIFTOUT1_UNCONNECTED\,
      SHIFTOUT2 => \NLW_pins[0].iserdese2_master_SHIFTOUT2_UNCONNECTED\
    );
\pins[10].ibufds_inst\: unisim.vcomponents.IBUFDS
     port map (
      I => data_in_from_pins_p(10),
      IB => data_in_from_pins_n(10),
      O => data_in_from_pins_int_10
    );
\pins[10].iserdese2_master\: unisim.vcomponents.ISERDESE2
    generic map(
      DATA_RATE => "DDR",
      DATA_WIDTH => 8,
      DYN_CLKDIV_INV_EN => "FALSE",
      DYN_CLK_INV_EN => "FALSE",
      INIT_Q1 => '0',
      INIT_Q2 => '0',
      INIT_Q3 => '0',
      INIT_Q4 => '0',
      INTERFACE_TYPE => "NETWORKING",
      IOBDELAY => "NONE",
      IS_CLKB_INVERTED => '1',
      IS_CLKDIVP_INVERTED => '0',
      IS_CLKDIV_INVERTED => '0',
      IS_CLK_INVERTED => '0',
      IS_D_INVERTED => '0',
      IS_OCLKB_INVERTED => '0',
      IS_OCLK_INVERTED => '0',
      NUM_CE => 2,
      OFB_USED => "FALSE",
      SERDES_MODE => "MASTER",
      SRVAL_Q1 => '0',
      SRVAL_Q2 => '0',
      SRVAL_Q3 => '0',
      SRVAL_Q4 => '0'
    )
        port map (
      BITSLIP => bitslip(10),
      CE1 => '1',
      CE2 => '1',
      CLK => clk_in_int_buf,
      CLKB => clk_in_int_buf,
      CLKDIV => \^clk_div_out\,
      CLKDIVP => '0',
      D => data_in_from_pins_int_10,
      DDLY => '0',
      DYNCLKDIVSEL => '0',
      DYNCLKSEL => '0',
      O => \NLW_pins[10].iserdese2_master_O_UNCONNECTED\,
      OCLK => '0',
      OCLKB => '0',
      OFB => '0',
      Q1 => data_in_to_device(108),
      Q2 => data_in_to_device(94),
      Q3 => data_in_to_device(80),
      Q4 => data_in_to_device(66),
      Q5 => data_in_to_device(52),
      Q6 => data_in_to_device(38),
      Q7 => data_in_to_device(24),
      Q8 => data_in_to_device(10),
      RST => io_reset,
      SHIFTIN1 => '0',
      SHIFTIN2 => '0',
      SHIFTOUT1 => \NLW_pins[10].iserdese2_master_SHIFTOUT1_UNCONNECTED\,
      SHIFTOUT2 => \NLW_pins[10].iserdese2_master_SHIFTOUT2_UNCONNECTED\
    );
\pins[11].ibufds_inst\: unisim.vcomponents.IBUFDS
     port map (
      I => data_in_from_pins_p(11),
      IB => data_in_from_pins_n(11),
      O => data_in_from_pins_int_11
    );
\pins[11].iserdese2_master\: unisim.vcomponents.ISERDESE2
    generic map(
      DATA_RATE => "DDR",
      DATA_WIDTH => 8,
      DYN_CLKDIV_INV_EN => "FALSE",
      DYN_CLK_INV_EN => "FALSE",
      INIT_Q1 => '0',
      INIT_Q2 => '0',
      INIT_Q3 => '0',
      INIT_Q4 => '0',
      INTERFACE_TYPE => "NETWORKING",
      IOBDELAY => "NONE",
      IS_CLKB_INVERTED => '1',
      IS_CLKDIVP_INVERTED => '0',
      IS_CLKDIV_INVERTED => '0',
      IS_CLK_INVERTED => '0',
      IS_D_INVERTED => '0',
      IS_OCLKB_INVERTED => '0',
      IS_OCLK_INVERTED => '0',
      NUM_CE => 2,
      OFB_USED => "FALSE",
      SERDES_MODE => "MASTER",
      SRVAL_Q1 => '0',
      SRVAL_Q2 => '0',
      SRVAL_Q3 => '0',
      SRVAL_Q4 => '0'
    )
        port map (
      BITSLIP => bitslip(11),
      CE1 => '1',
      CE2 => '1',
      CLK => clk_in_int_buf,
      CLKB => clk_in_int_buf,
      CLKDIV => \^clk_div_out\,
      CLKDIVP => '0',
      D => data_in_from_pins_int_11,
      DDLY => '0',
      DYNCLKDIVSEL => '0',
      DYNCLKSEL => '0',
      O => \NLW_pins[11].iserdese2_master_O_UNCONNECTED\,
      OCLK => '0',
      OCLKB => '0',
      OFB => '0',
      Q1 => data_in_to_device(109),
      Q2 => data_in_to_device(95),
      Q3 => data_in_to_device(81),
      Q4 => data_in_to_device(67),
      Q5 => data_in_to_device(53),
      Q6 => data_in_to_device(39),
      Q7 => data_in_to_device(25),
      Q8 => data_in_to_device(11),
      RST => io_reset,
      SHIFTIN1 => '0',
      SHIFTIN2 => '0',
      SHIFTOUT1 => \NLW_pins[11].iserdese2_master_SHIFTOUT1_UNCONNECTED\,
      SHIFTOUT2 => \NLW_pins[11].iserdese2_master_SHIFTOUT2_UNCONNECTED\
    );
\pins[12].ibufds_inst\: unisim.vcomponents.IBUFDS
     port map (
      I => data_in_from_pins_p(12),
      IB => data_in_from_pins_n(12),
      O => data_in_from_pins_int_12
    );
\pins[12].iserdese2_master\: unisim.vcomponents.ISERDESE2
    generic map(
      DATA_RATE => "DDR",
      DATA_WIDTH => 8,
      DYN_CLKDIV_INV_EN => "FALSE",
      DYN_CLK_INV_EN => "FALSE",
      INIT_Q1 => '0',
      INIT_Q2 => '0',
      INIT_Q3 => '0',
      INIT_Q4 => '0',
      INTERFACE_TYPE => "NETWORKING",
      IOBDELAY => "NONE",
      IS_CLKB_INVERTED => '1',
      IS_CLKDIVP_INVERTED => '0',
      IS_CLKDIV_INVERTED => '0',
      IS_CLK_INVERTED => '0',
      IS_D_INVERTED => '0',
      IS_OCLKB_INVERTED => '0',
      IS_OCLK_INVERTED => '0',
      NUM_CE => 2,
      OFB_USED => "FALSE",
      SERDES_MODE => "MASTER",
      SRVAL_Q1 => '0',
      SRVAL_Q2 => '0',
      SRVAL_Q3 => '0',
      SRVAL_Q4 => '0'
    )
        port map (
      BITSLIP => bitslip(12),
      CE1 => '1',
      CE2 => '1',
      CLK => clk_in_int_buf,
      CLKB => clk_in_int_buf,
      CLKDIV => \^clk_div_out\,
      CLKDIVP => '0',
      D => data_in_from_pins_int_12,
      DDLY => '0',
      DYNCLKDIVSEL => '0',
      DYNCLKSEL => '0',
      O => \NLW_pins[12].iserdese2_master_O_UNCONNECTED\,
      OCLK => '0',
      OCLKB => '0',
      OFB => '0',
      Q1 => data_in_to_device(110),
      Q2 => data_in_to_device(96),
      Q3 => data_in_to_device(82),
      Q4 => data_in_to_device(68),
      Q5 => data_in_to_device(54),
      Q6 => data_in_to_device(40),
      Q7 => data_in_to_device(26),
      Q8 => data_in_to_device(12),
      RST => io_reset,
      SHIFTIN1 => '0',
      SHIFTIN2 => '0',
      SHIFTOUT1 => \NLW_pins[12].iserdese2_master_SHIFTOUT1_UNCONNECTED\,
      SHIFTOUT2 => \NLW_pins[12].iserdese2_master_SHIFTOUT2_UNCONNECTED\
    );
\pins[13].ibufds_inst\: unisim.vcomponents.IBUFDS
     port map (
      I => data_in_from_pins_p(13),
      IB => data_in_from_pins_n(13),
      O => data_in_from_pins_int_13
    );
\pins[13].iserdese2_master\: unisim.vcomponents.ISERDESE2
    generic map(
      DATA_RATE => "DDR",
      DATA_WIDTH => 8,
      DYN_CLKDIV_INV_EN => "FALSE",
      DYN_CLK_INV_EN => "FALSE",
      INIT_Q1 => '0',
      INIT_Q2 => '0',
      INIT_Q3 => '0',
      INIT_Q4 => '0',
      INTERFACE_TYPE => "NETWORKING",
      IOBDELAY => "NONE",
      IS_CLKB_INVERTED => '1',
      IS_CLKDIVP_INVERTED => '0',
      IS_CLKDIV_INVERTED => '0',
      IS_CLK_INVERTED => '0',
      IS_D_INVERTED => '0',
      IS_OCLKB_INVERTED => '0',
      IS_OCLK_INVERTED => '0',
      NUM_CE => 2,
      OFB_USED => "FALSE",
      SERDES_MODE => "MASTER",
      SRVAL_Q1 => '0',
      SRVAL_Q2 => '0',
      SRVAL_Q3 => '0',
      SRVAL_Q4 => '0'
    )
        port map (
      BITSLIP => bitslip(13),
      CE1 => '1',
      CE2 => '1',
      CLK => clk_in_int_buf,
      CLKB => clk_in_int_buf,
      CLKDIV => \^clk_div_out\,
      CLKDIVP => '0',
      D => data_in_from_pins_int_13,
      DDLY => '0',
      DYNCLKDIVSEL => '0',
      DYNCLKSEL => '0',
      O => \NLW_pins[13].iserdese2_master_O_UNCONNECTED\,
      OCLK => '0',
      OCLKB => '0',
      OFB => '0',
      Q1 => data_in_to_device(111),
      Q2 => data_in_to_device(97),
      Q3 => data_in_to_device(83),
      Q4 => data_in_to_device(69),
      Q5 => data_in_to_device(55),
      Q6 => data_in_to_device(41),
      Q7 => data_in_to_device(27),
      Q8 => data_in_to_device(13),
      RST => io_reset,
      SHIFTIN1 => '0',
      SHIFTIN2 => '0',
      SHIFTOUT1 => \NLW_pins[13].iserdese2_master_SHIFTOUT1_UNCONNECTED\,
      SHIFTOUT2 => \NLW_pins[13].iserdese2_master_SHIFTOUT2_UNCONNECTED\
    );
\pins[1].ibufds_inst\: unisim.vcomponents.IBUFDS
     port map (
      I => data_in_from_pins_p(1),
      IB => data_in_from_pins_n(1),
      O => data_in_from_pins_int_1
    );
\pins[1].iserdese2_master\: unisim.vcomponents.ISERDESE2
    generic map(
      DATA_RATE => "DDR",
      DATA_WIDTH => 8,
      DYN_CLKDIV_INV_EN => "FALSE",
      DYN_CLK_INV_EN => "FALSE",
      INIT_Q1 => '0',
      INIT_Q2 => '0',
      INIT_Q3 => '0',
      INIT_Q4 => '0',
      INTERFACE_TYPE => "NETWORKING",
      IOBDELAY => "NONE",
      IS_CLKB_INVERTED => '1',
      IS_CLKDIVP_INVERTED => '0',
      IS_CLKDIV_INVERTED => '0',
      IS_CLK_INVERTED => '0',
      IS_D_INVERTED => '0',
      IS_OCLKB_INVERTED => '0',
      IS_OCLK_INVERTED => '0',
      NUM_CE => 2,
      OFB_USED => "FALSE",
      SERDES_MODE => "MASTER",
      SRVAL_Q1 => '0',
      SRVAL_Q2 => '0',
      SRVAL_Q3 => '0',
      SRVAL_Q4 => '0'
    )
        port map (
      BITSLIP => bitslip(1),
      CE1 => '1',
      CE2 => '1',
      CLK => clk_in_int_buf,
      CLKB => clk_in_int_buf,
      CLKDIV => \^clk_div_out\,
      CLKDIVP => '0',
      D => data_in_from_pins_int_1,
      DDLY => '0',
      DYNCLKDIVSEL => '0',
      DYNCLKSEL => '0',
      O => \NLW_pins[1].iserdese2_master_O_UNCONNECTED\,
      OCLK => '0',
      OCLKB => '0',
      OFB => '0',
      Q1 => data_in_to_device(99),
      Q2 => data_in_to_device(85),
      Q3 => data_in_to_device(71),
      Q4 => data_in_to_device(57),
      Q5 => data_in_to_device(43),
      Q6 => data_in_to_device(29),
      Q7 => data_in_to_device(15),
      Q8 => data_in_to_device(1),
      RST => io_reset,
      SHIFTIN1 => '0',
      SHIFTIN2 => '0',
      SHIFTOUT1 => \NLW_pins[1].iserdese2_master_SHIFTOUT1_UNCONNECTED\,
      SHIFTOUT2 => \NLW_pins[1].iserdese2_master_SHIFTOUT2_UNCONNECTED\
    );
\pins[2].ibufds_inst\: unisim.vcomponents.IBUFDS
     port map (
      I => data_in_from_pins_p(2),
      IB => data_in_from_pins_n(2),
      O => data_in_from_pins_int_2
    );
\pins[2].iserdese2_master\: unisim.vcomponents.ISERDESE2
    generic map(
      DATA_RATE => "DDR",
      DATA_WIDTH => 8,
      DYN_CLKDIV_INV_EN => "FALSE",
      DYN_CLK_INV_EN => "FALSE",
      INIT_Q1 => '0',
      INIT_Q2 => '0',
      INIT_Q3 => '0',
      INIT_Q4 => '0',
      INTERFACE_TYPE => "NETWORKING",
      IOBDELAY => "NONE",
      IS_CLKB_INVERTED => '1',
      IS_CLKDIVP_INVERTED => '0',
      IS_CLKDIV_INVERTED => '0',
      IS_CLK_INVERTED => '0',
      IS_D_INVERTED => '0',
      IS_OCLKB_INVERTED => '0',
      IS_OCLK_INVERTED => '0',
      NUM_CE => 2,
      OFB_USED => "FALSE",
      SERDES_MODE => "MASTER",
      SRVAL_Q1 => '0',
      SRVAL_Q2 => '0',
      SRVAL_Q3 => '0',
      SRVAL_Q4 => '0'
    )
        port map (
      BITSLIP => bitslip(2),
      CE1 => '1',
      CE2 => '1',
      CLK => clk_in_int_buf,
      CLKB => clk_in_int_buf,
      CLKDIV => \^clk_div_out\,
      CLKDIVP => '0',
      D => data_in_from_pins_int_2,
      DDLY => '0',
      DYNCLKDIVSEL => '0',
      DYNCLKSEL => '0',
      O => \NLW_pins[2].iserdese2_master_O_UNCONNECTED\,
      OCLK => '0',
      OCLKB => '0',
      OFB => '0',
      Q1 => data_in_to_device(100),
      Q2 => data_in_to_device(86),
      Q3 => data_in_to_device(72),
      Q4 => data_in_to_device(58),
      Q5 => data_in_to_device(44),
      Q6 => data_in_to_device(30),
      Q7 => data_in_to_device(16),
      Q8 => data_in_to_device(2),
      RST => io_reset,
      SHIFTIN1 => '0',
      SHIFTIN2 => '0',
      SHIFTOUT1 => \NLW_pins[2].iserdese2_master_SHIFTOUT1_UNCONNECTED\,
      SHIFTOUT2 => \NLW_pins[2].iserdese2_master_SHIFTOUT2_UNCONNECTED\
    );
\pins[3].ibufds_inst\: unisim.vcomponents.IBUFDS
     port map (
      I => data_in_from_pins_p(3),
      IB => data_in_from_pins_n(3),
      O => data_in_from_pins_int_3
    );
\pins[3].iserdese2_master\: unisim.vcomponents.ISERDESE2
    generic map(
      DATA_RATE => "DDR",
      DATA_WIDTH => 8,
      DYN_CLKDIV_INV_EN => "FALSE",
      DYN_CLK_INV_EN => "FALSE",
      INIT_Q1 => '0',
      INIT_Q2 => '0',
      INIT_Q3 => '0',
      INIT_Q4 => '0',
      INTERFACE_TYPE => "NETWORKING",
      IOBDELAY => "NONE",
      IS_CLKB_INVERTED => '1',
      IS_CLKDIVP_INVERTED => '0',
      IS_CLKDIV_INVERTED => '0',
      IS_CLK_INVERTED => '0',
      IS_D_INVERTED => '0',
      IS_OCLKB_INVERTED => '0',
      IS_OCLK_INVERTED => '0',
      NUM_CE => 2,
      OFB_USED => "FALSE",
      SERDES_MODE => "MASTER",
      SRVAL_Q1 => '0',
      SRVAL_Q2 => '0',
      SRVAL_Q3 => '0',
      SRVAL_Q4 => '0'
    )
        port map (
      BITSLIP => bitslip(3),
      CE1 => '1',
      CE2 => '1',
      CLK => clk_in_int_buf,
      CLKB => clk_in_int_buf,
      CLKDIV => \^clk_div_out\,
      CLKDIVP => '0',
      D => data_in_from_pins_int_3,
      DDLY => '0',
      DYNCLKDIVSEL => '0',
      DYNCLKSEL => '0',
      O => \NLW_pins[3].iserdese2_master_O_UNCONNECTED\,
      OCLK => '0',
      OCLKB => '0',
      OFB => '0',
      Q1 => data_in_to_device(101),
      Q2 => data_in_to_device(87),
      Q3 => data_in_to_device(73),
      Q4 => data_in_to_device(59),
      Q5 => data_in_to_device(45),
      Q6 => data_in_to_device(31),
      Q7 => data_in_to_device(17),
      Q8 => data_in_to_device(3),
      RST => io_reset,
      SHIFTIN1 => '0',
      SHIFTIN2 => '0',
      SHIFTOUT1 => \NLW_pins[3].iserdese2_master_SHIFTOUT1_UNCONNECTED\,
      SHIFTOUT2 => \NLW_pins[3].iserdese2_master_SHIFTOUT2_UNCONNECTED\
    );
\pins[4].ibufds_inst\: unisim.vcomponents.IBUFDS
     port map (
      I => data_in_from_pins_p(4),
      IB => data_in_from_pins_n(4),
      O => data_in_from_pins_int_4
    );
\pins[4].iserdese2_master\: unisim.vcomponents.ISERDESE2
    generic map(
      DATA_RATE => "DDR",
      DATA_WIDTH => 8,
      DYN_CLKDIV_INV_EN => "FALSE",
      DYN_CLK_INV_EN => "FALSE",
      INIT_Q1 => '0',
      INIT_Q2 => '0',
      INIT_Q3 => '0',
      INIT_Q4 => '0',
      INTERFACE_TYPE => "NETWORKING",
      IOBDELAY => "NONE",
      IS_CLKB_INVERTED => '1',
      IS_CLKDIVP_INVERTED => '0',
      IS_CLKDIV_INVERTED => '0',
      IS_CLK_INVERTED => '0',
      IS_D_INVERTED => '0',
      IS_OCLKB_INVERTED => '0',
      IS_OCLK_INVERTED => '0',
      NUM_CE => 2,
      OFB_USED => "FALSE",
      SERDES_MODE => "MASTER",
      SRVAL_Q1 => '0',
      SRVAL_Q2 => '0',
      SRVAL_Q3 => '0',
      SRVAL_Q4 => '0'
    )
        port map (
      BITSLIP => bitslip(4),
      CE1 => '1',
      CE2 => '1',
      CLK => clk_in_int_buf,
      CLKB => clk_in_int_buf,
      CLKDIV => \^clk_div_out\,
      CLKDIVP => '0',
      D => data_in_from_pins_int_4,
      DDLY => '0',
      DYNCLKDIVSEL => '0',
      DYNCLKSEL => '0',
      O => \NLW_pins[4].iserdese2_master_O_UNCONNECTED\,
      OCLK => '0',
      OCLKB => '0',
      OFB => '0',
      Q1 => data_in_to_device(102),
      Q2 => data_in_to_device(88),
      Q3 => data_in_to_device(74),
      Q4 => data_in_to_device(60),
      Q5 => data_in_to_device(46),
      Q6 => data_in_to_device(32),
      Q7 => data_in_to_device(18),
      Q8 => data_in_to_device(4),
      RST => io_reset,
      SHIFTIN1 => '0',
      SHIFTIN2 => '0',
      SHIFTOUT1 => \NLW_pins[4].iserdese2_master_SHIFTOUT1_UNCONNECTED\,
      SHIFTOUT2 => \NLW_pins[4].iserdese2_master_SHIFTOUT2_UNCONNECTED\
    );
\pins[5].ibufds_inst\: unisim.vcomponents.IBUFDS
     port map (
      I => data_in_from_pins_p(5),
      IB => data_in_from_pins_n(5),
      O => data_in_from_pins_int_5
    );
\pins[5].iserdese2_master\: unisim.vcomponents.ISERDESE2
    generic map(
      DATA_RATE => "DDR",
      DATA_WIDTH => 8,
      DYN_CLKDIV_INV_EN => "FALSE",
      DYN_CLK_INV_EN => "FALSE",
      INIT_Q1 => '0',
      INIT_Q2 => '0',
      INIT_Q3 => '0',
      INIT_Q4 => '0',
      INTERFACE_TYPE => "NETWORKING",
      IOBDELAY => "NONE",
      IS_CLKB_INVERTED => '1',
      IS_CLKDIVP_INVERTED => '0',
      IS_CLKDIV_INVERTED => '0',
      IS_CLK_INVERTED => '0',
      IS_D_INVERTED => '0',
      IS_OCLKB_INVERTED => '0',
      IS_OCLK_INVERTED => '0',
      NUM_CE => 2,
      OFB_USED => "FALSE",
      SERDES_MODE => "MASTER",
      SRVAL_Q1 => '0',
      SRVAL_Q2 => '0',
      SRVAL_Q3 => '0',
      SRVAL_Q4 => '0'
    )
        port map (
      BITSLIP => bitslip(5),
      CE1 => '1',
      CE2 => '1',
      CLK => clk_in_int_buf,
      CLKB => clk_in_int_buf,
      CLKDIV => \^clk_div_out\,
      CLKDIVP => '0',
      D => data_in_from_pins_int_5,
      DDLY => '0',
      DYNCLKDIVSEL => '0',
      DYNCLKSEL => '0',
      O => \NLW_pins[5].iserdese2_master_O_UNCONNECTED\,
      OCLK => '0',
      OCLKB => '0',
      OFB => '0',
      Q1 => data_in_to_device(103),
      Q2 => data_in_to_device(89),
      Q3 => data_in_to_device(75),
      Q4 => data_in_to_device(61),
      Q5 => data_in_to_device(47),
      Q6 => data_in_to_device(33),
      Q7 => data_in_to_device(19),
      Q8 => data_in_to_device(5),
      RST => io_reset,
      SHIFTIN1 => '0',
      SHIFTIN2 => '0',
      SHIFTOUT1 => \NLW_pins[5].iserdese2_master_SHIFTOUT1_UNCONNECTED\,
      SHIFTOUT2 => \NLW_pins[5].iserdese2_master_SHIFTOUT2_UNCONNECTED\
    );
\pins[6].ibufds_inst\: unisim.vcomponents.IBUFDS
     port map (
      I => data_in_from_pins_p(6),
      IB => data_in_from_pins_n(6),
      O => data_in_from_pins_int_6
    );
\pins[6].iserdese2_master\: unisim.vcomponents.ISERDESE2
    generic map(
      DATA_RATE => "DDR",
      DATA_WIDTH => 8,
      DYN_CLKDIV_INV_EN => "FALSE",
      DYN_CLK_INV_EN => "FALSE",
      INIT_Q1 => '0',
      INIT_Q2 => '0',
      INIT_Q3 => '0',
      INIT_Q4 => '0',
      INTERFACE_TYPE => "NETWORKING",
      IOBDELAY => "NONE",
      IS_CLKB_INVERTED => '1',
      IS_CLKDIVP_INVERTED => '0',
      IS_CLKDIV_INVERTED => '0',
      IS_CLK_INVERTED => '0',
      IS_D_INVERTED => '0',
      IS_OCLKB_INVERTED => '0',
      IS_OCLK_INVERTED => '0',
      NUM_CE => 2,
      OFB_USED => "FALSE",
      SERDES_MODE => "MASTER",
      SRVAL_Q1 => '0',
      SRVAL_Q2 => '0',
      SRVAL_Q3 => '0',
      SRVAL_Q4 => '0'
    )
        port map (
      BITSLIP => bitslip(6),
      CE1 => '1',
      CE2 => '1',
      CLK => clk_in_int_buf,
      CLKB => clk_in_int_buf,
      CLKDIV => \^clk_div_out\,
      CLKDIVP => '0',
      D => data_in_from_pins_int_6,
      DDLY => '0',
      DYNCLKDIVSEL => '0',
      DYNCLKSEL => '0',
      O => \NLW_pins[6].iserdese2_master_O_UNCONNECTED\,
      OCLK => '0',
      OCLKB => '0',
      OFB => '0',
      Q1 => data_in_to_device(104),
      Q2 => data_in_to_device(90),
      Q3 => data_in_to_device(76),
      Q4 => data_in_to_device(62),
      Q5 => data_in_to_device(48),
      Q6 => data_in_to_device(34),
      Q7 => data_in_to_device(20),
      Q8 => data_in_to_device(6),
      RST => io_reset,
      SHIFTIN1 => '0',
      SHIFTIN2 => '0',
      SHIFTOUT1 => \NLW_pins[6].iserdese2_master_SHIFTOUT1_UNCONNECTED\,
      SHIFTOUT2 => \NLW_pins[6].iserdese2_master_SHIFTOUT2_UNCONNECTED\
    );
\pins[7].ibufds_inst\: unisim.vcomponents.IBUFDS
     port map (
      I => data_in_from_pins_p(7),
      IB => data_in_from_pins_n(7),
      O => data_in_from_pins_int_7
    );
\pins[7].iserdese2_master\: unisim.vcomponents.ISERDESE2
    generic map(
      DATA_RATE => "DDR",
      DATA_WIDTH => 8,
      DYN_CLKDIV_INV_EN => "FALSE",
      DYN_CLK_INV_EN => "FALSE",
      INIT_Q1 => '0',
      INIT_Q2 => '0',
      INIT_Q3 => '0',
      INIT_Q4 => '0',
      INTERFACE_TYPE => "NETWORKING",
      IOBDELAY => "NONE",
      IS_CLKB_INVERTED => '1',
      IS_CLKDIVP_INVERTED => '0',
      IS_CLKDIV_INVERTED => '0',
      IS_CLK_INVERTED => '0',
      IS_D_INVERTED => '0',
      IS_OCLKB_INVERTED => '0',
      IS_OCLK_INVERTED => '0',
      NUM_CE => 2,
      OFB_USED => "FALSE",
      SERDES_MODE => "MASTER",
      SRVAL_Q1 => '0',
      SRVAL_Q2 => '0',
      SRVAL_Q3 => '0',
      SRVAL_Q4 => '0'
    )
        port map (
      BITSLIP => bitslip(7),
      CE1 => '1',
      CE2 => '1',
      CLK => clk_in_int_buf,
      CLKB => clk_in_int_buf,
      CLKDIV => \^clk_div_out\,
      CLKDIVP => '0',
      D => data_in_from_pins_int_7,
      DDLY => '0',
      DYNCLKDIVSEL => '0',
      DYNCLKSEL => '0',
      O => \NLW_pins[7].iserdese2_master_O_UNCONNECTED\,
      OCLK => '0',
      OCLKB => '0',
      OFB => '0',
      Q1 => data_in_to_device(105),
      Q2 => data_in_to_device(91),
      Q3 => data_in_to_device(77),
      Q4 => data_in_to_device(63),
      Q5 => data_in_to_device(49),
      Q6 => data_in_to_device(35),
      Q7 => data_in_to_device(21),
      Q8 => data_in_to_device(7),
      RST => io_reset,
      SHIFTIN1 => '0',
      SHIFTIN2 => '0',
      SHIFTOUT1 => \NLW_pins[7].iserdese2_master_SHIFTOUT1_UNCONNECTED\,
      SHIFTOUT2 => \NLW_pins[7].iserdese2_master_SHIFTOUT2_UNCONNECTED\
    );
\pins[8].ibufds_inst\: unisim.vcomponents.IBUFDS
     port map (
      I => data_in_from_pins_p(8),
      IB => data_in_from_pins_n(8),
      O => data_in_from_pins_int_8
    );
\pins[8].iserdese2_master\: unisim.vcomponents.ISERDESE2
    generic map(
      DATA_RATE => "DDR",
      DATA_WIDTH => 8,
      DYN_CLKDIV_INV_EN => "FALSE",
      DYN_CLK_INV_EN => "FALSE",
      INIT_Q1 => '0',
      INIT_Q2 => '0',
      INIT_Q3 => '0',
      INIT_Q4 => '0',
      INTERFACE_TYPE => "NETWORKING",
      IOBDELAY => "NONE",
      IS_CLKB_INVERTED => '1',
      IS_CLKDIVP_INVERTED => '0',
      IS_CLKDIV_INVERTED => '0',
      IS_CLK_INVERTED => '0',
      IS_D_INVERTED => '0',
      IS_OCLKB_INVERTED => '0',
      IS_OCLK_INVERTED => '0',
      NUM_CE => 2,
      OFB_USED => "FALSE",
      SERDES_MODE => "MASTER",
      SRVAL_Q1 => '0',
      SRVAL_Q2 => '0',
      SRVAL_Q3 => '0',
      SRVAL_Q4 => '0'
    )
        port map (
      BITSLIP => bitslip(8),
      CE1 => '1',
      CE2 => '1',
      CLK => clk_in_int_buf,
      CLKB => clk_in_int_buf,
      CLKDIV => \^clk_div_out\,
      CLKDIVP => '0',
      D => data_in_from_pins_int_8,
      DDLY => '0',
      DYNCLKDIVSEL => '0',
      DYNCLKSEL => '0',
      O => \NLW_pins[8].iserdese2_master_O_UNCONNECTED\,
      OCLK => '0',
      OCLKB => '0',
      OFB => '0',
      Q1 => data_in_to_device(106),
      Q2 => data_in_to_device(92),
      Q3 => data_in_to_device(78),
      Q4 => data_in_to_device(64),
      Q5 => data_in_to_device(50),
      Q6 => data_in_to_device(36),
      Q7 => data_in_to_device(22),
      Q8 => data_in_to_device(8),
      RST => io_reset,
      SHIFTIN1 => '0',
      SHIFTIN2 => '0',
      SHIFTOUT1 => \NLW_pins[8].iserdese2_master_SHIFTOUT1_UNCONNECTED\,
      SHIFTOUT2 => \NLW_pins[8].iserdese2_master_SHIFTOUT2_UNCONNECTED\
    );
\pins[9].ibufds_inst\: unisim.vcomponents.IBUFDS
     port map (
      I => data_in_from_pins_p(9),
      IB => data_in_from_pins_n(9),
      O => data_in_from_pins_int_9
    );
\pins[9].iserdese2_master\: unisim.vcomponents.ISERDESE2
    generic map(
      DATA_RATE => "DDR",
      DATA_WIDTH => 8,
      DYN_CLKDIV_INV_EN => "FALSE",
      DYN_CLK_INV_EN => "FALSE",
      INIT_Q1 => '0',
      INIT_Q2 => '0',
      INIT_Q3 => '0',
      INIT_Q4 => '0',
      INTERFACE_TYPE => "NETWORKING",
      IOBDELAY => "NONE",
      IS_CLKB_INVERTED => '1',
      IS_CLKDIVP_INVERTED => '0',
      IS_CLKDIV_INVERTED => '0',
      IS_CLK_INVERTED => '0',
      IS_D_INVERTED => '0',
      IS_OCLKB_INVERTED => '0',
      IS_OCLK_INVERTED => '0',
      NUM_CE => 2,
      OFB_USED => "FALSE",
      SERDES_MODE => "MASTER",
      SRVAL_Q1 => '0',
      SRVAL_Q2 => '0',
      SRVAL_Q3 => '0',
      SRVAL_Q4 => '0'
    )
        port map (
      BITSLIP => bitslip(9),
      CE1 => '1',
      CE2 => '1',
      CLK => clk_in_int_buf,
      CLKB => clk_in_int_buf,
      CLKDIV => \^clk_div_out\,
      CLKDIVP => '0',
      D => data_in_from_pins_int_9,
      DDLY => '0',
      DYNCLKDIVSEL => '0',
      DYNCLKSEL => '0',
      O => \NLW_pins[9].iserdese2_master_O_UNCONNECTED\,
      OCLK => '0',
      OCLKB => '0',
      OFB => '0',
      Q1 => data_in_to_device(107),
      Q2 => data_in_to_device(93),
      Q3 => data_in_to_device(79),
      Q4 => data_in_to_device(65),
      Q5 => data_in_to_device(51),
      Q6 => data_in_to_device(37),
      Q7 => data_in_to_device(23),
      Q8 => data_in_to_device(9),
      RST => io_reset,
      SHIFTIN1 => '0',
      SHIFTIN2 => '0',
      SHIFTOUT1 => \NLW_pins[9].iserdese2_master_SHIFTOUT1_UNCONNECTED\,
      SHIFTOUT2 => \NLW_pins[9].iserdese2_master_SHIFTOUT2_UNCONNECTED\
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity selectio_wiz_adc is
  port (
    data_in_from_pins_p : in STD_LOGIC_VECTOR ( 13 downto 0 );
    data_in_from_pins_n : in STD_LOGIC_VECTOR ( 13 downto 0 );
    data_in_to_device : out STD_LOGIC_VECTOR ( 111 downto 0 );
    bitslip : in STD_LOGIC_VECTOR ( 13 downto 0 );
    clk_in_p : in STD_LOGIC;
    clk_in_n : in STD_LOGIC;
    clk_div_out : out STD_LOGIC;
    clk_reset : in STD_LOGIC;
    io_reset : in STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of selectio_wiz_adc : entity is true;
  attribute DEV_W : integer;
  attribute DEV_W of selectio_wiz_adc : entity is 112;
  attribute SYS_W : integer;
  attribute SYS_W of selectio_wiz_adc : entity is 14;
end selectio_wiz_adc;

architecture STRUCTURE of selectio_wiz_adc is
  attribute DEV_W of inst : label is 112;
  attribute SYS_W of inst : label is 14;
  attribute num_serial_bits : integer;
  attribute num_serial_bits of inst : label is 8;
begin
inst: entity work.selectio_wiz_adc_selectio_wiz_adc_selectio_wiz
     port map (
      bitslip(13 downto 0) => bitslip(13 downto 0),
      clk_div_out => clk_div_out,
      clk_in_n => clk_in_n,
      clk_in_p => clk_in_p,
      clk_reset => clk_reset,
      data_in_from_pins_n(13 downto 0) => data_in_from_pins_n(13 downto 0),
      data_in_from_pins_p(13 downto 0) => data_in_from_pins_p(13 downto 0),
      data_in_to_device(111 downto 0) => data_in_to_device(111 downto 0),
      io_reset => io_reset
    );
end STRUCTURE;
