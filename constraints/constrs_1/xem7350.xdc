############################################################################
# XEM7350 - Xilinx constraints file
#
# Pin mappings for the XEM7350.  Use this as a template and comment out 
# the pins that are not used in your design.  (By default, map will fail
# if this file contains constraints for signals not in your design).
#
# Copyright (c) 2004-2014 Opal Kelly Incorporated
#
#
# requirement: FPASIM-FW-REQ-0040 (applicable to the file)
############################################################################


set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS True [current_design]

############################################################################
## FrontPanel Host Interface
############################################################################
set_property PACKAGE_PIN F23 [get_ports {o_okHU[0]}]
set_property PACKAGE_PIN H23 [get_ports {o_okHU[1]}]
set_property PACKAGE_PIN J25 [get_ports {o_okHU[2]}]
set_property SLEW FAST [get_ports {o_okHU[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {o_okHU[*]}]

set_property PACKAGE_PIN F22 [get_ports {i_okUH[0]}]
set_property PACKAGE_PIN G24 [get_ports {i_okUH[1]}]
set_property PACKAGE_PIN J26 [get_ports {i_okUH[2]}]
set_property PACKAGE_PIN G26 [get_ports {i_okUH[3]}]
set_property PACKAGE_PIN C23 [get_ports {i_okUH[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {i_okUH[*]}]

set_property PACKAGE_PIN B21 [get_ports {b_okUHU[0]}]
set_property PACKAGE_PIN C21 [get_ports {b_okUHU[1]}]
set_property PACKAGE_PIN E22 [get_ports {b_okUHU[2]}]
set_property PACKAGE_PIN A20 [get_ports {b_okUHU[3]}]
set_property PACKAGE_PIN B20 [get_ports {b_okUHU[4]}]
set_property PACKAGE_PIN C22 [get_ports {b_okUHU[5]}]
set_property PACKAGE_PIN D21 [get_ports {b_okUHU[6]}]
set_property PACKAGE_PIN C24 [get_ports {b_okUHU[7]}]
set_property PACKAGE_PIN C26 [get_ports {b_okUHU[8]}]
set_property PACKAGE_PIN D26 [get_ports {b_okUHU[9]}]
set_property PACKAGE_PIN A24 [get_ports {b_okUHU[10]}]
set_property PACKAGE_PIN A23 [get_ports {b_okUHU[11]}]
set_property PACKAGE_PIN A22 [get_ports {b_okUHU[12]}]
set_property PACKAGE_PIN B22 [get_ports {b_okUHU[13]}]
set_property PACKAGE_PIN A25 [get_ports {b_okUHU[14]}]
set_property PACKAGE_PIN B24 [get_ports {b_okUHU[15]}]
set_property PACKAGE_PIN G21 [get_ports {b_okUHU[16]}]
set_property PACKAGE_PIN E23 [get_ports {b_okUHU[17]}]
set_property PACKAGE_PIN E21 [get_ports {b_okUHU[18]}]
set_property PACKAGE_PIN H22 [get_ports {b_okUHU[19]}]
set_property PACKAGE_PIN D23 [get_ports {b_okUHU[20]}]
set_property PACKAGE_PIN J21 [get_ports {b_okUHU[21]}]
set_property PACKAGE_PIN K22 [get_ports {b_okUHU[22]}]
set_property PACKAGE_PIN D24 [get_ports {b_okUHU[23]}]
set_property PACKAGE_PIN K23 [get_ports {b_okUHU[24]}]
set_property PACKAGE_PIN H24 [get_ports {b_okUHU[25]}]
set_property PACKAGE_PIN F24 [get_ports {b_okUHU[26]}]
set_property PACKAGE_PIN D25 [get_ports {b_okUHU[27]}]
set_property PACKAGE_PIN J24 [get_ports {b_okUHU[28]}]
set_property PACKAGE_PIN B26 [get_ports {b_okUHU[29]}]
set_property PACKAGE_PIN H26 [get_ports {b_okUHU[30]}]
set_property PACKAGE_PIN E26 [get_ports {b_okUHU[31]}]
set_property SLEW FAST [get_ports {b_okUHU[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {b_okUHU[*]}]

set_property PACKAGE_PIN R26 [get_ports b_okAA]
set_property IOSTANDARD LVCMOS33 [get_ports b_okAA]


############################################################################
## System Clock
############################################################################
# set_property IOSTANDARD LVDS [get_ports {sys_clkp}]
# set_property PACKAGE_PIN AC4 [get_ports {sys_clkp}]

# set_property IOSTANDARD LVDS [get_ports {sys_clkn}]
# set_property PACKAGE_PIN AC3 [get_ports {sys_clkn}]



############################################################################
## User Reset
############################################################################
# set_property PACKAGE_PIN G22 [get_ports {i_reset}]
# set_property IOSTANDARD LVCMOS18 [get_ports {i_reset}]
# set_property SLEW FAST [get_ports {i_reset}]


# FMC-A1 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A10 
# set_property PACKAGE_PIN B6 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A11 
# set_property PACKAGE_PIN B5 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A12 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A13 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A14 
# set_property PACKAGE_PIN R4 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A15 
# set_property PACKAGE_PIN R3 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A16 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A17 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A18 
# set_property PACKAGE_PIN N4 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A19 
# set_property PACKAGE_PIN N3 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A2 
# set_property PACKAGE_PIN E4 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A20 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A21 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A22 
# set_property PACKAGE_PIN D2 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A23 
# set_property PACKAGE_PIN D1 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A24 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A25 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A26 
# set_property PACKAGE_PIN B2 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A27 
# set_property PACKAGE_PIN B1 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A28 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A29 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A3 
# set_property PACKAGE_PIN E3 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A30 
# set_property PACKAGE_PIN A4 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A31 
# set_property PACKAGE_PIN A3 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A32 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A33 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A34 
# set_property PACKAGE_PIN P2 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A35 
# set_property PACKAGE_PIN P1 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A36 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A37 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A38 
# set_property PACKAGE_PIN M2 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A39 
# set_property PACKAGE_PIN M1 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A4 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A40 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A5 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A6 
# set_property PACKAGE_PIN C4 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A7 
# set_property PACKAGE_PIN C3 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A8 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-A9 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B1 
# set_property PACKAGE_PIN M26 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B10 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B11 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B12 
# set_property PACKAGE_PIN J4 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B13 
# set_property PACKAGE_PIN J3 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B14 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B15 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B16 
# set_property PACKAGE_PIN L4 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B17 
# set_property PACKAGE_PIN L3 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B18 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B19 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B2 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B20 
# set_property PACKAGE_PIN H6 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B21 
# set_property PACKAGE_PIN H5 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B22 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B23 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B26 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B27 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B3 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B30 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B31 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B32 
# set_property PACKAGE_PIN H2 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B33 
# set_property PACKAGE_PIN H1 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B34 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B35 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B36 
# set_property PACKAGE_PIN K2 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B37 
# set_property PACKAGE_PIN K1 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B38 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B39 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B6 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-B7 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-C1 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-C10
set_property PACKAGE_PIN C19 [get_ports {i_cha_10_p}];# CHA_10_P
set_property IOSTANDARD LVDS_25 [get_ports {i_cha_10_p}];# CHA_10_P
# FMC-C11
set_property PACKAGE_PIN B19 [get_ports {i_cha_10_n}];# CHA_10_N
set_property IOSTANDARD LVDS_25 [get_ports {i_cha_10_n}];# CHA_10_N
# FMC-C12
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-C13 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-C14
set_property PACKAGE_PIN B17 [get_ports {i_chb_04_p}];# CHB_04_P
set_property IOSTANDARD LVDS_25 [get_ports {i_chb_04_p}];# CHB_04_P
# FMC-C15
set_property PACKAGE_PIN A17 [get_ports {i_chb_04_n}];# CHB_04_N
set_property IOSTANDARD LVDS_25 [get_ports {i_chb_04_n}];# CHB_04_N
# FMC-C16
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-C17 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-C18
set_property PACKAGE_PIN H16 [get_ports {i_chb_12_p}];# CHB_12_P
set_property IOSTANDARD LVDS_25 [get_ports {i_chb_12_p}];# CHB_12_P
# FMC-C19
set_property PACKAGE_PIN G16 [get_ports {i_chb_12_n}];# CHB_12_N
set_property IOSTANDARD LVDS_25 [get_ports {i_chb_12_n}];# CHB_12_N
# FMC-C2
# set_property PACKAGE_PIN F2 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-C20 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-C21 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-C22
set_property PACKAGE_PIN F17 [get_ports {o_dac_d6_p}];# DAC_D6_P
set_property IOSTANDARD LVDS_25 [get_ports {o_dac_d6_p}];# DAC_D6_P
# FMC-C23
set_property PACKAGE_PIN E17 [get_ports {o_dac_d6_n}];# DAC_D6_N
set_property IOSTANDARD LVDS_25 [get_ports {o_dac_d6_n}];# DAC_D6_N
# FMC-C24
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-C25 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-C26 
set_property PACKAGE_PIN D9 [get_ports {o_mon_n_en}];# MON_N_EN
set_property IOSTANDARD LVCMOS25 [get_ports {o_mon_n_en}];# MON_N_EN
# FMC-C27 
set_property PACKAGE_PIN D8 [get_ports {o_mon_n_reset}];# MON_N_RESET
set_property IOSTANDARD LVCMOS25 [get_ports {o_mon_n_reset}];# MON_N_RESET
# FMC-C28 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-C29 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-C3 
# set_property PACKAGE_PIN F1 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-C30 
# set_property PACKAGE_PIN  [get_ports {}];# I2C_SCL
# set_property IOSTANDARD LVCMOS25 [get_ports {}];# I2C_SCL
# FMC-C31 
# set_property PACKAGE_PIN  [get_ports {}];# i2C_SDA
# set_property IOSTANDARD LVCMOS25 [get_ports {}];# i2C_SDA
# FMC-C32 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-C33 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-C34 
# set_property PACKAGE_PIN  [get_ports {}];# GA0
# set_property IOSTANDARD  [get_ports {}];# GA0
# FMC-C35 
# set_property PACKAGE_PIN  [get_ports {}];# 12V
# set_property IOSTANDARD  [get_ports {}];# 12V
# FMC-C36 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-C37 
# set_property PACKAGE_PIN  [get_ports {}];# 12V
# set_property IOSTANDARD  [get_ports {}];# 12V
# FMC-C38 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-C39 
# set_property PACKAGE_PIN  [get_ports {}];# 3.3V
# set_property IOSTANDARD  [get_ports {}];# 3.3V
# FMC-C4 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-C40 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-C5 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-C6 
# set_property PACKAGE_PIN G4 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-C7 
# set_property PACKAGE_PIN G3 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-C8 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-C9 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-D1 
# set_property PACKAGE_PIN  [get_ports {}];# PG_C2M
# set_property IOSTANDARD  [get_ports {}];# PG_C2M
# FMC-D10 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-D11
set_property PACKAGE_PIN C17 [get_ports {i_cha_08_p}];# CHA_08_P
set_property IOSTANDARD LVDS_25 [get_ports {i_cha_08_p}];# CHA_08_P
# FMC-D12
set_property PACKAGE_PIN C18 [get_ports {i_cha_08_n}];# CHA_08_N
set_property IOSTANDARD LVDS_25 [get_ports {i_cha_08_n}];# CHA_08_N
# FMC-D13
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-D14
set_property PACKAGE_PIN L19 [get_ports {i_chb_02_p}];# CHB_02_P
set_property IOSTANDARD LVDS_25 [get_ports {i_chb_02_p}];# CHB_02_P
# FMC-D15
set_property PACKAGE_PIN L20 [get_ports {i_chb_02_n}];# CHB_02_N
set_property IOSTANDARD LVDS_25 [get_ports {i_chb_02_n}];# CHB_02_N
# FMC-D16
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-D17
set_property PACKAGE_PIN E15 [get_ports {i_chb_10_p}];# CHB_10_P
set_property IOSTANDARD LVDS_25 [get_ports {i_chb_10_p}];# CHB_10_P
# FMC-D18
set_property PACKAGE_PIN E16 [get_ports {i_chb_10_n}];# CHB_10_N
set_property IOSTANDARD LVDS_25 [get_ports {i_chb_10_n}];# CHB_10_N
# FMC-D19
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-D2 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-D20
set_property PACKAGE_PIN E10 [get_ports {o_dac_d7_p}];# DAC_D7_P
set_property IOSTANDARD LVDS_25 [get_ports {o_dac_d7_p}];# DAC_D7_P
# FMC-D21
set_property PACKAGE_PIN D10 [get_ports {o_dac_d7_n}];# DAC_D7_N
set_property IOSTANDARD LVDS_25 [get_ports {o_dac_d7_n}];# DAC_D7_N
# FMC-D22
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-D23
set_property PACKAGE_PIN F14 [get_ports {o_dac_d3_p}];# DAC_D3_P
set_property IOSTANDARD LVDS_25 [get_ports {o_dac_d3_p}];# DAC_D3_P
# FMC-D24
set_property PACKAGE_PIN F13 [get_ports {o_dac_d3_n}];# DAC_D3_N
set_property IOSTANDARD LVDS_25 [get_ports {o_dac_d3_n}];# DAC_D3_N
# FMC-D25
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-D26
set_property PACKAGE_PIN C9 [get_ports {o_dac_d0_p}];# DAC_D0_P
set_property IOSTANDARD LVDS_25 [get_ports {o_dac_d0_p}];# DAC_D0_P
# FMC-D27
set_property PACKAGE_PIN B9 [get_ports {o_dac_d0_n}];# DAC_D0_N
set_property IOSTANDARD LVDS_25 [get_ports {o_dac_d0_n}];# DAC_D0_N
# FMC-D28
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-D29 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-D3 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-D30 
# set_property PACKAGE_PIN  [get_ports {}];# TDI2TDO
# set_property IOSTANDARD  [get_ports {}];# TDI2TDO
# FMC-D31 
# set_property PACKAGE_PIN  [get_ports {}];# TDI2TDO
# set_property IOSTANDARD  [get_ports {}];# TDI2TDO
# FMC-D32 
# set_property PACKAGE_PIN  [get_ports {}];# 3.3V Aux
# set_property IOSTANDARD  [get_ports {}];# 3.3V Aux
# FMC-D33 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-D34 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-D35 
# set_property PACKAGE_PIN  [get_ports {}];# GA1
# set_property IOSTANDARD  [get_ports {}];# GA1
# FMC-D36 
# set_property PACKAGE_PIN  [get_ports {}];# 3.3V
# set_property IOSTANDARD  [get_ports {}];# 3.3V
# FMC-D37 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-D38 
# set_property PACKAGE_PIN  [get_ports {}];# 3.3V
# set_property IOSTANDARD  [get_ports {}];# 3.3V
# FMC-D39 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-D4 
# set_property PACKAGE_PIN D6 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-D40 
# set_property PACKAGE_PIN  [get_ports {}];# 3.3V
# set_property IOSTANDARD  [get_ports {}];# 3.3V
# FMC-D5 
# set_property PACKAGE_PIN D5 [get_ports {}];# 1
# set_property IOSTANDARD  [get_ports {}];# 1
# FMC-D6 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-D7 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-D8
set_property PACKAGE_PIN G17 [get_ports {i_cha_00_p}];# CHA_00_P
set_property IOSTANDARD LVDS_25 [get_ports {i_cha_00_p}];# CHA_00_P
# FMC-D9
set_property PACKAGE_PIN F18 [get_ports {i_cha_00_n}];# CHA_00_N
set_property IOSTANDARD LVDS_25 [get_ports {i_cha_00_n}];# CHA_00_N
# FMC-E1
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E10 
# set_property PACKAGE_PIN AE26 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E11 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E12 
# set_property PACKAGE_PIN Y25 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E13 
# set_property PACKAGE_PIN Y26 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E14 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E15 
# set_property PACKAGE_PIN U26 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E16 
# set_property PACKAGE_PIN V26 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E17 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E18 
# set_property PACKAGE_PIN U22 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E19 
# set_property PACKAGE_PIN V22 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E2 
# set_property PACKAGE_PIN Y23 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E20 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E21 
# set_property PACKAGE_PIN V16 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E22 
# set_property PACKAGE_PIN V17 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E23 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E24 
# set_property PACKAGE_PIN V14 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E25 
# set_property PACKAGE_PIN W14 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E26 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E27 
# set_property PACKAGE_PIN AA19 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E28 
# set_property PACKAGE_PIN AA20 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E29 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E3 
# set_property PACKAGE_PIN AA24 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E30 
# set_property PACKAGE_PIN AB14 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E31 
# set_property PACKAGE_PIN AB15 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E32 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E33 
# set_property PACKAGE_PIN AC19 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E34 
# set_property PACKAGE_PIN AD19 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E35 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E36 
# set_property PACKAGE_PIN AE18 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E37 
# set_property PACKAGE_PIN AF18 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E38 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E39 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E4 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E40 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E5 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E6 
# set_property PACKAGE_PIN W23 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E7 
# set_property PACKAGE_PIN W24 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E8 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-E9 
# set_property PACKAGE_PIN AD26 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F1 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F10 
# set_property PACKAGE_PIN AB26 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F11 
# set_property PACKAGE_PIN AC26 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F12 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F13 
# set_property PACKAGE_PIN W25 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F14 
# set_property PACKAGE_PIN W26 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F15 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F16 
# set_property PACKAGE_PIN U24 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F17 
# set_property PACKAGE_PIN U25 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F18 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F19 
# set_property PACKAGE_PIN AB21 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F2 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F20 
# set_property PACKAGE_PIN AC21 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F21 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F22 
# set_property PACKAGE_PIN V18 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F23 
# set_property PACKAGE_PIN V19 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F24 
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F25 
# set_property PACKAGE_PIN W18 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F26 
# set_property PACKAGE_PIN W19 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F27
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F28
# set_property PACKAGE_PIN AD15 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F29
# set_property PACKAGE_PIN AE15 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F3
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F30
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F31
# set_property PACKAGE_PIN AC14 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F32
# set_property PACKAGE_PIN AD14 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F33
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F34
# set_property PACKAGE_PIN AF14 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F35
# set_property PACKAGE_PIN AF15 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F36
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F37
# set_property PACKAGE_PIN AF19 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F38
# set_property PACKAGE_PIN AF20 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F39
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F4
# set_property PACKAGE_PIN Y22 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F40
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F5
# set_property PACKAGE_PIN AA22 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F6
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F7
# set_property PACKAGE_PIN AF24 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F8
# set_property PACKAGE_PIN AF25 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-F9
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-G1
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-G10
set_property PACKAGE_PIN A19 [get_ports {i_cha_04_n}];# CHA_04_N
set_property IOSTANDARD LVDS_25 [get_ports {i_cha_04_n}];# CHA_04_N
# FMC-G11
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-G12
set_property PACKAGE_PIN F19 [get_ports {i_chb_00_p}];# CHB_00_P
set_property IOSTANDARD LVDS_25 [get_ports {i_chb_00_p}];# CHB_00_P
# FMC-G13
set_property PACKAGE_PIN E20 [get_ports {i_chb_00_n}];# CHB_00_N
set_property IOSTANDARD LVDS_25 [get_ports {i_chb_00_n}];# CHB_00_N
# FMC-G14
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-G15
set_property PACKAGE_PIN H19 [get_ports {i_chb_08_p}];# CHB_08_P
set_property IOSTANDARD LVDS_25 [get_ports {i_chb_08_p}];# CHB_08_P
# FMC-G16
set_property PACKAGE_PIN G20 [get_ports {i_chb_08_n}];# CHB_08_N
set_property IOSTANDARD LVDS_25 [get_ports {i_chb_08_n}];# CHB_08_N
# FMC-G17
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-G18
set_property PACKAGE_PIN A9 [get_ports {o_adc_n_en}];# ADC_N_EN
set_property IOSTANDARD LVCMOS25 [get_ports {o_adc_n_en}];# ADC_N_EN
# FMC-G19
set_property PACKAGE_PIN A8 [get_ports {o_tx_enable}];# TXENABLE
set_property IOSTANDARD LVCMOS25 [get_ports {o_tx_enable}];# TXENABLE
# FMC-G2
# set_property PACKAGE_PIN E11 [get_ports {}];# EXT_TRIGGER_P
# set_property IOSTANDARD LVDS_25 [get_ports {}];# EXT_TRIGGER_P
# FMC-G20
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-G21
set_property PACKAGE_PIN L17 [get_ports {o_dac_d4_p}];# DAC_D4_P
set_property IOSTANDARD LVDS_25 [get_ports {o_dac_d4_p}];# DAC_D4_P
# FMC-G22
set_property PACKAGE_PIN K18 [get_ports {o_dac_d4_n}];# DAC_D4_N
set_property IOSTANDARD LVDS_25 [get_ports {o_dac_d4_n}];# DAC_D4_N
# FMC-G23
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-G24
set_property PACKAGE_PIN G11 [get_ports {o_frame_p}];# FRAME_P
set_property IOSTANDARD LVDS_25 [get_ports {o_frame_p}];# FRAME_P
# FMC-G25
set_property PACKAGE_PIN F10 [get_ports {o_frame_n}];# FRAME_N
set_property IOSTANDARD LVDS_25 [get_ports {o_frame_n}];# FRAME_N
# FMC-G26
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-G27
set_property PACKAGE_PIN J15 [get_ports {o_dac_d1_p}];# DAC_D1_P
set_property IOSTANDARD LVDS_25 [get_ports {o_dac_d1_p}];# DAC_D1_P
# FMC-G28
set_property PACKAGE_PIN J16 [get_ports {o_dac_d1_n}];# DAC_D1_N
set_property IOSTANDARD LVDS_25 [get_ports {o_dac_d1_n}];# DAC_D1_N
# FMC-G29
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-G3
# set_property PACKAGE_PIN D11 [get_ports {}];# EXT_TRIGGER_N
# set_property IOSTANDARD LVDS_25 [get_ports {}];# EXT_TRIGGER_N
# FMC-G30
set_property PACKAGE_PIN J13 [get_ports {o_spi_sclk}];# SPI_SCLK
set_property IOSTANDARD LVCMOS25 [get_ports {o_spi_sclk}];# SPI_SCLK
# FMC-G31
set_property PACKAGE_PIN H13 [get_ports {o_spi_sdata}];# SPI_DATA
set_property IOSTANDARD LVCMOS25 [get_ports {o_spi_sdata}];# SPI_DATA
# FMC-G32
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-G33
set_property PACKAGE_PIN J11 [get_ports {o_cdce_n_reset}];# CDCE_N_RESET
set_property IOSTANDARD LVCMOS25 [get_ports {o_cdce_n_reset}];# CDCE_N_RESET
# FMC-G34
set_property PACKAGE_PIN J10 [get_ports {o_cdce_n_pd}];# CDCE_N_PD
set_property IOSTANDARD LVCMOS25 [get_ports {o_cdce_n_pd}];# CDCE_N_PD
# FMC-G35
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-G36
set_property PACKAGE_PIN F9 [get_ports {o_ref_en}];# REF_EN
set_property IOSTANDARD LVCMOS25 [get_ports {o_ref_en}];# REF_EN
# FMC-G37
set_property PACKAGE_PIN F8 [get_ports {i_pll_status}];# PLL_STATUS
set_property IOSTANDARD LVCMOS25 [get_ports {i_pll_status}];# PLL_STATUS
# FMC-G38
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-G39
# set_property PACKAGE_PIN  [get_ports {}];# VADJ
# set_property IOSTANDARD  [get_ports {}];# VADJ
# FMC-G4
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-G40
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-G5
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-G6
set_property PACKAGE_PIN H17 [get_ports {i_clk_ab_p}];# CLK_AB_P
set_property IOSTANDARD LVDS_25 [get_ports {i_clk_ab_p}];# CLK_AB_P
# FMC-G7
set_property PACKAGE_PIN H18 [get_ports {i_clk_ab_n}];# CLK_AB_N
set_property IOSTANDARD LVDS_25 [get_ports {i_clk_ab_n}];# CLK_AB_N
# FMC-G8
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-G9
set_property PACKAGE_PIN A18 [get_ports {i_cha_04_p}];# CHA_04_P
set_property IOSTANDARD LVDS_25 [get_ports {i_cha_04_p}];# CHA_04_P
# FMC-H1
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-H10
set_property PACKAGE_PIN D19 [get_ports {i_cha_06_p}];# CHA_06_P
set_property IOSTANDARD LVDS_25 [get_ports {i_cha_06_p}];# CHA_06_P
# FMC-H11
set_property PACKAGE_PIN D20 [get_ports {i_cha_06_n}];# CHA_06_N
set_property IOSTANDARD LVDS_25 [get_ports {i_cha_06_n}];# CHA_06_N
# FMC-H12
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-H13
set_property PACKAGE_PIN J18 [get_ports {i_cha_12_p}];# CHA_12_P
set_property IOSTANDARD LVDS_25 [get_ports {i_cha_12_p}];# CHA_12_P
# FMC-H14
set_property PACKAGE_PIN J19 [get_ports {i_cha_12_n}];# CHA_12_N
set_property IOSTANDARD LVDS_25 [get_ports {i_cha_12_n}];# CHA_12_N
# FMC-H15
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-H16
set_property PACKAGE_PIN C16 [get_ports {i_chb_06_p}];# CHB_06_P
set_property IOSTANDARD LVDS_25 [get_ports {i_chb_06_p}];# CHB_06_P
# FMC-H17
set_property PACKAGE_PIN B16 [get_ports {i_chb_06_n}];# CHB_06_N
set_property IOSTANDARD LVDS_25 [get_ports {i_chb_06_n}];# CHB_06_N
# FMC-H18
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-H19
set_property PACKAGE_PIN K16 [get_ports {i_adc_sdo}];# ADC_SDO
set_property IOSTANDARD LVCMOS25 [get_ports {i_adc_sdo}];# ADC_SDO
# FMC-H2
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-H20
set_property PACKAGE_PIN K17 [get_ports {o_adc_reset}];# ADC_RESET
set_property IOSTANDARD LVCMOS25 [get_ports {o_adc_reset}];# ADC_RESET
# FMC-H21
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-H22
set_property PACKAGE_PIN M17 [get_ports {o_dac_d5_p}];# DAC_D5_P
set_property IOSTANDARD LVDS_25 [get_ports {o_dac_d5_p}];# DAC_D5_P
# FMC-H23
set_property PACKAGE_PIN L18 [get_ports {o_dac_d5_n}];# DAC_D5_N
set_property IOSTANDARD LVDS_25 [get_ports {o_dac_d5_n}];# DAC_D5_N
# FMC-H24
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-H25
set_property PACKAGE_PIN G15 [get_ports {o_dac_dclk_p}];# DAC_DCLK_P
set_property IOSTANDARD LVDS_25 [get_ports {o_dac_dclk_p}];# DAC_DCLK_P
# FMC-H26
set_property PACKAGE_PIN F15 [get_ports {o_dac_dclk_n}];# DAC_DCLK_N
set_property IOSTANDARD LVDS_25 [get_ports {o_dac_dclk_n}];# DAC_DCLK_N
# FMC-H27
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-H28
set_property PACKAGE_PIN H14 [get_ports {o_dac_d2_p}];# DAC_D2_P
set_property IOSTANDARD LVDS_25 [get_ports {o_dac_d2_p}];# DAC_D2_P
# FMC-H29
set_property PACKAGE_PIN G14 [get_ports {o_dac_d2_n}];# DAC_D2_N
set_property IOSTANDARD LVDS_25 [get_ports {o_dac_d2_n}];# DAC_D2_N
# FMC-H3
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-H30
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-H31
set_property PACKAGE_PIN G12 [get_ports {o_dac_n_en}];# DAC_N_EN
set_property IOSTANDARD LVCMOS25 [get_ports {o_dac_n_en}];# DAC_N_EN
# FMC-H32
set_property PACKAGE_PIN F12 [get_ports {i_dac_sdo}];# DAC_SDO
set_property IOSTANDARD LVCMOS25 [get_ports {i_dac_sdo}];# DAC_SDO
# FMC-H33
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-H34
set_property PACKAGE_PIN G10 [get_ports {o_cdce_n_en}];# CDCE_N_EN
set_property IOSTANDARD LVCMOS25 [get_ports {o_cdce_n_en}];# CDCE_N_EN
# FMC-H35
set_property PACKAGE_PIN G9 [get_ports {i_cdce_sdo}];# CDCE_SDO
set_property IOSTANDARD LVCMOS25 [get_ports {i_cdce_sdo}];# CDCE_SDO
# FMC-H36
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-H37
set_property PACKAGE_PIN H9 [get_ports {i_mon_sdo}];# MON_SDO
set_property IOSTANDARD LVCMOS25 [get_ports {i_mon_sdo}];# MON_SDO
# FMC-H38
set_property PACKAGE_PIN H8 [get_ports {i_mon_n_int}];# MON_N_INIT
set_property IOSTANDARD LVCMOS25 [get_ports {i_mon_n_int}];# MON_N_INIT
# FMC-H39
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-H4
# set_property PACKAGE_PIN E18 [get_ports {}];# CLK_TO_FPGA_P
# set_property IOSTANDARD LVDS_25 [get_ports {}];# CLK_TO_FPGA_P
# FMC-H40
# set_property PACKAGE_PIN  [get_ports {}];# VADJ
# set_property IOSTANDARD  [get_ports {}];# VADJ
# FMC-H5
# set_property PACKAGE_PIN D18 [get_ports {}];# CLK_TO_FPGA_N
# set_property IOSTANDARD LVDS_25 [get_ports {}];# CLK_TO_FPGA_N
# FMC-H6
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-H7
set_property PACKAGE_PIN G19 [get_ports {i_cha_02_p}];# CHA_02_P
set_property IOSTANDARD LVDS_25 [get_ports {i_cha_02_p}];# CHA_02_P
# FMC-H8
set_property PACKAGE_PIN F20 [get_ports {i_cha_02_n}];# CHA_02_N
set_property IOSTANDARD LVDS_25 [get_ports {i_cha_02_n}];# CHA_02_N
# FMC-H9
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J1
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J10
# set_property PACKAGE_PIN AE25 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J11
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J12
# set_property PACKAGE_PIN AA25 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J13
# set_property PACKAGE_PIN AB25 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J14
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J15
# set_property PACKAGE_PIN V23 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J16
# set_property PACKAGE_PIN V24 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J17
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J18
# set_property PACKAGE_PIN AD21 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J19
# set_property PACKAGE_PIN AE21 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J2
# set_property PACKAGE_PIN AB16 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J20
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J21
# set_property PACKAGE_PIN V21 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J22
# set_property PACKAGE_PIN W21 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J23
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J24
# set_property PACKAGE_PIN Y17 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J25
# set_property PACKAGE_PIN Y18 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J26
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J27
# set_property PACKAGE_PIN W15 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J28
# set_property PACKAGE_PIN W16 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J29
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J3
# set_property PACKAGE_PIN AC16 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J30
# set_property PACKAGE_PIN AA14 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J31
# set_property PACKAGE_PIN AA15 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J32
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J33
# set_property PACKAGE_PIN AB19 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J34
# set_property PACKAGE_PIN AB20 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J35
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J36
# set_property PACKAGE_PIN AD20 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J37
# set_property PACKAGE_PIN AE20 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J38
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J39
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J4
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J40
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J5
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J6
# set_property PACKAGE_PIN AD23 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J7
# set_property PACKAGE_PIN AD24 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J8
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-J9
# set_property PACKAGE_PIN AD25 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K1
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K10
# set_property PACKAGE_PIN AB22 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K11
# set_property PACKAGE_PIN AC22 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K12
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K13
# set_property PACKAGE_PIN AA23 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K14
# set_property PACKAGE_PIN AB24 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K15
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K16
# set_property PACKAGE_PIN AC23 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K17
# set_property PACKAGE_PIN AC24 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K18
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K19
# set_property PACKAGE_PIN AE22 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K2
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K20
# set_property PACKAGE_PIN AF22 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K21
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K22
# set_property PACKAGE_PIN W20 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K23
# set_property PACKAGE_PIN Y21 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K24
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K25
# set_property PACKAGE_PIN AA17 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K26
# set_property PACKAGE_PIN AA18 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K27
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K28
# set_property PACKAGE_PIN AB17 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K29
# set_property PACKAGE_PIN AC17 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K3
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K30
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K31
# set_property PACKAGE_PIN Y15 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K32
# set_property PACKAGE_PIN Y16 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K33
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K34
# set_property PACKAGE_PIN AE17 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K35
# set_property PACKAGE_PIN AF17 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K36
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K37
# set_property PACKAGE_PIN AC18 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K38
# set_property PACKAGE_PIN AD18 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K39
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K4
# set_property PACKAGE_PIN C12 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K40
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K5
# set_property PACKAGE_PIN C11 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K6
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K7
# set_property PACKAGE_PIN AE23 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K8
# set_property PACKAGE_PIN AF23 [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]
# FMC-K9
# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD  [get_ports {}]

# LEDs #####################################################################
# set_property PACKAGE_PIN T24 [get_ports {led[0]}]
# set_property PACKAGE_PIN T25 [get_ports {led[1]}]
set_property PACKAGE_PIN R25 [get_ports {o_leds[2]}]
set_property PACKAGE_PIN P26 [get_ports {o_leds[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_leds[*]}]

# TODO: temporary
set_property PACKAGE_PIN T24 [get_ports {o_clk_ref}]
set_property IOSTANDARD LVCMOS33 [get_ports o_clk_ref];
set_property PACKAGE_PIN T25 [get_ports {o_clk_frame}]
set_property IOSTANDARD LVCMOS33 [get_ports o_clk_frame];

# Flash ####################################################################
# set_property PACKAGE_PIN N17 [get_ports {spi_dq0}]
# set_property PACKAGE_PIN N16 [get_ports {spi_c}]
# set_property PACKAGE_PIN R16 [get_ports {spi_s}]
# set_property PACKAGE_PIN U17 [get_ports {spi_dq1}]
# set_property PACKAGE_PIN U16 [get_ports {spi_w_dq2}]
# set_property PACKAGE_PIN T17 [get_ports {spi_hold_dq3}]
# set_property IOSTANDARD LVCMOS33 [get_ports {spi_dq0}]
# set_property IOSTANDARD LVCMOS33 [get_ports {spi_c}]
# set_property IOSTANDARD LVCMOS33 [get_ports {spi_s}]
# set_property IOSTANDARD LVCMOS33 [get_ports {spi_dq1}]
# set_property IOSTANDARD LVCMOS33 [get_ports {spi_w_dq2}]
# set_property IOSTANDARD LVCMOS33 [get_ports {spi_hold_dq3}]

# DRAM #####################################################################
# set_property PACKAGE_PIN AD1 [get_ports {ddr3_dq[0]}]
# set_property PACKAGE_PIN AE1 [get_ports {ddr3_dq[1]}]
# set_property PACKAGE_PIN AE3 [get_ports {ddr3_dq[2]}]
# set_property PACKAGE_PIN AE2 [get_ports {ddr3_dq[3]}]
# set_property PACKAGE_PIN AE6 [get_ports {ddr3_dq[4]}]
# set_property PACKAGE_PIN AE5 [get_ports {ddr3_dq[5]}]
# set_property PACKAGE_PIN AF3 [get_ports {ddr3_dq[6]}]
# set_property PACKAGE_PIN AF2 [get_ports {ddr3_dq[7]}]
# set_property PACKAGE_PIN W11 [get_ports {ddr3_dq[8]}]
# set_property PACKAGE_PIN V8  [get_ports {ddr3_dq[9]}]
# set_property PACKAGE_PIN V7  [get_ports {ddr3_dq[10]}]
# set_property PACKAGE_PIN Y8 [get_ports {ddr3_dq[11]}]
# set_property PACKAGE_PIN Y7 [get_ports {ddr3_dq[12]}]
# set_property PACKAGE_PIN Y11 [get_ports {ddr3_dq[13]}]
# set_property PACKAGE_PIN Y10 [get_ports {ddr3_dq[14]}]
# set_property PACKAGE_PIN V9 [get_ports {ddr3_dq[15]}]
# set_property SLEW FAST [get_ports {ddr3_dq[*]}]
# set_property IOSTANDARD SSTL15_T_DCI [get_ports {ddr3_dq[*]}]

# set_property PACKAGE_PIN AC1 [get_ports {ddr3_addr[0]}]
# set_property PACKAGE_PIN AB1 [get_ports {ddr3_addr[1]}]
# set_property PACKAGE_PIN V1 [get_ports {ddr3_addr[2]}]
# set_property PACKAGE_PIN V2 [get_ports {ddr3_addr[3]}]
# set_property PACKAGE_PIN Y2 [get_ports {ddr3_addr[4]}]
# set_property PACKAGE_PIN Y3 [get_ports {ddr3_addr[5]}]
# set_property PACKAGE_PIN V4 [get_ports {ddr3_addr[6]}]
# set_property PACKAGE_PIN V6 [get_ports {ddr3_addr[7]}]
# set_property PACKAGE_PIN U7 [get_ports {ddr3_addr[8]}]
# set_property PACKAGE_PIN W3 [get_ports {ddr3_addr[9]}]
# set_property PACKAGE_PIN V3 [get_ports {ddr3_addr[10]}]
# set_property PACKAGE_PIN U1 [get_ports {ddr3_addr[11]}]
# set_property PACKAGE_PIN U2 [get_ports {ddr3_addr[12]}]
# set_property PACKAGE_PIN U5 [get_ports {ddr3_addr[13]}]
# set_property PACKAGE_PIN U6 [get_ports {ddr3_addr[14]}]
# set_property SLEW FAST [get_ports {ddr3_addr[*]}]
# set_property IOSTANDARD SSTL15 [get_ports {ddr3_addr[*]}]

# set_property PACKAGE_PIN AB2 [get_ports {ddr3_ba[0]}]
# set_property PACKAGE_PIN Y1 [get_ports {ddr3_ba[1]}]
# set_property PACKAGE_PIN W1 [get_ports {ddr3_ba[2]}]
# set_property SLEW FAST [get_ports {ddr3_ba[*]}]
# set_property IOSTANDARD SSTL15 [get_ports {ddr3_ba[*]}]

# set_property PACKAGE_PIN AC2 [get_ports {ddr3_ras_n}]
# set_property SLEW FAST [get_ports {ddr3_ras_n}]
# set_property IOSTANDARD SSTL15 [get_ports {ddr3_ras_n}]

# set_property PACKAGE_PIN AA3 [get_ports {ddr3_cas_n}]
# set_property SLEW FAST [get_ports {ddr3_cas_n}]
# set_property IOSTANDARD SSTL15 [get_ports {ddr3_cas_n}]

# set_property PACKAGE_PIN AA2 [get_ports {ddr3_we_n}]
# set_property SLEW FAST [get_ports {ddr3_we_n}]
# set_property IOSTANDARD SSTL15 [get_ports {ddr3_we_n}]

# set_property PACKAGE_PIN AA4 [get_ports {ddr3_reset_n}]
# set_property SLEW FAST [get_ports {ddr3_reset_n}]
# set_property IOSTANDARD LVCMOS15 [get_ports {ddr3_reset_n}]

# set_property PACKAGE_PIN AB5 [get_ports {ddr3_cke[0]}]
# set_property SLEW FAST [get_ports {ddr3_cke[0]}]
# set_property IOSTANDARD SSTL15 [get_ports {ddr3_cke[0]}]

# set_property PACKAGE_PIN AB6 [get_ports {ddr3_odt[0]}]
# set_property SLEW FAST [get_ports {ddr3_odt[0]}]
# set_property IOSTANDARD SSTL15 [get_ports {ddr3_odt[0]}]

# set_property PACKAGE_PIN AA5 [get_ports {ddr3_cs_n[0]}]
# set_property SLEW FAST [get_ports {ddr3_cs_n[0]}]
# set_property IOSTANDARD SSTL15 [get_ports {ddr3_cs_n[0]}]

# set_property PACKAGE_PIN AD4 [get_ports {ddr3_dm[0]}]
# set_property PACKAGE_PIN V11 [get_ports {ddr3_dm[1]}]
# set_property SLEW FAST [get_ports {ddr3_dm[*]}]
# set_property IOSTANDARD SSTL15 [get_ports {ddr3_dm[*]}]

# set_property PACKAGE_PIN AF5 [get_ports {ddr3_dqs_p[0]}]
# set_property PACKAGE_PIN AF4 [get_ports {ddr3_dqs_n[0]}]
# set_property PACKAGE_PIN W10 [get_ports {ddr3_dqs_p[1]}]
# set_property PACKAGE_PIN W9 [get_ports {ddr3_dqs_n[1]}]
# set_property SLEW FAST [get_ports {ddr3_dqs*}]
# set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {ddr3_dqs*}]

# set_property PACKAGE_PIN W6 [get_ports {ddr3_ck_p[0]}]
# set_property PACKAGE_PIN W5 [get_ports {ddr3_ck_n[0]}]
# set_property SLEW FAST [get_ports {ddr3_ck*}]
# set_property IOSTANDARD DIFF_SSTL15 [get_ports {ddr3_ck_*}]

# OnBoard 100Mhz MGTREFCLK #################################################
# set_property PACKAGE_PIN K6 [get_ports {mgtrefclk_p}]
# set_property PACKAGE_PIN K5 [get_ports {mgtrefclk_n}]


############################################################################
# add diff_term
############################################################################
set_property DIFF_TERM TRUE [get_ports i_clk_ab_p]
set_property DIFF_TERM TRUE [get_ports i_clk_ab_n]
set_property DIFF_TERM TRUE [get_ports i_cha*_p]
set_property DIFF_TERM TRUE [get_ports i_chb*_p]

