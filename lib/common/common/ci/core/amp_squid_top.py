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
#    @file                   amp_squid_top.py
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
import math
from pathlib import Path, PurePosixPath

# user library
from .file import File
from .points import Points


class AmpSquidTop(Points):
    """
    Computation of the AmpSquidTop model on a list of Point Instances.
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
        # define the content of the amp_squid_tf RAM
        self.amp_squid_tf_list = []

        # address width of the amp_squid_tf RAM
        self.addr_ram_width = 14

        # define the fpasim_gain computed by the vhdl code
        self._vhdl_fpasim_gain = 0

    def set_ram_amp_squid_tf(self, filepath_p):
        """
        Define the content of the amp_squid_tf ram.

        Parameters
        ----------
        filepath_p: str
            filepath to read


        Returns
        -------
        None

        """
        obj_file = File(filepath_p=filepath_p)
        self.amp_squid_tf_list = obj_file.run()

    def set_fpasim_gain(self, fpasim_gain_p):
        """
        set the fpasim_gain field value from the FPASIM_GAIN register
   
        Parameters
        ----------
        fpasim_gain_p: int
            define the fpasim_gain value

        Returns
        -------
        the fpasim_gain value used in the VHDL code.

        """

        if fpasim_gain_p == 0:
            data = 0.25
        elif fpasim_gain_p == 1:
            data = 0.5
        elif fpasim_gain_p == 2:
            data = 0.75
        elif fpasim_gain_p == 3:
            data = 1
        elif fpasim_gain_p == 4:
            data = 1.5
        elif fpasim_gain_p == 5:
            data = 2
        elif fpasim_gain_p == 6:
            data = 3
        else:
            # 7
            data = 4
        self._vhdl_fpasim_gain = data

    def _compute(self, mux_out_p, adc_amp_squid_offset_correction_p):
        """
        Compute the output value of the amp_squid function model.

        Parameters
        ----------
        mux_out_p: int
            Define the output value of the mux_squid function

        adc_amp_squid_offset_correction_p: int
            Define the adc_amp_squid_offset_correction_p value

        Returns
        -------
        the computed output value of the amp_squid function model
        """
        addr_max = (2 ** self.addr_ram_width - 1)
        sub = mux_out_p - adc_amp_squid_offset_correction_p
        # check if 0 <= sub<= 2**14-1
        amp_squid_tf = 0
        if (0 <= sub) and (sub <= addr_max):
            amp_squid_tf = self.amp_squid_tf_list[sub]
        else:
            msg0 = '[AmpSquidModel]: ERROR  0 <= (data - amp_offset_correction) <= (2**14-1) is not verified'
            print(msg0)

        mult = math.floor(self._vhdl_fpasim_gain * amp_squid_tf)

        return mult

    def run(self, output_attribute_name_p="amp_squid_out"):
        """
        Apply the amp_squid model on a list of point instances

        Parameters
        ----------
        output_attribute_name_p: str
            attribute name where to store the result of the amp_squid function output

        Returns
        -------
        list of Point instances

        """

        for obj_pt in self._pts_list:
            mux_squid_out = obj_pt.get_attribute(name_p='mux_squid_out')
            adc_amp_squid_offset_correction = obj_pt.get_attribute(name_p='adc_amp_squid_offset_correction')

            result = self._compute(mux_out_p=mux_squid_out,
                                   adc_amp_squid_offset_correction_p=adc_amp_squid_offset_correction)
            obj_pt.set_attribute(name_p=output_attribute_name_p, value_p=result)

        return self._pts_list
