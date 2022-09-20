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
--!   @file                   fifo_async_with_error_prog_full.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--!   
--!   This module intanciates an asynchronuous FIFO with the empty, full and prog full flags
--!   This module generates 4 types of errors in the following cases:
--!     . a writting when the FIFO is full
--!     . a writting when the FIFO is in a reset state
--!     . a reading when the FIFO is empty
--!     . a reading when the FIFO is in a reset state
--!   Via generics parameters, the user can select in which clock domain the error/empty flags are resynchronized. I.e,
--!       1. the write clock domain
--!       2. or the read clock domain
--!   Note: the following header documentation is an extract of the associated XPM Xilinx header       
-- -------------------------------------------------------------------------------------------------------------   

-- -------------------------------------------------------------------------------------------------------------
-- Parameter usage table, organized as follows:
-- +---------------------------------------------------------------------------------------------------------------------+
-- | Parameter name       | Data type          | Restrictions, if applicable                                             |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Description                                                                                                         |
-- +---------------------------------------------------------------------------------------------------------------------+
-- +---------------------------------------------------------------------------------------------------------------------+
-- | CASCADE_HEIGHT       | Integer            | Range: 0 - 64. Default value = 0.                                       |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | 0- No Cascade Height, Allow Vivado Synthesis to choose.                                                             |
-- | 1 or more - Vivado Synthesis sets the specified value as Cascade Height.                                            |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | CDC_SYNC_STAGES      | Integer            | Range: 2 - 8. Default value = 2.                                        |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specifies the number of synchronization stages on the CDC path                                                      |
-- |                                                                                                                     |
-- |   Must be < 5 if FIFO_WRITE_DEPTH = 16                                                                              |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | DOUT_RESET_VALUE     | String             | Default value = 0.                                                      |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Reset value of read data path.                                                                                      |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | ECC_MODE             | String             | Allowed values: no_ecc, en_ecc. Default value = no_ecc.                 |
-- |---------------------------------------------------------------------------------------------------------------------|
-- |                                                                                                                     |
-- |   "no_ecc" - Disables ECC                                                                                           |
-- |   "en_ecc" - Enables both ECC Encoder and Decoder                                                                   |
-- |                                                                                                                     |
-- | NOTE: ECC_MODE should be "no_ecc" if FIFO_MEMORY_TYPE is set to "auto". Violating this may result incorrect behavior.|
-- +---------------------------------------------------------------------------------------------------------------------+
-- | FIFO_MEMORY_TYPE     | String             | Allowed values: auto, block, distributed. Default value = auto.         |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Designate the fifo memory primitive (resource type) to use.                                                         |
-- |                                                                                                                     |
-- |   "auto"- Allow Vivado Synthesis to choose                                                                          |
-- |   "block"- Block RAM FIFO                                                                                           |
-- |   "distributed"- Distributed RAM FIFO                                                                               |
-- |                                                                                                                     |
-- | NOTE: There may be a behavior mismatch if Block RAM or Ultra RAM specific features, like ECC or Asymmetry, are selected with FIFO_MEMORY_TYPE set to "auto".|
-- +---------------------------------------------------------------------------------------------------------------------+
-- | FIFO_READ_LATENCY    | Integer            | Range: 0 - 10. Default value = 1.                                       |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Number of output register stages in the read data path.                                                             |
-- |                                                                                                                     |
-- |   If READ_MODE = "fwft", then the only applicable value is 0.                                                       |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | FIFO_WRITE_DEPTH     | Integer            | Range: 16 - 4194304. Default value = 2048.                              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Defines the FIFO Write Depth, must be power of two.                                                                 |
-- |                                                                                                                     |
-- |   In standard READ_MODE, the effective depth = FIFO_WRITE_DEPTH-1                                                   |
-- |   In First-Word-Fall-Through READ_MODE, the effective depth = FIFO_WRITE_DEPTH+1                                    |
-- |                                                                                                                     |
-- | NOTE: The maximum FIFO size (width x depth) is limited to 150-Megabits.                                             |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | FULL_RESET_VALUE     | Integer            | Range: 0 - 1. Default value = 0.                                        |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Sets full, almost_full and prog_full to FULL_RESET_VALUE during reset                                               |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | PROG_EMPTY_THRESH    | Integer            | Range: 3 - 4194301. Default value = 10.                                 |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specifies the minimum number of read words in the FIFO at or below which prog_empty is asserted.                    |
-- |                                                                                                                     |
-- |   Min_Value = 3 + (READ_MODE_VAL*2)                                                                                 |
-- |   Max_Value = (FIFO_WRITE_DEPTH-3) - (READ_MODE_VAL*2)                                                              |
-- |                                                                                                                     |
-- | If READ_MODE = "std", then READ_MODE_VAL = 0; Otherwise READ_MODE_VAL = 1.                                          |
-- | NOTE: The default threshold value is dependent on default FIFO_WRITE_DEPTH value. If FIFO_WRITE_DEPTH value is      |
-- | changed, ensure the threshold value is within the valid range though the programmable flags are not used.           |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | PROG_FULL_THRESH     | Integer            | Range: 5 - 4194301. Default value = 10.                                 |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specifies the maximum number of write words in the FIFO at or above which prog_full is asserted.                    |
-- |                                                                                                                     |
-- |   Min_Value = 3 + (READ_MODE_VAL*2*(FIFO_WRITE_DEPTH/FIFO_READ_DEPTH))+CDC_SYNC_STAGES                              |
-- |   Max_Value = (FIFO_WRITE_DEPTH-3) - (READ_MODE_VAL*2*(FIFO_WRITE_DEPTH/FIFO_READ_DEPTH))                           |
-- |                                                                                                                     |
-- | If READ_MODE = "std", then READ_MODE_VAL = 0; Otherwise READ_MODE_VAL = 1.                                          |
-- | NOTE: The default threshold value is dependent on default FIFO_WRITE_DEPTH value. If FIFO_WRITE_DEPTH value is      |
-- | changed, ensure the threshold value is within the valid range though the programmable flags are not used.           |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | RD_DATA_COUNT_WIDTH  | Integer            | Range: 1 - 23. Default value = 1.                                       |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specifies the width of rd_data_count. To reflect the correct value, the width should be log2(FIFO_READ_DEPTH)+1.    |
-- |                                                                                                                     |
-- |   FIFO_READ_DEPTH = FIFO_WRITE_DEPTH*WRITE_DATA_WIDTH/READ_DATA_WIDTH                                               |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | READ_DATA_WIDTH      | Integer            | Range: 1 - 4096. Default value = 32.                                    |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Defines the width of the read data port, dout                                                                       |
-- |                                                                                                                     |
-- |   Write and read width aspect ratio must be 1:1, 1:2, 1:4, 1:8, 8:1, 4:1 and 2:1                                    |
-- |   For example, if WRITE_DATA_WIDTH is 32, then the READ_DATA_WIDTH must be 32, 64,128, 256, 16, 8, 4.               |
-- |                                                                                                                     |
-- | NOTE:                                                                                                               |
-- |                                                                                                                     |
-- |   READ_DATA_WIDTH should be equal to WRITE_DATA_WIDTH if FIFO_MEMORY_TYPE is set to "auto". Violating this may result incorrect behavior. |
-- |   The maximum FIFO size (width x depth) is limited to 150-Megabits.                                                 |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | READ_MODE            | String             | Allowed values: std, fwft. Default value = std.                         |
-- |---------------------------------------------------------------------------------------------------------------------|
-- |                                                                                                                     |
-- |   "std"- standard read mode                                                                                         |
-- |   "fwft"- First-Word-Fall-Through read mode                                                                         |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | RELATED_CLOCKS       | Integer            | Range: 0 - 1. Default value = 0.                                        |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specifies if the wr_clk and rd_clk are related having the same source but different clock ratios                    |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | SIM_ASSERT_CHK       | Integer            | Range: 0 - 1. Default value = 0.                                        |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | 0- Disable simulation message reporting. Messages related to potential misuse will not be reported.                 |
-- | 1- Enable simulation message reporting. Messages related to potential misuse will be reported.                      |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | USE_ADV_FEATURES     | String             | Default value = 0707.                                                   |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Enables data_valid, almost_empty, rd_data_count, prog_empty, underflow, wr_ack, almost_full, wr_data_count,         |
-- | prog_full, overflow features.                                                                                       |
-- |                                                                                                                     |
-- |   Setting USE_ADV_FEATURES[0] to 1 enables overflow flag; Default value of this bit is 1                            |
-- |   Setting USE_ADV_FEATURES[1] to 1 enables prog_full flag; Default value of this bit is 1                           |
-- |   Setting USE_ADV_FEATURES[2] to 1 enables wr_data_count; Default value of this bit is 1                            |
-- |   Setting USE_ADV_FEATURES[3] to 1 enables almost_full flag; Default value of this bit is 0                         |
-- |   Setting USE_ADV_FEATURES[4] to 1 enables wr_ack flag; Default value of this bit is 0                              |
-- |   Setting USE_ADV_FEATURES[8] to 1 enables underflow flag; Default value of this bit is 1                           |
-- |   Setting USE_ADV_FEATURES[9] to 1 enables prog_empty flag; Default value of this bit is 1                          |
-- |   Setting USE_ADV_FEATURES[10] to 1 enables rd_data_count; Default value of this bit is 1                           |
-- |   Setting USE_ADV_FEATURES[11] to 1 enables almost_empty flag; Default value of this bit is 0                       |
-- |   Setting USE_ADV_FEATURES[12] to 1 enables data_valid flag; Default value of this bit is 0                         |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | WAKEUP_TIME          | Integer            | Range: 0 - 2. Default value = 0.                                        |
-- |---------------------------------------------------------------------------------------------------------------------|
-- |                                                                                                                     |
-- |   0 - Disable sleep                                                                                                 |
-- |   2 - Use Sleep Pin                                                                                                 |
-- |                                                                                                                     |
-- | NOTE: WAKEUP_TIME should be 0 if FIFO_MEMORY_TYPE is set to "auto". Violating this may result incorrect behavior.   |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | WRITE_DATA_WIDTH     | Integer            | Range: 1 - 4096. Default value = 32.                                    |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Defines the width of the write data port, din                                                                       |
-- |                                                                                                                     |
-- |   Write and read width aspect ratio must be 1:1, 1:2, 1:4, 1:8, 8:1, 4:1 and 2:1                                    |
-- |   For example, if WRITE_DATA_WIDTH is 32, then the READ_DATA_WIDTH must be 32, 64,128, 256, 16, 8, 4.               |
-- |                                                                                                                     |
-- | NOTE:                                                                                                               |
-- |                                                                                                                     |
-- |   WRITE_DATA_WIDTH should be equal to READ_DATA_WIDTH if FIFO_MEMORY_TYPE is set to "auto". Violating this may result incorrect behavior. |
-- |   The maximum FIFO size (width x depth) is limited to 150-Megabits.                                                 |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | WR_DATA_COUNT_WIDTH  | Integer            | Range: 1 - 23. Default value = 1.                                       |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Specifies the width of wr_data_count. To reflect the correct value, the width should be log2(FIFO_WRITE_DEPTH)+1.   |
-- +---------------------------------------------------------------------------------------------------------------------+

-- Port usage table, organized as follows:
-- +---------------------------------------------------------------------------------------------------------------------+
-- | Port name      | Direction | Size, in bits                         | Domain  | Sense       | Handling if unused     |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Description                                                                                                         |
-- +---------------------------------------------------------------------------------------------------------------------+
-- +---------------------------------------------------------------------------------------------------------------------+
-- | almost_empty   | Output    | 1                                     | rd_clk  | Active-high | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Almost Empty : When asserted, this signal indicates that only one more read can be performed before the FIFO goes to|
-- | empty.                                                                                                              |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | almost_full    | Output    | 1                                     | wr_clk  | Active-high | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Almost Full: When asserted, this signal indicates that only one more write can be performed before the FIFO is full.|
-- +---------------------------------------------------------------------------------------------------------------------+
-- | data_valid     | Output    | 1                                     | rd_clk  | Active-high | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Read Data Valid: When asserted, this signal indicates that valid data is available on the output bus (dout).        |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | dbiterr        | Output    | 1                                     | rd_clk  | Active-high | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Double Bit Error: Indicates that the ECC decoder detected a double-bit error and data in the FIFO core is corrupted.|
-- +---------------------------------------------------------------------------------------------------------------------+
-- | din            | Input     | WRITE_DATA_WIDTH                      | wr_clk  | NA          | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Write Data: The input data bus used when writing the FIFO.                                                          |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | dout           | Output    | READ_DATA_WIDTH                       | rd_clk  | NA          | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Read Data: The output data bus is driven when reading the FIFO.                                                     |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | empty          | Output    | 1                                     | rd_clk  | Active-high | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Empty Flag: When asserted, this signal indicates that the FIFO is empty.                                            |
-- | Read requests are ignored when the FIFO is empty, initiating a read while empty is not destructive to the FIFO.     |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | full           | Output    | 1                                     | wr_clk  | Active-high | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Full Flag: When asserted, this signal indicates that the FIFO is full.                                              |
-- | Write requests are ignored when the FIFO is full, initiating a write when the FIFO is full is not destructive       |
-- | to the contents of the FIFO.                                                                                        |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | injectdbiterr  | Input     | 1                                     | wr_clk  | Active-high | Tie to 1'b0            |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Double Bit Error Injection: Injects a double bit error if the ECC feature is used on block RAMs or                  |
-- | UltraRAM macros.                                                                                                    |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | injectsbiterr  | Input     | 1                                     | wr_clk  | Active-high | Tie to 1'b0            |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Single Bit Error Injection: Injects a single bit error if the ECC feature is used on block RAMs or                  |
-- | UltraRAM macros.                                                                                                    |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | overflow       | Output    | 1                                     | wr_clk  | Active-high | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Overflow: This signal indicates that a write request (wren) during the prior clock cycle was rejected,              |
-- | because the FIFO is full. Overflowing the FIFO is not destructive to the contents of the FIFO.                      |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | prog_empty     | Output    | 1                                     | rd_clk  | Active-high | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Programmable Empty: This signal is asserted when the number of words in the FIFO is less than or equal              |
-- | to the programmable empty threshold value.                                                                          |
-- | It is de-asserted when the number of words in the FIFO exceeds the programmable empty threshold value.              |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | prog_full      | Output    | 1                                     | wr_clk  | Active-high | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Programmable Full: This signal is asserted when the number of words in the FIFO is greater than or equal            |
-- | to the programmable full threshold value.                                                                           |
-- | It is de-asserted when the number of words in the FIFO is less than the programmable full threshold value.          |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | rd_clk         | Input     | 1                                     | NA      | Rising edge | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Read clock: Used for read operation. rd_clk must be a free running clock.                                           |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | rd_data_count  | Output    | RD_DATA_COUNT_WIDTH                   | rd_clk  | NA          | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Read Data Count: This bus indicates the number of words read from the FIFO.                                         |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | rd_en          | Input     | 1                                     | rd_clk  | Active-high | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Read Enable: If the FIFO is not empty, asserting this signal causes data (on dout) to be read from the FIFO.        |
-- |                                                                                                                     |
-- |   Must be held active-low when rd_rst_busy is active high.                                                          |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | rd_rst_busy    | Output    | 1                                     | rd_clk  | Active-high | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Read Reset Busy: Active-High indicator that the FIFO read domain is currently in a reset state.                     |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | rst            | Input     | 1                                     | wr_clk  | Active-high | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Reset: Must be synchronous to wr_clk. The clock(s) can be unstable at the time of applying reset, but reset must be released only after the clock(s) is/are stable.|
-- +---------------------------------------------------------------------------------------------------------------------+
-- | sbiterr        | Output    | 1                                     | rd_clk  | Active-high | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Single Bit Error: Indicates that the ECC decoder detected and fixed a single-bit error.                             |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | sleep          | Input     | 1                                     | NA      | Active-high | Tie to 1'b0            |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Dynamic power saving: If sleep is High, the memory/fifo block is in power saving mode.                              |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | underflow      | Output    | 1                                     | rd_clk  | Active-high | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Underflow: Indicates that the read request (rd_en) during the previous clock cycle was rejected                     |
-- | because the FIFO is empty. Under flowing the FIFO is not destructive to the FIFO.                                   |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | wr_ack         | Output    | 1                                     | wr_clk  | Active-high | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Write Acknowledge: This signal indicates that a write request (wr_en) during the prior clock cycle is succeeded.    |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | wr_clk         | Input     | 1                                     | NA      | Rising edge | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Write clock: Used for write operation. wr_clk must be a free running clock.                                         |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | wr_data_count  | Output    | WR_DATA_COUNT_WIDTH                   | wr_clk  | NA          | DoNotCare              |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Write Data Count: This bus indicates the number of words written into the FIFO.                                     |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | wr_en          | Input     | 1                                     | wr_clk  | Active-high | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Write Enable: If the FIFO is not full, asserting this signal causes data (on din) to be written to the FIFO.        |
-- |                                                                                                                     |
-- |   Must be held active-low when rst or wr_rst_busy is active high.                                                   |
-- +---------------------------------------------------------------------------------------------------------------------+
-- | wr_rst_busy    | Output    | 1                                     | wr_clk  | Active-high | Required               |
-- |---------------------------------------------------------------------------------------------------------------------|
-- | Write Reset Busy: Active-High indicator that the FIFO write domain is currently in a reset state.                   |
-- +---------------------------------------------------------------------------------------------------------------------+

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library xpm;
use xpm.vcomponents.all;

library fpasim;

entity fifo_async_with_error_prog_full is
  generic(
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | CASCADE_HEIGHT       | Integer            | Range: 0 - 64. Default value = 0.                                       |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | 0- No Cascade Height, Allow Vivado Synthesis to choose.                                                             |
    -- | 1 or more - Vivado Synthesis sets the specified value as Cascade Height.                                            |
    -- g_CASCADE_HEIGHT : integer := 0;

    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | CDC_SYNC_STAGES      | Integer            | Range: 2 - 8. Default value = 2.                                        |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Specifies the number of synchronization stages on the CDC path                                                      |
    -- |                                                                                                                     |
    -- |   Must be < 5 if FIFO_WRITE_DEPTH = 16                                                                              |
    g_CDC_SYNC_STAGES   : integer := 2;
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | DOUT_RESET_VALUE     | String             | Default value = 0.                                                      |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Reset value of read data path.                                                                                      |
    -- g_DOUT_RESET_VALUE : string := "0";

    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | ECC_MODE             | String             | Allowed values: no_ecc, en_ecc. Default value = no_ecc.                 |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- |                                                                                                                     |
    -- |   "no_ecc" - Disables ECC                                                                                           |
    -- |   "en_ecc" - Enables both ECC Encoder and Decoder                                                                   |
    -- |                                                                                                                     |
    -- | NOTE: ECC_MODE should be "no_ecc" if FIFO_MEMORY_TYPE is set to "auto". Violating this may result incorrect behavior.|
    -- g_ECC_MODE : string := "no_ecc";

    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | FIFO_MEMORY_TYPE     | String             | Allowed values: auto, block, distributed. Default value = auto.         |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Designate the fifo memory primitive (resource type) to use.                                                         |
    -- |                                                                                                                     |
    -- |   "auto"- Allow Vivado Synthesis to choose                                                                          |
    -- |   "block"- Block RAM FIFO                                                                                           |
    -- |   "distributed"- Distributed RAM FIFO                                                                               |
    -- |                                                                                                                     |
    -- | NOTE: There may be a behavior mismatch if Block RAM or Ultra RAM specific features, like ECC or Asymmetry, are selected with FIFO_MEMORY_TYPE set to "auto".|
    g_FIFO_MEMORY_TYPE  : string  := "auto";
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | FIFO_READ_LATENCY    | Integer            | Range: 0 - 10. Default value = 1.                                       |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Number of output register stages in the read data path.                                                             |
    -- |                                                                                                                     |
    -- |   If READ_MODE = "fwft", then the only applicable value is 0.                                                       |
    g_FIFO_READ_LATENCY : integer := 0;
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | FIFO_WRITE_DEPTH     | Integer            | Range: 16 - 4194304. Default value = 2048.                              |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Defines the FIFO Write Depth, must be power of two.                                                                 |
    -- |                                                                                                                     |
    -- |   In standard READ_MODE, the effective depth = FIFO_WRITE_DEPTH-1                                                   |
    -- |   In First-Word-Fall-Through READ_MODE, the effective depth = FIFO_WRITE_DEPTH+1                                    |
    -- |                                                                                                                     |
    -- | NOTE: The maximum FIFO size (width x depth) is limited to 150-Megabits.                                             |
    g_FIFO_WRITE_DEPTH  : integer := 16;
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | FULL_RESET_VALUE     | Integer            | Range: 0 - 1. Default value = 0.                                        |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Sets full, almost_full and prog_full to FULL_RESET_VALUE during reset                                               |
    -- g_FULL_RESET_VALUE : integer := 0;

    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | PROG_EMPTY_THRESH    | Integer            | Range: 3 - 4194301. Default value = 10.                                 |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Specifies the minimum number of read words in the FIFO at or below which prog_empty is asserted.                    |
    -- |                                                                                                                     |
    -- |   Min_Value = 3 + (READ_MODE_VAL*2)                                                                                 |
    -- |   Max_Value = (FIFO_WRITE_DEPTH-3) - (READ_MODE_VAL*2)                                                              |
    -- |                                                                                                                     |
    -- | If READ_MODE = "std", then READ_MODE_VAL = 0; Otherwise READ_MODE_VAL = 1.                                          |
    -- | NOTE: The default threshold value is dependent on default FIFO_WRITE_DEPTH value. If FIFO_WRITE_DEPTH value is      |
    -- | changed, ensure the threshold value is within the valid range though the programmable flags are not used.           |
    -- g_PROG_EMPTY_THRESH : integer := 3;

    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | PROG_FULL_THRESH     | Integer            | Range: 5 - 4194301. Default value = 10.                                 |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Specifies the maximum number of write words in the FIFO at or above which prog_full is asserted.                    |
    -- |                                                                                                                     |
    -- |   Min_Value = 3 + (READ_MODE_VAL*2*(FIFO_WRITE_DEPTH/FIFO_READ_DEPTH))+CDC_SYNC_STAGES                              |
    -- |   Max_Value = (FIFO_WRITE_DEPTH-3) - (READ_MODE_VAL*2*(FIFO_WRITE_DEPTH/FIFO_READ_DEPTH))                           |
    -- |                                                                                                                     |
    -- | If READ_MODE = "std", then READ_MODE_VAL = 0; Otherwise READ_MODE_VAL = 1.                                          |
    -- | NOTE: The default threshold value is dependent on default FIFO_WRITE_DEPTH value. If FIFO_WRITE_DEPTH value is      |
    -- | changed, ensure the threshold value is within the valid range though the programmable flags are not used.           |
    g_PROG_FULL_THRESH  : integer := 5;
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | RD_DATA_COUNT_WIDTH  | Integer            | Range: 1 - 23. Default value = 1.                                       |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Specifies the width of rd_data_count. To reflect the correct value, the width should be log2(FIFO_READ_DEPTH)+1.    |
    -- |                                                                                                                     |
    -- |   FIFO_READ_DEPTH = FIFO_WRITE_DEPTH*WRITE_DATA_WIDTH/READ_DATA_WIDTH                                               |
    -- g_RD_DATA_COUNT_WIDTH : integer := 1;

    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | READ_DATA_WIDTH      | Integer            | Range: 1 - 4096. Default value = 32.                                    |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Defines the width of the read data port, dout                                                                       |
    -- |                                                                                                                     |
    -- |   Write and read width aspect ratio must be 1:1, 1:2, 1:4, 1:8, 8:1, 4:1 and 2:1                                    |
    -- |   For example, if WRITE_DATA_WIDTH is 32, then the READ_DATA_WIDTH must be 32, 64,128, 256, 16, 8, 4.               |
    -- |                                                                                                                     |
    -- | NOTE:                                                                                                               |
    -- |                                                                                                                     |
    -- |   READ_DATA_WIDTH should be equal to WRITE_DATA_WIDTH if FIFO_MEMORY_TYPE is set to "auto". Violating this may result incorrect behavior. |
    -- |   The maximum FIFO size (width x depth) is limited to 150-Megabits.                                                 |
    g_READ_DATA_WIDTH   : integer := 32;
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | READ_MODE            | String             | Allowed values: std, fwft. Default value = std.                         |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- |                                                                                                                     |
    -- |   "std"- standard read mode                                                                                         |
    -- |   "fwft"- First-Word-Fall-Through read mode                                                                         |
    g_READ_MODE         : string  := "fwft";
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | RELATED_CLOCKS       | Integer            | Range: 0 - 1. Default value = 0.                                        |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Specifies if the wr_clk and rd_clk are related having the same source but different clock ratios                    |
    g_RELATED_CLOCKS    : integer := 0;
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | SIM_ASSERT_CHK       | Integer            | Range: 0 - 1. Default value = 0.                                        |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | 0- Disable simulation message reporting. Messages related to potential misuse will not be reported.                 |
    -- | 1- Enable simulation message reporting. Messages related to potential misuse will be reported.                      |
    -- g_SIM_ASSERT_CHK : integer := 0;

    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | USE_ADV_FEATURES     | String             | Default value = 0707.                                                   |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Enables data_valid, almost_empty, rd_data_count, prog_empty, underflow, wr_ack, almost_full, wr_data_count,         |
    -- | prog_full, overflow features.                                                                                       |
    -- |                                                                                                                     |
    -- |   Setting USE_ADV_FEATURES[0] to 1 enables overflow flag; Default value of this bit is 1                            |
    -- |   Setting USE_ADV_FEATURES[1] to 1 enables prog_full flag; Default value of this bit is 1                           |
    -- |   Setting USE_ADV_FEATURES[2] to 1 enables wr_data_count; Default value of this bit is 1                            |
    -- |   Setting USE_ADV_FEATURES[3] to 1 enables almost_full flag; Default value of this bit is 0                         |
    -- |   Setting USE_ADV_FEATURES[4] to 1 enables wr_ack flag; Default value of this bit is 0                              |
    -- |   Setting USE_ADV_FEATURES[8] to 1 enables underflow flag; Default value of this bit is 1                           |
    -- |   Setting USE_ADV_FEATURES[9] to 1 enables prog_empty flag; Default value of this bit is 1                          |
    -- |   Setting USE_ADV_FEATURES[10] to 1 enables rd_data_count; Default value of this bit is 1                           |
    -- |   Setting USE_ADV_FEATURES[11] to 1 enables almost_empty flag; Default value of this bit is 0                       |
    -- |   Setting USE_ADV_FEATURES[12] to 1 enables data_valid flag; Default value of this bit is 0                         |
    -- g_USE_ADV_FEATURES : string := "0707";

    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | WAKEUP_TIME          | Integer            | Range: 0 - 2. Default value = 0.                                        |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- |                                                                                                                     |
    -- |   0 - Disable sleep                                                                                                 |
    -- |   2 - Use Sleep Pin                                                                                                 |
    -- |                                                                                                                     |
    -- | NOTE: WAKEUP_TIME should be 0 if FIFO_MEMORY_TYPE is set to "auto". Violating this may result incorrect behavior.   |
    -- g_WAKEUP_TIME : integer := 0;

    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | WRITE_DATA_WIDTH     | Integer            | Range: 1 - 4096. Default value = 32.                                    |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Defines the width of the write data port, din                                                                       |
    -- |                                                                                                                     |
    -- |   Write and read width aspect ratio must be 1:1, 1:2, 1:4, 1:8, 8:1, 4:1 and 2:1                                    |
    -- |   For example, if WRITE_DATA_WIDTH is 32, then the READ_DATA_WIDTH must be 32, 64,128, 256, 16, 8, 4.               |
    -- |                                                                                                                     |
    -- | NOTE:                                                                                                               |
    -- |                                                                                                                     |
    -- |   WRITE_DATA_WIDTH should be equal to READ_DATA_WIDTH if FIFO_MEMORY_TYPE is set to "auto". Violating this may result incorrect behavior. |
    -- |   The maximum FIFO size (width x depth) is limited to 150-Megabits.                                                 |
    g_WRITE_DATA_WIDTH  : integer := 1;
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- | WR_DATA_COUNT_WIDTH  | Integer            | Range: 1 - 23. Default value = 1.                                       |
    -- |---------------------------------------------------------------------------------------------------------------------|
    -- | Specifies the width of wr_data_count. To reflect the correct value, the width should be log2(FIFO_WRITE_DEPTH)+1.   |
    -- +---------------------------------------------------------------------------------------------------------------------+
    -- g_WR_DATA_COUNT_WIDTH : integer := 1

    ---------------------------------------------------------------------
    -- resynchronization: fifo errors/empty flag
    ---------------------------------------------------------------------
    g_SYNC_SIDE         : string  := "wr"; -- define the clock side where status/errors is resynchronised. Possible value "wr" or "rd"
    g_DEST_SYNC_FF      : integer := 2; -- Number of register stages used to synchronize signal in the destination clock domain.   
    g_SRC_INPUT_REG     : integer := 1  -- 0- Do not register input (src_in), 1- Register input (src_in) once using src_clk 

  );
  port(
    ---------------------------------------------------------------------
    -- write side
    ---------------------------------------------------------------------
    i_wr_clk        : in  std_logic;    -- write clock
    i_wr_rst        : in  std_logic;    -- write reset 
    i_wr_en         : in  std_logic;    -- write enable
    i_wr_din        : in  std_logic_vector(g_WRITE_DATA_WIDTH - 1 downto 0); -- write data
    o_wr_full       : out std_logic;    -- When asserted, this signal indicates that the FIFO is full (not destructive to the contents of the FIFO.)
    o_wr_prog_full  : out std_logic;    -- Programmable Full: This signal is asserted when the number of words in the FIFO is greater than or equal to the programmable full threshold value. It is de-asserted when the number of words in the FIFO is less than the programmable full threshold value.
    o_wr_rst_busy   : out std_logic;    -- Active-High indicator that the FIFO write domain is currently in a reset state

    ---------------------------------------------------------------------
    -- read side
    ---------------------------------------------------------------------
    i_rd_clk        : in  std_logic;    -- read clock
    i_rd_en         : in  std_logic;    -- read enable (Must be held active-low when rd_rst_busy is active high)
    o_rd_dout_valid : out std_logic;    -- When asserted, this signal indicates that valid data is available on the output bus
    o_rd_dout       : out std_logic_vector(g_READ_DATA_WIDTH - 1 downto 0);
    o_rd_empty      : out std_logic;    -- When asserted, this signal indicates that the FIFO is full (not destructive to the contents of the FIFO.)
    o_rd_rst_busy   : out std_logic;    -- Active-High indicator that the FIFO read domain is currently in a reset state

    ---------------------------------------------------------------------
    -- resynchronized errors/ empty status 
    ---------------------------------------------------------------------
    o_errors_sync   : out std_logic_vector(3 downto 0); -- output resynchronized errors
    o_empty_sync    : out std_logic     -- output resynchronized empty fifo status flag
  );
end entity fifo_async_with_error_prog_full;

architecture RTL of fifo_async_with_error_prog_full is

  ---------------------------------------------------------------------
  -- fifo
  ---------------------------------------------------------------------
  signal wr_full      : std_logic;
  signal wr_prog_full : std_logic;
  signal wr_rst_busy  : std_logic;

  signal rd_dout_valid : std_logic;
  signal rd_dout       : std_logic_vector(o_rd_dout'range);
  signal rd_empty      : std_logic;
  signal rd_rst_busy   : std_logic;

  ---------------------------------------------------------------------
  -- error
  ---------------------------------------------------------------------
  signal error_full   : std_logic;
  signal error_wr_rst : std_logic;
  signal error_empty  : std_logic;
  signal error_rd_rst : std_logic;

  ---------------------------------------------------------------------
  -- resync errors and empty fifo status flag
  ---------------------------------------------------------------------
  signal error_wr_rst_sync : std_logic;
  signal error_full_sync   : std_logic;
  signal error_rd_rst_sync : std_logic;
  signal error_empty_sync  : std_logic;

  signal empty_sync : std_logic;

begin

  ---------------------------------------------------------------------
  -- instanciate fifo
  ---------------------------------------------------------------------
  inst_fifo_async_with_prog_full : entity fpasim.fifo_async_with_prog_full
    generic map(
      g_CDC_SYNC_STAGES   => g_CDC_SYNC_STAGES,
      g_FIFO_MEMORY_TYPE  => g_FIFO_MEMORY_TYPE,
      g_FIFO_READ_LATENCY => g_FIFO_READ_LATENCY,
      g_FIFO_WRITE_DEPTH  => g_FIFO_WRITE_DEPTH,
      g_PROG_FULL_THRESH  => g_PROG_FULL_THRESH,
      g_READ_DATA_WIDTH   => g_READ_DATA_WIDTH,
      g_READ_MODE         => g_READ_MODE,
      g_RELATED_CLOCKS    => g_RELATED_CLOCKS,
      g_WRITE_DATA_WIDTH  => g_WRITE_DATA_WIDTH
    )
    port map(
      ---------------------------------------------------------------------
      -- write side
      ---------------------------------------------------------------------
      i_wr_clk        => i_wr_clk,      -- write clock
      i_wr_rst        => i_wr_rst,      -- write reset 
      i_wr_en         => i_wr_en,       -- write enable
      i_wr_din        => i_wr_din,      -- write data
      o_wr_full       => wr_full,       -- When asserted, this signal indicates that the FIFO is full (not destructive to the contents of the FIFO.)
      o_wr_prog_full  => wr_prog_full,  -- When asserted, this signal indicates that the FIFO is full (not destructive to the contents of the FIFO.)
      o_wr_rst_busy   => wr_rst_busy,   -- Active-High indicator that the FIFO write domain is currently in a reset state
      ---------------------------------------------------------------------
      -- read side
      ---------------------------------------------------------------------
      i_rd_clk        => i_rd_clk,      -- read clock
      i_rd_en         => i_rd_en,       -- read enable (Must be held active-low when rd_rst_busy is active high)
      o_rd_dout_valid => rd_dout_valid, -- When asserted, this signal indicates that valid data is available on the output bus
      o_rd_dout       => rd_dout,
      o_rd_empty      => rd_empty,      -- When asserted, this signal indicates that the FIFO is full (not destructive to the contents of the FIFO.)
      o_rd_rst_busy   => rd_rst_busy    -- Active-High indicator that the FIFO read domain is currently in a reset state
    );

  ---------------------------------------------------------------------
  -- generate errors flag
  ---------------------------------------------------------------------
  error_wr_rst <= '1' when i_wr_en = '1' and wr_rst_busy = '1' else '0';
  error_full   <= '1' when i_wr_en = '1' and wr_full = '1' else '0';
  error_rd_rst <= '1' when i_rd_en = '1' and rd_rst_busy = '1' else '0';
  error_empty  <= '1' when i_rd_en = '1' and rd_empty = '1' else '0';

  ---------------------------------------------------------------------
  -- resynchronize all errors/status flag on the same clock domain: write or read
  ---------------------------------------------------------------------
  gen_sync_wr_clock_domain : if g_SYNC_SIDE = "wr" generate
    signal data_tmp      : std_logic_vector(2 downto 0);
    signal data_tmp_sync : std_logic_vector(2 downto 0);
  begin

    data_tmp(2) <= rd_empty;
    data_tmp(1) <= error_rd_rst;
    data_tmp(0) <= error_empty;

    gen_bit_synchronizer : for i in data_tmp'range generate
      inst_single_bit_synchronizer : entity fpasim.single_bit_synchronizer
        generic map(
          g_DEST_SYNC_FF  => g_DEST_SYNC_FF,
          g_SRC_INPUT_REG => g_SRC_INPUT_REG
        )
        port map(
          ---------------------------------------------------------------------
          -- source
          ---------------------------------------------------------------------
          i_src_clk  => i_rd_clk,       -- source clock
          i_src      => data_tmp(i),    -- input signal to be synchronized to dest_clk domain
          ---------------------------------------------------------------------
          -- destination
          ---------------------------------------------------------------------
          i_dest_clk => i_wr_clk,       -- destination clock domain
          o_dest     => data_tmp_sync(i) -- src_in synchronized to the destination clock domain. This output is registered.   
        );

    end generate gen_bit_synchronizer;

    error_wr_rst_sync <= error_wr_rst;
    error_full_sync   <= error_full;
    -- resync
    error_rd_rst_sync <= data_tmp_sync(1);
    error_empty_sync  <= data_tmp_sync(0);
    empty_sync        <= data_tmp_sync(2);

  end generate gen_sync_wr_clock_domain;

  gen_sync_rd_clock_domain : if g_SYNC_SIDE = "rd" generate
    signal data_tmp      : std_logic_vector(1 downto 0);
    signal data_tmp_sync : std_logic_vector(1 downto 0);

  begin

    data_tmp(1) <= error_wr_rst;
    data_tmp(0) <= error_full;

    gen_bit_synchronizer : for i in data_tmp'range generate
      inst_single_bit_synchronizer : entity fpasim.single_bit_synchronizer
        generic map(
          g_DEST_SYNC_FF  => g_DEST_SYNC_FF,
          g_SRC_INPUT_REG => g_SRC_INPUT_REG
        )
        port map(
          ---------------------------------------------------------------------
          -- source
          ---------------------------------------------------------------------
          i_src_clk  => i_rd_clk,       -- source clock
          i_src      => data_tmp(i),    -- input signal to be synchronized to dest_clk domain
          ---------------------------------------------------------------------
          -- destination
          ---------------------------------------------------------------------
          i_dest_clk => i_wr_clk,       -- destination clock domain
          o_dest     => data_tmp_sync(i) -- src_in synchronized to the destination clock domain. This output is registered.   
        );

    end generate gen_bit_synchronizer;

    error_wr_rst_sync <= data_tmp_sync(1);
    error_full_sync   <= data_tmp_sync(0);

    error_rd_rst_sync <= error_rd_rst;
    error_empty_sync  <= error_empty;

    empty_sync <= rd_empty;

  end generate gen_sync_rd_clock_domain;

  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_wr_full      <= wr_full;
  o_wr_prog_full <= wr_prog_full;
  o_wr_rst_busy  <= wr_rst_busy;

  o_rd_dout_valid <= rd_dout_valid;
  o_rd_dout       <= rd_dout;
  o_rd_empty      <= rd_empty;
  o_rd_rst_busy   <= rd_rst_busy;

  o_errors_sync(3) <= error_rd_rst_sync;
  o_errors_sync(2) <= error_wr_rst_sync;
  o_errors_sync(1) <= error_empty_sync;
  o_errors_sync(0) <= error_full_sync;
  o_empty_sync     <= empty_sync;

end architecture RTL;
