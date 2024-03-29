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
--    @file                   mux_squid.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This module performs the following mux_squid computation steps:
--      . addr0 = i_pixel_result - i_mux_squid_feedback
--      . S0 = MUX_SQUID_TF(addr0): use the addr value to read a pre-loaded RAM
--      . addr1 = id_pixel_id
--      . offset =  MUX_SQUID_OFFSET(addr1): use the addr value to read a pre-loaded RAM
--      . o_pixel_result = S0 + offset
--
--    Note:
--       . i_inter_squid_gain is not aligned with the data flow.
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_fpasim.all;
use work.pkg_regdecode.all;

entity mux_squid is
  generic(
    -- command
    g_INTER_SQUID_GAIN_WIDTH                : positive := pkg_CONF0_INTER_SQUID_GAIN_WIDTH;  -- inter_squid_gain bus width (expressed in bits). Possible values: [1; max integer value[
    -- pixel
    g_PIXEL_ID_WIDTH                        : positive := pkg_NB_PIXEL_BY_FRAME_MAX_WIDTH;  -- pixel id bus width (expressed in bits). Possible values: [1; max integer value[
    -- address
    g_MUX_SQUID_TF_RAM_ADDR_WIDTH           : positive := pkg_MUX_SQUID_TF_RAM_ADDR_WIDTH;  -- address bus width (expressed in bits)
    -- computation
    g_PIXEL_RESULT_INPUT_WIDTH              : positive := pkg_TES_MULT_SUB_Q_WIDTH_S;  -- pixel input result bus width  (expressed in bits). Possible values: [1; max integer value[
    g_PIXEL_RESULT_OUTPUT_WIDTH             : positive := pkg_MUX_SQUID_MULT_ADD_Q_WIDTH_S;  -- pixel output result bus width (expressed in bits). Possible values: [1; max integer value[
    -- RAM configuration filename
    g_MUX_SQUID_OFFSET_RAM_MEMORY_INIT_FILE : string   := pkg_MUX_SQUID_OFFSET_RAM_MEMORY_INIT_FILE;
    g_MUX_SQUID_TF_RAM_MEMORY_INIT_FILE     : string   := pkg_MUX_SQUID_TF_RAM_MEMORY_INIT_FILE
    );
  port(
    i_clk              : in std_logic;  -- clock
    i_rst              : in std_logic;  -- reset
    i_rst_status       : in std_logic;  -- reset error flag(s)
    i_debug_pulse      : in std_logic;  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
    ---------------------------------------------------------------------
    -- input command: from the regdecode
    ---------------------------------------------------------------------
    -- inter_squid_gain valid
    i_inter_squid_gain_valid : in std_logic;
    -- inter_squid_gain value
    i_inter_squid_gain : in std_logic_vector(g_INTER_SQUID_GAIN_WIDTH - 1 downto 0);

    -- RAM: mux_squid_offset
    -- wr
    i_mux_squid_offset_wr_en      : in  std_logic;  -- ram write enable
    i_mux_squid_offset_wr_rd_addr : in  std_logic_vector(g_PIXEL_ID_WIDTH - 1 downto 0);  -- ram write/read address
    i_mux_squid_offset_wr_data    : in  std_logic_vector(15 downto 0);  -- ram write data
    -- rd
    i_mux_squid_offset_rd_en      : in  std_logic;  -- ram read en
    o_mux_squid_offset_rd_valid   : out std_logic;  -- ram read data valid
    o_mux_squid_offset_rd_data    : out std_logic_vector(15 downto 0);  -- ram rd data

    -- RAM: mux_squid_tf
    -- wr
    i_mux_squid_tf_wr_en      : in  std_logic;  -- ram write enable
    i_mux_squid_tf_wr_rd_addr : in  std_logic_vector(g_MUX_SQUID_TF_RAM_ADDR_WIDTH - 1 downto 0);  -- ram write/read address
    i_mux_squid_tf_wr_data    : in  std_logic_vector(15 downto 0);  -- ram write data
    --rd
    i_mux_squid_tf_rd_en      : in  std_logic;  -- ram read enable
    o_mux_squid_tf_rd_valid   : out std_logic;  -- ram read data valid
    o_mux_squid_tf_rd_data    : out std_logic_vector(15 downto 0);  -- ram read data
    ---------------------------------------------------------------------
    -- input1
    ---------------------------------------------------------------------
    i_pixel_sof               : in  std_logic;  -- first pixel sample
    i_pixel_eof               : in  std_logic;  -- last pixel sample
    i_pixel_valid             : in  std_logic;  -- valid pixel sample
    i_pixel_id                : in  std_logic_vector(g_PIXEL_ID_WIDTH - 1 downto 0);  -- pixel id
    i_pixel_result            : in  std_logic_vector(g_PIXEL_RESULT_INPUT_WIDTH - 1 downto 0);  -- pixel result
    ---------------------------------------------------------------------
    -- input2
    ---------------------------------------------------------------------
    i_mux_squid_feedback      : in  std_logic_vector(13 downto 0);  -- mux squid feedback value
    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    o_pixel_sof               : out std_logic;  -- first pixel sample
    o_pixel_eof               : out std_logic;  -- last pixel sample
    o_pixel_valid             : out std_logic;  -- valid pixel sample
    o_pixel_id                : out std_logic_vector(g_PIXEL_ID_WIDTH - 1 downto 0);  -- pixel id
    o_pixel_result            : out std_logic_vector(g_PIXEL_RESULT_OUTPUT_WIDTH - 1 downto 0);  -- pixel result
    ---------------------------------------------------------------------
    -- errors/status
    ---------------------------------------------------------------------
    o_errors                  : out std_logic_vector(15 downto 0);  -- output errors
    o_status                  : out std_logic_vector(7 downto 0)  -- output status
    );
end entity mux_squid;

architecture RTL of mux_squid is

  -- memory size in bits
  constant c_MEMORY_SIZE_MUX_SQUID_OFFSET : positive := (2 ** (i_mux_squid_offset_wr_rd_addr'length)) * (i_mux_squid_offset_wr_data'length);
  -- memory size in bits
  constant c_MEMORY_SIZE_MUX_SQUID_TF     : positive := (2 ** (i_mux_squid_tf_wr_rd_addr'length)) * i_mux_squid_tf_wr_data'length;

  ---------------------------------------------------------------------
  -- default inter_squid_gain
  ---------------------------------------------------------------------
  -- init value (startup) of the inter_squid_gain
  constant c_INTER_SQUID_GAIN_INIT : std_logic_vector(i_inter_squid_gain'range):= std_logic_vector(to_unsigned(pkg_INTER_SQUID_GAIN_INIT,i_inter_squid_gain'length));
  -- latched inter_squid_gain value
  signal inter_squid_gain_r1 : std_logic_vector(i_inter_squid_gain'range):= c_INTER_SQUID_GAIN_INIT;

  ---------------------------------------------------------------------
  -- compute
  --   S = i_pixel_result - i_mux_squid_feedback
  ---------------------------------------------------------------------
  -- operator input_a
  signal pixel_result_tmp : std_logic_vector(pkg_MUX_SQUID_SUB_Q_WIDTH_A - 1 downto 0);
  -- operator input_b
  signal mux_squid_fb_tmp : std_logic_vector(pkg_MUX_SQUID_SUB_Q_WIDTH_B - 1 downto 0):= (others => '0');
  -- operator output
  signal result_sub_rx    : std_logic_vector(pkg_MUX_SQUID_SUB_Q_WIDTH_S - 1 downto 0);

  ---------------------------------------------------------------------
  -- sync with sub_sfixed_mux_squid out
  ---------------------------------------------------------------------
  constant c_IDX0_L : integer := 0; --index0: low
  constant c_IDX0_H : integer := c_IDX0_L + i_pixel_id'length - 1; -- index0: high

  constant c_IDX1_L : integer := c_IDX0_H + 1; --index1: low
  constant c_IDX1_H : integer := c_IDX1_L + 1 - 1; -- index1: high

  constant c_IDX2_L : integer := c_IDX1_H + 1; --index2: low
  constant c_IDX2_H : integer := c_IDX2_L + 1 - 1; -- index2: high

  constant c_IDX3_L : integer := c_IDX2_H + 1; --index3: low
  constant c_IDX3_H : integer := c_IDX3_L + 1 - 1; -- index3: high

  signal data_pipe_tmp0 : std_logic_vector(c_IDX3_H downto 0);-- temporary input pipe signal
  signal data_pipe_tmp1 : std_logic_vector(c_IDX3_H downto 0);-- temporary output pipe signal

  signal pixel_sof_rx   : std_logic; -- first pixel sample
  signal pixel_eof_rx   : std_logic; -- last pixel sample
  signal pixel_valid_rx : std_logic; -- valid pixel sample
  signal pixel_id_rx    : std_logic_vector(i_pixel_id'range); -- pixel id

  ---------------------------------------------------------------------
  -- mux_squid_offset
  ---------------------------------------------------------------------
  -- RAM
  -- portA en
  signal mux_squid_offset_wea    : std_logic;
  -- portA we
  signal mux_squid_offset_ena    : std_logic;
   -- portA address
  signal mux_squid_offset_addra  : std_logic_vector(i_mux_squid_offset_wr_rd_addr'range);
  -- portA data in
  signal mux_squid_offset_dina   : std_logic_vector(i_mux_squid_offset_wr_data'range);
  -- portA regce
  signal mux_squid_offset_regcea : std_logic;
  -- portA data out
  signal mux_squid_offset_douta  : std_logic_vector(i_mux_squid_offset_wr_data'range);

  -- portB en
  signal mux_squid_offset_web    : std_logic;
  -- portB we
  signal mux_squid_offset_enb    : std_logic;
  -- portB address
  signal mux_squid_offset_addrb  : std_logic_vector(i_mux_squid_offset_wr_rd_addr'range);
  -- portB data in
  signal mux_squid_offset_dinb   : std_logic_vector(i_mux_squid_offset_wr_data'range);
  -- portB regce
  signal mux_squid_offset_regceb : std_logic;
  -- portB data out
  signal mux_squid_offset_doutb  : std_logic_vector(i_mux_squid_offset_wr_data'range);

  -- sync with rd RAM output
  signal mux_squid_offset_rd_en_rw : std_logic;
  -- ram check
  signal mux_squid_offset_error    : std_logic;

  ---------------------------------------------------------------------
  -- mux_squid_tf
  ---------------------------------------------------------------------
  -- RAM
  -- portA en
  signal mux_squid_tf_wea    : std_logic;
  -- portA we
  signal mux_squid_tf_ena    : std_logic;
  -- portA address
  signal mux_squid_tf_addra  : std_logic_vector(i_mux_squid_tf_wr_rd_addr'range);
  -- portA data in
  signal mux_squid_tf_dina   : std_logic_vector(i_mux_squid_tf_wr_data'range);
  -- portA regce
  signal mux_squid_tf_regcea : std_logic;
  -- portA data out
  signal mux_squid_tf_douta  : std_logic_vector(i_mux_squid_tf_wr_data'range);

  -- portB en
  signal mux_squid_tf_web    : std_logic;
  -- portB we
  signal mux_squid_tf_enb    : std_logic;
  -- portB address
  signal mux_squid_tf_addrb  : std_logic_vector(i_mux_squid_tf_wr_rd_addr'range);
  -- portB data in
  signal mux_squid_tf_dinb   : std_logic_vector(i_mux_squid_tf_wr_data'range);
  -- portB regce
  signal mux_squid_tf_regceb : std_logic;
  -- portB data out
  signal mux_squid_tf_doutb  : std_logic_vector(i_mux_squid_tf_wr_data'range);

  -- sync with rd ram output
  signal mux_squid_tf_rd_en_rw : std_logic;

  -- ram check
  signal mux_squid_tf_error : std_logic;

  ---------------------------------------------------------------------
  -- sync with the mux_squid_tf out
  ---------------------------------------------------------------------
  signal data_pipe_tmp2 : std_logic_vector(c_IDX3_H downto 0);-- temporary input pipe signal
  signal data_pipe_tmp3 : std_logic_vector(c_IDX3_H downto 0);-- temporary output pipe signal

  signal pixel_sof_ry   : std_logic; -- first pixel sample
  signal pixel_eof_ry   : std_logic; -- last pixel sample
  signal pixel_valid_ry : std_logic; -- valid pixel sample
  signal pixel_id_ry    : std_logic_vector(i_pixel_id'range); -- pixel id

  -- delayed mux_squid_offset
  signal mux_squid_offset_ry : std_logic_vector(i_mux_squid_offset_wr_data'range);

  -------------------------------------------------------------------
  -- add: mux_squid_offset + mux_squid_tf
  -------------------------------------------------------------------
  -- add a sign bit
  -- operator input a
  signal inter_squid_gain_tmp : std_logic_vector(pkg_MUX_SQUID_MULT_ADD_Q_WIDTH_A - 1 downto 0);
  -- operator input b
  signal mux_squid_tf_tmp     : std_logic_vector(pkg_MUX_SQUID_MULT_ADD_Q_WIDTH_B - 1 downto 0);
  -- operator input c
  signal mux_squid_offset_tmp : std_logic_vector(pkg_MUX_SQUID_MULT_ADD_Q_WIDTH_C - 1 downto 0);
  -- operator output
  signal result_rz            : std_logic_vector(o_pixel_result'range);

  ---------------------------------------------------------------------
  -- sync with the add_sfixed_mux_squid_offset_and_tf out
  ---------------------------------------------------------------------
  signal data_pipe_tmp4 : std_logic_vector(c_IDX3_H downto 0); -- temporary input pipe signal
  signal data_pipe_tmp5 : std_logic_vector(c_IDX3_H downto 0); -- temporary output pipe signal

  signal pixel_sof_rz   : std_logic; -- first pixel sample
  signal pixel_eof_rz   : std_logic; -- last pixel sample
  signal pixel_valid_rz : std_logic; -- valid pixel sample
  signal pixel_id_rz    : std_logic_vector(i_pixel_id'range); -- pixel id

  ---------------------------------------------------------------------
  -- error latching
  ---------------------------------------------------------------------
  constant c_NB_ERRORS : integer := 2; -- define the width of the temporary errors signals
  signal error_tmp     : std_logic_vector(c_NB_ERRORS - 1 downto 0); -- temporary input errors
  signal error_tmp_bis : std_logic_vector(c_NB_ERRORS - 1 downto 0); -- temporary output errors

begin

  ---------------------------------------------------------------------
  -- default inter_squid_gain
  ---------------------------------------------------------------------
  p_default_inter_squid_gain: process (i_clk) is
  begin
    if rising_edge(i_clk) then
      if i_rst = '1' then
        inter_squid_gain_r1 <= c_INTER_SQUID_GAIN_INIT;
      elsif i_inter_squid_gain_valid = '1' then
        inter_squid_gain_r1 <= i_inter_squid_gain;
      end if;
    end if;
  end process p_default_inter_squid_gain;

  assert not ((i_pixel_result'length) /= ((pixel_result_tmp'length)))
         report "[mux_squid]: pixel result => input port width and sfixed package definition width doesn't match." severity error;
  assert not ((mux_squid_fb_tmp'length) < (i_mux_squid_feedback'length))
         report "[mux_squid]: mux_squid_fb_tmp'length must be >= i_mux_squid_feedback'length" severity error;

  -------------------------------------------------------------------
  -- sub_sfixed_mux_squid_out
  -- requirement: FPASIM-FW-REQ-0150 (part0)
  -------------------------------------------------------------------
  -- we assume i_pixel_result is always >=0 => set the sign bit (MSB bits) to '0'
  pixel_result_tmp       <= '0' & i_pixel_result(i_pixel_result'high - 1 downto 0);
  -- we assume (mux_squid_fb_tmp'length) >= (i_mux_squid_feedback'length)
  --    align the MSB bits between mux_squid_fb_tmp and i_mux_squid_feedback (<=> mux_squid_fb_tmp <= i_mux_squid_feedback*4).
  --     => the remaining LSB bits of mux_squid_fb_tmp are fixed to '0'
  mux_squid_fb_tmp(mux_squid_fb_tmp'high downto (mux_squid_fb_tmp'high - i_mux_squid_feedback'high)) <= i_mux_squid_feedback;

  inst_sub_sfixed_mux_squid : entity work.sub_sfixed
    generic map(
      -- port A: AMD Q notation (fixed point)
      g_Q_M_A => pkg_MUX_SQUID_SUB_Q_M_A,
      g_Q_N_A => pkg_MUX_SQUID_SUB_Q_N_A,
      -- port B: AMD Q notation (fixed point)
      g_Q_M_B => pkg_MUX_SQUID_SUB_Q_M_B,
      g_Q_N_B => pkg_MUX_SQUID_SUB_Q_N_B,
      -- port S: AMD Q notation (fixed point)
      g_Q_M_S => pkg_MUX_SQUID_SUB_Q_M_S,
      g_Q_N_S => pkg_MUX_SQUID_SUB_Q_N_S
      )
    port map(
      i_clk => i_clk,
      --------------------------------------------------------------
      -- input
      --------------------------------------------------------------
      i_a   => pixel_result_tmp,
      i_b   => mux_squid_fb_tmp,
      --------------------------------------------------------------
      -- output : S = A - B
      --------------------------------------------------------------
      o_s   => result_sub_rx
      );
  assert not ((result_sub_rx'length) /= (mux_squid_tf_addrb'length)) report "[mux_squid]: result_sub_rx => mux_squid_tf_addrb width and sfixed package definition width doesn't match." severity error;

  -----------------------------------------------------------------
  -- sync with sub_sfixed_mux_squid out
  -----------------------------------------------------------------
  data_pipe_tmp0(c_IDX3_H)                 <= i_pixel_valid;
  data_pipe_tmp0(c_IDX2_H)                 <= i_pixel_sof;
  data_pipe_tmp0(c_IDX1_H)                 <= i_pixel_eof;
  data_pipe_tmp0(c_IDX0_H downto c_IDX0_L) <= i_pixel_id;
  inst_pipeliner_sync_with_sub_sfixed_mux_squid_out : entity work.pipeliner
    generic map(
      g_NB_PIPES   => pkg_SUB_SFIXED_LATENCY,  -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => data_pipe_tmp0'length  -- width of the input/output data.  Possibles values: [1, integer max value[
      )
    port map(
      i_clk  => i_clk,                  -- clock signal
      i_data => data_pipe_tmp0,         -- input data
      o_data => data_pipe_tmp1          -- output data with/without delay
      );

  pixel_valid_rx <= data_pipe_tmp1(c_IDX3_H);
  pixel_sof_rx   <= data_pipe_tmp1(c_IDX2_H);
  pixel_eof_rx   <= data_pipe_tmp1(c_IDX1_H);
  pixel_id_rx    <= data_pipe_tmp1(c_IDX0_H downto c_IDX0_L);

  ---------------------------------------------------------------------
  -- RAM: mux_squid_offset
  ---------------------------------------------------------------------
  mux_squid_offset_ena   <= i_mux_squid_offset_wr_en or i_mux_squid_offset_rd_en;
  mux_squid_offset_wea   <= i_mux_squid_offset_wr_en;
  mux_squid_offset_addra <= i_mux_squid_offset_wr_rd_addr;
  mux_squid_offset_dina  <= i_mux_squid_offset_wr_data;

  mux_squid_offset_regcea <= '1';

  inst_tdpram_mux_squid_offset : entity work.tdpram
    generic map(
      -- port A
      g_ADDR_WIDTH_A       => mux_squid_offset_addra'length,
      g_BYTE_WRITE_WIDTH_A => mux_squid_offset_dina'length,
      g_WRITE_DATA_WIDTH_A => mux_squid_offset_dina'length,
      g_WRITE_MODE_A       => "no_change",
      g_READ_DATA_WIDTH_A  => mux_squid_offset_dina'length,
      g_READ_LATENCY_A     => pkg_MUX_SQUID_OFFSET_RAM_A_RD_LATENCY,
      -- port B
      g_ADDR_WIDTH_B       => mux_squid_offset_addra'length,
      g_BYTE_WRITE_WIDTH_B => mux_squid_offset_dina'length,
      g_WRITE_DATA_WIDTH_B => mux_squid_offset_dina'length,
      g_WRITE_MODE_B       => "no_change",
      g_READ_DATA_WIDTH_B  => mux_squid_offset_dina'length,
      g_READ_LATENCY_B     => pkg_MUX_SQUID_OFFSET_RAM_B_RD_LATENCY,
      -- other
      g_CLOCKING_MODE      => "common_clock",
      g_MEMORY_PRIMITIVE   => "block",
      g_MEMORY_SIZE        => c_MEMORY_SIZE_MUX_SQUID_OFFSET,
      g_MEMORY_INIT_FILE   => g_MUX_SQUID_OFFSET_RAM_MEMORY_INIT_FILE,
      g_MEMORY_INIT_PARAM  => ""
      )
    port map(
      ---------------------------------------------------------------------
      -- port A
      ---------------------------------------------------------------------
      i_rsta   => '0',
      i_clka   => i_clk,
      i_ena    => mux_squid_offset_ena,
      i_wea(0) => mux_squid_offset_wea,
      i_addra  => mux_squid_offset_addra,
      i_dina   => mux_squid_offset_dina,
      i_regcea => mux_squid_offset_regcea,
      o_douta  => mux_squid_offset_douta,
      ---------------------------------------------------------------------
      -- port B
      ---------------------------------------------------------------------
      i_rstb   => '0',
      i_clkb   => i_clk,
      i_web(0) => mux_squid_offset_web,
      i_enb    => mux_squid_offset_enb,
      i_addrb  => mux_squid_offset_addrb,
      i_dinb   => mux_squid_offset_dinb,
      i_regceb => mux_squid_offset_regceb,
      o_doutb  => mux_squid_offset_doutb
      );
  mux_squid_offset_web    <= '0';
  mux_squid_offset_dinb   <= (others => '0');
  mux_squid_offset_enb    <= i_pixel_valid;
  mux_squid_offset_addrb  <= i_pixel_id;
  mux_squid_offset_regceb <= '1';

  -------------------------------------------------------------------
  -- sync with rd RAM output
  -------------------------------------------------------------------
  inst_pipeliner_sync_with_tdpram_mux_squid_offset_outa : entity work.pipeliner
    generic map(
      g_NB_PIPES   => pkg_MUX_SQUID_OFFSET_RAM_A_RD_LATENCY,  -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => 1  -- width of the input/output data.  Possibles values: [1, integer max value[
      )
    port map(
      i_clk     => i_clk,               -- clock signal
      i_data(0) => i_mux_squid_offset_rd_en,  -- input data
      o_data(0) => mux_squid_offset_rd_en_rw  -- output data with/without delay
      );
  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_mux_squid_offset_rd_valid <= mux_squid_offset_rd_en_rw;
  o_mux_squid_offset_rd_data  <= mux_squid_offset_douta;

  ---------------------------------------------------------------------
  -- RAM check
  ---------------------------------------------------------------------

  inst_ram_check_sdpram_mux_squid_offset : entity work.ram_check
    generic map(
      g_WR_ADDR_WIDTH => mux_squid_offset_addra'length,
      g_RD_ADDR_WIDTH => mux_squid_offset_addrb'length
      )
    port map(
      i_clk         => i_clk,
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_wr          => mux_squid_offset_wea,
      i_wr_addr     => mux_squid_offset_addra,
      i_rd          => mux_squid_offset_enb,
      i_rd_addr     => mux_squid_offset_addrb,
      ---------------------------------------------------------------------
      -- Errors
      ---------------------------------------------------------------------
      o_error_pulse => mux_squid_offset_error
      );

  ---------------------------------------------------------------------
  -- RAM: mux_squid_tf
  ---------------------------------------------------------------------
  mux_squid_tf_ena   <= i_mux_squid_tf_wr_en or i_mux_squid_tf_rd_en;
  mux_squid_tf_wea   <= i_mux_squid_tf_wr_en;
  mux_squid_tf_addra <= i_mux_squid_tf_wr_rd_addr;
  mux_squid_tf_dina  <= i_mux_squid_tf_wr_data;

  mux_squid_tf_regcea <= '1';

  inst_tdpram_mux_squid_tf : entity work.tdpram
    generic map(
      -- port A
      g_ADDR_WIDTH_A       => mux_squid_tf_addra'length,
      g_BYTE_WRITE_WIDTH_A => mux_squid_tf_dina'length,
      g_WRITE_DATA_WIDTH_A => mux_squid_tf_dina'length,
      g_WRITE_MODE_A       => "no_change",
      g_READ_DATA_WIDTH_A  => mux_squid_tf_dina'length,
      g_READ_LATENCY_A     => pkg_MUX_SQUID_TF_RAM_A_RD_LATENCY,
      -- port B
      g_ADDR_WIDTH_B       => mux_squid_tf_addra'length,
      g_BYTE_WRITE_WIDTH_B => mux_squid_tf_dina'length,
      g_WRITE_DATA_WIDTH_B => mux_squid_tf_dina'length,
      g_WRITE_MODE_B       => "no_change",
      g_READ_DATA_WIDTH_B  => mux_squid_tf_dina'length,
      g_READ_LATENCY_B     => pkg_MUX_SQUID_TF_RAM_B_RD_LATENCY,
      -- other
      g_CLOCKING_MODE      => "common_clock",
      g_MEMORY_PRIMITIVE   => "block",
      g_MEMORY_SIZE        => c_MEMORY_SIZE_MUX_SQUID_TF,
      g_MEMORY_INIT_FILE   => g_MUX_SQUID_TF_RAM_MEMORY_INIT_FILE,
      g_MEMORY_INIT_PARAM  => ""
      )
    port map(
      ---------------------------------------------------------------------
      -- port A
      ---------------------------------------------------------------------
      i_rsta   => '0',
      i_clka   => i_clk,
      i_ena    => mux_squid_tf_ena,
      i_wea(0) => mux_squid_tf_wea,
      i_addra  => mux_squid_tf_addra,
      i_dina   => mux_squid_tf_dina,
      i_regcea => mux_squid_tf_regcea,
      o_douta  => mux_squid_tf_douta,
      ---------------------------------------------------------------------
      -- port B
      ---------------------------------------------------------------------
      i_rstb   => '0',
      i_clkb   => i_clk,
      i_web(0) => mux_squid_tf_web,
      i_enb    => mux_squid_tf_enb,
      i_addrb  => mux_squid_tf_addrb,
      i_dinb   => mux_squid_tf_dinb,
      i_regceb => mux_squid_tf_regceb,
      o_doutb  => mux_squid_tf_doutb
      );
  mux_squid_tf_web    <= '0';
  mux_squid_tf_dinb   <= (others => '0');
  mux_squid_tf_enb    <= pixel_valid_rx;
  mux_squid_tf_addrb  <= result_sub_rx;
  mux_squid_tf_regceb <= '1';

  -------------------------------------------------------------------
  -- sync with rd RAM output
  -------------------------------------------------------------------
  inst_pipeliner_sync_with_tdpram_mux_squid_tf_outa : entity work.pipeliner
    generic map(
      g_NB_PIPES   => pkg_MUX_SQUID_TF_RAM_A_RD_LATENCY,  -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => 1  -- width of the input/output data.  Possibles values: [1, integer max value[
      )
    port map(
      i_clk     => i_clk,               -- clock signal
      i_data(0) => i_mux_squid_tf_rd_en,  -- input data
      o_data(0) => mux_squid_tf_rd_en_rw  -- output data with/without delay
      );
  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_mux_squid_tf_rd_valid <= mux_squid_tf_rd_en_rw;
  o_mux_squid_tf_rd_data  <= mux_squid_tf_douta;

  ---------------------------------------------------------------------
  -- check RAM
  ---------------------------------------------------------------------
  inst_ram_check_sdpram_mux_squid_tf : entity work.ram_check
    generic map(
      g_WR_ADDR_WIDTH => mux_squid_tf_addra'length,
      g_RD_ADDR_WIDTH => mux_squid_tf_addrb'length
      )
    port map(
      i_clk         => i_clk,
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_wr          => mux_squid_tf_wea,
      i_wr_addr     => mux_squid_tf_addra,
      i_rd          => mux_squid_tf_enb,
      i_rd_addr     => mux_squid_tf_addrb,
      ---------------------------------------------------------------------
      -- Errors
      ---------------------------------------------------------------------
      o_error_pulse => mux_squid_tf_error
      );

  -----------------------------------------------------------------
  -- sync with sub_sfixed_mux_squid out
  -----------------------------------------------------------------
  data_pipe_tmp2(c_IDX3_H)                 <= pixel_valid_rx;
  data_pipe_tmp2(c_IDX2_H)                 <= pixel_sof_rx;
  data_pipe_tmp2(c_IDX1_H)                 <= pixel_eof_rx;
  data_pipe_tmp2(c_IDX0_H downto c_IDX0_L) <= pixel_id_rx;
  inst_pipeliner_sync_with_sdpram_mux_squid_tf_out : entity work.pipeliner
    generic map(
      g_NB_PIPES   => pkg_MUX_SQUID_TF_RAM_B_RD_LATENCY,  -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => data_pipe_tmp2'length  -- width of the input/output data.  Possibles values: [1, integer max value[
      )
    port map(
      i_clk  => i_clk,                  -- clock signal
      i_data => data_pipe_tmp2,         -- input data
      o_data => data_pipe_tmp3          -- output data with/without delay
      );

  pixel_valid_ry <= data_pipe_tmp3(c_IDX3_H);
  pixel_sof_ry   <= data_pipe_tmp3(c_IDX2_H);
  pixel_eof_ry   <= data_pipe_tmp3(c_IDX1_H);
  pixel_id_ry    <= data_pipe_tmp3(c_IDX0_H downto c_IDX0_L);

  -----------------------------------------------------------------
  -- sync with sub_sfixed_mux_squid out
  -----------------------------------------------------------------

  inst_pipeliner_sync_with_sdpram_mux_squid_tf2_out : entity work.pipeliner
    generic map(
      g_NB_PIPES   => pkg_SUB_SFIXED_LATENCY,  -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => mux_squid_offset_doutb'length  -- width of the input/output data.  Possibles values: [1, integer max value[
      )
    port map(
      i_clk  => i_clk,                  -- clock signal
      i_data => mux_squid_offset_doutb,        -- input data
      o_data => mux_squid_offset_ry     -- output data with/without delay
      );

  ---------------------------------------------------------------------
  -- compute: inter_squid_gain* mux_squid_tf + mux_squid_offset
  -- requirement: FPASIM-FW-REQ-0150 (part1)
  ---------------------------------------------------------------------
  assert not ((inter_squid_gain_r1'length) /= ((inter_squid_gain_tmp'length) - 1))
      report "[mux_squid]: inter_squid_gain_tmp => port width and sfixed package definition width doesn't match." severity error;
  assert not ((mux_squid_tf_doutb'length) /= ((mux_squid_tf_tmp'length) - 1))
     report "[mux_squid]: mux_squid_tf_tmp => port width and sfixed package definition width doesn't match." severity error;
  assert not ((mux_squid_offset_tmp'length) /= (mux_squid_offset_ry'length))
     report "[mux_squid]: mux_squid_offset_tmp => port width and sfixed package definition width doesn't match." severity error;
  -- unsigned to signed conversion: sign bit extension (add a sign bit)
  inter_squid_gain_tmp <= std_logic_vector(resize(unsigned(inter_squid_gain_r1), inter_squid_gain_tmp'length));
  mux_squid_tf_tmp     <= std_logic_vector(resize(unsigned(mux_squid_tf_doutb), mux_squid_tf_tmp'length));
  -- no conversion => width unchanged
  mux_squid_offset_tmp <= mux_squid_offset_ry;

  inst_mult_add_sfixed_mux_squid_offset_and_tf : entity work.mult_add_sfixed
    generic map(
      -- port A: AMD Q notation (fixed point)
      g_Q_M_A => pkg_MUX_SQUID_MULT_ADD_Q_M_A,
      g_Q_N_A => pkg_MUX_SQUID_MULT_ADD_Q_N_A,
      -- port B: AMD Q notation (fixed point)
      g_Q_M_B => pkg_MUX_SQUID_MULT_ADD_Q_M_B,
      g_Q_N_B => pkg_MUX_SQUID_MULT_ADD_Q_N_B,
      -- port C: AMC Q notation (fixed point)
      g_Q_M_C => pkg_MUX_SQUID_MULT_ADD_Q_M_C,
      g_Q_N_C => pkg_MUX_SQUID_MULT_ADD_Q_N_C,
      -- port S: AMD Q notation (fixed point)
      g_Q_M_S => pkg_MUX_SQUID_MULT_ADD_Q_M_S,
      g_Q_N_S => pkg_MUX_SQUID_MULT_ADD_Q_N_S
      )
    port map(
      i_clk => i_clk,
      --------------------------------------------------------------
      -- input
      --------------------------------------------------------------
      i_a   => inter_squid_gain_tmp,
      i_b   => mux_squid_tf_tmp,
      i_c   => mux_squid_offset_tmp,
      --------------------------------------------------------------
      -- output : S = C + A*B
      --------------------------------------------------------------
      o_s   => result_rz
      );

  -----------------------------------------------------------------
  -- sync with inst_add_sfixed_mux_squid_offset_and_tf out
  -----------------------------------------------------------------
  data_pipe_tmp4(c_IDX3_H)                 <= pixel_valid_ry;
  data_pipe_tmp4(c_IDX2_H)                 <= pixel_sof_ry;
  data_pipe_tmp4(c_IDX1_H)                 <= pixel_eof_ry;
  data_pipe_tmp4(c_IDX0_H downto c_IDX0_L) <= pixel_id_ry;
  inst_pipeliner_sync_with_mult_add_sfixed_mux_squid_offset_and_tf_out : entity work.pipeliner
    generic map(
      g_NB_PIPES   => pkg_MULT_ADD_SFIXED_LATENCY,  -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => data_pipe_tmp4'length  -- width of the input/output data.  Possibles values: [1, integer max value[
      )
    port map(
      i_clk  => i_clk,                  -- clock signal
      i_data => data_pipe_tmp4,         -- input data
      o_data => data_pipe_tmp5          -- output data with/without delay
      );

  pixel_valid_rz <= data_pipe_tmp5(c_IDX3_H);
  pixel_sof_rz   <= data_pipe_tmp5(c_IDX2_H);
  pixel_eof_rz   <= data_pipe_tmp5(c_IDX1_H);
  pixel_id_rz    <= data_pipe_tmp5(c_IDX0_H downto c_IDX0_L);

  -------------------------------------------------------------------
  -- output
  -------------------------------------------------------------------
  o_pixel_sof    <= pixel_sof_rz;
  o_pixel_eof    <= pixel_eof_rz;
  o_pixel_valid  <= pixel_valid_rz;
  o_pixel_id     <= pixel_id_rz;
  o_pixel_result <= result_rz;

  ---------------------------------------------------------------------
  -- Error latching
  ---------------------------------------------------------------------
  error_tmp(1) <= mux_squid_tf_error;
  error_tmp(0) <= mux_squid_offset_error;
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

  o_errors(15 downto 2) <= (others => '0');
  o_errors(1)           <= error_tmp_bis(1);
  o_errors(0)           <= error_tmp_bis(0);

  o_status <= (others => '0');

end architecture RTL;
