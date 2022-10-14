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

    def _compile_ip(self, vunit_object_p, key_name_p, level_p = 0):

        json_data = self.json_data
        script_name = self.script_name
        VU = vunit_object_p
        display_obj = self.display_obj
        level0      = level_p
        level1      = level_p + 1

        dic = json_data["ip"]["vhdl"][key_name_p]
        name          = dic["name"]
        library_name  = dic["compile_lib"]
        version       = dic["version"]
        filepath_list = dic["filepath_list"]
        directory_path_list = dic["directory_path_list"]

        VU = self._add_library(vunit_object_p,name_p=library_name)
        display_obj.display_title(msg_p = name+ ' Ip Compilation (library_name: path)',level_p = level0)
        obj = FilepathListBuilder()
        for filepath in filepath_list:
                filepath = str(Path(filepath).resolve())
                obj.add_filepath(filepath_p=filepath)
        for directory_path in directory_path_list:
            path = str(Path(directory_path).resolve())
            obj.add_basepath(basepath_p=path)


        filepath_list = obj.get_filepath_list()
        file_list = VU.add_source_files(filepath_list,vhdl_standard=version,library_name=library_name)
        for file in file_list:
            path = str(Path(file.name).resolve())
            msg0 = library_name+ ': '+path
            display_obj.display(msg_p = msg0,level_p = level1)


        # return VU

    def compile_xilinx_xpm_ip(self, vunit_object_p, level_p = 0):

        self._compile_ip(vunit_object_p=vunit_object_p,key_name_p='xpm',level_p=level_p)
        self._compile_ip(vunit_object_p=vunit_object_p,key_name_p='user_xpm',level_p=level_p)

    def compile_xilinx_coregen_ip(self, vunit_object_p, level_p = 0):
        self._compile_ip(vunit_object_p=vunit_object_p,key_name_p='coregen',level_p=level_p)


    def compile_opal_kelly_ip(self, vunit_object_p, level_p = 0):

        self._compile_ip(vunit_object_p=vunit_object_p,key_name_p='opal_kelly',level_p=level_p)







    def add_xilinx_precompile_name_lib(self, name):
        '''
        This function add the "name" argument to the internal list if the name is not already present
        :param name: (string) -> name to add if not already present in the list
        :return:
        '''
        first = 1
        # check if the name is in the internal list
        for compile_name in self.xilinx_external_library_name_list:
            if compile_name == name:
                first = 0

        if first == 1:
            self.xilinx_external_library_name_list.append(name)

    def add_xilinx_default_dependencies_lib(self):
        '''
        This function defines the default library names of Xilinx precompiled libraries.
        Note: Each added library name will be used as external library by the Vunit object
        Note: All VHDL testbench files should add theses libraries
        :return:
        '''
        self.add_xilinx_precompile_name_lib(name='xilinx_vip')
        self.add_xilinx_precompile_name_lib(name='xpm')
        self.add_xilinx_precompile_name_lib(name='unisims_ver')
        self.add_xilinx_precompile_name_lib(name='unisim')
        self.add_xilinx_precompile_name_lib(name='unimacro')
        self.add_xilinx_precompile_name_lib(name='unimacro_ver')
        self.add_xilinx_precompile_name_lib(name='unifast')
        self.add_xilinx_precompile_name_lib(name='secureip')

    def add_xilinx_axi_interconnect_ddr_dependencies_lib(self):
        '''
        This function defines the library names of Xilinx precompiled libraries specific to
        the Xilinx "AXI_interconnect_DDR" IP
        Note: Each added library name will be used as external library by the Vunit object
        :return:
        '''
        # Axi_interconnect_DDR
        self.add_xilinx_precompile_name_lib(name='fifo_generator_v13_2_4')
        self.add_xilinx_precompile_name_lib(name='axi_interconnect_v1_7_16')

    def add_xilinx_migddr4_dependencies_lib(self):
        '''
        This function defines the library names of Xilinx precompiled libraries specific to the
        Xilinx "MigDDR4" Ip
        Note: Each added library name will be used as external library by the Vunit object
        :return:
        '''
        self.add_xilinx_precompile_name_lib(name='microblaze_v11_0_1')
        self.add_xilinx_precompile_name_lib(name='lmb_v10_v3_0_9')
        self.add_xilinx_precompile_name_lib(name='lmb_bram_if_cntlr_v4_0_16')
        self.add_xilinx_precompile_name_lib(name='blk_mem_gen_v8_4_3')
        self.add_xilinx_precompile_name_lib(name='iomodule_v3_1_4')


    def add_xilinx_fir_dependencies_lib(self):
        '''
        This function defines the library names of Xilinx precompiled libraries specific to the
        Xilinx "FIR" Ip
        Note: Each added library name will be used as external library by the Vunit object
        :return:
        '''
        self.add_xilinx_precompile_name_lib(name='xbip_utils_v3_0_10')
        self.add_xilinx_precompile_name_lib(name='axi_utils_v2_0_6')
        self.add_xilinx_precompile_name_lib(name='fir_compiler_v7_2_12')






    def compile_xilinx_dependencies_lib(self, vunit_object_p, debug_p='false', linux_p = 1):
        '''
        This function adds the Xilinx precompiled library names to the vunit_object_p
        as external library
        :param vunit_object_p: Vunit object
        :param debug_p: (string) -> print debug_p message if the value is 'true'
        :param linux_p: (integer) -> linux_p=None: automatically choose the separator (OS dependent) for the path, linux_p = 1: use the linux_p separator '/', linux_p=0: use the windows separator '\'
        :return:
        '''
        script_name = self.script_name
        xilinx_external_library_name_list = self.xilinx_external_library_name_list
        xilinx_compile_lib_path = self.xilinx_compile_lib_path

        VU = vunit_object_p

        for ip_compile_dir in xilinx_external_library_name_list:
            library_name = ip_compile_dir
            library_path = clean_path(xilinx_compile_lib_path + ip_compile_dir, linux_p= linux_p)
            rfem_utils.display_filepath(filepath=library_path, script_name=script_name, debug_p=debug_p)
            VU.add_external_library(library_name=library_name, path=library_path)

        return VU

    def compile_xilinx_axi_interconnect_ddr_source(self, vunit_object_p, library_name, basepath, debug_p='false',linux_p = 1):
        '''
        This function retrieves the source files necessary to compile for the Xilinx "axi_interconnect_ddr" IP.
        And each file are added to the vunit_object_p
        :param vunit_object_p: Vunit object
        :param library_name: (string) -> library name where the source file will be compiled
        :param basepath: (string) -> path to the IP parent directory
        :param debug_p:  (string) -> print debug_p message if the value is 'true'
        :param linux_p: (integer) -> linux_p=None: automatically choose the separator (OS dependent) for the path, linux_p = 1: use the linux_p separator '/', linux_p=0: use the windows separator '\'
        :return:
        '''
        xilinx_path_root = os.environ['RFEM_ROOT_PATH_VIVADO_INSTALL']
        include_filepath = clean_path(xilinx_path_root + sep + "data/xilinx_vip/include",linux_p=linux_p)
        VU = vunit_object_p
        script_name = self.script_name
        dir_ip_path = clean_path(basepath + sep + 'axi_interconnect_DDR' + sep + 'sim')
        filepath_list = count_line_in_files(base_filepath=dir_ip_path, msg='', file_ext='v')
        for filepath in filepath_list:
            filepath = clean_path(filepath,linux_p=linux_p)
            rfem_utils.display_filepath(filepath=filepath, script_name=script_name, debug_p=debug_p)
            VU.add_source_file(filepath, library_name=library_name, file_type='verilog',
                               include_dirs=[include_filepath])

    def compile_xilinx_migddr4_source(self, vunit_object_p, library_name, basepath, debug_p='false',linux_p=1):
        '''
        This function retrieves the source files necessary to compile for the Xilinx "MigDDR4" IP.
        And each file are added to the vunit_object_p
        :param vunit_object_p: Vunit object
        :param library_name: (string) -> library name where the source file will be compiled
        :param basepath: (string) -> path to the IP parent directory
        :param debug_p:  (string) -> print debug_p message if the value is 'true'
        :param linux_p: (integer) -> linux_p=None: automatically choose the separator (OS dependent) for the path, linux_p = 1: use the linux_p separator '/', linux_p=0: use the windows separator '\'
        :return:
        '''
        ddr_basepath = os.environ['RFEM_DDR_MODEL_PATH'] 
        ddr_model_path = clean_path(ddr_basepath + 'micron_ddr4_verilog_model',linux_p=linux_p)
        # ddr_model_path = clean_path(ddr_basepath + 'xilinx_ddr_example_design')

        xilinx_path_root = os.environ['RFEM_ROOT_PATH_VIVADO_INSTALL']
        include_filepath = clean_path(xilinx_path_root + sep + "data/xilinx_vip/include",linux_p=linux_p)

        VU = vunit_object_p
        script_name = self.script_name
        ip_path_root = basepath
        filepath_list = []
        filepath_list.append(rfem_utils.clean_path( ip_path_root + sep + 'MigDdr4' + sep + "bd_0" + sep + 'ip' + sep + 'ip_0' + sep + 'sim' + sep + 'bd_ae5f_microblaze_I_0.vhd'))
        filepath_list.append(rfem_utils.clean_path( ip_path_root + sep + 'MigDdr4' + sep + "bd_0" + sep + 'ip' + sep + 'ip_1' + sep + 'sim' + sep + 'bd_ae5f_rst_0_0.vhd'))
        filepath_list.append(rfem_utils.clean_path( ip_path_root + sep + 'MigDdr4' + sep + "bd_0" + sep + 'ip' + sep + 'ip_2' + sep + 'sim' + sep + 'bd_ae5f_ilmb_0.vhd'))
        filepath_list.append(rfem_utils.clean_path( ip_path_root + sep + 'MigDdr4' + sep + "bd_0" + sep + 'ip' + sep + 'ip_3' + sep + 'sim' + sep + 'bd_ae5f_dlmb_0.vhd'))
        filepath_list.append(rfem_utils.clean_path( ip_path_root + sep + 'MigDdr4' + sep + "bd_0" + sep + 'ip' + sep + 'ip_4' + sep + 'sim' + sep + 'bd_ae5f_dlmb_cntlr_0.vhd'))
        filepath_list.append(rfem_utils.clean_path( ip_path_root + sep + 'MigDdr4' + sep + "bd_0" + sep + 'ip' + sep + 'ip_5' + sep + 'sim' + sep + 'bd_ae5f_ilmb_cntlr_0.vhd'))
        filepath_list.append(rfem_utils.clean_path( ip_path_root + sep + 'MigDdr4' + sep + "bd_0" + sep + 'ip' + sep + 'ip_7' + sep + 'sim' + sep + 'bd_ae5f_second_dlmb_cntlr_0.vhd'))
        filepath_list.append(rfem_utils.clean_path( ip_path_root + sep + 'MigDdr4' + sep + "bd_0" + sep + 'ip' + sep + 'ip_8' + sep + 'sim' + sep + 'bd_ae5f_second_ilmb_cntlr_0.vhd'))
        filepath_list.append(rfem_utils.clean_path( ip_path_root + sep + 'MigDdr4' + sep + "bd_0" + sep + 'ip' + sep + 'ip_10' + sep + 'sim' + sep + 'bd_ae5f_iomodule_0_0.vhd'))
        filepath_list.append(rfem_utils.clean_path( ip_path_root + sep + 'MigDdr4' + sep + "bd_0" + sep + 'sim' + sep + 'bd_ae5f.vhd'))
        filepath_list.append(rfem_utils.clean_path( ip_path_root + sep + 'MigDdr4' + sep + "ip_0" + sep + 'sim' + sep + 'MigDdr4_microblaze_mcs.vhd'))

        for filepath in filepath_list:
            rfem_utils.clean_path(filepath,linux_p=linux_p)
            rfem_utils.display_filepath(filepath=filepath, script_name=script_name, debug_p=debug_p)
            VU.add_source_file(filepath, library_name=library_name, file_type=None)

        include_dirs = []
        include_dirs.append(clean_path(ddr_model_path,linux_p=linux_p))
        include_dirs.append(rfem_utils.clean_path(ip_path_root + sep + 'MigDdr4' + sep + "rtl" + sep + 'ip_top',linux_p=linux_p))
        include_dirs.append(rfem_utils.clean_path(ip_path_root + sep + 'MigDdr4' + sep + "rtl" + sep + 'cal',linux_p=linux_p))
        include_dirs.append(rfem_utils.clean_path(ip_path_root + sep + 'MigDdr4' + sep + 'ip_1' + sep + 'rtl' + sep + 'map',linux_p=linux_p))
        include_dirs.append(include_filepath)

        filepath_list = []
        filepath_list.append(rfem_utils.clean_path(
            ip_path_root + sep + 'MigDdr4' + sep + "bd_0" + sep + 'ip' + sep + 'ip_6' + sep + 'sim' + sep + 'bd_ae5f_lmb_bram_I_0.v'))
        filepath_list.append(rfem_utils.clean_path(
            ip_path_root + sep + 'MigDdr4' + sep + "bd_0" + sep + 'ip' + sep + 'ip_9' + sep + 'sim' + sep + 'bd_ae5f_second_lmb_bram_I_0.v'))
        for filepath in filepath_list:
            rfem_utils.clean_path(filepath,linux_p=linux_p)
            rfem_utils.display_filepath(filepath=filepath, script_name=script_name, debug_p=debug_p)
            VU.add_source_file(filepath, library_name=library_name, file_type=None, include_dirs=include_dirs)

        dir_ip_path = rfem_utils.clean_path(ip_path_root + sep + 'MigDdr4' + sep + "ip_1" + sep + 'rtl')
        filepath_list = rfem_utils.count_line_in_files(base_filepath=dir_ip_path, msg='top_ddr', file_ext='sv')
        for filepath in filepath_list:
            rfem_utils.clean_path(filepath,linux_p=linux_p)
            rfem_utils.display_filepath(filepath=filepath, script_name=script_name, debug_p=debug_p)
            VU.add_source_file(filepath, library_name=library_name, file_type=None, include_dirs=include_dirs)

        dir_ip_path = rfem_utils.clean_path(ip_path_root + sep + 'MigDdr4' + sep + "rtl")
        filepath_list = rfem_utils.count_line_in_files(base_filepath=dir_ip_path, msg='top_ddr', file_ext='sv')
        for filepath in filepath_list:
            rfem_utils.clean_path(filepath,linux_p=linux_p)
            rfem_utils.display_filepath(filepath=filepath, script_name=script_name, debug_p=debug_p)
            VU.add_source_file(filepath, library_name=library_name, file_type=None, include_dirs=include_dirs)

        dir_ip_path = rfem_utils.clean_path(ip_path_root + sep + 'MigDdr4' + sep + "tb")
        filepath_list = rfem_utils.count_line_in_files(base_filepath=dir_ip_path, msg='top_ddr', file_ext='sv')
        for filepath in filepath_list:
            rfem_utils.clean_path(filepath,linux_p=linux_p)
            rfem_utils.display_filepath(filepath=filepath, script_name=script_name, debug_p=debug_p)
            VU.add_source_file(filepath, library_name=library_name, file_type=None, include_dirs=include_dirs)


        
        for filepath in filepath_list:
            rfem_utils.clean_path(filepath,linux_p=linux_p)
            rfem_utils.display_filepath(filepath=filepath, script_name=script_name, debug_p=debug_p)
            VU.add_source_file(filepath, library_name=library_name, file_type="systemverilog", include_dirs=include_dirs)



    def compile_xilinx_migddr4_model_source(self, vunit_object_p, library_name, debug_p='false',linux_p=1):
        '''
        This function retrieves the source files necessary to compile the DDR4 RAM model (MICRON).
        And each file are added to the vunit_object_p
        :param vunit_object_p: Vunit object
        :param library_name: (string) -> library name where the source file will be compiled
        :param basepath: (string) -> path to the IP parent directory
        :param debug_p:  (string) -> print debug_p message if the value is 'true'
        :param linux_p: (integer) -> linux_p=None: automatically choose the separator (OS dependent) for the path, linux_p = 1: use the linux_p separator '/', linux_p=0: use the windows separator '\'
        :return:
        '''
        ddr_basepath   = os.environ['RFEM_DDR_MODEL_PATH'] 
        ddr_model_path = clean_path(ddr_basepath + 'micron_ddr4_verilog_model')
        ip_path_root   = os.environ['IP_PATH'] 

        VU = vunit_object_p
        script_name = self.script_name

        ########################
        # Add library files
        #######################
        include_dirs = []
        include_dirs.append(clean_path(ddr_model_path,linux_p=linux_p))
        include_dirs.append(clean_path(ip_path_root + 'MigDdr4' + sep + 'rtl' + sep + 'ip_top',linux_p=linux_p))
        include_dirs.append(clean_path(ip_path_root + 'MigDdr4' + sep + 'rtl' + sep + 'cal',linux_p=linux_p))
        include_dirs.append(clean_path(ip_path_root + 'MigDdr4' + sep + 'ip_1' + sep + 'rtl' + sep + 'map',linux_p=linux_p))

        filepath_arch_package = clean_path(ddr_model_path + sep + 'arch_package.sv',linux_p=linux_p)
        filepath_proj_package = clean_path(ddr_model_path + sep + 'proj_package.sv',linux_p=linux_p)
        filepath_interface = clean_path(ddr_model_path + sep + 'interface.sv',linux_p=linux_p)
        filepath_ddr4_model = clean_path(ddr_model_path + sep + 'ddr4_model.svp',linux_p=linux_p)
        filepath_top_memory_model = clean_path(ddr_basepath   +       'TOP_Memory_Model.sv',linux_p = linux_p)

        filepath_list = []
        linux_p = None
        filepath_list.append(filepath_arch_package)
        filepath_list.append(filepath_proj_package)
        filepath_list.append(filepath_interface)
        filepath_list.append(filepath_ddr4_model)
        filepath_list.append(filepath_top_memory_model)

        
        for filepath in filepath_list:
            rfem_utils.clean_path(filepath,linux_p=linux_p)
            rfem_utils.display_filepath(filepath=filepath, script_name=script_name, debug_p=debug_p)
            VU.add_source_file(filepath, library_name=library_name, file_type='systemverilog', include_dirs=include_dirs)


        ######################
        # change file compile order
        ######################
        # retrieve the fileobject associated to the ddr4_model.svp file 
        lib = VU.library(library_name=library_name)
        ddr4_file_obj = lib.get_source_file(filepath_ddr4_model)

        # list of files to compile before the "filepath_ddr4_model"
        filename_list = []
        filename_list.append(filepath_arch_package) # must be compiled before "filepath_ddr4_model"
        filename_list.append(filepath_proj_package) # must be compiled before "filepath_ddr4_model"
        filename_list.append(filepath_interface)    # must be compiled before "filepath_ddr4_model"
        for filename in filename_list:
            file_obj= lib.get_source_file(filename)
            ddr4_file_obj.add_dependency_on(file_obj)


    def compile_xilinx_fir_source(self, vunit_object_p, library_name, filename_list, basepath, debug_p='false',linux_p=1):
        '''
        This function retrieves the source files necessary to compile for the Xilinx "FIR" IPs.
        And each file are added to the vunit_object_p
        :param vunit_object_p: Vunit object
        :param library_name: (string) -> library name where the source file will be compiled
        :param filename_list: (list of strings) -> defines a list of IP names
        :param basepath: (string) -> path to the IP parent directory
        :param debug_p:  (string) -> print debug_p message if the value is 'true'
        :param linux_p: (integer) -> linux_p=None: automatically choose the separator (OS dependent) for the path, linux_p = 1: use the linux_p separator '/', linux_p=0: use the windows separator '\'
        :return:
        '''
        ip_path = basepath
        VU = vunit_object_p
        script_name = self.script_name
        for index, filename in enumerate(filename_list):
            filepath = rfem_utils.clean_path(ip_path + sep + filename + sep + 'sim' + sep + filename + ".vhd",linux_p=linux_p)
            rfem_utils.display_filepath(filepath=filepath, script_name=script_name, debug_p=debug_p)
            VU.add_source_file(filepath, library_name=library_name, file_type='vhdl')

            # save the paths to the *.mif files
            self.filepath_list_mif.append(
                rfem_utils.clean_path(ip_path + os.sep + filename + os.sep + filename + ".mif",linux_p=linux_p))

    def compile_xilinx_fft_source(self, vunit_object_p, library_name, filename_list, basepath, debug_p='false',linux_p=1):
        '''
        This function retrieves the source files necessary to compile for the Xilinx "FFT" IPs.
        Then, each file is added to the vunit_object_p
        :param vunit_object_p: Vunit object
        :param library_name: (string) -> library name where the source file will be compiled
        :param filename_list: (list of strings) -> defines a list of IP names
        :param basepath: (string) -> path to the IP parent directory
        :param debug_p: (string) -> print debug_p message if the value is 'true'
        :param linux_p: (integer) -> linux_p=None: automatically choose the separator (OS dependent) for the path, linux_p = 1: use the linux_p separator '/', linux_p=0: use the windows separator '\'
        :return:
        '''
        ip_path = basepath
        VU = vunit_object_p
        script_name = self.script_name
        for index, filename in enumerate(filename_list):
            filepath = rfem_utils.clean_path(ip_path + sep + filename + sep + 'sim' + sep + filename + ".vhd",linux_p=linux_p)
            rfem_utils.display_filepath(filepath=filepath, script_name=script_name, debug_p=debug_p)
            VU.add_source_file(filepath, library_name=library_name, file_type='vhdl')

    def compile_xilinx_source(self, vunit_object_p, library_name, filename_list, basepath, debug_p='false',linux_p=1):
        '''
        This function retrieves the source files necessary to compile for the Xilinx IPs.
        Then, each file is added to the vunit_object_p
        :param vunit_object_p: Vunit object
        :param library_name: (string) -> library name where the source file will be compiled
        :param filename_list: (list of strings) -> defines a list of IP names
        :param basepath: (string) -> path to the IP parent directory
        :param debug_p: (string) -> print debug_p message if the value is 'true'
        :param linux_p: (integer) -> linux_p=None: automatically choose the separator (OS dependent) for the path, linux_p = 1: use the linux_p separator '/', linux_p=0: use the windows separator '\'
        :return:
        '''
        ip_path = basepath
        VU = vunit_object_p
        script_name = self.script_name
        for index, filename in enumerate(filename_list):
            filepath = rfem_utils.clean_path(ip_path + sep + filename + sep + 'sim' + sep + filename + ".vhd",linux_p=linux_p)
            rfem_utils.display_filepath(filepath=filepath, script_name=script_name, debug_p=debug_p)
            VU.add_source_file(filepath, library_name=library_name, file_type='vhdl')

    def debug_display(self, script_name, library_name, filepath, index, debug_p):
        '''
        This function prints a debug_p message
        :param script_name: (string) -> script name
        :param library_name: (string) -> library name
        :param filepath: (string) -> filepath
        :param index: (int) -> index
        :param debug_p: (string) -> print debug_p message if the value is 'true'
        :return:
        '''
        if debug_p == 'true':
            if index == 0:
                print('\n')
                print(script_name + 'compilation of the "' + library_name + '" library')
            print(script_name + filepath)

    def get_uvvm_library_filepaths_and_name(self, basepath, filename_compile_order="compile_order.txt", linux_p = 1):
        '''
        This function retrieves a list of relative filepath from a file.
        Then, it concatenate with the basepath with each relative filepath in order to build the absolute filepath.
        Note: This function is specific to the uvvm library
        Assumpution: the file must have the following pattern
          . line0 : # library library_name
          . linex : relative path (ex '../src/types_pkg.vhd')
        :param basepath:
        :param filename_compile_order:
        :return:
        '''
        # read all lines of the file
        sep = os.sep
        basepath = clean_path(basepath + 'script', linux_p=linux_p)

        # retrieve the relative filepaths from the file
        filepath = clean_path(basepath + sep + filename_compile_order, linux_p=linux_p)
        fid = open(filepath, 'r')
        lines = fid.readlines()
        fid.close()

        # cleanup
        # strip the '\n'
        lines = [line.rstrip('\n') for line in lines]

        # get the library name
        line_library = lines[0]
        m = re.match(r'#\s*\w+\s*(?P<library_name>\w*)', line_library)
        library_name = m.group('library_name')

        # get all relative filepath from the file
        relative_filepath_list = []
        for line in lines[1:]:
            # don't take empty line
            line = line.replace(' ', '')
            if line == '':
                continue
            else:
                line = clean_path(line, linux_p=linux_p)
                relative_filepath_list.append(line)

        absolute_filepath_list = []
        for relative_filepath in relative_filepath_list:
            # compute the absolute_filepath = absolute basepath + relative filepath
            filepath = os.path.join(basepath, relative_filepath)
            filepath = os.path.normpath(filepath)
            absolute_filepath_list.append(filepath)

        return library_name, absolute_filepath_list

    def rfem_compile_library(self, vunit_object_p, script_name,
                             en_vhdl_simu_lib=1,       library_name_vhdl_simu = 'vhdl_simu_lib',
                             en_glbl_lib=1,            library_name_glbl = 'glbl_lib',
                             en_ieee_proposed_lib=1,   library_name_ieee_proposed = 'ieee_proposed',
                             en_csv_file_reader_lib=1, library_name_csv_file_reader = 'csv_file_reader_lib',
                             en_uvvm_util=1,
                             en_uvvm_vvc_framework=1,
                             en_bitvis_vip_clock_generator=1,
                             en_bitvis_vip_scoreboard=1,
                             en_bitvis_vip_axilite=1,
                             en_bitvis_vip_axistream=1,
                             en_bitvis_vip_error_injection=1,
                             en_bitvis_vip_axi=1,
                             en_bitvis_vip_spec_cov=1,
                             debug_p='false',
                             linux_p = 1
                             ):
        '''
        This function adds library source files to the Vunit object
        Note: The library source files to add depends of the VHDL testbench (see the import section)
        :param vunit_object_p: (Vunit object)
        :param script_name: (string) -> script name

        :param en_vhdl_simu_lib: (int) -> 1: the associated library will be compiled, 0: otherwise
        :param library_name_vhdl_simu: (string) -> "vhdl_simu_lib": compiled default library name

        :param en_glbl_lib: (int) -> 1: the associated library will be compiled, 0: otherwise
        :param library_name_glbl: (string) -> "glbl_lib": compiled default library name

        :param en_ieee_proposed_lib: (int) -> 1: the associated library will be compiled, 0: otherwise

        :param en_csv_file_reader_lib: (int) -> 1: the associated library will be compiled, 0: otherwise
        :param library_name_csv_file_reader: (string) -> "csv_file_reader_lib": compiled default library name

        :param en_uvvm_util: (int) -> 1: the associated library will be compiled, 0: otherwise
        :param en_uvvm_vvc_framework: (int) -> 1: the associated library will be compiled, 0: otherwise
        :param en_bitvis_vip_clock_generator: (int) -> 1: the associated library will be compiled, 0: otherwise
        :param en_bitvis_vip_scoreboard: (int) -> 1: the associated library will be compiled, 0: otherwise
        :param en_bitvis_vip_axilite: (int) -> 1: the associated library will be compiled, 0: otherwise
        :param en_bitvis_vip_axistream: (int) -> 1: the associated library will be compiled, 0: otherwise
        :param en_bitvis_vip_error_injection: (int) -> 1: the associated library will be compiled, 0: otherwise
        :param en_bitvis_vip_axi: (int) -> 1: the associated library will be compiled, 0: otherwise
        :param en_bitvis_vip_spec_cov: (int) -> 1: the associated library will be compiled, 0: otherwise
        :param debug_p: (string) -> print debug_p message if the value is 'true'
        :param linux_p: (integer) -> linux_p=None: automatically choose the separator (OS dependent) for the path, linux_p = 1: use the linux_p separator '/', linux_p=0: use the windows separator '\'
        :return:
        '''

        VU = vunit_object_p
        vhdl_simu_lib_path                  = os.environ['RFEM_VHDL_SIMU_LIB_PATH']
        glbl_path                           = os.environ['RFEM_GLBL_PATH']
        ieee_proposed_lib_path              = os.environ['RFEM_IEEE_PROPOSED_LIB_PATH']
        csv_file_reader_lib_path            = os.environ['RFEM_CSV_FILE_READER_LIB_PATH']
        uvvm_util_lib_path                  = os.environ['RFEM_UVVM_UTIL_LIB_PATH']
        uvvm_vvc_framework_lib_path         = os.environ['RFEM_UVVM_VVC_FRAMEWORK_LIB_PATH']
        bitvis_vip_scoreboard_lib_path      = os.environ['RFEM_UVVM_BITVIS_VIP_SCOREBOARD_LIB_PATH']

        ####################################
        # Add vhdl_simu_lib library
        ###################################

        if en_vhdl_simu_lib == 1:
           
            library_name = library_name_vhdl_simu
            lib_tmp1 = VU.add_library(library_name,allow_duplicate = True)
            filename = "pkg_vhdl_simu.vhd"
            filepath = clean_path(vhdl_simu_lib_path + filename)
            filepath_list = [filepath]
            for index, filepath in enumerate(filepath_list):
                filepath = rfem_utils.clean_path(filepath,linux_p=linux_p)
                self.debug_display(script_name=script_name, library_name=library_name, filepath=filepath, index=index,
                                   debug_p=debug_p)
                file_list = VU.add_source_file(filepath, library_name = library_name, file_type='vhdl', vhdl_standard='2008')

        #######################################
        # Add glbl library
        #####################################
        if en_glbl_lib == 1:
            library_name = library_name_glbl
            lib_tmp1 = VU.add_library(library_name,allow_duplicate = True)
            filename = "glbl.v"

            filepath = clean_path(glbl_path + filename)
            filepath_list = [filepath]
            for index, filepath in enumerate(filepath_list):
                filepath = rfem_utils.clean_path(filepath,linux_p=linux_p)
                self.debug_display(script_name=script_name, library_name=library_name, filepath=filepath, index=index,
                                   debug_p=debug_p)
                file_list = VU.add_source_file(filepath, library_name=library_name, file_type='verilog')

        ####################################
        # Add ieee_proposed library
        ###################################
        if en_ieee_proposed_lib == 1:
            library_name = library_name_ieee_proposed
            lib_tmp1 = VU.add_library(library_name,allow_duplicate = True)
            filepath_list = count_line_in_files(base_filepath=ieee_proposed_lib_path, msg=library_name, file_ext='vhd')
            for index, filepath in enumerate(filepath_list):
                filepath = rfem_utils.clean_path(filepath,linux_p=linux_p)
                self.debug_display(script_name=script_name, library_name=library_name, filepath=filepath, index=index,
                                   debug_p=debug_p)
                file_list = VU.add_source_file(filepath, library_name = library_name, file_type='vhdl', vhdl_standard='93')

        ####################################
        # Add csv_file_reader_lib_path library
        ###################################
        if (en_csv_file_reader_lib == 1) or (en_vhdl_simu_lib == 1):
            library_name = library_name_csv_file_reader
            lib_tmp1 = VU.add_library(library_name,allow_duplicate = True)
            filepath_list = count_line_in_files(base_filepath=csv_file_reader_lib_path, msg=library_name,
                                                file_ext='vhd')
            for index, filepath in enumerate(filepath_list):
                filepath = rfem_utils.clean_path(filepath,linux_p=linux_p)
                self.debug_display(script_name=script_name, library_name=library_name, filepath=filepath, index=index,
                                   debug_p=debug_p)
                file_list = VU.add_source_file(filepath, library_name = library_name, file_type='vhdl', vhdl_standard='2008')

        ####################################
        # Add uvvm_util library
        ###################################
        if (en_uvvm_util == 1) or (en_vhdl_simu_lib == 1):
            library_name, filepath_list = self.get_uvvm_library_filepaths_and_name(basepath=uvvm_util_lib_path)
            lib_tmp1 = VU.add_library(library_name)
            for index, filepath in enumerate(filepath_list):
                filepath = rfem_utils.clean_path(filepath,linux_p=linux_p)
                self.debug_display(script_name=script_name, library_name=library_name, filepath=filepath, index=index,
                                   debug_p=debug_p)
                file_list = VU.add_source_file(filepath,library_name = library_name, file_type='vhdl', vhdl_standard='2008')

        ####################################
        # Add uvvm_vvc_framework library
        ###################################
        if (en_uvvm_vvc_framework == 1) or (en_vhdl_simu_lib == 1):
            library_name, filepath_list = self.get_uvvm_library_filepaths_and_name(basepath=uvvm_vvc_framework_lib_path)
            lib_tmp1 = VU.add_library(library_name)
            for index, filepath in enumerate(filepath_list):
                filepath = rfem_utils.clean_path(filepath,linux_p=linux_p)
                self.debug_display(script_name=script_name, library_name=library_name, filepath=filepath, index=index,
                                   debug_p=debug_p)
                file_list = VU.add_source_file(filepath, library_name = library_name,file_type='vhdl', vhdl_standard='2008')

        ####################################
        # Add bitvis_vip_scoreboard library
        ###################################
        if (en_bitvis_vip_scoreboard == 1) or (en_vhdl_simu_lib == 1):
            library_name, filepath_list = self.get_uvvm_library_filepaths_and_name( basepath=bitvis_vip_scoreboard_lib_path)
            lib_tmp1 = VU.add_library(library_name)
            for index, filepath in enumerate(filepath_list):
                filepath = rfem_utils.clean_path(filepath,linux_p=linux_p)
                self.debug_display(script_name=script_name, library_name=library_name, filepath=filepath, index=index,
                                   debug_p=debug_p)
                file_list = VU.add_source_file(filepath, library_name = library_name, file_type='vhdl', vhdl_standard='2008')



        return VU

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
