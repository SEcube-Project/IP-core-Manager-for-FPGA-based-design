/**
  ******************************************************************************
  * File Name          : MUX161_16.vhd
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

entity MUX161_16 is
	port( I0 : in std_logic_vector(15 downto 0);
		  I1 : in std_logic_vector(15 downto 0);
		  I2 : in std_logic_vector(15 downto 0);
		  I3 : in std_logic_vector(15 downto 0);
		  I4 : in std_logic_vector(15 downto 0);
		  I5 : in std_logic_vector(15 downto 0);
		  I6 : in std_logic_vector(15 downto 0);
		  I7 : in std_logic_vector(15 downto 0);
		  I8 : in std_logic_vector(15 downto 0);
		  I9 : in std_logic_vector(15 downto 0);
		  I10 : in std_logic_vector(15 downto 0);
		  I11 : in std_logic_vector(15 downto 0);
		  I12 : in std_logic_vector(15 downto 0);
		  I13 : in std_logic_vector(15 downto 0);
		  I14 : in std_logic_vector(15 downto 0);
		  I15 : in std_logic_vector(15 downto 0);
		  SEL : in std_logic_vector(3 downto 0);
		  O : out std_logic_vector(15 downto 0));
end MUX161_16;

architecture BEHAVIORAL of MUX161_16 is
begin
	
	with SEL select O <=
		I0  when x"0",
		I1  when x"1",
		I2  when x"2",
		I3  when x"3",
		I4  when x"4",
		I5  when x"5",
		I6  when x"6",
		I7  when x"7",
		I8  when x"8",
		I9  when x"9",
		I10 when x"A",
		I11 when x"B",
		I12 when x"C",
		I13 when x"D",
		I14 when x"E",
		I15 when x"F",
		(others => 'X') when others;

end BEHAVIORAL;
