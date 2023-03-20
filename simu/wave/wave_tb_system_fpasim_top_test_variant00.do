onerror {resume}
quietly virtual signal -install /tb_system_fpasim_top { /tb_system_fpasim_top/o_data(31 downto 16)} o_data_addr
quietly virtual signal -install /tb_system_fpasim_top { /tb_system_fpasim_top/o_data(15 downto 0)} o_data_data
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider reg_decode
add wave -noupdate -expand -group regdecode_top /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/usb_clk
add wave -noupdate -expand -group regdecode_top /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/i_usb_rst
add wave -noupdate -expand -group regdecode_top /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/i_out_rst
add wave -noupdate -expand -group regdecode_top /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/i_out_clk
add wave -noupdate -expand -group regdecode_top -group tes_pulse_shape_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/o_tes_pulse_shape_ram_wr_rd_addr
add wave -noupdate -expand -group regdecode_top -group tes_pulse_shape_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/o_tes_pulse_shape_ram_wr_en
add wave -noupdate -expand -group regdecode_top -group tes_pulse_shape_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/o_tes_pulse_shape_ram_wr_data
add wave -noupdate -expand -group regdecode_top -group tes_pulse_shape_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/o_tes_pulse_shape_ram_rd_en
add wave -noupdate -expand -group regdecode_top -group tes_pulse_shape_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/i_tes_pulse_shape_ram_rd_valid
add wave -noupdate -expand -group regdecode_top -group tes_pulse_shape_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/i_tes_pulse_shape_ram_rd_data
add wave -noupdate -expand -group regdecode_top -group amp_squid_tf_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/o_amp_squid_tf_ram_wr_en
add wave -noupdate -expand -group regdecode_top -group amp_squid_tf_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/o_amp_squid_tf_ram_wr_rd_addr
add wave -noupdate -expand -group regdecode_top -group amp_squid_tf_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/o_amp_squid_tf_ram_wr_data
add wave -noupdate -expand -group regdecode_top -group amp_squid_tf_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/o_amp_squid_tf_ram_rd_en
add wave -noupdate -expand -group regdecode_top -group amp_squid_tf_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/i_amp_squid_tf_ram_rd_valid
add wave -noupdate -expand -group regdecode_top -group amp_squid_tf_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/i_amp_squid_tf_ram_rd_data
add wave -noupdate -expand -group regdecode_top -group mux_squid_tf_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/o_mux_squid_tf_ram_wr_en
add wave -noupdate -expand -group regdecode_top -group mux_squid_tf_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/o_mux_squid_tf_ram_wr_rd_addr
add wave -noupdate -expand -group regdecode_top -group mux_squid_tf_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/o_mux_squid_tf_ram_wr_data
add wave -noupdate -expand -group regdecode_top -group mux_squid_tf_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/o_mux_squid_tf_ram_rd_en
add wave -noupdate -expand -group regdecode_top -group mux_squid_tf_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/i_mux_squid_tf_ram_rd_valid
add wave -noupdate -expand -group regdecode_top -group mux_squid_tf_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/i_mux_squid_tf_ram_rd_data
add wave -noupdate -expand -group regdecode_top -group tes_std_state_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/o_tes_std_state_ram_wr_en
add wave -noupdate -expand -group regdecode_top -group tes_std_state_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/o_tes_std_state_ram_wr_rd_addr
add wave -noupdate -expand -group regdecode_top -group tes_std_state_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/o_tes_std_state_ram_wr_data
add wave -noupdate -expand -group regdecode_top -group tes_std_state_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/o_tes_std_state_ram_rd_en
add wave -noupdate -expand -group regdecode_top -group tes_std_state_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/i_tes_std_state_ram_rd_valid
add wave -noupdate -expand -group regdecode_top -group tes_std_state_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/i_tes_std_state_ram_rd_data
add wave -noupdate -expand -group regdecode_top -group mux_squid_offset_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/o_mux_squid_offset_ram_wr_en
add wave -noupdate -expand -group regdecode_top -group mux_squid_offset_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/o_mux_squid_offset_ram_wr_rd_addr
add wave -noupdate -expand -group regdecode_top -group mux_squid_offset_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/o_mux_squid_offset_ram_wr_data
add wave -noupdate -expand -group regdecode_top -group mux_squid_offset_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/o_mux_squid_offset_ram_rd_en
add wave -noupdate -expand -group regdecode_top -group mux_squid_offset_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/i_mux_squid_offset_ram_rd_valid
add wave -noupdate -expand -group regdecode_top -group mux_squid_offset_ram /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/i_mux_squid_offset_ram_rd_data
add wave -noupdate -expand -group regdecode_top -group wr /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/pipein_valid0
add wave -noupdate -expand -group regdecode_top -group wr /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/pipein_addr0
add wave -noupdate -expand -group regdecode_top -group wr /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/pipein_data0
add wave -noupdate -expand -group regdecode_top -group rd /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/pipeout_rd
add wave -noupdate -expand -group regdecode_top -group rd /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/pipeout_sof
add wave -noupdate -expand -group regdecode_top -group rd /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/pipeout_eof
add wave -noupdate -expand -group regdecode_top -group rd /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/pipeout_valid
add wave -noupdate -expand -group regdecode_top -group rd /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/pipeout_addr
add wave -noupdate -expand -group regdecode_top -group rd /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/pipeout_data
add wave -noupdate -expand -group regdecode_top -group rd /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/pipeout_empty
add wave -noupdate -expand -group regdecode_top -group rd /tb_system_fpasim_top/dut_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/pipeout_data_count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 352
configure wave -valuecolwidth 352
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
WaveRestoreZoom {0 ps} {474 ps}
