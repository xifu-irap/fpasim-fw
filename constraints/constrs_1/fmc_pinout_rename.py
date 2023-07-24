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
#   between fpga and fmc parameters (name, pin location,..) in order to modify the existing name with a new one.
#   only the names defined in the fpga_port_name column of the input csv files are affected.
#
#   Note:
#      . Each input csv files are associated to a FMC connector column.
#      . Tested with python : 3.10.7
#
#   Dependency:
#      . pandas library needs to be installed. tested with pandas 1.5.3
#
# -------------------------------------------------------------------------------------------------------------

import pandas as pd
from pathlib import Path


if __name__ == "__main__":
    # define the base address where to find the *.csv input files
    base_address = str(Path(__file__).parents[0]) # base path of this script
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

    # list tuple (old_name,new_name) to replace
    names_list = []
    names_list.append(('i_da10_p','i_cha_10_p'))
    names_list.append(('i_da10_n','i_cha_10_n'))

    names_list.append(('i_db4_p','i_chb_04_p'))
    names_list.append(('i_db4_n','i_chb_04_n'))

    names_list.append(('i_db12_p','i_chb_12_p'))
    names_list.append(('i_db12_n','i_chb_12_n'))

    names_list.append(('o_dac6_p','o_dac_d6_p'))
    names_list.append(('o_dac6_n','o_dac_d6_n'))

    # names_list.append(('o_mon_n_en','o_mon_n_en'))
    # names_list.append(('o_mon_n_reset','o_mon_n_reset'))

    names_list.append(('i_da0_p','i_cha_00_p'))
    names_list.append(('i_da0_n','i_cha_00_n'))

    names_list.append(('i_da8_p','i_cha_08_p'))
    names_list.append(('i_da8_n','i_cha_08_n'))

    names_list.append(('i_db2_p','i_chb_02_p'))
    names_list.append(('i_db2_n','i_chb_02_n'))

    names_list.append(('i_db10_p','i_chb_10_p'))
    names_list.append(('i_db10_n','i_chb_10_n'))

    names_list.append(('o_dac7_p','o_dac_d7_p'))
    names_list.append(('o_dac7_n','o_dac_d7_n'))

    names_list.append(('o_dac3_p','o_dac_d3_p'))
    names_list.append(('o_dac3_n','o_dac_d3_n'))

    names_list.append(('o_dac0_p','o_dac_d0_p'))
    names_list.append(('o_dac0_n','o_dac_d0_n'))

    names_list.append(('i_adc_clk_p','i_clk_ab_p'))
    names_list.append(('i_adc_clk_n','i_clk_ab_n'))

    names_list.append(('i_da4_p','i_cha_04_p'))
    names_list.append(('i_da4_n','i_cha_04_n'))

    names_list.append(('i_db0_p','i_chb_00_p'))
    names_list.append(('i_db0_n','i_chb_00_n'))

    names_list.append(('i_db8_p','i_chb_08_p'))
    names_list.append(('i_db8_n','i_chb_08_n'))

    # names_list.append(('o_adc_n_en','o_adc_n_en'))
    names_list.append(('o_dac_tx_present','o_tx_enable'))

    names_list.append(('o_dac4_p','o_dac_d4_p'))
    names_list.append(('o_dac4_n','o_dac_d4_n'))

    names_list.append(('o_dac_frame_p','o_frame_p'))
    names_list.append(('o_dac_frame_n','o_frame_n'))

    names_list.append(('o_dac1_p','o_dac_d1_p'))
    names_list.append(('o_dac1_n','o_dac_d1_n'))

    # names_list.append(('o_spi_sclk','o_spi_sclk'))
    # names_list.append(('o_spi_sdata','o_spi_sdata'))
    # names_list.append(('o_cdce_n_reset','o_cdce_n_reset'))
    # names_list.append(('o_cdce_n_pd','o_cdce_n_pd'))
    # names_list.append(('o_ref_en','o_ref_en'))
    names_list.append(('i_cdce_pll_status','i_pll_status'))

    names_list.append(('i_da2_p','i_cha_02_p'))
    names_list.append(('i_da2_n','i_cha_02_n'))

    names_list.append(('i_da6_p','i_cha_06_p'))
    names_list.append(('i_da6_n','i_cha_06_n'))

    names_list.append(('i_da12_p','i_cha_12_p'))
    names_list.append(('i_da12_n','i_cha_12_n'))

    names_list.append(('i_db6_p','i_chb_06_p'))
    names_list.append(('i_db6_n','i_chb_06_n'))

    # names_list.append(('i_adc_sdo','i_adc_sdo'))
    # names_list.append(('o_adc_reset','o_adc_reset'))

    names_list.append(('o_dac5_p','o_dac_d5_p'))
    names_list.append(('o_dac5_n','o_dac_d5_n'))

    names_list.append(('o_dac_clk_p','o_dac_dclk_p'))
    names_list.append(('o_dac_clk_n','o_dac_dclk_n'))

    names_list.append(('o_dac2_p','o_dac_d2_p'))
    names_list.append(('o_dac2_n','o_dac_d2_n'))

    # names_list.append(('o_dac_n_en','o_dac_n_en'))
    # names_list.append(('i_dac_sdo','i_dac_sdo'))
    # names_list.append(('o_cdce_n_en','o_cdce_n_en'))
    # names_list.append(('i_cdce_sdo','i_cdce_sdo'))
    # names_list.append(('i_mon_sdo','i_mon_sdo'))
    # names_list.append(('i_mon_n_int','i_mon_n_int'))

    #######################################################
    # build a list of pandas dataframe from the input files
    #######################################################
    df_list = []
    # read csv files
    for filename in input_filename_list:
        filepath = str(Path(base_address, filename))
        df = pd.read_csv(filepath, sep=';')
        # replace Na value by empty string
        df = df.fillna("")

        # get the column
        fpga_port_name_list = df["fpga_port_name"]

        res = []
        for i in range(len(fpga_port_name_list)):
            name = fpga_port_name_list[i]
            for old_name,new_name in names_list:
                if name == old_name:
                    name = new_name

            res.append(name)
        # overwrite the dataframe column with old_names replaces with new_name
        df["fpga_port_name"] = res 

        # 
        columns = []
        columns.append('fmc_loc')
        columns.append('fmc_pin_name')
        columns.append('fmc_io_standard')
        columns.append('fpga_port_name')
        columns.append('fpga_pin')
        columns.append('comment')
        df.to_csv(filepath,sep=';',index=False,columns=columns)

    