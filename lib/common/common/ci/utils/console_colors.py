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
#    This python defines colors which can be printed in the cmd/powershell console
#
# -------------------------------------------------------------------------------------------------------------

# standard library
import os

# Enable the coloring in the console
os.system("")


class ConsoleColors:
    def __init__(self):
        self.colors = {}
        self.colors['black'] = '\033[30m'
        self.colors['red'] = '\033[31m'
        self.colors['green'] = '\033[32m'
        self.colors['orange'] = '\033[33m'
        self.colors['blue'] = '\033[34m'
        self.colors['purple'] = '\033[35m'
        self.colors['cyan'] = '\033[36m'
        self.colors['lightgrey'] = '\033[37m'
        self.colors['darkgrey'] = '\033[90m'
        self.colors['lightred'] = '\033[91m'
        self.colors['lightgreen'] = '\033[92m'
        self.colors['yellow'] = '\033[93m'
        self.colors['lightblue'] = '\033[94m'
        self.colors['pink'] = '\033[95m'
        self.colors['lightcyan'] = '\033[96m'
        self.colors['reset'] = '\033[0m'

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
        value = self.colors[name_p]
        if value is None:
            print(f"[ConsoleColors.get_colors]: KO: the colors {name_p} doesn't exist")
        return value

