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
--!   @file                   pkg_front_panel.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--!   @details                
--
--    This VHDL package is based on the "Opal Kelly\FrontPanelUSB\Samples\Simulation\USB3\VHDL example\sim_tf.vhd" example design.
--    It allows to control USB port signals.
--    It redefines the functions/procedures in a package instead of a plain text in the VHDL testbench.
--    The objective is to facilitate readability but also to facilitate the possibility of controlling several different USB ports.
--
--  Note: 
--    . The functions/procedures are almost identical to the sim_tf.vhd file. Except, the 2 new added arguments:
--       1. variable front_panel_conf : inout t_front_panel_conf
--       2. signal internal_if : inout t_internal_if
--    . This script needs the simulation files (USB3) profided by the Opal Kelly company. In particular, the
--      parameters file needs to be compiled in the fpasim library.
-- -------------------------------------------------------------------------------------------------------------

library ieee;
library std;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use IEEE.std_logic_textio.all;

use std.textio.all;

library fpasim;
use fpasim.parameters.all;

package pkg_front_panel is

    type t_void is (VOID);

    ------------------------------------------------------
    -- this procedure allows to wait a number of rising edge
    -- then a margin is applied, if any
    ------------------------------------------------------
    procedure wait_nb_rising_edge_plus_margin(
        signal   i_clk            : in std_logic;
        constant i_nb_rising_edge : in natural;
        constant i_margin         : in time
    );

    type t_internal_if is record
        hi_drive   : std_logic;
        hi_cmd     : std_logic_vector(2 downto 0);
        hi_busy    : std_logic;
        hi_datain  : std_logic_vector(31 downto 0);
        hi_dataout : std_logic_vector(31 downto 0);

    end record t_internal_if;

    constant BlockDelayStates : integer := 5;    -- REQUIRED: # of clocks between blocks of pipe data
    constant ReadyCheckDelay  : integer := 5;    -- REQUIRED: # of clocks before block transfer before
                                                 --    host interface checks for ready (0-255)
    constant PostReadyDelay   : integer := 5;    -- REQUIRED: # of clocks after ready is asserted and
                                                 --    check that the block transfer begins (0-255)
    constant pipeInSize       : integer := 1024; -- REQUIRED: byte (must be even) length of default
                                               --    PipeIn; Integer 0-2^32
    constant pipeOutSize      : integer := 1024; -- REQUIRED: byte (must be even) length of default
                                               --    PipeOut; Integer 0-2^32
    constant registerSetSize  : integer := 32; 

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

    type PIPEIN_ARRAY is array (integer range <>) of std_logic_vector(7 downto 0);
    type PIPEOUT_ARRAY is array (integer range <>) of std_logic_vector(7 downto 0);
    type STD_ARRAY is array (integer range <>) of std_logic_vector(31 downto 0);
    type REGISTER_ARRAY is array (integer range <>) of std_logic_vector(31 downto 0);

    type t_front_panel_conf is record
        pipeIn           : PIPEIN_ARRAY(0 to pipeInSize - 1);

        pipeOut          : PIPEOUT_ARRAY(0 to pipeOutSize - 1);

        WireIns          : STD_ARRAY(0 to 31);   -- 32x32 array storing WireIn values
        WireOuts         : STD_ARRAY(0 to 31);   -- 32x32 array storing WireOut values 
        Triggered        : STD_ARRAY(0 to 31);   -- 32x32 array storing IsTriggered values

        u32Address       : REGISTER_ARRAY(0 to registerSetSize - 1);
        u32Data          : REGISTER_ARRAY(0 to registerSetSize - 1);
        u32Count         : std_logic_vector(31 downto 0);
        ReadRegisterData : std_logic_vector(31 downto 0);

    end record t_front_panel_conf;


    impure function init_internal_if(dummy : in integer) return t_internal_if;

    procedure okHost_driver(
        signal i_clk       : in std_logic;
        signal okUH        : out STD_LOGIC_VECTOR (4  downto 0);
        signal okHU        : in STD_LOGIC_VECTOR (2  downto 0);
        signal okUHU       : inout STD_LOGIC_VECTOR (31 downto 0);
        signal internal_if : inout t_internal_if
    );

    -----------------------------------------------------------------------
    -- Available User Task and Function Calls:
    --    FrontPanelReset;              -- Always start routine with FrontPanelReset;
    --    SetWireInValue(ep, val, mask);
    --    UpdateWireIns;
    --    UpdateWireOuts;
    --    GetWireOutValue(ep);          -- returns a 16 bit SLV
    --    ActivateTriggerIn(ep, bit);   -- bit is an integer 0-15
    --    UpdateTriggerOuts;
    --    IsTriggered(ep, mask);        -- returns a BOOLEAN
    --    WriteToPipeIn(ep, length);    -- pass pipeIn array data; length is integer
    --    ReadFromPipeOut(ep, length);  -- pass data to pipeOut array; length is integer
    --    WriteToBlockPipeIn(ep, blockSize, length);   -- pass pipeIn array data; blockSize and length are integers
    --    ReadFromBlockPipeOut(ep, blockSize, length); -- pass data to pipeOut array; blockSize and length are integers
    --    WriteRegister(addr, data);  
    --    ReadRegister(addr, data);
    --    WriteRegisterSet();  
    --    ReadRegisterSet();
    --
    -- *  Pipes operate by passing arrays of data back and forth to the user's
    --    design.  If you need multiple arrays, you can create a new procedure
    --    above and connect it to a differnet array.  More information is
    --    available in Opal Kelly documentation and online support tutorial.
    ----------------------------------------------------------------------- 
    -----------------------------------------------------------------------
    -- FrontPanelReset
    -----------------------------------------------------------------------
    procedure FrontPanelReset(signal i_clk : in std_logic; variable front_panel_conf : inout t_front_panel_conf; signal internal_if : inout t_internal_if);

    -----------------------------------------------------------------------
    -- SetWireInValue
    -----------------------------------------------------------------------
    procedure SetWireInValue(
        ep                        : in std_logic_vector(7 downto 0);
        val                       : in std_logic_vector(31 downto 0);
        mask                      : in std_logic_vector(31 downto 0);
        variable front_panel_conf : inout t_front_panel_conf
    );

    -----------------------------------------------------------------------
    -- GetWireOutValue
    -----------------------------------------------------------------------
    --impure function GetWireOutValue(
    --    ep               : std_logic_vector;
    --    front_panel_conf : in t_front_panel_conf) return std_logic_vector;

    -----------------------------------------------------------------------
    -- IsTriggered
    -----------------------------------------------------------------------
    --impure function IsTriggered(
    --    ep               : std_logic_vector;
    --    mask             : std_logic_vector(31 downto 0);
    --    front_panel_conf : t_front_panel_conf
    --) return boolean;

    -----------------------------------------------------------------------
    -- UpdateWireIns
    -----------------------------------------------------------------------
    procedure UpdateWireIns(signal   i_clk            : in std_logic;
                            variable front_panel_conf : inout t_front_panel_conf;
                            signal   internal_if      : inout t_internal_if
                           );

    -----------------------------------------------------------------------
    -- UpdateWireOuts
    -----------------------------------------------------------------------
    procedure UpdateWireOuts(
        signal   i_clk            : in std_logic;
        variable front_panel_conf : inout t_front_panel_conf;
        signal   internal_if      : inout t_internal_if
    );

    -----------------------------------------------------------------------
    -- ActivateTriggerIn
    -----------------------------------------------------------------------
    procedure ActivateTriggerIn(
        signal i_clk       : in std_logic;
        ep                 : in std_logic_vector(7 downto 0);
        bit                : in integer;
        signal internal_if : inout t_internal_if);

    -----------------------------------------------------------------------
    -- UpdateTriggerOuts
    -----------------------------------------------------------------------
    --procedure UpdateTriggerOuts(
    --    signal   i_clk            : in std_logic;
    --    variable front_panel_conf : inout t_front_panel_conf;
    --    signal   internal_if      : inout t_internal_if
    --);

    -----------------------------------------------------------------------
    -- WriteToPipeIn
    -----------------------------------------------------------------------
    --procedure WriteToPipeIn(
    --    signal   i_clk            : in std_logic;
    --    ep                        : in std_logic_vector(7 downto 0);
    --    length                    : in integer;
    --    variable front_panel_conf : inout t_front_panel_conf;
    --    signal   internal_if      : inout t_internal_if
    --);

    -----------------------------------------------------------------------
    -- ReadFromPipeOut
    -----------------------------------------------------------------------
    procedure ReadFromPipeOut(
        signal   i_clk            : in std_logic;
        ep                        : in std_logic_vector(7 downto 0);
        length                    : in integer;
        variable front_panel_conf : inout t_front_panel_conf;
        signal   internal_if      : inout t_internal_if
    );

    -----------------------------------------------------------------------
    -- WriteToBlockPipeIn
    -----------------------------------------------------------------------
    procedure WriteToBlockPipeIn(
        signal   i_clk            : in std_logic;
        ep                        : in std_logic_vector(7 downto 0);
        blockLength               : in integer;
        length                    : in integer;
        variable front_panel_conf : inout t_front_panel_conf;
        signal   internal_if      : inout t_internal_if);

    -----------------------------------------------------------------------
    -- ReadFromBlockPipeOut
    -----------------------------------------------------------------------
    procedure ReadFromBlockPipeOut(
        signal   i_clk            : in std_logic;
        ep                        : in std_logic_vector(7 downto 0);
        blockLength               : in integer;
        length                    : in integer;
        variable front_panel_conf : inout t_front_panel_conf;
        signal   internal_if      : inout t_internal_if);

    -----------------------------------------------------------------------
    -- WriteRegister
    -----------------------------------------------------------------------
    procedure WriteRegister(
        signal i_clk       : in std_logic;
        address            : in std_logic_vector(31 downto 0);
        data               : in std_logic_vector(31 downto 0);
        signal internal_if : inout t_internal_if);

    -----------------------------------------------------------------------
    -- ReadRegister
    -----------------------------------------------------------------------
    procedure ReadRegister(
        signal i_clk       : in std_logic;
        address            : in std_logic_vector(31 downto 0);
        data               : out std_logic_vector(31 downto 0);
        signal internal_if : inout t_internal_if
    );

    -----------------------------------------------------------------------
    -- WriteRegisterSet
    -----------------------------------------------------------------------
    procedure WriteRegisterSet(
        signal   i_clk            : in std_logic;
        variable front_panel_conf : inout t_front_panel_conf;
        signal   internal_if      : inout t_internal_if
    );

    -----------------------------------------------------------------------
    -- ReadRegisterSet
    -----------------------------------------------------------------------
    procedure ReadRegisterSet(
        signal   i_clk            : in std_logic;
        variable front_panel_conf : inout t_front_panel_conf;
        signal   internal_if      : inout t_internal_if);

end;

package body pkg_front_panel is

    ------------------------------------------------------
    -- this procedure allows to wait a number of rising edge
    -- then a margin is applied, if any
    ------------------------------------------------------
    procedure wait_nb_rising_edge_plus_margin(
        signal   i_clk            : in std_logic;
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

        -----------------------------------------------------------------------
    -- init_internal_if
    -----------------------------------------------------------------------
    impure function init_internal_if(
        dummy : in integer
    ) return t_internal_if is

        variable result : t_internal_if;
    begin
        result.hi_drive   := '0';
        result.hi_cmd     := (others => '0');
        result.hi_busy    := '0';
        result.hi_datain  := (others => '0');
        result.hi_dataout := (others => '0');

        return result;
    end function;


    procedure okHost_driver(
        signal i_clk       : in std_logic;
        signal okUH        : out STD_LOGIC_VECTOR (4  downto 0);
        signal okHU        : in STD_LOGIC_VECTOR (2  downto 0);
        signal okUHU       : inout STD_LOGIC_VECTOR (31 downto 0);
        signal internal_if : inout t_internal_if
    ) is

        alias hi_drive   : std_logic is internal_if.hi_drive;
        alias hi_cmd     : std_logic_vector(internal_if.hi_cmd'range) is internal_if.hi_cmd;
        alias hi_busy    : std_logic is internal_if.hi_busy;
        alias hi_datain  : std_logic_vector(internal_if.hi_datain'range) is internal_if.hi_datain;
        alias hi_dataout : std_logic_vector(internal_if.hi_dataout'range) is internal_if.hi_dataout;

    begin
        --while v_test = True loop
        -- okHostCalls Simulation okHostCall<->okHost Mapping  --------------------------------------
        okUH(0)          <= i_clk;
        okUH(1)          <= hi_drive;
        okUH(4 downto 2) <= hi_cmd;
        hi_datain        <= okUHU;
        hi_busy          <= okHU(0);
        okUHU            <= hi_dataout when (hi_drive = '1') else (others => 'Z');
        --end loop;
    end okHost_driver;

    -----------------------------------------------------------------------
    -- FrontPanelReset
    -----------------------------------------------------------------------
    procedure FrontPanelReset(signal i_clk : in std_logic; variable front_panel_conf : inout t_front_panel_conf; signal internal_if : inout t_internal_if) is
        variable i        : integer := 0;
        --variable msg_line : line;

        alias hi_cmd    : std_logic_vector(internal_if.hi_cmd'range) is internal_if.hi_cmd;
        alias hi_busy   : std_logic is internal_if.hi_busy;
        alias WireIns   : STD_ARRAY(front_panel_conf.WireIns'range) is front_panel_conf.WireIns;
        alias WireOuts  : STD_ARRAY(front_panel_conf.WireOuts'range) is front_panel_conf.WireOuts;
        alias Triggered : STD_ARRAY(front_panel_conf.Triggered'range) is front_panel_conf.Triggered;

    begin
        for i in 31 downto 0 loop
            WireIns(i)   := (others => '0');
            WireOuts(i)  := (others => '0');
            Triggered(i) := (others => '0');
        end loop;
        wait until (rising_edge(i_clk));
        wait for 12 ps;
        hi_cmd <= DReset;
        wait until (rising_edge(i_clk));
        wait for 12 ps;
        hi_cmd <= DNOP;
        wait on i_clk until (hi_busy = '0');
        wait for 12 ps;
    end procedure FrontPanelReset;



    -----------------------------------------------------------------------
    -- SetWireInValue
    -----------------------------------------------------------------------
    procedure SetWireInValue(
        ep                        : in std_logic_vector(7 downto 0);
        val                       : in std_logic_vector(31 downto 0);
        mask                      : in std_logic_vector(31 downto 0);
        variable front_panel_conf : inout t_front_panel_conf
    ) is

        variable tmp_slv32 : std_logic_vector(31 downto 0);
        variable tmpI      : integer;

        alias WireIns : STD_ARRAY(front_panel_conf.WireIns'range) is front_panel_conf.WireIns;

    begin
        tmpI                           := to_integer(unsigned(ep));
        tmp_slv32                      := WireIns(tmpI) and (not mask);
        WireIns(tmpI) := (tmp_slv32 or (val and mask));
    end procedure SetWireInValue;

    -----------------------------------------------------------------------
    -- UpdateWireIns
    -----------------------------------------------------------------------
    procedure UpdateWireIns(signal   i_clk            : in std_logic;
                            variable front_panel_conf : inout t_front_panel_conf;
                            signal   internal_if      : inout t_internal_if) is
        variable i : integer := 0;

        alias hi_drive   : std_logic is internal_if.hi_drive;
        alias hi_cmd     : std_logic_vector(internal_if.hi_cmd'range) is internal_if.hi_cmd;
        alias hi_busy    : std_logic is internal_if.hi_busy;
        alias hi_dataout : std_logic_vector(internal_if.hi_dataout'range) is internal_if.hi_dataout;
        alias WireIns    : STD_ARRAY(front_panel_conf.WireIns'range) is front_panel_conf.WireIns;

    begin
        wait until (rising_edge(i_clk));
        wait for 12 ps;
        hi_cmd   <= DWires;
        wait until (rising_edge(i_clk));
        wait for 12 ps;
        hi_cmd   <= DUpdateWireIns;
        wait until (rising_edge(i_clk));
        wait for 12 ps;
        hi_drive <= '1';
        wait until (rising_edge(i_clk));
        wait for 12 ps;
        hi_cmd   <= DNOP;
        for i in 0 to 31 loop
            hi_dataout <= WireIns(i);
            wait until (rising_edge(i_clk));
            wait for 12 ps;
        end loop;
        --wait on internal_if until (hi_busy = '0');
        --wait on i_clk until (hi_busy = '0');
        wait until (hi_busy = '0' and rising_edge(i_clk));
        wait for 12 ps;
    end procedure UpdateWireIns;

    -----------------------------------------------------------------------
    -- GetWireOutValue
    -----------------------------------------------------------------------
    impure function GetWireOutValue(
        ep               : std_logic_vector;
        front_panel_conf : in t_front_panel_conf)
    return std_logic_vector is

        variable tmp_slv32 : std_logic_vector(31 downto 0);
        variable tmpI      : integer;

        alias WireOuts : STD_ARRAY(front_panel_conf.WireOuts'range) is front_panel_conf.WireOuts;

    begin
        tmpI      := to_integer(unsigned(ep));
        tmp_slv32 := WireOuts(tmpI - 16#20#);
        return (tmp_slv32);
    end GetWireOutValue;

    -----------------------------------------------------------------------
    -- IsTriggered
    -----------------------------------------------------------------------
    impure function IsTriggered(
        ep               : std_logic_vector;
        mask             : std_logic_vector(31 downto 0);
        front_panel_conf : t_front_panel_conf
    ) return boolean is

        alias Triggered    : STD_ARRAY(front_panel_conf.Triggered'range) is front_panel_conf.Triggered;
        variable tmp_slv32 : std_logic_vector(Triggered(0)'range);
        variable tmpI      : integer;
        variable msg_line  : line;

    begin
        tmpI      := to_integer(unsigned(ep));
        tmp_slv32 := (Triggered(tmpI - 16#60#) and mask);

        if (tmp_slv32 >= std_logic_vector(to_unsigned(0, tmp_slv32'length))) then
            if (tmp_slv32 = std_logic_vector(to_unsigned(0, tmp_slv32'length))) then
                return FALSE;
            else
                return TRUE;
            end if;
        else
            write(msg_line, STRING'("***FRONTPANEL ERROR: IsTriggered mask 0x"));
            hwrite(msg_line, mask);
            write(msg_line, STRING'(" covers unused Triggers"));
            writeline(output, msg_line);
            return FALSE;
        end if;
    end IsTriggered;


    -----------------------------------------------------------------------
    -- UpdateWireOuts
    -----------------------------------------------------------------------
    procedure UpdateWireOuts(
        signal   i_clk            : in std_logic;
        variable front_panel_conf : inout t_front_panel_conf;
        signal   internal_if      : inout t_internal_if
    ) is
        variable i : integer := 0;

        alias hi_drive  : std_logic is internal_if.hi_drive;
        alias hi_cmd    : std_logic_vector(internal_if.hi_cmd'range) is internal_if.hi_cmd;
        alias hi_busy   : std_logic is internal_if.hi_busy;
        alias hi_datain : std_logic_vector(internal_if.hi_datain'range) is internal_if.hi_datain;
        alias WireOuts : STD_ARRAY(front_panel_conf.WireOuts'range) is front_panel_conf.WireOuts;

    begin
        wait until (rising_edge(i_clk));
        wait for 12 ps;
        hi_cmd   <= DWires;
        wait until (rising_edge(i_clk));
        wait for 12 ps;
        hi_cmd   <= DUpdateWireOuts;
        wait until (rising_edge(i_clk));
        wait for 12 ps;
        wait until (rising_edge(i_clk));
        wait for 12 ps;
        hi_cmd   <= DNOP;
        wait until (rising_edge(i_clk));
        wait for 12 ps;
        hi_drive <= '0';
        wait until (rising_edge(i_clk));
        wait for 12 ps;
        wait until (rising_edge(i_clk));
        wait for 12 ps;
        for i in 0 to 31 loop
            wait until (rising_edge(i_clk));
            wait for 12 ps;
            WireOuts(i) := hi_datain;
        end loop;
        wait until (hi_busy = '0');
    end procedure UpdateWireOuts;

    -----------------------------------------------------------------------
    -- ActivateTriggerIn
    -----------------------------------------------------------------------
    procedure ActivateTriggerIn(
        signal i_clk       : in std_logic;
        ep                 : in std_logic_vector(7 downto 0);
        bit                : in integer;
        signal internal_if : inout t_internal_if) is

        variable tmp_slv5 : std_logic_vector(4 downto 0);
        variable c_ONE    : unsigned(31 downto 0) := x"00000001";

        alias hi_drive   : std_logic is internal_if.hi_drive;
        alias hi_cmd     : std_logic_vector(internal_if.hi_cmd'range) is internal_if.hi_cmd;
        alias hi_busy    : std_logic is internal_if.hi_busy;
        alias hi_dataout : std_logic_vector(internal_if.hi_dataout'range) is internal_if.hi_dataout;

    begin
        tmp_slv5   := std_logic_vector(to_unsigned(bit, tmp_slv5'length));
        wait until (rising_edge(i_clk));
        wait for 12 ps;
        hi_cmd     <= DTriggers;
        wait until (rising_edge(i_clk));
        wait for 12 ps;
        hi_cmd     <= DActivateTriggerIn;
        wait until (rising_edge(i_clk));
        wait for 12 ps;
        hi_drive   <= '1';
        hi_dataout <= (x"000000" & ep);
        wait until (rising_edge(i_clk));
        wait for 12 ps;
        --hi_dataout <= SHL(x"00000001", tmp_slv5); 
        hi_dataout <= std_logic_vector(c_ONE sll to_integer(unsigned(tmp_slv5))); -- TODO
        hi_cmd     <= DNOP;
        wait until (rising_edge(i_clk));
        wait for 12 ps;
        hi_dataout <= x"00000000";
        wait until (hi_busy = '0');
    end procedure ActivateTriggerIn;

    -----------------------------------------------------------------------
    -- UpdateTriggerOuts
    -----------------------------------------------------------------------
    procedure UpdateTriggerOuts(
        signal   i_clk            : in std_logic;
        variable front_panel_conf : inout t_front_panel_conf;
        signal   internal_if      : inout t_internal_if
    ) is

        alias hi_drive  : std_logic is internal_if.hi_drive;
        alias hi_cmd    : std_logic_vector(internal_if.hi_cmd'range) is internal_if.hi_cmd;
        alias hi_busy   : std_logic is internal_if.hi_busy;
        alias hi_datain : std_logic_vector(internal_if.hi_datain'range) is internal_if.hi_datain;

        alias Triggered : STD_ARRAY(front_panel_conf.Triggered'range) is front_panel_conf.Triggered;
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
            Triggered(i) := hi_datain;
        end loop;
        wait until (hi_busy = '0');
    end procedure UpdateTriggerOuts;

    -----------------------------------------------------------------------
    -- WriteToPipeIn
    -----------------------------------------------------------------------
    procedure WriteToPipeIn(
        signal   i_clk            : in std_logic;
        ep                        : in std_logic_vector(7 downto 0);
        length                    : in integer;
        variable front_panel_conf : inout t_front_panel_conf;
        signal   internal_if      : inout t_internal_if) is

        variable len, i, j, k, blockSize : integer;
        variable tmp_slv8                : std_logic_vector(7 downto 0);
        variable tmp_slv32               : std_logic_vector(31 downto 0);

        alias hi_drive   : std_logic is internal_if.hi_drive;
        alias hi_cmd     : std_logic_vector(internal_if.hi_cmd'range) is internal_if.hi_cmd;
        alias hi_busy    : std_logic is internal_if.hi_busy;
        alias hi_dataout : std_logic_vector(internal_if.hi_dataout'range) is internal_if.hi_dataout;

        alias pipeIn           : PIPEIN_ARRAY(front_panel_conf.pipeIn'range) is front_panel_conf.pipeIn;

    begin
        len       := (length / 4);
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
        hi_dataout <= (x"0000" & tmp_slv8 & ep);
        wait until (rising_edge(i_clk));
        hi_cmd     <= DNOP;
        hi_dataout <= tmp_slv32;
        for i in 0 to len - 1 loop
            wait until (rising_edge(i_clk));
            hi_dataout(7 downto 0)   <= pipeIn(i * 4);
            hi_dataout(15 downto 8)  <= pipeIn((i * 4) + 1);
            hi_dataout(23 downto 16) <= pipeIn((i * 4) + 2);
            hi_dataout(31 downto 24) <= pipeIn((i * 4) + 3);
            j                        := j + 4;
            if (j = blockSize) then
                for k in 0 to BlockDelayStates - 1 loop
                    wait until (rising_edge(i_clk));
                end loop;
                j := 0;
            end if;
        end loop;
        wait until (hi_busy = '0');
    end procedure WriteToPipeIn;

    -----------------------------------------------------------------------
    -- ReadFromPipeOut
    -----------------------------------------------------------------------
    procedure ReadFromPipeOut(
        signal   i_clk            : in std_logic;
        ep                        : in std_logic_vector(7 downto 0);
        length                    : in integer;
        variable front_panel_conf : inout t_front_panel_conf;
        signal   internal_if      : inout t_internal_if
    ) is

        variable len, i, j, k, blockSize : integer;
        variable tmp_slv8                : std_logic_vector(7 downto 0);
        variable tmp_slv32               : std_logic_vector(31 downto 0);

        alias hi_drive   : std_logic is internal_if.hi_drive;
        alias hi_cmd     : std_logic_vector(internal_if.hi_cmd'range) is internal_if.hi_cmd;
        alias hi_busy    : std_logic is internal_if.hi_busy;
        alias hi_datain  : std_logic_vector(internal_if.hi_datain'range) is internal_if.hi_datain;
        alias hi_dataout : std_logic_vector(internal_if.hi_dataout'range) is internal_if.hi_dataout;

        alias pipeOut          : PIPEOUT_ARRAY(front_panel_conf.pipeOut'range) is front_panel_conf.pipeOut;

    begin
        len       := (length / 4);
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
        hi_dataout <= (x"0000" & tmp_slv8 & ep);
        wait until (rising_edge(i_clk));
        hi_cmd     <= DNOP;
        hi_dataout <= tmp_slv32;
        wait until (rising_edge(i_clk));
        hi_drive   <= '0';
        for i in 0 to len - 1 loop
            wait until (rising_edge(i_clk));
            pipeOut(i * 4)       := hi_datain(7 downto 0);
            pipeOut((i * 4) + 1) := hi_datain(15 downto 8);
            pipeOut((i * 4) + 2) := hi_datain(23 downto 16);
            pipeOut((i * 4) + 3) := hi_datain(31 downto 24);
            j                    := j + 4;
            if (j = blockSize) then
                for k in 0 to BlockDelayStates - 1 loop
                    wait until (rising_edge(i_clk));
                end loop;
                j := 0;
            end if;
        end loop;
        wait until (hi_busy = '0');
    end procedure ReadFromPipeOut;

    -----------------------------------------------------------------------
    -- WriteToBlockPipeIn
    -----------------------------------------------------------------------
    procedure WriteToBlockPipeIn(
        signal   i_clk            : in std_logic;
        ep                        : in std_logic_vector(7 downto 0);
        blockLength               : in integer;
        length                    : in integer;
        variable front_panel_conf : inout t_front_panel_conf;
        signal   internal_if      : inout t_internal_if) is

        variable len, i, j, k, blockSize, blockNum : integer;
        variable tmp_slv8                          : std_logic_vector(7 downto 0);
        variable tmp_slv16                         : std_logic_vector(15 downto 0);
        variable tmp_slv32                         : std_logic_vector(31 downto 0);

        alias hi_drive   : std_logic is internal_if.hi_drive;
        alias hi_cmd     : std_logic_vector(internal_if.hi_cmd'range) is internal_if.hi_cmd;
        alias hi_busy    : std_logic is internal_if.hi_busy;
        alias hi_dataout : std_logic_vector(internal_if.hi_dataout'range) is internal_if.hi_dataout;

        alias pipeIn           : PIPEIN_ARRAY(front_panel_conf.pipeIn'range) is front_panel_conf.pipeIn;

    begin
        len       := (length / 4);
        blockSize := (blockLength / 4);
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
        hi_dataout             <= (x"0000" & tmp_slv8 & ep);
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
            while (internal_if.hi_busy = '1') loop
                wait until (rising_edge(i_clk));
            end loop;
            while (internal_if.hi_busy = '0') loop
                wait until (rising_edge(i_clk));
            end loop;
            wait until (rising_edge(i_clk));
            wait until (rising_edge(i_clk));
            for j in 1 to blockSize loop
                hi_dataout(7 downto 0)   <= pipeIn(k);
                hi_dataout(15 downto 8)  <= pipeIn(k + 1);
                hi_dataout(23 downto 16) <= pipeIn(k + 2);
                hi_dataout(31 downto 24) <= pipeIn(k + 3);
                wait until (rising_edge(i_clk));
                k                        := k + 4;
            end loop;
            for j in 1 to BlockDelayStates loop
                wait until (rising_edge(i_clk));
            end loop;
        end loop;
        wait until (hi_busy = '0');
    end procedure WriteToBlockPipeIn;

    -----------------------------------------------------------------------
    -- ReadFromBlockPipeOut
    -----------------------------------------------------------------------
    procedure ReadFromBlockPipeOut(
        signal   i_clk            : in std_logic;
        ep                        : in std_logic_vector(7 downto 0);
        blockLength               : in integer;
        length                    : in integer;
        variable front_panel_conf : inout t_front_panel_conf;
        signal   internal_if      : inout t_internal_if) is

        variable len, i, j, k, blockSize, blockNum : integer;
        variable tmp_slv8                          : std_logic_vector(7 downto 0);
        variable tmp_slv16                         : std_logic_vector(15 downto 0);
        variable tmp_slv32                         : std_logic_vector(31 downto 0);

        alias hi_drive   : std_logic is internal_if.hi_drive;
        alias hi_cmd     : std_logic_vector(internal_if.hi_cmd'range) is internal_if.hi_cmd;
        alias hi_busy    : std_logic is internal_if.hi_busy;
        alias hi_datain  : std_logic_vector(internal_if.hi_datain'range) is internal_if.hi_datain;
        alias hi_dataout : std_logic_vector(internal_if.hi_dataout'range) is internal_if.hi_dataout;

        alias pipeOut          : PIPEOUT_ARRAY(front_panel_conf.pipeOut'range) is front_panel_conf.pipeOut;

    begin
        len       := (length / 4);
        blockSize := (blockLength / 4);
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
        hi_dataout             <= (x"0000" & tmp_slv8 & ep);
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
                pipeOut(k)     := hi_datain(7 downto 0);
                pipeOut(k + 1) := hi_datain(15 downto 8);
                pipeOut(k + 2) := hi_datain(23 downto 16);
                pipeOut(k + 3) := hi_datain(31 downto 24);
                wait until (rising_edge(i_clk));
                k              := k + 4;
            end loop;
            for j in 1 to BlockDelayStates loop
                wait until (rising_edge(i_clk));
            end loop;
        end loop;
        wait until (hi_busy = '0');
    end procedure ReadFromBlockPipeOut;

    -----------------------------------------------------------------------
    -- WriteRegister
    -----------------------------------------------------------------------
    procedure WriteRegister(
        signal i_clk       : in std_logic;
        address            : in std_logic_vector(31 downto 0);
        data               : in std_logic_vector(31 downto 0);
        signal internal_if : inout t_internal_if) is

        alias hi_drive   : std_logic is internal_if.hi_drive;
        alias hi_cmd     : std_logic_vector(internal_if.hi_cmd'range) is internal_if.hi_cmd;
        alias hi_busy    : std_logic is internal_if.hi_busy;
        alias hi_dataout : std_logic_vector(internal_if.hi_dataout'range) is internal_if.hi_dataout;

    begin
        wait until (rising_edge(i_clk));
        hi_cmd     <= DRegisters;
        wait until (rising_edge(i_clk));
        hi_cmd     <= DWriteRegister;
        wait until (rising_edge(i_clk));
        hi_drive   <= '1';
        hi_cmd     <= DNOP;
        wait until (rising_edge(i_clk));
        hi_dataout <= address;
        wait until (rising_edge(i_clk));
        hi_dataout <= data;
        wait until (hi_busy = '0');
        hi_drive   <= '0';
    end procedure WriteRegister;

    -----------------------------------------------------------------------
    -- ReadRegister
    -----------------------------------------------------------------------
    procedure ReadRegister(
        signal i_clk       : in std_logic;
        address            : in std_logic_vector(31 downto 0);
        data               : out std_logic_vector(31 downto 0);
        signal internal_if : inout t_internal_if) is

        alias hi_drive   : std_logic is internal_if.hi_drive;
        alias hi_cmd     : std_logic_vector(internal_if.hi_cmd'range) is internal_if.hi_cmd;
        alias hi_busy    : std_logic is internal_if.hi_busy;
        alias hi_datain  : std_logic_vector(internal_if.hi_datain'range) is internal_if.hi_datain;
        alias hi_dataout : std_logic_vector(internal_if.hi_dataout'range) is internal_if.hi_dataout;

    begin
        wait until (rising_edge(i_clk));
        hi_cmd     <= DRegisters;
        wait until (rising_edge(i_clk));
        hi_cmd     <= DReadRegister;
        wait until (rising_edge(i_clk));
        hi_drive   <= '1';
        hi_cmd     <= DNOP;
        wait until (rising_edge(i_clk));
        hi_dataout <= address;
        wait until (rising_edge(i_clk));
        hi_drive   <= '0';
        wait until (rising_edge(i_clk));
        wait until (rising_edge(i_clk));
        data       := hi_datain;
        wait until (hi_busy = '0');
    end procedure ReadRegister;

    -----------------------------------------------------------------------
    -- WriteRegisterSet
    -----------------------------------------------------------------------
    procedure WriteRegisterSet(
        signal   i_clk            : in std_logic;
        variable front_panel_conf : inout t_front_panel_conf;
        signal   internal_if      : inout t_internal_if) is
        variable i            : integer;
        variable u32Count_int : integer;

        alias hi_drive   : std_logic is internal_if.hi_drive;
        alias hi_cmd     : std_logic_vector(internal_if.hi_cmd'range) is internal_if.hi_cmd;
        alias hi_busy    : std_logic is internal_if.hi_busy;
        alias hi_dataout : std_logic_vector(internal_if.hi_dataout'range) is internal_if.hi_dataout;

        alias u32Count   : std_logic_vector(front_panel_conf.u32Count'range) is front_panel_conf.u32Count;
        alias u32Data    : REGISTER_ARRAY(front_panel_conf.u32Data'range) is front_panel_conf.u32Data;
        alias u32Address : REGISTER_ARRAY(front_panel_conf.u32Address'range) is front_panel_conf.u32Address;
    begin
        u32Count_int := to_integer(unsigned(u32Count));
        wait until (rising_edge(i_clk));
        hi_cmd       <= DRegisters;
        wait until (rising_edge(i_clk));
        hi_cmd       <= DWriteRegisterSet;
        wait until (rising_edge(i_clk));
        hi_drive     <= '1';
        hi_cmd       <= DNOP;
        wait until (rising_edge(i_clk));
        hi_dataout   <= u32Count;
        for i in 1 to u32Count_int loop
            wait until (rising_edge(i_clk));
            hi_dataout <= u32Address(i - 1);
            wait until (rising_edge(i_clk));
            hi_dataout <= u32Data(i - 1);
            wait until (rising_edge(i_clk));
            wait until (rising_edge(i_clk));
        end loop;
        wait until (hi_busy = '0');
        hi_drive     <= '0';
    end procedure WriteRegisterSet;

    -----------------------------------------------------------------------
    -- ReadRegisterSet
    -----------------------------------------------------------------------
    procedure ReadRegisterSet(
        signal   i_clk            : in std_logic;
        variable front_panel_conf : inout t_front_panel_conf;
        signal   internal_if      : inout t_internal_if
    ) is
        variable i            : integer;
        variable u32Count_int : integer;

        alias hi_drive   : std_logic is internal_if.hi_drive;
        alias hi_cmd     : std_logic_vector(internal_if.hi_cmd'range) is internal_if.hi_cmd;
        alias hi_busy    : std_logic is internal_if.hi_busy;
        alias hi_datain  : std_logic_vector(internal_if.hi_datain'range) is internal_if.hi_datain;
        alias hi_dataout : std_logic_vector(internal_if.hi_dataout'range) is internal_if.hi_dataout;

        alias u32Count   : std_logic_vector(front_panel_conf.u32Count'range) is front_panel_conf.u32Count;
        alias u32Data    : REGISTER_ARRAY(front_panel_conf.u32Data'range) is front_panel_conf.u32Data;
        alias u32Address : REGISTER_ARRAY(front_panel_conf.u32Address'range) is front_panel_conf.u32Address;
    begin
        u32Count_int := to_integer(unsigned(u32Count));
        wait until (rising_edge(i_clk));
        hi_cmd       <= DRegisters;
        wait until (rising_edge(i_clk));
        hi_cmd       <= DReadRegisterSet;
        wait until (rising_edge(i_clk));
        hi_drive     <= '1';
        hi_cmd       <= DNOP;
        wait until (rising_edge(i_clk));
        hi_dataout   <= u32Count;
        for i in 1 to u32Count_int loop
            wait until (rising_edge(i_clk));
            hi_dataout     <= u32Address(i - 1);
            wait until (rising_edge(i_clk));
            hi_drive       <= '0';
            wait until (rising_edge(i_clk));
            wait until (rising_edge(i_clk));
            u32Data(i - 1) := hi_datain;
            hi_drive       <= '1';
        end loop;
        wait until (hi_busy = '0');
    end procedure ReadRegisterSet;

end;
