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
#    @file                   vunit_utils.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    N/A
# -------------------------------------------------------------------------------------------------------------
#    @details
#
#    The VunitUtils class defines shared methods.#
#    
#    Note:
#       . Used for the VHDL simulation.
#       . This script was tested with python 3.10
#       
#
# -------------------------------------------------------------------------------------------------------------

# standard library
import os
import shutil
from pathlib import Path


class VunitUtils:
    """
        Define common attributes and methods
    """

    def __init__(self, display_obj_p):
        """
        Initialize the class instance
        """
        # display object
        self.display_obj = display_obj_p
        # set indentation level (integer >=0)
        self.level = 0
        # set the level of verbosity
        self.verbosity = 0
        # path to the Xilinx mif files (for Xilinx RAM, ...)
        self.filepath_list_mif = None

    def set_indentation_level(self, level_p):
        """
        Set the indentation level of the print message
        Parameters
        ----------
        level_p: int
            (int >= 0) define the level of indentation of the message to print

        Returns
        -------
        None

        """
        self.level = level_p
        return None

    def set_verbosity(self, verbosity_p):
        """
        Set the level of verbosity
        Parameters
        ----------
        verbosity_p: int
            (int >=0) level of verbosity

        Returns
        -------
        None

        """
        self.verbosity = verbosity_p
        return None

    def get_indentation_level(self, level_p):
        """
        Select the indentation level to use.
        Note:
            If level_p is None, the class attribute is used. Otherwise, the level_p method argument is used

        Parameters
        ----------
        level_p: int
            (int >= 0) define the level of indentation of the message to print

        Returns
        -------
        int
            level of indentation of the message to print
        """
        level = level_p
        if level is None:
            return self.level
        else:
            return level

    def create_directory(self, path_p, level_p=None):
        """
        Create the directory tree defined by the "path" argument (if not exist)

        Parameters
        ----------
        path_p: str
            path to the directory to create
        level_p: int
            (int >= 0) define the level of indentation of the message to print

        Returns
        -------
        None

        """
        display_obj = self.display_obj
        level0 = self.get_indentation_level(level_p=level_p)
        level1 = level0 + 1

        if not os.path.exists(path_p):
            os.makedirs(path_p)
            msg0 = "Create Directory: "
            display_obj.display(msg_p=msg0, level_p=level0, color_p='green')
            msg0 = path_p
            display_obj.display(msg_p=msg0, level_p=level1, color_p='green')
        else:
            msg0 = "Warning: Directory already exists: "
            display_obj.display(msg_p=msg0, level_p=level0, color_p='yellow')
            msg0 = path_p
            display_obj.display(msg_p=msg0, level_p=level1, color_p='yellow')

        return None

    def set_mif_files(self, filepath_list_p):
        """
        Set a list of memory configuration files (*.mif, *.mem).

        Parameters
        ----------
        filepath_list_p: list of str
            filepath_list to set

        Returns
        -------
        None

        """
        self.filepath_list_mif = filepath_list_p
        return None

    def copy_mif_files(self, output_path_p, level_p=None):
        """
        Copy a list of memory configuration files (*.mif,*.mem,...) at @output_simulation_directory/modelsim
        Note:
            . To be visible by the modelsim/questa simulator, the files must be copied at
                "@output_simulation_directory/modelsim"

        Parameters
        ----------
        output_path_p: str
            output simulation path
        level_p: int
            (int >= 0) define the level of indentation of the message to print

        Returns
        -------
        None

        """
        display_obj = self.display_obj
        output_path = output_path_p
        level0 = self.get_indentation_level(level_p=level_p)
        level1 = level0 + 1

        # get absolute path
        script_path = Path(output_path).resolve()
        # move into the hierarchy : vunit_out/modelsim
        output_path = str(Path(script_path.parents[1], "modelsim"))

        # copy each files
        msg0 = "[VunitUtils.copy_mif_files]: Copy the IP init files into the Vunit output simulation directory"
        display_obj.display(msg_p=msg0, level_p=level0, color_p='green')
        for filepath in self.filepath_list_mif:
            msg0 = 'Copy: ' + filepath + " to " + output_path
            display_obj.display(msg_p=msg0, level_p=level1, color_p='green')
            shutil.copy(filepath, output_path)

        return None
