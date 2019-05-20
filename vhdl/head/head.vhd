library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package head is
	-- types
	subtype short is integer range 2 ** 15 - 1 downto - 2 ** 15;
	subtype ushort is integer range 2 ** 16 - 1 downto 0;
	subtype byte is integer range 2 ** 7 - 1 downto - 2 ** 7;
	subtype ubyte is integer range 2 ** 8 - 1 downto 0;

	subtype int4 is integer range 2 ** 3 - 1 downto - 2 ** 3;
	subtype uint4 is integer range 2 ** 4 - 1 downto 0;
	subtype int8 is integer range 2 ** 7 - 1 downto - 2 ** 7;
	subtype uint8 is integer range 2 ** 8 - 1 downto 0;
	subtype int16 is integer range 2 ** 15 - 1 downto - 2 ** 15;
	subtype uint16 is integer range 2 ** 16 - 1 downto 0;
	subtype int32 is integer range 2 ** 31 - 1 downto - 2 ** 31;

	-- fixed point Q8.8 (two's complement representation)
	subtype q8_8 is signed(15 downto 0);
	-- fixed point Q16.16 (two's complement representation)
	subtype q16_16 is signed(31 downto 0);
	-- type of the signals that are used in calculation
	subtype val_type is q8_8;

	-- vector and matrix of calculation type
	type vector is array(natural range<>) of val_type;
	type matrix is array(natural range<>,natural range<>) of val_type;

	-- types that are used to be compatible with std_logic_vector
	subtype val_logic is std_logic_vector(val_type'length - 1 downto 0);
	type vector_logic is array(natural range<>) of val_logic;
	type matrix_logic is array(natural range<>,natural range<>) of val_logic;

	-- conversion
	function to_val_type(n: integer) return val_type;

	-- calculate the maximum of two numbers
	function max(l:val_type; r:val_type) return val_type;

end head;

package body head is

	-- conversion
	function to_val_type(n: integer) return val_type is
		variable temp: signed(val_type'length - 1 downto 0);
		variable result: val_type;
	begin
		temp := to_signed(n,val_type'length);
		result(val_type'length - 1 downto val_type'length / 2)
			:= temp(val_type'length / 2 - 1 downto 0);
		result(val_type'length / 2 - 1 downto 0) := (others => '0');
		return result;
	end to_val_type;

	-- calculate the maximum of two numbers
	function max(l:val_type; r:val_type) return val_type is
		variable result: val_type;
	begin
		if l >= r then
			result := l;
		else
			result := r;
		end if;
		return result;
	end function;

end head;
