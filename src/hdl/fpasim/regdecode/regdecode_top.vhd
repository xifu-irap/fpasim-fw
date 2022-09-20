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
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fpasim;

entity regdecode_top is
    generic(
        g_DEBUG : boolean := false
    );
    port(
        ---------------------------------------------------------------------
        -- from the usb @i_clk
        ---------------------------------------------------------------------
        i_clk                             : in  std_logic;
        i_rst                             : in  std_logic;
        -- trig
        i_usb_pipein_fifo_valid           : in  std_logic;
        i_usb_pipein_fifo                 : in  std_logic_vector(31 downto 0);
        -- trig
        i_usb_trigin_valid                : in  std_logic_vector(31 downto 0);
        -- wire
        i_usb_wirein_ctrl                 : in  std_logic_vector(31 downto 0);
        i_usb_wirein_make_pulse           : in  std_logic_vector(31 downto 0);
        i_usb_wirein_fpasim_gain          : in  std_logic_vector(31 downto 0);
        i_usb_wirein_mux_sq_fb_delay      : in  std_logic_vector(31 downto 0);
        i_usb_wirein_amp_sq_of_delay      : in  std_logic_vector(31 downto 0);
        i_usb_wirein_error_delay          : in  std_logic_vector(31 downto 0);
        i_usb_wirein_ra_delay             : in  std_logic_vector(31 downto 0);
        i_usb_wirein_tes_conf             : in  std_logic_vector(31 downto 0);
        i_usb_wirein_debug_ctrl           : in  std_logic_vector(31 downto 0);
        ---------------------------------------------------------------------
        -- to the usb @o_usb_clk
        ---------------------------------------------------------------------
        -- pipe
        i_usb_pipeout_fifo_valid          : in  std_logic;
        o_usb_pipeout_fifo_data           : out std_logic_vector(31 downto 0);
        -- trig
        o_usb_trigout_interrupt           : out std_logic_vector(31 downto 0);
        -- wire
        o_usb_wireout_fifo_data_count     : out std_logic_vector(31 downto 0);
        o_usb_wireout_ctrl                : out std_logic_vector(31 downto 0);
        o_usb_wireout_make_pulse          : out std_logic_vector(31 downto 0);
        o_usb_wireout_fpasim_gain         : out std_logic_vector(31 downto 0);
        o_usb_wireout_mux_sq_fb_delay     : out std_logic_vector(31 downto 0);
        o_usb_wireout_amp_sq_of_delay     : out std_logic_vector(31 downto 0);
        o_usb_wireout_error_delay         : out std_logic_vector(31 downto 0);
        o_usb_wireout_ra_delay            : out std_logic_vector(31 downto 0);
        o_usb_wireout_tes_conf            : out std_logic_vector(31 downto 0);
        o_usb_wireout_debug_ctrl          : out std_logic_vector(31 downto 0);
        o_usb_wireout_errors0             : out std_logic_vector(31 downto 0);
        o_usb_wireout_errors1             : out std_logic_vector(31 downto 0);
        o_usb_wireout_status0             : out std_logic_vector(31 downto 0);
        o_usb_wireout_status1             : out std_logic_vector(31 downto 0);
        ---------------------------------------------------------------------
        -- from the user
        ---------------------------------------------------------------------

        ---------------------------------------------------------------------
        -- to the user: @i_out_clk
        ---------------------------------------------------------------------
        i_out_clk                         : in  std_logic;
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
        i_tes_pulse_shape_ram_rd_data     : in  std_logic_vector(15 downto 0); -- input data

        -- amp_squid_tf
        -- ram: wr
        o_amp_squid_tf_ram_wr_en          : out std_logic; -- output write enable
        o_amp_squid_tf_ram_wr_rd_addr     : out std_logic_vector(15 downto 0); -- output address (shared by the writting and the reading)
        o_amp_squid_tf_ram_wr_data        : out std_logic_vector(15 downto 0); -- output data
        -- ram: rd
        o_amp_squid_tf_ram_rd_en          : out std_logic; -- output read enable
        i_amp_squid_tf_ram_rd_valid       : in  std_logic; -- input read valid
        i_amp_squid_tf_ram_rd_data        : in  std_logic_vector(15 downto 0);
        -- mux_squid_tf
        -- ram: wr
        o_mux_squid_tf_ram_wr_en          : out std_logic; -- output write enable
        o_mux_squid_tf_ram_wr_rd_addr     : out std_logic_vector(15 downto 0); -- output address (shared by the writting and the reading)
        o_mux_squid_tf_ram_wr_data        : out std_logic_vector(15 downto 0); -- output data
        -- ram: rd
        o_mux_squid_tf_ram_rd_en          : out std_logic; -- output read enable
        i_mux_squid_tf_ram_rd_valid       : in  std_logic; -- input read valid
        i_mux_squid_tf_ram_rd_data        : in  std_logic_vector(15 downto 0);
        -- tes_std_state
        -- ram: wr
        o_tes_std_state_ram_wr_en         : out std_logic; -- output write enable
        o_tes_std_state_ram_wr_rd_addr    : out std_logic_vector(15 downto 0); -- output address (shared by the writting and the reading)
        o_tes_std_state_ram_wr_data       : out std_logic_vector(15 downto 0); -- output data
        -- ram: rd
        o_tes_std_state_ram_rd_en         : out std_logic; -- output read enable
        i_tes_std_state_ram_rd_valid      : in  std_logic; -- input read valid
        i_tes_std_state_ram_rd_data       : in  std_logic_vector(15 downto 0);
        -- mux_squid_offset
        -- ram: wr
        o_mux_squid_offset_ram_wr_en      : out std_logic; -- output write enable
        o_mux_squid_offset_ram_wr_rd_addr : out std_logic_vector(15 downto 0); -- output address (shared by the writting and the reading)
        o_mux_squid_offset_ram_wr_data    : out std_logic_vector(15 downto 0); -- output data
        -- ram: rd
        o_mux_squid_offset_ram_rd_en      : out std_logic; -- output read enable
        i_mux_squid_offset_ram_rd_valid   : in  std_logic; -- input read valid
        i_mux_squid_offset_ram_rd_data    : in  std_logic_vector(15 downto 0);
        -- Register configuration
        ---------------------------------------------------------------------
        -- common register
        o_reg_valid                       : out std_logic;
        o_reg_fpasim_gain                 : out std_logic_vector(31 downto 0);
        o_reg_mux_sq_fb_delay             : out std_logic_vector(31 downto 0);
        o_reg_amp_sq_of_delay             : out std_logic_vector(31 downto 0);
        o_reg_error_delay                 : out std_logic_vector(31 downto 0);
        o_reg_ra_delay                    : out std_logic_vector(31 downto 0);
        o_reg_tes_conf                    : out std_logic_vector(31 downto 0);
        -- ctrl register
        o_reg_ctrl_valid                  : out std_logic;
        o_reg_ctrl                        : out std_logic_vector(31 downto 0);
        -- debug ctrl register
        o_reg_debug_ctrl_valid            : out std_logic;
        o_reg_debug_ctrl                  : out std_logic_vector(31 downto 0);
        -- make pulse register
        o_reg_make_pulse_valid            : out std_logic;
        o_reg_make_pulse                  : out std_logic_vector(31 downto 0)
    );
end entity regdecode_top;

architecture RTL of regdecode_top is
    ---------------------------------------------------------------------
    -- regdecode_pipe
    ---------------------------------------------------------------------
    signal reg_valid        : std_logic;
    signal make_pulse_valid : std_logic;
    signal rd_all_valid     : std_logic;
    signal ctrl_valid       : std_logic;
    signal debug_valid      : std_logic;

    signal pipein_valid0 : std_logic;
    signal pipein_addr0  : std_logic_vector(15 downto 0);
    signal pipein_data0  : std_logic_vector(15 downto 0);

    signal pipeout_sof        : std_logic;
    signal pipeout_eof        : std_logic;
    signal pipeout_valid      : std_logic;
    signal pipeout_addr       : std_logic_vector(15 downto 0);
    signal pipeout_data       : std_logic_vector(15 downto 0);
    signal pipeout_empty      : std_logic;
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
    signal make_pulse_data_valid_tmp0 : std_logic;
    signal make_pulse_data_tmp0       : std_logic_vector(i_usb_wirein_make_pulse'range);

    signal make_pulse_rd_tmp1    : std_logic;
    -- signal make_pulse_data_valid_tmp1 : std_logic;
    signal make_pulse_data_tmp1  : std_logic_vector(i_usb_wirein_make_pulse'range);
    signal make_pulse_empty_tmp1 : std_logic;

    signal make_pulse_data_valid_tmp2 : std_logic;
    signal make_pulse_data_tmp2       : std_logic_vector(i_usb_wirein_make_pulse'range);

    signal make_pulse_errors : std_logic_vector(15 downto 0);
    signal make_pulse_status : std_logic_vector(7 downto 0);

begin

    -- from trigin: extract bits signal
    debug_valid      <= i_usb_trigin_valid(16);
    ctrl_valid       <= i_usb_trigin_valid(12);
    rd_all_valid     <= i_usb_trigin_valid(8);
    make_pulse_valid <= i_usb_trigin_valid(4);
    reg_valid        <= i_usb_trigin_valid(0);

    pipein_valid0 <= i_usb_pipein_fifo_valid;
    pipein_addr0  <= i_usb_pipein_fifo(31 downto 16);
    pipein_data0  <= i_usb_pipein_fifo(15 downto 0);

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
            i_start_auto_rd                   => rd_all_valid, -- enable the auto generation of memory reading address
            -- from the pipe in
            i_data_valid                      => pipein_valid0, -- write enable
            i_addr                            => pipein_addr0, -- input address
            i_data                            => pipein_data0, -- input data

            ---------------------------------------------------------------------
            -- to the pipe out: @i_clk
            ---------------------------------------------------------------------

            i_fifo_rd                         => i_usb_pipeout_fifo_valid,
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
    o_usb_pipeout_fifo_data(31 downto 16) <= pipeout_addr;
    o_usb_pipeout_fifo_data(15 downto 0)  <= pipeout_data;
    -- resize 
    o_usb_wireout_fifo_data_count         <= std_logic_vector(resize(unsigned(pipeout_data_count), o_usb_wireout_fifo_data_count'length));

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
    reg_data_valid_tmp0                             <= reg_valid;
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

    ---------------------------------------------------------------------
    -- control register
    ---------------------------------------------------------------------
    ctrl_data_valid_tmp0 <= ctrl_valid;
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

    ---------------------------------------------------------------------
    -- debug control register
    ---------------------------------------------------------------------
    debug_ctrl_data_valid_tmp0 <= debug_valid;
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

    ---------------------------------------------------------------------
    -- make pulse register
    ---------------------------------------------------------------------
    make_pulse_data_valid_tmp0 <= make_pulse_valid;
    make_pulse_data_tmp0       <= i_usb_wirein_make_pulse;
    inst_regdecode_wire_make_pulse : entity fpasim.regdecode_wire_make_pulse
        generic map(
            g_DATA_WIDTH_OUT => make_pulse_data_tmp0'length -- define the RAM address width
        )
        port map(
            ---------------------------------------------------------------------
            -- from the regdecode: input @i_clk
            ---------------------------------------------------------------------
            i_clk             => i_clk,
            i_rst             => i_rst,
            -- data
            i_data_valid      => make_pulse_data_valid_tmp0,
            i_data            => make_pulse_data_tmp0,
            ---------------------------------------------------------------------
            -- from/to the user:  @i_out_clk
            ---------------------------------------------------------------------
            i_out_clk         => i_out_clk,
            i_rst_status      => i_rst_status,
            i_debug_pulse     => i_debug_pulse,
            -- ram: wr
            o_data_valid      => make_pulse_data_valid_tmp2,
            o_data            => make_pulse_data_tmp2,
            ---------------------------------------------------------------------
            -- to the regdecode: @i_clk
            ---------------------------------------------------------------------
            i_fifo_rd         => make_pulse_rd_tmp1,
            o_fifo_data_valid => open,
            o_fifo_data       => make_pulse_data_tmp1,
            o_fifo_empty      => make_pulse_empty_tmp1,
            ---------------------------------------------------------------------
            -- errors/status @ i_out_clk
            ---------------------------------------------------------------------
            o_errors          => make_pulse_errors,
            o_status          => make_pulse_status
        );
    -- to the USB: auto-read the FIFO
    make_pulse_rd_tmp1 <= '1' when make_pulse_empty_tmp1 = '0' else '0';

    -- output: to USB
    ---------------------------------------------------------------------
    o_usb_wireout_make_pulse <= make_pulse_data_tmp1;

    -- output: to the user
    ---------------------------------------------------------------------
    o_reg_make_pulse_valid <= make_pulse_data_valid_tmp2;
    o_reg_make_pulse       <= make_pulse_data_tmp2;

    ---------------------------------------------------------------------
    -- debug
    ---------------------------------------------------------------------
    gen_debug_ila : if g_DEBUG = true generate -- @suppress "Redundant boolean equality check with true"
        inst_fpasim_regdecode_top_ila_0 : entity fpasim.fpasim_regdecode_top_ila_0
            PORT MAP(
                clk                  => i_clk,
                -- probe0
                probe0(4)            => debug_valid,
                probe0(3)            => ctrl_valid,
                probe0(2)            => rd_all_valid,
                probe0(1)            => make_pulse_valid,
                probe0(0)            => reg_valid,
                -- probe1
                probe1(5)            => i_usb_pipeout_fifo_valid,
                probe1(4)            => pipeout_sof,
                probe1(3)            => pipeout_eof,
                probe1(2)            => pipeout_valid,
                probe1(1)            => pipeout_empty,
                probe1(0)            => pipein_valid0,
                -- probe2
                probe2(31 downto 16) => pipein_addr0,
                probe2(15 downto 0)  => pipein_data0,
                -- probe3
                probe3(31 downto 16) => pipeout_addr,
                probe3(15 downto 0)  => pipeout_data
            );

    end generate gen_debug_ila;

end architecture RTL;
