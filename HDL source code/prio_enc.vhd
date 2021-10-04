library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Version 1.1: Leonardo Izzi

-- Priority encoder, MSB is more important than LSB
--
-- For now the implementation is very stupid, it's a behavioral
-- description generating a cascade of mux. It works fine for
-- a small value of N, but for big numbers a faster design
-- should be developed
entity prio_enc is
	generic (
		-- input bit size
		N: integer := 4;
		--output bit size
		M: integer := 2
	);
	port (
		x: in std_logic_vector(N-1 downto 0);
		o: out std_logic_vector(M-1 downto 0)
	);
end entity prio_enc;

architecture behavioral of prio_enc is

begin
	comblogic: process(x)
	begin
		o <= (others => '0');
		for i in 0 to N-1 loop
			if (x(i) = '1') then
				o <= std_logic_vector(to_unsigned(i, M));
			end if;
		end loop;
	end process comblogic;
end architecture behavioral;