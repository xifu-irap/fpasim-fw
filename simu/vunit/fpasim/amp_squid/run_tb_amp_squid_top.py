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
#    @file                   run_tb_amp_squid_top.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    
# -------------------------------------------------------------------------------------------------------------
#    @details                
# 
# -------------------------------------------------------------------------------------------------------------




import os
# Enable the coloring in the console
os.system("")
import sys
import argparse
from pathlib import Path,PurePosixPath
# Json lib
import json

# get the name of the script name without file extension
script_name = str(Path(__file__).stem)


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


# retrieve all python library path in order to import them
def get_python_library_from_json_file(filepath_p):

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
json_filepath = str(Path(root_path,'./launch_sim_processed.json').resolve())
path_list = get_python_library_from_json_file(filepath_p=json_filepath)
if path_list != None:
    for path in path_list:
        sys.path.append(path)


#################################################################
# import specific library
#################################################################
from vunit import VUnit, VUnitCLI
from common import Display, VunitConf
     

if __name__ == '__main__':
    # Add custom command line argument to standard CLI
    # Beware of conflicts with existing arguments
    cli = VUnitCLI()

    help0 = 'Specify the VHDL simulator to use (mixed language (vhdl, verilog,system verilog) + VHDL 2008 compatible).'
    cli.parser.add_argument('--simulator','-s', default='questa',help=help0)

    help0 = 'Specify if the simulator is in gui mode or not.'
    cli.parser.add_argument('--display', default='False',choices = ['True','False'], help=help0)

    help0 = 'Specify the verbosity level. Possible values (uint): 0 to 2'
    cli.parser.add_argument('--verbosity', default=0,choices = [0,1,2], type = int, help=help0)

    help0 = 'Specify the json key path'
    cli.parser.add_argument('--json_key_path', default='test0_tb_tes_top/tb_tes_top',help=help0)

    args = cli.parse_args()

    # retrieve the command line arguments
    simulator     = args.simulator
    display       = args.display
    verbosity     = args.verbosity
    json_key_path   = args.json_key_path


    ###########################################################
    # It's impossible to pass a boolean to a subprocess call
    # We can't directly use the vunit defined --gui argument (boolean type)
    # So, we use an intermediary "--display" custom argument (string type) to pass the command
    ###########################################################
    if display == 'False':
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
    msg0 = 'Start Python Script: '+__file__
    obj_display.display_title(msg_p=msg0,level_p=0)

    #####################################################
    # Order matter:
    # Some Vunit environment variables need to be set before
    # creating the VUNIT class instance
    # So, the following steps need to be followed:
    #  1. Create the VunitConf class instance
    #  2. Call the VunitConf.set_vunit_simulator instance method
    #  3. create the VUNIT class instance
    #  4. call the VunitConf.set_vunit instance method
    #####################################################
    obj = VunitConf( json_filepath_p =json_filepath,script_name_p = script_name, json_key_path_p = json_key_path)
    obj.set_vunit_simulator(name_p = simulator,level_p=level1)
    obj.set_verbosity(verbosity_p = verbosity)
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
    
    #####################################################
    # add source files
    #####################################################
    # obj.compile_src(filename_p='top_fpasim_system.vhd',level_p=level1)
    obj.compile_src_directory(directory_name_p='utils',level_p=level1)
    # obj.compile_src_directory(directory_name_p='clocking',level_p=level1)
    obj.compile_src_directory(directory_name_p='fpasim',level_p=level1)
    # obj.compile_src_directory(directory_name_p='usb',level_p=level1)
    # obj.compile_src_directory(directory_name_p='io',level_p=level1)

    #####################################################
    # add testbench file
    #####################################################
    obj.compile_tb(level_p=level1)

    #####################################################
    # simulator configuration
    #####################################################
    # Set the simulator options
    obj.set_waveform(level_p=level1)

    #####################################################
    # Set the simulation options
    #####################################################
    VU.set_sim_option("modelsim.vsim_flags", ["-stats=-cmd,-time",'-c','-t','ps','-voptargs=+acc','-title',__file__.replace('\\','/')])

    ######################################################
    # get the list of conf_filepath (if any)
    ######################################################
    conf_filepath_list = obj.get_conf_filepath(level_p=level1)

    
    ######################################################
    # get the Vunit testbench object + testbench name
    ######################################################
    tb = obj.get_testbench(level_p=level1)
    tb_name = obj.get_testbench_name()

    # loop on all configuration files
    for conf_filepath in conf_filepath_list :

        str0 = 'Start the Test'
        obj_display.display_title(msg_p=str0, level_p=level1)
        str0 = 'conf_filepath='+conf_filepath   
        obj_display.display(msg_p=str0, level_p=level2)
        str0 = 'tb_name='+tb_name   
        obj_display.display(msg_p=str0, level_p=level2)

        conf_filename = str(Path(conf_filepath).stem)

        name = conf_filename
        test_name = tb_name
        
        ####################################################################
        # generate the input command/data files and others actions before launching the simulator
        ####################################################################

        obj.set_script(conf_filepath_p=conf_filepath, level_p=level1)

        #####################################################
        # Mandatory: The simulator modelsim/Questa wants generics filepaths in the Linux format
        #####################################################
        tb.add_config(
                      name=test_name,
                      pre_config=obj.pre_config,
                      generics = 
                        {
                        "g_TEST_NAME":name
                        }
                        )


    VU.main()
    # conf.pre_config(output_path = "test")