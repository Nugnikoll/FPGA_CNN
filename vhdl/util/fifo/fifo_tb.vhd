library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo_tb is
end entity;

architecture arch of fifo_tb is

	constant period: time := 1 us;

	constant width: integer := 5;
	constant depth: integer := 6;

	signal clk: std_logic := '0'; -- clock
	signal reset: std_logic; -- synchronous reset
	signal enable: std_logic; -- synchronous enable

	signal rvalid: std_logic; -- indicate whether the input data is valid
	signal rready: std_logic; -- indicate whether the fifo is ready for input (whether the fifo is not full)

	signal tvalid: std_logic; -- indicate whether the data can be transmit
	signal tready: std_logic; -- indicate whether the output data is valid (whether the fifo is not empty)

	signal data: signed(width - 1 downto 0); -- input data
	signal result: signed(width - 1 downto 0); -- output data

begin

	fifo_inst: entity work.fifo
		generic map(
			width => width,
			depth => depth
		)
		port map(
			clk => clk,
			reset => reset,
			enable => enable,
			rvalid => rvalid,
			rready => rready,
			tvalid => tvalid,
			tready => tready,
			data => data,
			result => result
		);

	process
	begin
		wait for period / 2;
		clk <= not clk;
	end process;

	process
	begin

		reset <= '1';
		enable <= '0';
		rvalid <= '1';
		tready <= '1';
		data <= to_signed(0, data'length);
		wait for 3 * period;

		reset <= '0';
		wait for period;

		enable <= '1';
		for i in 3 to 12 loop
			data <= to_signed(i, data'length);
			wait for period;
		end loop;

		enable <= '0';
		data <= to_signed(0, data'length);
		wait for period;

		reset <= '1';
		rvalid <= '0';
		tready <= '0';
		wait for period;

		reset <= '0';
		wait for period;

		enable <= '1';
		rvalid <= '1';
		for i in 3 to 12 loop
			data <= to_signed(i, data'length);
			wait for period;
		end loop;

		rvalid <= '0';
		wait for period;

		tready <= '1';
		wait;
		
	end process;

end arch;
