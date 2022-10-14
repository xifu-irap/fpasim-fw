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
#!   @file                   launch_sim.py
# -------------------------------------------------------------------------------------------------------------
#    Automatic Generation    No
#    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
# -------------------------------------------------------------------------------------------------------------
#!   @details                
# This module is the fpga top level
# -------------------------------------------------------------------------------------------------------------




# standard library
import sys
import argparse
import os
from pathlib import Path
import subprocess

# Json lib
import json

# get the name of the script name without file extension
script_name = str(Path(__file__).stem)


if __name__ == '__main__':

	####################################
	# parse command line
	####################################
	parser = argparse.ArgumentParser(description='Launch some test_list')
	# add an optional argument with limited choices
	parser.add_argument('--simulator','-s', default='questa', choices = ['modelsim','questa'],  help='Specify the VHDL simulator to use (must be VHDL 2008 compatible).')
	# add an optional argument with a list of values
	parser.add_argument('--test_name_list','-t', default='test_tmp',metavar = 'test_name_list',  nargs = '*', help='define a list of test_list name to simulate. These test_list names are defined in the launch_sim.json file')
	# add an optional argument 
	parser.add_argument('-gui', default='false',choices = ['true','false'], help='Specify if the simulator is in gui mode or not. Possible values: true or false')
	# add an optional argument
	parser.add_argument('-v', default=0,choices = [0,1,2], type = int, help='Specify the verbosity level. Possible values (uint): 0 to 2')

	args = parser.parse_args()

	simulator = args.simulator
	test_name_list  = args.test_name_list
	gui  = args.gui
	verbosity  = args.v
	sep = os.sep

	json_filepath_input = './launch_sim.json'
	json_filepath_output = './launch_sim_processed.json'

	# convert path to absolute path
	json_filepath_input = str(Path(json_filepath_input).resolve())
	json_filepath_output = str(Path(json_filepath_output).resolve())

	# get the root path of this file
	root_path = str(Path(__file__).parent)

	# Opening JSON file
	fid_in = open(json_filepath_input,'r')
	fid_out = open(json_filepath_output,'w')

	# returns JSON object as 
	# a dictionary
	json_data = json.load(fid_in)

	# Closing file
	fid_in.close()

	
	########################################
	# dynamically overwrite path
	########################################
	# overwrite the launch_sim_path/path
	json_data["launch_sim_path"]["path"] = root_path

	# overwrite the vunit_path/path with the environment variable: VUNIT_PATH (if exist)
	tmp = os.environ.get('VUNIT_PATH')
	if tmp == None:
		tmp = ""
	json_data["vunit_path"]["path"] = tmp

	# overwrite the modelsim_path/path with the environment variable: MODELSIM_PATH (if exist)
	tmp = os.environ.get('MODELSIM_PATH')
	if tmp == None:
		tmp = ""
	json_data["modelsim_path"]["path"] = tmp

	# overwrite the questa_path/path with the environment variable: QUESTA_PATH (if exist)
	tmp = os.environ.get('QUESTA_PATH')
	if tmp == None:
		tmp = ""
	json_data["questa_path"]["path"] = tmp

	# overwrite the modelsim_xilinx_compil_lib_path/path with the environment variable: MODELSIM_XILINX_COMPIL_LIB_PATH (if exist)
	tmp = os.environ.get('modelsim_xilinx_compil_lib_path')
	if tmp == None:
		tmp = ""
	json_data["modelsim_xilinx_compil_lib_path"]["path"] = tmp

	# overwrite the questa_xilinx_compil_lib_path/path with the environment variable: QUESTA_XILINX_COMPIL_LIB_PATH (if exist)
	tmp = os.environ.get('questa_xilinx_compil_lib_path')
	if tmp == None:
		tmp = ""
	json_data["questa_xilinx_compil_lib_path"]["path"] = tmp


	# overwrite all lib/vhdl/path parameters
	tmp_list = json_data["lib"]["vhdl"]
	for dic in tmp_list:
		path = str(Path(dic["path"]))
		dic["path"] = path.replace('@launch_sim_path',root_path)

	# overwrite all lib/python/path parameters
	tmp_list = json_data["lib"]["python"]
	for dic in tmp_list:
		path = str(Path(dic["path"]))
		dic["path"] = path.replace('@launch_sim_path',root_path)

	# overwrite all test_list/conf/json_basepath parameters
	tmp_list = json_data["test_list"]
	for dic in tmp_list:
		json_filepath_list = dic["conf"]["json_filepath_list"]
		res = []
		for json_filepath in json_filepath_list:
			path = str(Path(json_filepath))
			path = path.replace('@launch_sim_path',root_path)
			res.append(path)
		dic["conf"]["json_filepath_list"] = res

	# overwrite all test_list/vunit/basepath parameters
	tmp_list = json_data["test_list"]
	for dic in tmp_list:
		path = str(Path(dic["vunit"]["filepath"]))
		dic["vunit"]["filepath"] = path.replace('@launch_sim_path',root_path)

	# overwrite all test_list/vunit/basepath_output parameters
	tmp_list = json_data["test_list"]
	for dic in tmp_list:
		path = str(Path(dic["vunit"]["basepath_output"]))
		dic["vunit"]["basepath_output"] = path.replace('@launch_sim_path',root_path)

	# print(json_data.keys())


	##################################
	# output the processed json file with updated address path
	##################################
	# Serializing then json dictionnary
	json_object = json.dumps(json_data, indent=4)
	# Writing to the output json file
	fid_out.write(json_object)
	fid_out.close()


	########################################
	# display debug message
	########################################
	if verbosity == 2:
		h0 = '*'*20
		indent = ' '*4
		print(h0)
		print(indent + __file__ + ': processing in progress')
		print(indent*2 + 'input file: '+ json_filepath_input )
		print(indent*2 + 'output file: '+ json_filepath_output)

	########################################
	# add python library path
	########################################
	vunit_path = str(Path('D:\\fpasim-fw-hardware\\simu\\lib\\python\\vunit\\vunit'))
	vunit_path = str(Path('D:\\fpasim-fw-hardware\\simu\\lib\\python\\vunit'))
	sys.path.append(vunit_path)


	#########################################
	# Execute the sequence of test_list
	#########################################
	for test_name in test_name_list:
		test_list = json_data["test_list"]
		# search in test_list a name with test_name value
		for dic in test_list:
			name = dic.get('name')
			if name == None:
				print('['+script_name+']: '+'ERROR: the test '+name+" doesn't exist")
				continue
			if name == test_name:
				vunit_file_path = str(Path(dic['vunit']['filepath'])) 
				output_path = str(Path(dic['vunit']['basepath_output']))
				cmd = []
				# call python
				cmd.append('python')

				# specify the run file to launch
				cmd.append(vunit_file_path)
				
				# specify the test_name
				# cmd.append('--test_name')
				# cmd.append(test_name)

				# specify the vhdl simulator to use
				cmd.append('--simulator')
				cmd.append(simulator)
				# # specify the verbosity
				cmd.append('--verbosity')
				cmd.append(str(verbosity))
				# # specify if the gui mode of the simulator is activated
				cmd.append('-gui')
				cmd.append(gui)

				subprocess.run(cmd)
				continue





	
	  
	
	  
	  
	
