--  ******************************************************************************
--  * File Name          : REGISTER_GENERIC.vhd
--  * Description        : Generic register for FPGA developments
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

entity REGISTER_GENERIC is
	generic (N : integer := 32);
	port (RST : IN std_logic;
		  CLK : IN std_logic;
		  CE  : IN std_logic; 
		  D   : IN std_logic_vector(N-1 downto 0);
		  Q   : OUT std_logic_vector(N-1 downto 0));
end REGISTER_GENERIC;

architecture BEHAVIORAL of REGISTER_GENERIC is
begin

	process (RST, CLK, CE, D)
	begin
		if(RST = '1') then
			Q <= (others => '0');
		elsif(CLK'event and CLK = '1') then
			if(CE = '1') then
				Q <= D;
			end if;
		end if;
	end process;

end BEHAVIORAL;