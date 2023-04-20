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
#    @file                   test_tes_signalling.py
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
from pathlib import Path, PurePosixPath

# Add the ci directory path to the system path
filepath = Path(__file__)
ci_root_path = str(filepath.parents[1])
sys.path.append(ci_root_path)

# user library
from core import Generator
from core import Attribute
from core import OverSample
from core import TesSignalling


def test_tes_signalling():
    ########################################################
    # input parameters
    ########################################################
    nb_pixel_by_frame = 1
    nb_sample_by_pixel = 4
    nb_frame_by_pulse = 2

    ########################################################
    # adc: compute parameters
    ########################################################
    nb_sample_by_frame = nb_pixel_by_frame * nb_sample_by_pixel
    nb_pts = nb_pixel_by_frame * nb_sample_by_pixel * nb_frame_by_pulse
    oversampling = nb_sample_by_pixel

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
    obj_over.set_oversampling(value_p=oversampling)
    pts_list = obj_over.run()

    # tes
    obj_sign = TesSignalling(pts_list_p=pts_list)
    obj_sign.set_conf(nb_pixel_by_frame_p=nb_pixel_by_frame, nb_sample_by_pixel_p=nb_sample_by_pixel,
                      nb_sample_by_frame_p=nb_sample_by_frame, nb_frame_by_pulse_p=nb_frame_by_pulse)
    pts_list = obj_sign.run()

    ########################################################
    # print point attributes
    ########################################################
    for obj_pt in pts_list:
        str0 = obj_pt.get_info("bob", "bobi", "pixel_sof", "pixel_eof", "pixel_id", "frame_sof", "frame_eof", "frame_id")
        # str0 = obj_pt.get_info("bob","bobi","pixel_sof","pixel_eof","pixel_id")
        # str0 = obj_pt.get_info("pixel_sof", "pixel_id")
        print(str0)


if __name__ == '__main__':
    test_tes_signalling()
