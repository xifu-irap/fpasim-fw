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
--    @file                   pkg_csv_file.vhd 
-- -------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- -------------------------------------------------------------------------------------------------------------
--    @details                
--    This package uses the same principle as https://github.com/ricardo-jasinski/vhdl-csv-file-reader/blob/master/hdl/package/csv_file_reader_pkg.vhd
--    But, new functionnalities was added
--
-- How to use this package:
--    1. Create a csv_file_reader object:               
--         variable v_csv: t_csv_file_reader;
--    2. Open a csv file and define the csv separator:  
--         v_csv.initialize("c:\file.csv",';');
--    3. Read one line at a time:                       
--         csv.readline();
--    4. Read the first column (integer value)          
--         v_my_integer := csv.read_integer();
--    5. To read more values in the same line, call any of the read_* functions
--    6. To move to the next line, call csv.readline() again
--
-- Note: this package should be compiled in the csv_lib
-- -------------------------------------------------------------------------------------------------------------

library ieee;
library std;

use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use ieee.math_real.all;


package pkg_csv_file is
    type t_void is (VOID);

    type t_csv_file_reader is protected
        -- Open the CSV text file to be used for subsequent read operations
        -- FILE_OPEN_KIND values: READ_MODE, WRITE_MODE, APPEND_MODE
        procedure initialize(file_pathname: in string; csv_separator: in character := ';'; Open_Kind: in FILE_OPEN_KIND:=READ_MODE);
        -- Release (close) the associated CSV file
        procedure dispose(dummy:in t_void:= VOID);
        -- Read one line from the csv file, and keep it in the cache
        procedure readline(dummy:in t_void:= VOID);
        -- Read a string from the csv file and convert it to an integer
        impure function read_integer(dummy:in t_void:= VOID) return integer;
        -- Read a string from the csv file and convert it to real
        impure function read_real(dummy:in t_void:= VOID) return real;
        -- Read a string from the csv file and convert it to boolean
        impure function read_boolean(dummy:in t_void:= VOID) return boolean;
        -- Read a string with a numeric value from the csv file and convert it to a boolean
        impure function read_integer_as_boolean(dummy:in t_void:= VOID) return boolean;
        -- Read a string from the csv file, until a separator character ';' is found
        impure function read_string(dummy:in t_void:= VOID) return string;
        -- Read a string from the csv file of the column specified by column_index, until a separator character ';' is found
        impure function read_string_by_index(column_index:in integer) return string;
        -- True when the end of the CSV file was reached
        impure function end_of_file(dummy:in t_void:= VOID) return boolean;
         -- Read a string (ex: 0 or 1) from the csv file and convert it to std_logic
        impure function read_integer_as_std(dummy:in t_void:= VOID) return std_logic;
         -- Read a string (ex: 11010) from the csv file and convert it to std_logic_vector
        impure function read_integer_as_std_vec(length:in integer;unsigned_value : boolean := true) return std_logic_vector;
        -- Read a string (ex: ABC) from the csv file and convert it to std_logic_vector
        impure function read_hex_as_std_vec(length:in integer) return std_logic_vector;
        -- read a common typ as std_logic_vector
        --  common typ = "UINT" => the file integer value is converted into an unsigned vector -> std_logic_vector
        --  common typ = "INT" => the file integer value  is converted into a signed vector -> std_logic_vector
        --  common typ = "HEX" => the hexadecimal value is converted into a std_logic_vector
        --  common typ = "STD_VEC" (binary value) => the std_logic_vector is not converted
        impure function read_common_typ_as_std_vec(length:in integer; common_typ:in string:= "UINT") return std_logic_vector;
        -- Read a string (ex: 10010) from the csv file and convert it to std_logic_vector
        impure function read_std_vec(length:in integer) return std_logic_vector;
        -- Read a string (ex: 1 or 0) from the csv file and convert it to std_logic
        impure function read_std(dummy:in t_void:= VOID) return std_logic;
        -- write a std_logic_vector to a csv file
        procedure write_std_vec(value:in std_logic_vector; csv_separator: in character := ';'; constant use_csv_separator: in integer := 1);
        -- write a std_logic into line
        procedure write_std(value:in std_logic; csv_separator: in character := ';'; constant use_csv_separator: in integer := 1);
        -- write a string into line
        procedure write_string(value:in string; csv_separator: in character := ';'; constant use_csv_separator: in integer := 1);
         -- write a integer into line
        procedure write_integer(value:in integer; csv_separator: in character := ';'; constant use_csv_separator: in integer := 1);
         -- write a real into line
        procedure write_real(value:in real; csv_separator: in character := ';'; constant use_csv_separator: in integer := 1);
        -- write a time into line
        procedure write_time(value:in time; csv_separator: in character := ';'; constant use_csv_separator: in integer := 1);
         -- write a boolean into line
        procedure write_boolean(value:in boolean; csv_separator: in character := ';'; constant use_csv_separator: in integer := 1);
        -- write a character into line
        procedure write_char(value:in character);
        -- write a std_logic_vector as hexadecimal string into line
        procedure write_std_vec_as_hex(value:in std_logic_vector; csv_separator: in character := ';'; constant use_csv_separator: in integer := 1; constant unsigned_value : boolean := true);
        -- write a std_logic_vector as common type
        --  common typ = "UINT" => the std_logic_vector value is converted into unsigned int representation
        --  common typ = "INT" => the std_logic_vector value is converted into signed int representation
        --  common typ = "HEX" => the std_logic_vector value is considered as a signed vector, then it's converted into hex representation
        --  common typ = "UHEX" => the std_logic_vector value is considered as a unsigned vector, then it's converted into hex representation
        --  common typ = "STD_VEC" => the std_logic_vector value is not converted
        procedure write_std_vec_as_common_typ(value:in std_logic_vector;csv_separator:in character:= ';';common_typ:in string:= "UINT"; constant use_csv_separator: in integer := 1);
        -- write a std_logic_vector in different ways
        procedure writeline(dummy:in t_void:= VOID);

    end protected;
end;

package body pkg_csv_file is

    type t_csv_file_reader is protected body
        file my_csv_file: text;
        -- cache one line at a time for read operations
        variable v_current_line: line;
        -- true when end of file was reached and there are no more lines to read
        variable v_end_of_file_reached: boolean;

        variable v_csv_sep : character;
        
        -- Maximum string length for read operations
        constant c_LINE_LENGTH_MAX: integer := 256;

        -- True when the end of the CSV file was reached
        impure function end_of_file(dummy:in t_void:= VOID) return boolean is begin
            return v_end_of_file_reached;
        end;
        
        -- Open the CSV text file to be used for subsequent read operations
        procedure initialize(file_pathname: in string; csv_separator: in character := ';'; Open_Kind: in FILE_OPEN_KIND:=READ_MODE ) is begin
            -- FILE_OPEN_KIND values: READ_MODE, WRITE_MODE, APPEND_MODE
            --file_open(my_csv_file, file_pathname, READ_MODE);
            file_open(my_csv_file, file_pathname, Open_Kind);
            v_csv_sep := csv_separator;
            v_end_of_file_reached := false;
        end;
        
        -- Release (close) the associated CSV file
        procedure dispose(dummy:in t_void:= VOID) is begin
            file_close(my_csv_file);
        end;
        
        -- Read one line from the csv file, and keep it in the cache
        procedure readline(dummy:in t_void:= VOID) is begin
            readline(my_csv_file, v_current_line);
            v_end_of_file_reached := endfile(my_csv_file);
        end;

        -- Skip a separator (comma character) in the current line
        procedure skip_separator is
            variable dummy_string: string(1 to c_LINE_LENGTH_MAX);
        begin
            dummy_string := read_string(void);
        end;
                
        -- Read a string from the csv file and convert it to integer
        impure function read_integer(dummy:in t_void:= VOID) return integer is
            variable read_value: integer;
        begin
            read(v_current_line, read_value);
            skip_separator;
            return read_value;
        end;
    
        -- Read a string from the csv file and convert it to real
        impure function read_real(dummy:in t_void:= VOID) return real is
            variable read_value: real;
        begin
            read(v_current_line, read_value);
            skip_separator;
            return read_value;
        end;
        
        -- Read a string from the csv file and convert it to boolean
        impure function read_boolean(dummy:in t_void:= VOID) return boolean is begin
            return boolean'value(read_string(void));
        end;
        
        impure function read_integer_as_boolean(dummy:in t_void:= VOID) return boolean is
        begin
            return (read_integer(void) /= 0);
        end;
        
        -- Read a string from the csv file, until a separator character ',' is found
        impure function read_string(dummy:in t_void:= VOID) return string is
            variable v_return_string: string(1 to c_LINE_LENGTH_MAX);
            variable v_read_char: character;
            variable v_read_ok: boolean := true;
            variable v_index: integer := 1;
        begin
            read(v_current_line, v_read_char, v_read_ok);
            while v_read_ok loop
                if v_read_char = v_csv_sep then
                    return v_return_string;
                else
                    v_return_string(v_index) := v_read_char;
                    v_index := v_index + 1;
                end if;
                read(v_current_line, v_read_char, v_read_ok);
            end loop;
            v_return_string(1):= ' ';
            return v_return_string;

        end;

        -- Read a string from the csv file, at the column index until a separator character ',' is found
        impure function read_string_by_index(column_index:in integer) return string is
            variable v_return_string: string(1 to c_LINE_LENGTH_MAX);
            variable v_read_char: character;
            variable v_read_ok: boolean := true;
            variable v_index: integer := 1;
            variable v_line_tmp : line;
            variable v_cnt : integer := 0;
        begin
            v_line_tmp := v_current_line;
            read(v_line_tmp, v_read_char, v_read_ok);
            while v_read_ok loop
                if v_read_char = v_csv_sep and v_cnt = column_index then
                    return v_return_string;
                elsif v_read_char = v_csv_sep then
                   v_cnt := v_cnt + 1;
                else
                    v_return_string(v_index) := v_read_char;
                    v_index := v_index + 1;
                end if;
                read(v_line_tmp, v_read_char, v_read_ok);
            end loop;
            v_return_string(1):= ' ';
            return v_return_string;

        end;

        -- Read a string (ex: 0 or 1) from the csv file and convert it to std_logic
        impure function read_integer_as_std(dummy:in t_void:= VOID) return std_logic is
            variable read_value: integer;
            variable val_v : std_logic;
        begin
            read(v_current_line, read_value);
            skip_separator;
            val_v :=  std_logic(to_unsigned(read_value, 1)(0));
            return val_v;
        end;
    
        -- Read a string (ex:255) from the csv file and convert it to std_logic_vector
        impure function read_integer_as_std_vec(length:in integer;unsigned_value: boolean := true) return std_logic_vector is
            variable read_value: integer;
            variable val_v : std_logic_vector(length - 1 downto 0);
        begin
            read(v_current_line, read_value);
            skip_separator;
            if unsigned_value = true then
                val_v :=  std_logic_vector(to_unsigned(read_value, length));
            else
                val_v :=  std_logic_vector(to_signed(read_value, length));
            end if;
            return val_v;
        end;

        -- Read a string (ex: AB0) from the csv file and convert it to std_logic_vector
        impure function read_hex_as_std_vec(length:in integer) return std_logic_vector is
            variable val_tmp_v : std_logic_vector(2**integer(ceil(log2(real(length)))) - 1 downto 0);
            variable val_v : std_logic_vector(length - 1 downto 0);
        begin
            HREAD(v_current_line, val_tmp_v);
            -- get the LSB bits
            val_v := val_tmp_v(val_v'range);
            skip_separator;
            return val_v;
        end;

        -- read a common typ as std_logic_vector
        --  common typ = "UINT" => the file integer value is converted into an unsigned vector -> std_logic_vector
        --  common typ = "INT" => the file integer value  is converted into a signed vector -> std_logic_vector
        --  common typ = "HEX" => the file hexadecimal value is converted into a std_logic_vector
        --  common typ = "STD_VEC" (binary value) => the std_logic_vector is not converted
        impure function read_common_typ_as_std_vec(length:in integer; common_typ:in string:= "UINT") return std_logic_vector is
          variable val_v : std_logic_vector(length - 1 downto 0) := (others => '0');
        begin

            if common_typ = "UINT" then
               val_v := read_integer_as_std_vec(length=> val_v'length,unsigned_value=> true);
            elsif common_typ = "INT" then
               val_v := read_integer_as_std_vec(length=> val_v'length,unsigned_value=> false);
            elsif common_typ = "HEX" then
               val_v := read_hex_as_std_vec(length=> val_v'length);
            else
              val_v := read_std_vec(length=> val_v'length);
            end if;

            return val_v;
        end;

        -- Read a string (ex: 10010) from the csv file and convert it to std_logic_vector
        impure function read_std_vec(length:in integer) return std_logic_vector is
            variable val_v : std_logic_vector(length - 1 downto 0);
        begin
            READ(v_current_line, val_v);
            skip_separator;
            return val_v;
        end;

         -- Read a string (ex: 10010) from the csv file and convert it to std_logic_vector
        impure function read_std(dummy:in t_void:= VOID) return std_logic is
            variable val_v : std_ulogic;
        begin
            READ(v_current_line, val_v);
            skip_separator;
            return std_logic(val_v);
        end;

        -- write a std_logic_vector into line
        procedure write_std_vec(value:in std_logic_vector;csv_separator: in character := ';'; constant use_csv_separator: in integer := 1) is
        begin
            WRITE(v_current_line, value);
            if use_csv_separator = 1 then
             WRITE(v_current_line,csv_separator);
            end if;
        end;
        -- write a std_logic into line
        procedure write_std(value:in std_logic;csv_separator: in character := ';'; constant use_csv_separator: in integer := 1) is
            variable val_v : std_ulogic;
        begin
            val_v := std_ulogic(value);
            WRITE(v_current_line, val_v);
            if use_csv_separator = 1 then
             WRITE(v_current_line,csv_separator);
            end if;
        end;

        -- write a string into line
        procedure write_string(value:in string;csv_separator: in character := ';'; constant use_csv_separator: in integer := 1) is
        begin
            WRITE(v_current_line, value);
            if use_csv_separator = 1 then
                WRITE(v_current_line,csv_separator);
            end if;
        end;

         -- write a integer into line
        procedure write_integer(value:in integer;csv_separator: in character := ';'; constant use_csv_separator: in integer := 1) is
        begin
            WRITE(v_current_line, value);
            if use_csv_separator = 1 then
                WRITE(v_current_line,csv_separator);
            end if;
        end;

         -- write a real into line
        procedure write_real(value:in real;csv_separator: in character := ';'; constant use_csv_separator: in integer := 1) is
        begin
            WRITE(v_current_line, value);
            if use_csv_separator = 1 then
                WRITE(v_current_line,csv_separator);
            end if;
        end;

        -- write a time into line
        procedure write_time(value:in time;csv_separator: in character := ';'; constant use_csv_separator: in integer := 1) is
        begin
            WRITE(v_current_line, value);
            if use_csv_separator = 1 then
              WRITE(v_current_line,csv_separator);
            end if;
        end;
        -- write a boolean into line
        procedure write_boolean(value:in boolean;csv_separator: in character := ';'; constant use_csv_separator: in integer := 1) is
        begin
            WRITE(v_current_line, value);
            if use_csv_separator = 1 then
              WRITE(v_current_line,csv_separator);
            end if;
        end;

        -- write a character into line
        procedure write_char(value:in character) is
        begin
            WRITE(v_current_line, value);
        end;

        -- write a std_logic_vector as hexadecimal string into line
        procedure write_std_vec_as_hex(value:in std_logic_vector;csv_separator: in character := ';'; constant use_csv_separator: in integer := 1; constant unsigned_value : boolean := true) is
        -- This function write in a file the hexadecimal value of an input "value" std_logic_vector with a minimal number of hexadecimal character.
        -- The user can define if the input std_logic_vector must be processed as a signed vector or a unsigned vector
        -- TO do that:
        -- we build a "val0_v" variable of std_logic_vector type with the following properties:
        --   . the length is a multiple of 4 bits (1 hexadécimal character = 4 bits)
        --   . The length >= length(value)
        variable val0_v : std_logic_vector(integer(ceil( real(value'length)/real(4) ) ) * 4 - 1 downto 0);

        begin


            if unsigned_value = false then
               val0_v := std_logic_vector(resize(signed(value),val0_v'length));
            else
               val0_v := std_logic_vector(resize(unsigned(value),val0_v'length));
            end if;

            HWRITE(v_current_line, val0_v);
            if use_csv_separator = 1 then
              WRITE(v_current_line,csv_separator);
            end if;
        end;

        -- write a std_logic_vector as common type
        --  common typ = "UINT" => the std_logic_vector is converted into unsigned int representation
        --  common typ = "INT" => the std_logic_vector is converted into signed int representation
        --  common typ = "HEX" => the std_logic_vector value is considered as a signed vector, then it's converted into hex representation
        --  common typ = "UHEX" => the std_logic_vector value is considered as a unsigned vector, then it's converted into hex representation
        --  common typ = "STD_VEC" => the std_logic_vector is not converted
        procedure write_std_vec_as_common_typ(value:in std_logic_vector;csv_separator:in character:= ';';common_typ:in string:= "UINT"; constant use_csv_separator: in integer := 1) is
          variable val_v : integer := 0;
        begin
            if common_typ = "UINT" then
               assert not(value'length > 32) report "pkg_csv_file.write_std_vec_as_common_typ: std_logic_vector (length = "&to_string(value'length)&" can't be represented by an unsigned integer" severity warning;
               val_v := to_integer(unsigned(value));
               write_integer(value=> val_v ,csv_separator=> csv_separator, use_csv_separator => use_csv_separator);
            elsif common_typ = "INT" then
               assert not(value'length > 32) report "pkg_csv_file.write_std_vec_as_common_typ: std_logic_vector (length = "&to_string(value'length)&" can't be represented by an signed integer" severity warning;
               val_v := to_integer(signed(value));
               write_integer(value=> val_v ,csv_separator=> csv_separator, use_csv_separator => use_csv_separator);
            elsif common_typ = "HEX" then
               write_std_vec_as_hex(value=> value ,csv_separator=> csv_separator, use_csv_separator => use_csv_separator, unsigned_value => false);
            elsif common_typ = "UHEX" then
               write_std_vec_as_hex(value=> value ,csv_separator=> csv_separator, use_csv_separator => use_csv_separator, unsigned_value => true);
            else
            -- common_typ = "STD_VEC"
              write_std_vec(value=> value ,csv_separator=> csv_separator, use_csv_separator => use_csv_separator);
            end if;
        end;


        -- write line into a csv file
        procedure writeline(dummy:in t_void:= VOID) is
        begin
            writeline(my_csv_file,v_current_line);
        end;



    end protected body;

end;
