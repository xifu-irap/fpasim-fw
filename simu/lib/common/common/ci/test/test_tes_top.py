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
#    @file                   test_tes_top.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    N/A
# -------------------------------------------------------------------------------------------------------------
#    @details
#    
#    Note:
#       . This script was tested with python 3.10
# -------------------------------------------------------------------------------------------------------------
# standard library
import sys
from pathlib import Path

# Add the ci directory path to the system path
filepath = Path(__file__)
ci_root_path = str(filepath.parents[1])
sys.path.append(ci_root_path)

# user library
from core import Generator
from core import Attribute
from core import OverSample
from core import TesSignalling
from core import TesTop


def test_tes_top():
    ########################################################
    # input parameters
    ########################################################
    root_filepath = str(filepath.parents[0])
    input_base_path = str(Path(root_filepath, 'test_data'))
    output_base_path = str(Path(root_filepath, 'test_result'))

    # adc
    nb_sample_by_pixel = 8
    nb_pixel_by_frame = 8
    nb_frame_by_pulse = 2048
    nb_pulse = 1

    # tes
    cmd_pixel_id = 0
    cmd_time_shift = 2
    cmd_pulse_height = 16384
    skip_nb_samples = 0

    tes_pulse_shape_filepath = str(Path(input_base_path, "tes_pulse_shape.csv"))
    tes_std_state_filepath = str(Path(input_base_path, "tes_std_state.csv"))

    # result
    output_filepath = str(Path(output_base_path, "tes_out.csv"))

    ########################################################
    # adc: compute parameters
    ########################################################
    nb_sample_by_frame = nb_pixel_by_frame * nb_sample_by_pixel
    nb_pts = nb_pixel_by_frame * nb_frame_by_pulse * nb_pulse
    overSample = nb_sample_by_pixel

    ########################################################
    # generate data
    ########################################################
    # adc
    obj_gen = Generator(nb_pts_p=nb_pts)
    pts_list = obj_gen.run()

    obj_attr = Attribute(pts_list_p=pts_list)
    obj_attr.set_attribute(name_p="bob", mode_p=0, min_value_p=0, max_value_p=7)
    pts_list = obj_attr.run()

    obj_attr = Attribute(pts_list_p=pts_list)
    obj_attr.set_attribute(name_p="bobi", mode_p=1, min_value_p=0, max_value_p=8)
    pts_list = obj_attr.run()

    obj_over = OverSample(pts_list_p=pts_list)
    obj_over.set_oversampling(value_p=overSample)
    pts_list = obj_over.run()

    # tes
    obj_sign = TesSignalling(pts_list_p=pts_list)
    obj_sign.set_conf(nb_pixel_by_frame_p=nb_pixel_by_frame, nb_sample_by_pixel_p=nb_sample_by_pixel,
                      nb_sample_by_frame_p=nb_sample_by_frame, nb_frame_by_pulse_p=nb_frame_by_pulse)
    pts_list = obj_sign.run()

    obj_tes = TesTop(pts_list_p=pts_list)
    obj_tes.set_ram_tes_pulse_shape(filepath_p=tes_pulse_shape_filepath)
    obj_tes.set_ram_tes_steady_state(filepath_p=tes_std_state_filepath)
    obj_tes.add_make_pulse_command(pixel_id_p=cmd_pixel_id, time_shift_p=cmd_time_shift,
                                   pulse_height_p=cmd_pulse_height, skip_nb_samples_p=skip_nb_samples)
    pts_list = obj_tes.run(output_attribute_name_p="tes_out")

    ########################################################
    # save data in a output file
    ########################################################
    with open(output_filepath, 'w') as fid:
        csv_separator = ';'
        L = len(pts_list)
        index_max = L - 1
        for index, obj_pt in enumerate(pts_list):
            if index == 0:
                # write header
                fid.write("expected_output_int")
                fid.write(csv_separator)
                fid.write('pixel_id_uint')
                fid.write('\n')
            # get point attributes
            pixel_id = obj_pt.get_attribute(name_p="pixel_id")
            tes_out = obj_pt.get_attribute(name_p="tes_out")

            fid.write(str(tes_out))
            fid.write(csv_separator)
            fid.write(str(pixel_id))
            if index != index_max:
                fid.write('\n')

    ########################################################
    # print point attributes
    ########################################################
    # for obj_pt in pts_list:
    #     str0 = obj_pt.get_info("pixel_sof","pixel_eof","pixel_id","frame_sof","frame_eof","frame_id","tes_out")
    #     str0 = obj_pt.get_info("bob","bobi","pixel_sof","pixel_eof","pixel_id")
    #     str0 = obj_pt.get_info("pixel_sof", "pixel_id")
    #     print(str0)


if __name__ == '__main__':
    test_tes_top()
