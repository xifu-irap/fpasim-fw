
-- -------------------------------------------------------------------------------------------------------------
--                              Copyright (C) 2022-2030 Ken-ji de la Rosa, IRAP Toulouse.
-- -------------------------------------------------------------------------------------------------------------
--                              This file is part of the ATHENA X-IFU DRE Focal Plane Assembly simulator.
--
--                              work-fw is free software: you can redistribute it and/or modify
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
--!   @file                   regdecode_top.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--!
--!   This module manages the writing/reading of the registers/RAMs.
--!   The module is composed of 4 main sections:
--!     . The RAM access are done by using the Opal Kelly pipe_in/pipe_out
--!        . de-multiplexes the input data flow (i_addr/i_data) in order to configure each RAM
--!        . multiplexe the reading of each RAM into the output data flow (o_fifo_addr/o_fifo_data)
--!        . for each ram, it automatically generates read address in order to retrieve the RAM contents by taking into account
--!          the different RAM depth.
--!     . The common register access are done by using the Opal Kelly wire_in/wire_out and trig_in
--!        . on the trig signal, common registers are synchronized from a source clock domain to a destination clock domain.
--!        . Then, the output synchronized registers are read back from the destination clock domain to the source clock domain.
--!     . The command register access are done by using the Opal Kelly wire_in/wire_out and trig_in
--!        . it analyses the field of the i_make_pulse register. 2 behaviour are managed by the FSM:
--!           1. if pixel_all_tmp = '0' then no change is done on the i_make_pulse register value.
--!           2. if pixel_out_tmp = '1', then the FSM will automatically generate (i_pixel_nb + 1) words from the i_make_pulse value.
--!           All field of the generated words will be identical except the pixel_id field. For each generated word, the pixel_id field
--!           will be incremented from 0 to i_pixel_nb.
--!     . The errors/status access are done by using the Opal Kelly wire_in/wire_out and trig_out
--!       . it synchronizes the input errors/status from the i_clk source clock domain to the i_out_clk destination clock domain.
--!       Then, it generates a common error pulse signal on the first error detection.
--!
--!
--!   The RAM configuration principle is as follows:
--!       @i_clk source clock domain                                         |    @ i_out_clk destination clock domain
--!                                                        |--- fsm ---- fifo_async -------------- RAM0
--!                                                        |--- fsm ---- fifo_async ----------- RAM1 |
--!          i_addr/i_data    ----> addr_decode----------> |--- fsm ---- fifo_async ------- RAM2  |  |
--!                                                        |--- fsm ---- fifo_async ---- RAM3 |   |  |
--!                                                        |--- fsm ---- fifo_async - RAM4 |  |   |  |
--!                                                                                    |   |  |   |  |
--!                                              |------------------------fifo_async----   |  |   |  |                        
--!                                              |------------------------fifo_async--------  |   |  |                          
--!         o_fifo_addr/o_fifo_data <--fsm <---- |------------------------fifo_async----------    |  |
--!                                              |------------------------fifo_async--------------   | 
--!                                              |------------------------fifo_async-----------------
--!  The common register architecture principle is as follows:
--!        @i_clk clock domain        |                   @ i_out_clk clock domain
--!        i_data ---------------> async_fifo -----------> o_data
--!                                                      |
--!        o_fifo_data <---------  async_fifo <---------- 
--!
--!
--! The command register architecture principle is as follows:
--!        @i_clk source clock domain              |                   @ i_out_clk destination clock domain
--!        i_make_pulse_valid-------FSM -----> async_fifo -----------> o_data
--!                                                                      |
--!        o_fifo_data <----------------------  async_fifo <------------- 
--!
--!
--! The error/status register architecture principle is as follows:
--!       @i_clk destination clock domain                                         |                                @ i_out_clk source clock domain
--!                                                   |<-------------  single_bit_array_synchronizer <------------- i_errors7/i_status7
--!                                                   |<-------------  single_bit_array_synchronizer <-------------         .
--!        o_errors/o_status <--------- select output |<-------------  single_bit_array_synchronizer <-------------         .
--!                                                   |<-------------  single_bit_array_synchronizer <-------------         .
--!                                                   |<-------------  single_bit_array_synchronizer <------------- i_errors0/i_status0
--!
--!                                                                        |<-------------  /=0 ?    <------------- errors7 synchronized
--!                                                                        |<-------------  /=0 ?    <-------------         .
--!        errors_valid <-- rising_edge detection <-- /= last value? ------|<-------------  /=0 ?    <-------------         .
--!                                                                        |<-------------  /=0 ?    <-------------         .
--!                                                                        |<-------------  /=0 ?    <------------- errors0 synchronized
--!   Note: 
--!      . The module manages the clock domain crossing
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pkg_regdecode.all;

entity regdecode_top is
  generic(
    g_DEBUG : boolean := false
    );
  port(
    i_rst : in std_logic;               -- reset

    ---------------------------------------------------------------------
    -- from the usb @i_clk (clock included)
    ---------------------------------------------------------------------
    --  Opal Kelly inouts --
    i_okUH  : in    std_logic_vector(4 downto 0);
    o_okHU  : out   std_logic_vector(2 downto 0);
    b_okUHU : inout std_logic_vector(31 downto 0);
    b_okAA  : inout std_logic;

    ---------------------------------------------------------------------
    -- from/to the user @usb_clk
    ---------------------------------------------------------------------
    o_usb_clk             : out std_logic;  -- clock @usb_clk
    o_usb_rst_status        : out std_logic; -- reset error flag(s)
    o_usb_debug_pulse       : out std_logic; -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)

    -- spi: tx
    o_reg_spi_valid   : out std_logic;  -- valid spi_wr_data and spi_ctrl register
    o_reg_spi_ctrl    : out std_logic_vector(31 downto 0);  -- spi_ctrl register value
    o_reg_spi_conf    : out std_logic_vector(31 downto 0);  -- spi_ctrl register value
    o_reg_spi_wr_data : out std_logic_vector(31 downto 0);  -- spi_wr_data register value

    -- spi: rx
    i_reg_spi_rd_data_valid : in std_logic;  -- to connect
    i_reg_spi_rd_data       : in std_logic_vector(31 downto 0);  -- spi_rd_data register value
    -- spi: status
    i_reg_spi_status        : in std_logic_vector(31 downto 0);  -- spi_status register value

    i_spi_errors: in std_logic_vector(15 downto 0);
    i_spi_status: in std_logic_vector(7 downto 0);
    ---------------------------------------------------------------------
    -- from the board
    ---------------------------------------------------------------------
    i_board_id : in std_logic_vector(7 downto 0);  -- board id

    ---------------------------------------------------------------------
    -- from/to the user: @i_out_clk
    ---------------------------------------------------------------------
    i_out_rst     : in std_logic;       -- reset (user side)
    i_out_clk     : in std_logic;       -- clock (user side)
    i_rst_status  : in std_logic;       -- reset error flag(s)
    i_debug_pulse : in std_logic;  -- error mode (transparent vs capture). Possib

    -- RAM configuration 
    ---------------------------------------------------------------------
    -- tes_pulse_shape
    -- ram: wr
    o_tes_pulse_shape_ram_wr_en      : out std_logic;  -- output write enable
    o_tes_pulse_shape_ram_wr_rd_addr : out std_logic_vector(15 downto 0);  -- output address (shared by the writting and the reading)
    o_tes_pulse_shape_ram_wr_data    : out std_logic_vector(15 downto 0);  -- output data
    -- ram: rd
    o_tes_pulse_shape_ram_rd_en      : out std_logic;  -- output read enable
    i_tes_pulse_shape_ram_rd_valid   : in  std_logic;  -- input read valid
    i_tes_pulse_shape_ram_rd_data    : in  std_logic_vector(15 downto 0);  -- input read data

    -- amp_squid_tf
    -- ram: wr
    o_amp_squid_tf_ram_wr_en          : out std_logic;  -- output write enable
    o_amp_squid_tf_ram_wr_rd_addr     : out std_logic_vector(15 downto 0);  -- output address (shared by the writting and the reading)
    o_amp_squid_tf_ram_wr_data        : out std_logic_vector(15 downto 0);  -- output data
    -- ram: rd
    o_amp_squid_tf_ram_rd_en          : out std_logic;  -- output read enable
    i_amp_squid_tf_ram_rd_valid       : in  std_logic;  -- input read valid
    i_amp_squid_tf_ram_rd_data        : in  std_logic_vector(15 downto 0);  -- input read data
    -- mux_squid_tf
    -- ram: wr
    o_mux_squid_tf_ram_wr_en          : out std_logic;  -- output write enable
    o_mux_squid_tf_ram_wr_rd_addr     : out std_logic_vector(15 downto 0);  -- output address (shared by the writting and the reading)
    o_mux_squid_tf_ram_wr_data        : out std_logic_vector(15 downto 0);  -- output data
    -- ram: rd
    o_mux_squid_tf_ram_rd_en          : out std_logic;  -- output read enable
    i_mux_squid_tf_ram_rd_valid       : in  std_logic;  -- input read valid
    i_mux_squid_tf_ram_rd_data        : in  std_logic_vector(15 downto 0);  -- input read data
    -- tes_std_state
    -- ram: wr
    o_tes_std_state_ram_wr_en         : out std_logic;  -- output write enable
    o_tes_std_state_ram_wr_rd_addr    : out std_logic_vector(15 downto 0);  -- output address (shared by the writting and the reading)
    o_tes_std_state_ram_wr_data       : out std_logic_vector(15 downto 0);  -- output data
    -- ram: rd
    o_tes_std_state_ram_rd_en         : out std_logic;  -- output read enable
    i_tes_std_state_ram_rd_valid      : in  std_logic;  -- input read valid
    i_tes_std_state_ram_rd_data       : in  std_logic_vector(15 downto 0);  -- input read data
    -- mux_squid_offset
    -- ram: wr
    o_mux_squid_offset_ram_wr_en      : out std_logic;  -- output write enable
    o_mux_squid_offset_ram_wr_rd_addr : out std_logic_vector(15 downto 0);  -- output address (shared by the writting and the reading)
    o_mux_squid_offset_ram_wr_data    : out std_logic_vector(15 downto 0);  -- output data
    -- ram: rd
    o_mux_squid_offset_ram_rd_en      : out std_logic;  -- output read enable
    i_mux_squid_offset_ram_rd_valid   : in  std_logic;  -- input read valid
    i_mux_squid_offset_ram_rd_data    : in  std_logic_vector(15 downto 0);  -- input read data
    -- Register configuration
    ---------------------------------------------------------------------
    -- common register
    o_reg_valid                       : out std_logic;  -- register valid
    o_reg_fpasim_gain                 : out std_logic_vector(31 downto 0);  -- register fpasim_gain value
    o_reg_mux_sq_fb_delay             : out std_logic_vector(31 downto 0);  -- register mux_sq_fb_delay value
    o_reg_amp_sq_of_delay             : out std_logic_vector(31 downto 0);  -- register amp_sq_of_delay value
    o_reg_error_delay                 : out std_logic_vector(31 downto 0);  -- register error_delay value
    o_reg_ra_delay                    : out std_logic_vector(31 downto 0);  -- register ra_delay value
    o_reg_tes_conf                    : out std_logic_vector(31 downto 0);  -- register tes_conf value
    -- ctrl register
    o_reg_ctrl_valid                  : out std_logic;  -- register ctrl valid
    o_reg_ctrl                        : out std_logic_vector(31 downto 0);  -- register ctrl value
    -- debug ctrl register
    o_reg_debug_ctrl_valid            : out std_logic;  -- register debug_ctrl valid
    o_reg_debug_ctrl                  : out std_logic_vector(31 downto 0);  -- register debug_ctrl value
    -- make pulse register
    i_reg_make_pulse_ready            : in  std_logic;
    o_reg_make_sof                    : out std_logic;  -- first sample
    o_reg_make_eof                    : out std_logic;  -- last sample
    o_reg_make_pulse_valid            : out std_logic;  -- register make_pulse valid
    o_reg_make_pulse                  : out std_logic_vector(31 downto 0);  -- register make_pulse value

    -- recording
    ---------------------------------------------------------------------
    -- register
    o_reg_rec_valid               : out std_logic;  -- register rec_ctrl/rec_conf0 valid
    o_reg_rec_ctrl                : out std_logic_vector(31 downto 0);  -- register rec_ctrl value
    o_reg_rec_conf0               : out std_logic_vector(31 downto 0);  -- register rec_conf0 value
    -- data
    o_reg_fifo_rec_adc_rd         : out std_logic;  -- fifo read signal
    i_reg_fifo_rec_adc_sof        : in  std_logic;  -- first sample
    i_reg_fifo_rec_adc_eof        : in  std_logic;  -- last sample
    i_reg_fifo_rec_adc_data_valid : in  std_logic;  -- data valid
    i_reg_fifo_rec_adc_data       : in  std_logic_vector(31 downto 0);  -- data value
    i_reg_fifo_rec_adc_empty      : in  std_logic;  -- fifo empty flag

    -- to the usb 
    ---------------------------------------------------------------------
    -- errors
    i_reg_wire_errors3 : in std_logic_vector(31 downto 0);  -- errors3 register
    i_reg_wire_errors2 : in std_logic_vector(31 downto 0);  -- errors2 register
    i_reg_wire_errors1 : in std_logic_vector(31 downto 0);  -- errors1 register
    i_reg_wire_errors0 : in std_logic_vector(31 downto 0);  -- errors0 register
    -- status
    i_reg_wire_status3 : in std_logic_vector(31 downto 0);  -- status3 register
    i_reg_wire_status2 : in std_logic_vector(31 downto 0);  -- status2 register
    i_reg_wire_status1 : in std_logic_vector(31 downto 0);  -- status1 register
    i_reg_wire_status0 : in std_logic_vector(31 downto 0)   -- status0 register

    );
end entity regdecode_top;

architecture RTL of regdecode_top is
  -- spi_valid
  constant c_TRIGIN_SPI_VALID_IDX_H        : integer := pkg_TRIGIN_SPI_VALID_IDX_H;
  -- rec_valid
  constant c_TRIGIN_REC_VALID_IDX_H        : integer := pkg_TRIGIN_REC_VALID_IDX_H;
  -- debug_valid
  constant c_TRIGIN_DEBUG_VALID_IDX_H      : integer := pkg_TRIGIN_DEBUG_VALID_IDX_H;
  -- ctrl_valid
  constant c_TRIGIN_CTRL_VALID_IDX_H       : integer := pkg_TRIGIN_CTRL_VALID_IDX_H;
  -- read_all
  constant c_TRIGIN_READ_ALL_VALID_IDX_H   : integer := pkg_TRIGIN_READ_ALL_VALID_IDX_H;
  -- make_pulse valid
  constant c_TRIGIN_MAKE_PULSE_VALID_IDX_H : integer := pkg_TRIGIN_MAKE_PULSE_VALID_IDX_H;
  -- reg_valid
  constant c_TRIGIN_REG_VALID_IDX_H        : integer := pkg_TRIGIN_REG_VALID_IDX_H;

  -- firwmare id
  constant c_FIRMWARE_ID      : std_logic_vector(31 downto 0) := pkg_FIRMWARE_ID;
  -- firmware version
  constant c_FIRMWARE_VERSION : std_logic_vector(31 downto 0) := pkg_FIRMWARE_VERSION;

  constant c_TES_CONF_PIXEL_NB_IDX_H : integer := pkg_TES_CONF_NB_PIXEL_BY_FRAME_IDX_H;
  constant c_TES_CONF_PIXEL_NB_IDX_L : integer := pkg_TES_CONF_NB_PIXEL_BY_FRAME_IDX_L;
  constant c_TES_CONF_PIXEL_NB_WIDTH : integer := pkg_TES_CONF_NB_PIXEL_BY_FRAME_WIDTH;

  constant c_ERROR_SEL_IDX_H : integer := pkg_ERROR_SEL_IDX_H;
  constant c_ERROR_SEL_IDX_L : integer := pkg_ERROR_SEL_IDX_L;
  constant c_ERROR_SEL_WIDTH : integer := pkg_ERROR_SEL_WIDTH;

  ---------------------------------------------------------------------
  -- usb
  ---------------------------------------------------------------------

  -- from the user 
  ---------------------------------------------------------------------
  -- pipe
  signal usb_pipeout_fifo_rd             : std_logic;  --  read fifo
  signal usb_pipeout_fifo_data           : std_logic_vector(31 downto 0);
  signal usb_wireout_fifo_data_count     : std_logic_vector(31 downto 0);
  -- trig
  signal usb_trigout_data                : std_logic_vector(31 downto 0);
  -- ctrl: register
  signal usb_wireout_ctrl                : std_logic_vector(31 downto 0);
  -- make_pulse: register
  signal usb_wireout_make_pulse          : std_logic_vector(31 downto 0);
  -- common: register
  signal usb_wireout_fpasim_gain         : std_logic_vector(31 downto 0);
  signal usb_wireout_mux_sq_fb_delay     : std_logic_vector(31 downto 0);
  signal usb_wireout_amp_sq_of_delay     : std_logic_vector(31 downto 0);
  signal usb_wireout_error_delay         : std_logic_vector(31 downto 0);
  signal usb_wireout_ra_delay            : std_logic_vector(31 downto 0);
  signal usb_wireout_tes_conf            : std_logic_vector(31 downto 0);
  signal usb_wireout_debug_ctrl          : std_logic_vector(31 downto 0);
  signal usb_wireout_firmware_id         : std_logic_vector(31 downto 0);
  signal usb_wireout_firmware_version    : std_logic_vector(31 downto 0);
  signal usb_wireout_board_id            : std_logic_vector(31 downto 0);
  -- recording: register
  signal usb_wireout_rec_ctrl            : std_logic_vector(31 downto 0);
  signal usb_wireout_rec_conf0           : std_logic_vector(31 downto 0);
  -- recording: pipe
  signal usb_pipeout_rec_fifo_adc_rd     : std_logic;  --  read fifo
  signal usb_pipeout_rec_fifo_adc_data   : std_logic_vector(31 downto 0);
  signal usb_wireout_rec_fifo_data_count : std_logic_vector(31 downto 0);
  -- spi: register
  signal usb_wireout_spi_ctrl            : std_logic_vector(31 downto 0);
  signal usb_wireout_spi_conf            : std_logic_vector(31 downto 0);
  signal usb_wireout_spi_wr_data         : std_logic_vector(31 downto 0);
  signal usb_wireout_spi_rd_data         : std_logic_vector(31 downto 0);
  signal usb_wireout_spi_status          : std_logic_vector(31 downto 0);
  -- errors/status
  signal usb_wireout_sel_errors          : std_logic_vector(31 downto 0);
  signal usb_wireout_errors              : std_logic_vector(31 downto 0);
  signal usb_wireout_status              : std_logic_vector(31 downto 0);

  -- to the user
  ---------------------------------------------------------------------
  signal usb_clk                    : std_logic;
  -- pipe
  signal usb_pipein_fifo_valid      : std_logic;
  signal usb_pipein_fifo            : std_logic_vector(31 downto 0);
  -- trig
  signal usb_trigin_data            : std_logic_vector(31 downto 0);
  -- ctrl: register
  signal usb_wirein_ctrl            : std_logic_vector(31 downto 0);
  -- make_pulse: register
  signal usb_wirein_make_pulse      : std_logic_vector(31 downto 0);
  -- common: register
  signal usb_wirein_fpasim_gain     : std_logic_vector(31 downto 0);
  signal usb_wirein_mux_sq_fb_delay : std_logic_vector(31 downto 0);
  signal usb_wirein_amp_sq_of_delay : std_logic_vector(31 downto 0);
  signal usb_wirein_error_delay     : std_logic_vector(31 downto 0);
  signal usb_wirein_ra_delay        : std_logic_vector(31 downto 0);
  signal usb_wirein_tes_conf        : std_logic_vector(31 downto 0);
  -- recording: register
  signal usb_wirein_rec_ctrl        : std_logic_vector(31 downto 0);
  signal usb_wirein_rec_conf0       : std_logic_vector(31 downto 0);

  -- spi:register
  signal usb_wirein_spi_ctrl    : std_logic_vector(31 downto 0);
  signal usb_wirein_spi_conf    : std_logic_vector(31 downto 0);
  signal usb_wirein_spi_wr_data : std_logic_vector(31 downto 0);

  -- debug: register
  signal usb_wirein_debug_ctrl : std_logic_vector(31 downto 0);
  signal usb_wirein_sel_errors : std_logic_vector(31 downto 0);

  ---------------------------------------------------------------------
  -- regdecode_pipe
  ---------------------------------------------------------------------
  signal trig_reg_valid        : std_logic;
  signal trig_make_pulse_valid : std_logic;
  signal trig_rd_all_valid     : std_logic;
  signal trig_ctrl_valid       : std_logic;
  signal trig_debug_valid      : std_logic;
  signal trig_rec_valid        : std_logic;
  signal trig_spi_valid        : std_logic;

  signal pipein_valid0 : std_logic;
  signal pipein_addr0  : std_logic_vector(15 downto 0);
  signal pipein_data0  : std_logic_vector(15 downto 0);

  signal pipeout_rd         : std_logic;
  signal pipeout_sof        : std_logic;  -- @suppress "signal pipeout_sof is never read"
  signal pipeout_eof        : std_logic;  -- @suppress "signal pipeout_eof is never read"
  signal pipeout_valid      : std_logic;  -- @suppress "signal pipeout_valid is never read"
  signal pipeout_addr       : std_logic_vector(15 downto 0);
  signal pipeout_data       : std_logic_vector(15 downto 0);
  signal pipeout_empty      : std_logic;  -- @suppress "signal pipeout_empty is never read"
  signal pipeout_data_count : std_logic_vector(15 downto 0);

  -- tes_pulse_shape
  -- ram: wr
  signal tes_pulse_shape_ram_wr_en      : std_logic;
  signal tes_pulse_shape_ram_wr_rd_addr : std_logic_vector(o_tes_pulse_shape_ram_wr_rd_addr'range);
  signal tes_pulse_shape_ram_wr_data    : std_logic_vector(o_tes_pulse_shape_ram_wr_data'range);
  -- ram: rd
  signal tes_pulse_shape_ram_rd_en      : std_logic;

  -- amp_squid_tf
  -- ram: wr
  signal amp_squid_tf_ram_wr_en      : std_logic;
  signal amp_squid_tf_ram_wr_rd_addr : std_logic_vector(o_amp_squid_tf_ram_wr_rd_addr'range);
  signal amp_squid_tf_ram_wr_data    : std_logic_vector(o_amp_squid_tf_ram_wr_data'range);
  -- ram: rd
  signal amp_squid_tf_ram_rd_en      : std_logic;

  -- mux_squid_tf
  -- ram: wr
  signal mux_squid_tf_ram_wr_en      : std_logic;
  signal mux_squid_tf_ram_wr_rd_addr : std_logic_vector(o_mux_squid_tf_ram_wr_rd_addr'range);
  signal mux_squid_tf_ram_wr_data    : std_logic_vector(o_mux_squid_tf_ram_wr_data'range);
  -- ram: rd
  signal mux_squid_tf_ram_rd_en      : std_logic;

  -- tes_std_state
  -- ram: wr
  signal tes_std_state_ram_wr_en      : std_logic;
  signal tes_std_state_ram_wr_rd_addr : std_logic_vector(o_tes_std_state_ram_wr_rd_addr'range);
  signal tes_std_state_ram_wr_data    : std_logic_vector(o_tes_std_state_ram_wr_data'range);
  -- ram: rd
  signal tes_std_state_ram_rd_en      : std_logic;

  -- mux_squid_offset
  -- ram: wr
  signal mux_squid_offset_ram_wr_en      : std_logic;
  signal mux_squid_offset_ram_wr_rd_addr : std_logic_vector(o_mux_squid_offset_ram_wr_rd_addr'range);
  signal mux_squid_offset_ram_wr_data    : std_logic_vector(o_mux_squid_offset_ram_wr_data'range);
  -- ram: rd
  signal mux_squid_offset_ram_rd_en      : std_logic;

  -- errors
  signal regdecode_pipe_errors5 : std_logic_vector(15 downto 0);
  signal regdecode_pipe_errors4 : std_logic_vector(15 downto 0);
  signal regdecode_pipe_errors3 : std_logic_vector(15 downto 0);
  signal regdecode_pipe_errors2 : std_logic_vector(15 downto 0);
  signal regdecode_pipe_errors1 : std_logic_vector(15 downto 0);
  signal regdecode_pipe_errors0 : std_logic_vector(15 downto 0);
  -- status
  signal regdecode_pipe_status5 : std_logic_vector(7 downto 0);
  signal regdecode_pipe_status4 : std_logic_vector(7 downto 0);
  signal regdecode_pipe_status3 : std_logic_vector(7 downto 0);
  signal regdecode_pipe_status2 : std_logic_vector(7 downto 0);
  signal regdecode_pipe_status1 : std_logic_vector(7 downto 0);
  signal regdecode_pipe_status0 : std_logic_vector(7 downto 0);

  ---------------------------------------------------------------------
  -- wire: common registers
  ---------------------------------------------------------------------
  constant c_REG_IDX0_L : integer := 0;
  constant c_REG_IDX0_H : integer := c_REG_IDX0_L + usb_wirein_fpasim_gain'length - 1;

  constant c_REG_IDX1_L : integer := c_REG_IDX0_H + 1;
  constant c_REG_IDX1_H : integer := c_REG_IDX1_L + usb_wirein_mux_sq_fb_delay'length - 1;

  constant c_REG_IDX2_L : integer := c_REG_IDX1_H + 1;
  constant c_REG_IDX2_H : integer := c_REG_IDX2_L + usb_wirein_amp_sq_of_delay'length - 1;

  constant c_REG_IDX3_L : integer := c_REG_IDX2_H + 1;
  constant c_REG_IDX3_H : integer := c_REG_IDX3_L + usb_wirein_error_delay'length - 1;

  constant c_REG_IDX4_L : integer := c_REG_IDX3_H + 1;
  constant c_REG_IDX4_H : integer := c_REG_IDX4_L + usb_wirein_ra_delay'length - 1;

  constant c_REG_IDX5_L : integer := c_REG_IDX4_H + 1;
  constant c_REG_IDX5_H : integer := c_REG_IDX5_L + usb_wirein_tes_conf'length - 1;

  signal reg_data_valid_tmp0 : std_logic;
  signal reg_data_tmp0       : std_logic_vector(c_REG_IDX5_H downto 0);

  signal reg_rd_tmp1    : std_logic;
  -- signal reg_data_valid_tmp1 : std_logic;
  signal reg_data_tmp1  : std_logic_vector(c_REG_IDX5_H downto 0);
  signal reg_empty_tmp1 : std_logic;

  signal reg_data_valid_tmp2 : std_logic;
  signal reg_data_tmp2       : std_logic_vector(c_REG_IDX5_H downto 0);

  signal reg_errors : std_logic_vector(15 downto 0);
  signal reg_status : std_logic_vector(7 downto 0);

  ---------------------------------------------------------------------
  -- wire: control register
  ---------------------------------------------------------------------
  signal ctrl_data_valid_tmp0 : std_logic;
  signal ctrl_data_tmp0       : std_logic_vector(usb_wirein_ctrl'range);

  signal ctrl_rd_tmp1    : std_logic;
  -- signal ctrl_data_valid_tmp1 : std_logic;
  signal ctrl_data_tmp1  : std_logic_vector(usb_wirein_ctrl'range);
  signal ctrl_empty_tmp1 : std_logic;

  signal ctrl_data_valid_tmp2 : std_logic;
  signal ctrl_data_tmp2       : std_logic_vector(usb_wirein_ctrl'range);

  signal ctrl_errors : std_logic_vector(15 downto 0);
  signal ctrl_status : std_logic_vector(7 downto 0);

  ---------------------------------------------------------------------
  -- wire: debug control register
  ---------------------------------------------------------------------
  signal usb_rst_status  : std_logic;
  signal usb_debug_pulse : std_logic;

  signal debug_ctrl_data_valid_tmp0 : std_logic;
  signal debug_ctrl_data_tmp0       : std_logic_vector(usb_wirein_debug_ctrl'range);

  signal debug_ctrl_rd_tmp1    : std_logic;
  -- signal debug_ctrl_data_valid_tmp1 : std_logic;
  signal debug_ctrl_data_tmp1  : std_logic_vector(usb_wirein_debug_ctrl'range);
  signal debug_ctrl_empty_tmp1 : std_logic;

  signal debug_ctrl_data_valid_tmp2 : std_logic;
  signal debug_ctrl_data_tmp2       : std_logic_vector(usb_wirein_debug_ctrl'range);

  signal debug_ctrl_errors : std_logic_vector(15 downto 0);
  signal debug_ctrl_status : std_logic_vector(7 downto 0);

  ---------------------------------------------------------------------
  -- wire: make pulse register
  ---------------------------------------------------------------------
  signal pixel_nb                      : std_logic_vector(c_TES_CONF_PIXEL_NB_WIDTH - 1 downto 0);
  signal make_pulse_data_valid_tmp0    : std_logic;
  signal make_pulse_data_tmp0          : std_logic_vector(usb_wirein_make_pulse'range);
  signal make_pulse_wr_data_count_tmp0 : std_logic_vector(15 downto 0);

  signal make_pulse_rd_tmp1    : std_logic;
  --signal make_pulse_data_valid_tmp1  : std_logic;
  --signal make_pulse_sof_tmp1  : std_logic;
  --signal make_pulse_eof_tmp1  : std_logic;
  signal make_pulse_data_tmp1  : std_logic_vector(usb_wirein_make_pulse'range);
  signal make_pulse_empty_tmp1 : std_logic;

  signal make_pulse_rd_tmp2         : std_logic;
  signal make_pulse_sof_tmp2        : std_logic;
  signal make_pulse_eof_tmp2        : std_logic;
  signal make_pulse_data_valid_tmp2 : std_logic;
  signal make_pulse_data_tmp2       : std_logic_vector(usb_wirein_make_pulse'range);
  signal make_pulse_empty_tmp2      : std_logic;

  signal make_pulse_errors : std_logic_vector(15 downto 0);
  signal make_pulse_status : std_logic_vector(7 downto 0);


  ---------------------------------------------------------------------
  -- wire/pipe: recording register
  ---------------------------------------------------------------------
  signal rec_valid_tmp0 : std_logic;
  signal rec_ctrl_tmp0  : std_logic_vector(usb_wirein_rec_ctrl'range);
  signal rec_conf0_tmp0 : std_logic_vector(usb_wirein_rec_conf0'range);

  signal rec_valid_tmp2 : std_logic;
  signal rec_ctrl_tmp2  : std_logic_vector(usb_wirein_rec_ctrl'range);
  signal rec_conf0_tmp2 : std_logic_vector(usb_wirein_rec_conf0'range);

  -- from user: fifo
  signal reg_fifo_rec_adc_rd : std_logic;

  -- to usb: register
  signal usb_rec_valid              : std_logic;
  signal usb_rec_ctrl               : std_logic_vector(usb_wireout_rec_ctrl'range);
  signal usb_rec_conf0              : std_logic_vector(usb_wireout_rec_conf0'range);
  -- to usb: fifo
  signal usb_fifo_adc_rd            : std_logic;  -- fifo read enable
  signal usb_fifo_adc_sof           : std_logic;  -- fifo first sample
  signal usb_fifo_adc_eof           : std_logic;  -- fifo last sample
  signal usb_fifo_adc_data_valid    : std_logic;  -- fifo data valid
  signal usb_fifo_adc_data          : std_logic_vector(usb_pipeout_rec_fifo_adc_data'range);  -- fifo data
  signal usb_fifo_adc_empty         : std_logic;  -- fifo empty flag
  signal usb_fifo_adc_wr_data_count : std_logic_vector(15 downto 0);

  signal rec_errors1 : std_logic_vector(15 downto 0);
  signal rec_errors0 : std_logic_vector(15 downto 0);
  signal rec_status1 : std_logic_vector(7 downto 0);
  signal rec_status0 : std_logic_vector(7 downto 0);

  ---------------------------------------------------------------------
  -- wire: errors registers
  ---------------------------------------------------------------------
  signal error_sel : std_logic_vector(c_ERROR_SEL_WIDTH - 1 downto 0);

  signal wire_errors_valid : std_logic;
  signal wire_errors       : std_logic_vector(i_reg_wire_errors0'range);
  signal wire_status       : std_logic_vector(i_reg_wire_status0'range);

  signal regdecode_errors6 : std_logic_vector(i_reg_wire_errors0'range);
  signal regdecode_errors5 : std_logic_vector(i_reg_wire_errors0'range);
  signal regdecode_errors4 : std_logic_vector(i_reg_wire_errors0'range);
  signal regdecode_errors3 : std_logic_vector(i_reg_wire_errors0'range);
  signal regdecode_errors2 : std_logic_vector(i_reg_wire_errors0'range);
  signal regdecode_errors1 : std_logic_vector(i_reg_wire_errors0'range);
  signal regdecode_errors0 : std_logic_vector(i_reg_wire_errors0'range);

  signal regdecode_status6 : std_logic_vector(i_reg_wire_status0'range);
  signal regdecode_status5 : std_logic_vector(i_reg_wire_status0'range);
  signal regdecode_status4 : std_logic_vector(i_reg_wire_status0'range);
  signal regdecode_status3 : std_logic_vector(i_reg_wire_status0'range);
  signal regdecode_status2 : std_logic_vector(i_reg_wire_status0'range);
  signal regdecode_status1 : std_logic_vector(i_reg_wire_status0'range);
  signal regdecode_status0 : std_logic_vector(i_reg_wire_status0'range);

begin

  inst_usb_opal_kelly : entity work.usb_opal_kelly
    port map(
      --  Opal Kelly inouts --
      i_okUH                            => i_okUH,
      o_okHU                            => o_okHU,
      b_okUHU                           => b_okUHU,
      b_okAA                            => b_okAA,
      ---------------------------------------------------------------------
      -- from the user @o_usb_clk
      ---------------------------------------------------------------------
      -- pipe
      o_usb_pipeout_fifo_rd             => usb_pipeout_fifo_rd,
      i_usb_pipeout_fifo_data           => usb_pipeout_fifo_data,
      i_usb_wireout_fifo_data_count     => usb_wireout_fifo_data_count,
      -- trig
      i_usb_trigout_data                => usb_trigout_data,
      -- wire
      i_usb_wireout_ctrl                => usb_wireout_ctrl,
      i_usb_wireout_make_pulse          => usb_wireout_make_pulse,
      i_usb_wireout_fpasim_gain         => usb_wireout_fpasim_gain,
      i_usb_wireout_mux_sq_fb_delay     => usb_wireout_mux_sq_fb_delay,
      i_usb_wireout_amp_sq_of_delay     => usb_wireout_amp_sq_of_delay,
      i_usb_wireout_error_delay         => usb_wireout_error_delay,
      i_usb_wireout_ra_delay            => usb_wireout_ra_delay,
      i_usb_wireout_tes_conf            => usb_wireout_tes_conf,
      i_usb_wireout_debug_ctrl          => usb_wireout_debug_ctrl,
      i_usb_wireout_firmware_id         => usb_wireout_firmware_id,
      i_usb_wireout_firmware_version    => usb_wireout_firmware_version,
      i_usb_wireout_board_id            => usb_wireout_board_id,
      -- recording: register 
      i_usb_wireout_rec_ctrl            => usb_wireout_rec_ctrl,
      i_usb_wireout_rec_conf0           => usb_wireout_rec_conf0,
      -- recording: pipe 
      o_usb_pipeout_rec_fifo_adc_rd     => usb_pipeout_rec_fifo_adc_rd,
      i_usb_pipeout_rec_fifo_adc_data   => usb_pipeout_rec_fifo_adc_data,
      i_usb_wireout_rec_fifo_data_count => usb_wireout_rec_fifo_data_count,  -- to connect
      -- spi: register
      i_usb_wireout_spi_ctrl            => usb_wireout_spi_ctrl,
      i_usb_wireout_spi_conf            => usb_wireout_spi_conf,
      i_usb_wireout_spi_wr_data         => usb_wireout_spi_wr_data,
      i_usb_wireout_spi_rd_data         => i_reg_spi_rd_data,
      i_usb_wireout_spi_status          => i_reg_spi_status,

      -- errors/status
      i_usb_wireout_sel_errors     => usb_wireout_sel_errors,
      i_usb_wireout_errors         => usb_wireout_errors,
      i_usb_wireout_status         => usb_wireout_status,
      ---------------------------------------------------------------------
      -- to the user @o_usb_clk
      ---------------------------------------------------------------------
      o_usb_clk                    => usb_clk,  -- usb clock
      -- pipe
      o_usb_pipein_fifo_valid      => usb_pipein_fifo_valid,
      o_usb_pipein_fifo            => usb_pipein_fifo,
      -- trig
      o_usb_trigin_data            => usb_trigin_data,
      -- wire
      o_usb_wirein_ctrl            => usb_wirein_ctrl,
      o_usb_wirein_make_pulse      => usb_wirein_make_pulse,
      o_usb_wirein_fpasim_gain     => usb_wirein_fpasim_gain,
      o_usb_wirein_mux_sq_fb_delay => usb_wirein_mux_sq_fb_delay,
      o_usb_wirein_amp_sq_of_delay => usb_wirein_amp_sq_of_delay,
      o_usb_wirein_error_delay     => usb_wirein_error_delay,
      o_usb_wirein_ra_delay        => usb_wirein_ra_delay,
      o_usb_wirein_tes_conf        => usb_wirein_tes_conf,
      -- recording
      o_usb_wirein_rec_ctrl        => usb_wirein_rec_ctrl,
      o_usb_wirein_rec_conf0       => usb_wirein_rec_conf0,
      -- spi: register
      o_usb_wirein_spi_ctrl        => usb_wirein_spi_ctrl,
      o_usb_wirein_spi_conf        => usb_wirein_spi_conf,
      o_usb_wirein_spi_wr_data     => usb_wirein_spi_wr_data,

      -- debug
      o_usb_wirein_debug_ctrl => usb_wirein_debug_ctrl,
      o_usb_wirein_sel_errors => usb_wirein_sel_errors
      );

  ---------------------------------------------------------------------
  -- output @usb_clk
  ---------------------------------------------------------------------
  o_usb_clk             <= usb_clk;
  o_reg_spi_valid   <= trig_spi_valid;
  o_reg_spi_ctrl    <= usb_wirein_spi_ctrl;
  o_reg_spi_conf    <= usb_wirein_spi_conf;
  o_reg_spi_wr_data <= usb_wirein_spi_wr_data;

  o_usb_rst_status  <= usb_rst_status;
  o_usb_debug_pulse  <= usb_debug_pulse;

  -- loop back register value
  usb_wireout_spi_ctrl    <= usb_wirein_spi_ctrl;
  usb_wireout_spi_conf    <= usb_wirein_spi_conf;
  usb_wireout_spi_wr_data <= usb_wirein_spi_wr_data;

  ---------------------------------------------------------------------
  -- get the firmware id
  ---------------------------------------------------------------------
  usb_wireout_firmware_id      <= c_FIRMWARE_ID;
  usb_wireout_firmware_version <= c_FIRMWARE_VERSION;
  usb_wireout_board_id         <= std_logic_vector(resize(unsigned(i_board_id), usb_wireout_board_id'length));

  -- from trigin: extract bits signal
  trig_spi_valid        <= usb_trigin_data(c_TRIGIN_SPI_VALID_IDX_H);
  trig_rec_valid        <= usb_trigin_data(c_TRIGIN_REC_VALID_IDX_H);
  trig_debug_valid      <= usb_trigin_data(c_TRIGIN_DEBUG_VALID_IDX_H);
  trig_ctrl_valid       <= usb_trigin_data(c_TRIGIN_CTRL_VALID_IDX_H);
  trig_rd_all_valid     <= usb_trigin_data(c_TRIGIN_READ_ALL_VALID_IDX_H);
  trig_make_pulse_valid <= usb_trigin_data(c_TRIGIN_MAKE_PULSE_VALID_IDX_H);
  trig_reg_valid        <= usb_trigin_data(c_TRIGIN_REG_VALID_IDX_H);

  ---------------------------------------------------------------------
  -- pipe management
  ---------------------------------------------------------------------
  pipein_valid0 <= usb_pipein_fifo_valid;
  pipein_addr0  <= usb_pipein_fifo(31 downto 16);
  pipein_data0  <= usb_pipein_fifo(15 downto 0);
  pipeout_rd    <= usb_pipeout_fifo_rd;

  inst_regdecode_pipe : entity work.regdecode_pipe
    generic map(
      g_ADDR_WIDTH => pipein_addr0'length,  -- define the address bus width
      g_DATA_WIDTH => pipein_data0'length   -- define the data bus width

      )
    port map(
      ---------------------------------------------------------------------
      -- input @i_clk
      ---------------------------------------------------------------------
      i_clk           => usb_clk,       -- clock
      i_rst           => i_rst,         -- reset
      i_rst_status    => usb_rst_status,
      i_debug_pulse   => usb_debug_pulse,
      -- from the trig in
      i_start_auto_rd => trig_rd_all_valid,  -- enable the auto generation of memory reading address
      -- from the pipe in
      i_data_valid    => pipein_valid0,
      i_addr          => pipein_addr0,
      i_data          => pipein_data0,

      ---------------------------------------------------------------------
      -- to the pipe out: @i_clk
      ---------------------------------------------------------------------

      i_fifo_rd                         => pipeout_rd,
      o_fifo_sof                        => pipeout_sof,
      o_fifo_eof                        => pipeout_eof,
      o_fifo_data_valid                 => pipeout_valid,
      o_fifo_addr                       => pipeout_addr,
      o_fifo_data                       => pipeout_data,
      o_fifo_empty                      => pipeout_empty,
      o_fifo_data_count                 => pipeout_data_count,
      ---------------------------------------------------------------------
      -- to the user: @i_out_clk
      ---------------------------------------------------------------------
      i_out_clk                         => i_out_clk,
      -- tes_pulse_shape
      -- ram: wr
      o_tes_pulse_shape_ram_wr_en       => tes_pulse_shape_ram_wr_en,
      o_tes_pulse_shape_ram_wr_rd_addr  => tes_pulse_shape_ram_wr_rd_addr,
      o_tes_pulse_shape_ram_wr_data     => tes_pulse_shape_ram_wr_data,
      -- ram: rd
      o_tes_pulse_shape_ram_rd_en       => tes_pulse_shape_ram_rd_en,
      i_tes_pulse_shape_ram_rd_valid    => i_tes_pulse_shape_ram_rd_valid,
      i_tes_pulse_shape_ram_rd_data     => i_tes_pulse_shape_ram_rd_data,
      -- amp_squid_tf
      -- ram: wr
      o_amp_squid_tf_ram_wr_en          => amp_squid_tf_ram_wr_en,
      o_amp_squid_tf_ram_wr_rd_addr     => amp_squid_tf_ram_wr_rd_addr,
      o_amp_squid_tf_ram_wr_data        => amp_squid_tf_ram_wr_data,
      -- ram: rd
      o_amp_squid_tf_ram_rd_en          => amp_squid_tf_ram_rd_en,
      i_amp_squid_tf_ram_rd_valid       => i_amp_squid_tf_ram_rd_valid,
      i_amp_squid_tf_ram_rd_data        => i_amp_squid_tf_ram_rd_data,
      -- mux_squid_tf
      -- ram: wr
      o_mux_squid_tf_ram_wr_en          => mux_squid_tf_ram_wr_en,
      o_mux_squid_tf_ram_wr_rd_addr     => mux_squid_tf_ram_wr_rd_addr,
      o_mux_squid_tf_ram_wr_data        => mux_squid_tf_ram_wr_data,
      -- ram: rd
      o_mux_squid_tf_ram_rd_en          => mux_squid_tf_ram_rd_en,
      i_mux_squid_tf_ram_rd_valid       => i_mux_squid_tf_ram_rd_valid,
      i_mux_squid_tf_ram_rd_data        => i_mux_squid_tf_ram_rd_data,
      -- tes_std_state
      -- ram: wr
      o_tes_std_state_ram_wr_en         => tes_std_state_ram_wr_en,
      o_tes_std_state_ram_wr_rd_addr    => tes_std_state_ram_wr_rd_addr,
      o_tes_std_state_ram_wr_data       => tes_std_state_ram_wr_data,
      -- ram: rd
      o_tes_std_state_ram_rd_en         => tes_std_state_ram_rd_en,
      i_tes_std_state_ram_rd_valid      => i_tes_std_state_ram_rd_valid,
      i_tes_std_state_ram_rd_data       => i_tes_std_state_ram_rd_data,
      -- mux_squid_offset
      -- ram: wr
      o_mux_squid_offset_ram_wr_en      => mux_squid_offset_ram_wr_en,
      o_mux_squid_offset_ram_wr_rd_addr => mux_squid_offset_ram_wr_rd_addr,
      o_mux_squid_offset_ram_wr_data    => mux_squid_offset_ram_wr_data,
      -- ram: rd
      o_mux_squid_offset_ram_rd_en      => mux_squid_offset_ram_rd_en,
      i_mux_squid_offset_ram_rd_valid   => i_mux_squid_offset_ram_rd_valid,
      i_mux_squid_offset_ram_rd_data    => i_mux_squid_offset_ram_rd_data,
      ---------------------------------------------------------------------
      -- errors/status @i_clk
      ---------------------------------------------------------------------
      -- errors
      o_errors5                         => regdecode_pipe_errors5,  -- rd all: output errors
      o_errors4                         => regdecode_pipe_errors4,  -- mux squid offset: output errors
      o_errors3                         => regdecode_pipe_errors3,  -- tes std state: output errors
      o_errors2                         => regdecode_pipe_errors2,  -- mux squid tf: output errors
      o_errors1                         => regdecode_pipe_errors1,  -- amp squid tf: output errors
      o_errors0                         => regdecode_pipe_errors0,  -- tes pulse shape: output errors
      -- status
      o_status5                         => regdecode_pipe_status5,  -- rd all: output status
      o_status4                         => regdecode_pipe_status4,  -- mux squid offset: output status
      o_status3                         => regdecode_pipe_status3,  -- tes std state: output status
      o_status2                         => regdecode_pipe_status2,  -- mux squid tf: output status
      o_status1                         => regdecode_pipe_status1,  -- amp squid tf: output status
      o_status0                         => regdecode_pipe_status0  -- tes pulse shape: output status
      );

  ---------------------------------------------------------------------
  -- output: to the usb
  ---------------------------------------------------------------------
  -- to the usb: pipeout
  usb_pipeout_fifo_data(31 downto 16)       <= pipeout_addr;
  usb_pipeout_fifo_data(15 downto 0)        <= pipeout_data;
  -- resize 
  usb_wireout_fifo_data_count(31 downto 16) <= make_pulse_wr_data_count_tmp0;
  usb_wireout_fifo_data_count(15 downto 0)  <= pipeout_data_count;

  ---------------------------------------------------------------------
  -- output: to the user
  ---------------------------------------------------------------------
  -- tes_pulse_shape
  -- ram: wr
  o_tes_pulse_shape_ram_wr_en      <= tes_pulse_shape_ram_wr_en;
  o_tes_pulse_shape_ram_wr_rd_addr <= tes_pulse_shape_ram_wr_rd_addr;
  o_tes_pulse_shape_ram_wr_data    <= tes_pulse_shape_ram_wr_data;
  -- ram: rd
  o_tes_pulse_shape_ram_rd_en      <= tes_pulse_shape_ram_rd_en;

  -- amp_squid_tf
  -- ram: wr
  o_amp_squid_tf_ram_wr_en      <= amp_squid_tf_ram_wr_en;
  o_amp_squid_tf_ram_wr_rd_addr <= amp_squid_tf_ram_wr_rd_addr;
  o_amp_squid_tf_ram_wr_data    <= amp_squid_tf_ram_wr_data;
  -- ram: rd
  o_amp_squid_tf_ram_rd_en      <= amp_squid_tf_ram_rd_en;

  -- mux_squid_tf
  -- ram: wr
  o_mux_squid_tf_ram_wr_en      <= mux_squid_tf_ram_wr_en;
  o_mux_squid_tf_ram_wr_rd_addr <= mux_squid_tf_ram_wr_rd_addr;
  o_mux_squid_tf_ram_wr_data    <= mux_squid_tf_ram_wr_data;
  -- ram: rd
  o_mux_squid_tf_ram_rd_en      <= mux_squid_tf_ram_rd_en;

  -- tes_std_state
  -- ram: wr
  o_tes_std_state_ram_wr_en      <= tes_std_state_ram_wr_en;
  o_tes_std_state_ram_wr_rd_addr <= tes_std_state_ram_wr_rd_addr;
  o_tes_std_state_ram_wr_data    <= tes_std_state_ram_wr_data;
  -- ram: rd
  o_tes_std_state_ram_rd_en      <= tes_std_state_ram_rd_en;

  -- mux_squid_offset
  -- ram: wr
  o_mux_squid_offset_ram_wr_en      <= mux_squid_offset_ram_wr_en;
  o_mux_squid_offset_ram_wr_rd_addr <= mux_squid_offset_ram_wr_rd_addr;
  o_mux_squid_offset_ram_wr_data    <= mux_squid_offset_ram_wr_data;
  -- ram: rd
  o_mux_squid_offset_ram_rd_en      <= mux_squid_offset_ram_rd_en;

  ---------------------------------------------------------------------
  -- common register
  ---------------------------------------------------------------------
  reg_data_valid_tmp0                             <= trig_reg_valid;
  reg_data_tmp0(c_REG_IDX5_H downto c_REG_IDX5_L) <= usb_wirein_tes_conf;
  reg_data_tmp0(c_REG_IDX4_H downto c_REG_IDX4_L) <= usb_wirein_ra_delay;
  reg_data_tmp0(c_REG_IDX3_H downto c_REG_IDX3_L) <= usb_wirein_error_delay;
  reg_data_tmp0(c_REG_IDX2_H downto c_REG_IDX2_L) <= usb_wirein_amp_sq_of_delay;
  reg_data_tmp0(c_REG_IDX1_H downto c_REG_IDX1_L) <= usb_wirein_mux_sq_fb_delay;
  reg_data_tmp0(c_REG_IDX0_H downto c_REG_IDX0_L) <= usb_wirein_fpasim_gain;
  inst_regdecode_wire_wr_rd_common_register : entity work.regdecode_wire_wr_rd
    generic map(
      g_DATA_WIDTH_OUT => reg_data_tmp0'length  -- define the RAM address width
      )
    port map(
      ---------------------------------------------------------------------
      -- from the regdecode: input @i_clk
      ---------------------------------------------------------------------
      i_clk             => usb_clk,
      i_rst             => i_rst,
      i_rst_status      => usb_rst_status,
      i_debug_pulse     => usb_debug_pulse,
      -- data
      i_data_valid      => reg_data_valid_tmp0,
      i_data            => reg_data_tmp0,
      ---------------------------------------------------------------------
      -- from/to the user:  @i_out_clk
      ---------------------------------------------------------------------
      i_out_clk         => i_out_clk,
      -- ram: wr
      o_data_valid      => reg_data_valid_tmp2,
      o_data            => reg_data_tmp2,
      ---------------------------------------------------------------------
      -- to the regdecode: @i_clk
      ---------------------------------------------------------------------
      i_fifo_rd         => reg_rd_tmp1,
      o_fifo_data_valid => open,
      o_fifo_data       => reg_data_tmp1,
      o_fifo_empty      => reg_empty_tmp1,
      ---------------------------------------------------------------------
      -- errors/status @ i_clk
      ---------------------------------------------------------------------
      o_errors          => reg_errors,
      o_status          => reg_status
      );
  -- to the USB: auto-read the FIFO
  reg_rd_tmp1 <= '1' when reg_empty_tmp1 = '0' else '0';

  -- output: to USB
  ---------------------------------------------------------------------
  usb_wireout_tes_conf        <= reg_data_tmp1(c_REG_IDX5_H downto c_REG_IDX5_L);
  usb_wireout_ra_delay        <= reg_data_tmp1(c_REG_IDX4_H downto c_REG_IDX4_L);
  usb_wireout_error_delay     <= reg_data_tmp1(c_REG_IDX3_H downto c_REG_IDX3_L);
  usb_wireout_amp_sq_of_delay <= reg_data_tmp1(c_REG_IDX2_H downto c_REG_IDX2_L);
  usb_wireout_mux_sq_fb_delay <= reg_data_tmp1(c_REG_IDX1_H downto c_REG_IDX1_L);
  usb_wireout_fpasim_gain     <= reg_data_tmp1(c_REG_IDX0_H downto c_REG_IDX0_L);

  -- output: to the user
  ---------------------------------------------------------------------
  o_reg_valid           <= reg_data_valid_tmp2;
  o_reg_tes_conf        <= reg_data_tmp2(c_REG_IDX5_H downto c_REG_IDX5_L);
  o_reg_ra_delay        <= reg_data_tmp2(c_REG_IDX4_H downto c_REG_IDX4_L);
  o_reg_error_delay     <= reg_data_tmp2(c_REG_IDX3_H downto c_REG_IDX3_L);
  o_reg_amp_sq_of_delay <= reg_data_tmp2(c_REG_IDX2_H downto c_REG_IDX2_L);
  o_reg_mux_sq_fb_delay <= reg_data_tmp2(c_REG_IDX1_H downto c_REG_IDX1_L);
  o_reg_fpasim_gain     <= reg_data_tmp2(c_REG_IDX0_H downto c_REG_IDX0_L);

  ---------------------------------------------------------------------
  -- control register
  ---------------------------------------------------------------------
  ctrl_data_valid_tmp0 <= trig_ctrl_valid;
  ctrl_data_tmp0       <= usb_wirein_ctrl;
  inst_regdecode_wire_wr_rd_ctrl_register : entity work.regdecode_wire_wr_rd
    generic map(
      g_DATA_WIDTH_OUT => ctrl_data_tmp0'length  -- define the RAM address width
      )
    port map(
      ---------------------------------------------------------------------
      -- from the regdecode: input @i_clk
      ---------------------------------------------------------------------
      i_clk             => usb_clk,
      i_rst             => i_rst,
      i_rst_status      => usb_rst_status,
      i_debug_pulse     => usb_debug_pulse,
      -- data
      i_data_valid      => ctrl_data_valid_tmp0,
      i_data            => ctrl_data_tmp0,
      ---------------------------------------------------------------------
      -- from/to the user:  @i_out_clk
      ---------------------------------------------------------------------
      i_out_clk         => i_out_clk,
      -- ram: wr
      o_data_valid      => ctrl_data_valid_tmp2,
      o_data            => ctrl_data_tmp2,
      ---------------------------------------------------------------------
      -- to the regdecode: @i_clk
      ---------------------------------------------------------------------
      i_fifo_rd         => ctrl_rd_tmp1,
      o_fifo_data_valid => open,
      o_fifo_data       => ctrl_data_tmp1,
      o_fifo_empty      => ctrl_empty_tmp1,
      ---------------------------------------------------------------------
      -- errors/status @ i_clk
      ---------------------------------------------------------------------
      o_errors          => ctrl_errors,
      o_status          => ctrl_status
      );
  -- to the USB: auto-read the FIFO
  ctrl_rd_tmp1 <= '1' when ctrl_empty_tmp1 = '0' else '0';

  -- output: to USB
  ---------------------------------------------------------------------
  usb_wireout_ctrl <= ctrl_data_tmp1;

  -- output: to the user
  ---------------------------------------------------------------------
  o_reg_ctrl_valid <= ctrl_data_valid_tmp2;
  o_reg_ctrl       <= ctrl_data_tmp2;

  ---------------------------------------------------------------------
  -- debug control register
  ---------------------------------------------------------------------
  -- extract bits
  usb_rst_status  <= usb_wirein_debug_ctrl(pkg_DEBUG_CTRL_RST_STATUS_IDX_H);
  usb_debug_pulse <= usb_wirein_debug_ctrl(pkg_DEBUG_CTRL_DEBUG_PULSE_IDX_H);

  debug_ctrl_data_valid_tmp0 <= trig_debug_valid;
  debug_ctrl_data_tmp0       <= usb_wirein_debug_ctrl;
  inst_regdecode_wire_wr_rd_debug_ctrl_register : entity work.regdecode_wire_wr_rd
    generic map(
      g_DATA_WIDTH_OUT => debug_ctrl_data_tmp0'length  -- define the RAM address width
      )
    port map(
      ---------------------------------------------------------------------
      -- from the regdecode: input @i_clk
      ---------------------------------------------------------------------
      i_clk             => usb_clk,
      i_rst             => i_rst,
      i_rst_status      => usb_rst_status,
      i_debug_pulse     => usb_debug_pulse,
      -- data
      i_data_valid      => debug_ctrl_data_valid_tmp0,
      i_data            => debug_ctrl_data_tmp0,
      ---------------------------------------------------------------------
      -- from/to the user:  @i_out_clk
      ---------------------------------------------------------------------
      i_out_clk         => i_out_clk,
      -- ram: wr
      o_data_valid      => debug_ctrl_data_valid_tmp2,
      o_data            => debug_ctrl_data_tmp2,
      ---------------------------------------------------------------------
      -- to the regdecode: @i_clk
      ---------------------------------------------------------------------
      i_fifo_rd         => debug_ctrl_rd_tmp1,
      o_fifo_data_valid => open,
      o_fifo_data       => debug_ctrl_data_tmp1,
      o_fifo_empty      => debug_ctrl_empty_tmp1,
      ---------------------------------------------------------------------
      -- errors/status @ i_clk
      ---------------------------------------------------------------------
      o_errors          => debug_ctrl_errors,
      o_status          => debug_ctrl_status
      );
  -- to the USB: auto-read the FIFO
  debug_ctrl_rd_tmp1 <= '1' when debug_ctrl_empty_tmp1 = '0' else '0';

  -- output: to USB
  ---------------------------------------------------------------------
  usb_wireout_debug_ctrl <= debug_ctrl_data_tmp1;

  -- output: to the user
  ---------------------------------------------------------------------
  o_reg_debug_ctrl_valid <= debug_ctrl_data_valid_tmp2;
  o_reg_debug_ctrl       <= debug_ctrl_data_tmp2;

  ---------------------------------------------------------------------
  -- make pulse register
  ---------------------------------------------------------------------
  make_pulse_data_valid_tmp0 <= trig_make_pulse_valid;
  make_pulse_data_tmp0       <= usb_wirein_make_pulse;
  pixel_nb                   <= usb_wirein_tes_conf(c_TES_CONF_PIXEL_NB_IDX_H downto c_TES_CONF_PIXEL_NB_IDX_L);  -- @suppress "Incorrect array size in assignment: expected (<pkg_TES_CONF_PIXEL_NB_WIDTH>) but was (<6>)"

  inst_regdecode_wire_make_pulse : entity work.regdecode_wire_make_pulse
    generic map(
      g_DATA_WIDTH_OUT => make_pulse_data_tmp0'length,  -- define the RAM address width
      g_PIXEL_NB_WIDTH => pixel_nb'length
      )
    port map(  -- @suppress "The order of the associations is different from the declaration order"
      ---------------------------------------------------------------------
      -- from the regdecode: input @i_clk
      ---------------------------------------------------------------------
      i_clk              => usb_clk,
      i_rst              => i_rst,
      i_rst_status       => usb_rst_status,
      i_debug_pulse      => usb_debug_pulse,
      -- conf
      i_pixel_nb         => pixel_nb,
      -- data
      i_make_pulse_valid => make_pulse_data_valid_tmp0,
      i_make_pulse       => make_pulse_data_tmp0,
      o_wr_data_count    => make_pulse_wr_data_count_tmp0,
      ---------------------------------------------------------------------
      -- from/to the user:  @i_out_clk
      ---------------------------------------------------------------------
      i_out_clk          => i_out_clk,
      -- ram: wr
      i_data_rd          => make_pulse_rd_tmp2,
      o_sof              => make_pulse_sof_tmp2,
      o_eof              => make_pulse_eof_tmp2,
      o_data_valid       => make_pulse_data_valid_tmp2,
      o_data             => make_pulse_data_tmp2,
      o_empty            => make_pulse_empty_tmp2,
      ---------------------------------------------------------------------
      -- to the regdecode: @i_clk
      ---------------------------------------------------------------------
      i_fifo_rd          => make_pulse_rd_tmp1,
      o_fifo_data_valid  => open,
      o_fifo_sof         => open,
      o_fifo_eof         => open,
      o_fifo_data        => make_pulse_data_tmp1,
      o_fifo_empty       => make_pulse_empty_tmp1,
      ---------------------------------------------------------------------
      -- errors/status @ i_clk
      ---------------------------------------------------------------------
      o_errors           => make_pulse_errors,
      o_status           => make_pulse_status
      );
  -- to the USB: auto-read the FIFO
  make_pulse_rd_tmp1 <= '1' when make_pulse_empty_tmp1 = '0' else '0';

  -- to the user: auto read the fifo if the upstream fifo is empty and if the downstream fifo is ready
  make_pulse_rd_tmp2 <= '1' when ((make_pulse_empty_tmp2 = '0') and (i_reg_make_pulse_ready = '1')) else '0';

  -- output: to USB
  ---------------------------------------------------------------------
  usb_wireout_make_pulse <= make_pulse_data_tmp1;

  -- output: to the user
  ---------------------------------------------------------------------
  o_reg_make_sof         <= make_pulse_sof_tmp2;
  o_reg_make_eof         <= make_pulse_eof_tmp2;
  o_reg_make_pulse_valid <= make_pulse_data_valid_tmp2;
  o_reg_make_pulse       <= make_pulse_data_tmp2;

  ---------------------------------------------------------------------
  -- recording register
  ---------------------------------------------------------------------
  rec_valid_tmp0 <= trig_rec_valid;
  rec_ctrl_tmp0  <= usb_wirein_rec_ctrl;
  rec_conf0_tmp0 <= usb_wirein_rec_conf0;

  regdecode_recording_INST : entity work.regdecode_recording
    generic map(
      g_DATA_WIDTH => i_reg_fifo_rec_adc_data'length
      )
    port map(
      ---------------------------------------------------------------------
      -- from the regdecode/usb: input @i_clk
      ---------------------------------------------------------------------
      i_clk                        => usb_clk,         -- clock
      i_rst                        => i_rst,           -- reset
      i_rst_status                 => usb_rst_status,  -- not connected  
      i_debug_pulse                => usb_debug_pulse,     -- not connected  
      -- data
      i_rec_valid                  => rec_valid_tmp0,  -- register data valid
      i_rec_ctrl                   => rec_ctrl_tmp0,   -- register ctrl value
      i_rec_conf0                  => rec_conf0_tmp0,  -- register conf0 value
      ---------------------------------------------------------------------
      -- from/to the user:  @i_out_clk
      ---------------------------------------------------------------------
      i_out_rst                    => i_out_rst,
      i_out_clk                    => i_out_clk,
      -- register
      o_rec_valid                  => rec_valid_tmp2,
      o_rec_ctrl                   => rec_ctrl_tmp2,
      o_rec_conf0                  => rec_conf0_tmp2,
      -- data
      o_fifo_adc_rd                => reg_fifo_rec_adc_rd,
      i_fifo_adc_sof               => i_reg_fifo_rec_adc_sof,
      i_fifo_adc_eof               => i_reg_fifo_rec_adc_eof,
      i_fifo_adc_data_valid        => i_reg_fifo_rec_adc_data_valid,
      i_fifo_adc_data              => i_reg_fifo_rec_adc_data,
      i_fifo_adc_empty             => i_reg_fifo_rec_adc_empty,
      ---------------------------------------------------------------------
      -- to the regdecode/usb: @i_clk
      ---------------------------------------------------------------------
      -- register
      o_usb_rec_valid              => usb_rec_valid,   -- not connected  
      o_usb_rec_ctrl               => usb_rec_ctrl,
      o_usb_rec_conf0              => usb_rec_conf0,
      -- data
      i_usb_fifo_adc_rd            => usb_fifo_adc_rd,     -- not connected  
      o_usb_fifo_adc_sof           => usb_fifo_adc_sof,    -- not connected  
      o_usb_fifo_adc_eof           => usb_fifo_adc_eof,    -- not connected  
      o_usb_fifo_adc_data_valid    => usb_fifo_adc_data_valid,  -- not connected  
      o_usb_fifo_adc_data          => usb_fifo_adc_data,
      o_usb_fifo_adc_empty         => usb_fifo_adc_empty,  -- not connected  
      o_usb_fifo_adc_wr_data_count => usb_fifo_adc_wr_data_count,
      ---------------------------------------------------------------------
      -- usb_errors/usb_status @ i_out_clk
      ---------------------------------------------------------------------
      o_errors1                    => rec_errors1,
      o_errors0                    => rec_errors0,
      o_status1                    => rec_status1,
      o_status0                    => rec_status0
      );
-- output: to USB
  ---------------------------------------------------------------------
  -- register
  usb_wireout_rec_ctrl                          <= usb_rec_ctrl;
  usb_wireout_rec_conf0                         <= usb_rec_conf0;
  usb_wireout_rec_fifo_data_count(31 downto 16) <= (others => '0');
  usb_wireout_rec_fifo_data_count(15 downto 0)  <= usb_fifo_adc_wr_data_count;
  -- fifo data
  usb_fifo_adc_rd                               <= usb_pipeout_rec_fifo_adc_rd;
  usb_pipeout_rec_fifo_adc_data                 <= usb_fifo_adc_data;


-- output: to the user
---------------------------------------------------------------------
-- register
  o_reg_rec_valid       <= rec_valid_tmp2;
  o_reg_rec_ctrl        <= rec_ctrl_tmp2;
  o_reg_rec_conf0       <= rec_conf0_tmp2;
-- fifo: data
  o_reg_fifo_rec_adc_rd <= reg_fifo_rec_adc_rd;


  ---------------------------------------------------------------------
  -- regdecode errors/status
  ---------------------------------------------------------------------
  -- errors
  regdecode_errors6(31 downto 16) <= (others => '0');  
  regdecode_errors6(15 downto 0)  <= i_spi_errors;  -- spi register: output errors
  
  regdecode_errors5(31 downto 16) <= rec_errors1;  -- rec_conf0 register: output errors
  regdecode_errors5(15 downto 0)  <= rec_errors0;  -- rec_ctrl/rec_conf0 register: output errors

  regdecode_errors4(31 downto 16) <= make_pulse_errors;  -- make_pulse register: output errors
  regdecode_errors4(15 downto 0)  <= debug_ctrl_errors;  -- debug_ctrl register: output errors

  regdecode_errors3(31 downto 16) <= ctrl_errors;  -- ctrl register: output errors
  regdecode_errors3(15 downto 0)  <= reg_errors;  -- common register: output errors

  regdecode_errors2(31 downto 16) <= regdecode_pipe_errors5;  -- rd all: output errors
  regdecode_errors2(15 downto 0)  <= regdecode_pipe_errors4;  -- mux squid offset: output errors

  regdecode_errors1(31 downto 16) <= regdecode_pipe_errors3;  -- tes std state: output errors
  regdecode_errors1(15 downto 0)  <= regdecode_pipe_errors2;  -- mux squid tf: output errors

  regdecode_errors0(31 downto 16) <= regdecode_pipe_errors1;  -- amp squid tf: output errors
  regdecode_errors0(15 downto 0)  <= regdecode_pipe_errors0;  -- tes pulse shape: output errors

  -- status
  regdecode_status6(31 downto 24) <= (others => '0');
  regdecode_status6(23 downto 16) <= (others => '0');  
  regdecode_status6(15 downto 8)  <= (others => '0');
  regdecode_status6(7 downto 0)   <= i_spi_status;  -- spi register: output status

  regdecode_status5(31 downto 24) <= (others => '0');
  regdecode_status5(23 downto 16) <= rec_status1;  -- rec_ctrl register: output status
  regdecode_status5(15 downto 8)  <= (others => '0');
  regdecode_status5(7 downto 0)   <= rec_status0;  -- rec_ctrl/rec_conf0 register: output status

  regdecode_status4(31 downto 24) <= (others => '0');
  regdecode_status4(23 downto 16) <= make_pulse_status;  -- make_pulse register: output status
  regdecode_status4(15 downto 8)  <= (others => '0');
  regdecode_status4(7 downto 0)   <= debug_ctrl_status;  -- debug_ctrl register: output status

  regdecode_status3(31 downto 24) <= (others => '0');
  regdecode_status3(23 downto 16) <= ctrl_status;  -- ctrl register: output status
  regdecode_status3(15 downto 8)  <= (others => '0');
  regdecode_status3(7 downto 0)   <= reg_status;  -- common register: output status


  regdecode_status2(31 downto 24) <= (others => '0');
  regdecode_status2(23 downto 16) <= regdecode_pipe_status5;  -- rd all: output status
  regdecode_status2(15 downto 8)  <= (others => '0');
  regdecode_status2(7 downto 0)   <= regdecode_pipe_status4;  -- mux squid offset: output status

  regdecode_status1(31 downto 24) <= (others => '0');
  regdecode_status1(23 downto 16) <= regdecode_pipe_status3;  -- tes std state: output status
  regdecode_status1(15 downto 8)  <= (others => '0');
  regdecode_status1(7 downto 0)   <= regdecode_pipe_status2;  -- mux squid tf: output status

  regdecode_status0(31 downto 24) <= (others => '0');
  regdecode_status0(23 downto 16) <= regdecode_pipe_status1;  -- amp squid tf: output status
  regdecode_status0(15 downto 8)  <= (others => '0');
  regdecode_status0(7 downto 0)   <= regdecode_pipe_status0;  -- tes pulse shape: output status

  ---------------------------------------------------------------------
  -- errors register
  ---------------------------------------------------------------------
  error_sel <= usb_wirein_sel_errors(c_ERROR_SEL_IDX_H downto c_ERROR_SEL_IDX_L);  -- @suppress "Incorrect array size in assignment: expected (<pkg_ERROR_SEL_WIDTH>) but was (<3>)"
  inst_regdecode_wire_errors : entity work.regdecode_wire_errors
    generic map(
      g_ERROR_SEL_WIDTH => error_sel'length
      )
    port map(
      ---------------------------------------------------------------------
      -- input @i_out_clk
      ---------------------------------------------------------------------
      i_out_clk          => i_out_clk,
      -- errors
      i_reg_wire_errors3 => i_reg_wire_errors3,
      i_reg_wire_errors2 => i_reg_wire_errors2,
      i_reg_wire_errors1 => i_reg_wire_errors1,
      i_reg_wire_errors0 => i_reg_wire_errors0,
      -- status
      i_reg_wire_status3 => i_reg_wire_status3,
      i_reg_wire_status2 => i_reg_wire_status2,
      i_reg_wire_status1 => i_reg_wire_status1,
      i_reg_wire_status0 => i_reg_wire_status0,

      ---------------------------------------------------------------------
      -- input @i_clk
      ---------------------------------------------------------------------
      i_clk       => usb_clk,
      i_error_sel => error_sel,

      -- errors
      i_usb_reg_errors6 => regdecode_errors6,
      i_usb_reg_errors5 => regdecode_errors5,
      i_usb_reg_errors4 => regdecode_errors4,
      i_usb_reg_errors3 => regdecode_errors3,
      i_usb_reg_errors2 => regdecode_errors2,
      i_usb_reg_errors1 => regdecode_errors1,
      i_usb_reg_errors0 => regdecode_errors0,

      -- status
      i_usb_reg_status6 => regdecode_status6,
      i_usb_reg_status5 => regdecode_status5,
      i_usb_reg_status4 => regdecode_status4,
      i_usb_reg_status3 => regdecode_status3,
      i_usb_reg_status2 => regdecode_status2,
      i_usb_reg_status1 => regdecode_status1,
      i_usb_reg_status0 => regdecode_status0,

      ---------------------------------------------------------------------
      -- output @i_clk
      ---------------------------------------------------------------------
      o_wire_errors_valid => wire_errors_valid,
      o_wire_errors       => wire_errors,
      o_wire_status       => wire_status
      );

  -- output: to usb 
  ---------------------------------------------------------------------
  usb_wireout_sel_errors <= usb_wirein_sel_errors;
  usb_wireout_errors     <= wire_errors;
  usb_wireout_status     <= wire_status;

  usb_trigout_data(31 downto 29) <= (others => '0');
  usb_trigout_data(28)           <= wire_errors_valid;
  usb_trigout_data(27 downto 1) <= (others => '0');
  usb_trigout_data(0)           <= i_reg_spi_rd_data_valid;



  ---------------------------------------------------------------------
  -- debug
  ---------------------------------------------------------------------
  gen_debug_ila : if g_DEBUG = true generate  -- @suppress "Redundant boolean equality check with true"
    -- inst_fpasim_regdecode_top_ila_0 : entity work.fpasim_regdecode_top_ila_0
    --   port map(
    --     clk                  => usb_clk,
    --     -- probe0
    --     probe0(4)            => trig_debug_valid,
    --     probe0(3)            => trig_ctrl_valid,
    --     probe0(2)            => trig_rd_all_valid,
    --     probe0(1)            => trig_make_pulse_valid,
    --     probe0(0)            => trig_reg_valid,
    --     -- probe1
    --     probe1(5)            => i_usb_pipeout_fifo_rd,
    --     probe1(4)            => pipeout_sof,
    --     probe1(3)            => pipeout_eof,
    --     probe1(2)            => pipeout_valid,
    --     probe1(1)            => pipeout_empty,
    --     probe1(0)            => pipein_valid0,
    --     -- probe2
    --     probe2(31 downto 16) => pipein_addr0,
    --     probe2(15 downto 0)  => pipein_data0,
    --     -- probe3
    --     probe3(31 downto 16) => pipeout_addr,
    --     probe3(15 downto 0)  => pipeout_data
    --   );

  end generate gen_debug_ila;

end architecture RTL;
