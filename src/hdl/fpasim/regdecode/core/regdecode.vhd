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
--!   @file                   regdecode.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--

library ieee;
use ieee.std_logic_1164.all;


entity regdecode is
  port (
       i_clk : in std_logic;
       i_rst : in std_logic;
       
       ---------------------------------------------------------------------
       -- from/to Opal Kelly
       ---------------------------------------------------------------------

       -- from pipe_in
       ---------------------------------------------------------------------
       i_pipe_wr : in std_logic;
       i_pipe_data : in std_logic_vector(31 downto 0);

       -- to pipe_out
       ---------------------------------------------------------------------
       o_pipe_wr : out std_logic;
       o_pipe_data : out std_logic_vector(31 downto 0);

       -- to wire_out
       ---------------------------------------------------------------------
       o_pipe_data_count : out std_logic_vector(15 downto 0);

       -- from trig_in
       ---------------------------------------------------------------------
       i_rd_all_valid : in std_logic;
       i_reg_valid    : in std_logic;
       i_make_pulse_valid   : in std_logic;
       i_make_pulse_all_valid : in std_logic;
       i_ctrl_valid : in std_logic;
       i_debug_valid : in std_logic;

       -- from wire_in
       ---------------------------------------------------------------------



       ---------------------------------------------------------------------
       -- to trig_out
       ---------------------------------------------------------------------

       ---------------------------------------------------------------------
       -- from/to the user
       ---------------------------------------------------------------------

       -- to the user
       ---------------------------------------------------------------------




       -- from the user
       ---------------------------------------------------------------------
       
     ) ;
end entity regdecode;

architecture RTL of regdecode is


begin



end architecture RTL;