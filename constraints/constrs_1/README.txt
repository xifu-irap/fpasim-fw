To build the pin allocation associated ot the the FMC part, few *.csv files have been created (one by FMC column), the created files are:
    . fmc_pinout_col_a.csv
    . fmc_pinout_col_b.csv
    . fmc_pinout_col_c.csv
    . fmc_pinout_col_d.csv
    . fmc_pinout_col_e.csv
    . fmc_pinout_col_f.csv
    . fmc_pinout_col_g.csv
    . fmc_pinout_col_h.csv
    . fmc_pinout_col_j.csv
    . fmc_pinout_col_k.csv

Those *.csv files are constitued by 2 parts:
  . the FMC part
     . fmc_loc: column name (pin)
     . fmc_pin_name: user defined name of the wire/pin connected to the FMC pin
     . fmc_io_standard: io standard (the FPGA side must match it.)
  . the FPGA part
     . fpga_port_name: user defined name used on the VHDL top level
     . fpga_pin: fpga pin allocation
  . comment: commentary if needed

Note: 
   . if a new FPGA is used (new FPGA parts), the "fpga_pin" column needs to be updated.


The fmc_pinout_pandas.py python script read the *.csv files in order to generate the temporary "fmc_pinout_pandas_tmp.xdc" file.
This temporary output file is a modified pinout associated to the FMC.
With a data comparison software (file comparator), the user can check and overwrite overwrite the FMC part of the original pinout (xem7350.xdc) used by the Vivado project with the temporary one (fmc_pinout_pandas_tmp.xdc)

The "fmc_pinout_rename.py" python script is only used to modified the already defined name of the "fpga_port_name" column of the *.csv files. This python script is not normally used.