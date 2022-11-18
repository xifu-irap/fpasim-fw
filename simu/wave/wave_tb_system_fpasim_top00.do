onerror {resume}
quietly virtual signal -install /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host { /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/hi_datain(31 downto 16)} addr
quietly virtual signal -install /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host { /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/hi_datain(15 downto 0)} data
quietly virtual signal -install /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top { /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_pipein_fifo(31 downto 16)} i_usb_pipein_fifo_addr
quietly virtual signal -install /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top { /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_pipein_fifo(15 downto 0)} i_usb_pipein_fifo_data
quietly virtual signal -install /tb_system_fpasim_top { /tb_system_fpasim_top/o_data(31 downto 16)} o_data_addr
quietly virtual signal -install /tb_system_fpasim_top { /tb_system_fpasim_top/o_data(15 downto 0)} o_data_data
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_system_fpasim_top/usb_clk
add wave -noupdate /tb_system_fpasim_top/sys_clk
add wave -noupdate -group tb -radix unsigned /tb_system_fpasim_top/o_reg_id
add wave -noupdate -group tb /tb_system_fpasim_top/o_data_valid
add wave -noupdate -group tb /tb_system_fpasim_top/o_data_addr
add wave -noupdate -group tb /tb_system_fpasim_top/o_data_data
add wave -noupdate -group tb /tb_system_fpasim_top/o_data
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
add wave -noupdate -group Opal_Kelly_Host -expand -group fpga_if /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/okClk
add wave -noupdate -group Opal_Kelly_Host -expand -group fpga_if /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/okHE
add wave -noupdate -group Opal_Kelly_Host -expand -group fpga_if /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/okEH
add wave -noupdate -group Opal_Kelly_Host /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/hi_clk
add wave -noupdate -group Opal_Kelly_Host /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/hi_drive
add wave -noupdate -group Opal_Kelly_Host -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/addr
add wave -noupdate -group Opal_Kelly_Host -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_usb_opal_kelly/Opal_Kelly_Host/data
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
add wave -noupdate -group regdecode_top /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_clk
add wave -noupdate -group regdecode_top -group usb -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_pipein_fifo_valid
add wave -noupdate -group regdecode_top -group usb -expand -group in -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_pipein_fifo_addr
add wave -noupdate -group regdecode_top -group usb -expand -group in -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_pipein_fifo_data
add wave -noupdate -group regdecode_top -group usb -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_pipein_fifo
add wave -noupdate -group regdecode_top -group usb -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_trigin_data
add wave -noupdate -group regdecode_top -group usb -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_wirein_ctrl
add wave -noupdate -group regdecode_top -group usb -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_wirein_make_pulse
add wave -noupdate -group regdecode_top -group usb -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_wirein_fpasim_gain
add wave -noupdate -group regdecode_top -group usb -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_wirein_mux_sq_fb_delay
add wave -noupdate -group regdecode_top -group usb -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_wirein_amp_sq_of_delay
add wave -noupdate -group regdecode_top -group usb -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_wirein_error_delay
add wave -noupdate -group regdecode_top -group usb -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_wirein_ra_delay
add wave -noupdate -group regdecode_top -group usb -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_wirein_tes_conf
add wave -noupdate -group regdecode_top -group usb -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_wirein_debug_ctrl
add wave -noupdate -group regdecode_top -group usb -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_wirein_sel_errors
add wave -noupdate -group regdecode_top -group usb -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_usb_pipeout_fifo_rd
add wave -noupdate -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_trigout_data
add wave -noupdate -group regdecode_top -group usb -group out -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_fifo_data_count
add wave -noupdate -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_ctrl
add wave -noupdate -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_make_pulse
add wave -noupdate -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_fpasim_gain
add wave -noupdate -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_mux_sq_fb_delay
add wave -noupdate -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_amp_sq_of_delay
add wave -noupdate -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_error_delay
add wave -noupdate -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_ra_delay
add wave -noupdate -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_tes_conf
add wave -noupdate -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_debug_ctrl
add wave -noupdate -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_fpga_id
add wave -noupdate -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_fpga_version
add wave -noupdate -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_sel_errors
add wave -noupdate -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_errors
add wave -noupdate -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_wireout_status
add wave -noupdate -group regdecode_top -group usb -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_usb_pipeout_fifo_data
add wave -noupdate -group regdecode_top -group reg /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_valid
add wave -noupdate -group regdecode_top -group reg -group conf /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_fpasim_gain
add wave -noupdate -group regdecode_top -group reg -group conf /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_mux_sq_fb_delay
add wave -noupdate -group regdecode_top -group reg -group conf /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_amp_sq_of_delay
add wave -noupdate -group regdecode_top -group reg -group conf /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_error_delay
add wave -noupdate -group regdecode_top -group reg -group conf /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_ra_delay
add wave -noupdate -group regdecode_top -group reg -group conf /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_tes_conf
add wave -noupdate -group regdecode_top -group reg -group ctrl /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_ctrl_valid
add wave -noupdate -group regdecode_top -group reg -group ctrl /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_ctrl
add wave -noupdate -group regdecode_top -group reg -group debug /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_debug_ctrl_valid
add wave -noupdate -group regdecode_top -group reg -group debug /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_debug_ctrl
add wave -noupdate -group regdecode_top -group reg -group make_pulse /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_reg_make_pulse_ready
add wave -noupdate -group regdecode_top -group reg -group make_pulse /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_make_sof
add wave -noupdate -group regdecode_top -group reg -group make_pulse /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_make_eof
add wave -noupdate -group regdecode_top -group reg -group make_pulse /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_make_pulse_valid
add wave -noupdate -group regdecode_top -group reg -group make_pulse /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_reg_make_pulse
add wave -noupdate -group regdecode_top -group ram_tes_pulse_shape -expand -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_tes_pulse_shape_ram_wr_en
add wave -noupdate -group regdecode_top -group ram_tes_pulse_shape -expand -group wr -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_tes_pulse_shape_ram_wr_rd_addr
add wave -noupdate -group regdecode_top -group ram_tes_pulse_shape -expand -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_tes_pulse_shape_ram_wr_data
add wave -noupdate -group regdecode_top -group ram_tes_pulse_shape -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_tes_pulse_shape_ram_rd_en
add wave -noupdate -group regdecode_top -group ram_tes_pulse_shape -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_tes_pulse_shape_ram_rd_valid
add wave -noupdate -group regdecode_top -group ram_tes_pulse_shape -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_tes_pulse_shape_ram_rd_data
add wave -noupdate -group regdecode_top -group ram_amp_squid_tf -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_amp_squid_tf_ram_wr_en
add wave -noupdate -group regdecode_top -group ram_amp_squid_tf -group wr -radix hexadecimal /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_amp_squid_tf_ram_wr_rd_addr
add wave -noupdate -group regdecode_top -group ram_amp_squid_tf -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_amp_squid_tf_ram_wr_data
add wave -noupdate -group regdecode_top -group ram_amp_squid_tf -expand -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_amp_squid_tf_ram_rd_en
add wave -noupdate -group regdecode_top -group ram_amp_squid_tf -expand -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_amp_squid_tf_ram_rd_valid
add wave -noupdate -group regdecode_top -group ram_amp_squid_tf -expand -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_amp_squid_tf_ram_rd_data
add wave -noupdate -group regdecode_top -group ram_tes_steady_state -expand -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_tes_std_state_ram_wr_en
add wave -noupdate -group regdecode_top -group ram_tes_steady_state -expand -group wr -radix hexadecimal /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_tes_std_state_ram_wr_rd_addr
add wave -noupdate -group regdecode_top -group ram_tes_steady_state -expand -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_tes_std_state_ram_wr_data
add wave -noupdate -group regdecode_top -group ram_tes_steady_state -expand -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_tes_std_state_ram_rd_en
add wave -noupdate -group regdecode_top -group ram_tes_steady_state -expand -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_tes_std_state_ram_rd_valid
add wave -noupdate -group regdecode_top -group ram_tes_steady_state -expand -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_tes_std_state_ram_rd_data
add wave -noupdate -group regdecode_top -group ram_mux_squid_offset -expand -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_mux_squid_offset_ram_wr_en
add wave -noupdate -group regdecode_top -group ram_mux_squid_offset -expand -group wr -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_mux_squid_offset_ram_wr_rd_addr
add wave -noupdate -group regdecode_top -group ram_mux_squid_offset -expand -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_mux_squid_offset_ram_wr_data
add wave -noupdate -group regdecode_top -group ram_mux_squid_offset -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_mux_squid_offset_ram_rd_en
add wave -noupdate -group regdecode_top -group ram_mux_squid_offset -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_mux_squid_offset_ram_rd_valid
add wave -noupdate -group regdecode_top -group ram_mux_squid_offset -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_mux_squid_offset_ram_rd_data
add wave -noupdate -group regdecode_top -group ram_mux_squid_tf -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_mux_squid_tf_ram_wr_en
add wave -noupdate -group regdecode_top -group ram_mux_squid_tf -group wr -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_mux_squid_tf_ram_wr_rd_addr
add wave -noupdate -group regdecode_top -group ram_mux_squid_tf -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_mux_squid_tf_ram_wr_data
add wave -noupdate -group regdecode_top -group ram_mux_squid_tf -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/o_mux_squid_tf_ram_rd_en
add wave -noupdate -group regdecode_top -group ram_mux_squid_tf -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_mux_squid_tf_ram_rd_valid
add wave -noupdate -group regdecode_top -group ram_mux_squid_tf -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/i_mux_squid_tf_ram_rd_data
add wave -noupdate -group regdecode_ctrl_reg -expand -group user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/i_clk
add wave -noupdate -group regdecode_ctrl_reg -expand -group user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/i_out_clk
add wave -noupdate -group regdecode_ctrl_reg -expand -group user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/i_rst_status
add wave -noupdate -group regdecode_ctrl_reg -expand -group user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/i_debug_pulse
add wave -noupdate -group regdecode_ctrl_reg -expand -group user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/i_data_valid
add wave -noupdate -group regdecode_ctrl_reg -expand -group user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/i_data
add wave -noupdate -group regdecode_ctrl_reg -expand -group user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/o_data_valid
add wave -noupdate -group regdecode_ctrl_reg -expand -group user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/o_data
add wave -noupdate -group regdecode_ctrl_reg -group usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/i_fifo_rd
add wave -noupdate -group regdecode_ctrl_reg -group usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/o_fifo_data_valid
add wave -noupdate -group regdecode_ctrl_reg -group usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/o_fifo_data
add wave -noupdate -group regdecode_ctrl_reg -group usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/o_fifo_empty
add wave -noupdate -group regdecode_ctrl_reg -group usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/o_errors
add wave -noupdate -group regdecode_ctrl_reg -group usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/o_status
add wave -noupdate -group regdecode_ctrl_reg -group fifo0 -expand -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/wr_rst_tmp0
add wave -noupdate -group regdecode_ctrl_reg -group fifo0 -expand -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/wr_tmp0
add wave -noupdate -group regdecode_ctrl_reg -group fifo0 -expand -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/data_tmp0
add wave -noupdate -group regdecode_ctrl_reg -group fifo0 -expand -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/rd1
add wave -noupdate -group regdecode_ctrl_reg -group fifo0 -expand -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/data_valid1
add wave -noupdate -group regdecode_ctrl_reg -group fifo0 -expand -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/data1
add wave -noupdate -group regdecode_ctrl_reg -group fifo1 -expand -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/wr_tmp2
add wave -noupdate -group regdecode_ctrl_reg -group fifo1 -expand -group wr /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/data_tmp2
add wave -noupdate -group regdecode_ctrl_reg -group fifo1 -expand -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/rd3
add wave -noupdate -group regdecode_ctrl_reg -group fifo1 -expand -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/data_valid3
add wave -noupdate -group regdecode_ctrl_reg -group fifo1 -expand -group rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_wr_rd_ctrl_register/data3
add wave -noupdate -group wire_make_pulse -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/i_rst_status
add wave -noupdate -group wire_make_pulse -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/i_debug_pulse
add wave -noupdate -group wire_make_pulse -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/i_out_clk
add wave -noupdate -group wire_make_pulse -group in -group cmd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/i_make_pulse_valid
add wave -noupdate -group wire_make_pulse -group in -group cmd -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/i_pixel_nb
add wave -noupdate -group wire_make_pulse -group in -group cmd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/i_make_pulse
add wave -noupdate -group wire_make_pulse -group in -group cmd -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/o_wr_data_count
add wave -noupdate -group wire_make_pulse -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/pixel_all_tmp
add wave -noupdate -group wire_make_pulse -group step1 -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/pixel_id_tmp
add wave -noupdate -group wire_make_pulse -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/ready_tmp0
add wave -noupdate -group wire_make_pulse -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/sm_state_r1
add wave -noupdate -group wire_make_pulse -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/sof_r1
add wave -noupdate -group wire_make_pulse -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/eof_r1
add wave -noupdate -group wire_make_pulse -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/data_valid_r1
add wave -noupdate -group wire_make_pulse -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/error_r1
add wave -noupdate -group wire_make_pulse -group step1 -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/pixel_id_r1
add wave -noupdate -group wire_make_pulse -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/pixel_id_max_r1
add wave -noupdate -group wire_make_pulse -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/data_r1
add wave -noupdate -group wire_make_pulse -expand -group out -expand -group to_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/i_data_rd
add wave -noupdate -group wire_make_pulse -expand -group out -expand -group to_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/o_sof
add wave -noupdate -group wire_make_pulse -expand -group out -expand -group to_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/o_eof
add wave -noupdate -group wire_make_pulse -expand -group out -expand -group to_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/o_data_valid
add wave -noupdate -group wire_make_pulse -expand -group out -expand -group to_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/o_data
add wave -noupdate -group wire_make_pulse -expand -group out -expand -group to_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/o_empty
add wave -noupdate -group wire_make_pulse -expand -group out -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/i_fifo_rd
add wave -noupdate -group wire_make_pulse -expand -group out -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/o_fifo_data_valid
add wave -noupdate -group wire_make_pulse -expand -group out -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/o_fifo_sof
add wave -noupdate -group wire_make_pulse -expand -group out -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/o_fifo_eof
add wave -noupdate -group wire_make_pulse -expand -group out -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/o_fifo_data
add wave -noupdate -group wire_make_pulse -expand -group out -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/o_fifo_empty
add wave -noupdate -group wire_make_pulse -expand -group out -color Magenta -itemcolor Red /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/o_errors
add wave -noupdate -group wire_make_pulse -expand -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/o_status
add wave -noupdate -expand -group tes_top /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_tes_top/i_cmd_valid
add wave -noupdate -expand -group tes_top -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_tes_top/i_cmd_pulse_height
add wave -noupdate -expand -group tes_top -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_tes_top/i_cmd_pixel_id
add wave -noupdate -expand -group tes_top /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_tes_top/i_cmd_time_shift
add wave -noupdate -expand -group tes_top -group ram_pulse_shape /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_tes_top/i_pulse_shape_wr_en
add wave -noupdate -expand -group tes_top -group ram_pulse_shape -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_tes_top/i_pulse_shape_wr_rd_addr
add wave -noupdate -expand -group tes_top -group ram_pulse_shape -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_tes_top/i_pulse_shape_wr_data
add wave -noupdate -expand -group tes_top -group ram_pulse_shape /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_tes_top/i_pulse_shape_rd_en
add wave -noupdate -expand -group tes_top -group ram_pulse_shape /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_tes_top/o_pulse_shape_rd_valid
add wave -noupdate -expand -group tes_top -group ram_pulse_shape /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_tes_top/o_pulse_shape_rd_data
add wave -noupdate -expand -group tes_top -group ram_steady_state /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_tes_top/i_steady_state_wr_en
add wave -noupdate -expand -group tes_top -group ram_steady_state /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_tes_top/i_steady_state_wr_rd_addr
add wave -noupdate -expand -group tes_top -group ram_steady_state /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_tes_top/i_steady_state_wr_data
add wave -noupdate -expand -group tes_top -group ram_steady_state /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_tes_top/i_steady_state_rd_en
add wave -noupdate -expand -group tes_top -group ram_steady_state /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_tes_top/o_steady_state_rd_valid
add wave -noupdate -expand -group tes_top -group ram_steady_state /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_tes_top/o_steady_state_rd_data
add wave -noupdate -group wire_make_pulse_wr_rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/inst_regdecode_wire_make_pulse_wr_rd/i_clk
add wave -noupdate -group wire_make_pulse_wr_rd /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/inst_regdecode_wire_make_pulse_wr_rd/i_rst
add wave -noupdate -group wire_make_pulse_wr_rd -expand -group in1 -expand -group from_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/inst_regdecode_wire_make_pulse_wr_rd/i_data_valid
add wave -noupdate -group wire_make_pulse_wr_rd -expand -group in1 -expand -group from_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/inst_regdecode_wire_make_pulse_wr_rd/i_data
add wave -noupdate -group wire_make_pulse_wr_rd -expand -group in1 -expand -group from_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/inst_regdecode_wire_make_pulse_wr_rd/o_ready
add wave -noupdate -group wire_make_pulse_wr_rd -expand -group in1 -expand -group from_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/inst_regdecode_wire_make_pulse_wr_rd/o_wr_data_count
add wave -noupdate -group wire_make_pulse_wr_rd -group out1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/inst_regdecode_wire_make_pulse_wr_rd/i_out_clk
add wave -noupdate -group wire_make_pulse_wr_rd -group out1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/inst_regdecode_wire_make_pulse_wr_rd/i_rst_status
add wave -noupdate -group wire_make_pulse_wr_rd -group out1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/inst_regdecode_wire_make_pulse_wr_rd/i_debug_pulse
add wave -noupdate -group wire_make_pulse_wr_rd -group out1 -expand -group to_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/inst_regdecode_wire_make_pulse_wr_rd/i_data_rd
add wave -noupdate -group wire_make_pulse_wr_rd -group out1 -expand -group to_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/inst_regdecode_wire_make_pulse_wr_rd/o_data_valid
add wave -noupdate -group wire_make_pulse_wr_rd -group out1 -expand -group to_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/inst_regdecode_wire_make_pulse_wr_rd/o_data
add wave -noupdate -group wire_make_pulse_wr_rd -group out1 -expand -group to_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/inst_regdecode_wire_make_pulse_wr_rd/o_empty
add wave -noupdate -group wire_make_pulse_wr_rd -group out1 -expand -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/inst_regdecode_wire_make_pulse_wr_rd/i_fifo_rd
add wave -noupdate -group wire_make_pulse_wr_rd -group out1 -expand -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/inst_regdecode_wire_make_pulse_wr_rd/o_fifo_data_valid
add wave -noupdate -group wire_make_pulse_wr_rd -group out1 -expand -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/inst_regdecode_wire_make_pulse_wr_rd/o_fifo_data
add wave -noupdate -group wire_make_pulse_wr_rd -group out1 -expand -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/inst_regdecode_wire_make_pulse_wr_rd/o_fifo_empty
add wave -noupdate -group wire_make_pulse_wr_rd -group out1 -group errors_status -color Magenta -itemcolor Red /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/inst_regdecode_wire_make_pulse_wr_rd/o_errors
add wave -noupdate -group wire_make_pulse_wr_rd -group out1 -group errors_status /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_wire_make_pulse/inst_regdecode_wire_make_pulse_wr_rd/o_status
add wave -noupdate -group regdecode_pipe -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/i_start_auto_rd
add wave -noupdate -group regdecode_pipe -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/i_data_valid
add wave -noupdate -group regdecode_pipe -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/i_addr
add wave -noupdate -group regdecode_pipe -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/i_data
add wave -noupdate -group regdecode_pipe -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/i_fifo_rd
add wave -noupdate -group regdecode_pipe -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/o_fifo_sof
add wave -noupdate -group regdecode_pipe -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/o_fifo_eof
add wave -noupdate -group regdecode_pipe -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/o_fifo_data_valid
add wave -noupdate -group regdecode_pipe -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/o_fifo_addr
add wave -noupdate -group regdecode_pipe -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/o_fifo_data
add wave -noupdate -group regdecode_pipe -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/o_fifo_empty
add wave -noupdate -group regdecode_pipe -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/o_fifo_data_count
add wave -noupdate -divider {New Divider}
add wave -noupdate -group regdecode_pipe_addr_decode -expand -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_addr_decode/i_data_valid
add wave -noupdate -group regdecode_pipe_addr_decode -expand -group in -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_addr_decode/i_addr
add wave -noupdate -group regdecode_pipe_addr_decode -expand -group in -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_addr_decode/i_data
add wave -noupdate -group regdecode_pipe_addr_decode -expand -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_addr_decode/o_tes_pulse_shape_wr_en
add wave -noupdate -group regdecode_pipe_addr_decode -expand -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_addr_decode/o_amp_squid_tf_wr_en
add wave -noupdate -group regdecode_pipe_addr_decode -expand -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_addr_decode/o_mux_squid_tf_wr_en
add wave -noupdate -group regdecode_pipe_addr_decode -expand -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_addr_decode/o_tes_std_state_wr_en
add wave -noupdate -group regdecode_pipe_addr_decode -expand -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_addr_decode/o_mux_squid_offset_wr_en
add wave -noupdate -group regdecode_pipe_addr_decode -expand -group out -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_addr_decode/o_addr
add wave -noupdate -group regdecode_pipe_addr_decode -expand -group out -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_addr_decode/o_data
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group generic -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/g_RAM_NB_WORDS
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group generic /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/g_RAM_RD_LATENCY
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group generic /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/g_ADDR_WIDTH
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group generic /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/g_DATA_WIDTH
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/i_clk
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/i_rst
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/i_start_auto_rd
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/i_addr_range_min
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/i_data_valid
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group in -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/i_addr
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group in -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/i_data
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/sm_state_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/sof_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/eof_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/sel_wr_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/data_valid_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group step1 -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/cnt_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group step1 -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/addr_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/error_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/data_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/i_out_clk
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/i_rst_status
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/i_debug_pulse
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group out -expand -group to_from_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/o_ram_wr_en
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group out -expand -group to_from_user -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/o_ram_wr_rd_addr
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group out -expand -group to_from_user -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/o_ram_wr_data
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group out -expand -group to_from_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/o_ram_rd_en
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group out -expand -group to_from_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/i_ram_rd_valid
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group out -expand -group to_from_user -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/i_ram_rd_data
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group out -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/i_fifo_rd
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group out -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/o_fifo_sof
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group out -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/o_fifo_eof
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group out -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/o_fifo_data_valid
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group out -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/o_fifo_addr
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group out -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/o_fifo_data
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group out -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/o_fifo_empty
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group out -group error_status -color Magenta -itemcolor Red /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/o_errors
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_pulse_shape -group out -group error_status /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_pulse_shape/o_status
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group generic -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/g_RAM_NB_WORDS
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group generic /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/g_RAM_RD_LATENCY
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group generic /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/g_ADDR_WIDTH
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group generic /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/g_DATA_WIDTH
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/i_clk
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/i_rst
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/i_start_auto_rd
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/i_addr_range_min
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/i_data_valid
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/i_addr
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/i_data
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/sm_state_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/sof_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/eof_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/sel_wr_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/data_valid_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/cnt_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/addr_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/error_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/data_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/i_out_clk
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/i_rst_status
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/i_debug_pulse
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group out -group to_from_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/o_ram_wr_en
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group out -group to_from_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/o_ram_wr_rd_addr
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group out -group to_from_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/o_ram_wr_data
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group out -group to_from_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/o_ram_rd_en
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group out -group to_from_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/i_ram_rd_valid
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group out -group to_from_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/i_ram_rd_data
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group out -expand -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/i_fifo_rd
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group out -expand -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/o_fifo_sof
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group out -expand -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/o_fifo_eof
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group out -expand -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/o_fifo_data_valid
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group out -expand -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/o_fifo_addr
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group out -expand -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/o_fifo_data
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group out -expand -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/o_fifo_empty
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group out -expand -group error_status -color Magenta -itemcolor Red /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/o_errors
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_amp_squid_tf -group out -expand -group error_status /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_amp_squid_tf/o_status
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group generic -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/g_RAM_NB_WORDS
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group generic /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/g_RAM_RD_LATENCY
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group generic /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/g_ADDR_WIDTH
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group generic /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/g_DATA_WIDTH
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/i_clk
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/i_rst
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/i_start_auto_rd
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/i_addr_range_min
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/i_data_valid
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/i_addr
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/i_data
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/sm_state_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/sof_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/eof_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/sel_wr_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/data_valid_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group step1 -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/cnt_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/addr_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/error_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/i_out_clk
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/i_rst_status
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/i_debug_pulse
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group out -expand -group to_from_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/o_ram_wr_en
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group out -expand -group to_from_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/o_ram_wr_rd_addr
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group out -expand -group to_from_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/o_ram_wr_data
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group out -expand -group to_from_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/o_ram_rd_en
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group out -expand -group to_from_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/i_ram_rd_valid
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group out -expand -group to_from_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/i_ram_rd_data
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group out -expand -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/i_fifo_rd
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group out -expand -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/o_fifo_sof
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group out -expand -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/o_fifo_eof
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group out -expand -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/o_fifo_data_valid
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group out -expand -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/o_fifo_addr
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group out -expand -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/o_fifo_data
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group out -expand -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/o_fifo_empty
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group out -expand -group errors_status -color Magenta -itemcolor Red /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/o_errors
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_tf -group out -expand -group errors_status /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_tf/o_status
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group generic -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/g_RAM_NB_WORDS
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group generic /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/g_RAM_RD_LATENCY
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group generic /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/g_ADDR_WIDTH
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group generic /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/g_DATA_WIDTH
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/i_clk
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/i_rst
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/i_start_auto_rd
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/i_addr_range_min
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/i_data_valid
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/i_addr
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/i_data
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/sm_state_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/sof_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/eof_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/sel_wr_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/data_valid_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/cnt_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/addr_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/i_out_clk
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/i_rst_status
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/i_debug_pulse
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group out -expand -group from_to_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/o_ram_wr_en
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group out -expand -group from_to_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/o_ram_wr_rd_addr
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group out -expand -group from_to_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/o_ram_wr_data
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group out -expand -group from_to_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/o_ram_rd_en
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group out -expand -group from_to_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/i_ram_rd_valid
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group out -expand -group from_to_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/i_ram_rd_data
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group out -expand -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/i_fifo_rd
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group out -expand -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/o_fifo_sof
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group out -expand -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/o_fifo_eof
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group out -expand -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/o_fifo_data_valid
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group out -expand -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/o_fifo_addr
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group out -expand -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/o_fifo_data
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group out -expand -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/o_fifo_empty
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group out -expand -group error_status -color Magenta -itemcolor Red /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/o_errors
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_tes_steady_state -group out -expand -group error_status /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_tes_std_state/o_status
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group generic -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/g_RAM_NB_WORDS
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group generic /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/g_RAM_RD_LATENCY
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group generic /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/g_ADDR_WIDTH
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group generic /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/g_DATA_WIDTH
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/i_clk
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/i_rst
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/i_start_auto_rd
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/i_addr_range_min
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/i_data_valid
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/i_addr
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/i_data
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/sm_state_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/sof_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/eof_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/sel_wr_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/data_valid_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/cnt_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/addr_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/error_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/data_r1
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/i_out_clk
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/i_rst_status
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/i_debug_pulse
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group out -group to_from_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/o_ram_wr_en
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group out -group to_from_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/o_ram_wr_rd_addr
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group out -group to_from_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/o_ram_wr_data
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group out -group to_from_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/o_ram_rd_en
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group out -group to_from_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/i_ram_rd_valid
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group out -group to_from_user /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/i_ram_rd_data
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group out -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/i_fifo_rd
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group out -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/o_fifo_sof
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group out -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/o_fifo_eof
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group out -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/o_fifo_data_valid
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group out -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/o_fifo_addr
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group out -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/o_fifo_data
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group out -group to_usb /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/o_fifo_empty
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group out -expand -group errors_status -color Magenta -itemcolor Red /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/o_errors
add wave -noupdate -group regdecode_pipe_wr_rd_ram_mng_mux_squid_offset -group out -expand -group errors_status /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_wr_rd_ram_manager_mux_squid_offset/o_status
add wave -noupdate -group regdecode_pipe_rd_all /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_clk
add wave -noupdate -group regdecode_pipe_rd_all /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_rst
add wave -noupdate -group regdecode_pipe_rd_all -expand -group in0 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/o_fifo_rd0
add wave -noupdate -group regdecode_pipe_rd_all -expand -group in0 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_sof0
add wave -noupdate -group regdecode_pipe_rd_all -expand -group in0 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_eof0
add wave -noupdate -group regdecode_pipe_rd_all -expand -group in0 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_data_valid0
add wave -noupdate -group regdecode_pipe_rd_all -expand -group in0 -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_addr0
add wave -noupdate -group regdecode_pipe_rd_all -expand -group in0 -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_data0
add wave -noupdate -group regdecode_pipe_rd_all -expand -group in0 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_empty0
add wave -noupdate -group regdecode_pipe_rd_all -expand -group in1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/o_fifo_rd1
add wave -noupdate -group regdecode_pipe_rd_all -expand -group in1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_sof1
add wave -noupdate -group regdecode_pipe_rd_all -expand -group in1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_eof1
add wave -noupdate -group regdecode_pipe_rd_all -expand -group in1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_data_valid1
add wave -noupdate -group regdecode_pipe_rd_all -expand -group in1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_addr1
add wave -noupdate -group regdecode_pipe_rd_all -expand -group in1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_data1
add wave -noupdate -group regdecode_pipe_rd_all -expand -group in1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_empty1
add wave -noupdate -group regdecode_pipe_rd_all -group in2 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/o_fifo_rd2
add wave -noupdate -group regdecode_pipe_rd_all -group in2 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_sof2
add wave -noupdate -group regdecode_pipe_rd_all -group in2 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_eof2
add wave -noupdate -group regdecode_pipe_rd_all -group in2 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_data_valid2
add wave -noupdate -group regdecode_pipe_rd_all -group in2 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_addr2
add wave -noupdate -group regdecode_pipe_rd_all -group in2 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_data2
add wave -noupdate -group regdecode_pipe_rd_all -group in2 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_empty2
add wave -noupdate -group regdecode_pipe_rd_all -group in3 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/o_fifo_rd3
add wave -noupdate -group regdecode_pipe_rd_all -group in3 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_sof3
add wave -noupdate -group regdecode_pipe_rd_all -group in3 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_eof3
add wave -noupdate -group regdecode_pipe_rd_all -group in3 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_data_valid3
add wave -noupdate -group regdecode_pipe_rd_all -group in3 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_addr3
add wave -noupdate -group regdecode_pipe_rd_all -group in3 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_data3
add wave -noupdate -group regdecode_pipe_rd_all -group in3 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_empty3
add wave -noupdate -group regdecode_pipe_rd_all -group in4 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/o_fifo_rd4
add wave -noupdate -group regdecode_pipe_rd_all -group in4 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_sof4
add wave -noupdate -group regdecode_pipe_rd_all -group in4 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_eof4
add wave -noupdate -group regdecode_pipe_rd_all -group in4 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_data_valid4
add wave -noupdate -group regdecode_pipe_rd_all -group in4 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_addr4
add wave -noupdate -group regdecode_pipe_rd_all -group in4 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_data4
add wave -noupdate -group regdecode_pipe_rd_all -group in4 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_empty4
add wave -noupdate -group regdecode_pipe_rd_all -expand -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/sm_state_r1
add wave -noupdate -group regdecode_pipe_rd_all -expand -group step1 /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/sel_r1
add wave -noupdate -group regdecode_pipe_rd_all -expand -group stepx /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/sof_rx
add wave -noupdate -group regdecode_pipe_rd_all -expand -group stepx /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/eof_rx
add wave -noupdate -group regdecode_pipe_rd_all -expand -group stepx /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/data_valid_rx
add wave -noupdate -group regdecode_pipe_rd_all -expand -group stepx /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/addr_rx
add wave -noupdate -group regdecode_pipe_rd_all -expand -group stepx /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/data_rx
add wave -noupdate -group regdecode_pipe_rd_all -expand -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_fifo_rd
add wave -noupdate -group regdecode_pipe_rd_all -expand -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/o_fifo_sof
add wave -noupdate -group regdecode_pipe_rd_all -expand -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/o_fifo_eof
add wave -noupdate -group regdecode_pipe_rd_all -expand -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/o_fifo_data_valid
add wave -noupdate -group regdecode_pipe_rd_all -expand -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/o_fifo_addr
add wave -noupdate -group regdecode_pipe_rd_all -expand -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/o_fifo_data
add wave -noupdate -group regdecode_pipe_rd_all -expand -group out -radix unsigned /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/o_fifo_data_count
add wave -noupdate -group regdecode_pipe_rd_all -expand -group out /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/o_fifo_empty
add wave -noupdate -group regdecode_pipe_rd_all -expand -group error_status /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_out_clk
add wave -noupdate -group regdecode_pipe_rd_all -expand -group error_status /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_rst_status
add wave -noupdate -group regdecode_pipe_rd_all -expand -group error_status /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/i_debug_pulse
add wave -noupdate -group regdecode_pipe_rd_all -expand -group error_status -color Magenta -itemcolor Red /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/o_errors
add wave -noupdate -group regdecode_pipe_rd_all -expand -group error_status /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_regdecode_top/inst_regdecode_pipe/inst_regdecode_pipe_rd_all/o_status
add wave -noupdate -group mux_squid_top -group generic /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/g_PIXEL_ID_WIDTH
add wave -noupdate -group mux_squid_top -group generic /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/g_FRAME_ID_WIDTH
add wave -noupdate -group mux_squid_top -group generic /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/g_MUX_SQUID_TF_RAM_ADDR_WIDTH
add wave -noupdate -group mux_squid_top -group generic /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/g_PIXEL_RESULT_INPUT_WIDTH
add wave -noupdate -group mux_squid_top -group generic /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/g_PIXEL_RESULT_OUTPUT_WIDTH
add wave -noupdate -group mux_squid_top -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/i_clk
add wave -noupdate -group mux_squid_top -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/i_rst_status
add wave -noupdate -group mux_squid_top -group in /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/i_debug_pulse
add wave -noupdate -group mux_squid_top -group in -group ram_mux_squid_offset /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/i_mux_squid_offset_wr_en
add wave -noupdate -group mux_squid_top -group in -group ram_mux_squid_offset /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/i_mux_squid_offset_wr_rd_addr
add wave -noupdate -group mux_squid_top -group in -group ram_mux_squid_offset /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/i_mux_squid_offset_wr_data
add wave -noupdate -group mux_squid_top -group in -group ram_mux_squid_offset /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/i_mux_squid_offset_rd_en
add wave -noupdate -group mux_squid_top -group in -group ram_mux_squid_offset /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/o_mux_squid_offset_rd_valid
add wave -noupdate -group mux_squid_top -group in -group ram_mux_squid_offset /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/o_mux_squid_offset_rd_data
add wave -noupdate -group mux_squid_top -group in -group ram_mux_squid_tf /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/i_mux_squid_tf_wr_en
add wave -noupdate -group mux_squid_top -group in -group ram_mux_squid_tf /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/i_mux_squid_tf_wr_rd_addr
add wave -noupdate -group mux_squid_top -group in -group ram_mux_squid_tf /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/i_mux_squid_tf_wr_data
add wave -noupdate -group mux_squid_top -group in -group ram_mux_squid_tf /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/i_mux_squid_tf_rd_en
add wave -noupdate -group mux_squid_top -group in -group ram_mux_squid_tf /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/o_mux_squid_tf_rd_valid
add wave -noupdate -group mux_squid_top -group in -group ram_mux_squid_tf /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/o_mux_squid_tf_rd_data
add wave -noupdate -group mux_squid_top -group in -group data /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/i_pixel_sof
add wave -noupdate -group mux_squid_top -group in -group data /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/i_pixel_eof
add wave -noupdate -group mux_squid_top -group in -group data /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/i_pixel_valid
add wave -noupdate -group mux_squid_top -group in -group data /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/i_pixel_id
add wave -noupdate -group mux_squid_top -group in -group data /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/i_pixel_result
add wave -noupdate -group mux_squid_top -group in -group data /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/i_frame_sof
add wave -noupdate -group mux_squid_top -group in -group data /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/i_frame_eof
add wave -noupdate -group mux_squid_top -group in -group data /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/i_frame_id
add wave -noupdate -group mux_squid_top -group in -group data /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/i_mux_squid_feedback
add wave -noupdate -group mux_squid_top -group output /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/o_pixel_sof
add wave -noupdate -group mux_squid_top -group output /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/o_pixel_eof
add wave -noupdate -group mux_squid_top -group output /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/o_pixel_valid
add wave -noupdate -group mux_squid_top -group output /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/o_pixel_id
add wave -noupdate -group mux_squid_top -group output /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/o_pixel_result
add wave -noupdate -group mux_squid_top -group output /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/o_frame_sof
add wave -noupdate -group mux_squid_top -group output /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/o_frame_eof
add wave -noupdate -group mux_squid_top -group output /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/o_frame_id
add wave -noupdate -group mux_squid_top -group output -group errors_status -color Magenta -itemcolor Red /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/o_errors
add wave -noupdate -group mux_squid_top -group output -group errors_status /tb_system_fpasim_top/dut_top_fpasim_system/inst_top_fpasim/inst_mux_squid_top/o_status
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5597529467 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 352
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
WaveRestoreZoom {5647009996 ps} {5647150716 ps}
