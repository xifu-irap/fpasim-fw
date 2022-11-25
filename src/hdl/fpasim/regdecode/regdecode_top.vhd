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

library fpasim;
use fpasim.pkg_regdecode.all;

entity regdecode_top is
  generic(
    g_DEBUG : boolean := false
  );
  port(
    ---------------------------------------------------------------------
    -- from the usb @i_clk
    ---------------------------------------------------------------------
    i_clk                             : in  std_logic; -- clock
    i_rst                             : in  std_logic; -- reset
    -- trig
    i_usb_pipein_fifo_valid           : in  std_logic; -- pipe in data valid
    i_usb_pipein_fifo                 : in  std_logic_vector(31 downto 0); -- pipe in data
    -- trig
    i_usb_trigin_data                 : in  std_logic_vector(31 downto 0); -- trigin value
    -- wire
    i_usb_wirein_ctrl                 : in  std_logic_vector(31 downto 0); -- wirein ctrl value
    i_usb_wirein_make_pulse           : in  std_logic_vector(31 downto 0); -- wirein make_pulse value
    i_usb_wirein_fpasim_gain          : in  std_logic_vector(31 downto 0); -- wirein fpasim_gain value
    i_usb_wirein_mux_sq_fb_delay      : in  std_logic_vector(31 downto 0); -- wirein mux_sq_fb_delay value
    i_usb_wirein_amp_sq_of_delay      : in  std_logic_vector(31 downto 0); -- wirein amp_sq_of_delay value
    i_usb_wirein_error_delay          : in  std_logic_vector(31 downto 0); -- wirein error_delay value
    i_usb_wirein_ra_delay             : in  std_logic_vector(31 downto 0); -- wirein ra_delay value
    i_usb_wirein_tes_conf             : in  std_logic_vector(31 downto 0); -- wirein tes_conf value
    i_usb_wirein_debug_ctrl           : in  std_logic_vector(31 downto 0); -- wirein debug_ctrl value
    i_usb_wirein_sel_errors           : in  std_logic_vector(31 downto 0); -- wirein select errors/status
    ---------------------------------------------------------------------
    -- to the usb @o_usb_clk
    ---------------------------------------------------------------------
    -- pipe
    i_usb_pipeout_fifo_rd             : in  std_logic; -- pipe out fifo rd
    o_usb_pipeout_fifo_data           : out std_logic_vector(31 downto 0); -- pipe out data
    -- trig
    o_usb_trigout_data                : out std_logic_vector(31 downto 0); -- trig out value
    -- wire
    o_usb_wireout_fifo_data_count     : out std_logic_vector(31 downto 0); -- wire out fifo data count (necessary for the pipe out)
    o_usb_wireout_ctrl                : out std_logic_vector(31 downto 0); -- wire out ctrl value
    o_usb_wireout_make_pulse          : out std_logic_vector(31 downto 0); -- wire out make_pulse value
    o_usb_wireout_fpasim_gain         : out std_logic_vector(31 downto 0); -- wire out fpasim_gain value
    o_usb_wireout_mux_sq_fb_delay     : out std_logic_vector(31 downto 0); -- wire out mux_sq_fb_delay value
    o_usb_wireout_amp_sq_of_delay     : out std_logic_vector(31 downto 0); -- wire out amp_sq_of_delay value
    o_usb_wireout_error_delay         : out std_logic_vector(31 downto 0); -- wire out error_delay value
    o_usb_wireout_ra_delay            : out std_logic_vector(31 downto 0); -- wire out ra_delay value
    o_usb_wireout_tes_conf            : out std_logic_vector(31 downto 0); -- wire out tes_conf value
    o_usb_wireout_debug_ctrl          : out std_logic_vector(31 downto 0); -- wire out debug_ctrl value

    o_usb_wireout_fpga_id             : out std_logic_vector(31 downto 0); -- wire out fpga id
    o_usb_wireout_fpga_version        : out std_logic_vector(31 downto 0); -- wire out fpga version

    o_usb_wireout_sel_errors          : out std_logic_vector(31 downto 0); -- wire out select errors
    o_usb_wireout_errors              : out std_logic_vector(31 downto 0); -- wire out errors
    o_usb_wireout_status              : out std_logic_vector(31 downto 0); -- wire out status
    ---------------------------------------------------------------------
    -- from/to the user: @i_out_clk
    ---------------------------------------------------------------------

    i_out_clk                         : in  std_logic; -- clock (user side)
    i_rst_status                      : in  std_logic; -- reset error flag(s)
    i_debug_pulse                     : in  std_logic; -- error mode (transparent vs capture). Possib

    -- RAM configuration 
    ---------------------------------------------------------------------
    -- tes_pulse_shape
    -- ram: wr
    o_tes_pulse_shape_ram_wr_en       : out std_logic; -- output write enable
    o_tes_pulse_shape_ram_wr_rd_addr  : out std_logic_vector(15 downto 0); -- output address (shared by the writting and the reading)
    o_tes_pulse_shape_ram_wr_data     : out std_logic_vector(15 downto 0); -- output data
    -- ram: rd
    o_tes_pulse_shape_ram_rd_en       : out std_logic; -- output read enable
    i_tes_pulse_shape_ram_rd_valid    : in  std_logic; -- input read valid
    i_tes_pulse_shape_ram_rd_data     : in  std_logic_vector(15 downto 0); -- input read data

    -- amp_squid_tf
    -- ram: wr
    o_amp_squid_tf_ram_wr_en          : out std_logic; -- output write enable
    o_amp_squid_tf_ram_wr_rd_addr     : out std_logic_vector(15 downto 0); -- output address (shared by the writting and the reading)
    o_amp_squid_tf_ram_wr_data        : out std_logic_vector(15 downto 0); -- output data
    -- ram: rd
    o_amp_squid_tf_ram_rd_en          : out std_logic; -- output read enable
    i_amp_squid_tf_ram_rd_valid       : in  std_logic; -- input read valid
    i_amp_squid_tf_ram_rd_data        : in  std_logic_vector(15 downto 0); -- input read data
    -- mux_squid_tf
    -- ram: wr
    o_mux_squid_tf_ram_wr_en          : out std_logic; -- output write enable
    o_mux_squid_tf_ram_wr_rd_addr     : out std_logic_vector(15 downto 0); -- output address (shared by the writting and the reading)
    o_mux_squid_tf_ram_wr_data        : out std_logic_vector(15 downto 0); -- output data
    -- ram: rd
    o_mux_squid_tf_ram_rd_en          : out std_logic; -- output read enable
    i_mux_squid_tf_ram_rd_valid       : in  std_logic; -- input read valid
    i_mux_squid_tf_ram_rd_data        : in  std_logic_vector(15 downto 0); -- input read data
    -- tes_std_state
    -- ram: wr
    o_tes_std_state_ram_wr_en         : out std_logic; -- output write enable
    o_tes_std_state_ram_wr_rd_addr    : out std_logic_vector(15 downto 0); -- output address (shared by the writting and the reading)
    o_tes_std_state_ram_wr_data       : out std_logic_vector(15 downto 0); -- output data
    -- ram: rd
    o_tes_std_state_ram_rd_en         : out std_logic; -- output read enable
    i_tes_std_state_ram_rd_valid      : in  std_logic; -- input read valid
    i_tes_std_state_ram_rd_data       : in  std_logic_vector(15 downto 0); -- input read data
    -- mux_squid_offset
    -- ram: wr
    o_mux_squid_offset_ram_wr_en      : out std_logic; -- output write enable
    o_mux_squid_offset_ram_wr_rd_addr : out std_logic_vector(15 downto 0); -- output address (shared by the writting and the reading)
    o_mux_squid_offset_ram_wr_data    : out std_logic_vector(15 downto 0); -- output data
    -- ram: rd
    o_mux_squid_offset_ram_rd_en      : out std_logic; -- output read enable
    i_mux_squid_offset_ram_rd_valid   : in  std_logic; -- input read valid
    i_mux_squid_offset_ram_rd_data    : in  std_logic_vector(15 downto 0); -- input read data
    -- Register configuration
    ---------------------------------------------------------------------
    -- common register
    o_reg_valid                       : out std_logic; -- register valid
    o_reg_fpasim_gain                 : out std_logic_vector(31 downto 0); -- register fpasim_gain value
    o_reg_mux_sq_fb_delay             : out std_logic_vector(31 downto 0); -- register mux_sq_fb_delay value
    o_reg_amp_sq_of_delay             : out std_logic_vector(31 downto 0); -- register amp_sq_of_delay value
    o_reg_error_delay                 : out std_logic_vector(31 downto 0); -- register error_delay value
    o_reg_ra_delay                    : out std_logic_vector(31 downto 0); -- register ra_delay value
    o_reg_tes_conf                    : out std_logic_vector(31 downto 0); -- register tes_conf value
    -- ctrl register
    o_reg_ctrl_valid                  : out std_logic; -- register ctrl valid
    o_reg_ctrl                        : out std_logic_vector(31 downto 0); -- register ctrl value
    -- debug ctrl register
    o_reg_debug_ctrl_valid            : out std_logic; -- register debug_ctrl valid
    o_reg_debug_ctrl                  : out std_logic_vector(31 downto 0); -- register debug_ctrl value
    -- make pulse register
    i_reg_make_pulse_ready            : in  std_logic;
    o_reg_make_sof                    : out std_logic; -- first sample
    o_reg_make_eof                    : out std_logic; -- last sample
    o_reg_make_pulse_valid            : out std_logic; -- register make_pulse valid
    o_reg_make_pulse                  : out std_logic_vector(31 downto 0); -- register make_pulse value
    -- to the usb 
    ---------------------------------------------------------------------
    -- errors
    i_reg_wire_errors7                : in  std_logic_vector(31 downto 0); -- errors7 register
    i_reg_wire_errors6                : in  std_logic_vector(31 downto 0); -- errors6 register
    i_reg_wire_errors5                : in  std_logic_vector(31 downto 0); -- errors5 register
    i_reg_wire_errors4                : in  std_logic_vector(31 downto 0); -- errors4 register
    i_reg_wire_errors3                : in  std_logic_vector(31 downto 0); -- errors3 register
    i_reg_wire_errors2                : in  std_logic_vector(31 downto 0); -- errors2 register
    i_reg_wire_errors1                : in  std_logic_vector(31 downto 0); -- errors1 register
    i_reg_wire_errors0                : in  std_logic_vector(31 downto 0); -- errors0 register
    -- status
    i_reg_wire_status7                : in  std_logic_vector(31 downto 0); -- status7 register
    i_reg_wire_status6                : in  std_logic_vector(31 downto 0); -- status6 register
    i_reg_wire_status5                : in  std_logic_vector(31 downto 0); -- status5 register
    i_reg_wire_status4                : in  std_logic_vector(31 downto 0); -- status4 register
    i_reg_wire_status3                : in  std_logic_vector(31 downto 0); -- status3 register
    i_reg_wire_status2                : in  std_logic_vector(31 downto 0); -- status2 register
    i_reg_wire_status1                : in  std_logic_vector(31 downto 0); -- status1 register
    i_reg_wire_status0                : in  std_logic_vector(31 downto 0); -- status0 register
    -- to the user: errors/status
    ---------------------------------------------------------------------
    -- pipe errors
    o_pipe_errors5                    : out std_logic_vector(15 downto 0); -- rd all: output errors
    o_pipe_errors4                    : out std_logic_vector(15 downto 0); -- mux squid offset: output errors
    o_pipe_errors3                    : out std_logic_vector(15 downto 0); -- tes std state: output errors
    o_pipe_errors2                    : out std_logic_vector(15 downto 0); -- mux squid tf: output errors
    o_pipe_errors1                    : out std_logic_vector(15 downto 0); -- amp squid tf: output errors
    o_pipe_errors0                    : out std_logic_vector(15 downto 0); -- tes pulse shape: output errors

    -- pipe status
    o_pipe_status5                    : out std_logic_vector(7 downto 0); -- rd all: output status
    o_pipe_status4                    : out std_logic_vector(7 downto 0); -- mux squid offset: output status
    o_pipe_status3                    : out std_logic_vector(7 downto 0); -- tes std state: output status
    o_pipe_status2                    : out std_logic_vector(7 downto 0); -- mux squid tf: output status
    o_pipe_status1                    : out std_logic_vector(7 downto 0); -- amp squid tf: output status
    o_pipe_status0                    : out std_logic_vector(7 downto 0); -- tes pulse shape: output status

    -- reg errors/status
    o_reg_errors0                     : out std_logic_vector(15 downto 0); -- common register errors
    o_reg_status0                     : out std_logic_vector(7 downto 0); -- common register status

    -- ctrl errors/status
    o_ctrl_errors0                    : out std_logic_vector(15 downto 0); -- register ctrl errors
    o_ctrl_status0                    : out std_logic_vector(7 downto 0); -- register ctrl status

    -- debug_ctrl errors/status
    o_debug_ctrl_errors0              : out std_logic_vector(15 downto 0); -- register debug_ctrl errors
    o_debug_ctrl_status0              : out std_logic_vector(7 downto 0); -- register debug_ctrl status

    -- make_pulse errors/status
    o_make_pulse_errors0              : out std_logic_vector(15 downto 0); -- register make_pulse errors
    o_make_pulse_status0              : out std_logic_vector(7 downto 0) -- register make_pulse status
  );
end entity regdecode_top;

architecture RTL of regdecode_top is
  -- debug valid
  constant c_TRIGIN_DEBUG_VALID_IDX_H : integer := pkg_TRIGIN_DEBUG_VALID_IDX_H;

  -- ctrl valid
  constant c_TRIGIN_CTRL_VALID_IDX_H : integer := pkg_TRIGIN_CTRL_VALID_IDX_H;

  -- read all
  constant c_TRIGIN_READ_ALL_VALID_IDX_H : integer := pkg_TRIGIN_READ_ALL_VALID_IDX_H;

  -- make pulse valid
  constant c_TRIGIN_MAKE_PULSE_VALID_IDX_H : integer := pkg_TRIGIN_MAKE_PULSE_VALID_IDX_H;

  -- reg valid
  constant c_TRIGIN_REG_VALID_IDX_H : integer := pkg_TRIGIN_REG_VALID_IDX_H;

  -- fpga id
  constant c_FPGA_ID      : std_logic_vector(31 downto 0) := pkg_FPGA_ID;
  -- fpga version
  constant c_FPGA_VERSION : std_logic_vector(31 downto 0) := pkg_FPGA_VERSION;

  constant c_TES_CONF_PIXEL_NB_IDX_H : integer := pkg_TES_CONF_NB_PIXEL_BY_FRAME_IDX_H;
  constant c_TES_CONF_PIXEL_NB_IDX_L : integer := pkg_TES_CONF_NB_PIXEL_BY_FRAME_IDX_L;
  constant c_TES_CONF_PIXEL_NB_WIDTH : integer := pkg_TES_CONF_NB_PIXEL_BY_FRAME_WIDTH;

  constant c_ERROR_SEL_IDX_H : integer := pkg_ERROR_SEL_IDX_H;
  constant c_ERROR_SEL_IDX_L : integer := pkg_ERROR_SEL_IDX_L;
  constant c_ERROR_SEL_WIDTH : integer := pkg_ERROR_SEL_WIDTH;

  ---------------------------------------------------------------------
  -- regdecode_pipe
  ---------------------------------------------------------------------
  signal trig_reg_valid        : std_logic;
  signal trig_make_pulse_valid : std_logic;
  signal trig_rd_all_valid     : std_logic;
  signal trig_ctrl_valid       : std_logic;
  signal trig_debug_valid      : std_logic;

  signal pipein_valid0 : std_logic;
  signal pipein_addr0  : std_logic_vector(15 downto 0);
  signal pipein_data0  : std_logic_vector(15 downto 0);

  signal pipeout_rd         : std_logic;
  signal pipeout_sof        : std_logic; -- @suppress "signal pipeout_sof is never read"
  signal pipeout_eof        : std_logic; -- @suppress "signal pipeout_eof is never read"
  signal pipeout_valid      : std_logic; -- @suppress "signal pipeout_valid is never read"
  signal pipeout_addr       : std_logic_vector(15 downto 0);
  signal pipeout_data       : std_logic_vector(15 downto 0);
  signal pipeout_empty      : std_logic; -- @suppress "signal pipeout_empty is never read"
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
  constant c_REG_IDX0_H : integer := c_REG_IDX0_L + i_usb_wirein_fpasim_gain'length - 1;

  constant c_REG_IDX1_L : integer := c_REG_IDX0_H + 1;
  constant c_REG_IDX1_H : integer := c_REG_IDX1_L + i_usb_wirein_mux_sq_fb_delay'length - 1;

  constant c_REG_IDX2_L : integer := c_REG_IDX1_H + 1;
  constant c_REG_IDX2_H : integer := c_REG_IDX2_L + i_usb_wirein_amp_sq_of_delay'length - 1;

  constant c_REG_IDX3_L : integer := c_REG_IDX2_H + 1;
  constant c_REG_IDX3_H : integer := c_REG_IDX3_L + i_usb_wirein_error_delay'length - 1;

  constant c_REG_IDX4_L : integer := c_REG_IDX3_H + 1;
  constant c_REG_IDX4_H : integer := c_REG_IDX4_L + i_usb_wirein_ra_delay'length - 1;

  constant c_REG_IDX5_L : integer := c_REG_IDX4_H + 1;
  constant c_REG_IDX5_H : integer := c_REG_IDX5_L + i_usb_wirein_tes_conf'length - 1;

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
  signal ctrl_data_tmp0       : std_logic_vector(i_usb_wirein_ctrl'range);

  signal ctrl_rd_tmp1    : std_logic;
  -- signal ctrl_data_valid_tmp1 : std_logic;
  signal ctrl_data_tmp1  : std_logic_vector(i_usb_wirein_ctrl'range);
  signal ctrl_empty_tmp1 : std_logic;

  signal ctrl_data_valid_tmp2 : std_logic;
  signal ctrl_data_tmp2       : std_logic_vector(i_usb_wirein_ctrl'range);

  signal ctrl_errors : std_logic_vector(15 downto 0);
  signal ctrl_status : std_logic_vector(7 downto 0);

  ---------------------------------------------------------------------
  -- wire: debug control register
  ---------------------------------------------------------------------
  signal debug_ctrl_data_valid_tmp0 : std_logic;
  signal debug_ctrl_data_tmp0       : std_logic_vector(i_usb_wirein_debug_ctrl'range);

  signal debug_ctrl_rd_tmp1    : std_logic;
  -- signal debug_ctrl_data_valid_tmp1 : std_logic;
  signal debug_ctrl_data_tmp1  : std_logic_vector(i_usb_wirein_debug_ctrl'range);
  signal debug_ctrl_empty_tmp1 : std_logic;

  signal debug_ctrl_data_valid_tmp2 : std_logic;
  signal debug_ctrl_data_tmp2       : std_logic_vector(i_usb_wirein_debug_ctrl'range);

  signal debug_ctrl_errors : std_logic_vector(15 downto 0);
  signal debug_ctrl_status : std_logic_vector(7 downto 0);

  ---------------------------------------------------------------------
  -- wire: make pulse register
  ---------------------------------------------------------------------
  signal pixel_nb                      : std_logic_vector(c_TES_CONF_PIXEL_NB_WIDTH - 1 downto 0);
  signal make_pulse_data_valid_tmp0    : std_logic;
  signal make_pulse_data_tmp0          : std_logic_vector(i_usb_wirein_make_pulse'range);
  signal make_pulse_wr_data_count_tmp0 : std_logic_vector(15 downto 0);

  signal make_pulse_rd_tmp1    : std_logic;
  --signal make_pulse_data_valid_tmp1  : std_logic;
  --signal make_pulse_sof_tmp1  : std_logic;
  --signal make_pulse_eof_tmp1  : std_logic;
  signal make_pulse_data_tmp1  : std_logic_vector(i_usb_wirein_make_pulse'range);
  signal make_pulse_empty_tmp1 : std_logic;

  signal make_pulse_rd_tmp2         : std_logic;
  signal make_pulse_sof_tmp2        : std_logic;
  signal make_pulse_eof_tmp2        : std_logic;
  signal make_pulse_data_valid_tmp2 : std_logic;
  signal make_pulse_data_tmp2       : std_logic_vector(i_usb_wirein_make_pulse'range);
  signal make_pulse_empty_tmp2      : std_logic;

  signal make_pulse_errors : std_logic_vector(15 downto 0);
  signal make_pulse_status : std_logic_vector(7 downto 0);

  ---------------------------------------------------------------------
  -- wire: errors registers
  ---------------------------------------------------------------------
  signal error_sel : std_logic_vector(c_ERROR_SEL_WIDTH - 1 downto 0);

  signal wire_errors_valid : std_logic;
  signal wire_errors       : std_logic_vector(i_reg_wire_errors0'range);
  signal wire_status       : std_logic_vector(i_reg_wire_status0'range);

begin
  ---------------------------------------------------------------------
  -- get the fpga id
  ---------------------------------------------------------------------
  o_usb_wireout_fpga_id      <= c_FPGA_ID;
  o_usb_wireout_fpga_version <= c_FPGA_VERSION;

  -- from trigin: extract bits signal
  trig_debug_valid      <= i_usb_trigin_data(c_TRIGIN_DEBUG_VALID_IDX_H);
  trig_ctrl_valid       <= i_usb_trigin_data(c_TRIGIN_CTRL_VALID_IDX_H);
  trig_rd_all_valid     <= i_usb_trigin_data(c_TRIGIN_READ_ALL_VALID_IDX_H);
  trig_make_pulse_valid <= i_usb_trigin_data(c_TRIGIN_MAKE_PULSE_VALID_IDX_H);
  trig_reg_valid        <= i_usb_trigin_data(c_TRIGIN_REG_VALID_IDX_H);

  ---------------------------------------------------------------------
  -- pipe management
  ---------------------------------------------------------------------
  pipein_valid0 <= i_usb_pipein_fifo_valid;
  pipein_addr0  <= i_usb_pipein_fifo(31 downto 16);
  pipein_data0  <= i_usb_pipein_fifo(15 downto 0);
  pipeout_rd    <= i_usb_pipeout_fifo_rd;

  inst_regdecode_pipe : entity fpasim.regdecode_pipe
    generic map(
      g_ADDR_WIDTH => pipein_addr0'length, -- define the address bus width
      g_DATA_WIDTH => pipein_data0'length -- define the data bus width

    )
    port map(
      ---------------------------------------------------------------------
      -- input @i_clk
      ---------------------------------------------------------------------
      i_clk                             => i_clk, -- clock
      i_rst                             => i_rst, -- reset
      -- from the trig in
      i_start_auto_rd                   => trig_rd_all_valid, -- enable the auto generation of memory reading address
      -- from the pipe in
      i_data_valid                      => pipein_valid0, -- write enable
      i_addr                            => pipein_addr0, -- input address
      i_data                            => pipein_data0, -- input data

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
      i_rst_status                      => i_rst_status, -- reset error flag(s)
      i_debug_pulse                     => i_debug_pulse, -- error mode (transparent vs capture). Possib
      -- tes_pulse_shape
      -- ram: wr
      o_tes_pulse_shape_ram_wr_en       => tes_pulse_shape_ram_wr_en, -- output write enable
      o_tes_pulse_shape_ram_wr_rd_addr  => tes_pulse_shape_ram_wr_rd_addr, -- output address (shared by the writting and the reading)
      o_tes_pulse_shape_ram_wr_data     => tes_pulse_shape_ram_wr_data, -- output data
      -- ram: rd
      o_tes_pulse_shape_ram_rd_en       => tes_pulse_shape_ram_rd_en, -- output read enable
      i_tes_pulse_shape_ram_rd_valid    => i_tes_pulse_shape_ram_rd_valid, -- input read valid
      i_tes_pulse_shape_ram_rd_data     => i_tes_pulse_shape_ram_rd_data, -- input data
      -- amp_squid_tf
      -- ram: wr
      o_amp_squid_tf_ram_wr_en          => amp_squid_tf_ram_wr_en, -- output write enable
      o_amp_squid_tf_ram_wr_rd_addr     => amp_squid_tf_ram_wr_rd_addr, -- output address (shared by the writting and the reading)
      o_amp_squid_tf_ram_wr_data        => amp_squid_tf_ram_wr_data, -- output data
      -- ram: rd
      o_amp_squid_tf_ram_rd_en          => amp_squid_tf_ram_rd_en, -- output read enable
      i_amp_squid_tf_ram_rd_valid       => i_amp_squid_tf_ram_rd_valid, -- input read valid
      i_amp_squid_tf_ram_rd_data        => i_amp_squid_tf_ram_rd_data,
      -- mux_squid_tf
      -- ram: wr
      o_mux_squid_tf_ram_wr_en          => mux_squid_tf_ram_wr_en, -- output write enable
      o_mux_squid_tf_ram_wr_rd_addr     => mux_squid_tf_ram_wr_rd_addr, -- output address (shared by the writting and the reading)
      o_mux_squid_tf_ram_wr_data        => mux_squid_tf_ram_wr_data, -- output data
      -- ram: rd
      o_mux_squid_tf_ram_rd_en          => mux_squid_tf_ram_rd_en, -- output read enable
      i_mux_squid_tf_ram_rd_valid       => i_mux_squid_tf_ram_rd_valid, -- input read valid
      i_mux_squid_tf_ram_rd_data        => i_mux_squid_tf_ram_rd_data,
      -- tes_std_state
      -- ram: wr
      o_tes_std_state_ram_wr_en         => tes_std_state_ram_wr_en, -- output write enable
      o_tes_std_state_ram_wr_rd_addr    => tes_std_state_ram_wr_rd_addr, -- output address (shared by the writting and the reading)
      o_tes_std_state_ram_wr_data       => tes_std_state_ram_wr_data, -- output data
      -- ram: rd
      o_tes_std_state_ram_rd_en         => tes_std_state_ram_rd_en, -- output read enable
      i_tes_std_state_ram_rd_valid      => i_tes_std_state_ram_rd_valid, -- input read valid
      i_tes_std_state_ram_rd_data       => i_tes_std_state_ram_rd_data,
      -- mux_squid_offset
      -- ram: wr
      o_mux_squid_offset_ram_wr_en      => mux_squid_offset_ram_wr_en, -- output write enable
      o_mux_squid_offset_ram_wr_rd_addr => mux_squid_offset_ram_wr_rd_addr, -- output address (shared by the writting and the reading)
      o_mux_squid_offset_ram_wr_data    => mux_squid_offset_ram_wr_data, -- output data
      -- ram: rd
      o_mux_squid_offset_ram_rd_en      => mux_squid_offset_ram_rd_en, -- output read enable
      i_mux_squid_offset_ram_rd_valid   => i_mux_squid_offset_ram_rd_valid, -- input read valid
      i_mux_squid_offset_ram_rd_data    => i_mux_squid_offset_ram_rd_data,
      ---------------------------------------------------------------------
      -- errors/status @i_out_clk
      ---------------------------------------------------------------------
      -- errors
      o_errors5                         => regdecode_pipe_errors5, -- rd all: output errors
      o_errors4                         => regdecode_pipe_errors4, -- mux squid offset: output errors
      o_errors3                         => regdecode_pipe_errors3, -- tes std state: output errors
      o_errors2                         => regdecode_pipe_errors2, -- mux squid tf: output errors
      o_errors1                         => regdecode_pipe_errors1, -- amp squid tf: output errors
      o_errors0                         => regdecode_pipe_errors0, -- tes pulse shape: output errors
      -- status
      o_status5                         => regdecode_pipe_status5, -- rd all: output status
      o_status4                         => regdecode_pipe_status4, -- mux squid offset: output status
      o_status3                         => regdecode_pipe_status3, -- tes std state: output status
      o_status2                         => regdecode_pipe_status2, -- mux squid tf: output status
      o_status1                         => regdecode_pipe_status1, -- amp squid tf: output status
      o_status0                         => regdecode_pipe_status0 -- tes pulse shape: output status
    );
  ---------------------------------------------------------------------
  -- output: to the usb
  ---------------------------------------------------------------------
  -- to the usb: pipeout
  o_usb_pipeout_fifo_data(31 downto 16)       <= pipeout_addr;
  o_usb_pipeout_fifo_data(15 downto 0)        <= pipeout_data;
  -- resize 
  o_usb_wireout_fifo_data_count(31 downto 16) <= make_pulse_wr_data_count_tmp0;
  o_usb_wireout_fifo_data_count(15 downto 0)  <= pipeout_data_count;

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

  o_pipe_errors5 <= regdecode_pipe_errors5;
  o_pipe_errors4 <= regdecode_pipe_errors4;
  o_pipe_errors3 <= regdecode_pipe_errors3;
  o_pipe_errors2 <= regdecode_pipe_errors2;
  o_pipe_errors1 <= regdecode_pipe_errors1;
  o_pipe_errors0 <= regdecode_pipe_errors0;

  o_pipe_status5                                  <= regdecode_pipe_status5;
  o_pipe_status4                                  <= regdecode_pipe_status4;
  o_pipe_status3                                  <= regdecode_pipe_status3;
  o_pipe_status2                                  <= regdecode_pipe_status2;
  o_pipe_status1                                  <= regdecode_pipe_status1;
  o_pipe_status0                                  <= regdecode_pipe_status0;
  ---------------------------------------------------------------------
  -- common register
  ---------------------------------------------------------------------
  reg_data_valid_tmp0                             <= trig_reg_valid;
  reg_data_tmp0(c_REG_IDX5_H downto c_REG_IDX5_L) <= i_usb_wirein_tes_conf;
  reg_data_tmp0(c_REG_IDX4_H downto c_REG_IDX4_L) <= i_usb_wirein_ra_delay;
  reg_data_tmp0(c_REG_IDX3_H downto c_REG_IDX3_L) <= i_usb_wirein_error_delay;
  reg_data_tmp0(c_REG_IDX2_H downto c_REG_IDX2_L) <= i_usb_wirein_amp_sq_of_delay;
  reg_data_tmp0(c_REG_IDX1_H downto c_REG_IDX1_L) <= i_usb_wirein_mux_sq_fb_delay;
  reg_data_tmp0(c_REG_IDX0_H downto c_REG_IDX0_L) <= i_usb_wirein_fpasim_gain;
  inst_regdecode_wire_wr_rd_common_register : entity fpasim.regdecode_wire_wr_rd
    generic map(
      g_DATA_WIDTH_OUT => reg_data_tmp0'length -- define the RAM address width
    )
    port map(
      ---------------------------------------------------------------------
      -- from the regdecode: input @i_clk
      ---------------------------------------------------------------------
      i_clk             => i_clk,
      i_rst             => i_rst,
      -- data
      i_data_valid      => reg_data_valid_tmp0,
      i_data            => reg_data_tmp0,
      ---------------------------------------------------------------------
      -- from/to the user:  @i_out_clk
      ---------------------------------------------------------------------
      i_out_clk         => i_out_clk,
      i_rst_status      => i_rst_status,
      i_debug_pulse     => i_debug_pulse,
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
      -- errors/status @ i_out_clk
      ---------------------------------------------------------------------
      o_errors          => reg_errors,
      o_status          => reg_status
    );
  -- to the USB: auto-read the FIFO
  reg_rd_tmp1 <= '1' when reg_empty_tmp1 = '0' else '0';

  -- output: to USB
  ---------------------------------------------------------------------
  o_usb_wireout_tes_conf        <= reg_data_tmp1(c_REG_IDX5_H downto c_REG_IDX5_L);
  o_usb_wireout_ra_delay        <= reg_data_tmp1(c_REG_IDX4_H downto c_REG_IDX4_L);
  o_usb_wireout_error_delay     <= reg_data_tmp1(c_REG_IDX3_H downto c_REG_IDX3_L);
  o_usb_wireout_amp_sq_of_delay <= reg_data_tmp1(c_REG_IDX2_H downto c_REG_IDX2_L);
  o_usb_wireout_mux_sq_fb_delay <= reg_data_tmp1(c_REG_IDX1_H downto c_REG_IDX1_L);
  o_usb_wireout_fpasim_gain     <= reg_data_tmp1(c_REG_IDX0_H downto c_REG_IDX0_L);

  -- output: to the user
  ---------------------------------------------------------------------
  o_reg_valid           <= reg_data_valid_tmp2;
  o_reg_tes_conf        <= reg_data_tmp2(c_REG_IDX5_H downto c_REG_IDX5_L);
  o_reg_ra_delay        <= reg_data_tmp2(c_REG_IDX4_H downto c_REG_IDX4_L);
  o_reg_error_delay     <= reg_data_tmp2(c_REG_IDX3_H downto c_REG_IDX3_L);
  o_reg_amp_sq_of_delay <= reg_data_tmp2(c_REG_IDX2_H downto c_REG_IDX2_L);
  o_reg_mux_sq_fb_delay <= reg_data_tmp2(c_REG_IDX1_H downto c_REG_IDX1_L);
  o_reg_fpasim_gain     <= reg_data_tmp2(c_REG_IDX0_H downto c_REG_IDX0_L);

  o_reg_errors0 <= reg_errors;
  o_reg_status0 <= reg_status;

  ---------------------------------------------------------------------
  -- control register
  ---------------------------------------------------------------------
  ctrl_data_valid_tmp0 <= trig_ctrl_valid;
  ctrl_data_tmp0       <= i_usb_wirein_ctrl;
  inst_regdecode_wire_wr_rd_ctrl_register : entity fpasim.regdecode_wire_wr_rd
    generic map(
      g_DATA_WIDTH_OUT => ctrl_data_tmp0'length -- define the RAM address width
    )
    port map(
      ---------------------------------------------------------------------
      -- from the regdecode: input @i_clk
      ---------------------------------------------------------------------
      i_clk             => i_clk,
      i_rst             => i_rst,
      -- data
      i_data_valid      => ctrl_data_valid_tmp0,
      i_data            => ctrl_data_tmp0,
      ---------------------------------------------------------------------
      -- from/to the user:  @i_out_clk
      ---------------------------------------------------------------------
      i_out_clk         => i_out_clk,
      i_rst_status      => i_rst_status,
      i_debug_pulse     => i_debug_pulse,
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
      -- errors/status @ i_out_clk
      ---------------------------------------------------------------------
      o_errors          => ctrl_errors,
      o_status          => ctrl_status
    );
  -- to the USB: auto-read the FIFO
  ctrl_rd_tmp1 <= '1' when ctrl_empty_tmp1 = '0' else '0';

  -- output: to USB
  ---------------------------------------------------------------------
  o_usb_wireout_ctrl <= ctrl_data_tmp1;

  -- output: to the user
  ---------------------------------------------------------------------
  o_reg_ctrl_valid <= ctrl_data_valid_tmp2;
  o_reg_ctrl       <= ctrl_data_tmp2;

  o_ctrl_errors0 <= ctrl_errors;
  o_ctrl_status0 <= ctrl_status;

  ---------------------------------------------------------------------
  -- debug control register
  ---------------------------------------------------------------------
  debug_ctrl_data_valid_tmp0 <= trig_debug_valid;
  debug_ctrl_data_tmp0       <= i_usb_wirein_debug_ctrl;
  inst_regdecode_wire_wr_rd_debug_ctrl_register : entity fpasim.regdecode_wire_wr_rd
    generic map(
      g_DATA_WIDTH_OUT => debug_ctrl_data_tmp0'length -- define the RAM address width
    )
    port map(
      ---------------------------------------------------------------------
      -- from the regdecode: input @i_clk
      ---------------------------------------------------------------------
      i_clk             => i_clk,
      i_rst             => i_rst,
      -- data
      i_data_valid      => debug_ctrl_data_valid_tmp0,
      i_data            => debug_ctrl_data_tmp0,
      ---------------------------------------------------------------------
      -- from/to the user:  @i_out_clk
      ---------------------------------------------------------------------
      i_out_clk         => i_out_clk,
      i_rst_status      => i_rst_status,
      i_debug_pulse     => i_debug_pulse,
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
      -- errors/status @ i_out_clk
      ---------------------------------------------------------------------
      o_errors          => debug_ctrl_errors,
      o_status          => debug_ctrl_status
    );
  -- to the USB: auto-read the FIFO
  debug_ctrl_rd_tmp1 <= '1' when debug_ctrl_empty_tmp1 = '0' else '0';

  -- output: to USB
  ---------------------------------------------------------------------
  o_usb_wireout_debug_ctrl <= debug_ctrl_data_tmp1;

  -- output: to the user
  ---------------------------------------------------------------------
  o_reg_debug_ctrl_valid <= debug_ctrl_data_valid_tmp2;
  o_reg_debug_ctrl       <= debug_ctrl_data_tmp2;

  o_debug_ctrl_errors0 <= debug_ctrl_errors;
  o_debug_ctrl_status0 <= debug_ctrl_status;

  ---------------------------------------------------------------------
  -- make pulse register
  ---------------------------------------------------------------------
  make_pulse_data_valid_tmp0 <= trig_make_pulse_valid;
  make_pulse_data_tmp0       <= i_usb_wirein_make_pulse;
  pixel_nb                   <= i_usb_wirein_tes_conf(c_TES_CONF_PIXEL_NB_IDX_H downto c_TES_CONF_PIXEL_NB_IDX_L); -- @suppress "Incorrect array size in assignment: expected (<pkg_TES_CONF_PIXEL_NB_WIDTH>) but was (<6>)"

  inst_regdecode_wire_make_pulse : entity fpasim.regdecode_wire_make_pulse
    generic map(
      g_DATA_WIDTH_OUT => make_pulse_data_tmp0'length, -- define the RAM address width
      g_PIXEL_NB_WIDTH => pixel_nb'length
    )
    port map(                           -- @suppress "The order of the associations is different from the declaration order"
      ---------------------------------------------------------------------
      -- from the regdecode: input @i_clk
      ---------------------------------------------------------------------
      i_clk              => i_clk,
      i_rst              => i_rst,
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
      i_rst_status       => i_rst_status,
      i_debug_pulse      => i_debug_pulse,
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
      -- errors/status @ i_out_clk
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
  o_usb_wireout_make_pulse <= make_pulse_data_tmp1;

  -- output: to the user
  ---------------------------------------------------------------------
  o_reg_make_sof         <= make_pulse_sof_tmp2;
  o_reg_make_eof         <= make_pulse_eof_tmp2;
  o_reg_make_pulse_valid <= make_pulse_data_valid_tmp2;
  o_reg_make_pulse       <= make_pulse_data_tmp2;

  o_make_pulse_errors0 <= make_pulse_errors;
  o_make_pulse_status0 <= make_pulse_status;

  ---------------------------------------------------------------------
  -- errors register
  ---------------------------------------------------------------------
  error_sel <= i_usb_wirein_sel_errors(c_ERROR_SEL_IDX_H downto c_ERROR_SEL_IDX_L); -- @suppress "Incorrect array size in assignment: expected (<pkg_ERROR_SEL_WIDTH>) but was (<3>)"
  inst_regdecode_wire_errors : entity fpasim.regdecode_wire_errors
    generic map(
      g_ERROR_SEL_WIDTH => error_sel'length
    )
    port map(
      i_clk               => i_out_clk,
      -- errors
      i_reg_wire_errors7  => i_reg_wire_errors7,
      i_reg_wire_errors6  => i_reg_wire_errors6,
      i_reg_wire_errors5  => i_reg_wire_errors5,
      i_reg_wire_errors4  => i_reg_wire_errors4,
      i_reg_wire_errors3  => i_reg_wire_errors3,
      i_reg_wire_errors2  => i_reg_wire_errors2,
      i_reg_wire_errors1  => i_reg_wire_errors1,
      i_reg_wire_errors0  => i_reg_wire_errors0,
      -- status
      i_reg_wire_status7  => i_reg_wire_status7,
      i_reg_wire_status6  => i_reg_wire_status6,
      i_reg_wire_status5  => i_reg_wire_status5,
      i_reg_wire_status4  => i_reg_wire_status4,
      i_reg_wire_status3  => i_reg_wire_status3,
      i_reg_wire_status2  => i_reg_wire_status2,
      i_reg_wire_status1  => i_reg_wire_status1,
      i_reg_wire_status0  => i_reg_wire_status0,
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      i_out_clk           => i_clk,
      i_error_sel         => error_sel,
      o_wire_errors_valid => wire_errors_valid,
      o_wire_errors       => wire_errors,
      o_wire_status       => wire_status
    );

  -- output: to usb 
  ---------------------------------------------------------------------
  o_usb_wireout_sel_errors <= i_usb_wirein_sel_errors;
  o_usb_wireout_errors     <= wire_errors;
  o_usb_wireout_status     <= wire_status;

  o_usb_trigout_data(31 downto 1) <= (others => '0');
  o_usb_trigout_data(0)           <= wire_errors_valid;

  ---------------------------------------------------------------------
  -- debug
  ---------------------------------------------------------------------
  gen_debug_ila : if g_DEBUG = true generate -- @suppress "Redundant boolean equality check with true"
    -- inst_fpasim_regdecode_top_ila_0 : entity fpasim.fpasim_regdecode_top_ila_0
    --   port map(
    --     clk                  => i_clk,
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
