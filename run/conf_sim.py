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

class VhdlLibrary():
    def __init__(self):
        self.description_list = []
        self.name = ""
        self.filepath_list = []
        self.directory_path_list = []
        self.version = None
        self.library_name = None


    def add_description(self,text_p):
        self.description_list.append(text_p)

    def _build_path(self,path_p,library_name_p,version_p):
        return library_name_p + '@' + version_p + '@'  + path_p

    def _get_version(self,version_p):
        if version_p == None:
            return self.version
        else:
            return version_p

    def _get_library_name(self,library_name_p):
        if library_name_p == None:
            return self.library_name
        else:
            return library_name_p

    def set_name(self,name_p):
        self.name = name_p

    def set_library_name(self,library_name_p):
        self.library_name = library_name_p

    def set_version(self,version_p):
        self.version = version_p

    def add_filepath(self,filepath_p,library_name_p=None,version_p=None):
        filepath = str(Path(filename_p).resolve())
        version = self._get_version(version_p=version_p)
        library_name = self._get_library_name(library_name_p=library_name_p)
        str0 = self._build_path(path_p=filepath,library_name_p=library_name,version_p=version)
        self.filepath_list.append(str0)

    def add_filepath(self,base_path_p,name_p,library_name_p=None,version_p=None):
        filepath = str(Path(base_path_p,name_p).resolve())
        version = self._get_version(version_p=version_p)
        library_name = self._get_library_name(library_name_p=library_name_p)
        str0 = self._build_path(path_p=filepath,library_name_p=library_name,version_p = version)
        self.filepath_list.append(str0)

    def add_directory_path(self,base_path_p,library_name_p=None,version_p=None):
        path = str(Path(base_path_p).resolve())
        version = self._get_version(version_p=version_p)
        library_name = self._get_library_name(library_name_p=library_name_p)
        str0 = self._build_path(path_p=path,library_name_p=library_name,version_p=version)
        self.directory_path_list.append(str0)



    def get_dic(self):
        
        dic = {}
        dic["description"] = self.description_list
        dic["name"] = self.name
        dic["compile_lib@version@filepath_list"] = self.filepath_list
        dic["compile_lib@version@directory_path_list"] = self.directory_path_list
        return dic

class PyLibrary():
    def __init__(self):
        self.description_list = []
        self.name = ""
        self.filepath_list = []
        self.directory_path_list = []
        self.version = None
        self.library_name = None


    def add_description(self,text_p):
        self.description_list.append(text_p)

    def set_name(self,name_p):
        self.name = name_p


    def add_directory_path(self,base_path_p,library_name_p=None,version_p=None):
        path = str(Path(base_path_p).resolve())
        self.directory_path_list.append(path)

    def get_dic(self):
        
        dic = {}
        dic["description"] = self.description_list
        dic["name"] = self.name
        dic["directory_path_list"] = self.directory_path_list
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
        path = str(Path(path_p).resolve())
        self.filepath_list.append(path)
    def set_run_filepath(self,path_p):
        path = str(Path(path_p).resolve())
        self.run_filepath = path
    def set_out_path(self,path_p):
        path = str(Path(path_p).resolve())
        self.out_path = path
    def set_wave_filepath(self,path_p):
        path = str(Path(path_p).resolve())
        self.wave_filepath = path

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

    ############################################
    # define compilation library name
    ############################################
    xpm_compile_name_lib = 'xpm'
    unisim_compile_name_lib = 'unisim'
    src_compile_name_lib = 'fpasim'
    csv_compile_name_lib = 'csv_lib'
    vhdl_simu_compile_name_lib = 'vhdl_simu_lib'
    opal_kelly_compile_name_lib = 'opal_kelly_lib'
    vunit_compile_name_lib = 'vunit_lib'

    # lib path (python/VHDL)
    ############################################
    # csv lib
    relpath = './lib/csv'
    lib_csv_base_path_py = str(Path(root_path,relpath).resolve())
    lib_csv_base_path_vhdl = str(Path(lib_csv_base_path_py,'csv/vhdl/src').resolve())

    # vhdl_simu_lib
    relpath = './lib/vhdl_simu'
    lib_vhdl_simu_base_path_py = str(Path(root_path,relpath).resolve())
    lib_vhdl_simu_base_path_vhdl = str(Path(lib_vhdl_simu_base_path_py,'vhdl_simu/vhdl/src').resolve())

    # common
    relpath = './lib/common'
    lib_common_base_path_py = str(Path(root_path,relpath).resolve())


    # opal_kelly_lib
    relpath = './lib/vhdl_opal_kelly'
    lib_opal_kelly_base_path_py = str(Path(root_path,relpath).resolve())
    lib_opal_kelly_base_path_vhdl = str(Path(lib_opal_kelly_base_path_py,'vhdl_opal_kelly/vhdl/src').resolve())

    # ip path (python/VHDL)
    ############################################
    # coregen
    relpath = './ip/xilinx/coregen'
    ip_xilinx_coregen_base_path_vhdl = str(Path(root_path,relpath).resolve())

    # opal kelly
    relpath = './ip/opal_kelly/simu'
    ip_opal_kelly_base_path_vhdl = str(Path(root_path,relpath).resolve())

    # xpm
    relpath = './ip/xilinx/xpm'
    ip_user_xpm_base_path_vhdl = str(Path(root_path,relpath).resolve())

    # vhdl path (python/VHDL)
    ############################################
    # hdl functions path
    relpath = './src/hdl'
    hdl_base_path = str(Path(root_path,relpath).resolve())

    # clocking function
    relpath = './src/hdl/clocking'
    hdl_clocking_base_path = str(Path(root_path,relpath).resolve())

    # fpasim function
    relpath = './src/hdl/fpasim'
    hdl_fpasim_base_path = str(Path(root_path,relpath).resolve())

    # fpasim/adc function
    relpath = './src/hdl/fpasim/adc'
    hdl_fpasim_adc_base_path = str(Path(root_path,relpath).resolve())

    # fpasim/amp_squid function
    relpath = './src/hdl/fpasim/amp_squid'
    hdl_fpasim_amp_squid_base_path = str(Path(root_path,relpath).resolve())

    # fpasim/dac function
    relpath = './src/hdl/fpasim/dac'
    hdl_fpasim_dac_base_path = str(Path(root_path,relpath).resolve())

    # fpasim/mux_squid function
    relpath = './src/hdl/fpasim/mux_squid'
    hdl_fpasim_mux_squid_base_path = str(Path(root_path,relpath).resolve())

    # fpasim/sync function
    relpath = './src/hdl/fpasim/sync'
    hdl_fpasim_sync_base_path = str(Path(root_path,relpath).resolve())

    # fpasim/tes function
    relpath = './src/hdl/fpasim/tes'
    hdl_fpasim_tes_base_path = str(Path(root_path,relpath).resolve())

    # fpasim/regdecode function
    relpath = './src/hdl/fpasim/regdecode'
    hdl_fpasim_regdecode_base_path = str(Path(root_path,relpath).resolve())

    # io function
    relpath = './src/hdl/io'
    hdl_io_base_path = str(Path(root_path,relpath).resolve())

    # usb function
    relpath = './src/hdl/usb'
    hdl_usb_base_path = str(Path(root_path,relpath).resolve())

    # utils function
    relpath = './src/hdl/utils'
    hdl_utils_base_path = str(Path(root_path,relpath).resolve())




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
    # define the ip section
    ####################################################
    ip_vhdl_dic = {}
    # xpm
    path = str(Path(vivado_path,"data/ip/xpm"))
    path0 = ip_user_xpm_base_path_vhdl
    name = 'xpm'
    vhld_lib0 = VhdlLibrary()
    vhld_lib0.add_description(text_p="")
    vhld_lib0.set_name(name_p=name)
    vhld_lib0.set_library_name(library_name_p=xpm_compile_name_lib)
    vhld_lib0.set_version(version_p='93')
    vhld_lib0.add_filepath(base_path_p=path,name_p="xpm_cdc/hdl/xpm_cdc.sv")
    vhld_lib0.add_filepath(base_path_p=path,name_p="xpm_memory/hdl/xpm_memory.sv")
    vhld_lib0.add_filepath(base_path_p=path,name_p="xpm_fifo/hdl/xpm_fifo.sv")
    vhld_lib0.add_filepath(base_path_p=path,name_p="xpm_VCOMP.vhd")
    vhld_lib0.set_library_name(library_name_p=src_compile_name_lib)
    vhld_lib0.set_version(version_p='2008')
    vhld_lib0.add_directory_path(base_path_p=path0)
    vhdl_dic0 = vhld_lib0.get_dic()
    ip_vhdl_dic[name] = vhdl_dic0

    # unisim
    path = str(Path(vivado_path,"data/vhdl/src/unisims"))
    path0 = str(Path(vivado_path,"data/vhdl/src/unisims/primitive"))
    name = 'unisim'
    vhld_lib0 = VhdlLibrary()
    vhld_lib0.add_description(text_p="")
    vhld_lib0.set_name(name_p=name)
    vhld_lib0.set_library_name(library_name_p=src_compile_name_lib)
    vhld_lib0.set_version(version_p='2008')
    vhld_lib0.add_filepath(base_path_p=path,name_p="unisim_VPKG.vhd")
    vhld_lib0.add_filepath(base_path_p=path,name_p="unisim_VCOMP.vhd")

    vhld_lib0.add_directory_path(base_path_p=path0)
    vhdl_dic0 = vhld_lib0.get_dic()
    ip_vhdl_dic[name] = vhdl_dic0


    # coregen
    path = ip_xilinx_coregen_base_path_vhdl
    name = 'coregen'
    vhld_lib0 = VhdlLibrary()
    vhld_lib0.add_description(text_p="")
    vhld_lib0.set_name(name_p=name)
    vhld_lib0.set_library_name(library_name_p=src_compile_name_lib)
    vhld_lib0.set_version(version_p='2008')
    vhld_lib0.add_filepath(base_path_p=path,name_p="selectio_wiz_adc/selectio_wiz_adc_selectio_wiz.v")
    vhld_lib0.add_filepath(base_path_p=path,name_p="selectio_wiz_adc/selectio_wiz_adc.v")
    vhld_lib0.add_filepath(base_path_p=path,name_p="selectio_wiz_sync/selectio_wiz_sync_selectio_wiz.v")
    vhld_lib0.add_filepath(base_path_p=path,name_p="selectio_wiz_sync/selectio_wiz_sync.v")
    vhld_lib0.add_filepath(base_path_p=path,name_p="selectio_wiz_dac/selectio_wiz_dac_selectio_wiz.v")
    vhld_lib0.add_filepath(base_path_p=path,name_p="selectio_wiz_dac/selectio_wiz_dac.v")
    vhld_lib0.add_filepath(base_path_p=path,name_p="fpasim_clk_wiz_0/fpasim_clk_wiz_0_clk_wiz.v")
    vhld_lib0.add_filepath(base_path_p=path,name_p="fpasim_clk_wiz_0/fpasim_clk_wiz_0.v")
    vhld_lib0.add_filepath(base_path_p=path,name_p="fpasim_top_ila_0/sim/fpasim_top_ila_0.vhd")
    vhld_lib0.add_filepath(base_path_p=path,name_p="fpasim_regdecode_top_ila_0/sim/fpasim_regdecode_top_ila_0.vhd")
    vhdl_dic0 = vhld_lib0.get_dic()
    ip_vhdl_dic[name] = vhdl_dic0

    # coregen
    path = ip_opal_kelly_base_path_vhdl
    name = 'opal_kelly'
    vhld_lib0 = VhdlLibrary()
    vhld_lib0.add_description(text_p="")
    vhld_lib0.set_name(name_p=name)
    vhld_lib0.set_library_name(library_name_p=src_compile_name_lib)
    vhld_lib0.set_version(version_p='2008')
    vhld_lib0.add_directory_path(base_path_p=path)
    vhdl_dic0 = vhld_lib0.get_dic()
    ip_vhdl_dic[name] = vhdl_dic0



     # ip description
    #################################
    description_list = []
    description_list.append("")
    dic = {}
    dic['description'] = description_list
    dic['vhdl'] = ip_vhdl_dic
    json_data["ip"] = dic

    ####################################################
    # define the lib section
    ####################################################

    # define the vhdl library
    ##############################################
    lib_vhdl_dic = {}
    # csv_lib
    path = lib_csv_base_path_py
    name = 'csv'
    vhld_lib0 = VhdlLibrary()
    vhld_lib0.add_description(text_p="")
    vhld_lib0.set_name(name_p=name)
    vhld_lib0.set_library_name(library_name_p=csv_compile_name_lib)
    vhld_lib0.set_version(version_p='2008')
    vhld_lib0.add_directory_path(base_path_p=path)
    vhdl_dic0 = vhld_lib0.get_dic()
    lib_vhdl_dic[name] = vhdl_dic0

    # vhdl_simu_lib
    path = lib_vhdl_simu_base_path_vhdl
    name = 'vhdl_simu'
    vhld_lib0 = VhdlLibrary()
    vhld_lib0.add_description(text_p="")
    vhld_lib0.set_name(name_p=name)
    vhld_lib0.set_library_name(library_name_p=csv_compile_name_lib)
    vhld_lib0.set_version(version_p='2008')
    vhld_lib0.add_directory_path(base_path_p=path)
    vhdl_dic0 = vhld_lib0.get_dic()
    lib_vhdl_dic[name] = vhdl_dic0

    # opal_kelly_lib
    path = lib_opal_kelly_base_path_vhdl
    name = 'vhdl_opal_kelly'
    vhld_lib0 = VhdlLibrary()
    vhld_lib0.add_description(text_p="")
    vhld_lib0.set_name(name_p=name)
    vhld_lib0.set_library_name(library_name_p=opal_kelly_compile_name_lib)
    vhld_lib0.set_version(version_p='2008')
    vhld_lib0.add_directory_path(base_path_p=path)
    vhdl_dic0 = vhld_lib0.get_dic()
    lib_vhdl_dic[name] = vhdl_dic0

    # vunit_lib
    path = str(Path(vunit_path,"vunit/vhdl"))
    name = 'vunit'
    vhld_lib0 = VhdlLibrary()
    vhld_lib0.add_description(text_p="")
    vhld_lib0.set_name(name_p=name)
    vhld_lib0.set_library_name(library_name_p=vunit_compile_name_lib)
    vhld_lib0.set_version(version_p='2008')
    vhld_lib0.add_directory_path(base_path_p=path)
    vhdl_dic0 = vhld_lib0.get_dic()
    lib_vhdl_dic[name] = vhdl_dic0

    # define the python library
    ##############################################
    lib_py_dic = {}
    # vunit_lib
    path = str(Path(vunit_path,""))
    name = "vunit"
    py_lib0 = PyLibrary()
    py_lib0.add_description(text_p="")
    py_lib0.set_name(name_p=name)
    py_lib0.add_directory_path(base_path_p=path)
    py_dic0 = py_lib0.get_dic()
    lib_py_dic[name] = py_dic0

    # utils
    path = lib_vhdl_simu_base_path_py
    name = "vhdl_simu"
    py_lib0 = PyLibrary()
    py_lib0.add_description(text_p="")
    py_lib0.set_name(name_p=name)
    py_lib0.add_directory_path(base_path_p=path)
    py_dic0 = py_lib0.get_dic()
    lib_py_dic[name] = py_dic0

    # utils
    path = lib_common_base_path_py
    name = "common"
    py_lib0 = PyLibrary()
    py_lib0.add_description(text_p="")
    py_lib0.set_name(name_p=name)
    py_lib0.add_directory_path(base_path_p=path)
    py_dic0 = py_lib0.get_dic()
    lib_py_dic[name] = py_dic0


    # lib description
    #################################
    description_list = []
    description_list.append("")
    dic = {}
    dic['description'] = description_list
    dic['vhdl'] = lib_vhdl_dic
    dic['python'] = lib_py_dic
    json_data["lib"] = dic

    ####################################################
    # define the src section
    ####################################################
    src_relpath = './src/hdl'
    dic_tmp = {}
    path = str(Path(root_path,src_relpath))
    name = 'system'
    vhld_lib0 = VhdlLibrary()
    vhld_lib0.add_description(text_p="")
    vhld_lib0.set_name(name_p=name)
    vhld_lib0.set_library_name(library_name_p=src_compile_name_lib)
    vhld_lib0.set_version(version_p='2008')
    vhld_lib0.add_directory_path(base_path_p=path)
    vhdl_dic0 = vhld_lib0.get_dic()
    dic_tmp[name] = vhdl_dic0

    path = str(Path(root_path,src_relpath,'clocking'))
    name = 'clocking'
    vhld_lib0 = VhdlLibrary()
    vhld_lib0.add_description(text_p="")
    vhld_lib0.set_name(name_p=name)
    vhld_lib0.set_library_name(library_name_p=src_compile_name_lib)
    vhld_lib0.set_version(version_p='2008')
    vhld_lib0.add_directory_path(base_path_p=path)
    vhdl_dic0 = vhld_lib0.get_dic()
    dic_tmp[name] = vhdl_dic0

    path = str(Path(root_path,src_relpath,'fpasim'))
    name = 'fpasim'
    vhld_lib0 = VhdlLibrary()
    vhld_lib0.add_description(text_p="")
    vhld_lib0.set_name(name_p=name)
    vhld_lib0.set_library_name(library_name_p=src_compile_name_lib)
    vhld_lib0.set_version(version_p='2008')
    vhld_lib0.add_directory_path(base_path_p=path)
    vhdl_dic0 = vhld_lib0.get_dic()
    dic_tmp[name] = vhdl_dic0

    path = str(Path(root_path,src_relpath,'io'))
    name = 'io'
    vhld_lib0 = VhdlLibrary()
    vhld_lib0.add_description(text_p="")
    vhld_lib0.set_name(name_p=name)
    vhld_lib0.set_library_name(library_name_p=src_compile_name_lib)
    vhld_lib0.set_version(version_p='2008')
    vhld_lib0.add_directory_path(base_path_p=path)
    vhdl_dic0 = vhld_lib0.get_dic()
    dic_tmp[name] = vhdl_dic0

    path = str(Path(root_path,src_relpath,'utils'))
    name = 'io'
    vhld_lib0 = VhdlLibrary()
    vhld_lib0.add_description(text_p="")
    vhld_lib0.set_name(name_p=name)
    vhld_lib0.set_library_name(library_name_p=src_compile_name_lib)
    vhld_lib0.set_version(version_p='2008')
    vhld_lib0.add_directory_path(base_path_p=path)
    vhdl_dic0 = vhld_lib0.get_dic()
    dic_tmp[name] = vhdl_dic0

    json_data['src'] = dic_tmp





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



    
