
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
#    @file                   mux_squid_model.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    N/A
# -------------------------------------------------------------------------------------------------------------
#    @details
#    This python script defines the AmpSquidModel class.
#    This class defines methods to generate data which simulates the VHDL amp_squid module
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

class AmpSquidModel:
    """
    This class defines methods to generate data which simulates the VHDL amp_squid module
    Note:
        Method name starting by '_' are local to the class (ex:def _toto(...)).
        It should not be usually used by the user
    """
    def __init__(self):
        """
        This method initializes the class instance
        """
        self.amp_squid_tf_list = None
        self.data_list = None
        self.amp_offset_correction_list = None
        self.fpasim_gain = None
        self.result = None


    def set_ram_amp_squid_tf(self,data_list_p):
        """
        Set the mux_squid_tf ram content
        :param data_list_p (list of integer string). 
        :return: None
        """
        self.amp_squid_tf_list = [int(i) for i in data_list_p]

        return None

    def set_data(self,data_list_p):
        """
        Set the input data (previous data result)
        :param data_list_p: (list of integer string)
        :return: None
        """

        self.data_list = [int(i) for i in data_list_p]
        return None

    def set_amp_offset_correction(self,data_list_p):
        """
        Set the input data (mux_squid_feedback)
        :param data_list_p: (list of integer string).
        :return: list of lists
        """
        self.amp_offset_correction_list = [int(i) for i in data_list_p]

    def set_fpasim_gain(self, data_p):

        if data_p == 0:
            data = 0.25
        elif data_p == 1:
            data = 0.5
        elif data_p == 2:
            data = 0.75
        elif data_p == 3:
            data = 1
        elif data_p == 4:
            data = 1.5
        elif data_p == 5:
            data = 2
        elif data_p == 6:
            data = 3
        else:
            # 7
            data = 4
        self.fpasim_gain = data


    def run(self):

        amp_squid_tf_list = self.amp_squid_tf_list
        data_list = self.data_list
        amp_offset_correction_list = self.amp_offset_correction_list
        fpasim_gain = self.fpasim_gain

        result = []
        L = len(data_list)
        for i in range(L):
            data = data_list[i]
            amp_offset_correction = amp_offset_correction_list[i]

            sub = data - amp_offset_correction
            # check if 0 <= sub<= 2**14-1
            amp_squid_tf = 0
            if (0 <= sub) and (sub <= 2**14-1):
                amp_squid_tf = amp_squid_tf_list[sub]
            else:
                msg0 = '[AmpSquidModel]: ERROR  0 <= (data - amp_offset_correction) <= (2**14-1) is not verified'
                print(msg0)

            mult = math.floor(fpasim_gain * amp_squid_tf)

            result.append(mult)

        self.result = result

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