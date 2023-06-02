onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group tes_top -group in /tb_tes_top/inst_dut_tes_top/i_clk
add wave -noupdate -group tes_top -group in /tb_tes_top/inst_dut_tes_top/i_rst
add wave -noupdate -group tes_top -group in /tb_tes_top/inst_dut_tes_top/i_rst_status
add wave -noupdate -group tes_top -group in /tb_tes_top/inst_dut_tes_top/i_debug_pulse
add wave -noupdate -group tes_top -group in /tb_tes_top/inst_dut_tes_top/i_en
add wave -noupdate -group tes_top -group in -radix unsigned /tb_tes_top/inst_dut_tes_top/i_nb_sample_by_pixel
add wave -noupdate -group tes_top -group in -radix unsigned /tb_tes_top/inst_dut_tes_top/i_nb_pixel_by_frame
add wave -noupdate -group tes_top -group in -radix unsigned /tb_tes_top/inst_dut_tes_top/i_nb_sample_by_frame
add wave -noupdate -group tes_top -group in -group cmd /tb_tes_top/inst_dut_tes_top/i_cmd_valid
add wave -noupdate -group tes_top -group in -group cmd -radix unsigned /tb_tes_top/inst_dut_tes_top/i_cmd_pulse_height
add wave -noupdate -group tes_top -group in -group cmd -radix unsigned /tb_tes_top/inst_dut_tes_top/i_cmd_pixel_id
add wave -noupdate -group tes_top -group in -group cmd -radix unsigned /tb_tes_top/inst_dut_tes_top/i_cmd_time_shift
add wave -noupdate -group tes_top -group in -group ram_pulse_shape /tb_tes_top/inst_dut_tes_top/i_pulse_shape_wr_en
add wave -noupdate -group tes_top -group in -group ram_pulse_shape -radix unsigned /tb_tes_top/inst_dut_tes_top/i_pulse_shape_wr_rd_addr
add wave -noupdate -group tes_top -group in -group ram_pulse_shape /tb_tes_top/inst_dut_tes_top/i_pulse_shape_wr_data
add wave -noupdate -group tes_top -group in -group ram_pulse_shape /tb_tes_top/inst_dut_tes_top/i_pulse_shape_rd_en
add wave -noupdate -group tes_top -group in -group ram_pulse_shape /tb_tes_top/inst_dut_tes_top/o_pulse_shape_rd_valid
add wave -noupdate -group tes_top -group in -group ram_pulse_shape /tb_tes_top/inst_dut_tes_top/o_pulse_shape_rd_data
add wave -noupdate -group tes_top -group in -group ram_steady_state /tb_tes_top/inst_dut_tes_top/i_steady_state_wr_en
add wave -noupdate -group tes_top -group in -group ram_steady_state -radix unsigned /tb_tes_top/inst_dut_tes_top/i_steady_state_wr_rd_addr
add wave -noupdate -group tes_top -group in -group ram_steady_state /tb_tes_top/inst_dut_tes_top/i_steady_state_wr_data
add wave -noupdate -group tes_top -group in -group ram_steady_state /tb_tes_top/inst_dut_tes_top/i_steady_state_rd_en
add wave -noupdate -group tes_top -group in -group ram_steady_state /tb_tes_top/inst_dut_tes_top/o_steady_state_rd_valid
add wave -noupdate -group tes_top -group in -group ram_steady_state /tb_tes_top/inst_dut_tes_top/o_steady_state_rd_data
add wave -noupdate -group tes_top -group in -group data /tb_tes_top/inst_dut_tes_top/i_data_valid
add wave -noupdate -group tes_top -group out -group data /tb_tes_top/inst_dut_tes_top/o_pixel_sof
add wave -noupdate -group tes_top -group out -group data /tb_tes_top/inst_dut_tes_top/o_pixel_eof
add wave -noupdate -group tes_top -group out -group data /tb_tes_top/inst_dut_tes_top/o_pixel_valid
add wave -noupdate -group tes_top -group out -group data -radix unsigned /tb_tes_top/inst_dut_tes_top/o_pixel_id
add wave -noupdate -group tes_top -group out -group data /tb_tes_top/inst_dut_tes_top/o_pixel_result
add wave -noupdate -group tes_top -group out -group data /tb_tes_top/inst_dut_tes_top/o_frame_sof
add wave -noupdate -group tes_top -group out -group data /tb_tes_top/inst_dut_tes_top/o_frame_eof
add wave -noupdate -group tes_top -group out -group data -radix unsigned /tb_tes_top/inst_dut_tes_top/o_frame_id
add wave -noupdate -group tes_top -group out -expand -group errors_status -color Magenta /tb_tes_top/inst_dut_tes_top/o_errors
add wave -noupdate -group tes_top -group out -expand -group errors_status /tb_tes_top/inst_dut_tes_top/o_status
add wave -noupdate -divider internal_modules
add wave -noupdate -group tes_signalling_pixel -group in /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/i_clk
add wave -noupdate -group tes_signalling_pixel -group in /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/i_rst
add wave -noupdate -group tes_signalling_pixel -group in /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/i_start
add wave -noupdate -group tes_signalling_pixel -group in -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/i_nb_samples_by_block
add wave -noupdate -group tes_signalling_pixel -group in -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/i_nb_block
add wave -noupdate -group tes_signalling_pixel -group in /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/i_data_valid
add wave -noupdate -group tes_signalling_pixel -expand -group step1 /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/sm_state_r1
add wave -noupdate -group tes_signalling_pixel -expand -group step1 /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/data_valid_r1
add wave -noupdate -group tes_signalling_pixel -expand -group step1 /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/sof_r1
add wave -noupdate -group tes_signalling_pixel -expand -group step1 /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/eof_r1
add wave -noupdate -group tes_signalling_pixel -expand -group step1 -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/cnt_frame_r1
add wave -noupdate -group tes_signalling_pixel -expand -group step1 -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/cnt_frame_max_r1
add wave -noupdate -group tes_signalling_pixel -expand -group out /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_sof
add wave -noupdate -group tes_signalling_pixel -expand -group out /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_eof
add wave -noupdate -group tes_signalling_pixel -expand -group out -radix unsigned -childformat {{/tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_id(5) -radix unsigned} {/tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_id(4) -radix unsigned} {/tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_id(3) -radix unsigned} {/tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_id(2) -radix unsigned} {/tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_id(1) -radix unsigned} {/tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_id(0) -radix unsigned}} -expand -subitemconfig {/tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_id(5) {-height 15 -radix unsigned} /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_id(4) {-height 15 -radix unsigned} /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_id(3) {-height 15 -radix unsigned} /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_id(2) {-height 15 -radix unsigned} /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_id(1) {-height 15 -radix unsigned} /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_id(0) {-height 15 -radix unsigned}} /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_id
add wave -noupdate -group tes_signalling_pixel -expand -group out /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_data_valid
add wave -noupdate -group tes_signalling_frame -expand -group in /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/i_clk
add wave -noupdate -group tes_signalling_frame -expand -group in /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/i_rst
add wave -noupdate -group tes_signalling_frame -expand -group in /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/i_start
add wave -noupdate -group tes_signalling_frame -expand -group in -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/i_nb_samples_by_block
add wave -noupdate -group tes_signalling_frame -expand -group in -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/i_nb_block
add wave -noupdate -group tes_signalling_frame -expand -group in /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/i_data_valid
add wave -noupdate -group tes_signalling_frame -group step1 /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/sm_state_r1
add wave -noupdate -group tes_signalling_frame -group step1 /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/data_valid_r1
add wave -noupdate -group tes_signalling_frame -group step1 /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/sof_r1
add wave -noupdate -group tes_signalling_frame -group step1 /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/eof_r1
add wave -noupdate -group tes_signalling_frame -group step1 -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/cnt_frame_r1
add wave -noupdate -group tes_signalling_frame -group step1 -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/cnt_frame_max_r1
add wave -noupdate -group tes_signalling_frame -expand -group out /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_sof
add wave -noupdate -group tes_signalling_frame -expand -group out /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_eof
add wave -noupdate -group tes_signalling_frame -expand -group out -radix unsigned -childformat {{/tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(10) -radix unsigned} {/tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(9) -radix unsigned} {/tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(8) -radix unsigned} {/tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(7) -radix unsigned} {/tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(6) -radix unsigned} {/tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(5) -radix unsigned} {/tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(4) -radix unsigned} {/tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(3) -radix unsigned} {/tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(2) -radix unsigned} {/tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(1) -radix unsigned} {/tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(0) -radix unsigned}} -subitemconfig {/tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(10) {-height 15 -radix unsigned} /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(9) {-height 15 -radix unsigned} /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(8) {-height 15 -radix unsigned} /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(7) {-height 15 -radix unsigned} /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(6) {-height 15 -radix unsigned} /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(5) {-height 15 -radix unsigned} /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(4) {-height 15 -radix unsigned} /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(3) {-height 15 -radix unsigned} /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(2) {-height 15 -radix unsigned} /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(1) {-height 15 -radix unsigned} /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(0) {-height 15 -radix unsigned}} /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id
add wave -noupdate -group tes_signalling_frame -expand -group out /tb_tes_top/inst_dut_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_data_valid
add wave -noupdate -group tes_pulse_manager -group generic -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/g_CMD_PULSE_HEIGHT_WIDTH
add wave -noupdate -group tes_pulse_manager -group generic -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/g_CMD_TIME_SHIFT_WIDTH
add wave -noupdate -group tes_pulse_manager -group generic -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/g_CMD_PIXEL_ID_WIDTH
add wave -noupdate -group tes_pulse_manager -group generic -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/g_NB_FRAME_BY_PULSE_SHAPE
add wave -noupdate -group tes_pulse_manager -group generic -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/g_NB_SAMPLE_BY_FRAME_WIDTH
add wave -noupdate -group tes_pulse_manager -group generic -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/g_PULSE_SHAPE_RAM_ADDR_WIDTH
add wave -noupdate -group tes_pulse_manager -group generic -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/g_PIXEL_RESULT_OUTPUT_WIDTH
add wave -noupdate -group tes_pulse_manager -expand -group in /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_clk
add wave -noupdate -group tes_pulse_manager -expand -group in /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_rst
add wave -noupdate -group tes_pulse_manager -expand -group in /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_rst_status
add wave -noupdate -group tes_pulse_manager -expand -group in /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_debug_pulse
add wave -noupdate -group tes_pulse_manager -expand -group in -group cmd /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_cmd_valid
add wave -noupdate -group tes_pulse_manager -expand -group in -group cmd -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_cmd_pulse_height
add wave -noupdate -group tes_pulse_manager -expand -group in -group cmd -radix unsigned -childformat {{/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_cmd_pixel_id(5) -radix unsigned} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_cmd_pixel_id(4) -radix unsigned} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_cmd_pixel_id(3) -radix unsigned} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_cmd_pixel_id(2) -radix unsigned} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_cmd_pixel_id(1) -radix unsigned} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_cmd_pixel_id(0) -radix unsigned}} -subitemconfig {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_cmd_pixel_id(5) {-height 15 -radix unsigned} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_cmd_pixel_id(4) {-height 15 -radix unsigned} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_cmd_pixel_id(3) {-height 15 -radix unsigned} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_cmd_pixel_id(2) {-height 15 -radix unsigned} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_cmd_pixel_id(1) {-height 15 -radix unsigned} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_cmd_pixel_id(0) {-height 15 -radix unsigned}} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_cmd_pixel_id
add wave -noupdate -group tes_pulse_manager -expand -group in -group cmd -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_cmd_time_shift
add wave -noupdate -group tes_pulse_manager -expand -group in -group ram_pulse_shape /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_pulse_shape_wr_en
add wave -noupdate -group tes_pulse_manager -expand -group in -group ram_pulse_shape -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_pulse_shape_wr_rd_addr
add wave -noupdate -group tes_pulse_manager -expand -group in -group ram_pulse_shape /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_pulse_shape_wr_data
add wave -noupdate -group tes_pulse_manager -expand -group in -group ram_pulse_shape /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_pulse_shape_rd_en
add wave -noupdate -group tes_pulse_manager -expand -group in -group ram_pulse_shape /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/o_pulse_shape_rd_valid
add wave -noupdate -group tes_pulse_manager -expand -group in -group ram_pulse_shape /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/o_pulse_shape_rd_data
add wave -noupdate -group tes_pulse_manager -expand -group in -group ram_steady_state /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_steady_state_wr_en
add wave -noupdate -group tes_pulse_manager -expand -group in -group ram_steady_state -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_steady_state_wr_rd_addr
add wave -noupdate -group tes_pulse_manager -expand -group in -group ram_steady_state /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_steady_state_wr_data
add wave -noupdate -group tes_pulse_manager -expand -group in -group ram_steady_state /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_steady_state_rd_en
add wave -noupdate -group tes_pulse_manager -expand -group in -group ram_steady_state /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/o_steady_state_rd_valid
add wave -noupdate -group tes_pulse_manager -expand -group in -group ram_steady_state /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/o_steady_state_rd_data
add wave -noupdate -group tes_pulse_manager -expand -group in -expand -group data /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_pixel_sof
add wave -noupdate -group tes_pulse_manager -expand -group in -expand -group data /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_pixel_eof
add wave -noupdate -group tes_pulse_manager -expand -group in -expand -group data -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_pixel_id
add wave -noupdate -group tes_pulse_manager -expand -group in -expand -group data /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/i_pixel_valid
add wave -noupdate -group tes_pulse_manager -group step1 -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/c_SHIFT_MAX_VECTOR
add wave -noupdate -group tes_pulse_manager -group step1 /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/empty1
add wave -noupdate -group tes_pulse_manager -group step1 -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/cmd_pulse_height1
add wave -noupdate -group tes_pulse_manager -group step1 -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/cmd_pixel_id1
add wave -noupdate -group tes_pulse_manager -group step1 /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/cmd_time_shift1
add wave -noupdate -group tes_pulse_manager -group step1 /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/sm_state_r1
add wave -noupdate -group tes_pulse_manager -group step1 /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/cmd_rd_r1
add wave -noupdate -group tes_pulse_manager -group step1 /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/en_r1
add wave -noupdate -group tes_pulse_manager -group step1 /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/pixel_valid_r1
add wave -noupdate -group tes_pulse_manager -group step1 -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/cnt_sample_pulse_shape_r1
add wave -noupdate -group tes_pulse_manager -group step1 -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/pulse_heigth_r1
add wave -noupdate -group tes_pulse_manager -group step1 -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/ram_addr_r1
add wave -noupdate -group tes_pulse_manager -group step1 /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/time_shift_r1
add wave -noupdate -group tes_pulse_manager -group step2_rc /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/pixel_sof_rc
add wave -noupdate -group tes_pulse_manager -group step2_rc /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/pixel_eof_rc
add wave -noupdate -group tes_pulse_manager -group step2_rc -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/addr_pulse_shape_rc
add wave -noupdate -group tes_pulse_manager -group step2_rc -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/pixel_id_rc
add wave -noupdate -group tes_pulse_manager -group step2_rc -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/pulse_heigth_rc
add wave -noupdate -group tes_pulse_manager -group step2_rc /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/pixel_valid_rc
add wave -noupdate -group tes_pulse_manager -group step3 -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/pulse_shape_doutb
add wave -noupdate -group tes_pulse_manager -group step3 -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/steady_state_doutb
add wave -noupdate -group tes_pulse_manager -group step3 /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/pixel_sof_rx
add wave -noupdate -group tes_pulse_manager -group step3 /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/pixel_eof_rx
add wave -noupdate -group tes_pulse_manager -group step3 /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/pixel_valid_rx
add wave -noupdate -group tes_pulse_manager -group step3 -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/pixel_id_rx
add wave -noupdate -group tes_pulse_manager -group step3 -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/pulse_heigth_rx
add wave -noupdate -group tes_pulse_manager -group out /tb_tes_top/inst_dut_tes_top/o_pulse_sof
add wave -noupdate -group tes_pulse_manager -group out /tb_tes_top/inst_dut_tes_top/o_pulse_eof
add wave -noupdate -group tes_pulse_manager -group out /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/o_pixel_sof
add wave -noupdate -group tes_pulse_manager -group out /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/o_pixel_eof
add wave -noupdate -group tes_pulse_manager -group out /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/o_pixel_valid
add wave -noupdate -group tes_pulse_manager -group out -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/o_pixel_id
add wave -noupdate -group tes_pulse_manager -group out /tb_tes_top/inst_dut_tes_top/o_frame_sof
add wave -noupdate -group tes_pulse_manager -group out /tb_tes_top/inst_dut_tes_top/o_frame_eof
add wave -noupdate -group tes_pulse_manager -group out -radix unsigned /tb_tes_top/inst_dut_tes_top/o_frame_id
add wave -noupdate -group tes_pulse_manager -group out -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/o_pixel_result
add wave -noupdate -group tes_pulse_manager -group out -expand -group error_status -color Magenta /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/o_errors
add wave -noupdate -group tes_pulse_manager -group out -expand -group error_status /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/o_status
add wave -noupdate -group mult_sub_fixed -group generic -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/g_Q_M_A
add wave -noupdate -group mult_sub_fixed -group generic -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/g_Q_N_A
add wave -noupdate -group mult_sub_fixed -group generic -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/g_Q_M_B
add wave -noupdate -group mult_sub_fixed -group generic -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/g_Q_N_B
add wave -noupdate -group mult_sub_fixed -group generic -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/g_Q_M_C
add wave -noupdate -group mult_sub_fixed -group generic -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/g_Q_N_C
add wave -noupdate -group mult_sub_fixed -group generic -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/g_Q_M_S
add wave -noupdate -group mult_sub_fixed -group generic -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/g_Q_N_S
add wave -noupdate -group mult_sub_fixed -group generic /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/g_SIM_EN
add wave -noupdate -group mult_sub_fixed -expand -group in /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/pixel_sof_rx
add wave -noupdate -group mult_sub_fixed -expand -group in /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/pixel_eof_rx
add wave -noupdate -group mult_sub_fixed -expand -group in -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/pixel_id_rx
add wave -noupdate -group mult_sub_fixed -expand -group in /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/pixel_valid_rx
add wave -noupdate -group mult_sub_fixed -expand -group in /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/i_clk
add wave -noupdate -group mult_sub_fixed -expand -group in -radix hexadecimal /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/i_a
add wave -noupdate -group mult_sub_fixed -expand -group in -radix hexadecimal /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/i_b
add wave -noupdate -group mult_sub_fixed -expand -group in -radix hexadecimal /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/i_c
add wave -noupdate -group mult_sub_fixed -expand -group step1 -expand -group ram_pulse_shape_out -radix sfixed /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/a_r1
add wave -noupdate -group mult_sub_fixed -expand -group step1 -expand -group pulse_height -radix sfixed /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/b_r1
add wave -noupdate -group mult_sub_fixed -expand -group step1 -expand -group ram_steady_state_out -radix sfixed /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/c_r1
add wave -noupdate -group mult_sub_fixed -group step2 -expand -group axb -radix sfixed /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/mult_r2
add wave -noupdate -group mult_sub_fixed -group step2 -radix sfixed /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/c_r2
add wave -noupdate -group mult_sub_fixed -expand -group step3 -expand -group s=c-a*b -radix sfixed -childformat {{/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(18) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(17) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(16) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(15) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(14) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(13) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(12) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(11) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(10) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(9) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(8) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(7) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(6) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(5) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(4) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(3) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(2) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(1) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(0) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-1) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-2) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-3) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-4) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-5) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-6) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-7) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-8) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-9) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-10) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-11) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-12) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-13) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-14) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-15) -radix sfixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-16) -radix sfixed}} -subitemconfig {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(18) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(17) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(16) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(15) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(14) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(13) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(12) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(11) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(10) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(9) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(8) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(7) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(6) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(5) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(4) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(3) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(2) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(1) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(0) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-1) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-2) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-3) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-4) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-5) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-6) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-7) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-8) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-9) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-10) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-11) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-12) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-13) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-14) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-15) {-radix sfixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3(-16) {-radix sfixed}} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_r3
add wave -noupdate -group mult_sub_fixed -expand -group step3 -expand -group trunc_out -radix ufixed -childformat {{/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(16) -radix ufixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(15) -radix ufixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(14) -radix ufixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(13) -radix ufixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(12) -radix ufixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(11) -radix ufixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(10) -radix ufixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(9) -radix ufixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(8) -radix ufixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(7) -radix ufixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(6) -radix ufixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(5) -radix ufixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(4) -radix ufixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(3) -radix ufixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(2) -radix ufixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(1) -radix ufixed} {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(0) -radix ufixed}} -subitemconfig {/tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(16) {-radix ufixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(15) {-radix ufixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(14) {-radix ufixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(13) {-radix ufixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(12) {-radix ufixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(11) {-radix ufixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(10) {-radix ufixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(9) {-radix ufixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(8) {-radix ufixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(7) {-radix ufixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(6) {-radix ufixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(5) {-radix ufixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(4) {-radix ufixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(3) {-radix ufixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(2) {-radix ufixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(1) {-radix ufixed} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4(0) {-radix ufixed}} /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/res_tmp4
add wave -noupdate -group mult_sub_fixed -group out -radix unsigned /tb_tes_top/inst_dut_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/o_s
add wave -noupdate -divider testbench
add wave -noupdate -group tb_generic -radix unsigned /tb_tes_top/g_CMD_PULSE_HEIGHT_WIDTH
add wave -noupdate -group tb_generic -radix unsigned /tb_tes_top/g_CMD_TIME_SHIFT_WIDTH
add wave -noupdate -group tb_generic -radix unsigned /tb_tes_top/g_CMD_PIXEL_ID_WIDTH
add wave -noupdate -group tb_generic -radix unsigned /tb_tes_top/g_PIXEL_LENGTH_WIDTH
add wave -noupdate -group tb_generic -radix unsigned /tb_tes_top/g_FRAME_LENGTH_WIDTH
add wave -noupdate -group tb_generic -radix unsigned /tb_tes_top/g_FRAME_ID_WIDTH
add wave -noupdate -group tb_generic -radix unsigned /tb_tes_top/g_PULSE_SHAPE_RAM_ADDR_WIDTH
add wave -noupdate -group tb_generic -radix unsigned /tb_tes_top/g_PIXEL_RESULT_OUTPUT_WIDTH
add wave -noupdate -group tb_generic /tb_tes_top/g_VUNIT_DEBUG
add wave -noupdate -group tb_generic /tb_tes_top/g_TEST_NAME
add wave -noupdate -group tb_generic /tb_tes_top/g_ENABLE_CHECK
add wave -noupdate -group tb_generic /tb_tes_top/g_ENABLE_LOG
add wave -noupdate -group Master_FSM /tb_tes_top/reg_start
add wave -noupdate -group Master_FSM /tb_tes_top/reg_gen_finish
add wave -noupdate -group Master_FSM /tb_tes_top/cmd_start
add wave -noupdate -group Master_FSM /tb_tes_top/cmd_gen_finish
add wave -noupdate -group Master_FSM /tb_tes_top/data_start
add wave -noupdate -group Master_FSM /tb_tes_top/data_gen_finish
add wave -noupdate -group stat -radix unsigned /tb_tes_top/data_count_in
add wave -noupdate -group stat /tb_tes_top/data_count_overflow_in
add wave -noupdate -group stat /tb_tes_top/data_gen_finish
add wave -noupdate -group stat -radix unsigned /tb_tes_top/data_count_out
add wave -noupdate -group stat /tb_tes_top/data_count_overflow_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {918134012 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 220
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
WaveRestoreZoom {917761180 ps} {918506844 ps}
