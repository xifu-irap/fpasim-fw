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

    

    type t_internal_if is record
        hi_drive   : std_logic;
        hi_cmd     : std_logic_vector(2 downto 0);
        hi_busy    : std_logic;
        hi_datain  : std_logic_vector(31 downto 0);
        hi_dataout : std_logic_vector(31 downto 0);

    end record t_internal_if;

    type t_internal_wr_if is record
        hi_drive   : std_logic;
        hi_cmd     : std_logic_vector(2 downto 0);
        hi_dataout : std_logic_vector(31 downto 0);
    end record;


    type t_internal_rd_if is record
        i_clk      : std_logic;
        hi_busy    : std_logic;
        hi_datain  : std_logic_vector(31 downto 0);
    end record;


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


    type t_front_panel_conf is protected
        procedure set_WireIns(index: in integer; value: in std_logic_vector);
        procedure set_WireOuts(index: in integer; value: in std_logic_vector);
        procedure set_Triggered(index: in integer; value: in std_logic_vector);
        procedure set_pipeIn(index: in integer; value: in std_logic_vector);
        procedure set_pipeOut(index: in integer; value: in std_logic_vector);
        procedure set_u32Data(index: in integer; value: in std_logic_vector);
        impure function get_WireIns(index: in integer) return std_logic_vector;
        impure function get_WireOuts(index: in integer) return std_logic_vector;
        impure function get_Triggered(index: in integer) return std_logic_vector;
        impure function get_pipeIn(index: in integer) return std_logic_vector;
        impure function get_pipeOut(index: in integer) return std_logic_vector;
        impure function get_u32Count return std_logic_vector;
        impure function get_u32Address(index: in integer) return std_logic_vector;
        impure function get_u32Data(index: in integer) return std_logic_vector;

    end protected;



    impure function init_internal_if(dummy : in integer) return t_internal_if;

    procedure okHost_driver(
        signal i_clk       : in std_logic;
        signal okUH        : out STD_LOGIC_VECTOR (4  downto 0);
        signal okHU        : in STD_LOGIC_VECTOR (2  downto 0);
        signal okUHU       : inout STD_LOGIC_VECTOR (31 downto 0);
        signal internal_wr_if : in t_internal_wr_if;
        signal internal_rd_if : out t_internal_rd_if
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
    procedure FrontPanelReset(
        --signal i_clk : in std_logic;
        variable front_panel_conf : inout t_front_panel_conf;
        signal internal_wr_if : out t_internal_wr_if;
        signal internal_rd_if : in t_internal_rd_if
        );

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
    procedure GetWireOutValue(
        ep               : std_logic_vector;
        variable front_panel_conf : inout t_front_panel_conf;
        result: out std_logic_vector);



    -----------------------------------------------------------------------
    -- IsTriggered
    -----------------------------------------------------------------------
     procedure IsTriggered(
        ep               : std_logic_vector;
        mask             : std_logic_vector(31 downto 0);
        variable front_panel_conf : inout t_front_panel_conf;
        result : out boolean
    );
    -----------------------------------------------------------------------
    -- UpdateWireIns
    -----------------------------------------------------------------------
    procedure UpdateWireIns(
                            --signal   i_clk            : in std_logic;
                            variable front_panel_conf : inout t_front_panel_conf;
                            signal internal_wr_if : out t_internal_wr_if;
                            signal internal_rd_if : in t_internal_rd_if
                           );


    -----------------------------------------------------------------------
    -- UpdateWireOuts
    -----------------------------------------------------------------------
    procedure UpdateWireOuts(
        --signal   i_clk            : in std_logic;
        variable front_panel_conf : inout t_front_panel_conf;
        signal internal_wr_if : out t_internal_wr_if;
        signal internal_rd_if : in t_internal_rd_if
    );

    -----------------------------------------------------------------------
    -- ActivateTriggerIn
    -----------------------------------------------------------------------
    procedure ActivateTriggerIn(
        --signal i_clk       : in std_logic;
        ep                 : in std_logic_vector(7 downto 0);
        bit                : in integer;
        signal internal_wr_if : out t_internal_wr_if;
        signal internal_rd_if : in t_internal_rd_if
        );

    -----------------------------------------------------------------------
    -- UpdateTriggerOuts
    -----------------------------------------------------------------------
    procedure UpdateTriggerOuts(
        --signal   i_clk            : in std_logic;
        variable front_panel_conf : inout t_front_panel_conf;
        signal internal_wr_if : out t_internal_wr_if;
        signal internal_rd_if : in t_internal_rd_if
    );

    -----------------------------------------------------------------------
    -- WriteToPipeIn
    -----------------------------------------------------------------------
    procedure WriteToPipeIn(
        --signal   i_clk            : in std_logic;
        ep                        : in std_logic_vector(7 downto 0);
        length                    : in integer;
        variable front_panel_conf : inout t_front_panel_conf;
        signal internal_wr_if : out t_internal_wr_if;
        signal internal_rd_if : in t_internal_rd_if
    );

    -----------------------------------------------------------------------
    -- ReadFromPipeOut
    -----------------------------------------------------------------------
    procedure ReadFromPipeOut(
        --signal   i_clk            : in std_logic;
        ep                        : in std_logic_vector(7 downto 0);
        length                    : in integer;
        variable front_panel_conf : inout t_front_panel_conf;
        signal internal_wr_if : out t_internal_wr_if;
        signal internal_rd_if : in t_internal_rd_if
    );

    -----------------------------------------------------------------------
    -- WriteToBlockPipeIn
    -----------------------------------------------------------------------
    procedure WriteToBlockPipeIn(
        --signal   i_clk            : in std_logic;
        ep                        : in std_logic_vector(7 downto 0);
        blockLength               : in integer;
        length                    : in integer;
        variable front_panel_conf : inout t_front_panel_conf;
        signal internal_wr_if : out t_internal_wr_if;
        signal internal_rd_if : in t_internal_rd_if
        );

    -----------------------------------------------------------------------
    -- ReadFromBlockPipeOut
    -----------------------------------------------------------------------
    procedure ReadFromBlockPipeOut(
        --signal   i_clk            : in std_logic;
        ep                        : in std_logic_vector(7 downto 0);
        blockLength               : in integer;
        length                    : in integer;
        variable front_panel_conf : inout t_front_panel_conf;
        signal internal_wr_if : out t_internal_wr_if;
        signal internal_rd_if : in t_internal_rd_if
        );

    -----------------------------------------------------------------------
    -- WriteRegister
    -----------------------------------------------------------------------
    procedure WriteRegister(
        --signal i_clk       : in std_logic;
        address            : in std_logic_vector(31 downto 0);
        data               : in std_logic_vector(31 downto 0);
        signal internal_wr_if : out t_internal_wr_if;
        signal internal_rd_if : in t_internal_rd_if
        );

    -----------------------------------------------------------------------
    -- ReadRegister
    -----------------------------------------------------------------------
    procedure ReadRegister(
        --signal i_clk       : in std_logic;
        address            : in std_logic_vector(31 downto 0);
        data               : out std_logic_vector(31 downto 0);
        signal internal_wr_if : out t_internal_wr_if;
        signal internal_rd_if : in t_internal_rd_if
    );

    -----------------------------------------------------------------------
    -- WriteRegisterSet
    -----------------------------------------------------------------------
    procedure WriteRegisterSet(
        --signal   i_clk            : in std_logic;
        variable front_panel_conf : inout t_front_panel_conf;
        signal internal_wr_if : out t_internal_wr_if;
        signal internal_rd_if : in t_internal_rd_if
    );

    -----------------------------------------------------------------------
    -- ReadRegisterSet
    -----------------------------------------------------------------------
    procedure ReadRegisterSet(
        --signal   i_clk            : in std_logic;
        variable front_panel_conf : inout t_front_panel_conf;
        signal internal_wr_if : out t_internal_wr_if;
        signal internal_rd_if : in t_internal_rd_if
        );

    ------------------------------------------------------
    -- this procedure allows to wait a number of rising edge
    -- then a margin is applied, if any
    ------------------------------------------------------
    procedure wait_nb_rising_edge_plus_margin(
        signal   i_clk            : in std_logic;
        constant i_nb_rising_edge : in natural;
        constant i_margin         : in time
    );

end;

package body pkg_front_panel is

    type t_front_panel_conf is protected body
        variable pipeIn           : PIPEIN_ARRAY(0 to pipeInSize - 1);

        variable pipeOut          : PIPEOUT_ARRAY(0 to pipeOutSize - 1);

        variable WireIns          : STD_ARRAY(0 to 31);   -- 32x32 array storing WireIn values
        variable WireOuts         : STD_ARRAY(0 to 31);   -- 32x32 array storing WireOut values 
        variable Triggered        : STD_ARRAY(0 to 31);   -- 32x32 array storing IsTriggered values

        variable u32Address       : REGISTER_ARRAY(0 to registerSetSize - 1);
        variable u32Data          : REGISTER_ARRAY(0 to registerSetSize - 1);
        variable u32Count         : std_logic_vector(31 downto 0);
        --ReadRegisterData : std_logic_vector(31 downto 0);

        procedure set_WireIns(index: in integer; value: in std_logic_vector) is
        begin
            WireIns(index):= value;
        end;

        procedure set_WireOuts(index: in integer; value: in std_logic_vector) is
        begin
            WireOuts(index):= value;
        end;

        procedure set_Triggered(index: in integer; value: in std_logic_vector) is
        begin
            Triggered(index):= value;
        end;

        procedure set_pipeIn(index: in integer; value: in std_logic_vector) is
        begin
            pipeIn(index):= value;
        end;

        procedure set_pipeOut(index: in integer; value: in std_logic_vector) is
        begin
            pipeOut(index):= value;
        end;

        procedure set_u32Data(index: in integer; value: in std_logic_vector) is
        begin
            u32Data(index):= value;
        end;



        impure function get_WireIns(index: in integer) return std_logic_vector is
        begin
            return WireIns(index);
        end;

        impure function get_WireOuts(index: in integer) return std_logic_vector is
        begin
            return WireOuts(index);
        end;

        impure function get_Triggered(index: in integer) return std_logic_vector is
        begin
            return Triggered(index);
        end;

        impure function get_pipeIn(index: in integer) return std_logic_vector is
        begin
            return pipeIn(index);
        end;

         impure function get_pipeOut(index: in integer) return std_logic_vector is
        begin
            return pipeOut(index);
        end;

        impure function get_u32Count return std_logic_vector is
        begin
            return u32Count;
        end;

         impure function get_u32Address(index: in integer) return std_logic_vector is
        begin
            return u32Address(index);
        end;
        impure function get_u32Data(index: in integer) return std_logic_vector is
        begin
            return u32Data(index);
        end;


    end protected body;


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

    ---------------------------------------------------------------------
    -- okHost_driver
    ---------------------------------------------------------------------
    procedure okHost_driver(
        signal i_clk       : in std_logic;
        signal okUH        : out STD_LOGIC_VECTOR (4  downto 0);
        signal okHU        : in STD_LOGIC_VECTOR (2  downto 0);
        signal okUHU       : inout STD_LOGIC_VECTOR (31 downto 0);
        signal internal_wr_if : in t_internal_wr_if;
        signal internal_rd_if : out t_internal_rd_if
    ) is

        alias hi_drive   : std_logic is internal_wr_if.hi_drive;
        alias hi_cmd     : std_logic_vector(internal_wr_if.hi_cmd'range) is internal_wr_if.hi_cmd;
        alias hi_dataout : std_logic_vector(internal_wr_if.hi_dataout'range) is internal_wr_if.hi_dataout;

        alias hi_busy    : std_logic is internal_rd_if.hi_busy;
        alias hi_datain  : std_logic_vector(internal_rd_if.hi_datain'range) is internal_rd_if.hi_datain;

    begin
        -- get clocks for the procedure/function
        internal_rd_if.i_clk <= i_clk;
        -- okHostCalls Simulation okHostCall<->okHost Mapping  --------------------------------------
        ---------------------------------------------------------------------
        -- drive usb ports
        ---------------------------------------------------------------------
        okUH(0)          <= i_clk;
        okUH(1)          <= hi_drive;
        okUH(4 downto 2) <= hi_cmd;
        hi_datain        <= okUHU;
        hi_busy          <= okHU(0);
        okUHU            <= hi_dataout when (hi_drive = '1') else (others => 'Z');
    end okHost_driver;

    -----------------------------------------------------------------------
    -- FrontPanelReset
    -----------------------------------------------------------------------
    procedure FrontPanelReset(
        --signal i_clk : in std_logic; 
        variable front_panel_conf : inout t_front_panel_conf;
        signal internal_wr_if : out t_internal_wr_if;
        signal internal_rd_if : in t_internal_rd_if
        ) is
        variable i        : integer := 0;
        alias hi_cmd    : std_logic_vector(internal_wr_if.hi_cmd'range) is internal_wr_if.hi_cmd;

        alias i_clk    : std_logic is internal_rd_if.i_clk;
        alias hi_busy   : std_logic is internal_rd_if.hi_busy;

        constant c_ZEROS: std_logic_vector(31 downto 0):= (others => '0');

    begin
        for i in 31 downto 0 loop
            front_panel_conf.set_WireIns(index=> i,value=> c_ZEROS);
            front_panel_conf.set_WireOuts(index=> i,value=> c_ZEROS);
            front_panel_conf.set_Triggered(index=> i,value=> c_ZEROS);
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
        ep                        : in std_logic_vector(7 downto 0);
        val                       : in std_logic_vector(31 downto 0);
        mask                      : in std_logic_vector(31 downto 0);
        variable front_panel_conf : inout t_front_panel_conf
    ) is

        variable tmp_slv32 : std_logic_vector(31 downto 0);
        variable tmpI      : integer;

    begin
        tmpI          := to_integer(unsigned(ep));
        tmp_slv32     := front_panel_conf.get_WireIns(tmpI) and (not mask);
        front_panel_conf.set_WireIns(index=> tmpI, value=> (tmp_slv32 or (val and mask)));
    end procedure SetWireInValue;


    -----------------------------------------------------------------------
    -- UpdateWireIns
    -----------------------------------------------------------------------
    procedure UpdateWireIns(
                            --signal   i_clk            : in std_logic;
                            variable front_panel_conf : inout t_front_panel_conf;
                            signal internal_wr_if : out t_internal_wr_if;
                            signal internal_rd_if : in t_internal_rd_if
        ) is
        variable i : integer := 0;
        alias hi_drive   : std_logic is internal_wr_if.hi_drive;
        alias hi_cmd     : std_logic_vector(internal_wr_if.hi_cmd'range) is internal_wr_if.hi_cmd;
        alias hi_dataout : std_logic_vector(internal_wr_if.hi_dataout'range) is internal_wr_if.hi_dataout;

        alias i_clk    : std_logic is internal_rd_if.i_clk;
        alias hi_busy    : std_logic is internal_rd_if.hi_busy;


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
            hi_dataout <= front_panel_conf.get_WireIns(i);
            wait until (rising_edge(i_clk));
        end loop;
        wait on i_clk until (hi_busy = '0');
    end procedure UpdateWireIns;

    -----------------------------------------------------------------------
    -- GetWireOutValue
    -----------------------------------------------------------------------
    procedure GetWireOutValue(
        ep               : std_logic_vector;
        front_panel_conf : inout t_front_panel_conf;
        result: out std_logic_vector
        )
         is

        variable tmp_slv32 : std_logic_vector(31 downto 0);
        variable tmpI      : integer;

    begin
        tmpI      := to_integer(unsigned(ep));
        tmp_slv32 := front_panel_conf.get_WireOuts(tmpI - 16#20#);
        result    := tmp_slv32;
    end GetWireOutValue;

    -----------------------------------------------------------------------
    -- IsTriggered
    ---------------------------------------------------------------------
    procedure IsTriggered(
        ep               : std_logic_vector;
        mask             : std_logic_vector(31 downto 0);
        variable front_panel_conf : inout t_front_panel_conf;
        result : out boolean
    ) is

        variable tmp_slv32 : std_logic_vector(mask'range);
        variable tmpI      : integer;
        variable msg_line  : line;

    begin
        tmpI      := to_integer(unsigned(ep));
        tmp_slv32 := (front_panel_conf.get_Triggered(tmpI - 16#60#) and mask);

        if (tmp_slv32 >= std_logic_vector(to_unsigned(0, tmp_slv32'length))) then
            if (tmp_slv32 = std_logic_vector(to_unsigned(0, tmp_slv32'length))) then
                result:=  FALSE;
            else
                result:=  TRUE;
            end if;
        else
            write(msg_line, STRING'("***FRONTPANEL ERROR: IsTriggered mask 0x"));
            hwrite(msg_line, mask);
            write(msg_line, STRING'(" covers unused Triggers"));
            writeline(output, msg_line);
            result:=  FALSE;
        end if;
    end IsTriggered;

    -----------------------------------------------------------------------
    -- UpdateWireOuts
    -----------------------------------------------------------------------
    procedure UpdateWireOuts(
        --signal   i_clk            : in std_logic;
        variable front_panel_conf : inout t_front_panel_conf;
        signal internal_wr_if : out t_internal_wr_if;
        signal internal_rd_if : in t_internal_rd_if
    ) is
        variable i : integer := 0;

        alias hi_drive  : std_logic is internal_wr_if.hi_drive;
        alias hi_cmd    : std_logic_vector(internal_wr_if.hi_cmd'range) is internal_wr_if.hi_cmd;

        alias i_clk    : std_logic is internal_rd_if.i_clk;
        alias hi_busy   : std_logic is internal_rd_if.hi_busy;
        alias hi_datain : std_logic_vector(internal_rd_if.hi_datain'range) is internal_rd_if.hi_datain;

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
            front_panel_conf.set_WireOuts(index=> i,value=> hi_datain);
        end loop;
        wait on i_clk until (hi_busy = '0');
    end procedure UpdateWireOuts;

    -----------------------------------------------------------------------
    -- ActivateTriggerIn
    -----------------------------------------------------------------------
    procedure ActivateTriggerIn(
        --signal i_clk       : in std_logic;
        ep                 : in std_logic_vector(7 downto 0);
        bit                : in integer;
        signal internal_wr_if : out t_internal_wr_if;
        signal internal_rd_if : in t_internal_rd_if
        ) is

        variable c_ONE    : unsigned(31 downto 0) := x"00000001";

        alias hi_drive   : std_logic is internal_wr_if.hi_drive;
        alias hi_cmd     : std_logic_vector(internal_wr_if.hi_cmd'range) is internal_wr_if.hi_cmd;
        alias hi_dataout : std_logic_vector(internal_wr_if.hi_dataout'range) is internal_wr_if.hi_dataout;

        alias i_clk    : std_logic is internal_rd_if.i_clk;
        alias hi_busy    : std_logic is internal_rd_if.hi_busy;

    begin
        wait until (rising_edge(i_clk));
        hi_cmd     <= DTriggers;
        wait until (rising_edge(i_clk));
        hi_cmd     <= DActivateTriggerIn;
        wait until (rising_edge(i_clk));
        hi_drive   <= '1';
        hi_dataout <= (x"000000" & ep);
        wait until (rising_edge(i_clk));
        hi_dataout <= std_logic_vector(c_ONE sll bit);
        hi_cmd     <= DNOP;
        wait until (rising_edge(i_clk));
        hi_dataout <= x"00000000";
        wait on i_clk until (hi_busy = '0');
    end procedure ActivateTriggerIn;

    -----------------------------------------------------------------------
    -- UpdateTriggerOuts
    -----------------------------------------------------------------------
    procedure UpdateTriggerOuts(
        --signal   i_clk            : in std_logic;
        variable front_panel_conf : inout t_front_panel_conf;
        signal internal_wr_if : out t_internal_wr_if;
        signal internal_rd_if : in t_internal_rd_if
    ) is

        alias hi_drive  : std_logic is internal_wr_if.hi_drive;
        alias hi_cmd    : std_logic_vector(internal_wr_if.hi_cmd'range) is internal_wr_if.hi_cmd;

        alias i_clk    : std_logic is internal_rd_if.i_clk;
        alias hi_busy   : std_logic is internal_rd_if.hi_busy;
        alias hi_datain : std_logic_vector(internal_rd_if.hi_datain'range) is internal_rd_if.hi_datain;

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
            front_panel_conf.set_Triggered(index=> i,value=> hi_datain);
        end loop;
        wait on i_clk until (hi_busy = '0');
    end procedure UpdateTriggerOuts;

    -----------------------------------------------------------------------
    -- WriteToPipeIn
    -----------------------------------------------------------------------
    procedure WriteToPipeIn(
        --signal   i_clk            : in std_logic;
        ep                        : in std_logic_vector(7 downto 0);
        length                    : in integer;
        variable front_panel_conf : inout t_front_panel_conf;
        signal internal_wr_if : out t_internal_wr_if;
        signal internal_rd_if : in t_internal_rd_if
        ) is

        variable len, i, j, k, blockSize : integer;
        variable tmp_slv8                : std_logic_vector(7 downto 0);
        variable tmp_slv32               : std_logic_vector(31 downto 0);

        alias hi_drive   : std_logic is internal_wr_if.hi_drive;
        alias hi_cmd     : std_logic_vector(internal_wr_if.hi_cmd'range) is internal_wr_if.hi_cmd;
        alias hi_dataout : std_logic_vector(internal_wr_if.hi_dataout'range) is internal_wr_if.hi_dataout;

        alias i_clk    : std_logic is internal_rd_if.i_clk;
        alias hi_busy    : std_logic is internal_rd_if.hi_busy;

        --alias pipeIn           : PIPEIN_ARRAY(front_panel_conf.pipeIn'range) is front_panel_conf.pipeIn;

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
            hi_dataout(7 downto 0)   <= front_panel_conf.get_pipeIn(i * 4);
            hi_dataout(15 downto 8)  <= front_panel_conf.get_pipeIn((i * 4) + 1);
            hi_dataout(23 downto 16) <= front_panel_conf.get_pipeIn((i * 4) + 2);
            hi_dataout(31 downto 24) <= front_panel_conf.get_pipeIn((i * 4) + 3);
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
        --signal   i_clk            : in std_logic;
        ep                        : in std_logic_vector(7 downto 0);
        length                    : in integer;
        variable front_panel_conf : inout t_front_panel_conf;
        signal internal_wr_if : out t_internal_wr_if;
        signal internal_rd_if : in t_internal_rd_if
    ) is

        variable len, i, j, k, blockSize : integer;
        variable tmp_slv8                : std_logic_vector(7 downto 0);
        variable tmp_slv32               : std_logic_vector(31 downto 0);

        alias hi_drive   : std_logic is internal_wr_if.hi_drive;
        alias hi_cmd     : std_logic_vector(internal_wr_if.hi_cmd'range) is internal_wr_if.hi_cmd;
        alias hi_dataout : std_logic_vector(internal_wr_if.hi_dataout'range) is internal_wr_if.hi_dataout;

        alias i_clk    : std_logic is internal_rd_if.i_clk;
        alias hi_busy    : std_logic is internal_rd_if.hi_busy;
        alias hi_datain  : std_logic_vector(internal_rd_if.hi_datain'range) is internal_rd_if.hi_datain;


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
            front_panel_conf.set_pipeOut(index=> (i * 4)    , value=>  hi_datain(7 downto 0));
            front_panel_conf.set_pipeOut(index=> (i * 4) + 1, value=>  hi_datain(15 downto 8));
            front_panel_conf.set_pipeOut(index=> (i * 4) + 2, value=>  hi_datain(23 downto 16));
            front_panel_conf.set_pipeOut(index=> (i * 4) + 3, value=>  hi_datain(31 downto 24));
            j                    := j + 4;
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
        --signal   i_clk            : in std_logic;
        ep                        : in std_logic_vector(7 downto 0);
        blockLength               : in integer;
        length                    : in integer;
        variable front_panel_conf : inout t_front_panel_conf;
        signal internal_wr_if : out t_internal_wr_if;
        signal internal_rd_if : in t_internal_rd_if
        ) is

        variable len, i, j, k, blockSize, blockNum : integer;
        variable tmp_slv8                          : std_logic_vector(7 downto 0);
        variable tmp_slv16                         : std_logic_vector(15 downto 0);
        variable tmp_slv32                         : std_logic_vector(31 downto 0);

        alias hi_drive   : std_logic is internal_wr_if.hi_drive;
        alias hi_cmd     : std_logic_vector(internal_wr_if.hi_cmd'range) is internal_wr_if.hi_cmd;
        alias hi_dataout : std_logic_vector(internal_wr_if.hi_dataout'range) is internal_wr_if.hi_dataout;

        alias i_clk    : std_logic is internal_rd_if.i_clk;
        alias hi_busy    : std_logic is internal_rd_if.hi_busy;

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
            while (hi_busy = '1') loop
                wait until (rising_edge(i_clk));
            end loop;
            while (hi_busy = '0') loop
                wait until (rising_edge(i_clk));
            end loop;
            wait until (rising_edge(i_clk));
            wait until (rising_edge(i_clk));
            for j in 1 to blockSize loop
                hi_dataout(7 downto 0)   <= front_panel_conf.get_pipeIn(k);
                hi_dataout(15 downto 8)  <= front_panel_conf.get_pipeIn(k + 1);
                hi_dataout(23 downto 16) <= front_panel_conf.get_pipeIn(k + 2);
                hi_dataout(31 downto 24) <= front_panel_conf.get_pipeIn(k + 3);
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
        --signal   i_clk            : in std_logic;
        ep                        : in std_logic_vector(7 downto 0);
        blockLength               : in integer;
        length                    : in integer;
        variable front_panel_conf : inout t_front_panel_conf;
        signal internal_wr_if : out t_internal_wr_if;
        signal internal_rd_if : in t_internal_rd_if
        ) is

        variable len, i, j, k, blockSize, blockNum : integer;
        variable tmp_slv8                          : std_logic_vector(7 downto 0);
        variable tmp_slv16                         : std_logic_vector(15 downto 0);
        variable tmp_slv32                         : std_logic_vector(31 downto 0);

        alias hi_drive   : std_logic is internal_wr_if.hi_drive;
        alias hi_cmd     : std_logic_vector(internal_wr_if.hi_cmd'range) is internal_wr_if.hi_cmd;
        alias hi_dataout : std_logic_vector(internal_wr_if.hi_dataout'range) is internal_wr_if.hi_dataout;

        alias i_clk    : std_logic is internal_rd_if.i_clk;
        alias hi_busy    : std_logic is internal_rd_if.hi_busy;
        alias hi_datain  : std_logic_vector(internal_rd_if.hi_datain'range) is internal_rd_if.hi_datain;

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
                front_panel_conf.set_pipeOut(index=> k    ,value=> hi_datain(7 downto 0));
                front_panel_conf.set_pipeOut(index=> k + 1,value=> hi_datain(15 downto 8));
                front_panel_conf.set_pipeOut(index=> k + 2,value=> hi_datain(23 downto 16));
                front_panel_conf.set_pipeOut(index=> k + 3,value=> hi_datain(31 downto 24));
                wait until (rising_edge(i_clk));
                k              := k + 4;
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
        --signal i_clk       : in std_logic;
        address            : in std_logic_vector(31 downto 0);
        data               : in std_logic_vector(31 downto 0);
        signal internal_wr_if : out t_internal_wr_if;
        signal internal_rd_if : in t_internal_rd_if
        ) is

        alias hi_drive   : std_logic is internal_wr_if.hi_drive;
        alias hi_cmd     : std_logic_vector(internal_wr_if.hi_cmd'range) is internal_wr_if.hi_cmd;
        alias hi_dataout : std_logic_vector(internal_wr_if.hi_dataout'range) is internal_wr_if.hi_dataout;

        alias i_clk    : std_logic is internal_rd_if.i_clk;
        alias hi_busy    : std_logic is internal_rd_if.hi_busy;

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
        wait on i_clk until (hi_busy = '0');
        hi_drive   <= '0';
    end procedure WriteRegister;

    -----------------------------------------------------------------------
    -- ReadRegister
    -----------------------------------------------------------------------
    procedure ReadRegister(
        --signal i_clk       : in std_logic;
        address            : in std_logic_vector(31 downto 0);
        data               : out std_logic_vector(31 downto 0);
        signal internal_wr_if : out t_internal_wr_if;
        signal internal_rd_if : in t_internal_rd_if
        ) is

        alias hi_drive   : std_logic is internal_wr_if.hi_drive;
        alias hi_cmd     : std_logic_vector(internal_wr_if.hi_cmd'range) is internal_wr_if.hi_cmd;
        alias hi_dataout : std_logic_vector(internal_wr_if.hi_dataout'range) is internal_wr_if.hi_dataout;

        alias i_clk    : std_logic is internal_rd_if.i_clk;
        alias hi_datain  : std_logic_vector(internal_rd_if.hi_datain'range) is internal_rd_if.hi_datain;
        alias hi_busy    : std_logic is internal_rd_if.hi_busy;

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
        wait on i_clk until (hi_busy = '0');
    end procedure ReadRegister;

    -----------------------------------------------------------------------
    -- WriteRegisterSet
    -----------------------------------------------------------------------
    procedure WriteRegisterSet(
        --signal   i_clk            : in std_logic;
        variable front_panel_conf : inout t_front_panel_conf;
        signal internal_wr_if : out t_internal_wr_if;
        signal internal_rd_if : in t_internal_rd_if
       ) is

        variable i            : integer;
        variable u32Count_int : integer;

        alias hi_drive   : std_logic is internal_wr_if.hi_drive;
        alias hi_cmd     : std_logic_vector(internal_wr_if.hi_cmd'range) is internal_wr_if.hi_cmd;
        alias hi_dataout : std_logic_vector(internal_wr_if.hi_dataout'range) is internal_wr_if.hi_dataout;

        alias i_clk    : std_logic is internal_rd_if.i_clk;
        alias hi_busy    : std_logic is internal_rd_if.hi_busy;

    begin
        u32Count_int := to_integer(unsigned(front_panel_conf.get_u32Count));
        wait until (rising_edge(i_clk));
        hi_cmd       <= DRegisters;
        wait until (rising_edge(i_clk));
        hi_cmd       <= DWriteRegisterSet;
        wait until (rising_edge(i_clk));
        hi_drive     <= '1';
        hi_cmd       <= DNOP;
        wait until (rising_edge(i_clk));
        hi_dataout   <= front_panel_conf.get_u32Count;
        for i in 1 to u32Count_int loop
            wait until (rising_edge(i_clk));
            hi_dataout <= front_panel_conf.get_u32Address(i - 1);
            wait until (rising_edge(i_clk));
            hi_dataout <= front_panel_conf.get_u32Data(i - 1);
            wait until (rising_edge(i_clk));
            wait until (rising_edge(i_clk));
        end loop;
        wait on i_clk until (hi_busy = '0');
        hi_drive     <= '0';
    end procedure WriteRegisterSet;

    -----------------------------------------------------------------------
    -- ReadRegisterSet
    -----------------------------------------------------------------------
    procedure ReadRegisterSet(
        --signal   i_clk            : in std_logic;
        variable front_panel_conf : inout t_front_panel_conf;
        signal internal_wr_if : out t_internal_wr_if;
        signal internal_rd_if : in t_internal_rd_if
    ) is
        variable i            : integer;
        variable u32Count_int : integer;

        alias hi_drive   : std_logic is internal_wr_if.hi_drive;
        alias hi_cmd     : std_logic_vector(internal_wr_if.hi_cmd'range) is internal_wr_if.hi_cmd;
        alias hi_dataout : std_logic_vector(internal_wr_if.hi_dataout'range) is internal_wr_if.hi_dataout;

        alias i_clk    : std_logic is internal_rd_if.i_clk;
        alias hi_busy    : std_logic is internal_rd_if.hi_busy;
        alias hi_datain  : std_logic_vector(internal_rd_if.hi_datain'range) is internal_rd_if.hi_datain;

    begin
        u32Count_int := to_integer(unsigned(front_panel_conf.get_u32Count));
        wait until (rising_edge(i_clk));
        hi_cmd       <= DRegisters;
        wait until (rising_edge(i_clk));
        hi_cmd       <= DReadRegisterSet;
        wait until (rising_edge(i_clk));
        hi_drive     <= '1';
        hi_cmd       <= DNOP;
        wait until (rising_edge(i_clk));
        hi_dataout   <= front_panel_conf.get_u32Count;
        for i in 1 to u32Count_int loop
            wait until (rising_edge(i_clk));
            hi_dataout     <= front_panel_conf.get_u32Address(i - 1);
            wait until (rising_edge(i_clk));
            hi_drive       <= '0';
            wait until (rising_edge(i_clk));
            wait until (rising_edge(i_clk));
            front_panel_conf.set_u32Data(index=> i - 1, value=> hi_datain);
            hi_drive       <= '1';
        end loop;
        wait on i_clk until (hi_busy = '0');
    end procedure ReadRegisterSet;

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
end;
