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
#    This python script defines the TesTopDataGen class.
#    This class defines methods to generate data for the tes_top test bench
#    
#    Note:
#       . This script is aware of the json configuration file
#       . This script was tested with python 3.10
# -------------------------------------------------------------------------------------------------------------

# standard library

from common import Display
from common import ValidSequencer
from pathlib import Path,PurePosixPath
from common import TesSignallingModel
from common import TesModel
import json
import os
import shutil
import random
import copy
import shutil


class TesTopDataGen:
    """
        This class defines methods to generate data for the VHDL tes_top testbench file.
        Note:
            Method name starting by '_' are local to the class (ex:def _toto(...)).
            It should not be usually used by the user
    """

    def __init__(self):
        """
        This method initializes the class instance
        """
        # path to the configuration file
        self.conf_filepath = None
        # display object
        self.display_obj = Display()
        # set indentation level (integer >=0)
        self.level = 0
        # set the level of verbosity
        self.verbosity = 0
        # path to the Xilinx mif files (for Xilinx RAM, ...)
        self.filepath_list_mif = None
        # JSON object as a dictionary
        self.json_data = None
        # instance of the VunitConf class
        #  => use its method to retrieve filepath
        self.vunit_conf_obj = None

    def set_conf_filepath(self,conf_filepath_p):
        """
        This method set the json configuration filepath and get its dictionary
        :param conf_filepath_p: (string) configuration filepath
        :return: None
        """

        conf_filepath = conf_filepath_p
        display_obj = self.display_obj
        level0 = self.level
        level1= level0 + 1

        msg0 = "TesTopDataGen._get_json_content: Process Configuration File"
        display_obj.display_title(msg_p=msg0,level_p=level0)

        msg0 = 'conf_filepath='+conf_filepath
        display_obj.display(msg_p=msg0,level_p=level1)

        ################################################
        # Extract data from the configuration json file
        ################################################
        # Opening JSON file
        fid_in = open(conf_filepath, 'r')

        # returns JSON object as
        # a dictionary
        json_data = json.load(fid_in)

        # Closing file
        fid_in.close()
        # save the json dictionary
        self.json_data = json_data
        # save the configuration filepath
        self.conf_filepath = conf_filepath
        return None

    def set_vunit_conf_obj(self,obj_p):
        """
        This method set the VunitConf instance
        :param obj_p: (VunitConf instance) instance of the VunitConf class
        :return: None
        """
        self.vunit_conf_obj = obj_p
        return None

    def set_indentation_level(self, level_p):
        """
        This method set the indentation level of the print message
        :param level_p: (integer >= 0) define the level of indentation of the message to print
        :return: None
        """
        self.level = level_p
        return None

    def set_verbosity(self, verbosity_p):
        """
        Set the level of verbosity
        :param verbosity_p: (integer >=0) level of verbosity
        :return: None
        """
        self.verbosity = verbosity_p
        return None

    def get_generic_dic(self):
        """
        Get the testbench vhdl generic parameters
        Note: Vunit set the testbench vhdl generic parameters with a python
        dictionary where key name are the VHDL generic parameter names
        :return: (dictionary)
        """
        json_data = self.json_data

        nb_pixel_by_frame = json_data['register']['value']['nb_pixel_by_frame']
        nb_frame_by_pulse = json_data['register']['value']['nb_frame_by_pulse']

        ram1_check = json_data['ram1']['generic']['check']
        ram1_verbosity = json_data['ram1']['generic']['verbosity']

        ram2_check = json_data['ram2']['generic']['check']
        ram2_verbosity = json_data['ram2']['generic']['verbosity']

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
        This method generates output files for the testbench
        :param tb_input_base_path_p: (string) base path of the testbench VHDL input files
        :param tb_output_base_path_p: (string) base path of the testbench VHDL output files
        :return: None
        """
        tb_input_base_path = tb_input_base_path_p
        tb_output_base_path = tb_output_base_path_p
        conf_filepath = self.conf_filepath
        display_obj = self.display_obj
        level0 = self.level
        level1 = level0 + 1
        level2 = level0 + 2
        verbosity = self.verbosity
        json_data = self.json_data
        vunit_conf_obj = self.vunit_conf_obj

       

        ################################################
        # process valid sequences
        ################################################
        csv_separator = ';'
        msg0 = 'TesTopDataGen._run: Generate sequence files'
        display_obj.display_subtitle(msg_p=msg0,level_p=level0)

        dic_sequence = []
        dic_sequence.append(json_data["register"]["sequence"])
        dic_sequence.append(json_data["cmd"]["sequence"])
        dic_sequence.append(json_data["data"]["sequence"])
        dic_sequence.append(json_data["ram1"]["sequence"])
        dic_sequence.append(json_data["ram2"]["sequence"])

        for dic in dic_sequence:
            filename = dic["filename"]
            filepath   = str(Path(tb_input_base_path,filename).resolve())

            ctrl       = dic["ctrl"]
            min_value1 = dic["min_value1"]
            max_value1 = dic["max_value1"]
            min_value2 = dic["min_value2"]
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

        ####################################################
        # process register
        ####################################################
        msg0 = 'TesTopDataGen._run: Generate register file'
        display_obj.display_subtitle(msg_p=msg0,level_p=level0)

        filename           = json_data["register"]["value"]["filename"]
        en                 = json_data["register"]["value"]["en"]
        nb_sample_by_pixel = json_data["register"]["value"]["nb_sample_by_pixel"]
        nb_pixel_by_frame  = json_data["register"]["value"]["nb_pixel_by_frame"]
        nb_frame_by_pulse  = json_data["register"]["value"]["nb_frame_by_pulse"]
        nb_pulse           = json_data["register"]["value"]["nb_pulse"]

        # compute the number total of data to generate
        nb_total_samples = nb_sample_by_pixel * nb_pixel_by_frame * nb_frame_by_pulse * nb_pulse

        # compute fpga values start from 0
        nb_sample_by_pixel_tmp = nb_sample_by_pixel - 1
        nb_pixel_by_frame_tmp  = nb_pixel_by_frame - 1
        nb_frame_by_pulse_tmp  = nb_frame_by_pulse - 1
        # nb_pulse           = nb_pulse_tmp
        # auto-compute the VDHL expected nb_samples_by_frame value (start from 0)
        nb_samples_by_frame_tmp = nb_sample_by_pixel * nb_pixel_by_frame - 1


        filepath     = str(Path(tb_input_base_path,filename))
        fid = open(filepath,'w')
        # header
        fid.write('en_uint1_t')
        fid.write(csv_separator)
        fid.write('nb_samples_by_pixel_uint')
        fid.write(csv_separator)
        fid.write('nb_pixel_by_frame_uint')
        fid.write(csv_separator)
        fid.write('nb_samples_by_frame_uint')
        fid.write('\n')
        fid.write(str(en))
        fid.write(csv_separator)
        fid.write(str(nb_sample_by_pixel_tmp))
        fid.write(csv_separator)
        fid.write(str(nb_pixel_by_frame_tmp))
        fid.write(csv_separator)
        fid.write(str(nb_samples_by_frame_tmp))

        msg0 = 'filepath='+filepath
        display_obj.display(msg_p=msg0,level_p=level1)

        ####################################################
        # process data
        ####################################################
        msg0 = 'TesTopDataGen._run: Generate data file'

        display_obj.display_subtitle(msg_p=msg0,level_p=level0)

        filename = json_data["data"]["value"]["filename"]
        filepath = str(Path(tb_input_base_path,filename))
        fid = open(filepath,'w')
        # header
        fid.write('data')
        fid.write('\n')
        index_max = nb_total_samples - 1
        for i in range(nb_total_samples):
            fid.write(str(1))
            if i != index_max:
                fid.write('\n')

        msg0 = 'filepath='+filepath
        display_obj.display(msg_p=msg0,level_p=level1)


        ####################################################
        # process cmd
        ####################################################
        msg0 = 'TesTopDataGen._run: Generate cmd file'
        display_obj.display_subtitle(msg_p=msg0,level_p=level0)

        filename           = json_data["cmd"]["value"]["filename"]
        cmd_pulse_height_list  = json_data["cmd"]["value"]["pulse_height_list"]
        cmd_pixel_id_list      = json_data["cmd"]["value"]["pixel_id_list"]
        cmd_time_shift_list    = json_data["cmd"]["value"]["time_shift_list"]

        filepath     = str(Path(tb_input_base_path,filename))
        fid = open(filepath,'w')
        # header
        fid.write('pulse_height')
        fid.write(csv_separator)
        fid.write('pixel_id')
        fid.write(csv_separator)
        fid.write('time_shift')
        fid.write('\n')
        index_max = len(cmd_pulse_height_list) - 1
        index = 0
        for pulse_height, pixel_id, time_shift in zip(cmd_pulse_height_list,cmd_pixel_id_list,cmd_time_shift_list):
            fid.write(str(pulse_height))
            fid.write(csv_separator)
            fid.write(str(pixel_id))
            fid.write(csv_separator)
            fid.write(str(time_shift))
            if index != index_max:
                fid.write('\n')

            index += 1

        msg0 = 'filepath='+filepath
        display_obj.display(msg_p=msg0,level_p=level1)

        ####################################################
        # copy file
        ####################################################
        vunit_conf_obj = self.vunit_conf_obj
        msg0 = 'TesTopDataGen._run: copy ram files'
        display_obj.display_subtitle(msg_p=msg0,level_p=level0)

        dic_sequence = []
        dic_sequence.append(json_data["ram1"])
        dic_sequence.append(json_data["ram2"])

        dic_ram_content_tmp = {}

        for dic in dic_sequence:
            input_filename = dic["value"]['input_filename']
            output_filename = dic["value"]['output_filename']
            name            = dic["generic"]['name']
            output_filepath = str(Path(tb_input_base_path,output_filename)) 
            input_filepath = vunit_conf_obj.get_data_filepath(filename_p=input_filename,level_p=level1)

            msg0 = 'input_filepath=' + input_filepath
            display_obj.display(msg_p=msg0,level_p=level2)
            msg0 = 'output_filepath=' + output_filepath
            display_obj.display(msg_p=msg0,level_p=level2)

            shutil.copyfile(input_filepath,output_filepath)

            #####################################################
            # extract the ram contents in order to compute the expected value 
            # we assume the data are string representation of integer value
            #####################################################
            data_list = []
            fid_tmp = open(input_filepath,'r')
            lines = fid_tmp.readlines()
            fid_tmp.close()

            L = len(lines)

            for i in range(L):
                line = lines[i]
                str_addr,str_data = line.split(csv_separator)
                # skip the header
                if i != 0:
                    data_list.append(int(str_data)) 

            # save the ram content
            dic_ram_content_tmp[name] = data_list


        #########################################################
        # compute the expected output
        #########################################################
        obj = TesSignallingModel()
        obj.set_conf(nb_sample_by_pixel_p=nb_sample_by_pixel, nb_pixel_by_frame_p=nb_pixel_by_frame, nb_frame_by_pulse_p=nb_frame_by_pulse, nb_pulse_p=nb_pulse)
        pixel_sof_list,pixel_eof_list,pixel_id_list,frame_sof_list,frame_eof_list,frame_id_list = obj.get_data()

        tes_pulse_shape_name = json_data["ram1"]["generic"]["name"]
        tes_steady_state_name = json_data["ram2"]["generic"]["name"]
        obj = TesModel()
        obj.set_ram_tes_pulse_shape(data_list_p=dic_ram_content_tmp[tes_pulse_shape_name])
        obj.set_ram_tes_steady_state(data_list_p=dic_ram_content_tmp[tes_steady_state_name])
        obj.set_conf(nb_sample_by_pixel_p=nb_sample_by_pixel)
        obj.set_pixel_id(data_list_p=pixel_id_list)
        for pixel_id,time_shift,pulse_height in zip(cmd_pixel_id_list,cmd_time_shift_list,cmd_pulse_height_list):
            obj.add_command(pixel_id_p=pixel_id,time_shift_p=time_shift,pulse_heigth_p=pulse_height)
        obj.run()

        result_list = obj.get_result()

        output_filename = json_data["model"]["value"]["output_filename"]
        output_filepath = str(Path(tb_input_base_path_p,output_filename))
        fid = open(output_filepath,'w')
        # write header
        fid.write("expected_output_int")
        fid.write(csv_separator)
        fid.write('pixel_id_uint')
        fid.write('\n')
        L = len(result_list)
        index_max = L - 1
        for index in range(L):
            result = result_list[index]
            pixel_id = pixel_id_list[index]
            fid.write(str(result))
            fid.write(csv_separator)
            fid.write(str(pixel_id))
            if index != index_max:
                fid.write('\n')

        fid.close()


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
        output_path = output_path_p
        level0   = self._get_indentation_level(level_p=level_p)
        level1 = level0 + 1

        # get absolute path
        script_path = Path(output_path).resolve()
        # move into the hierarchy : vunit_out/modelsim
        output_path = str(Path(script_path.parents[1],"modelsim"))

        # copy each files
        msg0 =  "[TesTopDataGen._copy_mif_files]: Copy the IP init files into the Vunit output simulation directory"
        display_obj.display(msg_p=msg0, level_p=level0, color_p='green')
        for filepath in self.filepath_list_mif:
            msg0 =  'Copy: ' + filepath + " to " + output_path
            display_obj.display(msg_p=msg0, level_p=level1, color_p='green')
            shutil.copy(filepath, output_path)

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
        verbosity     = self.verbosity

        output_path = output_path
        level0      = self.level
        level1      = level0 + 1

        str0 = "TesTopDataGen.pre_config"
        display_obj.display_title(msg_p=str0, level_p=level0)

        ###############################
        #create directories (if not exist) for the VHDL testbench
        # .input directory  for the input data/command files
        # .output directory for the output data files
        tb_input_base_path = str(Path(output_path,'inputs').resolve())
        tb_output_base_path = str(Path(output_path,'outputs').resolve())
        self._create_directory(path_p=tb_input_base_path,level_p = level1)
        self._create_directory(path_p=tb_output_base_path,level_p =level1)

        # copy the mif files into the Vunit simulation directory
        if self.filepath_list_mif is not None:
            self._copy_mif_files(output_path_p=output_path, level_p=level1)

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