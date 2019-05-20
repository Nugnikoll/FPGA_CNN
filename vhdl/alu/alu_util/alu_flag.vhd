library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_flag is
	generic(
		delay: integer
	);
	port(
		clk: in std_logic; -- clock
		reset: in std_logic; -- synchronous reset
		enable: in std_logic; -- synchronous enable
		rvalid: in std_logic; -- indicate whether the input data is valid
		tvalid: out std_logic -- indicate whether the output data is valid
	);
end;

architecture arch of alu_flag is

	signal flag: std_logic_vector(delay - 1 downto 0);

begin

	process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				flag <= (others => '0');
			elsif enable = '1' then
				flag(0) <= rvalid;
				if flag'length >= 2 then
					flag(flag'length - 1 downto 1) <= flag(flag'length - 2 downto 0);
				end if;
			end if;
		end if;
	end process;

	tvalid <= flag(flag'length - 1);

end;
