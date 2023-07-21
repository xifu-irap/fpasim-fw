onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group tes_top -group in /tb_tes_top/inst_tes_top/i_clk
add wave -noupdate -group tes_top -group in /tb_tes_top/inst_tes_top/i_rst
add wave -noupdate -group tes_top -group in /tb_tes_top/inst_tes_top/i_rst_status
add wave -noupdate -group tes_top -group in /tb_tes_top/inst_tes_top/i_debug_pulse
add wave -noupdate -group tes_top -group in /tb_tes_top/inst_tes_top/i_en
add wave -noupdate -group tes_top -group in -radix unsigned /tb_tes_top/inst_tes_top/i_nb_sample_by_pixel
add wave -noupdate -group tes_top -group in -radix unsigned /tb_tes_top/inst_tes_top/i_nb_pixel_by_frame
add wave -noupdate -group tes_top -group in -radix unsigned /tb_tes_top/inst_tes_top/i_nb_sample_by_frame
add wave -noupdate -group tes_top -group in -group cmd /tb_tes_top/inst_tes_top/i_cmd_valid
add wave -noupdate -group tes_top -group in -group cmd -radix unsigned /tb_tes_top/inst_tes_top/i_cmd_pulse_height
add wave -noupdate -group tes_top -group in -group cmd -radix unsigned /tb_tes_top/inst_tes_top/i_cmd_pixel_id
add wave -noupdate -group tes_top -group in -group cmd -radix unsigned /tb_tes_top/inst_tes_top/i_cmd_time_shift
add wave -noupdate -group tes_top -group in -group ram_pulse_shape /tb_tes_top/inst_tes_top/i_pulse_shape_wr_en
add wave -noupdate -group tes_top -group in -group ram_pulse_shape -radix unsigned /tb_tes_top/inst_tes_top/i_pulse_shape_wr_rd_addr
add wave -noupdate -group tes_top -group in -group ram_pulse_shape -format Analog-Step -height 74 -max 65530.999999999993 -radix unsigned /tb_tes_top/inst_tes_top/i_pulse_shape_wr_data
add wave -noupdate -group tes_top -group in -group ram_pulse_shape /tb_tes_top/inst_tes_top/i_pulse_shape_rd_en
add wave -noupdate -group tes_top -group in -group ram_pulse_shape /tb_tes_top/inst_tes_top/o_pulse_shape_rd_valid
add wave -noupdate -group tes_top -group in -group ram_pulse_shape /tb_tes_top/inst_tes_top/o_pulse_shape_rd_data
add wave -noupdate -group tes_top -group in -expand -group ram_steady_state /tb_tes_top/inst_tes_top/i_steady_state_wr_en
add wave -noupdate -group tes_top -group in -expand -group ram_steady_state -radix unsigned /tb_tes_top/inst_tes_top/i_steady_state_wr_rd_addr
add wave -noupdate -group tes_top -group in -expand -group ram_steady_state -format Analog-Step -height 74 -max 65279.999999999993 -radix unsigned /tb_tes_top/inst_tes_top/i_steady_state_wr_data
add wave -noupdate -group tes_top -group in -expand -group ram_steady_state /tb_tes_top/inst_tes_top/i_steady_state_rd_en
add wave -noupdate -group tes_top -group in -expand -group ram_steady_state /tb_tes_top/inst_tes_top/o_steady_state_rd_valid
add wave -noupdate -group tes_top -group in -expand -group ram_steady_state /tb_tes_top/inst_tes_top/o_steady_state_rd_data
add wave -noupdate -group tes_top -group in -group data /tb_tes_top/inst_tes_top/i_data_valid
add wave -noupdate -group tes_top -group out -group data /tb_tes_top/inst_tes_top/o_pixel_sof
add wave -noupdate -group tes_top -group out -group data /tb_tes_top/inst_tes_top/o_pixel_eof
add wave -noupdate -group tes_top -group out -group data /tb_tes_top/inst_tes_top/o_pixel_valid
add wave -noupdate -group tes_top -group out -group data -radix unsigned /tb_tes_top/inst_tes_top/o_pixel_id
add wave -noupdate -group tes_top -group out -group data /tb_tes_top/inst_tes_top/o_pixel_result
add wave -noupdate -group tes_top -group out -group data /tb_tes_top/inst_tes_top/o_frame_sof
add wave -noupdate -group tes_top -group out -group data /tb_tes_top/inst_tes_top/o_frame_eof
add wave -noupdate -group tes_top -group out -group data -radix unsigned /tb_tes_top/inst_tes_top/o_frame_id
add wave -noupdate -group tes_top -group out -expand -group errors_status -color Magenta /tb_tes_top/inst_tes_top/o_errors
add wave -noupdate -group tes_top -group out -expand -group errors_status /tb_tes_top/inst_tes_top/o_status
add wave -noupdate -divider internal_modules
add wave -noupdate -group tes_signalling_pixel -group in /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/i_clk
add wave -noupdate -group tes_signalling_pixel -group in /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/i_rst
add wave -noupdate -group tes_signalling_pixel -group in /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/i_start
add wave -noupdate -group tes_signalling_pixel -group in -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/i_nb_samples_by_block
add wave -noupdate -group tes_signalling_pixel -group in -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/i_nb_block
add wave -noupdate -group tes_signalling_pixel -group in /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/i_data_valid
add wave -noupdate -group tes_signalling_pixel -expand -group step1 /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/sm_state_r1
add wave -noupdate -group tes_signalling_pixel -expand -group step1 /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/data_valid_r1
add wave -noupdate -group tes_signalling_pixel -expand -group step1 /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/sof_r1
add wave -noupdate -group tes_signalling_pixel -expand -group step1 /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/eof_r1
add wave -noupdate -group tes_signalling_pixel -expand -group step1 -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/cnt_frame_r1
add wave -noupdate -group tes_signalling_pixel -expand -group step1 -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/cnt_frame_max_r1
add wave -noupdate -group tes_signalling_pixel -expand -group out /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_sof
add wave -noupdate -group tes_signalling_pixel -expand -group out /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_eof
add wave -noupdate -group tes_signalling_pixel -expand -group out -radix unsigned -childformat {{/tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_id(5) -radix unsigned} {/tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_id(4) -radix unsigned} {/tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_id(3) -radix unsigned} {/tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_id(2) -radix unsigned} {/tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_id(1) -radix unsigned} {/tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_id(0) -radix unsigned}} -expand -subitemconfig {/tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_id(5) {-height 15 -radix unsigned} /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_id(4) {-height 15 -radix unsigned} /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_id(3) {-height 15 -radix unsigned} /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_id(2) {-height 15 -radix unsigned} /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_id(1) {-height 15 -radix unsigned} /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_id(0) {-height 15 -radix unsigned}} /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_id
add wave -noupdate -group tes_signalling_pixel -expand -group out /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_pixel/o_data_valid
add wave -noupdate -group tes_signalling_frame -expand -group in /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/i_clk
add wave -noupdate -group tes_signalling_frame -expand -group in /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/i_rst
add wave -noupdate -group tes_signalling_frame -expand -group in /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/i_start
add wave -noupdate -group tes_signalling_frame -expand -group in -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/i_nb_samples_by_block
add wave -noupdate -group tes_signalling_frame -expand -group in -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/i_nb_block
add wave -noupdate -group tes_signalling_frame -expand -group in /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/i_data_valid
add wave -noupdate -group tes_signalling_frame -group step1 /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/sm_state_r1
add wave -noupdate -group tes_signalling_frame -group step1 /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/data_valid_r1
add wave -noupdate -group tes_signalling_frame -group step1 /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/sof_r1
add wave -noupdate -group tes_signalling_frame -group step1 /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/eof_r1
add wave -noupdate -group tes_signalling_frame -group step1 -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/cnt_frame_r1
add wave -noupdate -group tes_signalling_frame -group step1 -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/cnt_frame_max_r1
add wave -noupdate -group tes_signalling_frame -expand -group out /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_sof
add wave -noupdate -group tes_signalling_frame -expand -group out /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_eof
add wave -noupdate -group tes_signalling_frame -expand -group out -radix unsigned -childformat {{/tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(10) -radix unsigned} {/tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(9) -radix unsigned} {/tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(8) -radix unsigned} {/tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(7) -radix unsigned} {/tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(6) -radix unsigned} {/tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(5) -radix unsigned} {/tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(4) -radix unsigned} {/tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(3) -radix unsigned} {/tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(2) -radix unsigned} {/tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(1) -radix unsigned} {/tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(0) -radix unsigned}} -subitemconfig {/tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(10) {-height 15 -radix unsigned} /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(9) {-height 15 -radix unsigned} /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(8) {-height 15 -radix unsigned} /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(7) {-height 15 -radix unsigned} /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(6) {-height 15 -radix unsigned} /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(5) {-height 15 -radix unsigned} /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(4) {-height 15 -radix unsigned} /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(3) {-height 15 -radix unsigned} /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(2) {-height 15 -radix unsigned} /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(1) {-height 15 -radix unsigned} /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id(0) {-height 15 -radix unsigned}} /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_id
add wave -noupdate -group tes_signalling_frame -expand -group out /tb_tes_top/inst_tes_top/inst_tes_signalling/inst_tes_signalling_frame/o_data_valid
add wave -noupdate -group tes_pulse_manager -group generic -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/g_CMD_PULSE_HEIGHT_WIDTH
add wave -noupdate -group tes_pulse_manager -group generic -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/g_CMD_TIME_SHIFT_WIDTH
add wave -noupdate -group tes_pulse_manager -group generic -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/g_CMD_PIXEL_ID_WIDTH
add wave -noupdate -group tes_pulse_manager -group generic -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/g_NB_FRAME_BY_PULSE_SHAPE
add wave -noupdate -group tes_pulse_manager -group generic -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/g_NB_SAMPLE_BY_FRAME_WIDTH
add wave -noupdate -group tes_pulse_manager -group generic -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/g_PULSE_SHAPE_RAM_ADDR_WIDTH
add wave -noupdate -group tes_pulse_manager -group generic -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/g_PIXEL_RESULT_OUTPUT_WIDTH
add wave -noupdate -group tes_pulse_manager -group in /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_clk
add wave -noupdate -group tes_pulse_manager -group in /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_rst
add wave -noupdate -group tes_pulse_manager -group in /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_rst_status
add wave -noupdate -group tes_pulse_manager -group in /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_debug_pulse
add wave -noupdate -group tes_pulse_manager -group in -group cmd /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_cmd_valid
add wave -noupdate -group tes_pulse_manager -group in -group cmd -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_cmd_pulse_height
add wave -noupdate -group tes_pulse_manager -group in -group cmd -radix unsigned -childformat {{/tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_cmd_pixel_id(5) -radix unsigned} {/tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_cmd_pixel_id(4) -radix unsigned} {/tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_cmd_pixel_id(3) -radix unsigned} {/tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_cmd_pixel_id(2) -radix unsigned} {/tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_cmd_pixel_id(1) -radix unsigned} {/tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_cmd_pixel_id(0) -radix unsigned}} -subitemconfig {/tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_cmd_pixel_id(5) {-height 15 -radix unsigned} /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_cmd_pixel_id(4) {-height 15 -radix unsigned} /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_cmd_pixel_id(3) {-height 15 -radix unsigned} /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_cmd_pixel_id(2) {-height 15 -radix unsigned} /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_cmd_pixel_id(1) {-height 15 -radix unsigned} /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_cmd_pixel_id(0) {-height 15 -radix unsigned}} /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_cmd_pixel_id
add wave -noupdate -group tes_pulse_manager -group in -group cmd -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_cmd_time_shift
add wave -noupdate -group tes_pulse_manager -group in -expand -group ram_pulse_shape /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_pulse_shape_wr_en
add wave -noupdate -group tes_pulse_manager -group in -expand -group ram_pulse_shape -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_pulse_shape_wr_rd_addr
add wave -noupdate -group tes_pulse_manager -group in -expand -group ram_pulse_shape -format Analog-Step -height 74 -max 32765.000000000004 -min -32764.0 /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_pulse_shape_wr_data
add wave -noupdate -group tes_pulse_manager -group in -expand -group ram_pulse_shape /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_pulse_shape_rd_en
add wave -noupdate -group tes_pulse_manager -group in -expand -group ram_pulse_shape /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/o_pulse_shape_rd_valid
add wave -noupdate -group tes_pulse_manager -group in -expand -group ram_pulse_shape /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/o_pulse_shape_rd_data
add wave -noupdate -group tes_pulse_manager -group in -expand -group ram_steady_state /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_steady_state_wr_en
add wave -noupdate -group tes_pulse_manager -group in -expand -group ram_steady_state -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_steady_state_wr_rd_addr
add wave -noupdate -group tes_pulse_manager -group in -expand -group ram_steady_state -format Analog-Step -height 74 -max 31586.999999999996 -min -32394.0 /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_steady_state_wr_data
add wave -noupdate -group tes_pulse_manager -group in -expand -group ram_steady_state /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_steady_state_rd_en
add wave -noupdate -group tes_pulse_manager -group in -expand -group ram_steady_state /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/o_steady_state_rd_valid
add wave -noupdate -group tes_pulse_manager -group in -expand -group ram_steady_state /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/o_steady_state_rd_data
add wave -noupdate -group tes_pulse_manager -group in -expand -group data /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_pixel_sof
add wave -noupdate -group tes_pulse_manager -group in -expand -group data /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_pixel_eof
add wave -noupdate -group tes_pulse_manager -group in -expand -group data -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_pixel_id
add wave -noupdate -group tes_pulse_manager -group in -expand -group data /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/i_pixel_valid
add wave -noupdate -group tes_pulse_manager -group step1 -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/c_SHIFT_MAX_VECTOR
add wave -noupdate -group tes_pulse_manager -group step1 /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/empty1
add wave -noupdate -group tes_pulse_manager -group step1 -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/cmd_pulse_height1
add wave -noupdate -group tes_pulse_manager -group step1 -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/cmd_pixel_id1
add wave -noupdate -group tes_pulse_manager -group step1 /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/cmd_time_shift1
add wave -noupdate -group tes_pulse_manager -group step1 /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/sm_state_r1
add wave -noupdate -group tes_pulse_manager -group step1 /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/cmd_rd_r1
add wave -noupdate -group tes_pulse_manager -group step1 /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/en_r1
add wave -noupdate -group tes_pulse_manager -group step1 /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/pixel_valid_r1
add wave -noupdate -group tes_pulse_manager -group step1 -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/cnt_sample_pulse_shape_r1
add wave -noupdate -group tes_pulse_manager -group step1 -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/pulse_heigth_r1
add wave -noupdate -group tes_pulse_manager -group step1 -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/ram_addr_r1
add wave -noupdate -group tes_pulse_manager -group step1 /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/time_shift_r1
add wave -noupdate -group tes_pulse_manager -group step2_rc /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/pixel_sof_rc
add wave -noupdate -group tes_pulse_manager -group step2_rc /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/pixel_eof_rc
add wave -noupdate -group tes_pulse_manager -group step2_rc -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/addr_pulse_shape_rc
add wave -noupdate -group tes_pulse_manager -group step2_rc -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/pixel_id_rc
add wave -noupdate -group tes_pulse_manager -group step2_rc -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/pulse_heigth_rc
add wave -noupdate -group tes_pulse_manager -group step2_rc /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/pixel_valid_rc
add wave -noupdate -group tes_pulse_manager -group step3 -format Analog-Step -height 74 -max 65534.999999999993 -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/pulse_shape_doutb
add wave -noupdate -group tes_pulse_manager -group step3 -format Analog-Step -height 74 -max 58982.000000000007 -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/steady_state_doutb
add wave -noupdate -group tes_pulse_manager -group step3 /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/pixel_sof_rx
add wave -noupdate -group tes_pulse_manager -group step3 /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/pixel_eof_rx
add wave -noupdate -group tes_pulse_manager -group step3 /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/pixel_valid_rx
add wave -noupdate -group tes_pulse_manager -group step3 -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/pixel_id_rx
add wave -noupdate -group tes_pulse_manager -group step3 -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/pulse_heigth_rx
add wave -noupdate -group tes_pulse_manager -group out /tb_tes_top/inst_tes_top/o_pulse_sof
add wave -noupdate -group tes_pulse_manager -group out /tb_tes_top/inst_tes_top/o_pulse_eof
add wave -noupdate -group tes_pulse_manager -group out /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/o_pixel_sof
add wave -noupdate -group tes_pulse_manager -group out /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/o_pixel_eof
add wave -noupdate -group tes_pulse_manager -group out /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/o_pixel_valid
add wave -noupdate -group tes_pulse_manager -group out -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/o_pixel_id
add wave -noupdate -group tes_pulse_manager -group out /tb_tes_top/inst_tes_top/o_frame_sof
add wave -noupdate -group tes_pulse_manager -group out /tb_tes_top/inst_tes_top/o_frame_eof
add wave -noupdate -group tes_pulse_manager -group out -radix unsigned /tb_tes_top/inst_tes_top/o_frame_id
add wave -noupdate -group tes_pulse_manager -group out -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/o_pixel_result
add wave -noupdate -group tes_pulse_manager -group out -expand -group error_status -color Magenta /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/o_errors
add wave -noupdate -group tes_pulse_manager -group out -expand -group error_status /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/o_status
add wave -noupdate -group mult_sub_fixed -group generic -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/g_Q_M_A
add wave -noupdate -group mult_sub_fixed -group generic -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/g_Q_N_A
add wave -noupdate -group mult_sub_fixed -group generic -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/g_Q_M_B
add wave -noupdate -group mult_sub_fixed -group generic -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/g_Q_N_B
add wave -noupdate -group mult_sub_fixed -group generic -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/g_Q_M_C
add wave -noupdate -group mult_sub_fixed -group generic -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/g_Q_N_C
add wave -noupdate -group mult_sub_fixed -group generic -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/g_Q_M_S
add wave -noupdate -group mult_sub_fixed -group generic -radix unsigned /tb_tes_top/inst_tes_top/inst_tes_pulse_shape_manager/inst_mult_sub_sfixed/g_Q_N_S
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {87422000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 233
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
WaveRestoreZoom {63619172 ps} {111224828 ps}
