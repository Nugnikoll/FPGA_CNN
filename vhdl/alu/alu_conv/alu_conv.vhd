library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.head.all;
use work.head_const.all;

entity alu_conv is
	generic(
		kernel_max: integer := 4 -- the maximum size of the kernel
		-- note that the default value presented here is small indeed
		-- apply a small value for fear that the compilation eats up lots of time
		-- 		when I just want to test and debug 
		-- a rational value should be provided when this module is invoked
	);
	port(
		clk: in std_logic; -- clock
		enable: in std_logic; -- enable
		reset: in std_logic; -- synchronous reset
			-- the duration of the reset should be at least twice the clock cycle

		kernel_minus: in ubyte := 0; -- the effective size of the kernel minus one
		height_minus: in ubyte; -- the height of the image minus one
		width_minus: in ubyte; -- the width of the image minus one
		kernel: in matrix(kernel_max - 1 downto 0,kernel_max - 1 downto 0); -- the kernel
			-- It should be provided during configuration
			-- It can be assumed as static value during calculation

		rvalid: in std_logic; -- the signal indicates whether the input data is valid
		tvalid: out std_logic; -- the signal indicates whether the output data is valid

		data: in val_type; -- the input data stream
		result: out val_type -- the output data stream
	);
end alu_conv;

architecture arch of alu_conv is

	signal mul_valid: std_logic;
	signal fifo_read_enable: std_logic;

begin

	alu_conv_control_inst: entity work.alu_conv_control
		port map(
			clk => clk,
			enable => enable,
			reset => reset,
			kernel_minus => kernel_minus,
			height_minus => height_minus,
			width_minus => width_minus,
			rvalid => mul_valid,
			fifo_read_enable => fifo_read_enable,
			tvalid => tvalid
		);

	alu_conv_calc_inst: entity work.alu_conv_calc
		generic map(
			kernel_max => kernel_max
		)
		port map(
			clk => clk,
			enable => enable,
			fifo_read_enable => fifo_read_enable,
			reset => reset,
			kernel_minus => kernel_minus,
			kernel => kernel,
			rvalid => rvalid,
			mul_valid => mul_valid,
			data => data,
			result => result
		);

end arch;
