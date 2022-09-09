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

entity tes_pulse_shape_manager is
  generic(
    g_FRAME_SIZE                : positive := pkg_FRAME_SIZE;-- frame size value (expressed in bits). Possible values : [1; max integer value[
    g_FRAME_WIDTH               : positive := pkg_FRAME_WIDTH; -- frame bus width (expressed in bits). Possible values : [1; max integer value[
    g_PIXEL_ID_WIDTH            : positive := pkg_PIXEL_ID_WIDTH; -- pixel id bus width (expressed in bits). Possible values : [1; max integer value[
    g_PIXEL_RESULT_OUTPUT_WIDTH : positive := pkg_TES_MULT_SUB_Q_WIDTH_S -- pixel output result width (expressed in bits). Possible values : [1; max integer value[
  );
  port(
    i_clk                  : in  std_logic; -- clock 
    i_rst                  : in  std_logic; -- reset 
    i_rst_status           : in  std_logic; -- reset error flag(s)
    i_debug_pulse          : in  std_logic; -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)

    ---------------------------------------------------------------------
    -- input command: from the regdecode
    ---------------------------------------------------------------------
    i_cmd_valid            : in  std_logic; -- valid command
    i_cmd_pulse_height     : in  std_logic_vector(10 downto 0); -- pulse height command
    i_cmd_pixel_id         : in  std_logic_vector(g_PIXEL_ID_WIDTH - 1 downto 0); -- pixel id command
    i_cmd_time_shift       : in  std_logic_vector(3 downto 0); -- time shift command

    -- RAM: pulse shape
    -- wr
    i_wr_pulse_shape_en    : in  std_logic; -- write enable
    i_wr_pulse_shape_addr  : in  std_logic_vector(14 downto 0); -- write address
    i_wr_pulse_shape_data  : in  std_logic_vector(15 downto 0); -- write data

    -- RAM:
    -- wr
    i_wr_steady_state_en   : in  std_logic; -- write enable
    i_wr_steady_state_addr : in  std_logic_vector(g_PIXEL_ID_WIDTH - 1 downto 0); -- write address
    i_wr_steady_state_data : in  std_logic_vector(15 downto 0); -- write data

    ---------------------------------------------------------------------
    -- input data
    ---------------------------------------------------------------------
    i_pixel_sof            : in  std_logic; -- first pixel sample
    i_pixel_eof            : in  std_logic; -- last pixel sample
    i_pixel_id             : in  std_logic_vector(g_PIXEL_ID_WIDTH - 1 downto 0); -- pixel id 
    i_pixel_valid          : in  std_logic; -- valid pixel sample

    ---------------------------------------------------------------------
    -- output data
    ---------------------------------------------------------------------
    o_pixel_sof            : out std_logic; -- first pixel sample
    o_pixel_eof            : out std_logic; -- last pixel sample
    o_pixel_id             : out std_logic_vector(g_PIXEL_ID_WIDTH - 1 downto 0); -- pixel id
    o_pixel_valid          : out std_logic; -- valid pixel result
    o_pixel_result         : out std_logic_vector(g_PIXEL_RESULT_OUTPUT_WIDTH - 1 downto 0); -- pixel result

    -----------------------------------------------------------------
    -- errors/status
    -----------------------------------------------------------------
    o_errors               : out std_logic_vector(15 downto 0); -- output errors
    o_status               : out std_logic_vector(7 downto 0) -- output status
  );
end entity tes_pulse_shape_manager;

architecture RTL of tes_pulse_shape_manager is
  constant c_SHIFT_MAX                : positive := 2 ** (i_cmd_time_shift'length) + 1;

  constant c_RAM_RD_LATENCY           : natural := pkg_TES_PULSE_MANAGER_RD_RAM_LATENCY;
  constant c_MEMORY_SIZE_PULSE_SHAPE  : positive := (2 ** i_wr_pulse_shape_addr'length) * i_wr_pulse_shape_data'length; -- memory size in bits
  constant c_MEMORY_SIZE_STEADY_STATE : positive := (2 ** i_wr_steady_state_addr'length) * i_wr_steady_state_data'length; -- memory size in bits

  constant c_COMPUTATION_LATENCY      : natural := pkg_TES_PULSE_MANAGER_COMPUTATION_LATENCY;

  constant c_TES_MULT_SUB_Q_WIDTH_A   : positive := pkg_TES_MULT_SUB_Q_WIDTH_A;
  constant c_TES_MULT_SUB_Q_WIDTH_B   : positive := pkg_TES_MULT_SUB_Q_WIDTH_B;
  constant c_TES_MULT_SUB_Q_WIDTH_C   : positive := pkg_TES_MULT_SUB_Q_WIDTH_C;
  constant c_TES_MULT_SUB_Q_WIDTH_S   : positive := pkg_TES_MULT_SUB_Q_WIDTH_S;

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
  constant c_FIFO_DEPTH : integer := 16; --see IP
  constant c_FIFO_WIDTH : integer := c_CMD_IDX2_H + 1; --see IP

  signal wr_tmp0      : std_logic;
  signal data_tmp0    : std_logic_vector(c_FIFO_WIDTH - 1 downto 0);
  signal full0        : std_logic;
  signal wr_rst_busy0 : std_logic;

  signal rd1          : std_logic;
  signal data_tmp1    : std_logic_vector(c_FIFO_WIDTH - 1 downto 0);
  signal empty1       : std_logic;
  signal rd_rst_busy1 : std_logic;

  signal cmd_pulse_height1 : std_logic_vector(i_cmd_pulse_height'range);
  signal cmd_pixel_id1     : std_logic_vector(i_cmd_pixel_id'range);
  signal cmd_time_shift1   : std_logic_vector(i_cmd_time_shift'range);

  signal error_status1 : std_logic_vector(1 downto 0);

  ---------------------------------------------------------------------
  -- State machine
  ---------------------------------------------------------------------
  type t_addr_pulse_shape_array is array (0 to i_pixel_id'length - 1) of unsigned(g_FRAME_WIDTH - 1 downto 0);
  type t_pulse_height_array is array (0 to i_pixel_id'length - 1) of unsigned(i_cmd_pulse_height'range);
  type t_time_shift_array is array (0 to i_pixel_id'length - 1) of unsigned(i_cmd_time_shift'range);

  type t_state is (E_RST, E_WAIT, E_RUN);
  signal fsm_state_r1   : t_state;
  signal fsm_state_next : t_state;

  signal cmd_rd_next : std_logic;
  signal cmd_rd_r1   : std_logic;

  signal cnt_sample_pulse_shape_next : unsigned(g_FRAME_WIDTH - 1 downto 0);
  signal cnt_sample_pulse_shape_r1   : unsigned(g_FRAME_WIDTH - 1 downto 0);

  signal cnt_sample_pulse_shape_table_next : t_addr_pulse_shape_array;
  signal cnt_sample_pulse_shape_table_r1   : t_addr_pulse_shape_array;

  signal en_table_next : std_logic_vector(i_pixel_id'range);
  signal en_table_r1   : std_logic_vector(i_pixel_id'range);

  signal pulse_heigth_next : unsigned(i_cmd_pulse_height'range);
  signal pulse_heigth_r1   : unsigned(i_cmd_pulse_height'range);

  signal pulse_heigth_table_next : t_pulse_height_array;
  signal pulse_heigth_table_r1   : t_pulse_height_array;

  signal time_shift_next : unsigned(i_cmd_time_shift'range);
  signal time_shift_r1   : unsigned(i_cmd_time_shift'range);

  signal time_shift_table_next : t_time_shift_array;
  signal time_shift_table_r1   : t_time_shift_array;

  signal en_next : std_logic;
  signal en_r1   : std_logic;

  signal pixel_valid_next : std_logic;
  signal pixel_valid_r1   : std_logic;

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

  signal pixel_sof_r2 : std_logic;
  signal pixel_eof_r2 : std_logic;
  signal pixel_id_r2  : std_logic_vector(i_pixel_id'range);

  signal pulse_heigth_r2 : std_logic_vector(i_cmd_pulse_height'range);

  -- address computation
  signal pixel_valid_r2      : std_logic;
  signal addr_pulse_shape_r2 : unsigned(i_wr_pulse_shape_addr'range);

  ---------------------------------------------------------------------
  -- tes_pulse_shape
  ---------------------------------------------------------------------
  -- RAM
  signal pulse_shape_ena   : std_logic;
  signal pulse_shape_wea   : std_logic;
  signal pulse_shape_addra : std_logic_vector(i_wr_pulse_shape_addr'range);
  signal pulse_shape_dina  : std_logic_vector(i_wr_pulse_shape_data'range);

  signal pulse_shape_enb    : std_logic;
  signal pulse_shape_addrb  : std_logic_vector(i_wr_pulse_shape_addr'range);
  signal pulse_shape_regceb : std_logic;
  signal pulse_shape_doutb  : std_logic_vector(i_wr_pulse_shape_data'range);

  signal pulse_shape_error : std_logic;

  ---------------------------------------------------------------------
  -- tes_pulse_shape
  ---------------------------------------------------------------------
  -- RAM
  signal steady_state_ena   : std_logic;
  signal steady_state_wea   : std_logic;
  signal steady_state_addra : std_logic_vector(i_wr_steady_state_addr'range);
  signal steady_state_dina  : std_logic_vector(i_wr_steady_state_data'range);

  signal steady_state_enb    : std_logic;
  signal steady_state_addrb  : std_logic_vector(i_wr_steady_state_addr'range);
  signal steady_state_regceb : std_logic;
  signal steady_state_doutb  : std_logic_vector(i_wr_steady_state_data'range);

  signal steady_state_error : std_logic;

  ---------------------------------------------------------------------
  -- sync with RAM outputs
  ---------------------------------------------------------------------
  signal data_pipe_tmp2 : std_logic_vector(c_IDX4_H downto 0);
  signal data_pipe_tmp3 : std_logic_vector(c_IDX4_H downto 0);

  signal pixel_sof_rx   : std_logic;
  signal pixel_eof_rx   : std_logic;
  signal pixel_valid_rx : std_logic;
  signal pixel_id_rx    : std_logic_vector(i_pixel_id'range);

  signal pulse_heigth_rx  : std_logic_vector(i_cmd_pulse_height'range);
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
  constant NB_ERRORS_c : integer := 3;
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

  inst_cmd_fifo_sync : entity fpasim.fifo_sync
    generic map(
      g_FIFO_MEMORY_TYPE  => "auto",
      g_FIFO_READ_LATENCY => 1,
      g_FIFO_WRITE_DEPTH  => c_FIFO_DEPTH,
      g_READ_DATA_WIDTH   => data_tmp0'length,
      g_READ_MODE         => "std",
      g_WRITE_DATA_WIDTH  => data_tmp0'length
    )
    port map(
      ---------------------------------------------------------------------
      -- write side
      ---------------------------------------------------------------------
      i_wr_clk        => i_clk,         -- write clock
      i_wr_rst        => i_rst,         -- write reset 
      i_wr_en         => wr_tmp0,       -- write enable
      i_wr_din        => data_tmp0,     -- write data
      o_wr_full       => full0,         -- When asserted, this signal indicates that the FIFO is full (not destructive to the contents of the FIFO.)
      o_wr_rst_busy   => wr_rst_busy0,  -- Active-High indicator that the FIFO write domain is currently in a reset state
      ---------------------------------------------------------------------
      -- port B
      ---------------------------------------------------------------------
      i_rd_en         => rd1,           -- read enable (Must be held active-low when rd_rst_busy is active high)
      o_rd_dout_valid => open,          -- When asserted, this signal indicates that valid data is available on the output bus
      o_rd_dout       => data_tmp1,
      o_rd_empty      => empty1,        -- When asserted, this signal indicates that the FIFO is full (not destructive to the contents of the FIFO.)
      o_rd_rst_busy   => rd_rst_busy1   -- Active-High indicator that the FIFO read domain is currently in a reset state
    );

  rd1 <= cmd_rd_r1;

  cmd_pulse_height1 <= data_tmp1(c_CMD_IDX2_H downto c_CMD_IDX2_L);
  cmd_pixel_id1     <= data_tmp1(c_CMD_IDX1_H downto c_CMD_IDX1_L);
  cmd_time_shift1   <= data_tmp1(c_CMD_IDX0_H downto c_CMD_IDX0_L);

  inst_cmd_fifo_two_errors : entity fpasim.fifo_two_errors
    port map(                           -- @suppress "The order of the associations is different from the declaration order"
      i_clk         => i_clk,
      i_rst         => i_rst_status,
      i_debug_pulse => i_debug_pulse,
      i_fifo_cmd0   => wr_tmp0,
      i_fifo_flag0  => full0,
      i_fifo_cmd1   => rd1,
      i_fifo_flag1  => empty1,
      o_error       => error_status1
    );

  ---------------------------------------------------------------------
  -- state machine
  ---------------------------------------------------------------------
  p_decode_state : process(cnt_sample_pulse_shape_r1, cmd_pixel_id1, cmd_pulse_height1, cmd_time_shift1, cnt_sample_pulse_shape_table_r1, empty1, en_r1, en_table_r1, fsm_state_r1, i_pixel_eof, i_pixel_id, i_pixel_sof, i_pixel_valid, pulse_heigth_r1, pulse_heigth_table_r1, time_shift_r1, time_shift_table_r1) is
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

    case fsm_state_r1 is
      when E_RST =>
        en_table_next                     <= (others => '0');
        cnt_sample_pulse_shape_table_next <= (others => (others => '0'));
        pulse_heigth_table_next           <= (others => (others => '0'));
        time_shift_table_next             <= (others => (others => '0'));
        fsm_state_next                    <= E_WAIT;

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
          fsm_state_next              <= E_RUN;
        else
          fsm_state_next <= E_WAIT;
        end if;

      when E_RUN =>
        pixel_valid_next <= i_pixel_valid;
        if i_pixel_eof = '1' and i_pixel_valid = '1' then
          if cnt_sample_pulse_shape_r1 = to_unsigned(g_FRAME_SIZE - 1, cnt_sample_pulse_shape_r1'length) then
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
            cnt_sample_pulse_shape_table_next(to_integer(unsigned(i_pixel_id))) <= cnt_sample_pulse_shape_r1 + 1;
          end if;
          fsm_state_next <= E_WAIT;
        else
          fsm_state_next <= E_RUN;
        end if;

      when others =>                    -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
        fsm_state_next <= E_RST;
    end case;
  end process p_decode_state;

  p_state : process(i_clk) is
  begin
    if rising_edge(i_clk) then
      if i_rst = '1' then
        fsm_state_r1 <= E_RST;
      else
        fsm_state_r1 <= fsm_state_next;
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
  --  => addr_pulse_shape_r2 = i*step + pixel_shift with i=[0,2047]
  ---------------------------------------------------------------------
  p_pipe_and_computation : process(i_clk) is
  begin
    if rising_edge(i_clk) then
      pixel_valid_r2  <= pixel_valid_r1;
      pulse_heigth_r2 <= std_logic_vector(pulse_heigth_r1);

      -- ram: pulse_shape
      addr_pulse_shape_r2 <= resize((cnt_sample_pulse_shape_r1 * c_SHIFT_MAX) + time_shift_r1, addr_pulse_shape_r2'length);

    end if;
  end process p_pipe_and_computation;

  data_pipe_tmp0(c_IDX2_H)                 <= i_pixel_sof;
  data_pipe_tmp0(c_IDX1_H)                 <= i_pixel_eof;
  data_pipe_tmp0(c_IDX0_H downto c_IDX0_L) <= i_pixel_id;
  inst_pipeliner_sync_with_pipe_and_computation_out : entity fpasim.pipeliner
    generic map(
      g_NB_PIPES   => 2,                -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => data_pipe_tmp0'length -- width of the input/output data.  Possibles values: [1, integer max value[
    )
    port map(
      i_clk  => i_clk,                  -- clock signal
      i_data => data_pipe_tmp0,         -- input data
      o_data => data_pipe_tmp1          -- output data with/without delay
    );

  pixel_sof_r2 <= data_pipe_tmp1(c_IDX2_H);
  pixel_eof_r2 <= data_pipe_tmp1(c_IDX1_H);
  pixel_id_r2  <= data_pipe_tmp1(c_IDX0_H downto c_IDX0_L);

  ---------------------------------------------------------------------
  -- RAM: tes_pulse_shape
  ---------------------------------------------------------------------
  pulse_shape_ena   <= i_wr_pulse_shape_en;
  pulse_shape_wea   <= i_wr_pulse_shape_en;
  pulse_shape_addra <= i_wr_pulse_shape_addr;
  pulse_shape_dina  <= i_wr_pulse_shape_data;

  inst_sdpram_tes_pulse_shape : entity fpasim.sdpram
    generic map(
      g_ADDR_WIDTH_A       => pulse_shape_addra'length,
      g_BYTE_WRITE_WIDTH_A => pulse_shape_dina'length,
      g_WRITE_DATA_WIDTH_A => pulse_shape_dina'length,
      g_ADDR_WIDTH_B       => pulse_shape_addra'length,
      g_WRITE_MODE_B       => "no_change",
      g_READ_DATA_WIDTH_B  => pulse_shape_dina'length,
      g_READ_LATENCY_B     => c_RAM_RD_LATENCY,
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
      i_clka   => i_clk,                -- clock
      i_ena    => pulse_shape_ena,      -- memory enable
      i_wea(0) => pulse_shape_wea,      -- write enable
      i_addra  => pulse_shape_addra,    -- write address
      i_dina   => pulse_shape_dina,     -- write data input
      ---------------------------------------------------------------------
      -- port B
      ---------------------------------------------------------------------
      i_rstb   => '0',                  -- reset the ouput register
      i_clkb   => i_clk,                -- clock
      i_enb    => pulse_shape_enb,      -- memory enable
      i_addrb  => pulse_shape_addrb,    -- read address
      i_regceb => pulse_shape_regceb,   -- clock enable for the last register stage on the output data path
      o_doutb  => pulse_shape_doutb     -- read data output
    );
  pulse_shape_enb    <= pixel_valid_r2;
  pulse_shape_addrb  <= std_logic_vector(addr_pulse_shape_r2);
  pulse_shape_regceb <= pixel_valid_r2;

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
  steady_state_ena   <= i_wr_steady_state_en;
  steady_state_wea   <= i_wr_steady_state_en;
  steady_state_addra <= i_wr_steady_state_addr;
  steady_state_dina  <= i_wr_steady_state_data;

  inst_sdpram_tes_steady_state : entity fpasim.sdpram
    generic map(
      g_ADDR_WIDTH_A       => steady_state_addra'length,
      g_BYTE_WRITE_WIDTH_A => steady_state_dina'length,
      g_WRITE_DATA_WIDTH_A => steady_state_dina'length,
      g_ADDR_WIDTH_B       => steady_state_addra'length,
      g_WRITE_MODE_B       => "no_change",
      g_READ_DATA_WIDTH_B  => steady_state_dina'length,
      g_READ_LATENCY_B     => c_RAM_RD_LATENCY,
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
      i_clka   => i_clk,                -- clock
      i_ena    => steady_state_ena,     -- memory enable
      i_wea(0) => steady_state_wea,     -- write enable
      i_addra  => steady_state_addra,   -- write address
      i_dina   => steady_state_dina,    -- write data input
      ---------------------------------------------------------------------
      -- port B
      ---------------------------------------------------------------------
      i_rstb   => '0',                  -- reset the ouput register
      i_clkb   => i_clk,                -- clock
      i_enb    => steady_state_enb,     -- memory enable
      i_addrb  => steady_state_addrb,   -- read address
      i_regceb => steady_state_regceb,  -- clock enable for the last register stage on the output data path
      o_doutb  => steady_state_doutb    -- read data output
    );
  steady_state_enb    <= pixel_valid_r2;
  steady_state_addrb  <= pixel_id_r2;
  steady_state_regceb <= pixel_valid_r2;

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
  data_pipe_tmp2(c_IDX4_H downto c_IDX4_L) <= pulse_heigth_r2;
  data_pipe_tmp2(c_IDX3_H)                 <= pixel_valid_r2;
  data_pipe_tmp2(c_IDX2_H)                 <= pixel_sof_r2;
  data_pipe_tmp2(c_IDX1_H)                 <= pixel_eof_r2;
  data_pipe_tmp2(c_IDX0_H downto c_IDX0_L) <= pixel_id_r2;
  inst_pipeliner_sync_with_rams_out : entity fpasim.pipeliner
    generic map(
      g_NB_PIPES   => c_RAM_RD_LATENCY, -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => data_pipe_tmp2'length -- width of the input/output data.  Possibles values: [1, integer max value[
    )
    port map(
      i_clk  => i_clk,                  -- clock signal
      i_data => data_pipe_tmp2,         -- input data
      o_data => data_pipe_tmp3          -- output data with/without delay
    );

  pulse_heigth_rx <= data_pipe_tmp3(c_IDX4_H downto c_IDX4_L);
  pixel_valid_rx  <= data_pipe_tmp3(c_IDX3_H);
  pixel_sof_rx    <= data_pipe_tmp3(c_IDX2_H);
  pixel_eof_rx    <= data_pipe_tmp3(c_IDX1_H);
  pixel_id_rx     <= data_pipe_tmp3(c_IDX0_H downto c_IDX0_L);

  ---------------------------------------------------------------------
  -- TES computation
  ---------------------------------------------------------------------
  assert not (pulse_shape_doutb'length /= pulse_shape_tmp'length - 1) report "[tes_pulse_shape_manager]: pulse shape => register/command width and sfixed package definition width doesn't match." severity error;
  assert not (pulse_heigth_rx'length /= pulse_heigth_tmp'length - 1) report "[tes_pulse_shape_manager]: pulse heigth => register/command width and sfixed package definition width doesn't match." severity error;
  assert not (steady_state_doutb'length /= steady_state_tmp'length - 1) report "[tes_pulse_shape_manager]: steady state => register/command width and sfixed package definition width doesn't match." severity error;
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
      o_s   => result_ry
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
      g_NB_PIPES   => c_COMPUTATION_LATENCY, -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => data_pipe_tmp4'length -- width of the input/output data.  Possibles values: [1, integer max value[
    )
    port map(
      i_clk  => i_clk,                  -- clock signal
      i_data => data_pipe_tmp4,         -- input data
      o_data => data_pipe_tmp5          -- output data with/without delay
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
  error_tmp(2) <= steady_state_error;
  error_tmp(1) <= pulse_shape_error;
  error_tmp(0) <= (wr_rst_busy0 and wr_tmp0) or (rd_rst_busy1 and rd1);
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

  o_errors(15 downto 7) <= (others => '0');
  o_errors(6)           <= error_tmp_bis(2);
  o_errors(5)           <= error_tmp_bis(1);
  o_errors(4)           <= error_tmp_bis(0);
  o_errors(3 downto 2)  <= (others => '0');
  o_errors(1 downto 0)  <= error_status1;

  o_status(7 downto 1) <= (others => '0');
  o_status(0)          <= empty1;

  ---------------------------------------------------------------------
  -- for simulation only
  ---------------------------------------------------------------------
  assert not (error_tmp_bis(2) = '1') report "[tes_pulse_shape_manager] => steady state RAM wrong access " severity error;
  assert not (error_tmp_bis(1) = '1') report "[tes_pulse_shape_manager] => pulse shape RAM wrong access " severity error;
  assert not (error_tmp_bis(0) = '1') report "[tes_pulse_shape_manager] => FIFO01 is used before the end of the initialization " severity error;

  assert not (error_status1(0) = '1') report "[tes_pulse_shape_manager] => FIFO01 write a full FIFO" severity error;
  assert not (error_status1(1) = '1') report "[tes_pulse_shape_manager] => FIFO01 read an empty FIFO" severity error;

end architecture RTL;