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
#    @file                   run_tb_system_fpasim_top.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    
# -------------------------------------------------------------------------------------------------------------
#    @details         
#
#     This script performs the necessary steps to launch the VHDL simulation.
#     The main steps are:
#        . compilation of the VHDL libraries.
#        . compilation of the VHDL source files.
#        . compilation of the VHDL testbench file.
#        . Set the waveform (if exists).
#        . Set the configuration memory files (if exist).
#        . loop on the *.json file (test variant).
#        . run the selected VHDL simulator.
#               
#     Note: 
#       . Used for the VHDL simulation.
#       . This script should be called by the launch_sim.py python script. But, it can be run in standalone.
#
# -------------------------------------------------------------------------------------------------------------

# standard library
import os
# Enable the coloring in the console
os.system("")
import sys
import argparse
from pathlib import Path
from pathlib import PurePosixPath
import json

# get the name of the script name without file extension
script_name = str(Path(__file__).stem)


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


# retrieve all python library path in order to import them
def get_python_library_from_json_file(filepath_p):
    """
    Get the path to the simulation python libraries.

    Parameters
    ----------
    filepath_p: str
        configuration json filepath (test variant)

    Returns: list of str.
    -------
        list of path.
    """

    filepath = filepath_p
    # Opening JSON file
    fid = open(filepath,'r')
    # returns JSON object as 
    # a dictionary
    json_data = json.load(fid)
    # Closing file
    fid.close()

    python_lib_dic = json_data["lib"]["python"]
    path_list = []
    for key in python_lib_dic.keys():
        tmp_path_list = python_lib_dic[key]['directory_path_list']
        for path in tmp_path_list:
            path0 = str(Path(path).resolve())
            path_list.append(path0)

    return path_list

#################################################################
# loop on the project python library path (dynamically computed)
#   1. add path to the python path
#   => project specific python library can now be imported
#################################################################
root_path,filepath = find_file_in_hierarchy()
json_filepath = str(Path(root_path,'simu','./launch_sim_processed.json').resolve())
path_list = get_python_library_from_json_file(filepath_p=json_filepath)
if path_list != None:
    for path in path_list:
        sys.path.append(path)


#################################################################
# import specific library
#################################################################
from vunit import VUnitCLI
from vunit import VUnit
from vunit import about
from common import Display
from common import VunitConf
from common import SystemFpasimTopDataGen
     

if __name__ == '__main__':
    # Add custom command line argument to standard CLI
    # Beware of conflicts with existing arguments
    cli = VUnitCLI()

    help0 = 'Specify the VHDL simulator to use (mixed language (vhdl, verilog,system verilog) + VHDL 2008 compatible).'
    cli.parser.add_argument('--simulator','-s', default='questa',help=help0)

    help0 = 'Specify if the simulator is in gui mode or not.'
    cli.parser.add_argument('--gui_mode', default='False',choices = ['True','False'], help=help0)

    help0 = 'Specify the verbosity level. Possible values (uint): 0 to 2'
    cli.parser.add_argument('--verbosity', default=0,choices = [0,1,2], type = int, help=help0)

    help0 = 'Specify the json key path: test_name/test_id with test_name: name of the test and test_id: test index of the test list defined in test_name (see the launch_sim_processed.json file)'
    cli.parser.add_argument('--json_key_path', default='tb_system_fpasim_top_test_variant00/0',help=help0)

    args = cli.parse_args()

    # retrieve the command line arguments
    simulator     = args.simulator
    gui_mode      = args.gui_mode
    verbosity     = args.verbosity
    json_key_path = args.json_key_path

    ###############################################
    # extract parameters which uniquely identify the test
    ###############################################
    key_test_name, key_id = json_key_path.split('/')

    ###########################################################
    # When this script is called by an another python script with the subprocess function,
    # I don't know how to pass a boolean as command line argument (--gui argument defined by the Vunit library).
    # Instead, we use an intermediary "--gui_mode" custom argument (string type) to pass the command.
    ###########################################################
    if gui_mode == 'False':
        args.gui = False 
    else:
        args.gui = True

    ################################################
    # build the display object
    ################################################
    level0 = 0
    level1 = 1
    level2 = 2
    obj_display = Display()
    if verbosity > 0:
        msg0 = 'Start Python Script: '+__file__
        obj_display.display_title(msg_p=msg0,level_p=0)

    #####################################################
    # Order matter:
    # Some Vunit environment variables need to be set before
    # creating the VUNIT class instance
    # So, the following steps need to be followed:
    #  1. Create the VunitConf class instance
    #  2. Call the VunitConf.set_vunit_simulator instance method
    #  3. call the VunitConf.set_vunit instance method
    #####################################################
    obj = SystemFpasimTopDataGen( json_filepath_p =json_filepath, json_key_path_p = json_key_path)
    obj.set_vunit_simulator(name_p = simulator,level_p=level1)
    obj.set_verbosity(verbosity_p = verbosity)

    # get the library Vunit version
    vunit_version = about.VERSION
    # print('Vunit version ',vunit_version)
    # see: https://github.com/VUnit/vunit/issues/777
    if vunit_version >= '5.0.0':
        VU = VUnit.from_args(args=args)  # Do not use compile_builtins.
        VU.add_vhdl_builtins()  #
        VU.add_verilog_builtins()
    elif vunit_version > '4.6.0':
        VU = VUnit.from_args(args=args,compile_builtins=False)  # Stop using the builtins ahead of time.
        VU.add_vhdl_builtins()  # Add the VHDL builtins explicitly!
        VU.add_verilog_builtins()
    else:
        # vunit version <= 4.6.0
        VU = VUnit.from_args(args=args)

    obj.set_vunit(vunit_object_p = VU)
    #####################################################
    # add compiled xilinx library
    #####################################################
    obj.xilinx_compile_lib_default_lib(level_p=level1)
    
    #####################################################
    # add glbl library
    #####################################################
    obj.compile_glbl_lib(level_p=level1)

    #####################################################
    # add xilinx Coregen
    #####################################################
    obj.compile_xilinx_coregen_ip(level_p=level1)

    #####################################################
    # add opal kelly library
    #####################################################
    obj.compile_opal_kelly_ip(level_p=level1)

    #####################################################
    # add custom library
    #####################################################
    obj.compile_xilinx_xpm_ip(level_p=level1)
    obj.compile_opal_kelly_lib(level_p=level1)
    obj.compile_csv_lib(level_p=level1)
    obj.compile_common_lib(level_p=level1)
    
    #####################################################
    # add the VHDL/verilog source files
    #####################################################
    obj.compile_src(filename_p='system_fpasim_top.vhd',level_p=level1)
    obj.compile_src(filename_p='pkg_system_fpasim_debug.vhd',level_p=level1)
    obj.compile_src_directory(directory_name_p='utils',level_p=level1)
    obj.compile_src_directory(directory_name_p='clocking',level_p=level1)
    obj.compile_src_directory(directory_name_p='fpasim',level_p=level1)
    obj.compile_src_directory(directory_name_p='usb',level_p=level1)
    obj.compile_src_directory(directory_name_p='io',level_p=level1)
    obj.compile_src_directory(directory_name_p='reset',level_p=level1)
    obj.compile_src_directory(directory_name_p='spi',level_p=level1)

    #####################################################
    # add the VHDL testbench file
    #####################################################
    obj.compile_tb(level_p=level1)

    #####################################################
    # Set the simulator waveform
    #####################################################
    # Set the simulator waveform
    obj.set_waveform(level_p=level1)
    # Get the simulator wave
    wave_filepath = obj.get_waveform(level_p=level1)

    if wave_filepath is None:
        sim_title = __file__.replace('\\','/')
    else:
        str0 = "run_filepath:"+__file__.replace('\\','/')
        str1 = "waveform_filepath:"+wave_filepath.replace('\\','/')
        sim_title = str0 + '__' + str1

    #####################################################
    # Set the simulator options
    #####################################################
    simulation_option_list = []
    simulation_option_list.append("-stats=-cmd,-time")
    simulation_option_list.append("-c")
    simulation_option_list.append("-t")
    simulation_option_list.append('ps')
    simulation_option_list.append('-title')
    simulation_option_list.append(sim_title)
    simulation_option_list.append('fpasim.glbl')
    if args.gui == True:
        simulation_option_list.append('-voptargs=+acc')
    obj.set_sim_option(name_p="modelsim.vsim_flags", value_p=simulation_option_list)

    ######################################################
    # get the list of json test_variant_filepath (if any)
    ######################################################
    test_variant_filepath_list = obj.get_test_variant_filepath(level_p=level1)

    ######################################################
    # get the list of ram configuration filepath
    ######################################################
    ram_filename_list = []
    ram_filename_list.append('tes_pulse_shape.mem')
    ram_filename_list.append('tes_std_state.mem')
    ram_filename_list.append('mux_squid_offset.mem')
    ram_filename_list.append('mux_squid_tf.mem')
    ram_filename_list.append('amp_squid_tf.mem')
    ram_filename_list.append('mux_squid_linear_tf.mem')
    ram_filename_list.append('amp_squid_linear_tf.mem')
    ram_filepath_list = obj.get_ram_filepath(filename_list_p=ram_filename_list,level_p=level1)

    ######################################################
    # get the Vunit testbench object + testbench name
    ######################################################
    tb = obj.get_testbench(level_p=level1)
    tb_name = obj.get_testbench_name()

    # loop on all test variant files
    for test_variant_filepath in test_variant_filepath_list :
        if verbosity > 0:
            str0 = 'Start the Test'
            obj_display.display_title(msg_p=str0, level_p=level1)
            str0 = 'test_variant_filepath='+test_variant_filepath   
            obj_display.display(msg_p=str0, level_p=level2)
            str0 = 'tb_name='+tb_name   
            obj_display.display(msg_p=str0, level_p=level2)

        variant_filename = str(Path(test_variant_filepath).stem)

        # build the output directory name
        dir_out_name = key_test_name + '.test_id_' +'{0:04d}'.format(int(key_id)) + '.' + variant_filename
        
        ####################################################################
        # generate the input command/data files and others actions before launching the simulator
        ####################################################################
        obj.set_indentation_level(level_p= level1)
        obj.add_test_variant_filepath(filepath_p= test_variant_filepath)
        obj.set_mif_files(filepath_list_p=ram_filepath_list)

        # get the vhdl testbench generic parameters.
        # => to be updated, this function must be called after the set_test_variant_filepath/add_test_variant_filepath functions
        generic_dic = obj.get_generic_dic()
        #####################################################
        # Mandatory: The simulator modelsim/Questa wants generics filepaths in the Linux format
        #####################################################
        tb.add_config(
                      name=dir_out_name,
                      pre_config=obj.pre_config,
                      generics = generic_dic
                        )

    # should be:
    #   . outside the loop on the test_variant_filepath if add_test_variant_filepath is called
    #   . inside the loop on the test_variant_filepath if set_test_variant_filepath is called
    obj.main()
