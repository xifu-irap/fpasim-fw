
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
#    This script search files in a root directory and its sub-directory in order to build the corresponding filepath
#    The searched files are filtered by file_extension.
# -------------------------------------------------------------------------------------------------------------
import os
from pathlib import Path

class FilepathListBuilder():
    '''
    
    '''
    def __init__(self):
        # default authorized file extensions
        self.file_extension_list = ['.vhd','.v','.sv','.vh']
        self.filepath_list = []
    def set_file_extension(self,file_extension_list_p):
        '''
        This method overwrites the authorized file extension list
        :param file_extension_list_p: (string list) list of the authorized file extension  :return:
        '''
        self.file_extension_list = file_extension_list_p
    def add_basepath(self,basepath_p,requirement_filename_p=''):
        '''
        This method has 2 modes:
            . if the requirement_filename_p isn't an empty string then
                1. searchs all requirement_filename_p files in the root directory (defined by basepath_p) and its sub-directories
                2. in each requirement_filename_p files, extracts the list of filename (with extension)
                3. build the corresponding filepaths
                Note: in a directory, a requirement_filename_p file lists only the authorized file of this directory
            . if the requirement_filename_p is an empty string then
                1. search all files in the root directory (defined by basepath_p) and its sub-directories
                2. filter files by extensions
                3. build the corresponding filepaths
        :param basepath_p: (string) search path of the root directory
        :param requirement_filename_p: (string)
        :return:
        '''
        file_extension_list = self.file_extension_list
        tmp_list = []
        for (root, dirs, file) in os.walk(basepath_p):
            if requirement_filename_p in file:
            #####################################
            # The requirement_filename exists
            #   1. extract only filenames of this file
            #   2. build its corresponding filepaths
                fid = open(requirement_filename_p,'r')
                filename_list = fid.readlines()
                fid.close()
                for f in filename_list:
                    tmp_list.append(str(Path(root,f).resolve()))

            else:
                #####################################
                # The requirement_filename doesn' exist
                #   1. add all filenames of the directory
                #   2. build its corresponding filepaths
                for f in file:
                    extension = str(Path(f).suffix)
                    if extension in file_extension_list:
                        tmp_list.append(str(Path(root,f).resolve()))
        self.filepath_list.extend(tmp_list)

    def add_filepath(self,basepath_p,filename_p):
        '''
        This method adds an individual filepath
        :param basepath_p:(string) base path of the file
        :param filename_p:(string) filename
        :return:
        '''
        self.filepath_list.append(str(Path(basepath_p,filename_p).resolve()))

    def add_filepath(self,filepath_p):
        '''
        This method adds an individual filepath
        :param filepath_p:(string) filepath to add
        :return:
        '''
        self.filepath_list.append(str(Path(filepath_p).resolve()))

    def get_filepath_list(self):
        '''
        This method returns the computed filepath list
        :return: (string list) list of computed filepath
        '''
        return self.filepath_list       
