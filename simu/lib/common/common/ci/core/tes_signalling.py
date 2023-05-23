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
#    @file                   tes_signalling.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    N/A
# -------------------------------------------------------------------------------------------------------------
#    @details
#
#    The TesSignalling class is a python model of the VHDL function (tes_signalling.vhd).
#    It computes the expected output values.
#
#    Note:
#       This class automatically create the pixel_sof, pixel_eof, pixel_id, frame_sof, frame_eof, frame_id attributes on the
#       input list of Point instance.
#    
#    Note:
#       . Used for the VHDL simulation.
#       . This class can be instanciated by the user.
#       . It should be instanciated after:
#            . Generator class
#            . optional: OverSample class
#            . optional: Attribute Class 
#       . This script was tested with python 3.10
#
# -------------------------------------------------------------------------------------------------------------

# user library
from .points import Points


class TesSignalling(Points):
    """
    Python model of the VHDL function (tes_signalling.vhd).
    It computes the expected output values.
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
        # define the number of pixels by frame
        self._nb_pixel_by_frame = 0
        # define the number of samples by pixel
        self._nb_sample_by_pixel = 0
        # define the number of frames by pulse
        self._nb_frame_by_pulse = 0
        # define the number of samples by frame
        self._nb_sample_by_frame = 0

    def set_conf(self, nb_pixel_by_frame_p, nb_sample_by_pixel_p, nb_frame_by_pulse_p, nb_sample_by_frame_p):
        """
        Set the configuration parameters.

        Parameters
        ----------
        nb_pixel_by_frame_p: int
            Define the number of pixels by frame.
        nb_sample_by_pixel_p: int
            Define the number of samples by pixel.
        nb_frame_by_pulse_p: int
            Define the number of frame by pulse.
        nb_sample_by_frame_p:
            Define the number of sample by frame.

        Returns
        -------
            None

        """
        self._nb_pixel_by_frame = nb_pixel_by_frame_p
        self._nb_sample_by_pixel = nb_sample_by_pixel_p
        self._nb_frame_by_pulse = nb_frame_by_pulse_p
        self._nb_sample_by_frame = nb_sample_by_frame_p
        return None

    def _compute(self, name_sof_p, name_eof_p, name_id_p, nb_samples_p, nb_id_p):
        """
        Compute the "name_sof_p", name_eof_p, name_id_p attribute values.
        Example: 
            If nb_samples_p = 4 and nb_id_p = 3 then the input list of Point Instances will have the following attribute values:
                name_sof_p: 1 0 0 0 1 0 0 0 1 0 0 0 1 0 0 0  ..........
                name_eof_p: 0 0 0 1 0 0 0 1 0 0 0 1 0 0 0 1  ..........
                name_id_p : 0 0 0 0 1 1 1 1 2 2 2 2 0 0 0 0  ..........

        Note:
          . The computed Id attribute range is [0;nb_id_p-1].

        Parameters
        ----------
        name_sof_p: str
            Name of the "Start Of Frame" attribute (first sample of a block).
        name_eof_p: str
            Name of the "End Of Frame" attribute (last sample of a block).
        name_id_p: str
            Name of the "Id" attribute.
        nb_samples_p: int
            (int >= 1) Numbers of samples of a block. The value range is [1; max integer value].
        nb_id_p: int
            (int >= 1) Numbers of blocks (Id).

        Returns
        -------
            None

        """
        # count samples
        cnt = 0
        cnt_max = nb_samples_p - 1
        # count id block
        cnt_id = 0
        cnt_id_max = nb_id_p - 1

        for obj_pt in self._pts_list:
            if cnt == 0:
                sof = 1
            else:
                sof = 0

            id_value = cnt_id

            if cnt == cnt_max:
                eof = 1
                cnt_id += 1
                if cnt_id > cnt_id_max:
                    cnt_id = 0
                cnt = 0
            else:
                eof = 0
                cnt += 1

            obj_pt.set_attribute(name_p=name_sof_p, value_p=sof)
            obj_pt.set_attribute(name_p=name_eof_p, value_p=eof)
            obj_pt.set_attribute(name_p=name_id_p, value_p=id_value)

        return 0

    def run(self):
        """
        Compute the expected output values of the VHDL function (tes_signalling).
        Note:
            It automatically generate the following attributes:
                . pixel_sof, pixel_eof and pixel_id
                . frame_sof, frame_eof and frame_id

        Returns
        -------
            a list of Points instances.
        """
        self._compute(name_sof_p="pixel_sof", name_eof_p="pixel_eof", name_id_p='pixel_id',
                      nb_samples_p=self._nb_sample_by_pixel, nb_id_p=self._nb_pixel_by_frame)
        self._compute(name_sof_p="frame_sof", name_eof_p="frame_eof", name_id_p='frame_id',
                      nb_samples_p=self._nb_sample_by_frame, nb_id_p=self._nb_frame_by_pulse)

        return self._pts_list
