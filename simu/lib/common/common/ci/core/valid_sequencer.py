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
#    
#    This ValidSequencer class provides methods to generate an output csv file in order to
#    configure the VHDL pkg_valid_sequencer procedure (see common/vhdl/src/pkg_sequencer/pkg_sequence.vhd)
#
#     Note: 
#       . The first pulse can be delayed by a certain amount defined by time_shift value
#       . Used for the VHDL simulation.
#       . This script was tested with python 3.10
#
# -------------------------------------------------------------------------------------------------------------

# standard library
import os


class ValidSequencer:
    """
    This class provides methods to generate an output csv file in order to
    configure the VHDL pkg_valid_sequencer procedure.
    """

    def __init__(self, name_p):
        """
        Initialize the class instance.

        Parameters
        ----------
        name_p: str
            sequence name
        """

        self._name = name_p
        # define the mode
        self._ctrl = None
        # define the first (min_value, max_value)
        self._min_value1 = None
        self._max_value1 = None
        # define the second (min_value, max_value)
        self._min_value2 = None
        self._max_value2 = None
        # set the number of clock cycle before starting the generation
        self._time_shift = None
        # set the level of verbosity
        self._verbosity = 0

    def set_verbosity(self, verbosity_p):
        """
        Set the level of verbosity.

        Parameters
        ----------
        verbosity_p: int
            (integer >=0) level of verbosity.

        Returns
        -------
        None

        """
        self._verbosity = verbosity_p
        return None

    def set_sequence(self, ctrl_p, min_value1_p, max_value1_p, min_value2_p, max_value2_p, time_shift_p=0):
        """
        Define the mode of pulse generation.

        Parameters
        ----------
        ctrl_p: int
            define the mode of pulse generation. The possibles values are:
            .0: continuous valid generation.
                . min_value1_p, max_value1_p, min_value2_p, max_value2_p values are ignored.
            .1. constant short pulse generation.
                . a positive pulse with a width of 1 clock cycle followed by
                . a negative pulse with a constant width defined by the min_value2_p value.
            .2. constant pulse generation.
                . a positive pulse with a width defined by the min_value1_p value followed by
                . a negative pulse with a width defined by the min_value2_p value.
            .3: random short pulse generation.
                . a positive pulse with a width of 1 clock cycle followed by
                . a negative pulse with a random width between min_value2_p and max_value2_p.
            .4. random pulse generation.
                . a positive pulse with a width defined by a random value between min_value1_p and max_value1_p followed by
                . a negative pulse with a width defined by a random value between min_value2_p and max_value2_p.
            others values : continuous valid generation
        min_value1_p: int
            define the min value for the positive pulse.
        max_value1_p: int
            define the max value for the positive pulse.
        min_value2_p: int
            define the min value for the negative pulse.
        max_value2_p: int
            define the min value for the negative pulse.
        time_shift_p: int
            define the number of clock cycles to skip before generating the pulses.

        Returns
        -------
            None

        """
        self._ctrl = ctrl_p

        self._min_value1 = min_value1_p
        self._max_value1 = max_value1_p

        self._min_value2 = min_value2_p
        self._max_value2 = max_value2_p

        self._time_shift = time_shift_p

        return None

    def save(self, filepath_p, csv_separator_p=';'):
        """
        Save the result in an output file.

        Parameters
        ----------
        filepath_p: str
            Define the filepath of the output *.csv file.
        csv_separator_p: str
            Define the separator of the csv file.

        Returns
        -------
            None

        """
        filepath = filepath_p
        ctrl = self._ctrl

        min_value1 = self._min_value1
        max_value1 = self._max_value1

        min_value2 = self._min_value2
        max_value2 = self._max_value2

        time_shift = self._time_shift
        verbosity = self._verbosity

        with open(filepath, 'w') as fid:
            ###########################################################
            # write the header (column names)
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

        if verbosity >= 1:
            print('*' * 20)
            print('Sequencer : ' + self._name)
            print('filepath = {0}'.format(filepath))

        return None
