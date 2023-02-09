The compile.do file defines all source files to compile (*.vhd,*.sv,*.v). If necessary, the user can edit the following variable:
   . PR_DIR: path to the fpasim project root
   . COMPIL_LIB_DIR: path to the Xilinx compiled library
   . VIVADO_DIR: path to the Vivado installation library

The elaborate.do file build the object to simulate and link the external libraries. The user can edit the files

The simulate.do file allows to launch the simulation.

To try the behaviour in the questa simulator, do the following steps:
	1. open Questa and type the following command in the console:
		2. cd @script_path
		3. do "@script_path/compile.do"
		4. do "@script_path/elaborate.do"
		5. do "@script_path/simulate.do"
Ex:
	cd "D:/fpasim-fw-hardware/simu/script/"
	do "compile.do"
	do "elaborate.do"
	do "simulate.do"

