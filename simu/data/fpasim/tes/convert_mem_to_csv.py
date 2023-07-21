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
#    @file                   convert_mem_to_csv.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    N/A
# -------------------------------------------------------------------------------------------------------------
#    @details  
#
#    This script search the *.mem files in the src directory in order to generate the corresponding output csv files.
#       . The line number will be copied in the address column
#       . The line values will be copied in the data column
#    Note:
#      . This generated file will be used by the run python scripts during the VHDL simulation
#
# -------------------------------------------------------------------------------------------------------------

# standard library
import sys
import argparse
import os
from pathlib import Path
import math

# retrieve all python library path in order to import them
def find_file_in_hierarchy(filename_p='DONT_DELETE.txt', depth_level_p=10):
    """
    This function searches in this script parent directories, the filename_p parameter.
    If found, it returns the base path of the filename_p as well as its corresponding filepath

    Parameters
    ----------
    filename_p: str
            filename to search in the hierarchy
    depth_level_p: int
        (int >= 0) search depth limit

    Returns
    -------
    basepath, filepath: (string, string) (basepath of filename_p, filepath of filename_p) if found.
    Otherwise (None, None)
    
    """
    script_name0 = str(Path(__file__).stem)
    start_path = Path(__file__)
    ok = 0
    for i in range(depth_level_p):
        base_path = str(start_path.parents[i])
        filepath = str(Path(base_path, filename_p).resolve())
        exist = Path(filepath).is_file()
        if exist == True:
            ok = 1
            break
        else:
            continue
    if ok == 1:
        return base_path, filepath
    else:
        str0 = '[' + script_name0 + '] : ERRORS: the filename :' + filename_p + "wasn't found in the script hierarchy of " + str(
            start_path)
        print(str0)
        return None, None


############################################################################
# get the Project Root Path
#  because the DONT_DELETE.txt file is saved in the git repo root directory
############################################################################
root_path, _ = find_file_in_hierarchy(filename_p='DONT_DELETE.txt')

############################################################################
# add python common library
############################################################################
sys.path.append(str(Path(root_path, 'simu/lib/common')))
from common import Display
from common import FilepathListBuilder


def convert_hex_to_uint(input_filepath_p,output_filepath_p,ram_data_width_p=16):
    """
        This function convert hex string value into uint value

        Parameters
        ----------
        input_filepath_p: str
            input *.mem filepath with hex string value
        output_filepath_p: str
            output *.csv file
        ram_data_width_p: int
            data width of the ram (expressed in bits)

        Returns
        -------
            None

        """

    # read the *.mem file
    with open(input_filepath_p,'r') as fid:
        lines = fid.readlines()

    # skip first line (address line)
    lines = lines[1:]
    # compute address_width
    addr_width = str(math.ceil(math.log2(len(lines))))

    # write the *.csv output file
    with open(output_filepath_p,'w') as fid:
        index_max = len(lines) - 1
        for index,str_line in enumerate(lines):
            # delete end of line
            str_line = str_line.replace('\n','')
            # convert string hex into integer
            value = int(str_line,16)

            # convert integer into string
            str_line = str(value)

            # write the *.csv file header
            if index == 0:
                fid.write('offset_addr_uint'+str(addr_width)+'_t')
                fid.write(csv_separator)
                fid.write('data_uint'+str(ram_data_width_p)+'_t')
                fid.write('\n')
            # write data string to file
            fid.write(str(index))
            fid.write(csv_separator)
            fid.write(str_line)
            if index != index_max:
                fid.write('\n')


if __name__ == '__main__':

    # default csv file separator
    csv_separator = ';'
    

    ################################################
    # build the display object
    ################################################
    level0 = 0
    level1 = 1
    level2 = 2
    obj_display = Display()
    msg0 = 'Start Python Script: '+__file__
    obj_display.display_title(msg_p=msg0,level_p=level0)

    ##############################################
    # compute base path
    #   script
    #   *.mem file
    ##############################################
    script_base_path = str(Path(__file__).parents[0])
    src_base_path = str(Path(root_path,'src'))

    ##############################################
    # search tes_pulse_shape.mem file
    ##############################################
    search_obj = FilepathListBuilder()
    search_obj.set_file_extension(file_extension_list_p=['.mem'])

    # input file to search
    input_filename_list = []
    input_filename_list.append('tes_pulse_shape')

    for filename in input_filename_list:

        # get the path to the *.mem file
        input_filepath = search_obj.get_filepath_by_filename(basepath_p=src_base_path,filename_p=filename+'.mem')
        # compute the output filepath
        output_filepath = str(Path(script_base_path,filename+'.csv'))

        msg0 = 'Read input filepath: '+input_filepath
        obj_display.display(msg_p=msg0,level_p=level1)

        msg0 = 'Write output filepath: '+output_filepath
        obj_display.display(msg_p=msg0,level_p=level1)

        convert_hex_to_uint(input_filepath_p=input_filepath,output_filepath_p=output_filepath,ram_data_width_p=16)



    ##############################################
    # search mux_squid_offset.mem file
    ##############################################
    search_obj = FilepathListBuilder()
    search_obj.set_file_extension(file_extension_list_p=['.mem'])

    # input file to search
    input_filename_list = []
    input_filename_list.append('tes_std_state')

    for filename in input_filename_list:

        # get the path to the *.mem file
        input_filepath = search_obj.get_filepath_by_filename(basepath_p=src_base_path,filename_p=filename+'.mem')
        # compute the output filepath
        output_filepath = str(Path(script_base_path,filename+'.csv'))

        msg0 = 'Read input filepath: '+input_filepath
        obj_display.display(msg_p=msg0,level_p=level1)

        msg0 = 'Write output filepath: '+output_filepath
        obj_display.display(msg_p=msg0,level_p=level1)

        convert_hex_to_uint(input_filepath_p=input_filepath,output_filepath_p=output_filepath,ram_data_width_p=16)
