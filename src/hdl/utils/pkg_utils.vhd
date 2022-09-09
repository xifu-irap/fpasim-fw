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
--!   @file                   pkg_utils.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
-- This package defines commonly used function/procedure
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.math_real.all;

PACKAGE pkg_utils IS

  ---------------------------------------------------------------------
  -- This function computes the minimal width bus necessary to represent a value
  --   res = ceil(log2(i_value))
  --   example:
  --     i_value = 16 => res = 4
  --     i_value = 8  => res = 3
  ---------------------------------------------------------------------
  function pkg_width_from_value(i_value : in integer) return integer;

  ---------------------------------------------------------------------
  -- This function generates a integer random_by_range value
  --  between i_min_value and i_max_value
  ---------------------------------------------------------------------
  function pkg_random_by_range(
    constant i_min_value : in integer;
    constant i_max_value : in integer
  ) return integer;

  ---------------------------------------------------------------------
  -- this function generates an uniform random value between min_value and max_value
  ---------------------------------------------------------------------
  procedure pkg_random_uniform_by_range(
    constant i_min_value : in integer;
    constant i_max_value : in integer;
    variable v_seed1     : inout positive;
    variable v_seed2     : inout positive;
    variable v_result    : inout integer
  );

END pkg_utils;

PACKAGE BODY pkg_utils IS

  ---------------------------------------------------------------------
  -- This function computes the minimal width bus necessary to represent a value
  --   res = ceil(log2(i_value))
  --   example:
  --     i_value = 16 => res = 4
  --     i_value = 8  => res = 3
  ---------------------------------------------------------------------
  function pkg_width_from_value(i_value : in integer) return integer is
    variable v_result : integer;
  begin
    v_result := integer(ceil(log2(real(i_value))));
    return v_result;
end;


  ---------------------------------------------------------------------
  -- This function generates an integer random value
  --  between i_min_value and i_max_value
  ---------------------------------------------------------------------
  function pkg_random_by_range (
    constant i_min_value : in integer;
    constant i_max_value : in integer
    ) return integer is
    variable v_rand_result : integer;
    variable v_seed1       : positive := 10;
    variable v_seed2       : positive := 1000;
  begin
    pkg_random_uniform_by_range(i_min_value, i_max_value, v_seed1, v_seed2, v_rand_result);
    return v_rand_result;
  end;

  ---------------------------------------------------------------------
  -- this function generates an uniform random value between min_value and max_value
  ---------------------------------------------------------------------
  procedure pkg_random_uniform_by_range (
    constant i_min_value : in integer;
    constant i_max_value : in integer;
    variable v_seed1   : inout positive;
    variable v_seed2   : inout positive;
    variable v_result  : inout integer
    ) is
    variable v_rand : real;
  begin
    -- generate a uniform real random_uniform_by_range value between [0;1.0]
    uniform(v_seed1, v_seed2, v_rand);
    -- Scale to a random_uniform_by_range integer between min_value and max_value
    v_result := integer(real(i_min_value) + trunc(v_rand*(1.0+real(i_max_value)-real(i_min_value))));
  end;

END pkg_utils;
