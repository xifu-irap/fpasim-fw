# -*- coding: utf-8 -*-
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
#    @file                   test_amp_squid_top.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    N/A
# -------------------------------------------------------------------------------------------------------------
#    @details
#    
#    Note:
#       . This script was tested with python 3.10
# -------------------------------------------------------------------------------------------------------------
#standard library
import sys
from pathlib import Path,PurePosixPath

# Add the ci directory path to the system path
filepath = Path(__file__)
ci_root_path = str(filepath.parents[1])
sys.path.append(ci_root_path)

# user library
from core import Generator
from core import Attribute
from core import OverSample
from core import TesSignalling
from core import TesPulseShapeManager
from core import MuxSquidTop
from core import AmpSquidTop

def test_amp_squid_top():
    ########################################################
    # input parameters
    ########################################################
    root_filepath = str(filepath.parents[0])
    input_base_path = str(Path(root_filepath,'test_data'))
    output_base_path = str(Path(root_filepath,'test_result'))

    # adc
    nb_sample_by_pixel = 8
    nb_pixel_by_frame = 2
    nb_frame_by_pulse = 3
    nb_pulse = 2

    # tes
    # cmd_pixel_id     = 0
    # cmd_time_shift   = 2
    # cmd_pulse_heigth = 16384 
    # skip_nb_samples = 0

    # tes_pulse_shape_filepath = str(Path(input_base_path,"tes_pulse_shape.csv"))
    # tes_std_state_filepath = str(Path(input_base_path,"tes_std_state.csv"))

    # mux_squid
    # inter_squid_gain = 255
    # mux_squid_offset_filepath = str(Path(input_base_path,"mux_squid_offset.csv"))
    # mux_squid_tf_filepath     = str(Path(input_base_path,"mux_squid_tf.csv"))

    # amp_squid
    fpasim_gain = 1
    amp_squid_tf_filepath = str(Path(input_base_path,"amp_squid_tf.csv"))


    # result
    output_filepath_in = str(Path(output_base_path,"amp_squid_in.csv"))
    output_filepath_out = str(Path(output_base_path,"amp_squid_out.csv"))


    ########################################################
    # adc: compute parameters
    ########################################################
    nb_sample_by_frame = nb_pixel_by_frame * nb_sample_by_pixel
    nb_pts     = nb_pixel_by_frame * nb_frame_by_pulse * nb_pulse
    overSample = nb_sample_by_pixel

    ########################################################
    # generate data
    ########################################################
    # adc
    obj_gen = Generator(nb_pts_p=nb_pts)
    pts_list = obj_gen.run()

    obj_attr = Attribute(pts_list_p=pts_list)
    obj_attr.set_random_seed(value_p=10)
    obj_attr.set_attribute(name_p="mux_squid_out", mode_p=1, min_value_p=10, max_value_p=20)
    pts_list = obj_attr.run()

    obj_attr = Attribute(pts_list_p=pts_list)
    obj_attr.set_attribute(name_p="adc_amp_squid_offset_correction", mode_p=0, min_value_p=1, max_value_p=10)
    pts_list = obj_attr.run()

    obj_over = OverSample(pts_list_p=pts_list)
    obj_over.set_oversampling(value_p=overSample)
    pts_list = obj_over.run()

    # tes
    obj_sign = TesSignalling(pts_list_p=pts_list)
    obj_sign.set_conf(nb_pixel_by_frame_p=nb_pixel_by_frame, nb_sample_by_pixel_p=nb_sample_by_pixel, nb_sample_by_frame_p=nb_sample_by_frame, nb_frame_by_pulse_p=nb_frame_by_pulse)
    pts_list = obj_sign.run()

    # obj_tes = TesPulseShapeManager(pts_list_p=pts_list)
    # obj_tes.set_ram_tes_pulse_shape(filepath_p=tes_pulse_shape_filepath)
    # obj_tes.set_ram_tes_steady_state(filepath_p=tes_std_state_filepath)
    # obj_tes.add_make_pulse_command(pixel_id_p=cmd_pixel_id, time_shift_p=cmd_time_shift, pulse_heigth_p=cmd_pulse_heigth,skip_nb_samples_p=skip_nb_samples)
    # pts_list = obj_tes.run(output_attribute_name_p="tes_out")

    # mux_squid
    # obj_mux = MuxSquidTop(pts_list_p=pts_list)
    # obj_mux.set_ram_mux_squid_offset(filepath_p=mux_squid_offset_filepath)
    # obj_mux.set_ram_mux_squid_tf(filepath_p=mux_squid_tf_filepath)
    # obj_mux.set_register(inter_squid_gain_p=inter_squid_gain)
    # pts_list = obj_mux.run(output_attribute_name_p="mux_squid_out")

    # amp_squid
    obj_amp = AmpSquidTop(pts_list_p=pts_list)
    obj_amp.set_ram_amp_squid_tf(filepath_p=amp_squid_tf_filepath)
    obj_amp.set_fpasim_gain(fpasim_gain_p=fpasim_gain)
    pts_list = obj_amp.run(output_attribute_name_p="amp_squid_out")

    ########################################################
    # save data in a output files
    ########################################################
    with open(output_filepath_out,'w') as fid:
        L = len(pts_list)
        index_max = L - 1
        for index,obj_pt in enumerate(pts_list):
            if index == 0:
                # header
                fid.write('amp_squid_out')
                fid.write('\n')

            # get point attribute
            amp_squid_out  = obj_pt.get_attribute(name_p="amp_squid_out")

            fid.write(str(amp_squid_out))
            if index != index_max:
                fid.write('\n')

    with open(output_filepath_in,'w') as fid:
        csv_separator = ';'
        L = len(pts_list)
        index_max = L - 1
        for index,obj_pt in enumerate(pts_list):
            if index == 0:
                # header
                fid.write('pixel_sof')
                fid.write(csv_separator)
                fid.write('pixel_eof')
                fid.write(csv_separator)
                fid.write('pixel_id')
                fid.write(csv_separator)
                fid.write('mux_squid_out')
                fid.write(csv_separator)
                fid.write('frame_sof')
                fid.write(csv_separator)
                fid.write('frame_eof')
                fid.write(csv_separator)
                fid.write('frame_id')
                fid.write(csv_separator)
                fid.write('adc_amp_squid_offset_correction')
                fid.write('\n')

            # get point attributes
            pixel_sof = obj_pt.get_attribute(name_p="pixel_sof")
            pixel_eof = obj_pt.get_attribute(name_p="pixel_eof")
            pixel_id = obj_pt.get_attribute(name_p="pixel_id")
            mux_squid_out  = obj_pt.get_attribute(name_p="mux_squid_out")
            frame_sof  = obj_pt.get_attribute(name_p="frame_sof")
            frame_eof  = obj_pt.get_attribute(name_p="frame_eof")
            frame_id  = obj_pt.get_attribute(name_p="frame_id")
            adc_amp_squid_offset_correction  = obj_pt.get_attribute(name_p="adc_amp_squid_offset_correction")

            fid.write(str(pixel_sof))
            fid.write(csv_separator)
            fid.write(str(pixel_eof))
            fid.write(csv_separator)
            fid.write(str(pixel_id))
            fid.write(csv_separator)
            fid.write(str(mux_squid_out))
            fid.write(csv_separator)
            fid.write(str(frame_sof))
            fid.write(csv_separator)
            fid.write(str(frame_eof))
            fid.write(csv_separator)
            fid.write(str(frame_id))
            fid.write(csv_separator)
            fid.write(str(adc_amp_squid_offset_correction))
            if index != index_max:
                fid.write('\n')

    ########################################################
    # print point attributes
    ########################################################
    # for obj_pt in pts_list:
    #     str0 = obj_pt.get_info("tes_out","adc_mux_squid_feedback")
    #     print(str0)


if __name__ == '__main__':
    test_amp_squid_top()
