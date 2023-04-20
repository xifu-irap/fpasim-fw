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
#    @file                   file.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    N/A
# -------------------------------------------------------------------------------------------------------------
#    @details
#    
#    Note:
#       . This script was tested with python 3.10
# -------------------------------------------------------------------------------------------------------------


class File:
    """
    Extract the RAM content from csv file
    """
    def __init__(self, filepath_p):
        """
        Initialize the class instance.

        Parameters
        ----------
        filepath_p: str
            filepath
        """
        # filepath
        self._filepath = filepath_p
        # data list
        self._data_list = []
        # separator of the csv file
        self.csv_separator = ";"

    def run(self):
        """
        Extract the data part of a *.csv file
        Returns
        -------
        list of values
        """
        with open(self._filepath, 'r') as fid:
            lines = fid.readlines()
            nb_lines = len(lines)

            for i in range(nb_lines):
                line = lines[i]
                str_addr, str_data = line.split(self.csv_separator)
                # skip the header
                if i != 0:
                    self._data_list.append(int(str_data))

        return self._data_list

