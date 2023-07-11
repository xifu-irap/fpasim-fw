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
--    @file                   tes_negative_output_detection.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--   @details
--
--   This module does the following tasks:
--      . negative value detection:
--          1 .If i_pixel_result_sign = '1' and i_pixel_valid = '1' then the module
--            . generate a pulse (o_tes_neg_out_error_valid) on the first detection
--            . set to '1' the o_tes_neg_out_error signal until the i_rst signal is set to '1'
--            . latch the pixel_id value
--          2. wait a i_rst_status
--      . positive value detection:
--          1. If i_pixel_result_sign = '0' and i_pixel_valid = '1' (nominal case) then the module
--            . copy i_pixel_id into o_tes_neg_out_pixel_id
--
--  Note:
--    . To be able to detect a new negative value, the module need to be resetted.
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


use work.pkg_fpasim.all;
use work.pkg_regdecode.all;

entity tes_negative_output_detection is
  generic(
    -- command
    g_PIXEL_ID_WIDTH : positive := pkg_MAKE_PULSE_PIXEL_ID_WIDTH  -- pixel id bus width (expressed in bits). Possible values : [1; max integer value[
    );
  port(
    i_clk        : in std_logic;        -- clock
    i_rst        : in std_logic;        -- reset
    i_rst_status : in std_logic;        -- reset error flag(s)

    ---------------------------------------------------------------------
    -- input
    ---------------------------------------------------------------------
    i_pixel_valid             : in  std_logic;  -- pixel valid
    i_pixel_result_sign       : in  std_logic;  -- sign of the pixel result
    i_pixel_id                : in  std_logic_vector(g_PIXEL_ID_WIDTH - 1 downto 0);  -- pixel id
    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    o_pixel_neg_out_valid     : out std_logic;  -- valid negative output
    o_pixel_neg_out_error     : out std_logic;  -- negative output detection
    o_pixel_neg_out_pixel_id  : out std_logic_vector(g_PIXEL_ID_WIDTH - 1 downto 0)  -- pixel id when a negative output is detected
    );
end entity tes_negative_output_detection;

architecture RTL of tes_negative_output_detection is

  type t_state is (E_RST, E_WAIT, E_END);
  signal sm_state_next : t_state; -- state
  signal sm_state_r1   : t_state := E_RST; -- state (registered)

  signal data_valid_next : std_logic; -- data_valid
  signal data_valid_r1   : std_logic := '0'; -- data_valid (registered)

  signal rst_status_next : std_logic; -- reset_status
  signal rst_status_r1 : std_logic; -- reset_status (registered)

  signal pixel_id_next : std_logic_vector(i_pixel_id'range); -- pixel_id
  signal pixel_id_r1   : std_logic_vector(i_pixel_id'range) := (others => '0'); -- pixel_id (registered)

  signal error_next : std_logic; -- error flag
  signal error_r1   : std_logic := '0'; -- error flag (registered)

begin

---------------------------------------------------------------------
-- state machine
---------------------------------------------------------------------
  p_decode_state : process (error_r1, i_pixel_id, i_pixel_result_sign,
                            i_pixel_valid, pixel_id_r1, sm_state_r1, i_rst_status, rst_status_r1) is
  begin
    data_valid_next <= '0';
    pixel_id_next   <= pixel_id_r1;
    error_next      <= error_r1;
    rst_status_next <= '0';

    case sm_state_r1 is
      when E_RST =>
        sm_state_next <= E_WAIT;

      when E_WAIT =>

        pixel_id_next <= i_pixel_id;

        if i_pixel_valid = '1' and i_pixel_result_sign = '1' then
          data_valid_next <= '1';
          error_next      <= '1';
          rst_status_next <= '0';
          sm_state_next   <= E_END;
        else
          error_next    <= '0';
          sm_state_next <= E_WAIT;
        end if;

      when E_END =>
      rst_status_next <= i_rst_status;

      if i_rst_status = '1' and rst_status_r1 = '0' then
        data_valid_next <= '1';
        error_next      <= '0';
        sm_state_next <= E_WAIT;
      else
        sm_state_next <= E_END;
      end if;

      when others =>
        sm_state_next <= E_RST;
    end case;
  end process p_decode_state;

  p_state : process (i_clk) is
  begin
    if rising_edge(i_clk) then
      if i_rst = '1' then
        sm_state_r1 <= E_RST;
      else
        sm_state_r1 <= sm_state_next;
      end if;
      data_valid_r1 <= data_valid_next;
      pixel_id_r1   <= pixel_id_next;
      error_r1      <= error_next;
      rst_status_r1 <= rst_status_next;

    end if;
  end process p_state;


---------------------------------------------------------------------
-- output
---------------------------------------------------------------------
  o_pixel_neg_out_valid       <= data_valid_r1;
  o_pixel_neg_out_error       <= error_r1;
  o_pixel_neg_out_pixel_id    <= pixel_id_r1;


end architecture RTL;
