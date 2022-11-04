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
#    @file                   __init__.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    N/A
# -------------------------------------------------------------------------------------------------------------
#    @details                
#    This python script imports python module.
#    Note:
#      This is the first file to be loaded.
#      So you can use it to execute code that you want to run each time a module is loaded, 
#      or specify the submodules to be exported.
# -------------------------------------------------------------------------------------------------------------

import os
# Enable the coloring in the console
os.system("")

from common.console_colors import *
from common.filepath_list_builder import *
from common.display import Display
#########################################
# the following import order is important to
# avoid circular import
#########################################
from common.test.valid_sequencer import *
from common.test.vunit_conf import VunitConf
from common.test.tes_top_data_gen import TesTopDataGen



