--  ******************************************************************************
--  * File Name          : RND_LUT.vhd
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

entity RND_LUT is
	port ( STEP_IN : in std_logic_vector(5 downto 0);
		   WORD_OUT : out std_logic_vector(31 downto 0));
end RND_LUT;

architecture LUT of RND_LUT is

	constant RND_LUT_TABLE : rnd_lut_table_type := (
	x"428A2F98",
	x"71374491",
	x"B5C0FBCF",
	x"E9B5DBA5",
	x"3956C25B",
	x"59F111F1",
	x"923F82A4",
	x"AB1C5ED5",
	x"D807AA98",
	x"12835B01",
	x"243185BE",
	x"550C7DC3",
	x"72BE5D74",
	x"80DEB1FE",
	x"9BDC06A7",
	x"C19BF174",
	x"E49B69C1",
	x"EFBE4786",
	x"0FC19DC6",
	x"240CA1CC",
	x"2DE92C6F",
	x"4A7484AA",
	x"5CB0A9DC",
	x"76F988DA",
	x"983E5152",
	x"A831C66D",
	x"B00327C8",
	x"BF597FC7",
	x"C6E00BF3",
	x"D5A79147",
	x"06CA6351",
	x"14292967",
	x"27B70A85",
	x"2E1B2138",
	x"4D2C6DFC",
	x"53380D13",
	x"650A7354",
	x"766A0ABB",
	x"81C2C92E",
	x"92722C85",
	x"A2BFE8A1",
	x"A81A664B",
	x"C24B8B70",
	x"C76C51A3",
	x"D192E819",
	x"D6990624",
	x"F40E3585",
	x"106AA070",
	x"19A4C116",
	x"1E376C08",
	x"2748774C",
	x"34B0BCB5",
	x"391C0CB3",
	x"4ED8AA4A",
	x"5B9CCA4F",
	x"682E6FF3",
	x"748F82EE",
	x"78A5636F",
	x"84C87814",
	x"8CC70208",
	x"90BEFFFA",
	x"A4506CEB",
	x"BEF9A3F7",
	x"C67178F2");

begin

	WORD_OUT <= RND_LUT_TABLE(to_integer(unsigned(STEP_IN)));

end LUT;