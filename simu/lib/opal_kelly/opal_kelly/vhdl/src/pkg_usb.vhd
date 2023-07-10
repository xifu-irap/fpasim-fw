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
--    @file                   pkg_usb.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details             
--    This package defines a procedure specific to the project. 
--    This procedure is designed to work in VHDL simulation with a "opal kelly"-like library 
--    This procedure processes in input command csv file (with ";" as separator) with the following structure: 
--      . column0: reg_id : integer. (the list of possible reg_id can be found in the 0136-FPAsim-D_commands_dictionnary.xlsx file)
--           . It identifies a register in a unique manner.
--           . It allows to select the "opal kelly" procedures (wire_in, trig_in, wire_out, ...) corresponding to the processed register
--      . column1: opal_kelly_addr : hexadecimal value (without 0x)
--           . It selects the register
--      . column2 : data: hexadecimal value (without 0x) 
--           . data to write. When the reg_id select writting opal kelly functions/procedures
--           . data to compare. When the reg_id selects reading opal kelly functions/procedures
--      . column3: comment to understand the file command list
--    USE: 
--       0. import this package in the vhdl testbench
--       1. In the declarative part of the vhdl testbench architecture, declare:
--          1. one signal of t_internal_wr_if type
--          2. one signal of t_internal_rd_if type
--          3. one share variable of t_front_panel_conf type
--          Example:
--           . signal usb_wr_if0 : opal_kelly_lib.pkg_front_panel.t_internal_wr_if := (
--               hi_drive   => '0',
--               hi_cmd     => (others => '0'),
--               hi_dataout => (others => '0')
--               );
--           . signal usb_rd_if0 : opal_kelly_lib.pkg_front_panel.t_internal_rd_if := (
--             i_clk     => '0',
--             hi_busy   => '0',
--             hi_datain => (others => '0')
--           );
--          . shared variable v_front_panel_conf : opal_kelly_lib.pkg_front_panel.t_front_panel_conf; 
--      2. In the vhdl testbench architecture body:
--          1. Instanciate the okHost_driver procedure outside a process
--          2. Instanciate the pkg_usb_wr procedure outside a process
--
--   Note: 
--    . this procedure output read data on its output port
--    . 1 virtual function (Nop) was added to add latency between commands when reg_id = -1
--    . read data are compared against file data with a vunit checker_t object
--
--    Dependencies: 
--      . csv_lib.pkg_csv_file
--      . common_lib.pkg_common
--      . context vunit_lib.vunit_context
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library csv_lib;
use csv_lib.pkg_csv_file.all;

library vunit_lib;
context vunit_lib.vunit_context;

library common_lib;
use common_lib.pkg_common.all;

use work.pkg_front_panel.all;

package pkg_usb is

  ---------------------------------------------------------------------
  -- pkg_usb_wr
  ---------------------------------------------------------------------
  procedure pkg_usb_wr(
    signal i_clk                       : in    std_logic;
    signal i_start_wr                  : in    std_logic;
    ---------------------------------------------------------------------
    -- input file
    ---------------------------------------------------------------------
    i_filepath_wr                      : in    string;
    i_csv_separator                    : in    character;
    --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
    --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
    --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
    --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
    --  data type = "STD_VEC" => no data convertion before writing in the output file
    constant i_USB_WR_ADDR_TYP         : in    string := "HEX";
    constant i_USB_WR_DATA_TYP         : in    string := "HEX";
    ---------------------------------------------------------------------
    -- command
    ---------------------------------------------------------------------
    signal i_wr_ready                  : in    std_logic;
    ---------------------------------------------------------------------
    -- usb
    ---------------------------------------------------------------------
    variable b_front_panel_conf        : inout t_front_panel_conf;
    signal o_internal_wr_if            : out   t_internal_wr_if;
    signal i_internal_rd_if            : in    t_internal_rd_if;
    ---------------------------------------------------------------------
    -- Vunit Scoreboard objects
    ---------------------------------------------------------------------
    constant i_sb_reg_data             : in    checker_t;
    constant i_sb_ram_tes_pulse_shape  : in    checker_t;
    constant i_sb_ram_amp_squid_tf     : in    checker_t;
    constant i_sb_ram_mux_squid_tf     : in    checker_t;
    constant i_sb_ram_tes_steady_state : in    checker_t;
    constant i_sb_ram_mux_offset       : in    checker_t;
    ---------------------------------------------------------------------
    -- data
    ---------------------------------------------------------------------
    signal o_reg_id                    : out   integer;
    signal o_data_valid                : out   std_logic;
    signal o_data                      : out   std_logic_vector(31 downto 0);
    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal o_wr_finish                 : out   std_logic;
    signal o_error                     : out   std_logic_vector(0 downto 0)
    );

end package pkg_usb;

package body pkg_usb is

  ---------------------------------------------------------------------
  -- pkg_usb_wr
  ---------------------------------------------------------------------
  procedure pkg_usb_wr(
    signal i_clk                       : in    std_logic;
    signal i_start_wr                  : in    std_logic;
    ---------------------------------------------------------------------
    -- input file
    ---------------------------------------------------------------------
    i_filepath_wr                      : in    string;
    i_csv_separator                    : in    character;
    --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
    --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
    --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
    --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
    --  data type = "STD_VEC" => no data convertion before writing in the output file
    constant i_USB_WR_ADDR_TYP         : in    string := "HEX";
    constant i_USB_WR_DATA_TYP         : in    string := "HEX";
    ---------------------------------------------------------------------
    -- command
    ---------------------------------------------------------------------
    signal i_wr_ready                  : in    std_logic;
    ---------------------------------------------------------------------
    -- usb
    ---------------------------------------------------------------------
    variable b_front_panel_conf        : inout t_front_panel_conf;
    signal o_internal_wr_if            : out   t_internal_wr_if;
    signal i_internal_rd_if            : in    t_internal_rd_if;
    ---------------------------------------------------------------------
    -- Vunit Scoreboard objects
    ---------------------------------------------------------------------
    constant i_sb_reg_data             : in    checker_t;
    constant i_sb_ram_tes_pulse_shape  : in    checker_t;
    constant i_sb_ram_amp_squid_tf     : in    checker_t;
    constant i_sb_ram_mux_squid_tf     : in    checker_t;
    constant i_sb_ram_tes_steady_state : in    checker_t;
    constant i_sb_ram_mux_offset       : in    checker_t;
    ---------------------------------------------------------------------
    -- data
    ---------------------------------------------------------------------
    signal o_reg_id                    : out   integer;
    signal o_data_valid                : out   std_logic;
    signal o_data                      : out   std_logic_vector(31 downto 0);
    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal o_wr_finish                 : out   std_logic;
    signal o_error                     : out   std_logic_vector(0 downto 0)
    ) is
    variable v_csv_file : t_csv_file_reader;

    type t_state is (E_RST, E_WAIT_WR, E_RUN, E_PIPE_OUT_DATA_COMPARE, E_DELAY, E_END);
    variable v_fsm_state : t_state := E_RST;
    constant c_TEST      : boolean := true;

    ---------------------------------------------------------------------
    -- file data
    ---------------------------------------------------------------------
    variable v_file_reg_id          : integer                                            := 0;  -- reg_id value from file
    variable v_file_opal_kelly_addr : std_logic_vector(7 downto 0)                       := (others => '0');  -- address value from file
    variable v_file_data            : std_logic_vector(i_internal_rd_if.hi_datain'range) := (others => '0');  -- data value from file

    ---------------------------------------------------------------------
    -- generate v_first pulse on reg_id change
    ---------------------------------------------------------------------
    variable v_file_reg_id_last : integer := 0;  -- last reg_id value
    variable v_first_reg_id     : integer := 0;  -- 1: detect a difference of reg_id between the current one and the last one, 0: no difference

    ---------------------------------------------------------------------
    -- variable associated to the pipe command
    ---------------------------------------------------------------------
    variable v_pipe_length_byte : integer := 0;  -- number of bytes to write in the pipe (must be a multiple of 16 bytes: usb3 opal kelly limitation)

    constant c_PIPE_RD_WORD_MAX  : integer := 4;  -- pipe buffer size in reading (expressed in 32 bit-words)
    variable v_pipe_rd_cnt_word  : integer := 0;  -- count the number of 32 bits-word to read
    variable v_pipe_rd_cnt_index : integer := 0;  -- count the number total of read 32 bit-words
    variable v_pipe_rd_trig      : integer := 0;  -- 1: the pipe need to be read, 0: otherwise

    type t_pipe_array is array (0 to c_PIPE_RD_WORD_MAX - 1) of std_logic_vector(i_internal_rd_if.hi_datain'range);  -- should be an array of 32 bit vectors
    variable v_pipe_rd_data_file : t_pipe_array := (others => (others => '0'));  -- array of 32 bit-words read from the file
    variable v_pipe_rd_data      : t_pipe_array := (others => (others => '0'));  -- array of 32 bit-words read from the usb

    constant c_PIPE_WR_WORD_CNT_MAX : integer := 4;  -- pipe buffer size in writting (expressed in 32 bit-words)
    variable v_pipe_wr_word_cnt     : integer := 0;  -- count the number of 32 bit-words to write in pipe_in

    ---------------------------------------------------------------------
    -- variables associated to the nop command
    ---------------------------------------------------------------------
    variable v_nop_delay         : integer := 0;  -- delay value
    variable v_nop_delay_cnt_max : integer := 0;  -- maximum clock cycle
    variable v_nop_delay_cnt     : integer := 0;  -- count the number of clock cycle
    variable v_nop_delay_trig    : integer := 0;  -- 1: add delay, 0: do nothing

    ---------------------------------------------------------------------
    -- variables associated to the wire
    ---------------------------------------------------------------------
    constant c_WIRE_NO_MASK : std_logic_vector(i_internal_rd_if.hi_datain'range) := x"ffff_ffff";  -- wire mask value

    variable v_wire_cnt      : integer := 0;  -- count the max number of wire_out
    variable v_wire_data_out : std_logic_vector(i_internal_rd_if.hi_datain'range);  -- read wire data from usb
    variable v_wire_data1    : integer;  -- read wire from file (converted into integer)
    variable v_wire_data2    : integer;  -- read wire from usb (converted into integer)

    ---------------------------------------------------------------------
    -- output variable associated to the output signals
    ---------------------------------------------------------------------
    variable v_valid_out : std_logic                                          := '0';  -- data valid to output
    variable v_data_out  : std_logic_vector(i_internal_rd_if.hi_datain'range) := (others => '0');  -- data to output
    variable v_error     : std_logic_vector(o_error'range)                    := (others => '0');  -- error to output
    variable v_wr_finish : std_logic                                          := '0';  -- '1': the file is read, '0': otherwise

  begin

    while c_TEST = true loop  
      v_valid_out := '0';
      case v_fsm_state is

        when E_RST =>

          v_wr_finish := '0';
          v_error     := (others => '0');
          FrontPanelReset(
            b_front_panel_conf => b_front_panel_conf,
            o_internal_wr_if   => o_internal_wr_if,
            i_internal_rd_if   => i_internal_rd_if
            );
          v_fsm_state := E_WAIT_WR;

        when E_WAIT_WR =>

          if i_start_wr = '1' then

            v_csv_file.initialize(i_filepath_wr, i_csv_separator => i_csv_separator);
            -- skip the header
            v_csv_file.readline(void);

            if v_csv_file.end_of_file(void) = true then  
              v_wr_finish := '1';
              v_csv_file.dispose(void);
              v_fsm_state := E_END;
            else
              v_wr_finish := '0';
              v_fsm_state := E_RUN;
            end if;
          else
            v_fsm_state := E_WAIT_WR;
          end if;

        when E_RUN =>

          if i_wr_ready = '1' then
            v_csv_file.readline(void);

            ---------------------------------------------------------------------
            -- get file data
            ---------------------------------------------------------------------
            v_file_reg_id          := v_csv_file.read_integer(VOID);
            v_file_opal_kelly_addr := v_csv_file.read_data_typ_as_std_vec(i_length => v_file_opal_kelly_addr'length, i_data_typ => i_USB_WR_ADDR_TYP);
            v_file_data            := v_csv_file.read_data_typ_as_std_vec(i_length => v_file_data'length, i_data_typ => i_USB_WR_DATA_TYP);

            ---------------------------------------------------------------------
            -- generate a v_first pulse on v_file_reg_id change
            ---------------------------------------------------------------------
            if v_file_reg_id /= v_file_reg_id_last then
              v_first_reg_id := 1;
            else
              v_first_reg_id := 0;
            end if;
            v_file_reg_id_last := v_file_reg_id;

            ---------------------------------------------------------------------
            -- parse reg_id value
            ---------------------------------------------------------------------
            case v_file_reg_id is
              when -1 =>
                ---------------------------------------------------------------------
                -- Nop: add delay
                ---------------------------------------------------------------------
                v_nop_delay         := to_integer(unsigned(v_file_data));
                v_nop_delay_cnt_max := v_nop_delay;
                v_nop_delay_cnt     := 1;

                ---------------------------------------------------------------------
                -- if v_nop_delay = 1 : no need to change state to add delay
                --                = 0 : need to change state to add delay
                ---------------------------------------------------------------------
                if v_nop_delay = 1 then
                  v_nop_delay_trig := 0;
                else
                  v_nop_delay_trig := 1;
                end if;

                if v_first_reg_id = 1 then
                  info("[pkg_usb_wr] : NOP: add delay = " & to_string(v_nop_delay));
                end if;

              when 0 | 1 | 2 | 3 | 4 =>
                ---------------------------------------------------------------------
                -- Pipe in
                ---------------------------------------------------------------------
                if v_first_reg_id = 1 then
                  if v_file_reg_id = 0 then
                    info("[pkg_usb_wr] : Set tes_pulse_shape ram");
                  end if;
                  if v_file_reg_id = 1 then
                    info("[pkg_usb_wr] : Set amp_squid_tf ram");
                  end if;
                  if v_file_reg_id = 2 then
                    info("[pkg_usb_wr] : Set mux_squid_tf ram");
                  end if;
                  if v_file_reg_id = 3 then
                    info("[pkg_usb_wr] : Set tes_steady_state ram ");
                  end if;
                  if v_file_reg_id = 4 then
                    info("[pkg_usb_wr] : Set mux_squid_offset ram");
                  end if;
                end if;

                -- Fill the byte array before using the procedure associated to pipe_in
                ---------------------------------------------------------------------
                b_front_panel_conf.set_pipeIn(i_index => v_pipe_wr_word_cnt * c_PIPE_WR_WORD_CNT_MAX, i_value => v_file_data(7 downto 0));
                b_front_panel_conf.set_pipeIn(i_index => v_pipe_wr_word_cnt * c_PIPE_WR_WORD_CNT_MAX + 1, i_value => v_file_data(15 downto 8));
                b_front_panel_conf.set_pipeIn(i_index => v_pipe_wr_word_cnt * c_PIPE_WR_WORD_CNT_MAX + 2, i_value => v_file_data(23 downto 16));
                b_front_panel_conf.set_pipeIn(i_index => v_pipe_wr_word_cnt * c_PIPE_WR_WORD_CNT_MAX + 3, i_value => v_file_data(31 downto 24));

                if v_pipe_wr_word_cnt = (c_PIPE_WR_WORD_CNT_MAX - 1) then

                  -- write in the pipe_in only if the number of array bytes to write
                  -- is a multiple of 16 bytes (usb3 opal kelly constraints)
                  ---------------------------------------------------------------------
                  v_pipe_length_byte := 4 * c_PIPE_WR_WORD_CNT_MAX;
                  WriteToPipeIn(
                    i_ep               => v_file_opal_kelly_addr,
                    i_length           => v_pipe_length_byte,  --write length expressed in bytes
                    b_front_panel_conf => b_front_panel_conf,
                    o_internal_wr_if   => o_internal_wr_if,
                    i_internal_rd_if   => i_internal_rd_if
                    );
                  v_pipe_wr_word_cnt := 0;
                else
                  v_pipe_wr_word_cnt := v_pipe_wr_word_cnt + 1;
                end if;

              when 100 =>
                ---------------------------------------------------------------------
                -- Trig in
                ---------------------------------------------------------------------
                if v_first_reg_id = 1 then
                  info("[pkg_usb_wr] : Set Trig: " & to_string(v_file_opal_kelly_addr));
                end if;
                ActivateTriggerIn_by_data(
                  i_ep             => v_file_opal_kelly_addr,
                  i_data           => v_file_data,
                  o_internal_wr_if => o_internal_wr_if,
                  i_internal_rd_if => i_internal_rd_if
                  );

              when 200 | 201 | 202 | 203 | 204 | 205 | 206 | 207 | 208 | 212 | 213 | 218 | 219 | 220 | 221 | 224 | 225 =>
                ---------------------------------------------------------------------
                -- wire in
                ---------------------------------------------------------------------
                if v_first_reg_id = 1 then
                  if v_file_reg_id = 200 then
                    info("[pkg_usb_wr] : Set CTRL Register: " & to_string(v_file_data));
                  end if;
                  if v_file_reg_id = 201 then
                    info("[pkg_usb_wr] : Set MAKE_PULSE Register: " & to_string(v_file_data));
                  end if;
                  if v_file_reg_id = 202 then
                    info("[pkg_usb_wr] : Set FPASIM_GAIN Register: " & to_string(v_file_data));
                  end if;
                  if v_file_reg_id = 203 then
                    info("[pkg_usb_wr] : Set MUX_SQ_FB_DELAY Register: " & to_string(v_file_data));
                  end if;
                  if v_file_reg_id = 204 then
                    info("[pkg_usb_wr] : Set AMP_SQ_OF_DELAY Register: " & to_string(v_file_data));
                  end if;
                  if v_file_reg_id = 205 then
                    info("[pkg_usb_wr] : Set ERROR_DELAY Register: " & to_string(v_file_data));
                  end if;
                  if v_file_reg_id = 206 then
                    info("[pkg_usb_wr] : Set RA_DELAY Register: " & to_string(v_file_data));
                  end if;
                  if v_file_reg_id = 207 then
                    info("[pkg_usb_wr] : Set TES_CONF Register: " & to_string(v_file_data));
                  end if;
                  if v_file_reg_id = 208 then
                    info("[pkg_usb_wr] : Set CONF0 Register: " & to_string(v_file_data));
                  end if;

                  if v_file_reg_id = 212 then
                    info("[pkg_usb_wr] : Set REC_CTRL Register: " & to_string(v_file_data));
                  end if;
                  if v_file_reg_id = 213 then
                    info("[pkg_usb_wr] : Set REC_CONF0 Register: " & to_string(v_file_data));
                  end if;

                  if v_file_reg_id = 218 then
                    info("[pkg_usb_wr] : Set SPI_CTRL Register: " & to_string(v_file_data));
                  end if;
                  if v_file_reg_id = 219 then
                    info("[pkg_usb_wr] : Set SPI_CONF0 Register: " & to_string(v_file_data));
                  end if;
                  if v_file_reg_id = 220 then
                    info("[pkg_usb_wr] : Set SPI_CONF1 Register: " & to_string(v_file_data));
                  end if;
                  if v_file_reg_id = 221 then
                    info("[pkg_usb_wr] : Set SPI_WR_DATA Register: " & to_string(v_file_data));
                  end if;

                  if v_file_reg_id = 224 then
                    info("[pkg_usb_wr] : Set DEBUG_CTRL Register: " & to_string(v_file_data));
                  end if;
                  if v_file_reg_id = 225 then
                    info("[pkg_usb_wr] : Set ERROR_SEL Register: " & to_string(v_file_data));
                  end if;
                end if;

                SetWireInValue(
                  i_ep               => v_file_opal_kelly_addr,
                  i_val              => v_file_data,
                  i_mask             => c_WIRE_NO_MASK,
                  b_front_panel_conf => b_front_panel_conf
                  );

                UpdateWireIns(
                  b_front_panel_conf => b_front_panel_conf,
                  o_internal_wr_if   => o_internal_wr_if,
                  i_internal_rd_if   => i_internal_rd_if);

              when 300 | 301 | 302 | 303 | 304 | 305 =>
                ---------------------------------------------------------------------
                -- pipe out
                ---------------------------------------------------------------------
                if v_first_reg_id = 1 then
                  v_pipe_rd_cnt_index := 1;
                  if v_file_reg_id = 300 then
                    info("[pkg_usb_wr] : Get tes_pulse_shape ram");
                  end if;
                  if v_file_reg_id = 301 then
                    info("[pkg_usb_wr] : Get amp_squid_tf ram");
                  end if;
                  if v_file_reg_id = 302 then
                    info("[pkg_usb_wr] : Get mux_squid_tf ram");
                  end if;
                  if v_file_reg_id = 303 then
                    info("[pkg_usb_wr] : Get tes_steady_state ram");
                  end if;
                  if v_file_reg_id = 304 then
                    info("[pkg_usb_wr] : Get mux_squid_offset ram");
                  end if;
                  if v_file_reg_id = 305 then
                    info("[pkg_usb_wr] : Get adc recording");
                  end if;
                end if;

                -- Save an array of words from file (must be a multiple of 16 bytes for the opal kelly usb3)
                -- This array will be later compared with the read data array from the usb
                ---------------------------------------------------------------------
                v_pipe_rd_data_file(v_pipe_rd_cnt_word) := v_file_data;
                if v_pipe_rd_cnt_word = (c_PIPE_RD_WORD_MAX - 1) then
                  v_pipe_rd_trig     := 1;
                  v_pipe_rd_cnt_word := 0;

                  -- BE CAREFUL! v_pipe_length_byte must be a multiple of 16 (bytes) for usb3
                  -- read the usb before comparing the data
                  v_pipe_length_byte := 4 * c_PIPE_RD_WORD_MAX;
                  ReadFromPipeOut(
                    i_ep               => v_file_opal_kelly_addr,
                    i_length           => v_pipe_length_byte,
                    b_front_panel_conf => b_front_panel_conf,
                    o_internal_wr_if   => o_internal_wr_if,
                    i_internal_rd_if   => i_internal_rd_if
                    );

                else
                  v_pipe_rd_trig     := 0;
                  v_pipe_rd_cnt_word := v_pipe_rd_cnt_word + 1;
                end if;

              when 500 | 501 | 502 | 503 | 504 | 505 | 506 | 507 | 508 | 510 | 511 | 512 | 513 | 517 | 518 | 519 | 520 | 521 | 522 | 523 | 524 | 525 | 526 | 527 | 529 | 530 | 531 =>
                ---------------------------------------------------------------------
                -- wire out
                ---------------------------------------------------------------------
                if v_first_reg_id = 1 then
                  if v_file_reg_id = 500 then
                    info("[pkg_usb_wr] : Get CTRL Register");
                  end if;
                  if v_file_reg_id = 501 then
                    info("[pkg_usb_wr] : Get MAKE_PULSE Register");
                  end if;
                  if v_file_reg_id = 502 then
                    info("[pkg_usb_wr] : Get FPASIM_GAIN Register");
                  end if;
                  if v_file_reg_id = 503 then
                    info("[pkg_usb_wr] : Get MUX_SQ_FB_DELAY Register");
                  end if;
                  if v_file_reg_id = 504 then
                    info("[pkg_usb_wr] : Get AMP_SQ_OF_DELAY Register");
                  end if;
                  if v_file_reg_id = 505 then
                    info("[pkg_usb_wr] : Get ERROR_DELAY Register");
                  end if;
                  if v_file_reg_id = 506 then
                    info("[pkg_usb_wr] : Get RA_DELAY Register");
                  end if;
                  if v_file_reg_id = 507 then
                    info("[pkg_usb_wr] : Get TES_CONF Register");
                  end if;
                  if v_file_reg_id = 508 then
                    info("[pkg_usb_wr] : Get CONF0 Register");
                  end if;
                  if v_file_reg_id = 510 then
                    info("[pkg_usb_wr] : Get FPASIM_STATUS Register");
                  end if;

                  if v_file_reg_id = 511 then
                    info("[pkg_usb_wr] : Get DATA_COUNT Register");
                  end if;

                  if v_file_reg_id = 512 then
                    info("[pkg_usb_wr] : Get REC_CTRL Register: ");
                  end if;
                  if v_file_reg_id = 513 then
                    info("[pkg_usb_wr] : Get REC_CONF0 Register: ");
                  end if;
                  if v_file_reg_id = 517 then
                    info("[pkg_usb_wr] : Get REC_DATA_COUNT Register");
                  end if;

                  if v_file_reg_id = 518 then
                    info("[pkg_usb_wr] : Get SPI_CTRL Register");
                  end if;
                  if v_file_reg_id = 519 then
                    info("[pkg_usb_wr] : Get SPI_CONF0 Register");
                  end if;
                  if v_file_reg_id = 520 then
                    info("[pkg_usb_wr] : Get SPI_CONF1 Register");
                  end if;
                  if v_file_reg_id = 521 then
                    info("[pkg_usb_wr] : Get SPI_WR_DATA Register");
                  end if;
                  if v_file_reg_id = 522 then
                    info("[pkg_usb_wr] : Get SPI_RD_DATA Register");
                  end if;
                  if v_file_reg_id = 523 then
                    info("[pkg_usb_wr] : Get SPI_STATUS Register");
                  end if;

                  if v_file_reg_id = 524 then
                    info("[pkg_usb_wr] : Get DEBUG_CTRL Register");
                  end if;
                  if v_file_reg_id = 525 then
                    info("[pkg_usb_wr] : Get ERROR_SEL Register");
                  end if;
                  if v_file_reg_id = 526 then
                    info("[pkg_usb_wr] : Get ERRORS Register");
                  end if;
                  if v_file_reg_id = 527 then
                    info("[pkg_usb_wr] : Get STATUS Register");
                  end if;

                  if v_file_reg_id = 529 then
                    info("[pkg_usb_wr] : Get BOARD_ID Register");
                  end if;
                  if v_file_reg_id = 530 then
                    info("[pkg_usb_wr] : Get FPGA_ID Register");
                  end if;
                  if v_file_reg_id = 531 then
                    info("[pkg_usb_wr] : Get FPGA_VERSION Register");
                  end if;
                end if;

                UpdateWireOuts(
                  b_front_panel_conf => b_front_panel_conf,
                  o_internal_wr_if   => o_internal_wr_if,
                  i_internal_rd_if   => i_internal_rd_if
                  );
                GetWireOutValue(
                  i_ep               => v_file_opal_kelly_addr,
                  b_front_panel_conf => b_front_panel_conf,
                  o_result           => v_wire_data_out
                  );

                v_wire_data1 := to_integer(unsigned(v_file_data));
                v_wire_data2 := to_integer(unsigned(v_wire_data_out));

                if v_file_reg_id = 500 then
                  check_equal(i_sb_reg_data, v_wire_data2, v_wire_data1, result("[pkg_usb_wr] : Get CTRL Register, index: " & to_string(v_wire_cnt) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_wire_data1) & ", (VHDL) : " & to_string(v_wire_data2)));
                end if;
                if v_file_reg_id = 501 then
                  check_equal(i_sb_reg_data, v_wire_data2, v_wire_data1, result("[pkg_usb_wr] : Get MAKE_PULSE Register, index: " & to_string(v_wire_cnt) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_wire_data1) & ", (VHDL) : " & to_string(v_wire_data2)));
                end if;
                if v_file_reg_id = 502 then
                  check_equal(i_sb_reg_data, v_wire_data2, v_wire_data1, result("[pkg_usb_wr] : Get FPASIM_GAIN Register, index: " & to_string(v_wire_cnt) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_wire_data1) & ", (VHDL) : " & to_string(v_wire_data2)));
                end if;
                if v_file_reg_id = 503 then
                  check_equal(i_sb_reg_data, v_wire_data2, v_wire_data1, result("[pkg_usb_wr] : Get MUX_SQ_FB_DELAY Register, index: " & to_string(v_wire_cnt) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_wire_data1) & ", (VHDL) : " & to_string(v_wire_data2)));
                end if;
                if v_file_reg_id = 504 then
                  check_equal(i_sb_reg_data, v_wire_data2, v_wire_data1, result("[pkg_usb_wr] : Get AMP_SQ_OF_DELAY Register, index: " & to_string(v_wire_cnt) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_wire_data1) & ", (VHDL) : " & to_string(v_wire_data2)));
                end if;
                if v_file_reg_id = 505 then
                  check_equal(i_sb_reg_data, v_wire_data2, v_wire_data1, result("[pkg_usb_wr] : Get ERROR_DELAY Register, index: " & to_string(v_wire_cnt) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_wire_data1) & ", (VHDL) : " & to_string(v_wire_data2)));
                end if;
                if v_file_reg_id = 506 then
                  check_equal(i_sb_reg_data, v_wire_data2, v_wire_data1, result("[pkg_usb_wr] : Get RA_DELAY Register, index: " & to_string(v_wire_cnt) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_wire_data1) & ", (VHDL) : " & to_string(v_wire_data2)));
                end if;
                if v_file_reg_id = 507 then
                  check_equal(i_sb_reg_data, v_wire_data2, v_wire_data1, result("[pkg_usb_wr] : Get TES_CONF Register, index: " & to_string(v_wire_cnt) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_wire_data1) & ", (VHDL) : " & to_string(v_wire_data2)));
                end if;
                if v_file_reg_id = 508 then
                  check_equal(i_sb_reg_data, v_wire_data2, v_wire_data1, result("[pkg_usb_wr] : Get CONF0 Register, index: " & to_string(v_wire_cnt) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_wire_data1) & ", (VHDL) : " & to_string(v_wire_data2)));
                end if;
                if v_file_reg_id = 510 then
                  check_equal(i_sb_reg_data, v_wire_data2, v_wire_data1, result("[pkg_usb_wr] : Get FPASIM_STATUS Register, index: " & to_string(v_wire_cnt) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_wire_data1) & ", (VHDL) : " & to_string(v_wire_data2)));
                end if;
                if v_file_reg_id = 511 then
                  check_equal(i_sb_reg_data, v_wire_data2, v_wire_data1, result("[pkg_usb_wr] : Get DATA_COUNT Register, index: " & to_string(v_wire_cnt) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_wire_data1) & ", (VHDL) : " & to_string(v_wire_data2)));
                end if;

                if v_file_reg_id = 512 then
                  check_equal(i_sb_reg_data, v_wire_data2, v_wire_data1, result("[pkg_usb_wr] : Get REC_CTRL Register, index: " & to_string(v_wire_cnt) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_wire_data1) & ", (VHDL) : " & to_string(v_wire_data2)));
                end if;
                if v_file_reg_id = 513 then
                  check_equal(i_sb_reg_data, v_wire_data2, v_wire_data1, result("[pkg_usb_wr] : Get REC_CONF0 Register, index: " & to_string(v_wire_cnt) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_wire_data1) & ", (VHDL) : " & to_string(v_wire_data2)));
                end if;
                if v_file_reg_id = 517 then
                  check_equal(i_sb_reg_data, v_wire_data2, v_wire_data1, result("[pkg_usb_wr] : Get REC_DATA_COUNT Register, index: " & to_string(v_wire_cnt) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_wire_data1) & ", (VHDL) : " & to_string(v_wire_data2)));
                end if;

                if v_file_reg_id = 518 then
                  check_equal(i_sb_reg_data, v_wire_data2, v_wire_data1, result("[pkg_usb_wr] : Get SPI_CTRL Register, index: " & to_string(v_wire_cnt) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_wire_data1) & ", (VHDL) : " & to_string(v_wire_data2)));
                end if;
                if v_file_reg_id = 519 then
                  check_equal(i_sb_reg_data, v_wire_data2, v_wire_data1, result("[pkg_usb_wr] : Get SPI_CONF0 Register, index: " & to_string(v_wire_cnt) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_wire_data1) & ", (VHDL) : " & to_string(v_wire_data2)));
                end if;
                if v_file_reg_id = 520 then
                  check_equal(i_sb_reg_data, v_wire_data2, v_wire_data1, result("[pkg_usb_wr] : Get SPI_CONF1 Register, index: " & to_string(v_wire_cnt) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_wire_data1) & ", (VHDL) : " & to_string(v_wire_data2)));
                end if;
                if v_file_reg_id = 521 then
                  check_equal(i_sb_reg_data, v_wire_data2, v_wire_data1, result("[pkg_usb_wr] : Get SPI_WR_DATA Register, index: " & to_string(v_wire_cnt) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_wire_data1) & ", (VHDL) : " & to_string(v_wire_data2)));
                end if;
                if v_file_reg_id = 522 then
                  check_equal(i_sb_reg_data, v_wire_data2, v_wire_data1, result("[pkg_usb_wr] : Get SPI_RD_DATA Register, index: " & to_string(v_wire_cnt) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_wire_data1) & ", (VHDL) : " & to_string(v_wire_data2)));
                end if;
                if v_file_reg_id = 523 then
                  check_equal(i_sb_reg_data, v_wire_data2, v_wire_data1, result("[pkg_usb_wr] : Get SPI_STATUS Register, index: " & to_string(v_wire_cnt) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_wire_data1) & ", (VHDL) : " & to_string(v_wire_data2)));
                end if;

                if v_file_reg_id = 524 then
                  check_equal(i_sb_reg_data, v_wire_data2, v_wire_data1, result("[pkg_usb_wr] : Get DEBUG_CTRL Register, index: " & to_string(v_wire_cnt) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_wire_data1) & ", (VHDL) : " & to_string(v_wire_data2)));
                end if;
                if v_file_reg_id = 525 then
                  check_equal(i_sb_reg_data, v_wire_data2, v_wire_data1, result("[pkg_usb_wr] : Get ERROR_SEL Register, index: " & to_string(v_wire_cnt) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_wire_data1) & ", (VHDL) : " & to_string(v_wire_data2)));
                end if;
                if v_file_reg_id = 526 then
                  check_equal(i_sb_reg_data, v_wire_data2, v_wire_data1, result("[pkg_usb_wr] : Get ERRORS Register, index: " & to_string(v_wire_cnt) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_wire_data1) & ", (VHDL) : " & to_string(v_wire_data2)));
                end if;
                if v_file_reg_id = 527 then
                  check_equal(i_sb_reg_data, v_wire_data2, v_wire_data1, result("[pkg_usb_wr] : Get STATUS Register, index: " & to_string(v_wire_cnt) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_wire_data1) & ", (VHDL) : " & to_string(v_wire_data2)));
                end if;

                if v_file_reg_id = 529 then
                  check_equal(i_sb_reg_data, v_wire_data2, v_wire_data1, result("[pkg_usb_wr] : Get BOARD_ID Register, index: " & to_string(v_wire_cnt) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_wire_data1) & ", (VHDL) : " & to_string(v_wire_data2)));
                end if;
                if v_file_reg_id = 530 then
                  check_equal(i_sb_reg_data, v_wire_data2, v_wire_data1, result("[pkg_usb_wr] : Get FPGA_ID Register, index: " & to_string(v_wire_cnt) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_wire_data1) & ", (VHDL) : " & to_string(v_wire_data2)));
                end if;
                if v_file_reg_id = 531 then
                  check_equal(i_sb_reg_data, v_wire_data2, v_wire_data1, result("[pkg_usb_wr] : Get FPGA_VERSION Register, index: " & to_string(v_wire_cnt) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_wire_data1) & ", (VHDL) : " & to_string(v_wire_data2)));
                end if;
                v_wire_cnt := v_wire_cnt + 1;

                ---------------------------------------------------------------------
                -- output signal
                ---------------------------------------------------------------------
                v_valid_out := '1';
                v_data_out  := v_wire_data_out;

              when 52 =>
                ---------------------------------------------------------------------
                -- trig out: TODO if necessary
                ---------------------------------------------------------------------
                v_error(0) := '1';
              when others =>
                v_error(0) := '1';
            end case;

            if v_error(0) = '1' then
              info("[pkg_usb_wr]: error: v_file_reg_id(" & to_string(v_file_reg_id) & ") is out of range");
            end if;
            if v_csv_file.end_of_file(void) = true then  
              v_wr_finish := '1';
              v_csv_file.dispose(void);
              v_fsm_state := E_END;
            else
              if v_nop_delay_trig = 1 then
                v_fsm_state := E_DELAY;
              elsif v_pipe_rd_trig = 1 then
                v_fsm_state := E_PIPE_OUT_DATA_COMPARE;
              else
                v_wr_finish := '0';
                v_fsm_state := E_RUN;
              end if;
            end if;

          else
            v_valid_out := '0';
            v_fsm_state := E_RUN;
          end if;

        when E_PIPE_OUT_DATA_COMPARE =>

          v_pipe_rd_data(v_pipe_rd_cnt_word)(7 downto 0)   := b_front_panel_conf.get_pipeOut(v_pipe_rd_cnt_word * 4);
          v_pipe_rd_data(v_pipe_rd_cnt_word)(15 downto 8)  := b_front_panel_conf.get_pipeOut(v_pipe_rd_cnt_word * 4 + 1);
          v_pipe_rd_data(v_pipe_rd_cnt_word)(23 downto 16) := b_front_panel_conf.get_pipeOut(v_pipe_rd_cnt_word * 4 + 2);
          v_pipe_rd_data(v_pipe_rd_cnt_word)(31 downto 24) := b_front_panel_conf.get_pipeOut(v_pipe_rd_cnt_word * 4 + 3);
          v_pipe_rd_trig                                   := 0;

          -- output signal
          ---------------------------------------------------------------------
          v_valid_out := '1';
          v_data_out  := v_pipe_rd_data(v_pipe_rd_cnt_word);

          if v_file_reg_id = 300 then
            check_equal(i_sb_ram_tes_pulse_shape, v_pipe_rd_data_file(v_pipe_rd_cnt_word), v_pipe_rd_data(v_pipe_rd_cnt_word), result("[pkg_usb_wr] : Get tes_pulse_shape , index: " & to_string(v_pipe_rd_cnt_index) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_pipe_rd_data_file(v_pipe_rd_cnt_word)) & ", (VHDL) : " & to_string(v_pipe_rd_data(v_pipe_rd_cnt_word))));
          end if;
          if v_file_reg_id = 301 then
            check_equal(i_sb_ram_amp_squid_tf, v_pipe_rd_data_file(v_pipe_rd_cnt_word), v_pipe_rd_data(v_pipe_rd_cnt_word), result("[pkg_usb_wr] : Get amp_squid_tf , index: " & to_string(v_pipe_rd_cnt_index) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_pipe_rd_data_file(v_pipe_rd_cnt_word)) & ", (VHDL) : " & to_string(v_pipe_rd_data(v_pipe_rd_cnt_word))));
          end if;
          if v_file_reg_id = 302 then
            check_equal(i_sb_ram_mux_squid_tf, v_pipe_rd_data_file(v_pipe_rd_cnt_word), v_pipe_rd_data(v_pipe_rd_cnt_word), result("[pkg_usb_wr] : Get mux_squid_tf , index: " & to_string(v_pipe_rd_cnt_index) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_pipe_rd_data_file(v_pipe_rd_cnt_word)) & ", (VHDL) : " & to_string(v_pipe_rd_data(v_pipe_rd_cnt_word))));
          end if;
          if v_file_reg_id = 303 then
            check_equal(i_sb_ram_tes_steady_state, v_pipe_rd_data_file(v_pipe_rd_cnt_word), v_pipe_rd_data(v_pipe_rd_cnt_word), result("[pkg_usb_wr] : Get tes_steady_state , index: " & to_string(v_pipe_rd_cnt_index) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_pipe_rd_data_file(v_pipe_rd_cnt_word)) & ", (VHDL) : " & to_string(v_pipe_rd_data(v_pipe_rd_cnt_word))));
          end if;
          if v_file_reg_id = 304 then
            check_equal(i_sb_ram_mux_offset, v_pipe_rd_data_file(v_pipe_rd_cnt_word), v_pipe_rd_data(v_pipe_rd_cnt_word), result("[pkg_usb_wr] : Get mux_squid_offset , index: " & to_string(v_pipe_rd_cnt_index) & ", v_file_reg_id: " & to_string(v_file_reg_id) & " (File) : " & to_string(v_pipe_rd_data_file(v_pipe_rd_cnt_word)) & ", (VHDL) : " & to_string(v_pipe_rd_data(v_pipe_rd_cnt_word))));
          end if;
          v_pipe_rd_cnt_index := v_pipe_rd_cnt_index + 1;

          if v_pipe_rd_cnt_word = (c_PIPE_RD_WORD_MAX - 1) then
            v_pipe_rd_cnt_word := 0;
            v_fsm_state        := E_RUN;
          else
            v_pipe_rd_cnt_word := v_pipe_rd_cnt_word + 1;
            v_fsm_state        := E_PIPE_OUT_DATA_COMPARE;
          end if;

        when E_DELAY =>
          v_nop_delay_trig := 0;
          if v_nop_delay_cnt = (v_nop_delay_cnt_max - 1) then
            v_nop_delay_cnt := 1;
            v_fsm_state     := E_RUN;
          else
            v_nop_delay_cnt := v_nop_delay_cnt + 1;
            v_fsm_state     := E_DELAY;
          end if;

        when E_END =>
          v_valid_out := '0';
          v_wr_finish := '1';
          v_fsm_state := E_END;

        when others =>  
          v_fsm_state := E_RST;

      end case;

      ---------------------------------------------------------------------
      -- status
      ---------------------------------------------------------------------
      o_wr_finish <= v_wr_finish;
      o_error     <= v_error;

      o_reg_id     <= v_file_reg_id;
      o_data_valid <= v_valid_out;
      o_data       <= v_data_out;

      pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure pkg_usb_wr;

end package body pkg_usb;
