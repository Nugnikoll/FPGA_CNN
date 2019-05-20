library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_rom_tb is
end;

architecture arch of alu_rom_tb is

	constant period: time := 1 us;

	constant data_width: integer := 8;
	constant result_width: integer := 8;
	constant delay: integer := 3;

	signal clk: std_logic := '0'; -- clock
	signal reset: std_logic; -- synchronous reset
	signal enable: std_logic; -- synchronous enable

	signal rvalid: std_logic; -- indicate whether the input data is valid
	-- signal rready: std_logic; -- assert the fifo is always ready for input

	signal tvalid: std_logic; -- indicate whether the output data is valid
	-- tready: std_logic; -- assert the data can always be transmitted

	signal data: signed(data_width - 1 downto 0); -- input data
	signal result: signed(result_width - 1 downto 0); -- output data

begin

	fifo_inst: entity work.alu_rom
		generic map(
			data_width => data_width,
			result_width => result_width,
			delay => delay
		)
		port map(
			clk => clk,
			reset => reset,
			enable => enable,
			rvalid => rvalid,
			tvalid => tvalid,
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

		wait;

	end process;

end;
