onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group mux_squid_top /tb_mux_squid_top/dut_mux_squid_top/i_clk
add wave -noupdate -expand -group mux_squid_top -group in /tb_mux_squid_top/dut_mux_squid_top/i_rst_status
add wave -noupdate -expand -group mux_squid_top -group in /tb_mux_squid_top/dut_mux_squid_top/i_debug_pulse
add wave -noupdate -expand -group mux_squid_top -group in -group ram_mux_squid_offset /tb_mux_squid_top/dut_mux_squid_top/i_mux_squid_offset_wr_en
add wave -noupdate -expand -group mux_squid_top -group in -group ram_mux_squid_offset -radix unsigned /tb_mux_squid_top/dut_mux_squid_top/i_mux_squid_offset_wr_rd_addr
add wave -noupdate -expand -group mux_squid_top -group in -group ram_mux_squid_offset -radix unsigned /tb_mux_squid_top/dut_mux_squid_top/i_mux_squid_offset_wr_data
add wave -noupdate -expand -group mux_squid_top -group in -group ram_mux_squid_offset /tb_mux_squid_top/dut_mux_squid_top/i_mux_squid_offset_rd_en
add wave -noupdate -expand -group mux_squid_top -group in -group ram_mux_squid_offset /tb_mux_squid_top/dut_mux_squid_top/o_mux_squid_offset_rd_valid
add wave -noupdate -expand -group mux_squid_top -group in -group ram_mux_squid_offset /tb_mux_squid_top/dut_mux_squid_top/o_mux_squid_offset_rd_data
add wave -noupdate -expand -group mux_squid_top -group in -group ram_mux_squid_tf /tb_mux_squid_top/dut_mux_squid_top/i_mux_squid_tf_wr_en
add wave -noupdate -expand -group mux_squid_top -group in -group ram_mux_squid_tf -radix unsigned /tb_mux_squid_top/dut_mux_squid_top/i_mux_squid_tf_wr_rd_addr
add wave -noupdate -expand -group mux_squid_top -group in -group ram_mux_squid_tf /tb_mux_squid_top/dut_mux_squid_top/i_mux_squid_tf_wr_data
add wave -noupdate -expand -group mux_squid_top -group in -group ram_mux_squid_tf /tb_mux_squid_top/dut_mux_squid_top/i_mux_squid_tf_rd_en
add wave -noupdate -expand -group mux_squid_top -group in -group ram_mux_squid_tf /tb_mux_squid_top/dut_mux_squid_top/o_mux_squid_tf_rd_valid
add wave -noupdate -expand -group mux_squid_top -group in -group ram_mux_squid_tf /tb_mux_squid_top/dut_mux_squid_top/o_mux_squid_tf_rd_data
add wave -noupdate -expand -group mux_squid_top -group in -radix unsigned /tb_mux_squid_top/dut_mux_squid_top/i_mux_squid_feedback
add wave -noupdate -expand -group mux_squid_top -group in -group data /tb_mux_squid_top/dut_mux_squid_top/i_pixel_sof
add wave -noupdate -expand -group mux_squid_top -group in -group data /tb_mux_squid_top/dut_mux_squid_top/i_pixel_eof
add wave -noupdate -expand -group mux_squid_top -group in -group data /tb_mux_squid_top/dut_mux_squid_top/i_pixel_valid
add wave -noupdate -expand -group mux_squid_top -group in -group data -radix unsigned /tb_mux_squid_top/dut_mux_squid_top/i_pixel_id
add wave -noupdate -expand -group mux_squid_top -group in -group data -radix unsigned /tb_mux_squid_top/dut_mux_squid_top/i_pixel_result
add wave -noupdate -expand -group mux_squid_top -group in -group data /tb_mux_squid_top/dut_mux_squid_top/i_frame_sof
add wave -noupdate -expand -group mux_squid_top -group in -group data /tb_mux_squid_top/dut_mux_squid_top/i_frame_eof
add wave -noupdate -expand -group mux_squid_top -group in -group data -radix unsigned /tb_mux_squid_top/dut_mux_squid_top/i_frame_id
add wave -noupdate -expand -group mux_squid_top -group stepx /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/pixel_sof_rx
add wave -noupdate -expand -group mux_squid_top -group stepx /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/pixel_eof_rx
add wave -noupdate -expand -group mux_squid_top -group stepx /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/pixel_valid_rx
add wave -noupdate -expand -group mux_squid_top -group stepx -radix unsigned /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/pixel_id_rx
add wave -noupdate -expand -group mux_squid_top -group stepx -radix decimal /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/result_sub_rx
add wave -noupdate -expand -group mux_squid_top -group stepy /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/pixel_sof_ry
add wave -noupdate -expand -group mux_squid_top -group stepy /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/pixel_eof_ry
add wave -noupdate -expand -group mux_squid_top -group stepy /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/pixel_valid_ry
add wave -noupdate -expand -group mux_squid_top -group stepy -radix unsigned /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/pixel_id_ry
add wave -noupdate -expand -group mux_squid_top -group stepy -radix decimal /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/mux_squid_offset_ry
add wave -noupdate -expand -group mux_squid_top -group stepy -radix decimal /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/mux_squid_tf_doutb
add wave -noupdate -expand -group mux_squid_top -group stepz /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/pixel_sof_rz
add wave -noupdate -expand -group mux_squid_top -group stepz /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/pixel_eof_rz
add wave -noupdate -expand -group mux_squid_top -group stepz /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/pixel_valid_rz
add wave -noupdate -expand -group mux_squid_top -group stepz -radix unsigned /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/pixel_id_rz
add wave -noupdate -expand -group mux_squid_top -group stepz -radix decimal /tb_mux_squid_top/dut_mux_squid_top/inst_mux_squid/result_rz
add wave -noupdate -expand -group mux_squid_top -group out -expand -group data /tb_mux_squid_top/dut_mux_squid_top/o_pixel_sof
add wave -noupdate -expand -group mux_squid_top -group out -expand -group data /tb_mux_squid_top/dut_mux_squid_top/o_pixel_eof
add wave -noupdate -expand -group mux_squid_top -group out -expand -group data /tb_mux_squid_top/dut_mux_squid_top/o_pixel_valid
add wave -noupdate -expand -group mux_squid_top -group out -expand -group data -radix unsigned /tb_mux_squid_top/dut_mux_squid_top/o_pixel_id
add wave -noupdate -expand -group mux_squid_top -group out -expand -group data -radix decimal /tb_mux_squid_top/dut_mux_squid_top/o_pixel_result
add wave -noupdate -expand -group mux_squid_top -group out -expand -group data /tb_mux_squid_top/dut_mux_squid_top/o_frame_sof
add wave -noupdate -expand -group mux_squid_top -group out -expand -group data /tb_mux_squid_top/dut_mux_squid_top/o_frame_eof
add wave -noupdate -expand -group mux_squid_top -group out -expand -group data -radix unsigned /tb_mux_squid_top/dut_mux_squid_top/o_frame_id
add wave -noupdate -expand -group mux_squid_top -group out -group error_status -color Magenta /tb_mux_squid_top/dut_mux_squid_top/o_errors
add wave -noupdate -expand -group mux_squid_top -group out -group error_status /tb_mux_squid_top/dut_mux_squid_top/o_status
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {32958012 ps} 0}
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
WaveRestoreZoom {180807772 ps} {180986972 ps}
