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
#    @file                   mux_squid_top_data_gen.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    N/A
# -------------------------------------------------------------------------------------------------------------
#    @details
#    This python script defines the AmpSquidTopDataGen class.
#    This class defines methods to generate data for the amp_squid_top test bench
#    
#    Note:
#       . This script is aware of the json configuration file
#       . This script was tested with python 3.10
# -------------------------------------------------------------------------------------------------------------

# standard library
import json
import os
import shutil
import copy
from pathlib import Path,PurePosixPath

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
from .vunit_core import VunitUtils


class AmpSquidTopDataGen(VunitUtils):
    """
        This class defines methods to generate data for the VHDL amp_squid_top testbench file.
        Note:
            Method name starting by '_' are local to the class (ex:def _toto(...)).
            It should not be usually used by the user
    """

    def __init__(self):
        """
        This method initializes the class instance
        """
        # display object
        self.display_obj = Display()
        super().__init__(self.display_obj)

        # path to the configuration file
        self.test_variant_filepath = None
        # JSON object as a dictionary
        self.json_variant = None
        # instance of the VunitConf class
        #  => use its method to retrieve filepath
        self.vunit_conf_obj = None
        # separator of the *.csv file
        self.csv_separator = ';'

    def set_test_variant_filepath(self,filepath_p):
        """
        This method set the json test_variant filepath and get its dictionary
        :param filepath_p: (string) filepath
        :return: None
        """

        test_variant_filepath = filepath_p
        display_obj = self.display_obj
        level0 = self.level
        level1= level0 + 1

        msg0 = "AmpSquidTopDataGen.set_test_variant_filepath: Process Configuration File"
        display_obj.display_title(msg_p=msg0,level_p=level0)

        msg0 = 'test_variant_filepath='+test_variant_filepath
        display_obj.display(msg_p=msg0,level_p=level1)

        ################################################
        # Extract data from the configuration json file
        ################################################
        # Opening JSON file
        fid_in = open(test_variant_filepath, 'r')

        # returns JSON object as
        # a dictionary
        json_variant = json.load(fid_in)

        # Closing file
        fid_in.close()
        # save the json dictionary
        self.json_variant = json_variant
        # save the configuration filepath
        self.test_variant_filepath = test_variant_filepath
        return None

    def set_vunit_conf_obj(self,obj_p):
        """
        This method set the VunitConf instance
        :param obj_p: (VunitConf instance) instance of the VunitConf class
        :return: None
        """
        self.vunit_conf_obj = obj_p
        return None

    def get_generic_dic(self):
        """
        Get the testbench vhdl generic parameters
        Note: Vunit set the testbench vhdl generic parameters with a python
        dictionary where key name are the VHDL generic parameter names
        :return: (dictionary)
        """
        json_variant = self.json_variant

        nb_pixel_by_frame = json_variant['data']['value']['nb_pixel_by_frame']

        ram1_check = json_variant['ram1']['generic']['check']
        ram1_verbosity = json_variant['ram1']['generic']['verbosity']

        fpagain = json_variant['register']['value']['fpagain']


        dic = {}
        dic['g_NB_PIXEL_BY_FRAME'] = int(nb_pixel_by_frame)
        dic['g_RAM1_CHECK'] = bool(ram1_check)
        dic['g_RAM1_VERBOSITY'] = ram1_verbosity
        dic['g_FPAGAIN'] = fpagain

        return dic

    def _run(self, tb_input_base_path_p, tb_output_base_path_p):
        """
        This method generates output files for the testbench
        :param tb_input_base_path_p: (string) base path of the testbench VHDL input files
        :param tb_output_base_path_p: (string) base path of the testbench VHDL output files
        :return: None
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
        vunit_conf_obj = self.vunit_conf_obj
        csv_separator = self.csv_separator

        ########################################################
        # Generate the testbench input valid sequence files
        ########################################################
        msg0 = 'AmpSquidTopDataGen._run: Generate the testbench input valid sequence files'
        display_obj.display_subtitle(msg_p=msg0,level_p=level0)

        dic_sequence = []
        dic_sequence.append(json_variant["data"]["sequence"])
        dic_sequence.append(json_variant["ram1"]["sequence"])

        for dic in dic_sequence:
            filename = dic["filename"]
            filepath   = str(Path(tb_input_base_path,filename).resolve())

            ctrl       = dic["ctrl"]
            min_value1 = dic["min_value1"]
            max_value1 = dic["max_value1"]
            min_value2 = dic["min_value2"]
            max_value2 = dic["max_value2"]
            max_value2 = dic["max_value2"]
            time_shift = dic["time_shift"]

            seq = ValidSequencer(name_p = filename)
            seq.set_verbosity(verbosity_p=verbosity)
            seq.set_sequence(ctrl_p=ctrl, 
                             min_value1_p=min_value1,
                             max_value1_p=max_value1,
                             min_value2_p=min_value2,
                             max_value2_p=max_value2,
                             time_shift_p=time_shift)
            seq.save(filepath_p=filepath,csv_separator_p=csv_separator)

            msg0 = 'filepath='+filepath
            display_obj.display(msg_p=msg0,level_p=level1)

        ########################################################
        # Copy the testbench input RAM configuration files
        ########################################################
        vunit_conf_obj = self.vunit_conf_obj
        msg0 = 'AmpSquidTopDataGen._run: Copy the testbench input RAM configuration files'
        display_obj.display_subtitle(msg_p=msg0,level_p=level0)

        dic_sequence = []
        dic_sequence.append(json_variant["ram1"])

        ram_filepath_dic = {}

        for dic in dic_sequence:
            input_filename  = dic["value"]['input_filename']
            output_filename = dic["value"]['output_filename']
            name            = dic["generic"]['name']
            output_filepath = str(Path(tb_input_base_path,output_filename)) 
            input_filepath  = vunit_conf_obj.get_data_filepath(filename_p=input_filename,level_p=level1)

            msg0 = 'from: ' + input_filepath
            display_obj.display(msg_p=msg0,level_p=level2)
            msg0 = 'to: ' + output_filepath
            display_obj.display(msg_p=msg0,level_p=level2)

            shutil.copyfile(input_filepath,output_filepath)

            # save the ram content
            ram_filepath_dic[name] = output_filepath


        ########################################################
        # Get the testbench parameters
        ########################################################
        msg0 = 'AmpSquidTopDataGen._run: Get the testbench parameters'
        display_obj.display_subtitle(msg_p=msg0,level_p=level0)

        nb_sample_by_pixel = json_variant["data"]["value"]["nb_sample_by_pixel"]
        nb_pixel_by_frame  = json_variant["data"]["value"]["nb_pixel_by_frame"]
        nb_frame_by_pulse  = json_variant["data"]["value"]["nb_frame_by_pulse"]
        nb_pulse           = json_variant["data"]["value"]["nb_pulse"]

        # mux_squid_out
        mux_squid_dic          = json_variant["data"]["value"]["pixel_result"]
        mux_squid_out_mode     = mux_squid_dic["mode"]
        mux_squid_out_min_val  = mux_squid_dic["min_value"]
        mux_squid_out_max_val  = mux_squid_dic["max_value"]

        # amp_squid_offset_correction
        adc_amp_squid_offset_correction_dic      = json_variant["data"]["value"]["amp_squid_offset_correction"]
        adc_amp_squid_offset_correction_mode     = adc_amp_squid_offset_correction_dic["mode"]
        adc_amp_squid_offset_correction_min_val  = adc_amp_squid_offset_correction_dic["min_value"]
        adc_amp_squid_offset_correction_max_val  = adc_amp_squid_offset_correction_dic["max_value"]

        fpasim_gain = json_variant["register"]["value"]["fpagain"]

        amp_squid_tf_name = json_variant["ram1"]["generic"]["name"]
        amp_squid_tf_filepath = ram_filepath_dic[amp_squid_tf_name]

        ########################################################
        # Compute the testbench reference output values
        ########################################################
        msg0 = 'AmpSquidTopDataGen._run: compute the testbench reference output values'
        display_obj.display_subtitle(msg_p=msg0,level_p=level0)


        # adc: compute parameters
        ########################################################
        nb_sample_by_frame = nb_pixel_by_frame * nb_sample_by_pixel
        nb_pts     = nb_pixel_by_frame * nb_frame_by_pulse * nb_pulse
        oversample = nb_sample_by_pixel 


        # generate data
        ########################################################
        # adc
        obj_gen = Generator(nb_pts_p=nb_pts)
        pts_list = obj_gen.run()    

        obj_attr = Attribute(pts_list_p=pts_list)
        obj_attr.set_random_seed(value_p=10)
        obj_attr.set_attribute(name_p="mux_squid_out", mode_p=mux_squid_out_mode, min_value_p=mux_squid_out_min_val, max_value_p=mux_squid_out_max_val)
        pts_list = obj_attr.run()   

        obj_attr = Attribute(pts_list_p=pts_list)
        obj_attr.set_attribute(name_p="adc_amp_squid_offset_correction", mode_p=adc_amp_squid_offset_correction_mode, min_value_p=adc_amp_squid_offset_correction_min_val, max_value_p=adc_amp_squid_offset_correction_max_val)
        pts_list = obj_attr.run()   

        obj_over = OverSample(pts_list_p=pts_list)
        obj_over.set_oversampling(value_p=oversample)
        pts_list = obj_over.run()   

        # tes
        obj_sign = TesSignalling(pts_list_p=pts_list)
        obj_sign.set_conf(nb_pixel_by_frame_p=nb_pixel_by_frame, nb_sample_by_pixel_p=nb_sample_by_pixel, nb_sample_by_frame_p=nb_sample_by_frame, nb_frame_by_pulse_p=nb_frame_by_pulse)
        pts_list = obj_sign.run()   

        # obj_tes = TesTop(pts_list_p=pts_list)
        # obj_tes.set_ram_tes_pulse_shape(filepath_p=tes_pulse_shape_filepath)
        # obj_tes.set_ram_tes_steady_state(filepath_p=tes_std_state_filepath)
        # obj_tes.add_command(pixel_id_p=cmd_pixel_id, time_shift_p=cmd_time_shift, pulse_heigth_p=cmd_pulse_heigth,skip_nb_samples_p=skip_nb_samples)
        # pts_list = obj_tes.run(output_attribute_name_p="mux_squid_out") 

        # mux_squid
        # obj_mux = MuxSquidTop(pts_list_p=pts_list)
        # obj_mux.set_ram_mux_squid_offset(filepath_p=mux_squid_offset_filepath)
        # obj_mux.set_ram_mux_squid_tf(filepath_p=mux_squid_tf_filepath)
        # obj_mux.set_register(inter_squid_gain_p=inter_squid_gain)
        # pts_list = obj_mux.run(output_attribute_name_p="mux_squid_out")   

        # amp_squid
        obj_amp = AmpSquidTop(pts_list_p=pts_list)
        obj_amp.set_ram_amp_squid_tf(filepath_p=amp_squid_tf_filepath)
        obj_amp.set_fpasim_gain(fpasim_gain_p=fpasim_gain)
        pts_list = obj_amp.run(output_attribute_name_p="amp_squid_out")


        ########################################################
        # Generate the testbench reference output file
        ########################################################
        msg0 = 'AmpSquidTopDataGen._run: Generate the testbench reference output file'
        display_obj.display_subtitle(msg_p=msg0,level_p=level0)

        output_filename = json_variant["model"]["value"]["output_filename"]
        output_filepath = str(Path(tb_input_base_path_p,output_filename))

        with open(output_filepath,'w') as fid:
            L = len(pts_list)
            index_max = L - 1
            for index,obj_pt in enumerate(pts_list):
                if index == 0:
                    # header
                    fid.write('amp_squid_out')
                    fid.write('\n')
                # get point attribute
                amp_squid_out  = obj_pt.get_attribute(name_p="amp_squid_out")

                fid.write(str(amp_squid_out))
                if index != index_max:
                    fid.write('\n')

        msg0 = 'filepath= '+output_filepath
        display_obj.display(msg_p=msg0,level_p=level1)

        ########################################################
        # Generate the testbench input data file
        ########################################################
        msg0 = 'AmpSquidTopDataGen._run: Generate the testbench input data file'
        display_obj.display_subtitle(msg_p=msg0,level_p=level0)

        filename = json_variant["data"]["value"]["filename"]
        filepath = str(Path(tb_input_base_path,filename))
        with open(filepath,'w') as fid:
            L = len(pts_list)
            index_max = L - 1
            for index,obj_pt in enumerate(pts_list):
                if index == 0:
                    # header
                    fid.write('pixel_sof')
                    fid.write(csv_separator)
                    fid.write('pixel_eof')
                    fid.write(csv_separator)
                    fid.write('pixel_id')
                    fid.write(csv_separator)
                    fid.write('mux_squid_out')
                    fid.write(csv_separator)
                    fid.write('frame_sof')
                    fid.write(csv_separator)
                    fid.write('frame_eof')
                    fid.write(csv_separator)
                    fid.write('frame_id')
                    fid.write(csv_separator)
                    fid.write('adc_amp_squid_offset_correction')
                    fid.write('\n')
                # get point attributes
                pixel_sof = obj_pt.get_attribute(name_p="pixel_sof")
                pixel_eof = obj_pt.get_attribute(name_p="pixel_eof")
                pixel_id = obj_pt.get_attribute(name_p="pixel_id")
                mux_squid_out  = obj_pt.get_attribute(name_p="mux_squid_out")
                frame_sof  = obj_pt.get_attribute(name_p="frame_sof")
                frame_eof  = obj_pt.get_attribute(name_p="frame_eof")
                frame_id  = obj_pt.get_attribute(name_p="frame_id")
                adc_amp_squid_offset_correction  = obj_pt.get_attribute(name_p="adc_amp_squid_offset_correction")

                fid.write(str(pixel_sof))
                fid.write(csv_separator)
                fid.write(str(pixel_eof))
                fid.write(csv_separator)
                fid.write(str(pixel_id))
                fid.write(csv_separator)
                fid.write(str(mux_squid_out))
                fid.write(csv_separator)
                fid.write(str(frame_sof))
                fid.write(csv_separator)
                fid.write(str(frame_eof))
                fid.write(csv_separator)
                fid.write(str(frame_id))
                fid.write(csv_separator)
                fid.write(str(adc_amp_squid_offset_correction))
                if index != index_max:
                    fid.write('\n')

        msg0 = 'filepath='+filepath
        display_obj.display(msg_p=msg0,level_p=level1)



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
        test_variant_filepath = self.test_variant_filepath
        verbosity     = self.verbosity

        output_path = output_path
        level0      = self.level
        level1      = level0 + 1

        str0 = "AmpSquidTopDataGen.pre_config"
        display_obj.display_title(msg_p=str0, level_p=level0)

        ###############################
        #create directories (if not exist) for the VHDL testbench
        # .input directory  for the input data/command files
        # .output directory for the output data files
        tb_input_base_path = str(Path(output_path,'inputs').resolve())
        tb_output_base_path = str(Path(output_path,'outputs').resolve())
        self.create_directory(path_p=tb_input_base_path,level_p = level1)
        self.create_directory(path_p=tb_output_base_path,level_p =level1)

        # copy the mif files into the Vunit simulation directory
        if self.filepath_list_mif is not None:
            self.copy_mif_files(output_path_p=output_path, level_p=level1)

        ##########################################################
        # generate files
        ##########################################################    
        self._run(tb_input_base_path_p=tb_input_base_path, tb_output_base_path_p=tb_output_base_path)

        str0 = "AmpSquidTopDataGen.pre_config: Simulation transcript"
        display_obj.display_title(msg_p=str0, level_p=level0)

        str0 = ""
        display_obj.display(msg_p=str0, level_p=level0)

        # return True is mandatory for Vunit
        return True