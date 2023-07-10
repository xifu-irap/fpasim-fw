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
--    @file                   pkg_front_panel.vhd
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details
--
--    This VHDL package is based on the "Opal Kelly\FrontPanelUSB\Samples\Simulation\USB3\VHDL example\sim_tf.vhd" example design.
--    It allows to control USB3 port signals.
--    It redefines the functions/procedures in a package instead of a plain text in the VHDL testbench.
--    The objective is to facilitate readability but also to facilitate the possibility of controlling several different USB ports.
--
--    Use:
--      0. import this package in the vhdl testbench
--      1. In the declarative part of the vhdl testbench architecture, declare:
--         1. one signal of t_internal_wr_if type
--         2. one signal of t_internal_rd_if type
--         3. one share variable of t_front_panel_conf type
--           Example:
--             . signal usb_wr_if0 : opal_kelly_lib.pkg_front_panel.t_internal_wr_if := (
--                 hi_drive   => '0',
--                 hi_cmd     => (others => '0'),
--                 hi_dataout => (others => '0')
--                 );
--             . signal usb_rd_if0 : opal_kelly_lib.pkg_front_panel.t_internal_rd_if := (
--               i_clk     => '0',
--               hi_busy   => '0',
--               hi_datain => (others => '0')
--             );
--            . shared variable v_front_panel_conf : opal_kelly_lib.pkg_front_panel.t_front_panel_conf;
--      2. In the VHDL testbench architecture body,
--         1. Instanciate the okHost_driver procedure outside a process.
--      3. In an identical process, call :
--         1. FrontPanelReset procedure (mandatory)
--         2. the other functions/procedures defined in this package
--    Note:
--      1. after one or more SetWireInValue calls, the UpdateWireIns must be called
--      2. UpdateWireOuts must be called before the GetWireOutValue procedure
--      3. WriteToPipeIn must write a multiple of 16 bytes (usb3 limitation)
--      4. ReadFromPipeOut must read a multiple of 16 bytes (usb3 limitation)
--
--    Note:
--      . The functions/procedures are almost identical to the sim_tf.vhd file. Except, the 2 new added arguments:
--         1. variable front_panel_conf : inout t_front_panel_conf
--         2. signal internal_wr_if : inout t_internal_wr_if
--         2. signal internal_rd_if : inout t_internal_rd_if
--      . This script needs the simulation files (USB3) profided by the Opal Kelly company. In particular, the
--        parameters file needs to be compiled in the fpasim library.
--
--
--   LIMITATION: all function/procedures must be called in the same process to avoid conflict with signal record argument
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use IEEE.std_logic_textio.all;

use std.textio.all;

library fpasim;
use fpasim.parameters.all;

package pkg_front_panel is

  ---------------------------------------------------------------------
  -- user-defined constants
  --  . configure the usb behaviour
  ---------------------------------------------------------------------
  constant BlockDelayStates : integer := 5;  -- REQUIRED: # of clocks between blocks of pipe data
  constant ReadyCheckDelay  : integer := 5;  -- REQUIRED: # of clocks before block transfer before
                                             --    host interface checks for ready (0-255)
  constant PostReadyDelay   : integer := 5;  -- REQUIRED: # of clocks after ready is asserted and
                                             --    check that the block transfer begins (0-255)
  constant pipeInSize       : integer := 1024;  -- REQUIRED: byte (must be even) length of default
  --    PipeIn; Integer 0-2^32
  constant pipeOutSize      : integer := 1024;  -- REQUIRED: byte (must be even) length of default
  --    PipeOut; Integer 0-2^32
  constant registerSetSize  : integer := 32;

  ---------------------------------------------------------------------
  -- Don't touch: USB internal commands
  ---------------------------------------------------------------------
  constant DNOP                  : std_logic_vector(2 downto 0) := "000";
  constant DReset                : std_logic_vector(2 downto 0) := "001";
  constant DWires                : std_logic_vector(2 downto 0) := "010";
  constant DUpdateWireIns        : std_logic_vector(2 downto 0) := "001";
  constant DUpdateWireOuts       : std_logic_vector(2 downto 0) := "010";
  constant DTriggers             : std_logic_vector(2 downto 0) := "011";
  constant DActivateTriggerIn    : std_logic_vector(2 downto 0) := "001";
  constant DUpdateTriggerOuts    : std_logic_vector(2 downto 0) := "010";
  constant DPipes                : std_logic_vector(2 downto 0) := "100";
  constant DWriteToPipeIn        : std_logic_vector(2 downto 0) := "001";
  constant DReadFromPipeOut      : std_logic_vector(2 downto 0) := "010";
  constant DWriteToBlockPipeIn   : std_logic_vector(2 downto 0) := "011";
  constant DReadFromBlockPipeOut : std_logic_vector(2 downto 0) := "100";
  constant DRegisters            : std_logic_vector(2 downto 0) := "101";
  constant DWriteRegister        : std_logic_vector(2 downto 0) := "001";
  constant DReadRegister         : std_logic_vector(2 downto 0) := "010";
  constant DWriteRegisterSet     : std_logic_vector(2 downto 0) := "011";
  constant DReadRegisterSet      : std_logic_vector(2 downto 0) := "100";

  type t_void is (VOID);

  ---------------------------------------------------------------------
  -- define procedure/function records
  ---------------------------------------------------------------------
  type t_internal_wr_if is record
    hi_drive   : std_logic;
    hi_cmd     : std_logic_vector(2 downto 0);
    hi_dataout : std_logic_vector(31 downto 0);
  end record;

  type t_internal_rd_if is record
    i_clk     : std_logic;
    hi_busy   : std_logic;
    hi_datain : std_logic_vector(31 downto 0);
  end record;

  ---------------------------------------------------------------------
  -- define variable
  ---------------------------------------------------------------------
  type PIPEIN_ARRAY is array (integer range <>) of std_logic_vector(7 downto 0);
  type PIPEOUT_ARRAY is array (integer range <>) of std_logic_vector(7 downto 0);
  type STD_ARRAY is array (integer range <>) of std_logic_vector(31 downto 0);
  type REGISTER_ARRAY is array (integer range <>) of std_logic_vector(31 downto 0);

  type t_front_panel_conf is protected
    procedure set_WireIns(i_index          : in integer; i_value : in std_logic_vector);
    procedure set_WireOuts(i_index         : in integer; i_value : in std_logic_vector);
    procedure set_Triggered(i_index        : in integer; i_value : in std_logic_vector);
    procedure set_pipeIn(i_index           : in integer; i_value : in std_logic_vector);
    procedure set_pipeOut(i_index          : in integer; i_value : in std_logic_vector);
    procedure set_u32Data(i_index          : in integer; i_value : in std_logic_vector);
    impure function get_WireIns(i_index    : in integer) return std_logic_vector;
    impure function get_WireOuts(i_index   : in integer) return std_logic_vector;
    impure function get_Triggered(i_index  : in integer) return std_logic_vector;
    impure function get_pipeIn(i_index     : in integer) return std_logic_vector;
    impure function get_pipeOut(i_index    : in integer) return std_logic_vector;
    impure function get_u32Count return std_logic_vector;
    impure function get_u32Address(i_index : in integer) return std_logic_vector;
    impure function get_u32Data(i_index    : in integer) return std_logic_vector;

  end protected;

  -----------------------------------------------------------------------
  -- Available User Task and Function Calls:
  --   In the VHDL testbench architecture declarative part:
  --      Create the 2 signal of type : t_internal_wr_if and t_internal_wr_if
  --      Create a share variable of type t_front_panel_conf
  --   In the VHDL testbench architecture body:
  --      instanciate the okHost_driver procedure
  --   Note: in the following procedure/function call, arguments of type t_internal_wr_if, t_internal_wr_if and t_front_panel_conf aren't specified
  --   In a process,
  --      to initialize the devise (mandatory), call:
  --        FrontPanelReset;              -- Always start routine with FrontPanelReset;
  --      to write in the "wire in", call:
  --         one or more times:
  --            SetWireInValue(i_ep, i_val, i_mask); -- i_bit is an integer 0-31, i_val,i_mask are 32 bits std_logic_vector
  --         followed by:
  --            UpdateWireIns;
  --      to read a "wire out", call:
  --         one time:
  --           UpdateWireOuts;
  --         one or more times:
  --           GetWireOutValue(i_ep);          -- returns a 16 bit SLV
  --      to activate a trigger:
  --         to set a bit, call:
  --              ActivateTriggerIn(i_ep, i_bit);   -- i_bit is an integer 0-31
  --         to set an bit array, call:
  --              ActivateTriggerIn_by_data(i_ep,i_data) -- i_data is std_logic_vector(31 downto 0)
  --      to detect a trig, call:
  --         one time: (not tested)
  --              UpdateTriggerOuts;
  --         one or more times: (not tested)
  --              IsTriggered(ep, mask);        -- returns a BOOLEAN
  --      to write to the pipe_in, call:
  --          b_front_panel_conf.set_pipeIn(i_index,i_value)     -- set data to write in the byte array -- i_index is integer >= 0, i_value: 32 bit std_logic_vector
  --          WriteToPipeIn(i_ep, i_length);    -- i_length is integer expressed in bytes (should be a multiple of 16 bytes)
  --      to read from the pipe_out, call:
  --          ReadFromPipeOut(i_ep, i_length);        -- pass data to pipeOut array; i_length is integer expressed in bytes (should be a multiple of 16 bytes)
  --          b_front_panel_conf.get_pipeOut(i_index) -- get byte data -- i_index is integer >= 0
  --
  --    others functions/procedure: (not tested)
  --      WriteToBlockPipeIn(i_ep, i_blockLength, i_length);   -- pass pipeIn array data; blockSize and length are integers
  --      ReadFromBlockPipeOut(i_ep, i_blockLength, i_length); -- pass data to pipeOut array; blockSize and length are integers
  --      WriteRegister(i_address, i_data);
  --      ReadRegister(i_address, i_data);
  --      WriteRegisterSet();
  --      ReadRegisterSet();
  --
  -- *  Pipes operate by passing arrays of data back and forth to the user's
  --    design.  If you need multiple arrays, you can create a new procedure
  --    above and connect it to a differnet array.  More information is
  --    available in Opal Kelly documentation and online support tutorial.
  -----------------------------------------------------------------------

  ---------------------------------------------------------------------
  -- okHost_driver: to instanciate outside a process
  ---------------------------------------------------------------------
  procedure okHost_driver(
    signal i_clk            : in    std_logic;
    signal o_okUH           : out   std_logic_vector (4 downto 0);
    signal i_okHU           : in    std_logic_vector (2 downto 0);
    signal b_okUHU          : inout std_logic_vector (31 downto 0);
    signal i_internal_wr_if : in    t_internal_wr_if;
    signal o_internal_rd_if : out   t_internal_rd_if
    );

  -----------------------------------------------------------------------
  -- FrontPanelReset
  -----------------------------------------------------------------------
  procedure FrontPanelReset(
    variable b_front_panel_conf : inout t_front_panel_conf;
    signal o_internal_wr_if     : out   t_internal_wr_if;
    signal i_internal_rd_if     : in    t_internal_rd_if
    );

  -----------------------------------------------------------------------
  -- SetWireInValue
  -----------------------------------------------------------------------
  procedure SetWireInValue(
    i_ep                        : in    std_logic_vector(7 downto 0);
    i_val                       : in    std_logic_vector(31 downto 0);
    i_mask                      : in    std_logic_vector(31 downto 0);
    variable b_front_panel_conf : inout t_front_panel_conf
    );

  -----------------------------------------------------------------------
  -- GetWireOutValue
  -----------------------------------------------------------------------
  procedure GetWireOutValue(
    i_ep                        :       std_logic_vector;
    variable b_front_panel_conf : inout t_front_panel_conf;
    o_result                    : out   std_logic_vector);

  -----------------------------------------------------------------------
  -- IsTriggered
  -----------------------------------------------------------------------
  procedure IsTriggered(
    i_ep                        :       std_logic_vector;
    i_mask                      :       std_logic_vector(31 downto 0);
    variable b_front_panel_conf : inout t_front_panel_conf;
    o_result                    : out   boolean
    );
  -----------------------------------------------------------------------
  -- UpdateWireIns
  -----------------------------------------------------------------------
  procedure UpdateWireIns(
    variable b_front_panel_conf : inout t_front_panel_conf;
    signal o_internal_wr_if     : out   t_internal_wr_if;
    signal i_internal_rd_if     : in    t_internal_rd_if
    );

  -----------------------------------------------------------------------
  -- UpdateWireOuts
  -----------------------------------------------------------------------
  procedure UpdateWireOuts(
    variable b_front_panel_conf : inout t_front_panel_conf;
    signal o_internal_wr_if     : out   t_internal_wr_if;
    signal i_internal_rd_if     : in    t_internal_rd_if
    );

  -----------------------------------------------------------------------
  -- ActivateTriggerIn
  -----------------------------------------------------------------------
  procedure ActivateTriggerIn(
    i_ep                    : in  std_logic_vector(7 downto 0);
    i_bit                   : in  integer;
    signal o_internal_wr_if : out t_internal_wr_if;
    signal i_internal_rd_if : in  t_internal_rd_if
    );

  -----------------------------------------------------------------------
  -- ActivateTriggerIn_by_data
  -----------------------------------------------------------------------
  procedure ActivateTriggerIn_by_data(
    i_ep                    : in  std_logic_vector(7 downto 0);
    i_data                  : in  std_logic_vector(31 downto 0);
    signal o_internal_wr_if : out t_internal_wr_if;
    signal i_internal_rd_if : in  t_internal_rd_if
    );

  -----------------------------------------------------------------------
  -- UpdateTriggerOuts
  -----------------------------------------------------------------------
  procedure UpdateTriggerOuts(
    variable b_front_panel_conf : inout t_front_panel_conf;
    signal o_internal_wr_if     : out   t_internal_wr_if;
    signal i_internal_rd_if     : in    t_internal_rd_if
    );

  -----------------------------------------------------------------------
  -- WriteToPipeIn
  -----------------------------------------------------------------------
  procedure WriteToPipeIn(
    i_ep                        : in    std_logic_vector(7 downto 0);
    i_length                    : in    integer;
    variable b_front_panel_conf : inout t_front_panel_conf;
    signal o_internal_wr_if     : out   t_internal_wr_if;
    signal i_internal_rd_if     : in    t_internal_rd_if
    );

  -----------------------------------------------------------------------
  -- ReadFromPipeOut
  -----------------------------------------------------------------------
  procedure ReadFromPipeOut(
    i_ep                        : in    std_logic_vector(7 downto 0);
    i_length                    : in    integer;
    variable b_front_panel_conf : inout t_front_panel_conf;
    signal o_internal_wr_if     : out   t_internal_wr_if;
    signal i_internal_rd_if     : in    t_internal_rd_if
    );

  -----------------------------------------------------------------------
  -- WriteToBlockPipeIn
  -----------------------------------------------------------------------
  procedure WriteToBlockPipeIn(
    i_ep                        : in    std_logic_vector(7 downto 0);
    i_blockLength               : in    integer;
    i_length                    : in    integer;
    variable b_front_panel_conf : inout t_front_panel_conf;
    signal o_internal_wr_if     : out   t_internal_wr_if;
    signal i_internal_rd_if     : in    t_internal_rd_if
    );

  -----------------------------------------------------------------------
  -- ReadFromBlockPipeOut
  -----------------------------------------------------------------------
  procedure ReadFromBlockPipeOut(
    i_ep                        : in    std_logic_vector(7 downto 0);
    i_blockLength               : in    integer;
    i_length                    : in    integer;
    variable b_front_panel_conf : inout t_front_panel_conf;
    signal o_internal_wr_if     : out   t_internal_wr_if;
    signal i_internal_rd_if     : in    t_internal_rd_if
    );

  -----------------------------------------------------------------------
  -- WriteRegister
  -----------------------------------------------------------------------
  procedure WriteRegister(
    i_address               : in  std_logic_vector(31 downto 0);
    i_data                  : in  std_logic_vector(31 downto 0);
    signal o_internal_wr_if : out t_internal_wr_if;
    signal i_internal_rd_if : in  t_internal_rd_if
    );

  -----------------------------------------------------------------------
  -- ReadRegister
  -----------------------------------------------------------------------
  procedure ReadRegister(
    i_address               : in  std_logic_vector(31 downto 0);
    o_data                  : out std_logic_vector(31 downto 0);
    signal o_internal_wr_if : out t_internal_wr_if;
    signal i_internal_rd_if : in  t_internal_rd_if
    );

  -----------------------------------------------------------------------
  -- WriteRegisterSet
  -----------------------------------------------------------------------
  procedure WriteRegisterSet(
    variable b_front_panel_conf : inout t_front_panel_conf;
    signal o_internal_wr_if     : out   t_internal_wr_if;
    signal i_internal_rd_if     : in    t_internal_rd_if
    );

  -----------------------------------------------------------------------
  -- ReadRegisterSet
  -----------------------------------------------------------------------
  procedure ReadRegisterSet(
    variable b_front_panel_conf : inout t_front_panel_conf;
    signal o_internal_wr_if     : out   t_internal_wr_if;
    signal i_internal_rd_if     : in    t_internal_rd_if
    );

  ------------------------------------------------------
  -- this procedure allows to wait a number of rising edge
  -- then a margin is applied, if any
  ------------------------------------------------------
  procedure wait_nb_rising_edge_plus_margin(
    signal i_clk              : in std_logic;
    constant i_nb_rising_edge : in natural;
    constant i_margin         : in time
    );

end pkg_front_panel;

package body pkg_front_panel is

  type t_front_panel_conf is protected body
                                         variable pipeIn : PIPEIN_ARRAY(0 to pipeInSize - 1);

                                       variable pipeOut : PIPEOUT_ARRAY(0 to pipeOutSize - 1);

                                       variable WireIns   : STD_ARRAY(0 to 31);  -- 32x32 array storing WireIn values
                                       variable WireOuts  : STD_ARRAY(0 to 31);  -- 32x32 array storing WireOut values
                                       variable Triggered : STD_ARRAY(0 to 31);  -- 32x32 array storing IsTriggered values

                                       variable u32Address : REGISTER_ARRAY(0 to registerSetSize - 1);
                                       variable u32Data    : REGISTER_ARRAY(0 to registerSetSize - 1);
                                       variable u32Count   : std_logic_vector(31 downto 0);
                                       --ReadRegisterData : std_logic_vector(31 downto 0);

                                       procedure set_WireIns(i_index : in integer; i_value : in std_logic_vector) is
                                       begin
                                         WireIns(i_index) := i_value;
                                       end;

  procedure set_WireOuts(i_index : in integer; i_value : in std_logic_vector) is
  begin
    WireOuts(i_index) := i_value;
  end;

  procedure set_Triggered(i_index : in integer; i_value : in std_logic_vector) is
  begin
    Triggered(i_index) := i_value;
  end;

  procedure set_pipeIn(i_index : in integer; i_value : in std_logic_vector) is
  begin
    pipeIn(i_index) := i_value;
  end;

  procedure set_pipeOut(i_index : in integer; i_value : in std_logic_vector) is
  begin
    pipeOut(i_index) := i_value;
  end;

  procedure set_u32Data(i_index : in integer; i_value : in std_logic_vector) is
  begin
    u32Data(i_index) := i_value;
  end;

  impure function get_WireIns(i_index : in integer) return std_logic_vector is
  begin
    return WireIns(i_index);
  end;

  impure function get_WireOuts(i_index : in integer) return std_logic_vector is
  begin
    return WireOuts(i_index);
  end;

  impure function get_Triggered(i_index : in integer) return std_logic_vector is
  begin
    return Triggered(i_index);
  end;

  impure function get_pipeIn(i_index : in integer) return std_logic_vector is
  begin
    return pipeIn(i_index);
  end;

  impure function get_pipeOut(i_index : in integer) return std_logic_vector is
  begin
    return pipeOut(i_index);
  end;

  impure function get_u32Count return std_logic_vector is
  begin
    return u32Count;
  end;

  impure function get_u32Address(i_index : in integer) return std_logic_vector is
  begin
    return u32Address(i_index);
  end;
  impure function get_u32Data(i_index : in integer) return std_logic_vector is
  begin
    return u32Data(i_index);
  end;

end protected body;

---------------------------------------------------------------------
-- okHost_driver
---------------------------------------------------------------------
procedure okHost_driver(
  signal i_clk            : in    std_logic;
  signal o_okUH           : out   std_logic_vector (4 downto 0);
  signal i_okHU           : in    std_logic_vector (2 downto 0);
  signal b_okUHU          : inout std_logic_vector (31 downto 0);
  signal i_internal_wr_if : in    t_internal_wr_if;
  signal o_internal_rd_if : out   t_internal_rd_if
  ) is

  alias hi_drive   : std_logic is i_internal_wr_if.hi_drive;
  alias hi_cmd     : std_logic_vector(i_internal_wr_if.hi_cmd'range) is i_internal_wr_if.hi_cmd;
  alias hi_dataout : std_logic_vector(i_internal_wr_if.hi_dataout'range) is i_internal_wr_if.hi_dataout;

  alias hi_busy   : std_logic is o_internal_rd_if.hi_busy;
  alias hi_datain : std_logic_vector(o_internal_rd_if.hi_datain'range) is o_internal_rd_if.hi_datain;

begin
  -- get clocks for the procedure/function
  o_internal_rd_if.i_clk <= i_clk;
  -- okHostCalls Simulation okHostCall<->okHost Mapping  --------------------------------------
  ---------------------------------------------------------------------
  -- drive usb ports
  ---------------------------------------------------------------------
  o_okUH(0)              <= i_clk;
  o_okUH(1)              <= hi_drive;
  o_okUH(4 downto 2)     <= hi_cmd;
  hi_datain              <= b_okUHU;
  hi_busy                <= i_okHU(0);
  b_okUHU                <= hi_dataout when (hi_drive = '1') else (others => 'Z');
end okHost_driver;

-----------------------------------------------------------------------
-- FrontPanelReset
-----------------------------------------------------------------------
procedure FrontPanelReset(
  variable b_front_panel_conf : inout t_front_panel_conf;
  signal o_internal_wr_if     : out   t_internal_wr_if;
  signal i_internal_rd_if     : in    t_internal_rd_if
  ) is
  alias hi_cmd : std_logic_vector(o_internal_wr_if.hi_cmd'range) is o_internal_wr_if.hi_cmd;

  alias i_clk   : std_logic is i_internal_rd_if.i_clk;
  alias hi_busy : std_logic is i_internal_rd_if.hi_busy;

  constant c_ZEROS : std_logic_vector(31 downto 0) := (others => '0');

begin
  for i in 31 downto 0 loop
    b_front_panel_conf.set_WireIns(i_index   => i, i_value => c_ZEROS);
    b_front_panel_conf.set_WireOuts(i_index  => i, i_value => c_ZEROS);
    b_front_panel_conf.set_Triggered(i_index => i, i_value => c_ZEROS);
  end loop;
  wait until (rising_edge(i_clk));
  hi_cmd <= DReset;
  wait until (rising_edge(i_clk));
  hi_cmd <= DNOP;
  wait on i_clk until (hi_busy = '0');
end procedure FrontPanelReset;

-----------------------------------------------------------------------
-- SetWireInValue
-----------------------------------------------------------------------
procedure SetWireInValue(
  i_ep                        : in    std_logic_vector(7 downto 0);
  i_val                       : in    std_logic_vector(31 downto 0);
  i_mask                      : in    std_logic_vector(31 downto 0);
  variable b_front_panel_conf : inout t_front_panel_conf
  ) is

  variable tmp_slv32 : std_logic_vector(31 downto 0);
  variable tmpI      : integer;

begin
  tmpI      := to_integer(unsigned(i_ep));
  tmp_slv32 := b_front_panel_conf.get_WireIns(tmpI) and (not i_mask);
  b_front_panel_conf.set_WireIns(i_index => tmpI, i_value => (tmp_slv32 or (i_val and i_mask)));
end procedure SetWireInValue;

-----------------------------------------------------------------------
-- UpdateWireIns
-----------------------------------------------------------------------
procedure UpdateWireIns(
  variable b_front_panel_conf : inout t_front_panel_conf;
  signal o_internal_wr_if     : out   t_internal_wr_if;
  signal i_internal_rd_if     : in    t_internal_rd_if
  ) is
  alias hi_drive   : std_logic is o_internal_wr_if.hi_drive;
  alias hi_cmd     : std_logic_vector(o_internal_wr_if.hi_cmd'range) is o_internal_wr_if.hi_cmd;
  alias hi_dataout : std_logic_vector(o_internal_wr_if.hi_dataout'range) is o_internal_wr_if.hi_dataout;

  alias i_clk   : std_logic is i_internal_rd_if.i_clk;
  alias hi_busy : std_logic is i_internal_rd_if.hi_busy;

begin
  wait until (rising_edge(i_clk));
  hi_cmd   <= DWires;
  wait until (rising_edge(i_clk));
  hi_cmd   <= DUpdateWireIns;
  wait until (rising_edge(i_clk));
  hi_drive <= '1';
  wait until (rising_edge(i_clk));
  hi_cmd   <= DNOP;
  for i in 0 to 31 loop
    hi_dataout <= b_front_panel_conf.get_WireIns(i);
    wait until (rising_edge(i_clk));
  end loop;
  wait on i_clk until (hi_busy = '0');
end procedure UpdateWireIns;

-----------------------------------------------------------------------
-- GetWireOutValue
-----------------------------------------------------------------------
procedure GetWireOutValue(
  i_ep               :       std_logic_vector;
  b_front_panel_conf : inout t_front_panel_conf;
  o_result           : out   std_logic_vector
  ) is

  variable tmp_slv32 : std_logic_vector(31 downto 0);
  variable tmpI      : integer;

begin
  tmpI      := to_integer(unsigned(i_ep));
  tmp_slv32 := b_front_panel_conf.get_WireOuts(tmpI - 16#20#);
  o_result  := tmp_slv32;
end GetWireOutValue;

-----------------------------------------------------------------------
-- IsTriggered
---------------------------------------------------------------------
procedure IsTriggered(
  i_ep                        :       std_logic_vector;
  i_mask                      :       std_logic_vector(31 downto 0);
  variable b_front_panel_conf : inout t_front_panel_conf;
  o_result                    : out   boolean
  ) is

  variable tmp_slv32 : std_logic_vector(i_mask'range);
  variable tmpI      : integer;
  variable msg_line  : line;

begin
  tmpI      := to_integer(unsigned(i_ep));
  tmp_slv32 := (b_front_panel_conf.get_Triggered(tmpI - 16#60#) and i_mask);

  if (tmp_slv32 >= std_logic_vector(to_unsigned(0, tmp_slv32'length))) then
    if (tmp_slv32 = std_logic_vector(to_unsigned(0, tmp_slv32'length))) then
      o_result := false;
    else
      o_result := true;
    end if;
  else
    write(msg_line, string'("***FRONTPANEL ERROR: IsTriggered i_mask 0x"));
    hwrite(msg_line, i_mask);
    write(msg_line, string'(" covers unused Triggers"));
    writeline(output, msg_line);
    o_result := false;
  end if;
end IsTriggered;

-----------------------------------------------------------------------
-- UpdateWireOuts
-----------------------------------------------------------------------
procedure UpdateWireOuts(
  variable b_front_panel_conf : inout t_front_panel_conf;
  signal o_internal_wr_if     : out   t_internal_wr_if;
  signal i_internal_rd_if     : in    t_internal_rd_if
  ) is

  alias hi_drive : std_logic is o_internal_wr_if.hi_drive;
  alias hi_cmd   : std_logic_vector(o_internal_wr_if.hi_cmd'range) is o_internal_wr_if.hi_cmd;

  alias i_clk     : std_logic is i_internal_rd_if.i_clk;
  alias hi_busy   : std_logic is i_internal_rd_if.hi_busy;
  alias hi_datain : std_logic_vector(i_internal_rd_if.hi_datain'range) is i_internal_rd_if.hi_datain;

begin
  wait until (rising_edge(i_clk));
  hi_cmd   <= DWires;
  wait until (rising_edge(i_clk));
  hi_cmd   <= DUpdateWireOuts;
  wait until (rising_edge(i_clk));
  wait until (rising_edge(i_clk));
  hi_cmd   <= DNOP;
  wait until (rising_edge(i_clk));
  hi_drive <= '0';
  wait until (rising_edge(i_clk));
  wait until (rising_edge(i_clk));
  for i in 0 to 31 loop
    wait until (rising_edge(i_clk));
    b_front_panel_conf.set_WireOuts(i_index => i, i_value => hi_datain);
  end loop;
  wait on i_clk until (hi_busy = '0');
end procedure UpdateWireOuts;

-----------------------------------------------------------------------
-- ActivateTriggerIn
-----------------------------------------------------------------------
procedure ActivateTriggerIn(
  i_ep                    : in  std_logic_vector(7 downto 0);
  i_bit                   : in  integer;
  signal o_internal_wr_if : out t_internal_wr_if;
  signal i_internal_rd_if : in  t_internal_rd_if
  ) is

  constant c_ONE : unsigned(31 downto 0) := x"00000001";

  alias hi_drive   : std_logic is o_internal_wr_if.hi_drive;
  alias hi_cmd     : std_logic_vector(o_internal_wr_if.hi_cmd'range) is o_internal_wr_if.hi_cmd;
  alias hi_dataout : std_logic_vector(o_internal_wr_if.hi_dataout'range) is o_internal_wr_if.hi_dataout;

  alias i_clk   : std_logic is i_internal_rd_if.i_clk;
  alias hi_busy : std_logic is i_internal_rd_if.hi_busy;

begin
  wait until (rising_edge(i_clk));
  hi_cmd     <= DTriggers;
  wait until (rising_edge(i_clk));
  hi_cmd     <= DActivateTriggerIn;
  wait until (rising_edge(i_clk));
  hi_drive   <= '1';
  hi_dataout <= (x"000000" & i_ep);
  wait until (rising_edge(i_clk));
  hi_dataout <= std_logic_vector(c_ONE sll i_bit);
  hi_cmd     <= DNOP;
  wait until (rising_edge(i_clk));
  hi_dataout <= x"00000000";
  wait on i_clk until (hi_busy = '0');
end procedure ActivateTriggerIn;

-----------------------------------------------------------------------
-- ActivateTriggerIn_by_data
-----------------------------------------------------------------------
procedure ActivateTriggerIn_by_data(
  i_ep                    : in  std_logic_vector(7 downto 0);
  i_data                  : in  std_logic_vector(31 downto 0);
  signal o_internal_wr_if : out t_internal_wr_if;
  signal i_internal_rd_if : in  t_internal_rd_if
  ) is

  alias hi_drive   : std_logic is o_internal_wr_if.hi_drive;
  alias hi_cmd     : std_logic_vector(o_internal_wr_if.hi_cmd'range) is o_internal_wr_if.hi_cmd;
  alias hi_dataout : std_logic_vector(o_internal_wr_if.hi_dataout'range) is o_internal_wr_if.hi_dataout;

  alias i_clk   : std_logic is i_internal_rd_if.i_clk;
  alias hi_busy : std_logic is i_internal_rd_if.hi_busy;

begin
  wait until (rising_edge(i_clk));
  hi_cmd     <= DTriggers;
  wait until (rising_edge(i_clk));
  hi_cmd     <= DActivateTriggerIn;
  wait until (rising_edge(i_clk));
  hi_drive   <= '1';
  hi_dataout <= (x"000000" & i_ep);
  wait until (rising_edge(i_clk));
  hi_dataout <= i_data;
  hi_cmd     <= DNOP;
  wait until (rising_edge(i_clk));
  hi_dataout <= x"00000000";
  wait on i_clk until (hi_busy = '0');
end procedure ActivateTriggerIn_by_data;

-----------------------------------------------------------------------
-- UpdateTriggerOuts
-----------------------------------------------------------------------
procedure UpdateTriggerOuts(
  variable b_front_panel_conf : inout t_front_panel_conf;
  signal o_internal_wr_if     : out   t_internal_wr_if;
  signal i_internal_rd_if     : in    t_internal_rd_if
  ) is

  alias hi_drive : std_logic is o_internal_wr_if.hi_drive;
  alias hi_cmd   : std_logic_vector(o_internal_wr_if.hi_cmd'range) is o_internal_wr_if.hi_cmd;

  alias i_clk     : std_logic is i_internal_rd_if.i_clk;
  alias hi_busy   : std_logic is i_internal_rd_if.hi_busy;
  alias hi_datain : std_logic_vector(i_internal_rd_if.hi_datain'range) is i_internal_rd_if.hi_datain;

begin
  wait until (rising_edge(i_clk));
  hi_cmd   <= DTriggers;
  wait until (rising_edge(i_clk));
  hi_cmd   <= DUpdateTriggerOuts;
  wait until (rising_edge(i_clk));
  wait until (rising_edge(i_clk));
  hi_cmd   <= DNOP;
  wait until (rising_edge(i_clk));
  hi_drive <= '0';
  wait until (rising_edge(i_clk));
  wait until (rising_edge(i_clk));
  wait until (rising_edge(i_clk));

  for i in 0 to (UPDATE_TO_READOUT_CLOCKS - 1) loop
    wait until (rising_edge(i_clk));
  end loop;

  for i in 0 to 31 loop
    wait until (rising_edge(i_clk));
    b_front_panel_conf.set_Triggered(i_index => i, i_value => hi_datain);
  end loop;
  wait on i_clk until (hi_busy = '0');
end procedure UpdateTriggerOuts;

-----------------------------------------------------------------------
-- WriteToPipeIn
-----------------------------------------------------------------------
procedure WriteToPipeIn(
  i_ep                        : in    std_logic_vector(7 downto 0);
  i_length                    : in    integer;
  variable b_front_panel_conf : inout t_front_panel_conf;
  signal o_internal_wr_if     : out   t_internal_wr_if;
  signal i_internal_rd_if     : in    t_internal_rd_if
  ) is

  variable len, i, j, k, blockSize : integer;
  variable tmp_slv8                : std_logic_vector(7 downto 0);
  variable tmp_slv32               : std_logic_vector(31 downto 0);

  alias hi_drive   : std_logic is o_internal_wr_if.hi_drive;
  alias hi_cmd     : std_logic_vector(o_internal_wr_if.hi_cmd'range) is o_internal_wr_if.hi_cmd;
  alias hi_dataout : std_logic_vector(o_internal_wr_if.hi_dataout'range) is o_internal_wr_if.hi_dataout;

  alias i_clk   : std_logic is i_internal_rd_if.i_clk;
  alias hi_busy : std_logic is i_internal_rd_if.hi_busy;

  --alias pipeIn           : PIPEIN_ARRAY(front_panel_conf.pipeIn'range) is front_panel_conf.pipeIn;

begin
  len       := (i_length / 4);
  j         := 0;
  k         := 0;
  blockSize := 1024;
  tmp_slv8  := std_logic_vector(to_unsigned(BlockDelayStates, tmp_slv8'length));
  tmp_slv32 := std_logic_vector(to_unsigned(len, tmp_slv32'length));

  wait until (rising_edge(i_clk));
  hi_cmd     <= DPipes;
  wait until (rising_edge(i_clk));
  hi_cmd     <= DWriteToPipeIn;
  wait until (rising_edge(i_clk));
  hi_drive   <= '1';
  hi_dataout <= (x"0000" & tmp_slv8 & i_ep);
  wait until (rising_edge(i_clk));
  hi_cmd     <= DNOP;
  hi_dataout <= tmp_slv32;
  for i in 0 to len - 1 loop
    wait until (rising_edge(i_clk));
    hi_dataout(7 downto 0)   <= b_front_panel_conf.get_pipeIn(i * 4);
    hi_dataout(15 downto 8)  <= b_front_panel_conf.get_pipeIn((i * 4) + 1);
    hi_dataout(23 downto 16) <= b_front_panel_conf.get_pipeIn((i * 4) + 2);
    hi_dataout(31 downto 24) <= b_front_panel_conf.get_pipeIn((i * 4) + 3);
    j                        := j + 4;
    if (j = blockSize) then
      for k in 0 to BlockDelayStates - 1 loop
        wait until (rising_edge(i_clk));
      end loop;
      j := 0;
    end if;
  end loop;
  wait on i_clk until (hi_busy = '0');
end procedure WriteToPipeIn;

-----------------------------------------------------------------------
-- ReadFromPipeOut
-----------------------------------------------------------------------
procedure ReadFromPipeOut(
  i_ep                        : in    std_logic_vector(7 downto 0);
  i_length                    : in    integer;
  variable b_front_panel_conf : inout t_front_panel_conf;
  signal o_internal_wr_if     : out   t_internal_wr_if;
  signal i_internal_rd_if     : in    t_internal_rd_if
  ) is


  variable len       : integer;
  variable i         : integer;
  variable j         : integer;
  variable k         : integer;
  variable blockSize : integer;
  variable tmp_slv8  : std_logic_vector(7 downto 0);
  variable tmp_slv32 : std_logic_vector(31 downto 0);

  alias hi_drive   : std_logic is o_internal_wr_if.hi_drive;
  alias hi_cmd     : std_logic_vector(o_internal_wr_if.hi_cmd'range) is o_internal_wr_if.hi_cmd;
  alias hi_dataout : std_logic_vector(o_internal_wr_if.hi_dataout'range) is o_internal_wr_if.hi_dataout;

  alias i_clk     : std_logic is i_internal_rd_if.i_clk;
  alias hi_busy   : std_logic is i_internal_rd_if.hi_busy;
  alias hi_datain : std_logic_vector(i_internal_rd_if.hi_datain'range) is i_internal_rd_if.hi_datain;

begin
  len       := (i_length / 4);
  j         := 0;
  blockSize := 1024;
  tmp_slv8  := std_logic_vector(to_unsigned(BlockDelayStates, tmp_slv8'length));
  tmp_slv32 := std_logic_vector(to_unsigned(len, tmp_slv32'length));

  wait until (rising_edge(i_clk));
  hi_cmd     <= DPipes;
  wait until (rising_edge(i_clk));
  hi_cmd     <= DReadFromPipeOut;
  wait until (rising_edge(i_clk));
  hi_drive   <= '1';
  hi_dataout <= (x"0000" & tmp_slv8 & i_ep);
  wait until (rising_edge(i_clk));
  hi_cmd     <= DNOP;
  hi_dataout <= tmp_slv32;
  wait until (rising_edge(i_clk));
  hi_drive   <= '0';
  for i in 0 to len - 1 loop
    wait until (rising_edge(i_clk));
    b_front_panel_conf.set_pipeOut(i_index => (i * 4), i_value => hi_datain(7 downto 0));
    b_front_panel_conf.set_pipeOut(i_index => (i * 4) + 1, i_value => hi_datain(15 downto 8));
    b_front_panel_conf.set_pipeOut(i_index => (i * 4) + 2, i_value => hi_datain(23 downto 16));
    b_front_panel_conf.set_pipeOut(i_index => (i * 4) + 3, i_value => hi_datain(31 downto 24));
    j := j + 4;
    if (j = blockSize) then
      for k in 0 to BlockDelayStates - 1 loop
        wait until (rising_edge(i_clk));
      end loop;
      j := 0;
    end if;
  end loop;
  wait on i_clk until (hi_busy = '0');
end procedure ReadFromPipeOut;

-----------------------------------------------------------------------
-- WriteToBlockPipeIn
-----------------------------------------------------------------------
procedure WriteToBlockPipeIn(
  i_ep                        : in    std_logic_vector(7 downto 0);
  i_blockLength               : in    integer;
  i_length                    : in    integer;
  variable b_front_panel_conf : inout t_front_panel_conf;
  signal o_internal_wr_if     : out   t_internal_wr_if;
  signal i_internal_rd_if     : in    t_internal_rd_if
  ) is

  variable len       : integer;
  variable j         : integer;
  variable k         : integer;
  variable blockSize : integer;
  variable blockNum  : integer;
  variable tmp_slv8  : std_logic_vector(7 downto 0);
  variable tmp_slv16 : std_logic_vector(15 downto 0);
  variable tmp_slv32 : std_logic_vector(31 downto 0);

  alias hi_drive   : std_logic is o_internal_wr_if.hi_drive;
  alias hi_cmd     : std_logic_vector(o_internal_wr_if.hi_cmd'range) is o_internal_wr_if.hi_cmd;
  alias hi_dataout : std_logic_vector(o_internal_wr_if.hi_dataout'range) is o_internal_wr_if.hi_dataout;

  alias i_clk   : std_logic is i_internal_rd_if.i_clk;
  alias hi_busy : std_logic is i_internal_rd_if.hi_busy;

begin
  len       := (i_length / 4);
  blockSize := (i_blockLength / 4);
  j         := 0;
  k         := 0;
  blockNum  := (len / blockSize);
  tmp_slv8  := std_logic_vector(to_unsigned(BlockDelayStates, tmp_slv8'length));
  tmp_slv16 := std_logic_vector(to_unsigned(blockSize, tmp_slv16'length));
  tmp_slv32 := std_logic_vector(to_unsigned(len, tmp_slv32'length));

  wait until (rising_edge(i_clk));
  hi_cmd                 <= DPipes;
  wait until (rising_edge(i_clk));
  hi_cmd                 <= DWriteToBlockPipeIn;
  wait until (rising_edge(i_clk));
  hi_drive               <= '1';
  hi_dataout             <= (x"0000" & tmp_slv8 & i_ep);
  wait until (rising_edge(i_clk));
  hi_cmd                 <= DNOP;
  hi_dataout             <= tmp_slv32;
  wait until (rising_edge(i_clk));
  hi_dataout             <= x"0000" & tmp_slv16;
  wait until (rising_edge(i_clk));
  tmp_slv16(15 downto 8) := std_logic_vector(to_unsigned(PostReadyDelay, 8));
  tmp_slv16(7 downto 0)  := std_logic_vector(to_unsigned(ReadyCheckDelay, 8));
  hi_dataout             <= x"0000" & tmp_slv16;
  for i in 1 to blockNum loop
    while (hi_busy = '1') loop
      wait until (rising_edge(i_clk));
    end loop;
    while (hi_busy = '0') loop
      wait until (rising_edge(i_clk));
    end loop;
    wait until (rising_edge(i_clk));
    wait until (rising_edge(i_clk));
    for j in 1 to blockSize loop
      hi_dataout(7 downto 0)   <= b_front_panel_conf.get_pipeIn(k);
      hi_dataout(15 downto 8)  <= b_front_panel_conf.get_pipeIn(k + 1);
      hi_dataout(23 downto 16) <= b_front_panel_conf.get_pipeIn(k + 2);
      hi_dataout(31 downto 24) <= b_front_panel_conf.get_pipeIn(k + 3);
      wait until (rising_edge(i_clk));
      k                        := k + 4;
    end loop;
    for j in 1 to BlockDelayStates loop
      wait until (rising_edge(i_clk));
    end loop;
  end loop;
  wait on i_clk until (hi_busy = '0');
end procedure WriteToBlockPipeIn;

-----------------------------------------------------------------------
-- ReadFromBlockPipeOut
-----------------------------------------------------------------------
procedure ReadFromBlockPipeOut(
  i_ep                        : in    std_logic_vector(7 downto 0);
  i_blockLength               : in    integer;
  i_length                    : in    integer;
  variable b_front_panel_conf : inout t_front_panel_conf;
  signal o_internal_wr_if     : out   t_internal_wr_if;
  signal i_internal_rd_if     : in    t_internal_rd_if
  ) is

  variable len       : integer;
  variable j         : integer;
  variable k         : integer;
  variable blockSize : integer;
  variable blockNum  : integer;
  variable tmp_slv8  : std_logic_vector(7 downto 0);
  variable tmp_slv16 : std_logic_vector(15 downto 0);
  variable tmp_slv32 : std_logic_vector(31 downto 0);

  alias hi_drive   : std_logic is o_internal_wr_if.hi_drive;
  alias hi_cmd     : std_logic_vector(o_internal_wr_if.hi_cmd'range) is o_internal_wr_if.hi_cmd;
  alias hi_dataout : std_logic_vector(o_internal_wr_if.hi_dataout'range) is o_internal_wr_if.hi_dataout;

  alias i_clk     : std_logic is i_internal_rd_if.i_clk;
  alias hi_busy   : std_logic is i_internal_rd_if.hi_busy;
  alias hi_datain : std_logic_vector(i_internal_rd_if.hi_datain'range) is i_internal_rd_if.hi_datain;

begin
  len       := (i_length / 4);
  blockSize := (i_blockLength / 4);
  j         := 0;
  k         := 0;
  blockNum  := (len / blockSize);
  tmp_slv8  := std_logic_vector(to_unsigned(BlockDelayStates, tmp_slv8'length));
  tmp_slv16 := std_logic_vector(to_unsigned(blockSize, tmp_slv16'length));
  tmp_slv32 := std_logic_vector(to_unsigned(len, tmp_slv32'length));

  wait until (rising_edge(i_clk));
  hi_cmd                 <= DPipes;
  wait until (rising_edge(i_clk));
  hi_cmd                 <= DReadFromBlockPipeOut;
  wait until (rising_edge(i_clk));
  hi_drive               <= '1';
  hi_dataout             <= (x"0000" & tmp_slv8 & i_ep);
  wait until (rising_edge(i_clk));
  hi_cmd                 <= DNOP;
  hi_dataout             <= tmp_slv32;
  wait until (rising_edge(i_clk));
  hi_dataout             <= x"0000" & tmp_slv16;
  wait until (rising_edge(i_clk));
  tmp_slv16(15 downto 8) := std_logic_vector(to_unsigned(PostReadyDelay, 8));
  tmp_slv16(7 downto 0)  := std_logic_vector(to_unsigned(ReadyCheckDelay, 8));
  hi_dataout             <= x"0000" & tmp_slv16;
  wait until (rising_edge(i_clk));
  hi_drive               <= '0';
  for i in 1 to blockNum loop
    while (hi_busy = '1') loop
      wait until (rising_edge(i_clk));
    end loop;
    while (hi_busy = '0') loop
      wait until (rising_edge(i_clk));
    end loop;
    wait until (rising_edge(i_clk));
    wait until (rising_edge(i_clk));
    for j in 1 to blockSize loop
      b_front_panel_conf.set_pipeOut(i_index => k, i_value => hi_datain(7 downto 0));
      b_front_panel_conf.set_pipeOut(i_index => k + 1, i_value => hi_datain(15 downto 8));
      b_front_panel_conf.set_pipeOut(i_index => k + 2, i_value => hi_datain(23 downto 16));
      b_front_panel_conf.set_pipeOut(i_index => k + 3, i_value => hi_datain(31 downto 24));
      wait until (rising_edge(i_clk));
      k := k + 4;
    end loop;
    for j in 1 to BlockDelayStates loop
      wait until (rising_edge(i_clk));
    end loop;
  end loop;
  wait on i_clk until (hi_busy = '0');
end procedure ReadFromBlockPipeOut;

-----------------------------------------------------------------------
-- WriteRegister
-----------------------------------------------------------------------
procedure WriteRegister(
  i_address               : in  std_logic_vector(31 downto 0);
  i_data                  : in  std_logic_vector(31 downto 0);
  signal o_internal_wr_if : out t_internal_wr_if;
  signal i_internal_rd_if : in  t_internal_rd_if
  ) is

  alias hi_drive   : std_logic is o_internal_wr_if.hi_drive;
  alias hi_cmd     : std_logic_vector(o_internal_wr_if.hi_cmd'range) is o_internal_wr_if.hi_cmd;
  alias hi_dataout : std_logic_vector(o_internal_wr_if.hi_dataout'range) is o_internal_wr_if.hi_dataout;

  alias i_clk   : std_logic is i_internal_rd_if.i_clk;
  alias hi_busy : std_logic is i_internal_rd_if.hi_busy;

begin
  wait until (rising_edge(i_clk));
  hi_cmd     <= DRegisters;
  wait until (rising_edge(i_clk));
  hi_cmd     <= DWriteRegister;
  wait until (rising_edge(i_clk));
  hi_drive   <= '1';
  hi_cmd     <= DNOP;
  wait until (rising_edge(i_clk));
  hi_dataout <= i_address;
  wait until (rising_edge(i_clk));
  hi_dataout <= i_data;
  wait on i_clk until (hi_busy = '0');
  hi_drive   <= '0';
end procedure WriteRegister;

-----------------------------------------------------------------------
-- ReadRegister
-----------------------------------------------------------------------
procedure ReadRegister(
  i_address               : in  std_logic_vector(31 downto 0);
  o_data                  : out std_logic_vector(31 downto 0);
  signal o_internal_wr_if : out t_internal_wr_if;
  signal i_internal_rd_if : in  t_internal_rd_if
  ) is

  alias hi_drive   : std_logic is o_internal_wr_if.hi_drive;
  alias hi_cmd     : std_logic_vector(o_internal_wr_if.hi_cmd'range) is o_internal_wr_if.hi_cmd;
  alias hi_dataout : std_logic_vector(o_internal_wr_if.hi_dataout'range) is o_internal_wr_if.hi_dataout;

  alias i_clk     : std_logic is i_internal_rd_if.i_clk;
  alias hi_datain : std_logic_vector(i_internal_rd_if.hi_datain'range) is i_internal_rd_if.hi_datain;
  alias hi_busy   : std_logic is i_internal_rd_if.hi_busy;

begin
  wait until (rising_edge(i_clk));
  hi_cmd     <= DRegisters;
  wait until (rising_edge(i_clk));
  hi_cmd     <= DReadRegister;
  wait until (rising_edge(i_clk));
  hi_drive   <= '1';
  hi_cmd     <= DNOP;
  wait until (rising_edge(i_clk));
  hi_dataout <= i_address;
  wait until (rising_edge(i_clk));
  hi_drive   <= '0';
  wait until (rising_edge(i_clk));
  wait until (rising_edge(i_clk));
  o_data     := hi_datain;
  wait on i_clk until (hi_busy = '0');
end procedure ReadRegister;

-----------------------------------------------------------------------
-- WriteRegisterSet
-----------------------------------------------------------------------
procedure WriteRegisterSet(
  variable b_front_panel_conf : inout t_front_panel_conf;
  signal o_internal_wr_if     : out   t_internal_wr_if;
  signal i_internal_rd_if     : in    t_internal_rd_if
  ) is

  variable u32Count_int : integer;

  alias hi_drive   : std_logic is o_internal_wr_if.hi_drive;
  alias hi_cmd     : std_logic_vector(o_internal_wr_if.hi_cmd'range) is o_internal_wr_if.hi_cmd;
  alias hi_dataout : std_logic_vector(o_internal_wr_if.hi_dataout'range) is o_internal_wr_if.hi_dataout;

  alias i_clk   : std_logic is i_internal_rd_if.i_clk;
  alias hi_busy : std_logic is i_internal_rd_if.hi_busy;

begin
  u32Count_int := to_integer(unsigned(b_front_panel_conf.get_u32Count));
  wait until (rising_edge(i_clk));
  hi_cmd       <= DRegisters;
  wait until (rising_edge(i_clk));
  hi_cmd       <= DWriteRegisterSet;
  wait until (rising_edge(i_clk));
  hi_drive     <= '1';
  hi_cmd       <= DNOP;
  wait until (rising_edge(i_clk));
  hi_dataout   <= b_front_panel_conf.get_u32Count;
  for i in 1 to u32Count_int loop
    wait until (rising_edge(i_clk));
    hi_dataout <= b_front_panel_conf.get_u32Address(i - 1);
    wait until (rising_edge(i_clk));
    hi_dataout <= b_front_panel_conf.get_u32Data(i - 1);
    wait until (rising_edge(i_clk));
    wait until (rising_edge(i_clk));
  end loop;
  wait on i_clk until (hi_busy = '0');
  hi_drive <= '0';
end procedure WriteRegisterSet;

-----------------------------------------------------------------------
-- ReadRegisterSet
-----------------------------------------------------------------------
procedure ReadRegisterSet(
  variable b_front_panel_conf : inout t_front_panel_conf;
  signal o_internal_wr_if     : out   t_internal_wr_if;
  signal i_internal_rd_if     : in    t_internal_rd_if
  ) is
  variable u32Count_int : integer;

  alias hi_drive   : std_logic is o_internal_wr_if.hi_drive;
  alias hi_cmd     : std_logic_vector(o_internal_wr_if.hi_cmd'range) is o_internal_wr_if.hi_cmd;
  alias hi_dataout : std_logic_vector(o_internal_wr_if.hi_dataout'range) is o_internal_wr_if.hi_dataout;

  alias i_clk     : std_logic is i_internal_rd_if.i_clk;
  alias hi_busy   : std_logic is i_internal_rd_if.hi_busy;
  alias hi_datain : std_logic_vector(i_internal_rd_if.hi_datain'range) is i_internal_rd_if.hi_datain;

begin
  u32Count_int := to_integer(unsigned(b_front_panel_conf.get_u32Count));
  wait until (rising_edge(i_clk));
  hi_cmd       <= DRegisters;
  wait until (rising_edge(i_clk));
  hi_cmd       <= DReadRegisterSet;
  wait until (rising_edge(i_clk));
  hi_drive     <= '1';
  hi_cmd       <= DNOP;
  wait until (rising_edge(i_clk));
  hi_dataout   <= b_front_panel_conf.get_u32Count;
  for i in 1 to u32Count_int loop
    wait until (rising_edge(i_clk));
    hi_dataout <= b_front_panel_conf.get_u32Address(i - 1);
    wait until (rising_edge(i_clk));
    hi_drive   <= '0';
    wait until (rising_edge(i_clk));
    wait until (rising_edge(i_clk));
    b_front_panel_conf.set_u32Data(i_index => i - 1, i_value => hi_datain);
    hi_drive   <= '1';
  end loop;
  wait on i_clk until (hi_busy = '0');
end procedure ReadRegisterSet;

------------------------------------------------------
-- this procedure allows to wait a number of rising edge
-- then a margin is applied, if any
------------------------------------------------------
procedure wait_nb_rising_edge_plus_margin(
  signal i_clk              : in std_logic;
  constant i_nb_rising_edge : in natural;
  constant i_margin         : in time
  ) is
begin
  -- Wait for number of rising edges
  --   if the number of rising edges = 0 => only the margin is applied, if any
  if i_nb_rising_edge /= 0 then
    for i in 1 to i_nb_rising_edge loop
      wait until rising_edge(i_clk);
    end loop;
  end if;
  -- Wait for i_margin time, if any
  wait for i_margin;
end procedure;
end pkg_front_panel;
