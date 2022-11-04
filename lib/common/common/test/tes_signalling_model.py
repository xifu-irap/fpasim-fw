
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
#    @file                   tes_signalling_model.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    N/A
# -------------------------------------------------------------------------------------------------------------
#    @details
#    This python script defines the TesSignallingModel class.
#    This class defines methods to generate data which simulates the VHDL tes_signalling module
#    
#    Note:
#       . This script is aware of the json configuration file
#       . This script was tested with python 3.10
# -------------------------------------------------------------------------------------------------------------

import os
from pathlib import Path,PurePosixPath 
import argparse

def create_directory( path_p):
        """
        This function create the directory tree defined by the "path" argument (if not exist)
        :param path_p: (string) -> path to the directory to create
        :return: None
        """
        path = str(Path(path_p).resolve())
        if not os.path.exists(path):
            os.makedirs(path)
            msg0 = "Directory " + path + " Created "
            print(msg0)
        else:
            msg0 = "Warning: Directory " + path + " already exists"
            print(msg0)

        return None

class TesSignallingModel:
    def __init__(self):
        self.nb_sample_by_pixel = None
        self.nb_frame_by_pulse = None
        self.nb_pixel_by_frame = None
        self.nb_pulse = None

        self.pixel_sof_list = []
        self.pixel_eof_list = []
        self.pixel_id_list = []
        self.frame_sof_list = []
        self.frame_eof_list = []
        self.frame_id_list = []

    def set_conf(self,nb_sample_by_pixel_p,nb_pixel_by_frame_p,nb_frame_by_pulse_p,nb_pulse_p):
        self.nb_sample_by_pixel = nb_sample_by_pixel_p
        self.nb_frame_by_pulse = nb_frame_by_pulse_p
        self.nb_pixel_by_frame = nb_pixel_by_frame_p
        self.nb_pulse = nb_pulse_p
        self._compute()


    def get_data(self):
        return self.pixel_sof_list,self.pixel_eof_list,self.pixel_id_list,self.frame_sof_list,self.frame_eof_list,self.frame_id_list

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
        nb_frame_by_pulse  = self.nb_frame_by_pulse
        nb_pulse           = self.nb_pulse

        nb_sample_by_frame = nb_pixel_by_frame * nb_sample_by_pixel

        # compute id
        pixel_id_list = list(range(0,nb_pixel_by_frame))
        frame_id_list = list(range(0,nb_frame_by_pulse))

        # print('pixel_id_list',pixel_id_list)
        # print('frame_id_list',frame_id_list)

        # oversample
        pixel_id_oversample_list = self._oversample(data_list_p=pixel_id_list,oversample_p=nb_sample_by_pixel)
        frame_id_oversample_list = self._oversample(data_list_p=frame_id_list,oversample_p=nb_sample_by_frame)

        # duplicate
        pixel_id_oversample_list = pixel_id_oversample_list * nb_pulse * nb_frame_by_pulse
        frame_id_oversample_list = frame_id_oversample_list * nb_pulse
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

    csv_separator = ';'
    output_base_path_default = './__output__'
    default_test = 'test1'
    ############################################################################
    # parse command line
    ############################################################################
    parser = argparse.ArgumentParser(description='Launch some test_list')
    #
    parser.add_argument('--output_base_path', default=output_base_path_default, 
                        help='Define the output directory path')

    parser.add_argument('--test_name', choices=['test1','test2','test3','test4','test5'], default=default_test, 
                       help='Define the test to run')

    args = parser.parse_args()

    output_base_path = args.output_base_path
    test_name        = args.test_name


    create_directory(path_p=output_base_path)
    ########################################
    # Test definition
    ########################################
    obj = TesSignallingModel()

    if test_name == 'test1':
        nb_sample_by_pixel = 1
        nb_pixel_by_frame = 1
        nb_frame_by_pulse = 1
        nb_pulse = 1
    elif test_name == 'test2':
        nb_sample_by_pixel = 1
        nb_pixel_by_frame = 2
        nb_frame_by_pulse = 1
        nb_pulse = 1
    elif test_name == 'test3':
        nb_sample_by_pixel = 2
        nb_pixel_by_frame = 2
        nb_frame_by_pulse = 1
        nb_pulse = 1
    elif test_name == 'test4':
        nb_sample_by_pixel = 2
        nb_pixel_by_frame = 2
        nb_frame_by_pulse = 2
        nb_pulse = 1
    elif test_name == 'test5':
        nb_sample_by_pixel = 2
        nb_pixel_by_frame = 3
        nb_frame_by_pulse = 2
        nb_pulse = 2
        



    filename = test_name + '.csv'
    filepath = str(Path(output_base_path,filename))
    obj.set_conf(nb_sample_by_pixel_p=nb_sample_by_pixel, nb_pixel_by_frame_p=nb_pixel_by_frame, nb_frame_by_pulse_p=nb_frame_by_pulse, nb_pulse_p=nb_pulse)
    obj.save(filepath_p=filepath,csv_separator_p=csv_separator)