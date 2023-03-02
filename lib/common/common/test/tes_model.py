
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
#    @file                   tes_model.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    N/A
# -------------------------------------------------------------------------------------------------------------
#    @details
#    This python script defines the TesModel class.
#    This class defines methods to generate data which simulates the VHDL tes_top module
#    
#    Note:
#       . This script is aware of the json configuration file
#       . This script was tested with python 3.10
# -------------------------------------------------------------------------------------------------------------

import os
from pathlib import Path,PurePosixPath 
import argparse
import math

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

class TesModel:
    """
    This class defines methods to generate data which simulates the VHDL tes_top module
    Note:
        Method name starting by '_' are local to the class (ex:def _toto(...)).
        It should not be usually used by the user
    """
    def __init__(self):
        """
        This method initializes the class instance
        """
        self.tes_pulse_shape_list = None
        self.tes_steady_state_list = None
        self.pixel_id_list = None
        self.result = None
        self.cmd_dic_list = []
        self.nb_sample_by_pixel = None
        self.nb_pixel_by_frame = None
        self.nb_frame_by_pulse = None
        self.nb_pulse = None


    def set_ram_tes_pulse_shape(self, data_list_p):
        """
        Set the mux_squid_offset ram content
        :param data_list_p (list of integer string). 
        :return: None
        """
        self.tes_pulse_shape_list = [int(i) for i in data_list_p]

        return None

    def set_ram_tes_steady_state(self,data_list_p):
        """
        Set the mux_squid_tf ram content
        :param data_list_p (list of integer string). 
        :return: None
        """
        self.tes_steady_state_list = [int(i) for i in data_list_p]

        return None

    def set_pixel_id(self,data_list_p):
        """
        Set input data (pixel id)
        :param data_list_p: (list of integer string).
        :return: None
        """

        self.pixel_id_list = [int(i) for i in data_list_p]
        return None

    def set_conf(self, nb_sample_by_pixel_p):
        self.nb_sample_by_pixel = nb_sample_by_pixel_p



    def add_command(self, pixel_id_p, time_shift_p, pulse_heigth_p):

        dic = {}
        dic['pixel_id']     = pixel_id_p
        dic['time_shift']   = time_shift_p
        dic['pulse_heigth'] = pulse_heigth_p

        self.cmd_dic_list.append(dic)

    def _compute_tes(self,pulse_shape_p,pulse_heigth_p,i0_p):

        # convert pulse_heigth to percentage
        #    uint16_t -> [0;0.9999847412109375]
        #    0x0000 -> 0%
        #    0xFFFF -> ~100%
        pulse_heigth_width = 16

        pulse_heigth_percentage = pulse_heigth_p / 2**pulse_heigth_width

        pulse_shape = pulse_shape_p * pulse_heigth_percentage
        res = i0_p - pulse_shape
        res = math.floor(res)
        return res

    def run(self):

        pixel_id_list = self.pixel_id_list
        tes_pulse_shape_list = self.tes_pulse_shape_list
        tes_steady_state_list = self.tes_steady_state_list
        nb_sample_by_pixel = self.nb_sample_by_pixel

        cmd_dic_list = self.cmd_dic_list

        pulse_shape_oversampling_factor = 16
        pulse_shape_nb_samples_by_frame = 2048

        result = []

        # compute data with only I0
        io_list = []
        for pixel_id in pixel_id_list:
            data = tes_steady_state_list[pixel_id]
            io_list.append(data)
  
        index = 0
        L = len(io_list)
        for cmd_dic in cmd_dic_list:
            cmd_pixel_id = cmd_dic['pixel_id']
            cmd_time_shift = cmd_dic['time_shift']
            cmd_pulse_heigth = cmd_dic['pulse_heigth']

            cnt = 0
            cnt_sample = 1
            for i in range(L):
                pixel_id = pixel_id_list[i]
                i0       = io_list[i]
                if cmd_pixel_id == pixel_id:
                    if cnt <= (pulse_shape_nb_samples_by_frame - 1):
                        # compute tes_pulse_shape address
                        index = cnt*pulse_shape_oversampling_factor  + cmd_time_shift
                        pulse_shape = tes_pulse_shape_list[index]
                        io_list[i] = self._compute_tes(pulse_shape_p=pulse_shape, pulse_heigth_p=cmd_pulse_heigth, i0_p=i0)

                        # add pulse shape
                    if cnt_sample == nb_sample_by_pixel:
                        cnt += 1
                        cnt_sample = 1
                    else:
                        cnt_sample += 1
                       
                   

        self.result = io_list

    def get_result(self):

        return self.result



if __name__ == '__main__':
    """
    This part allows to test the python script in standolone.
    """
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
    # obj = TesSignallingModel()

    # if test_name == 'test1':
    #     nb_sample_by_pixel = 1
    #     nb_pixel_by_frame = 1
    #     nb_frame_by_pulse = 1
    #     nb_pulse = 1
    # elif test_name == 'test2':
    #     nb_sample_by_pixel = 1
    #     nb_pixel_by_frame = 2
    #     nb_frame_by_pulse = 1
    #     nb_pulse = 1
    # elif test_name == 'test3':
    #     nb_sample_by_pixel = 2
    #     nb_pixel_by_frame = 2
    #     nb_frame_by_pulse = 1
    #     nb_pulse = 1
    # elif test_name == 'test4':
    #     nb_sample_by_pixel = 2
    #     nb_pixel_by_frame = 2
    #     nb_frame_by_pulse = 2
    #     nb_pulse = 1
    # elif test_name == 'test5':
    #     nb_sample_by_pixel = 2
    #     nb_pixel_by_frame = 3
    #     nb_frame_by_pulse = 2
    #     nb_pulse = 2

    # filename = test_name + '.csv'
    # filepath_tmp = str(Path(output_base_path,filename))
    # obj.set_conf(nb_sample_by_pixel_p=nb_sample_by_pixel, nb_pixel_by_frame_p=nb_pixel_by_frame, nb_frame_by_pulse_p=nb_frame_by_pulse, nb_pulse_p=nb_pulse)
    # obj.save(filepath_p=filepath_tmp,csv_separator_p=csv_separator)