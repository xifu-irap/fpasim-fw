onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group tes_top -expand -group in /tb_tes_top/inst_tes_top/i_clk
add wave -noupdate -expand -group tes_top -expand -group in /tb_tes_top/inst_tes_top/i_rst
add wave -noupdate -expand -group tes_top -expand -group in /tb_tes_top/inst_tes_top/i_rst_status
add wave -noupdate -expand -group tes_top -expand -group in /tb_tes_top/inst_tes_top/i_debug_pulse
add wave -noupdate -expand -group tes_top -expand -group in /tb_tes_top/inst_tes_top/i_en
add wave -noupdate -expand -group tes_top -expand -group in -radix unsigned /tb_tes_top/inst_tes_top/i_pixel_length
add wave -noupdate -expand -group tes_top -expand -group in -radix unsigned /tb_tes_top/inst_tes_top/i_frame_length
add wave -noupdate -expand -group tes_top -expand -group in -group cmd /tb_tes_top/inst_tes_top/i_cmd_valid
add wave -noupdate -expand -group tes_top -expand -group in -group cmd /tb_tes_top/inst_tes_top/i_cmd_pulse_height
add wave -noupdate -expand -group tes_top -expand -group in -group cmd -radix unsigned /tb_tes_top/inst_tes_top/i_cmd_pixel_id
add wave -noupdate -expand -group tes_top -expand -group in -group cmd -radix unsigned /tb_tes_top/inst_tes_top/i_cmd_time_shift
add wave -noupdate -expand -group tes_top -expand -group in -group ram_pulse_shape /tb_tes_top/inst_tes_top/i_pulse_shape_wr_en
add wave -noupdate -expand -group tes_top -expand -group in -group ram_pulse_shape /tb_tes_top/inst_tes_top/i_pulse_shape_rd_en
add wave -noupdate -expand -group tes_top -expand -group in -group ram_pulse_shape -radix unsigned /tb_tes_top/inst_tes_top/i_pulse_shape_wr_rd_addr
add wave -noupdate -expand -group tes_top -expand -group in -group ram_pulse_shape /tb_tes_top/inst_tes_top/i_pulse_shape_wr_data
add wave -noupdate -expand -group tes_top -expand -group in -group ram_pulse_shape /tb_tes_top/inst_tes_top/o_pulse_shape_rd_valid
add wave -noupdate -expand -group tes_top -expand -group in -group ram_pulse_shape /tb_tes_top/inst_tes_top/o_pulse_shape_rd_data
add wave -noupdate -expand -group tes_top -expand -group in -group ram_steady_state /tb_tes_top/inst_tes_top/i_steady_state_wr_en
add wave -noupdate -expand -group tes_top -expand -group in -group ram_steady_state /tb_tes_top/inst_tes_top/i_steady_state_rd_en
add wave -noupdate -expand -group tes_top -expand -group in -group ram_steady_state -radix unsigned /tb_tes_top/inst_tes_top/i_steady_state_wr_rd_addr
add wave -noupdate -expand -group tes_top -expand -group in -group ram_steady_state /tb_tes_top/inst_tes_top/i_steady_state_wr_data
add wave -noupdate -expand -group tes_top -expand -group in -group ram_steady_state /tb_tes_top/inst_tes_top/o_steady_state_rd_valid
add wave -noupdate -expand -group tes_top -expand -group in -group ram_steady_state /tb_tes_top/inst_tes_top/o_steady_state_rd_data
add wave -noupdate -expand -group tes_top -expand -group in -group data /tb_tes_top/inst_tes_top/i_data_valid
add wave -noupdate -expand -group tes_top -expand -group out -expand -group data /tb_tes_top/inst_tes_top/o_pixel_sof
add wave -noupdate -expand -group tes_top -expand -group out -expand -group data /tb_tes_top/inst_tes_top/o_pixel_eof
add wave -noupdate -expand -group tes_top -expand -group out -expand -group data /tb_tes_top/inst_tes_top/o_pixel_valid
add wave -noupdate -expand -group tes_top -expand -group out -expand -group data -radix unsigned /tb_tes_top/inst_tes_top/o_pixel_id
add wave -noupdate -expand -group tes_top -expand -group out -expand -group data /tb_tes_top/inst_tes_top/o_pixel_result
add wave -noupdate -expand -group tes_top -expand -group out -expand -group data /tb_tes_top/inst_tes_top/o_frame_sof
add wave -noupdate -expand -group tes_top -expand -group out -expand -group data /tb_tes_top/inst_tes_top/o_frame_eof
add wave -noupdate -expand -group tes_top -expand -group out -expand -group data -radix unsigned /tb_tes_top/inst_tes_top/o_frame_id
add wave -noupdate -expand -group tes_top -expand -group out -expand -group errors_status -color Red /tb_tes_top/inst_tes_top/o_errors
add wave -noupdate -expand -group tes_top -expand -group out -expand -group errors_status /tb_tes_top/inst_tes_top/o_status
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {376 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 387
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ps} {653 ps}
