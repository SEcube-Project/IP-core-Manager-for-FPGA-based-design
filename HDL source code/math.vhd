-- Version 1.1: Leonardo Izzi
-- Basic math functions to calculate exact registers size

library ieee;
use ieee.math_real.all;
use ieee.numeric_std.all;

package math_pack is
	function n_bits (
		x: integer
	) return integer;

	function max (
		a: integer;
		b: integer
	) return integer;
end package math_pack;

package body math_pack is
	function n_bits (
		x: integer
	) return integer is
	begin
		return integer(ceil(log2(real(x))));
	end function n_bits;

	function max (
		a: integer;
		b: integer
	) return integer is
		variable m: integer;
	begin
		if (a > b) then
			m := a;
		else
			m := b;
		end if;
		
		return m;
	end function max;
end package body math_pack;