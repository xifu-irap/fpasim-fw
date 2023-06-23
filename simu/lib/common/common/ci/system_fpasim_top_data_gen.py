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
#    @file                   system_fpasim_top_data_gen.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    N/A
# -------------------------------------------------------------------------------------------------------------
#    @details
#
#    This SystemFpasimTopDataGen class provides methods for the run_tb_tes_top.py.
#    By processing the tb_tes_top_XXXX.json file, it can generate the input/output files expected by the VHDL tb_tes_top testbench.
#    
#    Note:
#       . This script was tested with python 3.10
#
# -------------------------------------------------------------------------------------------------------------

# standard library
import json
import os
import shutil
import copy
from pathlib import Path

# user library
from .utils import Display

from .core import ValidSequencer
from .core import File
from .core import Generator
from .core import Attribute
from .core import OverSample
from .core import TesSignalling
from .core import TesPulseShapeManager
from .core import MuxSquidTop
from .core import AmpSquidTop
from .vunit_conf import VunitConf


class SystemFpasimTopDataGen(VunitConf):
    """
        This class provides methods for the run_tb_system_fpasim_top.py and run_tb_fpga_system_fpasim_top.py.
        By processing the tb_system_fpasim_top_XXXX.json file, it can generate the input/output files expected by the VHDL tb_system_fpasim_top testbench.
    """

    def __init__(self, json_filepath_p, json_key_path_p):
        """
        This method initializes the class instance.

        Parameters
        ----------
        json_filepath_p: str
            json filepath
        json_key_path_p: str
            json keys to get a specific individual test
        """
        super().__init__(json_filepath_p=json_filepath_p, json_key_path_p=json_key_path_p)

        # separator of the *.csv file
        self.csv_separator = ';'

        # register field
        # ctrl register
        self.en = 0
        # fpasim_gain register
        self.fpasim_gain = 0
        # tes_conf register
        self.nb_pixel_by_frame = 0
        self.nb_sample_by_pixel = 0
        self.nb_sample_by_frame = 0
        # conf0 register
        self.inter_squid_gain = 0
        # make pulse register
        self.pixel_all_list = []
        self.pixel_id_list = []
        self.time_shift_list = []
        self.pulse_heigth_list = []

        # model
        # keep track of the input ram filepath
        self.ram_dic = {}

        self.reg_id_list = []
        self.addr_list = []
        self.data_list = []
        self.cmt_list = []
        self.data_width = 32  # number max of bit of a register

        # count the number of pre_config call
        self.index = 0

    def get_generic_dic(self):
        """
        Get the testbench vhdl generic parameters.

        Note:
            The Vunit library set the testbench vhdl generic parameters with a python
            dictionary where key name are the VHDL generic names.

        Returns: dic
        -------
            dictionnary of testbench VHDL generic values.
        """
        json_variant = self.json_variant

        dic = {}
        dic['g_TEST_NAME'] = self.vhdl_test_name

        return dic

    def _compute_reg_from_field(self, reg_def_section_dic_p, cmd_p):

        cmd_name, mode, *value_list = cmd_p.split(';')
        cmd = cmd_p

        key = '@' + cmd_name.lower()
        reg_dic = reg_def_section_dic_p.get(key)

        dic_mode = reg_dic.get(mode)
        if dic_mode is None:
            msg0 = 'SystemFpasimTopDataGen._run: ERROR: the mode ' + str(mode) + " doesn't exist (" + cmd + ')'
            display_obj.display(msg_p=msg0, level_p=level1, color_p='red')

        reg_id = str(reg_dic[mode]["reg_id"])
        usb_addr = dic_mode["usb_addr"]
        usb_addr = '{0:02x}'.format(int(usb_addr, 16))

        # work on a deep copy of the field in order to not modify the source dictionnary for further cmd processing
        dic_field = copy.deepcopy(reg_dic["field"])

        for item in value_list:
            field_name_tmp, str_new_value = item.split('=')
            # convert str to integer
            new_value = int(str_new_value)
            # test if the field exist
            dic_bit_field = dic_field.get(field_name_tmp)
            if dic_bit_field is None:
                msg0 = 'SystemFpasimTopDataGen._run: ERROR: the field ' + str(
                    field_name_tmp) + " doesn't exist (" + cmd + ')'
                display_obj.display(msg_p=msg0, level_p=level1, color_p='red')
            else:
                # overwrite the value
                # print('field_name_tmp',field_name_tmp)
                # print(dic_bit_field)
                dic_bit_field['value'] = new_value
        # compute the register value
        result = 0
        for key in dic_field.keys():
            dic = dic_field[key]

            bit_pos_min = dic.get('bit_pos_min')
            if bit_pos_min is None:
                bit_pos_min = 0
            width = dic.get('width')
            value = dic['value']
            # test the range of value
            if width is not None:
                max_value = 2 ** width - 1
                if value > max_value:
                    msg0 = 'SystemFpasimTopDataGen._run: ERROR: the field ' + str(
                        key) + " value is out of range (" + cmd + ')'
                    display_obj.display(msg_p=msg0, level_p=level1, color_p='red')

            if width is not None:
                # test if the field range is not bigger than the register width
                reg_bit_pos_max = self.data_width - 1
                bit_pos_max = bit_pos_min + (width - 1)

                if bit_pos_max > reg_bit_pos_max:
                    msg0 = 'SystemFpasimTopDataGen._run: ERROR: the field ' + str(
                        key) + " range is out of range (" + cmd + ')'
                    display_obj.display(msg_p=msg0, level_p=level1, color_p='red')
                    msg0 = 'the field ' + str(key) + " (" + str(bit_pos_max) + ',' + str(
                        bit_pos_min) + ') > register width (' + str(reg_bit_pos_max) + ',0)'
                    display_obj.display(msg_p=msg0, level_p=level2, color_p='red')

            result += (value << bit_pos_min)

        str_result = '{0:08x}'.format(result)

        self.reg_id_list.append(reg_id)
        self.addr_list.append(usb_addr)
        self.cmt_list.append('"' + cmd + '"')
        self.data_list.append(str_result)

        return result, dic_field

    def _run(self,test_variant_filepath_p, tb_input_base_path_p, tb_output_base_path_p):
        """
        Generate the VHDL testbench output files.

        Parameters
        ----------
        test_variant_filepath_p: str
            filepath to the test_variant json file.
        tb_input_base_path_p: str
            base path of the testbench VHDL input files
        tb_output_base_path_p: str
            base path of the testbench VHDL output files

        Returns
        -------
            None

        """
        tb_input_base_path = tb_input_base_path_p
        tb_output_base_path = tb_output_base_path_p
        test_variant_filepath = test_variant_filepath_p
        display_obj = self.display_obj
        level0 = self.level
        level1 = level0 + 1
        level2 = level0 + 2
        verbosity = self.verbosity
        csv_separator = self.csv_separator

        ################################################
        # Extract data from the configuration json file
        ################################################
        # Opening JSON file
        with open(test_variant_filepath, 'r') as fid_in:
            # returns JSON object as
            # a dictionary
            json_variant = json.load(fid_in)

        # get the list of command and get the output file name
        seq_dic = json_variant["command_sequence_section"]
        cmd_list = seq_dic["cmd_list"]
        output_tb_filename = seq_dic["output_tb_filename"]
        output_tb_filepath = str(Path(tb_input_base_path, output_tb_filename))

        # get the register definition
        reg_def_section_dic = json_variant["register_definition_section"]

        if self.verbosity > 0:
            msg0 = 'output_tb_filepath=' + output_tb_filepath
            display_obj.display(msg_p=msg0, level_p=level2)

        ########################################################
        # Generate the vhdl testbench input valid sequence files
        ########################################################
        if self.verbosity > 0:
            msg0 = 'SystemFpasimTopDataGen._run: ram data generation from files'
            display_obj.display_subtitle(msg_p=msg0, level_p=level0)

        for cmd in cmd_list:
            if self.verbosity > 0:
                msg0 = 'SystemFpasimTopDataGen._run: Generate the cmd: ' + cmd
                display_obj.display(msg_p=msg0, level_p=level1)

            cmd_name, mode, *value_list = cmd.split(';')

            key = '@' + cmd_name.lower()
            reg_dic = reg_def_section_dic.get(key)

            if reg_dic is None:
                msg0 = 'SystemFpasimTopDataGen._run: ERROR: the key ' + str(key) + " doesn't exist (" + cmd + ')'
                display_obj.display(msg_p=msg0, level_p=level1, color_p='red')
                continue

            if key == "@usb_ram":
                dic_field = reg_dic["field"]

                for ram_name in value_list:
                    new_cmd = cmd_name + ';' + mode + ';' + ram_name
                    dic = dic_field[ram_name]

                    dic_mode = dic.get(mode)
                    if dic_mode is None:
                        msg0 = 'SystemFpasimTopDataGen._run: ERROR: the mode ' + str(
                            mode) + " doesn't exist (" + cmd + ')'
                        display_obj.display(msg_p=msg0, level_p=level1, color_p='red')
                        continue

                    reg_id = str(dic_mode["reg_id"])
                    usb_addr = dic_mode["usb_addr"]
                    usb_addr = '{0:02x}'.format(int(usb_addr, 16))
                    name = dic['name']
                    offset_addr = dic['offset_addr']
                    input_filename = dic['input_filename']
                    ref_output_tb_filename = dic['output_tb_filename']
                    ref_output_tb_filepath = str(Path(tb_input_base_path, ref_output_tb_filename))
                    input_filepath = self.get_data_filepath(filename_p=input_filename, level_p=level1)

                    if self.verbosity > 0:
                        msg0 = 'input_filepath=' + input_filepath
                        display_obj.display(msg_p=msg0, level_p=level2)

                    with open(input_filepath, 'r') as fid_tmp:
                        lines = fid_tmp.readlines()

                    # delete the header
                    del lines[0]
                    addr_ref_list = []
                    data_ref_list = []
                    for line in lines:
                        line_tmp = line.rstrip()
                        if line_tmp == "":
                            # skip empty line. 
                            # In particular, at the end of the file
                            continue
                        str_addr, str_value = line.split(csv_separator)
                        str_addr = str_addr.replace('\n', '')
                        str_value = str_value.replace('\n', '')

                        # add the address offset
                        new_addr = int(str_addr) + int(offset_addr, 16)
                        str_addr = '{0:04x}'.format(new_addr)
                        str_data = '{0:04x}'.format(int(str_value))
                        str_result = str_addr + str_data

                        #####################################
                        # build lists for the command file
                        #####################################
                        self.data_list.append(str_result)
                        self.reg_id_list.append(reg_id)
                        self.addr_list.append(usb_addr)
                        self.cmt_list.append('"' + new_cmd + '"')

                        ######################################
                        # build list as reference file
                        ######################################
                        addr_ref_list.append(str(new_addr))
                        data_ref_list.append(str_value)

                    with open(ref_output_tb_filepath, 'w') as ref_fid:

                        #########################################
                        # build header file
                        ref_fid.write('addr_uint')
                        ref_fid.write(csv_separator)
                        ref_fid.write('data_uint')
                        ref_fid.write('\n')
                        L_ref = len(data_ref_list)
                        index_max = L_ref - 1
                        for j in range(0, L_ref):
                            addr_ref = addr_ref_list[j]
                            data_ref = data_ref_list[j]
                            ref_fid.write(addr_ref)
                            ref_fid.write(csv_separator)
                            ref_fid.write(data_ref)
                            if j != index_max:
                                ref_fid.write('\n')

            elif key == '@usb_ctrl':
                result, dic_field = self._compute_reg_from_field(reg_def_section_dic_p=reg_def_section_dic, cmd_p=cmd)
                self.en = dic_field['en']['value']
            elif key == '@usb_fpgasim_gain':
                result, dic_field = self._compute_reg_from_field(reg_def_section_dic_p=reg_def_section_dic, cmd_p=cmd)
                self.fpasim_gain = dic_field['gain']['value']

            elif key == '@usb_tes_conf':
                result, dic_field = self._compute_reg_from_field(reg_def_section_dic_p=reg_def_section_dic, cmd_p=cmd)
                self.nb_pixel_by_frame = dic_field['nb_pixel_by_frame']['value']
                self.nb_sample_by_pixel = dic_field['nb_sample_by_pixel']['value']
                self.nb_sample_by_frame = dic_field['nb_sample_by_frame']['value']

            elif key == '@usb_conf0':
                result, dic_field = self._compute_reg_from_field(reg_def_section_dic_p=reg_def_section_dic, cmd_p=cmd)
                self.inter_squid_gain = dic_field['inter_squid_gain']['value']

            elif key == '@usb_make_pulse':

                result, dic_field = self._compute_reg_from_field(reg_def_section_dic_p=reg_def_section_dic, cmd_p=cmd)
                pixel_all = dic_field['pixel_all']['value']
                pixel_id = dic_field['pixel_id']['value']
                time_shift = dic_field['time_shift']['value']
                pulse_heigth = dic_field['pulse_heigth']['value']
                self.pixel_id_list.append(pixel_id)
                self.time_shift_list.append(time_shift)
                self.pulse_heigth_list.append(pulse_heigth)

            else:
                # manage trig/wire
                result, _ = self._compute_reg_from_field(reg_def_section_dic_p=reg_def_section_dic, cmd_p=cmd)

        with open(output_tb_filepath, 'w') as fid:
            fid.write("reg_id")
            fid.write(csv_separator)
            fid.write("opal_kelly_addr_hex")
            fid.write(csv_separator)
            fid.write("data_hex(addr+data)")
            fid.write(csv_separator)
            fid.write("comment")
            fid.write("\n")
            L = len(self.data_list)
            index_max = L - 1
            for i in range(L):
                reg_id = self.reg_id_list[i]
                str_addr = self.addr_list[i]
                str_data = self.data_list[i]
                str_cmt = self.cmt_list[i]
                fid.write(reg_id)
                fid.write(csv_separator)
                fid.write(str_addr)
                fid.write(csv_separator)
                fid.write(str_data)
                fid.write(csv_separator)
                fid.write(str_cmt)
                if i != index_max:
                    fid.write('\n')

        ########################################################
        # compute the reference file
        ########################################################
        # retrieve RAM configuration file

        return None

    def pre_config(self, output_path):
        """
        Define a list of actions to do before launching the VHDL simulator.

        Note:
            This method is the main entry point for the Vunit library

        Parameters
        ----------
        output_path: str
            Vunit Output Simulation Path (auto-computed by the Vunit library)

        Returns
        -------
            bool

        """
        display_obj = self.display_obj
        verbosity = self.verbosity
        if self.new_test_variant_filepath_list != []:
            test_variant_filepath = self.new_test_variant_filepath_list[self.index]
        self.index += 1

   
        level0 = self.level
        level1 = level0 + 1

        if self.verbosity > 0:
            msg0 = ""
            display_obj.display(msg_p=msg0, level_p=level0)
            str0 = "SystemFpasimTopDataGen.pre_config"
            display_obj.display_title(msg_p=str0, level_p=level0)

        ###############################
        # create directories (if not exist) for the VHDL testbench
        # .input directory  for the input data/command files
        # .output directory for the output data files
        tb_input_base_path = str(Path(output_path, 'inputs').resolve())
        tb_output_base_path = str(Path(output_path, 'outputs').resolve())
        self.create_directory(path_p=tb_input_base_path, level_p=level1)
        self.create_directory(path_p=tb_output_base_path, level_p=level1)

        # copy the mif files into the Vunit simulation directory
        if self.filepath_list_mif is not None:
            self.copy_mif_files(output_path_p=output_path, level_p=level1)

        ##########################################################
        # generate files
        ##########################################################
        if self.new_test_variant_filepath_list != []:   
            self._run(test_variant_filepath_p=test_variant_filepath, tb_input_base_path_p=tb_input_base_path, tb_output_base_path_p=tb_output_base_path)
    
        if self.verbosity > 0:
            str0 = "SystemFpasimTopDataGen.pre_config: Simulation transcript"
            display_obj.display_title(msg_p=str0, level_p=level0)
            str0 = test_variant_filepath 
            display_obj.display(msg_p=str0, level_p=level1)

            str0 = ""
            display_obj.display(msg_p=str0, level_p=level0)

        # return True is mandatory for Vunit
        return True
