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
resize_pblock [get_pblocks pblock_inst_regdecode_top] -add {CLOCKREGION_X0Y1:CLOCKREGION_X1Y4}

create_pblock pblock_inst_dac_top
add_cells_to_pblock [get_pblocks pblock_inst_dac_top] [get_cells -quiet [list inst_fpasim_top/inst_dac_top]]
resize_pblock [get_pblocks pblock_inst_dac_top] -add {SLICE_X86Y190:SLICE_X105Y224 SLICE_X0Y147:SLICE_X43Y249}
resize_pblock [get_pblocks pblock_inst_dac_top] -add {DSP48_X4Y76:DSP48_X6Y89 DSP48_X0Y60:DSP48_X1Y99}
resize_pblock [get_pblocks pblock_inst_dac_top] -add {RAMB18_X5Y76:RAMB18_X5Y89 RAMB18_X0Y60:RAMB18_X1Y99}
resize_pblock [get_pblocks pblock_inst_dac_top] -add {RAMB36_X5Y38:RAMB36_X5Y44 RAMB36_X0Y30:RAMB36_X1Y49}

set_property PARENT pblock_inst_dac_top [get_pblocks pblock_inst_spi_top]
create_pblock pblock_inst_spi_top
add_cells_to_pblock [get_pblocks pblock_inst_spi_top] [get_cells -quiet [list inst_spi_top]]
resize_pblock [get_pblocks pblock_inst_spi_top] -add {SLICE_X0Y175:SLICE_X7Y248}
resize_pblock [get_pblocks pblock_inst_spi_top] -add {RAMB18_X0Y70:RAMB18_X0Y97}
resize_pblock [get_pblocks pblock_inst_spi_top] -add {RAMB36_X0Y35:RAMB36_X0Y48}
create_pblock pblock_inst_adc_top
add_cells_to_pblock [get_pblocks pblock_inst_adc_top] [get_cells -quiet [list inst_fpasim_top/inst_adc_top]]
resize_pblock [get_pblocks pblock_inst_adc_top] -add {SLICE_X0Y140:SLICE_X17Y249}
resize_pblock [get_pblocks pblock_inst_adc_top] -add {DSP48_X0Y56:DSP48_X0Y99}
resize_pblock [get_pblocks pblock_inst_adc_top] -add {RAMB18_X0Y56:RAMB18_X0Y99}
resize_pblock [get_pblocks pblock_inst_adc_top] -add {RAMB36_X0Y28:RAMB36_X0Y49}
create_pblock pblock_inst_recording_top
add_cells_to_pblock [get_pblocks pblock_inst_recording_top] [get_cells -quiet [list inst_fpasim_top/inst_recording_top]]
resize_pblock [get_pblocks pblock_inst_recording_top] -add {SLICE_X8Y125:SLICE_X23Y199}
resize_pblock [get_pblocks pblock_inst_recording_top] -add {DSP48_X0Y50:DSP48_X1Y79}
resize_pblock [get_pblocks pblock_inst_recording_top] -add {RAMB18_X0Y50:RAMB18_X1Y79}
resize_pblock [get_pblocks pblock_inst_recording_top] -add {RAMB36_X0Y25:RAMB36_X1Y39}
create_pblock pblock_inst_tes_top
add_cells_to_pblock [get_pblocks pblock_inst_tes_top] [get_cells -quiet [list inst_fpasim_top/inst_tes_top]]
resize_pblock [get_pblocks pblock_inst_tes_top] -add {SLICE_X0Y145:SLICE_X39Y199}
resize_pblock [get_pblocks pblock_inst_tes_top] -add {DSP48_X0Y58:DSP48_X1Y79}
resize_pblock [get_pblocks pblock_inst_tes_top] -add {RAMB18_X0Y58:RAMB18_X1Y79}
resize_pblock [get_pblocks pblock_inst_tes_top] -add {RAMB36_X0Y29:RAMB36_X1Y39}
create_pblock pblock_inst_mux_squid_top
add_cells_to_pblock [get_pblocks pblock_inst_mux_squid_top] [get_cells -quiet [list inst_fpasim_top/inst_mux_squid_top]]
resize_pblock [get_pblocks pblock_inst_mux_squid_top] -add {SLICE_X50Y147:SLICE_X77Y199}
resize_pblock [get_pblocks pblock_inst_mux_squid_top] -add {DSP48_X2Y60:DSP48_X3Y79}
resize_pblock [get_pblocks pblock_inst_mux_squid_top] -add {RAMB18_X2Y60:RAMB18_X3Y79}
resize_pblock [get_pblocks pblock_inst_mux_squid_top] -add {RAMB36_X2Y30:RAMB36_X3Y39}
create_pblock pblock_inst_amp_squid_top
add_cells_to_pblock [get_pblocks pblock_inst_amp_squid_top] [get_cells -quiet [list inst_fpasim_top/inst_amp_squid_top]]
resize_pblock [get_pblocks pblock_inst_amp_squid_top] -add {SLICE_X70Y145:SLICE_X113Y199}
resize_pblock [get_pblocks pblock_inst_amp_squid_top] -add {DSP48_X4Y58:DSP48_X6Y79}
resize_pblock [get_pblocks pblock_inst_amp_squid_top] -add {RAMB18_X4Y58:RAMB18_X6Y79}
resize_pblock [get_pblocks pblock_inst_amp_squid_top] -add {RAMB36_X4Y29:RAMB36_X6Y39}


