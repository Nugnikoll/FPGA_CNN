library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_mul is
	generic(
		width: integer; -- the width of the input data
		delay: integer
	);
	port(
		clk: in std_logic; -- clock
		reset: in std_logic; -- synchronous reset
		enable: in std_logic; -- synchronous enable

		rvalid: in std_logic; -- indicate whether the input data is valid
		-- rready: out std_logic; -- assert the alu_mul is always ready for input
		tvalid: out std_logic; -- indicate the output data is valid
		-- tready: in std_logic; -- assert the data can always be transmitted

		data_a: in signed(width - 1 downto 0); -- input data
		data_b: in signed(width - 1 downto 0); -- input data
		result: out signed(width - 1 downto 0) -- output data
	);
end;

architecture arch of alu_mul is

	signal data_fifo_buf: signed(width * 2 - 1 downto 0);
	signal data_fifo: signed(width - 1 downto 0);

begin
	data_fifo_buf <= data_a * data_b;
	data_fifo <= data_fifo_buf(width * 3 / 2 - 1 downto width / 2);

	fifo_inst: entity work.alu_fifo
		generic map(
			width => width,
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
