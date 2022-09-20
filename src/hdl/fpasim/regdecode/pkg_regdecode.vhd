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
--!   @file                   pkg_regdecode.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--
-- This package defines all constants used by the redecode function. 
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

PACKAGE pkg_regdecode IS

  -------------------------------------------------------------------
  -- pipe
  -------------------------------------------------------------------
  -- user-defined: address width of the register 
  constant pkg_REG_ADDR_WIDTH : positive := 16;

  -- user-defined : minimal address value associated to the tes_pulse_shape ram
  constant pkg_TES_PULSE_SHAPE_ADDR_RANGE_MIN : std_logic_vector(pkg_REG_ADDR_WIDTH - 1 downto 0) := x"0000";
  -- user-defined : maximal address value associated to the tes_pulse_shape ram
  constant pkg_TES_PULSE_SHAPE_ADDR_RANGE_MAX : std_logic_vector(pkg_REG_ADDR_WIDTH - 1 downto 0) := x"7FFF";

  -- user-defined : minimal address value associated to the amp_squid_tf ram
  constant pkg_AMP_SQUID_TF_ADDR_RANGE_MIN : std_logic_vector(pkg_REG_ADDR_WIDTH - 1 downto 0) := x"8000";
  -- user-defined : maximal address value associated to the amp_squid_tf ram
  constant pkg_AMP_SQUID_TF_ADDR_RANGE_MAX : std_logic_vector(pkg_REG_ADDR_WIDTH - 1 downto 0) := x"BFFF";

  -- user-defined : minimal address value associated to the mux_squid_tf ram
  constant pkg_MUX_SQUID_TF_ADDR_RANGE_MIN : std_logic_vector(pkg_REG_ADDR_WIDTH - 1 downto 0) := x"C000";
  -- user-defined : maximal address value associated to the mux_squid_tf ram
  constant pkg_MUX_SQUID_TF_ADDR_RANGE_MAX : std_logic_vector(pkg_REG_ADDR_WIDTH - 1 downto 0) := x"DFFF";

  -- user-defined : minimal address value associated to the tes_std_state ram
  constant pkg_TES_STD_STATE_ADDR_RANGE_MIN : std_logic_vector(pkg_REG_ADDR_WIDTH - 1 downto 0) := x"E000";
  -- user-defined : maximal address value associated to the tes_std_state ram
  constant pkg_TES_STD_STATE_ADDR_RANGE_MAX : std_logic_vector(pkg_REG_ADDR_WIDTH - 1 downto 0) := x"E03F";

  -- user-defined : minimal address value associated to the mux_squid_offset ram
  constant pkg_MUX_SQUID_OFFSET_ADDR_RANGE_MIN : std_logic_vector(pkg_REG_ADDR_WIDTH - 1 downto 0) := x"E000";
  -- user-defined : maximal address value associated to the mux_squid_offset ram
  constant pkg_MUX_SQUID_OFFSET_ADDR_RANGE_MAX : std_logic_vector(pkg_REG_ADDR_WIDTH - 1 downto 0) := x"E03F";

END pkg_regdecode;

