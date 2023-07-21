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
#    @file                   gen_random_amp_squid_tf.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    N/A
# -------------------------------------------------------------------------------------------------------------
#    @details  
#              
#    This script generates the random_amp_squid_tf.csv file with random values
#
#    Tested with python : 3.10.7
#
# -------------------------------------------------------------------------------------------------------------

from pathlib import Path
import random

def generate_random_int(output_filepath_p,ram_address_width_p,ram_data_width_p):
    """
        This function generates random int values

        Parameters
        ----------
        output_filepath_p: str
            output *.csv file
        ram_address_width_p: in
            address width of the ram (expressed in bits)
        ram_data_width_p: int
            data width of the ram (expressed in bits)

        Returns
        -------
            None

    """

    # Number of words in the RAM
    nb_data = 2**ram_address_width_p
    # max value in the ram
    max_value = 2**(ram_data_width_p - 1) - 1
    # min value in the RAM
    min_value = -2**(ram_data_width_p - 1)

    index_max = nb_data - 1
    with open(output_filepath_p,'w') as fid:
        for index in range(nb_data):
            if index == 0:
                fid.write('offset_addr_uint'+str(ram_address_width_p)+'_t')
                fid.write(csv_separator)
                fid.write('data_int'+str(ram_data_width_p)+'_t')
                fid.write('\n')
            # compute a random integer N such that min_value <= N <= max_value
            data = random.randint(min_value, max_value)
            str_line = str(data)

            fid.write(str(index))
            fid.write(csv_separator)
            fid.write(str_line)
            if index != index_max:
                fid.write('\n')

if __name__ == "__main__":

    # separator of the csv file
    csv_separator = ';'
    # define the base address where to find the *.csv input files
    base_address = str(Path(__file__).parents[0]) # base path of this script
    # output filename
    filename_out = 'random_amp_squid_tf.csv'
     # compute output filepath
    filepath_out = str(Path(base_address,filename_out))

    generate_random_int(output_filepath_p=filepath_out,ram_address_width_p=14,ram_data_width_p=16)
