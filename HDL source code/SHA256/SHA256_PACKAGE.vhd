--  ******************************************************************************
--  * File Name          : SHA256_PACKAGE.vhd
--  * Description        : Declarations and types the SHA256 IP core
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


library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.CONSTANTS.all;

package SHA256_PACKAGE is

	type rnd_lut_table_type is array (0 to 63) of std_logic_vector(31 downto 0);
	type block_fifo_type is array (15 downto 0) of std_logic_vector(31 downto 0);
	type state_type is array (0 to 7) of std_logic_vector(31 downto 0);


	component ADDER_GENERIC is
		generic(N : integer := 32);
		port(A : in std_logic_vector(N-1 downto 0);
			 B : in std_logic_vector(N-1 downto 0);
			 S : out std_logic_vector(N-1 downto 0));
	end component;

	component MUX21_GENERIC is 
		generic(N : integer := 32);
		port(A : in std_logic_vector(N-1 downto 0);
			 B : in std_logic_vector(N-1 downto 0);
			 SEL : in std_logic;
			 O : out std_logic_vector(N-1 downto 0));
	end component;

	component REGISTER_GENERIC is
		generic (N : integer := 32);
		port (RST : IN std_logic;
			  CLK : IN std_logic;
			  CE  : IN std_logic; 
			  D   : IN std_logic_vector(N-1 downto 0);
			  Q   : OUT std_logic_vector(N-1 downto 0));
	end component;

	component S0_BLOCK is
		port( X : in std_logic_vector(31 downto 0);
			  O : out std_logic_vector(31 downto 0));
	end component;

	component S1_BLOCK is
		port( X : in std_logic_vector(31 downto 0);
			  O : out std_logic_vector(31 downto 0));
	end component;

	component S2_BLOCK is
		port( X : in std_logic_vector(31 downto 0);
			  O : out std_logic_vector(31 downto 0));
	end component;

	component S3_BLOCK is
		port( X : in std_logic_vector(31 downto 0);
			  O : out std_logic_vector(31 downto 0));
	end component;

	component F0_GATE is
		port( X : in std_logic;
			  Y : in std_logic;
			  Z : in std_logic;
			  O : out std_logic);
	end component;

	component F1_GATE is
		port( X : in std_logic;
			  Y : in std_logic;
			  Z : in std_logic;
			  O : out std_logic);
	end component;

	component RND_LUT is
		port ( STEP_IN : in std_logic_vector(5 downto 0);
			   WORD_OUT : out std_logic_vector(31 downto 0));
	end component;

	component MUX161_16 is
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
	end component;

	component SHA256_CONTROL_UNIT is
		port (  -- EXTERNAL INTERFACE
				CLK : in std_logic;
				RST : in std_logic;
				EN : in std_logic;
				OPCODE : in std_logic_vector(OPCODE_SIZE-1 downto 0);
				ACK : in std_logic;
				I_P : in std_logic;
				WRITE_COMPLETED	: in std_logic;
				READ_COMPLETED : in std_logic;
				BUFF_EN : out std_logic;
				BUFF_RW : out std_logic;
				INTERRUPT : out std_logic;
			   	ERROR : out std_logic;
				-- CONTROL SIGNALS
				LD_ADDRESS : out std_logic;
				RST_ADDRESS : out std_logic;
				ADDRESS_MUX_SEL : out std_logic;
				DATAIN_REG_EN : out std_logic;
				BLOCK_FIFO_WR : out std_logic_vector(1 downto 0);
				BLOCK_FIFO_SH : out std_logic;
				BLOCK_FIFO_MUX_SEL : out std_logic;
				R_REG_EN : out std_logic;
				INC_STEP : out std_logic;
				P01_MUX_SEL : out std_logic;
				P_REG_EN : out std_logic;
				S_STATE_REG_EN : out std_logic_vector(15 downto 0);
				F_STATE_REG_EN : out std_logic;
				STATE_MUX_SEL : out std_logic_vector(3 downto 0);
				DATAOUT_MUX_SEL : out std_logic);
	end component;



end SHA256_PACKAGE;