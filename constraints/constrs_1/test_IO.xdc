#######################################
# xem7350 : system clock
######################################
# create_clock -name sys_clk -period 5 [get_ports sys_clkp]

########################################
# usb
#######################################
create_clock -period 9.920 -name okUH0 [get_ports {okUH[0]}]
# create_clock -period 9.920 -name virt_okUH0

# set_clock_groups -name async-mmcm-user-virt -asynchronous -group mmcm0_clk0 -group virt_okUH0

set_input_delay -clock [get_clocks mmcm0_clk0] -max -add_delay 8.000 [get_ports {okUH[*]}]
set_input_delay -clock [get_clocks mmcm0_clk0] -min -add_delay 0.000 [get_ports {okUH[*]}]

set_input_delay -clock [get_clocks mmcm0_clk0] -max -add_delay 8.000 [get_ports {okUHU[*]}]
set_input_delay -clock [get_clocks mmcm0_clk0] -min -add_delay 2.000 [get_ports {okUHU[*]}]

set_output_delay -clock [get_clocks mmcm0_clk0] -max -add_delay 2.000 [get_ports {okHU[*]}]
set_output_delay -clock [get_clocks mmcm0_clk0] -min -add_delay -0.500 [get_ports {okHU[*]}]

set_output_delay -clock [get_clocks mmcm0_clk0] -max -add_delay 2.000 [get_ports {okUHU[*]}]
set_output_delay -clock [get_clocks mmcm0_clk0] -min -add_delay -0.500 [get_ports {okUHU[*]}]


#######################################
# rename auto-derived clock
######################################
create_generated_clock -name adc_clk -source [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKIN1] -master_clock [get_clocks i_adc_clk_p] [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKOUT0]
create_generated_clock -name ref_clk -source [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKIN1] -master_clock [get_clocks i_adc_clk_p] [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKOUT1]
create_generated_clock -name dac_clk -source [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKIN1] -master_clock [get_clocks i_adc_clk_p] [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKOUT2]
create_generated_clock -name clk -source [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKIN1] -master_clock [get_clocks i_adc_clk_p] [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKOUT3]
# create_generated_clock -name usb_clk -source [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKIN1] -master_clock [get_clocks i_adc_clk_p] [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKOUT3]

#########################################
# ODDR : forward clock
#########################################
create_generated_clock -name gen_dac_clk_out -multiply_by 1 -source [get_pins inst_io_top/inst_io_dac/gen_io_dac.inst_selectio_wiz_dac/oddr_inst/C] [get_ports {o_dac_clk_p}]
create_generated_clock -name gen_sync_clk_out -multiply_by 1 -source [get_pins inst_io_top/inst_io_sync/gen_io_sync.inst_selectio_wiz_sync/oddr_inst/C] [get_ports {o_ref_clk}]

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
set input_clock_period  4;    # Period of input clock (full-period)
set dv_bre              0.55;             # Data valid before the rising clock edge
set dv_are              0.55;             # Data valid after the rising clock edge
set dv_bfe              0.55;             # Data valid before the falling clock edge
set dv_afe              0.55;             # Data valid after the falling clock edge
set input_ports         {i_da*_p i_db*_p};     # List of input ports

# Input Delay Constraint
set_input_delay -clock $input_clock -max [expr $input_clock_period/2 - $dv_bfe] [get_ports $input_ports];
set_input_delay -clock $input_clock -min $dv_are                                [get_ports $input_ports];
set_input_delay -clock $input_clock -max [expr $input_clock_period/2 - $dv_bre] [get_ports $input_ports] -clock_fall -add_delay;
set_input_delay -clock $input_clock -min $dv_afe                                [get_ports $input_ports] -clock_fall -add_delay;

# Edge-Aligned Double Data Rate Source Synchronous Inputs 
# (Using an MMCM/PLL)
#
# For an edge-aligned Source Synchronous interface, the clock
# transition occurs at the same time as the data transitions.
# In this template, the clock is aligned with the end of the
# data. The constraints below rely on the default timing
# analysis (setup = 1/2 cycle, hold = 0 cycle).
#
# input                        ___________________________
# clock  _____________________|                           |__________
#                             |                           |                 
#                     skew_bre|skew_are           skew_bfe|skew_afe
#                     <------>|<------>           <------>|<------>
#          ___________        |        ___________                 __
# data   XX_Rise_Data_XXXXXXXXXXXXXXXXX_Fall_Data_XXXXXXXXXXXXXXXXX__
#

# set input_clock         adc_clk;      # Name of input clock
# set skew_bre            0.500;             # Data invalid before the rising clock edge
# set skew_are            0.500;             # Data invalid after the rising clock edge
# set skew_bfe            0.500;             # Data invalid before the falling clock edge
# set skew_afe            0.500;             # Data invalid after the falling clock edge
# set input_ports         {i_da*_p i_db*_p};     # List of input ports

# # Input Delay Constraint
# set_input_delay -clock $input_clock -max $skew_are  [get_ports $input_ports];
# set_input_delay -clock $input_clock -min -$skew_bre [get_ports $input_ports];
# set_input_delay -clock $input_clock -max $skew_afe  [get_ports $input_ports] -clock_fall -add_delay;
# set_input_delay -clock $input_clock -min -$skew_bfe [get_ports $input_ports] -clock_fall -add_delay;



set dac_ports {o_dac*_p}
set_output_delay -clock [get_clocks gen_dac_clk_out] -clock_fall -min -add_delay -0.375 [get_ports $dac_ports]
set_output_delay -clock [get_clocks gen_dac_clk_out] -clock_fall -max -add_delay 0.025 [get_ports $dac_ports]
set_output_delay -clock [get_clocks gen_dac_clk_out] -min -add_delay -0.375 [get_ports $dac_ports]
set_output_delay -clock [get_clocks gen_dac_clk_out] -max -add_delay 0.025 [get_ports $dac_ports]
# set_output_delay -clock [get_clocks dac_clk] -clock_fall -min -add_delay 0.025 [get_ports $dac_ports]
# set_output_delay -clock [get_clocks gen_dac_clk_out] -clock_fall -max -add_delay 1.625 [get_ports $dac_ports]
# set_output_delay -clock [get_clocks dac_clk] -min -add_delay 0.025 [get_ports $dac_ports]
# set_output_delay -clock [get_clocks dac_clk] -max -add_delay 1.625 [get_ports $dac_ports]

set dac_frame_ports {o_dac_frame_p}
set_output_delay -clock [get_clocks gen_dac_clk_out] -clock_fall -min -add_delay -0.375 [get_ports $dac_frame_ports]
set_output_delay -clock [get_clocks gen_dac_clk_out] -clock_fall -max -add_delay 0.025 [get_ports $dac_frame_ports]
set_output_delay -clock [get_clocks gen_dac_clk_out] -min -add_delay -0.375 [get_ports $dac_frame_ports]
set_output_delay -clock [get_clocks gen_dac_clk_out] -max -add_delay 0.025 [get_ports $dac_frame_ports]

set sync_frame_ports {o_sync}
set_output_delay -clock [get_clocks gen_sync_clk_out] -min -add_delay 4.000 [get_ports $sync_frame_ports]
set_output_delay -clock [get_clocks gen_sync_clk_out] -max -add_delay 12.000 [get_ports $sync_frame_ports]


