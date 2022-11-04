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
#    @file                   valid_sequencer.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    N/A
# -------------------------------------------------------------------------------------------------------------      
#    @details                
#    This python script defines the ValidSequencer class.
#    This class provides methods to generate an output csv file in order to
#    configure the VHDL pkg_valid_sequencer procedure (see pkg_sequence.vhd)
#
#     Note: 
#       . The first pulse can be delayed by a certain amount defined by time_shift value
#       . This script was tested with python 3.10
# -------------------------------------------------------------------------------------------------------------


# standard library
import os


class ValidSequencer:
    """

    """

    def __init__(self, name_p):
        """
        init the class
        """
        self.name = name_p

        self.ctrl = None

        self.min_value1 = None
        self.max_value1 = None

        self.min_value2 = None
        self.max_value2 = None

        self.time_shift = None
        self.verbosity = 0

    def set_verbosity(self, verbosity_p):
        """

        :param verbosity_p:
        :return:
        """
        self.verbosity = verbosity_p

    def set_sequence(self, ctrl_p, min_value1_p, max_value1_p, min_value2_p, max_value2_p, time_shift_p=0):
        """
        define the different mode of pulse generation
        :param ctrl_p: define the mode: Possibles values are:
            .0: continuous valid generation
                . min_value1, max_value1, min_value2, max_value2 values are ignored
            .1: random short pulse generation
                . a positive pulse with a width of 1 clock cycle followed by
                . a negative pulse with a random width between min_value2 and max_value2
            .2. constant short pulse generation
                . a positive pulse with a width of 1 clock cycle followed by
                . a negative pulse with a constant width defined by the min_value2 value
            .3. random pulse generation
                . a positive pulse with a width defined by a random value between min_value1_v and max_value1_v followed by
                . a negative pulse with a width defined by a random value between min_value2_v and max_value2_
            .4. constant pulse generation
                . a positive pulse with a width defined by the min_value1_v value followed by
                . a negative pulse with a width defined by the min_value2_v value
            others values : continuous valid generation
        :param min_value1_p: define a min value for the positive pulse
        :param max_value1_p: define a max value for the positive pulse
        :param min_value2_p: define a min value for the negative pulse
        :param max_value2_p: define a min value for the negative pulse
        :param time_shift_p: define a starting offset before generating pulses
        :return:
        """

        self.ctrl = ctrl_p

        self.min_value1 = min_value1_p
        self.max_value1 = max_value1_p

        self.min_value2 = min_value2_p
        self.max_value2 = max_value2_p

        self.time_shift = time_shift_p

    def save(self, filepath_p, csv_separator_p=';'):
        """
        save the configuration in a *.csv file
        :return:
        """
        filepath = filepath_p
        ctrl = self.ctrl

        min_value1 = self.min_value1
        max_value1 = self.max_value1

        min_value2 = self.min_value2
        max_value2 = self.max_value2

        time_shift = self.time_shift
        verbosity = self.verbosity

        fid = open(filepath, 'w')
        ###########################################################
        # write the header
        ###########################################################
        fid.write('rd_ctrl')
        fid.write(csv_separator_p)
        fid.write('min_value1')
        fid.write(csv_separator_p)
        fid.write('max_value1')
        fid.write(csv_separator_p)
        fid.write('min_value2')
        fid.write(csv_separator_p)
        fid.write('max_value2')
        fid.write(csv_separator_p)
        fid.write('time_shift')
        fid.write(csv_separator_p)
        fid.write('\n')

        ###########################################################
        # write data
        ###########################################################
        fid.write(str(ctrl))
        fid.write(csv_separator_p)

        fid.write(str(min_value1))
        fid.write(csv_separator_p)
        fid.write(str(max_value1))
        fid.write(csv_separator_p)

        fid.write(str(min_value2))
        fid.write(csv_separator_p)
        fid.write(str(max_value2))
        fid.write(csv_separator_p)

        fid.write(str(time_shift))
        fid.write('\n')
        fid.close()

        if verbosity >= 1:
            print('*' * 20)
            print('Sequencer : ' + self.name)
            print('filepath = {0}'.format(filepath))
