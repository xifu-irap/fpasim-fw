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
#
# Important: get_src_do_compile function is not functional
#
# -------------------------------------------------------------------------------------------------------------

# standard library
import os

from shutil import copy
import subprocess
from pathlib import Path
import re
import json

# user library
from .utils import FilepathListBuilder
from .utils import Display
from .vunit_core import VunitUtils


class VunitConf(VunitUtils):
    """
    Define methods to compile VHDL files (source files, testbench)
    These methods hide as much as possible the project tree.
    Note:
        Method name starting by '_' are local to the class (ex:def _toto(...)).
        It should not be usually used by the user
    """

    def __init__(self, json_filepath_p, json_key_path_p):
        """
        Initialize the class instance

        Parameters
        ----------
        json_filepath_p: str
            json filepath
        json_key_path_p: str
            json keys to get a specific individual test
        """
        # display object
        self.display_obj = Display()
        super().__init__(self.display_obj)

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
        # name of the current simulator
        self.simulator_name = None
        # Vunit testbench object
        self.tb_obj = None
        # set the json_key_path_p
        self.json_key_path = json_key_path_p

        # tb_filename
        self.tb_filename = None

        # wave_filename
        self.wave_filename = None

        # wave_filepath
        self.wave_filepath = None

        # test_variant_filename_list
        self.test_variant_filename_list = None
        # path to the configuration file
        self.test_variant_filepath = None
        # JSON object as a dictionary
        self.json_variant = None

        # script_filepath
        self.script_filepath = None

        # testbench_name
        self.tb_name = None

        self.json_filepath = json_filepath_p

        with open(json_filepath_p, 'r') as fid_in:
            # returns JSON object as
            # a dictionary
            self.json_data = json.load(fid_in)

        # extract the individual test field
        self._extract_unit_test_param_from_json()

        # build the list of paths (project tree structure)
        self._build_path()

        # build GenDoFile object
        # self.obj_do = GenDoFile()
        #
        self.do_ext_lib_list = []
        self.do_lib_list = []
        self.do_list = []
        self.do_filepath_list = []

        # compute vhdl test name (used by the testbench)
        self.vhdl_test_name = ''

        # list the test_variant_filepath to simulate.
        #  => the order could be different to the test_variant_filename_list variable
        #  => the number should be less or equal to test_variant_filename_list variable
        self.new_test_variant_filepath_list = []

        # name of the class (use for message)
        self.class_name = "VunitConf"

        ## Code Coverage
        ############################################
        # path to the vcover exe (code coverage)
        self.vcover_path = None
        # enable code coverage
        self.enable_coverage = 0

    def set_test_variant_filepath(self, filepath_p):
        """
        This method set the json test_variant filepath and get its dictionary
        :param filepath_p: (string) filepath
        :return: None
        """

        test_variant_filepath = filepath_p
        display_obj = self.display_obj
        level0 = self.level
        level1 = level0 + 1
        fct_name = self.class_name + '.set_test_variant_filepath'

        if self.verbosity > 0:
            msg0 = fct_name + ": Process Configuration File"
            display_obj.display_title(msg_p=msg0, level_p=level0)

            msg0 = 'test_variant_filepath=' + test_variant_filepath
            display_obj.display(msg_p=msg0, level_p=level1)

        ################################################
        # Extract data from the configuration json file
        ################################################
        # Opening JSON file
        with open(test_variant_filepath, 'r') as fid_in:
            # returns JSON object as
            # a dictionary
            json_variant = json.load(fid_in)

        # save the json dictionary
        self.json_variant = json_variant
        # save the configuration filepath
        self.test_variant_filepath = test_variant_filepath
        #
        self.new_test_variant_filepath_list = [test_variant_filepath]

        # build the vhdl test name
        key_test_name, key_test_id = self.json_key_path.split('/')
        variant_filename = Path(test_variant_filepath).name
        self.vhdl_test_name = "test_name: "+key_test_name+', test_id: '+'{0:04d}'.format(int(key_test_id))+', variant: '+variant_filename

        return None

    def add_test_variant_filepath(self, filepath_p):
        """
        This method set the json test_variant filepath and get its dictionary
        :param filepath_p: (string) filepath
        :return: None
        """

        test_variant_filepath = filepath_p
        display_obj = self.display_obj
        level0 = self.level
        level1 = level0 + 1
        fct_name = self.class_name + '.add_test_variant_filepath'

        if self.verbosity > 0:
            msg0 = fct_name + ": Process Configuration File"
            display_obj.display_title(msg_p=msg0, level_p=level0)

            msg0 = 'test_variant_filepath=' + test_variant_filepath
            display_obj.display(msg_p=msg0, level_p=level1)

        ################################################
        # Extract data from the configuration json file
        ################################################
        # Opening JSON file
        with open(test_variant_filepath, 'r') as fid_in:
            # returns JSON object as
            # a dictionary
            json_variant = json.load(fid_in)

        # save the json dictionary
        self.json_variant = json_variant
        # save the configuration filepath
        self.test_variant_filepath = test_variant_filepath
        #
        self.new_test_variant_filepath_list.append(test_variant_filepath)

        # build the vhdl test name
        key_test_name, key_test_id = self.json_key_path.split('/')
        variant_filename = Path(test_variant_filepath).name
        self.vhdl_test_name = "test_name: "+key_test_name+', test_id: '+'{0:04d}'.format(int(key_test_id))+', variant: '+variant_filename

        return None

    def _extract_unit_test_param_from_json(self):
        """
        Retrieve parameters of the individual test from the json file.

        Returns
        -------
        None

        """
        json_key_path = self.json_key_path
        json_data = self.json_data['test_section_dic']

        # get the test_group_name as well as the test_name
        key_test_name, key_test_id = json_key_path.split('/')

        test_list = json_data.get(key_test_name)
        dic_tmp   = test_list[int(key_test_id)]

        tb_entity_name = dic_tmp["vunit"]["tb_entity_name"]
        tb_filename    = dic_tmp["vunit"]["tb_filename"]
        wave_filename  = dic_tmp["vunit"]["wave_filename"]
        test_variant_filename_list = dic_tmp["test_variant"]["filename_list"]

        self.tb_name = tb_entity_name
        self.tb_filename = tb_filename
        self.wave_filename = wave_filename
        self.test_variant_filename_list = test_variant_filename_list

        return None

    def _build_path(self):
        """
        Build the Git project directory paths necessary to the VHDL simulation.

        Returns
        -------
        None

        """
        json_data = self.json_data
        base_path_dic = self.base_path_dic
        # extract the project root path/Vivado install path from the json file
        root_path = str(Path(json_data['path_section_dic']['root_path']['path']))
        vivado_path = str(Path(json_data['path_section_dic']['vunit_vivado_path']['path']))

        # derived paths
        base_path_dic['ip_xilinx_coregen_path'] = str(Path(root_path, 'ip/xilinx/coregen'))
        base_path_dic['ip_xilinx_xpm_path'] = str(Path(root_path, 'ip/xilinx/xpm'))
        base_path_dic['ip_opal_kelly_simu_path'] = str(Path(root_path, 'ip/opal_kelly/simu'))
        base_path_dic['lib_opal_kelly_simu_path'] = str(Path(root_path, 'simu/lib/opal_kelly/opal_kelly/vhdl/src'))
        base_path_dic['lib_csv_path'] = str(Path(root_path, 'simu/lib/csv/csv/vhdl/src'))
        base_path_dic['lib_common_path'] = str(Path(root_path, 'simu/lib/common/common/vhdl/src'))

        base_path_dic['src_path'] = str(Path(root_path, 'src/hdl'))
        base_path_dic['src_system_path'] = str(Path(root_path, 'src/hdl'))
        base_path_dic['src_fpasim_path'] = str(Path(root_path, 'src/hdl/fpasim'))
        base_path_dic['src_clocking_path'] = str(Path(root_path, 'src/hdl/clocking'))
        base_path_dic['src_io_path'] = str(Path(root_path, 'src/hdl/io'))
        base_path_dic['src_usb_path'] = str(Path(root_path, 'src/hdl/usb'))
        base_path_dic['src_utils_path'] = str(Path(root_path, 'src/hdl/utils'))
        base_path_dic['src_reset_path'] = str(Path(root_path, 'src/hdl/reset'))
        base_path_dic['src_spi_path'] = str(Path(root_path, 'src/hdl/spi'))
        base_path_dic['src_cosim_path'] = str(Path(root_path, 'simu/cosim'))
        base_path_dic['src_led_path'] = str(Path(root_path, 'src/hdl/led'))

        base_path_dic['tb_path'] = str(Path(root_path, 'simu/tb'))
        base_path_dic['wave_path'] = str(Path(root_path, 'simu/wave'))
        base_path_dic['script_path'] = str(Path(root_path, 'simu/script'))
        base_path_dic['conf_path'] = str(Path(root_path, 'simu/conf'))
        base_path_dic['data_path'] = str(Path(root_path, 'simu/data'))
        base_path_dic['results_path'] = str(Path(root_path, 'simu/results'))

        base_path_dic['vivado_glbl_path'] = str(Path(vivado_path, 'data/verilog/src'))

        self.base_path_dic = base_path_dic
        self.root_path = root_path

        return None

    def _add_external_library(self, library_name_p, path_p, level_p=None):
        """
        Set an external library.

        Parameters
        ----------
        library_name_p: str
            library name
        path_p: str
            path of the library name
        level_p: int
            (int >= 0): define the level of indentation of the message to print

        Returns
        -------
        None

        """

        VU = self.VU
        display_obj = self.display_obj

        level0 = self.get_indentation_level(level_p=level_p)
        level1 = level0 + 1

        library_list = VU.get_libraries(library_name_p, allow_empty=True)
        found = 0
        for library_obj in library_list:
            if library_name_p == library_obj.name:
                found = 1
        if found == 0:
            if self.verbosity > 0:
                display_obj.display_subtitle(msg_p=library_name_p + ': Added external library', level_p=level0)
            VU.add_external_library(library_name=library_name_p, path=path_p)
            if self.verbosity > 0:
                display_obj.display(msg_p=path_p, level_p=level1)

            # build the external library
            path = path_p.replace('\\', '/')
            str0 = " ".join(["vmap", library_name_p, path])
            self.do_ext_lib_list.append(str0)
            # obj_do.add_external_library(library_name_p=library_name_p,path_p=path_p)
        return None

    def _add_library(self, library_name_p):
        """
        Ensures that the library is added once.

        Parameters
        ----------
        library_name_p: str
            library name to add if not already defined

        Returns
        -------
        None

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

            # obj_do.add_library(library_name_p=library_name_p)
            # Define the library
            str0 = " ".join(["vlib", library_name_p])
            self.do_lib_list.append(str0)
        return None

    def set_vunit_simulator(self, name_p, level_p=None):
        """
        Set the environment variables necessary to the VUNIT library.
        These environment variables are mandatory to correctly work with the modelsim/questa simulator
        Note: This function must be called before creating a VUNIT object (ex: VU = VUnit.from_args(args=args))
        in the run python script.

        Parameters
        ----------
        name_p: str
            VHDL simulator name. The possibles values are: 'modelsim' or 'questa'
        level_p: int
            (int >=0) level of indentation of the print message

        Returns
        -------
        int
            0 if no error. Otherwise, -1
        """

        json_data = self.json_data
        display_obj = self.display_obj
        level0 = self.get_indentation_level(level_p=level_p)
        level1 = level0 + 1
        level2 = level0 + 2

        # retrieve paths from the json file
        modelsim_path = json_data['path_section_dic']['vunit_modelsim_path']["path"]
        questa_path = json_data['path_section_dic']['vunit_questa_path']["path"]
        modelsim_compile_lib_path = json_data['path_section_dic']['vunit_modelsim_compile_lib_path']["path"]
        questa_compile_lib_path = json_data['path_section_dic']['vunit_questa_compile_lib_path']["path"]
        root_path = str(Path(json_data['path_section_dic']['root_path']['path']))

        if self.verbosity > 0:
            display_obj.display_title(msg_p='Simulator Configuration', level_p=level0)
            display_obj.display(msg_p='Selected Simulator: ' + name_p, level_p=level1)
        # build environment variable for the VUNIT library
        if name_p == 'modelsim':
            os.environ['VUNIT_SIMULATOR'] = 'modelsim'
            os.environ['VUNIT_MODELSIM_PATH'] = modelsim_path
            os.environ['VUNIT_MODELSIM_INI'] = str(Path(root_path, 'simu/simulator/modelsim/modelsim.ini'))
            self.compile_lib_basepath = modelsim_compile_lib_path
            self.vcover_path = modelsim_path

        elif name_p == 'questa':
            os.environ['VUNIT_SIMULATOR'] = 'modelsim'
            os.environ['VUNIT_MODELSIM_PATH'] = questa_path
            os.environ['VUNIT_MODELSIM_INI'] = str(Path(root_path, 'simu/simulator/questa/modelsim.ini'))
            self.compile_lib_basepath = questa_compile_lib_path
            self.vcover_path = questa_path
        else:
            msg0 = "ERROR: The simulator is not Modelsim or Questa"
            display_obj.display(msg_p=msg0, level_p=level1, color_p='red')
            return -1

        if self.verbosity > 0:
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
        Set the Vunit class instance

        Parameters
        ----------
        vunit_object_p: Vunit instance
            instance of the Vunit object

        Returns
        -------
        None

        """

        self.VU = vunit_object_p
        # self.obj_do.set_vunit(vunit_object_p=vunit_object_p)
        return None

    def xilinx_compile_lib_default_lib(self, level_p=None):
        """
        Defines and set a list of default pre-compiled Xilinx libraries.

        Parameters
        ----------
        level_p: int
            (int >= 0) define the level of indentation of the message to print

        Returns
        -------
        None

        """
        basepath = self.compile_lib_basepath
        display_obj = self.display_obj
        level0 = self.get_indentation_level(level_p=level_p)
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
        if self.verbosity > 0:
            msg0 = 'External compiled Xilinx library: ' + basepath
            display_obj.display_title(msg_p=msg0, level_p=level0)
        for library_name in library_name_list:
            path = str(Path(basepath, library_name))
            self._add_external_library(library_name_p=library_name, path_p=path, level_p=level1)

        return None

    def _add_source_file(self, filepath_list_p, msg_p, library_name_p, version_p, level_p, enable_coverage_p):
        """
        Add source files to the Vunit object.

        Parameters
        ----------
        filepath_list_p: list of str
            list of filepath to add to the Vunit object
        msg_p: str
            first part of a msg to print in the console
        library_name_p: str
             library name to use during the library compilation.
        version_p: str
            VHDL version if relevant (not applicable for verilog or system verilog file)
        level_p: int
            (int >= 0) define the level of indentation of the message to print
        enable_coverage_p: boolean
            True: enable the code coverage
            False: disable the code coverage
        Returns
        -------
        None

        """

        VU = self.VU
        display_obj = self.display_obj
        msg = msg_p
        library_name = library_name_p
        version = version_p
        filepath_list = filepath_list_p
        level0 = self.get_indentation_level(level_p=level_p)
        level1 = level0 + 1
        if self.verbosity > 0:
            display_obj.display_title(msg_p=msg + ' Compilation (library_name:version:path)', level_p=level0)
        for filepath in filepath_list:
            file_tmp = VU.add_source_file(filepath, vhdl_standard=version, library_name=library_name)
            path = str(Path(file_tmp.name).resolve())
            suffix = Path(filepath).suffix

            if enable_coverage_p == True:
                if suffix == '.vhd':
                    file_tmp.add_compile_option("modelsim.vcom_flags", ["+cover=bs"])
                elif suffix == '.vhdl':
                    file_tmp.add_compile_option("modelsim.vcom_flags", ["+cover=bs"])
                elif suffix == '.v':
                    file_tmp.add_compile_option("modelsim.vlog_flags", ["+cover=bs"])
                elif suffix == '.sv':
                    file_tmp.add_compile_option("modelsim.vlog_flags", ["+cover=bs"])

            msg0 = library_name + ':' + version + ":" + path
            if self.verbosity > 0:
                display_obj.display(msg_p=msg0, level_p=level1)


            # build the external library
            filepath = filepath.replace('\\', '/')
            if suffix == '.vhd':
                str0 = " ".join(['vcom', '-work', library_name, '-' + version, filepath])
            elif suffix == '.vhdl':
                str0 = " ".join(['vcom', '-work', library_name, '-' + version, filepath])
            elif suffix == '.v':
                str0 = " ".join(['vlog', '-work', library_name, filepath])
            elif suffix == '.sv':
                str0 = " ".join(['vlog', '-work', library_name, filepath])
            self.do_list.append(str0)
            self.do_filepath_list.append(filepath)
            # obj_do.add_source_file(filepath_p=filepath,library_name_p=library_name,version_p=version)

            # Be sure do not desactivate the enable_coverage if already defined somewhere else
            if enable_coverage_p == True:
                self.enable_coverage = enable_coverage_p

        return None

    def _compile_by_filepath(self, filepath_list_p, msg_p, library_name_p, version_p, level_p,enable_coverage_p):
        """
        Compile files by filepath

        Parameters
        ----------
        filepath_list_p: list of str
            list of filepath to compile
        msg_p: str
            message to print in the console
        library_name_p: str
            library name to use during the library compilation.
        version_p: str
            VHDL version if relevant (not applicable for verilog or system verilog file)
        level_p: int
            (int >= 0) define the level of indentation of the message to print
        enable_coverage_p: boolean
            True: enable the code coverage
            False: disable the code coverage
        Returns
        -------
        None
        """

        level0 = self.get_indentation_level(level_p=level_p)
        # add the library name
        self._add_library(library_name_p=library_name_p)

        obj = FilepathListBuilder()
        for filepath in filepath_list_p:
            obj.add_filepath(filepath_p=filepath)
        filepath_list = obj.get_filepath_list()

        # add files to compile in the Vunit object
        self._add_source_file(filepath_list_p=filepath_list, msg_p=msg_p, version_p=version_p,
                              library_name_p=library_name_p, level_p=level0,enable_coverage_p=enable_coverage_p)

    def _compile_by_base_path(self, base_path_p, msg_p, library_name_p, version_p, level_p, enable_coverage_p):
        """
        Search Files with a base_path root address and compile them.

        Parameters
        ----------
        base_path_p: str
            base_path where to find the source files to compile
        msg_p: str
            message to print in the console
        library_name_p: str
            library name to use during the library compilation.
        version_p: str
            VHDL version if relevant (not applicable for verilog or system verilog file)
        level_p: int
            (int >= 0) define the level of indentation of the message to print
        enable_coverage_p: boolean
            True: enable the code coverage
            False: disable the code coverage

        Returns
        -------
        None

        """

        level0 = self.get_indentation_level(level_p=level_p)
        # add the library name
        self._add_library(library_name_p=library_name_p)

        obj = FilepathListBuilder()
        obj.add_basepath(basepath_p=base_path_p)
        filepath_list = obj.get_filepath_list()

        # add files to compile in the Vunit object
        self._add_source_file(filepath_list_p=filepath_list, msg_p=msg_p, version_p=version_p,
                              library_name_p=library_name_p, level_p=level0, enable_coverage_p=enable_coverage_p)

    def _compile_by_filename(self, base_path_p, filename_p, msg_p, library_name_p, version_p, level_p,enable_coverage_p):
        """

        Parameters
        ----------
        base_path_p: str
            base_path of the path to compile
        filename_p: str
            filename to compile
        msg_p: str
            message to print in the console
        library_name_p: str
            library name to use during the library compilation.
        version_p: str
            VHDL version if relevant (not applicable for verilog or system verilog file)
        level_p: int
            (int >= 0) define the level of indentation of the message to print
        enable_coverage_p: boolean
            True: enable the code coverage
            False: disable the code coverage

        Returns
        -------
        None

        """
        level0 = self.get_indentation_level(level_p=level_p)

        # add the library names
        self._add_library(library_name_p=library_name_p)

        # search a file in the directory/subdirectories defined by base_path
        obj = FilepathListBuilder()
        filepath = obj.get_filepath_by_filename(basepath_p=base_path_p, filename_p=filename_p)

        # add files to compile in the Vunit object
        self._add_source_file(filepath_list_p=[filepath], msg_p=msg_p, version_p=version_p,
                              library_name_p=library_name_p, level_p=level0,enable_coverage_p=enable_coverage_p)

    def compile_glbl_lib(self, name_p='vivado_glbl', library_name_p='fpasim', version_p='2008', level_p=None, enable_coverage_p=False):
        """
        Compile the glbl library

        Parameters
        ----------
        name_p: str
            name to print in the console
        library_name_p: str
            library name to use during the library compilation.
        version_p: str
            VHDL version if relevant (not applicable for verilog or system verilog file)
        level_p: int
            (int >= 0) define the level of indentation of the message to print
        enable_coverage_p: boolean
            True: enable the code coverage
            False: disable the code coverage

        Returns
        -------
        None

        """
        base_path_dic = self.base_path_dic
        base_path = base_path_dic['vivado_glbl_path']

        # list of files to compile
        filepath_list = []
        filepath_list.append(str(Path(base_path, 'glbl.v')))

        self._compile_by_filepath(filepath_list_p=filepath_list, msg_p=name_p, library_name_p=library_name_p,
                                  version_p=version_p, level_p=level_p, enable_coverage_p=enable_coverage_p)

        return None

    def compile_xilinx_xpm_ip(self, name_p='ip_xpm', library_name_p='fpasim', version_p='2008', level_p=None,enable_coverage_p=False):
        """
        Compile the user vhdl files associated to the Xilinx XPM.

        Parameters
        ----------
        name_p: str
            name to print in the console
        library_name_p: str
            library name to use during the library compilation.
        version_p: str
            VHDL version if relevant (not applicable for verilog or system verilog file)
        level_p: int
            (int >= 0) define the level of indentation of the message to print
        enable_coverage_p: boolean
            True: enable the code coverage
            False: disable the code coverage

        Returns
        -------
        None

        """
        base_path_dic = self.base_path_dic
        base_path = base_path_dic['ip_xilinx_xpm_path']
        self._compile_by_base_path(base_path_p=base_path, msg_p=name_p, library_name_p=library_name_p,
                                   version_p=version_p, level_p=level_p,enable_coverage_p=enable_coverage_p)

        return None

    def compile_xilinx_coregen_ip(self, name_p='ip_coregen', library_name_p='fpasim', version_p='2008', level_p=None, enable_coverage_p=False):
        """
        Compile the simulation files associated to the Xilinx Coregen.

        Parameters
        ----------
        name_p: str
            name to print in the console
        library_name_p: str
            library name to use during the library compilation.
        version_p: str
            VHDL version if relevant (not applicable for verilog or system verilog file)
        level_p: int
            (int >= 0) define the level of indentation of the message to print
        enable_coverage_p: boolean
            True: enable the code coverage
            False: disable the code coverage

        Returns
        -------
        None

        """

        base_path_dic = self.base_path_dic
        base_path = base_path_dic['ip_xilinx_coregen_path']

        # list of files to compile
        filepath_list = []

        filepath_list.append(str(Path(base_path, 'selectio_wiz_adc/selectio_wiz_adc_sim_netlist.vhdl')))

        filepath_list.append(str(Path(base_path, 'selectio_wiz_sync/selectio_wiz_sync_sim_netlist.vhdl')))

        filepath_list.append(str(Path(base_path, 'selectio_wiz_dac/selectio_wiz_dac_sim_netlist.vhdl')))

        filepath_list.append(str(Path(base_path, 'selectio_wiz_dac_frame/selectio_wiz_dac_frame_sim_netlist.vhdl')))

        filepath_list.append(str(Path(base_path, 'selectio_wiz_dac_clk/selectio_wiz_dac_clk_sim_netlist.vhdl')))

        filepath_list.append(str(Path(base_path, 'fpasim_clk_wiz_0/fpasim_clk_wiz_0_sim_netlist.vhdl')))

        filepath_list.append(str(Path(base_path, 'system_fpasim_top_ila/sim/system_fpasim_top_ila.vhd')))
        filepath_list.append(str(Path(base_path, 'fpasim_top_ila_0/sim/fpasim_top_ila_0.vhd')))
        filepath_list.append(str(Path(base_path, 'fpasim_top_vio_0/sim/fpasim_top_vio_0.vhd')))

        filepath_list.append(str(Path(base_path, 'fpasim_regdecode_top_ila_0/sim/fpasim_regdecode_top_ila_0.vhd')))
        filepath_list.append(str(Path(base_path, 'fpasim_regdecode_top_ila_1/sim/fpasim_regdecode_top_ila_1.vhd')))
        filepath_list.append(str(Path(base_path, 'fpasim_spi_device_select_ila/sim/fpasim_spi_device_select_ila.vhd')))

        filepath_list.append(str(Path(base_path, 'fpasim_spi_device_select_vio/sim/fpasim_spi_device_select_vio.vhd')))

        self._compile_by_filepath(filepath_list_p=filepath_list, msg_p=name_p, library_name_p=library_name_p,
                                  version_p=version_p, level_p=level_p, enable_coverage_p=enable_coverage_p)

        return None

    def compile_opal_kelly_ip(self, name_p='ip_opal_kelly', library_name_p='fpasim', version_p='2008', level_p=None,enable_coverage_p=False):
        """
        Compile the source files provided by the Opal Kelly company.

        Parameters
        ----------
        name_p: str
            name to print in the console
        library_name_p: str
            library name to use during the library compilation.
        version_p: str
            VHDL version if relevant (not applicable for verilog or system verilog file)
        level_p: int
            (int >= 0) define the level of indentation of the message to print
        enable_coverage_p: boolean
            True: enable the code coverage
            False: disable the code coverage

        Returns
        -------
        None

        """

        base_path_dic = self.base_path_dic
        base_path = base_path_dic['ip_opal_kelly_simu_path']

        self._compile_by_base_path(base_path_p=base_path, msg_p=name_p, library_name_p=library_name_p,
                                   version_p=version_p, level_p=level_p,enable_coverage_p=enable_coverage_p)

        return None

    def compile_opal_kelly_lib(self, name_p='opal_kelly_lib', library_name_p='opal_kelly_lib', version_p='2008',level_p=None,enable_coverage_p=False):
        """
        Compile the user-defined files associated to the opal kelly IP.

        Parameters
        ----------
        name_p: str
            name to print in the console
        library_name_p: str
            library name to use during the library compilation.
        version_p: str
            VHDL version if relevant (not applicable for verilog or system verilog file)
        level_p: int
            (int >= 0) define the level of indentation of the message to print
        enable_coverage_p: boolean
            True: enable the code coverage
            False: disable the code coverage

        Returns
        -------
        None

        """
        base_path_dic = self.base_path_dic
        base_path = base_path_dic['lib_opal_kelly_simu_path']

        self._compile_by_base_path(base_path_p=base_path, msg_p=name_p, library_name_p=library_name_p,
                                   version_p=version_p, level_p=level_p,enable_coverage_p=enable_coverage_p)

        return None

    def compile_csv_lib(self, name_p='csv_lib', library_name_p='csv_lib', version_p='2008', level_p=None, enable_coverage_p=False):
        """
        Compile the user-defined files associated to the vhdl csv lib.

        Parameters
        ----------
        name_p: str
            name to print in the console
        library_name_p: str
            library name to use during the library compilation.
        version_p: str
            VHDL version if relevant (not applicable for verilog or system verilog file)
        level_p: int
            (int >= 0) define the level of indentation of the message to print
        enable_coverage_p: boolean
            True: enable the code coverage
            False: disable the code coverage

        Returns
        -------

        """

        base_path_dic = self.base_path_dic
        base_path = base_path_dic['lib_csv_path']

        self._compile_by_base_path(base_path_p=base_path, msg_p=name_p, library_name_p=library_name_p,
                                   version_p=version_p, level_p=level_p, enable_coverage_p=enable_coverage_p)

        return None

    def compile_common_lib(self, name_p='common_lib', library_name_p='common_lib', version_p='2008', level_p=None, enable_coverage_p=False):
        """
        Compile the user-defined files associated to the vhdl utility lib.

        Parameters
        ----------
        name_p: str
            name to print in the console
        library_name_p: str
            library name to use during the library compilation.
        version_p: str
            VHDL version if relevant (not applicable for verilog or system verilog file)
        level_p: int
            (int >= 0) define the level of indentation of the message to print
        enable_coverage_p: boolean
            True: enable the code coverage
            False: disable the code coverage

        Returns
        -------
        None

        """

        base_path_dic = self.base_path_dic
        base_path = base_path_dic['lib_common_path']

        self._compile_by_base_path(base_path_p=base_path, msg_p=name_p, library_name_p=library_name_p,
                                   version_p=version_p, level_p=level_p, enable_coverage_p=enable_coverage_p)

        return None

    def compile_src_directory(self, directory_name_p, library_name_p='fpasim', version_p='2008', level_p=None, enable_coverage_p=False):
        """
        Compile source files from a directory and its subdirectories.

        Parameters
        ----------
        directory_name_p: str
            name to print in the console
        library_name_p: str
            library name to use during the library compilation.
        version_p: str
             VHDL version if relevant (not applicable for verilog or system verilog file)
        level_p: int
            (int >= 0) define the level of indentation of the message to print
        enable_coverage_p: boolean
            True: enable the code coverage
            False: disable the code coverage

        Returns
        -------
        None

        """
        base_path_dic = self.base_path_dic
        directory_name = directory_name_p.lower()

        if directory_name in ['system', 'clocking', 'fpasim', 'io', 'utils', 'usb', 'reset', 'spi', 'cosim','led']:
            # based on the _build_path method, build the dictionary keys
            key_name = 'src_' + directory_name + '_path'
            base_path = base_path_dic[key_name]
            msg = directory_name + ' Source files '

            self._compile_by_base_path(base_path_p=base_path, msg_p=msg, library_name_p=library_name_p,
                                       version_p=version_p, level_p=level_p,enable_coverage_p=enable_coverage_p)

        return None

    def compile_src(self, filename_p, library_name_p='fpasim', version_p='2008', level_p=None,enable_coverage_p=False):
        """
        Search a file in the file source directory and compile it.

        Parameters
        ----------
        filename_p: str
            filename to search
        library_name_p: str
            library name to use during the library compilation.
        version_p: str
             VHDL version if relevant (not applicable for verilog or system verilog file)
        level_p: int
            (int >= 0) define the level of indentation of the message to print

        enable_coverage_p: boolean
            True: enable the code coverage
            False: disable the code coverage

        Returns
        -------
        None

        """
        base_path_dic = self.base_path_dic
        base_path = base_path_dic['src_path']

        msg = str(Path(filename_p).stem)

        self._compile_by_filename(base_path_p=base_path, filename_p=filename_p, msg_p=msg,
                                  library_name_p=library_name_p,
                                  version_p=version_p, level_p=level_p,enable_coverage_p=enable_coverage_p)
        return None

    def compile_tb(self, library_name_p='tb_fpasim', version_p='2008', level_p=None,enable_coverage_p=False):
        """
        Search a testbench file in the file testbench directory and compile it.

        Parameters
        ----------
        library_name_p: str
            library name to use during the library compilation.
        version_p: str
             VHDL version if relevant (not applicable for verilog or system verilog file)
        level_p: int
            (int >= 0) define the level of indentation of the message to print
        enable_coverage_p: boolean
            True: enable the code coverage
            False: disable the code coverage

        Returns
        -------
        None
        """
        VU = self.VU
        base_path_dic = self.base_path_dic
        filename = self.tb_filename
        tb_name = self.tb_name
        base_path = base_path_dic['tb_path']

        msg = str(Path(filename).stem)

        self._compile_by_filename(base_path_p=base_path, filename_p=filename, msg_p=msg, library_name_p=library_name_p,
                                  version_p=version_p, level_p=level_p,enable_coverage_p=enable_coverage_p)

        # get the testbench object
        tb_lib = VU.library(library_name_p)
        self.tb_obj = tb_lib.entity(tb_name)

        return None

    def set_waveform(self, level_p=None):
        """
        Set the waveform for Modelsim and Questa simulator

        Parameters
        ----------
        level_p: int
            (int >= 0) define the level of indentation of the message to print

        Returns
        -------
        None

        """
        VU = self.VU
        display_obj = self.display_obj
        base_path_dic = self.base_path_dic
        simulator_name = self.simulator_name
        level0 = self.get_indentation_level(level_p=level_p)
        level1 = level0 + 1
        filename = self.wave_filename
        base_path = base_path_dic['wave_path']
        fct_name = self.class_name + '.set_waveform'

        extension = str(Path(filename).suffix)
        if self.verbosity > 0:
            display_obj.display_title(msg_p='Set the Simulator Waveform', level_p=level0)
        if extension in ['.do']:
            obj = FilepathListBuilder()
            obj.set_file_extension(file_extension_list_p=['.do'])
            filepath = obj.get_filepath_by_filename(basepath_p=base_path, filename_p=filename)
            if filepath is None:
                if self.verbosity > 0:
                    msg0 = 'No Waveform'
                    display_obj.display(msg_p=msg0, level_p=level1)
            else:
                # set Linux separator
                if simulator_name is None:
                    if self.verbosity > 0:
                        msg0 = fct_name + ": ERROR: The set_vunit_simulator method should be called before"
                        display_obj.display(msg_p=msg0, level_p=level1)
                elif simulator_name in ['modelsim', 'questa']:
                    filepath = filepath.replace('\\', '/')
                    VU.set_sim_option('modelsim.init_file.gui', filepath)
                    if self.verbosity > 0:
                        msg0 = 'Enable the Waveform (linux separator mandatory): ' + filepath
                        display_obj.display(msg_p=msg0, level_p=level1)
                else:
                    msg0 = fct_name + ": ERROR: isn't defined for simulator other than modelsim, questa"
                    display_obj.display(msg_p=msg0, level_p=level1)
            self.wave_filepath = filepath

        else:
            self.wave_filepath = None
            if self.verbosity > 0:
                msg0 = 'No Waveform'
                display_obj.display(msg_p=msg0, level_p=level1)
        return None

    def get_waveform(self, level_p=None):
        """
        Get the waveform for Modelsim and Questa simulator.

        Parameters
        ----------
        level_p: int
            (int >= 0) define the level of indentation of the message to print

        Returns
        -------
        str
            waveform filepath

        """

        display_obj = self.display_obj
        level0 = self.get_indentation_level(level_p=level_p)
        if self.verbosity > 0:
            display_obj.display_title(msg_p='Get the Simulator Waveform', level_p=level0)
        return self.wave_filepath

    def get_testbench_name(self):
        """
        Get the testbench name.
        Returns
        -------
        str
            testbench name

        """
        return self.tb_name

    def get_testbench(self, level_p=None):
        """
        Get  the Vunit Testbench object

        Parameters
        ----------
        level_p: int
            (int >= 0) define the level of indentation of the message to print

        Returns
        -------
        Vunit Testbench object if the testbench was found. Otherwise None

        """

        display_obj = self.display_obj
        tb_obj = self.tb_obj
        level0 = self.get_indentation_level(level_p=level_p)
        fct_name = self.class_name + '.get_testbench'

        if self.verbosity > 0:
            str0 = fct_name
            display_obj.display_title(msg_p=str0, level_p=level0)

        if tb_obj is None:
            msg0 = fct_name + ': KO: call the compile_tb method before'
            display_obj.display(msg_p=msg0, level_p=level0, color_p='red')
            return None
        else:
            return tb_obj

    def get_test_variant_filepath(self, level_p=None):
        """
        Get a list of variant filepath

        Parameters
        ----------
        level_p: int
            (int >= 0) define the level of indentation of the message to print

        Returns
        -------
        list of str
            list of variant filepath

        """

        base_path_dic = self.base_path_dic
        base_path = base_path_dic['conf_path']
        display_obj = self.display_obj
        filename_list = self.test_variant_filename_list
        level0 = self.get_indentation_level(level_p=level_p)
        level1 = level0 + 1
        level2 = level0 + 2
        fct_name = self.class_name + '.get_test_variant_filepath'

        if self.verbosity > 0:
            str0 = fct_name
            display_obj.display_title(msg_p=str0, level_p=level0)

        self._display_searched_basepath(verbosity_p=self.verbosity,basepath_p=base_path,level_p=level1,verbosity_min_p=0)

        obj = FilepathListBuilder()
        obj.set_file_extension(file_extension_list_p=['.json'])
        filepath_list = []
        for filename in filename_list:
            self._display_searched_filename(verbosity_p=self.verbosity,filename_p=filename,level_p=level2,verbosity_min_p=0)
            filepath = obj.get_filepath_by_filename(basepath_p=base_path, filename_p=filename, level_p=level2)
            filepath_list.append(filepath)

        return filepath_list

    def get_ram_filepath(self, filename_list_p, level_p=None):
        """
        Get a list of ram filepath

        Parameters
        ----------
        level_p: int
            (int >= 0) define the level of indentation of the message to print

        Returns
        -------
        list of str
            list of filepath

        """
        base_path_dic = self.base_path_dic
        base_path = base_path_dic['src_path']
        display_obj = self.display_obj
        fct_name = self.class_name + '.get_ram_filepath'

        level0 = self.get_indentation_level(level_p=level_p)
        level1 = level0 + 1
        level2 = level0 + 2

        if self.verbosity > 0:
            str0 = fct_name
            display_obj.display_title(msg_p=str0, level_p=level0)

        self._display_searched_basepath(verbosity_p=self.verbosity,basepath_p=base_path,level_p=level1,verbosity_min_p=0)


        obj = FilepathListBuilder()
        obj.set_file_extension(file_extension_list_p=['.mem'])
        filepath_list = []
        for filename in filename_list_p:
            self._display_searched_filename(verbosity_p=self.verbosity,filename_p=filename,level_p=level2,verbosity_min_p=0)
            filepath = obj.get_filepath_by_filename(basepath_p=base_path, filename_p=filename, level_p=level2)
            filepath_list.append(filepath)

        return filepath_list

    def set_sim_option(self, name_p, value_p, enable_coverage_p=False):
        """
        For all files:
          . set the simulation options
          . set the compilation options (if enabled)


        Parameters
        ----------
        name_p: str
            The name of the simulation option: https://vunit.github.io/py/opts.html
        value_p: list of str
            The value of the simulation option
        enable_coverage_p: boolean
            True: enable the code coverage
            False: disable the code coverage

        Returns
        -------
        None

        """
        # For all files, set the simulation options
        self.VU.set_sim_option(name_p, value_p)

        # Be sure do not desactivate the enable_coverage if already defined somewhere else
        if enable_coverage_p == True:
            self.enable_coverage = enable_coverage_p

        if (enable_coverage_p == 1):
            # For all files, set the code coverage options
            if (self.simulator_name == 'modelsim') or (self.simulator_name == 'questa'):
                self.VU.add_compile_option("modelsim.vcom_flags", ["+cover=bs"])
                self.VU.add_compile_option("modelsim.vlog_flags", ["+cover=bs"])

    def get_data_filepath(self, filename_p, level_p=None):
        """
        Get a list of data filepath

        Parameters
        ----------
        filename_p: str
            filename to search
        level_p: int
            (int >= 0) define the level of indentation of the message to print

        Returns
        -------
        list of str
            list of filepath

        """
        base_path_dic = self.base_path_dic
        base_path = base_path_dic['data_path']
        display_obj = self.display_obj
        fct_name = self.class_name + '.get_data_filepath'

        level0 = self.get_indentation_level(level_p=level_p)
        level1 = level0 + 1
        level2 = level0 + 2
        # get file extension
        ext = str(Path(filename_p).suffix)

        if self.verbosity > 0:
            str0 = fct_name
            display_obj.display_title(msg_p=str0, level_p=level0)
        self._display_searched_basepath(verbosity_p=self.verbosity,basepath_p=base_path,level_p=level1,verbosity_min_p=0)


        obj = FilepathListBuilder()
        obj.set_file_extension(file_extension_list_p=[ext])

        self._display_searched_filename(verbosity_p=self.verbosity,filename_p=filename_p,level_p=level2,verbosity_min_p=0)
        filepath = obj.get_filepath_by_filename(basepath_p=base_path, filename_p=filename_p, level_p=level2)

        return filepath

    def pre_config(self, output_path):
        """
        Define a list of actions to do before launching the simulator
        2 actions are provided:
            . execute a python script with a predefined set of command line arguments
            . copy the "mif files" into the Vunit simulation director for the compatible Xilinx IP
        Note:
            This method is the main entry point for the Vunit library

        Parameters
        ----------
        output_path: str
            Vunit Output Simulation Path (auto-computed by Vunit)

        Returns
        -------
        bool
            True if successful, False otherwise
        """

        display_obj = self.display_obj
        test_variant_filepath = self.test_variant_filepath
        script_filepath = self.script_filepath
        verbosity = self.verbosity
        fct_name = self.class_name + '.pre_config'

        level0 = self.level
        level1 = level0 + 1

        if self.verbosity > 0:
            str0 = fct_name
            display_obj.display_title(msg_p=str0, level_p=level0)

        ###############################
        # create directories (if not exist) for the VHDL testbench
        # .input directory  for the input data/command files
        # .output directory for the output data files
        tb_input_base_path = str(Path(output_path, 'inputs').resolve())
        tb_output_base_path = str(Path(output_path, 'outputs').resolve())
        self.create_directory(path_p=tb_input_base_path, level_p=level1)
        self.create_directory(path_p=tb_output_base_path, level_p=level1)

        # launch a python script to generate data and commands
        if script_filepath is not None:
            cmd = []
            # set the python
            cmd.append('python')
            # set the script path to call
            cmd.append(script_filepath)
            # set the --test_variant_filepath
            cmd.append('--test_variant_filepath')
            cmd.append(test_variant_filepath)
            # set the tb_input_base_path
            cmd.append('--tb_input_base_path')
            cmd.append(tb_input_base_path)
            # set the tb_output_base_path
            cmd.append('--tb_output_base_path')
            cmd.append(tb_output_base_path)
            # set the verbosity
            cmd.append('--verbosity')
            cmd.append(str(verbosity))

            result = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
            result.wait()

            if verbosity >= 1:
                str0 = fct_name+ ": command: " + " ".join(cmd)
                display_obj.display_title(msg_p=str0, level_p=level1)

        # copy the mif files into the Vunit simulation directory
        if self.filepath_list_mif is not None:
            self.copy_mif_files(output_path_p=output_path, level_p=level1)

        # write do_file
        # do_filepath = str(Path(output_path,'fpasim_compile.do'))
        # self.save_do_file(filepath_p=do_filepath,level_p=level0)

        # return True is mandatory for Vunit
        return True

    def main(self):
        """
        Run vunit main function and exit
        Parameters
        ----------
        post_run:
          A callback function which is called after running tests. The function must accept a single results argument which is an instance of Results


        """

        def convert_usdb_to_xml(input_file_path_p,output_file_path_p):
            """
            This function convert a usdb file (from the coverage) into a xml file.

            Parameters
            ----------
            input_file_path_p: str
                input converage file (*.usdb)
            output_file_path_p: str
                output *.xml file
            Returns
            -------
                None
            """
            import subprocess

            options = []
            # convert the usdb file into xml file
            options.append(str(Path(self.vcover_path,"vcover.exe")))
            options.append("report")
            options.append("-output")
            options.append(output_file_path_p)
            options.append("-srcfile=*")
            options.append("-details")
            options.append("-all")
            options.append("-dump")
            options.append("-option")
            options.append("-code")
            options.append("s b c")
            options.append("-xml")
            options.append(input_file_path_p)
            subprocess.call(options)

            return None


        def post_run(results):
            """
            This function merge all coverage files (*.usdb) into one *.xml file
            Then, convert the absolute "fileData path" into relative path from the git root path

            Note:
            This function will be run after the end of the simulation.

            Parameters
            ----------
            post_run:
                A callback function which is called after running tests. The function must accept a single results argument which is an instance of Results
            Returns
            -------

            """

            input_merge_file = str(Path(self.base_path_dic["results_path"],"coverage_data_merge.ucdb"))
            output_merge_file = str(Path(self.base_path_dic["results_path"],"coverage_data_merge.xml"))
            output_replace_file = str(Path(self.base_path_dic["results_path"],"coverage_data_replace.xml"))
            # merge the coverage files (*.usdb)
            results.merge_coverage(file_name=input_merge_file)
            # convert the merge usdb file into xml file
            convert_usdb_to_xml(input_file_path_p=input_merge_file,output_file_path_p=output_merge_file)



        if self.enable_coverage == 1:
            # Enable the code coverage
            self.VU.set_sim_option("enable_coverage", True)
            self.VU.add_compile_option("enable_coverage", True)
            self.VU.main(post_run=post_run)
        else:
            self.VU.main()


    def _display_searched_filename(self,verbosity_p,filename_p,level_p,verbosity_min_p=0):
        """
            Display the searched filename

            Parameters
            ----------
                verbosity_p: int
                    level of verbosity
                filename_p: str
                    searched filename to display
                level_p: int
                    indentation level
                verbosity_min_p: int
                    minimum level of verbosity in order to display the message
            Returns
            -------
                None

        """

        display_obj = self.display_obj

        if verbosity_p > verbosity_min_p:
                msg0 = 'Searched filename=' + filename_p
                display_obj.display(msg_p=msg0, level_p=level_p)

    def _display_searched_basepath(self,verbosity_p,basepath_p,level_p,verbosity_min_p=0):
        """
            Display the filepath

            Parameters
            ----------
                verbosity_p: int
                    level of verbosity
                basepath_p: str
                    searched basepath to display
                level_p: int
                    indentation level
                verbosity_min_p: int
                    minimum level of verbosity in order to display the message
            Returns
            -------
                None

        """

        display_obj = self.display_obj

        if verbosity_p > verbosity_min_p:
            msg0 = 'Searched basepath =' + basepath_p
            display_obj.display(msg_p=msg0, level_p=level_p)


