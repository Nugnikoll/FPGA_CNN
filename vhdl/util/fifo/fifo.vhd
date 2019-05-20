library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo is
	generic(
		width: integer; -- the width of the input data
		depth: integer -- the depth of the fifo
	);
	port(
		clk: in std_logic; -- clock
		reset: in std_logic; -- synchronous reset
		enable: in std_logic; -- synchronous enable

		rvalid: in std_logic; -- indicate whether the input data is valid
		rready: out std_logic; -- indicate whether the fifo is ready for input

		tvalid: out std_logic; -- indicate whether the output data is valid
		tready: in std_logic; -- indicate whether the data can be transmitted

		data: in signed(width - 1 downto 0); -- input data
		result: out signed(width - 1 downto 0) -- output data
	);
end;

architecture arch of fifo is

	signal full, empty: std_logic;
	type memory_type is array(depth - 1 downto 0) of signed(width - 1 downto 0);
	signal memory: memory_type;
	subtype ptr_type is integer range depth - 1 downto 0;
	signal ptr_in, ptr_out: ptr_type := 0;
	signal ptr_in_next, ptr_out_next: ptr_type := 1;

begin

	ptr_in_next <= 0 when ptr_in = depth - 1 else ptr_in + 1;
	ptr_out_next <= 0 when ptr_out = depth - 1 else ptr_out + 1;
	full <= '1' when ptr_out = ptr_in_next else '0';
	empty <= '1' when ptr_in = ptr_out else '0';
	rready <= not reset and enable and not full;
	tvalid <= not reset and enable and not empty;
	result <= memory(ptr_out);

	process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				ptr_in <= 0;
				ptr_out <= 0;
			elsif enable = '1' then
				if rvalid = '1' and not full = '1' then
					memory(ptr_in) <= data;
					ptr_in <= ptr_in_next;
				end if;
				if tready = '1' and not empty = '1' then
					ptr_out <= ptr_out_next;
				end if;
			end if;
		end if;
	end process;

end;
