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
#    @file                   display.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    
# -------------------------------------------------------------------------------------------------------------
#    @details                
#    This python script defines the Display class.
#    This class provides methods to print in the console (coloring, indentation, ...).
#
# -------------------------------------------------------------------------------------------------------------

import os
import sys
from pathlib import Path
import re

from common.console_colors import *

# Enable the coloring in the console
os.system("")


class Display:
	"""
	This class provides methods to print in the console
	Note:
		Method name starting by '_' are local to the class (ex:def _toto(...)).
		It should not be usually used by the user
	"""

	def __init__(self):
		"""
		This method initializes the class instance
		"""
		# Section separator definition
		self.char_section = '*'
		self.nb_char_section = 70
		# indentation definition
		self.char_indent = ' '
		self.nb_char_indent = 4

		self.script_name = ''

	def set_script_name(self, name_p):
		"""
		Set the script name
		:param name_p: (string) script name
		:return: None
		"""
		self.script_name = name_p
		return None

	def set_indent(self, char_p=' ', nb_char_p=4):
		"""
		This method set the indentation properties
		:param char_p: (character) indentation character (can be a string)
		:param nb_char_p: (integer >=0) Number of characters by level of indentation
		:return: None
		"""
		self.char_indent = char_p
		self.nb_char_indent = nb_char_p
		return None

	def set_section(self, char_p='*', nb_char_p=70):
		"""
		This method set the section properties.
		Note: the section properties allows to build separators for title, subtitle, ... in the console
		:param char_p: (character) section character (can be a string)
		:param nb_char_p: (integer >=0) Number of characters by section line
		:return: None
		"""
		self.char_section = char_p
		self.nb_char_section = nb_char_p
		return None

	def display_title(self, msg_p, level_p=0, color_p='yellow'):
		"""
		This method display a title to print in the console
		Ex:
		***********************************
		* msg
		***********************************
		:param msg_p: (string or list of string) message to print
		:param level_p: (integer >= 0) define the level of indentation of the message to print
		:param color_p: (string) define the message color. The list of colors can be found in the common.console_colors
		python library
		:return: None
		"""

		color = colors[color_p]
		color_rst = colors['reset']
		msg = self._convert_str_to_list(msg_p=msg_p)
		str_indent = self.char_indent * self.nb_char_indent * level_p
		str_char = self.char_section * self.nb_char_section
		str_sep = color + str_indent + str_char

		print('')
		print(str_sep)
		for m in msg:
			str0 = color + str_indent + ' ' + m
			print(str0)
		print(str_sep + color_rst)
		return None

	def display_subtitle(self, msg_p, level_p=0, color_p='yellow'):
		"""
		This method display a subtitle to print in the console
		Ex:
		* msg
		***********************************
		:param msg_p: (string or list of string) message to print
		:param level_p: (integer >= 0) define the level of indentation of the message to print
		:param color_p: (string) define the message color. The list of colors can be found in the common.console_colors
		python library
		:return: None
		"""

		color = colors[color_p]
		color_rst = colors['reset']
		msg = self._convert_str_to_list(msg_p=msg_p)
		str_indent = self.char_indent * self.nb_char_indent * level_p
		str_char = self.char_section * self.nb_char_section
		str_sep = color + str_indent + str_char

		print('')
		for m in msg:
			str0 = color + str_indent + ' ' + m
			print(str0)
		print(str_sep + color_rst)
		return None

	def display(self, msg_p, level_p=0, color_p='reset'):
		"""
		This method display a message to print in the console
		Ex:
		* msg
		***********************************
		:param msg_p: (string or list of string) message to print
		:param level_p: (integer >= 0) define the level of indentation of the message to print
		:param color_p: (string) define the message color. The list of colors can be found in the common.console_colors
		python library
		:return: None
		"""
		color = colors[color_p]
		color_rst = colors['reset']
		msg = self._convert_str_to_list(msg_p=msg_p)
		str_indent = self.char_indent * self.nb_char_indent * level_p

		for m in msg:
			str0 = color + str_indent + ' ' + m + color_rst
			print(str0)

		return None

	def _convert_str_to_list(self, msg_p):
		"""
		This method converts the input msg_p into a list of strings
		:param msg_p: (string or list of string) : message
		:return: list of string
		"""
		test = isinstance(msg_p, str)
		if test:
			msg = [msg_p]
		else:
			msg = msg_p
		return msg
