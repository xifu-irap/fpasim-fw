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
--!   @file                   io_sync.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--
-- This module generates fpga specific IO component with an optional user-defined latency

-- Example0:
--   Input ports -> optionnal latency -> fpga specific IO generation -> output port
--
-- -------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;


library UNISIM;
use UNISIM.vcomponents.all;

entity io_sync is
  generic(
    g_OUTPUT_LATENCY : natural := 0  -- add latency before the output IO. Possible values: [0; max integer values[
    );
  port(
    i_clk        : in std_logic;        -- clock
    -- from reset_top: @i_clk
    i_io_clk_rst : in std_logic;  -- Clock reset: Reset connected to clocking elements in the circuit
    i_io_rst     : in std_logic;  -- Reset connected to all other elements in the circuit

    ---------------------------------------------------------------------
    -- input
    ---------------------------------------------------------------------
    i_sync     : in  std_logic;
    ---------------------------------------------------------------------
    -- output
    ---------------------------------------------------------------------
    o_sync_clk : out std_logic;
    o_sync     : out std_logic
    );
end entity io_sync;

architecture RTL of io_sync is

  ---------------------------------------------------------------------
  -- optionnally add latency
  ---------------------------------------------------------------------
  signal sync_rx : std_logic;

  ---------------------------------------------------------------------
  -- oddr
  ---------------------------------------------------------------------
  signal sync_tmp : std_logic;
  signal clk_tmp  : std_logic;

begin

  ---------------------------------------------------------------------
  -- output: optionnally add latency before output IOs
  ---------------------------------------------------------------------
  inst_pipeliner_add_output_latency : entity work.pipeliner
    generic map(
      g_NB_PIPES   => g_OUTPUT_LATENCY,  -- number of consecutives registers. Possibles values: [0, integer max value[
      g_DATA_WIDTH => 1  -- width of the input/output data.  Possibles values: [1, integer max value[
      )
    port map(
      i_clk     => i_clk,               -- clock signal
      i_data(0) => i_sync,              -- input data
      o_data(0) => sync_rx              -- output data with/without delay
      );

  ---------------------------------------------------------------------
  -- I/O interface
  ---------------------------------------------------------------------
  gen_io_sync : if true generate
    signal data_tmp0 : std_logic_vector(0 downto 0);
    signal data_tmp1 : std_logic_vector(0 downto 0);
  begin
    data_tmp0(0) <= sync_rx;
    inst_selectio_wiz_sync : entity work.selectio_wiz_sync
      port map(
        data_out_from_device => data_tmp0,
        data_out_to_pins     => data_tmp1,
        clk_to_pins          => clk_tmp,
        clk_in               => i_clk,
        clk_reset            => i_io_clk_rst,
        io_reset             => i_io_rst
        );
    sync_tmp <= data_tmp1(0);
  end generate gen_io_sync;

  ---------------------------------------------------------------------
  -- output
  ---------------------------------------------------------------------
  o_sync_clk <= clk_tmp;
  o_sync     <= sync_tmp;

end architecture RTL;
