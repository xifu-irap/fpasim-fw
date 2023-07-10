-- -------------------------------------------------------------------------------------------------------------
--                              Copyright (C) 2022-2030 Ken-ji de la Rosa, IRAP Toulouse.
-- -------------------------------------------------------------------------------------------------------------
--                              This file is part of the ATHENA X-IFU DRE Focal Plane Assembly simulator.
--
--                              fpasim-fw is free software: you can redistribute it and/or modify
--                              it under the terms of the GNU General Public License as published by
--                              the Free Software Foundation, either version 3 of the License, or
--                              (at your option) any later version.
--
--                              This program is distributed in the hope that it will be useful,
--                              but WITHOUT ANY WARRANTY; without even the implied warranty of
--                              MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--                              GNU General Public License for more details.
--
--                              You should have received a copy of the GNU General Public License
--                              along with this program.  If not, see <https://www.gnu.org/licenses/>.
-- -------------------------------------------------------------------------------------------------------------
--    email                   kenji.delarosa@alten.com
--    @file                   sdpram.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    The module is a wrapper of the Xilinx XPM Single Dual Port RAM
--    Note: the following header documentation is an extract of the associated XPM Xilinx header
--
-- -------------------------------------------------------------------------------------------------------------

-- -------------------------------------------------------------------------------------------------------------
-- XPM_MEMORY instantiation template for Simple Dual Port RAM configurations
-- Refer to the targeted device family architecture libraries guide for XPM_MEMORY documentation
-- =======================================================================================================================

-- Parameter usage table, organized as follows:
-- +---------------------------------------------------------------------------------------------------------------------+
-- | Parameter name       | Data type          | Restrictions, if applicable                                             |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Description                                                                                                         |
-- +---------------------------------------------------------------------------------------------------------------------+
-- +---------------------------------------------------------------------------------------------------------------------+
-- | ADDR_WIDTH_A         | Integer            | Range: 1 - 20. Default value = 6.                                       |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specify the width of the port A address port addra, in bits.                                                        |
-- | Must be large enough to access the entire memory from port A, i.e. &gt;= $clog2(MEMORY_SIZE/WRITE_DATA_WIDTH_A).    |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | ADDR_WIDTH_B         | Integer            | Range: 1 - 20. Default value = 6.                                       |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specify the width of the port B address port addrb, in bits.                                                        |
-- | Must be large enough to access the entire memory from port B, i.e. &gt;= $clog2(MEMORY_SIZE/READ_DATA_WIDTH_B).     |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | AUTO_SLEEP_TIME      | Integer            | Range: 0 - 15. Default value = 0.                                       |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Number of clk[a|b] cycles to auto-sleep, if feature is available in architecture.                                   |
-- |                                                                                                                     |
-- |   0 - Disable auto-sleep feature                                                                                    |
-- |   3-15 - Number of auto-sleep latency cycles                                                                        |
-- |                                                                                                                     |
-- | Do not change from the value provided in the template instantiation.                                                |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | BYTE_WRITE_WIDTH_A   | Integer            | Range: 1 - 4608. Default value = 32.                                    |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | To enable byte-wide writes on port A, specify the byte width, in bits.                                              |
-- |                                                                                                                     |
-- |   8- 8-bit byte-wide writes, legal when WRITE_DATA_WIDTH_A is an integer multiple of 8                              |
-- |   9- 9-bit byte-wide writes, legal when WRITE_DATA_WIDTH_A is an integer multiple of 9                              |
-- |                                                                                                                     |
-- | Or to enable word-wide writes on port A, specify the same value as for WRITE_DATA_WIDTH_A.                          |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | CASCADE_HEIGHT       | Integer            | Range: 0 - 64. Default value = 0.                                       |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | 0- No Cascade Height, Allow Vivado Synthesis to choose.                                                             |
-- | 1 or more - Vivado Synthesis sets the specified value as Cascade Height.                                            |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | CLOCKING_MODE        | String             | Allowed values: common_clock, independent_clock. Default value = common_clock.|
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Designate whether port A and port B are clocked with a common clock or with independent clocks.                     |
-- |                                                                                                                     |
-- |   "common_clock"- Common clocking; clock both port A and port B with clka                                           |
-- |   "independent_clock"- Independent clocking; clock port A with clka and port B with clkb                            |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | ECC_MODE             | String             | Allowed values: no_ecc, both_encode_and_decode, decode_only, encode_only. Default value = no_ecc.|
-- |---------------------------------------------------------------------------------------------------------------------|
-- |                                                                                                                     |
-- |   "no_ecc" - Disables ECC                                                                                           |
-- |   "encode_only" - Enables ECC Encoder only                                                                          |
-- |   "decode_only" - Enables ECC Decoder only                                                                          |
-- |   "both_encode_and_decode" - Enables both ECC Encoder and Decoder                                                   |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | MEMORY_INIT_FILE     | String             | Default value = none.                                                   |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specify "none" (including quotes) for no memory initialization, or specify the name of a memory initialization file.|
-- | Enter only the name of the file with .mem extension, including quotes but without path (e.g. "my_file.mem").        |
-- | File format must be ASCII and consist of only hexadecimal values organized into the specified depth by              |
-- | narrowest data width generic value of the memory. Initialization of memory happens through the file name specified only|
-- | when parameter MEMORY_INIT_PARAM value is equal to "".                                                              |
-- | When using XPM_MEMORY in a project, add the specified file to the Vivado project as a design source.                |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | MEMORY_INIT_PARAM    | String             | Default value = 0.                                                      |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specify "" or "0" (including quotes) for no memory initialization through parameter, or specify the string          |
-- | containing the hex characters. Enter only hex characters with each location separated by delimiter (,).             |
-- | Parameter format must be ASCII and consist of only hexadecimal values organized into the specified depth by         |
-- | narrowest data width generic value of the memory.For example, if the narrowest data width is 8, and the depth of    |
-- | memory is 8 locations, then the parameter value should be passed as shown below.                                    |
-- | parameter MEMORY_INIT_PARAM = "AB,CD,EF,1,2,34,56,78"                                                               |
-- | Where "AB" is the 0th location and "78" is the 7th location.                                                        |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | MEMORY_OPTIMIZATION  | String             | Allowed values: true, false. Default value = true.                      |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specify "true" to enable the optimization of unused memory or bits in the memory structure. Specify "false" to      |
-- | disable the optimization of unused memory or bits in the memory structure.                                          |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | MEMORY_PRIMITIVE     | String             | Allowed values: auto, block, distributed, mixed, ultra. Default value = auto.|
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Designate the memory primitive (resource type) to use.                                                              |
-- |                                                                                                                     |
-- |   "auto"- Allow Vivado Synthesis to choose                                                                          |
-- |   "distributed"- Distributed memory                                                                                 |
-- |   "block"- Block memory                                                                                             |
-- |   "ultra"- Ultra RAM memory                                                                                         |
-- |   "mixed"- Mixed memory                                                                                             |
-- |                                                                                                                     |
-- | NOTE: There may be a behavior mismatch if Block RAM or Ultra RAM specific features, like ECC or Asymmetry, are selected with MEMORY_PRIMITIVE set to "auto".|
-- +---------------------------------------------------------------------------------------------------------------------+
-- | MEMORY_SIZE          | Integer            | Range: 2 - 150994944. Default value = 2048.                             |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specify the total memory array size, in bits. For example, enter 65536 for a 2kx32 RAM.                             |
-- |                                                                                                                     |
-- |   When ECC is enabled and set to "encode_only", then the memory size has to be multiples of READ_DATA_WIDTH_B       |
-- |   When ECC is enabled and set to "decode_only", then the memory size has to be multiples of WRITE_DATA_WIDTH_A      |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | MESSAGE_CONTROL      | Integer            | Range: 0 - 1. Default value = 0.                                        |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specify 1 to enable the dynamic message reporting such as collision warnings, and 0 to disable the message reporting|
-- +---------------------------------------------------------------------------------------------------------------------+
-- | READ_DATA_WIDTH_B    | Integer            | Range: 1 - 4608. Default value = 32.                                    |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specify the width of the port B read data output port doutb, in bits.                                               |
-- |                                                                                                                     |
-- |   When ECC is enabled and set to "encode_only", then READ_DATA_WIDTH_B has to be multiples of 72-bits               |
-- |   When ECC is enabled and set to "decode_only" or "both_encode_and_decode", then READ_DATA_WIDTH_B has to be        |
-- | multiples of 64-bits                                                                                                |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | READ_LATENCY_B       | Integer            | Range: 0 - 100. Default value = 2.                                      |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specify the number of register stages in the port B read data pipeline. Read data output to port doutb takes this   |
-- | number of clkb cycles (clka when CLOCKING_MODE is "common_clock").                                                  |
-- | To target block memory, a value of 1 or larger is required- 1 causes use of memory latch only; 2 causes use of      |
-- | output register. To target distributed memory, a value of 0 or larger is required- 0 indicates combinatorial output.|
-- | Values larger than 2 synthesize additional flip-flops that are not retimed into memory primitives.                  |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | READ_RESET_VALUE_B   | String             | Default value = 0.                                                      |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specify the reset value of the port B final output register stage in response to rstb input port is assertion.      |
-- | As this parameter is a string, please specify the hex values inside double quotes. As an example,                   |
-- | If the read data width is 8, then specify READ_RESET_VALUE_B = "EA";                                                |
-- | When ECC is enabled, reset value is not supported.                                                                  |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | RST_MODE_A           | String             | Allowed values: SYNC, ASYNC. Default value = SYNC.                      |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Describes the behaviour of the reset                                                                                |
-- |                                                                                                                     |
-- |   "SYNC" - when reset is applied, synchronously resets output port douta to the value specified by parameter READ_RESET_VALUE_A|
-- |   "ASYNC" - when reset is applied, asynchronously resets output port douta to zero                                  |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | RST_MODE_B           | String             | Allowed values: SYNC, ASYNC. Default value = SYNC.                      |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Describes the behaviour of the reset                                                                                |
-- |                                                                                                                     |
-- |   "SYNC" - when reset is applied, synchronously resets output port doutb to the value specified by parameter READ_RESET_VALUE_B|
-- |   "ASYNC" - when reset is applied, asynchronously resets output port doutb to zero                                  |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | SIM_ASSERT_CHK       | Integer            | Range: 0 - 1. Default value = 0.                                        |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | 0- Disable simulation message reporting. Messages related to potential misuse will not be reported.                 |
-- | 1- Enable simulation message reporting. Messages related to potential misuse will be reported.                      |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | USE_EMBEDDED_CONSTRAINT| Integer            | Range: 0 - 1. Default value = 0.                                        |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specify 1 to enable the set_false_path constraint addition between clka of Distributed RAM and doutb_reg on clkb    |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | USE_MEM_INIT         | Integer            | Range: 0 - 1. Default value = 1.                                        |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specify 1 to enable the generation of below message and 0 to disable generation of the following message completely.|
-- | "INFO - MEMORY_INIT_FILE and MEMORY_INIT_PARAM together specifies no memory initialization.                         |
-- | Initial memory contents will be all 0s."                                                                            |
-- | NOTE: This message gets generated only when there is no Memory Initialization specified either through file or      |
-- | Parameter.                                                                                                          |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | USE_MEM_INIT_MMI     | Integer            | Range: 0 - 1. Default value = 0.                                        |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specify 1 to expose this memory information to be written out in the MMI file.                                      |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | WAKEUP_TIME          | String             | Allowed values: disable_sleep, use_sleep_pin. Default value = disable_sleep.|
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specify "disable_sleep" to disable dynamic power saving option, and specify "use_sleep_pin" to enable the           |
-- | dynamic power saving option                                                                                         |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | WRITE_DATA_WIDTH_A   | Integer            | Range: 1 - 4608. Default value = 32.                                    |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specify the width of the port A write data input port dina, in bits.                                                |
-- | The values of WRITE_DATA_WIDTH_A and READ_DATA_WIDTH_A must be equal.                                               |
-- | When ECC is enabled and set to "encode_only" or "both_encode_and_decode", then WRITE_DATA_WIDTH_A must be           |
-- | multiples of 64-bits.                                                                                               |
-- | When ECC is enabled and set to "decode_only", then WRITE_DATA_WIDTH_A must be multiples of 72-bits.                 |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | WRITE_MODE_B         | String             | Allowed values: no_change, read_first, write_first. Default value = no_change.|
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Write mode behavior for port B output data port, doutb.                                                             |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | WRITE_PROTECT        | Integer            | Range: 0 - 1. Default value = 1.                                        |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Default value is 1, means write is protected through enable and write enable and hence the LUT is placed before the memory. This is the default behaviour to access memory.|
-- | When 0, disables write protection. Write enable (WE) directly connected to memory.                                  |
-- | NOTE: Disable this option only if the advanced users can guarantee that the write enable (WE) cannot be given without enable (EN).|
-- +---------------------------------------------------------------------------------------------------------------------+

-- Port usage table, organized as follows:
-- +---------------------------------------------------------------------------------------------------------------------+
-- | Port name      | Direction | Size, in bits                         | Domain  | Sense       | Handling if unused     |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Description                                                                                                         |
-- +---------------------------------------------------------------------------------------------------------------------+
-- +---------------------------------------------------------------------------------------------------------------------+
-- | addra          | Input     | ADDR_WIDTH_A                          | clka    | NA          | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Address for port A write operations.                                                                                |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | addrb          | Input     | ADDR_WIDTH_B                          | clkb    | NA          | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Address for port B read operations.                                                                                 |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | clka           | Input     | 1                                     | NA      | Rising edge | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".                         |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | clkb           | Input     | 1                                     | NA      | Rising edge | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Clock signal for port B when parameter CLOCKING_MODE is "independent_clock".                                        |
-- | Unused when parameter CLOCKING_MODE is "common_clock".                                                              |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | dbiterrb       | Output    | 1                                     | clkb    | Active-high | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Status signal to indicate double bit error occurrence on the data output of port B.                                 |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | dina           | Input     | WRITE_DATA_WIDTH_A                    | clka    | NA          | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Data input for port A write operations.                                                                             |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | doutb          | Output    | READ_DATA_WIDTH_B                     | clkb    | NA          | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Data output for port B read operations.                                                                             |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | ena            | Input     | 1                                     | clka    | Active-high | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Memory enable signal for port A.                                                                                    |
-- | Must be high on clock cycles when write operations are initiated. Pipelined internally.                             |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | enb            | Input     | 1                                     | clkb    | Active-high | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Memory enable signal for port B.                                                                                    |
-- | Must be high on clock cycles when read operations are initiated. Pipelined internally.                              |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | injectdbiterra | Input     | 1                                     | clka    | Active-high | Tie to 1'b0            |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in  |
-- | "decode_only" mode).                                                                                                |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | injectsbiterra | Input     | 1                                     | clka    | Active-high | Tie to 1'b0            |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in  |
-- | "decode_only" mode).                                                                                                |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | regceb         | Input     | 1                                     | clkb    | Active-high | Tie to 1'b1            |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Clock Enable for the last register stage on the output data path.                                                   |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | rstb           | Input     | 1                                     | clkb    | Active-high | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Reset signal for the final port B output register stage.                                                            |
-- | Synchronously resets output port doutb to the value specified by parameter READ_RESET_VALUE_B.                      |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | sbiterrb       | Output    | 1                                     | clkb    | Active-high | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Status signal to indicate single bit error occurrence on the data output of port B.                                 |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | sleep          | Input     | 1                                     | NA      | Active-high | Tie to 1'b0            |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | sleep signal to enable the dynamic power saving feature.                                                            |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | wea            | Input     | WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A | clka    | Active-high | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are used.                     |
-- | In byte-wide write configurations, each bit controls the writing one byte of dina to address addra.                 |
-- | For example, to synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.   |
-- +---------------------------------------------------------------------------------------------------------------------+

library ieee;
use ieee.std_logic_1164.all;

library xpm;
use xpm.vcomponents.all;

---------------------------------------------------------------------
-- Simple Dual Port RAM
---------------------------------------------------------------------
entity sdpram is
  generic(
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | ADDR_WIDTH_A         | Integer            | Range: 1 - 20. Default value = 6.                                       |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Specify the width of the port A address port addra, in bits.                                                        |
    -- | Must be large enough to access the entire memory from port A, i.e. &gt;= $clog2(MEMORY_SIZE/WRITE_DATA_WIDTH_A).    |
    g_ADDR_WIDTH_A       : integer := 32;
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | BYTE_WRITE_WIDTH_A   | Integer            | Range: 1 - 4608. Default value = 32.                                    |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | To enable byte-wide writes on port A, specify the byte width, in bits.                                              |
    -- |                                                                                                                     |
    -- |   8- 8-bit byte-wide writes, legal when WRITE_DATA_WIDTH_A is an integer multiple of 8                              |
    -- |   9- 9-bit byte-wide writes, legal when WRITE_DATA_WIDTH_A is an integer multiple of 9                              |
    -- |                                                                                                                     |
    -- | Or to enable word-wide writes on port A, specify the same value as for WRITE_DATA_WIDTH_A.                          |
    g_BYTE_WRITE_WIDTH_A : integer := 32;
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | WRITE_DATA_WIDTH_A   | Integer            | Range: 1 - 4608. Default value = 32.                                    |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Specify the width of the port A write data input port dina, in bits.                                                |
    -- | The values of WRITE_DATA_WIDTH_A and READ_DATA_WIDTH_A must be equal.                                               |
    -- | When ECC is enabled and set to "encode_only" or "both_encode_and_decode", then WRITE_DATA_WIDTH_A must be           |
    -- | multiples of 64-bits.                                                                                               |
    -- | When ECC is enabled and set to "decode_only", then WRITE_DATA_WIDTH_A must be multiples of 72-bits.                 |
    g_WRITE_DATA_WIDTH_A : integer := 1;
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | ADDR_WIDTH_B         | Integer            | Range: 1 - 20. Default value = 6.                                       |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Specify the width of the port B address port addrb, in bits.                                                        |
    -- | Must be large enough to access the entire memory from port B, i.e. &gt;= $clog2(MEMORY_SIZE/READ_DATA_WIDTH_B).     |
    g_ADDR_WIDTH_B       : integer := 32;
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | WRITE_MODE_B         | String             | Allowed values: no_change, read_first, write_first. Default value = no_change.|
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Write mode behavior for port B output data port, doutb.                                                             |
    g_WRITE_MODE_B       : string  := "no_change";
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | READ_DATA_WIDTH_B    | Integer            | Range: 1 - 4608. Default value = 32.                                    |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Specify the width of the port B read data output port doutb, in bits.                                               |
    -- |                                                                                                                     |
    -- |   When ECC is enabled and set to "encode_only", then READ_DATA_WIDTH_B has to be multiples of 72-bits               |
    -- |   When ECC is enabled and set to "decode_only" or "both_encode_and_decode", then READ_DATA_WIDTH_B has to be        |
    -- | multiples of 64-bits                                                                                                |
    g_READ_DATA_WIDTH_B  : integer := 32;
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | READ_LATENCY_B       | Integer            | Range: 0 - 100. Default value = 2.                                      |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Specify the number of register stages in the port B read data pipeline. Read data output to port doutb takes this   |
    -- | number of clkb cycles (clka when CLOCKING_MODE is "common_clock").                                                  |
    -- | To target block memory, a value of 1 or larger is required- 1 causes use of memory latch only; 2 causes use of      |
    -- | output register. To target distributed memory, a value of 0 or larger is required- 0 indicates combinatorial output.|
    -- | Values larger than 2 synthesize additional flip-flops that are not retimed into memory primitives.                  |
    g_READ_LATENCY_B     : integer := 0;
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | READ_RESET_VALUE_B   | String             | Default value = 0.                                                      |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Specify the reset value of the port B final output register stage in response to rstb input port is assertion.      |
    -- | As this parameter is a string, please specify the hex values inside double quotes. As an example,                   |
    -- | If the read data width is 8, then specify READ_RESET_VALUE_B = "EA";                                                |
    -- | When ECC is enabled, reset value is not supported.                                                                  |
    -- g_READ_RESET_VALUE_B : string := "0";

    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | CLOCKING_MODE        | String             | Allowed values: common_clock, independent_clock. Default value = common_clock.|
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Designate whether port A and port B are clocked with a common clock or with independent clocks.                     |
    -- |                                                                                                                     |
    -- |   "common_clock"- Common clocking; clock both port A and port B with clka                                           |
    -- |   "independent_clock"- Independent clocking; clock port A with clka and port B with clkb                            |
    g_CLOCKING_MODE      : string  := "common_clock";
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | MEMORY_PRIMITIVE     | String             | Allowed values: auto, block, distributed, mixed, ultra. Default value = auto.|
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Designate the memory primitive (resource type) to use.                                                              |
    -- |                                                                                                                     |
    -- |   "auto"- Allow Vivado Synthesis to choose                                                                          |
    -- |   "distributed"- Distributed memory                                                                                 |
    -- |   "block"- Block memory                                                                                             |
    -- |   "ultra"- Ultra RAM memory                                                                                         |
    -- |   "mixed"- Mixed memory                                                                                             |
    -- |                                                                                                                     |
    -- | NOTE: There may be a behavior mismatch if Block RAM or Ultra RAM specific features, like ECC or Asymmetry, are selected with MEMORY_PRIMITIVE set to "auto".|
    g_MEMORY_PRIMITIVE   : string  := "auto";
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | MEMORY_SIZE          | Integer            | Range: 2 - 150994944. Default value = 2048.                             |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Specify the total memory array size, in bits. For example, enter 65536 for a 2kx32 RAM.                             |
    -- |                                                                                                                     |
    -- |   When ECC is enabled and set to "encode_only", then the memory size has to be multiples of READ_DATA_WIDTH_B       |
    -- |   When ECC is enabled and set to "decode_only", then the memory size has to be multiples of WRITE_DATA_WIDTH_A      |
    g_MEMORY_SIZE        : integer := 16365;
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | MEMORY_INIT_FILE     | String             | Default value = none.                                                   |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Specify "none" (including quotes) for no memory initialization, or specify the name of a memory initialization file.|
    -- | Enter only the name of the file with .mem extension, including quotes but without path (e.g. "my_file.mem").        |
    -- | File format must be ASCII and consist of only hexadecimal values organized into the specified depth by              |
    -- | narrowest data width generic value of the memory. Initialization of memory happens through the file name specified only|
    -- | when parameter MEMORY_INIT_PARAM value is equal to "".                                                              |
    -- | When using XPM_MEMORY in a project, add the specified file to the Vivado project as a design source.                |
    g_MEMORY_INIT_FILE   : string  := "none";
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | MEMORY_INIT_PARAM    | String             | Default value = 0.                                                      |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Specify "" or "0" (including quotes) for no memory initialization through parameter, or specify the string          |
    -- | containing the hex characters. Enter only hex characters with each location separated by delimiter (,).             |
    -- | Parameter format must be ASCII and consist of only hexadecimal values organized into the specified depth by         |
    -- | narrowest data width generic value of the memory.For example, if the narrowest data width is 8, and the depth of    |
    -- | memory is 8 locations, then the parameter value should be passed as shown below.                                    |
    -- | parameter MEMORY_INIT_PARAM = "AB,CD,EF,1,2,34,56,78"                                                               |
    -- | Where "AB" is the 0th location and "78" is the 7th location.                                                        |
    g_MEMORY_INIT_PARAM  : string  := "0"
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | ECC_MODE             | String             | Allowed values: no_ecc, both_encode_and_decode, decode_only, encode_only. Default value = no_ecc.|
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- |                                                                                                                     |
    -- |   "no_ecc" - Disables ECC                                                                                           |
    -- |   "encode_only" - Enables ECC Encoder only                                                                          |
    -- |   "decode_only" - Enables ECC Decoder only                                                                          |
    -- |   "both_encode_and_decode" - Enables both ECC Encoder and Decoder                                                   |
    -- g_ECC_MODE : string := "no_ecc";
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | MEMORY_OPTIMIZATION  | String             | Allowed values: true, false. Default value = true.                      |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Specify "true" to enable the optimization of unused memory or bits in the memory structure. Specify "false" to      |
    -- | disable the optimization of unused memory or bits in the memory structure.                                          |
    -- g_MEMORY_OPTIMIZATION : string := "true";

    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | RST_MODE_A           | String             | Allowed values: SYNC, ASYNC. Default value = SYNC.                      |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Describes the behaviour of the reset                                                                                |
    -- |                                                                                                                     |
    -- |   "SYNC" - when reset is applied, synchronously resets output port douta to the value specified by parameter READ_RESET_VALUE_A|
    -- |   "ASYNC" - when reset is applied, asynchronously resets output port douta to zero                                  |
    -- g_RST_MODE_A : string := "SYNC";
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | RST_MODE_B           | String             | Allowed values: SYNC, ASYNC. Default value = SYNC.                      |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Describes the behaviour of the reset                                                                                |
    -- |                                                                                                                     |
    -- |   "SYNC" - when reset is applied, synchronously resets output port doutb to the value specified by parameter READ_RESET_VALUE_B|
    -- |   "ASYNC" - when reset is applied, asynchronously resets output port doutb to zero                                  |
    -- g_RST_MODE_B : string := "SYNC";

    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | MESSAGE_CONTROL      | Integer            | Range: 0 - 1. Default value = 0.                                        |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Specify 1 to enable the dynamic message reporting such as collision warnings, and 0 to disable the message reporting|
    -- g_MESSAGE_CONTROL : integer := 0;
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | SIM_ASSERT_CHK       | Integer            | Range: 0 - 1. Default value = 0.                                        |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | 0- Disable simulation message reporting. Messages related to potential misuse will not be reported.                 |
    -- | 1- Enable simulation message reporting. Messages related to potential misuse will be reported.                      |
    -- g_SIM_ASSERT_CHK : integer := 0;
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | USE_EMBEDDED_CONSTRAINT| Integer            | Range: 0 - 1. Default value = 0.                                        |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Specify 1 to enable the set_false_path constraint addition between clka of Distributed RAM and doutb_reg on clkb    |
    -- g_USE_EMBEDDED_CONSTRAINT : integer := 1;
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | USE_MEM_INIT         | Integer            | Range: 0 - 1. Default value = 1.                                        |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Specify 1 to enable the generation of below message and 0 to disable generation of the following message completely.|
    -- | "INFO - MEMORY_INIT_FILE and MEMORY_INIT_PARAM together specifies no memory initialization.                         |
    -- | Initial memory contents will be all 0s."                                                                            |
    -- | NOTE: This message gets generated only when there is no Memory Initialization specified either through file or      |
    -- | Parameter.                                                                                                          |
    -- g_USE_MEM_INIT : integer := 1;
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | USE_MEM_INIT_MMI     | Integer            | Range: 0 - 1. Default value = 0.                                        |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Specify 1 to expose this memory information to be written out in the MMI file.                                      |
    -- g_USE_MEM_INIT_MMI : integer := 0;
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | AUTO_SLEEP_TIME      | Integer            | Range: 0 - 15. Default value = 0.                                       |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Number of clk[a|b] cycles to auto-sleep, if feature is available in architecture.                                   |
    -- |                                                                                                                     |
    -- |   0 - Disable auto-sleep feature                                                                                    |
    -- |   3-15 - Number of auto-sleep latency cycles                                                                        |
    -- |                                                                                                                     |
    -- | Do not change from the value provided in the template instantiation.
    -- g_AUTO_SLEEP_TIME : integer := 0;
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | CASCADE_HEIGHT       | Integer            | Range: 0 - 64. Default value = 0.                                       |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | 0- No Cascade Height, Allow Vivado Synthesis to choose.                                                             |
    -- | 1 or more - Vivado Synthesis sets the specified value as Cascade Height.                                            |
    -- g_CASCADE_HEIGHT : integer := 0;
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | WAKEUP_TIME          | String             | Allowed values: disable_sleep, use_sleep_pin. Default value = disable_sleep.|
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Specify "disable_sleep" to disable dynamic power saving option, and specify "use_sleep_pin" to enable the           |
    -- | dynamic power saving option                                                                                         |
    -- g_WAKEUP_TIME : string := "disable_sleep";
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | WRITE_PROTECT        | Integer            | Range: 0 - 1. Default value = 1.                                        |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Default value is 1, means write is protected through enable and write enable and hence the LUT is placed before the memory. This is the default behaviour to access memory.|
    -- | When 0, disables write protection. Write enable (WE) directly connected to memory.                                  |
    -- | NOTE: Disable this option only if the advanced users can guarantee that the write enable (WE) cannot be given without enable (EN).|
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- g_WRITE_PROTECT : integer := 1

  );
  port(
    ---------------------------------------------------------------------
    -- port A
    ---------------------------------------------------------------------
    i_clka   : in  std_logic;           -- clock
    i_ena    : in  std_logic;           -- memory enable
    i_wea    : in  std_logic_vector(g_WRITE_DATA_WIDTH_A / g_BYTE_WRITE_WIDTH_A - 1 downto 0); -- write enable
    i_addra  : in  std_logic_vector(g_ADDR_WIDTH_A - 1 downto 0); -- write address
    i_dina   : in  std_logic_vector(g_WRITE_DATA_WIDTH_A - 1 downto 0); -- write data input

    ---------------------------------------------------------------------
    -- port B
    ---------------------------------------------------------------------
    i_rstb   : in  std_logic;           -- reset the ouput register
    i_clkb   : in  std_logic;           -- clock
    i_enb    : in  std_logic;           -- memory enable
    i_addrb  : in  std_logic_vector(g_ADDR_WIDTH_B - 1 downto 0); -- read address
    i_regceb : in  std_logic;           -- clock enable for the last register stage on the output data path
    o_doutb  : out std_logic_vector(g_READ_DATA_WIDTH_B - 1 downto 0) -- read data output
  );
end entity sdpram;

architecture RTL of sdpram is

  ---------------------------------------------------------------------
  -- error injection
  ---------------------------------------------------------------------
  signal injectdbiterra : std_logic := '0';
  signal injectsbiterra : std_logic := '0';

  ---------------------------------------------------------------------
  -- error status
  ---------------------------------------------------------------------
  --signal sbiterrb       : std_logic;
  --signal dbiterrb       : std_logic;

  signal sleep : std_logic := '0';

  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  signal data_b : std_logic_vector(o_doutb'range);

begin

  sleep          <= '0';
  injectdbiterra <= '0';
  injectsbiterra <= '0';

  ---------------------------------------------------------------------
  -- xilinx template
  ---------------------------------------------------------------------
  inst_xpm_memory_sdpram : xpm_memory_sdpram
    generic map(
      ADDR_WIDTH_A            => g_ADDR_WIDTH_A, -- DECIMAL
      ADDR_WIDTH_B            => g_ADDR_WIDTH_B, -- DECIMAL
      AUTO_SLEEP_TIME         => 0,     -- DECIMAL
      BYTE_WRITE_WIDTH_A      => g_BYTE_WRITE_WIDTH_A, -- DECIMAL
      CASCADE_HEIGHT          => 0,     -- DECIMAL
      CLOCKING_MODE           => g_CLOCKING_MODE, -- String
      ECC_MODE                => "no_ecc", -- String
      MEMORY_INIT_FILE        => g_MEMORY_INIT_FILE, -- String
      MEMORY_INIT_PARAM       => g_MEMORY_INIT_PARAM, -- String
      MEMORY_OPTIMIZATION     => "true", -- String
      MEMORY_PRIMITIVE        => g_MEMORY_PRIMITIVE, -- String
      MEMORY_SIZE             => g_MEMORY_SIZE, -- DECIMAL
      MESSAGE_CONTROL         => 0,     -- DECIMAL
      READ_DATA_WIDTH_B       => g_READ_DATA_WIDTH_B, -- DECIMAL
      READ_LATENCY_B          => g_READ_LATENCY_B, -- DECIMAL
      READ_RESET_VALUE_B      => "0",   -- String
      RST_MODE_A              => "SYNC", -- String
      RST_MODE_B              => "SYNC", -- String
      SIM_ASSERT_CHK          => 1,     -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      USE_EMBEDDED_CONSTRAINT => 0,     -- DECIMAL
      USE_MEM_INIT            => 1,     -- DECIMAL
      USE_MEM_INIT_MMI        => 0,     -- DECIMAL
      WAKEUP_TIME             => "disable_sleep", -- String
      WRITE_DATA_WIDTH_A      => g_WRITE_DATA_WIDTH_A, -- DECIMAL
      WRITE_MODE_B            => g_WRITE_MODE_B, -- String
      WRITE_PROTECT           => 1      -- DECIMAL
    )
    port map(
      ---------------------------------------------------------------------
      -- port A
      ---------------------------------------------------------------------
      clka           => i_clka,         -- 1-bit input: Clock signal for port A. Also clocks port B when
      -- parameter CLOCKING_MODE is "common_clock".
      wea            => i_wea,          -- WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector
      ena            => i_ena,          -- 1-bit input: Memory enable signal for port A. Must be high on clock
      -- cycles when write operations are initiated. Pipelined internally.
      addra          => i_addra,        -- ADDR_WIDTH_A-bit input: Address for port A write operations.
      dina           => i_dina,         -- WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
      -- for port A input data port dina. 1 bit wide when word-wide writes
      -- are used. In byte-wide write configurations, each bit controls the
      -- writing one byte of dina to address addra. For example, to
      -- synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A
      -- is 32, wea would be 4'b0010.

      ---------------------------------------------------------------------
      -- port B
      ---------------------------------------------------------------------
      rstb           => i_rstb,         -- 1-bit input: Reset signal for the final port B output register
      -- stage. Synchronously resets output port doutb to the value specified
      -- by parameter READ_RESET_VALUE_B.
      clkb           => i_clkb,         -- 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is
      -- "independent_clock". Unused when parameter CLOCKING_MODE is
      -- "common_clock".
      enb            => i_enb,          -- 1-bit input: Memory enable signal for port B. Must be high on clock
      -- cycles when read operations are initiated. Pipelined internally.
      addrb          => i_addrb,        -- ADDR_WIDTH_B-bit input: Address for port B read operations.

      regceb         => i_regceb,       -- 1-bit input: Clock Enable for the last register stage on the output
      -- data path.
      doutb          => data_b,         -- READ_DATA_WIDTH_B-bit output: Data output for port B read operations.

      ---------------------------------------------------------------------
      -- below: signals aren't connected
      ---------------------------------------------------------------------
      injectdbiterra => injectdbiterra, -- 1-bit input: Controls double bit error injection on input data when
      -- ECC enabled (Error injection capability is not available in
      -- "decode_only" mode).

      injectsbiterra => injectsbiterra, -- 1-bit input: Controls single bit error injection on input data when
      -- ECC enabled (Error injection capability is not available in
      -- "decode_only" mode).

      dbiterrb       => open,           -- 1-bit output: Status signal to indicate double bit error occurrence
      -- on the data output of port B.

      sbiterrb       => open,           -- 1-bit output: Status signal to indicate single bit error occurrence
      -- on the data output of port B.

      sleep          => sleep           -- 1-bit input: sleep signal to enable the dynamic power saving feature.

    );

  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_doutb <= data_b;

end architecture RTL;
