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
--!   @file                   fpasim_top.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
-- This module is the top_level of the fpasim
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library fpasim;
use fpasim.pkg_fpasim.all;

entity top_fpasim is
    generic(
        g_DEBUG : boolean := true
    );
    port(
        i_clk                             : in  std_logic; -- system clock
        i_adc_clk                         : in  std_logic; -- adc clock
        i_ref_clk                         : in  std_logic; -- reference clock
        i_dac_clk                         : in  std_logic; -- dac clock
        ---------------------------------------------------------------------
        -- from adc
        ---------------------------------------------------------------------
        i_adc_valid                       : in  std_logic;
        i_adc_amp_squid_offset_correction : in  std_logic_vector(13 downto 0);
        i_adc_mux_squid_feedback          : in  std_logic_vector(13 downto 0);
        ---------------------------------------------------------------------
        -- output sync @clk_ref
        ---------------------------------------------------------------------
        o_sync                            : out std_logic;
        ---------------------------------------------------------------------
        -- output dac @i_clk_dac
        ---------------------------------------------------------------------
        o_dac_valid                       : out std_logic;
        o_dac_frame                       : out std_logic;
        o_dac                             : out std_logic_vector(15 downto 0)
    );
end entity top_fpasim;

architecture RTL of top_fpasim is
    constant c_PIXEL_ID_WIDTH : integer := pkg_PIXEL_ID_WIDTH;
    constant c_FRAME_ID_WIDTH : integer := pkg_FRAME_ID_WIDTH;

    constant c_TES_TOP_LATENCY         : integer := pkg_TES_TOP_LATENCY;
    constant c_MUX_SQUID_TOP_LATENCY   : integer := pkg_MUX_SQUID_TOP_LATENCY;
    constant c_SYNC_PULSE_DURATION     : integer := pkg_SYNC_PULSE_DURATION;
    constant c_MUX_SQUID_ADD_Q_WIDTH_S : integer := pkg_MUX_SQUID_ADD_Q_WIDTH_S;
    constant c_TES_MULT_SUB_Q_WIDTH_S  : integer := pkg_TES_MULT_SUB_Q_WIDTH_S;


    ---------------------------------------------------------------------
    -- adc_top
    ---------------------------------------------------------------------
    signal adc_valid0                       : std_logic;
    signal adc_mux_squid_feedback0          : std_logic_vector(i_adc_mux_squid_feedback'range);
    signal adc_amp_squid_offset_correction0 : std_logic_vector(i_adc_amp_squid_offset_correction'range);
    signal errors0                          : std_logic_vector(15 downto 0);
    signal status0                          : std_logic_vector(7 downto 0);

    ---------------------------------------------------------------------
    -- tes_top
    ---------------------------------------------------------------------
    signal pixel_sof1    : std_logic;
    signal pixel_eof1    : std_logic;
    signal pixel_valid1  : std_logic;
    signal pixel_id1     : std_logic_vector(c_PIXEL_ID_WIDTH - 1 downto 0);
    signal pixel_result1 : std_logic_vector(c_TES_MULT_SUB_Q_WIDTH_S - 1 downto 0);
    signal frame_sof1    : std_logic;
    signal frame_eof1    : std_logic;
    signal frame_id1     : std_logic_vector(c_FRAME_ID_WIDTH - 1 downto 0);
    signal errors1       : std_logic_vector(15 downto 0);
    signal status1       : std_logic_vector(7 downto 0);

    -- signals synchronization with tes_top output
    ---------------------------------------------------------------------
    constant c_IDX0_L : integer := 0;
    constant c_IDX0_H : integer := c_IDX0_L + i_adc_amp_squid_offset_correction'length - 1;

    constant c_IDX1_L : integer := c_IDX0_H + 1;
    constant c_IDX1_H : integer := c_IDX1_L + i_adc_mux_squid_feedback'length - 1;

    signal data_pipe_tmp0 : std_logic_vector(c_IDX1_H downto 0);
    signal data_pipe_tmp1 : std_logic_vector(c_IDX1_H downto 0);

    signal mux_squid_feedback1          : std_logic_vector(i_adc_mux_squid_feedback'range);
    signal amp_squid_offset_correction1 : std_logic_vector(i_adc_amp_squid_offset_correction'range);

    ---------------------------------------------------------------------
    -- mux_squid_top
    ---------------------------------------------------------------------
    signal pixel_sof2    : std_logic;
    signal pixel_eof2    : std_logic;
    signal pixel_valid2  : std_logic;
    signal pixel_id2     : std_logic_vector(c_PIXEL_ID_WIDTH - 1 downto 0);
    signal pixel_result2 : std_logic_vector(c_MUX_SQUID_ADD_Q_WIDTH_S - 1 downto 0);
    signal frame_sof2    : std_logic;
    signal frame_eof2    : std_logic;
    signal frame_id2     : std_logic_vector(c_FRAME_ID_WIDTH - 1 downto 0);
    signal errors2       : std_logic_vector(15 downto 0);
    signal status2       : std_logic_vector(7 downto 0);

    -- signals synchronization with mux_squid_top
    ---------------------------------------------------------------------
    signal amp_squid_offset_correction2 : std_logic_vector(i_adc_amp_squid_offset_correction'range);

    ---------------------------------------------------------------------
    -- amp_squid_top
    ---------------------------------------------------------------------
    signal pixel_sof3    : std_logic;
    signal pixel_eof3    : std_logic;
    signal pixel_valid3  : std_logic;
    signal pixel_id3     : std_logic_vector(c_PIXEL_ID_WIDTH - 1 downto 0);
    signal pixel_result3 : std_logic_vector(15 downto 0);
    signal frame_sof3    : std_logic;
    signal frame_eof3    : std_logic;
    signal frame_id3     : std_logic_vector(c_FRAME_ID_WIDTH - 1 downto 0);
    signal errors3       : std_logic_vector(15 downto 0);
    signal status3       : std_logic_vector(7 downto 0);

    ---------------------------------------------------------------------
    -- dac_top
    ---------------------------------------------------------------------
    signal dac_valid4 : std_logic;
    signal dac_frame4 : std_logic;
    signal dac4       : std_logic_vector(o_dac'range);
    signal errors4    : std_logic_vector(15 downto 0);
    signal status4    : std_logic_vector(7 downto 0);

    ---------------------------------------------------------------------
    -- sync_top
    ---------------------------------------------------------------------
    signal sync_valid5 : std_logic;
    signal sync5       : std_logic;
    signal errors5     : std_logic_vector(15 downto 0);
    signal status5     : std_logic_vector(7 downto 0);

begin

    ---------------------------------------------------------------------
    -- adc
    ---------------------------------------------------------------------
    inst_adc_top : entity fpasim.adc_top
        generic map(
            g_ADC1_WIDTH       => i_adc_mux_squid_feedback'length,
            g_ADC0_WIDTH       => i_adc_amp_squid_offset_correction'length,
            g_ADC1_DELAY_WIDTH => i_adc1_delay'length,
            g_ADC0_DELAY_WIDTH => i_adc0_delay'length
        )
        port map(
            ---------------------------------------------------------------------
            -- input
            ---------------------------------------------------------------------
            i_adc_clk     => i_adc_clk,
            i_adc_valid   => i_adc_valid,
            i_adc1        => i_adc_mux_squid_feedback,
            i_adc0        => i_adc_amp_squid_offset_correction,
            ---------------------------------------------------------------------
            -- output
            ---------------------------------------------------------------------
            i_clk         => i_clk,
            -- from regdecode
            -----------------------------------------------------------------
            i_rst         => i_rst,
            i_rst_status  => i_rst_status,
            i_debug_pulse => i_debug_pulse,
            i_en          => i_en,
            i_adc1_delay  => i_adc1_delay,
            i_adc0_delay  => i_adc0_delay,
            -- output
            -----------------------------------------------------------------
            o_adc_valid   => adc_valid0,
            o_adc1        => adc_mux_squid_feedback0,
            o_adc0        => adc_amp_squid_offset_correction0,
            ---------------------------------------------------------------------
            -- errors/status
            --------------------------------------------------------------------- 
            o_errors      => errors0,
            o_status      => status0
        );

    ---------------------------------------------------------------------
    -- tes
    ---------------------------------------------------------------------
    inst_tes_top : entity fpasim.tes_top
        generic map(
            g_PIXEL_ID_WIDTH            => pixel_id1'length,
            g_FRAME_ID_WIDTH            => frame_id1'length,
            g_PIXEL_RESULT_OUTPUT_WIDTH => pixel_result1'length
        )
        port map(
            i_clk                  => i_clk,
            i_rst                  => i_rst,
            i_rst_status           => i_rst_status,
            i_debug_pulse          => i_debug_pulse,
            ---------------------------------------------------------------------
            -- input command: from the regdecode
            ---------------------------------------------------------------------
            i_en                   => i_en,
            i_cmd_valid            => i_cmd_valid,
            i_cmd_pulse_height     => i_cmd_pulse_height,
            i_cmd_pixel_id         => i_cmd_pixel_id,
            i_cmd_time_shift       => i_cmd_time_shift,
            -- RAM: pulse shape
            -- wr
            i_wr_pulse_shape_en    => i_wr_pulse_shape_en,
            i_wr_pulse_shape_addr  => i_wr_pulse_shape_addr,
            i_wr_pulse_shape_data  => i_wr_pulse_shape_data,
            -- RAM:
            -- wr
            i_wr_steady_state_en   => i_wr_steady_state_en,
            i_wr_steady_state_addr => i_wr_steady_state_addr,
            i_wr_steady_state_data => i_wr_steady_state_data,
            ---------------------------------------------------------------------
            -- from the adc
            ---------------------------------------------------------------------
            i_data_valid           => adc_valid0,
            ---------------------------------------------------------------------
            -- output
            ---------------------------------------------------------------------
            o_pixel_sof            => pixel_sof1,
            o_pixel_eof            => pixel_eof1,
            o_pixel_valid          => pixel_valid1,
            o_pixel_id             => pixel_id1,
            o_pixel_result         => pixel_result1,
            o_frame_sof            => frame_sof1,
            o_frame_eof            => frame_eof1,
            o_frame_id             => frame_id1,
            ---------------------------------------------------------------------
            -- errors/status
            ---------------------------------------------------------------------
            o_errors               => errors1,
            o_status               => status1
        );

    -- sync with inst_tes_top out
    -----------------------------------------------------------------
    data_pipe_tmp0(c_IDX1_H downto c_IDX1_L) <= adc_mux_squid_feedback0;
    data_pipe_tmp0(c_IDX0_H downto c_IDX0_L) <= adc_amp_squid_offset_correction0;
    inst_pipeliner_sync_with_tes_top_out : entity fpasim.pipeliner
        generic map(
            g_NB_PIPES   => c_TES_TOP_LATENCY,
            g_DATA_WIDTH => data_pipe_tmp0'length
        )
        port map(
            i_clk  => i_clk,
            i_data => data_pipe_tmp0,
            o_data => data_pipe_tmp1
        );

    mux_squid_feedback1          <= data_pipe_tmp1(c_IDX1_H downto c_IDX1_L);
    amp_squid_offset_correction1 <= data_pipe_tmp1(c_IDX0_H downto c_IDX0_L);

    ---------------------------------------------------------------------
    -- mux squid
    ---------------------------------------------------------------------
    inst_mux_squid_top : entity fpasim.mux_squid_top
        generic map(
            g_PIXEL_ID_WIDTH            => pixel_id1'length,
            g_FRAME_ID_WIDTH            => frame_id1'length,
            g_PIXEL_RESULT_INPUT_WIDTH  => pixel_result1'length,
            g_PIXEL_RESULT_OUTPUT_WIDTH => pixel_result2'length
        )
        port map(
            i_clk                      => i_clk,
            i_rst_status               => i_rst_status,
            i_debug_pulse              => i_debug_pulse,
            ---------------------------------------------------------------------
            -- input command: from the regdecode
            ---------------------------------------------------------------------
            -- RAM: mux_squid_offset
            -- wr
            i_wr_mux_squid_offset_en   => i_wr_mux_squid_offset_en,
            i_wr_mux_squid_offset_addr => i_wr_mux_squid_offset_addr,
            i_wr_mux_squid_offset_data => i_wr_mux_squid_offset_data,
            -- RAM: mux_squid_tf
            -- wr
            i_wr_mux_squid_tf_en       => i_wr_mux_squid_tf_en,
            i_wr_mux_squid_tf_addr     => i_wr_mux_squid_tf_addr,
            i_wr_mux_squid_tf_data     => i_wr_mux_squid_tf_data,
            ---------------------------------------------------------------------
            -- input1
            ---------------------------------------------------------------------
            i_pixel_sof                => pixel_sof1,
            i_pixel_eof                => pixel_eof1,
            i_pixel_valid              => pixel_valid1,
            i_pixel_id                 => pixel_id1,
            i_pixel_result             => pixel_result1,
            i_frame_sof                => frame_sof1,
            i_frame_eof                => frame_eof1,
            i_frame_id                 => frame_id1,
            ---------------------------------------------------------------------
            -- input2
            ---------------------------------------------------------------------
            i_mux_squid_feedback       => mux_squid_feedback1,
            ---------------------------------------------------------------------
            -- output
            ---------------------------------------------------------------------
            o_pixel_sof                => pixel_sof2,
            o_pixel_eof                => pixel_eof2,
            o_pixel_valid              => pixel_valid2,
            o_pixel_id                 => pixel_id2,
            o_pixel_result             => pixel_result2,
            o_frame_sof                => frame_sof2,
            o_frame_eof                => frame_eof2,
            o_frame_id                 => frame_id2,
            ---------------------------------------------------------------------
            -- errors/status
            ---------------------------------------------------------------------
            o_errors                   => errors2,
            o_status                   => status2
        );

    -- sync with inst_mux_squid_top out
    -----------------------------------------------------------------
    inst_pipeliner_sync_with_mux_squid_top_out : entity fpasim.pipeliner
        generic map(
            g_NB_PIPES   => c_MUX_SQUID_TOP_LATENCY, -- number of consecutives registers. Possibles values: [0, integer max value[
            g_DATA_WIDTH => amp_squid_offset_correction1'length -- width of the input/output data.  Possibles values: [1, integer max value[
        )
        port map(
            i_clk  => i_clk,            -- clock signal
            i_data => amp_squid_offset_correction1, -- input data
            o_data => amp_squid_offset_correction2 -- output data with/without delay
        );

    ---------------------------------------------------------------------
    -- amp squid
    ---------------------------------------------------------------------
    inst_amp_squid_top : entity fpasim.amp_squid_top
        generic map(
            g_PIXEL_ID_WIDTH            => pixel_id1'length,
            g_FRAME_ID_WIDTH            => frame_id1'length,
            g_PIXEL_RESULT_INPUT_WIDTH  => pixel_result2'length,
            g_PIXEL_RESULT_OUTPUT_WIDTH => pixel_result3'length
        )
        port map(
            i_clk                         => i_clk, -- clock
            i_rst_status                  => i_rst_status, -- reset error flags
            i_debug_pulse                 => i_debug_pulse, -- '1': delayed error, '0': latched error

            ---------------------------------------------------------------------
            -- input command: from the regdecode
            ---------------------------------------------------------------------
            -- RAM: amp_squid_tf
            -- wr
            i_wr_amp_squid_tf_en          => i_wr_amp_squid_tf_en, -- write enable
            i_wr_amp_squid_tf_addr        => i_wr_amp_squid_tf_addr, -- write address
            i_wr_amp_squid_tf_data        => i_wr_amp_squid_tf_data, -- write data
            -- gain
            i_fpasim_gain                 => i_fpasim_gain, -- gain value
            ---------------------------------------------------------------------
            -- input1
            ---------------------------------------------------------------------
            i_pixel_sof                   => pixel_sof2, -- first sample of a pixel
            i_pixel_eof                   => pixel_eof2, -- last sample of a pixel
            i_pixel_valid                 => pixel_valid2, -- valid sample of a pixel
            i_pixel_id                    => pixel_id2, -- id of a pixel
            i_pixel_result                => pixel_result2,
            i_frame_sof                   => frame_sof2, -- first sample of a frame
            i_frame_eof                   => frame_eof2, -- last sample of a frame
            i_frame_id                    => frame_id2, -- id of a frame
            ---------------------------------------------------------------------
            -- input2
            ---------------------------------------------------------------------
            i_amp_squid_offset_correction => amp_squid_offset_correction2,
            ---------------------------------------------------------------------
            -- output
            ---------------------------------------------------------------------
            o_pixel_sof                   => pixel_sof3, -- not connected
            o_pixel_eof                   => pixel_eof3, -- not connected
            o_pixel_valid                 => pixel_valid3,
            o_pixel_id                    => pixel_id3, -- not connected
            o_pixel_result                => pixel_result3,
            o_frame_sof                   => frame_sof3,
            o_frame_eof                   => frame_eof3, -- not connected
            o_frame_id                    => frame_id3, -- not connected
            ---------------------------------------------------------------------
            -- errors/status
            ---------------------------------------------------------------------
            o_errors                      => errors3, -- output errors
            o_status                      => status3 -- output status
        );

    ---------------------------------------------------------------------
    -- dac_top
    ---------------------------------------------------------------------
    inst_dac_top : entity fpasim.dac_top
        generic map(
            g_DAC_DELAY_WIDTH => i_dac_delay'length
        )
        port map(
            ---------------------------------------------------------------------
            -- input @i_clk
            ---------------------------------------------------------------------
            i_clk         => i_clk,
            i_rst         => i_rst,
            -- from regdecode
            -----------------------------------------------------------------
            i_rst_status  => i_rst_status,
            i_debug_pulse => i_debug_pulse,
            i_en          => i_en,
            i_endianess   => i_endianess,
            i_dac_delay   => i_dac_delay,
            -- input data 
            ---------------------------------------------------------------------
            i_dac_valid   => pixel_valid3,
            i_dac         => pixel_result3,
            ---------------------------------------------------------------------
            -- output @i_clk_dac
            ---------------------------------------------------------------------
            i_dac_clk     => i_dac_clk,
            o_dac_valid   => dac_valid4,
            o_dac_frame   => dac_frame4,
            o_dac         => dac4,
            ---------------------------------------------------------------------
            -- errors/status @i_clk
            --------------------------------------------------------------------- 
            o_errors      => errors4,
            o_status      => status4
        );

    ---------------------------------------------------------------------
    -- sync_top
    ---------------------------------------------------------------------
    inst_sync_top : entity fpasim.sync_top
        generic map(
            g_PULSE_DURATION   => c_SYNC_PULSE_DURATION, -- duration of the output pulse. Possible values [1;integer max value[
            g_SYNC_DELAY_WIDTH => i_sync_delay'length
        )
        port map(
            ---------------------------------------------------------------------
            -- input @i_clk
            ---------------------------------------------------------------------
            i_clk         => i_clk,     -- clock
            i_rst         => i_rst,     -- reset
            -- from regdecode
            -----------------------------------------------------------------
            i_rst_status  => i_rst_status,
            i_debug_pulse => i_debug_pulse,
            i_sync_delay  => i_sync_delay,
            -- input data 
            ---------------------------------------------------------------------
            i_sync_valid  => pixel_valid3,
            i_sync        => frame_sof3,
            ---------------------------------------------------------------------
            -- output @i_ref_clk
            ---------------------------------------------------------------------
            i_ref_clk     => i_ref_clk,
            o_sync_valid  => sync_valid5, -- not connected
            o_sync        => sync5,
            ---------------------------------------------------------------------
            -- errors/status @i_clk
            --------------------------------------------------------------------- 
            o_errors      => errors5,
            o_status      => status5
        );

    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    -- @i_clk_dac
    o_dac_valid <= dac_valid4;
    o_dac_frame <= dac_frame4;
    o_dac       <= dac4;
    -- @i_ref_clk
    o_sync      <= sync5;

    ---------------------------------------------------------------------
    -- debug
    ---------------------------------------------------------------------
    gen_debug : if g_DEBUG = TRUE generate -- @suppress "Redundant boolean equality check with true"
        inst_fpasim_top_ila_0 : fpasim.fpasim_top_ila_0
            PORT MAP(
                clk                 => i_clk,
                probe0              => pixel_result3,
                probe1(21)          => pixel_sof3,
                probe1(20)          => pixel_eof3,
                probe1(19)          => pixel_valid3,
                probe1(18)          => frame_sof3,
                probe1(17)          => frame_eof3,
                probe1(16 downto 6) => frame_id3,
                probe1(5 downto 0)  => pixel_id3
            );
    end generate gen_debug;

end architecture RTL;
