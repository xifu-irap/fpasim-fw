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
#    @file                   tes_top_data_gen.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    N/A
# -------------------------------------------------------------------------------------------------------------
#    @details
#
#    This TesTopDataGen class provides methods for the run_tb_tes_top.py.
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
from .core import Generator
from .core import OverSample
from .core import TesSignalling
from .core import TesPulseShapeManager
from .vunit_conf import VunitConf


class TesTopDataGen(VunitConf):
    """
        This TesTopDataGen class provides methods for the run_tb_tes_top.py.
        By processing the tb_tes_top_XXXX.json file, it can generate the input/output files expected by the VHDL tb_tes_top testbench.
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

        # count the number of pre_config call
        self.index = 0

        # name of the class (use for message)
        self.class_name = "TesTopDataGen"

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

        nb_pixel_by_frame = json_variant['register']['value']['nb_pixel_by_frame']
        nb_frame_by_pulse = json_variant['register']['value']['nb_frame_by_pulse']

        ram1_check = json_variant['ram1']['generic']['check']
        ram1_verbosity = json_variant['ram1']['generic']['verbosity']

        ram2_check = json_variant['ram2']['generic']['check']
        ram2_verbosity = json_variant['ram2']['generic']['verbosity']

        dic = {}
        dic['g_TEST_NAME'] = self.vhdl_test_name
        dic['g_NB_PIXEL_BY_FRAME'] = int(nb_pixel_by_frame)
        dic['g_NB_FRAME_BY_PULSE'] = int(nb_frame_by_pulse)
        dic['g_RAM1_CHECK'] = bool(ram1_check)
        dic['g_RAM1_VERBOSITY'] = ram1_verbosity
        dic['g_RAM2_CHECK'] = bool(ram2_check)
        dic['g_RAM2_VERBOSITY'] = ram2_verbosity
        return dic

    def _run(self,test_variant_filepath_p, tb_input_base_path_p):
        """
        Generate the VHDL testbench output files.

        Parameters
        ----------
        test_variant_filepath_p: str
            filepath to the test_variant json file.
        tb_input_base_path_p: str
            base path of the testbench VHDL input files

        Returns
        -------
            None

        """
        ################################################
        # Extract data from the configuration json file
        ################################################
        # Opening JSON file
        with open(test_variant_filepath_p, 'r') as fid_in:
            # returns JSON object as
            # a dictionary
            self.json_variant = json.load(fid_in)

        ########################################################
        # Generate the input valid sequence *.csv files for the vhdl testbench
        ########################################################
        self._gen_tb_input_valid_seq(output_base_path_p=tb_input_base_path_p)

        ########################################################
        # Generate the register *.csv file for the vhdl testbench
        ########################################################
        self._gen_tb_input_reg_file(output_base_path_p=tb_input_base_path_p)

        ########################################################
        # Generate the vhdl testbench input command file
        ########################################################
        self._gen_tb_input_cmd_file(output_base_path_p=tb_input_base_path_p)
         ########################################################
        # Copy the input RAM configuration files for the vhdl testbench in order to:
        #  1. to write
        #  2. to read
        #  3. to compare written data Vs read data
        # compute ram filepaths to used in order to compute data samples
        ########################################################
        self._gen_tb_ram_file(output_base_path_p=tb_input_base_path_p)

        ########################################################
        # compute the input data
        # compute the reference output data
        ########################################################
        pts_list = self._compute_data()

        # Generate the reference output data *.csv file for the vhdl testbench
        ########################################################
        self._gen_tb_ref_data_file(pts_list_p=pts_list, output_base_path_p=tb_input_base_path_p)

        # Generate the input data *.csv file for the vhdl testbench
        ########################################################
        self._gen_tb_input_data_file(pts_list_p=pts_list, output_base_path_p=tb_input_base_path_p)

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
        test_variant_filepath = self.new_test_variant_filepath_list[self.index]
        self.index += 1
        fct_name = self.class_name + ".pre_config"


        level0 = self.level
        level1 = level0 + 1

        if self.verbosity > 0:
            msg0 = ""
            display_obj.display(msg_p=msg0, level_p=level0)
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

        # copy the mif files into the Vunit simulation directory
        if self.filepath_list_mif is not None:
            self.copy_mif_files(output_path_p=output_path, level_p=level1)

        ##########################################################
        # generate files
        ##########################################################
        self._run(test_variant_filepath_p=test_variant_filepath, tb_input_base_path_p=tb_input_base_path)

        if self.verbosity > 0:
            str0 = fct_name+": Simulation transcript"
            display_obj.display_title(msg_p=str0, level_p=level0)
            str0 = test_variant_filepath
            display_obj.display(msg_p=str0, level_p=level1)

            str0 = ""
            display_obj.display(msg_p=str0, level_p=level0)

        # return True is mandatory for Vunit
        return True

    def _gen_tb_input_valid_seq(self, output_base_path_p):
        """
        Generate input sequence valid files for the vhdl testbench

        Parameters
        ----------
        output_base_path_p: str
            output base path of the *.csv file to write

        Returns
        -------
            None

        """
        display_obj = self.display_obj
        level0 = self.level
        level1 = level0 + 1
        csv_separator = self.csv_separator
        json_variant = self.json_variant
        fct_name = self.class_name+'._gen_tb_input_valid_seq'

        ########################################################
        # Generate the vhdl testbench input valid sequence files
        ########################################################
        if self.verbosity > 0:
            msg0 = fct_name+': Generate the testbench input valid sequence files'
            display_obj.display_subtitle(msg_p=msg0, level_p=level0)

        dic_sequence = []
        dic_sequence.append(json_variant["register"]["sequence"])
        dic_sequence.append(json_variant["cmd"]["sequence"])
        dic_sequence.append(json_variant["data"]["sequence"])
        dic_sequence.append(json_variant["ram1"]["sequence"])
        dic_sequence.append(json_variant["ram2"]["sequence"])

        for dic in dic_sequence:
            filename = dic["filename"]
            filepath = str(Path(output_base_path_p, filename).resolve())

            ctrl = dic["ctrl"]
            min_value1 = dic["min_value1"]
            max_value1 = dic["max_value1"]
            min_value2 = dic["min_value2"]
            max_value2 = dic["max_value2"]
            time_shift = dic["time_shift"]

            seq = ValidSequencer(name_p=filename)
            seq.set_verbosity(verbosity_p=self.verbosity)
            seq.set_sequence(ctrl_p=ctrl,
                             min_value1_p=min_value1,
                             max_value1_p=max_value1,
                             min_value2_p=min_value2,
                             max_value2_p=max_value2,
                             time_shift_p=time_shift)
            seq.save(filepath_p=filepath, csv_separator_p=csv_separator)

            if self.verbosity > 0:
                msg0 = 'filepath=' + filepath
                display_obj.display(msg_p=msg0, level_p=level1)

    def _gen_tb_ram_file(self,output_base_path_p):
        """
        This method has 2 parts:

        1. Generate input RAM files for
           . write/read/check

        2. compute the ram filepaths used to compute data.

        Parameters
        ----------
        output_base_path_p: str
            output base path of the *.csv file to write

        Returns
        -------
            dic
                list of ram filepahs used to compute data
        """

        json_variant = self.json_variant
        display_obj = self.display_obj
        level0 = self.level
        level1 = level0 + 1
        level2 = level1 + 1
        fct_name = self.class_name+'._gen_tb_ram_file'

        if self.verbosity > 0:
            msg0 = fct_name+': Copy the testbench input RAM configuration files'
            display_obj.display_subtitle(msg_p=msg0, level_p=level0)

        dic_sequence = []
        dic_sequence.append(json_variant["ram1"])
        dic_sequence.append(json_variant["ram2"])

        # files to use in order to write/read/check the memory in the testbench
        for dic in dic_sequence:
            input_filename = dic["value"]['input_filename']
            output_filename = dic["value"]['output_filename']
            output_filepath = str(Path(output_base_path_p, output_filename))
            input_filepath = self.get_data_filepath(filename_p=input_filename, level_p=level1)

            if self.verbosity > 0:
                msg0 = 'from: ' + input_filepath
                display_obj.display(msg_p=msg0, level_p=level2)
                msg0 = 'to: ' + output_filepath
                display_obj.display(msg_p=msg0, level_p=level2)

            shutil.copyfile(input_filepath, output_filepath)

        if self.verbosity > 0:
            msg0 = fct_name+': Process RAM configuration files for the computation on the datapath'
            display_obj.display_subtitle(msg_p=msg0, level_p=level0)

        # compute the ram filepaths used to compute data
        ram_filepath_dic = {}
        for dic in dic_sequence:
            name = dic["generic"]['name']
            # defaut ram content
            input_data_filename = dic["value"]['input_filename_datapath']
            input_data_filepath = self.get_data_filepath(filename_p=input_data_filename, level_p=level1)


            if self.verbosity > 0:
                msg0 = 'used files for the datapath computation: ' + input_data_filepath
                display_obj.display(msg_p=msg0, level_p=level2)

            # save the ram content
            ram_filepath_dic[name] = input_data_filepath

        self.ram_filepath_dic = ram_filepath_dic

    def _compute_data(self):
        """
        compute data samples with attributes

        Parameters
        ----------
            None

        Returns
        -------
            list of data samples with attributes

        """

        json_variant = self.json_variant
        display_obj = self.display_obj
        level0 = self.level
        level1 = level0 + 1
        level2 = level0 + 2
        fct_name = self.class_name+'._compute_data'

         # adc: compute parameters
        ########################################################
        nb_sample_by_pixel = json_variant["register"]["value"]["nb_sample_by_pixel"]
        nb_pixel_by_frame = json_variant["register"]["value"]["nb_pixel_by_frame"]
        nb_frame_by_pulse = json_variant["register"]["value"]["nb_frame_by_pulse"]
        nb_pulse = json_variant["register"]["value"]["nb_pulse"]

        nb_pts = nb_pixel_by_frame * nb_frame_by_pulse * nb_pulse
        nb_sample_by_frame = nb_pixel_by_frame * nb_sample_by_pixel
        oversampling = nb_sample_by_pixel

        tes_pulse_shape_filename = json_variant["ram1"]["generic"]["name"]
        tes_pulse_shape_filepath = self.ram_filepath_dic[tes_pulse_shape_filename]

        tes_steady_state_filename = json_variant["ram2"]["generic"]["name"]
        tes_steady_state_filepath = self.ram_filepath_dic[tes_steady_state_filename]

        # generate data
        ########################################################
        # adc
        obj_gen = Generator(nb_pts_p=nb_pts)
        pts_list = obj_gen.run()

        obj_over = OverSample(pts_list_p=pts_list)
        obj_over.set_oversampling(value_p=oversampling)
        pts_list = obj_over.run()

        # tes
        obj_sign = TesSignalling(pts_list_p=pts_list)
        obj_sign.set_conf(nb_pixel_by_frame_p=nb_pixel_by_frame, nb_sample_by_pixel_p=nb_sample_by_pixel,
                          nb_sample_by_frame_p=nb_sample_by_frame, nb_frame_by_pulse_p=nb_frame_by_pulse)
        pts_list = obj_sign.run()

        obj_tes = TesPulseShapeManager(pts_list_p=pts_list)
        obj_tes.set_ram_tes_pulse_shape(filepath_p=tes_pulse_shape_filepath)
        obj_tes.set_ram_tes_steady_state(filepath_p=tes_steady_state_filepath)

        skip_nb_samples = self.cmd_skip_nb_samples
        for pulse_height, pixel_id, time_shift in zip(self.cmd_pulse_height_list, self.cmd_pixel_id_list, self.cmd_time_shift_list):
            obj_tes.add_make_pulse_command(pixel_id_p=pixel_id, time_shift_p=time_shift, pulse_height_p=pulse_height,
                                           skip_nb_samples_p=skip_nb_samples)
        pts_list = obj_tes.run(output_attribute_name_p="tes_out")

        return pts_list

    def _gen_tb_ref_data_file(self,pts_list_p, output_base_path_p):
        """
        Generate the output data reference file for the vhdl testbench

        Parameters
        ----------
            pts_list: list of pts
                computed data samples with attributes
            output_base_path_p: str
                output base path of the *.csv file to write
        Returns
        -------
            None

        """

        display_obj = self.display_obj
        level0 = self.level
        level1 = level0 + 1
        pts_list = pts_list_p
        json_variant = self.json_variant
        csv_separator = self.csv_separator

        fct_name = self.class_name+'._gen_tb_ref_data_file'

        if self.verbosity > 0:
            msg0 = fct_name+': Generate the testbench reference output file'
            display_obj.display_subtitle(msg_p=msg0, level_p=level0)

        output_filename = json_variant["model"]["value"]["output_filename"]
        output_filepath = str(Path(output_base_path_p, output_filename))

        with open(output_filepath, 'w') as fid:
            # write header
            fid.write("expected_tes_out_int")
            fid.write(csv_separator)
            fid.write('pixel_id_uint')
            fid.write('\n')
            # write data
            index_max = len(pts_list) - 1
            for index, obj_pt in enumerate(pts_list):
                # get point attribute
                tes_out = obj_pt.get_attribute(name_p="tes_out")
                pixel_id = obj_pt.get_attribute(name_p="pixel_id")
                # write attribute value
                fid.write(str(tes_out))
                fid.write(csv_separator)
                fid.write(str(pixel_id))
                if index != index_max:
                    fid.write('\n')

        if self.verbosity > 0:
            msg0 = 'filepath= ' + output_filepath
            display_obj.display(msg_p=msg0, level_p=level1)

    def _gen_tb_input_data_file(self,pts_list_p, output_base_path_p):
        """
        Generate the input data file for the vhdl testbench: input data file

        Parameters
        ----------
            pts_list: list of pts
                computed data samples with attributes
            output_base_path_p: str
                output base path of the *.csv file to write
        Returns
        -------
            None

        """
        display_obj = self.display_obj
        level0 = self.level
        level1 = level0 + 1
        pts_list = pts_list_p
        json_variant = self.json_variant
        csv_separator = self.csv_separator

        fct_name = self.class_name+'._gen_tb_input_data_file'

        if self.verbosity > 0:
            msg0 = fct_name+': Generate the testbench input data file'
            display_obj.display_subtitle(msg_p=msg0, level_p=level0)

        filename = json_variant["data"]["value"]["filename"]
        filepath = str(Path(output_base_path_p, filename))

        with open(filepath, 'w') as fid:
            # write header
            fid.write("data")
            fid.write('\n')
            index_max = len(pts_list) - 1
            for index, obj_pt in enumerate(pts_list):
                fid.write(str(1))
                if index != index_max:
                    fid.write('\n')

        if self.verbosity > 0:
            msg0 = 'filepath=' + filepath
            display_obj.display(msg_p=msg0, level_p=level1)

        return None

    def _gen_tb_input_reg_file(self,output_base_path_p):

        """
        Generate input sequence valid files for the vhdl testbench

        Parameters
        ----------
        output_base_path_p: str
            output base path of the *.csv file to write

        Returns
        -------
            None

        """
        display_obj = self.display_obj
        level0 = self.level
        level1 = level0 + 1
        csv_separator = self.csv_separator
        json_variant = self.json_variant
        fct_name = self.class_name+'._gen_tb_input_reg_file'

        if self.verbosity > 0:
            msg0 = fct_name+ ': Generate the testbench input register file'
            display_obj.display_subtitle(msg_p=msg0, level_p=level0)

        filename = json_variant["register"]["value"]["filename"]
        nb_sample_by_pixel = json_variant["register"]["value"]["nb_sample_by_pixel"]
        nb_pixel_by_frame = json_variant["register"]["value"]["nb_pixel_by_frame"]
        nb_frame_by_pulse = json_variant["register"]["value"]["nb_frame_by_pulse"]
        nb_pulse = json_variant["register"]["value"]["nb_pulse"]

        # compute fpga values start from 0
        nb_sample_by_pixel_tmp = nb_sample_by_pixel - 1
        nb_pixel_by_frame_tmp = nb_pixel_by_frame - 1
        # nb_frame_by_pulse_tmp = nb_frame_by_pulse - 1
        # nb_pulse           = nb_pulse_tmp
        # auto-compute the VDHL expected nb_sample_by_frame value (start from 0)
        nb_samples_by_frame_tmp = nb_sample_by_pixel * nb_pixel_by_frame - 1

        filepath = str(Path(output_base_path_p, filename))
        with open(filepath, 'w') as fid:
            # header
            fid.write('nb_samples_by_pixel_uint')
            fid.write(csv_separator)
            fid.write('nb_pixel_by_frame_uint')
            fid.write(csv_separator)
            fid.write('nb_samples_by_frame_uint')
            fid.write('\n')
            # data
            fid.write(str(nb_sample_by_pixel_tmp))
            fid.write(csv_separator)
            fid.write(str(nb_pixel_by_frame_tmp))
            fid.write(csv_separator)
            fid.write(str(nb_samples_by_frame_tmp))

        if self.verbosity > 0:
            msg0 = 'filepath=' + filepath
            display_obj.display(msg_p=msg0, level_p=level1)


    def _gen_tb_input_cmd_file(self,output_base_path_p):

        """
        Generate input sequence valid files for the vhdl testbench

        Parameters
        ----------
        output_base_path_p: str
            output base path of the *.csv file to write

        Returns
        -------
            None

        """
        display_obj = self.display_obj
        level0 = self.level
        level1 = level0 + 1
        csv_separator = self.csv_separator
        json_variant = self.json_variant
        fct_name = self.class_name+'._gen_tb_input_cmd_file'

        if self.verbosity > 0:
            msg0 = fct_name+': Generate the testbench input command file'
            display_obj.display_subtitle(msg_p=msg0, level_p=level0)

        filename = json_variant["cmd"]["value"]["filename"]
        self.cmd_pulse_height_list = json_variant["cmd"]["value"]["pulse_height_list"]
        self.cmd_pixel_id_list = json_variant["cmd"]["value"]["pixel_id_list"]
        self.cmd_time_shift_list = json_variant["cmd"]["value"]["time_shift_list"]
        self.cmd_skip_nb_samples = 0

        filepath = str(Path(output_base_path_p, filename))

        with open(filepath, 'w') as fid:
            # header
            fid.write('pulse_height')
            fid.write(csv_separator)
            fid.write('pixel_id')
            fid.write(csv_separator)
            fid.write('time_shift')
            fid.write('\n')
            index_max = len(self.cmd_pulse_height_list) - 1
            index = 0
            for pulse_height, pixel_id, time_shift in zip(self.cmd_pulse_height_list, self.cmd_pixel_id_list,self.cmd_time_shift_list):
                fid.write(str(pulse_height))
                fid.write(csv_separator)
                fid.write(str(pixel_id))
                fid.write(csv_separator)
                fid.write(str(time_shift))
                if index != index_max:
                    fid.write('\n')

                index += 1

        if self.verbosity > 0:
            msg0 = 'filepath=' + filepath
            display_obj.display(msg_p=msg0, level_p=level1)

        return None
