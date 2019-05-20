library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity alu_sigmoid is
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

		data: in signed(width - 1 downto 0); -- input data
		result: out signed(width - 1 downto 0) -- output data
	);
end;

architecture arch of alu_sigmoid is

	signal data_fifo: signed(width - 1 downto 0);

begin
	data_fifo <= to_signed(integer(1.0 / exp(real(to_integer(data)) / (2.0 ** (data'length / 2)) + 1.0) * (2.0 ** (data'length / 2))), data_fifo'length);

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
