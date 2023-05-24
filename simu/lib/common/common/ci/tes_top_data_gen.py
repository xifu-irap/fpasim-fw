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
        dic['g_NB_PIXEL_BY_FRAME'] = int(nb_pixel_by_frame)
        dic['g_NB_FRAME_BY_PULSE'] = int(nb_frame_by_pulse)
        dic['g_RAM1_CHECK'] = bool(ram1_check)
        dic['g_RAM1_VERBOSITY'] = ram1_verbosity
        dic['g_RAM2_CHECK'] = bool(ram2_check)
        dic['g_RAM2_VERBOSITY'] = ram2_verbosity
        return dic

    def _run(self, tb_input_base_path_p, tb_output_base_path_p):
        """
        Generate the VHDL testbench output files.

        Parameters
        ----------
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
        test_variant_filepath = self.test_variant_filepath
        display_obj = self.display_obj
        level0 = self.level
        level1 = level0 + 1
        level2 = level0 + 2
        verbosity = self.verbosity
        json_variant = self.json_variant
        csv_separator = self.csv_separator

        ########################################################
        # Generate the vhdl testbench input valid sequence files
        ########################################################
        msg0 = 'TesTopDataGen._run: Generate the testbench input valid sequence files'
        display_obj.display_subtitle(msg_p=msg0, level_p=level0)

        dic_sequence = []
        dic_sequence.append(json_variant["register"]["sequence"])
        dic_sequence.append(json_variant["cmd"]["sequence"])
        dic_sequence.append(json_variant["data"]["sequence"])
        dic_sequence.append(json_variant["ram1"]["sequence"])
        dic_sequence.append(json_variant["ram2"]["sequence"])

        for dic in dic_sequence:
            filename = dic["filename"]
            filepath = str(Path(tb_input_base_path, filename).resolve())

            ctrl = dic["ctrl"]
            min_value1 = dic["min_value1"]
            max_value1 = dic["max_value1"]
            min_value2 = dic["min_value2"]
            max_value2 = dic["max_value2"]
            time_shift = dic["time_shift"]

            seq = ValidSequencer(name_p=filename)
            seq.set_verbosity(verbosity_p=verbosity)
            seq.set_sequence(ctrl_p=ctrl,
                             min_value1_p=min_value1,
                             max_value1_p=max_value1,
                             min_value2_p=min_value2,
                             max_value2_p=max_value2,
                             time_shift_p=time_shift)
            seq.save(filepath_p=filepath, csv_separator_p=csv_separator)

            msg0 = 'filepath=' + filepath
            display_obj.display(msg_p=msg0, level_p=level1)

        ########################################################
        # Generate the VHDL testbench input register file
        ########################################################
        msg0 = 'TesTopDataGen._run: Generate the testbench input register file'
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

        filepath = str(Path(tb_input_base_path, filename))
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

        msg0 = 'filepath=' + filepath
        display_obj.display(msg_p=msg0, level_p=level1)

        ########################################################
        # Generate the vhdl testbench input command file
        ########################################################
        msg0 = 'TesTopDataGen._run: Generate the testbench input command file'
        display_obj.display_subtitle(msg_p=msg0, level_p=level0)

        filename = json_variant["cmd"]["value"]["filename"]
        cmd_pulse_height_list = json_variant["cmd"]["value"]["pulse_height_list"]
        cmd_pixel_id_list = json_variant["cmd"]["value"]["pixel_id_list"]
        cmd_time_shift_list = json_variant["cmd"]["value"]["time_shift_list"]
        cmd_skip_nb_samples = 0

        filepath = str(Path(tb_input_base_path, filename))

        with open(filepath, 'w') as fid:
            # header
            fid.write('pulse_height')
            fid.write(csv_separator)
            fid.write('pixel_id')
            fid.write(csv_separator)
            fid.write('time_shift')
            fid.write('\n')
            index_max = len(cmd_pulse_height_list) - 1
            index = 0
            for pulse_height, pixel_id, time_shift in zip(cmd_pulse_height_list, cmd_pixel_id_list,
                                                          cmd_time_shift_list):
                fid.write(str(pulse_height))
                fid.write(csv_separator)
                fid.write(str(pixel_id))
                fid.write(csv_separator)
                fid.write(str(time_shift))
                if index != index_max:
                    fid.write('\n')

                index += 1

        msg0 = 'filepath=' + filepath
        display_obj.display(msg_p=msg0, level_p=level1)

        ########################################################
        # Copy the vhdl testbench input RAM configuration files
        ########################################################
        msg0 = 'TesTopDataGen._run: Copy the testbench input RAM configuration files'
        display_obj.display_subtitle(msg_p=msg0, level_p=level0)

        dic_sequence = []
        dic_sequence.append(json_variant["ram1"])
        dic_sequence.append(json_variant["ram2"])

        ram_filepath_dic = {}

        for dic in dic_sequence:
            input_filename = dic["value"]['input_filename']
            output_filename = dic["value"]['output_filename']
            name = dic["generic"]['name']
            output_filepath = str(Path(tb_input_base_path, output_filename))
            input_filepath = self.get_data_filepath(filename_p=input_filename, level_p=level1)

            msg0 = 'from: ' + input_filepath
            display_obj.display(msg_p=msg0, level_p=level2)
            msg0 = 'to: ' + output_filepath
            display_obj.display(msg_p=msg0, level_p=level2)

            shutil.copyfile(input_filepath, output_filepath)

            # save the ram content
            # ram_filepath_dic[name] = output_filepath

        msg0 = 'TesTopDataGen._run: Process RAM configuration files for the computation on the datapath'
        display_obj.display_subtitle(msg_p=msg0, level_p=level0)
        # process Memory files for the datapath computation
        for dic in dic_sequence:
            input_filename = dic["value"]['input_filename_datapath']
            name = dic["generic"]['name']
            input_filepath = self.get_data_filepath(filename_p=input_filename, level_p=level1)

            msg0 = 'used files for the datapath computation: ' + input_filepath
            display_obj.display(msg_p=msg0, level_p=level2)

            shutil.copyfile(input_filepath, output_filepath)

            # save the ram content
            ram_filepath_dic[name] = input_filepath


        ########################################################
        # compute the vhdl testbench reference output values
        ########################################################
        msg0 = 'TesTopDataGen._run: compute the testbench reference output values'
        display_obj.display_subtitle(msg_p=msg0, level_p=level0)

        # adc: compute parameters
        ########################################################
        nb_pts = nb_pixel_by_frame * nb_frame_by_pulse * nb_pulse
        nb_sample_by_frame = nb_pixel_by_frame * nb_sample_by_pixel
        oversampling = nb_sample_by_pixel

        tes_pulse_shape_filename = json_variant["ram1"]["generic"]["name"]
        tes_pulse_shape_filepath = ram_filepath_dic[tes_pulse_shape_filename]

        tes_steady_state_filename = json_variant["ram2"]["generic"]["name"]
        tes_steady_state_filepath = ram_filepath_dic[tes_steady_state_filename]

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

        skip_nb_samples = cmd_skip_nb_samples
        for pulse_height, pixel_id, time_shift in zip(cmd_pulse_height_list, cmd_pixel_id_list, cmd_time_shift_list):
            obj_tes.add_make_pulse_command(pixel_id_p=pixel_id, time_shift_p=time_shift, pulse_height_p=pulse_height,
                                           skip_nb_samples_p=skip_nb_samples)
        pts_list = obj_tes.run(output_attribute_name_p="tes_out")

        # Generate the vhdl testbench reference output file
        ########################################################
        msg0 = 'TesTopDataGen._run: Generate the testbench reference output file'
        display_obj.display_subtitle(msg_p=msg0, level_p=level0)

        output_filename = json_variant["model"]["value"]["output_filename"]
        output_filepath = str(Path(tb_input_base_path_p, output_filename))

        with open(output_filepath, 'w') as fid:
            # write header
            fid.write("expected_tes_out_int")
            fid.write(csv_separator)
            fid.write('pixel_id_uint')
            fid.write('\n')
            index_max = len(pts_list) - 1
            for index, obj_pt in enumerate(pts_list):

                tes_out = obj_pt.get_attribute(name_p="tes_out")
                pixel_id = obj_pt.get_attribute(name_p="pixel_id")

                fid.write(str(tes_out))
                fid.write(csv_separator)
                fid.write(str(pixel_id))
                if index != index_max:
                    fid.write('\n')

        msg0 = 'filepath= ' + output_filepath
        display_obj.display(msg_p=msg0, level_p=level1)

        # Generate the vhdl testbench input data file
        ########################################################
        msg0 = 'TesTopDataGen._run: Generate the testbench input data file'
        display_obj.display_subtitle(msg_p=msg0, level_p=level0)

        filename = json_variant["data"]["value"]["filename"]
        filepath = str(Path(tb_input_base_path, filename))

        with open(filepath, 'w') as fid:
            # write header
            fid.write("data")
            fid.write('\n')
            index_max = len(pts_list) - 1
            for index, obj_pt in enumerate(pts_list):
                fid.write(str(1))
                if index != index_max:
                    fid.write('\n')

        msg0 = 'filepath=' + filepath
        display_obj.display(msg_p=msg0, level_p=level1)

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
        test_variant_filepath = self.test_variant_filepath
        verbosity = self.verbosity

        output_path = output_path
        level0 = self.level
        level1 = level0 + 1

        str0 = "TesTopDataGen.pre_config"
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
        self._run(tb_input_base_path_p=tb_input_base_path, tb_output_base_path_p=tb_output_base_path)

        str0 = "TesTopDataGen.pre_config: Simulation transcript"
        display_obj.display_title(msg_p=str0, level_p=level0)

        str0 = ""
        display_obj.display(msg_p=str0, level_p=level0)

        # return True is mandatory for Vunit
        return True
