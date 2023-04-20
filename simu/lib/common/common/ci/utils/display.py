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

# standard library
import os

# user library
from .console_colors import ConsoleColors

# Enable the coloring in the console
os.system("")


class Display(ConsoleColors):
    """
    Provide methods to print in the console
    """

    def __init__(self):
        """
        Initialize the class instance.
        """
        super().__init__()
        # Section separator definition
        self._char_section = '*'
        # number of section separators
        self._nb_char_section = 70
        # indentation string
        self._char_indent = ' '
        # number of character by indentation level
        self._nb_char_indent = 4

        # self.script_name = ''

    # def set_script_name(self, name_p):
    #     """
    #     Define the script name.

    #     Parameters
    #     ----------
    #     name_p: str
    #         Script name

    #     Returns
    #     -------
    #     None

    #     """

    #     self.script_name = name_p
    #     return None

    def set_indent(self, char_p=' ', nb_char_p=4):
        """
        Define the indentation.

        Parameters
        ----------
        char_p: str
            indentation character.
        nb_char_p: int
            (integer >=0) Number of characters by level of indentation

        Returns
        -------
        None

        """
        self._char_indent = char_p
        self._nb_char_indent = nb_char_p
        return None

    def set_section(self, char_p='*', nb_char_p=70):
        """
        This method set the section properties.
        Note: the section properties allows to build separators for title, subtitle, ... in the console
        :param char_p: (character) section character (can be a string)
        :param nb_char_p: (integer >=0) Number of characters by section line
        :return: None
        """
        self._char_section = char_p
        self._nb_char_section = nb_char_p
        return None

    def display_title(self, msg_p, level_p=0, color_p='yellow'):
        """
        Print a title.
            Ex:
            *************************
            * Tile
            ************************

        Parameters
        ----------
        msg_p: str
            Message to print
        level_p: int
            Define the level of indentation of the message to print
        color_p: str
            Color to print.
            Note:
                . The list of colors can be found in the common.console_colors

        Returns
        -------
        None

        """

        color = self.get_color(name_p=color_p)
        color_rst = self.get_color(name_p='reset')

        msg = self._convert_str_to_list(msg_p=msg_p)
        str_indent = self._char_indent * self._nb_char_indent * level_p
        str_char = self._char_section * self._nb_char_section
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
        Print a subtitle.
            Ex:
            * subtitle
            ************************

        Parameters
        ----------
        msg_p: str
            Message to print
        level_p: int
            Define the level of indentation of the message to print
        color_p: str
            Color to print.
            Note:
                . The list of colors can be found in the common.console_colors

        Returns
        -------
        None

        """
        color = self.get_color(name_p=color_p)
        color_rst = self.get_color(name_p='reset')

        msg = self._convert_str_to_list(msg_p=msg_p)
        str_indent = self._char_indent * self._nb_char_indent * level_p
        str_char = self._char_section * self._nb_char_section
        str_sep = color + str_indent + str_char

        print('')
        for m in msg:
            str0 = color + str_indent + ' ' + m
            print(str0)
        print(str_sep + color_rst)
        return None

    def display(self, msg_p, level_p=0, color_p='reset'):
        """
        Print a message.

        Parameters
        ----------
        msg_p: str
            Message to print
        level_p: int
            Define the level of indentation of the message to print
        color_p: str
            Color to print.
            Note:
                . The list of colors can be found in the common.console_colors

        Returns
        -------
        None

        """
        color = self.get_color(name_p=color_p)
        color_rst = self.get_color(name_p='reset')
        msg = self._convert_str_to_list(msg_p=msg_p)
        str_indent = self._char_indent * self._nb_char_indent * level_p

        for m in msg:
            str0 = color + str_indent + ' ' + m + color_rst
            print(str0)

        return None

    @staticmethod
    def _convert_str_to_list(msg_p):
        """
        Convert the input msg_p into a list of strings.

        Parameters
        ----------
        msg_p: str of list of str
            message to convert
        Returns
        -------
        list of strings
        """

        test = isinstance(msg_p, str)
        if test:
            msg = [msg_p]
        else:
            msg = msg_p
        return msg
