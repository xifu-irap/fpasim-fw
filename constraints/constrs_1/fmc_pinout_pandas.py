"""
"""
import pandas as pd


if __name__ == "__main__":
    base_address = './'
    input_filename_list = []
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


    output_filepath = base_address + 'fmc_pinout_pandas_tmp.xdc'
    fid_out = open(output_filepath,'w')
    
    # df list
    df_list = []
    # read csv files
    for filename in input_filename_list:
        filepath = base_address + filename
        df = pd.read_csv(filepath)
        df_list.append(df)
    # concatenate all dataframes
    df = pd.concat(df_list)

    # sort by fmc_loc
    df = df.sort_values(by="fmc_loc",ascending=True)
    # replace Na value by empty string
    df = df.fillna("")
    # retrieve each column
    fmc_loc_list = df["fmc_loc"]
    fmc_pin_name_list = df["fmc_pin_name"]
    fmc_io_standard_list = df["fmc_io_standard"]
    fpga_port_name_list = df["fpga_port_name"]
    fpga_pin_list = df["fpga_pin"]
    lines = []
    for fmc_loc,fmc_pin_name,fmc_io_standard,fpga_port_name,fpga_pin in zip(fmc_loc_list,fmc_pin_name_list,fmc_io_standard_list,fpga_port_name_list,fpga_pin_list):
        if fmc_pin_name == "":
            cmt = ""
        else:
            cmt = " # " + fmc_pin_name
            
        str0 =  "# FMC-"+ fmc_loc
        str1 = "set_property PACKAGE_PIN "+fpga_pin+ " [get_ports {"+fpga_port_name+"}]" + cmt
        str2 = "set_property IOSTANDARD "+fmc_io_standard+ " [get_ports {"+fpga_port_name+"}]" + cmt
        lines.append(str0)
        lines.append(str1)
        lines.append(str2)

    for str0 in lines:
        fid_out.write(str0 + '\n')

    fid_out.close()

        




