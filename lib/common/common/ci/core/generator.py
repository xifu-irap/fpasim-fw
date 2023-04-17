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
#    @file                   generator.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    N/A
# -------------------------------------------------------------------------------------------------------------
#    @details
#    
#    Note:
#       . This script was tested with python 3.10
# -------------------------------------------------------------------------------------------------------------

# import Point
from . import Point


class Generator:
    """
    Generate a list of Point instances with no attributes
    """
    def __init__(self, nb_pts_p):
        """
        Initialize the class instance.

        Parameters
        ----------
        nb_pts_p: int
            define the number of Point instances to generate
        """
        self._nb_pts = nb_pts_p
        self._obj_pts_list = []

    def run(self):
        """
        Generate a list of Point instances
        Returns
        -------
        list of Point instance
        """
        for i in range(self._nb_pts):
            obj_pt = Point()
            self._obj_pts_list.append(obj_pt)

        return self._obj_pts_list
