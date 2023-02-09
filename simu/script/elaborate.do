# -------------------------------------------------------------------------------------------------------------
#                              Copyright (C) 2022-2030 Ken-ji de la Rosa, IRAP Toulouse.
# -------------------------------------------------------------------------------------------------------------
#                              This file is part of the ATHENA X-IFU DRE Focal Plane Assembly simulator.
#
#                              fpasim-fw is free software: you can redistribute it and/or modify
#                              it under the terms of the GNU General Public License as published by
#                              the Free Software Foundation, either version 3 of the License, or
#                              (at your option) any later version.
#
#                              This program is distributed in the hope that it will be useful,
#                              but WITHOUT ANY WARRANTY; without even the implied warranty of
#                              MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#                              GNU General Public License for more details.
#
#                              You should have received a copy of the GNU General Public License
#                              along with this program.  If not, see <https://www.gnu.org/licenses/>.
# -------------------------------------------------------------------------------------------------------------
#    email                   kenji.delarosa@alten.com
#    @file                   elaborate.do 
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
# -------------------------------------------------------------------------------------------------------------
#    @details                
#
#    This Modesim *.do file allows to do the following steps:
#      . link the external libraries and build the object to simulate
#
#    Note: This file is for illustration
#
# -------------------------------------------------------------------------------------------------------------


vopt +acc=npr -l elaborate.log -L xpm -L fpasim -L unisims_ver -L unimacro_ver -L secureip -work fpasim  fpasim.fpga_system_fpasim_top fpasim.glbl -o fpga_system_fpasim_top_opt