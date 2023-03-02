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
--    @file                   pkg_system_fpasim_debug.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--   @details                
--
--   This package defines all constants associated to the system_fpasim function and its sub-functions (debugging)
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.math_real.all;

package pkg_system_fpasim_debug is
  ---------------------------------------------------------------------
  -- system_fpasim
  ---------------------------------------------------------------------
  -- user-defined: true: to use Xilinx debugging modules (ILA, VIO,..), false: otherwise
  constant pkg_SYSTEM_FPASIM_TOP_DEBUG : boolean := false;

  ---------------------------------------------------------------------
  -- IOs
  ---------------------------------------------------------------------
  -- user-defined: true: to use Xilinx debugging modules (ILA, VIO,..), false: otherwise
  constant pkg_SPI_TOP_DEBUG : boolean := false;

  ---------------------------------------------------------------------
  -- fpasim_top/regdecode_top
  ---------------------------------------------------------------------
  -- user-defined: true: to use Xilinx debugging modules (ILA, VIO,..), false: otherwise
  constant pkg_FPASIM_TOP_DEBUG : boolean := false;

  ---------------------------------------------------------------------
  -- fpasim_top/regdecode_top
  ---------------------------------------------------------------------
  -- user-defined: true: to use Xilinx debugging modules (ILA, VIO,..), false: otherwise
  constant pkg_REGDECODE_TOP_DEBUG : boolean := false;




end pkg_system_fpasim_debug;

