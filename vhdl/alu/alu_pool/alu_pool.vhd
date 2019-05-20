library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.head.all;

entity alu_pool is
	generic(
		pool_type: string; -- should be either "max_pool" or "mean_pool"
		width_div_max: integer;
		height_max: integer;
		width_max: integer;
		kernel_max: integer -- the maximum size of the kernel
	);
	port(
		clk: in std_logic; -- clock
		enable: in std_logic; -- enable
		reset: in std_logic; -- synchronous reset
			-- the duration of the reset should be at least twice the clock cycle
		kernel_minus: in ubyte; -- the effective size of the kernel minus one
		height_minus: in ubyte;  -- the height of the image minus one
		width_minus: in ubyte; -- the width of the image minus one
		width_div_minus: in ubyte; -- the width of the image divided by kernel size minus one
		rvalid: in std_logic;
		tvalid: out std_logic; -- the signal indicates whether the output data is tvalid
		data: in val_type; -- the input data stream
		result: out val_type -- the output data stream
	);
end;

architecture arch of alu_pool is

	signal valid_buf: std_logic;
	signal data_buf: val_type;

begin

	alu_pool_h_inst: entity work.alu_pool_h
		generic map(
			pool_type => pool_type,
			width_max => width_max,
			kernel_max => kernel_max
		)
		port map(
			clk => clk,
			enable => enable,
			reset => reset,

			width_minus => width_minus,
			kernel_minus => kernel_minus,

			rvalid => rvalid,
			tvalid => valid_buf,

			data => data,
			result => data_buf
		);

	alu_pool_v_inst: entity work.alu_pool_v
		generic map(
			pool_type => pool_type,
			width_div_max => width_div_max,
			height_max => height_max,
			kernel_max => kernel_max
		)
		port map(
			clk => clk,
			enable => enable,
			reset => reset,

			width_div_minus => width_div_minus,
			height_minus => height_minus,
			kernel_minus => kernel_minus,

			rvalid => valid_buf,
			tvalid => tvalid,

			data => data_buf,
			result => result
		);

end;
