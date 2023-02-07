onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group io_top /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/i_sys_clk
add wave -noupdate -group io_top /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/o_adc_valid
add wave -noupdate -group io_top -radix unsigned /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/o_adc_a
add wave -noupdate -group io_top -radix unsigned /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/o_adc_b
add wave -noupdate -group io_top -expand -group dac -expand -group in /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/i_dac_rst
add wave -noupdate -group io_top -expand -group dac -expand -group in -group rst /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/i_dac_io_rst
add wave -noupdate -group io_top -expand -group dac -expand -group in /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/i_dac_valid
add wave -noupdate -group io_top -expand -group dac -expand -group in /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/i_dac_frame
add wave -noupdate -group io_top -expand -group dac -expand -group in /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/i_dac
add wave -noupdate -group io_top -expand -group dac -expand -group in /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/o_dac_errors
add wave -noupdate -group io_top -expand -group dac -expand -group in /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/o_dac_status
add wave -noupdate -group io_top -expand -group dac -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/o_dac_clk_p
add wave -noupdate -group io_top -expand -group dac -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/o_dac_clk_n
add wave -noupdate -group io_top -expand -group dac -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/o_dac_frame_p
add wave -noupdate -group io_top -expand -group dac -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/o_dac_frame_n
add wave -noupdate -group io_top -expand -group dac -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/o_dac0_p
add wave -noupdate -group io_top -expand -group dac -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/o_dac0_n
add wave -noupdate -group io_top -expand -group dac -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/o_dac1_p
add wave -noupdate -group io_top -expand -group dac -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/o_dac1_n
add wave -noupdate -group io_top -expand -group dac -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/o_dac2_p
add wave -noupdate -group io_top -expand -group dac -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/o_dac2_n
add wave -noupdate -group io_top -expand -group dac -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/o_dac3_p
add wave -noupdate -group io_top -expand -group dac -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/o_dac3_n
add wave -noupdate -group io_top -expand -group dac -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/o_dac4_p
add wave -noupdate -group io_top -expand -group dac -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/o_dac4_n
add wave -noupdate -group io_top -expand -group dac -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/o_dac5_p
add wave -noupdate -group io_top -expand -group dac -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/o_dac5_n
add wave -noupdate -group io_top -expand -group dac -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/o_dac6_p
add wave -noupdate -group io_top -expand -group dac -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/o_dac6_n
add wave -noupdate -group io_top -expand -group dac -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/o_dac7_p
add wave -noupdate -group io_top -expand -group dac -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_io_top/o_dac7_n
add wave -noupdate -group dac_demux /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_dac3283_top/inst_dac3283_demux/i_clk
add wave -noupdate -group dac_demux /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_dac3283_top/inst_dac3283_demux/i_rst
add wave -noupdate -group dac_demux /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_dac3283_top/inst_dac3283_demux/i_rst
add wave -noupdate -group dac_demux -group in /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_dac3283_top/inst_dac3283_demux/i_dac_frame
add wave -noupdate -group dac_demux -group in /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_dac3283_top/inst_dac3283_demux/i_dac
add wave -noupdate -group dac_demux -group step /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_dac3283_top/inst_dac3283_demux/sm_state_r1
add wave -noupdate -group dac_demux -group step /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_dac3283_top/inst_dac3283_demux/data_valid0_r1
add wave -noupdate -group dac_demux -group step /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_dac3283_top/inst_dac3283_demux/data0_r1
add wave -noupdate -group dac_demux -group step /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_dac3283_top/inst_dac3283_demux/data_valid1_r1
add wave -noupdate -group dac_demux -group step /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_dac3283_top/inst_dac3283_demux/data1_r1
add wave -noupdate -group dac_demux -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_dac3283_top/inst_dac3283_demux/o_dac0_valid
add wave -noupdate -group dac_demux -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_dac3283_top/inst_dac3283_demux/o_dac0
add wave -noupdate -group dac_demux -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_dac3283_top/inst_dac3283_demux/o_dac1_valid
add wave -noupdate -group dac_demux -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_dac3283_top/inst_dac3283_demux/o_dac1
add wave -noupdate -expand -group fpga_system_fpasim_top /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/i_make_pulse_valid
add wave -noupdate -expand -group fpga_system_fpasim_top /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/i_make_pulse
add wave -noupdate -expand -group fpga_system_fpasim_top /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/o_auto_conf_busy
add wave -noupdate -expand -group fpga_system_fpasim_top /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/o_ready
add wave -noupdate -expand -group fpga_system_fpasim_top /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/i_adc_clk
add wave -noupdate -expand -group fpga_system_fpasim_top /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/i_adc0_real
add wave -noupdate -expand -group fpga_system_fpasim_top /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/i_adc1_real
add wave -noupdate -expand -group fpga_system_fpasim_top /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/o_ref_clk
add wave -noupdate -expand -group fpga_system_fpasim_top /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/o_sync
add wave -noupdate -expand -group fpga_system_fpasim_top /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/o_dac_real_valid
add wave -noupdate -expand -group fpga_system_fpasim_top /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/o_dac_real
add wave -noupdate -group convert_adc0 /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_ads62p49_top/inst_ads62p49_convert_adc0/i_clk
add wave -noupdate -group convert_adc0 /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_ads62p49_top/inst_ads62p49_convert_adc0/i_adc
add wave -noupdate -group convert_adc0 -group step /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_ads62p49_top/inst_ads62p49_convert_adc0/f_adc_tmp0
add wave -noupdate -group convert_adc0 -group step /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_ads62p49_top/inst_ads62p49_convert_adc0/s_adc_tmp0
add wave -noupdate -group convert_adc0 -group step /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_ads62p49_top/inst_ads62p49_convert_adc0/c_FACTOR
add wave -noupdate -group convert_adc0 -radix unsigned /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_ads62p49_top/inst_ads62p49_convert_adc0/o_ddr_adc
add wave -noupdate -group convert_adc1 /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_ads62p49_top/inst_ads62p49_convert_adc1/i_clk
add wave -noupdate -group convert_adc1 /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_ads62p49_top/inst_ads62p49_convert_adc1/i_adc
add wave -noupdate -group convert_adc1 -radix unsigned /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_ads62p49_top/inst_ads62p49_convert_adc1/o_ddr_adc
add wave -noupdate -group dac_top /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_fpasim_top/inst_dac_top/i_clk
add wave -noupdate -group dac_top /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_fpasim_top/inst_dac_top/i_rst
add wave -noupdate -group dac_top /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_fpasim_top/inst_dac_top/c_LATENCY_OUT
add wave -noupdate -group dac_top -group in /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_fpasim_top/inst_dac_top/i_dac_valid
add wave -noupdate -group dac_top -group in /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_fpasim_top/inst_dac_top/i_dac
add wave -noupdate -group dac_top -group in -radix unsigned /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_fpasim_top/inst_dac_top/i_dac_delay
add wave -noupdate -group dac_top -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_fpasim_top/inst_dac_top/o_dac_valid
add wave -noupdate -group dac_top -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_fpasim_top/inst_dac_top/o_dac_frame
add wave -noupdate -group dac_top -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_fpasim_top/inst_dac_top/o_dac
add wave -noupdate -group sync_top /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_fpasim_top/inst_sync_top/i_clk
add wave -noupdate -group sync_top /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_fpasim_top/inst_sync_top/i_rst
add wave -noupdate -group sync_top /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_fpasim_top/inst_sync_top/i_rst_status
add wave -noupdate -group sync_top -expand -group in /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_fpasim_top/inst_sync_top/i_debug_pulse
add wave -noupdate -group sync_top -expand -group in -radix unsigned /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_fpasim_top/inst_sync_top/i_sync_delay
add wave -noupdate -group sync_top -expand -group in /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_fpasim_top/inst_sync_top/i_sync_valid
add wave -noupdate -group sync_top -expand -group in /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_fpasim_top/inst_sync_top/i_sync
add wave -noupdate -group sync_top -expand -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_fpasim_top/inst_sync_top/o_sync_valid
add wave -noupdate -group sync_top -expand -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_fpasim_top/inst_sync_top/o_sync
add wave -noupdate -group sync_top -expand -group out /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_system_fpasim_top/inst_fpasim_top/inst_sync_top/o_errors
add wave -noupdate -group dac3283_top /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_dac3283_top/dac_clk
add wave -noupdate -group dac3283_top /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_dac3283_top/dac_frame
add wave -noupdate -group dac3283_top -radix unsigned /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_dac3283_top/dac
add wave -noupdate -group dac3283_top /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_dac3283_top/dac0_valid
add wave -noupdate -group dac3283_top /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_dac3283_top/dac0
add wave -noupdate -group dac3283_top /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_dac3283_top/dac1_valid
add wave -noupdate -group dac3283_top /tb_fpga_system_fpasim_top/inst_fpga_system_fpasim_top/inst_fpga_system_fpasim/inst_dac3283_top/dac1
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4288100 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 234
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {4230728 ps} {4345472 ps}
