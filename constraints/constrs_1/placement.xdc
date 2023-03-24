###############################################################################################################
#                              Copyright (C) 2022-2030 Ken-ji de la Rosa, IRAP Toulouse.
###############################################################################################################
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
###############################################################################################################
#    email                   kenji.delarosa@alten.com
#    @file                   placement.xdc
###############################################################################################################
#    Automatic Generation    No
#    Code Rules Reference    N/A
###############################################################################################################
#    @details
#    This file set the timing constraints on the top_level I/O ports (temporary)
#
#
###############################################################################################################


create_pblock pblock_inst_regdecode_top
add_cells_to_pblock [get_pblocks pblock_inst_regdecode_top] [get_cells -quiet [list inst_fpasim_top/inst_regdecode_top]]
resize_pblock [get_pblocks pblock_inst_regdecode_top] -add {CLOCKREGION_X0Y1:CLOCKREGION_X1Y2}

create_pblock pblock_inst_dac_top
add_cells_to_pblock [get_pblocks pblock_inst_dac_top] [get_cells -quiet [list inst_fpasim_top/inst_dac_top]]
resize_pblock [get_pblocks pblock_inst_dac_top] -add {SLICE_X0Y190:SLICE_X77Y224}
resize_pblock [get_pblocks pblock_inst_dac_top] -add {DSP48_X0Y76:DSP48_X4Y89}
resize_pblock [get_pblocks pblock_inst_dac_top] -add {RAMB18_X0Y76:RAMB18_X3Y89}
resize_pblock [get_pblocks pblock_inst_dac_top] -add {RAMB36_X0Y38:RAMB36_X3Y44}

create_pblock pblock_inst_spi_top
add_cells_to_pblock [get_pblocks pblock_inst_spi_top] [get_cells -quiet [list inst_spi_top]]
resize_pblock [get_pblocks pblock_inst_spi_top] -add {SLICE_X0Y175:SLICE_X7Y248}
resize_pblock [get_pblocks pblock_inst_spi_top] -add {RAMB18_X0Y70:RAMB18_X0Y97}
resize_pblock [get_pblocks pblock_inst_spi_top] -add {RAMB36_X0Y35:RAMB36_X0Y48}
create_pblock pblock_inst_adc_top
add_cells_to_pblock [get_pblocks pblock_inst_adc_top] [get_cells -quiet [list inst_fpasim_top/inst_adc_top]]
resize_pblock [get_pblocks pblock_inst_adc_top] -add {SLICE_X0Y131:SLICE_X17Y177}
resize_pblock [get_pblocks pblock_inst_adc_top] -add {DSP48_X0Y54:DSP48_X0Y69}
resize_pblock [get_pblocks pblock_inst_adc_top] -add {RAMB18_X0Y54:RAMB18_X0Y69}
resize_pblock [get_pblocks pblock_inst_adc_top] -add {RAMB36_X0Y27:RAMB36_X0Y34}
create_pblock pblock_inst_recording_top
add_cells_to_pblock [get_pblocks pblock_inst_recording_top] [get_cells -quiet [list inst_fpasim_top/inst_recording_top]]
resize_pblock [get_pblocks pblock_inst_recording_top] -add {SLICE_X0Y125:SLICE_X23Y174}
resize_pblock [get_pblocks pblock_inst_recording_top] -add {DSP48_X0Y50:DSP48_X1Y69}
resize_pblock [get_pblocks pblock_inst_recording_top] -add {RAMB18_X0Y50:RAMB18_X1Y69}
resize_pblock [get_pblocks pblock_inst_recording_top] -add {RAMB36_X0Y25:RAMB36_X1Y34}
create_pblock pblock_inst_tes_top
add_cells_to_pblock [get_pblocks pblock_inst_tes_top] [get_cells -quiet [list inst_fpasim_top/inst_tes_top]]
resize_pblock [get_pblocks pblock_inst_tes_top] -add {SLICE_X0Y145:SLICE_X57Y199}
resize_pblock [get_pblocks pblock_inst_tes_top] -add {DSP48_X0Y58:DSP48_X2Y79}
resize_pblock [get_pblocks pblock_inst_tes_top] -add {RAMB18_X0Y58:RAMB18_X2Y79}
resize_pblock [get_pblocks pblock_inst_tes_top] -add {RAMB36_X0Y29:RAMB36_X2Y39}
create_pblock pblock_inst_mux_squid_top
add_cells_to_pblock [get_pblocks pblock_inst_mux_squid_top] [get_cells -quiet [list inst_fpasim_top/inst_mux_squid_top]]
resize_pblock [get_pblocks pblock_inst_mux_squid_top] -add {SLICE_X52Y147:SLICE_X73Y199}
resize_pblock [get_pblocks pblock_inst_mux_squid_top] -add {DSP48_X3Y60:DSP48_X3Y79}
resize_pblock [get_pblocks pblock_inst_mux_squid_top] -add {RAMB18_X3Y60:RAMB18_X3Y79}
resize_pblock [get_pblocks pblock_inst_mux_squid_top] -add {RAMB36_X3Y30:RAMB36_X3Y39}
create_pblock pblock_inst_amp_squid_top
add_cells_to_pblock [get_pblocks pblock_inst_amp_squid_top] [get_cells -quiet [list inst_fpasim_top/inst_amp_squid_top]]
resize_pblock [get_pblocks pblock_inst_amp_squid_top] -add {SLICE_X70Y199:SLICE_X103Y145}
resize_pblock [get_pblocks pblock_inst_amp_squid_top] -add {DSP48_X4Y58:DSP48_X5Y79}
resize_pblock [get_pblocks pblock_inst_amp_squid_top] -add {RAMB18_X4Y79:RAMB18_X6Y58}
resize_pblock [get_pblocks pblock_inst_amp_squid_top] -add {RAMB36_X4Y39:RAMB36_X6Y29}
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets sys_clk]
