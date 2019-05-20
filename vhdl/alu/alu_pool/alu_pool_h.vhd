library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.head.all;

entity alu_pool_h is
	generic(
		pool_type: string; -- should be either "max_pool" or "mean_pool"
		width_max: integer; -- the maximum size of the image
		kernel_max: integer -- the maximum size of the kernel
	);
	port(
		clk: in std_logic; -- clock
		enable: in std_logic; -- enable
		reset: in std_logic; -- synchronous reset

		width_minus: in ubyte; -- the size of the image minus one
		kernel_minus: in ubyte; -- the size of the kernel minus one

		rvalid: in std_logic;
		tvalid: out std_logic;

		data: in val_type; -- the input data stream
		result: out val_type -- the output data stream
	);
end;

architecture arch of alu_pool_h is

	subtype count_type is integer range width_max - 1 downto 0;
	signal count: count_type;
	subtype count_k_type is integer range kernel_max - 1 downto 0;
	signal count_k: count_k_type;
	signal flag, flag_k: std_logic;
	signal result_buf: val_type;

begin

	flag <= '1' when count = width_minus else '0';
	flag_k <= '1' when count_k = kernel_minus else '0';
	result <= result_buf;

	process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				count <= 0;
				count_k <= 0;
				if pool_type = "mean_pool" then
					result_buf <= (others => '0');
				elsif pool_type = "max_pool" then
					result_buf <= (val_type'length - 1 => '1', others => '0');
				else
					report "unrecogized type of pooling" severity Error;
				end if;
				tvalid <= '0';
			elsif enable = '1' and rvalid = '1' then
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
				tvalid <= flag_k;
				if count = 0 or count_k = 0 then
					result_buf <= data;
				else
					if pool_type = "mean_pool" then
						result_buf <= result_buf + data;
					elsif pool_type  = "max_pool" then
						result_buf <= max(result_buf,data);
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
