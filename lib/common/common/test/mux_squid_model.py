
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
#    This python script defines the MuxSquidModel class.
#    This class defines methods to generate data which simulates the VHDL mux_squid_top module
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

class MuxSquidModel:
    """
    This class defines methods to generate data which simulates the VHDL mux_squid_top module
    Note:
        Method name starting by '_' are local to the class (ex:def _toto(...)).
        It should not be usually used by the user
    """
    def __init__(self):
        """
        This method initializes the class instance
        """
        self.mux_squid_offset_list = None
        self.mux_squid_tf_list = None
        self.pixel_id_list = None
        self.data_list = None
        self.mux_squid_feadback_list = None
        self.result = None


    def set_ram_mux_squid_offset(self, data_list_p):
        """
        Set the mux_squid_offset ram content
        :param data_list_p (list of integer string). 
        :return: None
        """
        self.mux_squid_offset_list = [int(i) for i in data_list_p]

        return None

    def set_ram_mux_squid_tf(self,data_list_p):
        """
        Set the mux_squid_tf ram content
        :param data_list_p (list of integer string). 
        :return: None
        """
        self.mux_squid_tf_list = [int(i) for i in data_list_p]

        return None

    def set_pixel_id(self,data_list_p):
        """
        Set input data (pixel id)
        :param data_list_p: (list of integer string).
        :return: None
        """

        self.pixel_id_list = [int(i) for i in data_list_p]
        return None

    def set_data(self,data_list_p):
        """
        Set the input data (previous data result)
        :param data_list_p: (list of integer string)
        :return: None
        """

        self.data_list = [int(i) for i in data_list_p]
        return None

    def set_mux_squid_feedback(self,data_list_p):
        """
        Set the input data (mux_squid_feedback)
        :param data_list_p: (list of integer string).
        :return: list of lists
        """
        self.mux_squid_feadback_list = [int(i) for i in data_list_p]


    def run(self):

        pixel_id_list = self.pixel_id_list
        data_list = self.data_list
        mux_squid_feadback_list = self.mux_squid_feadback_list
        mux_squid_tf_list = self.mux_squid_tf_list
        mux_squid_offset_list = self.mux_squid_offset_list
        result = []
        L = len(pixel_id_list)
        for i in range(L):
            pixel_id = pixel_id_list[i]
            data = data_list[i]
            mux_squid_feedback = mux_squid_feadback_list[i]

            sub = data - mux_squid_feedback
            # check if 0 <= sub<= 2**14-1
            mux_squid_tf = 0
            if (0 <= sub) and (sub <= 2**14-1):
                mux_squid_tf = mux_squid_tf_list[sub]
            else:
                msg0 = '[MuxSquidModel]: ERROR  0 <= (result - mux_squid_feadback) <= (2**14-1) is not verified'
                print(msg0)

            mux_squid_offset = mux_squid_offset_list[pixel_id]

            add = mux_squid_offset + mux_squid_tf

            result.append(add)

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