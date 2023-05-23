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
#    @file                   oversample.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    N/A
# -------------------------------------------------------------------------------------------------------------
#    @details
#    
#    This OverSample class oversamples an input list of Point instances by duplicating each Point instance.
#
#
#    Note:
#       . Used for the VHDL simulation.
#       . This class can be instanciated by the user.
#       . It should be instanciated after:
#            . Generator class
#       . This script was tested with python 3.10
#
# -------------------------------------------------------------------------------------------------------------

# standard library
import random
import copy

# user library
from . import Points


class OverSample(Points):
    """
    Apply an oversampling factor on an input list of Point instances.
    """
    def __init__(self, pts_list_p):
        """
        Initialize the class instance.

        Parameters
        ----------
        pts_list_p: list of Point instance.
            Define a list of Point instance.

        """
        super().__init__(pts_list_p=pts_list_p)

        self._oversampling_value = None

    def set_oversampling(self, value_p):
        """
        Define the number of oversampled Point instances.

        Parameters
        ----------
        value_p: int
            number of oversampled point. 
            value_p must be in the range [1; max_integer value].
                with 1: no oversampled point.

        Returns
        -------
            None

        """
        if value_p < 1:
            print("[OverSample.set_oversampling]: value_p should be >= 1, value_p is forced to 1")
            value = 1
        else:
            value = value_p
        self._oversampling_value = value
        return None

    def run(self):
        """
        Generate a list of oversampled Point instances.

        Returns 
        -------
            list of oversampled Point instances.

        """
        res = []
        for obj_pt in self._pts_list:
            for i in range(self._oversampling_value):
                # do a true object copy.
                # Otherwise, the object is shared between several elements of the list
                copy_pt = copy.deepcopy(obj_pt)
                res.append(copy_pt)
        return res
