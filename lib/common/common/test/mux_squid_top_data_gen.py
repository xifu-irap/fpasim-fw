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
#    This python script defines the MuxSquidTopDataGen class.
#    This class defines methods to generate data for the mux_squid_top test bench
#    
#    Note:
#       . This script is aware of the json configuration file
#       . This script was tested with python 3.10
# -------------------------------------------------------------------------------------------------------------

# standard library

from common import Display
from common import ValidSequencer
from common import TesSignallingModel
from common import MuxSquidModel
from pathlib import Path,PurePosixPath
import json
import os
import shutil
import random
import copy
import shutil


class MuxSquidTopDataGen:
    """
        This class defines methods to generate data for the VHDL mux_squid_top testbench file.
        Note:
            Method name starting by '_' are local to the class (ex:def _toto(...)).
            It should not be usually used by the user
    """

    def __init__(self):
        """
        This method initializes the class instance
        """
        # path to the configuration file
        self.test_variant_filepath = None
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

    def set_test_variant_filepath(self,filepath_p):
        """
        This method set the json test_variant filepath and get its dictionary
        :param filepath_p: (string) test_variant filepath
        :return: None
        """

        test_variant_filepath = filepath_p
        display_obj = self.display_obj
        level0 = self.level
        level1= level0 + 1

        msg0 = "MuxSquidTopDataGen.set_test_variant_filepath: Process Configuration File"
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
        json_data = json.load(fid_in)

        # Closing file
        fid_in.close()
        # save the json dictionary
        self.json_data = json_data
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

        nb_pixel_by_frame = json_data['data']['value']['nb_pixel_by_frame']

        ram1_check = json_data['ram1']['generic']['check']
        ram1_verbosity = json_data['ram1']['generic']['verbosity']

        ram2_check = json_data['ram2']['generic']['check']
        ram2_verbosity = json_data['ram2']['generic']['verbosity']

        inter_squid_gain  = json_data["register"]["value"]["inter_squid_gain"]

        dic = {}
        dic['g_INTER_SQUID_GAIN'] = int(inter_squid_gain)
        dic['g_NB_PIXEL_BY_FRAME'] = int(nb_pixel_by_frame)
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
        test_variant_filepath = self.test_variant_filepath
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
        msg0 = 'MuxSquidTopDataGen._run: Generate sequence files'
        display_obj.display_subtitle(msg_p=msg0,level_p=level0)

        dic_sequence = []
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
        # process data
        ####################################################
        msg0 = 'MuxSquidTopDataGen._run: Generate data file'
        display_obj.display_subtitle(msg_p=msg0,level_p=level0)

        filename           = json_data["data"]["value"]["filename"]
        nb_sample_by_pixel = json_data["data"]["value"]["nb_sample_by_pixel"]
        nb_pixel_by_frame  = json_data["data"]["value"]["nb_pixel_by_frame"]
        nb_frame_by_pulse  = json_data["data"]["value"]["nb_frame_by_pulse"]
        nb_pulse           = json_data["data"]["value"]["nb_pulse"]
        # mux_squid
        mux_squid           = json_data["data"]["value"]["mux_squid"]
        mux_squid_mode     = mux_squid["mode"]
        mux_squid_min_val     = mux_squid["min_value"]
        mux_squid_max_val     = mux_squid["max_value"]

        # pixel_result
        pixel_result           = json_data["data"]["value"]["pixel_result"]
        pixel_result_mode     = pixel_result["mode"]
        pixel_result_min_val     = pixel_result["min_value"]
        pixel_result_max_val     = pixel_result["max_value"]

        filepath = str(Path(tb_input_base_path,filename))
        obj = TesSignallingModel()
        obj.set_conf(nb_sample_by_pixel_p=nb_sample_by_pixel, nb_pixel_by_frame_p=nb_pixel_by_frame, nb_frame_by_pulse_p=nb_frame_by_pulse, nb_pulse_p=nb_pulse)
        pixel_sof_list,pixel_eof_list,pixel_id_list,frame_sof_list,frame_eof_list,frame_id_list = obj.get_data()
        

        def gen_seq(mode_p,min_value_p,max_value_p):
            mode = mode_p
            min_value = min_value_p
            max_value = max_value_p

            if mode == 0:
                return list(range(min_value,max_value+1))
            elif mode == 1:
                tmp = []
                for i in range(min_value,max_value+1):
                    tmp.append(random.randint(min_value,max_value))
                return tmp

        def gen_pixel(data_list_p,nb_pixel_p):
            data_list = data_list_p
            nb_pixel = nb_pixel_p
            tmp = []
            L = len(data_list)
            cnt = 1
            for i in range(nb_pixel):
                for data in data_list:
                    tmp.append(data)
                    if cnt == nb_pixel:
                        break;
                    else:
                        cnt += 1
            return tmp

        def oversample(data_list_p,oversample_p):
            res = []

            for data in data_list_p:
                for i in range(oversample_p):
                    res.append(data)
            return res
        # create a sequence of pixel
        mux_squid_seq_list    = gen_seq(mode_p=mux_squid_mode,min_value_p=mux_squid_min_val,max_value_p=mux_squid_max_val)
        pixel_result_seq_list = gen_seq(mode_p=pixel_result_mode,min_value_p=pixel_result_min_val,max_value_p=pixel_result_max_val)

        # duplicate the seq_list until the number of element is equal to nb_pixel
        nb_pixel = nb_pixel_by_frame * nb_frame_by_pulse * nb_pulse
        mux_squid_list = gen_pixel(data_list_p=mux_squid_seq_list,nb_pixel_p=nb_pixel)
        pixel_result_list = gen_pixel(data_list_p=pixel_result_seq_list,nb_pixel_p=nb_pixel)

        # oversample each sample
        mux_squid_oversample_list    = oversample(data_list_p=mux_squid_list,oversample_p=nb_sample_by_pixel)
        pixel_result_oversample_list = oversample(data_list_p=pixel_result_list,oversample_p=nb_sample_by_pixel)

        fid = open(filepath,'w')
        # header
        fid.write('pixel_sof')
        fid.write(csv_separator)
        fid.write('pixel_eof')
        fid.write(csv_separator)
        fid.write('pixel_id')
        fid.write(csv_separator)
        fid.write('pixel_result')
        fid.write(csv_separator)
        fid.write('frame_sof')
        fid.write(csv_separator)
        fid.write('frame_eof')
        fid.write(csv_separator)
        fid.write('frame_id')
        fid.write(csv_separator)
        fid.write('mux_squid')
        fid.write('\n')

        L = len(pixel_sof_list)
        index_max = L - 1
        for i in range(L):
            pixel_sof = pixel_sof_list[i]
            pixel_eof = pixel_eof_list[i]
            pixel_id = pixel_id_list[i]
            pixel_result = pixel_result_oversample_list[i]
            frame_sof = frame_sof_list[i]
            frame_eof = frame_eof_list[i]
            frame_id = frame_id_list[i]
            mux_squid = mux_squid_oversample_list[i]
            # header
            fid.write(str(pixel_sof))
            fid.write(csv_separator)
            fid.write(str(pixel_eof))
            fid.write(csv_separator)
            fid.write(str(pixel_id))
            fid.write(csv_separator)
            fid.write(str(pixel_result))
            fid.write(csv_separator)
            fid.write(str(frame_sof))
            fid.write(csv_separator)
            fid.write(str(frame_eof))
            fid.write(csv_separator)
            fid.write(str(frame_id))
            fid.write(csv_separator)
            fid.write(str(mux_squid))

            if i != index_max:
                fid.write('\n')

        ####################################################
        # copy file
        ####################################################
        vunit_conf_obj = self.vunit_conf_obj
        msg0 = 'MuxSquidTopDataGen._run: copy ram files'
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
        mux_squid_offset_name = json_data["ram1"]["generic"]["name"]
        mux_squid_tf_name = json_data["ram2"]["generic"]["name"]
        inter_squid_gain  = int(json_data["register"]["value"]["inter_squid_gain"])
        obj = MuxSquidModel()
        obj.set_ram_mux_squid_offset(data_list_p=dic_ram_content_tmp[mux_squid_offset_name])
        obj.set_ram_mux_squid_tf(data_list_p=dic_ram_content_tmp[mux_squid_tf_name])
        obj.set_pixel_id(data_list_p=pixel_id_list)
        obj.set_data(data_list_p=pixel_result_oversample_list)
        obj.set_mux_squid_feedback(data_list_p=mux_squid_oversample_list)
        obj.set_register(inter_squid_gain_p=inter_squid_gain)
        obj.run()

        result_list = obj.get_result()

        output_filename = json_data["model"]["value"]["output_filename"]
        output_filepath = str(Path(tb_input_base_path_p,output_filename))
        fid = open(output_filepath,'w')
        # write header
        fid.write("expected_output_int")
        fid.write('\n')
        L = len(result_list)
        index_max = L - 1
        for index in range(L):
            result = result_list[index]
            fid.write(str(result))
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
        msg0 =  "[mux_squid_top_data_gen._copy_mif_files]: Copy the IP init files into the Vunit output simulation directory"
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
        test_variant_filepath = self.test_variant_filepath
        verbosity     = self.verbosity

        output_path = output_path
        level0      = self.level
        level1      = level0 + 1

        str0 = "MuxSquidTopDataGen.pre_config"
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

        str0 = "MuxSquidTopDataGen.pre_config: Simulation transcript"
        display_obj.display_title(msg_p=str0, level_p=level0)

        str0 = ""
        display_obj.display(msg_p=str0, level_p=level0)

        # return True is mandatory for Vunit
        return True