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
#    @file                   tes_top.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    N/A
# -------------------------------------------------------------------------------------------------------------
#    @details
#
#   This class is a model of the VHDL tes function.
#
#    Note:
#       . This script was tested with python 3.10
# -------------------------------------------------------------------------------------------------------------

# standard library
import math
from pathlib import Path, PurePosixPath

# user library
from .file import File
from .points import Points


class TesPulseShapeManager(Points):
    """
    Computation of the TesPulseShapeManager model on a list of Point Instances.
    """
    def __init__(self, pts_list_p):
        """
        Initialize the class instance.

        Parameters
        ----------
        pts_list_p: Point object list.
            Defines a list of Point instances.

        """
        super().__init__(pts_list_p=pts_list_p)
        # define the content of the tes_pulse_shape RAM
        self._tes_pulse_shape_list = []
        # define the content of the tes_steady_state RAM
        self._tes_steady_state_list = []
        # list of the make pulse command
        self._make_pulse_dic_list = []
        # define the oversampling factor applied to each sample of a pulse
        self._pulse_shape_oversampling_factor = 16
        # define the number of frames in order to generate a pulse
        self._pulse_shape_nb_samples_by_frame = 2048

        # data width of the pulse_height parameter
        self._pulse_height_width = 16

    def set_ram_tes_pulse_shape(self, filepath_p):
        """
        Define the content of the tes_pulse_shape ram.

        Parameters
        ----------
        filepath_p: str
            filepath to read

        Returns
        -------
        None

        """
        obj_file = File(filepath_p=filepath_p)
        self._tes_pulse_shape_list = obj_file.run()

    def set_ram_tes_steady_state(self, filepath_p):
        """
        Define the content of the tes_steady_state.

        Parameters
        ----------
        filepath_p: str
            filepath to read

        Returns
        -------
        None

        """
        obj_file = File(filepath_p=filepath_p)
        self._tes_steady_state_list = obj_file.run()

    def add_make_pulse_command(self, pixel_id_p, time_shift_p, pulse_height_p, skip_nb_samples_p=0):
        """
        Add a make pulse command.

        Parameters
        ----------
        pixel_id_p: int
            Define the pixel id value
        time_shift_p: int
            Define the time shift value
        pulse_height_p: int
            Define the pulse height value
        skip_nb_samples_p: int
            Define the number of data samples to skip before generated the command

        Returns
        -------
        None

        """
        dic = {}
        dic['pixel_id'] = pixel_id_p
        dic['time_shift'] = time_shift_p
        dic['pulse_height'] = pulse_height_p
        dic['skip_nb_samples'] = skip_nb_samples_p

        self._make_pulse_dic_list.append(dic)

    def _compute(self, pulse_shape_p, pulse_height_p, i0_p):
        """
        Compute the output value of the tes function model.

        Parameters
        ----------
        pulse_shape_p: int
            Define the pulse_shape value
        pulse_height_p: int
            Define the pulse_height value
        i0_p: int
            Define the I0 value

        Returns
        -------
            computed value.

        """

        # convert pulse_height to percentage
        #    uint16_t -> [0;0.9999847412109375]
        #    0x0000 -> 0%
        #    0xFFFF -> ~100%
        pulse_height_percentage = pulse_height_p / (2 ** self._pulse_height_width)

        pulse_shape = pulse_shape_p * pulse_height_percentage
        res = i0_p - pulse_shape
        if res < 0:
            # force output value to 0 when negative
            res = 0
        res = math.floor(res)
        return res

    def run(self, output_attribute_name_p="tes_out"):
        """
        Apply the tes model on a list of point instances.
        
        Parameters
        ----------
        output_attribute_name_p: str
            attribute name where to store the result of the tes function output

        Returns
        -------
        list of Point instances
        """
        pulse_shape_oversampling_factor = self._pulse_shape_oversampling_factor
        pulse_shape_nb_samples_by_frame = self._pulse_shape_nb_samples_by_frame

        for cmd_dic in self._make_pulse_dic_list:
            cmd_pixel_id = cmd_dic['pixel_id']
            cmd_time_shift = cmd_dic['time_shift']
            cmd_pulse_height = cmd_dic['pulse_height']
            cmd_skip_nb_samples = cmd_dic['skip_nb_samples']

            cnt = 0
            state = 0
            cnt_skip = 0

            for obj_pt in self._pts_list:
                pixel_id = obj_pt.get_attribute(name_p='pixel_id')
                pixel_eof = obj_pt.get_attribute(name_p='pixel_eof')
                pixel_sof = obj_pt.get_attribute(name_p='pixel_sof')
                i0 = self._tes_steady_state_list[pixel_id]
                obj_pt.set_attribute(name_p=output_attribute_name_p, value_p=i0)

                # skip the first sample
                if state == 0:
                    # print("cnt_skip",cnt_skip,"cmd_skip_nb_samples",cmd_skip_nb_samples)
                    if cnt_skip == cmd_skip_nb_samples:
                        state = 1
                    else:
                        cnt_skip += 1
                        continue

                # the computation can't be done during a pixel
                #  => wait the first pixel sample
                if (state == 1) and (pixel_sof == 1):
                    state = 2

                if state == 2:
                    if cmd_pixel_id == pixel_id:
                        if cnt <= (pulse_shape_nb_samples_by_frame - 1):
                            # compute tes_pulse_shape address
                            index = cnt * pulse_shape_oversampling_factor + cmd_time_shift
                            pulse_shape = self._tes_pulse_shape_list[index]
                            i0 = self._compute(pulse_shape_p=pulse_shape, pulse_height_p=cmd_pulse_height, i0_p=i0)

                        # add pulse shape
                        if pixel_eof == 1:
                            cnt += 1

                    obj_pt.set_attribute(name_p=output_attribute_name_p, value_p=i0)

        return self._pts_list
