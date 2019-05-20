library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.head.all;
use work.head_const.all;

entity alu_conv_calc is
	generic(
		kernel_max: integer -- the maximum size of the kernel
	);
	port(
		clk: in std_logic; -- clock
		reset: in std_logic; -- synchronous reset
		enable: in std_logic; -- enable

		fifo_read_enable: in std_logic; -- the signal which enables us to read data from the fifo

			-- the duration of the reset should be at least twice the clock cycle
		kernel_minus: in ubyte; -- the effective size of the kernel minus one
		kernel: in matrix(kernel_max - 1 downto 0,kernel_max - 1 downto 0); -- the kernel
			-- It should be provided during configuration
			-- It can be assumed as static value during calculation

		rvalid: in std_logic;
		mul_valid: out std_logic;

		data: in val_type; -- the input data stream
		result: out val_type -- the output data stream
	);
end;

architecture arch of alu_conv_calc is

	signal mul_valid_buf: std_logic_vector(kernel_max ** 2 - 1 downto 0);
	signal fifo_rvalid: std_logic;
	signal fifo_tready: std_logic;

	signal kernel_limit: ubyte;

	signal data_buf: matrix(kernel_max - 1 downto 0,kernel_max - 1 downto 0);
	signal result_buf: matrix(kernel_max - 1 downto 0,kernel_max - 1 downto 0);
	signal result_in: vector(kernel_max - 1 downto 0);
	signal result_out: vector(kernel_max - 1 downto 0);

	constant fifo_size: integer := (kernel_max - 1) * val_type'length;
	signal fifo_in: signed(fifo_size - 1 downto 0);
	signal fifo_out: signed(fifo_size - 1 downto 0);

begin

	mul_valid <= mul_valid_buf(0);	
	fifo_rvalid <= enable and mul_valid_buf(0);
	fifo_tready <= fifo_read_enable;

	-- boundary of the matrix
	result_in(0) <= (others => '0');
	gen_fifo_out: for i in kernel_max - 1 downto 1 generate
		result_in(i) <= 
			val_type(
				fifo_out(i * val_type'length - 1 downto (i - 1) * val_type'length)
			);
	end generate;

	-- matrix of multipliers
	gen_mul_i: for i in kernel_max - 1 downto 0 generate
		gen_mul_j: for j in kernel_max - 1 downto 0 generate
			mul_calc_inst: entity work.alu_mul
				generic map(
					width => data'length,
					delay => mul_delay
				)
				port map(
					clk => clk,
					reset => reset,
					enable => enable,
					rvalid => rvalid,
					tvalid => mul_valid_buf(i * kernel_max + j),
					data_a => data,
					data_b => kernel(i, j),
					result => data_buf(i, j)
				);
		end generate;
	end generate;

	-- matrix of accumulators
	process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				-- result_buf <= data_buf;
				result_buf <= (others => (others => (others => '0')));
			elsif enable = '1' then
				if mul_valid_buf(0) = '1' then
					for i in kernel_max - 1 downto 0 loop
						result_buf(i,0) <= result_in(i) + data_buf(i,0);
					end loop;
					for i in kernel_max - 1 downto 0 loop
						for j in kernel_max - 1 downto 1 loop
							result_buf(i,j) <= result_buf(i,j - 1) + data_buf(i,j);
						end loop;
					end loop;
				end if;
			end if;
		end if;
	end process;

	fifo_inst: entity work.fifo
		generic map(
			width => fifo_size,
			depth => 16
		)
		port map(
			clk => clk,
			enable => enable,
			reset => reset,
			rvalid => fifo_rvalid,
			rready => open,
			tvalid => open,
			tready => fifo_tready,
			data => fifo_in,
			result => fifo_out
		);

	-- boundary of the matrix
	gen_out: for i in kernel_max - 1 downto 0 generate
		result_out(i) <= result_buf(i, kernel_minus);
	end generate;
	gen_fifo_in: for i in kernel_max - 1 downto 1 generate
		fifo_in(i * val_type'length - 1 downto (i - 1) * val_type'length)
			<= result_out(i - 1);
	end generate;
	result <= result_out(kernel_minus);

end;
