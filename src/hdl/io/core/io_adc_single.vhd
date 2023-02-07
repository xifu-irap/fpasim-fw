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
--    @file                   io_adc_single.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details                
--
--    This module retrieves data words from the FPGA IOs by de-serializing the input data.
--
--    The architecture is as follows:
--      i_adc_p/n ->  FPGA IO DDR deserializing (1-> 8) -> optionnal latency -> o_adc
--
--    Note: 
--      . An optional pipeliner (after the IO) can be added.
--      . After the de-serializer, bits are rearranged. For each output word, the bit order must match the bit order defined in the ads62p49 adc datasheet.
--  
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


entity io_adc_single is
  generic(
    g_INPUT_LATENCY : natural := 0  -- add latency after the input IO. Possible values: [0; max integer value[
    );
  port(

    -- from reset_top: @i_clk
    i_io_rst  : in std_logic;  -- Reset connected to all other elements in the circuit
    ---------------------------------------------------------------------
    -- input @i_adc_clk_p
    ---------------------------------------------------------------------
    i_adc_clk_p : in std_logic; -- adc clock
    i_adc_clk_n : in std_logic; -- adc clock
    
    i_adc_a_p : in std_logic_vector(6 downto 0);  -- Diff_p buffer input
    i_adc_a_n : in std_logic_vector(6 downto 0);  -- Diff_n buffer input

    i_adc_b_p : in std_logic_vector(6 downto 0);  -- Diff_p buffer input
    i_adc_b_n : in std_logic_vector(6 downto 0);  -- Diff_n buffer input

    ---------------------------------------------------------------------
    -- output @o_clk_div
    ---------------------------------------------------------------------
    o_adc_clk_div : out std_logic; -- output clock after the IO deserializing
    o_adc_a       : out std_logic_vector(55 downto 0); -- output adc_a data (4 words of 14 bits)
    o_adc_b       : out std_logic_vector(55 downto 0)  -- output adc_a data (4 words of 14 bits)
    );
end entity io_adc_single;

architecture RTL of io_adc_single is

  ---------------------------------------------------------------------
  -- selectio_wiz_adc
  ---------------------------------------------------------------------
  signal adc_tmp_p : std_logic_vector(13 downto 0);
  signal adc_tmp_n : std_logic_vector(13 downto 0);
  signal bitslip   : std_logic_vector(13 downto 0);
  signal adc_tmp0  : std_logic_vector(111 downto 0);

  signal clk_div : std_logic;

  ---------------------------------------------------------------------
  -- bit remapping
  ---------------------------------------------------------------------
  type t_word_by_bit is array (0 to 3) of std_logic_vector(13 downto 0);
  signal adc_a_word_tmp1 : t_word_by_bit;
  signal adc_a_word_tmp2 : t_word_by_bit;
  signal adc_b_word_tmp1 : t_word_by_bit;
  signal adc_b_word_tmp2 : t_word_by_bit;

begin

  -- adc_b
  adc_tmp_p(13 downto 7) <= i_adc_b_p;
  adc_tmp_n(13 downto 7) <= i_adc_b_n;
  -- adc_a
  adc_tmp_p(6 downto 0)  <= i_adc_a_p;
  adc_tmp_n(6 downto 0)  <= i_adc_a_n;

  bitslip <= (others => '0');

  inst_selectio_wiz_adc : entity work.selectio_wiz_adc
    port map(
      data_in_from_pins_p => adc_tmp_p,
      data_in_from_pins_n => adc_tmp_n,
      data_in_to_device   => adc_tmp0,
      clk_in_p            => i_adc_clk_p,
      clk_in_n            => i_adc_clk_n,
      bitslip             => bitslip,
      clk_div_out         => clk_div,
      clk_reset           => '0',
      io_reset            => i_io_rst
      );

-- output: to MMCM clock input
  o_adc_clk_div <= clk_div;
  ---------------------------------------------------------------------
  -- bit remapping: rebuild words from the serial links
  --     with word_tmp1(i)(j) <= adc_tmp0(k)
  --      i: word index of 14 bits words
  --      j: word bit index
  --      k: the index is taken from ip/xilinx/coregen/selectio_wiz_adc/selectio_wiz_adc_sim_netlist.vhdl from Xilinx ip compilation.
  --   Example:
  --   word0: 
  --      adc_b_word_tmp1(0)(13) <= adc_tmp0(27); -- word0: serial link13: 2nd bit 
  --      adc_b_word_tmp1(0)(12) <= adc_tmp0(13); -- word0: serial link13: 1st bit 
  --      adc_b_word_tmp1(0)(11) <= adc_tmp0(26); -- word0: serial link12: 2nd bit 
  --      adc_b_word_tmp1(0)(10) <= adc_tmp0(12); -- word0: serial link12: 1st bit 
  --      adc_b_word_tmp1(0)(9) <= adc_tmp0(25); -- word0: serial link11: 2nd bit
  --      adc_b_word_tmp1(0)(8) <= adc_tmp0(11); -- word0: serial link11: 1st bit 
  --      adc_b_word_tmp1(0)(7) <= adc_tmp0(24); -- word0: serial link10: 2nd bit
  --      adc_b_word_tmp1(0)(6) <= adc_tmp0(10); -- word0: serial link10: 1st bit 
  --      adc_b_word_tmp1(0)(5) <= adc_tmp0(23); -- word0: serial link09: 2nd bit 
  --      adc_b_word_tmp1(0)(4) <= adc_tmp0(09); -- word0: serial link09: 1st bit 
  --      adc_b_word_tmp1(0)(3) <= adc_tmp0(22); -- word0: serial link08: 2nd bit 
  --      adc_b_word_tmp1(0)(2) <= adc_tmp0(08); -- word0: serial link08: 1st bit 
  --      adc_b_word_tmp1(0)(1) <= adc_tmp0(21); -- word0: serial link07: 2nd bit 
  --      adc_b_word_tmp1(0)(0) <= adc_tmp0(07); -- word0: serial link07: 1st bit 
  --      adc_a_word_tmp1(0)(13) <= adc_tmp0(20); -- word0: serial link06: 2nd bit 
  --      adc_a_word_tmp1(0)(12) <= adc_tmp0(06); -- word0: serial link06: 1st bit 
  --      adc_a_word_tmp1(0)(11) <= adc_tmp0(19); -- word0: serial link05: 2nd bit 
  --      adc_a_word_tmp1(0)(10) <= adc_tmp0(05); -- word0: serial link05: 1st bit 
  --      adc_a_word_tmp1(0)(09) <= adc_tmp0(18); -- word0: serial link04: 2nd bit 
  --      adc_a_word_tmp1(0)(08) <= adc_tmp0(04); -- word0: serial link04: 1st bit 
  --      adc_a_word_tmp1(0)(07) <= adc_tmp0(17); -- word0: serial link03: 2nd bit 
  --      adc_a_word_tmp1(0)(06) <= adc_tmp0(03); -- word0: serial link03: 1st bit 
  --      adc_a_word_tmp1(0)(05) <= adc_tmp0(16); -- word0: serial link02: 2nd bit 
  --      adc_a_word_tmp1(0)(04) <= adc_tmp0(02); -- word0: serial link02: 1st bit 
  --      adc_a_word_tmp1(0)(03) <= adc_tmp0(15); -- word0: serial link01: 2nd bit 
  --      adc_a_word_tmp1(0)(02) <= adc_tmp0(01); -- word0: serial link01: 1st bit 
  --      adc_a_word_tmp1(0)(01) <= adc_tmp0(14); -- word0: serial link00: 2nd bit 
  --      adc_a_word_tmp1(0)(00) <= adc_tmp0(00); -- word0: serial link00: 1st bit 
  --   word1:
  --      adc_b_word_tmp1(i)(13) <= adc_tmp0(55); -- word1: serial link13 
  --      adc_b_word_tmp1(i)(12) <= adc_tmp0(41); -- word1: serial link13 
  --      adc_b_word_tmp1(i)(11) <= adc_tmp0(54); -- word1: serial link12 
  --      adc_b_word_tmp1(i)(10) <= adc_tmp0(40); -- word1: serial link12 
  --      adc_b_word_tmp1(i)(9) <= adc_tmp0(53); -- word1: serial link11 
  --      adc_b_word_tmp1(i)(8) <= adc_tmp0(39); -- word1: serial link11 
  --      adc_b_word_tmp1(i)(7) <= adc_tmp0(52); -- word1: serial link10 
  --      adc_b_word_tmp1(i)(6) <= adc_tmp0(38); -- word1: serial link10 
  --      adc_b_word_tmp1(i)(5) <= adc_tmp0(51); -- word1: serial link09 
  --      adc_b_word_tmp1(i)(4) <= adc_tmp0(37); -- word1: serial link09 
  --      adc_b_word_tmp1(i)(3) <= adc_tmp0(50); -- word1: serial link08 
  --      adc_b_word_tmp1(i)(2) <= adc_tmp0(36); -- word1: serial link08 
  --      adc_b_word_tmp1(i)(1) <= adc_tmp0(49); -- word1: serial link07 
  --      adc_b_word_tmp1(i)(0) <= adc_tmp0(25); -- word1: serial link07 
  --      adc_a_word_tmp1(1)(13) <= adc_tmp0(48); -- word1: serial link06: 4th bit 
  --      adc_a_word_tmp1(1)(12) <= adc_tmp0(34); -- word1: serial link06: 3th bit 
  --      adc_a_word_tmp1(1)(11) <= adc_tmp0(47); -- word1: serial link05: 4th bit 
  --      adc_a_word_tmp1(1)(10) <= adc_tmp0(33); -- word1: serial link05: 3th bit 
  --      adc_a_word_tmp1(1)(09) <= adc_tmp0(46); -- word1: serial link04: 4th bit 
  --      adc_a_word_tmp1(1)(08) <= adc_tmp0(32); -- word1: serial link04: 3th bit 
  --      adc_a_word_tmp1(1)(07) <= adc_tmp0(45); -- word1: serial link03: 4th bit 
  --      adc_a_word_tmp1(1)(06) <= adc_tmp0(31); -- word1: serial link03: 3th bit 
  --      adc_a_word_tmp1(1)(05) <= adc_tmp0(44); -- word1: serial link02: 4th bit 
  --      adc_a_word_tmp1(1)(04) <= adc_tmp0(30); -- word1: serial link02: 3th bit 
  --      adc_a_word_tmp1(1)(03) <= adc_tmp0(43); -- word1: serial link01: 4th bit 
  --      adc_a_word_tmp1(1)(02) <= adc_tmp0(29); -- word1: serial link01: 3th bit 
  --      adc_a_word_tmp1(1)(01) <= adc_tmp0(42); -- word1: serial link00: 4th bit 
  --      adc_a_word_tmp1(1)(00) <= adc_tmp0(28); -- word1: serial link00: 3th bit 

  gen_nb_words : for i in adc_a_word_tmp1'range generate
    -- adc_b
    adc_b_word_tmp1(i)(13) <= adc_tmp0(i*28 + 27);  -- wordj: serial link13 
    adc_b_word_tmp1(i)(12) <= adc_tmp0(i*28 + 13);  -- wordj: serial link13 
    adc_b_word_tmp1(i)(11) <= adc_tmp0(i*28 + 26);  -- wordj: serial link12 
    adc_b_word_tmp1(i)(10) <= adc_tmp0(i*28 + 12);  -- wordj: serial link12 
    adc_b_word_tmp1(i)(9)  <= adc_tmp0(i*28 + 25);  -- wordj: serial link11 
    adc_b_word_tmp1(i)(8)  <= adc_tmp0(i*28 + 11);  -- wordj: serial link11 
    adc_b_word_tmp1(i)(7)  <= adc_tmp0(i*28 + 24);  -- wordj: serial link10 
    adc_b_word_tmp1(i)(6)  <= adc_tmp0(i*28 + 10);  -- wordj: serial link10 
    adc_b_word_tmp1(i)(5)  <= adc_tmp0(i*28 + 23);  -- wordj: serial link09 
    adc_b_word_tmp1(i)(4)  <= adc_tmp0(i*28 + 09);  -- wordj: serial link09 
    adc_b_word_tmp1(i)(3)  <= adc_tmp0(i*28 + 22);  -- wordj: serial link08 
    adc_b_word_tmp1(i)(2)  <= adc_tmp0(i*28 + 08);  -- wordj: serial link08 
    adc_b_word_tmp1(i)(1)  <= adc_tmp0(i*28 + 21);  -- wordj: serial link07 
    adc_b_word_tmp1(i)(0)  <= adc_tmp0(i*28 + 07);  -- wordj: serial link07 
    -- adc_a
    adc_a_word_tmp1(i)(13) <= adc_tmp0(i*28 + 20);  -- wordj: serial link06 
    adc_a_word_tmp1(i)(12) <= adc_tmp0(i*28 + 06);  -- wordj: serial link06 
    adc_a_word_tmp1(i)(11) <= adc_tmp0(i*28 + 19);  -- wordj: serial link05 
    adc_a_word_tmp1(i)(10) <= adc_tmp0(i*28 + 05);  -- wordj: serial link05 
    adc_a_word_tmp1(i)(09) <= adc_tmp0(i*28 + 18);  -- wordj: serial link04 
    adc_a_word_tmp1(i)(08) <= adc_tmp0(i*28 + 04);  -- wordj: serial link04 
    adc_a_word_tmp1(i)(07) <= adc_tmp0(i*28 + 17);  -- wordj: serial link03 
    adc_a_word_tmp1(i)(06) <= adc_tmp0(i*28 + 03);  -- wordj: serial link03 
    adc_a_word_tmp1(i)(05) <= adc_tmp0(i*28 + 16);  -- wordj: serial link02 
    adc_a_word_tmp1(i)(04) <= adc_tmp0(i*28 + 02);  -- wordj: serial link02 
    adc_a_word_tmp1(i)(03) <= adc_tmp0(i*28 + 15);  -- wordj: serial link01 
    adc_a_word_tmp1(i)(02) <= adc_tmp0(i*28 + 01);  -- wordj: serial link01 
    adc_a_word_tmp1(i)(01) <= adc_tmp0(i*28 + 14);  -- wordj: serial link00 
    adc_a_word_tmp1(i)(00) <= adc_tmp0(i*28 + 00);  -- wordj: serial link00 
    ---------------------------------------------------------------------
    -- optionnally add latency after input IO
    ---------------------------------------------------------------------
    -- adc_a
    inst_pipeliner_add_input_latency_adc_a : entity work.pipeliner
      generic map(
        g_NB_PIPES   => g_INPUT_LATENCY,  -- number of consecutives registers. Possibles values: [0, integer max value[
        g_DATA_WIDTH => adc_a_word_tmp1(i)'length  -- width of the input/output data.  Possibles values: [1, integer max value[
        )
      port map(
        i_clk  => clk_div,
        i_data => adc_a_word_tmp1(i),
        o_data => adc_a_word_tmp2(i)
        );

    -- adc_b
    inst_pipeliner_add_input_latency_adc_b : entity work.pipeliner
      generic map(
        g_NB_PIPES   => g_INPUT_LATENCY,  -- number of consecutives registers. Possibles values: [0, integer max value[
        g_DATA_WIDTH => adc_b_word_tmp1(i)'length  -- width of the input/output data.  Possibles values: [1, integer max value[
        )
      port map(
        i_clk  => clk_div,
        i_data => adc_b_word_tmp1(i),
        o_data => adc_b_word_tmp2(i)
        );
  end generate gen_nb_words;

  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  -- adc_b
  o_adc_b(55 downto 42) <= adc_b_word_tmp2(3);
  o_adc_b(41 downto 28) <= adc_b_word_tmp2(2);
  o_adc_b(27 downto 14) <= adc_b_word_tmp2(1);
  o_adc_b(13 downto 0)  <= adc_b_word_tmp2(0);
  -- adc_a
  o_adc_a(55 downto 42) <= adc_a_word_tmp2(3);
  o_adc_a(41 downto 28) <= adc_a_word_tmp2(2);
  o_adc_a(27 downto 14) <= adc_a_word_tmp2(1);
  o_adc_a(13 downto 0)  <= adc_a_word_tmp2(0);


end architecture RTL;
