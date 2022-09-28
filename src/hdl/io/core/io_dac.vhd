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
--!   @file                   io_dac.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--
-- This module generates fpga specific IO component with an optional user-defined latency
--
-- Example0:
--   Input ports -> optionnal latency -> fpga specific IO generation -> output port
--
-- -------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

Library UNISIM;
use UNISIM.vcomponents.all;

library fpasim;

entity io_dac is
   generic(
      g_OUTPUT_LATENCY : natural := 0   -- add latency before the output IO. Possible values: [0; max integer value[
   );
   port(
      i_clk         : in  std_logic;    -- clock
      ---------------------------------------------------------------------
      -- input
      ---------------------------------------------------------------------
      i_dac_frame   : in  std_logic;
      i_dac         : in  std_logic_vector(15 downto 0);
      ---------------------------------------------------------------------
      -- output
      ---------------------------------------------------------------------
      o_dac_clk_p   : out std_logic;
      o_dac_clk_n   : out std_logic;
      o_dac_frame_p : out std_logic;
      o_dac_frame_n : out std_logic;
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
      o_dac7_n      : out std_logic
   );
end entity io_dac;

architecture RTL of io_dac is
   constant c_DAC_OUTPUT_WIDTH : integer := 8; -- number of output differential pairs

   ---------------------------------------------------------------------
   -- optionnally add latency
   ---------------------------------------------------------------------
   constant c_IDX0_L : integer := 0;
   constant c_IDX0_H : integer := c_IDX0_L + i_dac'length - 1;

   constant c_IDX1_L : integer := c_IDX0_H + 1;
   constant c_IDX1_H : integer := c_IDX1_L + 1 - 1;

   signal data_pipe_tmp0 : std_logic_vector(c_IDX1_H downto 0);
   signal data_pipe_tmp1 : std_logic_vector(c_IDX1_H downto 0);

   signal dac_frame1 : std_logic;
   signal dac1       : std_logic_vector(i_dac'range);

   ---------------------------------------------------------------------
   -- oddr
   ---------------------------------------------------------------------
   signal dac_clk_tmp2   : std_logic;
   signal dac_clk_p_tmp3 : std_logic;
   signal dac_clk_n_tmp3 : std_logic;

   signal dac_frame_tmp2   : std_logic;
   signal dac_frame_p_tmp3 : std_logic;
   signal dac_frame_n_tmp3 : std_logic;

   --signal dac_p_tmp1 : std_logic_vector(c_DAC_OUTPUT_WIDTH - 1 downto 0);
   --signal dac_n_tmp1 : std_logic_vector(c_DAC_OUTPUT_WIDTH - 1 downto 0);
   signal dac_tmp2   : std_logic_vector(c_DAC_OUTPUT_WIDTH - 1 downto 0);
   signal dac_p_tmp3 : std_logic_vector(c_DAC_OUTPUT_WIDTH - 1 downto 0);
   signal dac_n_tmp3 : std_logic_vector(c_DAC_OUTPUT_WIDTH - 1 downto 0);

begin

   ---------------------------------------------------------------------
   -- optionnally add latency before output IOs
   ---------------------------------------------------------------------
   data_pipe_tmp0(c_IDX1_H)                 <= i_dac_frame;
   data_pipe_tmp0(c_IDX0_H downto c_IDX0_L) <= i_dac;
   inst_pipeliner_add_output_latency : entity fpasim.pipeliner
      generic map(
         g_NB_PIPES   => g_OUTPUT_LATENCY, -- number of consecutives registers. Possibles values: [0, integer max value[
         g_DATA_WIDTH => data_pipe_tmp0'length -- width of the input/output data.  Possibles values: [1, integer max value[
      )
      port map(
         i_clk  => i_clk,               -- clock signal
         i_data => data_pipe_tmp0,      -- input data
         o_data => data_pipe_tmp1       -- output data with/without delay
      );

   dac_frame1 <= data_pipe_tmp1(c_IDX1_H);
   dac1       <= data_pipe_tmp1(c_IDX0_H downto c_IDX0_L);

   ---------------------------------------------------------------------
   -- oddr: dac frame
   ---------------------------------------------------------------------
   --inst_ODDR_dac_frame : ODDR
   --   generic map(                      -- @suppress "Generic map uses default values. Missing optional actuals: IS_C_INVERTED, IS_D1_INVERTED, IS_D2_INVERTED"
   --      DDR_CLK_EDGE => "SAME_EDGE",   -- "OPPOSITE_EDGE" or "SAME_EDGE" 
   --      INIT         => '0',           -- Initial value for Q port ('1' or '0')
   --      SRTYPE       => "SYNC")        -- Reset Type ("ASYNC" or "SYNC")
   --   port map(
   --      Q  => dac_frame_tmp2,          -- 1-bit DDR output
   --      C  => i_clk,                   -- 1-bit clock input
   --      CE => '1',                     -- 1-bit clock enable input
   --      D1 => dac_frame1,              -- 1-bit data input (positive edge)
   --      D2 => dac_frame1,              -- 1-bit data input (negative edge)
   --      R  => '0',                     -- 1-bit reset input
   --      S  => '0'                      -- 1-bit set input
   --   );

   --inst_OBUFDS_dac_frame : OBUFDS
   --   generic map(                      -- @suppress "Generic map uses default values. Missing optional actuals: CAPACITANCE"
   --      IOSTANDARD => "LVDS",       -- Specify the output I/O standard
   --      SLEW       => "FAST")          -- Specify the output slew rate
   --   port map(
   --      O  => dac_frame_p_tmp3,        -- Diff_p output (connect directly to top-level port)
   --      OB => dac_frame_n_tmp3,        -- Diff_n output (connect directly to top-level port)
   --      I  => dac_frame_tmp2           -- Buffer input 
   --   );

   ---------------------------------------------------------------------
   -- oddr : dac clk
   ---------------------------------------------------------------------
   -- dac_clk
   -- add oddr on clock to have the same logic on the FPGA pads as the data path
   --inst_ODDR_clk : ODDR
   --   generic map(                      -- @suppress "Generic map uses default values. Missing optional actuals: IS_C_INVERTED, IS_D1_INVERTED, IS_D2_INVERTED"
   --      DDR_CLK_EDGE => "SAME_EDGE",   -- "OPPOSITE_EDGE" or "SAME_EDGE" 
   --      INIT         => '0',           -- Initial value for Q port ('1' or '0')
   --      SRTYPE       => "SYNC")        -- Reset Type ("ASYNC" or "SYNC")
   --   port map(
   --      Q  => dac_clk_tmp2,            -- 1-bit DDR output
   --      C  => i_clk,                   -- 1-bit clock input
   --      CE => '1',                     -- 1-bit clock enable input

   --      D1 => '1',                     -- 1-bit data input (positive edge)
   --      D2 => '0',                     -- 1-bit data input (negative edge)

   --      R  => '0',                     -- 1-bit reset input
   --      S  => '0'                      -- 1-bit set input
   --   );

   --inst_OBUFDS_clk : OBUFDS
   --   generic map(                      -- @suppress "Generic map uses default values. Missing optional actuals: CAPACITANCE"
   --      IOSTANDARD => "LVDS",       -- Specify the output I/O standard
   --      SLEW       => "FAST")          -- Specify the output slew rate
   --   port map(
   --      O  => dac_clk_p_tmp3,          -- Diff_p output (connect directly to top-level port)
   --      OB => dac_clk_n_tmp3,          -- Diff_n output (connect directly to top-level port)
   --      I  => dac_clk_tmp2             -- Buffer input 
   --   );

   ---------------------------------------------------------------------
   -- oddr: dac
   ---------------------------------------------------------------------
   -- dac_p_tmp1 <= dac1(15 downto 8);
   -- dac_n_tmp1 <= dac1(7 downto 0);
   --gen_dac_oddr : for i in dac_p_tmp1'range generate

   --   inst_ODDR_dac : ODDR
   --      generic map(                   -- @suppress "Generic map uses default values. Missing optional actuals: IS_C_INVERTED, IS_D1_INVERTED, IS_D2_INVERTED"
   --         DDR_CLK_EDGE => "SAME_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE" 
   --         INIT         => '0',        -- Initial value for Q port ('1' or '0')
   --         SRTYPE       => "SYNC")     -- Reset Type ("ASYNC" or "SYNC")
   --      port map(
   --         Q  => dac_tmp2(i),          -- 1-bit DDR output
   --         C  => i_clk,                -- 1-bit clock input
   --         CE => '1',                  -- 1-bit clock enable input

   --         D1 => dac_p_tmp1(i),        -- 1-bit data input (positive edge)
   --         D2 => dac_n_tmp1(i),        -- 1-bit data input (negative edge)

   --         R  => '0',                  -- 1-bit reset input
   --         S  => '0'                   -- 1-bit set input
   --      );

   --   inst_OBUFDS_dac : OBUFDS
   --      generic map(                   -- @suppress "Generic map uses default values. Missing optional actuals: CAPACITANCE"
   --         IOSTANDARD => "LVDS",    -- Specify the output I/O standard
   --         SLEW       => "FAST")       -- Specify the output slew rate
   --      port map(
   --         O  => dac_p_tmp3(i),        -- Diff_p output (connect directly to top-level port)
   --         OB => dac_n_tmp3(i),        -- Diff_n output (connect directly to top-level port)
   --         I  => dac_tmp2(i)           -- Buffer input 
   --      );
   --end generate gen_dac_oddr;

   ---------------------------------------------------------------------
   -- bit remapping : see the selectio_wiz_dac_sim_netlist.vhdl from Xilinx ip compilation.
   -- data_out_to_pins_p(0) <= data_out_from_device(0); -- pos edge
   -- data_out_to_pins_n(0) <= data_out_from_device(9); -- neg edge
   -- data_out_to_pins_p(1) <= data_out_from_device(1); -- pos edge
   -- data_out_to_pins_n(1) <= data_out_from_device(10); -- neg edge
   -- and so on
   ---------------------------------------------------------------------
   gen_io_dac : if true generate
      signal dac_tmp0   : std_logic_vector(17 downto 0);
      signal dac_p_tmp1 : std_logic_vector(8 downto 0);
      signal dac_n_tmp1 : std_logic_vector(8 downto 0);
   begin
      dac_tmp0(17)          <= dac_frame1;
      dac_tmp0(16 downto 9) <= dac1(15 downto 8);
      dac_tmp0(8)           <= dac_frame1;
      dac_tmp0(7 downto 0)  <= dac1(7 downto 0);
      inst_selectio_wiz_dac : entity fpasim.selectio_wiz_dac
         port map(
            data_out_from_device => dac_tmp0,
            data_out_to_pins_p   => dac_p_tmp1,
            data_out_to_pins_n   => dac_n_tmp1,
            clk_to_pins_p        => dac_clk_p_tmp3,
            clk_to_pins_n        => dac_clk_n_tmp3,
            clk_in               => i_clk,
            clk_reset            => '0',
            io_reset             => '0'
         );
      dac_frame_p_tmp3      <= dac_p_tmp1(8);
      dac_p_tmp3            <= dac_p_tmp1(7 downto 0);

      dac_frame_n_tmp3 <= dac_n_tmp1(8);
      dac_n_tmp3       <= dac_n_tmp1(7 downto 0);
   end generate gen_io_dac;

   ---------------------------------------------------------------------
   -- output
   ---------------------------------------------------------------------
   -- dac: clk
   o_dac_clk_p <= dac_clk_p_tmp3;
   o_dac_clk_n <= dac_clk_n_tmp3;

   -- dac: frame
   o_dac_frame_p <= dac_frame_p_tmp3;
   o_dac_frame_n <= dac_frame_n_tmp3;

   -- dac: bit0
   o_dac0_p <= dac_p_tmp3(0);
   o_dac0_n <= dac_n_tmp3(0);

   -- dac: bit1
   o_dac1_p <= dac_p_tmp3(1);
   o_dac1_n <= dac_n_tmp3(1);

   -- dac: bit2
   o_dac2_p <= dac_p_tmp3(2);
   o_dac2_n <= dac_n_tmp3(2);

   -- dac: bit3
   o_dac3_p <= dac_p_tmp3(3);
   o_dac3_n <= dac_n_tmp3(3);

   -- dac: bit4
   o_dac4_p <= dac_p_tmp3(4);
   o_dac4_n <= dac_n_tmp3(4);

   -- dac: bit5
   o_dac5_p <= dac_p_tmp3(5);
   o_dac5_n <= dac_n_tmp3(5);

   -- dac: bit6
   o_dac6_p <= dac_p_tmp3(6);
   o_dac6_n <= dac_n_tmp3(6);

   -- dac: bit7
   o_dac7_p <= dac_p_tmp3(7);
   o_dac7_n <= dac_n_tmp3(7);

end architecture RTL;
