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
#    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
# -------------------------------------------------------------------------------------------------------------
#    @details                
#    This scripts allows to build the ./launch_sim_processed.json files which describes ./launch_sim_processed.json file
# -------------------------------------------------------------------------------------------------------------

# standard library
import sys
import argparse
import os
from pathlib import Path
import subprocess




# Json lib
import json

# get the name of the script without the file extension
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

root_path, _ = find_file_in_hierarchy()

#######################################
# add python common library
#######################################
path = str(Path(root_path,'lib/common'))
sys.path.append(path)
from common import ConsoleColors
# Enable the coloring in the console
os.system("")


class Env():
    def __init__(self,env_name_p,mandatory_p=1):
        self.description_list = []
        self.env_name = env_name_p
        self.mandatory = mandatory_p

        path = os.environ.get(env_name)
        if path is None:
            path =""
            if mandatory_p == 1:
                print(ConsoleColors.red + "["+script_name +"]: ERROR : the user must define the "+env_name +"system environnement variable. This variable must be accessible by the simulation computer")
            else:
                print(ConsoleColors.yellow + "["+script_name +"]: warning : the optional "+env_name +"system environnement variable is not set")
        else:
             path = str(Path(path).absolute())
             print(ConsoleColors.blue + '['+script_name +"]: INFO : "+env_name+" system environnement variable is set")
        self.path = path
    def add_description(self,text_p):
        self.description_list.append(text_p)
    def get_dic(self):
        env_name = self.env_name
        mandator = self.mandatory
        path = self.path
        
        dic = {}
        dic["description"] = self.description_list
        dic["path"] = path
        return dic

class Library():
    def __init__(self):
        self.description_list = []
        self.name = ""
        self.filename_list = []
        self.path = ""
        self.compile_lib = ""
        self.version = '2008'
    def add_description(self,text_p):
        self.description_list.append(text_p)
    def set_name(self,name_p):
        self.name = name_p
    def add_filename(self,name_p):
        self.filename_list.append(name_p)
    def set_path(self,path_p):
        self.path = str(Path(path_p))
    def set_version(self,value_p):
        self.version = value_p
    def set_compile_lib(self,name_p):
        self.compile_lib = name_p
    def get_dic(self):
        
        dic = {}
        dic["description"] = self.description_list
        dic["name"] = self.name
        dic["filename_list"] = self.filename_list
        dic["path"] = self.path
        dic["compile_lib"] = self.compile_lib
        dic["version"] = self.version
        return dic

class DUT():
    def __init__(self):
        self.description_list = []
        self.name = ""
        self.filepath_list = []
        self.run_filepath = ""
        self.out_path = ""
        self.wave_filepath = ""
    def add_description(self,text_p):
        self.description_list.append(text_p)
    def set_name(self,name_p):
        self.name = name_p
    def add_json_filepath(self,path_p):
        self.filepath_list.append(path_p)
    def set_run_filepath(self,path_p):
        self.run_filepath = str(Path(path_p))
    def set_out_path(self,path_p):
        self.out_path = str(Path(path_p))
    def set_wave_filepath(self,path_p):
        self.wave_filepath = str(Path(path_p))

    def get_dic(self):
        dic_conf = {}
        dic_conf["json_filepath_list"] = self.filepath_list
        dic_vunit = {}
        dic_vunit["run_filepath"] = self.run_filepath
        dic_vunit["output_path"] = self.out_path
        dic_vunit["wave_filepath"] = self.wave_filepath

        dic = {}
        dic["description"] = self.description_list
        dic["name"] = self.name
        dic["conf"] = dic_conf
        dic["vunit"] = dic_vunit
        return dic

if __name__ == '__main__':

    ####################################
    # parse command line
    ####################################
    parser = argparse.ArgumentParser(description='Generate the configuration json file')
    # add an optional argument
    parser.add_argument('-v', default=0,choices = [0,1,2], type = int, help='Specify the verbosity level. Possible values (uint): 0 to 2')
    args = parser.parse_args()

    verbosity  = args.v

    sep = os.sep

    ############################################
    # compute the path of the ouput json file
    ############################################
    
    json_filepath_output = str(Path(root_path, 'launch_sim_processed.json').resolve())
    # Opening JSON file
    fid_out = open(json_filepath_output,'w')

    ############################################
    # compute the path
    ############################################
    # get script name_p
    script_name = str(Path(__file__).stem)
    # csv lib
    relpath = './lib/csv'
    csv_lib_base_path = str(Path(root_path,relpath).resolve())
    csv_lib_base_path_vhdl = str(Path(csv_lib_base_path,'csv/vhdl/src').resolve())

    # vhdl_simu_lib
    relpath = './lib/vhdl_simu'
    vhdl_simu_lib_base_path = str(Path(root_path,relpath).resolve())
    vhdl_simu_lib_base_path_vhdl = str(Path(vhdl_simu_lib_base_path,'vhdl_simu/vhdl/src').resolve())

    # opal_kelly_lib
    relpath = './lib/vhdl_opal_kelly'
    opal_kelly_lib_base_path = str(Path(root_path,relpath).resolve())
    opal_kelly_lib_base_path_vhdl = str(Path(opal_kelly_lib_base_path,'vhdl_opal_kelly/vhdl/src').resolve())
    # coregen
    relpath = './ip/xilinx/coregen'
    xilinx_coregen_path = str(Path(root_path,relpath).resolve())




    json_data = {}
    #######################################
    # Define main description_list keys
    #######################################
    description_list = []
    description_list.append("The Continuous Integration (VHDL simulation) can be launched on any computer.")
    description_list.append("All path are dynamically computed by using the basepath of this python script")
    description_list.append("This script will generate an output json file with basepath of the source files")
    description_list.append("This output file will be used by the python script associated to the simulation of the VHDL module to get the path to the directory where source files are")
    description_list.append("Pre-requisite:")
    description_list.append("   Before running a VHDL simulation on a computer, the user needs to:")
    description_list.append("       . Install Vivado")
    description_list.append("       . Install Modelsim and/or Questa simulator.")
    description_list.append("           . The Vivado simulator is not enough compatible with VHDL-2008. So, it can't be used.")
    description_list.append("       . Define the following system environnement variables:")
    description_list.append("           . VUNIT_PATH: path to the repo root directory of python vunit library")
    description_list.append("               . ex: C:/blabla/vunit")
    description_list.append("                   . So, the path of the .git directory is C:/blabla/vunit/.git")
    description_list.append("           . VUNIT_VIVADO_PATH: path to the root directory of the vivado installation (with the version number directory)")
    description_list.append("               . ex: C:/Xilinx/Vivado/2022.1")
    description_list.append("                   . So, the path of the w64 directory is C:/Xilinx/Vivado/2022.1/win64")
    description_list.append("           . VUNIT_MODELSIM_PATH: path to the root directory of the modelsim.exe if the modelsim simulator is installed")
    description_list.append("               . ex: c:/blabla/modelsimXXXX/win32")
    description_list.append("           . VUNIT_QUESTA_PATH: path to the root directory of the questasim.exe if the questa simulator is installed")
    description_list.append("               . ex: c:/blabla/questasim64_2020.3/win64")
    json_data["description_list"] = description_list

    ################################################################
    # get the VUNIT_PATH environnment variable
    ################################################################
    env_name = "VUNIT_PATH"
    env = Env(env_name_p=env_name,mandatory_p=1)
    env.add_description(text_p="On the VHDL simulation computer, the user must set a system environnement variable called "+env_name)
    json_data[env_name.lower()] = env.get_dic()
    vunit_path = env.path

    ################################################################
    # get the VUNIT_VIVADO_PATH environnment variable
    ################################################################
    env_name = "VUNIT_VIVADO_PATH"
    env = Env(env_name_p=env_name,mandatory_p=1)
    env.add_description(text_p="On the VHDL simulation computer, the user must set a system environnement variable called "+env_name)
    json_data[env_name.lower()] = env.get_dic()
    vivado_path = env.path

    ################################################################
    # get the VUNIT_MODELSIM_PATH environnment variable
    ################################################################
    env_name = "VUNIT_MODELSIM_PATH"
    env = Env(env_name_p=env_name,mandatory_p=0)
    env.add_description(text_p="On the VHDL simulation computer, the user must set a system environnement variable called "+env_name)
    json_data[env_name.lower()] = env.get_dic()

    ################################################################
    # get the VUNIT_QUESTA_PATH environnment variable
    ################################################################
    env_name = "VUNIT_QUESTA_PATH"
    env = Env(env_name_p=env_name,mandatory_p=0)
    env.add_description(text_p="On the VHDL simulation computer, the user must set a system environnement variable called "+env_name)
    json_data[env_name.lower()] = env.get_dic()

    ####################################################
    # define the lib section
    ####################################################

    # define the vhdl library
    ##############################################
    vhdl_lib_dic = {}
    # csv_lib
    path = csv_lib_base_path
    name = 'csv'
    vhld_lib0 = Library()
    vhld_lib0.add_description(text_p="")
    vhld_lib0.set_name(name_p=name)
    vhld_lib0.add_filename(name_p="")
    vhld_lib0.set_path(path_p=path)
    vhld_lib0.set_version(value_p='2008')
    vhld_lib0.set_compile_lib(name_p="csv_lib")
    vhdl_dic0 = vhld_lib0.get_dic()
    vhdl_lib_dic[name] = vhdl_dic0

    # vhdl_simu_lib
    path = vhdl_simu_lib_base_path_vhdl
    name = 'vhdl_simu'
    vhld_lib0 = Library()
    vhld_lib0.add_description(text_p="")
    vhld_lib0.set_name(name_p=name)
    vhld_lib0.add_filename(name_p="")
    vhld_lib0.set_path(path_p=path)
    vhld_lib0.set_version(value_p='2008')
    vhld_lib0.set_compile_lib(name_p="vhdl_simu_lib")
    vhdl_dic0 = vhld_lib0.get_dic()
    vhdl_lib_dic[name] = vhdl_dic0

    # opal_kelly_lib
    path = opal_kelly_lib_base_path_vhdl
    name = 'vhdl_opal_kelly'
    vhld_lib0 = Library()
    vhld_lib0.add_description(text_p="")
    vhld_lib0.set_name(name_p=name)
    vhld_lib0.add_filename(name_p="")
    vhld_lib0.set_path(path_p=path)
    vhld_lib0.set_version(value_p='2008')
    vhld_lib0.set_compile_lib(name_p="opal_kelly_lib")
    vhdl_dic0 = vhld_lib0.get_dic()
    vhdl_lib_dic[name] = vhdl_dic0

    # vunit_lib
    path = str(Path(vunit_path,"vunit/vhdl"))
    name = 'vunit'
    vhld_lib0 = Library()
    vhld_lib0.add_description(text_p="")
    vhld_lib0.set_name(name_p=name)
    vhld_lib0.add_filename(name_p="")
    vhld_lib0.set_path(path_p=path)
    vhld_lib0.set_version(value_p='2008')
    vhld_lib0.set_compile_lib(name_p="vunit_lib")
    vhdl_dic0 = vhld_lib0.get_dic()
    vhdl_lib_dic[name] = vhdl_dic0

    # xpm
    path = str(Path(vivado_path,"data/ip/xpm"))
    name = 'xpm'
    vhld_lib0 = Library()
    vhld_lib0.add_description(text_p="")
    vhld_lib0.set_name(name_p=name)
    vhld_lib0.add_filename(name_p="xpm_cdc/hdl/xpm_cdc.sv")
    vhld_lib0.add_filename(name_p="xpm_memory/hdl/xpm_memory.sv")
    vhld_lib0.add_filename(name_p="xpm_fifo/hdl/xpm_fifo.sv")
    vhld_lib0.add_filename(name_p="xpm_VCOMP.vhd")
    vhld_lib0.set_path(path_p=path)
    vhld_lib0.set_version(value_p='93')
    vhld_lib0.set_compile_lib(name_p="xpm")
    vhdl_dic0 = vhld_lib0.get_dic()
    vhdl_lib_dic[name] = vhdl_dic0

    # coregen
    path = xilinx_coregen_path
    name = 'coregen'
    vhld_lib0 = Library()
    vhld_lib0.add_description(text_p="")
    vhld_lib0.set_name(name_p=name)
    vhld_lib0.add_filename(name_p="selectio_wiz_adc/selectio_wiz_adc_selectio_wiz.v")
    vhld_lib0.add_filename(name_p="selectio_wiz_adc/selectio_wiz_adc.v")
    vhld_lib0.add_filename(name_p="fpasim_clk_wiz_0/fpasim_clk_wiz_0_clk_wiz.v")
    vhld_lib0.add_filename(name_p="fpasim_clk_wiz_0/fpasim_clk_wiz_0.v")
    vhld_lib0.add_filename(name_p="fpasim_top_ila_0/sim/fpasim_top_ila_0.vhd")
    vhld_lib0.add_filename(name_p="fpasim_regdecode_top_ila_0/sim/fpasim_regdecode_top_ila_0.vhd")
    vhld_lib0.set_path(path_p=path)
    vhld_lib0.set_version(value_p='2008')
    vhld_lib0.set_compile_lib(name_p="fpasim")
    vhdl_dic0 = vhld_lib0.get_dic()
    vhdl_lib_dic[name] = vhdl_dic0

    # define the python library
    ##############################################
    py_lib_dic = {}
    # vunit_lib
    path = str(Path(vunit_path,""))
    name = "vunit"
    py_lib0 = Library()
    py_lib0.add_description(text_p="")
    py_lib0.set_name(name_p=name)
    py_lib0.add_filename(name_p="")
    py_lib0.set_path(path_p=path)
    py_lib0.set_compile_lib(name_p="vunit")
    py_dic0 = py_lib0.get_dic()
    py_lib_dic[name] = py_dic0

    # utils
    path = vhdl_simu_lib_base_path
    name = "vhdl_simu"
    py_lib0 = Library()
    py_lib0.add_description(text_p="")
    py_lib0.set_name(name_p=name)
    py_lib0.add_filename(name_p="")
    py_lib0.set_path(path_p=path)
    py_lib0.set_compile_lib(name_p="utils")
    py_dic0 = py_lib0.get_dic()
    py_lib_dic[name] = py_dic0


    # lib description
    #################################
    description_list = []
    description_list.append("")
    dic = {}
    dic['description'] = description_list
    dic['vhdl'] = vhdl_lib_dic
    dic['python'] = py_lib_dic
    json_data["lib"] = dic


    ###########################################
    # define test
    ###########################################
    test_list = []
    # define relative basepath
    conf_relpath = './simu/conf/fpasim/adc'
    run_relpath = './simu/vunit/fpasim/adc'
    out_relpath = './vunit_out/fpasim/adc'
    wave_relpath = './simu/wave/fpasim/adc'
    # build path
    relfilepath_list = []
    relfilepath_list.append(str(Path(root_path,conf_relpath,'blabla.json')))
    relfilepath_list.append(str(Path(root_path,conf_relpath,'blabla.json')))
    run_filepath = str(Path(root_path,run_relpath,'run_tmp.py'))
    output_path = str(Path(root_path,out_relpath))
    wave_filepath = str(Path(root_path,wave_relpath,'wave_run_tmp.do'))
    # generate json dictionnary
    test0 = DUT()
    test0.add_description(text_p="")
    test0.set_name(name_p="adc_tb_test1")
    for relfilepath in relfilepath_list:
        path = str(Path(root_path,relfilepath))
        test0.add_json_filepath(path_p=path)
    test0.set_run_filepath(path_p=run_filepath)
    test0.set_out_path(path_p=output_path)
    test0.set_wave_filepath(path_p=wave_filepath)
    test_dic0 = test0.get_dic()
    test_list.append(test_dic0)

    # build path
    relfilepath_list = []
    relfilepath_list.append(str(Path(root_path,conf_relpath,'blabla.json')))
    run_filepath = str(Path(root_path,run_relpath,'run_tmp.py'))
    output_path = str(Path(root_path,out_relpath))
    wave_filepath = str(Path(root_path,wave_relpath,'wave_run_tmp.do'))
    # generate json dictionnary
    test0 = DUT()
    test0.add_description(text_p="")
    test0.set_name(name_p="adc_tb_test2")
    for relfilepath in relfilepath_list:
        path = str(Path(root_path,relfilepath))
        test0.add_json_filepath(path_p=path)
    test0.set_run_filepath(path_p=run_filepath)
    test0.set_out_path(path_p=output_path)
    test0.set_wave_filepath(path_p=wave_filepath)
    test_dic0 = test0.get_dic()
    test_list.append(test_dic0)

    json_data["test_list0"] = test_list 

    #########################################
    # build an another test_list
    #########################################

    test_list = []
    # define relative basepath
    conf_relpath = ''
    run_relpath = './simu/vunit/tmp_test'
    out_relpath = './vunit_out/tmp_test'
    # wave_relpath = './simu/wave/fpasim/adc'
    # build path
    relfilepath_list = []
    relfilepath_list.append("")
    run_filepath = str(Path(root_path,run_relpath,'run_sim.py'))
    output_path = str(Path(root_path,out_relpath))
    wave_filepath = ""
    # generate json dictionnary
    test0 = DUT()
    test0.add_description(text_p="")
    test0.set_name(name_p="adc_tb_test1")
    for relfilepath in relfilepath_list:
        path = str(Path(root_path,relfilepath))
        test0.add_json_filepath(path_p=path)
    test0.set_run_filepath(path_p=run_filepath)
    test0.set_out_path(path_p=output_path)
    test0.set_wave_filepath(path_p=wave_filepath)
    test_dic0 = test0.get_dic()
    test_list.append(test_dic0)

    json_data["test_list1"] = test_list 


    ##################################
    # output the processed json file with updated address path
    ##################################
    # Serializing then json dictionnary
    json_object = json.dumps(json_data, indent=4)
    # Writing to the output json file
    fid_out.write(json_object)
    fid_out.close()

    print(ConsoleColors.reset)



    
