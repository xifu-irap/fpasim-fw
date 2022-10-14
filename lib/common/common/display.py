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
#    @file                   display.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    
# -------------------------------------------------------------------------------------------------------------
#    @details                
# 
# -------------------------------------------------------------------------------------------------------------

import os
# Enable the coloring in the console
os.system("")
import sys
from pathlib import Path
import re

from common import ConsoleColors



class Display():
	def __init__(self):
		self.char_section = '*'
		self.nb_char_section = 70
		self.char_indent = ' '
		self.nb_char_indent = 4
		self.script_name = ''
	def set_script_name(self,name_p):
		self.script_name = name_p

	def set_indent(self,char_p=' ',nb_char_p=4):
		self.char_indent    = char_p
		self.nb_char_indent = nb_char_p

	def set_section(self,char_p = '*', nb_char_p = 70):
		self.char_section    = char_p
		self.nb_char_section = nb_char_section

	def display_title(self,msg_p,level_p = 0,color_p = ConsoleColors.yellow):

		msg = self._convert_str_to_list(msg_p=msg_p)
		str_indent  = self.char_indent*self.nb_char_indent*level_p
		str_char = self.char_section * self.nb_char_section
		str_sep = color_p + str_indent + str_char 

		print('')
		print(str_sep)
		for m in msg:
			str0 =  color_p + str_indent + ' ' + m
			print(str0)
		print(str_sep)
	def display_subtitle(self,msg_p,level_p = 0,color_p = ConsoleColors.yellow):

		msg = self._convert_str_to_list(msg_p=msg_p)
		str_indent  = self.char_indent*self.nb_char_indent*level_p
		str_char = self.char_section * self.nb_char_section
		str_sep = color_p + str_indent + str_char 

		print('')
		for m in msg:
			str0 =  color_p + str_indent + ' ' + m
			print(str0)
		print(str_sep)

	def display(self,msg_p,level_p = 0,color_p = ConsoleColors.reset):
		msg = self._convert_str_to_list(msg_p=msg_p)
		str_indent  = self.char_indent*self.nb_char_indent*level_p

		for m in msg:
			str0 =  color_p + str_indent + ' ' + m
			print(str0)


	def _convert_str_to_list(self,msg_p):
		if type(msg_p) != type([]):
			msg = [msg_p]
		else:
			msg = msg_p
		return msg





