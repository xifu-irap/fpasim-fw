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
--!   @file                   app_top.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
-- This module is the fpga top level
library ieee;
use ieee.std_logic_1164.all;

entity app_top is
    port(
        --	Opal Kelly inouts --
        okUH    : in    std_logic_vector(4 downto 0);
        okHU    : out   std_logic_vector(2 downto 0);
        okUHU   : inout std_logic_vector(31 downto 0);
        okAA    : inout std_logic;
        ---------------------------------------------------------------------
        -- From the adc
        ---------------------------------------------------------------------
        i_clk_p : in    std_logic;      -- differential clock p @250MHz
        i_clk_n : in    std_logic       -- differential clock n @250MHZ

    );
end entity app_top;

architecture RTL of app_top is

    ---------------------------------------------------------------------
    -- clock generation
    ---------------------------------------------------------------------
    signal adc_clk : std_logic;
    signal ref_clk : std_logic;
    signal dac_clk : std_logic;
    signal clk     : std_logic;
    signal locked  : std_logic;

    ---------------------------------------------------------------------
    -- usb decoding
    ---------------------------------------------------------------------
    signal usb_clk : std_logic;

    -- from the user @usb_clk
    ---------------------------------------------------------------------
    signal usb_rd_fifo_valid      : std_logic;
    signal usb_rd_fifo_data       : std_logic_vector(31 downto 0);
    signal usb_rd_fifo_data_count : std_logic_vector(31 downto 0);
    signal usb_rd_interrupt       : std_logic_vector(31 downto 0);
    signal usb_rd_ctrl            : std_logic_vector(31 downto 0);
    signal usb_rd_make_pulse      : std_logic_vector(31 downto 0);
    signal usb_rd_fpasim_gain     : std_logic_vector(31 downto 0);
    signal usb_rd_mux_sq_fb_delay : std_logic_vector(31 downto 0);
    signal usb_rd_amp_sq_of_delay : std_logic_vector(31 downto 0);
    signal usb_rd_error_delay     : std_logic_vector(31 downto 0);
    signal usb_rd_ra_delay        : std_logic_vector(31 downto 0);
    signal usb_rd_tes_conf        : std_logic_vector(31 downto 0);
    signal usb_rd_debug_ctrl      : std_logic_vector(31 downto 0);
    signal usb_rd_errors0         : std_logic_vector(31 downto 0);
    signal usb_rd_errors1         : std_logic_vector(31 downto 0);
    signal usb_rd_status0         : std_logic_vector(31 downto 0);
    signal usb_rd_status1         : std_logic_vector(31 downto 0);
    ---------------------------------------------------------------------
    -- to the user @usb_clk
    ---------------------------------------------------------------------
    signal usb_wr_fifo_valid      : std_logic;
    signal usb_wr_fifo            : std_logic_vector(31 downto 0);
    signal usb_wr_valid_array     : std_logic_vector(31 downto 0);
    signal usb_wr_ctrl            : std_logic_vector(31 downto 0);
    signal usb_wr_make_pulse      : std_logic_vector(31 downto 0);
    signal usb_wr_fpasim_gain     : std_logic_vector(31 downto 0);
    signal usb_wr_mux_sq_fb_delay : std_logic_vector(31 downto 0);
    signal usb_wr_amp_sq_of_delay : std_logic_vector(31 downto 0);
    signal usb_wr_error_delay     : std_logic_vector(31 downto 0);
    signal usb_wr_ra_delay        : std_logic_vector(31 downto 0);
    signal usb_wr_tes_conf        : std_logic_vector(31 downto 0);
    signal usb_wr_debug_ctrl      : std_logic_vector(31 downto 0);

begin

    ---------------------------------------------------------------------
    -- clock generation
    ---------------------------------------------------------------------
    clocking_top_INST : entity work.clocking_top
        port map(
            ---------------------------------------------------------------------
            -- input
            ---------------------------------------------------------------------
            i_clk_p   => i_clk_p,       -- differential clock p @250MHz
            i_clk_n   => i_clk_n,       -- differential clock n @250MHZ
            ---------------------------------------------------------------------
            -- output
            ---------------------------------------------------------------------
            o_adc_clk => adc_clk,       -- adc output clock @250 MHz
            o_ref_clk => ref_clk,       -- ref output clock @62.5 MHz
            o_dac_clk => dac_clk,       -- dac output clock @500 MHz
            o_clk     => clk,           -- sys output clock @500 MHz
            o_locked  => locked         -- not connected
        );

    -----------------------------------------------------------------
    -- usb
    -----------------------------------------------------------------
    usb_opal_kelly_INST : entity work.usb_opal_kelly
        port map(
            --	Opal Kelly inouts --
            okUH                     => okUH,
            okHU                     => okHU,
            okUHU                    => okUHU,
            okAA                     => okAA,
            ---------------------------------------------------------------------
            -- from the user @o_usb_clk
            ---------------------------------------------------------------------
            o_usb_rd_fifo_valid      => usb_rd_fifo_valid,
            i_usb_rd_fifo_data       => usb_rd_fifo_data,
            i_usb_rd_fifo_data_count => usb_rd_fifo_data_count,
            i_usb_rd_interrupt       => usb_rd_interrupt,
            i_usb_rd_ctrl            => usb_rd_ctrl,
            i_usb_rd_make_pulse      => usb_rd_make_pulse,
            i_usb_rd_fpasim_gain     => usb_rd_fpasim_gain,
            i_usb_rd_mux_sq_fb_delay => usb_rd_mux_sq_fb_delay,
            i_usb_rd_amp_sq_of_delay => usb_rd_amp_sq_of_delay,
            i_usb_rd_error_delay     => usb_rd_error_delay,
            i_usb_rd_ra_delay        => usb_rd_ra_delay,
            i_usb_rd_tes_conf        => usb_rd_tes_conf,
            i_usb_rd_debug_ctrl      => usb_rd_debug_ctrl,
            i_usb_rd_errors0         => usb_rd_errors0,
            i_usb_rd_errors1         => usb_rd_errors1,
            i_usb_rd_status0         => usb_rd_status0,
            i_usb_rd_status1         => usb_rd_status1,
            ---------------------------------------------------------------------
            -- to the user @o_usb_clk
            ---------------------------------------------------------------------
            o_usb_clk                => usb_clk,
            o_usb_wr_fifo_valid      => usb_wr_fifo_valid,
            o_usb_wr_fifo            => usb_wr_fifo,
            o_usb_wr_valid_array     => usb_wr_valid_array,
            o_usb_wr_ctrl            => usb_wr_ctrl,
            o_usb_wr_make_pulse      => usb_wr_make_pulse,
            o_usb_wr_fpasim_gain     => usb_wr_fpasim_gain,
            o_usb_wr_mux_sq_fb_delay => usb_wr_mux_sq_fb_delay,
            o_usb_wr_amp_sq_of_delay => usb_wr_amp_sq_of_delay,
            o_usb_wr_error_delay     => usb_wr_error_delay,
            o_usb_wr_ra_delay        => usb_wr_ra_delay,
            o_usb_wr_tes_conf        => usb_wr_tes_conf,
            o_usb_wr_debug_ctrl      => usb_wr_debug_ctrl
        );

end architecture RTL;
