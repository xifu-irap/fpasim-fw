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
#    @file                   FilepathListBuilder.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    N/A
# -------------------------------------------------------------------------------------------------------------
#    @details
#    This python script defines the FilepathListBuilder class.
#    This class provides methods to search files in a root directory and its subdirectory.
#    The searched files are filtered by user-defined file extension.
#
# -------------------------------------------------------------------------------------------------------------

# standard library
import os
from pathlib import Path

# user library
from .display import Display


class FilepathListBuilder:
    """
    Search files in directory and its subdirectories
    """

    def __init__(self):
        """
        Initialize the class instance.
        """
        # default authorized file extensions
        self._file_extension_list = ['.vhd', '.v', '.sv', '.vh']
        # list of filepath to find
        self._filepath_list = []
        # display object
        self._obj_display = Display()
        # set indentation level (integer >=0)
        self._level = 0

    def set_indentation_level(self, level_p):
        """
        set the indentation level of the print message
        Parameters
        ----------
        level_p: int
            (int >= 0): define the level of indentation of the message to print

        Returns
        -------
        None

        """
        self._level = level_p
        return None

    def _get_indentation_level(self, level_p):
        """
        Select the indentation level to use.
        Note:
            . If level_p is None, the class attribute is used. Otherwise, the level_p method argument is used

        Parameters
        ----------
        level_p: int
           (int >= 0) Define the level of indentation of the message to print.

        Returns
        -------
        indentation level value

        """

        level = level_p
        if level is None:
            return self._level
        else:
            return level

    def set_file_extension(self, file_extension_list_p):
        """
        Set the authorized file extension
        Parameters
        ----------
        file_extension_list_p: list of str
            list of the authorized file extension.
            ex: ['.vhd','.v']
        Returns
        -------
        None

        """
        self._file_extension_list = file_extension_list_p
        return None

    def add_basepath(self, basepath_p, requirement_filename_p=''):
        """
        This method has 2 modes:
            . if the requirement_filename_p isn't an empty string then
                1. search all requirement_filename_p files in the root directory (defined by basepath_p) and its subdirectories
                2. in each requirement_filename_p files, extracts the list of filename (with extension)
                3. build the corresponding filepaths
                Note: in a directory, a requirement_filename_p file lists only the authorized file of this directory
            . if the requirement_filename_p is an empty string then
                1. search all files in the root directory (defined by basepath_p) and its subdirectories
                2. filter files by extensions
                3. build the corresponding filepaths
        Parameters
        ----------
        basepath_p: str
            search path
        requirement_filename_p: str
            filename

        Returns
        -------
        None

        """
        file_extension_list = self._file_extension_list
        tmp_list = []
        for (root, dirs, file) in os.walk(basepath_p):
            if requirement_filename_p in file:
                #####################################
                # The requirement_filename exists
                #   1. extract only filenames of this file
                #   2. build its corresponding filepaths
                fid = open(requirement_filename_p, 'r')
                filename_list = fid.readlines()
                fid.close()
                for f in filename_list:
                    tmp_list.append(str(Path(root, f).resolve()))

            else:
                #####################################
                # The requirement_filename doesn't exist
                #   1. add all filenames of the directory
                #   2. build its corresponding filepaths
                for f in file:
                    extension = str(Path(f).suffix)
                    if extension in file_extension_list:
                        tmp_list.append(str(Path(root, f).resolve()))
        self._filepath_list.extend(tmp_list)

        return None

    def add_filepath(self, basepath_p, filename_p):
        """
        Add an individual filepath.

        Parameters
        ----------
        basepath_p: str
            base path of the file
        filename_p: str
            filename

        Returns
        -------
        None

        """
        self._filepath_list.append(str(Path(basepath_p, filename_p).resolve()))
        return None

    def add_filepath(self, filepath_p):
        """
        Add an individual filepath.

        Parameters
        ----------
        filepath_p: str
            filepath

        Returns
        -------
        None.

        """
        self._filepath_list.append(str(Path(filepath_p).resolve()))
        return None

    def get_filepath_list(self):
        """
        Get the computed filepath list

        Returns
        -------
        list of filepath
        """
        return self._filepath_list

    def get_filepath_by_filename(self, basepath_p, filename_p, level_p=None):
        """
        Search in the directory defined by basepath_p as well as its subdirectories a file with
        the filename_p name.

        Parameters
        ----------
        basepath_p: str
            define the search base path
        filename_p: str
            filename to search
        level_p: int
            level of indentation of the print message

        Returns
        -------
            If the filename_p is found then the filepath is returned. Otherwise, None
        """

        file_extension_list = self._file_extension_list
        obj_display = self._obj_display
        file_extension_list = self._file_extension_list
        level0 = self._get_indentation_level(level_p=level_p)

        base_path = str(Path(basepath_p).resolve())

        tmp_filepath_list = []
        for (root, dirs, file) in os.walk(base_path):
            #####################################
            # The requirement_filename doesn't exist
            #   1. add all filenames of the directory and its subdirectories
            #   2. build its corresponding filepaths
            for f in file:
                extension = str(Path(f).suffix)
                if extension in file_extension_list:
                    tmp_filepath_list.append(str(Path(root, f).resolve()))

        tmp_filepath = None
        for filepath in tmp_filepath_list:
            filename = Path(filepath).name
            if filename == filename_p:
                tmp_filepath = filepath
                break

        if tmp_filepath is None:
            str0 = "ERROR: FilepathListBuilder.get_filepath_by_filename:"
            str1 = "  searched file_extension_list_p=" + ' '.join(file_extension_list)
            str2 = "  the filename_p=" + filename_p + " is not found in the director/subdirectories of " + basepath_p
            obj_display.display(msg_p=str0, color_p='red', level_p=level0)
            obj_display.display(msg_p=str1, color_p='red', level_p=level0)
            obj_display.display(msg_p=str2, color_p='red', level_p=level0)
            pass

        return tmp_filepath
