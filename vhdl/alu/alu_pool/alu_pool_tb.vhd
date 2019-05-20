library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.head.all;

entity alu_pool_tb is
end;

architecture arch of alu_pool_tb is

	constant pool_type: string := "max_pool"; -- should be either "max_pool" or "mean_pool"
	constant kernel_max: integer := 4;

	signal clk: std_logic := '0';
	signal enable: std_logic;
	signal reset: std_logic;
	signal kernel_minus: ubyte := 3;
	signal height_minus: ubyte;
	signal width_minus: ubyte;
	signal width_div_minus: ubyte := 0;
	signal rvalid: std_logic;
	signal tvalid: std_logic;
	signal data: val_type;
	signal result: val_type;

	constant period: time := 1 us;

	type series_type is array(1 to 35) of integer;
	constant series: series_type :=
		(
			20, 27, 23, 15,  8, 14, 12,
			17, 26, 28, 18, 10,  1,  9,
			11,  4, 24, 21, 22, 19,  3,
			 2,  7, 13, 29, 16,  6, 25,
			5 ,  4, -3, 09, 14, 23,-32
		);

begin

	alu_pool_inst: entity work.alu_pool
		generic map(
			pool_type => pool_type,
			height_max => 32,
			width_max => 32,
			width_div_max => 16,
			kernel_max => kernel_max
		)
		port map(
			clk => clk,
			enable => enable,
			reset => reset,
			kernel_minus => kernel_minus,
			height_minus => height_minus,
			width_minus => width_minus,
			width_div_minus => width_div_minus,
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
		rvalid <= '0';
		kernel_minus <= 3 - 1;
		height_minus <= 11 - 1;
		width_minus <= 7 - 1;
		width_div_minus <= 7 / 3 - 1;
		data <= val_type(to_signed(0,val_type'length));
		wait for period * 3;

		reset <= '0';
		wait for period * 2;

		enable <= '1';
		wait for period * 2;

		rvalid <= '1';
		for i in 1 to 3 loop
			for j in 1 to 35 loop
				data <= val_type(to_signed(series(j), val_type'length));
				wait for period;
			end loop;
		end loop;
		rvalid <= '0';
		wait for period * 2;

	end process;

end arch;
