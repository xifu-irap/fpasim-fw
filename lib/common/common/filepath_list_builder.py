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

import os
from pathlib import Path
from common.display import *


class FilepathListBuilder:
    """
    This class provides methods to search files in directory and subdirectories
    Note:
        The searched files can be filtered by file extension
        Method name starting by '_' are local to the class (ex:def _toto(...)).
        It should not be usually used by the user
    """
    def __init__(self):
        """
        This method initializes the class instance
        """
        # default authorized file extensions
        self.file_extension_list = ['.vhd', '.v', '.sv', '.vh']
        self.filepath_list = []
        # display object
        self.obj_display = Display()
        # set indentation level (integer >=0)
        self.level = 0

    def set_indentation_level(self, level_p):
        """
        This method set the indentation level of the print message
        :param level_p: (integer >= 0) define the level of indentation of the message to print
        :return: None
        """
        self.level = level_p
        return None

    def _get_indentation_level(self, level_p):
        """
        This method select the indentation level to use.
        If level_p is None, the class attribute is used. Otherwise, the level_p method argument is used
        :param level_p: (integer >= 0) define the level of indentation of the message to print
        :return: (integer >=0) level of indentation of the message to print
        """
        level = level_p
        if level is None:
            return self.level
        else:
            return level

    def set_file_extension(self, file_extension_list_p):
        """
        This method set the authorized file extension
        :param file_extension_list_p: (list of string) list of the authorized file extension
        ex: file_extension_list_p=['.vhd','.v']
        :return: None
        """
        self.file_extension_list = file_extension_list_p
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
        :param basepath_p: (string) search path
        :param requirement_filename_p: (string) filename
        :return: None
        """

        file_extension_list = self.file_extension_list
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
                        tmp_list.append(str(Path(root,f).resolve()))
        self.filepath_list.extend(tmp_list)

        return None

    def add_filepath(self, basepath_p, filename_p):
        """
        This method adds an individual filepath
        :param basepath_p: (string) base path of the file
        :param filename_p: (string) filename
        :return: None
        """
        self.filepath_list.append(str(Path(basepath_p, filename_p).resolve()))
        return None

    def add_filepath(self, filepath_p):
        """
        This method adds an individual filepath
        :param filepath_p: (string) filepath to add
        :return: None
        """
        self.filepath_list.append(str(Path(filepath_p).resolve()))
        return None

    def get_filepath_list(self):
        """
        This method returns the computed filepath list
        :return: (list of string) list of filepath
        """
        return self.filepath_list   

    def get_filepath_by_filename(self, basepath_p, filename_p, level_p=None):
        """
        This method search in the directory defined by basepath_p as well as its subdirectories a file with
        the filename_p name
        Note: the search stops at the first match
        :param basepath_p: (string) define the search base path
        :param filename_p: (string) filename to search
        :return: (string/None)
           If the filename_p is found then the filepath is returned. Otherwise, None
        """

        file_extension_list = self.file_extension_list
        obj_display         = self.obj_display
        file_extension_list = self.file_extension_list
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
            str1 = "  searched file_extension_list_p="+' '.join(file_extension_list)
            str2 = "  the filename_p=" + filename_p + " is not found in the director/subdirectories of " + basepath_p
            obj_display.display(msg_p=str0,color_p='red',level_p=level0)
            obj_display.display(msg_p=str1,color_p='red',level_p=level0)
            obj_display.display(msg_p=str2,color_p='red',level_p=level0)
            pass
        
        return tmp_filepath



