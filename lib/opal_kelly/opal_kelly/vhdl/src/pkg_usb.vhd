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

--
--    Note: This package should be compiled into the common_lib
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
    signal   i_clk                    : in std_logic;
    signal   i_start_wr               : in std_logic;
    ---------------------------------------------------------------------
    -- input file
    ---------------------------------------------------------------------
    i_filepath_wr                     : in string;
    i_csv_separator                   : in character;
    --  common typ = "UINT" => the file integer value is converted into an unsigned vector -> std_logic_vector
    --  common typ = "INT" => the file integer value  is converted into a signed vector -> std_logic_vector
    --  common typ = "HEX" => the hexadecimal value is converted into a std_logic_vector
    --  common typ = "STD_VEC" (binary value) => the std_logic_vector is not converted
    constant i_USB_WR_ADDR_COMMON_TYP : in string := "HEX";
    constant i_USB_WR_DATA_COMMON_TYP : in string := "HEX";
    ---------------------------------------------------------------------
    -- command
    ---------------------------------------------------------------------
    signal   i_wr_ready               : in std_logic;
    ---------------------------------------------------------------------
    -- usb
    ---------------------------------------------------------------------
    variable b_front_panel_conf       : inout t_front_panel_conf;
    signal   o_internal_wr_if         : out t_internal_wr_if;
    signal   i_internal_rd_if         : in t_internal_rd_if;
    ---------------------------------------------------------------------
    -- Vunit Scoreboard objects
    ---------------------------------------------------------------------
    constant i_data0_sb               : in checker_t;
    ---------------------------------------------------------------------
    -- data
    ---------------------------------------------------------------------
    signal   o_opal_kelly_type        : out integer;
    signal   o_opal_kelly_addr        : out std_logic_vector(7 downto 0);
    signal   o_data_valid             : out std_logic;
    signal   o_data                   : out std_logic_vector(31 downto 0);
    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal   o_wr_finish              : out std_logic;
    signal   o_error                  : out std_logic_vector(0 downto 0)
  );

end package pkg_usb;

package body pkg_usb is

  ---------------------------------------------------------------------
  -- pkg_usb_wr
  ---------------------------------------------------------------------
  procedure pkg_usb_wr(
    signal   i_clk                    : in std_logic;
    signal   i_start_wr               : in std_logic;
    ---------------------------------------------------------------------
    -- input file
    ---------------------------------------------------------------------
    i_filepath_wr                     : in string;
    i_csv_separator                   : in character;
    --  common typ = "UINT" => the file integer value is converted into an unsigned vector -> std_logic_vector
    --  common typ = "INT" => the file integer value  is converted into a signed vector -> std_logic_vector
    --  common typ = "HEX" => the hexadecimal value is converted into a std_logic_vector
    --  common typ = "STD_VEC" (binary value) => the std_logic_vector is not converted
    constant i_USB_WR_ADDR_COMMON_TYP : in string := "HEX";
    constant i_USB_WR_DATA_COMMON_TYP : in string := "HEX";
    ---------------------------------------------------------------------
    -- command
    ---------------------------------------------------------------------
    signal   i_wr_ready               : in std_logic;
    ---------------------------------------------------------------------
    -- usb
    ---------------------------------------------------------------------
    variable b_front_panel_conf       : inout t_front_panel_conf;
    signal   o_internal_wr_if         : out t_internal_wr_if;
    signal   i_internal_rd_if         : in t_internal_rd_if;
    ---------------------------------------------------------------------
    -- Vunit Scoreboard objects
    ---------------------------------------------------------------------
    constant i_data0_sb               : in checker_t;
    ---------------------------------------------------------------------
    -- data
    ---------------------------------------------------------------------
    signal   o_opal_kelly_type        : out integer;
    signal   o_opal_kelly_addr        : out std_logic_vector(7 downto 0);
    signal   o_data_valid             : out std_logic;
    signal   o_data                   : out std_logic_vector(31 downto 0);
    ---------------------------------------------------------------------
    -- status
    ---------------------------------------------------------------------
    signal   o_wr_finish              : out std_logic;
    signal   o_error                  : out std_logic_vector(0 downto 0)
  ) is
    variable v_csv_file : t_csv_file_reader;

    type t_state is (E_RST, E_WAIT_WR, E_RUN, E_DELAY, E_END);
    variable v_fsm_state : t_state := E_RST;
    variable v_test      : boolean := true;

    variable v_opal_kelly_type : integer                                            := 0;
    variable v_opal_kelly_addr : std_logic_vector(7 downto 0)                       := (others => '0');
    variable v_valid           : std_logic                                          := '0';
    variable v_wr_data         : std_logic_vector(i_internal_rd_if.hi_datain'range) := (others => '0');
    variable v_wr_finish       : std_logic                                          := '0';
    variable v_data            : std_logic_vector(i_internal_rd_if.hi_datain'range);

    variable v_cnt     : integer := 0;
    variable v_cnt_max : integer := 4;
    variable v_bit_pos : integer := 0;
    variable v_delay   : integer := 0;

    variable v_addr : integer;
    variable v_data1 : integer;
    variable v_data2 : integer;

    variable v_cnt_delay     : integer := 0;
    variable v_cnt_delay_max : integer := 0;
    variable v_is_delay      : integer := 0;

    variable v_cnt_wire : integer:= 0;

    variable v_length : integer := 0;

    variable v_NO_MASK : std_logic_vector(i_internal_rd_if.hi_datain'range) := x"ffff_ffff";
    variable v_error   : std_logic_vector(o_error'range)                    := (others => '0');

  begin

    while v_test = true loop
    v_valid := '0';
      case v_fsm_state is

        when E_RST =>

          v_wr_finish := '0';
          v_error     := (others => '0');
          FrontPanelReset(
            b_front_panel_conf => b_front_panel_conf,
            o_internal_wr_if => o_internal_wr_if,
            i_internal_rd_if => i_internal_rd_if
            );
          v_fsm_state := E_WAIT_WR;

        when E_WAIT_WR =>

          if i_start_wr = '1' then

            v_csv_file.initialize(i_filepath_wr, csv_separator => i_csv_separator);
            -- skip the header
            v_csv_file.readline(void);

            if v_csv_file.end_of_file(void) = true then -- @suppress "Redundant boolean equality check with true"
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

            v_opal_kelly_type := v_csv_file.read_integer(VOID);
            v_opal_kelly_addr := v_csv_file.read_common_typ_as_std_vec(length => v_opal_kelly_addr'length, common_typ => i_USB_WR_ADDR_COMMON_TYP);
            v_wr_data         := v_csv_file.read_common_typ_as_std_vec(length => v_wr_data'length, common_typ => i_USB_WR_DATA_COMMON_TYP);
            v_valid           := '1';

            case v_opal_kelly_type is
              when 0 =>
                -- pipe in
                b_front_panel_conf.set_pipeIn(index => v_cnt * v_cnt_max, value => v_wr_data(7 downto 0));
                b_front_panel_conf.set_pipeIn(index => v_cnt * v_cnt_max + 1, value => v_wr_data(15 downto 8));
                b_front_panel_conf.set_pipeIn(index => v_cnt * v_cnt_max + 2, value => v_wr_data(23 downto 16));
                b_front_panel_conf.set_pipeIn(index => v_cnt * v_cnt_max + 3, value => v_wr_data(31 downto 24));

                if v_cnt = v_cnt_max then
                  v_length := 4 * v_cnt_max;
                  WriteToPipeIn(
                    i_ep               => v_opal_kelly_addr,
                    i_length           => v_length, --write length expressed in bytes
                    b_front_panel_conf => b_front_panel_conf,
                    o_internal_wr_if   => o_internal_wr_if,
                    i_internal_rd_if   => i_internal_rd_if
                  );
                  v_cnt := 0;
                else
                  v_cnt := v_cnt + 1;
                end if;
              when 1 =>
                -- wire in
                SetWireInValue(
                  i_ep               => v_opal_kelly_addr,
                  i_val              => v_wr_data,
                  i_mask             => v_NO_MASK,
                  b_front_panel_conf => b_front_panel_conf
                );

                UpdateWireIns(
                  b_front_panel_conf => b_front_panel_conf,
                  o_internal_wr_if   => o_internal_wr_if,
                  i_internal_rd_if   => i_internal_rd_if);
              when 2 =>
                -- trig in
                -- v_wr_data value should be the bit position (start @0)
                --v_bit_pos := to_integer(unsigned(v_wr_data)) - 1;
                --ActivateTriggerIn(
                --  i_ep             => v_opal_kelly_addr,
                --  i_bit            => v_bit_pos,
                --  o_internal_wr_if => o_internal_wr_if,
                --  i_internal_rd_if => i_internal_rd_if
                --);

                ActivateTriggerIn_by_data(
                  i_ep             => v_opal_kelly_addr,
                  i_data            => v_wr_data,
                  o_internal_wr_if => o_internal_wr_if,
                  i_internal_rd_if => i_internal_rd_if
                );
              when 9 =>
                -- nop
                v_delay         := to_integer(unsigned(v_wr_data));
                v_cnt_delay_max := v_delay;
                v_cnt_delay     := 1;
                if v_delay = 1 then
                  v_is_delay := 0;
                else
                  v_is_delay := 1;
                end if;
              when 10 =>
                -- pipe out
                v_error(0) := '1';
              when 11 =>
                -- wire out
                UpdateWireOuts(
                   b_front_panel_conf => b_front_panel_conf,
                   o_internal_wr_if => o_internal_wr_if,
                   i_internal_rd_if => i_internal_rd_if
                   );
                GetWireOutValue(
                  i_ep => v_opal_kelly_addr,
                  b_front_panel_conf => b_front_panel_conf,
                  o_result => v_data
                 );
                v_addr := to_integer(unsigned(v_opal_kelly_addr));
                v_data1 := to_integer(unsigned(v_wr_data));
                v_data2 := to_integer(unsigned(v_data));
                --check_equal(i_data0_sb, v_wr_data, v_data, result("test rd wire, index: " & to_string(v_cnt_wire) & ", opal_kelly_addr: " & to_string(v_addr) & " (File) : " & to_string(v_wr_data) & ", (VHDL) : " & to_string(v_data)));
                check_equal(i_data0_sb, v_data2, v_data1, result("test rd wire, index: " & to_string(v_cnt_wire) & ", opal_kelly_addr: " & to_string(v_addr) & " (File) : " & to_string(v_data1) & ", (VHDL) : " & to_string(v_data2)));
                v_cnt_wire := v_cnt_wire + 1;
              when 12 =>
                -- trig out
                v_error(0) := '1';
              when others =>
                v_error(0) := '1';
            end case;

            if v_error(0) = '1' then
              info("[pkg_usb_wr]: error: v_opal_kelly_type is " & to_string(v_opal_kelly_type) & " instead of ");
              info("   pipe_in: opal_kelly_type=0 or ");
              info("   wire_in: opal_kelly_type=1 or ");
              info("   trig_in: opal_kelly_type=2 or ");
              info("   pipe_out: opal_kelly_type=10 or ");
              info("   wire_out: opal_kelly_type=11 or ");
              info("   trig_out: opal_kelly_type=12 or ");
            end if;
            if v_csv_file.end_of_file(void) = true then -- @suppress "Redundant boolean equality check with true"
              v_wr_finish := '1';
              v_csv_file.dispose(void);
              v_fsm_state := E_END;
            else
              if v_is_delay = 1 then
                v_fsm_state := E_DELAY;
              else
                v_wr_finish := '0';
                v_fsm_state := E_RUN;
              end if;
            end if;

          else
            v_valid     := '0';
            v_fsm_state := E_RUN;
          end if;

        when E_DELAY => 
        v_is_delay := 0;
          if v_cnt_delay = (v_cnt_delay_max - 1) then
            v_cnt_delay := 1;
            v_fsm_state := E_RUN;
          else
            v_cnt_delay := v_cnt_delay + 1;
            v_fsm_state := E_DELAY;
          end if;

        when E_END =>
          v_valid     := '0';
          v_wr_finish := '1';
          v_fsm_state := E_END;

        when others =>                  -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
          v_fsm_state := E_RST;

      end case;

      ---------------------------------------------------------------------
      -- status
      ---------------------------------------------------------------------
      o_wr_finish <= v_wr_finish;
      o_error     <= v_error;

      o_opal_kelly_type <= v_opal_kelly_type;
      o_opal_kelly_addr <= v_opal_kelly_addr;
      o_data_valid      <= v_valid;
      o_data            <= v_wr_data;

      --if v_wr_finish = '1' then
      --  v_test := False;
      --end if;

      pkg_wait_nb_rising_edge_plus_margin(i_clk, i_nb_rising_edge => 1, i_margin => 12 ps);
    end loop;

  end procedure pkg_usb_wr;

end package body pkg_usb;
