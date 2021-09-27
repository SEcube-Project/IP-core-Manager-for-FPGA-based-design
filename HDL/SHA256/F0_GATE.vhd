--  ******************************************************************************
--  * File Name          : F0_GATE.vhd
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

entity F0_GATE is
	port( X : in std_logic;
		  Y : in std_logic;
		  Z : in std_logic;
		  O : out std_logic);
end F0_GATE;

architecture LUT of F0_GATE is
begin

	O <= '0' when X = '0' and Y = '0' and Z = '0'
	else '0' when X = '0' and Y = '0' and Z = '1'
	else '0' when X = '0' and Y = '1' and Z = '0'
	else '1' when X = '0' and Y = '1' and Z = '1'
	else '0' when X = '1' and Y = '0' and Z = '0'
	else '1' when X = '1' and Y = '0' and Z = '1'
	else '1' when X = '1' and Y = '1' and Z = '0'
	else '1' when X = '1' and Y = '1' and Z = '1'
	else 'X';

end LUT;