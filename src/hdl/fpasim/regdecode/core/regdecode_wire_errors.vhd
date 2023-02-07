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
--!   @file                   regdecode_wire_errors.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--! 
--!   This module synchronizes the input errors/status from the i_out_clk source clock domain to the i_clk destination clock domain.
--!   Then, it generates a common error pulse signal on the first error detection.
--!   
--!   The architecture principle is as follows:
--!       @i_clk source clock domain                                         |                                 
--!                                                   |<-------------  fifo_async <------------- i_reg_wire_errors0 (@i_out_clk)
--!                                                   |<-------------  fifo_async <-------------         .
--!        o_errors/o_status <--------- select output |<-------------  fifo_async <------------- i_reg_wire_errors3 (@i_out_clk)
--!                                                   |<-------------  pass       <------------- i_usb_reg_errors0 (@i_clk)
--!                                                   |<-------------  pass       <-------------          .  
--!                                                   |<-------------  pass       <------------- i_usb_reg_errorsx (@i_clk)
--!                                                   |-------------------------------------------------------------------->
--!                                                                                                                         |
--!                                                                        |<-------------  /=0 ?    <------------- errorsx synchronized
--!                                                                        |<-------------  /=0 ?    <-------------         .
--!        errors_valid <-- rising_edge detection <-- /= last value? ------|<-------------  /=0 ?    <-------------         .
--!                                                                        |<-------------  /=0 ?    <-------------         .
--!                                                                        |<-------------  /=0 ?    <------------- errors0 synchronized
--!
--!   Note: 
--!      . the output common error pulse is generated only on the first error detection.
--!      So, the user needs to reset the errors to be able to generate an another common error pulse
-- -------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity regdecode_wire_errors is
  generic(
    g_ERROR_SEL_WIDTH : integer := 4
    );
  port(
    ---------------------------------------------------------------------
    -- input @i_out_clk
    ---------------------------------------------------------------------
    i_out_clk          : in std_logic;
    -- errors
    i_reg_wire_errors3 : in std_logic_vector(31 downto 0);
    i_reg_wire_errors2 : in std_logic_vector(31 downto 0);
    i_reg_wire_errors1 : in std_logic_vector(31 downto 0);
    i_reg_wire_errors0 : in std_logic_vector(31 downto 0);
    -- status
    i_reg_wire_status3 : in std_logic_vector(31 downto 0);
    i_reg_wire_status2 : in std_logic_vector(31 downto 0);
    i_reg_wire_status1 : in std_logic_vector(31 downto 0);
    i_reg_wire_status0 : in std_logic_vector(31 downto 0);

    ---------------------------------------------------------------------
    -- input @i_clk
    ---------------------------------------------------------------------
    i_clk               : in  std_logic;
    i_error_sel         : in  std_logic_vector(g_ERROR_SEL_WIDTH - 1 downto 0);
    -- errors
    i_usb_reg_errors6   : in  std_logic_vector(31 downto 0);
    i_usb_reg_errors5   : in  std_logic_vector(31 downto 0);
    i_usb_reg_errors4   : in  std_logic_vector(31 downto 0);
    i_usb_reg_errors3   : in  std_logic_vector(31 downto 0);
    i_usb_reg_errors2   : in  std_logic_vector(31 downto 0);
    i_usb_reg_errors1   : in  std_logic_vector(31 downto 0);
    i_usb_reg_errors0   : in  std_logic_vector(31 downto 0);
    -- status
    i_usb_reg_status6   : in  std_logic_vector(31 downto 0);
    i_usb_reg_status5   : in  std_logic_vector(31 downto 0);
    i_usb_reg_status4   : in  std_logic_vector(31 downto 0);
    i_usb_reg_status3   : in  std_logic_vector(31 downto 0);
    i_usb_reg_status2   : in  std_logic_vector(31 downto 0);
    i_usb_reg_status1   : in  std_logic_vector(31 downto 0);
    i_usb_reg_status0   : in  std_logic_vector(31 downto 0);
    ---------------------------------------------------------------------
    -- output @ i_clk
    ---------------------------------------------------------------------
    o_wire_errors_valid : out std_logic;
    o_wire_errors       : out std_logic_vector(31 downto 0);
    o_wire_status       : out std_logic_vector(31 downto 0)
    );
end entity regdecode_wire_errors;

architecture RTL of regdecode_wire_errors is

  constant c_NB_ERRORS : integer := 4;
  type t_errors is array (integer range <>) of std_logic_vector(i_reg_wire_errors0'range);
  signal errors_tmp0   : t_errors(0 to c_NB_ERRORS - 1);
  signal errors_tmp1   : t_errors(0 to c_NB_ERRORS - 1);

  type t_status is array (integer range <>) of std_logic_vector(i_reg_wire_status0'range);
  signal status_tmp0 : t_status(0 to c_NB_ERRORS - 1);
  signal status_tmp1 : t_status(0 to c_NB_ERRORS - 1);

  ---------------------------------------------------------------------
  -- select output error and 
  -- for each error word, generate an associated trig bit if the error value is different of 0
  ---------------------------------------------------------------------
  constant c_NB_ERRORS_ALL : integer := 11;
  signal errors_tmp        : t_errors(0 to c_NB_ERRORS_ALL - 1);
  signal status_tmp        : t_status(0 to c_NB_ERRORS_ALL - 1);

  signal trig_errors_vec_r1 : std_logic_vector(c_NB_ERRORS_ALL - 1 downto 0);
  signal errors_r1          : std_logic_vector(i_reg_wire_errors0'range);
  signal status_r1          : std_logic_vector(i_reg_wire_status0'range);

  ---------------------------------------------------------------------
  -- generate a common error bit for each change of trig_errors_vec
  ---------------------------------------------------------------------
  signal trig_errors_vec_r2   : std_logic_vector(c_NB_ERRORS_ALL - 1 downto 0);
  signal trig_common_error_r3 : std_logic;

  ---------------------------------------------------------------------
  -- 
  ---------------------------------------------------------------------
  signal trig_error_r4           : std_logic;
  signal trig_common_error_re_r5 : std_logic;

  ---------------------------------------------------------------------
  -- sync with pulse error generation
  ---------------------------------------------------------------------
  constant c_IDX0_L : integer := 0;
  constant c_IDX0_H : integer := c_IDX0_L + o_wire_errors'length - 1;

  constant c_IDX1_L : integer := c_IDX0_H + 1;
  constant c_IDX1_H : integer := c_IDX1_L + o_wire_status'length - 1;

  signal data_pipe_tmp0 : std_logic_vector(c_IDX1_H downto 0);
  signal data_pipe_tmp1 : std_logic_vector(c_IDX1_H downto 0);

  signal errors_r5 : std_logic_vector(i_reg_wire_errors0'range);
  signal status_r5 : std_logic_vector(i_reg_wire_status0'range);

begin

---------------------------------------------------------------------
-- cross clock domain: i_out_clk -> i_clk
---------------------------------------------------------------------
  errors_tmp0(3) <= i_reg_wire_errors3;
  errors_tmp0(2) <= i_reg_wire_errors2;
  errors_tmp0(1) <= i_reg_wire_errors1;
  errors_tmp0(0) <= i_reg_wire_errors0;

  gen_synchronisateur_error : for i in errors_tmp0'range generate
    signal data_r : t_errors(errors_tmp0'range)         := (others => (others => '0'));
    signal wr_r   : std_logic_vector(errors_tmp0'range) := (others => '0');

    signal wr_en_flag       : std_logic_vector(errors_tmp0'range);
    signal wr_din_flag      : t_errors(errors_tmp0'range);
    -- signal wr_full_flag     : std_logic_vector(errors_tmp0'range);
    signal wr_rst_busy_flag : std_logic_vector(errors_tmp0'range);
    signal rd_en_flag       : std_logic_vector(errors_tmp0'range);
    signal rd_dout_flag     : t_errors(errors_tmp0'range);
    signal rd_empty_flag    : std_logic_vector(errors_tmp0'range);
    signal rd_rst_busy_flag : std_logic_vector(errors_tmp0'range);

  begin

    p_detect_change : process(i_out_clk) is
    begin
      if rising_edge(i_out_clk) then
        data_r(i) <= errors_tmp0(i);
        if data_r(i) /= errors_tmp0(i) then
          wr_r(i) <= '1';
        else
          wr_r(i) <= '0';
        end if;
      end if;
    end process p_detect_change;

    wr_en_flag(i)  <= '1' when wr_r(i) = '1' and wr_rst_busy_flag(i) = '0' else '0';
    wr_din_flag(i) <= data_r(i);

    inst_fifo_async_flag : entity work.fifo_async
      generic map(
        g_CDC_SYNC_STAGES   => 2,
        g_FIFO_MEMORY_TYPE  => "distributed",
        g_FIFO_READ_LATENCY => 1,
        g_FIFO_WRITE_DEPTH  => 16,
        g_READ_DATA_WIDTH   => wr_din_flag(i)'length,
        g_READ_MODE         => "std",
        g_RELATED_CLOCKS    => 0,
        g_WRITE_DATA_WIDTH  => wr_din_flag(i)'length
        )
      port map(
        ---------------------------------------------------------------------
        -- write side
        ---------------------------------------------------------------------
        i_wr_clk        => i_out_clk,
        i_wr_rst        => '0',
        i_wr_en         => wr_en_flag(i),
        i_wr_din        => wr_din_flag(i),
        o_wr_full       => open,
        o_wr_rst_busy   => wr_rst_busy_flag(i),
        ---------------------------------------------------------------------
        -- read side
        ---------------------------------------------------------------------
        i_rd_clk        => i_clk,
        i_rd_en         => rd_en_flag(i),
        o_rd_dout_valid => open,
        o_rd_dout       => rd_dout_flag(i),
        o_rd_empty      => rd_empty_flag(i),
        o_rd_rst_busy   => rd_rst_busy_flag(i)
        );

    rd_en_flag(i) <= '1' when rd_empty_flag(i) = '0' and rd_rst_busy_flag(i) = '0' else '0';

    errors_tmp1(i) <= rd_dout_flag(i);

  end generate gen_synchronisateur_error;

  -- status register
  ---------------------------------------------------------------------
  status_tmp0(3) <= i_reg_wire_status3;
  status_tmp0(2) <= i_reg_wire_status2;
  status_tmp0(1) <= i_reg_wire_status1;
  status_tmp0(0) <= i_reg_wire_status0;

  gen_synchronisateur_status : for i in status_tmp0'range generate

    signal data_r : t_status(status_tmp0'range)         := (others => (others => '0'));
    signal wr_r   : std_logic_vector(status_tmp0'range) := (others => '0');

    signal wr_en_flag       : std_logic_vector(status_tmp0'range);
    signal wr_din_flag      : t_status(status_tmp0'range);
    -- signal wr_full_flag     : std_logic_vector(status_tmp0'range);
    signal wr_rst_busy_flag : std_logic_vector(status_tmp0'range);
    signal rd_en_flag       : std_logic_vector(status_tmp0'range);
    signal rd_dout_flag     : t_status(status_tmp0'range);
    signal rd_empty_flag    : std_logic_vector(status_tmp0'range);
    signal rd_rst_busy_flag : std_logic_vector(status_tmp0'range);

  begin

    p_detect_change : process(i_out_clk) is
    begin
      if rising_edge(i_out_clk) then
        data_r(i) <= status_tmp0(i);
        if data_r(i) /= status_tmp0(i) then
          wr_r(i) <= '1';
        else
          wr_r(i) <= '0';
        end if;
      end if;
    end process p_detect_change;

    wr_en_flag(i)  <= '1' when wr_r(i) = '1' and wr_rst_busy_flag(i) = '0' else '0';
    wr_din_flag(i) <= data_r(i);

    inst_fifo_async_flag : entity work.fifo_async
      generic map(
        g_CDC_SYNC_STAGES   => 2,
        g_FIFO_MEMORY_TYPE  => "distributed",
        g_FIFO_READ_LATENCY => 1,
        g_FIFO_WRITE_DEPTH  => 16,
        g_READ_DATA_WIDTH   => wr_din_flag(i)'length,
        g_READ_MODE         => "std",
        g_RELATED_CLOCKS    => 0,
        g_WRITE_DATA_WIDTH  => wr_din_flag(i)'length
        )
      port map(
        ---------------------------------------------------------------------
        -- write side
        ---------------------------------------------------------------------
        i_wr_clk        => i_out_clk,
        i_wr_rst        => '0',
        i_wr_en         => wr_en_flag(i),
        i_wr_din        => wr_din_flag(i),
        o_wr_full       => open,
        o_wr_rst_busy   => wr_rst_busy_flag(i),
        ---------------------------------------------------------------------
        -- read side
        ---------------------------------------------------------------------
        i_rd_clk        => i_clk,
        i_rd_en         => rd_en_flag(i),
        o_rd_dout_valid => open,
        o_rd_dout       => rd_dout_flag(i),
        o_rd_empty      => rd_empty_flag(i),
        o_rd_rst_busy   => rd_rst_busy_flag(i)
        );

    rd_en_flag(i) <= '1' when rd_empty_flag(i) = '0' and rd_rst_busy_flag(i) = '0' else '0';

    status_tmp1(i) <= rd_dout_flag(i);

  end generate gen_synchronisateur_status;

  -----------------------------------------------------------------
  -- select output errors and 
  -- for each error word, generate an associated trig bit if the error value is different of 0
  -----------------------------------------------------------------
  errors_tmp(10) <= errors_tmp1(3);
  errors_tmp(9) <= errors_tmp1(2);
  errors_tmp(8) <= errors_tmp1(1);
  errors_tmp(7) <= errors_tmp1(0);
  errors_tmp(6) <= i_usb_reg_errors6;
  errors_tmp(5) <= i_usb_reg_errors5;
  errors_tmp(4) <= i_usb_reg_errors4;
  errors_tmp(3) <= i_usb_reg_errors3;
  errors_tmp(2) <= i_usb_reg_errors2;
  errors_tmp(1) <= i_usb_reg_errors1;
  errors_tmp(0) <= i_usb_reg_errors0;

  status_tmp(10) <= status_tmp1(3);
  status_tmp(9) <= status_tmp1(2);
  status_tmp(8) <= status_tmp1(1);
  status_tmp(7) <= status_tmp1(0);
  status_tmp(6) <= i_usb_reg_status6;
  status_tmp(5) <= i_usb_reg_status5;
  status_tmp(4) <= i_usb_reg_status4;
  status_tmp(3) <= i_usb_reg_status3;
  status_tmp(2) <= i_usb_reg_status2;
  status_tmp(1) <= i_usb_reg_status1;
  status_tmp(0) <= i_usb_reg_status0;

  p_select_error_status : process(i_clk) is
  begin
    if rising_edge(i_clk) then
      case i_error_sel is
        when "0000" =>
          errors_r1 <= errors_tmp(0);
          status_r1 <= status_tmp(0);
        when "0001" =>
          errors_r1 <= errors_tmp(1);
          status_r1 <= status_tmp(1);
        when "0010" =>
          errors_r1 <= errors_tmp(2);
          status_r1 <= status_tmp(2);
        when "0011" =>
          errors_r1 <= errors_tmp(3);
          status_r1 <= status_tmp(3);
        when "0100" =>
          errors_r1 <= errors_tmp(4);
          status_r1 <= status_tmp(4);
        when "0101" =>
          errors_r1 <= errors_tmp(5);
          status_r1 <= status_tmp(5);
        when "0110" =>
          errors_r1 <= errors_tmp(6);
          status_r1 <= status_tmp(6);
        when "0111" =>
          errors_r1 <= errors_tmp(7);
          status_r1 <= status_tmp(7);
        when "1000" =>
          errors_r1 <= errors_tmp(8);
          status_r1 <= status_tmp(8);
        when "1001" =>
          errors_r1 <= errors_tmp(9);
          status_r1 <= status_tmp(9);
        when others =>
          errors_r1 <= errors_tmp(10);
          status_r1 <= status_tmp(10);
      end case;

      for i in errors_tmp1'range loop
        --if i = to_integer(unsigned(i_error_sel)) then
        --  errors_r1 <= errors_tmp1(i);
        --  status_r1 <= status_tmp1(i);
        --end if;
        -- generate one bit error by error word
        if unsigned(errors_tmp(i)) /= to_unsigned(0, errors_tmp(i)'length) then
          trig_errors_vec_r1(i) <= '1';
        else
          trig_errors_vec_r1(i) <= '0';
        end if;
      end loop;
    end if;
  end process p_select_error_status;

  ---------------------------------------------------------------------
  -- generate a common error bit for each change of trig_errors_vec
  ---------------------------------------------------------------------
  p_generate_common_error : process(i_clk) is
  begin
    if rising_edge(i_clk) then
      trig_errors_vec_r2 <= trig_errors_vec_r1;
      if trig_errors_vec_r2 /= trig_errors_vec_r1 then
        trig_common_error_r3 <= '1';
      else
        trig_common_error_r3 <= '0';
      end if;
    end if;
  end process p_generate_common_error;

  ---------------------------------------------------------------------
  -- detect the rising edge of the common error
  ---------------------------------------------------------------------
  p_detect_rising_edge_of_common_error : process(i_clk) is
  begin
    if rising_edge(i_clk) then
      trig_error_r4 <= trig_common_error_r3;
      if trig_common_error_r3 = '1' and trig_error_r4 = '0' then
        trig_common_error_re_r5 <= '1';
      else
        trig_common_error_re_r5 <= '0';
      end if;
    end if;
  end process p_detect_rising_edge_of_common_error;

  ---------------------------------------------------------------------
  -- sync with the p_detect_rising_edge_of_common_error out
  ---------------------------------------------------------------------
  data_pipe_tmp0(c_IDX1_H downto c_IDX1_L) <= status_r1;
  data_pipe_tmp0(c_IDX0_H downto c_IDX0_L) <= errors_r1;

  inst_pipeliner_sync_with_the_detect_rising_edge_of_common_error_process : entity work.pipeliner
    generic map(
      g_NB_PIPES   => 4,  -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => data_pipe_tmp0'length  -- width of the input/output data.  Possibles values: [1, integer max value[
      )
    port map(
      i_clk  => i_clk,                  -- clock signal
      i_data => data_pipe_tmp0,         -- input data
      o_data => data_pipe_tmp1          -- output data with/without delay
      );

  status_r5 <= data_pipe_tmp1(c_IDX1_H downto c_IDX1_L);
  errors_r5 <= data_pipe_tmp1(c_IDX0_H downto c_IDX0_L);

  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_wire_errors_valid <= trig_common_error_re_r5;
  o_wire_errors       <= errors_r5;
  o_wire_status       <= status_r5;

end architecture RTL;
