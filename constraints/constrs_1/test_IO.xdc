#######################################
# xem7350 : system clock
######################################
# create_clock -name sys_clk -period 5 [get_ports sys_clkp]

########################################
# usb
#######################################
create_clock -period 9.920 -name okUH0 [get_ports {okUH[0]}]
create_clock -period 9.920 -name virt_okUH0

set_clock_groups -name async-mmcm-user-virt -asynchronous -group mmcm0_clk0 -group virt_okUH0

set_input_delay -clock [get_clocks virt_okUH0] -max -add_delay 8.000 [get_ports {okUH[*]}]
set_input_delay -clock [get_clocks virt_okUH0] -min -add_delay 0.000 [get_ports {okUH[*]}]

set_input_delay -clock [get_clocks virt_okUH0] -max -add_delay 8.000 [get_ports {okUHU[*]}]
set_input_delay -clock [get_clocks virt_okUH0] -min -add_delay 2.000 [get_ports {okUHU[*]}]

set_output_delay -clock [get_clocks okUH0] -max -add_delay 2.000 [get_ports {okHU[*]}]
set_output_delay -clock [get_clocks okUH0] -min -add_delay -0.500 [get_ports {okHU[*]}]

set_output_delay -clock [get_clocks okUH0] -max -add_delay 2.000 [get_ports {okUHU[*]}]
set_output_delay -clock [get_clocks okUH0] -min -add_delay -0.500 [get_ports {okUHU[*]}]


#######################################
# rename auto-derived clock
######################################
create_generated_clock -name adc_clk -source [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKIN1] -master_clock [get_clocks i_adc_clk_p] [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKOUT0]
create_generated_clock -name ref_clk -source [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKIN1] -master_clock [get_clocks i_adc_clk_p] [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKOUT1]
create_generated_clock -name dac_clk -source [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKIN1] -master_clock [get_clocks i_adc_clk_p] [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKOUT2]
create_generated_clock -name clk -source [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKIN1] -master_clock [get_clocks i_adc_clk_p] [get_pins inst_clocking_top/inst_fpasim_clk_wiz_0/inst/mmcm_adv_inst/CLKOUT3]











create_generated_clock -name gen_dac_clk -source [get_pins inst_io_top/inst_io_dac/gen_io_dac.inst_selectio_wiz_dac/inst/oddr_inst/C] -divide_by 1 [get_ports o_dac_clk_p]
create_generated_clock -name gen_ref_clk -source [get_pins inst_io_top/inst_io_sync/gen_io_sync.inst_selectio_wiz_sync/inst/oddr_inst/C] -divide_by 1 [get_ports o_ref_clk]
set_input_delay -clock [get_clocks i_adc_clk_p] -clock_fall -min -add_delay 0.950 [get_ports i_da0_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -clock_fall -max -add_delay 1.100 [get_ports i_da0_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -min -add_delay 0.950 [get_ports i_da0_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -max -add_delay 1.100 [get_ports i_da0_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -clock_fall -min -add_delay 0.950 [get_ports i_da10_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -clock_fall -max -add_delay 1.100 [get_ports i_da10_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -min -add_delay 0.950 [get_ports i_da10_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -max -add_delay 1.100 [get_ports i_da10_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -clock_fall -min -add_delay 0.950 [get_ports i_da12_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -clock_fall -max -add_delay 1.100 [get_ports i_da12_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -min -add_delay 0.950 [get_ports i_da12_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -max -add_delay 1.100 [get_ports i_da12_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -clock_fall -min -add_delay 0.950 [get_ports i_da2_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -clock_fall -max -add_delay 1.100 [get_ports i_da2_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -min -add_delay 0.950 [get_ports i_da2_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -max -add_delay 1.100 [get_ports i_da2_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -clock_fall -min -add_delay 0.950 [get_ports i_da4_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -clock_fall -max -add_delay 1.100 [get_ports i_da4_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -min -add_delay 0.950 [get_ports i_da4_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -max -add_delay 1.100 [get_ports i_da4_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -clock_fall -min -add_delay 0.950 [get_ports i_da6_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -clock_fall -max -add_delay 1.100 [get_ports i_da6_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -min -add_delay 0.950 [get_ports i_da6_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -max -add_delay 1.100 [get_ports i_da6_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -clock_fall -min -add_delay 0.950 [get_ports i_da8_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -clock_fall -max -add_delay 1.100 [get_ports i_da8_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -min -add_delay 0.950 [get_ports i_da8_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -max -add_delay 1.100 [get_ports i_da8_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -clock_fall -min -add_delay 0.950 [get_ports i_db0_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -clock_fall -max -add_delay 1.100 [get_ports i_db0_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -min -add_delay 0.950 [get_ports i_db0_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -max -add_delay 1.100 [get_ports i_db0_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -clock_fall -min -add_delay 0.950 [get_ports i_db10_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -clock_fall -max -add_delay 1.100 [get_ports i_db10_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -min -add_delay 0.950 [get_ports i_db10_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -max -add_delay 1.100 [get_ports i_db10_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -clock_fall -min -add_delay 0.950 [get_ports i_db12_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -clock_fall -max -add_delay 1.100 [get_ports i_db12_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -min -add_delay 0.950 [get_ports i_db12_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -max -add_delay 1.100 [get_ports i_db12_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -clock_fall -min -add_delay 0.950 [get_ports i_db2_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -clock_fall -max -add_delay 1.100 [get_ports i_db2_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -min -add_delay 0.950 [get_ports i_db2_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -max -add_delay 1.100 [get_ports i_db2_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -clock_fall -min -add_delay 0.950 [get_ports i_db4_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -clock_fall -max -add_delay 1.100 [get_ports i_db4_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -min -add_delay 0.950 [get_ports i_db4_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -max -add_delay 1.100 [get_ports i_db4_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -clock_fall -min -add_delay 0.950 [get_ports i_db6_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -clock_fall -max -add_delay 1.100 [get_ports i_db6_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -min -add_delay 0.950 [get_ports i_db6_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -max -add_delay 1.100 [get_ports i_db6_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -clock_fall -min -add_delay 0.950 [get_ports i_db8_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -clock_fall -max -add_delay 1.100 [get_ports i_db8_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -min -add_delay 0.950 [get_ports i_db8_p]
set_input_delay -clock [get_clocks i_adc_clk_p] -max -add_delay 1.100 [get_ports i_db8_p]
set_output_delay -clock [get_clocks gen_dac_clk] -clock_fall -min -add_delay -0.375 [get_ports o_dac0_p]
set_output_delay -clock [get_clocks gen_dac_clk] -clock_fall -max -add_delay 0.025 [get_ports o_dac0_p]
set_output_delay -clock [get_clocks gen_dac_clk] -min -add_delay -0.375 [get_ports o_dac0_p]
set_output_delay -clock [get_clocks gen_dac_clk] -max -add_delay 0.025 [get_ports o_dac0_p]
set_output_delay -clock [get_clocks gen_dac_clk] -clock_fall -min -add_delay -0.375 [get_ports o_dac1_p]
set_output_delay -clock [get_clocks gen_dac_clk] -clock_fall -max -add_delay 0.025 [get_ports o_dac1_p]
set_output_delay -clock [get_clocks gen_dac_clk] -min -add_delay -0.375 [get_ports o_dac1_p]
set_output_delay -clock [get_clocks gen_dac_clk] -max -add_delay 0.025 [get_ports o_dac1_p]
set_output_delay -clock [get_clocks gen_dac_clk] -clock_fall -min -add_delay -0.375 [get_ports o_dac2_p]
set_output_delay -clock [get_clocks gen_dac_clk] -clock_fall -max -add_delay 0.025 [get_ports o_dac2_p]
set_output_delay -clock [get_clocks gen_dac_clk] -min -add_delay -0.375 [get_ports o_dac2_p]
set_output_delay -clock [get_clocks gen_dac_clk] -max -add_delay 0.025 [get_ports o_dac2_p]
set_output_delay -clock [get_clocks gen_dac_clk] -clock_fall -min -add_delay -0.375 [get_ports o_dac3_p]
set_output_delay -clock [get_clocks gen_dac_clk] -clock_fall -max -add_delay 0.025 [get_ports o_dac3_p]
set_output_delay -clock [get_clocks gen_dac_clk] -min -add_delay -0.375 [get_ports o_dac3_p]
set_output_delay -clock [get_clocks gen_dac_clk] -max -add_delay 0.025 [get_ports o_dac3_p]
set_output_delay -clock [get_clocks gen_dac_clk] -clock_fall -min -add_delay -0.375 [get_ports o_dac4_p]
set_output_delay -clock [get_clocks gen_dac_clk] -clock_fall -max -add_delay 0.025 [get_ports o_dac4_p]
set_output_delay -clock [get_clocks gen_dac_clk] -min -add_delay -0.375 [get_ports o_dac4_p]
set_output_delay -clock [get_clocks gen_dac_clk] -max -add_delay 0.025 [get_ports o_dac4_p]
set_output_delay -clock [get_clocks gen_dac_clk] -clock_fall -min -add_delay -0.375 [get_ports o_dac5_p]
set_output_delay -clock [get_clocks gen_dac_clk] -clock_fall -max -add_delay 0.025 [get_ports o_dac5_p]
set_output_delay -clock [get_clocks gen_dac_clk] -min -add_delay -0.375 [get_ports o_dac5_p]
set_output_delay -clock [get_clocks gen_dac_clk] -max -add_delay 0.025 [get_ports o_dac5_p]
set_output_delay -clock [get_clocks gen_dac_clk] -clock_fall -min -add_delay -0.375 [get_ports o_dac6_p]
set_output_delay -clock [get_clocks gen_dac_clk] -clock_fall -max -add_delay 0.025 [get_ports o_dac6_p]
set_output_delay -clock [get_clocks gen_dac_clk] -min -add_delay -0.375 [get_ports o_dac6_p]
set_output_delay -clock [get_clocks gen_dac_clk] -max -add_delay 0.025 [get_ports o_dac6_p]
set_output_delay -clock [get_clocks gen_dac_clk] -clock_fall -min -add_delay -0.375 [get_ports o_dac7_p]
set_output_delay -clock [get_clocks gen_dac_clk] -clock_fall -max -add_delay 0.025 [get_ports o_dac7_p]
set_output_delay -clock [get_clocks gen_dac_clk] -min -add_delay -0.375 [get_ports o_dac7_p]
set_output_delay -clock [get_clocks gen_dac_clk] -max -add_delay 0.025 [get_ports o_dac7_p]
set_output_delay -clock [get_clocks gen_dac_clk] -clock_fall -min -add_delay -0.375 [get_ports o_dac_frame_p]
set_output_delay -clock [get_clocks gen_dac_clk] -clock_fall -max -add_delay 0.025 [get_ports o_dac_frame_p]
set_output_delay -clock [get_clocks gen_dac_clk] -min -add_delay -0.375 [get_ports o_dac_frame_p]
set_output_delay -clock [get_clocks gen_dac_clk] -max -add_delay 0.025 [get_ports o_dac_frame_p]

set_output_delay -clock [get_clocks gen_ref_clk] -min -add_delay -1.000 [get_ports o_sync]
set_output_delay -clock [get_clocks gen_ref_clk] -max -add_delay 1.000 [get_ports o_sync]
