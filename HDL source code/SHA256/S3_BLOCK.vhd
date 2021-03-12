/**
  ******************************************************************************
  * File Name          : S3_BLOCK.vhd
  * Description        : Component of the SHA256 IP core
  ******************************************************************************
  *
  * Copyright � 2016-present Blu5 Group <https://www.blu5group.com>
  *
  * This library is free software; you can redistribute it and/or
  * modify it under the terms of the GNU Lesser General Public
  * License as published by the Free Software Foundation; either
  * version 3 of the License, or (at your option) any later version.
  *
  * This library is distributed in the hope that it will be useful,
  * but WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  * Lesser General Public License for more details.
  *
  * You should have received a copy of the GNU Lesser General Public
  * License along with this library; if not, see <https://www.gnu.org/licenses/>.
  *
  ******************************************************************************
  */

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.SHA256_PACKAGE.all;

entity S3_BLOCK is
	port( X : in std_logic_vector(31 downto 0);
		  O : out std_logic_vector(31 downto 0));
end S3_BLOCK;

architecture BEHAVIORAL of S3_BLOCK is

	signal ROR6 : std_logic_vector(31 downto 0);
	signal ROR11 : std_logic_vector(31 downto 0);
	signal ROR25 : std_logic_vector(31 downto 0);

begin

	ROR6 <= X(5 downto 0) & X(31 downto 6);
	ROR11 <= X(10 downto 0) & X(31 downto 11);
	ROR25 <= X(24 downto 0) & X(31 downto 25);

	O <= ROR6 xor ROR11 xor ROR25;

end BEHAVIORAL;