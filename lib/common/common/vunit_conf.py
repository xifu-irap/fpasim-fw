# standard library
import os

from shutil import copy
import subprocess
from pathlib import Path
import re
import json

from common import FilepathListBuilder, Display


class VunitConf:
    """
    """
    content = []

    def __init__(self, json_filepath_p,script_name_p):
        """
        Initialize the object
        """
        self.tb_input_basepath = ''
        self.tb_output_basepath = ''
        self.json_conf_filepath = ''

        self.simulator_name = 'modelsim'

        self.display_obj = Display()

        # self.debug_p              = debug_p
        self.script_name = script_name_p

        self.json_filepath = json_filepath_p
        # Opening JSON file
        fid_in = open(json_filepath_p, 'r')

        # returns JSON object as 
        # a dictionary
        self.json_data = json.load(fid_in)

        # Closing file
        fid_in.close()



    def set_vunit_simulator(self, name_p, level_p=0):
        '''
        This function allows to set the environment variables necessary to the VUNIT library
        These environment variables are mandatory  to correctly work with the modelsim/questa simulator
        :param simulator_name: (string) -> possibles values are: 'modelsim' or 'questa'
        :param debug_p: (string) -> print debug_p message if the value is 'true'
        :return:
        '''
        script_name = self.script_name
        json_data   = self.json_data
        display_obj = self.display_obj
        level0      = level_p
        level1      = level_p + 1

        modelsim_path = json_data['vunit_modelsim_path']["path"]
        questa_path   = json_data['vunit_questa_path']["path"]


        display_obj.display_title(msg_p = 'Define Simulator',level_p = level0)
        if name_p == 'modelsim':
            msg0 = name_p + ': ' + modelsim_path
            display_obj.display(msg_p= msg0,level_p=level1)
            os.environ['VUNIT_SIMULATOR']     = 'modelsim'
            os.environ['VUNIT_MODELSIM_PATH'] = modelsim_path
        elif name_p == 'questa':
            msg0 = name_p + ': ' + questa_path
            display_obj.display(msg_p= msg0,level_p=level1)
            os.environ['VUNIT_SIMULATOR']     = 'modelsim'
            os.environ['VUNIT_MODELSIM_PATH'] = questa_path

    def _add_library(self,vunit_object_p,name_p):
        VU = vunit_object_p

        library_list = VU.get_libraries(name_p,allow_empty = True)
        found = 0
        for library_obj in library_list:
            if name_p == library_obj.name:
                found = 1
        if found == 0:
            VU.add_library(name_p)
        return VU

    def _compile_src(self, vunit_object_p, key_name_list_p, level_p = 0):

        json_data = self.json_data
        script_name = self.script_name
        VU = vunit_object_p
        display_obj = self.display_obj
        level0      = level_p
        level1      = level_p + 1

        # dic = json_data["ip"]["vhdl"][key_name_p]
        dic = json_data
        for key in key_name_list_p:
        # for key in ["ip","vhdl",key_name_p]:
            dic = dic[key]
        name                    = dic["name"]
        src_filepath_list       = dic["compile_lib@version@filepath_list"]
        src_directory_path_list = dic["compile_lib@version@directory_path_list"]

        
     
        tmp_library_name_list = []
        tmp_version_list      = []
        tmp_filepath_list     = []
        for src_filepath in src_filepath_list:
                library_name,version,filepath = src_filepath.split('@')
                filepath = str(Path(filepath).resolve())

                tmp_library_name_list.append(library_name)
                tmp_version_list.append(version)
                tmp_filepath_list.append(filepath)


        for src_directory_path in src_directory_path_list:
            library_name,version,directory_path = src_directory_path.split('@')
            path = str(Path(directory_path).resolve())
            obj = FilepathListBuilder()
            obj.add_basepath(basepath_p=path)
            filepath_list = obj.get_filepath_list()


            # duplicate the library name
            L = len(filepath_list)
            tmp_library_name_list.extend([library_name]*L)
            tmp_version_list.extend([version]*L)
            tmp_filepath_list.extend(filepath_list)
  
        # add the library names
        library_name_set = set(tmp_library_name_list)
        for library_name in library_name_set:
            VU = self._add_library(vunit_object_p,name_p=library_name)

        display_obj.display_title(msg_p = name+ ' Ip Compilation (library_name:version:path)',level_p = level0)
        for library_name,version,filepath in zip(tmp_library_name_list,tmp_version_list,tmp_filepath_list):
            file_tmp = VU.add_source_file(filepath,vhdl_standard=version,library_name=library_name)
            path = str(Path(file_tmp.name).resolve())
            msg0 = library_name+ ':'+version+":"+path
            display_obj.display(msg_p = msg0,level_p = level1)


        # return VU

    def compile_xilinx_xpm_ip(self, vunit_object_p, level_p = 0):

        self._compile_src(vunit_object_p=vunit_object_p,key_name_list_p=["ip","vhdl",'xpm'],level_p=level_p)

    def compile_xilinx_coregen_ip(self, vunit_object_p, level_p = 0):
        self._compile_src(vunit_object_p=vunit_object_p,key_name_list_p=["ip","vhdl",'coregen'],level_p=level_p)


    def compile_opal_kelly_ip(self, vunit_object_p, level_p = 0):

        self._compile_src(vunit_object_p=vunit_object_p,key_name_list_p=["ip","vhdl",'opal_kelly'],level_p=level_p)

    def compile_unisim_ip(self, vunit_object_p, level_p = 0):

        self._compile_src(vunit_object_p=vunit_object_p,key_name_list_p=["ip","vhdl",'unisim'],level_p=level_p)



    def set_script(self, python_script_path, tb_input_basepath, tb_output_basepath, json_conf_filepath, debug_p='false'):
        '''
        This functions overwrites different kind of filepaths
        Note: This function must be used before the "pre_config" method
        :param python_script_path: (string) -> filepath to the python executable file
        :param tb_input_basepath: (string) -> basepath to the input testbench files
        :param tb_output_basepath: (string) -> basepath to the output testbench files
        :param json_conf_filepath: (string) -> filepath to the json files
        :param debug_p: (string) -> print debug_p message if the value is 'true'
        :return:
        '''
        ################################
        # create directories (if not exist) for the VHDL testbench
        #  .input directory  for the input data/command files
        #  .output directory for the output data files
        rfem_utils.create_directory(path=tb_input_basepath)
        rfem_utils.create_directory(path=tb_output_basepath)
        self.debug_p = debug_p
        self.python_script_path = python_script_path
        self.tb_input_basepath = tb_input_basepath
        self.tb_output_basepath = tb_output_basepath
        self.json_conf_filepath = json_conf_filepath

    def create_directory(self, path):
        '''
        This function create the directory tree defined by the "path" argument (if not exist)
        :param path: (string) -> path 
        :return:
        '''
        """
        create the necessary directory (if not exist)
        :param path:
        :return:
        """
        if not os.path.exists(path):
            os.makedirs(path)
            print("Directory ", path, " Created ")
        else:
            print("Directory ", path, " already exists")

    def set_mif_files(self, filepath_list):
        """
        This function stores a list of *.mif files
        Note: This function must be used by IP as Xilinx "FIR" IP
        :param filepath_list: (string) -> list of filepaths
        :return:
        """
        self.filepath_list_mif = filepath_list

    def copy_mif_files(self, output_path, debug_p):
        """
        copy a list of *.mif files into the Vunit simulation directory ("./Vunit_out/modelsim")
        Note: the expected destination directory is "./Vunit_out/modelsim"
        :param output_path: (string) -> output path provided by the Vunit library
        :param debug_p: (string) -> print debug_p message if the value is 'true'
        :return:
        """
        script_name = self.script_name

        # get absolute path
        script_path = Path(output_path).resolve()
        # move into the hierarchy : vunit_out/modelsim
        output_path = str(script_path.parents[1]) + sep + "modelsim"
        if debug_p == 'true':
            print(script_name + "copy the *.mif into the Vunit simulation directory")

        # copy each files
        for filepath in self.filepath_list_mif:
            if debug_p == 'true':
                print(script_name + "the filepath :" + filepath + " is copied to " + output_path)
            copy(filepath, output_path)

    def pre_config(self, output_path):
        """
        Define a list of actions to do before launching the simulator
        2 actions are provided:
          . execute a python script with a predefined set of command line arguments
          . copy the "mif files" into the Vunit simulation director for the compatible Xilinx IP (ex: FIR IP)
        :param output_path:
        :return:
        """

        python_exe_path = self.python_exe_path
        python_script_path = self.python_script_path
        tb_input_filepath = self.tb_input_basepath
        tb_output_filepath = self.tb_output_basepath
        json_conf_filepath = self.json_conf_filepath
        debug_p = self.debug_p
        script_name = self.script_name

        if debug_p == 'true':
            print(script_name + 'output path :', output_path, ', output_filepath:', tb_output_filepath,
                  ' ,input_filepath:', tb_input_filepath)
            print(script_name + 'python_exe_path: ', python_exe_path, ' ,python_script_path: ', python_script_path)

        # launch a python script to generate data and commands
        subprocess.run([
            self.python_exe_path, self.python_script_path,
            '-base_address_in', tb_input_filepath,
            '-base_address_out', tb_output_filepath,
            '-json_conf_filepath', json_conf_filepath,
            '-debug_p', debug_p
        ], stderr=subprocess.PIPE)

        # copy the mif files into the Vunit simulation directory
        if self.filepath_list_mif != []:
            self.copy_mif_files(output_path=output_path, debug_p=debug_p)

        # return True is mandatory for Vunit
        return True
