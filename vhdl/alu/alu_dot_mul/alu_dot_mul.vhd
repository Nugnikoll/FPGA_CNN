library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.head.all;
use work.head_const.all;

entity alu_dot_mul is
	generic(
		size_max: integer -- the max size of vector
	);
	port(
		clk: in std_logic; -- clock
		enable: in std_logic; -- enable
		reset: in std_logic; -- synchronous reset

		size_minus: in ubyte; -- the size of vector minus one
		conf_data: in vector(size_max - 1 downto 0);

		rvalid: in std_logic; -- the signal indicates whether the input data is valid
		tvalid: out std_logic; -- the signal indicates whether the output data is valid

		data: in val_type; -- the channel of input data stream
		result: out val_type -- the output data stream
	);
end;

architecture arch of alu_dot_mul is

	signal valid_first, valid_second: std_logic;
	signal tvalid_buf: std_logic;
	subtype addr_type is integer range size_max - 1 downto 0;
	signal addr: addr_type;
	signal data_buf, data_second, product, result_buf: val_type;

	subtype count_type is integer range size_max - 1 downto 0;
	signal count: count_type; -- the range should be specified

begin

	-- select data
	process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				data_second <= (others => '0');
				addr <= 0;
				valid_first <= '0';
				data_buf <= (others => '0');
			elsif enable = '1' and rvalid = '1' then
				data_second <= conf_data(addr);
				if addr = size_minus then
					addr <= 0;
				else
					addr <= addr + 1;
				end if;
				valid_first <= '1';
				data_buf <= data;
			else
				valid_first <= '0';
			end if;
		end if;
	end process;

	-- pipline multiplier
	alu_mul_inst: entity work.alu_mul
		generic map(
			width => 16,
			delay => mul_delay
		)
		port map(
			clk => clk,
			reset => reset,
			enable => enable,
			rvalid => valid_first,
			tvalid => valid_second,
			data_a => data_buf,
			data_b => data_second,
			result => product
		);

	-- accumulate
	process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				count <= 0;
				result_buf <= (others => '0');
				tvalid_buf <= '0';
			elsif enable = '1' and valid_second = '1' then
				if count = size_minus then
					count <= 0;
				else
					count <= count + 1;
				end if;
				if tvalid_buf = '1' then
					result_buf <= product;
				else
					result_buf <= product + result_buf;
				end if;

				if count = size_minus then
					tvalid_buf <= '1';
				else
					tvalid_buf <= '0';
				end if;
			else
				tvalid_buf <= '0';
			end if;
		end if;
	end process;

	result <= result_buf;
	tvalid <= tvalid_buf;

end;
