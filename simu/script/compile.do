# -------------------------------------------------------------------------------------------------------------
#                              Copyright (C) 2022-2030 Ken-ji de la Rosa, IRAP Toulouse.
# -------------------------------------------------------------------------------------------------------------
#                              This file is part of the ATHENA X-IFU DRE Focal Plane Assembly simulator.
#
#                              fpasim-fw is free software: you can redistribute it and/or modify
#                              it under the terms of the GNU General Public License as published by
#                              the Free Software Foundation, either version 3 of the License, or
#                              (at your option) any later version.
#
#                              This program is distributed in the hope that it will be useful,
#                              but WITHOUT ANY WARRANTY; without even the implied warranty of
#                              MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#                              GNU General Public License for more details.
#
#                              You should have received a copy of the GNU General Public License
#                              along with this program.  If not, see <https://www.gnu.org/licenses/>.
# -------------------------------------------------------------------------------------------------------------
#    email                   kenji.delarosa@alten.com
#    @file                   compile.do 
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
# -------------------------------------------------------------------------------------------------------------
#    @details                
#
#    This Modesim *.do file allows to do the following steps:
#      . define the project libraries
#      . link the Xilinx pre-compiled libraries
#      . compile the source files in the right library
#
# -------------------------------------------------------------------------------------------------------------


###################### Parameters ######################
# User-defined: To Edit, if necessary
# project root directory
quietly set PR_DIR D:/fpasim-fw-hardware
# Xilinx compiled libraries (by vivado)
quietly set COMPIL_LIB_DIR C:/Xifu/xilinx_compile_lib/questa
# vivado installation directory
quietly set VIVADO_DIR C:/Xilinx/Vivado/2022.1


###################### define project library ######################
# don't edit except if you know what you do
vlib xpm
vlib fpasim
#vlib tb_fpasim
vlib opal_kelly_lib
vlib common_lib
vlib csv_lib

###################### External Compiled libraries ######################
# don't edit except if you know what you do
vmap xilinx_vip ${COMPIL_LIB_DIR}/xilinx_vip
vmap xpm ${COMPIL_LIB_DIR}/xpm
vmap unisims_ver ${COMPIL_LIB_DIR}/unisims_ver
vmap unisim ${COMPIL_LIB_DIR}/unisim
vmap unimacro ${COMPIL_LIB_DIR}/unimacro
vmap unimacro_ver ${COMPIL_LIB_DIR}/unimacro_ver
vmap unifast ${COMPIL_LIB_DIR}/unifast
vmap secureip ${COMPIL_LIB_DIR}/secureip

###################### copy ram configuration files ######################
# don't edit except if you know what you do
# copy file in the compilation directory
file copy -force "${PR_DIR}/src/hdl/fpasim/tes/core/tes_std_state.mem" .
file copy -force "${PR_DIR}/src/hdl/fpasim/tes/core/tes_pulse_shape.mem" .
file copy -force "${PR_DIR}/src/hdl/fpasim/mux_squid/core/mux_squid_offset.mem" .
file copy -force "${PR_DIR}/src/hdl/fpasim/mux_squid/core/mux_squid_tf.mem" .
file copy -force "${PR_DIR}/src/hdl/fpasim/amp_squid/core/amp_squid_tf.mem" .

###################### IP Source files ######################
# don't edit except if you know what you do

vcom -work fpasim  -93 \
"${PR_DIR}/ip/xilinx/coregen/system_fpasim_top_ila/sim/system_fpasim_top_ila.vhd" \
"${PR_DIR}/ip/xilinx/coregen/fpasim_spi_device_select_ila/sim/fpasim_spi_device_select_ila.vhd" \
"${PR_DIR}/ip/xilinx/coregen/fpasim_spi_device_select_vio/sim/fpasim_spi_device_select_vio.vhd" \

vlog -work fpasim  -incr -mfcu "+incdir+${PR_DIR}/ip/xilinx/coregen/fpasim_clk_wiz_0" \
"${PR_DIR}/ip/xilinx/coregen/selectio_wiz_dac_frame/selectio_wiz_dac_frame_sim_netlist.v" \
"${PR_DIR}/ip/xilinx/coregen/selectio_wiz_dac/selectio_wiz_dac_sim_netlist.v" \
"${PR_DIR}/ip/xilinx/coregen/selectio_wiz_dac_clk/selectio_wiz_dac_clk_sim_netlist.v" \
"${PR_DIR}/ip/xilinx/coregen/selectio_wiz_sync/selectio_wiz_sync_sim_netlist.v" \
"${PR_DIR}/ip/xilinx/coregen/selectio_wiz_adc/selectio_wiz_adc_sim_netlist.v" \

vlog -work fpasim ${VIVADO_DIR}/data/verilog/src/glbl.v  

###################### Source files ######################
# don't edit except if you know what you do

vcom -work csv_lib -2008 ${PR_DIR}/lib/csv/csv/vhdl/src/pkg_csv_file.vhd

vcom -work fpasim  -93 \
"${PR_DIR}/ip/xilinx/coregen/fpasim_regdecode_top_ila_0/sim/fpasim_regdecode_top_ila_0.vhd" \

vlog -work fpasim  -incr -mfcu "+incdir+${PR_DIR}/ip/xilinx/coregen/fpasim_clk_wiz_0" \
"${PR_DIR}/ip/xilinx/coregen/fpasim_clk_wiz_0/fpasim_clk_wiz_0_clk_wiz.v" \
"${PR_DIR}/ip/xilinx/coregen/fpasim_clk_wiz_0/fpasim_clk_wiz_0.v" \

vcom -work fpasim  -93 \
"${PR_DIR}/src/hdl/utils/others/pipeliner.vhd" \
"${PR_DIR}/src/hdl/sim/ads62p49/core/ads62p49_convert.vhd" \
"${PR_DIR}/src/hdl/sim/ads62p49/core/ads62p49_io.vhd" \
"${PR_DIR}/src/hdl/sim/ads62p49/ads62p49_top.vhd" \

vcom -work fpasim  -2008 \
"${PR_DIR}/src/hdl/utils/pkg_utils.vhd" \

vcom -work fpasim  -93 \
"${PR_DIR}/src/hdl/fpasim/pkg_fpasim.vhd" \

vcom -work fpasim  -2008 \
"${PR_DIR}/src/hdl/utils/math/sub_sfixed.vhd" \

vcom -work fpasim  -93 \
"${PR_DIR}/ip/xilinx/xpm/ram/tdpram.vhd" \
"${PR_DIR}/src/hdl/utils/ram/ram_check.vhd" \
"${PR_DIR}/src/hdl/fpasim/amp_squid/core/amp_squid_fpagain_table.vhd" \

vcom -work fpasim  -2008 \
"${PR_DIR}/src/hdl/utils/math/mult_sfixed.vhd" \

vcom -work fpasim  -93 \
"${PR_DIR}/src/hdl/utils/error/one_error_latch.vhd" \
"${PR_DIR}/src/hdl/fpasim/amp_squid/core/amp_squid.vhd" \
"${PR_DIR}/src/hdl/fpasim/amp_squid/amp_squid_top.vhd" \
"${PR_DIR}/src/hdl/clocking/clocking_top.vhd" \
"${PR_DIR}/src/hdl/sim/dac3283/core/dac3283_convert.vhd" \
"${PR_DIR}/src/hdl/sim/dac3283/core/dac3283_demux.vhd" \
"${PR_DIR}/src/hdl/sim/dac3283/core/dac3283_io.vhd" \
"${PR_DIR}/src/hdl/sim/dac3283/dac3283_top.vhd" \

vcom -work fpasim  -2008 \
"${PR_DIR}/ip/xilinx/xpm/cdc/single_bit_synchronizer.vhd" \

vcom -work fpasim  -93 \
"${PR_DIR}/src/hdl/fpasim/dac/core/dac_frame_generator.vhd" \
"${PR_DIR}/src/hdl/utils/others/dynamic_shift_register.vhd" \
"${PR_DIR}/src/hdl/fpasim/dac/dac_top.vhd" \
"${PR_DIR}/src/hdl/utils/others/dynamic_shift_register_with_valid.vhd" \

vcom -work fpasim  -2008 \
"${PR_DIR}/ip/xilinx/xpm/fifo/fifo_sync.vhd" \

vcom -work fpasim  -93 \
"${PR_DIR}/ip/xilinx/xpm/fifo/fifo_sync_with_error.vhd" \
"${PR_DIR}/src/hdl/pkg_system_fpasim_debug.vhd" \
"${PR_DIR}/src/hdl/utils/others/synchronous_reset_pulse.vhd" \
"${PR_DIR}/ip/xilinx/xpm/cdc/synchronous_reset_synchronizer.vhd" \
"${PR_DIR}/src/hdl/reset/core/reset_io.vhd" \
"${PR_DIR}/src/hdl/reset/reset_top.vhd" \
"${PR_DIR}/src/hdl/fpasim/regdecode/pkg_regdecode.vhd" \
"${PR_DIR}/ip/opal_kelly/simu/okLibrary_sim.vhd" \
"${PR_DIR}/src/hdl/fpasim/regdecode/usb/usb_opal_kelly.vhd" \
"${PR_DIR}/src/hdl/fpasim/regdecode/core/regdecode_pipe_addr_decode_check_addr_range.vhd" \
"${PR_DIR}/src/hdl/fpasim/regdecode/core/regdecode_pipe_addr_decode.vhd" \

vcom -work fpasim  -2008 \
"${PR_DIR}/ip/xilinx/xpm/fifo/fifo_async.vhd" \
"${PR_DIR}/ip/xilinx/xpm/fifo/fifo_async_with_error.vhd" \
"${PR_DIR}/ip/xilinx/xpm/fifo/fifo_async_with_prog_full.vhd" \
"${PR_DIR}/ip/xilinx/xpm/fifo/fifo_async_with_error_prog_full.vhd" \

vcom -work fpasim  -93 \
"${PR_DIR}/src/hdl/fpasim/regdecode/core/regdecode_pipe_wr_rd_ram_manager.vhd" \

vcom -work fpasim  -2008 \
"${PR_DIR}/ip/xilinx/xpm/fifo/fifo_sync_with_prog_full_wr_count.vhd" \
"${PR_DIR}/ip/xilinx/xpm/fifo/fifo_sync_with_error_prog_full_wr_count.vhd" \

vcom -work fpasim  -93 \
"${PR_DIR}/src/hdl/fpasim/regdecode/core/regdecode_pipe_rd_all.vhd" \
"${PR_DIR}/src/hdl/fpasim/regdecode/core/regdecode_pipe.vhd" \
"${PR_DIR}/src/hdl/fpasim/regdecode/core/regdecode_wire_wr_rd.vhd" \

vcom -work fpasim  -2008 \
"${PR_DIR}/ip/xilinx/xpm/fifo/fifo_async_with_prog_full_wr_count.vhd" \
"${PR_DIR}/ip/xilinx/xpm/fifo/fifo_async_with_error_prog_full_wr_count.vhd" \
"${PR_DIR}/src/hdl/fpasim/regdecode/core/regdecode_wire_errors.vhd" \

vcom -work fpasim  -93 \
"${PR_DIR}/src/hdl/fpasim/regdecode/core/regdecode_wire_make_pulse_wr_rd.vhd" \
"${PR_DIR}/src/hdl/fpasim/regdecode/core/regdecode_wire_make_pulse.vhd" \
"${PR_DIR}/src/hdl/fpasim/regdecode/core/regdecode_recording_fifo.vhd" \
"${PR_DIR}/src/hdl/fpasim/regdecode/core/regdecode_recording.vhd" \
"${PR_DIR}/src/hdl/fpasim/regdecode/regdecode_top.vhd" \

vcom -work fpasim  -2008 \
"${PR_DIR}/src/hdl/fpasim/adc/adc_top.vhd" \

vcom -work fpasim  -93 \
"${PR_DIR}/src/hdl/fpasim/tes/core/tes_signalling_generator.vhd" \
"${PR_DIR}/src/hdl/fpasim/tes/core/tes_signalling.vhd" \

vcom -work fpasim  -2008 \
"${PR_DIR}/ip/xilinx/xpm/fifo/fifo_sync_with_prog_full.vhd" \
"${PR_DIR}/ip/xilinx/xpm/fifo/fifo_sync_with_error_prog_full.vhd" \
"${PR_DIR}/src/hdl/utils/math/mult_add_ufixed.vhd" \

vcom -work fpasim  -93 \
"${PR_DIR}/src/hdl/utils/math/mult_sub_sfixed.vhd" \
"${PR_DIR}/src/hdl/fpasim/tes/core/tes_pulse_shape_manager.vhd" \
"${PR_DIR}/src/hdl/fpasim/tes/tes_top.vhd" \

vcom -work fpasim  -2008 \
"${PR_DIR}/src/hdl/utils/math/add_sfixed.vhd" \

vcom -work fpasim  -93 \
"${PR_DIR}/src/hdl/fpasim/mux_squid/core/mux_squid.vhd" \
"${PR_DIR}/src/hdl/fpasim/mux_squid/mux_squid_top.vhd" \
"${PR_DIR}/src/hdl/fpasim/sync/core/sync_pulse_generator.vhd" \
"${PR_DIR}/src/hdl/fpasim/sync/sync_top.vhd" \
"${PR_DIR}/src/hdl/fpasim/recording/recording_adc.vhd" \
"${PR_DIR}/src/hdl/fpasim/recording/recording_top.vhd" \

vcom -work fpasim  -2008 \
"${PR_DIR}/src/hdl/fpasim/fpasim_top.vhd" \

vcom -work fpasim  -93 \
"${PR_DIR}/src/hdl/io/pkg_io.vhd" \
"${PR_DIR}/src/hdl/io/core/io_adc_single.vhd" \
"${PR_DIR}/src/hdl/io/core/io_adc.vhd" \
"${PR_DIR}/src/hdl/io/core/io_sync.vhd" \
"${PR_DIR}/src/hdl/io/core/io_dac_data_insert.vhd" \
"${PR_DIR}/src/hdl/io/core/io_dac.vhd" \
"${PR_DIR}/src/hdl/io/io_top.vhd" \
"${PR_DIR}/src/hdl/utils/others/synchronizer.vhd" \
"${PR_DIR}/src/hdl/utils/others/pipeliner_with_init.vhd" \
"${PR_DIR}/src/hdl/spi/core/spi_io.vhd" \
"${PR_DIR}/src/hdl/spi/core/pkg_spi.vhd" \
"${PR_DIR}/src/hdl/spi/core/spi_master_clock_gen.vhd" \
"${PR_DIR}/src/hdl/spi/core/spi_master.vhd" \
"${PR_DIR}/src/hdl/spi/core/spi_cdce72010.vhd" \
"${PR_DIR}/src/hdl/spi/core/spi_ads62p49.vhd" \
"${PR_DIR}/src/hdl/spi/core/spi_dac3283.vhd" \
"${PR_DIR}/src/hdl/spi/core/spi_amc7823.vhd" \
"${PR_DIR}/src/hdl/spi/core/spi_device_select.vhd" \
"${PR_DIR}/src/hdl/spi/spi_top.vhd" \
"${PR_DIR}/src/hdl/system_fpasim_top.vhd" \
"${PR_DIR}/src/hdl/sim/fpga_system_fpasim.vhd" \
"${PR_DIR}/ip/opal_kelly/simu/parameters.vhd" \

vcom -work opal_kelly_lib  -2008 \
"${PR_DIR}/lib/opal_kelly/opal_kelly/vhdl/src/pkg_front_panel.vhd" \

vcom -work common_lib  -93 \
"${PR_DIR}/lib/common/common/vhdl/src/pkg_common.vhd" \

vcom -work fpasim  -93 \
"${PR_DIR}/ip/opal_kelly/simu/mappings.vhd" \
"${PR_DIR}/ip/opal_kelly/simu/okHost.vhd" \
"${PR_DIR}/ip/opal_kelly/simu/okPipeIn.vhd" \
"${PR_DIR}/ip/opal_kelly/simu/okPipeOut.vhd" \
"${PR_DIR}/ip/opal_kelly/simu/okTriggerIn.vhd" \
"${PR_DIR}/ip/opal_kelly/simu/okTriggerOut.vhd" \
"${PR_DIR}/ip/opal_kelly/simu/okWireIn.vhd" \
"${PR_DIR}/ip/opal_kelly/simu/okWireOR.vhd" \
"${PR_DIR}/ip/opal_kelly/simu/okWireOut.vhd" \
"${PR_DIR}/src/hdl/sim/fpga_system_fpasim_top.vhd" \

