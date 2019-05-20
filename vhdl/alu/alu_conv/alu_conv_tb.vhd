library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.head.all;

entity alu_conv_tb is
end;

architecture arch of alu_conv_tb is

	constant kernel_max: integer := 4;

	signal clk: std_logic := '0';
	signal enable: std_logic;
	signal reset: std_logic;
	signal kernel_minus: ubyte := 3;
	signal height_minus: ubyte;
	signal width_minus: ubyte;
	signal kernel: matrix(kernel_max - 1 downto 0, kernel_max - 1 downto 0);
	signal rvalid: std_logic;
	signal tvalid: std_logic;
	signal data: val_type;
	signal result: val_type;

	constant period: time := 1 us;

begin

	alu_conv_inst: entity work.alu_conv
		generic map(
			kernel_max => kernel_max
		)
		port map(
			clk => clk,
			enable => enable,
			reset => reset,

			kernel_minus => kernel_minus,
			height_minus => height_minus,
			width_minus => width_minus,
			kernel => kernel,

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
		kernel <=
			(
				(
					val_type(to_unsigned(0 * (2**8),val_type'length)),
					val_type(to_unsigned(0 * (2**8),val_type'length)),
					val_type(to_unsigned(0 * (2**8),val_type'length)),
					val_type(to_unsigned(0 * (2**8),val_type'length))
				),(
					val_type(to_unsigned(0 * (2**8),val_type'length)),
					val_type(to_unsigned(9 * (2**8),val_type'length)),
					val_type(to_unsigned(8 * (2**8),val_type'length)),
					val_type(to_unsigned(7 * (2**8),val_type'length))
				),(
					val_type(to_unsigned(0 * (2**8),val_type'length)),
					val_type(to_unsigned(6 * (2**8),val_type'length)),
					val_type(to_unsigned(5 * (2**8),val_type'length)),
					val_type(to_unsigned(4 * (2**8),val_type'length))
				),(
					val_type(to_unsigned(0 * (2**8),val_type'length)),
					val_type(to_unsigned(3 * (2**8),val_type'length)),
					val_type(to_unsigned(2 * (2**8),val_type'length)),
					val_type(to_unsigned(1 * (2**8),val_type'length))
				)
			);

		reset <= '1';
		enable <= '0';
		rvalid <= '0';
		kernel_minus <= 3 - 1;
		height_minus <= 5 - 1;
		width_minus <= 7 - 1;
		data <= val_type(to_unsigned(1234,val_type'length));
		wait for period * 3;

		reset <= '0';
		wait for period * 2;

		enable <= '1';
		wait for period * 2;

		rvalid <= '1';
		for i in 1 to 35 loop
			data <= val_type(to_unsigned(i,val_type'length));
			wait for period;
		end loop;

		rvalid <= '0';
		wait for period * 10;

		reset <= '1';
		enable <= '0';
		rvalid <= '0';
		kernel_minus <= 3 - 1;
		height_minus <= 5 - 1;
		width_minus <= 7 - 1;
		data <= val_type(to_unsigned(1234,val_type'length));
		wait for period * 3;

		reset <= '0';
		wait for period * 2;

		enable <= '1';
		wait for period * 2;

		for i in 1 to 35 loop
			rvalid <= '1';
			data <= val_type(to_unsigned(i,val_type'length));
			wait for period;
			rvalid <= '0';
			wait for period * 2;
		end loop;

		rvalid <= '0';
		wait;

	end process;

end arch;
