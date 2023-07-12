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
--    @file                   tes_pulse_shape_manager.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--   @details
--
--   From a user-defined command, this module tracks the computation history of the associated pixel.
--   With one state machine and a mechanism of parameters' table, the module can simulate nb_pixel independent state machine (one by pixel).
--   if a previous command was received for the current pixel, this module performs the following tes computation steps:
--     . computation of the addr0
--        . at t=0: addr0 = i_cmd_time_shift
--        . at t/=0: addr0 = addr0 + time_shift_max (until all pulse_shape sample was processed)
--     . pulse_shape = TES_PULSE_SHAPE(addr0): use the addr value to read a pre-loaded RAM
--     . addr1 = i_pixel_id
--     . steady_state =  TES_STD_STATE(addr1): use the addr value to read a pre-loaded RAM
--     . o_pixel_result = steady_state - (pulse_shape * i_cmd_pulse_height)
--
--   Note:
--     . If the state machine is processing a pulse for the pixel 0 and if a new command is received for the pixel 0, then
--        the state machine stop the previous processing and start a new processing with the new set of paramters.
--   Remark:
--     . The minimum number of samples between the i_pixel_sof and i_pixel_eof is given by the following formula:
--        => min_sample = pkg_TES_PULSE_MANAGER_SOF_EOF_NB_SAMPLES_MIN
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_fpasim.all;
use work.pkg_regdecode.all;

entity tes_pulse_shape_manager is
  generic(
    -- command
    g_CMD_PULSE_HEIGHT_WIDTH               : positive := pkg_MAKE_PULSE_PULSE_HEIGHT_WIDTH;  -- pulse_heigth bus width (expressed in bits). Possible values [1;max integer value[
    g_CMD_TIME_SHIFT_WIDTH                 : positive := pkg_MAKE_PULSE_TIME_SHIFT_WIDTH;  -- time_shift bus width (expressed in bits). Possible values [1;max integer value[
    g_CMD_PIXEL_ID_WIDTH                   : positive := pkg_MAKE_PULSE_PIXEL_ID_WIDTH;  -- pixel id bus width (expressed in bits). Possible values : [1; max integer value[
    -- frame
    g_NB_FRAME_BY_PULSE_SHAPE              : positive := pkg_NB_FRAME_BY_PULSE_SHAPE; -- number of frames by pulse_shape
    g_NB_SAMPLE_BY_FRAME_WIDTH             : positive := pkg_NB_SAMPLE_BY_FRAME_WIDTH;  -- frame bus width (expressed in bits). Possible values : [1; max integer value[
    -- addr
    g_PULSE_SHAPE_RAM_ADDR_WIDTH           : positive := pkg_TES_PULSE_SHAPE_RAM_ADDR_WIDTH;  -- address bus width (expressed in bits)
    -- output
    g_PIXEL_RESULT_OUTPUT_WIDTH            : positive := pkg_TES_MULT_SUB_Q_WIDTH_S;  -- pixel output result width (expressed in bits). Possible values : [1; max integer value[
    -- RAM configuration filename
    g_TES_PULSE_SHAPE_RAM_MEMORY_INIT_FILE : string   := pkg_TES_PULSE_SHAPE_RAM_MEMORY_INIT_FILE; -- file to use in order to initialize the tes_pulse_shape RAM
    g_TES_STD_STATE_RAM_MEMORY_INIT_FILE   : string   := pkg_TES_STD_STATE_RAM_MEMORY_INIT_FILE -- file to use in order to initialize the tes_std_state RAM

    );
  port(
    i_clk         : in std_logic;       -- clock
    i_rst         : in std_logic;       -- reset
    i_rst_status  : in std_logic;       -- reset error flag(s)
    i_debug_pulse : in std_logic;  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)

    ---------------------------------------------------------------------
    -- input command: from the regdecode
    ---------------------------------------------------------------------
    i_cmd_valid              : in  std_logic;  -- valid command
    i_cmd_pulse_height       : in  std_logic_vector(g_CMD_PULSE_HEIGHT_WIDTH - 1 downto 0);  -- pulse height command
    i_cmd_pixel_id           : in  std_logic_vector(g_CMD_PIXEL_ID_WIDTH - 1 downto 0);  -- pixel id command
    i_cmd_time_shift         : in  std_logic_vector(g_CMD_TIME_SHIFT_WIDTH - 1 downto 0);  -- time shift command
    o_cmd_ready              : out std_logic;
    -- RAM: pulse shape
    -- wr
    i_pulse_shape_wr_en      : in  std_logic;  -- ram write enable
    i_pulse_shape_wr_rd_addr : in  std_logic_vector(g_PULSE_SHAPE_RAM_ADDR_WIDTH - 1 downto 0);  -- ram write/read address
    i_pulse_shape_wr_data    : in  std_logic_vector(15 downto 0);  -- ram write data
    -- rd
    i_pulse_shape_rd_en      : in  std_logic;  -- ram read enable
    o_pulse_shape_rd_valid   : out std_logic;  -- ram read data valid
    o_pulse_shape_rd_data    : out std_logic_vector(15 downto 0);  -- ram read data

    -- RAM:
    -- wr
    i_steady_state_wr_en      : in  std_logic;  -- ram write enable
    i_steady_state_wr_rd_addr : in  std_logic_vector(g_CMD_PIXEL_ID_WIDTH - 1 downto 0);  -- ram write/read address
    i_steady_state_wr_data    : in  std_logic_vector(15 downto 0);  -- ram write data
    -- rd
    i_steady_state_rd_en      : in  std_logic;  -- ram read enable
    o_steady_state_rd_valid   : out std_logic;  -- ram read data valid
    o_steady_state_rd_data    : out std_logic_vector(15 downto 0);  -- ram read data

    ---------------------------------------------------------------------
    -- input data
    ---------------------------------------------------------------------
    i_pixel_sof   : in std_logic;       -- first pixel sample
    i_pixel_eof   : in std_logic;       -- last pixel sample
    i_pixel_id    : in std_logic_vector(g_CMD_PIXEL_ID_WIDTH - 1 downto 0);  -- pixel id
    i_pixel_valid : in std_logic;       -- valid pixel sample

    ---------------------------------------------------------------------
    -- output data
    ---------------------------------------------------------------------
    o_pulse_sof    : out std_logic;     -- first processed sample of a pulse
    o_pulse_eof    : out std_logic;     -- last processed sample of a pulse
    o_pixel_sof    : out std_logic;     -- first pixel sample
    o_pixel_eof    : out std_logic;     -- last pixel sample
    o_pixel_id     : out std_logic_vector(g_CMD_PIXEL_ID_WIDTH - 1 downto 0);  -- pixel id
    o_pixel_valid  : out std_logic;     -- valid pixel result
    o_pixel_result : out std_logic_vector(g_PIXEL_RESULT_OUTPUT_WIDTH - 1 downto 0);  -- pixel result

    ---------------------------------------------------------------------
    -- output: detect negative output value
    ---------------------------------------------------------------------
    o_tes_pixel_neg_out_valid    : out std_logic; -- valid negative output
    o_tes_pixel_neg_out_error    : out std_logic; -- negative output detection
    o_tes_pixel_neg_out_pixel_id : out std_logic_vector(g_CMD_PIXEL_ID_WIDTH - 1 downto 0);  -- pixel id when a negative output is detected

    -----------------------------------------------------------------
    -- errors/status
    -----------------------------------------------------------------
    o_errors : out std_logic_vector(15 downto 0);  -- output errors
    o_status : out std_logic_vector(7 downto 0)    -- output status
    );
end entity tes_pulse_shape_manager;

architecture RTL of tes_pulse_shape_manager is

  -- number of frames by pulse_shape
  constant c_NB_FRAME_BY_PULSE_SHAPE : positive := g_NB_FRAME_BY_PULSE_SHAPE;

  -- max step value applied on the pulse_shape memory address
  constant c_SHIFT_MAX : positive := 2 ** (i_cmd_time_shift'length);

  -- Memory size (expressed in bits)
  constant c_MEMORY_SIZE_PULSE_SHAPE                  : positive := (2 ** i_pulse_shape_wr_rd_addr'length) * i_pulse_shape_wr_data'length;
  -- Memory size (expressed in bits)
  constant c_MEMORY_SIZE_STEADY_STATE                 : positive := (2 ** i_steady_state_wr_rd_addr'length) * i_steady_state_wr_data'length;
  -- Memory size (expressed in bits)
  constant c_MEMORY_SIZE_EN_TABLE                     : positive := (2 ** i_pixel_id'length) * 1;
  -- Memory size (expressed in bits)
  constant c_MEMORY_SIZE_PULSE_HEIGTH_TABLE           : positive := (2 ** i_pixel_id'length) * (i_cmd_pulse_height'length);
  -- Memory size (expressed in bits)
  constant c_MEMORY_SIZE_TIME_SHIFT_TABLE             : positive := (2 ** i_pixel_id'length) * (i_cmd_time_shift'length);
  -- Memory size (expressed in bits)
  constant c_MEMORY_SIZE_CNT_SAMPLE_PULSE_SHAPE_TABLE : positive := (2 ** i_pixel_id'length) * (g_NB_SAMPLE_BY_FRAME_WIDTH);

  -- add 1 bit to the i_cmd_time_shift length to be able to represent the c_SHIFT_MAX value
  constant c_SHIFT_MAX_VECTOR : std_logic_vector(i_cmd_time_shift'length downto 0) := std_logic_vector(to_unsigned(c_SHIFT_MAX, i_cmd_time_shift'length + 1));

  -- maximal number of words in the tables
  constant c_CNT_MAX : unsigned(i_pixel_id'range) := (others => '1');

  ---------------------------------------------------------------------
  -- FIFO cmd
  ---------------------------------------------------------------------
  constant c_CMD_IDX0_L : integer := 0; -- index0: low
  constant c_CMD_IDX0_H : integer := c_CMD_IDX0_L + i_cmd_time_shift'length - 1; -- index0: high

  constant c_CMD_IDX1_L : integer := c_CMD_IDX0_H + 1; -- index1: low
  constant c_CMD_IDX1_H : integer := c_CMD_IDX1_L + i_cmd_pixel_id'length - 1; -- index1: high

  constant c_CMD_IDX2_L : integer := c_CMD_IDX1_H + 1; -- index2: low
  constant c_CMD_IDX2_H : integer := c_CMD_IDX2_L + i_cmd_pulse_height'length - 1; -- index2: high

  -- FIFO depth (expressed in number of words)
  constant c_FIFO_DEPTH0    : integer := 16;
  -- FIFO prog_full threshold (expressed in words)
  constant c_FIFO_PROG_FULL : integer := c_FIFO_DEPTH0 - 5;
  -- FIFO width (expressed in bits)
  constant c_FIFO_WIDTH0    : integer := c_CMD_IDX2_H + 1;

  -- fifo: write side
  -- fifo: write
  signal wr_tmp0    : std_logic;
  -- fifo: data_in
  signal data_tmp0  : std_logic_vector(c_FIFO_WIDTH0 - 1 downto 0);
  -- fifo: full flag
  -- signal full0        : std_logic;
  -- fifo: prog_full flag
  signal prog_full0 : std_logic;
  -- fifo: rst_busy flag
  -- signal wr_rst_busy0 : std_logic;

  -- fifo: read side
  -- fifo: read
  signal rd1       : std_logic;
  -- fifo: data_out
  signal data_tmp1 : std_logic_vector(c_FIFO_WIDTH0 - 1 downto 0);
  -- fifo: empty flag
  signal empty1    : std_logic;
  -- fifo: rst_busy flag
  -- signal rd_rst_busy1 : std_logic;

  -- extract pulse_height from the input command
  signal cmd_pulse_height1 : std_logic_vector(i_cmd_pulse_height'range);
  -- extract pixel_id from the input command
  signal cmd_pixel_id1     : std_logic_vector(i_cmd_pixel_id'range);
  -- extract time_shift from the input command
  signal cmd_time_shift1   : std_logic_vector(i_cmd_time_shift'range);

  -- fifo: errors
  signal errors_sync : std_logic_vector(3 downto 0);
  -- fifo: empty flag
  signal empty_sync  : std_logic;

  -- fifo: ready
  signal cmd_ready_r1 : std_logic := '0';

  -------------------------------------------------------------------
  -- compute pipe indexes
  --   Note: shared by more than 1 pipeliner
  -------------------------------------------------------------------
  constant c_IDX0_L : integer := 0; -- index0: low
  constant c_IDX0_H : integer := c_IDX0_L + i_pixel_id'length - 1; -- index0: high

  constant c_IDX1_L : integer := c_IDX0_H + 1; -- index1: low
  constant c_IDX1_H : integer := c_IDX1_L + 1 - 1; -- index1: high

  constant c_IDX2_L : integer := c_IDX1_H + 1; -- index2: low
  constant c_IDX2_H : integer := c_IDX2_L + 1 - 1; -- index2: high

  constant c_IDX3_L : integer := c_IDX2_H + 1; -- index3: low
  constant c_IDX3_H : integer := c_IDX3_L + 1 - 1; -- index3: high

  constant c_IDX4_L : integer := c_IDX3_H + 1; -- index4: low
  constant c_IDX4_H : integer := c_IDX4_L + 1 - 1; -- index4: high

  constant c_IDX5_L : integer := c_IDX4_H + 1; -- index5: low
  constant c_IDX5_H : integer := c_IDX5_L + 1 - 1; -- index5: high

  constant c_IDX6_L : integer := c_IDX5_H + 1; -- index6: low
  constant c_IDX6_H : integer := c_IDX6_L + i_cmd_pulse_height'length - 1; -- index6: high

  ---------------------------------------------------------------------
  -- table
  ---------------------------------------------------------------------
  -- RAM: en_table
  signal en_table_wea   : std_logic; -- port A: en
  signal en_table_ena   : std_logic; -- port A: we
  signal en_table_addra : std_logic_vector(i_pixel_id'range);  -- port A: address
  signal en_table_dina  : std_logic_vector(0 downto 0); -- port A: data in
  --signal en_table_regcea : std_logic;-- port A: regce
  --signal en_table_douta  : std_logic_vector(0 downto 0); -- port A: data out

  signal en_table_enb    : std_logic; -- port B: en
  --signal en_table_web    : std_logic; -- port B: we
  signal en_table_addrb  : std_logic_vector(i_pixel_id'range); -- port B: address
  --signal en_table_dinb   : std_logic_vector(0 downto 0); -- port B: data in
  signal en_table_regceb : std_logic; -- port B: regce
  signal en_table_doutb  : std_logic_vector(0 downto 0); -- port B: data out

  -- temporary en value
  signal en_table_tmp : std_logic;

  -- RAM: pulse_heigth_table
  signal pulse_heigth_table_wea   : std_logic; -- port A: en
  signal pulse_heigth_table_ena   : std_logic; -- port A: we
  signal pulse_heigth_table_addra : std_logic_vector(i_pixel_id'range);  -- port A: address
  signal pulse_heigth_table_dina  : std_logic_vector(i_cmd_pulse_height'range); -- port A: data in
  --signal pulse_heigth_table_regcea : std_logic;-- port A: regce
  --signal pulse_heigth_table_douta  : std_logic_vector(0 downto 0); -- port A: data out

  signal pulse_heigth_table_enb    : std_logic; -- port B: en
  --signal pulse_heigth_table_web    : std_logic; -- port B: we
  signal pulse_heigth_table_addrb  : std_logic_vector(i_pixel_id'range); -- port B: address
  --signal pulse_heigth_table_dinb   : std_logic_vector(0 downto 0); -- port B: data in
  signal pulse_heigth_table_regceb : std_logic; -- port B: regce
  signal pulse_heigth_table_doutb  : std_logic_vector(i_cmd_pulse_height'range); -- port B: data out

  -- temporary pulse_heigth value
  signal pulse_heigth_table_tmp : std_logic_vector(i_cmd_pulse_height'range);

  -- RAM: time_shift_table
  signal time_shift_table_wea   : std_logic; -- port A: en
  signal time_shift_table_ena   : std_logic; -- port A: we
  signal time_shift_table_addra : std_logic_vector(i_pixel_id'range);  -- port A: address
  signal time_shift_table_dina  : std_logic_vector(i_cmd_time_shift'range); -- port A: data in
  --signal time_shift_table_regcea : std_logic; -- port A: regce
  --signal time_shift_table_douta  : std_logic_vector(0 downto 0); -- port A: data out

  signal time_shift_table_enb    : std_logic; -- port B: en
  --signal pulse_heigth_table_web    : std_logic; -- port B: we
  signal time_shift_table_addrb  : std_logic_vector(i_pixel_id'range); -- port B: address
  --signal time_shift_table_dinb   : std_logic_vector(0 downto 0); -- port B: data in
  signal time_shift_table_regceb : std_logic; -- port B: regce
  signal time_shift_table_doutb  : std_logic_vector(i_cmd_time_shift'range); -- port B: data out

  -- temporary time_shift value
  signal time_shift_table_tmp : std_logic_vector(i_cmd_time_shift'range);

  -- RAM: cnt_sample_pulse_shape_table
  signal cnt_sample_pulse_shape_table_wea   : std_logic; -- port A: en
  signal cnt_sample_pulse_shape_table_ena   : std_logic; -- port A: we
  signal cnt_sample_pulse_shape_table_addra : std_logic_vector(i_pixel_id'range);  -- port A: address
  signal cnt_sample_pulse_shape_table_dina  : std_logic_vector(g_NB_SAMPLE_BY_FRAME_WIDTH - 1 downto 0); -- port A: data in
  --signal cnt_sample_pulse_shape_table_regcea : std_logic; -- port A: regce
  --signal cnt_sample_pulse_shape_table_douta  : std_logic_vector(0 downto 0); -- port A: data out

  signal cnt_sample_pulse_shape_table_enb    : std_logic; -- port B: en
  --signal cnt_sample_pulse_shapeth_table_web    : std_logic; -- port B: we
  signal cnt_sample_pulse_shape_table_addrb  : std_logic_vector(i_pixel_id'range); -- port B: address
  --signal cnt_sample_pulse_shape_table_dinb   : std_logic_vector(0 downto 0); -- port B: data in
  signal cnt_sample_pulse_shape_table_regceb : std_logic; -- port B: regce
  signal cnt_sample_pulse_shape_table_doutb  : std_logic_vector(g_NB_SAMPLE_BY_FRAME_WIDTH - 1 downto 0); -- port B: data out

  -- temporary cnt_sample_pulse_shape value
  signal cnt_sample_pulse_shape_table_tmp : std_logic_vector(g_NB_SAMPLE_BY_FRAME_WIDTH - 1 downto 0);

  ---------------------------------------------------------------------
  -- sync with the table out
  ---------------------------------------------------------------------
  signal data_pipe_table_tmp0 : std_logic_vector(c_IDX3_H downto 0); -- temporary input pipe
  signal data_pipe_table_tmp1 : std_logic_vector(c_IDX3_H downto 0); -- temporary output pipe

  signal pixel_valid_ra : std_logic; -- data_valid
  signal pixel_sof_ra   : std_logic; -- first pixel sample
  signal pixel_eof_ra   : std_logic; -- last pixel sample
  signal pixel_id_ra    : std_logic_vector(i_pixel_id'range); -- pixel_id

  ---------------------------------------------------------------------
  -- State machine
  ---------------------------------------------------------------------
  type t_state is (E_RST0, E_RST1, E_WAIT, E_RUN);
  signal sm_state_next : t_state; -- state
  signal sm_state_r1   : t_state := E_RST0; -- state (registered)

  signal cmd_rd_next : std_logic; -- read command
  signal cmd_rd_r1   : std_logic := '0'; -- read command (registered)

  -- flag to update the table content
  signal first_next : std_logic;
  -- flag to update the table content (registered)
  signal first_r1   : std_logic := '0';

  -- last sample of the pulse
  signal last_sample_pulse_shape_next : std_logic;
  -- last sample of the pulse (registered)
  signal last_sample_pulse_shape_r1   : std_logic := '0';

  -- pixel_valid
  signal pixel_valid_next : std_logic;
  -- pixel_valid (registered)
  signal pixel_valid_r1   : std_logic := '0';

  -- first processed sample of a pulse
  signal pulse_sof_next : std_logic;
  -- first processed sample of a pulse (registered)
  signal pulse_sof_r1   : std_logic := '0';

  ---- last processed sample of a pulse
  signal pulse_eof_next : std_logic;
  ---- last processed sample of a pulse (registered)
  signal pulse_eof_r1   : std_logic := '0';

  -- enabled pixel
  signal en_next : std_logic;
  -- enabled pixel (registered)
  signal en_r1   : std_logic := '0';

  -- parameters for the computation
  -- pulse_heigth value
  signal pulse_heigth_next : unsigned(i_cmd_pulse_height'range);
  -- pulse_heigth value (registered)
  signal pulse_heigth_r1   : unsigned(i_cmd_pulse_height'range) := (others => '0');

  -- time_shift value
  signal time_shift_next : unsigned(i_cmd_time_shift'range);
  -- time_shift value (registered)
  signal time_shift_r1   : unsigned(i_cmd_time_shift'range) := (others => '0');

  -- pulse sample counter
  signal cnt_sample_pulse_shape_next : unsigned(g_NB_SAMPLE_BY_FRAME_WIDTH - 1 downto 0);
  -- pulse sample counter (register)
  signal cnt_sample_pulse_shape_r1   : unsigned(g_NB_SAMPLE_BY_FRAME_WIDTH - 1 downto 0) := (others => '0');

  -- parameters to store in the tables
  -- RAM: write enable
  signal ram_wr_en_next : std_logic;
  -- RAM: write enable (registered)
  signal ram_wr_en_r1   : std_logic := '0';

  -- RAM: write enable
  signal ram_wr_pulse_heigth_next : std_logic;
  -- RAM: write enable (registered)
  signal ram_wr_pulse_heigth_r1   : std_logic := '0';

  -- RAM: write enable
  signal ram_wr_time_shift_next : std_logic;
  -- RAM: write enable (registered)
  signal ram_wr_time_shift_r1   : std_logic := '0';

  -- RAM: write enable
  signal ram_wr_cnt_sample_pulse_shape_next : std_logic;
  -- RAM: write enable (registered)
  signal ram_wr_cnt_sample_pulse_shape_r1   : std_logic := '0';

  -- RAM: shared address (write side)
  signal ram_addr_next : unsigned(i_pixel_id'range);
  -- RAM: shared address (write side: registered)
  signal ram_addr_r1   : unsigned(i_pixel_id'range);

  -- RAM (en): data to write
  signal ram_en_next : std_logic;
  -- RAM (en): data to write (registered)
  signal ram_en_r1   : std_logic := '0';

  -- RAM (pulse_heigth): data to write
  signal ram_pulse_heigth_next : unsigned(i_cmd_pulse_height'range);
  -- RAM (pulse_heigth): data to write (registered)
  signal ram_pulse_heigth_r1   : unsigned(i_cmd_pulse_height'range) := (others => '0');

  -- RAM (time_shift): data to write
  signal ram_time_shift_next : unsigned(i_cmd_time_shift'range);
  -- RAM (time_shift): data to write (registered)
  signal ram_time_shift_r1   : unsigned(i_cmd_time_shift'range) := (others => '0');

  -- RAM (cnt_sample_pulse_shape): data to write
  signal ram_cnt_sample_pulse_shape_next : unsigned(g_NB_SAMPLE_BY_FRAME_WIDTH - 1 downto 0);
  -- RAM (cnt_sample_pulse_shape): data to write (registered)
  signal ram_cnt_sample_pulse_shape_r1   : unsigned(g_NB_SAMPLE_BY_FRAME_WIDTH - 1 downto 0) := (others => '0');

  ---------------------------------------------------------------------
  -- sync with the address computation output
  ---------------------------------------------------------------------
  signal data_pipe_tmp0 : std_logic_vector(c_IDX2_H downto 0); -- temporary input pipe
  signal data_pipe_tmp1 : std_logic_vector(c_IDX2_H downto 0); -- temporary output pipe

  signal pixel_sof_rc : std_logic; -- first pixel sample
  signal pixel_eof_rc : std_logic; -- last pixel sample
  signal pixel_id_rc  : std_logic_vector(i_pixel_id'range); -- pixel_id

  signal pulse_heigth_rc : std_logic_vector(i_cmd_pulse_height'range); -- pulse_heigth value

  -- address computation
  signal pulse_sof_rc        : std_logic; -- first pixel sample
  signal pulse_eof_rc        : std_logic; -- last pixel sample
  signal pixel_valid_rc      : std_logic; -- pixel valid
  -- address of the pulse_shape RAM
  signal addr_pulse_shape_rc : std_logic_vector(i_pulse_shape_wr_rd_addr'range);

  constant c_MULT_IDX0_L : integer := 0; -- index0: low
  constant c_MULT_IDX0_H : integer := c_MULT_IDX0_L + i_cmd_pulse_height'length - 1; -- index0: high

  constant c_MULT_IDX1_L : integer := c_MULT_IDX0_H + 1; -- index1: low
  constant c_MULT_IDX1_H : integer := c_MULT_IDX1_L + 1 - 1; -- index1: high

  constant c_MULT_IDX2_L : integer := c_MULT_IDX1_H + 1; -- index2: low
  constant c_MULT_IDX2_H : integer := c_MULT_IDX2_L + 1 - 1; -- index2: high

  constant c_MULT_IDX3_L : integer := c_MULT_IDX2_H + 1; -- index2: low
  constant c_MULT_IDX3_H : integer := c_MULT_IDX3_L + 1 - 1; -- index2: high

   -- temporary input pipe
  signal data_pipe_mult_tmp0 : std_logic_vector(c_MULT_IDX3_H downto 0);
  -- temporary output pipe
  signal data_pipe_mult_tmp1 : std_logic_vector(c_MULT_IDX3_H downto 0);

  ---------------------------------------------------------------------
  -- tes_pulse_shape
  ---------------------------------------------------------------------
  -- RAM
  signal pulse_shape_wea    : std_logic; -- port A: en
  signal pulse_shape_ena    : std_logic; -- port A: we
  signal pulse_shape_addra  : std_logic_vector(i_pulse_shape_wr_rd_addr'range);  -- port A: address
  signal pulse_shape_dina   : std_logic_vector(i_pulse_shape_wr_data'range); -- port A: data in
  signal pulse_shape_regcea : std_logic;-- port A: regce
  signal pulse_shape_douta  : std_logic_vector(i_pulse_shape_wr_data'range); -- port A: data out

  signal pulse_shape_enb    : std_logic; -- port B: en
  signal pulse_shape_web    : std_logic; -- port B: we
  signal pulse_shape_addrb  : std_logic_vector(i_pulse_shape_wr_rd_addr'range); -- port B: address
  signal pulse_shape_dinb   : std_logic_vector(i_pulse_shape_wr_data'range); -- port B: data in
  signal pulse_shape_regceb : std_logic; -- port B: regce
  signal pulse_shape_doutb  : std_logic_vector(i_pulse_shape_wr_data'range); -- port B: data out

  -- sync with rd RAM output
  signal pulse_shape_rd_en_rz : std_logic;
  -- ram check
  signal pulse_shape_error    : std_logic;

  ---------------------------------------------------------------------
  -- tes_pulse_shape
  ---------------------------------------------------------------------
  -- RAM
  signal steady_state_wea    : std_logic; -- port A: en
  signal steady_state_ena    : std_logic; -- port A: we
  signal steady_state_addra  : std_logic_vector(i_steady_state_wr_rd_addr'range);  -- port A: address
  signal steady_state_dina   : std_logic_vector(i_steady_state_wr_data'range); -- port A: data in
  signal steady_state_regcea : std_logic;-- port A: regce
  signal steady_state_douta  : std_logic_vector(i_steady_state_wr_data'range); -- port A: data out

  signal steady_state_enb    : std_logic; -- port B: en
  signal steady_state_web    : std_logic; -- port B: we
  signal steady_state_addrb  : std_logic_vector(i_steady_state_wr_rd_addr'range); -- port B: address
  signal steady_state_dinb   : std_logic_vector(i_steady_state_wr_data'range); -- port B: data in
  signal steady_state_regceb : std_logic; -- port B: regce
  signal steady_state_doutb  : std_logic_vector(i_steady_state_wr_data'range); -- port B: data out

  -- sync with rd RAM output
  signal steady_state_rd_en_rz : std_logic;
  -- ram check error
  signal steady_state_error    : std_logic;

  ---------------------------------------------------------------------
  -- sync with RAM outputs
  ---------------------------------------------------------------------
  signal data_pipe_tmp2 : std_logic_vector(c_IDX6_H downto 0); -- temporary input pipe
  signal data_pipe_tmp3 : std_logic_vector(c_IDX6_H downto 0); -- temporary output pipe

  signal pulse_sof_rx   : std_logic; -- first processed sample of a pulse
  signal pulse_eof_rx   : std_logic; -- last processed sample of a pulse
  signal pixel_sof_rx   : std_logic; -- first pixel sample
  signal pixel_eof_rx   : std_logic; -- last pixel sample
  signal pixel_valid_rx : std_logic; -- pixel valid
  signal pixel_id_rx    : std_logic_vector(i_pixel_id'range); -- pixel_id

  -- pulse_heigth value
  signal pulse_heigth_rx : std_logic_vector(i_cmd_pulse_height'range);

  ------------------------------------------------------------------
  -- mult_sub_sfixed
  ------------------------------------------------------------------
  -- add sign bit
  -- operator: input_a
  signal pulse_shape_tmp  : std_logic_vector(pkg_TES_MULT_SUB_Q_WIDTH_A - 1 downto 0);
  -- operator: input_b
  signal pulse_heigth_tmp : std_logic_vector(pkg_TES_MULT_SUB_Q_WIDTH_B - 1 downto 0);
  -- operator: input_c
  signal steady_state_tmp : std_logic_vector(pkg_TES_MULT_SUB_Q_WIDTH_C - 1 downto 0);
  -- operator: output
  signal result_ry : std_logic_vector(o_pixel_result'range);

  -------------------------------------------------------------------
  -- sync with tes_pulse_shape_manager_computation out
  -------------------------------------------------------------------
   -- temporary input pipe
  signal data_pipe_tmp4 : std_logic_vector(c_IDX5_H downto 0);
   -- temporary output pipe
  signal data_pipe_tmp5 : std_logic_vector(c_IDX5_H downto 0);

  signal pulse_sof_ry : std_logic; -- first processed sample of a pulse
  signal pulse_eof_ry : std_logic; -- last processed sample of a pulse

  signal pixel_sof_ry   : std_logic; -- first pixel sample
  signal pixel_eof_ry   : std_logic; -- last pixel sample
  signal pixel_valid_ry : std_logic; -- pixel valid
  signal pixel_id_ry    : std_logic_vector(i_pixel_id'range); -- pixel_id

  -------------------------------------------------------------------
  -- force output value when negative
  -------------------------------------------------------------------
  -- sign value
  signal sign_value_tmp6 : std_logic;
  -- data
  signal result_rz       : std_logic_vector(o_pixel_result'range);

  -------------------------------------------------------------------
  -- sync with p_force_output_value_when_negative output
  -------------------------------------------------------------------
   -- temporary input pipe
  signal data_pipe_tmp6 : std_logic_vector(c_IDX5_H downto 0);
   -- temporary output pipe
  signal data_pipe_tmp7 : std_logic_vector(c_IDX5_H downto 0);

  signal pulse_sof_rz : std_logic; -- first processed sample of a pulse
  signal pulse_eof_rz : std_logic; -- last processed sample of a pulse

  signal pixel_sof_rz   : std_logic; -- first pixel sample
  signal pixel_eof_rz   : std_logic; -- last pixel sample
  signal pixel_valid_rz : std_logic; -- pixel valid
  signal pixel_id_rz    : std_logic_vector(i_pixel_id'range); -- pixel_id

  ---------------------------------------------------------------------
  -- detect output negative value
  ---------------------------------------------------------------------
  -- sign value
  signal sign_value       : std_logic;

  -- detection of a negative value: valid signal
  signal pixel_neg_out_valid    : std_logic;
  -- detection of a negative value: associated error flag
  signal pixel_neg_out_error    : std_logic;
  -- detection of a negative value: associated pixel_id
  signal pixel_neg_out_pixel_id : std_logic_vector(i_pixel_id'range);

  ---------------------------------------------------------------------
  -- error latching
  ---------------------------------------------------------------------
  constant c_NB_ERRORS : integer := 5; -- define the width of the temporary errors signals
  signal error_tmp     : std_logic_vector(c_NB_ERRORS - 1 downto 0); -- temporary input errors
  signal error_tmp_bis : std_logic_vector(c_NB_ERRORS - 1 downto 0); -- temporary output errors


begin

  ---------------------------------------------------------------------
  -- commands
  ---------------------------------------------------------------------
  wr_tmp0                                     <= i_cmd_valid;
  data_tmp0(c_CMD_IDX2_H downto c_CMD_IDX2_L) <= i_cmd_pulse_height;
  data_tmp0(c_CMD_IDX1_H downto c_CMD_IDX1_L) <= i_cmd_pixel_id;
  data_tmp0(c_CMD_IDX0_H downto c_CMD_IDX0_L) <= i_cmd_time_shift;

  inst_fifo_sync_with_error_prog_full_cmd : entity work.fifo_sync_with_error_prog_full
    generic map(
      g_FIFO_MEMORY_TYPE  => "distributed",
      g_FIFO_READ_LATENCY => 1,
      g_FIFO_WRITE_DEPTH  => c_FIFO_DEPTH0,
      g_PROG_FULL_THRESH  => c_FIFO_PROG_FULL,
      g_READ_DATA_WIDTH   => data_tmp0'length,
      g_READ_MODE         => "fwft",
      g_WRITE_DATA_WIDTH  => data_tmp0'length
      )
    port map(
      ---------------------------------------------------------------------
      -- write side
      ---------------------------------------------------------------------
      i_wr_clk        => i_clk,
      i_wr_rst        => i_rst,
      i_wr_en         => wr_tmp0,
      i_wr_din        => data_tmp0,
      o_wr_full       => open,
      o_wr_prog_full  => prog_full0,
      o_wr_rst_busy   => open,
      ---------------------------------------------------------------------
      -- port B
      ---------------------------------------------------------------------
      i_rd_en         => rd1,
      o_rd_dout_valid => open,
      o_rd_dout       => data_tmp1,
      o_rd_empty      => empty1,
      o_rd_rst_busy   => open,
      ---------------------------------------------------------------------
      --  errors/status
      ---------------------------------------------------------------------
      o_errors_sync   => errors_sync,
      o_empty_sync    => empty_sync
      );
  rd1 <= cmd_rd_r1;

  p_prog_full : process(i_clk)
  begin
    if rising_edge(i_clk) then
      cmd_ready_r1 <= not (prog_full0);
    end if;
  end process p_prog_full;
  o_cmd_ready <= cmd_ready_r1;

  cmd_pulse_height1 <= data_tmp1(c_CMD_IDX2_H downto c_CMD_IDX2_L);
  cmd_pixel_id1     <= data_tmp1(c_CMD_IDX1_H downto c_CMD_IDX1_L);
  cmd_time_shift1   <= data_tmp1(c_CMD_IDX0_H downto c_CMD_IDX0_L);

  ---------------------------------------------------------------------
  -- memory
  ---------------------------------------------------------------------
  -- en_table
  en_table_wea     <= ram_wr_en_r1;
  en_table_ena     <= ram_wr_en_r1;
  en_table_addra   <= std_logic_vector(ram_addr_r1);
  en_table_dina(0) <= ram_en_r1;
  inst_sdpram_en_table : entity work.sdpram
    generic map(
      g_ADDR_WIDTH_A       => en_table_addra'length,
      g_BYTE_WRITE_WIDTH_A => en_table_dina'length,  -- to enable word-wide writes on port A, specify the same value as for WRITE_DATA_WIDTH_A.
      g_WRITE_DATA_WIDTH_A => en_table_dina'length,
      g_ADDR_WIDTH_B       => en_table_addrb'length,
      g_WRITE_MODE_B       => "no_change",  -- no_change, read_first, write_first
      g_READ_DATA_WIDTH_B  => en_table_doutb'length,
      g_READ_LATENCY_B     => pkg_TES_TABLE_RAM_RD_LATENCY,  -- memory block > 1, Values larger than 2 synthesize additional flip-flops that are not retimed into memory primitives.
      g_CLOCKING_MODE      => "common_clock",
      g_MEMORY_PRIMITIVE   => "auto",
      g_MEMORY_SIZE        => c_MEMORY_SIZE_EN_TABLE,
      g_MEMORY_INIT_FILE   => "none",
      g_MEMORY_INIT_PARAM  => ""
      )
    port map(
      ---------------------------------------------------------------------
      -- port A
      ---------------------------------------------------------------------
      i_clka   => i_clk,                -- clock
      i_ena    => en_table_ena,         -- memory enable
      i_wea(0) => en_table_wea,         -- write enable
      i_addra  => en_table_addra,       -- write address
      i_dina   => en_table_dina,        -- write data input
      ---------------------------------------------------------------------
      -- port B
      ---------------------------------------------------------------------
      i_rstb   => i_rst,                -- reset the ouput register
      i_clkb   => i_clk,                -- clock
      i_enb    => en_table_enb,         -- memory enable
      i_addrb  => en_table_addrb,       -- read address
      i_regceb => en_table_regceb,  -- clock enable for the last register stage on the output data path
      o_doutb  => en_table_doutb        -- read data output
      );
  en_table_enb    <= i_pixel_valid;
  en_table_addrb  <= i_pixel_id;
  en_table_regceb <= '1';

  en_table_tmp <= en_table_doutb(0);

  -- pulse_heigth_table
  pulse_heigth_table_wea   <= ram_wr_pulse_heigth_r1;
  pulse_heigth_table_ena   <= ram_wr_pulse_heigth_r1;
  pulse_heigth_table_addra <= std_logic_vector(ram_addr_r1);
  pulse_heigth_table_dina  <= std_logic_vector(ram_pulse_heigth_r1);
  inst_sdpram_pulse_heigth_table : entity work.sdpram
    generic map(
      g_ADDR_WIDTH_A       => pulse_heigth_table_addra'length,
      g_BYTE_WRITE_WIDTH_A => pulse_heigth_table_dina'length,  -- to enable word-wide writes on port A, specify the same value as for WRITE_DATA_WIDTH_A.
      g_WRITE_DATA_WIDTH_A => pulse_heigth_table_dina'length,
      g_ADDR_WIDTH_B       => pulse_heigth_table_addrb'length,
      g_WRITE_MODE_B       => "no_change",  -- no_change, read_first, write_first
      g_READ_DATA_WIDTH_B  => pulse_heigth_table_doutb'length,
      g_READ_LATENCY_B     => pkg_TES_TABLE_RAM_RD_LATENCY,  -- memory block > 1, Values larger than 2 synthesize additional flip-flops that are not retimed into memory primitives.
      g_CLOCKING_MODE      => "common_clock",
      g_MEMORY_PRIMITIVE   => "auto",
      g_MEMORY_SIZE        => c_MEMORY_SIZE_PULSE_HEIGTH_TABLE,
      g_MEMORY_INIT_FILE   => "none",
      g_MEMORY_INIT_PARAM  => ""
      )
    port map(
      ---------------------------------------------------------------------
      -- port A
      ---------------------------------------------------------------------
      i_clka   => i_clk,                -- clock
      i_ena    => pulse_heigth_table_ena,   -- memory enable
      i_wea(0) => pulse_heigth_table_wea,   -- write enable
      i_addra  => pulse_heigth_table_addra,   -- write address
      i_dina   => pulse_heigth_table_dina,  -- write data input
      ---------------------------------------------------------------------
      -- port B
      ---------------------------------------------------------------------
      i_rstb   => i_rst,                -- reset the ouput register
      i_clkb   => i_clk,                -- clock
      i_enb    => pulse_heigth_table_enb,   -- memory enable
      i_addrb  => pulse_heigth_table_addrb,   -- read address
      i_regceb => pulse_heigth_table_regceb,  -- clock enable for the last register stage on the output data path
      o_doutb  => pulse_heigth_table_doutb  -- read data output
      );
  pulse_heigth_table_enb    <= i_pixel_valid;
  pulse_heigth_table_addrb  <= i_pixel_id;
  pulse_heigth_table_regceb <= '1';

  pulse_heigth_table_tmp <= pulse_heigth_table_doutb;

  -- time_shift_table
  time_shift_table_wea   <= ram_wr_time_shift_r1;
  time_shift_table_ena   <= ram_wr_time_shift_r1;
  time_shift_table_addra <= std_logic_vector(ram_addr_r1);
  time_shift_table_dina  <= std_logic_vector(ram_time_shift_r1);
  inst_sdpram_time_shift_table : entity work.sdpram
    generic map(
      g_ADDR_WIDTH_A       => time_shift_table_addra'length,
      g_BYTE_WRITE_WIDTH_A => time_shift_table_dina'length,  -- to enable word-wide writes on port A, specify the same value as for WRITE_DATA_WIDTH_A.
      g_WRITE_DATA_WIDTH_A => time_shift_table_dina'length,
      g_ADDR_WIDTH_B       => time_shift_table_addrb'length,
      g_WRITE_MODE_B       => "no_change",  -- no_change, read_first, write_first
      g_READ_DATA_WIDTH_B  => time_shift_table_doutb'length,
      g_READ_LATENCY_B     => pkg_TES_TABLE_RAM_RD_LATENCY,  -- memory block > 1, Values larger than 2 synthesize additional flip-flops that are not retimed into memory primitives.
      g_CLOCKING_MODE      => "common_clock",
      g_MEMORY_PRIMITIVE   => "auto",
      g_MEMORY_SIZE        => c_MEMORY_SIZE_TIME_SHIFT_TABLE,
      g_MEMORY_INIT_FILE   => "none",
      g_MEMORY_INIT_PARAM  => ""
      )
    port map(
      ---------------------------------------------------------------------
      -- port A
      ---------------------------------------------------------------------
      i_clka   => i_clk,                -- clock
      i_ena    => time_shift_table_ena,     -- memory enable
      i_wea(0) => time_shift_table_wea,     -- write enable
      i_addra  => time_shift_table_addra,   -- write address
      i_dina   => time_shift_table_dina,    -- write data input
      ---------------------------------------------------------------------
      -- port B
      ---------------------------------------------------------------------
      i_rstb   => i_rst,                -- reset the ouput register
      i_clkb   => i_clk,                -- clock
      i_enb    => time_shift_table_enb,     -- memory enable
      i_addrb  => time_shift_table_addrb,   -- read address
      i_regceb => time_shift_table_regceb,  -- clock enable for the last register stage on the output data path
      o_doutb  => time_shift_table_doutb    -- read data output
      );
  time_shift_table_enb    <= i_pixel_valid;
  time_shift_table_addrb  <= i_pixel_id;
  time_shift_table_regceb <= '1';

  time_shift_table_tmp <= time_shift_table_doutb;

  -- cnt_sample_pulse_shape_table
  cnt_sample_pulse_shape_table_wea   <= ram_wr_cnt_sample_pulse_shape_r1;
  cnt_sample_pulse_shape_table_ena   <= ram_wr_cnt_sample_pulse_shape_r1;
  cnt_sample_pulse_shape_table_addra <= std_logic_vector(ram_addr_r1);
  cnt_sample_pulse_shape_table_dina  <= std_logic_vector(ram_cnt_sample_pulse_shape_r1);
  inst_sdpram_cnt_sample_pulse_shape_table : entity work.sdpram
    generic map(
      g_ADDR_WIDTH_A       => cnt_sample_pulse_shape_table_addra'length,
      g_BYTE_WRITE_WIDTH_A => cnt_sample_pulse_shape_table_dina'length,  -- to enable word-wide writes on port A, specify the same value as for WRITE_DATA_WIDTH_A.
      g_WRITE_DATA_WIDTH_A => cnt_sample_pulse_shape_table_dina'length,
      g_ADDR_WIDTH_B       => cnt_sample_pulse_shape_table_addrb'length,
      g_WRITE_MODE_B       => "no_change",  -- no_change, read_first, write_first
      g_READ_DATA_WIDTH_B  => cnt_sample_pulse_shape_table_doutb'length,
      g_READ_LATENCY_B     => pkg_TES_TABLE_RAM_RD_LATENCY,  -- memory block > 1, Values larger than 2 synthesize additional flip-flops that are not retimed into memory primitives.
      g_CLOCKING_MODE      => "common_clock",
      g_MEMORY_PRIMITIVE   => "auto",
      g_MEMORY_SIZE        => c_MEMORY_SIZE_CNT_SAMPLE_PULSE_SHAPE_TABLE,
      g_MEMORY_INIT_FILE   => "none",
      g_MEMORY_INIT_PARAM  => ""
      )
    port map(
      ---------------------------------------------------------------------
      -- port A
      ---------------------------------------------------------------------
      i_clka   => i_clk,                -- clock
      i_ena    => cnt_sample_pulse_shape_table_ena,     -- memory enable
      i_wea(0) => cnt_sample_pulse_shape_table_wea,     -- write enable
      i_addra  => cnt_sample_pulse_shape_table_addra,   -- write address
      i_dina   => cnt_sample_pulse_shape_table_dina,    -- write data input
      ---------------------------------------------------------------------
      -- port B
      ---------------------------------------------------------------------
      i_rstb   => i_rst,                -- reset the ouput register
      i_clkb   => i_clk,                -- clock
      i_enb    => cnt_sample_pulse_shape_table_enb,     -- memory enable
      i_addrb  => cnt_sample_pulse_shape_table_addrb,   -- read address
      i_regceb => cnt_sample_pulse_shape_table_regceb,  -- clock enable for the last register stage on the output data path
      o_doutb  => cnt_sample_pulse_shape_table_doutb    -- read data output
      );
  cnt_sample_pulse_shape_table_enb    <= i_pixel_valid;
  cnt_sample_pulse_shape_table_addrb  <= i_pixel_id;
  cnt_sample_pulse_shape_table_regceb <= '1';

  cnt_sample_pulse_shape_table_tmp <= cnt_sample_pulse_shape_table_doutb;


  ---------------------------------------------------------------------
  -- sync with output table
  ---------------------------------------------------------------------
  data_pipe_table_tmp0(c_IDX3_H)                 <= i_pixel_valid;
  data_pipe_table_tmp0(c_IDX2_H)                 <= i_pixel_sof;
  data_pipe_table_tmp0(c_IDX1_H)                 <= i_pixel_eof;
  data_pipe_table_tmp0(c_IDX0_H downto c_IDX0_L) <= i_pixel_id;

  inst_pipeliner_sync_with_table_output : entity work.pipeliner
    generic map(
      g_NB_PIPES   => pkg_TES_TABLE_RAM_RD_LATENCY,
      g_DATA_WIDTH => data_pipe_table_tmp0'length
      )
    port map(
      i_clk  => i_clk,
      i_data => data_pipe_table_tmp0,
      o_data => data_pipe_table_tmp1
      );

  pixel_valid_ra <= data_pipe_table_tmp1(c_IDX3_H);
  pixel_sof_ra   <= data_pipe_table_tmp1(c_IDX2_H);
  pixel_eof_ra   <= data_pipe_table_tmp1(c_IDX1_H);
  pixel_id_ra    <= data_pipe_table_tmp1(c_IDX0_H downto c_IDX0_L);

  ---------------------------------------------------------------------
  -- state machine
  ---------------------------------------------------------------------
  p_decode_state : process(cmd_pixel_id1, cmd_pulse_height1, cmd_time_shift1,
                           cnt_sample_pulse_shape_r1,
                           cnt_sample_pulse_shape_table_tmp, empty1, en_r1,
                           en_table_tmp, first_r1, last_sample_pulse_shape_r1,
                           pixel_eof_ra, pixel_id_ra, pixel_sof_ra,
                           pixel_valid_ra, pulse_heigth_r1,
                           pulse_heigth_table_tmp, ram_addr_r1,
                           ram_cnt_sample_pulse_shape_r1, ram_en_r1,
                           ram_pulse_heigth_r1, ram_time_shift_r1, sm_state_r1,
                           time_shift_r1, time_shift_table_tmp) is
  begin
    -- default value
    cmd_rd_next <= '0';

    first_next                   <= first_r1;
    last_sample_pulse_shape_next <= last_sample_pulse_shape_r1;
    pixel_valid_next             <= '0';
    pulse_sof_next               <= '0';
    pulse_eof_next               <= '0';

    en_next                     <= en_r1;
    pulse_heigth_next           <= pulse_heigth_r1;
    time_shift_next             <= time_shift_r1;
    cnt_sample_pulse_shape_next <= cnt_sample_pulse_shape_r1;

    ram_wr_en_next                     <= '0';
    ram_wr_pulse_heigth_next           <= '0';
    ram_wr_time_shift_next             <= '0';
    ram_wr_cnt_sample_pulse_shape_next <= '0';

    ram_addr_next                   <= ram_addr_r1;
    ram_en_next                     <= ram_en_r1;
    ram_pulse_heigth_next           <= ram_pulse_heigth_r1;
    ram_time_shift_next             <= ram_time_shift_r1;
    ram_cnt_sample_pulse_shape_next <= ram_cnt_sample_pulse_shape_r1;

    case sm_state_r1 is
      when E_RST0 =>
        ram_addr_next <= (others => '0');
        -- init values for table initialization in the next step
        sm_state_next <= E_RST1;

      when E_RST1 =>

        ram_wr_en_next                     <= '1';
        ram_wr_pulse_heigth_next           <= '1';
        ram_wr_time_shift_next             <= '1';
        ram_wr_cnt_sample_pulse_shape_next <= '1';

        ram_en_next                     <= '0';
        ram_pulse_heigth_next           <= (others => '0');
        ram_time_shift_next             <= (others => '0');
        ram_cnt_sample_pulse_shape_next <= (others => '0');

        ram_addr_next <= ram_addr_r1 + 1;

        if ram_addr_r1 = c_CNT_MAX then
          sm_state_next <= E_WAIT;
        else
          sm_state_next <= E_RST1;
        end if;

      when E_WAIT =>
        pixel_valid_next <= pixel_valid_ra;

        -- for the current pixel, detect if this is the last sample of the pulse shape.
        if unsigned(cnt_sample_pulse_shape_table_tmp) = to_unsigned(c_NB_FRAME_BY_PULSE_SHAPE - 1, cnt_sample_pulse_shape_table_tmp'length) then
          last_sample_pulse_shape_next <= '1';
        else
          last_sample_pulse_shape_next <= '0';
        end if;

        ram_addr_next <= unsigned(pixel_id_ra);

        if pixel_sof_ra = '1' and pixel_valid_ra = '1' then
          first_next <= '1';
          if (empty1 = '0') and (unsigned(cmd_pixel_id1) = unsigned(pixel_id_ra)) then
            -- read the command FIFO
            cmd_rd_next    <= '1';
            -- start processing pixel
            pulse_sof_next <= '1';

            -- latch data for the computation
            en_next                     <= '1';
            pulse_heigth_next           <= unsigned(cmd_pulse_height1);
            time_shift_next             <= unsigned(cmd_time_shift1);
            cnt_sample_pulse_shape_next <= (others => '0');

            -- save data in the tables
            ram_wr_en_next                     <= '1';
            ram_wr_pulse_heigth_next           <= '1';
            ram_wr_time_shift_next             <= '1';
            ram_wr_cnt_sample_pulse_shape_next <= '1';

            ram_en_next                     <= '1';
            ram_pulse_heigth_next           <= unsigned(cmd_pulse_height1);
            ram_time_shift_next             <= unsigned(cmd_time_shift1);
            ram_cnt_sample_pulse_shape_next <= (others => '0');
          else
            cmd_rd_next <= '0';

            -- latch data for the computation
            en_next                     <= en_table_tmp;
            pulse_heigth_next           <= unsigned(pulse_heigth_table_tmp);
            time_shift_next             <= unsigned(time_shift_table_tmp);
            cnt_sample_pulse_shape_next <= unsigned(cnt_sample_pulse_shape_table_tmp);

            -- save data in the tables
            ram_wr_en_next                     <= '1';
            ram_wr_pulse_heigth_next           <= '1';
            ram_wr_time_shift_next             <= '1';
            ram_wr_cnt_sample_pulse_shape_next <= '1';

            ram_en_next                     <= en_table_tmp;
            ram_pulse_heigth_next           <= unsigned(pulse_heigth_table_tmp);
            ram_time_shift_next             <= unsigned(time_shift_table_tmp);
            ram_cnt_sample_pulse_shape_next <= unsigned(cnt_sample_pulse_shape_table_tmp);
          end if;

          sm_state_next <= E_RUN;
        else
          sm_state_next <= E_WAIT;
        end if;

      when E_RUN =>
        pixel_valid_next <= pixel_valid_ra;
        ---------------------------------------------------------------------
        -- check the first_r1 bit to be able to update the table contents for the next processing as soon as possible.
        -- By anticipating, that's allows to absorb the latency on the table paths.
        -- If update is needed, it will be done only one time in this state.
        ---------------------------------------------------------------------
        if first_r1 = '1' then
          first_next <= '0';
          -- For the current pixel, the last sample of the pulse is reached (ex: frame 2047)
          if last_sample_pulse_shape_r1 = '1' then

            -- loop back on the first pulse sample (<=> frame 0) for the next processing.
            ram_wr_cnt_sample_pulse_shape_next <= '1';
            ram_cnt_sample_pulse_shape_next    <= (others => '0');

            if en_r1 = '1' then
              -- for the given pixel, the last sample of the pulse is reached => disable the pixel in the table.
              ram_wr_en_next           <= '1';
              ram_en_next              <= '0';
              -- for the given pixel, the last sample of the pulse is reached => zeroed the pulse_height in order to output IO (steady value) if a new command isn't received.
              ram_wr_pulse_heigth_next <= '1';
              ram_pulse_heigth_next    <= (others => '0');
            end if;

          else

            if en_r1 = '1' then
              -- for the current pixel, update table parameters because this isn't the last pulse shape sample.
              ram_wr_en_next                     <= '1';
              ram_wr_pulse_heigth_next           <= '1';
              ram_wr_time_shift_next             <= '1';
              ram_wr_cnt_sample_pulse_shape_next <= '1';

              ram_en_next                     <= '1';
              ram_time_shift_next             <= time_shift_r1;
              ram_pulse_heigth_next           <= pulse_heigth_r1;
              ram_cnt_sample_pulse_shape_next <= cnt_sample_pulse_shape_r1 + 1;

            end if;
          end if;

        end if;

        if pixel_eof_ra = '1' and pixel_valid_ra = '1' then
          -- reset the enable signal.
          en_next <= '0';

          if last_sample_pulse_shape_r1 = '1' then
            -- For the current pixel, the last sample of the pulse is reached.

            if en_r1 = '1' then
              -- end processing pixel
              pulse_eof_next <= '1';
            end if;
          end if;
          sm_state_next <= E_WAIT;
        else
          sm_state_next <= E_RUN;
        end if;

      when others =>
        sm_state_next <= E_RST0;
    end case;
  end process p_decode_state;

  p_state : process(i_clk) is
  begin
    if rising_edge(i_clk) then
      if i_rst = '1' then
        sm_state_r1 <= E_RST0;
      else
        sm_state_r1 <= sm_state_next;
      end if;
      cmd_rd_r1                  <= cmd_rd_next;
      first_r1                   <= first_next;
      last_sample_pulse_shape_r1 <= last_sample_pulse_shape_next;
      pixel_valid_r1             <= pixel_valid_next;
      pulse_sof_r1               <= pulse_sof_next;
      pulse_eof_r1               <= pulse_eof_next;

      -- parameters for the computation
      en_r1                     <= en_next;
      pulse_heigth_r1           <= pulse_heigth_next;
      time_shift_r1             <= time_shift_next;
      cnt_sample_pulse_shape_r1 <= cnt_sample_pulse_shape_next;

      -- parameters to store in the tables
      ram_wr_en_r1                     <= ram_wr_en_next;
      ram_wr_pulse_heigth_r1           <= ram_wr_pulse_heigth_next;
      ram_wr_time_shift_r1             <= ram_wr_time_shift_next;
      ram_wr_cnt_sample_pulse_shape_r1 <= ram_wr_cnt_sample_pulse_shape_next;

      ram_addr_r1                   <= ram_addr_next;
      ram_en_r1                     <= ram_en_next;
      ram_pulse_heigth_r1           <= ram_pulse_heigth_next;
      ram_time_shift_r1             <= ram_time_shift_next;
      ram_cnt_sample_pulse_shape_r1 <= ram_cnt_sample_pulse_shape_next;
    end if;
  end process p_state;

  ---------------------------------------------------------------------
  -- compute the tes_pulse_shape ram addr
  -- if the frame_size = 2048 and the step = max_shift = 16
  --  => addr_pulse_shape_rc = i*step + pixel_shift with i=[0,2047]
  ---------------------------------------------------------------------
  data_pipe_mult_tmp0(c_MULT_IDX3_H)                      <= pulse_sof_r1;
  data_pipe_mult_tmp0(c_MULT_IDX2_H)                      <= pulse_eof_r1;
  data_pipe_mult_tmp0(c_MULT_IDX1_H)                      <= pixel_valid_r1;
  data_pipe_mult_tmp0(c_MULT_IDX0_H downto c_MULT_IDX0_L) <= std_logic_vector(pulse_heigth_r1);
  inst_pipeliner_sync_with_mult_add_ufixed_out0 : entity work.pipeliner
    generic map(
      g_NB_PIPES   => pkg_MULT_ADD_UFIXED_LATENCY,
      g_DATA_WIDTH => data_pipe_mult_tmp0'length
      )
    port map(
      i_clk  => i_clk,
      i_data => data_pipe_mult_tmp0,
      o_data => data_pipe_mult_tmp1
      );

  pulse_sof_rc    <= data_pipe_mult_tmp1(c_MULT_IDX3_H);
  pulse_eof_rc    <= data_pipe_mult_tmp1(c_MULT_IDX2_H);
  pixel_valid_rc  <= data_pipe_mult_tmp1(c_MULT_IDX1_H);
  pulse_heigth_rc <= data_pipe_mult_tmp1(c_MULT_IDX0_H downto c_MULT_IDX0_L);

  inst_mult_add_ufixed : entity work.mult_add_ufixed
    generic map(
      -- port A: AMD Q notation (fixed point)
      g_UQ_M_A => cnt_sample_pulse_shape_r1'length,
      g_UQ_N_A => 0,
      -- requirement: FPASIM-FW-REQ-0110
      -- port B: AMD Q notation (fixed point)
      g_UQ_M_B => c_SHIFT_MAX_VECTOR'length,
      g_UQ_N_B => 0,
      -- requirement: FPASIM-FW-REQ-0110
      -- port C: AMC Q notation (fixed point)
      g_UQ_M_C => time_shift_r1'length,
      g_UQ_N_C => 0,
      -- port S: AMD Q notation (fixed point)
      g_UQ_M_S => addr_pulse_shape_rc'length,
      g_UQ_N_S => 0
      )
    port map(
      i_clk => i_clk,
      --------------------------------------------------------------
      -- input
      --------------------------------------------------------------
      i_a   => std_logic_vector(cnt_sample_pulse_shape_r1),
      i_b   => c_SHIFT_MAX_VECTOR,
      i_c   => std_logic_vector(time_shift_r1),
      --------------------------------------------------------------
      -- output : S = C + A*B
      --------------------------------------------------------------
      o_s   => addr_pulse_shape_rc
      );

  data_pipe_tmp0(c_IDX2_H)                 <= pixel_sof_ra;
  data_pipe_tmp0(c_IDX1_H)                 <= pixel_eof_ra;
  data_pipe_tmp0(c_IDX0_H downto c_IDX0_L) <= pixel_id_ra;
  inst_pipeliner_sync_with_mult_add_ufixed_out1 : entity work.pipeliner
    generic map(
      g_NB_PIPES   => pkg_MULT_ADD_UFIXED_LATENCY + 1,
      g_DATA_WIDTH => data_pipe_tmp0'length
      )
    port map(
      i_clk  => i_clk,
      i_data => data_pipe_tmp0,
      o_data => data_pipe_tmp1
      );

  pixel_sof_rc <= data_pipe_tmp1(c_IDX2_H);
  pixel_eof_rc <= data_pipe_tmp1(c_IDX1_H);
  pixel_id_rc  <= data_pipe_tmp1(c_IDX0_H downto c_IDX0_L);

  ---------------------------------------------------------------------
  -- RAM: tes_pulse_shape
  ---------------------------------------------------------------------
  pulse_shape_ena    <= i_pulse_shape_wr_en or i_pulse_shape_rd_en;
  pulse_shape_wea    <= i_pulse_shape_wr_en;
  pulse_shape_addra  <= i_pulse_shape_wr_rd_addr;
  pulse_shape_dina   <= i_pulse_shape_wr_data;
  pulse_shape_regcea <= '1';

  inst_tdpram_tes_pulse_shape : entity work.tdpram
    generic map(
      -- port A
      g_ADDR_WIDTH_A       => pulse_shape_addra'length,
      g_BYTE_WRITE_WIDTH_A => pulse_shape_dina'length,
      g_WRITE_DATA_WIDTH_A => pulse_shape_dina'length,
      g_WRITE_MODE_A       => "no_change",
      g_READ_DATA_WIDTH_A  => pulse_shape_dina'length,
      g_READ_LATENCY_A     => pkg_TES_PULSE_SHAPE_RAM_A_RD_LATENCY,
      -- port B
      g_ADDR_WIDTH_B       => pulse_shape_addra'length,
      g_BYTE_WRITE_WIDTH_B => pulse_shape_dina'length,
      g_WRITE_DATA_WIDTH_B => pulse_shape_dina'length,
      g_WRITE_MODE_B       => "no_change",
      g_READ_DATA_WIDTH_B  => pulse_shape_dina'length,
      g_READ_LATENCY_B     => pkg_TES_PULSE_SHAPE_RAM_B_RD_LATENCY,
      -- others
      g_CLOCKING_MODE      => "common_clock",
      g_MEMORY_PRIMITIVE   => "block",
      g_MEMORY_SIZE        => c_MEMORY_SIZE_PULSE_SHAPE,
      g_MEMORY_INIT_FILE   => g_TES_PULSE_SHAPE_RAM_MEMORY_INIT_FILE,
      g_MEMORY_INIT_PARAM  => ""
      )
    port map(
      ---------------------------------------------------------------------
      -- port A
      ---------------------------------------------------------------------
      i_rsta   => '0',
      i_clka   => i_clk,
      i_ena    => pulse_shape_ena,
      i_wea(0) => pulse_shape_wea,
      i_addra  => pulse_shape_addra,
      i_dina   => pulse_shape_dina,
      i_regcea => pulse_shape_regcea,
      o_douta  => pulse_shape_douta,
      ---------------------------------------------------------------------
      -- port B
      ---------------------------------------------------------------------
      i_rstb   => '0',
      i_clkb   => i_clk,
      i_web(0) => pulse_shape_web,
      i_enb    => pulse_shape_enb,
      i_addrb  => pulse_shape_addrb,
      i_dinb   => pulse_shape_dinb,
      i_regceb => pulse_shape_regceb,
      o_doutb  => pulse_shape_doutb
      );
  pulse_shape_web    <= '0';
  pulse_shape_dinb   <= (others => '0');
  pulse_shape_enb    <= pixel_valid_rc;
  pulse_shape_addrb  <= addr_pulse_shape_rc;
  pulse_shape_regceb <= '1';

  -------------------------------------------------------------------
  -- sync with rd ram out
  -------------------------------------------------------------------
  inst_pipeliner_sync_with_tdpram_tes_pulse_shape_outa : entity work.pipeliner
    generic map(
      g_NB_PIPES   => pkg_TES_PULSE_SHAPE_RAM_A_RD_LATENCY,
      g_DATA_WIDTH => 1
      )
    port map(
      i_clk     => i_clk,
      i_data(0) => i_pulse_shape_rd_en,
      o_data(0) => pulse_shape_rd_en_rz
      );
  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_pulse_shape_rd_valid <= pulse_shape_rd_en_rz;
  o_pulse_shape_rd_data  <= pulse_shape_douta;

  ---------------------------------------------------------------------
  -- RAM check
  ---------------------------------------------------------------------
  inst_ram_check_sdpram_tes_pulse_shape : entity work.ram_check
    generic map(
      g_WR_ADDR_WIDTH => pulse_shape_addra'length,
      g_RD_ADDR_WIDTH => pulse_shape_addrb'length
      )
    port map(
      i_clk         => i_clk,
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_wr          => pulse_shape_wea,
      i_wr_addr     => pulse_shape_addra,
      i_rd          => pulse_shape_enb,
      i_rd_addr     => pulse_shape_addrb,
      ---------------------------------------------------------------------
      -- Errors
      ---------------------------------------------------------------------
      o_error_pulse => pulse_shape_error
      );

  ---------------------------------------------------------------------
  -- RAM: tes_std_state
  ---------------------------------------------------------------------
  steady_state_ena    <= i_steady_state_wr_en or i_steady_state_rd_en;
  steady_state_wea    <= i_steady_state_wr_en;
  steady_state_addra  <= i_steady_state_wr_rd_addr;
  steady_state_dina   <= i_steady_state_wr_data;
  steady_state_regcea <= '1';

  inst_tdpram_tes_steady_state : entity work.tdpram
    generic map(
      -- port A
      g_ADDR_WIDTH_A       => steady_state_addra'length,
      g_BYTE_WRITE_WIDTH_A => steady_state_dina'length,
      g_WRITE_DATA_WIDTH_A => steady_state_dina'length,
      g_WRITE_MODE_A       => "no_change",
      g_READ_DATA_WIDTH_A  => steady_state_dina'length,
      g_READ_LATENCY_A     => pkg_TES_STD_STATE_RAM_A_RD_LATENCY,
      -- port B
      g_ADDR_WIDTH_B       => steady_state_addra'length,
      g_BYTE_WRITE_WIDTH_B => steady_state_dina'length,
      g_WRITE_DATA_WIDTH_B => steady_state_dina'length,
      g_WRITE_MODE_B       => "no_change",
      g_READ_DATA_WIDTH_B  => steady_state_dina'length,
      g_READ_LATENCY_B     => pkg_TES_STD_STATE_RAM_B_RD_LATENCY,
      -- others
      g_CLOCKING_MODE      => "common_clock",
      g_MEMORY_PRIMITIVE   => "block",
      g_MEMORY_SIZE        => c_MEMORY_SIZE_STEADY_STATE,
      g_MEMORY_INIT_FILE   => g_TES_STD_STATE_RAM_MEMORY_INIT_FILE,
      g_MEMORY_INIT_PARAM  => ""
      )
    port map(
      ---------------------------------------------------------------------
      -- port A
      ---------------------------------------------------------------------
      i_rsta   => '0',
      i_clka   => i_clk,
      i_ena    => steady_state_ena,
      i_wea(0) => steady_state_wea,
      i_addra  => steady_state_addra,
      i_dina   => steady_state_dina,
      i_regcea => steady_state_regcea,
      o_douta  => steady_state_douta,
      ---------------------------------------------------------------------
      -- port B
      ---------------------------------------------------------------------
      i_rstb   => '0',
      i_clkb   => i_clk,
      i_web(0) => steady_state_web,
      i_enb    => steady_state_enb,
      i_addrb  => steady_state_addrb,
      i_dinb   => steady_state_dinb,
      i_regceb => steady_state_regceb,
      o_doutb  => steady_state_doutb
      );
  steady_state_web    <= '0';
  steady_state_dinb   <= (others => '0');
  steady_state_enb    <= pixel_valid_rc;
  steady_state_addrb  <= pixel_id_rc;
  steady_state_regceb <= '1';

  -------------------------------------------------------------------
  -- sync with rd RAM output
  -------------------------------------------------------------------
  inst_pipeliner_sync_with_tdpram_tes_steady_state_outa : entity work.pipeliner
    generic map(
      g_NB_PIPES   => pkg_TES_STD_STATE_RAM_A_RD_LATENCY,
      g_DATA_WIDTH => 1
      )
    port map(
      i_clk     => i_clk,
      i_data(0) => i_steady_state_rd_en,
      o_data(0) => steady_state_rd_en_rz
      );
  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_steady_state_rd_valid <= steady_state_rd_en_rz;
  o_steady_state_rd_data  <= steady_state_douta;

  ---------------------------------------------------------------------
  -- RAM check
  ---------------------------------------------------------------------
  inst_ram_check_sdpram_tes_steady_state : entity work.ram_check
    generic map(
      g_WR_ADDR_WIDTH => steady_state_addra'length,
      g_RD_ADDR_WIDTH => steady_state_addrb'length
      )
    port map(
      i_clk         => i_clk,
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_wr          => steady_state_wea,
      i_wr_addr     => steady_state_addra,
      i_rd          => steady_state_enb,
      i_rd_addr     => steady_state_addrb,
      ---------------------------------------------------------------------
      -- Errors
      ---------------------------------------------------------------------
      o_error_pulse => steady_state_error
      );

  -------------------------------------------------------------------
  -- sync with RAM output
  --------------------------------------------------------------------
  assert not (pkg_TES_STD_STATE_RAM_B_RD_LATENCY /= pkg_TES_PULSE_SHAPE_RAM_B_RD_LATENCY) report "[tes_pulse_shape_manager]: c_TES_STD_STATE_RD_RAM_LATENCY and c_TES_PULSE_SHAPE_RD_RAM_LATENCY must be equal. Otherwise, the user needs to update this design to equalize the output data path from each memory" severity error;

  data_pipe_tmp2(c_IDX6_H downto c_IDX6_L) <= pulse_heigth_rc;
  data_pipe_tmp2(c_IDX5_H)                 <= pulse_sof_rc;
  data_pipe_tmp2(c_IDX4_H)                 <= pulse_eof_rc;
  data_pipe_tmp2(c_IDX3_H)                 <= pixel_valid_rc;
  data_pipe_tmp2(c_IDX2_H)                 <= pixel_sof_rc;
  data_pipe_tmp2(c_IDX1_H)                 <= pixel_eof_rc;
  data_pipe_tmp2(c_IDX0_H downto c_IDX0_L) <= pixel_id_rc;
  inst_pipeliner_sync_with_rams_out : entity work.pipeliner
    generic map(
      g_NB_PIPES   => pkg_TES_PULSE_SHAPE_RAM_B_RD_LATENCY,
      g_DATA_WIDTH => data_pipe_tmp2'length
      )
    port map(
      i_clk  => i_clk,
      i_data => data_pipe_tmp2,
      o_data => data_pipe_tmp3
      );

  pulse_heigth_rx <= data_pipe_tmp3(c_IDX6_H downto c_IDX6_L);
  pulse_sof_rx    <= data_pipe_tmp3(c_IDX5_H);
  pulse_eof_rx    <= data_pipe_tmp3(c_IDX4_H);
  pixel_valid_rx  <= data_pipe_tmp3(c_IDX3_H);
  pixel_sof_rx    <= data_pipe_tmp3(c_IDX2_H);
  pixel_eof_rx    <= data_pipe_tmp3(c_IDX1_H);
  pixel_id_rx     <= data_pipe_tmp3(c_IDX0_H downto c_IDX0_L);

  ---------------------------------------------------------------------
  -- TES computation
  -- requirement: FPASIM-FW-REQ-0120
  ---------------------------------------------------------------------
  assert not ((pulse_shape_doutb'length) /= (pulse_shape_tmp'length - 1)) report "[tes_pulse_shape_manager]: pulse shape => register/command width and sfixed package definition width doesn't match." severity error;
  assert not ((pulse_heigth_rx'length) /= (pulse_heigth_tmp'length - 1)) report "[tes_pulse_shape_manager]: pulse heigth => register/command width and sfixed package definition width doesn't match." severity error;
  assert not ((steady_state_doutb'length) /= (steady_state_tmp'length - 1)) report "[tes_pulse_shape_manager]: steady state => register/command width and sfixed package definition width doesn't match." severity error;
  -- unsigned to signed conversion: sign bit extension (add a sign bit)
  pulse_shape_tmp  <= std_logic_vector(resize(unsigned(pulse_shape_doutb), pulse_shape_tmp'length));
  pulse_heigth_tmp <= std_logic_vector(resize(unsigned(pulse_heigth_rx), pulse_heigth_tmp'length));
  steady_state_tmp <= std_logic_vector(resize(unsigned(steady_state_doutb), steady_state_tmp'length));

  inst_mult_sub_sfixed : entity work.mult_sub_sfixed
    generic map(
      -- port A: AMD Q notation (fixed point)
      g_Q_M_A  => pkg_TES_MULT_SUB_Q_M_A,
      g_Q_N_A  => pkg_TES_MULT_SUB_Q_N_A,
      -- port B: AMD Q notation (fixed point)
      g_Q_M_B  => pkg_TES_MULT_SUB_Q_M_B,
      g_Q_N_B  => pkg_TES_MULT_SUB_Q_N_B,
      -- port C: AMC Q notation (fixed point)
      g_Q_M_C  => pkg_TES_MULT_SUB_Q_M_C,
      g_Q_N_C  => pkg_TES_MULT_SUB_Q_N_C,
      -- port S: AMD Q notation (fixed point)
      g_Q_M_S  => pkg_TES_MULT_SUB_Q_M_S,
      g_Q_N_S  => pkg_TES_MULT_SUB_Q_N_S
      )
    port map(
      i_clk => i_clk,
      --------------------------------------------------------------
      -- input
      --------------------------------------------------------------
      i_a   => pulse_shape_tmp,
      i_b   => pulse_heigth_tmp,
      i_c   => steady_state_tmp,
      --------------------------------------------------------------
      -- output : S = C - A*B
      --------------------------------------------------------------
      o_s   => result_ry
      );

  assert not ((result_ry'length) /= (pkg_TES_MULT_SUB_Q_WIDTH_S)) report "[tes_pulse_shape_manager]: result => output result width and sfixed package definition width doesn't match." severity error;

  -------------------------------------------------------------------
  -- sync with RAM output
  --------------------------------------------------------------------
  data_pipe_tmp4(c_IDX5_H)                 <= pulse_sof_rx;
  data_pipe_tmp4(c_IDX4_H)                 <= pulse_eof_rx;
  data_pipe_tmp4(c_IDX3_H)                 <= pixel_valid_rx;
  data_pipe_tmp4(c_IDX2_H)                 <= pixel_sof_rx;
  data_pipe_tmp4(c_IDX1_H)                 <= pixel_eof_rx;
  data_pipe_tmp4(c_IDX0_H downto c_IDX0_L) <= pixel_id_rx;
  inst_pipeliner_sync_with_mult_sub_sfixed_out : entity work.pipeliner
    generic map(
      g_NB_PIPES   => pkg_TES_PULSE_MANAGER_COMPUTATION_LATENCY,
      g_DATA_WIDTH => data_pipe_tmp4'length
      )
    port map(
      i_clk  => i_clk,
      i_data => data_pipe_tmp4,
      o_data => data_pipe_tmp5
      );

  pulse_sof_ry   <= data_pipe_tmp5(c_IDX5_H);
  pulse_eof_ry   <= data_pipe_tmp5(c_IDX4_H);
  pixel_valid_ry <= data_pipe_tmp5(c_IDX3_H);
  pixel_sof_ry   <= data_pipe_tmp5(c_IDX2_H);
  pixel_eof_ry   <= data_pipe_tmp5(c_IDX1_H);
  pixel_id_ry    <= data_pipe_tmp5(c_IDX0_H downto c_IDX0_L);


  -------------------------------------------------------------------
  -- force output value to when the true value is negative (<=> max function)
  -- requirement: FPASIM-FW-REQ-0120
  --------------------------------------------------------------------
  sign_value_tmp6 <= result_ry(result_ry'high);
  p_force_output_value_when_negative : process (i_clk) is
  begin
    if rising_edge(i_clk) then
      if sign_value_tmp6 = '1' then
        -- input value negative => force output to 0
        result_rz <= (others => '0');
      else
        result_rz <= result_ry;
      end if;
    end if;
  end process p_force_output_value_when_negative;

  ---------------------------------------------------------------------
  -- sync with
  ---------------------------------------------------------------------
  data_pipe_tmp6(c_IDX5_H)                 <= pulse_sof_ry;
  data_pipe_tmp6(c_IDX4_H)                 <= pulse_eof_ry;
  data_pipe_tmp6(c_IDX3_H)                 <= pixel_valid_ry;
  data_pipe_tmp6(c_IDX2_H)                 <= pixel_sof_ry;
  data_pipe_tmp6(c_IDX1_H)                 <= pixel_eof_ry;
  data_pipe_tmp6(c_IDX0_H downto c_IDX0_L) <= pixel_id_ry;
  inst_pipeliner_sync_with_select_output : entity work.pipeliner
    generic map(
      g_NB_PIPES   => pkg_TES_FORCE_OUTPUT_LATENCY,
      g_DATA_WIDTH => data_pipe_tmp6'length
      )
    port map(
      i_clk  => i_clk,
      i_data => data_pipe_tmp6,
      o_data => data_pipe_tmp7
      );

  pulse_sof_rz   <= data_pipe_tmp7(c_IDX5_H);
  pulse_eof_rz   <= data_pipe_tmp7(c_IDX4_H);
  pixel_valid_rz <= data_pipe_tmp7(c_IDX3_H);
  pixel_sof_rz   <= data_pipe_tmp7(c_IDX2_H);
  pixel_eof_rz   <= data_pipe_tmp7(c_IDX1_H);
  pixel_id_rz    <= data_pipe_tmp7(c_IDX0_H downto c_IDX0_L);

  -------------------------------------------------------------------
  -- output
  -------------------------------------------------------------------
  o_pulse_sof    <= pulse_sof_rz;
  o_pulse_eof    <= pulse_eof_rz;
  o_pixel_sof    <= pixel_sof_rz;
  o_pixel_eof    <= pixel_eof_rz;
  o_pixel_valid  <= pixel_valid_rz;
  o_pixel_id     <= pixel_id_rz;
  o_pixel_result <= result_rz;

  ---------------------------------------------------------------------
  -- detect output negative value
  ---------------------------------------------------------------------
  sign_value <= sign_value_tmp6;
  inst_tes_negative_output_detection : entity work.tes_negative_output_detection
    generic map(
      -- command
      g_PIXEL_ID_WIDTH => pixel_id_ry'length  -- pixel id bus width (expressed in bits). Possible values : [1; max integer value[
      )
    port map(
      i_clk                    => i_clk,      -- clock
      i_rst                    => i_rst,      -- reset
      i_rst_status             => i_rst_status,     -- reset error flag(s)
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_pixel_valid            => pixel_valid_ry,   -- pixel valid
      i_pixel_result_sign      => sign_value,  -- sign of the pixel result
      i_pixel_id               => pixel_id_ry,      -- pixel id
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_pixel_neg_out_valid    => pixel_neg_out_valid,  -- valid negative output
      o_pixel_neg_out_error    => pixel_neg_out_error,  -- negative output detection
      o_pixel_neg_out_pixel_id => pixel_neg_out_pixel_id  -- pixel id when a negative output is detected
      );

  o_tes_pixel_neg_out_valid    <= pixel_neg_out_valid;
  o_tes_pixel_neg_out_error    <= pixel_neg_out_error;
  o_tes_pixel_neg_out_pixel_id <= pixel_neg_out_pixel_id;

  ---------------------------------------------------------------------
  -- Error latching
  ---------------------------------------------------------------------
  error_tmp(4) <= steady_state_error;
  error_tmp(3) <= pulse_shape_error;
  error_tmp(2) <= errors_sync(2) or errors_sync(3);  -- fifo rst error
  error_tmp(1) <= errors_sync(1);                    -- fifo rd empty error
  error_tmp(0) <= errors_sync(0);                    -- fifo wr full error
  gen_errors_latch : for i in error_tmp'range generate
    inst_one_error_latch : entity work.one_error_latch
      port map(
        i_clk         => i_clk,
        i_rst         => i_rst_status,
        i_debug_pulse => i_debug_pulse,
        i_error       => error_tmp(i),
        o_error       => error_tmp_bis(i)
        );
  end generate gen_errors_latch;

  o_errors(15 downto 6) <= (others => '0');
  o_errors(5)           <= error_tmp_bis(4);  -- steady state error
  o_errors(4)           <= error_tmp_bis(3);  -- pulse shape error
  o_errors(3)           <= '0';
  o_errors(2)           <= error_tmp_bis(2);  -- fifo rst error
  o_errors(1)           <= error_tmp_bis(1);  -- fifo rd empty error
  o_errors(0)           <= error_tmp_bis(0);  -- fifo wr full error

  o_status(7 downto 1) <= (others => '0');
  o_status(0)          <= empty_sync;   -- fifo empty

  ---------------------------------------------------------------------
  -- for simulation only
  ---------------------------------------------------------------------
  assert not (error_tmp_bis(4) = '1') report "[tes_pulse_shape_manager] => RAM wrong access: steady state " severity error;
  assert not (error_tmp_bis(3) = '1') report "[tes_pulse_shape_manager] => RAM wrong access: pulse shape" severity error;

  assert not (error_tmp_bis(2) = '1') report "[tes_pulse_shape_manager] => fifo is used before the end of the initialization " severity error;
  assert not (error_tmp_bis(1) = '1') report "[tes_pulse_shape_manager] => fifo read an empty FIFO" severity error;
  assert not (error_tmp_bis(0) = '1') report "[tes_pulse_shape_manager] => fifo write a full FIFO" severity error;

end architecture RTL;
