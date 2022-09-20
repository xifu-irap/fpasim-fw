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
--!   @file                   regdecode_wire_wr_rd.vhd 
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

entity regdecode_wire_wr_rd is
  generic(
    g_DATA_WIDTH_OUT : positive := 15   -- define the RAM address width
  );
  port(
    ---------------------------------------------------------------------
    -- from the regdecode: input @i_clk
    ---------------------------------------------------------------------
    i_clk             : in  std_logic; -- clock
    i_rst             : in  std_logic; -- rst
    -- data
    i_data_valid      : in  std_logic; -- data valid
    i_data            : in  std_logic_vector(g_DATA_WIDTH_OUT - 1 downto 0); -- data value
    ---------------------------------------------------------------------
    -- from/to the user:  @i_out_clk
    ---------------------------------------------------------------------
    i_out_clk         : in  std_logic; -- output clock
    i_rst_status      : in  std_logic; -- reset error flag(s)
    i_debug_pulse     : in  std_logic; -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
    -- ram: wr
    o_data_valid      : out std_logic; -- data valid
    o_data            : out std_logic_vector(g_DATA_WIDTH_OUT - 1 downto 0); -- data
    ---------------------------------------------------------------------
    -- to the regdecode: @i_clk
    ---------------------------------------------------------------------
    i_fifo_rd         : in  std_logic; -- fifo read enable
    o_fifo_data_valid : out std_logic; -- fifo data valid
    o_fifo_data       : out std_logic_vector(g_DATA_WIDTH_OUT - 1 downto 0); -- fifo data
    o_fifo_empty      : out std_logic; -- fifo empty flag
    ---------------------------------------------------------------------
    -- errors/status @ i_out_clk
    ---------------------------------------------------------------------
    o_errors          : out std_logic_vector(15 downto 0); -- output errors
    o_status          : out std_logic_vector(7 downto 0) -- output status
  );
end entity regdecode_wire_wr_rd;

architecture RTL of regdecode_wire_wr_rd is
  constant c_WR_TO_RD_DELAY : integer := 0;

  ---------------------------------------------------------------------
  -- cross clock domain: redecode to user
  ---------------------------------------------------------------------
  constant c_FIFO_IDX0_L : integer := 0;
  constant c_FIFO_IDX0_H : integer := c_FIFO_IDX0_L + i_data'length - 1;

  constant c_FIFO_DEPTH0 : integer := 16; --see IP
  constant c_FIFO_WIDTH0 : integer := c_FIFO_IDX0_H + 1; --see IP

  signal wr_rst_tmp0  : std_logic;
  signal wr_tmp0      : std_logic;
  signal data_tmp0    : std_logic_vector(c_FIFO_WIDTH0 - 1 downto 0);
  -- signal full0        : std_logic;
  -- signal wr_rst_busy0 : std_logic;

  signal rd1          : std_logic;
  signal data_tmp1    : std_logic_vector(c_FIFO_WIDTH0 - 1 downto 0);
  signal empty1       : std_logic;
  signal data_valid1  : std_logic;
  -- signal rd_rst_busy1 : std_logic;

  signal data1 : std_logic_vector(i_data'range);

    -- synchronized errors
  signal errors_sync1 : std_logic_vector(3 downto 0);
  signal empty_sync1  : std_logic;

  ---------------------------------------------------------------------
  -- sync with the rd RAM output 
  ---------------------------------------------------------------------
  constant c_PIPE_IDX0_L : integer := 0;
  constant c_PIPE_IDX0_H : integer := c_PIPE_IDX0_L + i_data'length - 1;

  constant c_PIPE_IDX1_L : integer := c_PIPE_IDX0_H + 1;
  constant c_PIPE_IDX1_H : integer := c_PIPE_IDX1_L + 1 - 1;

  signal data_pipe_tmp0 : std_logic_vector(c_PIPE_IDX1_H downto 0);
  signal data_pipe_tmp1 : std_logic_vector(c_PIPE_IDX1_H downto 0);

  signal data_valid_sync_rx : std_logic;
  signal data_sync_rx       : std_logic_vector(o_data'range);

  ---------------------------------------------------------------------
  -- cross clock domain: user to regdecode
  ---------------------------------------------------------------------
  constant c_FIFO_DEPTH2     : integer := 32; --see IP
  constant c_FIFO_WIDTH2     : integer := c_FIFO_IDX0_H + 1; --see IP

  -- wr side
  signal wr_tmp2      : std_logic;
  signal data_tmp2    : std_logic_vector(c_FIFO_WIDTH2 - 1 downto 0);
  -- signal full2        : std_logic;
  -- signal wr_rst_busy2 : std_logic;

  -- synchronized errors
  signal errors_sync2 : std_logic_vector(3 downto 0);
  signal empty_sync2  : std_logic;

  -- rd side
  signal rd3          : std_logic;
  signal data_tmp3    : std_logic_vector(c_FIFO_WIDTH2 - 1 downto 0);
  signal empty3       : std_logic;
  signal data_valid3  : std_logic;
  -- signal rd_rst_busy3 : std_logic;

  signal data3 : std_logic_vector(i_data'range);

  ---------------------------------------------------------------------
  -- error latching
  ---------------------------------------------------------------------
  constant NB_ERRORS_c : integer := 6;
  signal error_tmp     : std_logic_vector(NB_ERRORS_c - 1 downto 0);
  signal error_tmp_bis : std_logic_vector(NB_ERRORS_c - 1 downto 0);

begin

  ---------------------------------------------------------------------
  -- wr fifo: cross clock domain
  --    .from the regdecode clock domain to the user clock domain
  ---------------------------------------------------------------------
  wr_rst_tmp0                                   <= i_rst;
  wr_tmp0                                       <= i_data_valid;
  data_tmp0(c_FIFO_IDX0_H downto c_FIFO_IDX0_L) <= i_data;

  inst_fifo_async_with_error_regdecode_to_user : entity fpasim.fifo_async_with_error
    generic map(
      g_CDC_SYNC_STAGES   => 2,
      g_FIFO_MEMORY_TYPE  => "auto",
      g_FIFO_READ_LATENCY => 1,
      g_FIFO_WRITE_DEPTH  => c_FIFO_DEPTH0,
      g_READ_DATA_WIDTH   => data_tmp0'length,
      g_READ_MODE         => "std",
      g_RELATED_CLOCKS    => 0,
      g_WRITE_DATA_WIDTH  => data_tmp0'length,
      ---------------------------------------------------------------------
      -- resynchronization: fifo errors/empty flag
      ---------------------------------------------------------------------
      g_SYNC_SIDE         => "rd",      -- define the clock side where status/errors is resynchronised. Possible value "wr" or "rd"
      g_DEST_SYNC_FF      => 2,         -- Number of register stages used to synchronize signal in the destination clock domain.   
      g_SRC_INPUT_REG     => 1          -- 0- Do not register input (src_in), 1- Register input (src_in) once using src_clk 
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
      o_rd_rst_busy   => open,   
      ---------------------------------------------------------------------
      -- resynchronized errors/status 
      ---------------------------------------------------------------------
      o_errors_sync   => errors_sync1,
      o_empty_sync    => empty_sync1
    );

  rd1 <= '1' when empty1 = '0' else '0';

  data1 <= data_tmp1(c_FIFO_IDX0_H downto c_FIFO_IDX0_L);


  ---------------------------------------------------------------------
  -- to the user: output
  ---------------------------------------------------------------------
  o_data_valid <= data_valid1;
  o_data       <= data1;

  ---------------------------------------------------------------------
  -- optional: add latency before writing
  ---------------------------------------------------------------------
  data_pipe_tmp0(c_PIPE_IDX1_H)                      <= data_valid1;
  data_pipe_tmp0(c_PIPE_IDX0_H downto c_PIPE_IDX0_L) <= data1;
  inst_pipeliner_sync_with_rd_ram_out : entity work.pipeliner
    generic map(
      g_NB_PIPES   => c_WR_TO_RD_DELAY,
      g_DATA_WIDTH => data_pipe_tmp0'length
    )
    port map(
      i_clk  => i_out_clk,
      i_data => data_pipe_tmp0,
      o_data => data_pipe_tmp1
    );
  data_valid_sync_rx                                 <= data_pipe_tmp1(c_PIPE_IDX1_H);
  data_sync_rx                                       <= data_pipe_tmp1(c_PIPE_IDX0_H downto c_PIPE_IDX0_L);

  ---------------------------------------------------------------------
  -- cross clock domain: 
  --  from the user clock domain to the regdecode clock domain
  ---------------------------------------------------------------------
  wr_tmp2                                       <= data_valid_sync_rx;
  data_tmp2(c_FIFO_IDX0_H downto c_FIFO_IDX0_L) <= data_sync_rx;

  inst_fifo_async_with_error_user_to_regdecode : entity fpasim.fifo_async_with_error
    generic map(
      g_CDC_SYNC_STAGES   => 2,
      g_FIFO_MEMORY_TYPE  => "auto",
      g_FIFO_READ_LATENCY => 1,
      g_FIFO_WRITE_DEPTH  => c_FIFO_DEPTH2,
      g_READ_DATA_WIDTH   => data_tmp2'length,
      g_READ_MODE         => "std",
      g_RELATED_CLOCKS    => 0,
      g_WRITE_DATA_WIDTH  => data_tmp2'length,
      ---------------------------------------------------------------------
      -- resynchronization: fifo errors/empty flag
      ---------------------------------------------------------------------
      g_SYNC_SIDE         => "wr",      -- define the clock side where status/errors is resynchronised. Possible value "wr" or "rd"
      g_DEST_SYNC_FF      => 2,         -- Number of register stages used to synchronize signal in the destination clock domain.   
      g_SRC_INPUT_REG     => 1          -- 0- Do not register input (src_in), 1- Register input (src_in) once using src_clk 

    )
    port map(
      ---------------------------------------------------------------------
      -- write side
      ---------------------------------------------------------------------
      i_wr_clk        => i_out_clk,    
      i_wr_rst        => i_rst,        
      i_wr_en         => wr_tmp2,      
      i_wr_din        => data_tmp2,    
      o_wr_full       => open,        
      o_wr_rst_busy   => open,  
      ---------------------------------------------------------------------
      -- read side
      ---------------------------------------------------------------------
      i_rd_clk        => i_clk,
      i_rd_en         => rd3,          
      o_rd_dout_valid => data_valid3,  
      o_rd_dout       => data_tmp3,
      o_rd_empty      => empty3,       
      o_rd_rst_busy   => open,   
      ---------------------------------------------------------------------
      -- resynchronized errors/status 
      ---------------------------------------------------------------------
      o_errors_sync   => errors_sync2,
      o_empty_sync    => empty_sync2
    );

  rd3   <= i_fifo_rd;
  data3 <= data_tmp3(c_FIFO_IDX0_H downto c_FIFO_IDX0_L);


  ---------------------------------------------------------------------
  -- to the regdecode: output
  ---------------------------------------------------------------------
  o_fifo_data_valid <= data_valid3;
  o_fifo_data       <= data3;
  o_fifo_empty      <= empty3;

  ---------------------------------------------------------------------
  -- Error latching
  ---------------------------------------------------------------------
  error_tmp(5) <= errors_sync2(2) or errors_sync2(3); -- fifo2: fifo rst error
  error_tmp(4) <= errors_sync2(1);      -- fifo2: fifo rd empty
  error_tmp(3) <= errors_sync2(0);      -- fifo2: fifo wr error
  error_tmp(2) <= errors_sync1(2) or errors_sync1(3); -- fifo0: fifo rst error
  error_tmp(1) <= errors_sync1(1);      -- fifo0: fifo rd empty
  error_tmp(0) <= errors_sync1(0);      -- fifo0: fifo wr full
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

  o_errors(15 downto 7)  <= (others => '0');
  o_errors(6)           <= error_tmp_bis(5); -- fifo2: rst error
  o_errors(5)           <= error_tmp_bis(4); -- fifo2: fifo rd empty error
  o_errors(4)           <= error_tmp_bis(3); -- fifo2: fifo wr full error
  o_errors(3)           <= '0'; 
  o_errors(2)           <= error_tmp_bis(2); -- fifo0: rst error
  o_errors(1)           <= error_tmp_bis(1); -- fifo0: fifo rd empty error
  o_errors(0)           <= error_tmp_bis(0); -- fifo0: fifo wr full error

  o_status(7 downto 2) <= (others => '0');
  o_status(1)          <= empty_sync2;  -- fifo2: empty
  o_status(0)          <= empty_sync1;  -- fifo0: empty
  ---------------------------------------------------------------------
  -- for simulation only
  ---------------------------------------------------------------------
  assert not (error_tmp_bis(5) = '1') report "[regdecode_wire_wr_rd] => FIFO0 is used before the end of the initialization " severity error;
  assert not (error_tmp_bis(4) = '1') report "[regdecode_wire_wr_rd] => FIFO2 read an empty FIFO" severity error;
  assert not (error_tmp_bis(3) = '1') report "[regdecode_wire_wr_rd] => FIFO2 write a full FIFO" severity error;

  assert not (error_tmp_bis(2) = '1') report "[regdecode_wire_wr_rd] => FIFO2 is used before the end of the initialization " severity error;
  assert not (error_tmp_bis(1) = '1') report "[regdecode_wire_wr_rd] => FIFO0 read an empty FIFO" severity error;
  assert not (error_tmp_bis(0) = '1') report "[regdecode_wire_wr_rd] => FIFO0 write a full FIFO" severity error;

end architecture RTL;
