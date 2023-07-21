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
--    @file                   amp_squid.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This module performs the following amp_squid computation steps:
--      . addr = i_pixel_result - i_amp_squid_offset_correction
--      . S0 = AMP_SQUID_TF(addr): use the addr value to read a pre-loaded RAM the corresponding value.
--      . fpagain = gain_table(i_fpasim_gain): use the i_fpasim_gain to read a pre-defined gain value
--      . o_pixel_result = S0 * fpagain
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_fpasim.all;

entity amp_squid is
  generic(
    -- pixel
    g_PIXEL_ID_WIDTH                    : positive := pkg_NB_PIXEL_BY_FRAME_MAX_WIDTH;  -- pixel id bus width (expressed in bits). Possible values [1; max integer value[
    -- addr
    g_AMP_SQUID_TF_RAM_ADDR_WIDTH       : positive := pkg_AMP_SQUID_TF_RAM_ADDR_WIDTH;  -- address bus width (expressed in bits)
    -- computation
    g_PIXEL_RESULT_INPUT_WIDTH          : positive := pkg_AMP_SQUID_SUB_Q_WIDTH_A;  -- pixel input result bus width (expressed in bits). Possible values [1; max integer value[
    g_PIXEL_RESULT_OUTPUT_WIDTH         : positive := pkg_AMP_SQUID_Q_WIDTH;  -- pixel output result bus width (expressed in bits). Possible values [1; max integer value[
    -- RAM configuration filename
    g_AMP_SQUID_TF_RAM_MEMORY_INIT_FILE : string   := pkg_AMP_SQUID_TF_RAM_MEMORY_INIT_FILE
    );
  port(
    i_clk                     : in  std_logic;  -- clock
    i_rst_status              : in  std_logic;  -- reset error flag(s)
    i_debug_pulse             : in  std_logic;  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
    ---------------------------------------------------------------------
    -- input command: from the regdecode
    ---------------------------------------------------------------------
    -- RAM: amp_squid_tf
    -- wr
    i_amp_squid_tf_wr_en      : in  std_logic;  -- ram write enable
    i_amp_squid_tf_wr_rd_addr : in  std_logic_vector(g_AMP_SQUID_TF_RAM_ADDR_WIDTH - 1 downto 0);  -- ram write/read address
    i_amp_squid_tf_wr_data    : in  std_logic_vector(15 downto 0);  -- ram write data
    -- rd
    i_amp_squid_tf_rd_en      : in  std_logic;  -- ram read enable
    o_amp_squid_tf_rd_valid   : out std_logic;  -- ram read data valid
    o_amp_squid_tf_rd_data    : out std_logic_vector(15 downto 0);  -- ram read data

    ---------------------------------------------------------------------
    -- input1
    ---------------------------------------------------------------------
    i_pixel_sof                   : in  std_logic;  -- first pixel sample
    i_pixel_eof                   : in  std_logic;  -- last pixel sample
    i_pixel_valid                 : in  std_logic;  -- valid pixel sample
    i_pixel_id                    : in  std_logic_vector(g_PIXEL_ID_WIDTH - 1 downto 0);  -- pixel id
    i_pixel_result                : in  std_logic_vector(g_PIXEL_RESULT_INPUT_WIDTH - 1 downto 0);  -- pixel result
    ---------------------------------------------------------------------
    -- input2
    ---------------------------------------------------------------------
    i_amp_squid_offset_correction : in  std_logic_vector(13 downto 0);  -- amp squid offset correction value
    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    o_pixel_sof                   : out std_logic;  -- first pixel sample
    o_pixel_eof                   : out std_logic;  -- last pixel sample
    o_pixel_valid                 : out std_logic;  -- valid pixel sample
    o_pixel_id                    : out std_logic_vector(g_PIXEL_ID_WIDTH - 1 downto 0);  -- pixel id
    o_pixel_result                : out std_logic_vector(g_PIXEL_RESULT_OUTPUT_WIDTH - 1 downto 0);  -- pixel result
    ---------------------------------------------------------------------
    -- errors/status
    ---------------------------------------------------------------------
    o_errors                      : out std_logic_vector(15 downto 0);  -- output errors
    o_status                      : out std_logic_vector(7 downto 0)  -- output status
    );
end entity amp_squid;

architecture RTL of amp_squid is

  constant c_MEMORY_SIZE_AMP_SQUID_TF : positive := (2 ** (i_amp_squid_tf_wr_rd_addr'length)) * i_amp_squid_tf_wr_data'length;  -- memory size in bits

  ---------------------------------------------------------------------
  -- compute
  --   S = i_pixel_result - i_mux_squid_feedback
  ---------------------------------------------------------------------
  -- operator input_a
  signal pixel_result_tmp          : std_logic_vector(i_pixel_result'range); -- temporary input0
  -- operator input_b
  signal amp_squid_offset_corr_tmp : std_logic_vector(pkg_AMP_SQUID_SUB_Q_WIDTH_B - 1 downto 0):= (others => '0'); -- temporary input1
  -- operator output
  signal result_sub_rx             : std_logic_vector(pkg_AMP_SQUID_SUB_Q_WIDTH_S - 1 downto 0); -- computation result

  ---------------------------------------------------------------------
  -- sync with sub_sfixed_mux_squid out
  ---------------------------------------------------------------------
  constant c_IDX0_L : integer := 0; -- index0: low
  constant c_IDX0_H : integer := c_IDX0_L + i_pixel_id'length - 1;-- index0: high

  constant c_IDX1_L : integer := c_IDX0_H + 1; -- index1: low
  constant c_IDX1_H : integer := c_IDX1_L + 1 - 1;-- index1: high

  constant c_IDX2_L : integer := c_IDX1_H + 1; -- index2: low
  constant c_IDX2_H : integer := c_IDX2_L + 1 - 1;-- index2: high

  constant c_IDX3_L : integer := c_IDX2_H + 1; -- index3: low
  constant c_IDX3_H : integer := c_IDX3_L + 1 - 1;-- index3: high

  constant c_IDX4_L : integer := c_IDX3_H + 1; -- index4: low
  constant c_IDX4_H : integer := c_IDX4_L + o_pixel_result'length - 1;-- index4: high

  signal data_pipe_tmp0 : std_logic_vector(c_IDX3_H downto 0); -- temporary input pipe signal
  signal data_pipe_tmp1 : std_logic_vector(c_IDX3_H downto 0); -- temporary output pipe signal

  signal pixel_sof_rx   : std_logic; -- first pixel sample
  signal pixel_eof_rx   : std_logic; -- last pixel samplev
  signal pixel_valid_rx : std_logic; -- valid pixel sample
  signal pixel_id_rx    : std_logic_vector(i_pixel_id'range); -- pixel id

  ---------------------------------------------------------------------
  -- mux_squid_tf
  ---------------------------------------------------------------------
  -- RAM
  signal amp_squid_tf_ena    : std_logic; -- port A: en
  signal amp_squid_tf_wea    : std_logic; -- port A: we
  signal amp_squid_tf_addra  : std_logic_vector(i_amp_squid_tf_wr_rd_addr'range); -- port A: address
  signal amp_squid_tf_dina   : std_logic_vector(i_amp_squid_tf_wr_data'range); -- port A: data in
  signal amp_squid_tf_regcea : std_logic; -- port A: regce
  signal amp_squid_tf_douta  : std_logic_vector(i_amp_squid_tf_wr_data'range); -- port A: data out

  signal amp_squid_tf_web    : std_logic; -- port B: en
  signal amp_squid_tf_enb    : std_logic; -- port B: we
  signal amp_squid_tf_addrb  : std_logic_vector(i_amp_squid_tf_wr_rd_addr'range); -- port B: address
  signal amp_squid_tf_dinb   : std_logic_vector(i_amp_squid_tf_wr_data'range); -- port B: data in
  signal amp_squid_tf_regceb : std_logic; -- port B: regce
  signal amp_squid_tf_doutb  : std_logic_vector(i_amp_squid_tf_wr_data'range); -- port B: data out

  -- sync with rd RAM output
  signal amp_squid_tf_rd_en_rw : std_logic;

  -- ram check
  signal amp_squid_tf_error : std_logic;

  ---------------------------------------------------------------------
  -- sync with the mux_squid_tf out
  ---------------------------------------------------------------------
  signal data_pipe_tmp2 : std_logic_vector(c_IDX3_H downto 0); -- temporary input pipe signal
  signal data_pipe_tmp3 : std_logic_vector(c_IDX3_H downto 0); -- temporary output pipe signal

  signal pixel_sof_ry   : std_logic; -- first pixel sample
  signal pixel_eof_ry   : std_logic; -- last pixel sample
  signal pixel_valid_ry : std_logic; -- valid pixel sample
  signal pixel_id_ry    : std_logic_vector(i_pixel_id'range); -- pixel id

  ---------------------------------------------------------------------
  -- sync with the add_sfixed_mux_squid_offset_and_tf out
  ---------------------------------------------------------------------
  signal data_pipe_tmp4 : std_logic_vector(c_IDX4_H downto 0); -- temporary input pipe signal
  signal data_pipe_tmp5 : std_logic_vector(c_IDX4_H downto 0); -- temporary output pipe signal

  signal pixel_sof_rz   : std_logic; -- first pixel sample
  signal pixel_eof_rz   : std_logic; -- last pixel sample
  signal pixel_valid_rz : std_logic; -- valid pixel sample
  signal pixel_id_rz    : std_logic_vector(i_pixel_id'range); -- pixel id
  signal result_rz        : std_logic_vector(o_pixel_result'range); -- result

  ---------------------------------------------------------------------
  -- error latching
  ---------------------------------------------------------------------
  constant c_NB_ERRORS : integer := 1;-- define the width of the temporary errors signals
  signal error_tmp     : std_logic_vector(c_NB_ERRORS - 1 downto 0); -- temporary input errors
  signal error_tmp_bis : std_logic_vector(c_NB_ERRORS - 1 downto 0); -- temporary output errors

begin

  -------------------------------------------------------------------
  -- sub_sfixed_amp_squid_out : out = pixel_result_tmp - amp_squid_offset_correction_tmp
  -- requirement: FPASIM-FW-REQ-0170 (part0)
  -------------------------------------------------------------------
  assert not ((i_pixel_result'length) /= pkg_AMP_SQUID_SUB_Q_WIDTH_A)
         report "[amp_squid]: i_pixel_result => port width and sfixed package definition width doesn't match." severity error;
  assert not ((amp_squid_offset_corr_tmp'length) < i_amp_squid_offset_correction'length)
         report "[amp_squid]: amp_squid_offset_corr_tmp'length must be >= i_amp_squid_offset_correction'length" severity error;
  -- no conversion: already sfixed
  pixel_result_tmp                <= i_pixel_result;

  -- we assume (amp_squid_offset_corr_tmp'length) >= (i_amp_squid_offset_correction'length)
  --    align the MSB bits between amp_squid_offset_corr_tmp and i_amp_squid_offset_correction (<=> amp_squid_offset_corr_tmp <= i_amp_squid_offset_correction*2)
  --     => the remaining LSB bits of amp_squid_offset_corr_tmp are fixed to '0'
  amp_squid_offset_corr_tmp(amp_squid_offset_corr_tmp'high downto (amp_squid_offset_corr_tmp'high - i_amp_squid_offset_correction'high)) <= i_amp_squid_offset_correction;

  inst_sub_sfixed_amp_squid : entity work.sub_sfixed
    generic map(
      -- port A: AMD Q notation (fixed point)
      g_Q_M_A => pkg_AMP_SQUID_SUB_Q_M_A,
      g_Q_N_A => pkg_AMP_SQUID_SUB_Q_N_A,
      -- port B: AMD Q notation (fixed point)
      g_Q_M_B => pkg_AMP_SQUID_SUB_Q_M_B,
      g_Q_N_B => pkg_AMP_SQUID_SUB_Q_N_B,
      -- port S: AMD Q notation (fixed point)
      g_Q_M_S => pkg_AMP_SQUID_SUB_Q_M_S,
      g_Q_N_S => pkg_AMP_SQUID_SUB_Q_N_S
      )
    port map(
      i_clk => i_clk,
      --------------------------------------------------------------
      -- input
      --------------------------------------------------------------
      i_a   => pixel_result_tmp,
      i_b   => amp_squid_offset_corr_tmp,
      --------------------------------------------------------------
      -- output : S = A - B
      --------------------------------------------------------------
      o_s   => result_sub_rx
      );

  -----------------------------------------------------------------
  -- sync with inst_sub_sfixed_amp_squid out
  -----------------------------------------------------------------
  data_pipe_tmp0(c_IDX3_H)                 <= i_pixel_valid;
  data_pipe_tmp0(c_IDX2_H)                 <= i_pixel_sof;
  data_pipe_tmp0(c_IDX1_H)                 <= i_pixel_eof;
  data_pipe_tmp0(c_IDX0_H downto c_IDX0_L) <= i_pixel_id;
  inst_pipeliner_sync_with_sub_sfixed_amp_squid_out : entity work.pipeliner
    generic map(
      g_NB_PIPES   => pkg_AMP_SQUID_SUB_LATENCY,  -- number of consecutives registers. Possibles values: [0, integer max value[
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
  -- RAM: amp_squid_tf
  -- requirement: FPASIM-FW-REQ-0170 (part1)
  ---------------------------------------------------------------------
  amp_squid_tf_ena   <= i_amp_squid_tf_wr_en or i_amp_squid_tf_rd_en;
  amp_squid_tf_wea   <= i_amp_squid_tf_wr_en;
  amp_squid_tf_addra <= i_amp_squid_tf_wr_rd_addr;
  amp_squid_tf_dina  <= i_amp_squid_tf_wr_data;

  amp_squid_tf_regcea <= '1';

  inst_tdpram_amp_squid_tf : entity work.tdpram
    generic map(
      -- port A
      g_ADDR_WIDTH_A       => amp_squid_tf_addra'length,
      g_BYTE_WRITE_WIDTH_A => amp_squid_tf_dina'length,
      g_WRITE_DATA_WIDTH_A => amp_squid_tf_dina'length,
      g_WRITE_MODE_A       => "no_change",
      g_READ_DATA_WIDTH_A  => amp_squid_tf_dina'length,
      g_READ_LATENCY_A     => pkg_AMP_SQUID_TF_RAM_A_RD_LATENCY,
      -- port B
      g_ADDR_WIDTH_B       => amp_squid_tf_addra'length,
      g_BYTE_WRITE_WIDTH_B => amp_squid_tf_dina'length,
      g_WRITE_DATA_WIDTH_B => amp_squid_tf_dina'length,
      g_WRITE_MODE_B       => "no_change",
      g_READ_DATA_WIDTH_B  => amp_squid_tf_dina'length,
      g_READ_LATENCY_B     => pkg_AMP_SQUID_TF_RAM_B_RD_LATENCY,
      -- others
      g_CLOCKING_MODE      => "common_clock",
      g_MEMORY_PRIMITIVE   => "block",
      g_MEMORY_SIZE        => c_MEMORY_SIZE_AMP_SQUID_TF,
      g_MEMORY_INIT_FILE   => g_AMP_SQUID_TF_RAM_MEMORY_INIT_FILE,
      g_MEMORY_INIT_PARAM  => ""
      )
    port map(
      ---------------------------------------------------------------------
      -- port A
      ---------------------------------------------------------------------
      i_rsta   => '0',
      i_clka   => i_clk,
      i_ena    => amp_squid_tf_ena,
      i_wea(0) => amp_squid_tf_wea,
      i_addra  => amp_squid_tf_addra,
      i_dina   => amp_squid_tf_dina,
      i_regcea => amp_squid_tf_regcea,
      o_douta  => amp_squid_tf_douta,
      ---------------------------------------------------------------------
      -- port B
      ---------------------------------------------------------------------
      i_rstb   => '0',
      i_clkb   => i_clk,
      i_web(0) => amp_squid_tf_web,
      i_enb    => amp_squid_tf_enb,
      i_addrb  => amp_squid_tf_addrb,
      i_dinb   => amp_squid_tf_dinb,
      i_regceb => amp_squid_tf_regceb,
      o_doutb  => amp_squid_tf_doutb
      );
  amp_squid_tf_web    <= '0';
  amp_squid_tf_dinb   <= (others => '0');
  amp_squid_tf_enb    <= pixel_valid_rx;
  amp_squid_tf_addrb  <= result_sub_rx;
  amp_squid_tf_regceb <= '1';

  -------------------------------------------------------------------
  -- sync with rd RAM output
  -------------------------------------------------------------------
  inst_pipeliner_sync_with_tdpram_amp_squid_tf_outa : entity work.pipeliner
    generic map(
      g_NB_PIPES   => pkg_AMP_SQUID_TF_RAM_A_RD_LATENCY,  -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => 1  -- width of the input/output data.  Possibles values: [1, integer max value[
      )
    port map(
      i_clk     => i_clk,               -- clock signal
      i_data(0) => i_amp_squid_tf_rd_en,  -- input data
      o_data(0) => amp_squid_tf_rd_en_rw  -- output data with/without delay
      );
  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_amp_squid_tf_rd_valid <= amp_squid_tf_rd_en_rw;
  o_amp_squid_tf_rd_data  <= amp_squid_tf_douta;

  ---------------------------------------------------------------------
  -- ram check
  ---------------------------------------------------------------------
  inst_ram_check_sdpram_amp_squid_tf : entity work.ram_check
    generic map(
      g_WR_ADDR_WIDTH => amp_squid_tf_addra'length,
      g_RD_ADDR_WIDTH => amp_squid_tf_addrb'length
      )
    port map(
      i_clk         => i_clk,
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_wr          => amp_squid_tf_wea,
      i_wr_addr     => amp_squid_tf_addra,
      i_rd          => amp_squid_tf_enb,
      i_rd_addr     => amp_squid_tf_addrb,
      ---------------------------------------------------------------------
      -- Errors
      ---------------------------------------------------------------------
      o_error_pulse => amp_squid_tf_error
      );

  -----------------------------------------------------------------
  -- sync with inst_sdpram_mux_squid_tf out
  -----------------------------------------------------------------
  data_pipe_tmp2(c_IDX3_H)                 <= pixel_valid_rx;
  data_pipe_tmp2(c_IDX2_H)                 <= pixel_sof_rx;
  data_pipe_tmp2(c_IDX1_H)                 <= pixel_eof_rx;
  data_pipe_tmp2(c_IDX0_H downto c_IDX0_L) <= pixel_id_rx;
  inst_pipeliner_sync_with_sdpram_amp_squid_tf_out : entity work.pipeliner
    generic map(
      g_NB_PIPES   => pkg_AMP_SQUID_TF_RAM_B_RD_LATENCY,  -- number of consecutives registers. Possibles values: [0, integer max value[
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
  -- sync with inst_add_sfixed_mux_squid_offset_and_tf out
  -----------------------------------------------------------------
  data_pipe_tmp4(c_IDX4_H downto c_IDX4_L) <= amp_squid_tf_doutb;
  data_pipe_tmp4(c_IDX3_H)                 <= pixel_valid_ry;
  data_pipe_tmp4(c_IDX2_H)                 <= pixel_sof_ry;
  data_pipe_tmp4(c_IDX1_H)                 <= pixel_eof_ry;
  data_pipe_tmp4(c_IDX0_H downto c_IDX0_L) <= pixel_id_ry;
  inst_pipeliner_optionnal_output_pipe : entity work.pipeliner
    generic map(
      g_NB_PIPES   => pkg_AMP_SQUID_OUT_LATENCY,  -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => data_pipe_tmp4'length  -- width of the input/output data.  Possibles values: [1, integer max value[
      )
    port map(
      i_clk  => i_clk,                  -- clock signal
      i_data => data_pipe_tmp4,         -- input data
      o_data => data_pipe_tmp5          -- output data with/without delay
      );

  result_rz      <= data_pipe_tmp5(c_IDX4_H downto c_IDX4_L);
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
  error_tmp(0) <= amp_squid_tf_error;
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

  o_errors(15 downto 1) <= (others => '0');
  o_errors(0)           <= error_tmp_bis(0);

  o_status(7 downto 0) <= (others => '0');

  ---------------------------------------------------------------------
  -- for simulation only
  ---------------------------------------------------------------------
  assert not (error_tmp_bis(0) = '1') report "[amp_squid] => amp_squid_tf ram: wrong access" severity error;

end architecture RTL;
