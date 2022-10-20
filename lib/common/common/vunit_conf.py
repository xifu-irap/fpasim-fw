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
#    @file                   console_colors.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    N/A
# -------------------------------------------------------------------------------------------------------------
#    @details
#    This script defines the VunitConf class.
#    This class defines methods to compile VHDL files (source files, testbench)
#    These methods hide as much as possible the project tree to the user.
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

    def __init__(self, json_filepath_p, script_name_p):
        """
        This method initializes the class instance
        :param json_filepath_p: (string) json filepath
        :param script_name_p: (string) script name
        """

        self.tb_input_basepath = ''
        self.tb_output_basepath = ''
        self.json_conf_filepath = ''
        self.compile_lib_basepath = ''
        self.root_path = ''
        self.base_path_dic = {}
        self.VU = None
        self.authorized_simulator_name_list = ['modelsim', 'questa']

        self.simulator_name = None
        self.tb_obj = None

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

        self._build_path()

    def set_vunit(self, vunit_object_p):
        """
        This method set the Vunit class instance
        :param vunit_object_p: (VUNIT Instance) VUNIT class instance
        :return: None
        """
        self.VU = vunit_object_p
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

        base_path_dic['src_path'] = str(Path(root_path, 'src/hdl'))
        base_path_dic['src_system_path'] = str(Path(root_path, 'src/hdl'))
        base_path_dic['src_fpasim_path'] = str(Path(root_path, 'src/hdl/fpasim'))
        base_path_dic['src_clocking_path'] = str(Path(root_path, 'src/hdl/clocking'))
        base_path_dic['src_io_path'] = str(Path(root_path, 'src/hdl/io'))
        base_path_dic['src_usb_path'] = str(Path(root_path, 'src/hdl/usb'))
        base_path_dic['src_utils_path'] = str(Path(root_path, 'src/hdl/utils'))

        base_path_dic['tb_path'] = str(Path(root_path, 'simu/tb'))
        base_path_dic['wave_path'] = str(Path(root_path, 'simu/wave'))
        base_path_dic['script_path'] = str(Path(root_path, 'simu/script'))

        base_path_dic['vivado_glbl_path'] = str(Path(vivado_path, 'data/verilog/src'))

        self.base_path_dic = base_path_dic
        
        return None

    def set_vunit_simulator(self, name_p, level_p=0):
        """
        This function set the environment variables necessary to the VUNIT library
        These environment variables are mandatory to correctly work with the modelsim/questa simulator
        Note: This function should be called before creating a VUNIT object (ex: VU = VUnit.from_args(args=args))
        :param name_p: (string) -> possibles values are: 'modelsim' or 'questa'
        :param level_p: (integer >= 0) define the level of indentation of the message to print
        :return: 0 if no error. Otherwise, -1
        """

        json_data = self.json_data
        display_obj = self.display_obj
        level0 = level_p
        level1 = level_p + 1
        level2 = level_p + 2

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

    def set_waveform(self, filename_p, level_p=0):
        """
        This method set the waveform for Modelsim and Questa simulator
        :param filename_p: (string) waveform filename
        :param level_p: (integer >= 0) define the level of indentation of the message to print
        :return: None
        """
        VU = self.VU
        display_obj = self.display_obj
        base_path_dic = self.base_path_dic
        simulator_name = self.simulator_name

        level0 = level_p
        level1 = level_p + 1
        filename = filename_p
        basepath = base_path_dic['wave_path']

        extension = str(Path(filename).suffix)
        display_obj.display_title(msg_p='Set the Simulator Waveform', level_p=level0)
        if extension in ['.do']:
            obj = FilepathListBuilder()
            obj.set_file_extension(file_extension_list_p=['.do'])
            filepath = obj.get_filepath_by_filename(basepath_p=basepath, filename_p=filename)
            if filepath is None:
                msg0 = 'No Waveform'
                display_obj.display(msg_p=msg0, level_p=level1)
            else:
                # set Linux separator
                if simulator_name is None:
                    msg0 = "ERROR: VunitConf.set_waveform: The set_vunit_simulator method should be called before"
                    display_obj.display(msg_p=msg0, level_p=level1)
                elif simulator_name in ['modelsim','questa']:
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

    def _add_external_library(self, library_name_p, path_p, level_p=0):
        """
        This method set an external library
        :param library_name_p: (string) library name
        :param path_p: (string) path of the library name
        :param level_p: (integer >= 0) define the level of indentation of the message to print
        :return: None
        """
        VU = self.VU
        display_obj = self.display_obj

        level0 = level_p
        level1 = level_p + 1

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

    def xilinx_compile_lib_default_lib(self, level_p=0):
        """
        This method defines and set a list of default pre-compiled Xilinx libraries
        :param level_p:  (integer >= 0) define the level of indentation of the message to print
        :return: None
        """

        basepath = self.compile_lib_basepath
        display_obj = self.display_obj
        level0 = level_p
        level1 = level_p + 1
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
        level0 = level_p
        level1 = level_p + 1

        display_obj.display_title(msg_p=msg + ' Compilation (library_name:version:path)', level_p=level0)
        for filepath in filepath_list:
            file_tmp = VU.add_source_file(filepath, vhdl_standard=version, library_name=library_name)
            path = str(Path(file_tmp.name).resolve())
            msg0 = library_name + ':' + version + ":" + path
            display_obj.display(msg_p=msg0, level_p=level1)
        return None

    def compile_glbl_lib(self, name_p='vivado_glbl', library_name_p='fpasim', version_p='2008', level_p=0):
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
                              library_name_p=library_name, level_p=level_p)

        return None

    def compile_xilinx_xpm_ip(self, name_p='ip_xpm', library_name_p='fpasim', version_p='2008', level_p=0):
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

        # add the library name
        self._add_library(library_name_p=library_name)

        # search all files from the base_path root
        obj = FilepathListBuilder()
        obj.add_basepath(basepath_p=base_path)
        filepath_list = obj.get_filepath_list()

        # add files to compile in the Vunit object
        self._add_source_file(filepath_list_p=filepath_list, msg_p=name_p, version_p=version_p,
                              library_name_p=library_name, level_p=level_p)

        return None

    def compile_xilinx_coregen_ip(self, name_p='ip_coregen', library_name_p='fpasim', version_p='2008', level_p=0):
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

        # list of files to compile
        filepath_list = []
        filepath_list.append(str(Path(base_path, 'selectio_wiz_adc/selectio_wiz_adc_selectio_wiz.v')))
        filepath_list.append(str(Path(base_path, 'selectio_wiz_adc/selectio_wiz_adc.v')))
        filepath_list.append(str(Path(base_path, 'selectio_wiz_sync/selectio_wiz_sync_selectio_wiz.v')))
        filepath_list.append(str(Path(base_path, 'selectio_wiz_sync/selectio_wiz_sync.v')))
        filepath_list.append(str(Path(base_path, 'selectio_wiz_dac/selectio_wiz_dac_selectio_wiz.v')))
        filepath_list.append(str(Path(base_path, 'selectio_wiz_dac/selectio_wiz_dac.v')))
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
                              library_name_p=library_name, level_p=level_p)

        return None

    def compile_opal_kelly_ip(self, name_p='ip_opal_kelly', library_name_p='fpasim', version_p='2008', level_p=0, ):
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

        # add the library name
        self._add_library(library_name_p=library_name)

        obj = FilepathListBuilder()
        obj.add_basepath(basepath_p=base_path)
        filepath_list = obj.get_filepath_list()

        # add files to compile in the Vunit object
        self._add_source_file(filepath_list_p=filepath_list, msg_p=name_p, version_p=version_p,
                              library_name_p=library_name, level_p=level_p)
        return None

    def compile_opal_kelly_lib(self, name_p='lib_opal_kelly', library_name_p='opal_kelly_lib', version_p='2008', level_p=0):
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

        # add the library name
        self._add_library(library_name_p=library_name)

        obj = FilepathListBuilder()
        obj.add_basepath(basepath_p=base_path)
        filepath_list = obj.get_filepath_list()

        # add files to compile in the Vunit object
        self._add_source_file(filepath_list_p=filepath_list, msg_p=name_p, version_p=version_p,
                              library_name_p=library_name, level_p=level_p)

        return None

    def compile_src_directory(self, directory_name_p, library_name_p='fpasim', version_p='2008', level_p=0):
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
        directory_name = directory_name_p.lower()

        if directory_name in ['system', 'clocking', 'fpasim', 'io', 'utils', 'usb']:
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
                                  library_name_p=library_name, level_p=level_p)

        return None

    def compile_src(self, filename_p, library_name_p='fpasim', version_p='2008', level_p=0):
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
        name = str(Path(filename_p).stem)
        filename = filename_p

        # add the library names
        self._add_library(library_name_p=library_name)

        # search a file in the directory/subdirectories defined by base_path
        obj = FilepathListBuilder()
        filepath = obj.get_filepath_by_filename(basepath_p=base_path, filename_p=filename)

        # add files to compile in the Vunit object
        self._add_source_file(filepath_list_p=[filepath], msg_p=name, version_p=version_p,
                              library_name_p=library_name, level_p=level_p)
        return None

    def compile_tb(self, filename_p, tb_name_p, library_name_p='tb_fpasim', version_p='2008', level_p=0):
        """
        This method research a testbench file in the file testbench directory and compile it.
        :param filename_p: (string) filename to search
        :param tb_name_p: (string)  testbench entity name
        :param library_name_p: (string) library name where to compile the library
        :param version_p: (string) VHDL version if relevant (not applicable for verilog or system verilog file)
        :param level_p:  (integer >= 0) define the level of indentation of the message to print
        :return: None
        """

        VU = self.VU
        base_path_dic = self.base_path_dic
        base_path = base_path_dic['tb_path']

        library_name = library_name_p
        name = str(Path(filename_p).stem)

        filename = filename_p
        tb_name = tb_name_p

        # add the library name
        self._add_library(library_name_p=library_name)
        obj = FilepathListBuilder()
        filepath = obj.get_filepath_by_filename(basepath_p=base_path, filename_p=filename)

        # add files to compile in the Vunit object
        self._add_source_file(filepath_list_p=[filepath], msg_p=name, version_p=version_p,
                              library_name_p=library_name, level_p=level_p)

        # get the testbench object
        tb_lib = VU.library(library_name)
        self.tb_obj = tb_lib.entity(tb_name)

        return None

    def get_testbench(self, level_p=0):
        """
        This method retrieves the Vunit Testbench object
        :param level_p:   (integer >= 0) define the level of indentation of the message to print
        :return: Vunit Testbench object if the testbench was found. Otherwise None
        """

        display_obj = self.display_obj
        tb_obj = self.tb_obj
        if tb_obj is None:
            msg0 = 'ERROR: call the compile_tb method before'
            display_obj.display(msg_p=msg0, level_p=level_p, color_p='red')
            return None
        else:
            return tb_obj

    def set_script(self, python_script_path_p, tb_input_basepath_p, tb_output_basepath_p, json_conf_filepath_p,
                   debug_p='false'):
        """
        This functions overwrites different kind of filepaths
        Note: This function must be used before the "pre_config" method
        :param python_script_path_p: (string) -> filepath to the python executable file
        :param tb_input_basepath_p: (string) -> basepath to the input testbench files
        :param tb_output_basepath_p: (string) -> basepath to the output testbench files
        :param json_conf_filepath_p: (string) -> filepath to the json files
        :param debug_p: (string) -> print debug_p message if the value is 'true'
        :return:
        """
        ################################
        # create directories (if not exist) for the VHDL testbench
        #  .input directory  for the input data/command files
        #  .output directory for the output data files
        self.create_directory(path_p=tb_input_basepath_p)
        self.create_directory(path_p=tb_output_basepath_p)
        self.debug = debug_p
        self.python_script_path = python_script_path_p
        self.tb_input_basepath = tb_input_basepath_p
        self.tb_output_basepath = tb_output_basepath_p
        self.json_conf_filepath = json_conf_filepath_p

    def create_directory(self, path_p, level_p=0):
        """
        This function create the directory tree defined by the "path" argument (if not exist)
        :param path_p: (string) -> path to the directory to create
        :param level_p:   (integer >= 0) define the level of indentation of the message to print
        :return: None
        """
        display_obj = self.display_obj

        if not os.path.exists(path_p):
            os.makedirs(path_p)
            msg0 = "Directory ", path_p, " Created "
            display_obj.display(msg_p=msg0, level_p=level_p, color_p='green')
        else:
            msg0 = "Warning: Directory ", path_p, " already exists"
            display_obj.display(msg_p=msg0, level_p=level_p, color_p='yellow')

        return None

    def set_mif_files(self, filepath_list):
        """
        This function stores a list of *.mif files
        Note: This function must be used by IP as Xilinx "FIR" IP
        :param filepath_list: (string) -> list of filepaths
        :return: None
        """
        self.filepath_list_mif = filepath_list
        return None

    def copy_mif_files(self, output_path_p, debug_p, level_p=0):
        """
        copy a list of *.mif files into the Vunit simulation directory ("./Vunit_out/modelsim")
        Note: the expected destination directory is "./Vunit_out/modelsim"
        :param output_path_p: (string) -> output path provided by the Vunit library
        :param debug_p: (string) -> print debug_p message if the value is 'true'
        :param level_p:   (integer >= 0) define the level of indentation of the message to print
        :return: None
        """
        display_obj = self.display_obj
        script_name = self.script_name
        output_path = output_path_p

        # get absolute path
        script_path = Path(output_path).resolve()
        # move into the hierarchy : vunit_out/modelsim
        output_path = str(script_path.parents[1]) + sep + "modelsim"
        if debug_p == 'true':
            msg0 = script_name + "copy the *.mif into the Vunit simulation directory"
            display_obj.display(msg_p=msg0, level_p=level_p, color_p='green')

        # copy each files
        for filepath in self.filepath_list_mif:
            if debug_p == 'true':
                msg0 = script_name + "the filepath :" + filepath + " is copied to " + output_path
                display_obj.display(msg_p=msg0, level_p=level_p, color_p='green')
            copy(filepath, output_path)

        return None

    def pre_config(self, output_path_p, level_p=0):
        """
        Define a list of actions to do before launching the simulator
        2 actions are provided:
            . execute a python script with a predefined set of command line arguments
            . copy the "mif files" into the Vunit simulation director for the compatible Xilinx IP (ex: FIR IP)
        :param output_path_p: (string) Vunit Output Simulation Path
        :param level_p:   (integer >= 0) define the level of indentation of the message to print
        :return:
        """
        display_obj = self.display_obj
        python_exe_path = self.python_exe_path
        python_script_path = self.python_script_path
        tb_input_filepath = self.tb_input_basepath
        tb_output_filepath = self.tb_output_basepath
        json_conf_filepath = self.json_conf_filepath
        debug_p = self.debug_p
        script_name = self.script_name

        output_path = output_path_p

        if debug_p == 'true':
            msg0 = script_name + 'output path :' + output_path + ', output_filepath:' + tb_output_filepath + ' ,input_filepath:' + tb_input_filepath
            display_obj.display(msg_p=msg0, level_p=level_p, color_p='green')
            msg0 = script_name + 'python_exe_path: ' + python_exe_path +  ' ,python_script_path: ' + python_script_path
            display_obj.display(msg_p=msg0, level_p=level_p, color_p='green')

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
            self.copy_mif_files(output_path_p=output_path, debug_p=debug_p)

        # return True is mandatory for Vunit
        return True
