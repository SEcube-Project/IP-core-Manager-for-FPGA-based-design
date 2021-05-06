--  ******************************************************************************
--  * File Name          : S1_BLOCK.vhd
--  * Description        : Component of the SHA256 IP core
--  ******************************************************************************
--  *
--  * Copyright(c) 2016-present Blu5 Group <https://www.blu5group.com>
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

entity S1_BLOCK is
	port( X : in std_logic_vector(31 downto 0);
		  O : out std_logic_vector(31 downto 0));
end S1_BLOCK;

architecture BEHAVIORAL of S1_BLOCK is

	signal ROR17 : std_logic_vector(31 downto 0);
	signal ROR19 : std_logic_vector(31 downto 0);
	signal SHR10 : std_logic_vector(31 downto 0);

begin

	ROR17 <= X(16 downto 0) & X(31 downto 17);
	ROR19 <= X(18 downto 0) & X(31 downto 19);
	SHR10 <= "0000000000" & X(31 downto 10);

	O <= ROR17 xor ROR19 xor SHR10;

end BEHAVIORAL;