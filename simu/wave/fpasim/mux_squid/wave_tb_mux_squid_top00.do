onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group mux_squid /tb_mux_squid_top/inst_mux_squid_top/i_clk
add wave -noupdate -group mux_squid -group in /tb_mux_squid_top/inst_mux_squid_top/i_rst_status
add wave -noupdate -group mux_squid -group in /tb_mux_squid_top/inst_mux_squid_top/i_debug_pulse
add wave -noupdate -group mux_squid -group in /tb_mux_squid_top/i_inter_squid_gain
add wave -noupdate -group mux_squid -group in -group ram_mux_squid_offset /tb_mux_squid_top/inst_mux_squid_top/i_mux_squid_offset_wr_en
add wave -noupdate -group mux_squid -group in -group ram_mux_squid_offset -radix unsigned /tb_mux_squid_top/inst_mux_squid_top/i_mux_squid_offset_wr_rd_addr
add wave -noupdate -group mux_squid -group in -group ram_mux_squid_offset -format Analog-Step -height 74 -max 32646.0 -radix decimal /tb_mux_squid_top/inst_mux_squid_top/i_mux_squid_offset_wr_data
add wave -noupdate -group mux_squid -group in -group ram_mux_squid_offset /tb_mux_squid_top/inst_mux_squid_top/i_mux_squid_offset_rd_en
add wave -noupdate -group mux_squid -group in -group ram_mux_squid_offset /tb_mux_squid_top/inst_mux_squid_top/o_mux_squid_offset_rd_valid
add wave -noupdate -group mux_squid -group in -group ram_mux_squid_offset /tb_mux_squid_top/inst_mux_squid_top/o_mux_squid_offset_rd_data
add wave -noupdate -group mux_squid -group in -group ram_mux_squid_tf /tb_mux_squid_top/inst_mux_squid_top/i_mux_squid_tf_wr_en
add wave -noupdate -group mux_squid -group in -group ram_mux_squid_tf -radix unsigned /tb_mux_squid_top/inst_mux_squid_top/i_mux_squid_tf_wr_rd_addr
add wave -noupdate -group mux_squid -group in -group ram_mux_squid_tf -format Analog-Step -height 74 -max 65534.0 -radix unsigned /tb_mux_squid_top/inst_mux_squid_top/i_mux_squid_tf_wr_data
add wave -noupdate -group mux_squid -group in -group ram_mux_squid_tf /tb_mux_squid_top/inst_mux_squid_top/i_mux_squid_tf_rd_en
add wave -noupdate -group mux_squid -group in -group ram_mux_squid_tf /tb_mux_squid_top/inst_mux_squid_top/o_mux_squid_tf_rd_valid
add wave -noupdate -group mux_squid -group in -group ram_mux_squid_tf /tb_mux_squid_top/inst_mux_squid_top/o_mux_squid_tf_rd_data
add wave -noupdate -group mux_squid -group in -radix unsigned /tb_mux_squid_top/inst_mux_squid_top/i_mux_squid_feedback
add wave -noupdate -group mux_squid -group in -group data /tb_mux_squid_top/inst_mux_squid_top/i_pixel_sof
add wave -noupdate -group mux_squid -group in -group data /tb_mux_squid_top/inst_mux_squid_top/i_pixel_eof
add wave -noupdate -group mux_squid -group in -group data /tb_mux_squid_top/inst_mux_squid_top/i_pixel_valid
add wave -noupdate -group mux_squid -group in -group data -radix unsigned /tb_mux_squid_top/inst_mux_squid_top/i_pixel_id
add wave -noupdate -group mux_squid -group in -group data -radix unsigned /tb_mux_squid_top/inst_mux_squid_top/i_pixel_result
add wave -noupdate -group mux_squid -group in -group data /tb_mux_squid_top/inst_mux_squid_top/i_frame_sof
add wave -noupdate -group mux_squid -group in -group data /tb_mux_squid_top/inst_mux_squid_top/i_frame_eof
add wave -noupdate -group mux_squid -group in -group data -radix unsigned /tb_mux_squid_top/inst_mux_squid_top/i_frame_id
add wave -noupdate -group mux_squid -group stepx /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/pixel_sof_rx
add wave -noupdate -group mux_squid -group stepx /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/pixel_eof_rx
add wave -noupdate -group mux_squid -group stepx /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/pixel_valid_rx
add wave -noupdate -group mux_squid -group stepx -radix unsigned /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/pixel_id_rx
add wave -noupdate -group mux_squid -group stepx -radix decimal /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/result_sub_rx
add wave -noupdate -group mux_squid -group stepy /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/pixel_sof_ry
add wave -noupdate -group mux_squid -group stepy /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/pixel_eof_ry
add wave -noupdate -group mux_squid -group stepy /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/pixel_valid_ry
add wave -noupdate -group mux_squid -group stepy -radix unsigned /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/pixel_id_ry
add wave -noupdate -group mux_squid -group stepy -format Analog-Step -height 74 -max 70.0 -radix decimal /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/mux_squid_offset_ry
add wave -noupdate -group mux_squid -group stepy -format Analog-Step -height 74 -max 65534.999999999993 -radix unsigned /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/mux_squid_tf_doutb
add wave -noupdate -group mux_squid -group stepz /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/pixel_sof_rz
add wave -noupdate -group mux_squid -group stepz /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/pixel_eof_rz
add wave -noupdate -group mux_squid -group stepz /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/pixel_valid_rz
add wave -noupdate -group mux_squid -group stepz -radix unsigned /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/pixel_id_rz
add wave -noupdate -group mux_squid -group stepz -radix decimal /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/result_rz
add wave -noupdate -group mux_squid -group out -expand -group data /tb_mux_squid_top/inst_mux_squid_top/o_pixel_sof
add wave -noupdate -group mux_squid -group out -expand -group data /tb_mux_squid_top/inst_mux_squid_top/o_pixel_eof
add wave -noupdate -group mux_squid -group out -expand -group data /tb_mux_squid_top/inst_mux_squid_top/o_pixel_valid
add wave -noupdate -group mux_squid -group out -expand -group data -radix unsigned /tb_mux_squid_top/inst_mux_squid_top/o_pixel_id
add wave -noupdate -group mux_squid -group out -expand -group data -radix decimal /tb_mux_squid_top/inst_mux_squid_top/o_pixel_result
add wave -noupdate -group mux_squid -group out -expand -group data /tb_mux_squid_top/inst_mux_squid_top/o_frame_sof
add wave -noupdate -group mux_squid -group out -expand -group data /tb_mux_squid_top/inst_mux_squid_top/o_frame_eof
add wave -noupdate -group mux_squid -group out -expand -group data -radix unsigned /tb_mux_squid_top/inst_mux_squid_top/o_frame_id
add wave -noupdate -group mux_squid -group out -group error_status -color Magenta /tb_mux_squid_top/inst_mux_squid_top/o_errors
add wave -noupdate -group mux_squid -group out -group error_status /tb_mux_squid_top/inst_mux_squid_top/o_status
add wave -noupdate -divider internal_modules
add wave -noupdate -group sub_sfixed_mux_squid -group pixel_result_tmp -radix sfixed /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/inst_sub_sfixed_mux_squid/a_r1
add wave -noupdate -group sub_sfixed_mux_squid -group mux_squid_feedback_tmp -radix sfixed /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/inst_sub_sfixed_mux_squid/b_r1
add wave -noupdate -group sub_sfixed_mux_squid -radix sfixed /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/inst_sub_sfixed_mux_squid/res_r2
add wave -noupdate -group sub_sfixed_mux_squid -radix decimal /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/inst_sub_sfixed_mux_squid/o_s
add wave -noupdate -group mult_add_sfixed /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/pixel_sof_ry
add wave -noupdate -group mult_add_sfixed /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/pixel_eof_ry
add wave -noupdate -group mult_add_sfixed /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/pixel_valid_ry
add wave -noupdate -group mult_add_sfixed /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/pixel_id_ry
add wave -noupdate -group mult_add_sfixed -group inter_squid_gain_tmp -radix sfixed /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/inst_mult_add_sfixed_mux_squid_offset_and_tf/a_r1
add wave -noupdate -group mult_add_sfixed -group mux_squid_tf_tmp -radix sfixed /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/inst_mult_add_sfixed_mux_squid_offset_and_tf/b_r1
add wave -noupdate -group mult_add_sfixed -group mux_squid_offset_tmp -radix sfixed /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/inst_mult_add_sfixed_mux_squid_offset_and_tf/c_r1
add wave -noupdate -group mult_add_sfixed -group a*b -radix sfixed /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/inst_mult_add_sfixed_mux_squid_offset_and_tf/mult_r2
add wave -noupdate -group mult_add_sfixed -expand -group a*b+c -radix sfixed /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/inst_mult_add_sfixed_mux_squid_offset_and_tf/res_r3
add wave -noupdate -group mult_add_sfixed -radix decimal /tb_mux_squid_top/inst_mux_squid_top/inst_mux_squid/inst_mult_add_sfixed_mux_squid_offset_and_tf/o_s
add wave -noupdate -divider testbench
add wave -noupdate -radix unsigned -childformat {{/tb_mux_squid_top/data_count_out(31) -radix unsigned} {/tb_mux_squid_top/data_count_out(30) -radix unsigned} {/tb_mux_squid_top/data_count_out(29) -radix unsigned} {/tb_mux_squid_top/data_count_out(28) -radix unsigned} {/tb_mux_squid_top/data_count_out(27) -radix unsigned} {/tb_mux_squid_top/data_count_out(26) -radix unsigned} {/tb_mux_squid_top/data_count_out(25) -radix unsigned} {/tb_mux_squid_top/data_count_out(24) -radix unsigned} {/tb_mux_squid_top/data_count_out(23) -radix unsigned} {/tb_mux_squid_top/data_count_out(22) -radix unsigned} {/tb_mux_squid_top/data_count_out(21) -radix unsigned} {/tb_mux_squid_top/data_count_out(20) -radix unsigned} {/tb_mux_squid_top/data_count_out(19) -radix unsigned} {/tb_mux_squid_top/data_count_out(18) -radix unsigned} {/tb_mux_squid_top/data_count_out(17) -radix unsigned} {/tb_mux_squid_top/data_count_out(16) -radix unsigned} {/tb_mux_squid_top/data_count_out(15) -radix unsigned} {/tb_mux_squid_top/data_count_out(14) -radix unsigned} {/tb_mux_squid_top/data_count_out(13) -radix unsigned} {/tb_mux_squid_top/data_count_out(12) -radix unsigned} {/tb_mux_squid_top/data_count_out(11) -radix unsigned} {/tb_mux_squid_top/data_count_out(10) -radix unsigned} {/tb_mux_squid_top/data_count_out(9) -radix unsigned} {/tb_mux_squid_top/data_count_out(8) -radix unsigned} {/tb_mux_squid_top/data_count_out(7) -radix unsigned} {/tb_mux_squid_top/data_count_out(6) -radix unsigned} {/tb_mux_squid_top/data_count_out(5) -radix unsigned} {/tb_mux_squid_top/data_count_out(4) -radix unsigned} {/tb_mux_squid_top/data_count_out(3) -radix unsigned} {/tb_mux_squid_top/data_count_out(2) -radix unsigned} {/tb_mux_squid_top/data_count_out(1) -radix unsigned} {/tb_mux_squid_top/data_count_out(0) -radix unsigned}} -subitemconfig {/tb_mux_squid_top/data_count_out(31) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(30) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(29) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(28) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(27) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(26) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(25) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(24) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(23) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(22) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(21) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(20) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(19) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(18) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(17) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(16) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(15) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(14) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(13) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(12) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(11) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(10) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(9) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(8) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(7) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(6) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(5) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(4) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(3) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(2) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(1) {-height 15 -radix unsigned} /tb_mux_squid_top/data_count_out(0) {-height 15 -radix unsigned}} /tb_mux_squid_top/data_count_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {549726012 ps} 0}
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
WaveRestoreZoom {540719388 ps} {563880354 ps}
