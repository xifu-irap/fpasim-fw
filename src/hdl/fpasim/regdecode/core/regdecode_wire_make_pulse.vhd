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
--!   @file                   regdecode_wire_make_pulse.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details        
--! 
--!   This module analyses the field of the i_make_pulse register. 2 behaviour are managed by the FSM:
--!       1. if pixel_all_tmp = '0' then no change is done on the i_make_pulse register value.
--!       2. if pixel_out_tmp = '1', then the FSM will automatically generate (i_pixel_nb + 1) words from the i_make_pulse value.
--!          All field of the generated words will be identical except the pixel_id field. For each generated word, the pixel_id field
--!          will be incremented from 0 to i_pixel_nb.
--!                
--!   In all cases, the words are synchronized from a i_clk source clock domain to the i_out_clk destination clock domain. Then, the synchronized value(s) is/are read back in the
--!   i_clk source clock domain
--! 
--!   The architecture principle is as follows:
--!        @i_clk source clock domain              |                   @ i_out_clk destination clock domain
--!        i_make_pulse_valid-------FSM -----> async_fifo -----------> o_data 
--!                                                                |
--!        o_fifo_data <----------------------  async_fifo <-------
--!   Note: 
--!     . The read back of the synchronized data bus allows to check the clock domain crossing integrity.
--!     . The number of written data is equal to the number of data to read.
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_regdecode.all;

entity regdecode_wire_make_pulse is
  generic(
    g_DATA_WIDTH_OUT : positive := 15;  -- define the RAM address width
    g_PIXEL_NB_WIDTH : integer  := pkg_MAKE_PULSE_PIXEL_ID_WIDTH
    );
  port(
    ---------------------------------------------------------------------
    -- from the regdecode: input @i_clk
    ---------------------------------------------------------------------
    i_clk              : in  std_logic;  -- clock
    i_rst              : in  std_logic;  -- reset
    i_rst_status       : in  std_logic;  -- reset error flag(s)
    i_debug_pulse      : in  std_logic;  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
    -- conf
    i_pixel_nb         : in  std_logic_vector(g_PIXEL_NB_WIDTH - 1 downto 0);  -- number of pixels. Possibles values: [0,63]
    -- data
    i_make_pulse_valid : in  std_logic;  -- make pulse valid
    i_make_pulse       : in  std_logic_vector(g_DATA_WIDTH_OUT - 1 downto 0);  -- make pulse value
    o_wr_data_count    : out std_logic_vector(15 downto 0);
    ---------------------------------------------------------------------
    -- from/to the user:  @i_out_clk
    ---------------------------------------------------------------------
    i_out_clk          : in  std_logic;  -- output clock
    i_out_rst          : in std_logic; -- reset @i_out_clk
    -- extracted command
    i_data_rd          : in  std_logic;
    o_data_valid       : out std_logic;
    o_sof              : out std_logic;
    o_eof              : out std_logic;
    o_data             : out std_logic_vector(g_DATA_WIDTH_OUT - 1 downto 0);
    o_empty            : out std_logic;
    ---------------------------------------------------------------------
    -- from/to the regdecode: @i_clk
    ---------------------------------------------------------------------
    i_fifo_rd          : in  std_logic;  -- fifo read enable
    o_fifo_data_valid  : out std_logic;  -- fifo data valid
    o_fifo_sof         : out std_logic;  -- fifo first sample
    o_fifo_eof         : out std_logic;  -- fifo last sample
    o_fifo_data        : out std_logic_vector(g_DATA_WIDTH_OUT - 1 downto 0);  -- fifo data
    o_fifo_empty       : out std_logic;  -- fifo empty flag
    ---------------------------------------------------------------------
    -- errors/status @ i_clk
    ---------------------------------------------------------------------
    o_errors           : out std_logic_vector(15 downto 0);  -- output errors
    o_status           : out std_logic_vector(7 downto 0)    -- output status
    );
end entity regdecode_wire_make_pulse;

architecture RTL of regdecode_wire_make_pulse is
  -- pixel all
  constant c_PIXEL_ALL_IDX  : integer := pkg_MAKE_PULSE_PIXEL_ALL_IDX_H;
  -- pixel id
  constant c_PIXEL_ID_IDX_H : integer := pkg_MAKE_PULSE_PIXEL_ID_IDX_H;
  constant c_PIXEL_ID_IDX_L : integer := pkg_MAKE_PULSE_PIXEL_ID_IDX_L;
  constant c_PIXEL_ID_WIDTH : integer := pkg_MAKE_PULSE_PIXEL_ID_WIDTH;

  ---------------------------------------------------------------------
  -- fsm
  ---------------------------------------------------------------------
  signal pixel_all_tmp : std_logic;
  signal pixel_id_tmp  : std_logic_vector(c_PIXEL_ID_WIDTH - 1 downto 0);

  type t_state is (E_RST, E_WAIT, E_GEN_PIXEL_ID);
  signal sm_state_next : t_state := E_RST;
  signal sm_state_r1   : t_state := E_RST;

  signal sof_next : std_logic;
  signal sof_r1   : std_logic;

  signal eof_next : std_logic;
  signal eof_r1   : std_logic;

  signal data_valid_next : std_logic;
  signal data_valid_r1   : std_logic;

  signal error_next : std_logic;
  signal error_r1   : std_logic;

  signal pixel_id_next : unsigned(c_PIXEL_ID_WIDTH - 1 downto 0);
  signal pixel_id_r1   : unsigned(c_PIXEL_ID_WIDTH - 1 downto 0);

  signal pixel_id_max_next : unsigned(c_PIXEL_ID_WIDTH - 1 downto 0);
  signal pixel_id_max_r1   : unsigned(c_PIXEL_ID_WIDTH - 1 downto 0);

  signal tmp     : std_logic_vector(i_make_pulse'range);
  signal data_r1 : std_logic_vector(i_make_pulse'range);

  ---------------------------------------------------------------------
  -- regdecode_wire_wr_rd
  ---------------------------------------------------------------------
  constant c_IDX0_L : integer := 0;
  constant c_IDX0_H : integer := c_IDX0_L + i_make_pulse'length - 1;

  constant c_IDX1_L : integer := c_IDX0_H + 1;
  constant c_IDX1_H : integer := c_IDX1_L + 1 - 1;

  constant c_IDX2_L : integer := c_IDX1_H + 1;
  constant c_IDX2_H : integer := c_IDX2_L + 1 - 1;

  signal data_valid_tmp0    : std_logic;
  signal data_tmp0          : std_logic_vector(c_IDX2_H downto 0);
  signal ready_tmp0         : std_logic;
  signal wr_data_count_tmp0 : std_logic_vector(o_wr_data_count'range);

  signal rd_tmp1         : std_logic;
  signal data_valid_tmp1 : std_logic;
  signal data_tmp1       : std_logic_vector(c_IDX2_H downto 0);
  signal empty_tmp1      : std_logic;

  signal rd_tmp2         : std_logic;
  signal data_valid_tmp2 : std_logic;
  signal data_tmp2       : std_logic_vector(c_IDX2_H downto 0);
  signal empty_tmp2      : std_logic;

  signal errors : std_logic_vector(o_errors'range);
  signal status : std_logic_vector(o_status'range);

  ---------------------------------------------------------------------
  -- error latching
  ---------------------------------------------------------------------
  constant NB_ERRORS_c : integer := 1;
  signal error_tmp     : std_logic_vector(NB_ERRORS_c - 1 downto 0);
  signal error_tmp_bis : std_logic_vector(NB_ERRORS_c - 1 downto 0);

begin
  -- extract fields 
  pixel_all_tmp <= i_make_pulse(c_PIXEL_ALL_IDX);
  pixel_id_tmp  <= i_make_pulse(c_PIXEL_ID_IDX_H downto c_PIXEL_ID_IDX_L);  -- @suppress "Incorrect array size in assignment: expected (<pkg_MAKE_PULSE_PIXEL_ID_WIDTH>) but was (<6>)"

  ---------------------------------------------------------------------
  -- fsm
  ---------------------------------------------------------------------
  p_decode_state : process(i_make_pulse_valid, i_pixel_nb, pixel_all_tmp, pixel_id_tmp, pixel_id_max_r1, pixel_id_r1, sm_state_r1, ready_tmp0) is
  begin
    sof_next          <= '0';
    eof_next          <= '0';
    data_valid_next   <= '0';
    pixel_id_max_next <= pixel_id_max_r1;
    pixel_id_next     <= pixel_id_r1;
    error_next        <= '0';

    case sm_state_r1 is
      when E_RST =>
        sm_state_next <= E_WAIT;

      when E_WAIT =>
        if i_make_pulse_valid = '1' then
          data_valid_next   <= '1';
          pixel_id_max_next <= unsigned(i_pixel_nb) - 1;  -- 1 start @0  -- @suppress "Incorrect array size in assignment: expected (<pkg_NB_SAMPLE_BY_PIXEL_MAX_WIDTH>) but was (<g_PIXEL_NB_WIDTH>)"

          if pixel_all_tmp = '1' then
            sof_next      <= '1';
            pixel_id_next <= (others => '0');
            if unsigned(i_pixel_nb) = to_unsigned(0, i_pixel_nb'length) then
              -- special case: one pixel
              eof_next      <= '1';
              sm_state_next <= E_WAIT;
            else
              -- more than one pixel
              eof_next      <= '0';
              sm_state_next <= E_GEN_PIXEL_ID;
            end if;
          else
            pixel_id_next <= unsigned(pixel_id_tmp);
            sof_next      <= '1';
            eof_next      <= '1';
            sm_state_next <= E_WAIT;
          end if;
        else
          sm_state_next <= E_WAIT;
        end if;
      when E_GEN_PIXEL_ID =>

        if i_make_pulse_valid = '1' then
          error_next <= '1';
        else
          error_next <= '0';
        end if;
        if ready_tmp0 = '1' then
          data_valid_next <= '1';
          pixel_id_next   <= pixel_id_r1 + 1;
          if pixel_id_max_r1 = pixel_id_r1 then
            eof_next      <= '1';
            sm_state_next <= E_WAIT;
          else
            sm_state_next <= E_GEN_PIXEL_ID;
          end if;
        else
          sm_state_next <= E_GEN_PIXEL_ID;
        end if;
      when others =>  -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
        sm_state_next <= E_RST;
    end case;
  end process p_decode_state;

  p_state : process(i_clk) is
  begin
    if rising_edge(i_clk) then
      if i_rst = '1' then
        sm_state_r1 <= E_RST;
      else
        sm_state_r1 <= sm_state_next;
      end if;
      sof_r1          <= sof_next;
      eof_r1          <= eof_next;
      data_valid_r1   <= data_valid_next;
      pixel_id_r1     <= pixel_id_next;
      error_r1        <= error_next;
      pixel_id_max_r1 <= pixel_id_max_next;

    end if;
  end process p_state;

  ---------------------------------------------------------------------
  -- sync with fsm out
  ---------------------------------------------------------------------
  p_sync_with_fsm_out : process(i_clk) is
  begin
    if rising_edge(i_clk) then
      data_r1 <= i_make_pulse;
    end if;
  end process p_sync_with_fsm_out;

  ---------------------------------------------------------------------
  -- if pixel_all bit field = 1 then the pixel id is auto-computed
  -- if pixel_all bit field = 0 then no change on the pixel id field of the input data
  --  => only the pixel id field can be modified, the other fields keep their original values
  ---------------------------------------------------------------------
  -- keep the input data fields (above the pixel id field)
  tmp(data_r1'high downto c_PIXEL_ID_IDX_H + 1) <= data_r1(data_r1'high downto c_PIXEL_ID_IDX_H + 1);
  -- replace the pixed id field
  tmp(c_PIXEL_ID_IDX_H downto c_PIXEL_ID_IDX_L) <= std_logic_vector(pixel_id_r1);  -- @suppress "Incorrect array size in assignment: expected (<6>) but was (<pkg_MAKE_PULSE_PIXEL_ID_WIDTH>)"
  -- keep the input data field (below the pixel id field)
  tmp(c_PIXEL_ID_IDX_L - 1 downto 0)            <= data_r1(c_PIXEL_ID_IDX_L - 1 downto 0);

  ---------------------------------------------------------------------
  -- regdecode_wire_make_pulse_wr_rd
  ---------------------------------------------------------------------

  data_valid_tmp0                     <= data_valid_r1;
  data_tmp0(c_IDX2_H)                 <= sof_r1;
  data_tmp0(c_IDX1_H)                 <= eof_r1;
  data_tmp0(c_IDX0_H downto c_IDX0_L) <= tmp;

  inst_regdecode_wire_make_pulse_wr_rd : entity work.regdecode_wire_make_pulse_wr_rd
    generic map(
      g_DATA_WIDTH_OUT => data_tmp0'length   -- define the RAM address width
      )
    port map(
      ---------------------------------------------------------------------
      -- from the regdecode: input @i_clk
      ---------------------------------------------------------------------
      i_clk             => i_clk,       -- clock
      i_rst             => i_rst,       -- rst
      i_rst_status      => i_rst_status,   -- reset error flag(s)
      i_debug_pulse     => i_debug_pulse,  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
      -- data
      i_data_valid      => data_valid_tmp0,  -- data valid
      i_data            => data_tmp0,   -- data value
      o_ready           => ready_tmp0,
      o_wr_data_count   => wr_data_count_tmp0,
      ---------------------------------------------------------------------
      -- from/to the user:  @i_out_clk
      ---------------------------------------------------------------------
      i_out_clk         => i_out_clk,   -- output clock
      i_out_rst         => i_out_rst,
      -- ram: wr
      i_data_rd         => rd_tmp2,
      o_data_valid      => data_valid_tmp2,  -- data valid
      o_data            => data_tmp2,   -- data
      o_empty           => empty_tmp2,
      ---------------------------------------------------------------------
      -- to the regdecode: @i_clk
      ---------------------------------------------------------------------
      i_fifo_rd         => rd_tmp1,     -- fifo read enable
      o_fifo_data_valid => data_valid_tmp1,  -- fifo data valid
      o_fifo_data       => data_tmp1,   -- fifo data
      o_fifo_empty      => empty_tmp1,  -- fifo empty flag
      ---------------------------------------------------------------------
      -- errors/status @ i_clk
      ---------------------------------------------------------------------
      o_errors          => errors,      -- output errors
      o_status          => status       -- output status
      );

  rd_tmp1           <= i_fifo_rd;
  rd_tmp2           <= i_data_rd;
  -- output: to USB
  ---------------------------------------------------------------------
  o_fifo_data_valid <= data_valid_tmp1;
  o_fifo_sof        <= data_tmp1(c_IDX2_H);
  o_fifo_eof        <= data_tmp1(c_IDX1_H);
  o_fifo_data       <= data_tmp1(c_IDX0_H downto c_IDX0_L);
  o_fifo_empty      <= empty_tmp1;

  o_wr_data_count <= wr_data_count_tmp0;

  -- output: to the user
  ---------------------------------------------------------------------
  o_data_valid <= data_valid_tmp2;
  o_sof        <= data_tmp2(c_IDX2_H);
  o_eof        <= data_tmp2(c_IDX1_H);
  o_data       <= data_tmp2(c_IDX0_H downto c_IDX0_L);
  o_empty      <= empty_tmp2;

  ---------------------------------------------------------------------
  -- Error latching
  ---------------------------------------------------------------------
  error_tmp(0) <= error_r1;  -- fsm error: receive a wr command during the read address generation.
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

  o_errors(15)          <= error_tmp_bis(0);  -- fsm error: receive a wr command during the read address generation.
  o_errors(14 downto 0) <= errors(14 downto 0);
  o_status              <= status;
  ---------------------------------------------------------------------
  -- for simulation only
  ---------------------------------------------------------------------
  assert not (error_tmp_bis(0) = '1') report "[regdecode_wire_make_pulse] => a wr command is received during the read address generation " severity error;

end architecture RTL;
