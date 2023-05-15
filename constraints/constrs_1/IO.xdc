###############################################################################################################
#                              Copyright (C) 2022-2030 Ken-ji de la Rosa, IRAP Toulouse.
###############################################################################################################
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
###############################################################################################################
#    email                   kenji.delarosa@alten.com
#    @file                   test_IO.xdc
###############################################################################################################
#    Automatic Generation    No
#    Code Rules Reference    N/A
###############################################################################################################
#    @details
#    This file set the timing constraints on the top_level I/O ports (temporary)
#
#
###############################################################################################################

###############################################################################################################
# xem7350 : system clock
###############################################################################################################
# create_clock -name sys_clk -period 5 [get_ports sys_clkp]

###############################################################################################################
# usb @100.8 MHz
###############################################################################################################
# 100.8 MHz
create_clock -period 9.920 -name usb_clk_in [get_ports {i_okUH[0]}];
create_clock -name virt_usb_clk_in -period 9.920;

# 250 MHz
create_clock -period 4 -name adc_clk_in [get_ports {i_clk_ab_p}];
create_clock -name virt_adc_clk_in   -period 4;

# 500 MHz (data part)
create_clock -name virt_dac_clk   -period 2;

###############################################################################################################
# rename auto-derived clock
###############################################################################################################
# define variables
set usb_clk_in_pin [get_pins inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/inst_Opal_Kelly_Host/mmcm0/CLKIN1];
set usb_clk_out_pin  [get_pins inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/inst_Opal_Kelly_Host/mmcm0/CLKOUT0];
set mmcm_clk_in_pin [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKIN1];
set mmcm_clk_ref_out_pin [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKOUT0];
set mmcm_clk_sys_out_pin [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKOUT1];
set mmcm_dac_clk_out_pin [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKOUT2];
set mmcm_dac_clk_out_90_pin [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKOUT3];
set mmcm_dac_clk_div_out_pin [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKOUT4];
set mmcm_dac_clk_div_90_out_pin [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKOUT5];


# rename clocks
create_generated_clock -name ref_clk -source $mmcm_clk_in_pin $mmcm_clk_ref_out_pin;
create_generated_clock -name dac_clk -source $mmcm_clk_in_pin $mmcm_dac_clk_out_pin;
create_generated_clock -name dac_clk_phase90 -source $mmcm_clk_in_pin $mmcm_dac_clk_out_90_pin;
create_generated_clock -name dac_clk_div -source $mmcm_clk_in_pin $mmcm_dac_clk_div_out_pin;
create_generated_clock -name dac_clk_div_phase90 -source $mmcm_clk_in_pin $mmcm_dac_clk_div_90_out_pin;
create_generated_clock -name sys_clk -source $mmcm_clk_in_pin $mmcm_clk_sys_out_pin;
create_generated_clock -name usb_clk -source $usb_clk_in_pin $usb_clk_out_pin;


###############################################################################################################
# ODDR : forward clock
###############################################################################################################
create_generated_clock -name gen_dac_clk_out -multiply_by 1 -source [get_pins inst_io_top/inst_io_dac/gen_io_dac_clk.inst_selectio_wiz_dac_clk/clk_in] [get_ports {o_dac_dclk_p}];
create_generated_clock -name gen_sync_clk -multiply_by 1 -source [get_pins inst_io_top/inst_io_sync/gen_io_sync.inst_selectio_wiz_sync/inst/oddr_inst/C] [get_ports {o_clk_ref}];
create_generated_clock -name gen_spi_clk -multiply_by 1 -source [get_pins inst_spi_top/inst_spi_io/gen_user_to_pads_clk.inst_oddr/C] [get_ports {o_spi_sclk}];


###############################################################################################################
# usb: constraints register/Q on register/clk
###############################################################################################################
set usb_src [get_pins inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/inst_Opal_Kelly_Host/core0/core0/a0/d0/lc4da648cb12eeeb24e4d199c1195ed93_reg[4]/C];
set usb_dest [get_pins inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/inst_Opal_Kelly_Host/core0/core0/a0/d0/lc4da648cb12eeeb24e4d199c1195ed93_reg[4]/Q];
create_generated_clock -name usb_clk_regQ_on_clk_pin -source $usb_src -divide_by 2 $usb_dest;

###############################################################################################################
# usb (input ports)
###############################################################################################################
# Center-Aligned Rising Edge Source Synchronous Inputs
#
# For a center-aligned Source Synchronous interface, the clock
# transition is aligned with the center of the data valid window.
# The same clock edge is used for launching and capturing the
# data. The constraints below rely on the default timing
# analysis (setup = 1 cycle, hold = 0 cycle).
#
# input    ____           __________
# clock        |_________|          |_____
#                        |
#                 dv_bre | dv_are
#                <------>|<------>
#          __    ________|________    __
# data     __XXXX____Rise_Data____XXXX__
#

set input_clock         virt_usb_clk_in;      # Name of input clock
set input_clock_period  9.92;    # Period of input clock
set dv_bre              1.920;             # Data valid before the rising clock edge
set dv_are              0.000;             # Data valid after the rising clock edge
set input_ports         {i_okUH[*]};     # List of input ports

# Input Delay Constraint
set_input_delay -clock $input_clock -max [expr $input_clock_period - $dv_bre] [get_ports $input_ports] -add_delay;
set_input_delay -clock $input_clock -min $dv_are                              [get_ports $input_ports] -add_delay;

# Center-Aligned Rising Edge Source Synchronous Inputs
#
# For a center-aligned Source Synchronous interface, the clock
# transition is aligned with the center of the data valid window.
# The same clock edge is used for launching and capturing the
# data. The constraints below rely on the default timing
# analysis (setup = 1 cycle, hold = 0 cycle).
#
# input    ____           __________
# clock        |_________|          |_____
#                        |
#                 dv_bre | dv_are
#                <------>|<------>
#          __    ________|________    __
# data     __XXXX____Rise_Data____XXXX__
#

set input_clock         virt_usb_clk_in;      # Name of input clock
set input_clock_period  9.92;    # Period of input clock
set dv_bre              1.920;             # Data valid before the rising clock edge
set dv_are              0.000;             # Data valid after the rising clock edge
set input_ports         {b_okUHU[*] b_okAA};     # List of input ports

# Input Delay Constraint
set_input_delay -clock $input_clock -max [expr $input_clock_period - $dv_bre] [get_ports $input_ports] -add_delay;
set_input_delay -clock $input_clock -min $dv_are                              [get_ports $input_ports] -add_delay;

###############################################################################################################
# usb (output ports)
###############################################################################################################

#  Rising Edge Source Synchronous Outputs
#
#  Source synchronous output interfaces can be constrained either by the max data skew
#  relative to the generated clock or by the destination device setup/hold requirements.
#
#  Setup/Hold Case:
#  Setup and hold requirements for the destination device and board trace delays are known.
#
# forwarded         ____                      ___________________
# clock                 |____________________|                   |____________
#                                            |
#                                     tsu    |    thd
#                                <---------->|<--------->
#                                ____________|___________
# data @ destination    XXXXXXXXX________________________XXXXX
#
# Example of creating generated clock at clock output port
# create_generated_clock -name <gen_clock_name> -multiply_by 1 -source [get_pins <source_pin>] [get_ports <output_clock_port>]
# gen_clock_name is the name of forwarded clock here. It should be used below for defining "fwclk".

set fwclk        usb_clk;     # forwarded clock name (generated using create_generated_clock at output clock port)
set tsu          2.000;            # destination device setup time requirement
set thd          0.500;            # destination device hold time requirement
set trce_dly_max 0.000;            # maximum board trace delay
set trce_dly_min 0.000;            # minimum board trace delay
set output_ports {o_okHU[*] b_okUHU[*] b_okAA};   # list of output ports

# Output Delay Constraints
set_output_delay -clock $fwclk -max [expr $trce_dly_max + $tsu] [get_ports $output_ports] -add_delay;
set_output_delay -clock $fwclk -min [expr $trce_dly_min - $thd] [get_ports $output_ports] -add_delay;

##################################################################################
# ADC (input ports)
##################################################################################
# Center-Aligned Double Data Rate Source Synchronous Inputs
#
# For a center-aligned Source Synchronous interface, the clock
# transition is aligned with the center of the data valid window.
# The same clock edge is used for launching and capturing the
# data. The constraints below rely on the default timing
# analysis (setup = 1/2 cycle, hold = 0 cycle).
#
# input                  ____________________
# clock    _____________|                    |_____________
#                       |                    |
#                dv_bre | dv_are      dv_bfe | dv_afe
#               <------>|<------>    <------>|<------>
#          _    ________|________    ________|________    _
# data     _XXXX____Rise_Data____XXXX____Fall_Data____XXXX_
#

set input_clock        adc_clk_in;    # Name of input clock
set input_clock_period  4;               # Period of input clock (full-period)
set dv_bre              1.2;             # Data valid before the rising clock edge
set dv_are              0.8;             # Data valid after the rising clock edge
set dv_bfe              1.2;             # Data valid before the falling clock edge
set dv_afe              0.8;             # Data valid after the falling clock edge
set input_ports         {i_cha*_p i_chb*_p};     # List of input ports

# Input Delay Constraint
set_input_delay -clock $input_clock -max [expr $input_clock_period/2 - $dv_bfe] [get_ports $input_ports];
set_input_delay -clock $input_clock -min $dv_are                                [get_ports $input_ports];
set_input_delay -clock $input_clock -max [expr $input_clock_period/2 - $dv_bre] [get_ports $input_ports] -clock_fall -add_delay;
set_input_delay -clock $input_clock -min $dv_afe                                [get_ports $input_ports] -clock_fall -add_delay;


##################################################################################
# DAC (output ports)
##################################################################################
#  Double Data Rate Source Synchronous Outputs
#
#  Source synchronous output interfaces can be constrained either by the max data skew
#  relative to the generated clock or by the destination device setup/hold requirements.
#
#  Setup/Hold Case:
#  Setup and hold requirements for the destination device and board trace delays are known.
#
# forwarded                        _________________________________
# clock                 __________|                                 |______________
#                                 |                                 |
#                           tsu_r |  thd_r                    tsu_f | thd_f
#                         <------>|<------->                <------>|<----->
#                         ________|_________                ________|_______
# data @ destination   XXX__________________XXXXXXXXXXXXXXXX________________XXXXX
#
# Example of creating generated clock at clock output port
# create_generated_clock -name <gen_clock_name> -multiply_by 1 -source [get_pins <source_pin>] [get_ports <output_clock_port>]
# gen_clock_name is the name of forwarded clock here. It should be used below for defining "fwclk".

set fwclk        gen_dac_clk_out;  # forwarded clock name (generated using create_generated_clock at output clock port)
set tsu_r        0.025;            # destination device setup time requirement for rising edge
set thd_r        0.375;            # destination device hold time requirement for rising edge
set tsu_f        0.025;            # destination device setup time requirement for falling edge
set thd_f        0.375;            # destination device hold time requirement for falling edge
set trce_dly_max 0.000;            # maximum board trace delay
set trce_dly_min 0.000;            # minimum board trace delay
set output_ports {o_dac_d0_p o_dac_d1_p o_dac_d2_p o_dac_d3_p o_dac_d4_p o_dac_d5_p o_dac_d6_p o_dac_d7_p};   # list of output ports

# Output Delay Constraints
set_output_delay -clock $fwclk -max [expr $trce_dly_max + $tsu_r] [get_ports $output_ports];
set_output_delay -clock $fwclk -min [expr $trce_dly_min - $thd_r] [get_ports $output_ports];
set_output_delay -clock $fwclk -max [expr $trce_dly_max + $tsu_f] [get_ports $output_ports] -clock_fall -add_delay;
set_output_delay -clock $fwclk -min [expr $trce_dly_min - $thd_f] [get_ports $output_ports] -clock_fall -add_delay;

#  Rising Edge Source Synchronous Outputs
#
#  Source synchronous output interfaces can be constrained either by the max data skew
#  relative to the generated clock or by the destination device setup/hold requirements.
#
#  Setup/Hold Case:
#  Setup and hold requirements for the destination device and board trace delays are known.
#
# forwarded         ____                      ___________________
# clock                 |____________________|                   |____________
#                                            |
#                                     tsu    |    thd
#                                <---------->|<--------->
#                                ____________|___________
# data @ destination    XXXXXXXXX________________________XXXXX
#
# Example of creating generated clock at clock output port
# create_generated_clock -name <gen_clock_name> -multiply_by 1 -source [get_pins <source_pin>] [get_ports <output_clock_port>]
# gen_clock_name is the name of forwarded clock here. It should be used below for defining "fwclk".

set fwclk        gen_dac_clk_out;     # forwarded clock name (generated using create_generated_clock at output clock port)
set tsu          0.025;            # destination device setup time requirement
set thd          0.375;            # destination device hold time requirement
set trce_dly_max 0.000;            # maximum board trace delay
set trce_dly_min 0.000;            # minimum board trace delay
set output_ports {o_frame_p};   # list of output ports

# Output Delay Constraints
set_output_delay -clock $fwclk -max [expr $trce_dly_max + $tsu] [get_ports $output_ports];
set_output_delay -clock $fwclk -min [expr $trce_dly_min - $thd] [get_ports $output_ports];

##################################################################################
# reference (output ports)
##################################################################################
#  Rising Edge Source Synchronous Outputs
#
#  Source synchronous output interfaces can be constrained either by the max data skew
#  relative to the generated clock or by the destination device setup/hold requirements.
#
#  Setup/Hold Case:
#  Setup and hold requirements for the destination device and board trace delays are known.
#
# forwarded         ____                      ___________________
# clock                 |____________________|                   |____________
#                                            |
#                                     tsu    |    thd
#                                <---------->|<--------->
#                                ____________|___________
# data @ destination    XXXXXXXXX________________________XXXXX
#
# Example of creating generated clock at clock output port
# create_generated_clock -name <gen_clock_name> -multiply_by 1 -source [get_pins <source_pin>] [get_ports <output_clock_port>]
# gen_clock_name is the name of forwarded clock here. It should be used below for defining "fwclk".

set fwclk        ref_clk;      # forwarded clock name (generated using create_generated_clock at output clock port)
set tsu          1.000;           # destination device setup time requirement
set thd          1.500;           # destination device hold time requirement
set trce_dly_max 0.000;            # maximum board trace delay
set trce_dly_min 0.000;            # minimum board trace delay
set output_ports {o_clk_frame_p};   # list of output ports

# Output Delay Constraints
set_output_delay -clock $fwclk -max [expr $trce_dly_max + $tsu] [get_ports $output_ports];
set_output_delay -clock $fwclk -min [expr $trce_dly_min - $thd] [get_ports $output_ports];


##################################################################################
# SPI: timing constraints (output ports)
#    for all spi, we consider the worst case (CDCE @20MHz: cdce72010)
##################################################################################
#  Rising Edge Source Synchronous Outputs
#
#  Source synchronous output interfaces can be constrained either by the max data skew
#  relative to the generated clock or by the destination device setup/hold requirements.
#
#  Setup/Hold Case:
#  Setup and hold requirements for the destination device and board trace delays are known.
#
# forwarded         ____                      ___________________
# clock                 |____________________|                   |____________
#                                            |
#                                     tsu    |    thd
#                                <---------->|<--------->
#                                ____________|___________
# data @ destination    XXXXXXXXX________________________XXXXX
#
# Example of creating generated clock at clock output port
# create_generated_clock -name <gen_clock_name> -multiply_by 1 -source [get_pins <source_pin>] [get_ports <output_clock_port>]
# gen_clock_name is the name of forwarded clock here. It should be used below for defining "fwclk".

set fwclk        usb_clk;      # forwarded clock name (generated using create_generated_clock at output clock port)
set tsu          2.5;           # destination device setup time requirement
set thd          2.5;           # destination device hold time requirement
set trce_dly_max 0.000;            # maximum board trace delay
set trce_dly_min 0.000;            # minimum board trace delay
set output_ports {o_spi_sdata o_cdce_n_en o_cdce_n_reset o_cdce_n_pd o_ref_en o_adc_n_en o_adc_reset o_dac_n_en o_tx_enable o_mon_n_en o_mon_n_reset};   # list of output ports

# Output Delay Constraints
set_output_delay -clock $fwclk -max [expr $trce_dly_max + $tsu] [get_ports $output_ports];
set_output_delay -clock $fwclk -min [expr $trce_dly_min - $thd] [get_ports $output_ports];

##################################################################################
# SPI: timing constraints (input ports)
#    for all spi, we consider the worst case (CDCE @20MHz: cdce72010)
##################################################################################
# Center-Aligned Rising Edge Source Synchronous Inputs
#
# For a center-aligned Source Synchronous interface, the clock
# transition is aligned with the center of the data valid window.
# The same clock edge is used for launching and capturing the
# data. The constraints below rely on the default timing
# analysis (setup = 1 cycle, hold = 0 cycle).
#
# input    ____           __________
# clock        |_________|          |_____
#                        |
#                 dv_bre | dv_are
#                <------>|<------>
#          __    ________|________    __
# data     __XXXX____Rise_Data____XXXX__
#

set input_clock         usb_clk;      # Name of input clock
set input_clock_period  9.92;              # Period of input clock
set dv_bre              7.5;          # Data valid before the rising clock edge
set dv_are              3.500;          # Data valid after the rising clock edge
set input_ports         {i_cdce_sdo i_pll_status i_adc_sdo i_dac_sdo i_mon_sdo i_mon_n_int};     # List of input ports

# Input Delay Constraint
set_input_delay -clock $input_clock -max [expr $input_clock_period - $dv_bre] [get_ports $input_ports];
set_input_delay -clock $input_clock -min $dv_are                              [get_ports $input_ports];


##################################################################################
# o_trig_oscillo: timing constraints (output ports)
#    for all spi, we consider the worst case (CDCE @20MHz: cdce72010)
##################################################################################
#  Rising Edge Source Synchronous Outputs
#
#  Source synchronous output interfaces can be constrained either by the max data skew
#  relative to the generated clock or by the destination device setup/hold requirements.
#
#  Setup/Hold Case:
#  Setup and hold requirements for the destination device and board trace delays are known.
#
# forwarded         ____                      ___________________
# clock                 |____________________|                   |____________
#                                            |
#                                     tsu    |    thd
#                                <---------->|<--------->
#                                ____________|___________
# data @ destination    XXXXXXXXX________________________XXXXX
#
# Example of creating generated clock at clock output port
# create_generated_clock -name <gen_clock_name> -multiply_by 1 -source [get_pins <source_pin>] [get_ports <output_clock_port>]
# gen_clock_name is the name of forwarded clock here. It should be used below for defining "fwclk".

set fwclk        sys_clk;      # forwarded clock name (generated using create_generated_clock at output clock port)
set tsu          0.5;           # destination device setup time requirement
set thd          0.5;           # destination device hold time requirement
set trce_dly_max 0.000;            # maximum board trace delay
set trce_dly_min 0.000;            # minimum board trace delay
set output_ports {o_trig_oscillo};   # list of output ports

# Output Delay Constraints
set_output_delay -clock $fwclk -max [expr $trce_dly_max + $tsu] [get_ports $output_ports];
set_output_delay -clock $fwclk -min [expr $trce_dly_min - $thd] [get_ports $output_ports];

##################################################################################
# o_leds[3]: timing constraints (output ports)
##################################################################################
#  Rising Edge Source Synchronous Outputs
#
#  Source synchronous output interfaces can be constrained either by the max data skew
#  relative to the generated clock or by the destination device setup/hold requirements.
#
#  Setup/Hold Case:
#  Setup and hold requirements for the destination device and board trace delays are known.
#
# forwarded         ____                      ___________________
# clock                 |____________________|                   |____________
#                                            |
#                                     tsu    |    thd
#                                <---------->|<--------->
#                                ____________|___________
# data @ destination    XXXXXXXXX________________________XXXXX
#
# Example of creating generated clock at clock output port
# create_generated_clock -name <gen_clock_name> -multiply_by 1 -source [get_pins <source_pin>] [get_ports <output_clock_port>]
# gen_clock_name is the name of forwarded clock here. It should be used below for defining "fwclk".

set fwclk        sys_clk;      # forwarded clock name (generated using create_generated_clock at output clock port)
set tsu          1.5;           # destination device setup time requirement
set thd          1.5;           # destination device hold time requirement
set trce_dly_max 0.000;            # maximum board trace delay
set trce_dly_min 0.000;            # minimum board trace delay
set output_ports {o_leds[3]};   # list of output ports

# Output Delay Constraints
set_output_delay -clock $fwclk -max [expr $trce_dly_max + $tsu] [get_ports $output_ports];
set_output_delay -clock $fwclk -min [expr $trce_dly_min - $thd] [get_ports $output_ports];

##################################################################################
# o_leds[2]: timing constraints (output ports)
##################################################################################
#  Rising Edge Source Synchronous Outputs
#
#  Source synchronous output interfaces can be constrained either by the max data skew
#  relative to the generated clock or by the destination device setup/hold requirements.
#
#  Setup/Hold Case:
#  Setup and hold requirements for the destination device and board trace delays are known.
#
# forwarded         ____                      ___________________
# clock                 |____________________|                   |____________
#                                            |
#                                     tsu    |    thd
#                                <---------->|<--------->
#                                ____________|___________
# data @ destination    XXXXXXXXX________________________XXXXX
#
# Example of creating generated clock at clock output port
# create_generated_clock -name <gen_clock_name> -multiply_by 1 -source [get_pins <source_pin>] [get_ports <output_clock_port>]
# gen_clock_name is the name of forwarded clock here. It should be used below for defining "fwclk".

set fwclk        usb_clk;      # forwarded clock name (generated using create_generated_clock at output clock port)
set tsu          1.5;           # destination device setup time requirement
set thd          1.5;           # destination device hold time requirement
set trce_dly_max 0.000;            # maximum board trace delay
set trce_dly_min 0.000;            # minimum board trace delay
set output_ports {o_leds[2]};   # list of output ports

# Output Delay Constraints
set_output_delay -clock $fwclk -max [expr $trce_dly_max + $tsu] [get_ports $output_ports];
set_output_delay -clock $fwclk -min [expr $trce_dly_min - $thd] [get_ports $output_ports];

##################################################################################
# spy (output ports)
##################################################################################
# Rising Edge System Synchronous Outputs 
#
# A System Synchronous design interface is a clocking technique in which the same 
# active-edge of a system clock is used for both the source and destination device. 
#
# dest        __________            __________
# clk    ____|          |__________|
#                                  |
#     (trce_dly_max+tsu) <---------|
#             (trce_dly_min-thd) <-|
#                        __    __
# data   XXXXXXXXXXXXXXXX__DATA__XXXXXXXXXXXXX
#

set destination_clock sys_clk;    # Name of destination clock
set tsu               2.000;      # Destination device setup time requirement
set thd               0.500;      # Destination device hold time requirement
set trce_dly_max      0.000;      # Maximum board trace delay
set trce_dly_min      0.000;      # Minimum board trace delay
set output_ports      {o_spy*};   # List of output ports

# Output Delay Constraint
set_output_delay -clock $destination_clock -max [expr $trce_dly_max + $tsu] [get_ports $output_ports];
set_output_delay -clock $destination_clock -min [expr $trce_dly_min - $thd] [get_ports $output_ports];


###############################################################################################################
# Unrelated asynchronuous clocks
#  by default, set_clock_group on a master clock are NOT applied to generated clocks by default.
#  You need to explicitly include it as in the command below.
###############################################################################################################
# set_clock_groups -name async_clk_grp_usb_adc -asynchronous -group [get_clocks -include_generated_clocks adc_clk_in] -group [get_clocks -include_generated_clocks usb_clk_in];
set_clock_groups -name async_mmcm_usb_user_virt -asynchronous -group {usb_clk} -group {virt_usb_clk_in}

###############################################################################################################
#  uncorrelate the opposite clock edge of identical clock
###############################################################################################################
# set_multicycle_path 0 -from [get_clocks dac_clk] -to [get_clocks gen_dac_clk_out]
# set_multicycle_path -1 -hold -from [get_clocks dac_clk] -to [get_clocks gen_dac_clk_out]
# set_false_path -setup -rise_from [get_clocks dac_clk] -fall_to [get_clocks gen_dac_clk_out];
# set_false_path -hold -rise_from [get_clocks dac_clk] -fall_to [get_clocks gen_dac_clk_out];

# set_false_path -setup -rise_from [get_clocks virt_adc_clk_in] -fall_to [get_clocks adc_clk_in];
# set_false_path -hold -rise_from [get_clocks virt_adc_clk_in] -fall_to [get_clocks adc_clk_in;

# set_false_path -setup -rise_from [get_clocks virt_usb_clk_in] -fall_to [get_clocks usb_clk_in];
# set_false_path -hold -rise_from [get_clocks virt_usb_clk_in] -fall_to [get_clocks usb_clk_in];

# set_multicycle_path 2 -from [get_clocks virt_usb_clk_in] -to [get_clocks usb_clk_in];
# set_multicycle_path 2 -from [get_clocks usb_clk_in] -to [get_clocks virt_usb_clk_in];

# set_multicycle_path 2 -from [get_clocks virt_adc_clk_in] -to [get_clocks adc_clk_in];

# set_multicycle_path 2 -from [get_clocks virt_dac_clk] -to [get_clocks dac_clk];

set_multicycle_path 2 -from [get_ports i_adc_sdo i_mon_sdo i_cdce_sdo i_mon_n_int i_dac_sdo i_pll_status]


set dac_clk_net inst_clocking_top/inst_fpasim_clk_wiz_0/inst/clk_out3
set dac_clk_div_net inst_clocking_top/inst_fpasim_clk_wiz_0/inst/clk_out5
set_property CLOCK_DELAY_GROUP dac_out [get_nets "$dac_clk_net $dac_clk_div_net"]

set dac_clk_phase_90_net inst_clocking_top/inst_fpasim_clk_wiz_0/inst/clk_out4
set dac_clk_phase_90_div_net inst_clocking_top/inst_fpasim_clk_wiz_0/inst/clk_out6
set_property CLOCK_DELAY_GROUP dac_phase90_out [get_nets "$dac_clk_phase_90_net $dac_clk_phase_90_div_net"]

# DAC source-synchronuous
# Add false path exceptions for cross-clock transfers
#   disable analysis (setup, hold):
#   dac_clk: rise -> fall (gen_dac_clk_out)
#   dac_clk: fall  -> rise (gen_dac_clk_out)
set_false_path -setup  -rise_from [get_clocks dac_clk] -fall_to [get_clocks gen_dac_clk_out]
set_false_path -setup  -fall_from [get_clocks dac_clk] -rise_to [get_clocks gen_dac_clk_out]
set_false_path -hold  -rise_from [get_clocks dac_clk] -fall_to [get_clocks gen_dac_clk_out]
set_false_path -hold  -fall_from [get_clocks dac_clk] -rise_to [get_clocks gen_dac_clk_out]


set_false_path -setup  -rise_from [get_clocks virt_adc_clk_in] -fall_to [get_clocks gen_dac_clk_out]
set_false_path -setup  -fall_from [get_clocks virt_adc_clk_in] -rise_to [get_clocks gen_dac_clk_out]
set_false_path -hold  -rise_from [get_clocks virt_adc_clk_in] -fall_to [get_clocks gen_dac_clk_out]
set_false_path -hold  -fall_from [get_clocks virt_adc_clk_in] -rise_to [get_clocks gen_dac_clk_out]



# SPI source-synchronuous
# Add false path exceptions for cross-clock transfers
#   disable analysis (setup, hold):
#   usb_clk: rise -> fall (gen_spi_clk)
#   usb_clk: fall  -> rise (gen_spi_clk)
# set_false_path -setup  -rise_from [get_clocks usb_clk] -fall_to [get_clocks gen_spi_clk]
# set_false_path -setup  -fall_from [get_clocks usb_clk] -rise_to [get_clocks gen_spi_clk]
# set_false_path -hold  -rise_from [get_clocks usb_clk] -fall_to [get_clocks gen_spi_clk]
# set_false_path -hold  -fall_from [get_clocks usb_clk] -rise_to [get_clocks gen_spi_clk]

# set_multicycle_path -setup -end 0 -rise_from [get_clocks usb_clk] -rise_to [get_clocks gen_spi_clk]
# set_multicycle_path -setup -end 0 -fall_from [get_clocks usb_clk] -fall_to [get_clocks gen_spi_clk]


##################################################################################
# others (input ports): asynchronuous ports
##################################################################################

# set_false_path -from [get_ports "i_hardware_id*"]
set_false_path -to   [get_ports "o_leds[1]"];
set_false_path -to   [get_ports "o_leds[0]"];
set_false_path -to   [get_ports "o_led_fw"];
set_false_path -to   [get_ports "o_led_pll_lock"];


##################################################################################
# SPI: IO
#   use IO register when possible
##################################################################################
# shared spi links
set_property IOB true [get_ports o_spi_sclk];
set_property IOB true [get_ports o_spi_sdata];
# CDCE
set_property IOB true [get_ports i_cdce_sdo];
set_property IOB true [get_ports o_cdce_n_en];
set_property IOB true [get_ports i_pll_status];
# set_property IOB true [get_ports o_cdce_n_reset];
# set_property IOB true [get_ports o_cdce_n_pd];
set_property IOB true [get_ports o_ref_en];
# ADC
set_property IOB true [get_ports i_adc_sdo];
set_property IOB true [get_ports o_adc_n_en];
# set_property IOB true [get_ports o_adc_reset]; # stuck to a constant value
# DAC
set_property IOB true [get_ports i_dac_sdo];
set_property IOB true [get_ports o_dac_n_en];
set_property IOB true [get_ports o_tx_enable];
set_property IOB true [get_ports i_mon_sdo];
# AMC
set_property IOB true [get_ports o_mon_n_en];
set_property IOB true [get_ports i_mon_n_int];
# set_property IOB true [get_ports o_mon_n_reset];

##################################################################################
# Sync: IO
##################################################################################
set_property IOB true [get_ports o_clk_ref_p]
set_property IOB true [get_ports o_clk_frame_p]

##################################################################################
# usb: IO
##################################################################################
# set_property IOB true [get_ports i_okUH*]; # connected to a mmcm
# set_property IOB true [get_ports o_okHU*];
# set_property IOB true [get_ports b_okUHU*];
# set_property IOB true [get_ports b_okAA];

##################################################################################
# adc: IO
##################################################################################
# set_property IOB true [get_ports i_clk_ab_p];
# set_property IOB true [get_ports i_cha*_p];
# set_property IOB true [get_ports i_chb*_p];

##################################################################################
# dac: IO
##################################################################################
# set_property IOB true [get_ports o_dac_dclk_p];
# set_property IOB true [get_ports o_frame_p];
# set_property IOB true [get_ports o_dac_d*_p];

##################################################################################
# pulse: IO
##################################################################################
# set_property IOB true [get_ports o_trig_oscillo];

##################################################################################
# led: IO
##################################################################################
# set_property IOB true [get_ports o_leds[3]];
set_property IOB true [get_ports o_leds[2]];

##################################################################################
# spy: IO
##################################################################################
set_property IOB true [get_ports o_spy]
