onerror {resume}
quietly virtual signal -install /tb_system_fpasim_top { /tb_system_fpasim_top/o_data(31 downto 16)} o_data_addr
quietly virtual signal -install /tb_system_fpasim_top { /tb_system_fpasim_top/o_data(15 downto 0)} o_data_data
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider reg_decode
add wave -noupdate -expand -group usb_opal_kelly -group trig_in /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/o_usb_trigin_data
add wave -noupdate -expand -group usb_opal_kelly -group wirein /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/o_usb_wirein_ctrl
add wave -noupdate -expand -group usb_opal_kelly -group wirein /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/o_usb_wirein_make_pulse
add wave -noupdate -expand -group usb_opal_kelly -group wirein /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/o_usb_wirein_mux_sq_fb_delay
add wave -noupdate -expand -group usb_opal_kelly -group wirein /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/o_usb_wirein_amp_sq_of_delay
add wave -noupdate -expand -group usb_opal_kelly -group wirein /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/o_usb_wirein_error_delay
add wave -noupdate -expand -group usb_opal_kelly -group wirein /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/o_usb_wirein_ra_delay
add wave -noupdate -expand -group usb_opal_kelly -group wirein /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/o_usb_wirein_tes_conf
add wave -noupdate -expand -group usb_opal_kelly -group wirein /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/o_usb_wirein_rec_ctrl
add wave -noupdate -expand -group usb_opal_kelly -group wirein /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/o_usb_wirein_rec_conf0
add wave -noupdate -expand -group usb_opal_kelly -group wirein /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/o_usb_wirein_spi_ctrl
add wave -noupdate -expand -group usb_opal_kelly -group wirein /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/o_usb_wirein_spi_conf0
add wave -noupdate -expand -group usb_opal_kelly -group wirein /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/o_usb_wirein_spi_conf1
add wave -noupdate -expand -group usb_opal_kelly -group wirein /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/o_usb_wirein_spi_wr_data
add wave -noupdate -expand -group usb_opal_kelly -group wirein /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/o_usb_wirein_debug_ctrl
add wave -noupdate -expand -group usb_opal_kelly -group wirein /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/o_usb_wirein_sel_errors
add wave -noupdate -expand -group usb_opal_kelly -group wireout /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/i_usb_wireout_ctrl
add wave -noupdate -expand -group usb_opal_kelly -group wireout /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/i_usb_wireout_make_pulse
add wave -noupdate -expand -group usb_opal_kelly -group wireout /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/i_usb_wireout_mux_sq_fb_delay
add wave -noupdate -expand -group usb_opal_kelly -group wireout /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/i_usb_wireout_amp_sq_of_delay
add wave -noupdate -expand -group usb_opal_kelly -group wireout /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/i_usb_wireout_error_delay
add wave -noupdate -expand -group usb_opal_kelly -group wireout /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/i_usb_wireout_ra_delay
add wave -noupdate -expand -group usb_opal_kelly -group wireout /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/i_usb_wireout_tes_conf
add wave -noupdate -expand -group usb_opal_kelly -group wireout /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/i_usb_wireout_fpasim_status
add wave -noupdate -expand -group usb_opal_kelly -group wireout /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/i_usb_wireout_debug_ctrl
add wave -noupdate -expand -group usb_opal_kelly -group wireout /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/i_usb_wireout_firmware_name
add wave -noupdate -expand -group usb_opal_kelly -group wireout /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/i_usb_wireout_firmware_id
add wave -noupdate -expand -group usb_opal_kelly -group wireout /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/i_usb_wireout_hardware_id
add wave -noupdate -expand -group usb_opal_kelly -group wireout /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/i_usb_wireout_rec_ctrl
add wave -noupdate -expand -group usb_opal_kelly -group wireout /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/i_usb_wireout_rec_conf0
add wave -noupdate -expand -group usb_opal_kelly -group wireout /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/i_usb_wireout_spi_ctrl
add wave -noupdate -expand -group usb_opal_kelly -group wireout /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/i_usb_wireout_spi_conf0
add wave -noupdate -expand -group usb_opal_kelly -group wireout /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/i_usb_wireout_spi_conf1
add wave -noupdate -expand -group usb_opal_kelly -group wireout /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/i_usb_wireout_spi_wr_data
add wave -noupdate -expand -group usb_opal_kelly -group wireout /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/i_usb_wireout_spi_rd_data
add wave -noupdate -expand -group usb_opal_kelly -group wireout /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/i_usb_wireout_spi_status
add wave -noupdate -expand -group usb_opal_kelly -group wireout /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/i_usb_wireout_sel_errors
add wave -noupdate -expand -group usb_opal_kelly -group wireout /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/i_usb_wireout_errors
add wave -noupdate -expand -group usb_opal_kelly -group wireout /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/i_usb_wireout_status
add wave -noupdate -expand -group usb_opal_kelly -group trig_out /tb_system_fpasim_top/inst_system_fpasim_top/inst_fpasim_top/inst_regdecode_top/inst_usb_opal_kelly/i_usb_trigout_data
add wave -noupdate -divider spi
add wave -noupdate -expand -group spi_device_select /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/i_clk
add wave -noupdate -expand -group spi_device_select /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/i_rst
add wave -noupdate -expand -group spi_device_select /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/i_rst_status
add wave -noupdate -expand -group spi_device_select /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/i_debug_pulse
add wave -noupdate -expand -group spi_device_select -group cmd /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/i_spi_en
add wave -noupdate -expand -group spi_device_select -group cmd /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/i_spi_dac_tx_present
add wave -noupdate -expand -group spi_device_select -group cmd /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/i_spi_mode
add wave -noupdate -expand -group spi_device_select -group cmd /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/i_spi_id
add wave -noupdate -expand -group spi_device_select -group cmd /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/i_spi_cmd_valid
add wave -noupdate -expand -group spi_device_select -group cmd /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/i_spi_cmd_wr_data
add wave -noupdate -expand -group spi_device_select -group rd /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/o_spi_rd_data_valid
add wave -noupdate -expand -group spi_device_select -group rd /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/o_spi_rd_data
add wave -noupdate -expand -group spi_device_select -group errors_status /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/o_spi_ready
add wave -noupdate -expand -group spi_device_select -group errors_status /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/o_reg_spi_status
add wave -noupdate -expand -group spi_device_select -group errors_status /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/o_errors
add wave -noupdate -expand -group spi_device_select -group errors_status /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/o_status
add wave -noupdate -expand -group spi_device_select -group step1 /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/sm_state_r1
add wave -noupdate -expand -group spi_device_select -group step1 /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/cdce_data_valid_r1
add wave -noupdate -expand -group spi_device_select -group step1 /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/adc_data_valid_r1
add wave -noupdate -expand -group spi_device_select -group step1 /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/dac_data_valid_r1
add wave -noupdate -expand -group spi_device_select -group step1 /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/amc_data_valid_r1
add wave -noupdate -expand -group spi_device_select -group spi /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/o_spi_sclk
add wave -noupdate -expand -group spi_device_select -group spi /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/o_spi_sdata
add wave -noupdate -expand -group spi_device_select -group spi -group cdce /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/i_cdce_sdo
add wave -noupdate -expand -group spi_device_select -group spi -group cdce /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/o_cdce_n_en
add wave -noupdate -expand -group spi_device_select -group spi -group cdce /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/i_cdce_pll_status
add wave -noupdate -expand -group spi_device_select -group spi -group cdce /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/o_cdce_n_reset
add wave -noupdate -expand -group spi_device_select -group spi -group cdce /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/o_cdce_n_pd
add wave -noupdate -expand -group spi_device_select -group spi -group cdce /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/o_ref_en
add wave -noupdate -expand -group spi_device_select -group spi -group adc /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/i_adc_sdo
add wave -noupdate -expand -group spi_device_select -group spi -group adc /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/o_adc_n_en
add wave -noupdate -expand -group spi_device_select -group spi -group adc /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/o_adc_reset
add wave -noupdate -expand -group spi_device_select -group spi -expand -group dac /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/o_dac_n_en
add wave -noupdate -expand -group spi_device_select -group spi -expand -group dac /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/o_dac_tx_present
add wave -noupdate -expand -group spi_device_select -group spi -expand -group dac /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/i_dac_sdo
add wave -noupdate -expand -group spi_device_select -group spi -group amc /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/i_mon_sdo
add wave -noupdate -expand -group spi_device_select -group spi -group amc /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/o_mon_n_en
add wave -noupdate -expand -group spi_device_select -group spi -group amc /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/i_mon_n_int
add wave -noupdate -expand -group spi_device_select -group spi -group amc /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/o_mon_n_reset
add wave -noupdate -expand -group spi_dac_master /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/i_clk
add wave -noupdate -expand -group spi_dac_master /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/i_rst
add wave -noupdate -expand -group spi_dac_master -group in /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/i_wr_rd
add wave -noupdate -expand -group spi_dac_master -group in /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/i_tx_msb_first
add wave -noupdate -expand -group spi_dac_master -group in /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/i_tx_data_valid
add wave -noupdate -expand -group spi_dac_master -group in /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/i_tx_data
add wave -noupdate -expand -group spi_dac_master -group inst_master_clock_gen /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/inst_spi_master_clock_gen/i_clk
add wave -noupdate -expand -group spi_dac_master -group inst_master_clock_gen /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/inst_spi_master_clock_gen/i_rst
add wave -noupdate -expand -group spi_dac_master -group inst_master_clock_gen /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/inst_spi_master_clock_gen/o_sclk
add wave -noupdate -expand -group spi_dac_master -group inst_master_clock_gen /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/inst_spi_master_clock_gen/o_pulse_data_sample
add wave -noupdate -expand -group spi_dac_master -group inst_master_clock_gen /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/inst_spi_master_clock_gen/o_pulse_data_shift
add wave -noupdate -expand -group spi_dac_master -group inst_master_clock_gen /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/inst_spi_master_clock_gen/g_SYSTEM_FREQUENCY_HZ
add wave -noupdate -expand -group spi_dac_master -group inst_master_clock_gen /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/inst_spi_master_clock_gen/g_SPI_FREQUENCY_MAX_HZ
add wave -noupdate -expand -group spi_dac_master -group inst_master_clock_gen /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/inst_spi_master_clock_gen/sclk_r0
add wave -noupdate -expand -group spi_dac_master -group inst_master_clock_gen /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/inst_spi_master_clock_gen/cnt_r0
add wave -noupdate -expand -group spi_dac_master -group step1 /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/sm_wr_state_r1
add wave -noupdate -expand -group spi_dac_master -group step1 /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/tx_sclk_r1
add wave -noupdate -expand -group spi_dac_master -group step1 /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/tx_cs_n_r1
add wave -noupdate -expand -group spi_dac_master -group step1 /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/tx_data_valid_r1
add wave -noupdate -expand -group spi_dac_master -group step1 /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/tx_data_r1
add wave -noupdate -expand -group spi_dac_master -group step1 /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/ready_r1
add wave -noupdate -expand -group spi_dac_master -group step1 /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/finish_r1
add wave -noupdate -expand -group spi_dac_master -group step1 /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/tx_cnt_bit_r1
add wave -noupdate -expand -group spi_dac_master -group step1 /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/rx_data_valid_r1
add wave -noupdate -expand -group spi_dac_master -group step1 /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/rx_rd_en_r1
add wave -noupdate -expand -group spi_dac_master -group step1 /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/rd_en_r1
add wave -noupdate -expand -group spi_dac_master -group out /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/o_finish
add wave -noupdate -expand -group spi_dac_master -group out /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/o_ready
add wave -noupdate -expand -group spi_dac_master -group out /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/o_rx_data_valid
add wave -noupdate -expand -group spi_dac_master -group out /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/o_rx_data
add wave -noupdate -expand -group spi_dac_master -group out /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/i_miso
add wave -noupdate -expand -group spi_dac_master -group out /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/o_sclk
add wave -noupdate -expand -group spi_dac_master -group out /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/o_cs_n
add wave -noupdate -expand -group spi_dac_master -group out /tb_system_fpasim_top/inst_system_fpasim_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/o_mosi
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7902606 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 342
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
WaveRestoreZoom {0 ps} {25493504 ps}
