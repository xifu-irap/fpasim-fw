onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group spi_top /tb_spi_top/inst_spi_top/i_clk
add wave -noupdate -group spi_top /tb_spi_top/inst_spi_top/i_rst
add wave -noupdate -group spi_top /tb_spi_top/inst_spi_top/i_rst_status
add wave -noupdate -group spi_top /tb_spi_top/inst_spi_top/i_debug_pulse
add wave -noupdate -group spi_top -group cmd /tb_spi_top/inst_spi_top/i_spi_en
add wave -noupdate -group spi_top -group cmd /tb_spi_top/inst_spi_top/i_spi_dac_tx_present
add wave -noupdate -group spi_top -group cmd -expand -group wr /tb_spi_top/inst_spi_top/i_spi_mode
add wave -noupdate -group spi_top -group cmd -expand -group wr /tb_spi_top/inst_spi_top/i_spi_id
add wave -noupdate -group spi_top -group cmd -expand -group wr /tb_spi_top/inst_spi_top/i_spi_cmd_valid
add wave -noupdate -group spi_top -group cmd -expand -group wr /tb_spi_top/inst_spi_top/i_spi_cmd_wr_data
add wave -noupdate -group spi_top -group cmd -expand -group rd /tb_spi_top/inst_spi_top/o_spi_rd_data_valid
add wave -noupdate -group spi_top -group cmd -expand -group rd /tb_spi_top/inst_spi_top/o_spi_rd_data
add wave -noupdate -group spi_top -group cmd /tb_spi_top/inst_spi_top/o_spi_ready
add wave -noupdate -group spi_top -group error_status /tb_spi_top/inst_spi_top/o_reg_spi_status
add wave -noupdate -group spi_top -group error_status -color Magenta /tb_spi_top/inst_spi_top/o_errors
add wave -noupdate -group spi_top -group error_status /tb_spi_top/inst_spi_top/o_status
add wave -noupdate -group spi_top -group spi_link -group common /tb_spi_top/inst_spi_top/o_spi_sdata
add wave -noupdate -group spi_top -group spi_link -group common /tb_spi_top/inst_spi_top/o_spi_sclk
add wave -noupdate -group spi_top -group spi_link -group cdcde /tb_spi_top/inst_spi_top/i_cdce_sdo
add wave -noupdate -group spi_top -group spi_link -group cdcde /tb_spi_top/inst_spi_top/o_cdce_n_en
add wave -noupdate -group spi_top -group spi_link -group cdcde /tb_spi_top/inst_spi_top/i_cdce_pll_status
add wave -noupdate -group spi_top -group spi_link -group cdcde /tb_spi_top/inst_spi_top/o_cdce_n_reset
add wave -noupdate -group spi_top -group spi_link -group cdcde /tb_spi_top/inst_spi_top/o_cdce_n_pd
add wave -noupdate -group spi_top -group spi_link -group cdcde /tb_spi_top/inst_spi_top/o_ref_en
add wave -noupdate -group spi_top -group spi_link -group adc /tb_spi_top/inst_spi_top/i_adc_sdo
add wave -noupdate -group spi_top -group spi_link -group adc /tb_spi_top/inst_spi_top/o_adc_n_en
add wave -noupdate -group spi_top -group spi_link -group adc /tb_spi_top/inst_spi_top/o_adc_reset
add wave -noupdate -group spi_top -group spi_link -group adc /tb_spi_top/inst_spi_top/i_dac_sdo
add wave -noupdate -group spi_top -group spi_link -group dac /tb_spi_top/inst_spi_top/o_dac_n_en
add wave -noupdate -group spi_top -group spi_link -group dac /tb_spi_top/inst_spi_top/o_dac_tx_present
add wave -noupdate -group spi_top -group spi_link -group mon /tb_spi_top/inst_spi_top/i_mon_sdo
add wave -noupdate -group spi_top -group spi_link -group mon /tb_spi_top/inst_spi_top/o_mon_n_en
add wave -noupdate -group spi_top -group spi_link -group mon /tb_spi_top/inst_spi_top/i_mon_n_int
add wave -noupdate -group spi_top -group spi_link -group mon /tb_spi_top/inst_spi_top/o_mon_n_reset
add wave -noupdate -group spi_select /tb_spi_top/inst_spi_top/inst_spi_device_select/i_clk
add wave -noupdate -group spi_select /tb_spi_top/inst_spi_top/inst_spi_device_select/i_rst
add wave -noupdate -group spi_select /tb_spi_top/inst_spi_top/inst_spi_device_select/i_rst_status
add wave -noupdate -group spi_select /tb_spi_top/inst_spi_top/inst_spi_device_select/i_debug_pulse
add wave -noupdate -group spi_select -group cmd /tb_spi_top/inst_spi_top/inst_spi_device_select/i_spi_en
add wave -noupdate -group spi_select -group cmd /tb_spi_top/inst_spi_top/inst_spi_device_select/i_spi_dac_tx_present
add wave -noupdate -group spi_select -group cmd -group wr /tb_spi_top/inst_spi_top/inst_spi_device_select/i_spi_mode
add wave -noupdate -group spi_select -group cmd -group wr /tb_spi_top/inst_spi_top/inst_spi_device_select/i_spi_id
add wave -noupdate -group spi_select -group cmd -group wr /tb_spi_top/inst_spi_top/inst_spi_device_select/i_spi_cmd_valid
add wave -noupdate -group spi_select -group cmd -group wr /tb_spi_top/inst_spi_top/inst_spi_device_select/i_spi_cmd_wr_data
add wave -noupdate -group spi_select -group cmd -expand -group rd /tb_spi_top/inst_spi_top/inst_spi_device_select/o_spi_rd_data_valid
add wave -noupdate -group spi_select -group cmd -expand -group rd /tb_spi_top/inst_spi_top/inst_spi_device_select/o_spi_rd_data
add wave -noupdate -group spi_select -group cmd /tb_spi_top/inst_spi_top/inst_spi_device_select/o_spi_ready
add wave -noupdate -group spi_select -group error_status /tb_spi_top/inst_spi_top/inst_spi_device_select/o_reg_spi_status
add wave -noupdate -group spi_select -group error_status -color Magenta /tb_spi_top/inst_spi_top/inst_spi_device_select/o_errors
add wave -noupdate -group spi_select -group error_status /tb_spi_top/inst_spi_top/inst_spi_device_select/o_status
add wave -noupdate -group spi_select -group step1 /tb_spi_top/inst_spi_top/inst_spi_device_select/sm_state_r1
add wave -noupdate -group spi_select -group spi_link -group common -color Cyan /tb_spi_top/inst_spi_top/inst_spi_device_select/o_spi_sclk
add wave -noupdate -group spi_select -group spi_link -group common -color Cyan /tb_spi_top/inst_spi_top/inst_spi_device_select/o_spi_sdata
add wave -noupdate -group spi_select -group spi_link -group cdce -color Cyan /tb_spi_top/inst_spi_top/inst_spi_device_select/o_cdce_n_en
add wave -noupdate -group spi_select -group spi_link -group cdce -color Cyan /tb_spi_top/inst_spi_top/inst_spi_device_select/i_cdce_sdo
add wave -noupdate -group spi_select -group spi_link -group cdce /tb_spi_top/inst_spi_top/inst_spi_device_select/i_cdce_pll_status
add wave -noupdate -group spi_select -group spi_link -group cdce /tb_spi_top/inst_spi_top/inst_spi_device_select/o_cdce_n_reset
add wave -noupdate -group spi_select -group spi_link -group cdce /tb_spi_top/inst_spi_top/inst_spi_device_select/o_cdce_n_pd
add wave -noupdate -group spi_select -group spi_link -group cdce /tb_spi_top/inst_spi_top/inst_spi_device_select/o_ref_en
add wave -noupdate -group spi_select -group spi_link -group adc -color Cyan /tb_spi_top/inst_spi_top/inst_spi_device_select/i_adc_sdo
add wave -noupdate -group spi_select -group spi_link -group adc -color Cyan /tb_spi_top/inst_spi_top/inst_spi_device_select/o_adc_n_en
add wave -noupdate -group spi_select -group spi_link -group adc /tb_spi_top/inst_spi_top/inst_spi_device_select/o_adc_reset
add wave -noupdate -group spi_select -group spi_link -group dac -color Cyan /tb_spi_top/inst_spi_top/inst_spi_device_select/o_dac_n_en
add wave -noupdate -group spi_select -group spi_link -group dac -color Cyan /tb_spi_top/inst_spi_top/inst_spi_device_select/i_dac_sdo
add wave -noupdate -group spi_select -group spi_link -group dac /tb_spi_top/inst_spi_top/inst_spi_device_select/o_dac_tx_present
add wave -noupdate -group spi_select -group spi_link -group mon -color Cyan /tb_spi_top/inst_spi_top/inst_spi_device_select/o_mon_n_en
add wave -noupdate -group spi_select -group spi_link -group mon -color Cyan /tb_spi_top/inst_spi_top/inst_spi_device_select/i_mon_sdo
add wave -noupdate -group spi_select -group spi_link -group mon /tb_spi_top/inst_spi_top/inst_spi_device_select/i_mon_n_int
add wave -noupdate -group spi_select -group spi_link -group mon /tb_spi_top/inst_spi_top/inst_spi_device_select/o_mon_n_reset
add wave -noupdate -group spi_master_cdce /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_cdce72010/inst_spi_master/i_clk
add wave -noupdate -group spi_master_cdce /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_cdce72010/inst_spi_master/i_rst
add wave -noupdate -group spi_master_cdce -group cmd -group wr /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_cdce72010/inst_spi_master/i_tx_msb_first
add wave -noupdate -group spi_master_cdce -group cmd -group wr /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_cdce72010/inst_spi_master/i_tx_data_valid
add wave -noupdate -group spi_master_cdce -group cmd -group wr /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_cdce72010/inst_spi_master/i_tx_data
add wave -noupdate -group spi_master_cdce -group cmd -group wr /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_cdce72010/inst_spi_master/i_wr_rd
add wave -noupdate -group spi_master_cdce -group cmd -group out /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_cdce72010/inst_spi_master/o_ready
add wave -noupdate -group spi_master_cdce -group cmd -group out /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_cdce72010/inst_spi_master/o_finish
add wave -noupdate -group spi_master_cdce -group cmd -group out -expand -group rd /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_cdce72010/inst_spi_master/o_rx_data_valid
add wave -noupdate -group spi_master_cdce -group cmd -group out -expand -group rd /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_cdce72010/inst_spi_master/o_rx_data
add wave -noupdate -group spi_master_cdce -group step1 /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_cdce72010/inst_spi_master/sclk_tmp
add wave -noupdate -group spi_master_cdce -group step1 /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_cdce72010/inst_spi_master/pulse_data_shift_tmp
add wave -noupdate -group spi_master_cdce -group step1 /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_cdce72010/inst_spi_master/pulse_data_sample_tmp
add wave -noupdate -group spi_master_cdce -group step1 /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_cdce72010/inst_spi_master/sm_wr_state_r1
add wave -noupdate -group spi_master_cdce -expand -group spi /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_cdce72010/inst_spi_master/i_miso
add wave -noupdate -group spi_master_cdce -expand -group spi -color Cyan /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_cdce72010/inst_spi_master/o_mosi
add wave -noupdate -group spi_master_cdce -expand -group spi -color Cyan /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_cdce72010/inst_spi_master/o_sclk
add wave -noupdate -group spi_master_cdce -expand -group spi -color Cyan /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_cdce72010/inst_spi_master/o_cs_n
add wave -noupdate -group spi_master_adc /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_ads62p49/inst_spi_master/i_clk
add wave -noupdate -group spi_master_adc /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_ads62p49/inst_spi_master/i_rst
add wave -noupdate -group spi_master_adc -group cmd -group wr /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_ads62p49/inst_spi_master/i_tx_msb_first
add wave -noupdate -group spi_master_adc -group cmd -group wr /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_ads62p49/inst_spi_master/i_tx_data_valid
add wave -noupdate -group spi_master_adc -group cmd -group wr /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_ads62p49/inst_spi_master/i_tx_data
add wave -noupdate -group spi_master_adc -group cmd -group wr /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_ads62p49/inst_spi_master/i_wr_rd
add wave -noupdate -group spi_master_adc -group cmd -group out /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_ads62p49/inst_spi_master/o_ready
add wave -noupdate -group spi_master_adc -group cmd -group out /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_ads62p49/inst_spi_master/o_finish
add wave -noupdate -group spi_master_adc -group cmd -group out -expand -group rd /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_ads62p49/inst_spi_master/o_rx_data_valid
add wave -noupdate -group spi_master_adc -group cmd -group out -expand -group rd /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_ads62p49/inst_spi_master/o_rx_data
add wave -noupdate -group spi_master_adc -group step1 /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_ads62p49/inst_spi_master/sclk_tmp
add wave -noupdate -group spi_master_adc -group step1 /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_ads62p49/inst_spi_master/pulse_data_shift_tmp
add wave -noupdate -group spi_master_adc -group step1 /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_ads62p49/inst_spi_master/pulse_data_sample_tmp
add wave -noupdate -group spi_master_adc -group step1 /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_ads62p49/inst_spi_master/sm_wr_state_r1
add wave -noupdate -group spi_master_adc -group spi /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_ads62p49/inst_spi_master/i_miso
add wave -noupdate -group spi_master_adc -group spi -color Cyan /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_ads62p49/inst_spi_master/o_mosi
add wave -noupdate -group spi_master_adc -group spi -color Cyan /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_ads62p49/inst_spi_master/o_sclk
add wave -noupdate -group spi_master_adc -group spi -color Cyan /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_ads62p49/inst_spi_master/o_cs_n
add wave -noupdate -group spi_master_dac /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/i_clk
add wave -noupdate -group spi_master_dac /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/i_rst
add wave -noupdate -group spi_master_dac -group cmd -expand -group wr /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/i_wr_rd
add wave -noupdate -group spi_master_dac -group cmd -expand -group wr /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/i_tx_msb_first
add wave -noupdate -group spi_master_dac -group cmd -expand -group wr /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/i_tx_data_valid
add wave -noupdate -group spi_master_dac -group cmd -expand -group wr /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/i_tx_data
add wave -noupdate -group spi_master_dac -group cmd -expand -group out /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/o_ready
add wave -noupdate -group spi_master_dac -group cmd -expand -group out /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/o_finish
add wave -noupdate -group spi_master_dac -group cmd -expand -group out -expand -group rd /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/o_rx_data_valid
add wave -noupdate -group spi_master_dac -group cmd -expand -group out -expand -group rd /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/o_rx_data
add wave -noupdate -group spi_master_dac -group step1 /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/sclk_tmp
add wave -noupdate -group spi_master_dac -group step1 /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/pulse_data_shift_tmp
add wave -noupdate -group spi_master_dac -group step1 /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/pulse_data_sample_tmp
add wave -noupdate -group spi_master_dac -group step1 /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/sm_wr_state_r1
add wave -noupdate -group spi_master_dac -group spi /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/i_miso
add wave -noupdate -group spi_master_dac -group spi -color Cyan /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/o_mosi
add wave -noupdate -group spi_master_dac -group spi -color Cyan /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/o_sclk
add wave -noupdate -group spi_master_dac -group spi -color Cyan /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_dac3283/inst_spi_master/o_cs_n
add wave -noupdate -group spi_master_amc /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_amc7823/inst_spi_master/i_clk
add wave -noupdate -group spi_master_amc /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_amc7823/inst_spi_master/i_rst
add wave -noupdate -group spi_master_amc -group cmd -group wr /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_amc7823/inst_spi_master/i_wr_rd
add wave -noupdate -group spi_master_amc -group cmd -group wr /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_amc7823/inst_spi_master/i_tx_msb_first
add wave -noupdate -group spi_master_amc -group cmd -group wr /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_amc7823/inst_spi_master/i_tx_data_valid
add wave -noupdate -group spi_master_amc -group cmd -group wr /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_amc7823/inst_spi_master/i_tx_data
add wave -noupdate -group spi_master_amc -group cmd -group out /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_amc7823/inst_spi_master/o_ready
add wave -noupdate -group spi_master_amc -group cmd -group out /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_amc7823/inst_spi_master/o_finish
add wave -noupdate -group spi_master_amc -group cmd -group out -expand -group rd /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_amc7823/inst_spi_master/o_rx_data_valid
add wave -noupdate -group spi_master_amc -group cmd -group out -expand -group rd /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_amc7823/inst_spi_master/o_rx_data
add wave -noupdate -group spi_master_amc -group step1 /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_amc7823/inst_spi_master/sclk_tmp
add wave -noupdate -group spi_master_amc -group step1 /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_amc7823/inst_spi_master/pulse_data_shift_tmp
add wave -noupdate -group spi_master_amc -group step1 /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_amc7823/inst_spi_master/pulse_data_sample_tmp
add wave -noupdate -group spi_master_amc -group step1 /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_amc7823/inst_spi_master/sm_wr_state_r1
add wave -noupdate -group spi_master_amc -group spi /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_amc7823/inst_spi_master/i_miso
add wave -noupdate -group spi_master_amc -group spi -color Cyan /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_amc7823/inst_spi_master/o_mosi
add wave -noupdate -group spi_master_amc -group spi -color Cyan /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_amc7823/inst_spi_master/o_sclk
add wave -noupdate -group spi_master_amc -group spi -color Cyan /tb_spi_top/inst_spi_top/inst_spi_device_select/inst_spi_amc7823/inst_spi_master/o_cs_n
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {42500 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 210
configure wave -valuecolwidth 107
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
WaveRestoreZoom {2642676972 ps} {2643635436 ps}
