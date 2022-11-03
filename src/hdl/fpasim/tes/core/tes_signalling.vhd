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
--!   @file                   tes_signalling.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--
-- This module generates:
--   . pixel id 
--   . pixel delimiters
--      . pixel_sof: first pixel sample
--      . pixel_eof: last pixel sample
--   . frame id
--   . frame delimiters
--      . frame_sof: first frame sample
--      . frame_eof: last frame sample
--
-- Note: the generation is driven by the i_data_valid signal
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fpasim;
use fpasim.pkg_fpasim.all;

entity tes_signalling is
    generic(
        -- pixel
        g_PIXEL_LENGTH_WIDTH : positive := 6; -- bus width in order to define the number of samples by pixel
        g_PIXEL_ID_WIDTH     : positive := pkg_PIXEL_ID_WIDTH_MAX; -- pixel id bus width (expressed in bits). Possible values [1;max integer value[

        -- frame
        g_FRAME_LENGTH_WIDTH : positive := 11; -- bus width in order to define the number of samples by frame
        g_FRAME_ID_WIDTH     : positive := pkg_FRAME_ID_WIDTH -- frame id bus width (expressed in bits). Possible values [1;max integer value[
    );
    port(
        i_clk          : in  std_logic; -- clock signal
        i_rst          : in  std_logic; -- reset signal

        ---------------------------------------------------------------------
        -- Commands
        ---------------------------------------------------------------------
        i_start        : in  std_logic; -- start the signalling generation
        i_pixel_length : in  std_logic_vector(g_PIXEL_LENGTH_WIDTH - 1 downto 0); -- number of samples by pixel
        i_pixel_nb     : in  std_logic_vector(g_PIXEL_ID_WIDTH - 1 downto 0);     -- number of pixel
        i_frame_length : in  std_logic_vector(g_FRAME_LENGTH_WIDTH - 1 downto 0); -- number of samples by frame
        i_frame_nb     : in std_logic_vector(g_FRAME_ID_WIDTH - 1 downto 0); -- number of frames by series
        ---------------------------------------------------------------------
        -- Input data
        ---------------------------------------------------------------------
        i_data_valid   : in  std_logic; -- valid input data

        ---------------------------------------------------------------------
        -- Output data
        ---------------------------------------------------------------------
        o_pixel_sof    : out std_logic; -- first pixel sample
        o_pixel_eof    : out std_logic; -- last pixel sample
        o_pixel_id     : out std_logic_vector(g_PIXEL_ID_WIDTH - 1 downto 0); -- pixel id
        o_pixel_valid  : out std_logic; -- valid pixel

        o_frame_sof    : out std_logic; -- first frame sample
        o_frame_eof    : out std_logic; -- last frame sample
        o_frame_id     : out std_logic_vector(g_FRAME_ID_WIDTH - 1 downto 0) -- frame id
    );
end entity tes_signalling;

architecture RTL of tes_signalling is
    -- frame
    
    constant c_NB_PIPES_OUT  : integer                            := pkg_TES_SIGNALLING_GENERATOR_OUT_LATENCY;
    ---------------------------------------------------------------------
    -- pixel signalling
    ---------------------------------------------------------------------
    signal pixel_sof         : std_logic;
    signal pixel_eof         : std_logic;
    signal pixel_valid       : std_logic;
    signal pixel_id          : std_logic_vector(o_pixel_id'range);

    ---------------------------------------------------------------------
    -- frame signalling
    ---------------------------------------------------------------------
    signal frame_sof : std_logic;
    signal frame_eof : std_logic;
    signal frame_id  : std_logic_vector(o_frame_id'range);

begin

    ---------------------------------------------------------------------
    -- pixel: flags generation
    ---------------------------------------------------------------------
    inst_tes_signalling_pixel : entity fpasim.tes_signalling_generator
        generic map(
            g_LENGTH_WIDTH => i_pixel_length'length,
            g_ID_WIDTH     => i_pixel_nb'length,
            -- number of the output registers
            g_LATENCY_OUT  => c_NB_PIPES_OUT
        )
        port map(
            i_clk        => i_clk,
            i_rst        => i_rst,
            ---------------------------------------------------------------------
            -- Commands
            ---------------------------------------------------------------------
            i_start      => i_start,
            i_length     => i_pixel_length,
            i_id_size    => i_pixel_nb,
            ---------------------------------------------------------------------
            -- Input data
            ---------------------------------------------------------------------
            i_data_valid => i_data_valid,
            ---------------------------------------------------------------------
            -- Output data
            ---------------------------------------------------------------------
            o_sof        => pixel_sof,
            o_eof        => pixel_eof,
            o_id         => pixel_id,
            o_data_valid => pixel_valid
        );

    ---------------------------------------------------------------------
    -- frame: flags generation
    ---------------------------------------------------------------------
    inst_tes_signalling_frame : entity fpasim.tes_signalling_generator
        generic map(
            g_LENGTH_WIDTH => i_frame_length'length,
            g_ID_WIDTH     => i_frame_nb'length,
            -- number of the output registers
            g_LATENCY_OUT  => c_NB_PIPES_OUT
        )
        port map(
            i_clk        => i_clk,
            i_rst        => i_rst,
            ---------------------------------------------------------------------
            -- Commands
            ---------------------------------------------------------------------
            i_start      => i_start,
            i_length     => i_frame_length,
            i_id_size    => i_frame_nb,
            ---------------------------------------------------------------------
            -- Input data
            ---------------------------------------------------------------------
            i_data_valid => i_data_valid,
            ---------------------------------------------------------------------
            -- Output data
            ---------------------------------------------------------------------
            o_sof        => frame_sof,
            o_eof        => frame_eof,
            o_id         => frame_id,
            o_data_valid => open
        );

    ---------------------------------------------------------------------
    -- outputs
    ---------------------------------------------------------------------
    o_pixel_sof   <= pixel_sof;
    o_pixel_eof   <= pixel_eof;
    o_pixel_id    <= pixel_id;
    o_pixel_valid <= pixel_valid;

    o_frame_sof <= frame_sof;
    o_frame_eof <= frame_eof;
    o_frame_id  <= frame_id;

end architecture RTL;
