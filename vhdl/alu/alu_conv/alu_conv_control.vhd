library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.head.all;
use work.head_const.all;

entity alu_conv_control is
	port(
		clk: in std_logic; -- clock
		enable: in std_logic; -- enable
		reset: in std_logic; -- synchronous reset

		kernel_minus: in ubyte; -- the effective size of the kernel minus one
		height_minus: in ubyte; -- the height of the image minus one
		width_minus: in ubyte; -- the width of the image minus one

		rvalid: in std_logic; -- the signal indicates whether the input data is rvalid
		tvalid: out std_logic; -- the signal indicates whether the output data is tvalid
		fifo_read_enable: out std_logic -- the signal which enables us to read data from the fifo
	);
end;

architecture arch of alu_conv_control is

	signal count_x: ubyte;
	signal count_y: ubyte;
	signal count_fifo: ubyte;

	signal flag: std_logic;
	signal fifo_read_enable_buf: std_logic;

begin

	flag <= '1' when count_x >= kernel_minus and count_y >= kernel_minus else '0';

	process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				count_x <= 0;
				count_y <= 0;
				count_fifo <= 0;
				tvalid <= '0';
			elsif enable = '1' and rvalid = '1' then
				if count_x = width_minus then
					count_x <= 0;
					if count_y = height_minus then
						count_y <= 0;
					else
						count_y <= count_y + 1;
					end if;
				else
					count_x <= count_x + 1;
				end if;

				tvalid <= flag;

				if fifo_read_enable_buf = '0' then
					count_fifo <= count_fifo + 1;
				end if;
			else
				tvalid <= '0';
			end if;
		end if;
	end process;

	fifo_read_enable_buf <=
		'1' when enable = '1' and rvalid = '1'
			and count_fifo = (width_minus - kernel_minus - fifo_delay) else
		'0';
	fifo_read_enable <= fifo_read_enable_buf;

end;
