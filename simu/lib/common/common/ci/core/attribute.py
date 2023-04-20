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
#    @file                   attribute.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    N/A
# -------------------------------------------------------------------------------------------------------------
#    @details
#
#    This class process a list of point instances.
#    For each point instance, we create:
#       a attribute with constant value or
#       a attribute with an incremental value or
#       a attribute with a random value or
#
#    Note:
#       . This script was tested with python 3.10
# -------------------------------------------------------------------------------------------------------------

# standard library
import random

# user library
from . import Points


class Attribute(Points):
    """
    Generate an attribute (name,value) on each point of a list of Points Instances
    """
    def __init__(self, pts_list_p):
        """
        Initialize the class instance.

        Parameters
        ----------
        pts_list_p: Point object list
            Defines a list of Point instances.

        """
        super().__init__(pts_list_p=pts_list_p)
        # attribute name
        self._attr_name = ""
        # Select a mode of attribute generation
        self._mode = 0
        # define the mininum value 
        self._min_value = 0
        # define the maximal value 
        self._max_value = 0
        # define the next value
        self._next_value = 0
        # define the new value
        self._new_value = 0
        # Select the method of generation
        self._id = 0
        # Define the first iteration
        self._first = 1

    @staticmethod
    def set_random_seed(value_p):
        """
        Set the seed of the random generator

        Parameters
        ----------
        value_p: int
            Seed value

        Returns
        -------

        """
        random.seed(value_p)

    def set_attribute2(self, name_p, value_p):
        """
        Set an attribute name with a constant value

        Parameters
        ----------
        name_p: str
            Define the attribute name to set
        value_p: int, float,...
            Define the attribute value to set

        Returns
        -------
        None

        """
        self._id = 0
        self._attr_name = name_p
        self._new_value = value_p

    def set_attribute(self, name_p, mode_p, min_value_p, max_value_p):
        """
        Set an attribute name with an incremental/random value.

        Parameters
        ----------
        name_p: str
            Define the attribute name to set
        mode_p: int
            Define how the output value is computed. 0: incremental value, 1: random value
        min_value_p: int
            Define the minimal value
        max_value_p: int
            Define the maximal value

        Returns
        -------
        None

        """
        self._id = 1
        self._attr_name = name_p
        self._mode = mode_p
        self._min_value = min_value_p
        self._max_value = max_value_p

    def _compute(self):
        """
        Compute an incremental value or a random value.

        Returns
        -------
        computed value.

        """
        if self._mode == 0:
            # compute an incremental value
            if self._first == 1:
                self._first = 0
                new_value = self._min_value
            else:
                new_value = self._next_value

            if new_value == self._max_value:
                next_value = self._min_value
            else:
                next_value = new_value + 1
            self._next_value = next_value
            self._new_value = new_value

        elif self._mode == 1:
            # compute a random value
            new_value = random.randint(self._min_value, self._max_value)
            self._new_value = new_value

        return new_value

    def run(self):
        """
        For each Point instance, generate an attribute (name, value)
        Returns
        -------

        """
        for pts in self._pts_list:
            if self._id == 0:
                pts.set_attribute(name_p=self._attr_name, value_p=self._new_value)
            elif self._id == 1:
                value = self._compute()
                pts.set_attribute(name_p=self._attr_name, value_p=value)

        return self._pts_list
