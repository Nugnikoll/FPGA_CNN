library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_rom is
	generic(
		data_width: integer; -- the width of the input data
		result_width: integer; -- the width of the result
		delay: integer
	);
	port(
		clk: in std_logic; -- clock
		reset: in std_logic; -- synchronous reset
		enable: in std_logic; -- synchronous enable

		rvalid: in std_logic; -- indicate whether the input data is valid
		-- rready: out std_logic; -- assert the alu_rom is always ready for input

		tvalid: out std_logic; -- indicate the output data is valid
		-- tready: in std_logic; -- assert the data can always be transmitted

		data: in signed(data_width - 1 downto 0); -- input data
		result: out signed(result_width - 1 downto 0) -- output data
	);
end;

architecture arch of alu_rom is

	constant addr_space: integer := 2 ** data_width;
	type memory_type is array(addr_space - 1 downto 0) of signed(data_width - 1 downto 0);
	signal memory: memory_type := (others => to_signed(7, data_width));
	signal data_fifo: signed(result_width - 1 downto 0);

begin

	data_fifo <= memory(to_integer(data));

	fifo_inst: entity work.alu_fifo
		generic map(
			width => result_width,
			depth => delay
		)
		port map(
			clk => clk,
			reset => reset,
			enable => enable,
			rvalid => rvalid, 
			tvalid => tvalid,
			data => data_fifo,
			result => result
		);

end;
