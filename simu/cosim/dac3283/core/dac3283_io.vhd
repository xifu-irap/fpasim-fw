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
--    @file                   dac3283_io.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details                
--
--    This module retrieves data from IOs
--
--
-- -------------------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library unisim;
use UNISIM.vcomponents.all;


entity dac3283_io is
  port (
    ---------------------------------------------------------------------
    -- from pads
    ---------------------------------------------------------------------
    i_dac_clk_p   : in  std_logic; -- differential_p dac clock
    i_dac_clk_n   : in  std_logic; -- differential_n dac clock 

    i_dac_frame_p : in  std_logic; -- differential_p dac frame
    i_dac_frame_n : in  std_logic; -- differential_n dac frame

    i_dac0_p      : in  std_logic; -- differential_p dac data (lane0)
    i_dac0_n      : in  std_logic; -- differential_n dac data (lane0)

    i_dac1_p      : in  std_logic; -- differential_p dac data (lane1)
    i_dac1_n      : in  std_logic; -- differential_n dac data (lane1)

    i_dac2_p      : in  std_logic; -- differential_p dac data (lane2)
    i_dac2_n      : in  std_logic; -- differential_n dac data (lane2)

    i_dac3_p      : in  std_logic; -- differential_p dac data (lane3)
    i_dac3_n      : in  std_logic; -- differential_n dac data (lane3)

    i_dac4_p      : in  std_logic; -- differential_p dac data (lane4)
    i_dac4_n      : in  std_logic; -- differential_n dac data (lane4)

    i_dac5_p      : in  std_logic; -- differential_p dac data (lane5)
    i_dac5_n      : in  std_logic; -- differential_n dac data (lane5)

    i_dac6_p      : in  std_logic; -- differential_p dac data (lane6)
    i_dac6_n      : in  std_logic; -- differential_n dac data (lane6)

    i_dac7_p      : in  std_logic; -- differential_p dac data (lane7)
    i_dac7_n      : in  std_logic; -- differential_n dac data (lane7)
    ---------------------------------------------------------------------
    -- to the user
    ---------------------------------------------------------------------
    o_dac_clk     : out std_logic; -- dac clock
    o_dac_frame   : out std_logic; -- dac frame
    o_dac         : out std_logic_vector(15 downto 0) -- dac value

    );
end entity dac3283_io;

architecture RTL of dac3283_io is
  signal clk_tmp : std_logic;

begin

---------------------------------------------------------------------
-- clock
---------------------------------------------------------------------
  gen_clk : if true generate
  begin
    inst_IBUFDS : IBUFDS
      generic map (  -- @suppress "Generic map uses default values. Missing optional actuals: CAPACITANCE, DQS_BIAS, IBUF_DELAY_VALUE, IFD_DELAY_VALUE"
        DIFF_TERM    => false,          -- Differential Termination 
        IBUF_LOW_PWR => true,  -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
        IOSTANDARD   => "DEFAULT")
      port map (
        O  => clk_tmp,                  -- Buffer output
        I  => i_dac_clk_p,  -- Diff_p buffer input (connect directly to top-level port)
        IB => i_dac_clk_n  -- Diff_n buffer input (connect directly to top-level port)
        );
  end generate gen_clk;

  o_dac_clk <= clk_tmp;
---------------------------------------------------------------------
-- frame
---------------------------------------------------------------------
  gen_frame : if true generate
    signal frame_tmp : std_logic;
  begin
    inst_IBUFDS : IBUFDS
      generic map (  -- @suppress "Generic map uses default values. Missing optional actuals: CAPACITANCE, DQS_BIAS, IBUF_DELAY_VALUE, IFD_DELAY_VALUE"
        DIFF_TERM    => false,          -- Differential Termination 
        IBUF_LOW_PWR => true,  -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
        IOSTANDARD   => "DEFAULT")
      port map (
        O  => frame_tmp,                -- Buffer output
        I  => i_dac_frame_p,  -- Diff_p buffer input (connect directly to top-level port)
        IB => i_dac_frame_n  -- Diff_n buffer input (connect directly to top-level port)
        );

    o_dac_frame <= frame_tmp;
  end generate gen_frame;

---------------------------------------------------------------------
-- data
---------------------------------------------------------------------

  gen_data : if true generate
    signal data_tmp_p : std_logic_vector(7 downto 0);
    signal data_tmp_n : std_logic_vector(7 downto 0);

    signal data_tmp : std_logic_vector(7 downto 0);

    signal data_tmp1 : std_logic_vector(7 downto 0);
    signal data_tmp2 : std_logic_vector(7 downto 0);
  begin
    data_tmp_p(7) <= i_dac7_p;
    data_tmp_n(7) <= i_dac7_n;

    data_tmp_p(6) <= i_dac6_p;
    data_tmp_n(6) <= i_dac6_n;

    data_tmp_p(5) <= i_dac5_p;
    data_tmp_n(5) <= i_dac5_n;

    data_tmp_p(4) <= i_dac4_p;
    data_tmp_n(4) <= i_dac4_n;

    data_tmp_p(3) <= i_dac3_p;
    data_tmp_n(3) <= i_dac3_n;

    data_tmp_p(2) <= i_dac2_p;
    data_tmp_n(2) <= i_dac2_n;

    data_tmp_p(1) <= i_dac1_p;
    data_tmp_n(1) <= i_dac1_n;

    data_tmp_p(0) <= i_dac0_p;
    data_tmp_n(0) <= i_dac0_n;



    gen_io : for i in data_tmp'range generate
      inst_IBUFDS : IBUFDS
        generic map (  -- @suppress "Generic map uses default values. Missing optional actuals: CAPACITANCE, DQS_BIAS, IBUF_DELAY_VALUE, IFD_DELAY_VALUE"
          DIFF_TERM    => false,        -- Differential Termination 
          IBUF_LOW_PWR => true,  -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
          IOSTANDARD   => "DEFAULT")
        port map (
          O  => data_tmp(i),            -- Buffer output
          I  => data_tmp_p(i),  -- Diff_p buffer input (connect directly to top-level port)
          IB => data_tmp_n(i)  -- Diff_n buffer input (connect directly to top-level port)
          );

      inst_IDDR : IDDR
        generic map (  -- @suppress "Generic map uses default values. Missing optional actuals: IS_C_INVERTED, IS_D_INVERTED"
          --DDR_CLK_EDGE => "SAME_EDGE",  -- "OPPOSITE_EDGE", "SAME_EDGE" 
          DDR_CLK_EDGE => "SAME_EDGE_PIPELINED",  -- "OPPOSITE_EDGE", "SAME_EDGE" 
          -- or "SAME_EDGE_PIPELINED" 
          INIT_Q1      => '0',          -- Initial value of Q1: '0' or '1'
          INIT_Q2      => '0',          -- Initial value of Q2: '0' or '1'
          SRTYPE       => "SYNC")       -- Set/Reset type: "SYNC" or "ASYNC" 
        port map (
          Q1 => data_tmp1(i),  -- 1-bit output for positive edge of clock 
          Q2 => data_tmp2(i),  -- 1-bit output for negative edge of clock
          C  => clk_tmp,                -- 1-bit clock input
          CE => '1',                    -- 1-bit clock enable input
          D  => data_tmp(i),            -- 1-bit DDR data input
          R  => '0',                    -- 1-bit reset
          S  => '0'                     -- 1-bit set
          );
    end generate gen_io;

    o_dac(15 downto 8) <= data_tmp1;
    o_dac(7 downto 0)  <= data_tmp2;


  end generate gen_data;

end architecture RTL;
