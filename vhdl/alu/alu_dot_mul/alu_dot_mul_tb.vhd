library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.head.all;

entity alu_dot_mul_tb is
end alu_dot_mul_tb;

architecture arch of alu_dot_mul_tb is

	constant period: time := 1 us;

	constant size_max: integer := 16;

	signal size_minus: ubyte;
	signal clk: std_logic := '0';
	signal enable: std_logic;
	signal reset: std_logic;
	signal rvalid: std_logic;
	signal tvalid: std_logic;
	signal data_buf: val_type := "0000000000000011";
	signal data: val_type;
	signal conf_data: vector(16 - 1 downto 0);
	signal result: val_type;

begin

	g_conf: for i in conf_data'length - 1 downto 0 generate
		conf_data(i) <= to_signed(i * 2 + 1, val_type'length);
	end generate;

	process
	begin
		wait for period / 2;
		clk <= not clk;
	end process;

	process
	begin
		wait for period;
		data_buf <= data_buf + 1;
	end process;
	data <= data_buf sll 8;

	process
	begin
		size_minus <= 5 - 1;
		enable <= '0';
		reset <= '1';
		rvalid <= '0';
		wait for period;
		reset <= '0';
		wait for period;
		enable <= '1';
		rvalid <= '1';
		wait;
	end process;

	alu_dot_mul_inst: entity work.alu_dot_mul
		generic map(
			size_max => size_max
		)
		port map(
			size_minus => size_minus,
			clk => clk,
			enable => enable,
			reset => reset,
			rvalid => rvalid,
			tvalid => tvalid,
			data => data,
			conf_data => conf_data,
			result => result
		);

end arch;
