library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_fifo is
	generic(
		width: integer; -- the width of the input data
		depth: integer -- the depth of the fifo
	);
	port(
		clk: in std_logic; -- clock
		reset: in std_logic; -- synchronous reset
		enable: in std_logic; -- synchronous enable

		rvalid: in std_logic; -- indicate whether the input data is valid
		-- rready: out std_logic; -- assert the fifo is always ready for input

		tvalid: out std_logic; -- indicate whether the output data is valid
		-- tready: in std_logic; -- assert the data can always be transmitted

		data: in signed(width - 1 downto 0); -- input data
		result: out signed(width - 1 downto 0) -- output data
	);
end;

architecture arch of alu_fifo is

	signal flag: std_logic_vector(depth downto 0);
	type memory_type is array(depth downto 0) of signed(width - 1 downto 0);
	signal memory: memory_type;
	subtype ptr_type is integer range depth downto 0;
	signal ptr: ptr_type := 0;
	signal ptr_next: ptr_type := 1;

begin

	ptr_next <= 0 when ptr = depth else ptr + 1;
	tvalid <= not reset and enable and flag(ptr_next);
	result <= memory(ptr_next);

	process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				ptr <= 0;
				flag <= (others => '0');
			elsif enable = '1' then
				flag(ptr) <= rvalid;
				memory(ptr) <= data;
				ptr <= ptr_next;
			end if;
		end if;
	end process;

end arch;
