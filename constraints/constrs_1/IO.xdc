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
create_clock -period 9.920 -name okUH0 [get_ports {i_okUH[0]}]
create_clock -period 4 -name adc_clk [get_ports {i_clk_ab_p}]
create_clock -name virt_okUH0 -period 9.920


###############################################################################################################
# rename auto-derived clock
###############################################################################################################
set usb_clk_in_pin [get_pins inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/inst_Opal_Kelly_Host/mmcm0/CLKIN1]
set usb_clk_out_pin  [get_pins inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/inst_Opal_Kelly_Host/mmcm0/CLKOUT0]
# set usb_clk [get_clocks -of_objects [get_pins inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/inst_Opal_Kelly_Host/mmcm0/CLKOUT0]]
set mmcm_clk_in_pin [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKIN1]
set mmcm_clk_ref_out_pin [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKOUT0]
set mmcm_clk_sys_out_pin [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKOUT1]
set mmcm_dac_clk_out_pin [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKOUT2]
set mmcm_dac_clk_out_90_pin [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKOUT3]
set mmcm_dac_clk_div_out_pin [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKOUT4]
set mmcm_dac_clk_div_90_out_pin [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKOUT5]


# rename clock
create_generated_clock -name ref_clk -source $mmcm_clk_in_pin $mmcm_clk_ref_out_pin
create_generated_clock -name dac_clk -source $mmcm_clk_in_pin $mmcm_dac_clk_out_pin
create_generated_clock -name dac_clk_phase90 -source $mmcm_clk_in_pin $mmcm_dac_clk_out_90_pin
create_generated_clock -name dac_clk_div -source $mmcm_clk_in_pin $mmcm_dac_clk_div_out_pin
create_generated_clock -name dac_clk_div_phase90 -source $mmcm_clk_in_pin $mmcm_dac_clk_div_90_out_pin
create_generated_clock -name sys_clk -source $mmcm_clk_in_pin $mmcm_clk_sys_out_pin
create_generated_clock -name usb_clk -source $usb_clk_in_pin $usb_clk_out_pin

# set_property CLOCK_DELAY_GROUP clock_delay_group_clk_dac_feedback [get_nets-of_objects
# [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/clkf_buf/O] ]
# set_property CLOCK_DELAY_GROUP clock_delay_group_clk_dac [get_nets-of_objects
# [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/clkout2_buf/O] ]
# set_property CLOCK_DELAY_GROUP clock_delay_group_clk_dac_phase90 [get_nets-of_objects
# [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/clkout5_buf/O] ]

# set_property USER_CLOCK_ROOT {X0Y4} [get_nets inst_clocking_top/inst_fpasim_clk_wiz_0/inst/clkf_buf]
# set_property USER_CLOCK_ROOT {X0Y4} [get_nets inst_clocking_top/inst_fpasim_clk_wiz_0/inst/clkout2_buf]
# set_property USER_CLOCK_ROOT {X0Y4} [get_nets inst_clocking_top/inst_fpasim_clk_wiz_0/inst/clkout5_buf]

###############################################################################################################
# Unrelated asynchronuous clocks
###############################################################################################################
# set_clock_groups -asynchronous -group {mmcm0_clk0} -group {adc_clk ref_clk dac_clk sys_clk}
set_clock_groups -name async-mmcm-user-virt -asynchronous -group {usb_clk} -group {virt_okUH0}

###############################################################################################################
# ODDR : forward clock
###############################################################################################################
create_generated_clock -name gen_dac_clk_out -multiply_by 1 -source [get_pins inst_io_top/inst_io_dac/gen_io_dac_clk.inst_selectio_wiz_dac_clk/clk_in] [get_ports {o_dac_dclk_p}]
create_generated_clock -name gen_sync_clk -multiply_by 1 -source [get_pins inst_io_top/inst_io_sync/gen_io_sync.inst_selectio_wiz_sync/inst/oddr_inst/C] [get_ports {o_clk_ref}]
create_generated_clock -name gen_spi_clk -multiply_by 1 -source [get_pins inst_spi_top/inst_spi_io/gen_user_to_pads_clk.inst_oddr/C] [get_ports {o_spi_sclk}]
# usb_clk(100.8MHz) -> to max spi clock (20MHz) => multiply_by

set_multicycle_path 0 -from [get_clocks dac_clk] -to [get_clocks gen_dac_clk_out]
set_multicycle_path -1 -hold -from [get_clocks dac_clk] -to [get_clocks gen_dac_clk_out]
set_false_path -setup -rise_from [get_clocks dac_clk] -fall_to [get_clocks gen_dac_clk_out]
set_false_path -setup -rise_from [get_clocks dac_clk] -fall_to [get_clocks gen_dac_clk_out]
set_false_path -setup -fall_from [get_clocks dac_clk] -rise_to [get_clocks gen_dac_clk_out]
set_false_path -hold -rise_from [get_clocks dac_clk] -rise_to [get_clocks gen_dac_clk_out]
set_false_path -hold -fall_from [get_clocks dac_clk] -fall_to [get_clocks gen_dac_clk_out]


###############################################################################################################
# usb: constraints register/Q on register/clk
###############################################################################################################
set usb_src [get_pins inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/inst_Opal_Kelly_Host/core0/core0/a0/d0/lc4da648cb12eeeb24e4d199c1195ed93_reg[4]/C]
set usb_dest [get_pins inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/inst_Opal_Kelly_Host/core0/core0/a0/d0/lc4da648cb12eeeb24e4d199c1195ed93_reg[4]/Q]
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

# set input_clock         usb_clk;      # Name of input clock
set input_clock         virt_okUH0;      # Name of input clock
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

# set input_clock         usb_clk;      # Name of input clock
set input_clock         virt_okUH0;      # Name of input clock
set input_clock_period  9.92;    # Period of input clock
set dv_bre              1.920;             # Data valid before the rising clock edge
set dv_are              2.000;             # Data valid after the rising clock edge
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

# set fwclk        $usb_clk;     # forwarded clock name (generated using create_generated_clock at output clock port)
set fwclk        usb_clk;     # forwarded clock name (generated using create_generated_clock at output clock port)
set tsu          2.000;            # destination device setup time requirement
set thd          0.500;            # destination device hold time requirement
set trce_dly_max 0.000;            # maximum board trace delay
set trce_dly_min 0.000;            # minimum board trace delay
set output_ports {o_okHU[*] b_okUHU[*] b_okAA};   # list of output ports

# Output Delay Constraints
set_output_delay -clock $fwclk -max [expr $trce_dly_max + $tsu] [get_ports $output_ports] -add_delay;
set_output_delay -clock $fwclk -min [expr $trce_dly_min - $thd] [get_ports $output_ports] -add_delay;


# set_output_delay -clock [get_clocks mmcm0_clk0] -max -add_delay 2.000 [get_ports {o_okHU[*]}]
# set_output_delay -clock [get_clocks mmcm0_clk0] -min -add_delay -0.500 [get_ports {o_okHU[*]}]

# set_output_delay -clock [get_clocks mmcm0_clk0] -max -add_delay 2.000 [get_ports {b_okUHU[*]}]
# set_output_delay -clock [get_clocks mmcm0_clk0] -min -add_delay -0.500 [get_ports {b_okUHU[*]}]

# set_output_delay -clock [get_clocks mmcm0_clk0] -max -add_delay 2.000 [get_ports {b_okAA[*]}]
# set_output_delay -clock [get_clocks mmcm0_clk0] -min -add_delay -0.500 [get_ports {b_okAA[*]}]


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

set input_clock         adc_clk;      # Name of input clock
# set input_clock         i_clk_ab_p;      # Name of input clock
set input_clock_period  4;                # Period of input clock (full-period)
set dv_bre              0.8;             # Data valid before the rising clock edge
set dv_are              0.8;             # Data valid after the rising clock edge
set dv_bfe              0.8;             # Data valid before the falling clock edge
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

set fwclk        gen_sync_clk;      # forwarded clock name (generated using create_generated_clock at output clock port)
set tsu          1.000;           # destination device setup time requirement
set thd          1.500;           # destination device hold time requirement
set trce_dly_max 0.000;            # maximum board trace delay
set trce_dly_min 0.000;            # minimum board trace delay
set output_ports {o_clk_frame};   # list of output ports

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

# set fwclk        usb_clk;      # forwarded clock name (generated using create_generated_clock at output clock port)
set fwclk        gen_spi_clk;      # forwarded clock name (generated using create_generated_clock at output clock port)
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
set input_clock_period  10;              # Period of input clock
set dv_bre              2.5;          # Data valid before the rising clock edge
set dv_are              2.500;          # Data valid after the rising clock edge
set input_ports         {i_cdce_sdo i_pll_status i_adc_sdo i_dac_sdo i_mon_sdo i_mon_n_int};     # List of input ports

# Input Delay Constraint
set_input_delay -clock $input_clock -max [expr $input_clock_period - $dv_bre] [get_ports $input_ports];
set_input_delay -clock $input_clock -min $dv_are                              [get_ports $input_ports];

##################################################################################
# others (input ports): asynchronuous ports
##################################################################################

# set_false_path -from [get_ports "i_hardware_id*"]
# set_false_path -from [get_ports "i_reset"]
set_false_path -to   [get_ports "o_leds*"]
set_false_path -to   [get_ports "o_led_fw"]
set_false_path -to   [get_ports "o_led_pll_lock"]
set_false_path  -from [get_clocks sys_clk] -to [get_cells inst_fpasim_top/inst_regdecode_top/gen_debug_ila.count_r1*]
set_false_path -from [get_clocks usb_clk] -to  [get_cells gen_debug.count_r1*]

# set a delay = usb_clk period
# set_max_delay 9.9 -datapath_only -from [get_ports "i_pll_status"]
# set_max_delay 9.9 -datapath_only -from [get_ports "i_mon_n_int"]
# set_max_delay 9.9 -datapath_only -from [get_ports "i_adc_sdo"]
# set_max_delay 9.9 -datapath_only -from [get_ports "i_mon_sdo"]
# set_max_delay 9.9 -datapath_only -from [get_ports "i_cdce_sdo"]
# set_max_delay 9.9 -datapath_only -from [get_ports "i_dac_sdo"]
##################################################################################
# SPI: IO
#   use IO register when possible
##################################################################################
# shared spi links
set_property IOB true [get_ports o_spi_sclk]
set_property IOB true [get_ports o_spi_sdata]
# CDCE
set_property IOB true [get_ports i_cdce_sdo]
set_property IOB true [get_ports o_cdce_n_en]
set_property IOB true [get_ports i_pll_status]
# set_property IOB true [get_ports o_cdce_n_reset]
# set_property IOB true [get_ports o_cdce_n_pd]
set_property IOB true [get_ports o_ref_en]
# ADC
set_property IOB true [get_ports i_adc_sdo]
set_property IOB true [get_ports o_adc_n_en]
# set_property IOB true [get_ports o_adc_reset] # stuck to a constant value
# DAC
set_property IOB true [get_ports i_dac_sdo]
set_property IOB true [get_ports o_dac_n_en]
set_property IOB true [get_ports o_tx_enable]
set_property IOB true [get_ports i_mon_sdo]
# AMC
set_property IOB true [get_ports o_mon_n_en]
set_property IOB true [get_ports i_mon_n_int]
# set_property IOB true [get_ports o_mon_n_reset]

##################################################################################
# Sync: IO
##################################################################################
set_property IOB true [get_ports o_clk_ref]
set_property IOB true [get_ports o_clk_frame]

##################################################################################
# usb: IO
##################################################################################
# set_property IOB true [get_ports i_okUH*] # connected to a mmcm
# set_property IOB true [get_ports o_okHU*]
# set_property IOB true [get_ports b_okUHU*]
# set_property IOB true [get_ports b_okAA]

##################################################################################
# adc: IO
##################################################################################
# set_property IOB true [get_ports i_clk_ab_p]
# set_property IOB true [get_ports i_cha*_p]
# set_property IOB true [get_ports i_chb*_p]

##################################################################################
# dac: IO
##################################################################################
# set_property IOB true [get_ports o_dac_dclk_p]
# set_property IOB true [get_ports o_frame_p]
# set_property IOB true [get_ports o_dac_d*_p]
