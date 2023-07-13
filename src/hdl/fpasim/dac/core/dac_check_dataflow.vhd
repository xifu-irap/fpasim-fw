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
--    @file                   dac_check_dataflow.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This module generates an error if the module detects the following pattern in the data flow:
--     data_valid -> hole -> data_valid
--
--     Note:
--       . the error signal is valid only if it was detected when the function is enabled
--
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity dac_check_dataflow is
  port(
    ---------------------------------------------------------------------
    -- input @i_dac_clk
    ---------------------------------------------------------------------
    i_dac_clk     : in  std_logic;      -- dac clock
    i_dac_rst     : in  std_logic;      -- reset signal
    i_dac_valid   : in  std_logic;      -- valid dac value

    ---------------------------------------------------------------------
    -- error @i_clk
    ---------------------------------------------------------------------
    i_clk         : in  std_logic;      -- clock signal
    i_rst_status  : in  std_logic;      -- reset error flag(s)
    i_debug_pulse : in  std_logic;      -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
    i_en          : in  std_logic;      -- enable
    o_error       : out std_logic       -- output error
  );
end entity dac_check_dataflow;

architecture RTL of dac_check_dataflow is

  ---------------------------------------------------------------------
  -- fsm
  ---------------------------------------------------------------------
  type t_state is (E_RST, E_WAIT, E_RUN, E_ERROR);
  signal sm_state_r1   : t_state; -- state (registered)
  signal sm_state_next : t_state; -- state

  signal error_next : std_logic; -- error
  signal error_r1   : std_logic; -- error (registered)

  -------------------------------------------------------------------
  -- sync fifo flags : @i_dac_clk -> @i_clk
  -------------------------------------------------------------------
  -- temporary error
  signal errors_tmp0      : std_logic_vector(0 downto 0);
  -- temporary error resynchronized
  signal errors_tmp0_sync : std_logic_vector(0 downto 0);

  ---------------------------------------------------------------------
  -- error latching
  ---------------------------------------------------------------------
  constant c_NB_ERRORS : integer := 1; -- define the width of the temporary errors signals
  signal error_tmp     : std_logic_vector(c_NB_ERRORS - 1 downto 0); -- temporary input errors
  signal error_tmp_bis : std_logic_vector(c_NB_ERRORS - 1 downto 0); -- temporary output errors

begin

  ---------------------------------------------------------------------
  -- fsm
  ---------------------------------------------------------------------
  p_decode_state : process(sm_state_r1, i_dac_valid) is
  begin
    error_next <= '0';
    case sm_state_r1 is
      when E_RST =>
        sm_state_next <= E_WAIT;

      when E_WAIT =>
        if i_dac_valid = '1' then
          sm_state_next <= E_RUN;
        else
          sm_state_next <= E_WAIT;
        end if;

      when E_RUN =>
        if i_dac_valid = '0' then
          sm_state_next <= E_ERROR;
        else
          sm_state_next <= E_RUN;
        end if;

      when E_ERROR =>
        error_next    <= '1';
        sm_state_next <= E_WAIT;

      when others =>
        sm_state_next <= E_RST;
    end case;
  end process p_decode_state;

  ---------------------------------------------------------------------
  -- State process : register signals
  ---------------------------------------------------------------------
  p_state : process(i_dac_clk) is
  begin
    if rising_edge(i_dac_clk) then
      if i_dac_rst = '1' then
        sm_state_r1 <= E_RST;
      else
        sm_state_r1 <= sm_state_next;
      end if;
      error_r1 <= error_next;

    end if;
  end process p_state;

  ---------------------------------------------------------------------
  -- synchronize fifo flags with i_dac_clk -> i_clk
  ---------------------------------------------------------------------
  errors_tmp0(0) <= error_r1;
  gen_errors_sync : for i in errors_tmp0'range generate
    inst_single_bit_synchronizer_empty_error : entity work.single_bit_synchronizer
      generic map(
        -- +---------------------------------------------------------------------------------------------------------------------+
        -- | DEST_SYNC_FF         | Integer            | Range: 2 - 10. Default value = 4.                                       |
        -- |---------------------------------------------------------------------------------------------------------------------|
        -- | Number of register stages used to synchronize signal in the destination clock domain.
        g_DEST_SYNC_FF  => 2,
        -- +---------------------------------------------------------------------------------------------------------------------+
        -- | SRC_INPUT_REG        | Integer            | Allowed values: 1, 0. Default value = 1.                                |
        -- |---------------------------------------------------------------------------------------------------------------------|
        -- | 0- Do not register input (src_in)                                                                                   |
        -- | 1- Register input (src_in) once using src_clk
        g_SRC_INPUT_REG => 1
      )
      port map(
        ---------------------------------------------------------------------
        -- source
        ---------------------------------------------------------------------
        i_src_clk  => i_dac_clk,        -- source clock
        i_src      => errors_tmp0(i),   -- input signal to be synchronized to dest_clk domain
        ---------------------------------------------------------------------
        -- destination
        ---------------------------------------------------------------------
        i_dest_clk => i_clk,            -- destination clock domain
        o_dest     => errors_tmp0_sync(i) -- src_in synchronized to the destination clock domain. This output is registered.
      );

  end generate gen_errors_sync;

  ---------------------------------------------------------------------
  -- Error latching
  ---------------------------------------------------------------------
  error_tmp(0) <= '1' when errors_tmp0_sync(0) = '1' and i_en = '1' else '0'; -- error
  error_flag_mng : for i in error_tmp'range generate
    inst_one_error_latch : entity work.one_error_latch
      port map(
        i_clk         => i_clk,
        i_rst         => i_rst_status,
        i_debug_pulse => i_debug_pulse,
        i_error       => error_tmp(i),
        o_error       => error_tmp_bis(i)
      );
  end generate error_flag_mng;

  o_error <= error_tmp_bis(0);

  ---------------------------------------------------------------------
  -- for simulation only
  ---------------------------------------------------------------------
  assert not (error_tmp_bis(0) = '1') report "[dac_check_dataflow] => detect, in the data flow, the following pattern: data_valid -> hole -> data_valid" severity error;

end architecture RTL;
