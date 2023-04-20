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
#    @file                   test_oversample.py
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


def test_oversample():
    ########################################################
    # Generate data
    ########################################################

    nb_pts = 16
    overSample = 2
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

    for pts in pts_list:
        str0 = pts.get_info("bob", "bobi")
        print(str0)


if __name__ == '__main__':
    test_oversample()
