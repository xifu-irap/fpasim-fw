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
#    @file                   mux_squid_top.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    N/A
# -------------------------------------------------------------------------------------------------------------
#    @details
#    
#    Note:
#       . This script was tested with python 3.10
# -------------------------------------------------------------------------------------------------------------

# standard library
from pathlib import Path, PurePosixPath

# user library
from .file import File
from .points import Points


class MuxSquidTop(Points):
    """
    Computation of the MuxSquidTop model on a list of Point Instances.
    """
    def __init__(self, pts_list_p):
        """
        Initialize the class instance.

        Parameters
        ----------
        pts_list_p:  Point object list.
            Defines a list of Point instances.

        """
        super().__init__(pts_list_p=pts_list_p)
        # define the content of the mux_squid_offset RAM
        self._mux_squid_offset_list = []
        # define the content of the mux_squid_tf RAM
        self._mux_squid_tf_list = []
        # define the inter_squid_gain
        self._inter_squid_gain = 0
        # define the inter_squid_gain width
        self._inter_squid_gain_width = 8

    def set_ram_mux_squid_offset(self, filepath_p):
        """
        Define the content of the mux_squid_offset ram.

        Parameters
        ----------
        filepath_p: str
            filepath to read

        Returns
        -------
        None

        """
        obj_file = File(filepath_p=filepath_p)
        self._mux_squid_offset_list = obj_file.run()

    def set_ram_mux_squid_tf(self, filepath_p):
        """
        Define the content of the mux_squid_tf ram.

        Parameters
        ----------
        filepath_p: str
            filepath to read

        Returns
        -------
        None

        """
        obj_file = File(filepath_p=filepath_p)
        self._mux_squid_tf_list = obj_file.run()

    def set_conf0(self, inter_squid_gain_p):
        """
        Set the conf0 register.

        Parameters
        ----------
        inter_squid_gain_p: int
            Define the inter_squid_gain field value of the register

        Returns
        -------
        None

        """
        self._inter_squid_gain = inter_squid_gain_p

    def _compute(self, pixel_id_p, tes_out_p, adc_mux_squid_feedback_p):
        """
        Compute the output value of the mux_squid function model.

        Parameters
        ----------
        pixel_id_p: int
            Define the pixel id value.
        tes_out_p: int
            Define the output value of the tes function
        adc_mux_squid_feedback_p: int
            Define the adc_mux_squid_feedback value

        Returns
        -------
        the computed output value of the mux_squid function model
        """

        inter_squid_gain = self._inter_squid_gain / (2 ** self._inter_squid_gain_width)

        sub = tes_out_p - adc_mux_squid_feedback_p

        # convert sub into unsigned int
        if sub < 0:
            addr = 2 ** 16 - sub
        else:
            addr = sub

        # compute the modulo on the addr_width
        addr = addr % (2 ** 14)
        # get the mux_squid_tf value
        mux_squid_tf = self._mux_squid_tf_list[addr]

        # apply the gain
        mux_squid_tf_with_gain = inter_squid_gain * mux_squid_tf

        # get the mux_squid_offset
        mux_squid_offset = self._mux_squid_offset_list[pixel_id_p]

        add = mux_squid_offset + mux_squid_tf_with_gain

        return add

    def run(self, output_attribute_name_p="mux_squid_out"):
        """
        Apply the mux_squid model on a list of point instances.
        
        Parameters
        ----------
        output_attribute_name_p: str
            attribute name where to store the result of the mux_squid function output.

        Returns
        -------
        list of Point instances

        """
        for obj_pt in self._pts_list:
            pixel_id = obj_pt.get_attribute(name_p='pixel_id')
            tes_out = obj_pt.get_attribute(name_p='tes_out')
            adc_mux_squid_feedback = obj_pt.get_attribute(name_p='adc_mux_squid_feedback')

            result = self._compute(pixel_id_p=pixel_id, tes_out_p=tes_out,
                                   adc_mux_squid_feedback_p=adc_mux_squid_feedback)
            obj_pt.set_attribute(name_p=output_attribute_name_p, value_p=result)

        return self._pts_list
