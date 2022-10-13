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
#    @file                   launch_sim.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    N/A
# -------------------------------------------------------------------------------------------------------------
#    @details                
#    This scripts allows to select a vunit python run script 
# -------------------------------------------------------------------------------------------------------------
# standard library

import sys
import argparse
import os
from pathlib import Path
import subprocess

# Json lib
import json

# get the script name (without file extension)
script_name = str(Path(__file__).stem)


# retrieve all python library path in order to import them
def find_file_in_hierarchy(filename_p='DONT_DELETE.txt', depth_level_p=10):
    """
    This function searches in this script parent directories, the filename_p parameter.
    If found, it returns the base path of the filename_p as well as its corresponding filepath
    :param filename_p: (string) filename to search in the hierarchy
    :param depth_level_p: (integer >= 0) search depth limit
    :return: basepath, filepath: (string, string) (basepath of filename_p, filepath of filename_p) if found.
                                                  Otherwise (None, None)
    """
    script_name0 = str(Path(__file__).stem)
    start_path = Path(__file__)
    ok = 0
    for i in range(depth_level_p):
        basepath = str(start_path.parents[i])
        filepath = str(Path(basepath, filename_p).resolve())
        exist = Path(filepath).is_file()
        if exist == True:
            ok = 1
            break
        else:
            continue
    if ok == 1:
        return basepath, filepath
    else:
        msg = '[' + script_name0 + '] : ERRORS: the filename :' + filename_p + "wasn't found in the script hierarchy of " + str(start_path)
        print(msg)
        return None, None


if __name__ == '__main__':

    ####################################
    # parse command line
    ####################################
    parser = argparse.ArgumentParser(description='Launch some test_list')
    # add an optional argument with limited choices
    parser.add_argument('--simulator', '-s', default='questa', choices=['modelsim', 'questa'],
                        help='Specify the VHDL simulator to use (must be VHDL 2008 compatible).')
    # add an optional argument with a list of values
    parser.add_argument('--test_name_list', '-t', default='test_tmp', metavar='test_name_list', nargs='*',
                        help='define a list of test_list name to simulate. These test_list names are defined in the launch_sim.json file')
    # add an optional argument 
    parser.add_argument('--display', default='False', choices=['True', 'False'],
                        help='Specify if the simulator is in gui mode or not. Possible values: true or false')
    # add an optional argument
    parser.add_argument('-v', default=0, choices=[0, 1, 2], type=int,
                        help='Specify the verbosity level. Possible values (uint): 0 to 2')

    args = parser.parse_args()

    simulator = args.simulator
    test_name_list = args.test_name_list
    display = args.display
    verbosity = args.v
    sep = os.sep

    basepath, _ = find_file_in_hiearchy()

    json_filepath_input = str(Path(basepath, 'launch_sim_processed.json').resolve())

    # get the root path of this file
    root_path = str(Path(__file__).parent)

    # Opening JSON file
    fid_in = open(json_filepath_input, 'r')

    # returns JSON object as 
    # a dictionary
    json_data = json.load(fid_in)

    # Closing file
    fid_in.close()

    ########################################
    # display debug message
    ########################################
    if verbosity == 2:
        h0 = '*' * 20
        indent = ' ' * 4
        print(h0)
        print(indent + __file__ + ': processing in progress')
        print(indent * 2 + 'input file: ' + json_filepath_input)

    #########################################
    # Execute the sequence of test_list
    #########################################
    for test_name in test_name_list:
        test_list = json_data.get(test_name)
        if test_list is None:
            print("ERROR: No test list: " + test_name)
            break
        # search in test_list a name with test_name value
        for dic in test_list:
            vunit_file_path = str(Path(dic['vunit']['run_filepath']))
            output_path = str(Path(dic['vunit']['output_path']))
            report_path = str(Path(output_path, 'report.xml'))
            json_project_path = str(Path(output_path, 'project_info.json'))

            cmd = []
            # call python
            cmd.append('python')

            # specify the run file to launch
            cmd.append(vunit_file_path)

            # specify the vhdl simulator to use
            cmd.append('--simulator')
            cmd.append(simulator)
            # # specify the verbosity
            cmd.append('--verbosity')
            cmd.append(str(verbosity))
            # specify if the display mode of the simulator is activated
            cmd.append('--display')
            cmd.append(display)

            print('cmd_gui', display, 'type(cmd_gui)', type(display))

            cmd.append('-o')
            cmd.append(output_path)

            cmd.append('-x')
            cmd.append(report_path)

            # cmd.append('--export-json')
            # cmd.append(json_project_path)

            subprocess.run(cmd)
            continue
