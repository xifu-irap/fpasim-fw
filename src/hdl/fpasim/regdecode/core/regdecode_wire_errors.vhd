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
--!   This module synchronizes the input errors/status from the i_clk source clock domain to the i_out_clk destination clock domain.
--!   Then, it generates a common error pulse signal on the first error detection.
--!   
--!   The architecture principle is as follows:
--!       @i_out_clk source clock domain                                         |                                  @ i_clk destination clock domain
--!                                                   |<-------------  single_bit_array_synchronizer <------------- i_errors7/i_status7
--!                                                   |<-------------  single_bit_array_synchronizer <-------------         .
--!        o_errors/o_status <--------- select output |<-------------  single_bit_array_synchronizer <-------------         .
--!                                                   |<-------------  single_bit_array_synchronizer <-------------         .
--!                                                   |<-------------  single_bit_array_synchronizer <------------- i_errors0/i_status0
--!
--!                                                                        |<-------------  /=0 ?    <------------- errors7 synchronized
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

library fpasim;

entity regdecode_wire_errors is
  generic(
    g_ERROR_SEL_WIDTH : integer := 8
  );
  port(
    i_clk               : in  std_logic;
    -- errors
    i_reg_wire_errors7  : in  std_logic_vector(31 downto 0);
    i_reg_wire_errors6  : in  std_logic_vector(31 downto 0);
    i_reg_wire_errors5  : in  std_logic_vector(31 downto 0);
    i_reg_wire_errors4  : in  std_logic_vector(31 downto 0);
    i_reg_wire_errors3  : in  std_logic_vector(31 downto 0);
    i_reg_wire_errors2  : in  std_logic_vector(31 downto 0);
    i_reg_wire_errors1  : in  std_logic_vector(31 downto 0);
    i_reg_wire_errors0  : in  std_logic_vector(31 downto 0);
    -- status
    i_reg_wire_status7  : in  std_logic_vector(31 downto 0);
    i_reg_wire_status6  : in  std_logic_vector(31 downto 0);
    i_reg_wire_status5  : in  std_logic_vector(31 downto 0);
    i_reg_wire_status4  : in  std_logic_vector(31 downto 0);
    i_reg_wire_status3  : in  std_logic_vector(31 downto 0);
    i_reg_wire_status2  : in  std_logic_vector(31 downto 0);
    i_reg_wire_status1  : in  std_logic_vector(31 downto 0);
    i_reg_wire_status0  : in  std_logic_vector(31 downto 0);
    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    i_out_clk           : in  std_logic;
    i_error_sel         : in  std_logic_vector(g_ERROR_SEL_WIDTH - 1 downto 0);
    o_wire_errors_valid : out std_logic;
    o_wire_errors       : out std_logic_vector(31 downto 0);
    o_wire_status       : out std_logic_vector(31 downto 0)
  );
end entity regdecode_wire_errors;

architecture RTL of regdecode_wire_errors is

  constant c_NB_ERRORS : integer := 8;
  type t_errors is array (0 to c_NB_ERRORS - 1) of std_logic_vector(i_reg_wire_errors0'range);
  signal errors_tmp0   : t_errors;
  signal errors_tmp1   : t_errors;

  type t_status is array (0 to c_NB_ERRORS - 1) of std_logic_vector(i_reg_wire_status0'range);
  signal status_tmp0 : t_status;
  signal status_tmp1 : t_status;

  ---------------------------------------------------------------------
  -- select output error and 
  -- for each error word, generate an associated trig bit if the error value is different of 0
  ---------------------------------------------------------------------
  signal trig_errors_vec_r1 : std_logic_vector(c_NB_ERRORS - 1 downto 0);
  signal errors_r1          : std_logic_vector(i_reg_wire_errors0'range);
  signal status_r1          : std_logic_vector(i_reg_wire_status0'range);

  ---------------------------------------------------------------------
  -- generate a common error bit for each change of trig_errors_vec
  ---------------------------------------------------------------------
  signal trig_errors_vec_r2   : std_logic_vector(c_NB_ERRORS - 1 downto 0);
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

  errors_tmp0(7) <= i_reg_wire_errors7;
  errors_tmp0(6) <= i_reg_wire_errors6;
  errors_tmp0(5) <= i_reg_wire_errors5;
  errors_tmp0(4) <= i_reg_wire_errors4;
  errors_tmp0(3) <= i_reg_wire_errors3;
  errors_tmp0(2) <= i_reg_wire_errors2;
  errors_tmp0(1) <= i_reg_wire_errors1;
  errors_tmp0(0) <= i_reg_wire_errors0;

  gen_synchronisateur_error : for i in errors_tmp0'range generate
    inst_single_bit_array_synchronizer_error : entity work.single_bit_array_synchronizer
      generic map(
        -- +---------------------------------------------------------------------------------------------------------------------+
        -- | DEST_SYNC_FF         | Integer            | Range: 2 - 10. Default value = 4.                                       |
        -- |---------------------------------------------------------------------------------------------------------------------|
        -- | Number of register stages used to synchronize signal in the destination clock domain.                               |
        g_DEST_SYNC_FF  => 4,
        -- +---------------------------------------------------------------------------------------------------------------------+
        -- | INIT_SYNC_FF         | Integer            | Allowed values: 0, 1. Default value = 0.                                |
        -- |---------------------------------------------------------------------------------------------------------------------|
        -- | 0- Disable behavioral simulation initialization value(s) on synchronization registers.                              |
        -- | 1- Enable behavioral simulation initialization value(s) on synchronization registers.                               |
        -- g_INIT_SYNC_FF : integer := 4;
        -- +---------------------------------------------------------------------------------------------------------------------+
        -- | SIM_ASSERT_CHK       | Integer            | Allowed values: 0, 1. Default value = 0.                                |
        -- |---------------------------------------------------------------------------------------------------------------------|
        -- | 0- Disable simulation message reporting. Messages related to potential misuse will not be reported.                 |
        -- | 1- Enable simulation message reporting. Messages related to potential misuse will be reported.                      |
        --g_SIM_ASSERT_CHK : integer := 0;
        -- +---------------------------------------------------------------------------------------------------------------------+
        -- | SRC_INPUT_REG        | Integer            | Allowed values: 1, 0. Default value = 1.                                |
        -- |---------------------------------------------------------------------------------------------------------------------|
        -- | 0- Do not register input (src_in)                                                                                   |
        -- | 1- Register input (src_in) once using src_clk                                                                       |
        g_SRC_INPUT_REG => 1,
        -- +---------------------------------------------------------------------------------------------------------------------+
        -- | WIDTH                | Integer            | Range: 1 - 1024. Default value = 2.                                     |
        -- |---------------------------------------------------------------------------------------------------------------------|
        -- | Width of single-bit array (src_in) that will be synchronized to destination clock domain.                           |
        -- +-----
        g_WIDTH         => errors_tmp0(i)'length
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
        o_dest     => errors_tmp1(i)
      );

  end generate gen_synchronisateur_error;

  -- status register
  ---------------------------------------------------------------------
  status_tmp0(7) <= i_reg_wire_status7;
  status_tmp0(6) <= i_reg_wire_status6;
  status_tmp0(5) <= i_reg_wire_status5;
  status_tmp0(4) <= i_reg_wire_status4;
  status_tmp0(3) <= i_reg_wire_status3;
  status_tmp0(2) <= i_reg_wire_status2;
  status_tmp0(1) <= i_reg_wire_status1;
  status_tmp0(0) <= i_reg_wire_status0;

  gen_synchronisateur_status : for i in status_tmp0'range generate
    inst_single_bit_array_synchronizer_status : entity work.single_bit_array_synchronizer
      generic map(
        -- +---------------------------------------------------------------------------------------------------------------------+
        -- | DEST_SYNC_FF         | Integer            | Range: 2 - 10. Default value = 4.                                       |
        -- |---------------------------------------------------------------------------------------------------------------------|
        -- | Number of register stages used to synchronize signal in the destination clock domain.                               |
        g_DEST_SYNC_FF  => 4,
        -- +---------------------------------------------------------------------------------------------------------------------+
        -- | INIT_SYNC_FF         | Integer            | Allowed values: 0, 1. Default value = 0.                                |
        -- |---------------------------------------------------------------------------------------------------------------------|
        -- | 0- Disable behavioral simulation initialization value(s) on synchronization registers.                              |
        -- | 1- Enable behavioral simulation initialization value(s) on synchronization registers.                               |
        -- g_INIT_SYNC_FF : integer := 4;
        -- +---------------------------------------------------------------------------------------------------------------------+
        -- | SIM_ASSERT_CHK       | Integer            | Allowed values: 0, 1. Default value = 0.                                |
        -- |---------------------------------------------------------------------------------------------------------------------|
        -- | 0- Disable simulation message reporting. Messages related to potential misuse will not be reported.                 |
        -- | 1- Enable simulation message reporting. Messages related to potential misuse will be reported.                      |
        --g_SIM_ASSERT_CHK : integer := 0;
        -- +---------------------------------------------------------------------------------------------------------------------+
        -- | SRC_INPUT_REG        | Integer            | Allowed values: 1, 0. Default value = 1.                                |
        -- |---------------------------------------------------------------------------------------------------------------------|
        -- | 0- Do not register input (src_in)                                                                                   |
        -- | 1- Register input (src_in) once using src_clk                                                                       |
        g_SRC_INPUT_REG => 1,
        -- +---------------------------------------------------------------------------------------------------------------------+
        -- | WIDTH                | Integer            | Range: 1 - 1024. Default value = 2.                                     |
        -- |---------------------------------------------------------------------------------------------------------------------|
        -- | Width of single-bit array (src_in) that will be synchronized to destination clock domain.                           |
        -- +-----
        g_WIDTH         => status_tmp0(i)'length
      )
      port map(
        ---------------------------------------------------------------------
        -- source
        ---------------------------------------------------------------------
        i_src_clk  => i_clk,            -- source clock
        i_src      => status_tmp0(i),   -- input signal to be synchronized to dest_clk domain
        ---------------------------------------------------------------------
        -- destination
        ---------------------------------------------------------------------
        i_dest_clk => i_out_clk,        -- destination clock domain
        o_dest     => status_tmp1(i)
      );

  end generate gen_synchronisateur_status;

  -----------------------------------------------------------------
  -- select output errors and 
  -- for each error word, generate an associated trig bit if the error value is different of 0
  -----------------------------------------------------------------
  p_select_error_status : process(i_out_clk) is
  begin
    if rising_edge(i_out_clk) then
      for i in 0 to errors_tmp1'range loop
        if i = to_integer(unsigned(i_error_sel)) then
          errors_r1 <= errors_tmp1(i);
          status_r1 <= status_tmp1(i);
        end if;
        -- generate one bit error by error word
        if unsigned(errors_tmp1(i)) /= to_unsigned(0, errors_tmp1(i)'length) then
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
  p_generate_common_error : process(i_out_clk) is
  begin
    if rising_edge(i_out_clk) then
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
  p_detect_rising_edge_of_common_error : process(i_out_clk) is
  begin
    if rising_edge(i_out_clk) then
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

  inst_pipeliner_sync_with_the_detect_rising_edge_of_common_error_process : entity fpasim.pipeliner
    generic map(
      g_NB_PIPES   => 4,                -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => data_pipe_tmp0'length -- width of the input/output data.  Possibles values: [1, integer max value[
    )
    port map(
      i_clk  => i_out_clk,              -- clock signal
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
