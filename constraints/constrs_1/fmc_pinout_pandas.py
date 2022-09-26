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
#!   @file                   fmc_pinout_pandas.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference
# -------------------------------------------------------------------------------------------------------------
#!   @details
#
#   This scrips processes few input csv files which describes the relationship
#   between fpga and fmc parameters (name, pin location,..) in order to generate
#   an output xdc file associated to the fmc port definition.
#
#   Note:
#      . Each input csv files are associated to a column of the FMC connector.
#      . Tested with python : 3.10.7
#
# -------------------------------------------------------------------------------------------------------------

import pandas as pd


if __name__ == "__main__":
    # define the base address where to find the *.csv input files
    base_address = './'
    input_filename_list = []
    # list of the csv files associated to each column of the FMC
    input_filename_list.append('fmc_pinout_col_a.csv')
    input_filename_list.append('fmc_pinout_col_b.csv')
    input_filename_list.append('fmc_pinout_col_c.csv')
    input_filename_list.append('fmc_pinout_col_d.csv')
    input_filename_list.append('fmc_pinout_col_e.csv')
    input_filename_list.append('fmc_pinout_col_f.csv')
    input_filename_list.append('fmc_pinout_col_g.csv')
    input_filename_list.append('fmc_pinout_col_h.csv')
    input_filename_list.append('fmc_pinout_col_j.csv')
    input_filename_list.append('fmc_pinout_col_k.csv')

    # define the output xdc file associated to the processing of the input files
    output_filepath = base_address + 'fmc_pinout_pandas_tmp.xdc'
    fid_out = open(output_filepath, 'w')

    #######################################################
    # build a list of pandas dataframe from the input files
    #######################################################
    df_list = []
    # read csv files
    for filename in input_filename_list:
        filepath = base_address + filename
        df = pd.read_csv(filepath, sep=';')
        df_list.append(df)

    # concatenate all dataframes
    df = pd.concat(df_list)

    ######################################################
    # reorder the dataframe by fmc_loc
    # in order to match the order of the xdc file
    # provided by "Opal Kelly" company
    ######################################################
    # sort by fmc_loc
    df = df.sort_values(by="fmc_loc", ascending=True)
    # replace Na value by empty string
    df = df.fillna("")

    #####################################
    # column extraction of the dataframe
    #####################################
    fmc_loc_list = df["fmc_loc"]
    fmc_pin_name_list = df["fmc_pin_name"]
    fmc_io_standard_list = df["fmc_io_standard"]
    fpga_port_name_list = df["fpga_port_name"]
    fpga_pin_list = df["fpga_pin"]
    lines = []
    for fmc_loc, fmc_pin_name, fmc_io_standard, fpga_port_name, fpga_pin in zip(fmc_loc_list, fmc_pin_name_list, fmc_io_standard_list, fpga_port_name_list, fpga_pin_list):
        if fmc_pin_name == "":
            cmt = ""
        else:
            cmt = ";# " + fmc_pin_name

        if fpga_port_name == "":
            cmt0 = "# "
        else:
            cmt0 = ""

        # build the xdc commands
        #################################
        str0 = "# FMC-" + fmc_loc
        str1 = "set_property PACKAGE_PIN "+fpga_pin + \
            " [get_ports {"+fpga_port_name+"}]" + cmt
        str2 = "set_property IOSTANDARD " + fmc_io_standard + \
            " [get_ports {"+fpga_port_name+"}]" + cmt
        lines.append(str0)
        lines.append(cmt0 + str1)
        lines.append(cmt0 + str2)

    ###################################
    # write the pre-computed commands in files
    ###################################
    for str0 in lines:
        fid_out.write(str0 + '\n')

    fid_out.close()
