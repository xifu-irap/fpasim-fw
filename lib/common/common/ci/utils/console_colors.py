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
#    
#    This class map a name to a console color code.   
#
# -------------------------------------------------------------------------------------------------------------

# standard library
import os

# Enable the coloring in the console
os.system("")


class ConsoleColors:
    """
    Map a name to a console color code.
    """
    def __init__(self):
        """
        Initialize the class instance.
        """
        self._colors = {}
        self._colors['black'] = '\033[30m'
        self._colors['red'] = '\033[31m'
        self._colors['green'] = '\033[32m'
        self._colors['orange'] = '\033[33m'
        self._colors['blue'] = '\033[34m'
        self._colors['purple'] = '\033[35m'
        self._colors['cyan'] = '\033[36m'
        self._colors['lightgrey'] = '\033[37m'
        self._colors['darkgrey'] = '\033[90m'
        self._colors['lightred'] = '\033[91m'
        self._colors['lightgreen'] = '\033[92m'
        self._colors['yellow'] = '\033[93m'
        self._colors['lightblue'] = '\033[94m'
        self._colors['pink'] = '\033[95m'
        self._colors['lightcyan'] = '\033[96m'
        self._colors['reset'] = '\033[0m'

    def get_color(self, name_p):
        """
        Get the console color value from the color name

        Parameters
        ----------
        name_p: str
            Color name

        Returns
        -------
        console color value

        """
        value = self._colors[name_p]
        if value is None:
            print(f"[ConsoleColors.get_colors]: KO: the colors {name_p} doesn't exist")
        return value

