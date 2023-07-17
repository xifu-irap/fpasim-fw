The amp_squid_top_test_list.xlsx file is a summary of the available test variant.
This file describes 2 type of tests:
  . nominal case
  . debug case

The test variant file associated to the nominal case follows the following file pattern "*_func*.json".
The test parameters are compatible with the nominal case for the minimal, maximal and the classical number of pixels by frame. 
Some time are necessary to complete the VHDL simulation.

The test variant file associated to the debug case follows the following file pattern "*_debug*.json".
The VHDL simulation is faster than the nominal case. The tests are configured to test particular/limit cases.

