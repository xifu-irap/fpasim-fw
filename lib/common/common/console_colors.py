# -*- coding: utf-8 -*-
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
#    @file                   console_colors.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    N/A
# -------------------------------------------------------------------------------------------------------------
#    @details                
#    This python script defines the console print colors
#
# -------------------------------------------------------------------------------------------------------------

import os
# Enable the coloring in the console
os.system("")

colors = {}
colors['black'] = '\033[30m'
colors['red'] = '\033[31m'
colors['green'] = '\033[32m'
colors['orange'] = '\033[33m'
colors['blue'] = '\033[34m'
colors['purple'] = '\033[35m'
colors['cyan'] = '\033[36m'
colors['lightgrey'] = '\033[37m'
colors['darkgrey'] = '\033[90m'
colors['lightred'] = '\033[91m'
colors['lightgreen'] = '\033[92m'
colors['yellow'] = '\033[93m'
colors['lightblue'] = '\033[94m'
colors['pink'] = '\033[95m'
colors['lightcyan'] = '\033[96m'
colors['reset'] = '\033[0m'

