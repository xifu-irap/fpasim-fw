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
--    @file                   dac_frame_generator.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details                
--
--    This module has 2 modes:
--     . normal mode (i_dac_en_pattern=0): 
--        . After the startup, on the first sample, it generates a pulse on the sof signal one time.
--        . the input data flow are duplicated on the o_data0 and o_data1 signals
--     . pattern mode (i_dac_en_pattern=1): (see dac3283 datasheet (figure 34)).
--        . After the startup, on the first sample, it generates a pulse on the sof signal one time.
--        . The input data is ignored
--        . The input data valid drive the pattern generation.
--        . It periodically generates the following 2 sequences:
--           . sequence0: it generate a pulse on the sof signal
--              . o_dac0(15 downto 8) <= pkg_DAC_PATTERN0;
--              . o_dac0(7 downto 0) <= pkg_DAC_PATTERN1;
--              . o_dac1(15 downto 8) <= pkg_DAC_PATTERN2;
--              . o_dac1(7 downto 0) <= pkg_DAC_PATTERN3;
--           . sequence1:
--              . o_dac0(15 downto 8) <= pkg_DAC_PATTERN4;
--              . o_dac0(7 downto 0) <= pkg_DAC_PATTERN5;
--              . o_dac1(15 downto 8) <= pkg_DAC_PATTERN6;
--              . o_dac1(7 downto 0) <= pkg_DAC_PATTERN7;
--
--   The output data flow has the following structure:
--
--   Example0: normal mode
--     i_dac_valid:   1   1   1   1   1   1   1   1   
--     i_dac      :   a1  a2  a3  a4  a5  a6  a7  a8  
--     o_dac_valid:   1   1   1   1   1   1   1   1  
--     o_dac_frame:   1   0   0   0   0   0   0   0   
--     o_dac0      :  a1  a2  a3  a4  a5  a6  a7  a8  
--     o_dac1      :  a1  a2  a3  a4  a5  a6  a7  a8  
--
--   Example1: pattern mode (input data is ignored)
--     i_dac_valid      :   1              1           1         1   
--     i_dac            :   a1             a2          a3        a4  
--     o_dac_valid      :   1              1           1         1   
--     o_dac_frame      :   1              0           0         0   
--     o_dac0 (MSB-LSB) :  pat0-pat1  pat4-pat5  pat0-pat1  pat4-pat5 
--     o_dac1 (MSB-LSB) :  pat2-pat3  pat6-pat7  pat2-pat3  pat6-pat7
--
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dac_frame_generator is
  port(
    i_clk            : in std_logic;    -- clock signal
    i_rst            : in std_logic;    -- reset signal
    ---------------------------------------------------------------------
    -- command
    ---------------------------------------------------------------------
    i_dac_en_pattern : in std_logic;  --'1': enable dac pattern generation, '0': use input data flow
    i_dac_pattern0   : in std_logic_vector(7 downto 0);   -- pattern0 value
    i_dac_pattern1   : in std_logic_vector(7 downto 0);   -- pattern1 value
    i_dac_pattern2   : in std_logic_vector(7 downto 0);   -- pattern2 value
    i_dac_pattern3   : in std_logic_vector(7 downto 0);   -- pattern3 value
    i_dac_pattern4   : in std_logic_vector(7 downto 0);   -- pattern4 value
    i_dac_pattern5   : in std_logic_vector(7 downto 0);   -- pattern5 value
    i_dac_pattern6   : in std_logic_vector(7 downto 0);   -- pattern6 value
    i_dac_pattern7   : in std_logic_vector(7 downto 0);   -- pattern7 value
    ---------------------------------------------------------------------
    -- input
    ---------------------------------------------------------------------
    i_data_valid     : in std_logic;    -- input valid sample
    i_data           : in std_logic_vector(15 downto 0);  -- input data

    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    o_sof        : out std_logic;       -- first sample of the frame
    o_data_valid : out std_logic;       -- output valid sample
    o_data1      : out std_logic_vector(15 downto 0);  -- output data1
    o_data0      : out std_logic_vector(15 downto 0)   -- output data0
    );
end entity dac_frame_generator;

architecture RTL of dac_frame_generator is

  type t_state is (E_RST, E_WAIT, E_RUN, E_PATTERN);
  signal sm_state_r1   : t_state := E_RST;
  signal sm_state_next : t_state;

  signal sof_next : std_logic;
  signal sof_r1   : std_logic := '0';

  signal first_next : std_logic;
  signal first_r1   : std_logic := '0';

  signal data_valid_next : std_logic;
  signal data_valid_r1   : std_logic := '0';

  signal data0_next : std_logic_vector(o_data0'range) := (others => '0');
  signal data0_r1   : std_logic_vector(o_data0'range) := (others => '0');

  signal data1_next : std_logic_vector(o_data1'range) := (others => '0');
  signal data1_r1   : std_logic_vector(o_data1'range) := (others => '0');


begin

  -------------------------------------------------------------------
  -- fsm
  -------------------------------------------------------------------
  p_decode_state : process(data0_r1, data1_r1, first_r1, i_dac_en_pattern,
                           i_dac_pattern0, i_dac_pattern1, i_dac_pattern2,
                           i_dac_pattern3, i_dac_pattern4, i_dac_pattern5,
                           i_dac_pattern6, i_dac_pattern7, i_data,
                           i_data_valid, sm_state_r1) is
  begin
    sof_next        <= '0';
    first_next      <= first_r1;
    data_valid_next <= '0';
    data1_next      <= data1_r1;
    data0_next      <= data0_r1;
    case sm_state_r1 is
      when E_RST =>
        first_next    <= '1';
        sm_state_next <= E_WAIT;

      when E_WAIT =>
        if i_data_valid = '1' then
          data_valid_next <= i_data_valid;
          if i_dac_en_pattern = '1' then
            -- after the startup, generate one time a pulse on the sof signal.
            if first_r1 = '1' then
              first_next <= '0';
              sof_next   <= '1';
            end if;
            -- generate a pre-defined patterns according to the dac3283 datasheet (figure 34)
            data1_next(15 downto 8) <= i_dac_pattern2;
            data1_next(7 downto 0)  <= i_dac_pattern3;
            data0_next(15 downto 8) <= i_dac_pattern0;
            data0_next(7 downto 0)  <= i_dac_pattern1;
            sm_state_next           <= E_PATTERN;
          else
            sof_next      <= '1';
            -- duplicate the input data on the 2 outputs
            data0_next    <= i_data;
            data1_next    <= i_data;
            sm_state_next <= E_RUN;
          end if;
        else
          sm_state_next <= E_WAIT;
        end if;

      when E_RUN =>  -- @suppress "Dead state 'E_RUN': state does not have outgoing transitions"
        if i_data_valid = '1' then
          data_valid_next <= i_data_valid;
          -- duplicate the input data on the 2 outputs
          data0_next      <= i_data;
          data1_next      <= i_data;
          sm_state_next   <= E_RUN;
        else
          sm_state_next <= E_RUN;
        end if;

      when E_PATTERN =>

        if i_data_valid = '1' then
          data_valid_next         <= i_data_valid;
          -- generate a pre-defined patterns according to the dac3283 datasheet (figure 34)
          data1_next(15 downto 8) <= i_dac_pattern6;
          data1_next(7 downto 0)  <= i_dac_pattern7;

          data0_next(15 downto 8) <= i_dac_pattern4;
          data0_next(7 downto 0)  <= i_dac_pattern5;
          sm_state_next           <= E_WAIT;
        else
          sm_state_next <= E_PATTERN;
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
      sof_r1        <= sof_next;
      first_r1      <= first_next;
      data_valid_r1 <= data_valid_next;

      -- pipe
      data1_r1 <= data1_next;
      data0_r1 <= data0_next;

    end if;
  end process p_state;

  -------------------------------------------------------------------
  -- output
  -------------------------------------------------------------------
  o_sof        <= sof_r1;
  o_data_valid <= data_valid_r1;
  o_data1      <= data1_r1;
  o_data0      <= data0_r1;

end architecture RTL;
