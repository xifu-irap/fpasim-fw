onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_system_fpasim_top/usb_clk
add wave -noupdate /tb_system_fpasim_top/sys_clk
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/DNOP
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/DReset
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/Dwires
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/DUpdateWireIns
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/DUpdateWireOuts
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/DTriggers
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/DActivateTriggerIn
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/DUpdateTriggerOuts
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/DPipes
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/DWriteToPipeIn
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/DReadFromPipeOut
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/DWriteToBlockPipeIn
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/DReadFromBlockPipeOut
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/DRegisters
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/DWriteRegister
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/DReadRegister
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/DWriteRegisterSet
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/DReadRegisterSet
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/CReset
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/CSetWireIns
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/CUpdateWireIns
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/CGetWireOutValue
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/CUpdateWireOuts
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/CActivateTriggerIn
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/CUpdateTriggerOuts
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/CIsTriggered
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/CWriteToPipeIn
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/CReadFromPipeOut
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/CWriteToBTPipeIn
add wave -noupdate -group Opal_Kelly_Host -group cst /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/CReadFromBTPipeOut
add wave -noupdate -group Opal_Kelly_Host -group user_if /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/okUH
add wave -noupdate -group Opal_Kelly_Host -group user_if /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/okHU
add wave -noupdate -group Opal_Kelly_Host -group user_if /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/okUHU
add wave -noupdate -group Opal_Kelly_Host -group fpga_if /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/okClk
add wave -noupdate -group Opal_Kelly_Host -group fpga_if /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/okHE
add wave -noupdate -group Opal_Kelly_Host -group fpga_if /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/okEH
add wave -noupdate -group Opal_Kelly_Host /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/hi_clk
add wave -noupdate -group Opal_Kelly_Host /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/hi_drive
add wave -noupdate -group Opal_Kelly_Host /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/hi_datain
add wave -noupdate -group Opal_Kelly_Host /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/hi_dataout
add wave -noupdate -group Opal_Kelly_Host /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/hi_cmd
add wave -noupdate -group Opal_Kelly_Host /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/hi_busy
add wave -noupdate -group Opal_Kelly_Host /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/ep_command
add wave -noupdate -group Opal_Kelly_Host /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/ep_blockstrobe
add wave -noupdate -group Opal_Kelly_Host /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/ep_addr
add wave -noupdate -group Opal_Kelly_Host /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/ep_datain
add wave -noupdate -group Opal_Kelly_Host /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/ep_dataout
add wave -noupdate -group Opal_Kelly_Host /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/ep_ready
add wave -noupdate -group Opal_Kelly_Host /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/reg_addr
add wave -noupdate -group Opal_Kelly_Host /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/reg_write
add wave -noupdate -group Opal_Kelly_Host /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/reg_write_data
add wave -noupdate -group Opal_Kelly_Host /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/reg_read
add wave -noupdate -group Opal_Kelly_Host /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/reg_read_data
add wave -noupdate -expand -group regdecode_top /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_clk
add wave -noupdate -expand -group regdecode_top -group usb -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_pipein_fifo_valid
add wave -noupdate -expand -group regdecode_top -group usb -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_pipein_fifo
add wave -noupdate -expand -group regdecode_top -group usb -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_trigin_data
add wave -noupdate -expand -group regdecode_top -group usb -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_wirein_ctrl
add wave -noupdate -expand -group regdecode_top -group usb -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_wirein_make_pulse
add wave -noupdate -expand -group regdecode_top -group usb -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_wirein_fpasim_gain
add wave -noupdate -expand -group regdecode_top -group usb -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_wirein_mux_sq_fb_delay
add wave -noupdate -expand -group regdecode_top -group usb -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_wirein_amp_sq_of_delay
add wave -noupdate -expand -group regdecode_top -group usb -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_wirein_error_delay
add wave -noupdate -expand -group regdecode_top -group usb -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_wirein_ra_delay
add wave -noupdate -expand -group regdecode_top -group usb -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_wirein_tes_conf
add wave -noupdate -expand -group regdecode_top -group usb -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_wirein_debug_ctrl
add wave -noupdate -expand -group regdecode_top -group usb -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_wirein_sel_errors
add wave -noupdate -expand -group regdecode_top -group usb -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_pipeout_fifo_rd
add wave -noupdate -expand -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_trigout_data
add wave -noupdate -expand -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_fifo_data_count
add wave -noupdate -expand -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_ctrl
add wave -noupdate -expand -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_make_pulse
add wave -noupdate -expand -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_fpasim_gain
add wave -noupdate -expand -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_mux_sq_fb_delay
add wave -noupdate -expand -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_amp_sq_of_delay
add wave -noupdate -expand -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_error_delay
add wave -noupdate -expand -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_ra_delay
add wave -noupdate -expand -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_tes_conf
add wave -noupdate -expand -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_debug_ctrl
add wave -noupdate -expand -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_fpga_id
add wave -noupdate -expand -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_fpga_version
add wave -noupdate -expand -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_sel_errors
add wave -noupdate -expand -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_errors
add wave -noupdate -expand -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_status
add wave -noupdate -expand -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_pipeout_fifo_data
add wave -noupdate -expand -group regdecode_top -group reg /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_valid
add wave -noupdate -expand -group regdecode_top -group reg -group conf /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_fpasim_gain
add wave -noupdate -expand -group regdecode_top -group reg -group conf /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_mux_sq_fb_delay
add wave -noupdate -expand -group regdecode_top -group reg -group conf /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_amp_sq_of_delay
add wave -noupdate -expand -group regdecode_top -group reg -group conf /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_error_delay
add wave -noupdate -expand -group regdecode_top -group reg -group conf /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_ra_delay
add wave -noupdate -expand -group regdecode_top -group reg -group conf /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_tes_conf
add wave -noupdate -expand -group regdecode_top -group reg -expand -group ctrl /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_ctrl_valid
add wave -noupdate -expand -group regdecode_top -group reg -expand -group ctrl /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_ctrl
add wave -noupdate -expand -group regdecode_top -group reg -group debug /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_debug_ctrl_valid
add wave -noupdate -expand -group regdecode_top -group reg -group debug /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_debug_ctrl
add wave -noupdate -expand -group regdecode_top -group reg -group make_pulse /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_make_sof
add wave -noupdate -expand -group regdecode_top -group reg -group make_pulse /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_make_eof
add wave -noupdate -expand -group regdecode_top -group reg -group make_pulse /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_make_pulse_valid
add wave -noupdate -expand -group regdecode_top -group reg -group make_pulse /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_make_pulse
add wave -noupdate -expand -group regdecode_top -group ram_tes_pulse_shape -expand -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_tes_pulse_shape_ram_wr_en
add wave -noupdate -expand -group regdecode_top -group ram_tes_pulse_shape -expand -group wr -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_tes_pulse_shape_ram_wr_rd_addr
add wave -noupdate -expand -group regdecode_top -group ram_tes_pulse_shape -expand -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_tes_pulse_shape_ram_wr_data
add wave -noupdate -expand -group regdecode_top -group ram_tes_pulse_shape -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_tes_pulse_shape_ram_rd_en
add wave -noupdate -expand -group regdecode_top -group ram_tes_pulse_shape -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_tes_pulse_shape_ram_rd_valid
add wave -noupdate -expand -group regdecode_top -group ram_tes_pulse_shape -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_tes_pulse_shape_ram_rd_data
add wave -noupdate -expand -group regdecode_top -group ram_tes_steady_state -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_tes_std_state_ram_wr_en
add wave -noupdate -expand -group regdecode_top -group ram_tes_steady_state -group wr -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_tes_std_state_ram_wr_rd_addr
add wave -noupdate -expand -group regdecode_top -group ram_tes_steady_state -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_tes_std_state_ram_wr_data
add wave -noupdate -expand -group regdecode_top -group ram_tes_steady_state -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_tes_std_state_ram_rd_en
add wave -noupdate -expand -group regdecode_top -group ram_tes_steady_state -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_tes_std_state_ram_rd_valid
add wave -noupdate -expand -group regdecode_top -group ram_tes_steady_state -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_tes_std_state_ram_rd_data
add wave -noupdate -expand -group regdecode_top -group ram_mux_squid_offset -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_mux_squid_offset_ram_wr_en
add wave -noupdate -expand -group regdecode_top -group ram_mux_squid_offset -group wr -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_mux_squid_offset_ram_wr_rd_addr
add wave -noupdate -expand -group regdecode_top -group ram_mux_squid_offset -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_mux_squid_offset_ram_wr_data
add wave -noupdate -expand -group regdecode_top -group ram_mux_squid_offset -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_mux_squid_offset_ram_rd_en
add wave -noupdate -expand -group regdecode_top -group ram_mux_squid_offset -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_mux_squid_offset_ram_rd_valid
add wave -noupdate -expand -group regdecode_top -group ram_mux_squid_offset -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_mux_squid_offset_ram_rd_data
add wave -noupdate -expand -group regdecode_top -group ram_mux_squid_tf -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_mux_squid_tf_ram_wr_en
add wave -noupdate -expand -group regdecode_top -group ram_mux_squid_tf -group wr -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_mux_squid_tf_ram_wr_rd_addr
add wave -noupdate -expand -group regdecode_top -group ram_mux_squid_tf -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_mux_squid_tf_ram_wr_data
add wave -noupdate -expand -group regdecode_top -group ram_mux_squid_tf -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_mux_squid_tf_ram_rd_en
add wave -noupdate -expand -group regdecode_top -group ram_mux_squid_tf -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_mux_squid_tf_ram_rd_valid
add wave -noupdate -expand -group regdecode_top -group ram_mux_squid_tf -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_mux_squid_tf_ram_rd_data
add wave -noupdate -expand -group regdecode_top -group ram_amp_squid_tf -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_amp_squid_tf_ram_wr_en
add wave -noupdate -expand -group regdecode_top -group ram_amp_squid_tf -group wr -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_amp_squid_tf_ram_wr_rd_addr
add wave -noupdate -expand -group regdecode_top -group ram_amp_squid_tf -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_amp_squid_tf_ram_wr_data
add wave -noupdate -expand -group regdecode_top -group ram_amp_squid_tf -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_amp_squid_tf_ram_rd_en
add wave -noupdate -expand -group regdecode_top -group ram_amp_squid_tf -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_amp_squid_tf_ram_rd_valid
add wave -noupdate -expand -group regdecode_top -group ram_amp_squid_tf -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_amp_squid_tf_ram_rd_data
add wave -noupdate -expand -group regdecode_ctrl_reg -expand -group user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/i_clk
add wave -noupdate -expand -group regdecode_ctrl_reg -expand -group user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/i_out_clk
add wave -noupdate -expand -group regdecode_ctrl_reg -expand -group user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/i_rst_status
add wave -noupdate -expand -group regdecode_ctrl_reg -expand -group user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/i_debug_pulse
add wave -noupdate -expand -group regdecode_ctrl_reg -expand -group user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/i_data_valid
add wave -noupdate -expand -group regdecode_ctrl_reg -expand -group user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/i_data
add wave -noupdate -expand -group regdecode_ctrl_reg -expand -group user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/o_data_valid
add wave -noupdate -expand -group regdecode_ctrl_reg -expand -group user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/o_data
add wave -noupdate -expand -group regdecode_ctrl_reg -group usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/i_fifo_rd
add wave -noupdate -expand -group regdecode_ctrl_reg -group usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/o_fifo_data_valid
add wave -noupdate -expand -group regdecode_ctrl_reg -group usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/o_fifo_data
add wave -noupdate -expand -group regdecode_ctrl_reg -group usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/o_fifo_empty
add wave -noupdate -expand -group regdecode_ctrl_reg -group usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/o_errors
add wave -noupdate -expand -group regdecode_ctrl_reg -group usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/o_status
add wave -noupdate -expand -group regdecode_ctrl_reg -group fifo0 -expand -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/wr_rst_tmp0
add wave -noupdate -expand -group regdecode_ctrl_reg -group fifo0 -expand -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/wr_tmp0
add wave -noupdate -expand -group regdecode_ctrl_reg -group fifo0 -expand -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/data_tmp0
add wave -noupdate -expand -group regdecode_ctrl_reg -group fifo0 -expand -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/rd1
add wave -noupdate -expand -group regdecode_ctrl_reg -group fifo0 -expand -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/data_valid1
add wave -noupdate -expand -group regdecode_ctrl_reg -group fifo0 -expand -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/data1
add wave -noupdate -expand -group regdecode_ctrl_reg -group fifo1 -expand -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/wr_tmp2
add wave -noupdate -expand -group regdecode_ctrl_reg -group fifo1 -expand -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/data_tmp2
add wave -noupdate -expand -group regdecode_ctrl_reg -group fifo1 -expand -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/rd3
add wave -noupdate -expand -group regdecode_ctrl_reg -group fifo1 -expand -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/data_valid3
add wave -noupdate -expand -group regdecode_ctrl_reg -group fifo1 -expand -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/data3
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {491914 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 245
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
WaveRestoreZoom {39038081 ps} {39123987 ps}
