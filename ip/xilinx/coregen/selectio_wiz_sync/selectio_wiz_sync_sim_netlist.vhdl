-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
-- Date        : Tue Jul 25 10:44:03 2023
-- Host        : PC-PAUL running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim
--               d:/fpasim-fw-hardware/ip/xilinx/coregen/selectio_wiz_sync/selectio_wiz_sync_sim_netlist.vhdl
-- Design      : selectio_wiz_sync
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7k410tffg676-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity selectio_wiz_sync_selectio_wiz is
  port (
    data_out_from_device : in STD_LOGIC_VECTOR ( 0 to 0 );
    data_out_to_pins_p : out STD_LOGIC_VECTOR ( 0 to 0 );
    data_out_to_pins_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    clk_to_pins_p : out STD_LOGIC;
    clk_to_pins_n : out STD_LOGIC;
    clk_in : in STD_LOGIC;
    clk_reset : in STD_LOGIC;
    io_reset : in STD_LOGIC
  );
  attribute DEV_W : integer;
  attribute DEV_W of selectio_wiz_sync_selectio_wiz : entity is 1;
  attribute SYS_W : integer;
  attribute SYS_W of selectio_wiz_sync_selectio_wiz : entity is 1;
end selectio_wiz_sync_selectio_wiz;

architecture STRUCTURE of selectio_wiz_sync_selectio_wiz is
  signal clk_fwd_out : STD_LOGIC;
  signal data_out_to_pins_int : STD_LOGIC;
  signal NLW_oddr_inst_S_UNCONNECTED : STD_LOGIC;
  attribute BOX_TYPE : string;
  attribute BOX_TYPE of obufds_inst : label is "PRIMITIVE";
  attribute CAPACITANCE : string;
  attribute CAPACITANCE of obufds_inst : label is "DONT_CARE";
  attribute BOX_TYPE of oddr_inst : label is "PRIMITIVE";
  attribute OPT_MODIFIED : string;
  attribute OPT_MODIFIED of oddr_inst : label is "MLO";
  attribute \__SRVAL\ : string;
  attribute \__SRVAL\ of oddr_inst : label is "FALSE";
  attribute BOX_TYPE of \pins[0].fdre_out_inst\ : label is "PRIMITIVE";
  attribute IOB : string;
  attribute IOB of \pins[0].fdre_out_inst\ : label is "TRUE";
  attribute BOX_TYPE of \pins[0].obufds_inst\ : label is "PRIMITIVE";
  attribute CAPACITANCE of \pins[0].obufds_inst\ : label is "DONT_CARE";
begin
obufds_inst: unisim.vcomponents.OBUFDS
     port map (
      I => clk_fwd_out,
      O => clk_to_pins_p,
      OB => clk_to_pins_n
    );
oddr_inst: unisim.vcomponents.ODDR
    generic map(
      DDR_CLK_EDGE => "SAME_EDGE",
      INIT => '0',
      IS_C_INVERTED => '0',
      IS_D1_INVERTED => '0',
      IS_D2_INVERTED => '0',
      SRTYPE => "ASYNC"
    )
        port map (
      C => clk_in,
      CE => '1',
      D1 => '1',
      D2 => '0',
      Q => clk_fwd_out,
      R => clk_reset,
      S => NLW_oddr_inst_S_UNCONNECTED
    );
\pins[0].fdre_out_inst\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0',
      IS_C_INVERTED => '0',
      IS_D_INVERTED => '0',
      IS_R_INVERTED => '0'
    )
        port map (
      C => clk_in,
      CE => '1',
      D => data_out_from_device(0),
      Q => data_out_to_pins_int,
      R => io_reset
    );
\pins[0].obufds_inst\: unisim.vcomponents.OBUFDS
     port map (
      I => data_out_to_pins_int,
      O => data_out_to_pins_p(0),
      OB => data_out_to_pins_n(0)
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity selectio_wiz_sync is
  port (
    data_out_from_device : in STD_LOGIC_VECTOR ( 0 to 0 );
    data_out_to_pins_p : out STD_LOGIC_VECTOR ( 0 to 0 );
    data_out_to_pins_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    clk_to_pins_p : out STD_LOGIC;
    clk_to_pins_n : out STD_LOGIC;
    clk_in : in STD_LOGIC;
    clk_reset : in STD_LOGIC;
    io_reset : in STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of selectio_wiz_sync : entity is true;
  attribute DEV_W : integer;
  attribute DEV_W of selectio_wiz_sync : entity is 1;
  attribute SYS_W : integer;
  attribute SYS_W of selectio_wiz_sync : entity is 1;
end selectio_wiz_sync;

architecture STRUCTURE of selectio_wiz_sync is
  attribute DEV_W of inst : label is 1;
  attribute SYS_W of inst : label is 1;
begin
inst: entity work.selectio_wiz_sync_selectio_wiz
     port map (
      clk_in => clk_in,
      clk_reset => clk_reset,
      clk_to_pins_n => clk_to_pins_n,
      clk_to_pins_p => clk_to_pins_p,
      data_out_from_device(0) => data_out_from_device(0),
      data_out_to_pins_n(0) => data_out_to_pins_n(0),
      data_out_to_pins_p(0) => data_out_to_pins_p(0),
      io_reset => io_reset
    );
end STRUCTURE;
