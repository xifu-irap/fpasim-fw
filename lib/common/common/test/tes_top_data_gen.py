
from common import Display
from common import ValidSequencer
from pathlib import Path,PurePosixPath
import json
import os
import shutil


class TesSignallingModel:
    def __init__(self):
        self.nb_sample_by_pixel = None
        self.nb_frame_by_serie = None
        self.nb_pixel_by_frame = None
        self.nb_serie = None

        self.pixel_sof_list = []
        self.pixel_eof_list = []
        self.pixel_id_list = []
        self.frame_sof_list = []
        self.frame_eof_list = []
        self.frame_id_list = []

    def set_conf(self,nb_sample_by_pixel_p,nb_pixel_by_frame_p,nb_frame_by_serie_p,nb_serie_p):
        self.nb_sample_by_pixel = nb_sample_by_pixel_p
        self.nb_frame_by_serie = nb_frame_by_serie_p
        self.nb_pixel_by_frame = nb_pixel_by_frame_p
        self.nb_serie = nb_serie_p
        self._compute()

    def _oversample(self,data_list_p,oversample_p):
        res = []

        for data in data_list_p:
            for i in range(oversample_p):
                res.append(data)
        return res
    def _compute_flags(self,data_list_p,length_p):

        sof_list = []
        eof_list = []
        cnt = 1
        for data in data_list_p:
            if cnt == 1:
                sof_list.append(1)
            else:
                sof_list.append(0)
            if cnt == length_p:
                eof_list.append(1)
            else:
                eof_list.append(0)
            if cnt == length_p:
                cnt = 1
            else:
                cnt = cnt + 1
        return sof_list,eof_list
    def _compute(self):
        nb_sample_by_pixel = self.nb_sample_by_pixel
        nb_pixel_by_frame   = self.nb_pixel_by_frame
        nb_frame_by_serie  = self.nb_frame_by_serie
        nb_serie           = self.nb_serie

        nb_sample_by_frame = nb_pixel_by_frame * nb_sample_by_pixel

        # compute id
        pixel_id_list = list(range(0,nb_pixel_by_frame-1))
        frame_id_list = list(range(0,nb_frame_by_serie-1))

        # oversample
        pixel_id_oversample_list = self._oversample(data_list_p=pixel_id_list,oversample_p=nb_sample_by_pixel)
        frame_id_oversample_list = self._oversample(data_list_p=frame_id_list,oversample_p=nb_sample_by_frame)

        # duplicate
        pixel_id_oversample_list = pixel_id_oversample_list * nb_serie * nb_frame_by_serie
        frame_id_oversample_list = frame_id_oversample_list * nb_serie
        # compute flags
        pixel_sof_list,pixel_eof_list = self._compute_flags(data_list_p=pixel_id_oversample_list,length_p=nb_sample_by_pixel)
        frame_sof_list,frame_eof_list = self._compute_flags(data_list_p=frame_id_oversample_list,length_p=nb_sample_by_frame)

        self.pixel_sof_list = pixel_sof_list
        self.pixel_eof_list = pixel_eof_list
        self.pixel_id_list = pixel_id_oversample_list

        self.frame_sof_list = frame_sof_list
        self.frame_eof_list = frame_eof_list
        self.frame_id_list = frame_id_oversample_list



    def save(self,filepath_p,csv_separator_p=';'):


        pixel_sof_list = self.pixel_sof_list
        pixel_eof_list = self.pixel_eof_list
        pixel_id_list = self.pixel_id_list

        frame_sof_list = self.frame_sof_list
        frame_eof_list = self.frame_eof_list
        frame_id_list = self.frame_id_list


        filepath = filepath_p
        csv_separator = csv_separator_p

        fid = open(filepath,'w')
        #############################################
        # write header
        #############################################
        fid.write('pixel_sof_uint_t')
        fid.write(csv_separator)
        fid.write('pixel_eof_uint_t')
        fid.write(csv_separator)
        fid.write('pixel_id_uint_t')
        fid.write(csv_separator)
        fid.write('frame_sof_uint_t')
        fid.write(csv_separator)
        fid.write('frame_eof_uint_t')
        fid.write(csv_separator)
        fid.write('frame_id_uint_t')
        fid.write('\n')
        index_max = len(pixel_sof_list) - 1
        #############################################
        index = 0
        for pixel_sof,pixel_eof,pixel_id,frame_sof,frame_eof,frame_id in zip(pixel_sof_list,pixel_eof_list,pixel_id_list,frame_sof_list,frame_eof_list,frame_id_list):
            fid.write(str(pixel_sof))
            fid.write(csv_separator)
            fid.write(str(pixel_eof))
            fid.write(csv_separator)
            fid.write(str(pixel_id))
            fid.write(csv_separator)
            fid.write(str(frame_sof))
            fid.write(csv_separator)
            fid.write(str(frame_eof))
            fid.write(csv_separator)
            fid.write(str(frame_id))
            if index != index_max:
                fid.write('\n')
            index = index + 1
        fid.close()

class TesTopDataGen:

    def __init__(self):
            self.conf_filepath = None
            self.display_obj = Display()
            self.level = 0
            self.verbosity = 0
            self.filepath_list_mif = None
            self.json_data = None
            self.vunit_conf_obj = None

    def set_conf_filepath(self,conf_filepath_p):

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

        self.json_data = json_data
        self.conf_filepath = conf_filepath

    def set_vunit_conf_obj(self,obj_p):
        self.vunit_conf_obj = obj_p

    def set_indentation_level(self, level_p):
        """
        This method set the indentation level of the print message
        :param level_p: (integer >= 0) define the level of indentation of the message to print
        :return: None
        """
        self.level = level_p
        return None


    def set_verbosity(self, verbosity_p):
        self.verbosity = verbosity_p

    def get_generic_dic(self):
        json_data = self.json_data

        nb_pixel_by_frame = json_data['register']['value']['nb_pixel_by_frame']
        nb_frame_by_serie = json_data['register']['value']['nb_frame_by_serie']

        dic = {}
        dic['g_NB_PIXEL_BY_FRAME'] = int(nb_pixel_by_frame)
        dic['g_NB_FRAME_BY_SERIE'] = int(nb_frame_by_serie)
        return dic


    def _run(self, tb_input_base_path_p, tb_output_base_path_p):

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
        dic_sequence.append(json_data["ram_tes_shape"]["sequence"])
        dic_sequence.append(json_data["ram_steady_state"]["sequence"])

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
        # process register
        ####################################################
        msg0 = 'TesTopDataGen._run: Generate register file'
        display_obj.display_subtitle(msg_p=msg0,level_p=level0)

        filename           = json_data["register"]["value"]["filename"]
        en                 = json_data["register"]["value"]["en"]
        nb_sample_by_pixel = json_data["register"]["value"]["nb_sample_by_pixel"]
        nb_pixel_by_frame  = json_data["register"]["value"]["nb_pixel_by_frame"]
        nb_frame_by_serie  = json_data["register"]["value"]["nb_frame_by_serie"]
        nb_serie           = json_data["register"]["value"]["nb_serie"]

        pixel_length = nb_sample_by_pixel
        frame_length = nb_sample_by_pixel * nb_pixel_by_frame

        # count from 0 instead 1 => substract -1
        pixel_length_tmp = pixel_length - 1
        nb_pixel_by_frame_tmp = nb_pixel_by_frame - 1
        frame_length_tmp = frame_length - 1

        filepath     = str(Path(tb_input_base_path,filename))
        fid = open(filepath,'w')
        # header
        fid.write('en_uint1_t')
        fid.write(csv_separator)
        fid.write('pixel_length_uint')
        fid.write(csv_separator)
        fid.write('pixel_nb_uint')
        fid.write(csv_separator)
        fid.write('frame_length_uint')
        fid.write('\n')
        fid.write(str(en))
        fid.write(csv_separator)
        fid.write(str(pixel_length_tmp))
        fid.write(csv_separator)
        fid.write(str(nb_pixel_by_frame_tmp))
        fid.write(csv_separator)
        fid.write(str(frame_length_tmp))

        msg0 = 'filepath='+filepath
        display_obj.display(msg_p=msg0,level_p=level1)

        ####################################################
        # process data
        ####################################################
        nb_samples = frame_length * nb_frame_by_serie * nb_serie
        msg0 = 'TesTopDataGen._run: Generate data file'

        display_obj.display_subtitle(msg_p=msg0,level_p=level0)

        filename = json_data["data"]["value"]["filename"]
        filepath = str(Path(tb_input_base_path,filename))
        fid = open(filepath,'w')
        # header
        fid.write('data')
        fid.write('\n')
        index_max = nb_samples - 1
        for i in range(nb_samples):
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
        pulse_height_list  = json_data["cmd"]["value"]["pulse_height_list"]
        pixel_id_list      = json_data["cmd"]["value"]["pixel_id_list"]
        time_shift_list    = json_data["cmd"]["value"]["time_shift_list"]

        filepath     = str(Path(tb_input_base_path,filename))
        fid = open(filepath,'w')
        # header
        fid.write('pulse_height')
        fid.write(csv_separator)
        fid.write('pixel_id')
        fid.write(csv_separator)
        fid.write('time_shift')
        fid.write('\n')
        index_max = len(pulse_height_list) - 1
        index = 0
        for pulse_height, pixel_id, time_shift in zip(pulse_height_list,pixel_id_list,time_shift_list):
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
        dic_sequence.append(json_data["ram_tes_shape"]["value"])
        dic_sequence.append(json_data["ram_steady_state"]["value"])

        for dic in dic_sequence:
            input_filename = dic['input_filename']
            output_filename = dic['output_filename']
            output_filepath = str(Path(tb_input_base_path,output_filename)) 
            input_filepath = vunit_conf_obj.get_data_filepath(filename_p=input_filename,level_p=level1)

            msg0 = 'input_filepath=' + input_filepath
            display_obj.display(msg_p=msg0,level_p=level2)
            msg0 = 'output_filepath=' + output_filepath
            display_obj.display(msg_p=msg0,level_p=level2)

            shutil.copyfile(input_filepath,output_filepath)


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
        For Modelsim/Questa simulator, these *.mif files will be copied
        into a specific directory in order to be "seen" by the simulator
        Note: 
           This method is used for Xilinx IP which uses RAM
           This method should be called before the TesTopDataGen.pre_config method (if necessary)
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

        #copy the mif files into the Vunit simulation directory
        if self.filepath_list_mif is not None:
            self._copy_mif_files(output_path_p=output_path, debug_p='true')

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