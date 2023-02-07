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


# retrieve all python library path in order to import them
def find_file_in_hierarchy(filename_p='DONT_DELETE.txt', depth_level_p=10):
    """
    This function searches in this script parent directories, the filename_p parameter.
    If found, it returns the base path of the filename_p as well as its corresponding filepath
    :param filename_p: (string) filename to search in the hierarchy
    :param depth_level_p: (integer >= 0) search depth limit
    :return: base_path, filepath: (string, string) (base_path of filename_p, filepath of filename_p) if found.
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
root_path, _ = find_file_in_hierarchy()

############################################################################
# add python common library
############################################################################
path = str(Path(root_path, 'lib/common'))
sys.path.append(path)
from common import Display

if __name__ == '__main__':

    ############################################################################
    # parse command line
    ############################################################################
    parser = argparse.ArgumentParser(description='Launch some test_list')
    # add an optional argument with limited choices
    parser.add_argument('--simulator', '-s', default='questa', choices=['modelsim', 'questa'],
                        help='Specify the VHDL simulator to use (must be VHDL 2008 compatible).')
    # add an optional argument with a list of values
    parser.add_argument('--test_name_list', '-t', default=['test0_tb_system_fpasim'], nargs='*',
                        help='define a list of test_list name to simulate. These test_list names are defined in the launch_sim.json file')
    # add an optional argument 
    parser.add_argument('--display', default='False', choices=['True', 'False'],
                        help='Specify if the simulator is in gui mode or not. Possible values: true or false')
    # add an optional argument
    parser.add_argument('--verbosity','-v', default=0, choices=[0, 1, 2], type=int,
                        help='Specify the verbosity level. Possible values (uint): 0 to 2')

    args = parser.parse_args()

    simulator = args.simulator
    test_name_list = args.test_name_list
    display = args.display
    verbosity = args.verbosity

    ############################################################################
    # Search the Project Base Path: root of the git repository
    ############################################################################
    json_filepath_input = str(Path(root_path, 'launch_sim_processed.json').resolve())

    ############################################################################
    # build the display object
    ############################################################################
    level0 = 0
    level1 = 1
    level2 = 2
    obj_display = Display()
    msg0 = 'Start Python Script: ' + __file__
    obj_display.display_title(msg_p=msg0, level_p=level0)

    ############################################################################
    # get the file content
    ############################################################################
    # get the root path of this file
    root_path = str(Path(__file__).parent)

    # Opening JSON file
    fid_in = open(json_filepath_input, 'r')

    # returns JSON object as 
    # a dictionary
    json_data = json.load(fid_in)

    # Closing file
    fid_in.close()

    ############################################################################
    # display debug message
    ############################################################################
    if verbosity == 2:
        msg0 = 'Extract info from: ' + json_filepath_input
        obj_display.display(msg_p=msg0, level_p=level1, color_p='green')

    ############################################################################
    # Execute each individual test of a test_list
    ############################################################################
    for test_name in test_name_list:
        test_list = json_data.get(test_name)
        if test_list is None:
            msg0 = "ERROR: This " + test_name + " isn't defined in the json file (" + json_filepath_input +')'
            obj_display.display(msg_p=msg0, level_p=level1, color_p='red')
            break
        msg0 = 'Start: ' + test_name + ' test'
        obj_display.display_subtitle(msg_p=msg0, level_p=level1, color_p='yellow')
        # search in test_list a name with test_name value
        for dic in test_list:

            # extract parameter values from the json
            name = dic['name']
            run_file_path = str(Path(dic['vunit']['run_filepath']))
            output_path = str(Path(dic['vunit']['vunit_outpath']))
            tb_filename = str(Path(dic['vunit']['tb_filename']))
            wave_filename = str(Path(dic['vunit']['wave_filename']))
            conf_filename_list = dic['conf']['filename_list']

            # build a key to uniquely identify a test
            #   True if an individual test is listed only one time in the test_list
            json_key_path = test_name + '/' + name

            # build a unique test_report name
            #   True if an individual test is listed only one time in the test_list
            test_key = test_name + "__" + name
            report_filename = 'report__'+test_key+'.xml'
            report_path = str(Path(output_path, report_filename))

            # build a message
            msg_list = []
            msg_list.append('run_file_path           : ' + run_file_path)
            msg_list.append('output_path             : ' + output_path)
            msg_list.append('report_path             : ' + report_path)
            msg_list.append('test_list name          : ' + test_name)
            msg_list.append('individual test name    : ' + name)

            for msg in msg_list:
                obj_display.display(msg_p=msg, level_p=level2, color_p='green')

            ############################################################################
            # Call the simulation python script
            #  => Generate the list of argument
            ############################################################################
            cmd = []
            # call python
            cmd.append('python')

            # specify the simulation python script file to run
            cmd.append(run_file_path)

            # user arguments
            ############################################################################
            # specify the vhdl simulator to use
            cmd.append('--simulator')
            cmd.append(simulator)
            # # specify the verbosity
            cmd.append('--verbosity')
            cmd.append(str(verbosity))
            # specify if the display mode of the simulator is activated
            cmd.append('--display')
            cmd.append(display)
            # identify the test to run
            cmd.append('--json_key_path')
            cmd.append(json_key_path)

            # Vunit library arguments
            ############################################################################
            # define the Output path for compilation and simulation artifacts
            cmd.append('-o')
            cmd.append(output_path)

            # define the Xunit test report .xml file
            cmd.append('-x')
            cmd.append(report_path)

            # Only valid with –xunit-xml argument. 
            # Defines where in the XML file the simulator output is stored on a failure.
            # “jenkins” = Output stored in <system-out>, “bamboo” = Output stored in <failure>.
            cmd.append('--xunit-xml-format')
            cmd.append("jenkins")

            # Print test output immediately and not only when failure
            # Default: False
            cmd.append("-v")

            # Export project information to a JSON file.
            # cmd.append("--export-json")
            # cmd.append("compiled_file.json")

            # Only list all files in compile order
            # cmd.append("-f")


            if verbosity == 2:
                msg = 'generated command: ' + ' '.join(cmd)
                obj_display.display(msg_p=msg, level_p=level2, color_p='green')

            subprocess.run(cmd)
