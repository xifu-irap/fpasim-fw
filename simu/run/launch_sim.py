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
path = str(Path(root_path, 'simu/lib/common'))
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
    parser.add_argument('--test_name_list', '-t', default=['tb_system_fpasim_top_test_variant_func00'], nargs='*',
                        help='define a test name or  list of test names (separated by space) to simulate. The test_section_dic of the launch_sim_processed.json file defines the available test name')
    # add an optional argument 
    parser.add_argument('--gui_mode', default='False', choices=['True', 'False'],
                        help='Specify if the simulator is in gui mode or not. Possible values: True or False')
    # add an optional argument
    parser.add_argument('--verbosity','-v', default=0, choices=[0, 1, 2], type=int,
                        help='Specify the verbosity level. Possible values (uint): 0 to 2')

    args_known = parser. parse_known_args()
    # get arguments defined in this file.
    args = args_known[0]
    # get arguments not defined in this file in order to pass them to the called script.
    args_unknown = args_known[1]

 
    simulator      = args.simulator
    test_name_list = args.test_name_list
    gui_mode       = args.gui_mode
    verbosity      = args.verbosity

    ############################################################################
    # Search the Project Base Path: root of the git repository
    ############################################################################
    json_filepath_input = str(Path(root_path, 'simu', 'launch_sim_processed.json').resolve())

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
        test_dic = json_data.get('test_section_dic')
        test_list = test_dic.get(test_name)
        if test_list is None:
            msg0 = "ERROR: This " + test_name + " isn't defined in the json file (" + json_filepath_input +')'
            obj_display.display(msg_p=msg0, level_p=level1, color_p='red')
            break
        msg0 = 'Run Test Name: ' + test_name
        obj_display.display_subtitle(msg_p=msg0, level_p=level1, color_p='yellow')

        # search in test_list a name with test_name value
        for test_id, dic in enumerate(test_list):

            # extract parameter values from the json
            tb_entity_name = dic['vunit']['tb_entity_name']
            run_file_path = str(Path(dic['vunit']['run_filepath']))
            output_path = str(Path(dic['vunit']['vunit_outpath']))
            tb_filename = str(Path(dic['vunit']['tb_filename']))
            wave_filename = str(Path(dic['vunit']['wave_filename']))
            test_variant_filename_list = dic['test_variant']['filename_list']

            # build a key to uniquely identify a test
            #   True if an individual test is listed only one time in the test_list
            json_key_path = test_name + '/' + str(test_id)

            # build a unique test_report name
            #   True if an individual test is listed only one time in the test_list
            test_key = test_name + "__test_id_" + '{0:04d}'.format(test_id)
            report_filename = 'report__'+test_key+'.xml'
            report_path = str(Path(output_path, report_filename))

            # build a message
            msg_list = []
            msg_list.append('test_id                     : ' + str(test_id))
            msg_list.append('test_name_list              : ' + test_name)
            msg_list.append('tb entity name              : ' + tb_entity_name)
            msg_list.append('test_variant_filename_list: : ' + ", ".join(dic['test_variant']["filename_list"]) )
            msg_list.append('run_file_path               : ' + run_file_path)
            msg_list.append('run_json_key                : ' + json_key_path)
            msg_list.append('output_simulation_path      : ' + output_path)
            msg_list.append('report_simulation_path      : ' + report_path)
            msg_list.append('')

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
            # specify if the gui_mode mode of the simulator is activated
            cmd.append('--gui_mode')
            cmd.append(gui_mode)

            # pass arguments not defined in this file.
            for str0 in args_unknown:
                cmd.append(str0)
          
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
            if verbosity > 1:
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
