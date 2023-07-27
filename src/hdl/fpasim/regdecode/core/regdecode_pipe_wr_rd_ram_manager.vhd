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
--    @file                   regdecode_pipe_wr_rd_ram_manager.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This module is used to configure a RAM. 2 behaviour are managed by the FSM:
--
--    This module analyses the field of the i_make_pulse register. 2 behaviour are managed by the FSM:
--        1. if i_start_auto_rd = '0' then no change is done. The input data are used to write the RAM content.
--        2. if i_start_auto_rd = '1', then the FSM will automatically generate read addresses in order to fully read the RAM.
--
--    In all cases, the module manages the clock domain crossing.
--
--    The architecture is as follows:
--         @i_clk source clock domain                           |                    @ i_out_clk destination clock domain
--         i_data/i_addr -----------------FSM ------------> async_fifo -----------> o_ram_wr_rd_addr/o_ram_wr_data
--                                                                                           |
--         o_fifo_addr/o_fifo_data <----------------------  async_fifo <------------- i_ram_rd_data
--    Note:
--      . During the reading, the FSM manages the fifo data flow. So, the data flow can automatically be paused.
--      . i_addr_range_min is used to manage address offset during the read address generation.
--    Limitation:
--      g_RAM_NB_WORDS >= 2.
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity regdecode_pipe_wr_rd_ram_manager is
  generic(
    -- RAM
    g_RAM_NB_WORDS   : integer  := 2048;  -- define the maximal number of words associated to the RAM
    g_RAM_RD_LATENCY : integer  := 2;   -- define the read RAM latency
    -- input
    g_ADDR_WIDTH     : positive := 16;  -- define the input address bus width
    g_DATA_WIDTH     : positive := 16   -- define the input data bus width

    );
  port(
    ---------------------------------------------------------------------
    -- from the regdecode: input @i_clk
    ---------------------------------------------------------------------
    i_clk             : in  std_logic;  -- clock
    i_rst             : in  std_logic;  -- reset
    i_rst_status      : in  std_logic;  -- reset error flag(s)
    i_debug_pulse     : in  std_logic;  -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
    -- command
    i_start_auto_rd   : in  std_logic;  -- start the read address generation
    i_addr_range_min  : in  std_logic_vector(g_ADDR_WIDTH - 1 downto 0);  -- minimal address range (address offset)
    -- data
    i_data_valid      : in  std_logic;  -- input data valid
    i_addr            : in  std_logic_vector(g_ADDR_WIDTH - 1 downto 0);  -- input address
    i_data            : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0);  -- input data
    ---------------------------------------------------------------------
    -- from/to the user:  @i_out_clk
    ---------------------------------------------------------------------
    i_out_clk         : in  std_logic;  -- output clock
    i_out_rst         : in std_logic; -- reset @i_out_clk
    -- ram: wr
    o_ram_wr_en       : out std_logic;  -- output write enable
    o_ram_wr_rd_addr  : out std_logic_vector(g_ADDR_WIDTH - 1 downto 0);  -- output address (shared by the writting and the reading)
    o_ram_wr_data     : out std_logic_vector(g_DATA_WIDTH - 1 downto 0);  -- output data
    -- ram: rd
    o_ram_rd_en       : out std_logic;  -- output read enable
    i_ram_rd_valid    : in  std_logic;  -- input read valid
    i_ram_rd_data     : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0);  -- input data
    ---------------------------------------------------------------------
    -- to the regdecode: @i_clk
    ---------------------------------------------------------------------
    i_fifo_rd         : in  std_logic;  -- read enable
    o_fifo_sof        : out std_logic;  -- first data sample
    o_fifo_eof        : out std_logic;  -- last data sample
    o_fifo_data_valid : out std_logic;  -- data valid
    o_fifo_addr       : out std_logic_vector(g_ADDR_WIDTH - 1 downto 0);  -- address
    o_fifo_data       : out std_logic_vector(g_DATA_WIDTH - 1 downto 0);  -- data
    o_fifo_empty      : out std_logic;  -- empty fifo flag
    ---------------------------------------------------------------------
    -- errors/status @ i_clk
    ---------------------------------------------------------------------
    o_errors          : out std_logic_vector(15 downto 0);  -- output errors
    o_status          : out std_logic_vector(7 downto 0)    -- output status
    );
end entity regdecode_pipe_wr_rd_ram_manager;

architecture RTL of regdecode_pipe_wr_rd_ram_manager is

  -- RAM address width
  constant c_RAM_ADDR_WIDTH : integer := work.pkg_utils.pkg_width_from_value(g_RAM_NB_WORDS);
  -- number max of words in the RAM
  constant c_CNT_MAX        : integer := 2 ** c_RAM_ADDR_WIDTH;
  -- output delay
  constant c_DELAY_OUT      : integer := 1;
  -- RAM latency (in reading)
  constant c_ADDR_DELAY_OUT : integer := c_DELAY_OUT + g_RAM_RD_LATENCY;
  -- FIFO latency (in reading)
  constant c_FIFO_READ_LATENCY : integer := 2;

  ---------------------------------------------------------------------
  -- fsm
  ---------------------------------------------------------------------
  -- fsm type declaration
  type t_state is (E_RST, E_WAIT, E_AUTO_RD);
  signal sm_state_next : t_state; -- state
  signal sm_state_r1   : t_state; -- state (registered)

  signal sof_next : std_logic; -- first word
  signal sof_r1   : std_logic := '0'; -- first word (registered)

  signal eof_next : std_logic; -- last word
  signal eof_r1   : std_logic := '0'; -- last word (registered)

  -- RAM mode. If the RAM must be written or read: '1': write, '0': read
  signal sel_wr_next : std_logic;
  -- RAM mode (registered)
  signal sel_wr_r1   : std_logic := '0';

  signal data_valid_next : std_logic; -- data valid
  signal data_valid_r1   : std_logic := '0'; -- data valid (registered)

  -- count the number of words (to write or read)
  signal cnt_next : unsigned(c_RAM_ADDR_WIDTH - 1 downto 0);
  -- count the number of words (registered)
  signal cnt_r1   : unsigned(c_RAM_ADDR_WIDTH - 1 downto 0) := (others => '0');

  -- full address: address_sel & address_RAM
  signal addr_next : unsigned(i_addr'range);
  -- full address (registered)
  signal addr_r1   : unsigned(i_addr'range) := (others => '0');

  -- error flag
  signal error_next : std_logic;
  -- error flag (registered)
  signal error_r1   : std_logic := '0';

  -- sync with fsm out
  ---------------------------------------------------------------------
  -- delayed data
  signal data_r1 : std_logic_vector(i_data'range) := (others => '0');

  ---------------------------------------------------------------------
  -- cross clock domain: redecode to user
  ---------------------------------------------------------------------
  constant c_FIFO_IDX0_L : integer := 0; -- index0: low
  constant c_FIFO_IDX0_H : integer := c_FIFO_IDX0_L + i_data'length - 1; -- index0: high

  constant c_FIFO_IDX1_L : integer := c_FIFO_IDX0_H + 1; -- index1: low
  constant c_FIFO_IDX1_H : integer := c_FIFO_IDX1_L + i_addr'length - 1; -- index1: high

  constant c_FIFO_IDX2_L : integer := c_FIFO_IDX1_H + 1; -- index2: low
  constant c_FIFO_IDX2_H : integer := c_FIFO_IDX2_L + 1 - 1; -- index2: high

  constant c_FIFO_IDX3_L : integer := c_FIFO_IDX2_H + 1; -- index3: low
  constant c_FIFO_IDX3_H : integer := c_FIFO_IDX3_L + 1 - 1; -- index3: high

  constant c_FIFO_IDX4_L : integer := c_FIFO_IDX3_H + 1; -- index4: low
  constant c_FIFO_IDX4_H : integer := c_FIFO_IDX4_L + 1 - 1; -- index4: high

  -- FIFO depth (expressed in number of words)
  constant c_FIFO_DEPTH0 : integer := 512;
  -- FIFO width (expressed in bits)
  constant c_FIFO_WIDTH0 : integer := c_FIFO_IDX4_H + 1;

  -- fifo: write side
  -- fifo: rst
  signal wr_rst_tmp0 : std_logic;
  -- fifo: write
  signal wr_tmp0     : std_logic;
  -- fifo: data_in
  signal data_tmp0   : std_logic_vector(c_FIFO_WIDTH0 - 1 downto 0);
  -- fifo: full flag
  -- signal full0        : std_logic;
  -- fifo: rst_busy flag
  -- signal wr_rst_busy0 : std_logic;

  -- fifo: read side
  -- fifo: read
  signal rd1          : std_logic;
  -- fifo: data_in
  signal data_tmp1    : std_logic_vector(c_FIFO_WIDTH0 - 1 downto 0);
  -- fifo: empty flag
  signal empty1       : std_logic;
  -- fifo: data_valid flag
  signal data_valid1  : std_logic;
  -- fifo: rst_busy flag
  signal rd_rst_busy1 : std_logic;

  -- first word
  signal sof1    : std_logic;
  -- last word
  signal eof1    : std_logic;
  -- RAM mode
  signal sel_wr1 : std_logic;
  -- RAM address
  signal addr1   : std_logic_vector(i_addr'range);
  -- RAM data
  signal data1   : std_logic_vector(i_data'range);

  -- resynchronized errors
  signal errors_sync1 : std_logic_vector(3 downto 0);
  -- resynchronized empty flag
  signal empty_sync1  : std_logic;

  ---------------------------------------------------------------------
  -- compute flag
  ---------------------------------------------------------------------
  -- first word
  signal sof_sync_r1  : std_logic                      := '0';
  -- last word
  signal eof_sync_r1  : std_logic                      := '0';
  -- write flag
  signal wr_sync_r1   : std_logic                      := '0';
  -- read flag
  signal rd_sync_r1   : std_logic                      := '0';
  -- address
  signal addr_sync_r1 : std_logic_vector(i_addr'range) := (others => '0');
  -- data
  signal data_sync_r1 : std_logic_vector(i_data'range) := (others => '0');

  ---------------------------------------------------------------------
  -- add an optional output delay
  ---------------------------------------------------------------------
  constant c_IDX0_L : integer := 0; -- index0: low
  constant c_IDX0_H : integer := c_IDX0_L + i_data'length - 1; -- index0: high

  constant c_IDX1_L : integer := c_IDX0_H + 1; -- index1: low
  constant c_IDX1_H : integer := c_IDX1_L + i_addr'length - 1; -- index1: high

  constant c_IDX2_L : integer := c_IDX1_H + 1; -- index2: low
  constant c_IDX2_H : integer := c_IDX2_L + 1 - 1; -- index2: high

  constant c_IDX3_L : integer := c_IDX2_H + 1; -- index3: low
  constant c_IDX3_H : integer := c_IDX3_L + 1 - 1; -- index3: high

  signal data_pipe_tmp2 : std_logic_vector(c_IDX3_H downto 0); -- temporary input pipe
  signal data_pipe_tmp3 : std_logic_vector(c_IDX3_H downto 0); -- temporary output pipe

  signal wr_sync_ry   : std_logic; -- write flag
  signal rd_sync_ry   : std_logic; -- read flag
  signal addr_sync_ry : std_logic_vector(i_addr'range); -- address
  signal data_sync_ry : std_logic_vector(i_data'range); -- data

  ---------------------------------------------------------------------
  -- sync with the rd RAM output
  ---------------------------------------------------------------------
  constant c_PIPE_IDX0_L : integer := 0; -- index0: low
  constant c_PIPE_IDX0_H : integer := c_PIPE_IDX0_L + i_addr'length - 1; -- index0: high

  constant c_PIPE_IDX1_L : integer := c_PIPE_IDX0_H + 1; -- index1: low
  constant c_PIPE_IDX1_H : integer := c_PIPE_IDX1_L + 1 - 1; -- index1: high

  constant c_PIPE_IDX2_L : integer := c_PIPE_IDX1_H + 1; -- index2: low
  constant c_PIPE_IDX2_H : integer := c_PIPE_IDX2_L + 1 - 1; -- index2: high

  constant c_PIPE_IDX3_L : integer := c_PIPE_IDX2_H + 1; -- index3: low
  constant c_PIPE_IDX3_H : integer := c_PIPE_IDX3_L + 1 - 1; -- index3: high

  signal data_pipe_tmp0 : std_logic_vector(c_PIPE_IDX3_H downto 0); -- temporary input pipe
  signal data_pipe_tmp1 : std_logic_vector(c_PIPE_IDX3_H downto 0); -- temporary output pipe

  signal sof_sync_rx  : std_logic; -- first word
  signal eof_sync_rx  : std_logic; -- last word
  signal rd_sync_rx   : std_logic; -- read flag
  signal addr_sync_rx : std_logic_vector(o_fifo_addr'range); -- address

  ---------------------------------------------------------------------
  -- cross clock domain: user to regdecode
  ---------------------------------------------------------------------
  -- FIFO depth (expressed in number of words)
  constant c_FIFO_DEPTH2     : integer := 512;
  -- FIFO prog_full threshold (expressed in words)
  constant c_FIFO_PROG_FULL2 : integer := c_FIFO_DEPTH2 - 16;
  -- FIFO width (expressed in bits)
  constant c_FIFO_WIDTH2     : integer := c_FIFO_IDX4_H + 1;

  -- fifo: write side
  -- fifo: write
  signal wr_tmp2    : std_logic;
  -- fifo: data_in
  signal data_tmp2  : std_logic_vector(c_FIFO_WIDTH2 - 1 downto 0);
  -- fifo: full flag
  -- signal full2        : std_logic;
  -- fifo: prog_full flag
  signal prog_full2 : std_logic;
  -- fifo: rst_busy flag
  -- signal wr_rst_busy2 : std_logic;

  -- resynchronized errors
  signal errors_sync2 : std_logic_vector(3 downto 0);
  -- resynchronized empty flag
  signal empty_sync2  : std_logic;

  -- fifo: read side
  -- fifo: read
  signal rd3          : std_logic;
  -- fifo: data_out
  signal data_tmp3    : std_logic_vector(c_FIFO_WIDTH2 - 1 downto 0);
  -- fifo: empty flag
  signal empty3       : std_logic;
  -- fifo: data_valid flag
  signal data_valid3  : std_logic;
  -- fifo: rst_busy flag
  signal rd_rst_busy3 : std_logic;

  -- first word
  signal sof3  : std_logic;
  -- last word
  signal eof3  : std_logic;
  -- address
  signal addr3 : std_logic_vector(i_addr'range);
  -- data
  signal data3 : std_logic_vector(i_data'range);

  -- cross clock domain of the prog full flag: i_out_clk -> i_clk
  signal prog_full_fsm : std_logic;

  ---------------------------------------------------------------------
  -- error latching
  ---------------------------------------------------------------------
  constant c_NB_ERRORS : integer := 7; -- define the width of the temporary errors signals
  signal error_tmp     : std_logic_vector(c_NB_ERRORS - 1 downto 0); -- temporary input errors
  signal error_tmp_bis : std_logic_vector(c_NB_ERRORS - 1 downto 0); -- temporary output errors

begin

  ---------------------------------------------------------------------
  -- FSM
  --  It has 2 modes:
  --    . RAM writting by outputting the input data
  --    . RAM reading by generating RAM addresses
  ---------------------------------------------------------------------

  p_decode_state : process(addr_r1, cnt_r1, sm_state_r1, i_addr,
                           i_addr_range_min, i_data_valid, i_start_auto_rd, prog_full_fsm) is
  begin
    sof_next        <= '0';
    eof_next        <= '0';
    sel_wr_next     <= '0';
    data_valid_next <= '0';
    cnt_next        <= cnt_r1;
    addr_next       <= addr_r1;
    error_next      <= '0';
    case sm_state_r1 is
      when E_RST =>
        sm_state_next <= E_WAIT;

      when E_WAIT =>
        cnt_next <= (others => '0');
        if i_start_auto_rd = '1' then
        -- auto read data in the RAM
          sof_next        <= '1';
          data_valid_next <= '1';
          sel_wr_next     <= '0';
          addr_next       <= unsigned(i_addr_range_min);

          if i_data_valid = '1' then
            error_next <= '1';
          else
            error_next <= '0';
          end if;
          sm_state_next <= E_AUTO_RD;
        else
        -- write data in the RAM
          sof_next        <= '0';
          eof_next        <= '0';
          data_valid_next <= i_data_valid;
          sel_wr_next     <= '1';
          addr_next       <= unsigned(i_addr);
          sm_state_next   <= E_WAIT;
        end if;

      when E_AUTO_RD =>
        -- check wr command during the auto-rd
        if i_data_valid = '1' then
          error_next <= '1';
        else
          error_next <= '0';
        end if;

        if prog_full_fsm = '0' then
          -- auto generate address
          data_valid_next <= '1';
          sel_wr_next     <= '0';
          addr_next       <= addr_r1 + 1;
          cnt_next        <= cnt_r1 + 1;
          if cnt_r1 = to_unsigned(c_CNT_MAX - 1 - 1, cnt_r1'length) then  -- -1 start from @0 and -1 to anticipate
            eof_next      <= '1';
            sm_state_next <= E_WAIT;
          else
            sm_state_next <= E_AUTO_RD;
          end if;
        else
          -- pause the address generation
          sm_state_next <= E_AUTO_RD;

        end if;

      when others =>
        sm_state_next <= E_RST;
    end case;
  end process p_decode_state;

  ---------------------------------------------------------------------
  -- State process : register signals
  ---------------------------------------------------------------------
  p_state : process(i_clk) is
  begin
    if rising_edge(i_clk) then
      if i_rst = '1' then
        sm_state_r1 <= E_RST;
      else
        sm_state_r1 <= sm_state_next;
      end if;
      sof_r1        <= sof_next;
      eof_r1        <= eof_next;
      sel_wr_r1     <= sel_wr_next;
      data_valid_r1 <= data_valid_next;
      cnt_r1        <= cnt_next;
      addr_r1       <= addr_next;
      error_r1      <= error_next;

    end if;
  end process p_state;

  ---------------------------------------------------------------------
  -- sync with fsm out
  ---------------------------------------------------------------------
  inst_pipeliner_sync_with_fsm_out : entity work.pipeliner
    generic map(
      g_NB_PIPES   => 1,
      g_DATA_WIDTH => i_data'length
      )
    port map(
      i_clk  => i_clk,
      i_data => i_data,
      o_data => data_r1
      );

  ---------------------------------------------------------------------
  -- wr fifo: cross clock domain
  --    .from the i_clk clock domain to the i_out_clk clock domain
  ---------------------------------------------------------------------
  wr_rst_tmp0                                   <= i_rst;
  wr_tmp0                                       <= data_valid_r1;
  data_tmp0(c_FIFO_IDX4_H)                      <= sel_wr_r1;
  data_tmp0(c_FIFO_IDX3_H)                      <= sof_r1;
  data_tmp0(c_FIFO_IDX2_H)                      <= eof_r1;
  data_tmp0(c_FIFO_IDX1_H downto c_FIFO_IDX1_L) <= std_logic_vector(addr_r1);
  data_tmp0(c_FIFO_IDX0_H downto c_FIFO_IDX0_L) <= data_r1;

  inst_fifo_async_with_error_regdecode_to_user : entity work.fifo_async_with_error
    generic map(
      g_CDC_SYNC_STAGES   => 2,
      g_FIFO_MEMORY_TYPE  => "auto",
      g_FIFO_READ_LATENCY => c_FIFO_READ_LATENCY,
      g_FIFO_WRITE_DEPTH  => c_FIFO_DEPTH0,
      g_READ_DATA_WIDTH   => data_tmp0'length,
      g_READ_MODE         => "std",
      g_RELATED_CLOCKS    => 0,
      g_WRITE_DATA_WIDTH  => data_tmp0'length,
      ---------------------------------------------------------------------
      -- resynchronization: fifo errors/empty flag
      ---------------------------------------------------------------------
      g_SYNC_SIDE         => "wr"  -- define the clock side where status/errors is resynchronised. Possible value "wr" or "rd"
      )
    port map(
      ---------------------------------------------------------------------
      -- write side
      ---------------------------------------------------------------------
      i_wr_clk        => i_clk,
      i_wr_rst        => wr_rst_tmp0,
      i_wr_en         => wr_tmp0,
      i_wr_din        => data_tmp0,
      o_wr_full       => open,
      o_wr_rst_busy   => open,
      ---------------------------------------------------------------------
      -- read side
      ---------------------------------------------------------------------
      i_rd_clk        => i_out_clk,
      i_rd_en         => rd1,
      o_rd_dout_valid => data_valid1,
      o_rd_dout       => data_tmp1,
      o_rd_empty      => empty1,
      o_rd_rst_busy   => rd_rst_busy1,
      ---------------------------------------------------------------------
      -- resynchronized errors/status
      ---------------------------------------------------------------------
      o_errors_sync   => errors_sync1,
      o_empty_sync    => empty_sync1
      );

  rd1 <= '1' when empty1 = '0' and rd_rst_busy1 = '0' else '0';

  sel_wr1 <= data_tmp1(c_FIFO_IDX4_H);
  sof1    <= data_tmp1(c_FIFO_IDX3_H);
  eof1    <= data_tmp1(c_FIFO_IDX2_H);
  addr1   <= data_tmp1(c_FIFO_IDX1_H downto c_FIFO_IDX1_L);
  data1   <= data_tmp1(c_FIFO_IDX0_H downto c_FIFO_IDX0_L);

  ---------------------------------------------------------------------
  -- generate output
  ---------------------------------------------------------------------
  p_compute_flag : process(i_out_clk) is
  begin
    if rising_edge(i_out_clk) then
      sof_sync_r1 <= sof1;
      eof_sync_r1 <= eof1;
      -- generate flag
      if data_valid1 = '1' then
        if sel_wr1 = '1' then
          wr_sync_r1 <= '1';
          rd_sync_r1 <= '0';
        else
          wr_sync_r1 <= '0';
          rd_sync_r1 <= '1';
        end if;
      else
        wr_sync_r1 <= '0';
        rd_sync_r1 <= '0';

      end if;
      addr_sync_r1 <= addr1;
      data_sync_r1 <= data1;
    end if;
  end process p_compute_flag;
  ---------------------------------------------------------------------
  -- to the user: add optional delay
  ---------------------------------------------------------------------
  data_pipe_tmp2(c_IDX3_H)                 <= wr_sync_r1;
  data_pipe_tmp2(c_IDX2_H)                 <= rd_sync_r1;
  data_pipe_tmp2(c_IDX1_H downto c_IDX1_L) <= addr_sync_r1;
  data_pipe_tmp2(c_IDX0_H downto c_IDX0_L) <= data_sync_r1;

  inst_pipeliner_add_delay_out : entity work.pipeliner
    generic map(
      g_NB_PIPES   => c_DELAY_OUT,
      g_DATA_WIDTH => data_pipe_tmp2'length
      )
    port map(
      i_clk  => i_out_clk,
      i_data => data_pipe_tmp2,
      o_data => data_pipe_tmp3
      );

  wr_sync_ry   <= data_pipe_tmp3(c_IDX3_H);
  rd_sync_ry   <= data_pipe_tmp3(c_IDX2_H);
  addr_sync_ry <= data_pipe_tmp3(c_IDX1_H downto c_IDX1_L);
  data_sync_ry <= data_pipe_tmp3(c_IDX0_H downto c_IDX0_L);

  ---------------------------------------------------------------------
  -- to the user: output
  ---------------------------------------------------------------------
  o_ram_wr_en      <= wr_sync_ry;
  o_ram_rd_en      <= rd_sync_ry;
  o_ram_wr_rd_addr <= addr_sync_ry;
  o_ram_wr_data    <= data_sync_ry;

  ---------------------------------------------------------------------
  -- sync with the Reading of the RAM output
  ---------------------------------------------------------------------
  data_pipe_tmp0(c_PIPE_IDX3_H)                      <= sof_sync_r1;
  data_pipe_tmp0(c_PIPE_IDX2_H)                      <= eof_sync_r1;
  data_pipe_tmp0(c_PIPE_IDX1_H)                      <= rd_sync_r1;
  data_pipe_tmp0(c_PIPE_IDX0_H downto c_PIPE_IDX0_L) <= addr_sync_r1;

  inst_pipeliner_sync_with_rd_ram_out : entity work.pipeliner
    generic map(
      g_NB_PIPES   => c_ADDR_DELAY_OUT,
      g_DATA_WIDTH => data_pipe_tmp0'length
      )
    port map(
      i_clk  => i_out_clk,
      i_data => data_pipe_tmp0,
      o_data => data_pipe_tmp1
      );

  sof_sync_rx  <= data_pipe_tmp1(c_PIPE_IDX3_H);
  eof_sync_rx  <= data_pipe_tmp1(c_PIPE_IDX2_H);
  rd_sync_rx   <= data_pipe_tmp1(c_PIPE_IDX1_H);
  addr_sync_rx <= data_pipe_tmp1(c_PIPE_IDX0_H downto c_PIPE_IDX0_L);

  ---------------------------------------------------------------------
  -- check the path latency
  ---------------------------------------------------------------------
  -- assert not (rd_sync_rx = i_ram_rd_valid)
  -- report "[regdecode_pipe_wr_rd_ram_manager]: the internal pipeliner latency is not identical to the rd RAM latency.
  -- Change the g_RD_RAM_LATENCY value." severity error;

  ---------------------------------------------------------------------
  -- cross clock domain:
  --  from the i_out_clk clock domain to the i_clk clock domain
  ---------------------------------------------------------------------
  wr_tmp2                                       <= i_ram_rd_valid;
  data_tmp2(c_FIFO_IDX3_H)                      <= sof_sync_rx;
  data_tmp2(c_FIFO_IDX2_H)                      <= eof_sync_rx;
  data_tmp2(c_FIFO_IDX1_H downto c_FIFO_IDX1_L) <= addr_sync_rx;
  data_tmp2(c_FIFO_IDX0_H downto c_FIFO_IDX0_L) <= i_ram_rd_data;

  inst_fifo_async_with_error_prog_full_user_to_regdecode : entity work.fifo_async_with_error_prog_full
    generic map(
      g_CDC_SYNC_STAGES   => 2,
      g_FIFO_MEMORY_TYPE  => "auto",
      g_FIFO_READ_LATENCY => c_FIFO_READ_LATENCY,
      g_FIFO_WRITE_DEPTH  => c_FIFO_DEPTH2,
      g_PROG_FULL_THRESH  => c_FIFO_PROG_FULL2,
      g_READ_DATA_WIDTH   => data_tmp2'length,
      g_READ_MODE         => "std",
      g_RELATED_CLOCKS    => 0,
      g_WRITE_DATA_WIDTH  => data_tmp2'length,
      ---------------------------------------------------------------------
      -- resynchronization: fifo errors/empty flag
      ---------------------------------------------------------------------

      g_SYNC_SIDE => "rd"  -- define the clock side where status/errors is resynchronised. Possible value "wr" or "rd"

      )
    port map(
      ---------------------------------------------------------------------
      -- write side
      ---------------------------------------------------------------------
      i_wr_clk        => i_out_clk,
      i_wr_rst        => i_out_rst,
      i_wr_en         => wr_tmp2,
      i_wr_din        => data_tmp2,
      o_wr_full       => open,
      o_wr_prog_full  => prog_full2,
      o_wr_rst_busy   => open,
      ---------------------------------------------------------------------
      -- read side
      ---------------------------------------------------------------------
      i_rd_clk        => i_clk,
      i_rd_en         => rd3,
      o_rd_dout_valid => data_valid3,
      o_rd_dout       => data_tmp3,
      o_rd_empty      => empty3,
      o_rd_rst_busy   => rd_rst_busy3,
      ---------------------------------------------------------------------
      -- resynchronized errors/status
      ---------------------------------------------------------------------
      o_errors_sync   => errors_sync2,
      o_empty_sync    => empty_sync2
      );

  rd3 <= i_fifo_rd when rd_rst_busy3 = '0' else '0';

  sof3  <= data_tmp3(c_FIFO_IDX3_H);
  eof3  <= data_tmp3(c_FIFO_IDX2_H);
  addr3 <= data_tmp3(c_FIFO_IDX1_H downto c_FIFO_IDX1_L);
  data3 <= data_tmp3(c_FIFO_IDX0_H downto c_FIFO_IDX0_L);

  ---------------------------------------------------------------------
  -- synchronize prog full : i_out_clk -> i_clk
  --   used by the fsm to pause the auto-rd address generation
  ---------------------------------------------------------------------
  inst_single_bit_synchronizer_fifo2 : entity work.single_bit_synchronizer
    generic map(
      g_DEST_SYNC_FF  => 2,
      g_SRC_INPUT_REG => 1
      )
    port map(
      ---------------------------------------------------------------------
      -- source
      ---------------------------------------------------------------------
      i_src_clk  => i_out_clk,          -- source clock
      i_src      => prog_full2,  -- input signal to be synchronized to dest_clk domain
      ---------------------------------------------------------------------
      -- destination
      ---------------------------------------------------------------------
      i_dest_clk => i_clk,              -- destination clock domain
      o_dest     => prog_full_fsm  -- src_in synchronized to the destination clock domain. This output is registered.
      );

  ---------------------------------------------------------------------
  -- to the regdecode: output
  ---------------------------------------------------------------------
  o_fifo_sof        <= sof3;
  o_fifo_eof        <= eof3;
  o_fifo_data_valid <= data_valid3;
  o_fifo_addr       <= addr3;
  o_fifo_data       <= data3;
  o_fifo_empty      <= empty3;


  ---------------------------------------------------------------------
  -- Error latching
  ---------------------------------------------------------------------
  error_tmp(6) <= error_r1;  -- fsm error: receive a wr command during the auto rd.
  error_tmp(5) <= errors_sync2(2) or errors_sync2(3);  -- fifo2: fifo rst error
  error_tmp(4) <= errors_sync2(1);      -- fifo2: fifo rd empty
  error_tmp(3) <= errors_sync2(0);      -- fifo2: fifo wr error
  error_tmp(2) <= errors_sync1(2) or errors_sync1(3);  -- fifo0: fifo rst error
  error_tmp(1) <= errors_sync1(1);      -- fifo0: fifo rd empty
  error_tmp(0) <= errors_sync1(0);      -- fifo0: fifo wr full

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

  o_errors(15 downto 9) <= (others => '0');
  o_errors(8)           <= error_tmp_bis(6);  -- fsm error: receive a wr command during the auto rd.
  o_errors(7)           <= '0';
  o_errors(6)           <= error_tmp_bis(5);  -- fifo2: rst error
  o_errors(5)           <= error_tmp_bis(4);  -- fifo2: fifo rd empty error
  o_errors(4)           <= error_tmp_bis(3);  -- fifo2: fifo wr full error
  o_errors(3)           <= '0';         -- fifo0: rst error
  o_errors(2)           <= error_tmp_bis(2);  -- fifo0: rst error
  o_errors(1)           <= error_tmp_bis(1);  -- fifo0: fifo rd empty error
  o_errors(0)           <= error_tmp_bis(0);  -- fifo0: fifo wr full error

  o_status(7 downto 2) <= (others => '0');
  o_status(1)          <= empty_sync2;  -- fifo2: empty
  o_status(0)          <= empty_sync1;  -- fifo0: empty

  ---------------------------------------------------------------------
  -- for simulation only
  ---------------------------------------------------------------------
  assert not (error_tmp_bis(6) = '1') report "[regdecode_pipe_wr_rd_ram_manager] => fsm error: receive a wr command during the auto rd address generation " severity error;

  assert not (error_tmp_bis(5) = '1') report "[regdecode_pipe_wr_rd_ram_manager] => FIFO2 is used before the end of the initialization " severity error;
  assert not (error_tmp_bis(4) = '1') report "[regdecode_pipe_wr_rd_ram_manager] => FIFO2 read an empty FIFO" severity error;
  assert not (error_tmp_bis(3) = '1') report "[regdecode_pipe_wr_rd_ram_manager] => FIFO2 write a full FIFO" severity error;

  assert not (error_tmp_bis(2) = '1') report "[regdecode_pipe_wr_rd_ram_manager] => FIFO0 is used before the end of the initialization " severity error;
  assert not (error_tmp_bis(1) = '1') report "[regdecode_pipe_wr_rd_ram_manager] => FIFO0 read an empty FIFO" severity error;
  assert not (error_tmp_bis(0) = '1') report "[regdecode_pipe_wr_rd_ram_manager] => FIFO0 write a full FIFO" severity error;

end architecture RTL;
