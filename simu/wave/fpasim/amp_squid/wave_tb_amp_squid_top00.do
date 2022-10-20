onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group amp_squid_top -expand -group in /tb_amp_squid_top/inst_amp_squid_top/i_clk
add wave -noupdate -expand -group amp_squid_top -expand -group in /tb_amp_squid_top/inst_amp_squid_top/i_rst_status
add wave -noupdate -expand -group amp_squid_top -expand -group in /tb_amp_squid_top/inst_amp_squid_top/i_debug_pulse
add wave -noupdate -expand -group amp_squid_top -expand -group in -group ram_amp_squid_tf /tb_amp_squid_top/inst_amp_squid_top/i_amp_squid_tf_wr_en
add wave -noupdate -expand -group amp_squid_top -expand -group in -group ram_amp_squid_tf -radix unsigned /tb_amp_squid_top/inst_amp_squid_top/i_amp_squid_tf_wr_rd_addr
add wave -noupdate -expand -group amp_squid_top -expand -group in -group ram_amp_squid_tf /tb_amp_squid_top/inst_amp_squid_top/i_amp_squid_tf_wr_data
add wave -noupdate -expand -group amp_squid_top -expand -group in -group ram_amp_squid_tf /tb_amp_squid_top/inst_amp_squid_top/i_amp_squid_tf_rd_en
add wave -noupdate -expand -group amp_squid_top -expand -group in -group ram_amp_squid_tf /tb_amp_squid_top/inst_amp_squid_top/o_amp_squid_tf_rd_valid
add wave -noupdate -expand -group amp_squid_top -expand -group in -group ram_amp_squid_tf /tb_amp_squid_top/inst_amp_squid_top/o_amp_squid_tf_rd_data
add wave -noupdate -expand -group amp_squid_top -expand -group in /tb_amp_squid_top/inst_amp_squid_top/i_fpasim_gain
add wave -noupdate -expand -group amp_squid_top -expand -group in /tb_amp_squid_top/inst_amp_squid_top/i_amp_squid_offset_correction
add wave -noupdate -expand -group amp_squid_top -expand -group in -group data /tb_amp_squid_top/inst_amp_squid_top/i_pixel_sof
add wave -noupdate -expand -group amp_squid_top -expand -group in -group data /tb_amp_squid_top/inst_amp_squid_top/i_pixel_eof
add wave -noupdate -expand -group amp_squid_top -expand -group in -group data /tb_amp_squid_top/inst_amp_squid_top/i_pixel_valid
add wave -noupdate -expand -group amp_squid_top -expand -group in -group data -radix unsigned /tb_amp_squid_top/inst_amp_squid_top/i_pixel_id
add wave -noupdate -expand -group amp_squid_top -expand -group in -group data /tb_amp_squid_top/inst_amp_squid_top/i_pixel_result
add wave -noupdate -expand -group amp_squid_top -expand -group in -group data /tb_amp_squid_top/inst_amp_squid_top/i_frame_sof
add wave -noupdate -expand -group amp_squid_top -expand -group in -group data /tb_amp_squid_top/inst_amp_squid_top/i_frame_eof
add wave -noupdate -expand -group amp_squid_top -expand -group in -group data -radix unsigned /tb_amp_squid_top/inst_amp_squid_top/i_frame_id
add wave -noupdate -expand -group amp_squid_top -expand -group out -group data /tb_amp_squid_top/inst_amp_squid_top/o_pixel_sof
add wave -noupdate -expand -group amp_squid_top -expand -group out -group data /tb_amp_squid_top/inst_amp_squid_top/o_pixel_eof
add wave -noupdate -expand -group amp_squid_top -expand -group out -group data /tb_amp_squid_top/inst_amp_squid_top/o_pixel_valid
add wave -noupdate -expand -group amp_squid_top -expand -group out -group data -radix unsigned /tb_amp_squid_top/inst_amp_squid_top/o_pixel_id
add wave -noupdate -expand -group amp_squid_top -expand -group out -group data /tb_amp_squid_top/inst_amp_squid_top/o_pixel_result
add wave -noupdate -expand -group amp_squid_top -expand -group out -group data /tb_amp_squid_top/inst_amp_squid_top/o_frame_sof
add wave -noupdate -expand -group amp_squid_top -expand -group out -group data /tb_amp_squid_top/inst_amp_squid_top/o_frame_eof
add wave -noupdate -expand -group amp_squid_top -expand -group out -group data -radix unsigned /tb_amp_squid_top/inst_amp_squid_top/o_frame_id
add wave -noupdate -expand -group amp_squid_top -expand -group out -expand -group errors -color Red /tb_amp_squid_top/inst_amp_squid_top/o_errors
add wave -noupdate -expand -group amp_squid_top -expand -group out -expand -group errors /tb_amp_squid_top/inst_amp_squid_top/o_status
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 528
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
WaveRestoreZoom {10000576 ps} {10001023 ps}
