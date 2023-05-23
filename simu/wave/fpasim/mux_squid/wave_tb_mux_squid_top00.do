onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group mux_squid /tb_mux_squid_top/dut_mux_squid_top/i_clk
add wave -noupdate -expand -group mux_squid -group in /tb_mux_squid_top/dut_mux_squid_top/i_rst_status
add wave -noupdate -expand -group mux_squid -group in /tb_mux_squid_top/dut_mux_squid_top/i_debug_pulse
add wave -noupdate -expand -group mux_squid -group in /tb_mux_squid_top/i_inter_squid_gain
add wave -noupdate -expand -group mux_squid -group in -group ram_mux_squid_offset /tb_mux_squid_top/dut_mux_squid_top/i_mux_squid_offset_wr_en
add wave -noupdate -expand -group mux_squid -group in -group ram_mux_squid_offset -radix unsigned /tb_mux_squid_top/dut_mux_squid_top/i_mux_squid_offset_wr_rd_addr
add wave -noupdate -expand -group mux_squid -group in -group ram_mux_squid_offset -radix unsigned /tb_mux_squid_top/dut_mux_squid_top/i_mux_squid_offset_wr_data
add wave -noupdate -expand -group mux_squid -group in -group ram_mux_squid_offset /tb_mux_squid_top/dut_mux_squid_top/i_mux_squid_offset_rd_en
add wave -noupdate -expand -group mux_squid -group in -group ram_mux_squid_offset /tb_mux_squid_top/dut_mux_squid_top/o_mux_squid_offset_rd_valid
add wave -noupdate -expand -group mux_squid -group in -group ram_mux_squid_offset /tb_mux_squid_top/dut_mux_squid_top/o_mux_squid_offset_rd_data
add wave -noupdate -expand -group mux_squid -group in -group ram_mux_squid_tf /tb_mux_squid_top/dut_mux_squid_top/i_mux_squid_tf_wr_en
add wave -noupdate -expand -group mux_squid -group in -group ram_mux_squid_tf -radix unsigned /tb_mux_squid_top/dut_mux_squid_top/i_mux_squid_tf_wr_rd_addr
add wave -noupdate -expand -group mux_squid -group in -group ram_mux_squid_tf /tb_mux_squid_top/dut_mux_squid_top/i_mux_squid_tf_wr_data
add wave -noupdate -expand -group mux_squid -group in -group ram_mux_squid_tf /tb_mux_squid_top/dut_mux_squid_top/i_mux_squid_tf_rd_en
add wave -noupdate -expand -group mux_squid -group in -group ram_mux_squid_tf /tb_mux_squid_top/dut_mux_squid_top/o_mux_squid_tf_rd_valid
add wave -noupdate -expand -group mux_squid -group in -group ram_mux_squid_tf /tb_mux_squid_top/dut_mux_squid_top/o_mux_squid_tf_rd_data
add wave -noupdate -expand -group mux_squid -group in -radix unsigned /tb_mux_squid_top/dut_mux_squid_top/i_mux_squid_feedback
add wave -noupdate -expand -group mux_squid -group in -expand -group data /tb_mux_squid_top/dut_mux_squid_top/i_pixel_sof
add wave -noupdate -expand -group mux_squid -group in -expand -group data /tb_mux_squid_top/dut_mux_squid_top/i_pixel_eof
add wave -noupdate -expand -group mux_squid -group in -expand -group data /tb_mux_squid_top/dut_mux_squid_top/i_pixel_valid
add wave -noupdate -expand -group mux_squid -group in -expand -group data -radix unsigned /tb_mux_squid_top/dut_mux_squid_top/i_pixel_id
add wave -noupdate -expand -group mux_squid -group in -expand -group data -radix unsigned /tb_mux_squid_top/dut_mux_squid_top/i_pixel_result
add wave -noupdate -expand -group mux_squid -group in -expand -group data /tb_mux_squid_top/dut_mux_squid_top/i_frame_sof
add wave -noupdate -expand -group mux_squid -group in -expand -group data /tb_mux_squid_top/dut_mux_squid_top/i_frame_eof
add wave -noupdate -expand -group mux_squid -group in -expand -group data -radix unsigned /tb_mux_squid_top/dut_mux_squid_top/i_frame_id
add wave -noupdate -expand -group mux_squid -group sub_sfixed_mux_squid -group pixel_result_tmp -radix sfixed /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/inst_sub_sfixed_mux_squid/a_r1
add wave -noupdate -expand -group mux_squid -group sub_sfixed_mux_squid -group mux_squid_feedback_tmp -radix sfixed /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/inst_sub_sfixed_mux_squid/b_r1
add wave -noupdate -expand -group mux_squid -group sub_sfixed_mux_squid -radix sfixed /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/inst_sub_sfixed_mux_squid/res_r2
add wave -noupdate -expand -group mux_squid -group sub_sfixed_mux_squid -radix decimal /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/inst_sub_sfixed_mux_squid/o_s
add wave -noupdate -expand -group mux_squid -group stepx /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/pixel_sof_rx
add wave -noupdate -expand -group mux_squid -group stepx /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/pixel_eof_rx
add wave -noupdate -expand -group mux_squid -group stepx /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/pixel_valid_rx
add wave -noupdate -expand -group mux_squid -group stepx -radix unsigned /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/pixel_id_rx
add wave -noupdate -expand -group mux_squid -group stepx -radix decimal /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/result_sub_rx
add wave -noupdate -expand -group mux_squid -group stepy /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/pixel_sof_ry
add wave -noupdate -expand -group mux_squid -group stepy /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/pixel_eof_ry
add wave -noupdate -expand -group mux_squid -group stepy /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/pixel_valid_ry
add wave -noupdate -expand -group mux_squid -group stepy -radix unsigned /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/pixel_id_ry
add wave -noupdate -expand -group mux_squid -group stepy -radix decimal /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/mux_squid_offset_ry
add wave -noupdate -expand -group mux_squid -group stepy -radix decimal /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/mux_squid_tf_doutb
add wave -noupdate -expand -group mux_squid -group stepz /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/pixel_sof_rz
add wave -noupdate -expand -group mux_squid -group stepz /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/pixel_eof_rz
add wave -noupdate -expand -group mux_squid -group stepz /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/pixel_valid_rz
add wave -noupdate -expand -group mux_squid -group stepz -radix unsigned /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/pixel_id_rz
add wave -noupdate -expand -group mux_squid -group stepz -radix decimal /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/result_rz
add wave -noupdate -expand -group mux_squid -group mult_add_sfixed /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/pixel_sof_ry
add wave -noupdate -expand -group mux_squid -group mult_add_sfixed /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/pixel_eof_ry
add wave -noupdate -expand -group mux_squid -group mult_add_sfixed /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/pixel_valid_ry
add wave -noupdate -expand -group mux_squid -group mult_add_sfixed /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/pixel_id_ry
add wave -noupdate -expand -group mux_squid -group mult_add_sfixed -expand -group inter_squid_gain_tmp -radix sfixed /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/inst_mult_add_sfixed_mux_squid_offset_and_tf/a_r1
add wave -noupdate -expand -group mux_squid -group mult_add_sfixed -expand -group mux_squid_tf_tmp -radix sfixed /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/inst_mult_add_sfixed_mux_squid_offset_and_tf/b_r1
add wave -noupdate -expand -group mux_squid -group mult_add_sfixed -expand -group mux_squid_offset_tmp -radix sfixed /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/inst_mult_add_sfixed_mux_squid_offset_and_tf/c_r1
add wave -noupdate -expand -group mux_squid -group mult_add_sfixed -expand -group a*b -radix sfixed /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/inst_mult_add_sfixed_mux_squid_offset_and_tf/mult_r2
add wave -noupdate -expand -group mux_squid -group mult_add_sfixed -expand -group a*b+c -radix sfixed /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/inst_mult_add_sfixed_mux_squid_offset_and_tf/res_r3
add wave -noupdate -expand -group mux_squid -group mult_add_sfixed -radix decimal /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/inst_mult_add_sfixed_mux_squid_offset_and_tf/o_s
add wave -noupdate -expand -group mux_squid -group out -expand -group data /tb_mux_squid_top/dut_mux_squid_top/o_pixel_sof
add wave -noupdate -expand -group mux_squid -group out -expand -group data /tb_mux_squid_top/dut_mux_squid_top/o_pixel_eof
add wave -noupdate -expand -group mux_squid -group out -expand -group data /tb_mux_squid_top/dut_mux_squid_top/o_pixel_valid
add wave -noupdate -expand -group mux_squid -group out -expand -group data -radix unsigned /tb_mux_squid_top/dut_mux_squid_top/o_pixel_id
add wave -noupdate -expand -group mux_squid -group out -expand -group data -radix decimal /tb_mux_squid_top/dut_mux_squid_top/o_pixel_result
add wave -noupdate -expand -group mux_squid -group out -expand -group data /tb_mux_squid_top/dut_mux_squid_top/o_frame_sof
add wave -noupdate -expand -group mux_squid -group out -expand -group data /tb_mux_squid_top/dut_mux_squid_top/o_frame_eof
add wave -noupdate -expand -group mux_squid -group out -expand -group data -radix unsigned /tb_mux_squid_top/dut_mux_squid_top/o_frame_id
add wave -noupdate -expand -group mux_squid -group out -group error_status -color Magenta /tb_mux_squid_top/dut_mux_squid_top/o_errors
add wave -noupdate -expand -group mux_squid -group out -group error_status /tb_mux_squid_top/dut_mux_squid_top/o_status
add wave -noupdate -radix unsigned /tb_mux_squid_top/data_count_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {33120756 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 316
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
WaveRestoreZoom {32891433 ps} {33636187 ps}
