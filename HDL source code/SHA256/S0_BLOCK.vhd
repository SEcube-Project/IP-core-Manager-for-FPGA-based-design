--  ******************************************************************************
--  * File Name          : S0_BLOCK.vhd
--  * Description        : Component of the SHA256 IP core
--  ******************************************************************************
--  *
--  * Copyright � 2016-present Blu5 Group <https://www.blu5group.com>
--  *
--  * This library is free software; you can redistribute it and/or
--  * modify it under the terms of the GNU Lesser General Public
--  * License as published by the Free Software Foundation; either
--  * version 3 of the License, or (at your option) any later version.
--  *
--  * This library is distributed in the hope that it will be useful,
--  * but WITHOUT ANY WARRANTY; without even the implied warranty of
--  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
--  * Lesser General Public License for more details.
--  *
--  * You should have received a copy of the GNU Lesser General Public
--  * License along with this library; if not, see <https://www.gnu.org/licenses/>.
--  *
--  ******************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.SHA256_PACKAGE.all;

entity S0_BLOCK is
	port( X : in std_logic_vector(31 downto 0);
		  O : out std_logic_vector(31 downto 0));
end S0_BLOCK;

architecture BEHAVIORAL of S0_BLOCK is

	signal ROR7 : std_logic_vector(31 downto 0);
	signal ROR18 : std_logic_vector(31 downto 0);
	signal SHR3 : std_logic_vector(31 downto 0);

begin

	ROR7 <= X(6 downto 0) & X(31 downto 7);
	ROR18 <= X(17 downto 0) & X(31 downto 18);
	SHR3 <= "000" & X(31 downto 3);

	O <= ROR7 xor ROR18 xor SHR3;

end BEHAVIORAL;