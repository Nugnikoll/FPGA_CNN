library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.head.all;

entity alu_pool_v is
	generic(
		pool_type: string; -- should be either "max_pool" or "mean_pool"
		width_div_max: integer; -- the maximum of width / kernel_size
		height_max: integer; -- the maximum of height
		kernel_max: integer -- the maximum size of the kernel
	);
	port(
		clk: in std_logic; -- clock
		enable: in std_logic; -- enable
		reset: in std_logic; -- synchronous reset

		width_div_minus: in ubyte; -- int(width / kernel_size) - 1
		height_minus: in ubyte; -- height - 1
		kernel_minus: in ubyte; -- kernel_size - 1

		rvalid: in std_logic;
		tvalid: out std_logic;

		data: in val_type; -- the input data stream
		result: out val_type -- the output data stream
	);
end;

architecture arch of alu_pool_v is

	subtype count_type is integer range height_max - 1 downto 0;
	signal count: count_type;
	subtype count_r_type is integer range width_div_max downto 0;
	signal count_r: count_r_type;
	subtype count_k_type is integer range kernel_max - 1 downto 0;
	signal count_k: count_k_type;
	signal flag, flag_k, flag_r: std_logic;
	signal result_buf: vector(width_div_max - 1 downto 0);
	signal result_next: val_type;

begin

	flag_r <= '1' when count_r = width_div_minus else '0';
	flag <= '1' when count = height_minus else '0';
	flag_k <= '1' when count_k = kernel_minus else '0';

	result_next <= result_buf(width_div_minus);
	result <= result_buf(0);

	process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				count_r <= 0;
				count <= 0;
				count_k <= 0;
				if pool_type = "mean_pool" then
					result_buf <= (others => (others => '0'));
				elsif pool_type = "max_pool" then
					result_buf <= (others => (val_type'length - 1 => '1', others => '0'));
				else
					report "unrecogized type of pooling" severity Error;
				end if;
				tvalid <= '0';
			elsif enable = '1' and rvalid = '1' then
				if flag_r = '1' then
					count_r <= 0;
				else
					count_r <= count_r + 1;
				end if;
				if flag_r = '1' then
					if flag = '1' then
						count <= 0;
						count_k <= 0;
					else
						count <= count + 1;
						if flag_k = '1' then
							count_k <= 0;
						else
							count_k <= count_k + 1;
						end if;
					end if;
				end if;
				tvalid <= flag_k;
				result_buf(result_buf'length - 1 downto 1)
					<= result_buf(result_buf'length - 2 downto 0);
				if count = 0 or count_k = 0 then
					result_buf(0) <= data;
				else
					if pool_type = "mean_pool" then
						result_buf(0) <= result_next + data;
					elsif pool_type  = "max_pool" then
						result_buf(0) <= max(result_next, data);
					else
						report "unrecogized type of pooling" severity Error;
					end if;
				end if;
			else
				tvalid <= '0';
			end if;
		end if;
	end process;

end;
