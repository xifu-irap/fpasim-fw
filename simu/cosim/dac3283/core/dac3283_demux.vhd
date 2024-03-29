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
--    @file                   dac3283_demux.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    The input data stream is a Time-division multiplexing signal (dac0-dac1-dac0-dac1).
--    By using the frame signal, this module extracts for each dacs its associated data.
--
--    Note:
--     . The adc0 output is associated to the I ways of the dac3283 datasheet
--     . The adc1 output is associated to the Q ways of the dac3283 datasheet
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


entity dac3283_demux is
  generic (
    g_DAC_DELAY : natural := 0  -- DAC conversion delay (expressed in number of clock cycles @i_clk). The range is: [0;max integer value[)
    );
  port (

    i_clk       : in std_logic; -- clock
    i_rst       : in std_logic; -- reset
    ---------------------------------------------------------------------
    -- input
    ---------------------------------------------------------------------
    i_dac_frame : in std_logic; -- dac frame
    i_dac       : in std_logic_vector(15 downto 0); -- dac value

    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    o_dac0_valid : out std_logic; -- dac0 data valid
    o_dac0       : out std_logic_vector(15 downto 0); -- dac0 data value

    o_dac1_valid : out std_logic;-- dac1 data valid
    o_dac1       : out std_logic_vector(15 downto 0) -- dac1 data value
    );
end entity dac3283_demux;

architecture RTL of dac3283_demux is

---------------------------------------------------------------------
-- state machine
---------------------------------------------------------------------
  -- fsm type declaration
  type t_state is (E_RST, E_WAIT, E_RUN0, E_RUN1);
  signal sm_state_next : t_state := E_RST; -- state
  signal sm_state_r1   : t_state := E_RST; -- state (registered)

   -- dac0 data valid
  signal data_valid0_next : std_logic;
   -- dac0 data valid (registered)
  signal data_valid0_r1   : std_logic := '0';

   -- dac0 data
  signal data0_next : std_logic_vector(o_dac0'range);
   -- dac0 data (registered)
  signal data0_r1   : std_logic_vector(o_dac0'range) := (others => '0');

  -- dac1 data valid
  signal data_valid1_next : std_logic;
   -- dac1 data valid (registered)
  signal data_valid1_r1   : std_logic := '0';

   -- dac1 data
  signal data1_next : std_logic_vector(o_dac1'range);
   -- dac0 data (registered)
  signal data1_r1   : std_logic_vector(o_dac1'range) := (others => '0');

---------------------------------------------------------------------
-- optional output delay
---------------------------------------------------------------------
  constant c_IDX0_L : integer := 0;-- index0: low
  constant c_IDX0_H : integer := c_IDX0_L + o_dac0'length -1;-- index0: high

  constant c_IDX1_L : integer := c_IDX0_H + 1;-- index1: low
  constant c_IDX1_H : integer := c_IDX1_L + o_dac1'length -1;-- index1: high

  constant c_IDX2_L : integer := c_IDX1_H + 1;-- index2: low
  constant c_IDX2_H : integer := c_IDX2_L + 1 -1;-- index2: high

  constant c_IDX3_L : integer := c_IDX2_H + 1;-- index3: low
  constant c_IDX3_H : integer := c_IDX3_L + 1 -1;-- index3: high

  signal data_pipe_tmp0 : std_logic_vector(c_IDX3_H downto 0);-- temporary input pipe
  signal data_pipe_tmp1 : std_logic_vector(c_IDX3_H downto 0);-- temporary output pipe

   -- delayed dac0 data valid
  signal data_valid0_tmp1 : std_logic;
 -- delayed dac0 data (registered)
  signal data0_tmp1       : std_logic_vector(o_dac0'range);

   -- delayed dac1 data valid
  signal data_valid1_tmp1 : std_logic;
   -- delayed dac1 data (registered)
  signal data1_tmp1       : std_logic_vector(o_dac0'range);

begin

  ---------------------------------------------------------------------
  -- This state machine allows to demux the input data into 2 channel:
  --   . dac0
  --   . dac1
  ---------------------------------------------------------------------
  p_decode_state : process (data0_r1, data1_r1, i_dac, i_dac_frame,
                            sm_state_r1) is
  begin
    -- default value
    data_valid0_next <= '0';
    data0_next       <= data0_r1;
    data_valid1_next <= '0';
    data1_next       <= data1_r1;

    case sm_state_r1 is
      when E_RST =>
        sm_state_next <= E_WAIT;

      when E_WAIT =>
        if i_dac_frame = '1' then
          data_valid0_next <= '1';
          data0_next       <= i_dac;
          sm_state_next    <= E_RUN1;
        else
          sm_state_next <= E_WAIT;
        end if;

      when E_RUN0 =>
        data_valid0_next <= '1';
        data0_next       <= i_dac;
        sm_state_next    <= E_RUN1;

      when E_RUN1 =>
        data_valid1_next <= '1';
        data1_next       <= i_dac;
        sm_state_next    <= E_RUN0;

      when others =>
        sm_state_next <= E_RST;
    end case;
  end process p_decode_state;

  ---------------------------------------------------------------------
  -- State process : register signals
  ---------------------------------------------------------------------
  p_state : process (i_clk) is
  begin
    if rising_edge(i_clk) then
      if i_rst = '1' then
        sm_state_r1 <= E_RST;
      else
        sm_state_r1 <= sm_state_next;
      end if;
      data_valid0_r1 <= data_valid0_next;
      data0_r1       <= data0_next;
      data_valid1_r1 <= data_valid1_next;
      data1_r1       <= data1_next;
    end if;
  end process p_state;

---------------------------------------------------------------------
-- optional output delay
---------------------------------------------------------------------
  data_pipe_tmp0(c_IDX3_H)                 <= data_valid1_r1;
  data_pipe_tmp0(c_IDX2_H)                 <= data_valid0_r1;
  data_pipe_tmp0(c_IDX1_H downto c_IDX1_L) <= data1_r1;
  data_pipe_tmp0(c_IDX0_H downto c_IDX0_L) <= data0_r1;

  inst_pipeliner : entity work.pipeliner
    generic map(
      g_NB_PIPES   => g_DAC_DELAY,  -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => data_pipe_tmp0'length  -- width of the input/output data.  Possibles values: [1, integer max value[
      )
    port map(
      i_clk  => i_clk,                  -- clock signal
      i_data => data_pipe_tmp0,         -- input data
      o_data => data_pipe_tmp1          -- output data with/without delay
      );

  data_valid1_tmp1 <= data_pipe_tmp1(c_IDX3_H);
  data_valid0_tmp1 <= data_pipe_tmp1(c_IDX2_H);
  data1_tmp1       <= data_pipe_tmp1(c_IDX1_H downto c_IDX1_L);
  data0_tmp1       <= data_pipe_tmp1(c_IDX0_H downto c_IDX0_L);
---------------------------------------------------------------------
-- output
---------------------------------------------------------------------
  o_dac0_valid     <= data_valid0_tmp1;
  o_dac0           <= data0_tmp1;

  o_dac1_valid <= data_valid1_tmp1;
  o_dac1       <= data1_tmp1;

end architecture RTL;
