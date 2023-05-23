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
#    @file                   points.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    N/A
# -------------------------------------------------------------------------------------------------------------
#    @details
#
#    The class Point stores a list of Points Instance.
#
#    Note:
#       . Used for the VHDL simulation.
#       . The user shouln't directly instanciate this class.
#       . This script was tested with python 3.10
#
# -------------------------------------------------------------------------------------------------------------


class Points:
    """
    Store a list of Point instances.
    """
    def __init__(self, pts_list_p):
        """
        Initialize the class instance.

        Parameters
        ----------
        pts_list_p: list of Point object.
            Defines a list of Point instances.

        """
        self._pts_list = pts_list_p
