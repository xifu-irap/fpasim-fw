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
#    @file                   conf_sim.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    N/A
# -------------------------------------------------------------------------------------------------------------
#    @details                
#    This script generates the launch_sim_processed.json file.
#    This generated file will be used by the run python scripts during the VHDL simulation
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
    :param depth_level_p: (integer >= 0) search depth limit (ascending way)
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
root_path, _ = find_file_in_hierarchy(filename_p='DONT_DELETE.txt')

############################################################################
# add python common library
############################################################################
sys.path.append(str(Path(root_path, 'lib/common')))
from common import Display, FilepathListBuilder


class Env:
    """
    This class checks if an environment variable exist and builds an output dictionary
    How to use:
        1. create an instance of this class
        2. optionally call the "add_description" method one or more times
        3. call last the "get_dic" method
    Note:
        Method name starting by '_' are local to the class (ex:def _toto(...)).
        It should not be usually used by the user
    """

    def __init__(self, env_name_p, mandatory_p=1, level_p=0):
        """
        This method initializes the class instance
        :param env_name_p: (string) Name of the environment variable to check if exist
        :param mandatory_p: (integer: 0 or 1) Define if the message generates an error (mandatory = 1) or a warning
                                              (mandatory=0) if the environment variable is missing
        :param level_p: (integer >= 0) define the level of indentation of the message to print
        """
        self.description_list = []
        self.obj_display = Display()
        self.path = None

        self._check_environment_variable(env_name_p=env_name_p, mandatory_p=mandatory_p, level_p=level_p)

    def _check_environment_variable(self, env_name_p, mandatory_p=1, level_p=0):
        """
        This method checks if an environment variable exist and print a message according
        :param env_name_p: (string) Name of the environment variable to check if exist
        :param mandatory_p: (integer: 0 or 1) Define if the message generates an error (mandatory = 1) or a warning
                                              (mandatory=0) if the environment variable is missing
        :param level_p: (integer >= 0) define the level of indentation of the message to print
        :return:
        """
        env_path = os.environ.get(env_name_p)
        if env_path is None:
            path_tmp = ""
            if mandatory_p == 1:
                str0 = "ERROR : the user must define the " + env_name_p + " system environment variable."
                str1 = "This variable must be accessible by the simulation computer"
                str2 = str0 + str1
                self.obj_display.display(str2, color_p='red', level_p=level_p)

            else:
                str0 = "Warning : the optional " + env_name_p + " system environment variable is not set"
                self.obj_display.display(str0, color_p='yellow', level_p=level_p)
        else:
            path_tmp = str(Path(env_path).absolute())
            str0 = "Info : " + env_name_p + " system environment variable is set"
            self.obj_display.display(str0, color_p='green', level_p=level_p)
        self.path = path_tmp

    def add_description(self, text_p):
        """
        This method allows to add a new line of description
        :param text_p: (string) line of description to add
        :return: None
        """
        self.description_list.append(text_p)
        return None

    def get_dic(self):
        """
        This method returns a dictionary
        :return: dictionary
        """
        path_tmp = self.path

        dic = {}
        dic["description"] = self.description_list
        dic["path"] = path_tmp
        return dic


class PyLibrary:
    """
    This class builds parameters for a python library definition and outputs the result in a dictionary
    How to use:
        1. create an instance of this class
        2. optionally call the "add_description" method one or more times
        3. call the "set_name" method one time.
        4. call the add_directory_path method at least one time
        3. call last the "get_dic" method
    Note:
        Method name starting by '_' are local to the class (ex:def _toto(...)).
        It should not be usually used by the user
    """

    def __init__(self):
        """
        This method initializes the class instance
        """
        self.description_list = []
        self.name = ""
        self.filepath_list = []
        self.directory_path_list = []
        self.obj_display = Display()

    def add_description(self, text_p):
        """
        This method allows to add a new line of description
        :param text_p: (string) line of description to add
        :return: None
        """
        self.description_list.append(text_p)
        return None

    def set_name(self, name_p):
        """
        This method set a name
        :param name_p: (string) define the name
        :return: None
        """
        self.name = name_p
        return None

    def add_directory_path(self, base_path_p):
        """
        This method allows to add a new directory path
        :param base_path_p: (string) path to add
        :return: None
        """
        path_tmp = str(Path(base_path_p).resolve())
        self.directory_path_list.append(path_tmp)
        return None

    def get_dic(self, level_p=0):
        """
        This method returns a dictionary
        :param level_p: (integer >=0) define the message level indentation
        :return: dictionary
        """
        # check if the class instance is correctly configured
        self._check_class_configuration(level_p=level_p)

        dic = {}
        dic["description"] = self.description_list
        dic["name"] = self.name
        dic["directory_path_list"] = self.directory_path_list
        return dic

    def _check_class_configuration(self, level_p=0):
        """
        This method checks if the class instance is correctly configured
        :param level_p: (integer >=0) define the message level indentation
        :return:
        """
        if self.directory_path_list == []:
            str0 = 'Warning: call PyLibrary.add_directory_path at least one time (name=' + self.name + ')'
            self.obj_display.display(str0, level_p=level_p, color_p='yellow')


class DUT:
    """
    This class builds parameters of an individual test and outputs the result in a dictionary
    Note:
        Method name starting by '_' are local to the class (ex:def _toto(...)).
        It should not be usually used by the user
    """

    def __init__(self):
        """
        This method initializes the class instance
        """
        self.description_list = []
        self.name = ""
        self.conf_filename_list = []
        self.run_filepath = ""
        self.tb_filename = ""
        self.vunit_outpath = ""
        self.wave_filename = ""
        self.obj_display = Display()

    def add_description(self, text_p):
        """
        This method allows to add a new line of description
        :param text_p: (string) line of description to add
        :return: None
        """
        self.description_list.append(text_p)
        return None

    def set_name(self, name_p):
        """
        This method set a name
        :param name_p: (string) define the name
        :return: None
        """
        self.name = name_p
        return None

    def add_conf_filepath(self, path_p):
        """
        This method adds a configuration filepath
        :param path_p: (string) path to add
        :return: None
        """
        path_tmp = str(Path(path_p).resolve())
        self.conf_filename_list.append(path_tmp)
        return None

    def set_tb_filename(self, filename_p):
        """
        This method set a testbench filename (with extension)
        Example: tb_XXX.vhd
        :param filename_p: (string) testbench filename
        :return: None
        """
        self.tb_filename = filename_p
        return None

    def set_vunit_run_filepath(self, filepath_p, level_p=0):
        """
        This method set the filepath to the run script python
        Example: c:/blabla/run_tb_XXX.py
        :param level_p: (integer >=0) define the message level indentation
        :param filepath_p: (string) filepath of the run script python (can be relative or absolute)
        :return: None
        """
        if filepath_p is None:
            str0 = "ERROR: DUT.run_filepath (name=" + self.name + "): filepath_p = None"
            self.obj_display.display(str0, level_p=level_p, color_p='red')
            return -1

        path_tmp = Path(filepath_p).resolve()
        if path_tmp.is_file() == False:
            str0 = "ERROR: DUT.run_filepath (name=" + self.name + "): filepath isn't a file"
            self.obj_display.display(str0, level_p=level_p, color_p='red')
        path_tmp = str(path_tmp)
        self.run_filepath = path_tmp
        return None

    def set_vunit_outpath(self, path_p):
        """
        This method set the vunit_output base path
        :param path_p: (string) output path to the simulation
        :return: None
        """
        if path_p is None:
            str0 = "DUT.set_vunit_outpath (name=" + self.name + "): ERROR  path_p = None"
            self.obj_display.display(str0, level_p=level_p, color_p='red')

        path_tmp = str(Path(path_p).resolve())
        self.vunit_outpath = path_tmp
        return None

    def set_sim_wave_filepath(self, filename_p):
        """
        This method set the simulation waveform filename.
        Example: For modelsim/questa, wave_tb_XXXX.do
        :param filename_p: (string) simulation waveform filename
        :return: None
        """
        self.wave_filename = filename_p
        return None

    def get_dic(self, level_p=0):
        """
        This method returns a dictionary
        :param level_p: (integer >=0) define the message level indentation
        :return: dictionary
        """
        # check if the class instance is correctly configured
        self._check_class_configuration(level_p=level_p)

        dic_conf = {}
        dic_conf["filename_list"] = self.conf_filename_list
        dic_vunit = {}
        dic_vunit["tb_filename"] = self.tb_filename
        dic_vunit["run_filepath"] = self.run_filepath
        dic_vunit["vunit_outpath"] = self.vunit_outpath
        dic_vunit["wave_filename"] = self.wave_filename

        dic = {}
        dic["description"] = self.description_list
        dic["name"] = self.name
        dic["conf"] = dic_conf
        dic["vunit"] = dic_vunit
        return dic

    def _check_class_configuration(self, level_p=0):
        """
        This method checks if the class instance is correctly configured
        :param level_p: (integer >=0) define the message level indentation
        :return:
        """
        if self.tb_filename == "":
            str0 = 'ERROR: DUT.set_tb_filename (name=' + self.name + "): call the method at least one time."
            self.obj_display.display(str0, level_p=level_p, color_p='red')

        if self.run_filepath == "":
            str0 = 'ERROR: DUT.set_vunit_run_filepath (name=' + self.name + "): call the method at least one time."
            self.obj_display.display(str0, level_p=level_p, color_p='red')

        if self.vunit_outpath == "":
            str0 = 'ERROR: DUT.set_vunit_outpath (name=' + self.name + "): call the method at least one time."
            self.obj_display.display(str0, level_p=level_p, color_p='red')


if __name__ == '__main__':
    ############################################################################
    # parse the command line
    ############################################################################
    parser = argparse.ArgumentParser(description='Generate the configuration json file')
    # add an optional argument
    parser.add_argument('-v', default=0, choices=[0, 1, 2], type=int,
                        help='Specify the verbosity level. Possible values (uint): 0 to 2')
    args = parser.parse_args()

    verbosity = args.v

    #############################################################################
    # build the display object
    ############################################################################
    level0 = 0
    level1 = 1
    level2 = 2
    obj_display = Display()
    msg0 = 'Start Python Script: ' + __file__
    obj_display.display_title(msg_p=msg0, level_p=level0)

    ############################################################################
    # compute the path of the output json file
    ############################################################################
    json_filepath_output = str(Path(root_path, 'launch_sim_processed.json').resolve())
    # Opening JSON file
    fid_out = open(json_filepath_output, 'w')

    msg0 = 'Generate: ' + json_filepath_output
    obj_display.display_subtitle(msg_p=msg0, level_p=level1)

    # lib path (python/VHDL)
    ############################################################################

    # vhdl_simu_lib
    relpath = './lib/vhdl_simu'
    lib_vhdl_simu_base_path_py = str(Path(root_path, relpath).resolve())

    # common
    relpath = './lib/common'
    lib_common_base_path_py = str(Path(root_path, relpath).resolve())

    json_data = {}
    ############################################################################
    # Define main description_list keys
    ############################################################################
    description_list = []
    description_list.append("This file was generated by the python script: " + str(Path(__file__)))
    description_list.append("This file will be used by the run python scripts during the VHDL simulation.")
    description_list.append("This file contains auto-computed paths")
    description_list.append("Pre-requisite: Before running the python script: " + str(Path(__file__)))
    description_list.append(" On every running computer (VHDL simulation), The user needs to:")
    description_list.append("  . Install Vivado")
    description_list.append("  . Install the mixed language compatible (vhdl, verilog, system verilog) simulator:")
    description_list.append("    . Modelsim and/or Questa simulator.")
    description_list.append("    . The Vivado simulator is not enough compatible with VHDL-2008.")
    description_list.append("       So, it can't be used.")
    description_list.append("  . Define the following system environment variables:")
    description_list.append("    . VUNIT_PATH: path to the repo root directory of python vunit library")
    description_list.append("      . ex: C:/blabla/vunit")
    description_list.append("      . So, the path of the vunit .git directory is C:/blabla/vunit/.git")
    description_list.append("    . VUNIT_VIVADO_PATH: path to the root directory of the vivado installation")
    description_list.append("      . The path should have the Vivado version number")
    description_list.append("      . ex: C:/Xilinx/Vivado/2022.1")
    description_list.append("      . checks if the path of the w64 directory is C:/Xilinx/Vivado/2022.1/win64")
    description_list.append("   . VUNIT_MODELSIM_PATH: path to the root directory of the modelsim.exe (if installed)")
    description_list.append("     . ex: c:/blabla/modelsimXXXX/win32")
    description_list.append("   . VUNIT_QUESTA_PATH: path to the root directory of the questasim.exe (if installed)")
    description_list.append("     . ex: c:/blabla/questasim64_2020.3/win64")
    description_list.append("   . VUNIT_MODELSIM_COMPILE_LIB_PATH: path to the root directory of the Xilinx simulation")
    description_list.append("                                    libraries compiled with modelsim simulator via Vivado")
    description_list.append("   . VUNIT_QUESTA_COMPILE_LIB_PATH: path to the root directory of the Xilinx Simulation ")
    description_list.append("                                    libraries compiled with Questa simulator via Vivado")
    json_data["description_list"] = description_list

    ############################################################################
    # get the VUNIT_PATH environment variable
    ############################################################################
    env_name = "VUNIT_PATH"
    env = Env(env_name_p=env_name, mandatory_p=1, level_p=level1)
    env.add_description(
        text_p="On the VHDL simulation computer, the user must set a system environment variable called " + env_name)
    json_data[env_name.lower()] = env.get_dic()
    vunit_path = env.path

    ############################################################################
    # get the VUNIT_VIVADO_PATH environment variable
    ############################################################################
    env_name = "VUNIT_VIVADO_PATH"
    env = Env(env_name_p=env_name, mandatory_p=1, level_p=level1)
    env.add_description(
        text_p="On the VHDL simulation computer, the user must set a system environment variable called " + env_name)
    json_data[env_name.lower()] = env.get_dic()
    vivado_path = env.path

    ############################################################################
    # get the VUNIT_MODELSIM_PATH environment variable
    ############################################################################
    env_name = "VUNIT_MODELSIM_PATH"
    env = Env(env_name_p=env_name, mandatory_p=0, level_p=level1)
    env.add_description(
        text_p="On the VHDL simulation computer, the user must set a system environment variable called " + env_name)
    json_data[env_name.lower()] = env.get_dic()

    ############################################################################
    # get the VUNIT_QUESTA_PATH environment variable
    ############################################################################
    env_name = "VUNIT_QUESTA_PATH"
    env = Env(env_name_p=env_name, mandatory_p=0, level_p=level1)
    env.add_description(
        text_p="On the VHDL simulation computer, the user must set a system environment variable called " + env_name)
    json_data[env_name.lower()] = env.get_dic()

    ############################################################################
    # get the VUNIT_MODELSIM_COMPILE_LIB_PATH environment variable
    ############################################################################
    env_name = "VUNIT_MODELSIM_COMPILE_LIB_PATH"
    env = Env(env_name_p=env_name, mandatory_p=0, level_p=level1)
    env.add_description(
        text_p="On the VHDL simulation computer, the user must set a system environment variable called " + env_name)
    json_data[env_name.lower()] = env.get_dic()

    ############################################################################
    # get the VUNIT_QUESTA_COMPILE_LIB_PATH environment variable
    ############################################################################
    env_name = "VUNIT_QUESTA_COMPILE_LIB_PATH"
    env = Env(env_name_p=env_name, mandatory_p=0, level_p=level1)
    env.add_description(
        text_p="On the VHDL simulation computer, the user must set a system environment variable called " + env_name)
    json_data[env_name.lower()] = env.get_dic()

    ############################################################################
    # set root path
    ############################################################################
    dic = {}
    description_list = []
    description_list.append('Project Base Path: root path of the git repository')
    dic['description'] = description_list
    dic['path'] = root_path
    json_data['root_path'] = dic

    ############################################################################
    # define the lib section
    ############################################################################

    # define the python library
    ############################################################################
    lib_py_dic = {}
    # vunit_lib
    path = str(Path(vunit_path, ""))
    name = "vunit"
    py_lib0 = PyLibrary()
    py_lib0.add_description(text_p="")
    py_lib0.set_name(name_p=name)
    py_lib0.add_directory_path(base_path_p=path)
    py_dic0 = py_lib0.get_dic(level_p=level2)
    lib_py_dic[name] = py_dic0

    # utils
    path = lib_vhdl_simu_base_path_py
    name = "vhdl_simu"
    py_lib0 = PyLibrary()
    py_lib0.add_description(text_p="")
    py_lib0.set_name(name_p=name)
    py_lib0.add_directory_path(base_path_p=path)
    py_dic0 = py_lib0.get_dic(level_p=level2)
    lib_py_dic[name] = py_dic0

    # utils
    path = lib_common_base_path_py
    name = "common"
    py_lib0 = PyLibrary()
    py_lib0.add_description(text_p="")
    py_lib0.set_name(name_p=name)
    py_lib0.add_directory_path(base_path_p=path)
    py_dic0 = py_lib0.get_dic(level_p=level2)
    lib_py_dic[name] = py_dic0

    # lib description
    ############################################################################
    description_list = []
    description_list.append("")
    dic = {}
    dic['description'] = description_list
    dic['python'] = lib_py_dic
    json_data["lib"] = dic

    ############################################################################
    # define every individual test
    ############################################################################
    # dictionary of individual test (the key name must be unique)
    solo_test_dic = {}

    # 0: individual test
    ############################################################################
    # search run python script file
    tb_name = 'tb_system_fpasim'
    obj = FilepathListBuilder()
    obj.set_file_extension(file_extension_list_p=['.py'])
    vunit_basepath = str(Path(root_path, 'simu/vunit'))
    run_filepath = obj.get_filepath_by_filename(basepath_p=vunit_basepath, filename_p='run_' + tb_name + '.py')
    # generate individual test
    vunit_outpath = str(Path(root_path, 'vunit_out'))
    test0 = DUT()
    test0.add_description(text_p="")
    test0.set_name(name_p=tb_name)
    # for relfilepath in relfilepath_list:
    #     path = str(Path(root_path,relfilepath))
    #     test0.add_conf_filepath(path_p=path)
    test0.set_tb_filename(filename_p=tb_name + ".vhd")
    test0.set_vunit_run_filepath(filepath_p=run_filepath, level_p=level2)
    test0.set_vunit_outpath(path_p=vunit_outpath)
    test0.set_sim_wave_filepath(filename_p="wave_" + tb_name + "00.do")
    test_dic0 = test0.get_dic(level_p=level2)
    # save the individual test for further use (sequence building)
    solo_test_dic[tb_name] = test_dic0

    # 1: individual test
    ############################################################################
    # search run python script file
    tb_name = 'tb_tes_top'
    obj = FilepathListBuilder()
    obj.set_file_extension(file_extension_list_p=['.py'])
    vunit_basepath = str(Path(root_path, 'simu/vunit'))
    run_filepath = obj.get_filepath_by_filename(basepath_p=vunit_basepath, filename_p='run_' + tb_name + '.py')
    # generate individual test
    vunit_outpath = str(Path(root_path, 'vunit_out'))
    test0 = DUT()
    test0.add_description(text_p="")
    test0.set_name(name_p=tb_name)
    # for relfilepath in relfilepath_list:
    #     path = str(Path(root_path,relfilepath))
    #     test0.add_conf_filepath(path_p=path)
    test0.set_tb_filename(filename_p=tb_name + ".vhd")
    test0.set_vunit_run_filepath(filepath_p=run_filepath, level_p=level2)
    test0.set_vunit_outpath(path_p=vunit_outpath)
    test0.set_sim_wave_filepath(filename_p="wave_" + tb_name + "00.do")
    test_dic0 = test0.get_dic(level_p=level2)
    # save the individual test for further use (sequence building)
    solo_test_dic[tb_name] = test_dic0

    # 2: individual test
    ############################################################################
    # search run python script file
    tb_name = 'tb_amp_squid_top'
    obj = FilepathListBuilder()
    obj.set_file_extension(file_extension_list_p=['.py'])
    vunit_basepath = str(Path(root_path, 'simu/vunit'))
    run_filepath = obj.get_filepath_by_filename(basepath_p=vunit_basepath, filename_p='run_' + tb_name + '.py')
    # generate individual test
    vunit_outpath = str(Path(root_path, 'vunit_out'))
    test0 = DUT()
    test0.add_description(text_p="")
    test0.set_name(name_p=tb_name)
    # for relfilepath in relfilepath_list:
    #     path = str(Path(root_path,relfilepath))
    #     test0.add_conf_filepath(path_p=path)
    test0.set_tb_filename(filename_p=tb_name + ".vhd")
    test0.set_vunit_run_filepath(filepath_p=run_filepath, level_p=level2)
    test0.set_vunit_outpath(path_p=vunit_outpath)
    test0.set_sim_wave_filepath(filename_p="wave_" + tb_name + "00.do")
    test_dic0 = test0.get_dic(level_p=level2)
    # save the individual test for further use (sequence building)
    solo_test_dic[tb_name] = test_dic0

    # 3: individual test
    ############################################################################
    # search run python script file
    tb_name = 'tb_mux_squid_top'
    obj = FilepathListBuilder()
    obj.set_file_extension(file_extension_list_p=['.py'])
    vunit_basepath = str(Path(root_path, 'simu/vunit'))
    run_filepath = obj.get_filepath_by_filename(basepath_p=vunit_basepath, filename_p='run_' + tb_name + '.py')
    # generate individual test
    vunit_outpath = str(Path(root_path, 'vunit_out'))
    test0 = DUT()
    test0.add_description(text_p="")
    test0.set_name(name_p=tb_name)
    # for relfilepath in relfilepath_list:
    #     path = str(Path(root_path,relfilepath))
    #     test0.add_conf_filepath(path_p=path)
    test0.set_tb_filename(filename_p=tb_name + ".vhd")
    test0.set_vunit_run_filepath(filepath_p=run_filepath, level_p=level2)
    test0.set_vunit_outpath(path_p=vunit_outpath)
    test0.set_sim_wave_filepath(filename_p="wave_" + tb_name + "00.do")
    test_dic0 = test0.get_dic(level_p=level2)
    # save the individual test for further use (sequence building)
    solo_test_dic[tb_name] = test_dic0

    ############################################################################
    # Define 1 or several sequence of individual tests
    ############################################################################
    # 0: first sequence of individual tests
    json_data["test0_tb_system_fpasim"] = [solo_test_dic['tb_system_fpasim']]
    json_data["test0_tb_tes_top"] = [solo_test_dic['tb_tes_top']]
    json_data["test0_tb_amp_squid_top"] = [solo_test_dic['tb_amp_squid_top']]
    json_data["test0_tb_mux_squid_top"] = [solo_test_dic['tb_mux_squid_top']]

    ############################################################################
    # output the processed json file with updated address path
    ############################################################################
    # Serializing then json dictionary
    json_object = json.dumps(json_data, indent=4)
    # Writing to the output json file
    fid_out.write(json_object)
    fid_out.close()
