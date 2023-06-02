onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group amp_squid_top -group in /tb_amp_squid_top/dut_amp_squid_top/i_clk
add wave -noupdate -group amp_squid_top -group in /tb_amp_squid_top/dut_amp_squid_top/i_rst_status
add wave -noupdate -group amp_squid_top -group in /tb_amp_squid_top/dut_amp_squid_top/i_debug_pulse
add wave -noupdate -group amp_squid_top -group in -group ram_amp_squid_tf /tb_amp_squid_top/dut_amp_squid_top/i_amp_squid_tf_wr_en
add wave -noupdate -group amp_squid_top -group in -group ram_amp_squid_tf -radix unsigned /tb_amp_squid_top/dut_amp_squid_top/i_amp_squid_tf_wr_rd_addr
add wave -noupdate -group amp_squid_top -group in -group ram_amp_squid_tf /tb_amp_squid_top/dut_amp_squid_top/i_amp_squid_tf_wr_data
add wave -noupdate -group amp_squid_top -group in -group ram_amp_squid_tf /tb_amp_squid_top/dut_amp_squid_top/i_amp_squid_tf_rd_en
add wave -noupdate -group amp_squid_top -group in -group ram_amp_squid_tf /tb_amp_squid_top/dut_amp_squid_top/o_amp_squid_tf_rd_valid
add wave -noupdate -group amp_squid_top -group in -group ram_amp_squid_tf /tb_amp_squid_top/dut_amp_squid_top/o_amp_squid_tf_rd_data
add wave -noupdate -group amp_squid_top -group in -radix unsigned /tb_amp_squid_top/dut_amp_squid_top/i_fpasim_gain
add wave -noupdate -group amp_squid_top -group in -radix unsigned /tb_amp_squid_top/dut_amp_squid_top/i_amp_squid_offset_correction
add wave -noupdate -group amp_squid_top -group in -expand -group data /tb_amp_squid_top/dut_amp_squid_top/i_pixel_sof
add wave -noupdate -group amp_squid_top -group in -expand -group data /tb_amp_squid_top/dut_amp_squid_top/i_pixel_eof
add wave -noupdate -group amp_squid_top -group in -expand -group data /tb_amp_squid_top/dut_amp_squid_top/i_pixel_valid
add wave -noupdate -group amp_squid_top -group in -expand -group data -radix unsigned /tb_amp_squid_top/dut_amp_squid_top/i_pixel_id
add wave -noupdate -group amp_squid_top -group in -expand -group data -radix unsigned /tb_amp_squid_top/dut_amp_squid_top/i_pixel_result
add wave -noupdate -group amp_squid_top -group in -expand -group data /tb_amp_squid_top/dut_amp_squid_top/i_frame_sof
add wave -noupdate -group amp_squid_top -group in -expand -group data /tb_amp_squid_top/dut_amp_squid_top/i_frame_eof
add wave -noupdate -group amp_squid_top -group in -expand -group data -radix unsigned /tb_amp_squid_top/dut_amp_squid_top/i_frame_id
add wave -noupdate -group amp_squid_top -group stepx /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/pixel_sof_rx
add wave -noupdate -group amp_squid_top -group stepx /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/pixel_eof_rx
add wave -noupdate -group amp_squid_top -group stepx /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/pixel_valid_rx
add wave -noupdate -group amp_squid_top -group stepx -radix unsigned /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/pixel_id_rx
add wave -noupdate -group amp_squid_top -group stepx -radix decimal /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/result_sub_rx
add wave -noupdate -group amp_squid_top -group stepy /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/pixel_sof_ry
add wave -noupdate -group amp_squid_top -group stepy /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/pixel_eof_ry
add wave -noupdate -group amp_squid_top -group stepy /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/pixel_valid_ry
add wave -noupdate -group amp_squid_top -group stepy -radix unsigned /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/pixel_id_ry
add wave -noupdate -group amp_squid_top -group stepy -radix sfixed -childformat {{/tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/fpasim_gain(5) -radix sfixed} {/tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/fpasim_gain(4) -radix sfixed} {/tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/fpasim_gain(3) -radix sfixed} {/tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/fpasim_gain(2) -radix sfixed} {/tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/fpasim_gain(1) -radix sfixed} {/tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/fpasim_gain(0) -radix sfixed}} -subitemconfig {/tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/fpasim_gain(5) {-height 15 -radix sfixed} /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/fpasim_gain(4) {-height 15 -radix sfixed} /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/fpasim_gain(3) {-height 15 -radix sfixed} /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/fpasim_gain(2) {-height 15 -radix sfixed} /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/fpasim_gain(1) {-height 15 -radix sfixed} /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/fpasim_gain(0) {-height 15 -radix sfixed}} /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/fpasim_gain
add wave -noupdate -group amp_squid_top -group stepy -radix unsigned /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/amp_squid_tf_doutb
add wave -noupdate -group amp_squid_top -group stepz /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/pixel_sof_rz
add wave -noupdate -group amp_squid_top -group stepz /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/pixel_eof_rz
add wave -noupdate -group amp_squid_top -group stepz /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/pixel_valid_rz
add wave -noupdate -group amp_squid_top -group stepz -radix unsigned /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/pixel_id_rz
add wave -noupdate -group amp_squid_top -group stepz -radix unsigned /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/result_rz
add wave -noupdate -group amp_squid_top -group out -group data /tb_amp_squid_top/dut_amp_squid_top/o_pixel_sof
add wave -noupdate -group amp_squid_top -group out -group data /tb_amp_squid_top/dut_amp_squid_top/o_pixel_eof
add wave -noupdate -group amp_squid_top -group out -group data /tb_amp_squid_top/dut_amp_squid_top/o_pixel_valid
add wave -noupdate -group amp_squid_top -group out -group data -radix unsigned /tb_amp_squid_top/dut_amp_squid_top/o_pixel_id
add wave -noupdate -group amp_squid_top -group out -group data -radix decimal /tb_amp_squid_top/dut_amp_squid_top/o_pixel_result
add wave -noupdate -group amp_squid_top -group out -group data /tb_amp_squid_top/dut_amp_squid_top/o_frame_sof
add wave -noupdate -group amp_squid_top -group out -group data /tb_amp_squid_top/dut_amp_squid_top/o_frame_eof
add wave -noupdate -group amp_squid_top -group out -group data -radix unsigned /tb_amp_squid_top/dut_amp_squid_top/o_frame_id
add wave -noupdate -group amp_squid_top -group out -group errors -color Magenta /tb_amp_squid_top/dut_amp_squid_top/o_errors
add wave -noupdate -group amp_squid_top -group out -group errors /tb_amp_squid_top/dut_amp_squid_top/o_status
add wave -noupdate -divider internal_modules
add wave -noupdate -group amp_squid_fpagain_table -group generic /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/inst_amp_squid_fpagain_table/g_Q_M_S
add wave -noupdate -group amp_squid_fpagain_table -group generic /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/inst_amp_squid_fpagain_table/g_Q_N_S
add wave -noupdate -group amp_squid_fpagain_table -group generic /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/inst_amp_squid_fpagain_table/g_LATENCY_OUT
add wave -noupdate -group amp_squid_fpagain_table -group in /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/inst_amp_squid_fpagain_table/i_clk
add wave -noupdate -group amp_squid_fpagain_table -group in /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/inst_amp_squid_fpagain_table/i_fpasim_gain
add wave -noupdate -group amp_squid_fpagain_table -group in /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/inst_amp_squid_fpagain_table/i_pixel_sof
add wave -noupdate -group amp_squid_fpagain_table -group in /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/inst_amp_squid_fpagain_table/i_pixel_valid
add wave -noupdate -group amp_squid_fpagain_table -group step1 -radix sfixed /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/inst_amp_squid_fpagain_table/gain_r1
add wave -noupdate -group amp_squid_fpagain_table -group step1 -radix unsigned -childformat {{/tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/inst_amp_squid_fpagain_table/gain_tmp0(5) -radix unsigned} {/tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/inst_amp_squid_fpagain_table/gain_tmp0(4) -radix unsigned} {/tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/inst_amp_squid_fpagain_table/gain_tmp0(3) -radix unsigned} {/tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/inst_amp_squid_fpagain_table/gain_tmp0(2) -radix unsigned} {/tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/inst_amp_squid_fpagain_table/gain_tmp0(1) -radix unsigned} {/tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/inst_amp_squid_fpagain_table/gain_tmp0(0) -radix unsigned}} -subitemconfig {/tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/inst_amp_squid_fpagain_table/gain_tmp0(5) {-height 15 -radix unsigned} /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/inst_amp_squid_fpagain_table/gain_tmp0(4) {-height 15 -radix unsigned} /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/inst_amp_squid_fpagain_table/gain_tmp0(3) {-height 15 -radix unsigned} /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/inst_amp_squid_fpagain_table/gain_tmp0(2) {-height 15 -radix unsigned} /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/inst_amp_squid_fpagain_table/gain_tmp0(1) {-height 15 -radix unsigned} /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/inst_amp_squid_fpagain_table/gain_tmp0(0) {-height 15 -radix unsigned}} /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/inst_amp_squid_fpagain_table/gain_tmp0
add wave -noupdate -group amp_squid_fpagain_table -group step2 /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/inst_amp_squid_fpagain_table/gain_tmp1
add wave -noupdate -group amp_squid_fpagain_table -expand -group out /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/inst_amp_squid_fpagain_table/o_fpasim_gain
add wave -noupdate -group mult_sfixed_amp_squid_correction -group amp_squid_tf_out -radix sfixed /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/inst_mult_sfixed_amp_squid_correction_and_tf/a_r1
add wave -noupdate -group mult_sfixed_amp_squid_correction -group fpagain -radix sfixed /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/inst_mult_sfixed_amp_squid_correction_and_tf/b_r1
add wave -noupdate -group mult_sfixed_amp_squid_correction -divider full_out
add wave -noupdate -group mult_sfixed_amp_squid_correction -radix sfixed /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/inst_mult_sfixed_amp_squid_correction_and_tf/p_r4
add wave -noupdate -group mult_sfixed_amp_squid_correction -divider trunc_out
add wave -noupdate -group mult_sfixed_amp_squid_correction -radix sfixed /tb_amp_squid_top/dut_amp_squid_top/inst_amp_squid/inst_mult_sfixed_amp_squid_correction_and_tf/p_tmp5
add wave -noupdate -divider testbench_counter
add wave -noupdate -radix unsigned /tb_amp_squid_top/data_count_in
add wave -noupdate -radix unsigned /tb_amp_squid_top/data_count_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {153446012 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 252
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
WaveRestoreZoom {660710122 ps} {660789994 ps}
