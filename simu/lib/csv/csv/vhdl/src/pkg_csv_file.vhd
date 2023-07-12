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
--
--    This package uses the same principle as https://github.com/ricardo-jasinski/vhdl-csv-file-reader/blob/master/hdl/package/csv_file_reader_pkg.vhd
--    But, new functionnalities was added
--
--    How to use this package:
--       1. Create a csv_file_reader object:
--            variable v_csv: t_csv_file_reader;
--       2. Open a csv file and define the csv separator:
--            v_csv.initialize("c:\file.csv",';');
--       3. Read one line at a time:
--            csv.readline();
--       4. Read the first column (integer value)
--            v_my_integer := csv.read_integer();
--       5. To read more column values in the same line, call any of the read_* functions
--       6. To move to the next line, call csv.readline() again
--
--     Note: this package could be compiled in the csv_lib
--     LIMITATION:
--       . the vhdl code its integer value on 32 bits. So, 2 limitations are present:
--          . write, in an output csv file, a std_logic_vector (with a width > 32 bits) as an integer value is not possible.
--            But, the binary representation can be.
--          . an integer value of 64 bits (>32 bits) from an input csv file can't be read by this library. But, the binary
--            representation can be.
--
-- -------------------------------------------------------------------------------------------------------------

library ieee;

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
        procedure initialize(i_file_pathname : in string; i_csv_separator : in character := ';'; i_open_kind : in FILE_OPEN_KIND := READ_MODE);
        -- Release (close) the associated CSV file
        procedure dispose(i_dummy : in t_void := VOID);
        -- Read one line from the csv file, and keep it in the cache
        procedure readline(i_dummy : in t_void := VOID);
        -- Read a string from the csv file, until a separator character ';' is found
        impure function read_string(i_dummy : in t_void := VOID) return string;
        -- Read a string from the csv file and convert it to an integer
        impure function read_integer(i_dummy : in t_void := VOID) return integer;
        -- Read a string from the csv file and convert it to real
        impure function read_real(i_dummy : in t_void := VOID) return real;
        -- Read a string from the csv file and convert it to boolean
        impure function read_boolean(i_dummy : in t_void := VOID) return boolean;
        -- Read a string with a numeric value from the csv file and convert it to a boolean
        impure function read_integer_as_boolean(i_dummy : in t_void := VOID) return boolean;
        -- Read a string from the csv file of the column specified by column_index, until a separator character ';' is found
        impure function read_string_by_index(i_column_index : in integer) return string;
        -- True when the end of the CSV file was reached
        impure function end_of_file(i_dummy : in t_void := VOID) return boolean;
        -- Read a string (ex: 0 or 1) from the csv file and convert it to std_logic
        impure function read_integer_as_std(i_dummy : in t_void := VOID) return std_logic;
        -- Read a string (ex: 11010) from the csv file and convert it to std_logic_vector
        impure function read_integer_as_std_vec(i_length : in integer; i_unsigned_value : boolean := true) return std_logic_vector;
        -- Read a string (ex: ABC) from the csv file and convert it to std_logic_vector
        impure function read_hex_as_std_vec(i_length : in integer) return std_logic_vector;
        -- read a data typ as std_logic_vector
        --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
        --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
        --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
        --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
        --  data type = "STD_VEC" => no data convertion before writing in the output file
        impure function read_data_typ_as_std_vec(i_length : in integer; i_data_typ : in string := "UINT") return std_logic_vector;
        -- Read a string (ex: 10010) from the csv file and convert it to std_logic_vector
        impure function read_std_vec(i_length : in integer) return std_logic_vector;
        -- Read a string (ex: 1 or 0) from the csv file and convert it to std_logic
        impure function read_std(i_dummy : in t_void := VOID) return std_logic;
        -- write a std_logic_vector to a csv file
        procedure write_std_vec(i_value : in std_logic_vector; i_csv_separator : in character := ';'; constant i_use_csv_separator : in integer := 1);
        -- write a std_logic into line
        procedure write_std(i_value : in std_logic; i_csv_separator : in character := ';'; constant i_use_csv_separator : in integer := 1);
        -- write a string into line
        procedure write_string(i_value : in string; i_csv_separator : in character := ';'; constant i_use_csv_separator : in integer := 1);
        -- write a integer into line
        procedure write_integer(i_value : in integer; i_csv_separator : in character := ';'; constant i_use_csv_separator : in integer := 1);
        -- write a real into line
        procedure write_real(i_value : in real; i_csv_separator : in character := ';'; constant i_use_csv_separator : in integer := 1);
        -- write a time into line
        procedure write_time(i_value : in time; i_csv_separator : in character := ';'; constant i_use_csv_separator : in integer := 1);
        -- write a boolean into line
        procedure write_boolean(i_value : in boolean; i_csv_separator : in character := ';'; constant i_use_csv_separator : in integer := 1);
        -- write a character into line
        procedure write_char(i_value : in character);
        -- write a std_logic_vector as hexadecimal string into line
        procedure write_std_vec_as_hex(i_value : in std_logic_vector; i_csv_separator : in character := ';'; constant i_use_csv_separator : in integer := 1; constant i_unsigned_value : boolean := true);
        -- write a std_logic_vector as data type
        --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
        --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
        --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
        --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
        --  data type = "STD_VEC" => no data convertion before writing in the output file
        procedure write_std_vec_as_data_typ(i_value : in std_logic_vector; i_csv_separator : in character := ';'; i_data_typ : in string := "UINT"; constant i_use_csv_separator : in integer := 1);
        -- write a std_logic_vector in different ways
        procedure writeline(i_dummy : in t_void := VOID);

    end protected;
end pkg_csv_file;

package body pkg_csv_file is

    type t_csv_file_reader is protected body
        -- Maximum string length for read operations
        constant c_LINE_LENGTH_MAX : integer := 256;

        -- file object
        file my_csv_file               : text;

        -- cache one line at a time for read operations
        variable v_current_line        : line;

        -- true when end of file was reached and there are no more lines to read
        variable v_end_of_file_reached : boolean;

        variable v_csv_sep : character;

        -- True when the end of the CSV file was reached
        impure function end_of_file(i_dummy : in t_void := VOID) return boolean is
        begin
            return v_end_of_file_reached;
        end;

        -- Open the CSV text file to be used for subsequent read operations
        procedure initialize(i_file_pathname : in string; i_csv_separator : in character := ';'; i_open_kind : in FILE_OPEN_KIND := READ_MODE) is
        begin
            -- FILE_OPEN_KIND values: READ_MODE, WRITE_MODE, APPEND_MODE
            file_open(my_csv_file, i_file_pathname, i_open_kind);
            v_csv_sep             := i_csv_separator;
            v_end_of_file_reached := false;
        end;

        -- Release (close) the associated CSV file
        procedure dispose(i_dummy : in t_void := VOID) is
        begin
            file_close(my_csv_file);
        end;

        -- Read one line from the csv file, and keep it in the cache
        procedure readline(i_dummy : in t_void := VOID) is
        begin
            readline(my_csv_file, v_current_line);
            v_end_of_file_reached := endfile(my_csv_file);
        end;

        -- Read a string from the csv file, until a separator character ',' is found
        impure function read_string(i_dummy : in t_void := VOID) return string is
            variable v_return_string : string(1 to c_LINE_LENGTH_MAX);
            variable v_read_char     : character;
            variable v_read_ok       : boolean := true;
            variable v_index         : integer := 1;
        begin
            read(v_current_line, v_read_char, v_read_ok);
            while v_read_ok loop
                if v_read_char = v_csv_sep then
                    return v_return_string;
                else
                    v_return_string(v_index) := v_read_char;
                    v_index                  := v_index + 1;
                end if;
                read(v_current_line, v_read_char, v_read_ok);
            end loop;
            v_return_string(1) := ' ';
            return v_return_string;

        end;

        -- Skip a separator (comma character) in the current line
        procedure skip_separator is
            -- string associated to the separator character.
            variable v_dummy_string: string(1 to c_LINE_LENGTH_MAX);
        begin
            v_dummy_string := read_string(VOID);
        end;

        -- Read a string from the csv file and convert it to integer
        impure function read_integer(i_dummy : in t_void := VOID) return integer is
            variable v_read_value : integer;
        begin
            read(v_current_line, v_read_value);
            skip_separator;
            return v_read_value;
        end;

        -- Read a string from the csv file and convert it to real
        impure function read_real(i_dummy : in t_void := VOID) return real is
            variable v_read_value : real;
        begin
            read(v_current_line, v_read_value);
            skip_separator;
            return v_read_value;
        end;

        -- Read a string from the csv file and convert it to boolean
        impure function read_boolean(i_dummy : in t_void := VOID) return boolean is
        begin
            return boolean'value(read_string(VOID));
        end;

        impure function read_integer_as_boolean(i_dummy : in t_void := VOID) return boolean is
        begin
            return (read_integer(VOID) /= 0);
        end;



        -- Read a string from the csv file, at the column index until a separator character ',' is found
        impure function read_string_by_index(i_column_index : in integer) return string is
            variable v_return_string : string(1 to c_LINE_LENGTH_MAX);
            variable v_read_char     : character;
            variable v_read_ok       : boolean := true;
            variable v_index         : integer := 1;
            variable v_line_tmp      : line;
            variable v_cnt           : integer := 0;
        begin
            v_line_tmp         := v_current_line;
            read(v_line_tmp, v_read_char, v_read_ok);
            while v_read_ok loop
                if v_read_char = v_csv_sep and v_cnt = i_column_index then
                    return v_return_string;
                elsif v_read_char = v_csv_sep then
                    v_cnt := v_cnt + 1;
                else
                    v_return_string(v_index) := v_read_char;
                    v_index                  := v_index + 1;
                end if;
                read(v_line_tmp, v_read_char, v_read_ok);
            end loop;
            v_return_string(1) := ' ';
            return v_return_string;

        end;

        -- Read a string (ex: 0 or 1) from the csv file and convert it to std_logic
        impure function read_integer_as_std(i_dummy : in t_void := VOID) return std_logic is
            variable v_read_value : integer;
            variable v_val      : std_logic;
        begin
            read(v_current_line, v_read_value);
            skip_separator;
            v_val := std_logic(to_unsigned(v_read_value, 1)(0));
            return v_val;
        end;

        -- Read a string (ex:255) from the csv file and convert it to std_logic_vector
        impure function read_integer_as_std_vec(i_length : in integer; i_unsigned_value : boolean := true) return std_logic_vector is
            variable v_read_value : integer;
            variable v_val      : std_logic_vector(i_length - 1 downto 0);
        begin
            read(v_current_line, v_read_value);
            skip_separator;
            if i_unsigned_value = true then
                v_val := std_logic_vector(to_unsigned(v_read_value, i_length));
            else
                v_val := std_logic_vector(to_signed(v_read_value, i_length));
            end if;
            return v_val;
        end;

        -- Read a string (ex: AB0) from the csv file and convert it to std_logic_vector
        impure function read_hex_as_std_vec(i_length : in integer) return std_logic_vector is
            variable v_val_tmp : std_logic_vector(2 ** integer(ceil(log2(real(i_length)))) - 1 downto 0);
            variable v_val     : std_logic_vector(i_length - 1 downto 0);
        begin
            HREAD(v_current_line, v_val_tmp);
            -- get the LSB bits
            v_val := v_val_tmp(v_val'range);
            skip_separator;
            return v_val;
        end;

        -- read a data typ as std_logic_vector
        --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
        --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
        --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
        --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
        --  data type = "STD_VEC" => no data convertion before writing in the output file
        impure function read_data_typ_as_std_vec(i_length : in integer; i_data_typ : in string := "UINT") return std_logic_vector is
            variable v_val : std_logic_vector(i_length - 1 downto 0) := (others => '0');
        begin

            if i_data_typ = "UINT" then
                v_val := read_integer_as_std_vec(i_length => v_val'length, i_unsigned_value => true);
            elsif i_data_typ = "INT" then
                v_val := read_integer_as_std_vec(i_length => v_val'length, i_unsigned_value => false);
            elsif i_data_typ = "HEX" then
                v_val := read_hex_as_std_vec(i_length => v_val'length);
            else
                v_val := read_std_vec(i_length => v_val'length);
            end if;

            return v_val;
        end;

        -- Read a string (ex: 10010) from the csv file and convert it to std_logic_vector
        impure function read_std_vec(i_length : in integer) return std_logic_vector is
            variable v_val : std_logic_vector(i_length - 1 downto 0);
        begin
            READ(v_current_line, v_val);
            skip_separator;
            return v_val;
        end;

        -- Read a string (ex: 10010) from the csv file and convert it to std_logic_vector
        impure function read_std(i_dummy : in t_void := VOID) return std_logic is
            variable v_val : std_ulogic;
        begin
            READ(v_current_line, v_val);
            skip_separator;
            return std_logic(v_val);
        end;

        -- write a std_logic_vector into line
        procedure write_std_vec(i_value : in std_logic_vector; i_csv_separator : in character := ';'; constant i_use_csv_separator : in integer := 1) is
        begin
            WRITE(v_current_line, i_value);
            if i_use_csv_separator = 1 then
                WRITE(v_current_line, i_csv_separator);
            end if;
        end;
        -- write a std_logic into line
        procedure write_std(i_value : in std_logic; i_csv_separator : in character := ';'; constant i_use_csv_separator : in integer := 1) is
            variable v_val : std_ulogic;
        begin
            v_val := std_ulogic(i_value);
            WRITE(v_current_line, v_val);
            if i_use_csv_separator = 1 then
                WRITE(v_current_line, i_csv_separator);
            end if;
        end;

        -- write a string into line
        procedure write_string(i_value : in string; i_csv_separator : in character := ';'; constant i_use_csv_separator : in integer := 1) is
        begin
            WRITE(v_current_line, i_value);
            if i_use_csv_separator = 1 then
                WRITE(v_current_line, i_csv_separator);
            end if;
        end;

        -- write a integer into line
        procedure write_integer(i_value : in integer; i_csv_separator : in character := ';'; constant i_use_csv_separator : in integer := 1) is
        begin
            WRITE(v_current_line, i_value);
            if i_use_csv_separator = 1 then
                WRITE(v_current_line, i_csv_separator);
            end if;
        end;

        -- write a real into line
        procedure write_real(i_value : in real; i_csv_separator : in character := ';'; constant i_use_csv_separator : in integer := 1) is
        begin
            WRITE(v_current_line, i_value);
            if i_use_csv_separator = 1 then
                WRITE(v_current_line, i_csv_separator);
            end if;
        end;

        -- write a time into line
        procedure write_time(i_value : in time; i_csv_separator : in character := ';'; constant i_use_csv_separator : in integer := 1) is
        begin
            WRITE(v_current_line, i_value);
            if i_use_csv_separator = 1 then
                WRITE(v_current_line, i_csv_separator);
            end if;
        end;
        -- write a boolean into line
        procedure write_boolean(i_value : in boolean; i_csv_separator : in character := ';'; constant i_use_csv_separator : in integer := 1) is
        begin
            WRITE(v_current_line, i_value);
            if i_use_csv_separator = 1 then
                WRITE(v_current_line, i_csv_separator);
            end if;
        end;

        -- write a character into line
        procedure write_char(i_value : in character) is
        begin
            WRITE(v_current_line, i_value);
        end;

        -- write a std_logic_vector as hexadecimal string into line
        procedure write_std_vec_as_hex(i_value : in std_logic_vector; i_csv_separator : in character := ';'; constant i_use_csv_separator : in integer := 1; constant i_unsigned_value : boolean := true) is
            -- This function write in a file the hexadecimal value of an input "value" std_logic_vector with a minimal number of hexadecimal character.
            -- The user can define if the input std_logic_vector must be processed as a signed vector or a unsigned vector
            -- TO do that:
            -- we build a "v_val0" variable of std_logic_vector type with the following properties:
            --   . the length is a multiple of 4 bits (1 hexadécimal character = 4 bits)
            --   . The length >= length(value)
            variable v_val0 : std_logic_vector(integer(ceil(real(i_value'length) / real(4))) * 4 - 1 downto 0);

        begin

            if i_unsigned_value = false then
                v_val0 := std_logic_vector(resize(signed(i_value), v_val0'length));
            else
                v_val0 := std_logic_vector(resize(unsigned(i_value), v_val0'length));
            end if;

            HWRITE(v_current_line, v_val0);
            if i_use_csv_separator = 1 then
                WRITE(v_current_line, i_csv_separator);
            end if;
        end;

        -- write a std_logic_vector as data type
        --  data type = "UINT" => the input std_logic_vector value is converted into unsigned int value in the output file
        --  data type = "INT" => the input std_logic_vector value is converted into signed int value in the output file
        --  data type = "HEX" => the input std_logic_vector value is considered as a signed vector, then it's converted into hex value in the output file
        --  data type = "UHEX" => the input std_logic_vector value is considered as a unsigned vector, then it's converted into hex value in the output file
        --  data type = "STD_VEC" => no data convertion before writing in the output file
        procedure write_std_vec_as_data_typ(i_value : in std_logic_vector; i_csv_separator : in character := ';'; i_data_typ : in string := "UINT"; constant i_use_csv_separator : in integer := 1) is
            variable v_val : integer := 0;
        begin
            if i_data_typ = "UINT" then
                assert not (i_value'length > 32) report "pkg_csv_file.write_std_vec_as_common_typ: std_logic_vector (length = " & to_string(i_value'length) & " can't be represented by an unsigned integer" severity warning;
                v_val := to_integer(unsigned(i_value));
                write_integer(i_value => v_val, i_csv_separator => i_csv_separator, i_use_csv_separator => i_use_csv_separator);
            elsif i_data_typ = "INT" then
                assert not (i_value'length > 32) report "pkg_csv_file.write_std_vec_as_common_typ: std_logic_vector (length = " & to_string(i_value'length) & " can't be represented by an signed integer" severity warning;
                v_val := to_integer(signed(i_value));
                write_integer(i_value => v_val, i_csv_separator => i_csv_separator, i_use_csv_separator => i_use_csv_separator);
            elsif i_data_typ = "HEX" then
                write_std_vec_as_hex(i_value => i_value, i_csv_separator => i_csv_separator, i_use_csv_separator => i_use_csv_separator, i_unsigned_value => false);
            elsif i_data_typ = "UHEX" then
                write_std_vec_as_hex(i_value => i_value, i_csv_separator => i_csv_separator, i_use_csv_separator => i_use_csv_separator, i_unsigned_value => true);
            else
                -- common_typ = "STD_VEC"
                write_std_vec(i_value => i_value, i_csv_separator => i_csv_separator, i_use_csv_separator => i_use_csv_separator);
            end if;
        end;

        -- write line into a csv file
        procedure writeline(i_dummy : in t_void := VOID) is
        begin
            writeline(my_csv_file, v_current_line);
        end;

    end protected body;

end pkg_csv_file;
