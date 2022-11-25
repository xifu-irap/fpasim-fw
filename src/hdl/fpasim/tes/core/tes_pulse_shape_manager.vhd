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
--!   @file                   tes_pulse_shape_manager.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--
-- From a user-defined command, this module tracks the computation history of the associated pixel.
-- With one state machine and a mechanism of parameters' table, the module can simulate nb_pixel independent state machine (one by pixel).
-- if a previous command was received for the current pixel, this module performs the following tes computation steps:
--   . computation of the addr0
--      . at t=0: addr0 = i_cmd_time_shift
--      . at t/=0: addr0 = addr0 + time_shift_max (until all pulse_shape sample was processed)
--   . pulse_shape = TES_PULSE_SHAPE(addr0): use the addr value to read a pre-loaded RAM
--   . addr1 = i_pixel_id
--   . steady_state =  TES_STD_STATE(addr1): use the addr value to read a pre-loaded RAM
--   . o_pixel_result = steady_state - (pulse_shape * i_cmd_pulse_height)
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fpasim;
use fpasim.pkg_fpasim.all;
use fpasim.pkg_regdecode.all;

entity tes_pulse_shape_manager is
  generic(
    -- command
    g_CMD_PULSE_HEIGHT_WIDTH     : positive := pkg_MAKE_PULSE_PULSE_HEIGHT_WIDTH; -- pulse_heigth bus width (expressed in bits). Possible values [1;max integer value[
    g_CMD_TIME_SHIFT_WIDTH       : positive := pkg_MAKE_PULSE_TIME_SHIFT_WIDTH; -- time_shift bus width (expressed in bits). Possible values [1;max integer value[
    g_CMD_PIXEL_ID_WIDTH         : positive := pkg_MAKE_PULSE_PIXEL_ID_WIDTH; -- pixel id bus width (expressed in bits). Possible values : [1; max integer value[
    -- frame
    g_NB_FRAME_BY_PULSE_SHAPE    : positive := pkg_NB_FRAME_BY_PULSE_SHAPE;
    g_NB_SAMPLE_BY_FRAME_WIDTH   : positive := pkg_NB_SAMPLE_BY_FRAME_WIDTH; -- frame bus width (expressed in bits). Possible values : [1; max integer value[
    -- pixel
    g_NB_PIXEL_BY_FRAME_MAX       : positive := pkg_NB_PIXEL_BY_FRAME_MAX; -- number max of pixel by frame authorised by the design
    -- addr
    g_PULSE_SHAPE_RAM_ADDR_WIDTH : positive := pkg_TES_PULSE_SHAPE_RAM_ADDR_WIDTH; -- address bus width (expressed in bits)
    -- output 
    g_PIXEL_RESULT_OUTPUT_WIDTH  : positive := pkg_TES_MULT_SUB_Q_WIDTH_S -- pixel output result width (expressed in bits). Possible values : [1; max integer value[
  );
  port(
    i_clk                     : in  std_logic; -- clock 
    i_rst                     : in  std_logic; -- reset 
    i_rst_status              : in  std_logic; -- reset error flag(s)
    i_debug_pulse             : in  std_logic; -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)

    ---------------------------------------------------------------------
    -- input command: from the regdecode
    ---------------------------------------------------------------------
    i_cmd_valid               : in  std_logic; -- valid command
    i_cmd_pulse_height        : in  std_logic_vector(g_CMD_PULSE_HEIGHT_WIDTH - 1 downto 0); -- pulse height command
    i_cmd_pixel_id            : in  std_logic_vector(g_CMD_PIXEL_ID_WIDTH - 1 downto 0); -- pixel id command
    i_cmd_time_shift          : in  std_logic_vector(g_CMD_TIME_SHIFT_WIDTH - 1 downto 0); -- time shift command
    o_cmd_ready               : out std_logic;
    -- RAM: pulse shape
    -- wr
    i_pulse_shape_wr_en       : in  std_logic; -- write enable
    i_pulse_shape_wr_rd_addr  : in  std_logic_vector(g_PULSE_SHAPE_RAM_ADDR_WIDTH - 1 downto 0); -- write address
    i_pulse_shape_wr_data     : in  std_logic_vector(15 downto 0); -- write data
    -- rd
    i_pulse_shape_rd_en       : in  std_logic; -- rd enable
    o_pulse_shape_rd_valid    : out std_logic; -- rd data valid
    o_pulse_shape_rd_data     : out std_logic_vector(15 downto 0); -- rd data

    -- RAM:
    -- wr
    i_steady_state_wr_en      : in  std_logic; -- write enable
    i_steady_state_wr_rd_addr : in  std_logic_vector(g_CMD_PIXEL_ID_WIDTH - 1 downto 0); -- write address
    i_steady_state_wr_data    : in  std_logic_vector(15 downto 0); -- write data
    -- rd
    i_steady_state_rd_en      : in  std_logic; -- rd enable
    o_steady_state_rd_valid   : out std_logic; -- rd data valid
    o_steady_state_rd_data    : out std_logic_vector(15 downto 0); -- read data

    ---------------------------------------------------------------------
    -- input data
    ---------------------------------------------------------------------
    i_pixel_sof               : in  std_logic; -- first pixel sample
    i_pixel_eof               : in  std_logic; -- last pixel sample
    i_pixel_id                : in  std_logic_vector(g_CMD_PIXEL_ID_WIDTH - 1 downto 0); -- pixel id 
    i_pixel_valid             : in  std_logic; -- valid pixel sample

    ---------------------------------------------------------------------
    -- output data
    ---------------------------------------------------------------------
    o_pixel_sof               : out std_logic; -- first pixel sample
    o_pixel_eof               : out std_logic; -- last pixel sample
    o_pixel_id                : out std_logic_vector(g_CMD_PIXEL_ID_WIDTH - 1 downto 0); -- pixel id
    o_pixel_valid             : out std_logic; -- valid pixel result
    o_pixel_result            : out std_logic_vector(g_PIXEL_RESULT_OUTPUT_WIDTH - 1 downto 0); -- pixel result

    -----------------------------------------------------------------
    -- errors/status
    -----------------------------------------------------------------
    o_errors                  : out std_logic_vector(15 downto 0); -- output errors
    o_status                  : out std_logic_vector(7 downto 0) -- output status
  );
end entity tes_pulse_shape_manager;

architecture RTL of tes_pulse_shape_manager is
  constant c_NB_FRAME_BY_PULSE_SHAPE : positive := g_NB_FRAME_BY_PULSE_SHAPE;
  constant c_NB_PIXEL_BY_FRAME_MAX   : positive := g_NB_PIXEL_BY_FRAME_MAX;

  constant c_SHIFT_MAX : positive := 2 ** (i_cmd_time_shift'length);

  constant c_TES_PULSE_SHAPE_RAM_A_RD_LATENCY : natural := pkg_TES_PULSE_SHAPE_RAM_A_RD_LATENCY;
  constant c_TES_PULSE_SHAPE_RAM_B_RD_LATENCY : natural := pkg_TES_PULSE_SHAPE_RAM_B_RD_LATENCY;

  constant c_TES_STD_STATE_RAM_A_RD_LATENCY : natural := pkg_TES_STD_STATE_RAM_A_RD_LATENCY;
  constant c_TES_STD_STATE_RAM_B_RD_LATENCY : natural := pkg_TES_STD_STATE_RAM_B_RD_LATENCY;

  constant c_MEMORY_SIZE_PULSE_SHAPE  : positive := (2 ** i_pulse_shape_wr_rd_addr'length) * i_pulse_shape_wr_data'length; -- memory size in bits
  constant c_MEMORY_SIZE_STEADY_STATE : positive := (2 ** i_steady_state_wr_rd_addr'length) * i_steady_state_wr_data'length; -- memory size in bits

  constant c_COMPUTATION_LATENCY : natural := pkg_TES_PULSE_MANAGER_COMPUTATION_LATENCY;

  constant c_TES_MULT_SUB_Q_WIDTH_A : positive := pkg_TES_MULT_SUB_Q_WIDTH_A;
  constant c_TES_MULT_SUB_Q_WIDTH_B : positive := pkg_TES_MULT_SUB_Q_WIDTH_B;
  constant c_TES_MULT_SUB_Q_WIDTH_C : positive := pkg_TES_MULT_SUB_Q_WIDTH_C;
  constant c_TES_MULT_SUB_Q_WIDTH_S : positive := pkg_TES_MULT_SUB_Q_WIDTH_S;

  constant c_MULT_ADD_UFIXED_LATENCY : natural := pkg_MULT_ADD_UFIXED_LATENCY;

  -- add 1 bit to the i_cmd_time_shift length to be able to represente the c_SHIFT_MAX value
  constant c_SHIFT_MAX_VECTOR : std_logic_vector(i_cmd_time_shift'length downto 0) := std_logic_vector(to_unsigned(c_SHIFT_MAX, i_cmd_time_shift'length + 1));

  ---------------------------------------------------------------------
  -- FIFO cmd
  ---------------------------------------------------------------------
  constant c_CMD_IDX0_L : integer := 0;
  constant c_CMD_IDX0_H : integer := c_CMD_IDX0_L + i_cmd_time_shift'length - 1;

  constant c_CMD_IDX1_L : integer := c_CMD_IDX0_H + 1;
  constant c_CMD_IDX1_H : integer := c_CMD_IDX1_L + i_cmd_pixel_id'length - 1;

  constant c_CMD_IDX2_L : integer := c_CMD_IDX1_H + 1;
  constant c_CMD_IDX2_H : integer := c_CMD_IDX2_L + i_cmd_pulse_height'length - 1;

  -- find the power of 2 superior to the g_DELAY
  --constant c_FIFO_DEPTH0  : integer := c_PIXEL_NB_MAX; 
  constant c_FIFO_DEPTH0    : integer := 16; --see IP
  constant c_FIFO_PROG_FULL : integer := c_FIFO_DEPTH0 - 5; --see IP
  constant c_FIFO_WIDTH0    : integer := c_CMD_IDX2_H + 1; --see IP

  signal wr_tmp0    : std_logic;
  signal data_tmp0  : std_logic_vector(c_FIFO_WIDTH0 - 1 downto 0);
  -- signal full0        : std_logic;
  signal prog_full0 : std_logic;
  -- signal wr_rst_busy0 : std_logic;

  signal rd1       : std_logic;
  signal data_tmp1 : std_logic_vector(c_FIFO_WIDTH0 - 1 downto 0);
  signal empty1    : std_logic;
  -- signal rd_rst_busy1 : std_logic;

  signal cmd_pulse_height1 : std_logic_vector(i_cmd_pulse_height'range);
  signal cmd_pixel_id1     : std_logic_vector(i_cmd_pixel_id'range);
  signal cmd_time_shift1   : std_logic_vector(i_cmd_time_shift'range);

  signal errors_sync : std_logic_vector(3 downto 0);
  signal empty_sync  : std_logic;

  signal cmd_ready_r1 : std_logic := '0';

  ---------------------------------------------------------------------
  -- State machine
  ---------------------------------------------------------------------
  type t_addr_pulse_shape_array is array (0 to c_NB_PIXEL_BY_FRAME_MAX - 1) of unsigned(g_NB_SAMPLE_BY_FRAME_WIDTH - 1 downto 0);
  type t_pulse_height_array is array (0 to c_NB_PIXEL_BY_FRAME_MAX - 1) of unsigned(i_cmd_pulse_height'range);
  type t_time_shift_array is array (0 to c_NB_PIXEL_BY_FRAME_MAX - 1) of unsigned(i_cmd_time_shift'range);

  type t_state is (E_RST, E_WAIT, E_RUN);
  signal sm_state_next : t_state;
  signal sm_state_r1   : t_state := E_RST;

  signal cmd_rd_next : std_logic;
  signal cmd_rd_r1   : std_logic := '0';

  signal cnt_sample_pulse_shape_next : unsigned(g_NB_SAMPLE_BY_FRAME_WIDTH - 1 downto 0);
  signal cnt_sample_pulse_shape_r1   : unsigned(g_NB_SAMPLE_BY_FRAME_WIDTH - 1 downto 0) := (others => '0');

  signal cnt_sample_pulse_shape_table_next : t_addr_pulse_shape_array;
  signal cnt_sample_pulse_shape_table_r1   : t_addr_pulse_shape_array := (others => (others => '0'));

  signal en_table_next : std_logic_vector(c_NB_PIXEL_BY_FRAME_MAX - 1 downto 0);
  signal en_table_r1   : std_logic_vector(c_NB_PIXEL_BY_FRAME_MAX - 1 downto 0) := (others => '0');

  signal pulse_heigth_next : unsigned(i_cmd_pulse_height'range);
  signal pulse_heigth_r1   : unsigned(i_cmd_pulse_height'range) := (others => '0');

  signal pulse_heigth_table_next : t_pulse_height_array;
  signal pulse_heigth_table_r1   : t_pulse_height_array := (others => (others => '0'));

  signal time_shift_next : unsigned(i_cmd_time_shift'range);
  signal time_shift_r1   : unsigned(i_cmd_time_shift'range) := (others => '0');

  signal time_shift_table_next : t_time_shift_array;
  signal time_shift_table_r1   : t_time_shift_array := (others => (others => '0'));

  signal en_next : std_logic;
  signal en_r1   : std_logic := '0';

  signal pixel_valid_next : std_logic;
  signal pixel_valid_r1   : std_logic := '0';

  -------------------------------------------------------------------
  -- compute pipe indexes
  --   Note: shared by more than 1 pipeliner
  -------------------------------------------------------------------
  constant c_IDX0_L : integer := 0;
  constant c_IDX0_H : integer := c_IDX0_L + i_pixel_id'length - 1;

  constant c_IDX1_L : integer := c_IDX0_H + 1;
  constant c_IDX1_H : integer := c_IDX1_L + 1 - 1;

  constant c_IDX2_L : integer := c_IDX1_H + 1;
  constant c_IDX2_H : integer := c_IDX2_L + 1 - 1;

  constant c_IDX3_L : integer := c_IDX2_H + 1;
  constant c_IDX3_H : integer := c_IDX3_L + 1 - 1;

  constant c_IDX4_L : integer := c_IDX3_H + 1;
  constant c_IDX4_H : integer := c_IDX4_L + i_cmd_pulse_height'length - 1;

  ---------------------------------------------------------------------
  -- sync with the address computation output
  ---------------------------------------------------------------------
  signal data_pipe_tmp0 : std_logic_vector(c_IDX2_H downto 0);
  signal data_pipe_tmp1 : std_logic_vector(c_IDX2_H downto 0);

  signal pixel_sof_rc : std_logic;
  signal pixel_eof_rc : std_logic;
  signal pixel_id_rc  : std_logic_vector(i_pixel_id'range);

  signal pulse_heigth_rc : std_logic_vector(i_cmd_pulse_height'range);

  -- address computation
  signal pixel_valid_rc      : std_logic;
  signal addr_pulse_shape_rc : std_logic_vector(i_pulse_shape_wr_rd_addr'range);

  constant c_MULT_IDX0_L : integer := 0;
  constant c_MULT_IDX0_H : integer := c_MULT_IDX0_L + i_cmd_pulse_height'length - 1;

  constant c_MULT_IDX1_L : integer := c_MULT_IDX0_H + 1;
  constant c_MULT_IDX1_H : integer := c_MULT_IDX1_L + 1 - 1;

  signal data_pipe_mult_tmp0 : std_logic_vector(c_MULT_IDX1_H downto 0);
  signal data_pipe_mult_tmp1 : std_logic_vector(c_MULT_IDX1_H downto 0);

  ---------------------------------------------------------------------
  -- tes_pulse_shape
  ---------------------------------------------------------------------
  -- RAM
  signal pulse_shape_wea    : std_logic;
  signal pulse_shape_ena    : std_logic;
  signal pulse_shape_addra  : std_logic_vector(i_pulse_shape_wr_rd_addr'range);
  signal pulse_shape_dina   : std_logic_vector(i_pulse_shape_wr_data'range);
  signal pulse_shape_regcea : std_logic;
  signal pulse_shape_douta  : std_logic_vector(i_pulse_shape_wr_data'range);

  signal pulse_shape_enb    : std_logic;
  signal pulse_shape_web    : std_logic;
  signal pulse_shape_addrb  : std_logic_vector(i_pulse_shape_wr_rd_addr'range);
  signal pulse_shape_dinb   : std_logic_vector(i_pulse_shape_wr_data'range);
  signal pulse_shape_regceb : std_logic;
  signal pulse_shape_doutb  : std_logic_vector(i_pulse_shape_wr_data'range);

  -- sync with rd RAM output
  signal pulse_shape_rd_en_rz : std_logic;
  -- ram check
  signal pulse_shape_error    : std_logic;

  ---------------------------------------------------------------------
  -- tes_pulse_shape
  ---------------------------------------------------------------------
  -- RAM
  signal steady_state_wea    : std_logic;
  signal steady_state_ena    : std_logic;
  signal steady_state_addra  : std_logic_vector(i_steady_state_wr_rd_addr'range);
  signal steady_state_dina   : std_logic_vector(i_steady_state_wr_data'range);
  signal steady_state_regcea : std_logic;
  signal steady_state_douta  : std_logic_vector(i_steady_state_wr_data'range);

  signal steady_state_enb    : std_logic;
  signal steady_state_web    : std_logic;
  signal steady_state_addrb  : std_logic_vector(i_steady_state_wr_rd_addr'range);
  signal steady_state_dinb   : std_logic_vector(i_steady_state_wr_data'range);
  signal steady_state_regceb : std_logic;
  signal steady_state_doutb  : std_logic_vector(i_steady_state_wr_data'range);

  -- sync with rd RAM output
  signal steady_state_rd_en_rz : std_logic;
  -- ram check
  signal steady_state_error    : std_logic;

  ---------------------------------------------------------------------
  -- sync with RAM outputs
  ---------------------------------------------------------------------
  signal data_pipe_tmp2 : std_logic_vector(c_IDX4_H downto 0);
  signal data_pipe_tmp3 : std_logic_vector(c_IDX4_H downto 0);

  signal pixel_sof_rx   : std_logic;
  signal pixel_eof_rx   : std_logic;
  signal pixel_valid_rx : std_logic;
  signal pixel_id_rx    : std_logic_vector(i_pixel_id'range);

  signal pulse_heigth_rx : std_logic_vector(i_cmd_pulse_height'range);

  ------------------------------------------------------------------
  -- mult_sub_sfixed
  ------------------------------------------------------------------
  -- add sign bit
  signal pulse_shape_tmp  : std_logic_vector(c_TES_MULT_SUB_Q_WIDTH_A - 1 downto 0);
  signal pulse_heigth_tmp : std_logic_vector(c_TES_MULT_SUB_Q_WIDTH_B - 1 downto 0);
  signal steady_state_tmp : std_logic_vector(c_TES_MULT_SUB_Q_WIDTH_C - 1 downto 0);

  signal result_ry : std_logic_vector(o_pixel_result'range);

  -------------------------------------------------------------------
  -- sync with tes_pulse_shape_manager_computation out
  -------------------------------------------------------------------
  signal data_pipe_tmp4 : std_logic_vector(c_IDX3_H downto 0);
  signal data_pipe_tmp5 : std_logic_vector(c_IDX3_H downto 0);
  signal pixel_sof_ry   : std_logic;
  signal pixel_eof_ry   : std_logic;
  signal pixel_valid_ry : std_logic;
  signal pixel_id_ry    : std_logic_vector(i_pixel_id'range);

  ---------------------------------------------------------------------
  -- error latching
  ---------------------------------------------------------------------
  constant NB_ERRORS_c : integer := 5;
  signal error_tmp     : std_logic_vector(NB_ERRORS_c - 1 downto 0);
  signal error_tmp_bis : std_logic_vector(NB_ERRORS_c - 1 downto 0);

begin

  ---------------------------------------------------------------------
  -- commands
  ---------------------------------------------------------------------
  wr_tmp0                                     <= i_cmd_valid;
  data_tmp0(c_CMD_IDX2_H downto c_CMD_IDX2_L) <= i_cmd_pulse_height;
  data_tmp0(c_CMD_IDX1_H downto c_CMD_IDX1_L) <= i_cmd_pixel_id;
  data_tmp0(c_CMD_IDX0_H downto c_CMD_IDX0_L) <= i_cmd_time_shift;

  inst_fifo_sync_with_error_prog_full_cmd : entity fpasim.fifo_sync_with_error_prog_full
    generic map(
      g_FIFO_MEMORY_TYPE  => "distributed",
      g_FIFO_READ_LATENCY => 1,
      g_FIFO_WRITE_DEPTH  => c_FIFO_DEPTH0,
      g_PROG_FULL_THRESH  => c_FIFO_PROG_FULL,
      g_READ_DATA_WIDTH   => data_tmp0'length,
      g_READ_MODE         => "fwft",
      g_WRITE_DATA_WIDTH  => data_tmp0'length
    )
    port map(
      ---------------------------------------------------------------------
      -- write side
      ---------------------------------------------------------------------
      i_wr_clk        => i_clk,
      i_wr_rst        => i_rst,
      i_wr_en         => wr_tmp0,
      i_wr_din        => data_tmp0,
      o_wr_full       => open,
      o_wr_prog_full  => prog_full0,
      o_wr_rst_busy   => open,
      ---------------------------------------------------------------------
      -- port B
      ---------------------------------------------------------------------
      i_rd_en         => rd1,
      o_rd_dout_valid => open,
      o_rd_dout       => data_tmp1,
      o_rd_empty      => empty1,
      o_rd_rst_busy   => open,
      ---------------------------------------------------------------------
      --  errors/status 
      ---------------------------------------------------------------------
      o_errors_sync   => errors_sync,
      o_empty_sync    => empty_sync
    );
  rd1 <= cmd_rd_r1;

  p_prog_full : process(i_clk)
  begin
    if rising_edge(i_clk) then
      cmd_ready_r1 <= not (prog_full0);
    end if;
  end process p_prog_full;
  o_cmd_ready <= cmd_ready_r1;

  cmd_pulse_height1 <= data_tmp1(c_CMD_IDX2_H downto c_CMD_IDX2_L);
  cmd_pixel_id1     <= data_tmp1(c_CMD_IDX1_H downto c_CMD_IDX1_L);
  cmd_time_shift1   <= data_tmp1(c_CMD_IDX0_H downto c_CMD_IDX0_L);

  ---------------------------------------------------------------------
  -- state machine
  ---------------------------------------------------------------------
  p_decode_state : process(cnt_sample_pulse_shape_r1, cmd_pixel_id1, cmd_pulse_height1, cmd_time_shift1, cnt_sample_pulse_shape_table_r1, empty1, en_r1, en_table_r1, sm_state_r1, i_pixel_eof, i_pixel_id, i_pixel_sof, i_pixel_valid, pulse_heigth_r1, pulse_heigth_table_r1, time_shift_r1, time_shift_table_r1) is
  begin
    cmd_rd_next                       <= '0';
    cnt_sample_pulse_shape_table_next <= cnt_sample_pulse_shape_table_r1;
    cnt_sample_pulse_shape_next       <= cnt_sample_pulse_shape_r1;
    en_table_next                     <= en_table_r1;
    en_next                           <= en_r1;

    pulse_heigth_next       <= pulse_heigth_r1;
    pulse_heigth_table_next <= pulse_heigth_table_r1;
    time_shift_next         <= time_shift_r1;
    time_shift_table_next   <= time_shift_table_r1;
    pixel_valid_next        <= '0';

    case sm_state_r1 is
      when E_RST =>
        en_table_next                     <= (others => '0');
        cnt_sample_pulse_shape_table_next <= (others => (others => '0'));
        pulse_heigth_table_next           <= (others => (others => '0'));
        time_shift_table_next             <= (others => (others => '0'));
        sm_state_next                     <= E_WAIT;

      when E_WAIT =>
        pixel_valid_next <= i_pixel_valid;
        if i_pixel_sof = '1' and i_pixel_valid = '1' then
          if (empty1 = '0') and (unsigned(cmd_pixel_id1) = unsigned(i_pixel_id)) then
            cmd_rd_next       <= '1';
            -- addr_pulse_shape to update
            en_next           <= '1';
            pulse_heigth_next <= unsigned(cmd_pulse_height1);
            time_shift_next   <= unsigned(cmd_time_shift1);
          else
            cmd_rd_next       <= '0';
            en_next           <= en_table_r1(to_integer(unsigned(i_pixel_id)));
            pulse_heigth_next <= pulse_heigth_table_r1(to_integer(unsigned(i_pixel_id)));
            time_shift_next   <= time_shift_table_r1(to_integer(unsigned(i_pixel_id)));
          end if;
          cnt_sample_pulse_shape_next <= cnt_sample_pulse_shape_table_r1(to_integer(unsigned(i_pixel_id)));
          sm_state_next               <= E_RUN;
        else
          sm_state_next <= E_WAIT;
        end if;

      when E_RUN =>
        pixel_valid_next <= i_pixel_valid;
        if i_pixel_eof = '1' and i_pixel_valid = '1' then
          if cnt_sample_pulse_shape_r1 = to_unsigned(c_NB_FRAME_BY_PULSE_SHAPE - 1, cnt_sample_pulse_shape_r1'length) then
            -- last samples of the pulse shape
            --  => disable the pixel
            --      => init the cnt_sample of the pulse shape ram
            cnt_sample_pulse_shape_table_next(to_integer(unsigned(i_pixel_id))) <= (others => '0');

            if en_r1 = '1' then
              -- disable this pixel update
              en_table_next(to_integer(unsigned(i_pixel_id)))           <= '0';
              -- zeroed the pulse shape contribution for this pixel
              pulse_heigth_table_next(to_integer(unsigned(i_pixel_id))) <= (others => '0');
            end if;
          else
            en_table_next(to_integer(unsigned(i_pixel_id)))                     <= en_r1;
            time_shift_table_next(to_integer(unsigned(i_pixel_id)))             <= time_shift_r1;
            pulse_heigth_table_next(to_integer(unsigned(i_pixel_id)))           <= pulse_heigth_r1;
            cnt_sample_pulse_shape_table_next(to_integer(unsigned(i_pixel_id))) <= cnt_sample_pulse_shape_r1 + 1;
          end if;
          sm_state_next <= E_WAIT;
        else
          sm_state_next <= E_RUN;
        end if;

      when others =>                    -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
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
      cmd_rd_r1                       <= cmd_rd_next;
      cnt_sample_pulse_shape_table_r1 <= cnt_sample_pulse_shape_table_next;
      cnt_sample_pulse_shape_r1       <= cnt_sample_pulse_shape_next;
      en_table_r1                     <= en_table_next;
      en_r1                           <= en_next;
      pulse_heigth_r1                 <= pulse_heigth_next;
      pulse_heigth_table_r1           <= pulse_heigth_table_next;
      time_shift_r1                   <= time_shift_next;
      time_shift_table_r1             <= time_shift_table_next;
      pixel_valid_r1                  <= pixel_valid_next;
    end if;
  end process p_state;

  ---------------------------------------------------------------------
  -- compute the tes_pulse_shape ram addr
  -- if the frame_size = 2048 and the step = max_shift = 16
  --  => addr_pulse_shape_rc = i*step + pixel_shift with i=[0,2047]
  ---------------------------------------------------------------------

  data_pipe_mult_tmp0(c_MULT_IDX1_H)                      <= pixel_valid_r1;
  data_pipe_mult_tmp0(c_MULT_IDX0_H downto c_MULT_IDX0_L) <= std_logic_vector(pulse_heigth_r1);
  inst_pipeliner_sync_with_mult_add_ufixed_out0 : entity fpasim.pipeliner
    generic map(
      g_NB_PIPES   => c_MULT_ADD_UFIXED_LATENCY,
      g_DATA_WIDTH => data_pipe_mult_tmp0'length
    )
    port map(
      i_clk  => i_clk,
      i_data => data_pipe_mult_tmp0,
      o_data => data_pipe_mult_tmp1
    );

  pixel_valid_rc  <= data_pipe_mult_tmp1(c_MULT_IDX1_H);
  pulse_heigth_rc <= data_pipe_mult_tmp1(c_MULT_IDX0_H downto c_MULT_IDX0_L);

  inst_mult_add_ufixed : entity fpasim.mult_add_ufixed
    generic map(
      -- port A: AMD Q notation (fixed point)
      g_UQ_M_A => cnt_sample_pulse_shape_r1'length,
      g_UQ_N_A => 0,
      -- port B: AMD Q notation (fixed point)
      g_UQ_M_B => c_SHIFT_MAX_VECTOR'length,
      g_UQ_N_B => 0,
      -- port C: AMC Q notation (fixed point)
      g_UQ_M_C => time_shift_r1'length,
      g_UQ_N_C => 0,
      -- port S: AMD Q notation (fixed point)
      g_UQ_M_S => addr_pulse_shape_rc'length,
      g_UQ_N_S => 0
    )
    port map(
      i_clk => i_clk,
      --------------------------------------------------------------
      -- input
      --------------------------------------------------------------
      i_a   => std_logic_vector(cnt_sample_pulse_shape_r1),
      i_b   => c_SHIFT_MAX_VECTOR,
      i_c   => std_logic_vector(time_shift_r1),
      --------------------------------------------------------------
      -- output : S = C + A*B
      --------------------------------------------------------------
      o_s   => addr_pulse_shape_rc
    );

  data_pipe_tmp0(c_IDX2_H)                 <= i_pixel_sof;
  data_pipe_tmp0(c_IDX1_H)                 <= i_pixel_eof;
  data_pipe_tmp0(c_IDX0_H downto c_IDX0_L) <= i_pixel_id;
  inst_pipeliner_sync_with_mult_add_ufixed_out1 : entity fpasim.pipeliner
    generic map(
      g_NB_PIPES   => c_MULT_ADD_UFIXED_LATENCY + 1,
      g_DATA_WIDTH => data_pipe_tmp0'length
    )
    port map(
      i_clk  => i_clk,
      i_data => data_pipe_tmp0,
      o_data => data_pipe_tmp1
    );

  pixel_sof_rc <= data_pipe_tmp1(c_IDX2_H);
  pixel_eof_rc <= data_pipe_tmp1(c_IDX1_H);
  pixel_id_rc  <= data_pipe_tmp1(c_IDX0_H downto c_IDX0_L);

  ---------------------------------------------------------------------
  -- RAM: tes_pulse_shape
  ---------------------------------------------------------------------

  pulse_shape_ena    <= i_pulse_shape_wr_en or i_pulse_shape_rd_en;
  pulse_shape_wea    <= i_pulse_shape_wr_en;
  pulse_shape_addra  <= i_pulse_shape_wr_rd_addr;
  pulse_shape_dina   <= i_pulse_shape_wr_data;
  pulse_shape_regcea <= '1';

  inst_tdpram_tes_pulse_shape : entity fpasim.tdpram
    generic map(
      -- port A
      g_ADDR_WIDTH_A       => pulse_shape_addra'length,
      g_BYTE_WRITE_WIDTH_A => pulse_shape_dina'length,
      g_WRITE_DATA_WIDTH_A => pulse_shape_dina'length,
      g_WRITE_MODE_A       => "no_change",
      g_READ_DATA_WIDTH_A  => pulse_shape_dina'length,
      g_READ_LATENCY_A     => c_TES_PULSE_SHAPE_RAM_A_RD_LATENCY,
      -- port B
      g_ADDR_WIDTH_B       => pulse_shape_addra'length,
      g_BYTE_WRITE_WIDTH_B => pulse_shape_dina'length,
      g_WRITE_DATA_WIDTH_B => pulse_shape_dina'length,
      g_WRITE_MODE_B       => "no_change",
      g_READ_DATA_WIDTH_B  => pulse_shape_dina'length,
      g_READ_LATENCY_B     => c_TES_PULSE_SHAPE_RAM_B_RD_LATENCY,
      -- others
      g_CLOCKING_MODE      => "common_clock",
      g_MEMORY_PRIMITIVE   => "block",
      g_MEMORY_SIZE        => c_MEMORY_SIZE_PULSE_SHAPE,
      g_MEMORY_INIT_FILE   => "none",
      g_MEMORY_INIT_PARAM  => "0"
    )
    port map(
      ---------------------------------------------------------------------
      -- port A
      ---------------------------------------------------------------------
      i_rsta   => '0',
      i_clka   => i_clk,
      i_ena    => pulse_shape_ena,
      i_wea(0) => pulse_shape_wea,
      i_addra  => pulse_shape_addra,
      i_dina   => pulse_shape_dina,
      i_regcea => pulse_shape_regcea,
      o_douta  => pulse_shape_douta,
      ---------------------------------------------------------------------
      -- port B
      ---------------------------------------------------------------------
      i_rstb   => '0',
      i_clkb   => i_clk,
      i_web(0) => pulse_shape_web,
      i_enb    => pulse_shape_enb,
      i_addrb  => pulse_shape_addrb,
      i_dinb   => pulse_shape_dinb,
      i_regceb => pulse_shape_regceb,
      o_doutb  => pulse_shape_doutb
    );
  pulse_shape_web    <= '0';
  pulse_shape_dinb   <= (others => '0');
  pulse_shape_enb    <= pixel_valid_rc;
  pulse_shape_addrb  <= addr_pulse_shape_rc;
  pulse_shape_regceb <= pixel_valid_rc;

  -------------------------------------------------------------------
  -- sync with rd ram out
  -------------------------------------------------------------------
  inst_pipeliner_sync_with_tdpram_tes_pulse_shape_outa : entity fpasim.pipeliner
    generic map(
      g_NB_PIPES   => c_TES_PULSE_SHAPE_RAM_A_RD_LATENCY,
      g_DATA_WIDTH => 1
    )
    port map(
      i_clk     => i_clk,
      i_data(0) => i_pulse_shape_rd_en,
      o_data(0) => pulse_shape_rd_en_rz
    );
  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_pulse_shape_rd_valid <= pulse_shape_rd_en_rz;
  o_pulse_shape_rd_data  <= pulse_shape_douta;

  ---------------------------------------------------------------------
  -- RAM check
  ---------------------------------------------------------------------
  inst_ram_check_sdpram_tes_pulse_shape : entity fpasim.ram_check
    generic map(
      g_WR_ADDR_WIDTH => pulse_shape_addra'length,
      g_RD_ADDR_WIDTH => pulse_shape_addrb'length
    )
    port map(
      i_clk         => i_clk,
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_wr          => pulse_shape_wea,
      i_wr_addr     => pulse_shape_addra,
      i_rd          => pulse_shape_enb,
      i_rd_addr     => pulse_shape_addrb,
      ---------------------------------------------------------------------
      -- Errors
      ---------------------------------------------------------------------
      o_error_pulse => pulse_shape_error
    );

  ---------------------------------------------------------------------
  -- RAM: tes_std_state
  ---------------------------------------------------------------------
  steady_state_ena    <= i_steady_state_wr_en or i_steady_state_rd_en;
  steady_state_wea    <= i_steady_state_wr_en;
  steady_state_addra  <= i_steady_state_wr_rd_addr;
  steady_state_dina   <= i_steady_state_wr_data;
  steady_state_regcea <= '1';

  inst_tdpram_tes_steady_state : entity fpasim.tdpram
    generic map(
      -- port A
      g_ADDR_WIDTH_A       => steady_state_addra'length,
      g_BYTE_WRITE_WIDTH_A => steady_state_dina'length,
      g_WRITE_DATA_WIDTH_A => steady_state_dina'length,
      g_WRITE_MODE_A       => "no_change",
      g_READ_DATA_WIDTH_A  => steady_state_dina'length,
      g_READ_LATENCY_A     => c_TES_STD_STATE_RAM_A_RD_LATENCY,
      -- port B
      g_ADDR_WIDTH_B       => steady_state_addra'length,
      g_BYTE_WRITE_WIDTH_B => steady_state_dina'length,
      g_WRITE_DATA_WIDTH_B => steady_state_dina'length,
      g_WRITE_MODE_B       => "no_change",
      g_READ_DATA_WIDTH_B  => steady_state_dina'length,
      g_READ_LATENCY_B     => c_TES_STD_STATE_RAM_B_RD_LATENCY,
      -- others
      g_CLOCKING_MODE      => "common_clock",
      g_MEMORY_PRIMITIVE   => "block",
      g_MEMORY_SIZE        => c_MEMORY_SIZE_STEADY_STATE,
      g_MEMORY_INIT_FILE   => "none",
      g_MEMORY_INIT_PARAM  => "0"
    )
    port map(
      ---------------------------------------------------------------------
      -- port A
      ---------------------------------------------------------------------
      i_rsta   => '0',
      i_clka   => i_clk,
      i_ena    => steady_state_ena,
      i_wea(0) => steady_state_wea,
      i_addra  => steady_state_addra,
      i_dina   => steady_state_dina,
      i_regcea => steady_state_regcea,
      o_douta  => steady_state_douta,
      ---------------------------------------------------------------------
      -- port B
      ---------------------------------------------------------------------
      i_rstb   => '0',
      i_clkb   => i_clk,
      i_web(0) => steady_state_web,
      i_enb    => steady_state_enb,
      i_addrb  => steady_state_addrb,
      i_dinb   => steady_state_dinb,
      i_regceb => steady_state_regceb,
      o_doutb  => steady_state_doutb
    );
  steady_state_web    <= '0';
  steady_state_dinb   <= (others => '0');
  steady_state_enb    <= pixel_valid_rc;
  steady_state_addrb  <= pixel_id_rc;
  steady_state_regceb <= pixel_valid_rc;

  -------------------------------------------------------------------
  -- sync with rd RAM output
  -------------------------------------------------------------------
  inst_pipeliner_sync_with_tdpram_tes_steady_state_outa : entity fpasim.pipeliner
    generic map(
      g_NB_PIPES   => c_TES_STD_STATE_RAM_A_RD_LATENCY,
      g_DATA_WIDTH => 1
    )
    port map(
      i_clk     => i_clk,
      i_data(0) => i_steady_state_rd_en,
      o_data(0) => steady_state_rd_en_rz
    );
  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_steady_state_rd_valid <= steady_state_rd_en_rz;
  o_steady_state_rd_data  <= steady_state_douta;

  ---------------------------------------------------------------------
  -- RAM check
  ---------------------------------------------------------------------
  inst_ram_check_sdpram_tes_steady_state : entity fpasim.ram_check
    generic map(
      g_WR_ADDR_WIDTH => steady_state_addra'length,
      g_RD_ADDR_WIDTH => steady_state_addrb'length
    )
    port map(
      i_clk         => i_clk,
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_wr          => steady_state_wea,
      i_wr_addr     => steady_state_addra,
      i_rd          => steady_state_enb,
      i_rd_addr     => steady_state_addrb,
      ---------------------------------------------------------------------
      -- Errors
      ---------------------------------------------------------------------
      o_error_pulse => steady_state_error
    );

  -------------------------------------------------------------------
  -- sync with RAM output
  --------------------------------------------------------------------
  --assert not (c_TES_STD_STATE_RAM_B_RD_LATENCY = c_TES_PULSE_SHAPE_RAM_B_RD_LATENCY) report "[tes_pulse_shape_manager]: c_TES_STD_STATE_RD_RAM_LATENCY and c_TES_PULSE_SHAPE_RD_RAM_LATENCY must be equal. Otherwise, the user needs to update this design to equalize the output data path from each memory" severity error;

  data_pipe_tmp2(c_IDX4_H downto c_IDX4_L) <= pulse_heigth_rc;
  data_pipe_tmp2(c_IDX3_H)                 <= pixel_valid_rc;
  data_pipe_tmp2(c_IDX2_H)                 <= pixel_sof_rc;
  data_pipe_tmp2(c_IDX1_H)                 <= pixel_eof_rc;
  data_pipe_tmp2(c_IDX0_H downto c_IDX0_L) <= pixel_id_rc;
  inst_pipeliner_sync_with_rams_out : entity fpasim.pipeliner
    generic map(
      g_NB_PIPES   => c_TES_PULSE_SHAPE_RAM_B_RD_LATENCY,
      g_DATA_WIDTH => data_pipe_tmp2'length
    )
    port map(
      i_clk  => i_clk,
      i_data => data_pipe_tmp2,
      o_data => data_pipe_tmp3
    );

  pulse_heigth_rx <= data_pipe_tmp3(c_IDX4_H downto c_IDX4_L);
  pixel_valid_rx  <= data_pipe_tmp3(c_IDX3_H);
  pixel_sof_rx    <= data_pipe_tmp3(c_IDX2_H);
  pixel_eof_rx    <= data_pipe_tmp3(c_IDX1_H);
  pixel_id_rx     <= data_pipe_tmp3(c_IDX0_H downto c_IDX0_L);

  ---------------------------------------------------------------------
  -- TES computation
  ---------------------------------------------------------------------
  --assert not (pulse_shape_doutb'length /= pulse_shape_tmp'length - 1) report "[tes_pulse_shape_manager]: pulse shape => register/command width and sfixed package definition width doesn't match." severity error;
  --assert not (pulse_heigth_rx'length /= pulse_heigth_tmp'length - 1) report "[tes_pulse_shape_manager]: pulse heigth => register/command width and sfixed package definition width doesn't match." severity error;
  --assert not (steady_state_doutb'length /= steady_state_tmp'length - 1) report "[tes_pulse_shape_manager]: steady state => register/command width and sfixed package definition width doesn't match." severity error;
  -- unsigned to signed conversion: sign bit extension (add a sign bit)
  pulse_shape_tmp  <= std_logic_vector(resize(unsigned(pulse_shape_doutb), pulse_shape_tmp'length));
  pulse_heigth_tmp <= std_logic_vector(resize(unsigned(pulse_heigth_rx), pulse_heigth_tmp'length));
  steady_state_tmp <= std_logic_vector(resize(unsigned(steady_state_doutb), steady_state_tmp'length));

  inst_mult_sub_sfixed : entity fpasim.mult_sub_sfixed
    generic map(
      -- port A: AMD Q notation (fixed point)
      g_Q_M_A  => pkg_TES_MULT_SUB_Q_M_A,
      g_Q_N_A  => pkg_TES_MULT_SUB_Q_N_A,
      -- port B: AMD Q notation (fixed point)
      g_Q_M_B  => pkg_TES_MULT_SUB_Q_M_B,
      g_Q_N_B  => pkg_TES_MULT_SUB_Q_N_B,
      -- port C: AMC Q notation (fixed point)
      g_Q_M_C  => pkg_TES_MULT_SUB_Q_M_C,
      g_Q_N_C  => pkg_TES_MULT_SUB_Q_N_C,
      -- port S: AMD Q notation (fixed point)
      g_Q_M_S  => pkg_TES_MULT_SUB_Q_M_S,
      g_Q_N_S  => pkg_TES_MULT_SUB_Q_N_S,
      g_SIM_EN => pkg_TES_PULSE_MANAGER_COMPUTATION_SIM_EN
    )
    port map(
      i_clk => i_clk,
      --------------------------------------------------------------
      -- input
      --------------------------------------------------------------
      i_a   => pulse_shape_tmp,
      i_b   => pulse_heigth_tmp,
      i_c   => steady_state_tmp,
      --------------------------------------------------------------
      -- output : S = C - A*B
      --------------------------------------------------------------
      o_s   => result_ry -- @suppress "Incorrect array size in assignment: expected (<16>) but was (<g_PIXEL_RESULT_OUTPUT_WIDTH>)"
    );

  assert not (result_ry'length /= c_TES_MULT_SUB_Q_WIDTH_S) report "[tes_pulse_shape_manager]: result => output result width and sfixed package definition width doesn't match." severity error;

  -------------------------------------------------------------------
  -- sync with RAM output
  --------------------------------------------------------------------
  data_pipe_tmp4(c_IDX3_H)                 <= pixel_valid_rx;
  data_pipe_tmp4(c_IDX2_H)                 <= pixel_sof_rx;
  data_pipe_tmp4(c_IDX1_H)                 <= pixel_eof_rx;
  data_pipe_tmp4(c_IDX0_H downto c_IDX0_L) <= pixel_id_rx;
  inst_pipeliner_sync_with_mult_sub_sfixed_out : entity fpasim.pipeliner
    generic map(
      g_NB_PIPES   => c_COMPUTATION_LATENCY,
      g_DATA_WIDTH => data_pipe_tmp4'length
    )
    port map(
      i_clk  => i_clk,
      i_data => data_pipe_tmp4,
      o_data => data_pipe_tmp5
    );

  pixel_valid_ry <= data_pipe_tmp5(c_IDX3_H);
  pixel_sof_ry   <= data_pipe_tmp5(c_IDX2_H);
  pixel_eof_ry   <= data_pipe_tmp5(c_IDX1_H);
  pixel_id_ry    <= data_pipe_tmp5(c_IDX0_H downto c_IDX0_L);

  -------------------------------------------------------------------
  -- output
  -------------------------------------------------------------------
  o_pixel_sof    <= pixel_sof_ry;
  o_pixel_eof    <= pixel_eof_ry;
  o_pixel_valid  <= pixel_valid_ry;
  o_pixel_id     <= pixel_id_ry;
  o_pixel_result <= result_ry;

  ---------------------------------------------------------------------
  -- Error latching
  ---------------------------------------------------------------------
  error_tmp(4) <= steady_state_error;
  error_tmp(3) <= pulse_shape_error;
  error_tmp(2) <= errors_sync(2) or errors_sync(3); -- fifo rst error
  error_tmp(1) <= errors_sync(1);       -- fifo rd empty error
  error_tmp(0) <= errors_sync(0);       -- fifo wr full error
  gen_errors_latch : for i in error_tmp'range generate
    inst_one_error_latch : entity fpasim.one_error_latch
      port map(
        i_clk         => i_clk,
        i_rst         => i_rst_status,
        i_debug_pulse => i_debug_pulse,
        i_error       => error_tmp(i),
        o_error       => error_tmp_bis(i)
      );
  end generate gen_errors_latch;

  o_errors(15 downto 6) <= (others => '0');
  o_errors(5)           <= error_tmp_bis(4); -- steady state error
  o_errors(4)           <= error_tmp_bis(3); -- pulse shape error
  o_errors(3)           <= '0';
  o_errors(2)           <= error_tmp_bis(2); -- fifo rst error
  o_errors(1)           <= error_tmp_bis(1); -- fifo rd empty error
  o_errors(0)           <= error_tmp_bis(0); -- fifo wr full error

  o_status(7 downto 1) <= (others => '0');
  o_status(0)          <= empty_sync;   -- fifo empty

  ---------------------------------------------------------------------
  -- for simulation only
  ---------------------------------------------------------------------
  assert not (error_tmp_bis(4) = '1') report "[tes_pulse_shape_manager] => RAM wrong access: steady state " severity error;
  assert not (error_tmp_bis(3) = '1') report "[tes_pulse_shape_manager] => RAM wrong access: pulse shape" severity error;

  assert not (error_tmp_bis(2) = '1') report "[tes_pulse_shape_manager] => fifo is used before the end of the initialization " severity error;
  assert not (error_tmp_bis(1) = '1') report "[tes_pulse_shape_manager] => fifo read an empty FIFO" severity error;
  assert not (error_tmp_bis(0) = '1') report "[tes_pulse_shape_manager] => fifo write a full FIFO" severity error;

end architecture RTL;
