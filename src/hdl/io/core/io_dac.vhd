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
--    @file                   io_dac.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details                
--
--    This module inserts zeros after each FIFO read.
--    The output data flow has the following structure:
--
--    Example0: we assume the dac frame is generated every 8 input dac samples and no latency between the input and the output
--    i_dac_valid:   1   1   1   1   1   1   1   1   
--    i_dac      :   a1  a2  a3  a4  a5  a6  a7  a8  
--    o_dac_valid:   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1
--    o_dac_frame:   1   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0
--    o_dac      :   a1  0   a2  0   a3  0   a4  0   a5  0   a6  0   a7  0   a8  0   a9 
--
--    Example0:
--      Input ports -> optionnal latency -> fpga specific IO generation -> output port
--
-- -------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity io_dac is
  generic(
    g_OUTPUT_LATENCY : natural := 0  -- add latency before the output IO. Possible values: [0; max integer value[
    );
  port(
    ---------------------------------------------------------------------
    -- input: @i_clk
    ---------------------------------------------------------------------
    i_clk         : in std_logic; -- clock
    i_rst         : in std_logic; -- reset
    i_rst_status  : in std_logic; -- reset error flag(s)
    i_debug_pulse : in std_logic; -- error mode (transparent vs capture). Possible values: '1': delay the error(s), '0': capture the error(s)
    i_dac_valid   : in std_logic; -- dac data valid
    i_dac_frame   : in std_logic; -- data frame flag
    i_dac         : in std_logic_vector(15 downto 0); -- dac data value
    ---------------------------------------------------------------------
    -- output @i_out_clk
    ---------------------------------------------------------------------
    i_out_clk      : in  std_logic;      -- clock
    i_out_rst      : in std_logic;       -- rst synchronized @i_out_clk
    -- from reset_top: @i_out_clk
    i_io_clk_rst  : in  std_logic;  -- Clock reset: Reset connected to clocking elements in the circuit
    i_io_rst      : in  std_logic;  -- Reset connected to all other elements in the circuit
    -- to pads:
    -- clock
    o_dac_clk_p   : out std_logic;
    o_dac_clk_n   : out std_logic;
    -- frame flag
    o_dac_frame_p : out std_logic;
    o_dac_frame_n : out std_logic;
    -- data
    o_dac0_p      : out std_logic;
    o_dac0_n      : out std_logic;
    o_dac1_p      : out std_logic;
    o_dac1_n      : out std_logic;
    o_dac2_p      : out std_logic;
    o_dac2_n      : out std_logic;
    o_dac3_p      : out std_logic;
    o_dac3_n      : out std_logic;
    o_dac4_p      : out std_logic;
    o_dac4_n      : out std_logic;
    o_dac5_p      : out std_logic;
    o_dac5_n      : out std_logic;
    o_dac6_p      : out std_logic;
    o_dac6_n      : out std_logic;
    o_dac7_p      : out std_logic;
    o_dac7_n      : out std_logic;

    ---------------------------------------------------------------------
    -- output/status: @i_clk
    ---------------------------------------------------------------------
    o_errors : out std_logic_vector(15 downto 0); -- errors
    o_status : out std_logic_vector(7 downto 0)  -- status
    );
end entity io_dac;

architecture RTL of io_dac is
  constant c_DAC_OUTPUT_WIDTH : integer := 8;  -- number of output differential pairs

  ---------------------------------------------------------------------
  -- dac_data_insert
  ---------------------------------------------------------------------
  signal dac_valid_tmp0 : std_logic;
  signal dac_frame_tmp0 : std_logic;
  signal dac_tmp0       : std_logic_vector(i_dac'range);
  signal errors_tmp0    : std_logic_vector(o_errors'range);
  signal status_tmp0    : std_logic_vector(o_status'range);

  ---------------------------------------------------------------------
  -- optionnally add latency
  ---------------------------------------------------------------------
  constant c_IDX0_L : integer := 0;
  constant c_IDX0_H : integer := c_IDX0_L + i_dac'length - 1;

  constant c_IDX1_L : integer := c_IDX0_H + 1;
  constant c_IDX1_H : integer := c_IDX1_L + 1 - 1;

  constant c_IDX2_L : integer := c_IDX1_H + 1;
  constant c_IDX2_H : integer := c_IDX2_L + 1 - 1;

  signal data_pipe_tmp0 : std_logic_vector(c_IDX2_H downto 0);
  signal data_pipe_tmp1 : std_logic_vector(c_IDX2_H downto 0);

  signal dac_frame_tmp1 : std_logic;
  signal dac_tmp1       : std_logic_vector(i_dac'range);

  ---------------------------------------------------------------------
  -- oddr
  ---------------------------------------------------------------------
  signal dac_clk_p_tmp4 : std_logic;
  signal dac_clk_n_tmp4 : std_logic;

  signal dac_frame_p_tmp4 : std_logic;
  signal dac_frame_n_tmp4 : std_logic;

  signal dac_p_tmp4 : std_logic_vector(c_DAC_OUTPUT_WIDTH - 1 downto 0);
  signal dac_n_tmp4 : std_logic_vector(c_DAC_OUTPUT_WIDTH - 1 downto 0);

begin

   inst_dac_data_insert : entity work.dac_data_insert
    generic map(
      g_DAC_WIDTH => i_dac'length
    )
    port map(
      ---------------------------------------------------------------------
      -- input @i_clk
      ---------------------------------------------------------------------
      i_clk         => i_clk,
      i_rst         => i_rst,
      i_rst_status  => i_rst_status,
      i_debug_pulse => i_debug_pulse,
      i_dac_valid   => i_dac_valid,
      i_dac_frame   => i_dac_frame,
      i_dac         => i_dac,
      ---------------------------------------------------------------------
      -- output @i_dac_clk
      ---------------------------------------------------------------------
      i_dac_clk     => i_out_clk,
      i_dac_rst     => i_out_rst,
      o_dac_valid   => dac_valid_tmp0,
      o_dac_frame   => dac_frame_tmp0,
      o_dac         => dac_tmp0,
      ---------------------------------------------------------------------
      -- errors/status @i_clk
      ---------------------------------------------------------------------
      o_errors      => errors_tmp0,
      o_status      => status_tmp0
    );

---------------------------------------------------------------------
-- check if no hole in the output data flow
---------------------------------------------------------------------
  --inst_dac_check_dataflow : entity work.dac_check_dataflow
  --  port map(
  --    ---------------------------------------------------------------------
  --    -- input @i_dac_clk
  --    ---------------------------------------------------------------------
  --    i_dac_clk     => i_out_clk,
  --    i_dac_rst     => i_out_rst,
  --    i_dac_valid   => dac_valid_tmp0,
  --    ---------------------------------------------------------------------
  --    -- error @i_clk
  --    ---------------------------------------------------------------------
  --    i_clk         => i_clk,
  --    i_rst_status  => i_rst_status,
  --    i_debug_pulse => i_debug_pulse,
  --    i_en          => i_en,
  --    o_error       => error3
  --  );

  
  ---------------------------------------------------------------------
  -- optionnally add latency before output IOs
  ---------------------------------------------------------------------
  data_pipe_tmp0(c_IDX2_H)                 <= dac_valid_tmp0;
  data_pipe_tmp0(c_IDX1_H)                 <= dac_frame_tmp0;
  data_pipe_tmp0(c_IDX0_H downto c_IDX0_L) <= dac_tmp0;
  inst_pipeliner_add_output_latency : entity work.pipeliner
    generic map(
      g_NB_PIPES   => g_OUTPUT_LATENCY,  -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => data_pipe_tmp0'length  -- width of the input/output data.  Possibles values: [1, integer max value[
      )
    port map(
      i_clk  => i_out_clk,      
      i_data => data_pipe_tmp0, 
      o_data => data_pipe_tmp1 
      );

  dac_frame_tmp1 <= data_pipe_tmp1(c_IDX1_H);
  dac_tmp1       <= data_pipe_tmp1(c_IDX0_H downto c_IDX0_L);

  ---------------------------------------------------------------------
  -- I/O interface:
  -- bit remapping : see the selectio_wiz_dac_sim_netlist.vhdl from Xilinx ip compilation.
  -- data_out_to_pins_p(0) <= data_out_from_device(0); -- pos edge
  -- data_out_to_pins_n(0) <= data_out_from_device(8); -- neg edge
  -- data_out_to_pins_p(1) <= data_out_from_device(1); -- pos edge
  -- data_out_to_pins_n(1) <= data_out_from_device(9); -- neg edge
  -- and so on
  ---------------------------------------------------------------------
  gen_io_dac : if true generate
    signal dac_tmp2   : std_logic_vector(15 downto 0);
    signal dac_p_tmp2 : std_logic_vector(7 downto 0);
    signal dac_n_tmp2 : std_logic_vector(7 downto 0);
  begin
    dac_tmp2(15 downto 8) <= dac_tmp1(15 downto 8);
    dac_tmp2(7 downto 0)  <= dac_tmp1(7 downto 0);
    inst_selectio_wiz_dac : entity work.selectio_wiz_dac
      port map(
        data_out_from_device => dac_tmp2,
        data_out_to_pins_p   => dac_p_tmp2,
        data_out_to_pins_n   => dac_n_tmp2,
        clk_to_pins_p        => dac_clk_p_tmp4,
        clk_to_pins_n        => dac_clk_n_tmp4,
        clk_in               => i_out_clk,
        clk_reset            => i_io_clk_rst,
        io_reset             => i_io_rst
        );

    dac_p_tmp4 <= dac_p_tmp2(7 downto 0);
    dac_n_tmp4 <= dac_n_tmp2(7 downto 0);

  end generate gen_io_dac;

  gen_io_dac_frame : if true generate
    signal dac_tmp2   : std_logic_vector(0 downto 0);
    signal dac_p_tmp2 : std_logic_vector(0 downto 0);
    signal dac_n_tmp2 : std_logic_vector(0 downto 0);
  begin
    dac_tmp2(0) <= dac_frame_tmp1;
    inst_selectio_wiz_dac_frame : entity work.selectio_wiz_dac_frame
      port map(
        data_out_from_device => dac_tmp2,
        data_out_to_pins_p   => dac_p_tmp2,
        data_out_to_pins_n   => dac_n_tmp2,
        clk_in               => i_out_clk,
        io_reset             => i_io_rst
        );
    dac_frame_p_tmp4 <= dac_p_tmp2(0);
    dac_frame_n_tmp4 <= dac_n_tmp2(0);
  end generate gen_io_dac_frame;

  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  -- dac: clk
  o_dac_clk_p <= dac_clk_p_tmp4;
  o_dac_clk_n <= dac_clk_n_tmp4;

  -- dac: frame
  o_dac_frame_p <= dac_frame_p_tmp4;
  o_dac_frame_n <= dac_frame_n_tmp4;

  -- dac: bit0
  o_dac0_p <= dac_p_tmp4(0);
  o_dac0_n <= dac_n_tmp4(0);

  -- dac: bit1
  o_dac1_p <= dac_p_tmp4(1);
  o_dac1_n <= dac_n_tmp4(1);

  -- dac: bit2
  o_dac2_p <= dac_p_tmp4(2);
  o_dac2_n <= dac_n_tmp4(2);

  -- dac: bit3
  o_dac3_p <= dac_p_tmp4(3);
  o_dac3_n <= dac_n_tmp4(3);

  -- dac: bit4
  o_dac4_p <= dac_p_tmp4(4);
  o_dac4_n <= dac_n_tmp4(4);

  -- dac: bit5
  o_dac5_p <= dac_p_tmp4(5);
  o_dac5_n <= dac_n_tmp4(5);

  -- dac: bit6
  o_dac6_p <= dac_p_tmp4(6);
  o_dac6_n <= dac_n_tmp4(6);

  -- dac: bit7
  o_dac7_p <= dac_p_tmp4(7);
  o_dac7_n <= dac_n_tmp4(7);


  ---------------------------------------------------------------------
  -- errors/status
  ---------------------------------------------------------------------
  --o_errors(15)          <= error3;
  o_errors(14 downto 0) <= errors_tmp0(14 downto 0);
  o_status              <= status_tmp0;

end architecture RTL;
