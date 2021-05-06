--  ******************************************************************************
--  * File Name          : ADDER_GENERIC.vhd
--  * Description        : Generic adder for FPGA developments
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

entity ADDER_GENERIC is
	generic(N : integer := 32);
	port(A : in std_logic_vector(N-1 downto 0);
		 B : in std_logic_vector(N-1 downto 0);
		 S : out std_logic_vector(N-1 downto 0));
end ADDER_GENERIC;

architecture BEHAVIORAL of ADDER_GENERIC is
begin
	
	S <= std_logic_vector(unsigned(A) + unsigned(B));

end BEHAVIORAL;