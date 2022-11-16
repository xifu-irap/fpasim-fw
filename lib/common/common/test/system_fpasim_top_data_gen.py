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
#    This python script defines the SystemFpasimTopDataGen class.
#    This class defines methods to generate data for the system_fpasim_top dic_field bench
#    
#    Note:
#       . This script is aware of the json configuration file
#       . This script was tested with python 3.10
# -------------------------------------------------------------------------------------------------------------

# standard library

from common import Display
from common import ValidSequencer
from common import TesSignallingModel
from pathlib import Path,PurePosixPath
import json
import os
import shutil
import random
import copy




class SystemFpasimTopDataGen:
    """
        This class defines methods to generate data for the VHDL system_fpasim_top testbench file.
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

        msg0 = "SystemFpasimTopDataGen._get_json_content: Process Configuration File"
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

        #TODO

        # nb_pixel_by_frame = json_data['data']['value']['nb_pixel_by_frame']

        # ram1_check = json_data['ram1']['generic']['check']
        # ram1_verbosity = json_data['ram1']['generic']['verbosity']

        # ram2_check = json_data['ram2']['generic']['check']
        # ram2_verbosity = json_data['ram2']['generic']['verbosity']
        # opal_addr_pipe_in = json_data['RAM']['wr']['opal_kelly_addr']
        # opal_addr_pipe_out = json_data['RAM']['rd']['opal_kelly_addr']

        dic = {}
        # dic['g_NB_PIXEL_BY_FRAME'] = int(nb_pixel_by_frame)
        # dic['g_RAM1_CHECK'] = bool(ram1_check)
        # dic['g_RAM1_VERBOSITY'] = ram1_verbosity
        # dic['g_RAM2_CHECK'] = bool(ram2_check)
        # dic['g_OPAL_ADDR_PIPE_IN'] = int(opal_addr_pipe_in,16)
        # dic['g_OPAL_ADDR_PIPE_OUT'] = int(opal_addr_pipe_out,16)
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
        csv_separator = ";"
        data_width = 32 # number max of bit of a register


        seq_dic = json_data["sequence"]
        def_dic = json_data["def"]
        cmd_list = seq_dic["cmd_list"]

        output_tb_filename = seq_dic["output_tb_filename"]
        output_tb_filepath = str(Path(tb_input_base_path,output_tb_filename))

        msg0 = 'output_tb_filepath=' + output_tb_filepath
        display_obj.display(msg_p=msg0,level_p=level2)

        ############################################
        # write the header
        ###########################################
        fid = open(output_tb_filepath,'w')

        description_list = []
        description_list.append("pipe_in: opal_kelly_type=0")
        description_list.append("wire_in: opal_kelly_type=1")
        description_list.append("trig_in: opal_kelly_type=2")
        description_list.append("pipe_out: opal_kelly_type=10")
        description_list.append("wire_out: opal_kelly_type=11")
        description_list.append("trig_out: opal_kelly_type=12")
        description = ', '.join(description_list)

        fid.write("opal_kelly_tag")
        fid.write(csv_separator)
        fid.write("opal_kelly_addr_hex")
        fid.write(csv_separator)
        fid.write("data_hex(addr+data)")
        fid.write(csv_separator)
        fid.write("comment")
        fid.write("\n")

        ####################################################
        # RAM data Generation
        ####################################################
        vunit_conf_obj = self.vunit_conf_obj
        msg0 = 'SystemFpasimTopDataGen._run: ram data generation from files'
        display_obj.display_subtitle(msg_p=msg0,level_p=level0)

        # get Ram data from files
        ##################################################
        # tag_list = []
        # addr_list = []
        # data_list = []
        # cmt_list = []
        # for dic in ram_dic_sequence:
        #     name = dic['name']
        #     offset_addr = dic['offset_addr']
        #     input_filename = dic['input_filename']
        #     input_filepath = vunit_conf_obj.get_data_filepath(filename_p=input_filename,level_p=level1)

        #     msg0 = 'input_filepath=' + input_filepath
        #     display_obj.display(msg_p=msg0,level_p=level2)

        #     fid = open(input_filepath,'r')
        #     lines = fid.readlines()
        #     fid.close()
        #     # delete the header
        #     del lines[0]

        #     for line in lines:
        #         str_addr,str_value = line.split(csv_separator)
        #         str_addr = str_addr.replace('\n','')
        #         str_value = str_value.replace('\n','')

        #         # add the address offset
        #         addr = int(str_addr) + int(offset_addr,16)
        #         str_addr = '{0:04x}'.format(addr)
        #         str_data = '{0:04x}'.format(int(str_value))
        #         str_result = str_addr + str_data
              
        #         data_list.append(str_result)
        #         cmt_list.append(name)
        #         addr_list.append("80")
        #         tag_list.append("0")
        
        # L = len(data_list)

    
        # msg0 = '\nTotal data RAMS= ' + str(L)
        # display_obj.display(msg_p=msg0,level_p=level1)

        def get_type(usb_type_p,mode_p):
            result = 0
            if usb_type_p == 'pipe':
                if mode_p == 'wr':
                    result = 0
                else:
                    result =  10
            elif usb_type_p == 'wire':
                if mode_p == 'wr':
                    result =  1
                else:
                    result = 11
            elif usb_type_p == 'trig':
                if mode_p == 'wr':
                    result = 2
                else:
                    result = 22
            elif usb_type_p == 'nop':
                result = 9
            else: 
                result = -1

            return result


        def compute_reg_from_field(dic_usb_p,value_list_p):

            # work on a deep copy of the field in order to not modify the source dictionnary for further cmd processing
            dic_field = copy.deepcopy(dic_usb_p["field"])

            for item in value_list_p:
                field_name_tmp, str_new_value = item.split('=')
                # convert str to integer
                new_value = int(str_new_value)
                # test if the field exist
                dic_bit_field = dic_field.get(field_name_tmp)
                if dic_bit_field is None:
                    msg0 = 'SystemFpasimTopDataGen._run: ERROR: the field ' + str(field_name_tmp) + " doesn't exist ("+cmd+')'
                    display_obj.display(msg_p=msg0,level_p=level1,color_p='red')
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
                    max_value = 2**width - 1
                    if value > max_value:
                        msg0 = 'SystemFpasimTopDataGen._run: ERROR: the field ' + str(key) + " value is out of range ("+cmd+')'
                        display_obj.display(msg_p=msg0,level_p=level1,color_p='red')

                if width is not None:
                    # test if the field range is not bigger than the register width
                    reg_bit_pos_max = data_width - 1
                    bit_pos_max = bit_pos_min + (width - 1)

                    if bit_pos_max > reg_bit_pos_max:
                        msg0 = 'SystemFpasimTopDataGen._run: ERROR: the field ' + str(key) + " range is out of range ("+cmd+')'
                        display_obj.display(msg_p=msg0,level_p=level1,color_p='red')
                        msg0 = 'the field ' + str(key) + " ("+str(bit_pos_max)+','+str(bit_pos_min)+') > register width ('+str(reg_bit_pos_max)+',0)'
                        display_obj.display(msg_p=msg0,level_p=level2,color_p='red')

                result += (value << bit_pos_min)

            return result
            

        tag_list = []
        addr_list = []
        data_list = []
        cmt_list = []
        for cmd in cmd_list:
            print('cmd',cmd)

            cmd_name,mode,*value_list = cmd.split(';')

            key = '@'+cmd_name.lower()
            dic_usb = def_dic.get(key)
            if dic_usb is None:
                msg0 = 'SystemFpasimTopDataGen._run: ERROR: the ley ' + str(key) + " doesn't exist ("+cmd+')'
                display_obj.display(msg_p=msg0,level_p=level1,color_p='red')
                continue
     
            if key == "@nop":
                usb_type = dic_usb["usb_type"]
                str_tag = str(get_type(usb_type_p=usb_type,mode_p=mode))
                usb_addr = "FF"
                tag_list.append(str_tag)
                addr_list.append(usb_addr)
                cmt_list.append('"'+cmd+'"')

                result = compute_reg_from_field(dic_usb_p=dic_usb,value_list_p=value_list)
                str_result = '{0:08x}'.format(result)
                data_list.append(str_result)

            elif key == "@usb_ram":
                usb_type = dic_usb["usb_type"]
                dic_mode = dic_usb.get(mode)
                if dic_mode is None:
                    msg0 = 'SystemFpasimTopDataGen._run: ERROR: the mode ' + str(mode) + " doesn't exist ("+cmd+')'
                    display_obj.display(msg_p=msg0,level_p=level1,color_p='red')
                    continue

                str_tag = str(get_type(usb_type_p=usb_type,mode_p=mode))

                usb_addr = dic_mode["usb_addr"]
                usb_addr = '{0:02x}'.format(int(usb_addr,16))
                
                for value in value_list:
                    new_cmd = cmd_name+';'+mode+';'+value
                    dic_field = dic_usb["field"]
                    dic = dic_field[value]
                    name = dic['name']
                    offset_addr = dic['offset_addr']
                    input_filename = dic['input_filename']
                    input_filepath = vunit_conf_obj.get_data_filepath(filename_p=input_filename,level_p=level1) 

                    msg0 = 'input_filepath=' + input_filepath
                    display_obj.display(msg_p=msg0,level_p=level2)  

                    fid_tmp = open(input_filepath,'r')
                    lines = fid_tmp.readlines()
                    fid_tmp.close()
                    # delete the header
                    del lines[0]    

                    for line in lines:
                        str_addr,str_value = line.split(csv_separator)
                        str_addr = str_addr.replace('\n','')
                        str_value = str_value.replace('\n','')  

                        # add the address offset
                        addr = int(str_addr) + int(offset_addr,16)
                        str_addr = '{0:04x}'.format(addr)
                        str_data = '{0:04x}'.format(int(str_value))
                        str_result = str_addr + str_data
                      

                        data_list.append(str_result)
                        tag_list.append(str_tag)
                        addr_list.append(usb_addr)
                        cmt_list.append('"'+new_cmd+'"')
               
                
            else:
                # manage trig/wire
                
                usb_type = dic_usb["usb_type"]
                dic_mode = dic_usb.get(mode)
                if dic_mode is None:
                    msg0 = 'SystemFpasimTopDataGen._run: ERROR: the mode ' + str(mode) + " doesn't exist ("+cmd+')'
                    display_obj.display(msg_p=msg0,level_p=level1,color_p='red')
                    continue
                str_tag = str(get_type(usb_type_p=usb_type,mode_p=mode))
                usb_addr = dic_mode["usb_addr"]
                usb_addr = '{0:02x}'.format(int(usb_addr,16))
                tag_list.append(str_tag)
                addr_list.append(usb_addr)
                cmt_list.append('"'+cmd+'"')

                result = compute_reg_from_field(dic_usb_p=dic_usb,value_list_p=value_list)
      
                # # work on a deep copy of the field in order to not modify the source dictionnary for further cmd processing
                # dic_field = copy.deepcopy(dic_usb["field"])

                # for item in value_list:
                #     field_name_tmp, str_new_value = item.split('=')
                #     # convert str to integer
                #     new_value = int(str_new_value)
                #     # test if the field exist
                #     dic_bit_field = dic_field.get(field_name_tmp)
                #     if dic_bit_field is None:
                #         msg0 = 'SystemFpasimTopDataGen._run: ERROR: the field ' + str(field_name_tmp) + " doesn't exist ("+cmd+')'
                #         display_obj.display(msg_p=msg0,level_p=level1,color_p='red')
                #     else:
                #         # overwrite the value 
                #         # print('field_name_tmp',field_name_tmp)
                #         # print(dic_bit_field)
                #         dic_bit_field['value'] = new_value

                # # compute the register value
                # result = 0
                # for key in dic_field.keys():
                #     dic = dic_field[key]

                #     bit_pos_min = dic['bit_pos_min']
                #     width = dic['width']
                #     value = dic['value']
                #     # test the range of value
                #     max_value = 2**width - 1
                #     if value > max_value:
                #         msg0 = 'SystemFpasimTopDataGen._run: ERROR: the field ' + str(key) + " value is out of range ("+cmd+')'
                #         display_obj.display(msg_p=msg0,level_p=level1,color_p='red')

                #     # test if the field range is not bigger than the register width
                #     reg_bit_pos_max = data_width - 1
                #     bit_pos_max = bit_pos_min + width

                #     if bit_pos_max > reg_bit_pos_max:
                #         msg0 = 'SystemFpasimTopDataGen._run: ERROR: the field ' + str(key) + " range is out of range ("+cmd+')'
                #         display_obj.display(msg_p=msg0,level_p=level1,color_p='red')
                #         msg0 = 'the field ' + str(key) + " ("+str(bit_pos_max)+','+str(bit_pos_min)+') > register width ('+str(reg_bit_pos_max)+',0)'
                #         display_obj.display(msg_p=msg0,level_p=level2,color_p='red')

                #     result += (value << bit_pos_min)

                str_result = '{0:08x}'.format(result)
                data_list.append(str_result)

                        
        print('len(tag_list)',len(tag_list))
        print('len(addr_list)',len(addr_list))
        print('len(data_list)',len(data_list))
        print('len(cmt_list)',len(cmt_list))
                
        L = len(data_list)
        index_max = L - 1
        for i in range(L):
            str_tag = tag_list[i]
            str_addr = addr_list[i]
            str_data = data_list[i]
            str_cmt = cmt_list[i]
            fid.write(str_tag)
            fid.write(csv_separator)
            fid.write(str_addr)
            fid.write(csv_separator)
            fid.write(str_data)
            fid.write(csv_separator)
            fid.write(str_cmt)
            if i != index_max:
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
        level0   = self._get_indentation_level(level_p=level_p)

        if not os.path.exists(path_p):
            os.makedirs(path_p)
            msg0 = "Directory ", path_p, " Created "
            display_obj.display(msg_p=msg0, level_p=level0, color_p='green')
        else:
            msg0 = "Warning: Directory ", path_p, " already exists"
            display_obj.display(msg_p=msg0, level_p=level0, color_p='yellow')

        return None

    def set_mif_files(self, filepath_list_p):
        """
        This method stores a list of *.mif files.
        For Modelsim/Questa simulator, these *.mif files must be copied
        into a specific directory in order to be "seen" by the simulator
        Note: 
           This method is used for Xilinx IP which uses RAM
           This method should be called before the SystemFpasimTopDataGen.pre_config method (if necessary)
        :param filepath_list_p: (list of strings) -> list of filepaths
        :return: None
        """
        self.filepath_list_mif = filepath_list_p
        return None

    def _copy_mif_files(self, output_path_p, debug_p, level_p=None):
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
        level0   = self._get_indentation_level(level_p=level_p)

        # get absolute path
        script_path = Path(output_path).resolve()
        # move into the hierarchy : vunit_out/modelsim
        output_path = str(script_path.parents[1]) + sep + "modelsim"
        if debug_p == 'true':
            msg0 = script_name + "copy the *.mif into the Vunit simulation directory"
            display_obj.display(msg_p=msg0, level_p=level0, color_p='green')

        # copy each files
        for filepath in self.filepath_list_mif:
            if debug_p == 'true':
                msg0 = script_name + "the filepath :" + filepath + " is copied to " + output_path
                display_obj.display(msg_p=msg0, level_p=level0, color_p='green')
            copy(filepath, output_path)

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

        str0 = "SystemFpasimTopDataGen.pre_config"
        display_obj.display_title(msg_p=str0, level_p=level0)

        ###############################
        #create directories (if not exist) for the VHDL testbench
        # .input directory  for the input data/command files
        # .output directory for the output data files
        tb_input_base_path = str(Path(output_path,'inputs').resolve())
        tb_output_base_path = str(Path(output_path,'outputs').resolve())
        self._create_directory(path_p=tb_input_base_path,level_p = level1)
        self._create_directory(path_p=tb_output_base_path,level_p =level1)

        #copy the mif files into the Vunit simulation directory
        if self.filepath_list_mif is not None:
            self._copy_mif_files(output_path_p=output_path, debug_p='true')

        ##########################################################
        # generate files
        ##########################################################    
        self._run(tb_input_base_path_p=tb_input_base_path, tb_output_base_path_p=tb_output_base_path)

        str0 = "SystemFpasimTopDataGen.pre_config: Simulation transcript"
        display_obj.display_title(msg_p=str0, level_p=level0)

        str0 = ""
        display_obj.display(msg_p=str0, level_p=level0)

        # return True is mandatory for Vunit
        return True