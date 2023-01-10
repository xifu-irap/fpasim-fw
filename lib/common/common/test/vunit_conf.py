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
#    @file                   vunit_conf.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    N/A
# -------------------------------------------------------------------------------------------------------------
#    @details
#    This python script defines the VunitConf class.
#    This class defines methods to compile VHDL files (source files, testbench).
#    These methods hide as much as possible the project tree to the user.
#    
#    Note:
#       . This script is aware of the project tree structure
#       . If a new path need to be added, update VunitConf._build_path method with the new path.
#        Then, the user can create a new method by copying an existing method code in order to use the new added path
#       . This script was tested with python 3.10
# -------------------------------------------------------------------------------------------------------------

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
    This class defines methods to compile VHDL files (source files, testbench)
    These methods hide as much as possible the project tree.
    Note:
        Method name starting by '_' are local to the class (ex:def _toto(...)).
        It should not be usually used by the user
    """

    def __init__(self, json_filepath_p, json_key_path_p, script_name_p):
        """
        This method initializes the class instance
        :param json_filepath_p: (string) json filepath
        :param json_key_path_p: (string) json keys to get a specific individual test
        :param script_name_p: (string) script name
        """
        self.filepath_list_mif = None
        # current conf filepath
        self.conf_filepath = None
        # current python script filepath
        self.script_filepath = None
        # path to the Xilinx pre-compiled libraries
        self.compile_lib_basepath = ''
        # root project path (root project git repo directory)
        self.root_path = ''
        # list of paths (project tree structure)
        self.base_path_dic = {}
        # Vunit object (This object will be created in the Vunit run python scripts)
        self.VU = None
        # list of authorized simulator
        self.authorized_simulator_name_list = ['modelsim', 'questa']
        # name of the current simulator
        self.simulator_name = None
        # Vunit testbench object
        self.tb_obj = None
        # set indentation level (integer >=0)
        self.level = 0
        # set the level of verbosity
        self.verbosity = 0
        # set the json_key_path_p
        self.json_key_path = json_key_path_p

        # display object
        self.display_obj = Display()

        # script name
        self.script_name = script_name_p

        # tb_filename
        self.tb_filename = None

        # wave_filename
        self.wave_filename = None

        # conf_filename_list
        self.conf_filename_list = None

        # script_filepath
        self.script_filepath = None

        # testbench_name
        self.tb_name = None

        self.json_filepath = json_filepath_p
        # Opening JSON file
        fid_in = open(json_filepath_p, 'r')

        # returns JSON object as
        # a dictionary
        self.json_data = json.load(fid_in)

        # Closing file
        fid_in.close()

        # extract the individual test field
        self._extract_test_param_from_json()

        # build the list of paths (project tree structure)
        self._build_path()

    def _extract_test_param_from_json(self):
        """
        This method retrieves parameters of the individual test from the json file
        :return: None
        """

        json_key_path = self.json_key_path
        json_data = self.json_data

        # get the test_group_name as well as the test_name
        key_test_name, key_name = json_key_path.split('/')

        test_list = json_data.get(key_test_name)
        dic_tmp = {}
        for dic in test_list:
            name = dic['name']
            if name == key_name:
                dic_tmp = dic
                break
        tb_filename = dic_tmp["vunit"]["tb_filename"]
        wave_filename = dic_tmp["vunit"]["wave_filename"]
        script_filename = dic_tmp["vunit"]["script_filename"]
        conf_filename_list = dic_tmp["conf"]["filename_list"]
        self.tb_name = str(Path(tb_filename).stem)
        self.tb_filename = tb_filename
        self.wave_filename = wave_filename
        self.script_filename = script_filename
        self.conf_filename_list = conf_filename_list
        return None

    def _build_path(self):
        """
        This method builds project directory paths necessary to the simulation
        :return: None
        """
        json_data = self.json_data
        base_path_dic = self.base_path_dic
        # extract the project root path/Vivado install path from the json file
        root_path = str(Path(json_data['root_path']['path']))
        vivado_path = str(Path(json_data['vunit_vivado_path']['path']))

        # derived paths
        base_path_dic['ip_xilinx_coregen_path'] = str(Path(root_path, 'ip/xilinx/coregen'))
        base_path_dic['ip_xilinx_xpm_path'] = str(Path(root_path, 'ip/xilinx/xpm'))
        base_path_dic['ip_opal_kelly_simu_path'] = str(Path(root_path, 'ip/opal_kelly/simu'))
        base_path_dic['lib_opal_kelly_simu_path'] = str(Path(root_path, 'lib/opal_kelly/opal_kelly/vhdl/src'))
        base_path_dic['lib_csv_path'] = str(Path(root_path, 'lib/csv/csv/vhdl/src'))
        base_path_dic['lib_common_path'] = str(Path(root_path, 'lib/common/common/vhdl/src'))

        base_path_dic['src_path'] = str(Path(root_path, 'src/hdl'))
        base_path_dic['src_system_path'] = str(Path(root_path, 'src/hdl'))
        base_path_dic['src_fpasim_path'] = str(Path(root_path, 'src/hdl/fpasim'))
        base_path_dic['src_clocking_path'] = str(Path(root_path, 'src/hdl/clocking'))
        base_path_dic['src_io_path'] = str(Path(root_path, 'src/hdl/io'))
        base_path_dic['src_usb_path'] = str(Path(root_path, 'src/hdl/usb'))
        base_path_dic['src_utils_path'] = str(Path(root_path, 'src/hdl/utils'))
        base_path_dic['src_reset_path'] = str(Path(root_path, 'src/hdl/reset'))
        base_path_dic['src_spi_path'] = str(Path(root_path, 'src/hdl/spi'))

        base_path_dic['tb_path'] = str(Path(root_path, 'simu/tb'))
        base_path_dic['wave_path'] = str(Path(root_path, 'simu/wave'))
        base_path_dic['script_path'] = str(Path(root_path, 'simu/script'))
        base_path_dic['conf_path'] = str(Path(root_path, 'simu/conf'))
        base_path_dic['data_path'] = str(Path(root_path, 'simu/data'))

        base_path_dic['vivado_glbl_path'] = str(Path(vivado_path, 'data/verilog/src'))

        self.base_path_dic = base_path_dic
        
        return None

    def _get_indentation_level(self, level_p):
        """
        This method select the indentation level to use.
        If level_p is None, the class attribute is used. Otherwise, the level_p method argument is used
        :param level_p: (integer >= 0) define the level of indentation of the message to print
        :return: (integer >=0) level of indentation of the message to print
        """
        level = level_p
        if level is None:
            return self.level
        else:
            return level

    def _add_external_library(self, library_name_p, path_p, level_p=None):
        """
        This method set an external library
        :param library_name_p: (string) library name
        :param path_p: (string) path of the library name
        :param level_p: (integer >= 0) define the level of indentation of the message to print
        :return: None
        """
        VU = self.VU
        display_obj = self.display_obj

        level0   = self._get_indentation_level(level_p=level_p)
        level1 = level0 + 1

        library_list = VU.get_libraries(library_name_p, allow_empty=True)
        found = 0
        for library_obj in library_list:
            if library_name_p == library_obj.name:
                found = 1
        if found == 0:
            display_obj.display_subtitle(msg_p=library_name_p + ': Added external library', level_p=level0)
            VU.add_external_library(library_name=library_name_p, path=path_p)
            display_obj.display(msg_p=path_p, level_p=level1)
        return None

    def _add_library(self, library_name_p):
        """
        This method ensures that the library is added once
        :param library_name_p: (string) library name to add if not already defined
        :return: None
        """
        VU = self.VU

        library_list = VU.get_libraries(library_name_p, allow_empty=True)
        found = 0
        # search the library name in already defined libraries
        for library_obj in library_list:
            if library_name_p == library_obj.name:
                found = 1
        # add the library if not already defined
        if found == 0:
            VU.add_library(library_name_p)
        return None

    def set_verbosity(self, verbosity_p):
        """
        Set the level of verbosity
        :param verbosity_p: (integer >=0) level of verbosity
        :return: None
        """
        self.verbosity = verbosity_p
        return None

    def set_vunit_simulator(self, name_p, level_p=None):
        """
        This function set the environment variables necessary to the VUNIT library
        These environment variables are mandatory to correctly work with the modelsim/questa simulator
        Note: This function must be called before creating a VUNIT object (ex: VU = VUnit.from_args(args=args))
        in the run python script
        :param name_p: (string) -> possibles values are: 'modelsim' or 'questa'
        :param level_p: (integer >= 0) define the level of indentation of the message to print
        :return: 0 if no error. Otherwise, -1
        """

        json_data = self.json_data
        display_obj = self.display_obj
        level0 = self._get_indentation_level(level_p=level_p)
        level1 = level0 + 1
        level2 = level0 + 2

        # retrieve paths from the json file
        modelsim_path = json_data['vunit_modelsim_path']["path"]
        questa_path = json_data['vunit_questa_path']["path"]
        modelsim_compile_lib_path = json_data['vunit_modelsim_compile_lib_path']["path"]
        questa_compile_lib_path = json_data['vunit_questa_compile_lib_path']["path"]
        root_path = str(Path(json_data['root_path']['path']))

        display_obj.display_title(msg_p='Simulator Configuration', level_p=level0)
        display_obj.display(msg_p='Selected Simulator: ' + name_p, level_p=level1)
        # build environment variable for the VUNIT library
        if name_p == 'modelsim':
            os.environ['VUNIT_SIMULATOR'] = 'modelsim'
            os.environ['VUNIT_MODELSIM_PATH'] = modelsim_path
            os.environ['VUNIT_MODELSIM_INI'] = str(Path(root_path, 'simu/simulator/modelsim/modelsim.ini'))
            self.compile_lib_basepath = modelsim_compile_lib_path

        elif name_p == 'questa':
            os.environ['VUNIT_SIMULATOR'] = 'modelsim'
            os.environ['VUNIT_MODELSIM_PATH'] = questa_path
            os.environ['VUNIT_MODELSIM_INI'] = str(Path(root_path, 'simu/simulator/questa/modelsim.ini'))
            self.compile_lib_basepath = questa_compile_lib_path
        else:
            msg0 = "ERROR: The simulator is not Modelsim or Questa"
            display_obj.display(msg_p=msg0, level_p=level1, color_p='red')
            return -1

        msg0 = 'Set the environment variables:'
        display_obj.display(msg_p=msg0, level_p=level1)

        msg0 = 'VUNIT_SIMULATOR = ' + os.environ['VUNIT_SIMULATOR']
        display_obj.display(msg_p=msg0, level_p=level2)

        msg0 = 'VUNIT_MODELSIM_PATH = ' + os.environ['VUNIT_MODELSIM_PATH']
        display_obj.display(msg_p=msg0, level_p=level2)

        msg0 = 'VUNIT_MODELSIM_INI = ' + os.environ['VUNIT_MODELSIM_INI']
        display_obj.display(msg_p=msg0, level_p=level2)

        self.simulator_name = name_p
        return 0

    def set_vunit(self, vunit_object_p):
        """
        This method set the Vunit class instance
        Note: this method must be called after the VunitConf.set_vunit_simulator method
        :param vunit_object_p: (VUNIT Instance) VUNIT class instance
        :return: None
        """
        self.VU = vunit_object_p
        return None

    def set_indentation_level(self, level_p):
        """
        This method set the indentation level of the print message
        :param level_p: (integer >= 0) define the level of indentation of the message to print
        :return: None
        """
        self.level = level_p
        return None

    def xilinx_compile_lib_default_lib(self, level_p=None):
        """
        This method defines and set a list of default pre-compiled Xilinx libraries
        :param level_p:  (integer >= 0) define the level of indentation of the message to print
        :return: None
        """

        basepath = self.compile_lib_basepath
        display_obj = self.display_obj
        level0   = self._get_indentation_level(level_p=level_p)
        level1 = level0 + 1
        # define a list of pre-compiled Xilinx libraries to set as external libraries
        library_name_list = []
        library_name_list.append('xilinx_vip')
        library_name_list.append('xpm')
        library_name_list.append('unisims_ver')
        library_name_list.append('unisim')
        library_name_list.append('unimacro')
        library_name_list.append('unimacro_ver')
        library_name_list.append('unifast')
        library_name_list.append('secureip')
        msg0 = 'External compiled Xilinx library: ' + basepath
        display_obj.display_title(msg_p=msg0, level_p=level0)
        for library_name in library_name_list:
            path = str(Path(basepath, library_name))
            self._add_external_library(library_name_p=library_name, path_p=path, level_p=level1)

        return None

    def _add_source_file(self, filepath_list_p, msg_p, library_name_p, version_p, level_p):
        """
        This method adds source files to the Vunit object
        :param filepath_list_p: (list of string) list of filepath to add to the Vunit object
        :param msg_p: (string) first part of a msg to print in the console
        :param library_name_p: (string) library name where to compile the library
        :param version_p: (string) VHDL version if relevant (not applicable for verilog or system verilog file)
        :param level_p: (integer >= 0) define the level of indentation of the message to print
        :return: None
        """
        VU = self.VU
        display_obj = self.display_obj
        msg = msg_p
        library_name = library_name_p
        version = version_p
        filepath_list = filepath_list_p
        level0   = self._get_indentation_level(level_p=level_p)
        level1 = level0 + 1

        display_obj.display_title(msg_p=msg + ' Compilation (library_name:version:path)', level_p=level0)
        for filepath in filepath_list:
            file_tmp = VU.add_source_file(filepath, vhdl_standard=version, library_name=library_name)
            path = str(Path(file_tmp.name).resolve())
            msg0 = library_name + ':' + version + ":" + path
            display_obj.display(msg_p=msg0, level_p=level1)
        return None

    def compile_glbl_lib(self, name_p='vivado_glbl', library_name_p='fpasim', version_p='2008', level_p=None):
        """
        This method compiles the glbl library
        :param name_p: (string) name to print in the console
        :param library_name_p: (string) library name where to compile the library
        :param version_p: (string) VHDL version if relevant (not applicable for verilog or system verilog file)
        :param level_p:  (integer >= 0) define the level of indentation of the message to print
        :return: None
        """

        base_path_dic = self.base_path_dic
        base_path = base_path_dic['vivado_glbl_path']

        library_name = library_name_p
        level0   = self._get_indentation_level(level_p=level_p)

        # list of files to compile
        filepath_list = []
        filepath_list.append(str(Path(base_path, 'glbl.v')))

        # add the library name
        self._add_library(library_name_p=library_name)

        obj = FilepathListBuilder()
        for filepath in filepath_list:
            obj.add_filepath(filepath_p=filepath)
        filepath_list = obj.get_filepath_list()

        # add files to compile in the Vunit object
        self._add_source_file(filepath_list_p=filepath_list, msg_p=name_p, version_p=version_p,
                              library_name_p=library_name, level_p=level0)

        return None

    def compile_xilinx_xpm_ip(self, name_p='ip_xpm', library_name_p='fpasim', version_p='2008', level_p=None):
        """
        This method compiles the user vhdl files associated to the Xilinx XPM
        :param name_p: (string) name to print in the console
        :param library_name_p: (string) library name where to compile the library
        :param version_p: (string) VHDL version if relevant (not applicable for verilog or system verilog file)
        :param level_p:  (integer >= 0) define the level of indentation of the message to print
        :return: None
        """

        base_path_dic = self.base_path_dic
        base_path = base_path_dic['ip_xilinx_xpm_path']

        library_name = library_name_p
        level0   = self._get_indentation_level(level_p=level_p)

        # add the library name
        self._add_library(library_name_p=library_name)

        # search all files from the base_path root
        obj = FilepathListBuilder()
        obj.add_basepath(basepath_p=base_path)
        filepath_list = obj.get_filepath_list()

        # add files to compile in the Vunit object
        self._add_source_file(filepath_list_p=filepath_list, msg_p=name_p, version_p=version_p,
                              library_name_p=library_name, level_p=level0)

        return None

    def compile_xilinx_coregen_ip(self, name_p='ip_coregen', library_name_p='fpasim', version_p='2008', level_p=None):
        """
        This method compiles the simulation files associated to the Xilinx Coregen
        :param name_p: (string) name to print in the console
        :param library_name_p: (string) library name where to compile the library
        :param version_p: (string) VHDL version if relevant (not applicable for verilog or system verilog file)
        :param level_p:  (integer >= 0) define the level of indentation of the message to print
        :return: None
        """

        base_path_dic = self.base_path_dic
        base_path = base_path_dic['ip_xilinx_coregen_path']

        library_name = library_name_p
        level0   = self._get_indentation_level(level_p=level_p)

        # list of files to compile
        filepath_list = []
        filepath_list.append(str(Path(base_path, 'selectio_wiz_adc/selectio_wiz_adc_selectio_wiz.v')))
        filepath_list.append(str(Path(base_path, 'selectio_wiz_adc/selectio_wiz_adc.v')))
        filepath_list.append(str(Path(base_path, 'selectio_wiz_sync/selectio_wiz_sync_selectio_wiz.v')))
        filepath_list.append(str(Path(base_path, 'selectio_wiz_sync/selectio_wiz_sync.v')))
        filepath_list.append(str(Path(base_path, 'selectio_wiz_dac/selectio_wiz_dac_selectio_wiz.v')))
        filepath_list.append(str(Path(base_path, 'selectio_wiz_dac/selectio_wiz_dac.v')))
        filepath_list.append(str(Path(base_path, 'selectio_wiz_dac_frame/selectio_wiz_dac_frame_selectio_wiz.v')))
        filepath_list.append(str(Path(base_path, 'selectio_wiz_dac_frame/selectio_wiz_dac_frame.v')))
        filepath_list.append(str(Path(base_path, 'selectio_wiz_dac_clk/selectio_wiz_dac_clk_selectio_wiz.v')))
        filepath_list.append(str(Path(base_path, 'selectio_wiz_dac_clk/selectio_wiz_dac_clk.v')))
        filepath_list.append(str(Path(base_path, 'fpasim_clk_wiz_0/fpasim_clk_wiz_0_clk_wiz.v')))
        filepath_list.append(str(Path(base_path, 'fpasim_clk_wiz_0/fpasim_clk_wiz_0.v')))
        filepath_list.append(str(Path(base_path, 'fpasim_top_ila_0/sim/fpasim_top_ila_0.vhd')))
        filepath_list.append(str(Path(base_path, 'fpasim_regdecode_top_ila_0/sim/fpasim_regdecode_top_ila_0.vhd')))


        # add the library name
        self._add_library(library_name_p=library_name)
        obj = FilepathListBuilder()
        for filepath in filepath_list:
            obj.add_filepath(filepath_p=filepath)
        filepath_list = obj.get_filepath_list()

        # add files to compile in the Vunit object
        self._add_source_file(filepath_list_p=filepath_list, msg_p=name_p, version_p=version_p,
                              library_name_p=library_name, level_p=level0)

        return None

    def compile_opal_kelly_ip(self, name_p='ip_opal_kelly', library_name_p='fpasim', version_p='2008', level_p=None):
        """
        This method compiles the files provided by the Opal Kelly company
        :param name_p: (string) name to print in the console
        :param library_name_p: (string) library name where to compile the library
        :param version_p: (string) VHDL version if relevant (not applicable for verilog or system verilog file)
        :param level_p:  (integer >= 0) define the level of indentation of the message to print
        :return: None
        """

        base_path_dic = self.base_path_dic
        base_path = base_path_dic['ip_opal_kelly_simu_path']

        library_name = library_name_p
        level0   = self._get_indentation_level(level_p=level_p)

        # add the library name
        self._add_library(library_name_p=library_name)

        obj = FilepathListBuilder()
        obj.add_basepath(basepath_p=base_path)
        filepath_list = obj.get_filepath_list()

        # add files to compile in the Vunit object
        self._add_source_file(filepath_list_p=filepath_list, msg_p=name_p, version_p=version_p,
                              library_name_p=library_name, level_p=level0)
        return None

    def compile_opal_kelly_lib(self, name_p='opal_kelly_lib', library_name_p='opal_kelly_lib', version_p='2008', level_p=None):
        """
        This method compiles the user-defined files associated to the opal kelly IP
        :param name_p: (string) name to print in the console
        :param library_name_p: (string) library name where to compile the library
        :param version_p: (string) VHDL version if relevant (not applicable for verilog or system verilog file)
        :param level_p:  (integer >= 0) define the level of indentation of the message to print
        :return: None
        """

        base_path_dic = self.base_path_dic
        base_path = base_path_dic['lib_opal_kelly_simu_path']

        library_name = library_name_p
        level0   = self._get_indentation_level(level_p=level_p)

        # add the library name
        self._add_library(library_name_p=library_name)

        obj = FilepathListBuilder()
        obj.add_basepath(basepath_p=base_path)
        filepath_list = obj.get_filepath_list()

        # add files to compile in the Vunit object
        self._add_source_file(filepath_list_p=filepath_list, msg_p=name_p, version_p=version_p,
                              library_name_p=library_name, level_p=level0)

        return None

    def compile_csv_lib(self, name_p='csv_lib', library_name_p='csv_lib', version_p='2008', level_p=None):
        """
        This method compiles the user-defined files associated to the vhdl csv lib
        :param name_p: (string) name to print in the console
        :param library_name_p: (string) library name where to compile the library
        :param version_p: (string) VHDL version if relevant (not applicable for verilog or system verilog file)
        :param level_p:  (integer >= 0) define the level of indentation of the message to print
        :return: None
        """

        base_path_dic = self.base_path_dic
        base_path = base_path_dic['lib_csv_path']

        library_name = library_name_p
        level0   = self._get_indentation_level(level_p=level_p)

        # add the library name
        self._add_library(library_name_p=library_name)

        obj = FilepathListBuilder()
        obj.add_basepath(basepath_p=base_path)
        filepath_list = obj.get_filepath_list()

        # add files to compile in the Vunit object
        self._add_source_file(filepath_list_p=filepath_list, msg_p=name_p, version_p=version_p,
                              library_name_p=library_name, level_p=level0)

        return None

    def compile_common_lib(self, name_p='common_lib', library_name_p='common_lib', version_p='2008', level_p=None):
        """
        This method compiles the user-defined files associated to the vhdl utility lib
        :param name_p: (string) name to print in the console
        :param library_name_p: (string) library name where to compile the library
        :param version_p: (string) VHDL version if relevant (not applicable for verilog or system verilog file)
        :param level_p:  (integer >= 0) define the level of indentation of the message to print
        :return: None
        """

        base_path_dic = self.base_path_dic
        base_path = base_path_dic['lib_common_path']

        library_name = library_name_p
        level0   = self._get_indentation_level(level_p=level_p)

        # add the library name
        self._add_library(library_name_p=library_name)

        obj = FilepathListBuilder()
        obj.add_basepath(basepath_p=base_path)
        filepath_list = obj.get_filepath_list()

        # add files to compile in the Vunit object
        self._add_source_file(filepath_list_p=filepath_list, msg_p=name_p, version_p=version_p,
                              library_name_p=library_name, level_p=level0)

        return None

    def compile_src_directory(self, directory_name_p, library_name_p='fpasim', version_p='2008', level_p=None):
        """
        This method compiles source files from a directory and its subdirectories
        :param directory_name_p: (string) name to print in the console
        :param library_name_p: (string) library name where to compile the library
        :param version_p: (string) VHDL version if relevant (not applicable for verilog or system verilog file)
        :param level_p:  (integer >= 0) define the level of indentation of the message to print
        :return: None
        """


        base_path_dic = self.base_path_dic

        library_name = library_name_p
        level0   = self._get_indentation_level(level_p=level_p)
        directory_name = directory_name_p.lower()

        if directory_name in ['system', 'clocking', 'fpasim', 'io', 'utils', 'usb','reset','spi']:
            # based on the _build_path method, build the dictionary keys
            key_name = 'src_' + directory_name + '_path'
            base_path = base_path_dic[key_name]

            # add the library names
            self._add_library(library_name_p=library_name)
            obj = FilepathListBuilder()
            obj.add_basepath(basepath_p=base_path)
            filepath_list = obj.get_filepath_list()

            # add files to compile in the Vunit object
            self._add_source_file(filepath_list_p=filepath_list, msg_p=directory_name + ' Source files ',
                                  version_p=version_p,
                                  library_name_p=library_name, level_p=level0)

        return None

    def compile_src(self, filename_p, library_name_p='fpasim', version_p='2008', level_p=None):
        """
        This method research a file in the file source directory and compile it.
        :param filename_p: (string) filename to search
        :param library_name_p: (string) library name where to compile the library
        :param version_p: (string) VHDL version if relevant (not applicable for verilog or system verilog file)
        :param level_p:  (integer >= 0) define the level of indentation of the message to print
        :return: None
        """

        base_path_dic = self.base_path_dic
        base_path = base_path_dic['src_path']

        library_name = library_name_p
        level0   = self._get_indentation_level(level_p=level_p)
        name = str(Path(filename_p).stem)
        filename = filename_p

        # add the library names
        self._add_library(library_name_p=library_name)

        # search a file in the directory/subdirectories defined by base_path
        obj = FilepathListBuilder()
        filepath = obj.get_filepath_by_filename(basepath_p=base_path, filename_p=filename)

        # add files to compile in the Vunit object
        self._add_source_file(filepath_list_p=[filepath], msg_p=name, version_p=version_p,
                              library_name_p=library_name, level_p=level0)
        return None

    def compile_tb(self, library_name_p='tb_fpasim', version_p='2008', level_p=None):
        """
        This method research a testbench file in the file testbench directory and compile it.
        :param library_name_p: (string) library name where to compile the library
        :param version_p: (string) VHDL version if relevant (not applicable for verilog or system verilog file)
        :param level_p:  (integer >= 0) define the level of indentation of the message to print
        :return: None
        """

        VU = self.VU
        base_path_dic = self.base_path_dic
        filename = self.tb_filename
        tb_name     = self.tb_name
        base_path = base_path_dic['tb_path']

        library_name = library_name_p
        level0   = self._get_indentation_level(level_p=level_p)
        name = str(Path(filename).stem)

        # add the library name
        self._add_library(library_name_p=library_name)
        obj = FilepathListBuilder()
        filepath = obj.get_filepath_by_filename(basepath_p=base_path, filename_p=filename)

        # add files to compile in the Vunit object
        self._add_source_file(filepath_list_p=[filepath], msg_p=name, version_p=version_p,
                              library_name_p=library_name, level_p=level0)

        # get the testbench object
        tb_lib = VU.library(library_name)
        self.tb_obj = tb_lib.entity(tb_name)

        return None

    def set_waveform(self, level_p=None):
        """
        This method set the waveform for Modelsim and Questa simulator
        :param level_p: (integer >= 0) define the level of indentation of the message to print
        :return: None
        """
        VU = self.VU
        display_obj = self.display_obj
        base_path_dic = self.base_path_dic
        simulator_name = self.simulator_name
        level0 = self._get_indentation_level(level_p=level_p)
        level1 = level0 + 1
        filename = self.wave_filename
        base_path = base_path_dic['wave_path']

        extension = str(Path(filename).suffix)
        display_obj.display_title(msg_p='Set the Simulator Waveform', level_p=level0)
        if extension in ['.do']:
            obj = FilepathListBuilder()
            obj.set_file_extension(file_extension_list_p=['.do'])
            filepath = obj.get_filepath_by_filename(basepath_p=base_path, filename_p=filename)
            if filepath is None:
                msg0 = 'No Waveform'
                display_obj.display(msg_p=msg0, level_p=level1)
            else:
                # set Linux separator
                if simulator_name is None:
                    msg0 = "ERROR: VunitConf.set_waveform: The set_vunit_simulator method should be called before"
                    display_obj.display(msg_p=msg0, level_p=level1)
                elif simulator_name in ['modelsim', 'questa']:
                    filepath = filepath.replace('\\', '/')
                    VU.set_sim_option('modelsim.init_file.gui', filepath)
                    msg0 = 'Enable the Waveform (linux separator mandatory): ' + filepath
                    display_obj.display(msg_p=msg0, level_p=level1)
                else:
                    msg0 = "ERROR: VunitConf.set_waveform: isn't defined for simulator other than modelsim, questa"
                    display_obj.display(msg_p=msg0, level_p=level1)

        else:
            msg0 = 'No Waveform'
            display_obj.display(msg_p=msg0, level_p=level1)
        return None

    def get_testbench_name(self):
        """
        This method returns the testbench name
        :return: (string) testbench name
        """
        return self.tb_name

    def get_testbench(self, level_p=None):
        """
        This method retrieves the Vunit Testbench object
        :param level_p: (integer >= 0) define the level of indentation of the message to print
        :return: Vunit Testbench object if the testbench was found. Otherwise None
        """

        display_obj = self.display_obj
        tb_obj = self.tb_obj
        level0 = self._get_indentation_level(level_p=level_p)

        str0 = "VunitConf.get_testbench"
        display_obj.display_title(msg_p=str0,level_p=level0)

        if tb_obj is None:
            msg0 = 'ERROR: call the compile_tb method before'
            display_obj.display(msg_p=msg0, level_p=level0, color_p='red')
            return None
        else:
            return tb_obj

    def get_conf_filepath(self, level_p=None):
        """
        This method returns a list of conf filepath
        :param level_p: (integer >= 0) define the level of indentation of the message to print
        :return: (list of string) list of filepath
        """
        base_path_dic = self.base_path_dic
        base_path = base_path_dic['conf_path']
        display_obj = self.display_obj
        filename_list = self.conf_filename_list
        level0 = self._get_indentation_level(level_p=level_p)
        level1 = level0 + 1
        level2 = level0 + 2

        str0 = "VunitConf.get_conf_filepath"
        display_obj.display_title(msg_p=str0, level_p=level0)
        str0 = 'Search in base_path='+base_path
        display_obj.display(msg_p=str0, level_p=level1)

        obj = FilepathListBuilder()
        obj.set_file_extension(file_extension_list_p=['.json'])
        filepath_list = []
        for filename in filename_list:
            str0 = 'Searched filename='+filename
            display_obj.display(msg_p=str0,level_p=level2)
            filepath = obj.get_filepath_by_filename(basepath_p=base_path, filename_p=filename, level_p=level2)
            filepath_list.append(filepath)
        
        return filepath_list

    def get_ram_filepath(self,filename_list_p, level_p=None):
        """
        This method returns a list of conf ram filepath
        :param filename_list_p: (list of string) define a list of filename to search
        :param level_p: (integer >= 0) define the level of indentation of the message to print
        :return: (list of string) list of filepath
        """
        base_path_dic = self.base_path_dic
        base_path = base_path_dic['src_path']
        display_obj = self.display_obj
        filename_list = filename_list_p
        level0 = self._get_indentation_level(level_p=level_p)
        level1 = level0 + 1
        level2 = level0 + 2

        str0 = "VunitConf.get_ram_filepath"
        display_obj.display_title(msg_p=str0, level_p=level0)
        str0 = 'Search in base_path='+base_path
        display_obj.display(msg_p=str0, level_p=level1)

        obj = FilepathListBuilder()
        obj.set_file_extension(file_extension_list_p=['.mem'])
        filepath_list = []
        for filename in filename_list:
            str0 = 'Searched filename='+filename
            display_obj.display(msg_p=str0,level_p=level2)
            filepath = obj.get_filepath_by_filename(basepath_p=base_path, filename_p=filename, level_p=level2)
            filepath_list.append(filepath)
        
        return filepath_list

    def get_data_filepath(self,filename_p, level_p=None):
        """
        This method returns a list of data filepath
        :param level_p: (integer >= 0) define the level of indentation of the message to print
        :param filename_p: (string) filename to search
        :return: (list of string) list of filepath
        """
        base_path_dic = self.base_path_dic
        base_path = base_path_dic['data_path']
        display_obj = self.display_obj
        filename = filename_p
        level0 = self._get_indentation_level(level_p=level_p)
        level1 = level0 + 1
        level2 = level0 + 2
        # get file extension
        ext = str(Path(filename).suffix)

        str0 = "VunitConf.get_data_filepath"
        display_obj.display_title(msg_p=str0, level_p=level0)
        str0 = 'Search in base_path='+base_path
        display_obj.display(msg_p=str0, level_p=level1)

        obj = FilepathListBuilder()
        obj.set_file_extension(file_extension_list_p=[ext])
        str0 = 'Searched filename='+filename
        display_obj.display(msg_p=str0,level_p=level2)
        filepath = obj.get_filepath_by_filename(basepath_p=base_path, filename_p=filename, level_p=level2)
       
        
        return filepath

    def _get_script_filepath(self, filename_p, level_p=None):
        """
        This method returns the filepath of the filename_p
        :param filename_p: (string) filename
        :param level_p: (integer >= 0) define the level of indentation of the message to print
        :return: (string) filepath
        """

        filename = filename_p
        base_path_dic = self.base_path_dic
        base_path = base_path_dic['script_path']
        display_obj   = self.display_obj
        level0        = self._get_indentation_level(level_p=level_p)
        level1        = level0 + 1
        level2        = level0 + 2

        str0 = "VunitConf._get_script_filepath"
        display_obj.display_title(msg_p=str0, level_p=level0)
        str0 = 'Search in base_path='+base_path
        display_obj.display(msg_p=str0, level_p=level1)

        obj = FilepathListBuilder()
        obj.set_file_extension(file_extension_list_p=['.py'])
        str0 = 'Searched filename='+filename
        display_obj.display(msg_p=str0,level_p=level2)
        filepath = obj.get_filepath_by_filename(basepath_p=base_path, filename_p=filename, level_p=level2)

        return filepath

    def _create_directory(self, path_p, level_p=None):
        """
        This function create the directory tree defined by the "path" argument (if not exist)
        :param path_p: (string) -> path to the directory to create
        :param level_p:   (integer >= 0) define the level of indentation of the message to print
        :return: None
        """
        display_obj = self.display_obj
        level0 = self._get_indentation_level(level_p=level_p)
        level1 = level0 + 1

        if not os.path.exists(path_p):
            os.makedirs(path_p)
            msg0 = "Create Directory: "
            display_obj.display(msg_p=msg0, level_p=level0, color_p='green')
            msg0 = path_p
            display_obj.display(msg_p=msg0, level_p=level1, color_p='green')
        else:
            msg0 = "Warning: Directory already exists: "
            display_obj.display(msg_p=msg0, level_p=level0, color_p='yellow')
            msg0 = path_p
            display_obj.display(msg_p=msg0, level_p=level1, color_p='yellow')

        return None

    def set_mif_files(self, filepath_list_p):
        """
        This method stores a list of *.mif files.
        For Modelsim/Questa simulator, these *.mif files will be copied
        into a specific directory in order to be "seen" by the simulator
        Note: 
           This method is used for Xilinx IP which uses RAM
           This method should be called before the pre_config method (if necessary)
        :param filepath_list_p: (list of strings) -> list of filepaths
        :return: None
        """
        self.filepath_list_mif = filepath_list_p
        return None

    def _copy_mif_files(self, output_path_p, level_p=None):
        """
        copy a list of init files such as *.mif and/or *.mem into the Vunit simulation directory ("./Vunit_out/modelsim")
        Note: the expected destination directory is "./Vunit_out/modelsim"
        :param output_path_p: (string) -> output path provided by the Vunit library
        :param level_p:   (integer >= 0) define the level of indentation of the message to print
        :return: None
        """
        display_obj = self.display_obj
        script_name = self.script_name
        output_path = output_path_p
        level0   = self._get_indentation_level(level_p=level_p)
        level1 = level0 + 1

        # get absolute path
        script_path = Path(output_path).resolve()
        # move into the hierarchy : vunit_out/modelsim
        output_path = str(Path(script_path.parents[1],"modelsim"))

        # copy each files
        msg0 = script_name + ": Copy the IP init files into the Vunit output simulation directory"
        display_obj.display(msg_p=msg0, level_p=level0, color_p='green')
        for filepath in self.filepath_list_mif:
            msg0 =  'Copy: ' + filepath + " to " + output_path
            display_obj.display(msg_p=msg0, level_p=level1, color_p='green')
            copy(filepath, output_path)

        return None

    def set_script(self, conf_filepath_p, level_p=None):
        """
        This method set the current conf_filepath
        Note: This function must be called before the VunitConf.pre_config method
        :param conf_filepath_p: (string) -> filepath to the json file
        :return: None
        """
        
        level0        = self._get_indentation_level(level_p=level_p)
        level1        = level0 + 1
        level2        = level0 + 2
        conf_filepath = conf_filepath_p
        display_obj   = self.display_obj

        str0 = "VunitConf.set_script"
        display_obj.display_title(msg_p=str0, level_p=level0)
        str0 = 'Set conf_filepath='+conf_filepath
        display_obj.display(msg_p=str0, level_p=level1)

        script_filename = self.script_filename
        script_filepath = self._get_script_filepath(filename_p=script_filename, level_p=level0)

        if script_filepath is not None:
            str0 = 'Set script_filepath='+script_filepath
            display_obj.display(msg_p=str0, level_p=level1)


        self.conf_filepath = conf_filepath
        self.script_filepath = script_filepath

        return None

    def pre_config(self, output_path):
        """
        Define a list of actions to do before launching the simulator
        2 actions are provided:
            . execute a python script with a predefined set of command line arguments
            . copy the "mif files" into the Vunit simulation director for the compatible Xilinx IP
        Note: This method is the main entry point for the Vunit library
        :param output_path: (string) Vunit Output Simulation Path (auto-computed by Vunit)
        :return: boolean
        """
        display_obj   = self.display_obj
        conf_filepath = self.conf_filepath
        script_filepath = self.script_filepath
        script_name   = self.script_name
        verbosity     = self.verbosity

        output_path = output_path
        level0      = self.level
        level1      = level0 + 1

        str0 = "VunitConf.pre_config"
        display_obj.display_title(msg_p=str0, level_p=level0)

        ###############################
        #create directories (if not exist) for the VHDL testbench
        # .input directory  for the input data/command files
        # .output directory for the output data files
        tb_input_base_path = str(Path(output_path,'inputs').resolve())
        tb_output_base_path = str(Path(output_path,'outputs').resolve())
        self._create_directory(path_p=tb_input_base_path,level_p = level1)
        self._create_directory(path_p=tb_output_base_path,level_p =level1)

        # launch a python script to generate data and commands
        if script_filepath is not None:
            cmd = []
            # set the python
            cmd.append('python')
            # set the script path to call
            cmd.append(script_filepath)
            # set the --conf_filepath
            cmd.append('--conf_filepath')
            cmd.append(conf_filepath)
            # set the tb_input_base_path
            cmd.append('--tb_input_base_path')
            cmd.append(tb_input_base_path)
            # set the tb_output_base_path
            cmd.append('--tb_output_base_path')
            cmd.append(tb_output_base_path)
            # set the verbosity
            cmd.append('--verbosity')
            cmd.append(str(verbosity))

            result = subprocess.Popen(cmd,shell=True,stdout=subprocess.PIPE)
            result.wait()

            if verbosity >= 1:
                str0 = "VunitConf.pre_config: command: "+ " ".join(cmd)
                display_obj.display_title(msg_p=str0, level_p=level1)


        # copy the mif files into the Vunit simulation directory
        if self.filepath_list_mif is not None:
            self._copy_mif_files(output_path_p=output_path, level_p=level1)

        # return True is mandatory for Vunit
        return True
