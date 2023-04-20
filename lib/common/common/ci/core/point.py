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
#    @file                   point.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    N/A
# -------------------------------------------------------------------------------------------------------------
#    @details
#
#    The class Point defines a container for point attributes
#    Each point can represent a data sample
#
#    Note:
#       . This script was tested with python 3.10
# -------------------------------------------------------------------------------------------------------------

class Point:
    """
    Define a Point instance
    """
    def __init__(self):
        """
        Initialize the class instance.
        """

        # dictionary of point attribute
        self._attribute_dic = {}
        # debug message: 0: no print, 1: print a message
        self._verbosity = 0

    def set_verbosity(self, verbosity_p):
        """
        Set the level of _verbosity for the message display.

        Parameters
        ----------
        verbosity_p: int
            Define the level of _verbosity. 0: no print, 1: print.

        Returns
        -------
        None

        """
        self._verbosity = verbosity_p

    def set_attribute(self, name_p, value_p):
        """
        Set an attribute: (name, value).
        Note: If the attribute name doesn't exist, the attribute name is created.

        Parameters
        ----------
        name_p: str
            Define the Attribute name
        value_p: int, float, str
            Define the Attribute value

        Returns
        -------
        None

        """
        self._attribute_dic[name_p] = value_p
        if self._verbosity == 1:
            print("[Point.set_attribute]: ", name_p, ":", value_p)

    def get_attribute(self, name_p):
        """
        Get an attribute value from an attribute name.
        Note:
            if the attribute name doesn't exist, an error message is printed.

        Parameters
        ----------
        name_p: str
            attribute name to use in order to retrieve the attribute value

        Returns
        -------
            The attribute value

        """
        value = self._attribute_dic.get(name_p)
        if value is None:
            print('[Point.get_attribute]: no Key: ' + name_p)
        return value

    def delete_attribute(self, name_p):
        """
        Delete an attribute by name.
        Note: If the attribute doesn't exist, an error is printed.

        Parameters
        ----------
        name_p: str
            attribute name to delete

        Returns
        -------
        None


        """
        try:
            self._attribute_dic.pop(name_p)
        finally:
            print('[Point.delete_attribute]: no Key: ' + name_p)

    def get_info(self, *name_p):
        """
        Format the input (name,value) attribute list.

        Parameters
        ----------
        name_p: str
            Variable length attribute name list.

        Returns
        -------
        str

        """
        str_list = []

        for name in name_p:
            value = self.get_attribute(name_p=name)
            str_list.append(name + ":" + str(value))

        return ', '.join(str_list)


