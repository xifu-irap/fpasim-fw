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
#    @file                   tb_tes_top.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    
# -------------------------------------------------------------------------------------------------------------
#    @details                
# 
# -------------------------------------------------------------------------------------------------------------

import os
# Enable the coloring in the console
os.system("")
import sys
import argparse
from pathlib import Path,PurePosixPath
# Json lib
import json

# get the name of the script name without file extension
script_name = str(Path(__file__).stem)


def find_file_in_hierarchy(filename_p='DONT_DELETE.txt', depth_level_p=10):
    """
    This function searches in this script parent directories, the filename_p parameter.
    If found, it returns the base path of the filename_p as well as its corresponding filepath

    :param filename_p: (string) filename to search in the hierarchy
    :param depth_level_p: (integer >= 0) search depth limit
    :return: basepath, filepath: (string, string) (basepath of filename_p, filepath of filename_p) if found.
                                                  Otherwise (None, None)
    """
    script_name0 = str(Path(__file__).stem)
    start_path = Path(__file__)
    ok = 0
    for i in range(depth_level_p):
        basepath = str(start_path.parents[i])
        filepath = str(Path(basepath, filename_p).resolve())
        exist = Path(filepath).is_file()
        if exist == True:
            ok = 1
            break
        else:
            continue
    if ok == 1:
        return basepath, filepath
    else:
        msg = '[' + script_name0 + '] : ERRORS: the filename :' + filename_p + "wasn't found in the script hierarchy of " + str(start_path)
        print(msg)
        return None, None


# retrieve all python library path in order to import them
def get_python_library_from_json_file(filepath_p):

    filepath = filepath_p
    # Opening JSON file
    fid = open(filepath,'r')
    # returns JSON object as 
    # a dictionary
    json_data = json.load(fid)
    # Closing file
    fid.close()

    python_lib_dic = json_data["lib"]["python"]
    path_list = []
    for key in python_lib_dic.keys():
        tmp_path_list = python_lib_dic[key]['directory_path_list']
        for path in tmp_path_list:
            path0 = str(Path(path).resolve())
            path_list.append(path0)

    return path_list

#################################################################
# loop on the project python library path (dynamically computed)
#   1. add path to the python path
#   => project specific python library can now be imported
#################################################################
root_path,filepath = find_file_in_hierarchy()
json_filepath = str(Path(root_path,'./launch_sim_processed.json').resolve())
path_list = get_python_library_from_json_file(filepath_p=json_filepath)
if path_list != None:
    for path in path_list:
        print(path)
        sys.path.append(path)


#################################################################
# import specific library
#################################################################
from vunit import VUnit, VUnitCLI
from common import FilepathListBuilder, Display, VunitConf, ValidSequencer


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
     

if __name__ == '__main__':
    # Add custom command line argument to standard CLI
    # Beware of conflicts with existing arguments
    cli = VUnitCLI()

    help0 = 'Specify the conf_filename'
    cli.parser.add_argument('--conf_filepath', default='tb_tes_top_conf.json', help=help0)

    help0 = 'Specify the testbench base path for the input files'
    cli.parser.add_argument('--tb_input_base_path', default='', help=help0)

    help0 = 'Specify the testbench base path for the output files'
    cli.parser.add_argument('--tb_output_base_path', default='', help=help0)

    help0 = 'Specify the verbosity level. Possible values (uint): 0 to 2'
    cli.parser.add_argument('--verbosity', default=0,choices = [0,1,2], type = int, help=help0)

    args = cli.parse_args()

    # retrieve the command line arguments
    conf_filepath = args.conf_filepath
    tb_input_base_path   = args.tb_input_base_path
    tb_output_base_path   = args.tb_output_base_path
    verbosity     = args.verbosity


    ################################################
    # build the display object
    ################################################
    level0 = 0
    level1 = 1
    level2 = 2
    obj_display = Display()
    msg0 = 'Start Python Script: '+__file__
    obj_display.display_title(msg_p=msg0,level_p=level0)
    msg0 = 'conf_filepath = ' + conf_filepath
    obj_display.display(msg_p=msg0,level_p=level1)


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


    ################################################
    # process all sequences
    ################################################
    csv_separator = ';'
    msg0 = 'write sequence file'
    obj_display.display_subtitle(msg_p=msg0,level_p=level0)

    dic_sequence = []
    dic_sequence.append(json_data["register"]["sequence"])
    dic_sequence.append(json_data["cmd"]["sequence"])

    for dic in dic_sequence:
        filename = dic["filename"]
        filepath   = str(Path(tb_input_base_path,filename).resolve())
        
        ctrl       = str(dic["ctrl"])
        min_value1 = str(dic["min_value1"])
        max_value1 = str(dic["max_value1"])
        min_value2 = str(dic["min_value2"])
        max_value2 = str(dic["max_value2"])
        max_value2 = str(dic["max_value2"])
        time_shift = str(dic["time_shift"])

        seq = ValidSequencer(name_p = filename)
        seq.set_verbosity(verbosity_p=verbosity)
        seq.set_sequence(ctrl_p=ctrl, 
                         min_value1_p=min_value1,
                         max_value1_p=max_value1,
                         min_value2_p=min_value2,
                         max_value2_p=max_value2,
                         time_shift_p=time_shift)
        seq.save(filepath_p=filepath,csv_separator_p=csv_separator)

        msg0 = 'write filepath='+filepath
        obj_display.display(msg_p=msg0,level_p=level1)


    ####################################################
    # process register
    ####################################################
    msg0 = 'write register file'
    obj_display.display_subtitle(msg_p=msg0,level_p=level0)

    filename     = json_data["register"]["value"]["filename"]
    en           = int(json_data["register"]["value"]["en"])
    nb_sample_by_pixel = int(json_data["register"]["value"]["nb_sample_by_pixel"])
    nb_pixel_by_frame  = int(json_data["register"]["value"]["nb_pixel_by_frame"])
    nb_frame_by_serie  = int(json_data["register"]["value"]["nb_frame_by_serie"])
    nb_serie           = int(json_data["register"]["value"]["nb_serie"])

    pixel_length = nb_sample_by_pixel
    frame_length = nb_sample_by_pixel * nb_pixel_by_frame

    filepath     = str(Path(tb_input_base_path,filename))
    fid = open(filepath,'w')
    # header
    fid.write('en_uint1_t')
    fid.write(csv_separator)
    fid.write('pixel_length_uint')
    fid.write(csv_separator)
    fid.write('frame_length_uint')
    fid.write('\n')
    fid.write(str(en))
    fid.write(csv_separator)
    fid.write(str(pixel_length))
    fid.write(csv_separator)
    fid.write(str(frame_length))

    msg0 = 'write filepath='+filepath
    obj_display.display(msg_p=msg0,level_p=level1)




    










