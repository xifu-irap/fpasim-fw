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
--    @file                   usb_opal_kelly.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details                
--
--    This module instanciates the necessary different opal kelly component
--
--    requirement: FPASIM-FW-REQ-0250
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


use work.FRONTPANEL.all;

entity usb_opal_kelly is
  port(
    --  Opal Kelly inouts --
    i_okUH                            : in    std_logic_vector(4 downto 0);
    o_okHU                            : out   std_logic_vector(2 downto 0);
    b_okUHU                           : inout std_logic_vector(31 downto 0);
    b_okAA                            : inout std_logic;
    ---------------------------------------------------------------------
    -- from the user @o_usb_clk
    ---------------------------------------------------------------------
    -- pipe
    o_usb_pipeout_fifo_rd             : out   std_logic;  -- read fifo
    i_usb_pipeout_fifo_data           : in    std_logic_vector(31 downto 0);  -- input data fifo
    i_usb_wireout_fifo_data_count     : in    std_logic_vector(31 downto 0);  -- pipeout_fifo wr data count register(reading)
    -- trig
    i_usb_trigout_data                : in    std_logic_vector(31 downto 0);  -- trigout register
    -- wire
    i_usb_wireout_ctrl                : in    std_logic_vector(31 downto 0);  -- ctrl register (reading)
    i_usb_wireout_make_pulse          : in    std_logic_vector(31 downto 0);  -- make_pulse register (reading)
    i_usb_wireout_fpasim_gain         : in    std_logic_vector(31 downto 0);  -- fpasim_gain register (reading)
    i_usb_wireout_mux_sq_fb_delay     : in    std_logic_vector(31 downto 0);  -- mux_sq_fb_delay register (reading)
    i_usb_wireout_amp_sq_of_delay     : in    std_logic_vector(31 downto 0);  -- amp_sq_of_delay register (reading)
    i_usb_wireout_error_delay         : in    std_logic_vector(31 downto 0);  -- error_delay register (reading)
    i_usb_wireout_ra_delay            : in    std_logic_vector(31 downto 0);  -- ra_delay register (reading)
    i_usb_wireout_tes_conf            : in    std_logic_vector(31 downto 0);  -- tes_conf register (reading)
    i_usb_wireout_conf0               : in    std_logic_vector(31 downto 0);  -- conf0 register (reading)
    i_usb_wireout_fpasim_status       : in    std_logic_vector(31 downto 0);  -- fpasim register (reading)
    i_usb_wireout_debug_ctrl          : in    std_logic_vector(31 downto 0);  -- debug_ctrl register (reading)
    i_usb_wireout_firmware_id         : in    std_logic_vector(31 downto 0);  -- firmware id register (reading)
    i_usb_wireout_firmware_version    : in    std_logic_vector(31 downto 0);  -- firmware version register (reading)
    i_usb_wireout_board_id            : in    std_logic_vector(31 downto 0);  -- board id register (reading)
    -- recording: register
    i_usb_wireout_rec_ctrl            : in    std_logic_vector(31 downto 0);  -- rec_ctrl register (reading)
    i_usb_wireout_rec_conf0           : in    std_logic_vector(31 downto 0);  -- rec_conf0 register (reading)
    -- recording: pipe
    o_usb_pipeout_rec_fifo_adc_rd     : out   std_logic;  -- read fifo
    i_usb_pipeout_rec_fifo_adc_data   : in    std_logic_vector(31 downto 0);  -- input data fifo
    i_usb_wireout_rec_fifo_data_count : in    std_logic_vector(31 downto 0);  -- rec_data_count register (reading)
    -- spi: register
    i_usb_wireout_spi_ctrl            : in    std_logic_vector(31 downto 0);  -- spi_ctrl register (reading)
    i_usb_wireout_spi_conf0           : in    std_logic_vector(31 downto 0);  -- spi_conf0 register (reading)
    i_usb_wireout_spi_conf1           : in    std_logic_vector(31 downto 0);  -- spi_conf1 register (reading)
    i_usb_wireout_spi_wr_data         : in    std_logic_vector(31 downto 0);  -- spi_wr_data register (reading)
    i_usb_wireout_spi_rd_data         : in    std_logic_vector(31 downto 0);  -- spi_rd_data register (reading)
    i_usb_wireout_spi_status          : in    std_logic_vector(31 downto 0);  -- spi_status register (reading)
    -- errors/status
    i_usb_wireout_sel_errors          : in    std_logic_vector(31 downto 0);  -- sel_errors register (reading)
    i_usb_wireout_errors              : in    std_logic_vector(31 downto 0);  -- errors register (reading)
    i_usb_wireout_status              : in    std_logic_vector(31 downto 0);  -- status register (reading)
    ---------------------------------------------------------------------
    -- to the user @o_usb_clk
    ---------------------------------------------------------------------
    o_usb_clk                         : out   std_logic;  -- usb clock
    -- pipe
    o_usb_pipein_fifo_valid           : out   std_logic;  -- pipein data valid
    o_usb_pipein_fifo                 : out   std_logic_vector(31 downto 0);  -- pipein data
    -- trig
    o_usb_trigin_data                 : out   std_logic_vector(31 downto 0);  -- trigin data
    -- wire
    o_usb_wirein_ctrl                 : out   std_logic_vector(31 downto 0);  -- ctrl register (writting)
    o_usb_wirein_make_pulse           : out   std_logic_vector(31 downto 0);  -- make pulse register (writting)
    o_usb_wirein_fpasim_gain          : out   std_logic_vector(31 downto 0);  -- fpasim_gain register (writting)
    o_usb_wirein_mux_sq_fb_delay      : out   std_logic_vector(31 downto 0);  -- mux_sq_fb_delay register (writting)
    o_usb_wirein_amp_sq_of_delay      : out   std_logic_vector(31 downto 0);  -- amp_sq_of_delay register (writting)
    o_usb_wirein_error_delay          : out   std_logic_vector(31 downto 0);  -- error_delay register (writting)
    o_usb_wirein_ra_delay             : out   std_logic_vector(31 downto 0);  -- ra_delay register (writting)
    o_usb_wirein_tes_conf             : out   std_logic_vector(31 downto 0);  -- tes_conf register (writting)
    o_usb_wirein_conf0                : out   std_logic_vector(31 downto 0);  -- conf0 register (writting)
    -- recording : register
    o_usb_wirein_rec_ctrl             : out   std_logic_vector(31 downto 0);  -- rec_ctrl register (writting)
    o_usb_wirein_rec_conf0            : out   std_logic_vector(31 downto 0);  -- rec_conf0 register (writting)
    -- spi: register
    o_usb_wirein_spi_ctrl             : out   std_logic_vector(31 downto 0);  -- spi_ctrl register (writting)
    o_usb_wirein_spi_conf0            : out   std_logic_vector(31 downto 0);  -- spi_conf0 register (writting)
    o_usb_wirein_spi_conf1            : out   std_logic_vector(31 downto 0);  -- spi_conf2 register (writting)
    o_usb_wirein_spi_wr_data          : out   std_logic_vector(31 downto 0);  -- spi_wr_data register (writting)

    -- debug
    o_usb_wirein_debug_ctrl : out std_logic_vector(31 downto 0);  -- debug_ctrl register (writting)
    o_usb_wirein_sel_errors : out std_logic_vector(31 downto 0)  -- sel_errors register (writting)
    );
end entity usb_opal_kelly;

architecture RTL of usb_opal_kelly is

  -- total number of wire out, pipe out, pipe in and trigger out
  constant c_WIRE_PIPE_TRIG_NUMBER_OUT : integer := 31;

  ---- Opal Kelly signals ----
  signal okClk : std_logic;             -- Opal Kelly Clock
  signal okHE  : std_logic_vector(112 downto 0);
  signal okEH  : std_logic_vector(64 downto 0);
  signal okEHx : std_logic_vector(c_WIRE_PIPE_TRIG_NUMBER_OUT * 65 - 1 downto 0);

  -- trig in
  signal ep40_trig : std_logic_vector(31 downto 0);

  -- trig out
  signal ep60_trig : std_logic_vector(31 downto 0);

  -- wires in
  signal ep00_wire : std_logic_vector(31 downto 0);
  signal ep01_wire : std_logic_vector(31 downto 0);
  signal ep02_wire : std_logic_vector(31 downto 0);
  signal ep03_wire : std_logic_vector(31 downto 0);
  signal ep04_wire : std_logic_vector(31 downto 0);
  signal ep05_wire : std_logic_vector(31 downto 0);
  signal ep06_wire : std_logic_vector(31 downto 0);
  signal ep07_wire : std_logic_vector(31 downto 0);
  signal ep08_wire : std_logic_vector(31 downto 0);
  --signal ep09_wire : std_logic_vector(31 downto 0);
  --signal ep0A_wire : std_logic_vector(31 downto 0);
  --signal ep0B_wire : std_logic_vector(31 downto 0);
  signal ep0C_wire : std_logic_vector(31 downto 0);
  signal ep0D_wire : std_logic_vector(31 downto 0);
  --signal ep0E_wire : std_logic_vector(31 downto 0);
  --signal ep0F_wire : std_logic_vector(31 downto 0);
  --signal ep10_wire : std_logic_vector(31 downto 0);
  --signal ep11_wire : std_logic_vector(31 downto 0);
  signal ep12_wire : std_logic_vector(31 downto 0);
  signal ep13_wire : std_logic_vector(31 downto 0);
  signal ep14_wire : std_logic_vector(31 downto 0);
  signal ep15_wire : std_logic_vector(31 downto 0);
  --signal ep16_wire : std_logic_vector(31 downto 0);
  --signal ep17_wire : std_logic_vector(31 downto 0);
  signal ep18_wire : std_logic_vector(31 downto 0);
  signal ep19_wire : std_logic_vector(31 downto 0);
  --signal ep1A_wire : std_logic_vector(31 downto 0);
  --signal ep1B_wire : std_logic_vector(31 downto 0);
  --signal ep1C_wire : std_logic_vector(31 downto 0);
  --signal ep1D_wire : std_logic_vector(31 downto 0);
  --signal ep1E_wire : std_logic_vector(31 downto 0);
  --signal ep1F_wire : std_logic_vector(31 downto 0);

  -- wires out
  signal ep20_wire : std_logic_vector(31 downto 0);
  signal ep21_wire : std_logic_vector(31 downto 0);
  signal ep22_wire : std_logic_vector(31 downto 0);
  signal ep23_wire : std_logic_vector(31 downto 0);
  signal ep24_wire : std_logic_vector(31 downto 0);
  signal ep25_wire : std_logic_vector(31 downto 0);
  signal ep26_wire : std_logic_vector(31 downto 0);
  signal ep27_wire : std_logic_vector(31 downto 0);
  signal ep28_wire : std_logic_vector(31 downto 0);
  --signal ep29_wire : std_logic_vector(31 downto 0);
  signal ep2A_wire : std_logic_vector(31 downto 0);
  signal ep2B_wire : std_logic_vector(31 downto 0);
  signal ep2C_wire : std_logic_vector(31 downto 0);
  signal ep2D_wire : std_logic_vector(31 downto 0);
  --signal ep2E_wire : std_logic_vector(31 downto 0);
  --signal ep2F_wire : std_logic_vector(31 downto 0);
  --signal ep30_wire : std_logic_vector(31 downto 0);
  signal ep31_wire : std_logic_vector(31 downto 0);
  signal ep32_wire : std_logic_vector(31 downto 0);
  signal ep33_wire : std_logic_vector(31 downto 0);
  signal ep34_wire : std_logic_vector(31 downto 0);
  signal ep35_wire : std_logic_vector(31 downto 0);
  signal ep36_wire : std_logic_vector(31 downto 0);
  signal ep37_wire : std_logic_vector(31 downto 0);
  signal ep38_wire : std_logic_vector(31 downto 0);
  signal ep39_wire : std_logic_vector(31 downto 0);
  signal ep3A_wire : std_logic_vector(31 downto 0);
  signal ep3B_wire : std_logic_vector(31 downto 0);
  --signal ep3C_wire : std_logic_vector(31 downto 0);
  signal ep3D_wire : std_logic_vector(31 downto 0);
  signal ep3E_wire : std_logic_vector(31 downto 0);
  signal ep3F_wire : std_logic_vector(31 downto 0);

  -- pipe in
  signal ep80_pipe_valid : std_logic;
  signal ep80_pipe       : std_logic_vector(31 downto 0);

  -- pipe out
  signal epA0_pipe_rd : std_logic;
  signal epA0_pipe    : std_logic_vector(31 downto 0);

  signal epA1_pipe_rd : std_logic;
  signal epA1_pipe    : std_logic_vector(31 downto 0);

begin

  ----------------------------------------------------
  --    Opal Kelly Host
  ----------------------------------------------------
  Opal_Kelly_Host : okHost
    port map(  
      okUH  => i_okUH,
      okHU  => o_okHU,
      okUHU => b_okUHU,
      okAA  => b_okAA,
      okClk => okClk,  -- Clock Opal Kelly generated in the okLibrary
      okHE  => okHE,
      okEH  => okEH
      );
  ----------------------------------------------------
  --    Opal Kelly Wire OR
  ----------------------------------------------------
  ins_wireor_opak_kelly : okWireOR
    generic map(N => c_WIRE_PIPE_TRIG_NUMBER_OUT)  -- N = Number of wires + pipes used
    port map(
      okEH  => okEH,
      okEHx => okEHx
      );

  ---------------------------------------------------------------------
  -- inputs
  ---------------------------------------------------------------------
  -- to trig out
  ep60_trig <= i_usb_trigout_data;
  -- to wire_out: main
  ep20_wire <= i_usb_wireout_ctrl;
  ep21_wire <= i_usb_wireout_make_pulse;
  ep22_wire <= i_usb_wireout_fpasim_gain;
  ep23_wire <= i_usb_wireout_mux_sq_fb_delay;
  ep24_wire <= i_usb_wireout_amp_sq_of_delay;
  ep25_wire <= i_usb_wireout_error_delay;
  ep26_wire <= i_usb_wireout_ra_delay;
  ep27_wire <= i_usb_wireout_tes_conf;
  ep28_wire <= i_usb_wireout_conf0;
  ep2A_wire <= i_usb_wireout_fpasim_status;
  ep2B_wire <= i_usb_wireout_fifo_data_count;

  -- to wire_out: recording
  ep2C_wire <= i_usb_wireout_rec_ctrl;
  ep2D_wire <= i_usb_wireout_rec_conf0;
  ep31_wire <= i_usb_wireout_rec_fifo_data_count;

  -- to wire_out: spi
  ep32_wire <= i_usb_wireout_spi_ctrl;
  ep33_wire <= i_usb_wireout_spi_conf0;
  ep34_wire <= i_usb_wireout_spi_conf1;
  ep35_wire <= i_usb_wireout_spi_wr_data;
  ep36_wire <= i_usb_wireout_spi_rd_data;
  ep37_wire <= i_usb_wireout_spi_status;


  -- to wire_out: debug
  ep38_wire <= i_usb_wireout_debug_ctrl;
  ep39_wire <= i_usb_wireout_sel_errors;
  ep3A_wire <= i_usb_wireout_errors;
  ep3B_wire <= i_usb_wireout_status;

  -- to wire_out: others
  ep3D_wire <= i_usb_wireout_board_id;
  ep3E_wire <= i_usb_wireout_firmware_id;
  ep3F_wire <= i_usb_wireout_firmware_version;

  -- from/to pipe out
  o_usb_pipeout_fifo_rd <= epA0_pipe_rd;
  epA0_pipe             <= i_usb_pipeout_fifo_data;

  -- from/to pipeout
  o_usb_pipeout_rec_fifo_adc_rd <= epA1_pipe_rd;
  epA1_pipe                     <= i_usb_pipeout_rec_fifo_adc_data;

  ----------------------------------------------------
  --    Opal Kelly Wire in
  ----------------------------------------------------
  inst_okwirein_ep00 : okWireIn
    port map(
      okHE       => okHE,
      ep_addr    => x"00",              -- Endpoint adress
      ep_dataout => ep00_wire           -- Endpoint data in 32 bits
      );

  inst_okwirein_ep01 : okWireIn
    port map(
      okHE       => okHE,
      ep_addr    => x"01",              -- Endpoint adress
      ep_dataout => ep01_wire           -- Endpoint data in 32 bits
      );

  inst_okwirein_ep02 : okWireIn
    port map(
      okHE       => okHE,
      ep_addr    => x"02",              -- Endpoint adress
      ep_dataout => ep02_wire           -- Endpoint data in 32 bits
      );

  inst_okwirein_ep03 : okWireIn
    port map(
      okHE       => okHE,
      ep_addr    => x"03",              -- Endpoint adress
      ep_dataout => ep03_wire           -- Endpoint data in 32 bits
      );

  inst_okwirein_ep04 : okWireIn
    port map(
      okHE       => okHE,
      ep_addr    => x"04",              -- Endpoint adress
      ep_dataout => ep04_wire           -- Endpoint data in 32 bits
      );

  inst_okwirein_ep05 : okWireIn
    port map(
      okHE       => okHE,
      ep_addr    => x"05",              -- Endpoint adress
      ep_dataout => ep05_wire           -- Endpoint data in 32 bits
      );

  inst_okwirein_ep06 : okWireIn
    port map(
      okHE       => okHE,
      ep_addr    => x"06",              -- Endpoint adress
      ep_dataout => ep06_wire           -- Endpoint data in 32 bits
      );

  inst_okwirein_ep07 : okWireIn
    port map(
      okHE       => okHE,
      ep_addr    => x"07",              -- Endpoint adress
      ep_dataout => ep07_wire           -- Endpoint data in 32 bits
      );

  inst_okwirein_ep08 : okWireIn
    port map(
      okHE       => okHE,
      ep_addr    => x"08",              -- Endpoint adress
      ep_dataout => ep08_wire           -- Endpoint data in 32 bits
      );

  inst_okwirein_ep18 : okWireIn
    port map(
      okHE       => okHE,
      ep_addr    => x"18",              -- Endpoint adress
      ep_dataout => ep18_wire           -- Endpoint data in 32 bits
      );

  inst_okwirein_ep19 : okWireIn
    port map(
      okHE       => okHE,
      ep_addr    => x"19",              -- Endpoint adress
      ep_dataout => ep19_wire           -- Endpoint data in 32 bits
      );


  inst_okwirein_ep0C : okWireIn
    port map(
      okHE       => okHE,
      ep_addr    => x"0C",              -- Endpoint adress
      ep_dataout => ep0C_wire           -- Endpoint data in 32 bits
      );

  inst_okwirein_ep0D : okWireIn
    port map(
      okHE       => okHE,
      ep_addr    => x"0D",              -- Endpoint adress
      ep_dataout => ep0D_wire           -- Endpoint data in 32 bits
      );

  inst_okwirein_ep12 : okWireIn
    port map(
      okHE       => okHE,
      ep_addr    => x"12",              -- Endpoint adress
      ep_dataout => ep12_wire           -- Endpoint data in 32 bits
      );

  inst_okwirein_ep13 : okWireIn
    port map(
      okHE       => okHE,
      ep_addr    => x"13",              -- Endpoint adress
      ep_dataout => ep13_wire           -- Endpoint data in 32 bits
      );

  inst_okwirein_ep14 : okWireIn
    port map(
      okHE       => okHE,
      ep_addr    => x"14",              -- Endpoint adress
      ep_dataout => ep14_wire           -- Endpoint data in 32 bits
      );

  inst_okwirein_ep15 : okWireIn
    port map(
      okHE       => okHE,
      ep_addr    => x"15",              -- Endpoint adress
      ep_dataout => ep15_wire           -- Endpoint data in 32 bits
      );





  ---------------------------------------------------------------------
  -- Opal Kelly Trig In
  ---------------------------------------------------------------------
  ep40 : okTriggerIn
    port map(
      okHE       => okHE,
      ep_addr    => x"40",
      ep_clk     => okClk,
      ep_trigger => ep40_trig
      );

  ----------------------------------------------------
  --    Opal Kelly Wire out
  ----------------------------------------------------
  inst_okwireout_ep20 : okWireOut
    port map(
      okHE      => okHE,
      okEH      => okEHx(1 * 65 - 1 downto 0 * 65),
      ep_addr   => x"20",               -- Endpoint adress
      ep_datain => ep20_wire            -- Endpoint data out 32 bits
      );

  inst_okwireout_ep21 : okWireOut
    port map(
      okHE      => okHE,
      okEH      => okEHx(2 * 65 - 1 downto 1 * 65),
      ep_addr   => x"21",               -- Endpoint adress
      ep_datain => ep21_wire            -- Endpoint data out 32 bits
      );

  inst_okwireout_ep22 : okWireOut
    port map(
      okHE      => okHE,
      okEH      => okEHx(3 * 65 - 1 downto 2 * 65),
      ep_addr   => x"22",               -- Endpoint adress
      ep_datain => ep22_wire            -- Endpoint data out 32 bits
      );

  inst_okwireout_ep23 : okWireOut
    port map(
      okHE      => okHE,
      okEH      => okEHx(4 * 65 - 1 downto 3 * 65),
      ep_addr   => x"23",               -- Endpoint adress
      ep_datain => ep23_wire            -- Endpoint data out 32 bits
      );

  inst_okwireout_ep24 : okWireOut
    port map(
      okHE      => okHE,
      okEH      => okEHx(5 * 65 - 1 downto 4 * 65),
      ep_addr   => x"24",               -- Endpoint adress
      ep_datain => ep24_wire            -- Endpoint data out 32 bits
      );

  inst_okwireout_ep25 : okWireOut
    port map(
      okHE      => okHE,
      okEH      => okEHx(6 * 65 - 1 downto 5 * 65),
      ep_addr   => x"25",               -- Endpoint adress
      ep_datain => ep25_wire            -- Endpoint data out 32 bits
      );

  inst_okwireout_ep26 : okWireOut
    port map(
      okHE      => okHE,
      okEH      => okEHx(7 * 65 - 1 downto 6 * 65),
      ep_addr   => x"26",               -- Endpoint adress
      ep_datain => ep26_wire            -- Endpoint data out 32 bits
      );

  inst_okwireout_ep27 : okWireOut
    port map(
      okHE      => okHE,
      okEH      => okEHx(8 * 65 - 1 downto 7 * 65),
      ep_addr   => x"27",               -- Endpoint adress
      ep_datain => ep27_wire            -- Endpoint data out 32 bits
      );

  inst_okwireout_ep28 : okWireOut
    port map(
      okHE      => okHE,
      okEH      => okEHx(9 * 65 - 1 downto 8 * 65),
      ep_addr   => x"28",               -- Endpoint adress
      ep_datain => ep28_wire            -- Endpoint data out 32 bits
      );

  inst_okwireout_ep2A : okWireOut
    port map(
      okHE      => okHE,
      okEH      => okEHx(10 * 65 - 1 downto 9 * 65),
      ep_addr   => x"2A",               -- Endpoint adress
      ep_datain => ep2A_wire            -- Endpoint data out 32 bits
      );

  inst_okwireout_ep2B : okWireOut
    port map(
      okHE      => okHE,
      okEH      => okEHx(11 * 65 - 1 downto 10 * 65),
      ep_addr   => x"2B",               -- Endpoint adress
      ep_datain => ep2B_wire            -- Endpoint data out 32 bits
      );

  inst_okwireout_ep2C : okWireOut
    port map(
      okHE      => okHE,
      okEH      => okEHx(12 * 65 - 1 downto 11 * 65),
      ep_addr   => x"2C",               -- Endpoint adress
      ep_datain => ep2C_wire            -- Endpoint data out 32 bits
      );

  inst_okwireout_ep2D : okWireOut
    port map(
      okHE      => okHE,
      okEH      => okEHx(13 * 65 - 1 downto 12 * 65),
      ep_addr   => x"2D",               -- Endpoint adress
      ep_datain => ep2D_wire            -- Endpoint data out 32 bits
      );

  inst_okwireout_ep31 : okWireOut
    port map(
      okHE      => okHE,
      okEH      => okEHx(14 * 65 - 1 downto 13 * 65),
      ep_addr   => x"31",               -- Endpoint adress
      ep_datain => ep31_wire            -- Endpoint data out 32 bits
      );

  inst_okwireout_ep32 : okWireOut
    port map(
      okHE      => okHE,
      okEH      => okEHx(15 * 65 - 1 downto 14 * 65),
      ep_addr   => x"32",               -- Endpoint adress
      ep_datain => ep32_wire            -- Endpoint data out 32 bits
      );

  inst_okwireout_ep33 : okWireOut
    port map(
      okHE      => okHE,
      okEH      => okEHx(16 * 65 - 1 downto 15 * 65),
      ep_addr   => x"33",               -- Endpoint adress
      ep_datain => ep33_wire            -- Endpoint data out 32 bits
      );

  inst_okwireout_ep34 : okWireOut
    port map(
      okHE      => okHE,
      okEH      => okEHx(17 * 65 - 1 downto 16 * 65),
      ep_addr   => x"34",               -- Endpoint adress
      ep_datain => ep34_wire            -- Endpoint data out 32 bits
      );

  inst_okwireout_ep35 : okWireOut
    port map(
      okHE      => okHE,
      okEH      => okEHx(18 * 65 - 1 downto 17 * 65),
      ep_addr   => x"35",               -- Endpoint adress
      ep_datain => ep35_wire            -- Endpoint data out 32 bits
      );

  inst_okwireout_ep36 : okWireOut
    port map(
      okHE      => okHE,
      okEH      => okEHx(19 * 65 - 1 downto 18 * 65),
      ep_addr   => x"36",               -- Endpoint adress
      ep_datain => ep36_wire            -- Endpoint data out 32 bits
      );

  inst_okwireout_ep37 : okWireOut
    port map(
      okHE      => okHE,
      okEH      => okEHx(20 * 65 - 1 downto 19 * 65),
      ep_addr   => x"37",               -- Endpoint adress
      ep_datain => ep37_wire            -- Endpoint data out 32 bits
      );


  inst_okwireout_ep38 : okWireOut
    port map(
      okHE      => okHE,
      okEH      => okEHx(21 * 65 - 1 downto 20 * 65),
      ep_addr   => x"38",               -- Endpoint adress
      ep_datain => ep38_wire            -- Endpoint data out 32 bits
      );

  inst_okwireout_ep39 : okWireOut
    port map(
      okHE      => okHE,
      okEH      => okEHx(22 * 65 - 1 downto 21 * 65),
      ep_addr   => x"39",               -- Endpoint adress
      ep_datain => ep39_wire            -- Endpoint data out 32 bits
      );

  inst_okwireout_ep3A : okWireOut
    port map(
      okHE      => okHE,
      okEH      => okEHx(23 * 65 - 1 downto 22 * 65),
      ep_addr   => x"3A",               -- Endpoint adress
      ep_datain => ep3A_wire            -- Endpoint data out 32 bits
      );

  inst_okwireout_ep3B : okWireOut
    port map(
      okHE      => okHE,
      okEH      => okEHx(24 * 65 - 1 downto 23 * 65),
      ep_addr   => x"3B",               -- Endpoint adress
      ep_datain => ep3B_wire            -- Endpoint data out 32 bits
      );


  ---------------------------------------------------------------------
  -- 
  ---------------------------------------------------------------------
  inst_okwireout_ep3D : okWireOut
    port map(
      okHE      => okHE,
      okEH      => okEHx(25 * 65 - 1 downto 24 * 65),
      ep_addr   => x"3D",               -- Endpoint adress
      ep_datain => ep3D_wire            -- Endpoint data out 32 bits
      );

  inst_okwireout_ep3E : okWireOut
    port map(
      okHE      => okHE,
      okEH      => okEHx(26 * 65 - 1 downto 25 * 65),
      ep_addr   => x"3E",               -- Endpoint adress
      ep_datain => ep3E_wire            -- Endpoint data out 32 bits
      );

  inst_okwireout_ep3F : okWireOut
    port map(
      okHE      => okHE,
      okEH      => okEHx(27 * 65 - 1 downto 26 * 65),
      ep_addr   => x"3F",               -- Endpoint adress
      ep_datain => ep3F_wire            -- Endpoint data out 32 bits
      );

  ---------------------------------------------------------------------
  -- Opal Kelly trig out
  ---------------------------------------------------------------------
  inst_okTriggerOut_ep60 : okTriggerOut
    port map(
      okHE       => okHE,
      okEH       => okEHx(28 * 65 - 1 downto 27 * 65),
      ep_addr    => x"60",
      ep_clk     => okClk,
      ep_trigger => ep60_trig
      );
  ----------------------------------------------------
  --    Opal Kelly Pipe in
  ----------------------------------------------------  
  inst_okpipein_ep80 : okPipeIn
    port map(
      okHE       => okHE,
      okEH       => okEHx(29 * 65 - 1 downto 28 * 65),
      ep_addr    => x"80",
      ep_write   => ep80_pipe_valid,
      ep_dataout => ep80_pipe
      );

  ----------------------------------------------------
  --    Opal Kelly Pipe out
  ----------------------------------------------------
  inst_okpipeout_epA0 : okPipeOut
    port map(
      okHE      => okHE,
      okEH      => okEHx(30 * 65 - 1 downto 29 * 65),
      ep_addr   => x"A0",
      ep_read   => epA0_pipe_rd,
      ep_datain => epA0_pipe
      );

  inst_okpipeout_epA1 : okPipeOut
    port map(
      okHE      => okHE,
      okEH      => okEHx(31 * 65 - 1 downto 30 * 65),
      ep_addr   => x"A1",
      ep_read   => epA1_pipe_rd,
      ep_datain => epA1_pipe
      );




  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  -- from okhost
  o_usb_clk               <= okClk;
  -- from pipe in
  o_usb_pipein_fifo_valid <= ep80_pipe_valid;
  o_usb_pipein_fifo       <= ep80_pipe;

  -- from trig in
  o_usb_trigin_data <= ep40_trig;

  -- from wire in
  o_usb_wirein_ctrl            <= ep00_wire;
  o_usb_wirein_make_pulse      <= ep01_wire;
  o_usb_wirein_fpasim_gain     <= ep02_wire;
  o_usb_wirein_mux_sq_fb_delay <= ep03_wire;
  o_usb_wirein_amp_sq_of_delay <= ep04_wire;
  o_usb_wirein_error_delay     <= ep05_wire;
  o_usb_wirein_ra_delay        <= ep06_wire;
  o_usb_wirein_tes_conf        <= ep07_wire;
  o_usb_wirein_conf0           <= ep08_wire;

  o_usb_wirein_rec_ctrl  <= ep0C_wire;
  o_usb_wirein_rec_conf0 <= ep0D_wire;

  o_usb_wirein_spi_ctrl    <= ep12_wire;
  o_usb_wirein_spi_conf0   <= ep13_wire;
  o_usb_wirein_spi_conf1   <= ep14_wire;
  o_usb_wirein_spi_wr_data <= ep15_wire;

  o_usb_wirein_debug_ctrl <= ep18_wire;
  o_usb_wirein_sel_errors <= ep19_wire;

end architecture RTL;
