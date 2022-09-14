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
--!   @file                   regdecode_pipe_wr_rd_ram_manager.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
-- This module is used to drive a RAM. 2 modes are available according the value of the i_start_auto_rd and i_data_valid signals.
--   . to configure the RAM content
--   . to auto-generate the read address in order to read the RAM content
--
-- -------------------------------------------------------------------------------------------------------------





library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fpasim;

entity regdecode_pipe_wr_rd_ram_manager is
  generic(
    g_RD_RAM_LATENCY : integer  := 2; -- define the RAM latency during the reading
    g_ADDR_WIDTH_OUT : positive := 15 -- define the RAM address width
  );
  port(
    ---------------------------------------------------------------------
    -- from the regdecode: input @i_clk
    ---------------------------------------------------------------------
    i_clk            : in  std_logic;
    i_rst            : in  std_logic;
    -- command
    i_start_auto_rd  : in  std_logic;
    i_cnt_init_value : in  std_logic_vector(15 downto 0);
    -- data
    i_data_valid     : in  std_logic;
    i_addr           : in  std_logic_vector(15 downto 0);
    i_data           : in  std_logic_vector(15 downto 0);
    ---------------------------------------------------------------------
    -- from/to the user:  @i_out_clk
    ---------------------------------------------------------------------
    i_out_clk        : in  std_logic;
    i_rst_status     : in  std_logic;
    i_debug_pulse    : in  std_logic;
    -- ram: wr
    o_ram_wr_en      : out std_logic;
    o_ram_wr_rd_addr : out std_logic_vector(g_ADDR_WIDTH_OUT - 1 downto 0);
    o_ram_wr_data    : out std_logic_vector(15 downto 0);
    -- ram: rd
    o_ram_rd_en      : out std_logic;
    i_ram_rd_valid   : in  std_logic;
    i_ram_rd_data    : in  std_logic_vector(15 downto 0);
    ---------------------------------------------------------------------
    -- to the regdecode: @i_clk
    ---------------------------------------------------------------------
    i_fifo_rd             : in std_logic;
    o_fifo_sof            : out std_logic;
    o_fifo_eof            : out std_logic;
    o_fifo_data_valid     : out std_logic;
    o_fifo_addr           : out std_logic_vector(15 downto 0);
    o_fifo_data           : out std_logic_vector(15 downto 0);
    o_fifo_empty          : out std_logic;
    ---------------------------------------------------------------------
    -- errors/status @ i_out_clk
    ---------------------------------------------------------------------
    o_errors         : out std_logic_vector(15 downto 0);
    o_status         : out std_logic_vector(7 downto 0)
  );
end entity regdecode_pipe_wr_rd_ram_manager;

architecture RTL of regdecode_pipe_wr_rd_ram_manager is

  constant c_CNT_MAX    : unsigned(o_ram_wr_rd_addr'range) := (others => '1');
  ---------------------------------------------------------------------
  -- fsm
  ---------------------------------------------------------------------
  type t_state is (E_RST, E_WAIT, E_AUTO_RD);
  signal sm_state_r1   : t_state;
  signal sm_state_next : t_state;

  signal sof_next : std_logic;
  signal sof_r1   : std_logic;

  signal eof_next : std_logic;
  signal eof_r1   : std_logic;

  signal wr_next : std_logic;
  signal wr_r1   : std_logic;

  signal data_valid_next : std_logic;
  signal data_valid_r1   : std_logic;

  signal cnt_next : unsigned(o_ram_wr_rd_addr'range);
  signal cnt_r1   : unsigned(o_ram_wr_rd_addr'range);

  signal addr_next : unsigned(i_addr'range);
  signal addr_r1   : unsigned(i_addr'range);

  signal error_next : std_logic;
  signal error_r1   : std_logic;

  -- sync with fsm out
  ---------------------------------------------------------------------
  signal data_r1 : std_logic_vector(i_data'range);

  -- cross clock domain of error fifo flags : i_clk -> i_out_clk
  signal error_sync : std_logic;

  ---------------------------------------------------------------------
  -- cross clock domain: redecode to user
  ---------------------------------------------------------------------
  constant c_FIFO_IDX0_L : integer := 0;
  constant c_FIFO_IDX0_H : integer := c_FIFO_IDX0_L + i_data'length - 1;

  constant c_FIFO_IDX1_L : integer := c_FIFO_IDX0_H + 1;
  constant c_FIFO_IDX1_H : integer := c_FIFO_IDX1_L + i_addr'length - 1;

  constant c_FIFO_IDX2_L : integer := c_FIFO_IDX1_H + 1;
  constant c_FIFO_IDX2_H : integer := c_FIFO_IDX2_L + 1 - 1;

  constant c_FIFO_IDX3_L : integer := c_FIFO_IDX2_H + 1;
  constant c_FIFO_IDX3_H : integer := c_FIFO_IDX3_L + 1 - 1;

  constant c_FIFO_IDX4_L : integer := c_FIFO_IDX3_H + 1;
  constant c_FIFO_IDX4_H : integer := c_FIFO_IDX4_L + 1 - 1;


  constant c_FIFO_DEPTH0 : integer := 16; --see IP
  constant c_FIFO_WIDTH0 : integer := c_FIFO_IDX4_H + 1; --see IP
  
  signal wr_rst_tmp0 : std_logic;
  signal wr_tmp0      : std_logic;
  signal data_tmp0    : std_logic_vector(c_FIFO_WIDTH0 - 1 downto 0);
  signal full0        : std_logic;
  signal wr_rst_busy0 : std_logic;

  signal rd1          : std_logic;
  signal data_tmp1    : std_logic_vector(c_FIFO_WIDTH0 - 1 downto 0);
  signal empty1       : std_logic;
  signal data_valid1  : std_logic;
  signal rd_rst_busy1 : std_logic;

  signal sof1  : std_logic;
  signal eof1  : std_logic;
  signal wr1   : std_logic;
  signal addr1 : std_logic_vector(i_addr'range);
  signal data1 : std_logic_vector(i_data'range);

  signal error_status1 : std_logic_vector(1 downto 0);

  -- cross clock domain of error fifo flags : i_clk -> i_out_clk
  signal errors_tmp0      : std_logic_vector(1 downto 0);
  signal errors_tmp0_sync : std_logic_vector(1 downto 0);

  ---------------------------------------------------------------------
  -- compute flag
  ---------------------------------------------------------------------
  signal sof_sync_r1  : std_logic;
  signal eof_sync_r1  : std_logic;
  signal wr_sync_r1   : std_logic;
  signal rd_sync_r1   : std_logic;
  signal addr_sync_r1 : std_logic_vector(i_addr'range);
  signal data_sync_r1 : std_logic_vector(i_data'range);

  ---------------------------------------------------------------------
  -- sync with the rd RAM output 
  ---------------------------------------------------------------------
  constant c_PIPE_IDX0_L : integer := 0;
  constant c_PIPE_IDX0_H : integer := c_PIPE_IDX0_L + i_addr'length - 1;

  constant c_PIPE_IDX1_L : integer := c_PIPE_IDX0_H + 1;
  constant c_PIPE_IDX1_H : integer := c_PIPE_IDX1_L + 1 - 1;

  constant c_PIPE_IDX2_L : integer := c_PIPE_IDX1_H + 1;
  constant c_PIPE_IDX2_H : integer := c_PIPE_IDX2_L + 1 - 1;

  constant c_PIPE_IDX3_L : integer := c_PIPE_IDX2_H + 1;
  constant c_PIPE_IDX3_H : integer := c_PIPE_IDX3_L + 1 - 1;

  signal data_pipe_tmp0 : std_logic_vector(c_PIPE_IDX3_H downto 0);
  signal data_pipe_tmp1 : std_logic_vector(c_PIPE_IDX3_H downto 0);

  signal sof_sync_rx  : std_logic;
  signal eof_sync_rx  : std_logic;
  signal rd_sync_rx   : std_logic;
  signal addr_sync_rx : std_logic_vector(o_fifo_addr'range);

  ---------------------------------------------------------------------
  -- cross clock domain: user to regdecode
  ---------------------------------------------------------------------
  constant c_FIFO_DEPTH2     : integer := 32; --see IP
  constant c_FIFO_WIDTH2     : integer := c_FIFO_IDX4_H + 1; --see IP
  constant c_FIFO_PROG_FULL2 : integer := c_FIFO_DEPTH2 - 20;

  signal wr_tmp2      : std_logic;
  signal data_tmp2    : std_logic_vector(c_FIFO_WIDTH2 - 1 downto 0);
  signal full2        : std_logic;
  signal prog_full2        : std_logic;
  signal wr_rst_busy2 : std_logic;

  signal rd3          : std_logic;
  signal data_tmp3    : std_logic_vector(c_FIFO_WIDTH2 - 1 downto 0);
  signal empty3       : std_logic;
  signal data_valid3  : std_logic;
  signal rd_rst_busy3 : std_logic;

  signal sof3  : std_logic;
  signal eof3  : std_logic;
  signal addr3 : std_logic_vector(i_addr'range);
  signal data3 : std_logic_vector(i_data'range);

  signal error_status3 : std_logic_vector(1 downto 0);

  -- cross clock domain of error fifo flags: i_clk -> i_out_clk
  signal errors_tmp3      : std_logic_vector(2 downto 0);
  signal errors_tmp3_sync : std_logic_vector(2 downto 0);

  -- cross clock domain of the prog full flag: i_out_clk -> i_clk
  signal prog_full_fsm : std_logic;

  ---------------------------------------------------------------------
  -- error latching
  ---------------------------------------------------------------------
  constant NB_ERRORS_c : integer := 7;
  signal error_tmp     : std_logic_vector(NB_ERRORS_c - 1 downto 0);
  signal error_tmp_bis : std_logic_vector(NB_ERRORS_c - 1 downto 0);

begin

  ---------------------------------------------------------------------
  -- check generic parameter
  ---------------------------------------------------------------------
  assert not (i_addr'length >= o_ram_wr_rd_addr'length) report "[regdecode_pipe_wr_rd_ram_manager]: for design reason, the input address bus width must be >= to the output address bus width" severity error;

  ---------------------------------------------------------------------
  -- FSM
  ---------------------------------------------------------------------

  p_decode_state : process(addr_r1, cnt_r1, sm_state_r1, i_addr,
                           i_cnt_init_value, i_data_valid, i_start_auto_rd,prog_full_fsm) is
  begin
    sof_next        <= '0';
    eof_next        <= '0';
    wr_next         <= '0';
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
          sof_next        <= '1';
          data_valid_next <= '1';
          wr_next         <= '0';
          addr_next       <= unsigned(i_cnt_init_value);

          if i_data_valid = '1' then
            error_next <= '1';
          else
            error_next <= '0';
          end if;
          sm_state_next <= E_AUTO_RD;
        else
          sof_next        <= '0';
          eof_next        <= '0';
          data_valid_next <= i_data_valid;
          wr_next         <= '1';
          addr_next       <= unsigned(i_addr);
          sm_state_next  <= E_WAIT;
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
          wr_next         <= '0';
          addr_next       <= addr_r1 + 1;
          if cnt_r1 = c_CNT_MAX then
            eof_next       <= '1';
            sm_state_next <= E_WAIT;
          else
            cnt_next       <= cnt_r1 + 1;
            sm_state_next <= E_AUTO_RD;
          end if;
        else
        -- pause the address generation
        sm_state_next <= E_AUTO_RD;

        end if;

      when others => -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"
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
      eof_r1        <= eof_next;
      wr_r1         <= wr_next;
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
  --    .from the regdecode clock domain to the user clock domain
  ---------------------------------------------------------------------
  wr_rst_tmp0                                   <= i_rst;
  wr_tmp0                                       <= data_valid_r1;
  data_tmp0(c_FIFO_IDX4_H) <= wr_r1;
  data_tmp0(c_FIFO_IDX3_H) <= sof_r1;
  data_tmp0(c_FIFO_IDX2_H) <= eof_r1;
  data_tmp0(c_FIFO_IDX1_H downto c_FIFO_IDX1_L) <= std_logic_vector(addr_r1);
  data_tmp0(c_FIFO_IDX0_H downto c_FIFO_IDX0_L) <= data_r1;

  inst_fifo_async_regdecode_to_user : entity fpasim.fifo_async
    generic map(
      g_CDC_SYNC_STAGES   => 2,
      g_FIFO_MEMORY_TYPE  => "auto",
      g_FIFO_READ_LATENCY => 1,
      g_FIFO_WRITE_DEPTH  => c_FIFO_DEPTH0,
      g_READ_DATA_WIDTH   => data_tmp0'length,
      g_READ_MODE         => "std",
      g_RELATED_CLOCKS    => 0,
      g_WRITE_DATA_WIDTH  => data_tmp0'length
    )
    port map(
      ---------------------------------------------------------------------
      -- write side
      ---------------------------------------------------------------------
      i_wr_clk        => i_clk,         -- write clock
      i_wr_rst        => wr_rst_tmp0,   -- write reset 
      i_wr_en         => wr_tmp0,       -- write enable
      i_wr_din        => data_tmp0,     -- write data
      o_wr_full       => full0,         -- When asserted, this signal indicates that the FIFO is full (not destructive to the contents of the FIFO.)
      o_wr_rst_busy   => wr_rst_busy0,  -- Active-High indicator that the FIFO write domain is currently in a reset state
      ---------------------------------------------------------------------
      -- port B
      ---------------------------------------------------------------------
      i_rd_clk        => i_out_clk,
      i_rd_en         => rd1,           -- read enable (Must be held active-low when rd_rst_busy is active high)
      o_rd_dout_valid => data_valid1,   -- When asserted, this signal indicates that valid data is available on the output bus
      o_rd_dout       => data_tmp1,
      o_rd_empty      => empty1,        -- When asserted, this signal indicates that the FIFO is full (not destructive to the contents of the FIFO.)
      o_rd_rst_busy   => rd_rst_busy1   -- Active-High indicator that the FIFO read domain is currently in a reset state
    );

  rd1 <= '1' when empty1 = '0' else '0';

  wr1   <= data_tmp1(c_FIFO_IDX4_H);
  sof1  <= data_tmp1(c_FIFO_IDX3_H);
  eof1  <= data_tmp1(c_FIFO_IDX2_H);
  addr1 <= data_tmp1(c_FIFO_IDX1_H downto c_FIFO_IDX1_L);
  data1 <= data_tmp1(c_FIFO_IDX0_H downto c_FIFO_IDX0_L);

  ---------------------------------------------------------------------
  -- synchronize error fifo flags: i_clk -> i_out_clk
  ---------------------------------------------------------------------
  errors_tmp0(1) <= '1' when wr_tmp0 = '1' and wr_rst_busy0 = '1' else '0';
  errors_tmp0(0) <= '1' when wr_tmp0 = '1' and full0 = '1' else '0';
  gen_errors_sync_fifo0 : for i in errors_tmp0'range generate
    inst_single_bit_synchronizer_fifo0 : entity fpasim.single_bit_synchronizer
      generic map(
        g_DEST_SYNC_FF  => 2,
        g_SRC_INPUT_REG => 1
      )
      port map(
        ---------------------------------------------------------------------
        -- source
        ---------------------------------------------------------------------
        i_src_clk  => i_clk,            -- source clock
        i_src      => errors_tmp0(i),   -- input signal to be synchronized to dest_clk domain
        ---------------------------------------------------------------------
        -- destination
        ---------------------------------------------------------------------
        i_dest_clk => i_out_clk,        -- destination clock domain
        o_dest     => errors_tmp0_sync(i) -- src_in synchronized to the destination clock domain. This output is registered.   
      );

  end generate gen_errors_sync_fifo0;
  ---------------------------------------------------------------------
  -- generate output
  ---------------------------------------------------------------------
  p_compute_flag : process(i_clk) is
  begin
    if rising_edge(i_clk) then
      sof_sync_r1  <= sof1;
      eof_sync_r1  <= eof1;
      -- generate flag
      if data_valid1 = '1' then
        if wr1 = '1' then
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
  -- to the user: output
  ---------------------------------------------------------------------
  o_ram_wr_en      <= wr_sync_r1;
  o_ram_rd_en      <= rd_sync_r1;
  -- truncate MSB bits if necessary
  o_ram_wr_rd_addr <= addr_sync_r1(o_ram_wr_rd_addr'range);
  o_ram_wr_data    <= data_sync_r1;

  ---------------------------------------------------------------------
  -- sync with the Reading of the RAM output
  ---------------------------------------------------------------------
  data_pipe_tmp0(c_PIPE_IDX3_H)                      <= sof_sync_r1;
  data_pipe_tmp0(c_PIPE_IDX2_H)                      <= eof_sync_r1;
  data_pipe_tmp0(c_PIPE_IDX1_H)                      <= rd_sync_r1;
  data_pipe_tmp0(c_PIPE_IDX0_H downto c_PIPE_IDX0_L) <= addr_sync_r1;
  inst_pipeliner_sync_with_rd_ram_out : entity work.pipeliner
    generic map(
      g_NB_PIPES   => g_RD_RAM_LATENCY,
      g_DATA_WIDTH => data_pipe_tmp0'length
    )
    port map(
      i_clk  => i_out_clk,
      i_data => data_pipe_tmp0,
      o_data => data_pipe_tmp1
    );
  sof_sync_rx                                        <= data_pipe_tmp1(c_PIPE_IDX3_H);
  eof_sync_rx                                        <= data_pipe_tmp1(c_PIPE_IDX2_H);
  rd_sync_rx                                         <= data_pipe_tmp1(c_PIPE_IDX1_H);
  addr_sync_rx                                       <= data_pipe_tmp1(c_PIPE_IDX0_H downto c_PIPE_IDX0_L);

  ---------------------------------------------------------------------
  -- check the path latency
  ---------------------------------------------------------------------
  assert not (rd_sync_rx = i_ram_rd_valid) report "[regdecode_pipe_wr_rd_ram_manager]: the internal pipeliner latency is not identical to the rd RAM latency. Change the g_RD_RAM_LATENCY value." severity error;
  ---------------------------------------------------------------------
  -- cross clock domain: 
  --  from the user clock domain to the regdecode clock domain
  ---------------------------------------------------------------------
  wr_tmp2                                       <= i_ram_rd_valid;
  data_tmp2(c_FIFO_IDX3_H) <= sof_sync_rx;
  data_tmp2(c_FIFO_IDX2_H) <= eof_sync_rx;
  data_tmp2(c_FIFO_IDX1_H downto c_FIFO_IDX1_L) <= addr_sync_rx;
  data_tmp2(c_FIFO_IDX0_H downto c_FIFO_IDX0_L) <= i_ram_rd_data;

  inst_fifo_async_with_prog_full_user_to_regdecode : entity fpasim.fifo_async_with_prog_full
    generic map(
      g_CDC_SYNC_STAGES   => 2,
      g_FIFO_MEMORY_TYPE  => "auto",
      g_FIFO_READ_LATENCY => 1,
      g_FIFO_WRITE_DEPTH  => c_FIFO_DEPTH2,
      g_PROG_FULL_THRESH  => c_FIFO_PROG_FULL2,
      g_READ_DATA_WIDTH   => data_tmp2'length,
      g_READ_MODE         => "std",
      g_RELATED_CLOCKS    => 0,
      g_WRITE_DATA_WIDTH  => data_tmp2'length
    )
    port map(
      ---------------------------------------------------------------------
      -- write side
      ---------------------------------------------------------------------
      i_wr_clk        => i_out_clk,     -- write clock
      i_wr_rst        => i_rst,         -- write reset 
      i_wr_en         => wr_tmp2,       -- write enable
      i_wr_din        => data_tmp2,     -- write data
      o_wr_full       => full2,         -- When asserted, this signal indicates that the FIFO is full (not destructive to the contents of the FIFO.)
      o_wr_prog_full  => prog_full2,    -- Programmable Full: This signal is asserted when the number of words in the FIFO is greater than or equal to the programmable full threshold value. It is de-asserted when the number of words in the FIFO is less than the programmable full threshold value.
      o_wr_rst_busy   => wr_rst_busy2,  -- Active-High indicator that the FIFO write domain is currently in a reset state
      ---------------------------------------------------------------------
      -- port B
      ---------------------------------------------------------------------
      i_rd_clk        => i_clk,
      i_rd_en         => rd3,           -- read enable (Must be held active-low when rd_rst_busy is active high)
      o_rd_dout_valid => data_valid3,   -- When asserted, this signal indicates that valid data is available on the output bus
      o_rd_dout       => data_tmp3,
      o_rd_empty      => empty3,        -- When asserted, this signal indicates that the FIFO is full (not destructive to the contents of the FIFO.)
      o_rd_rst_busy   => rd_rst_busy3   -- Active-High indicator that the FIFO read domain is currently in a reset state
    );

  rd3 <= i_fifo_rd;

  sof3  <= data_tmp3(c_FIFO_IDX3_H);
  eof3  <= data_tmp3(c_FIFO_IDX2_H);
  addr3 <= data_tmp3(c_FIFO_IDX1_H downto c_FIFO_IDX1_L);
  data3 <= data_tmp3(c_FIFO_IDX0_H downto c_FIFO_IDX0_L);

  ---------------------------------------------------------------------
  -- synchronize prog full : i_out_clk -> i_clk
  --   used by the fsm to pause the auto-rd address generation
  ---------------------------------------------------------------------
  inst_single_bit_synchronizer_fifo2 : entity fpasim.single_bit_synchronizer
      generic map(
        g_DEST_SYNC_FF  => 2,
        g_SRC_INPUT_REG => 1
      )
      port map(
        ---------------------------------------------------------------------
        -- source
        ---------------------------------------------------------------------
        i_src_clk  => i_out_clk,            -- source clock
        i_src      => prog_full2,   -- input signal to be synchronized to dest_clk domain
        ---------------------------------------------------------------------
        -- destination
        ---------------------------------------------------------------------
        i_dest_clk => i_clk,        -- destination clock domain
        o_dest     => prog_full_fsm -- src_in synchronized to the destination clock domain. This output is registered.   
      );

  ---------------------------------------------------------------------
  -- synchronize error fifo flags: i_clk -> i_out_clk
  ---------------------------------------------------------------------
  errors_tmp3(2) <= empty3;
  errors_tmp3(1) <= '1' when rd3 = '1' and rd_rst_busy3 = '1' else '0';
  errors_tmp3(0) <= '1' when rd3 = '1' and empty3 = '1' else '0';
  gen_errors_sync_fifo2 : for i in errors_tmp3'range generate
    inst_single_bit_synchronizer_fifo2 : entity fpasim.single_bit_synchronizer
      generic map(
        g_DEST_SYNC_FF  => 2,
        g_SRC_INPUT_REG => 1
      )
      port map(
        ---------------------------------------------------------------------
        -- source
        ---------------------------------------------------------------------
        i_src_clk  => i_clk,            -- source clock
        i_src      => errors_tmp3(i),   -- input signal to be synchronized to dest_clk domain
        ---------------------------------------------------------------------
        -- destination
        ---------------------------------------------------------------------
        i_dest_clk => i_out_clk,        -- destination clock domain
        o_dest     => errors_tmp3_sync(i) -- src_in synchronized to the destination clock domain. This output is registered.   
      );

  end generate gen_errors_sync_fifo2;

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
  -- cross clock domain: i_clk -> i_out_clk
  --   fsm error
  ---------------------------------------------------------------------
  inst_single_bit_synchronizer_error_fsm : entity fpasim.single_bit_synchronizer
    generic map(
      g_DEST_SYNC_FF  => 2,
      g_SRC_INPUT_REG => 1
    )
    port map(
      ---------------------------------------------------------------------
      -- source
      ---------------------------------------------------------------------
      i_src_clk  => i_clk,              -- source clock
      i_src      => error_r1,           -- input signal to be synchronized to dest_clk domain
      ---------------------------------------------------------------------
      -- destination
      ---------------------------------------------------------------------
      i_dest_clk => i_out_clk,          -- destination clock domain
      o_dest     => error_sync          -- src_in synchronized to the destination clock domain. This output is registered.   
    );

  ---------------------------------------------------------------------
  -- Error latching
  ---------------------------------------------------------------------
  error_tmp(6) <= error_sync;           -- fsm error: receive a wr command during the auto rd.
  error_tmp(5) <= errors_tmp3_sync(0);  -- fifo2: empty error
  error_tmp(4) <= wr_tmp2 and full2;     -- fifo2: full error
  error_tmp(3) <= (wr_tmp2 and wr_rst_busy2) or errors_tmp3_sync(1); -- fifo2: rst error
  error_tmp(2) <= rd1 and empty1;       -- fifo0: error empty
  error_tmp(1) <= errors_tmp0_sync(0);  -- fifo0: error full
  error_tmp(0) <= errors_tmp0_sync(1) or (rd1 and rd_rst_busy1); -- fifo0: rst error
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

  -- error remapping
  error_status3(1) <= error_tmp_bis(5); -- fifo2: empty error
  error_status3(0) <= error_tmp_bis(4); -- fifo2: full error

  error_status1(1) <= error_tmp_bis(2); -- fifo0: empty error
  error_status1(0) <= error_tmp_bis(1); -- fifo0: full error

  o_errors(15 downto 9) <= (others => '0');
  o_errors(8)           <= error_tmp_bis(6); -- fsm error: receive a wr command during the auto rd.
  o_errors(7 downto 6)  <= (others => '0');
  o_errors(5)           <= error_tmp_bis(3); -- fifo2: rst error
  o_errors(4)           <= error_tmp_bis(0); -- fifo0: rst error
  o_errors(2)           <= error_status3(1); -- fifo2: empty error
  o_errors(2)           <= error_status3(0); -- fifo2: full error
  o_errors(1)           <= error_status1(1); -- fifo0: empty error
  o_errors(0)           <= error_status1(0); -- fifo0: full error

  o_status(7 downto 2) <= (others => '0');
  o_status(1)          <= errors_tmp3_sync(2);-- fifo2: empty
  o_status(0)          <= empty1;

  ---------------------------------------------------------------------
  -- for simulation only
  ---------------------------------------------------------------------
  assert not (error_tmp_bis(6) = '1') report "[regdecode_pipe_wr_rd_ram_manager] => fsm error: receive a wr command during the auto rd address generation " severity error;

  assert not (error_tmp_bis(3) = '1') report "[regdecode_pipe_wr_rd_ram_manager] => FIFO2 is used before the end of the initialization " severity error;
  assert not (error_tmp_bis(0) = '1') report "[regdecode_pipe_wr_rd_ram_manager] => FIFO0 is used before the end of the initialization " severity error;

  assert not (error_status3(0) = '1') report "[regdecode_pipe_wr_rd_ram_manager] => FIFO2 write a full FIFO" severity error;
  assert not (error_status3(1) = '1') report "[regdecode_pipe_wr_rd_ram_manager] => FIFO2 read an empty FIFO" severity error;

  assert not (error_status1(0) = '1') report "[regdecode_pipe_wr_rd_ram_manager] => FIFO0 write a full FIFO" severity error;
  assert not (error_status1(1) = '1') report "[regdecode_pipe_wr_rd_ram_manager] => FIFO0 read an empty FIFO" severity error;

end architecture RTL;
