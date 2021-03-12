/**
  ******************************************************************************
  * File Name          : SHA256_TOP.vhd
  * Description        : Top entity of the SHA256 IP core
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

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.CONSTANTS.all;
use work.SHA256_PACKAGE.all;

entity SHA256_TOP is
	port ( CLK : in std_logic;
		   RST : in std_logic;
		   EN : in std_logic;
		   OPCODE : in std_logic_vector(OPCODE_SIZE-1 downto 0);
		   ACK : in std_logic;
		   I_P : in std_logic;
		   WRITE_COMPLETED	: in std_logic;
		   READ_COMPLETED : in std_logic;
		   BUFF_EN : out std_logic;
		   BUFF_RW : out std_logic;
		   ADDRESS : out std_logic_vector(ADD_WIDTH-1 downto 0);
		   INTERRUPT : out std_logic;
		   ERROR : out std_logic;
		   DATAIN : in std_logic_vector(DATA_WIDTH-1 downto 0);
		   DATAOUT : out std_logic_vector(DATA_WIDTH-1 downto 0));
end SHA256_TOP;

architecture STRUCTURAL of SHA256_TOP is

	-- CONTROL SIGNALS
	signal LD_ADDRESS : std_logic;
	signal RST_ADDRESS : std_logic;
	signal ADDRESS_MUX_SEL : std_logic;
	signal DATAIN_REG_EN : std_logic;
	signal BLOCK_FIFO_WR : std_logic_vector(1 downto 0);
	signal BLOCK_FIFO_SH : std_logic;
	signal BLOCK_FIFO_MUX_SEL : std_logic;
	signal R_REG_EN : std_logic;
	signal INC_STEP : std_logic;
	signal P01_MUX_SEL : std_logic;
	signal P_REG_EN : std_logic;
	signal S_STATE_REG_EN : std_logic_vector(15 downto 0);
	signal F_STATE_REG_EN : std_logic;
	signal STATE_MUX_SEL : std_logic_vector(3 downto 0);
	signal DATAOUT_MUX_SEL : std_logic;

	-- DATAPATH SIGNALS
	signal ADDRESS_REG_OUT : std_logic_vector(ADD_WIDTH-1 downto 0);
	signal ADDRESS_ADD_OUT : std_logic_vector(ADD_WIDTH-1 downto 0);
	signal ADDRESS_MUX_OUT : std_logic_vector(ADD_WIDTH-1 downto 0);

	signal DATAIN_REG_OUT : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal BLOCK_FIFO_MUX_OUT : std_logic_vector(31 downto 0);

	signal BLOCK_FIFO_W : block_fifo_type;


	signal R01_S0_OUT : std_logic_vector(31 downto 0);
	signal R01_S1_OUT : std_logic_vector(31 downto 0);
	signal R01_ADD_OUT : std_logic_vector(31 downto 0);
	signal R01_REG_0_OUT : std_logic_vector(31 downto 0);
	signal R01_REG_1_OUT : std_logic_vector(31 downto 0);
	signal R01_REG_2_OUT : std_logic_vector(31 downto 0);

	signal R02_ADD_OUT : std_logic_vector(31 downto 0);
	signal R02_REG_0_OUT : std_logic_vector(31 downto 0);
	signal R02_REG_1_OUT : std_logic_vector(31 downto 0);

	signal R03_ADD_OUT : std_logic_vector(31 downto 0);
	signal R03_REG_OUT : std_logic_vector(31 downto 0);

	signal STEP_REG_OUT : std_logic_vector(5 downto 0);
	signal STEP_INC_OUT : std_logic_vector(5 downto 0);

	signal S_STATE : state_type;

	signal P01_MUX_OUT : state_type;
	signal P01_S2_OUT : std_logic_vector(31 downto 0);
	signal P01_F0_OUT : std_logic_vector(31 downto 0);
	signal P01_S3_OUT : std_logic_vector(31 downto 0);
	signal P01_F1_OUT : std_logic_vector(31 downto 0);
	signal P01_ADD_OUT : std_logic_vector(31 downto 0);
	signal RND_LUT_OUT : std_logic_vector(31 downto 0);
	signal P01_REG_0_OUT : std_logic_vector(31 downto 0);
	signal P01_REG_1_OUT : std_logic_vector(31 downto 0);
	signal P01_REG_2_OUT : std_logic_vector(31 downto 0);
	signal P01_REG_3_OUT : std_logic_vector(31 downto 0);
	signal P01_REG_4_OUT : std_logic_vector(31 downto 0);
	signal P01_REG_5_OUT : std_logic_vector(31 downto 0);
	signal P01_REG_6_OUT : std_logic_vector(31 downto 0);
	signal P01_REG_7_OUT : std_logic_vector(31 downto 0);
	signal P01_REG_8_OUT : std_logic_vector(31 downto 0);
	signal P01_REG_9_OUT : std_logic_vector(31 downto 0);
	signal P01_REG_10_OUT : std_logic_vector(31 downto 0);
	signal P01_REG_11_OUT : std_logic_vector(31 downto 0);
	signal P01_REG_12_OUT : std_logic_vector(31 downto 0);

	signal P02_ADD_0_OUT : std_logic_vector(31 downto 0);
	signal P02_ADD_1_OUT : std_logic_vector(31 downto 0);
	signal P02_ADD_2_OUT : std_logic_vector(31 downto 0);
	signal P02_REG_0_OUT : std_logic_vector(31 downto 0);
	signal P02_REG_1_OUT : std_logic_vector(31 downto 0);
	signal P02_REG_2_OUT : std_logic_vector(31 downto 0);
	signal P02_REG_3_OUT : std_logic_vector(31 downto 0);
	signal P02_REG_4_OUT : std_logic_vector(31 downto 0);
	signal P02_REG_5_OUT : std_logic_vector(31 downto 0);
	signal P02_REG_6_OUT : std_logic_vector(31 downto 0);
	signal P02_REG_7_OUT : std_logic_vector(31 downto 0);
	signal P02_REG_8_OUT : std_logic_vector(31 downto 0);
	signal P02_REG_9_OUT : std_logic_vector(31 downto 0);

	signal P03_ADD_OUT : std_logic_vector(31 downto 0);
	signal P03_REG_0_OUT : std_logic_vector(31 downto 0);
	signal P03_REG_1_OUT : std_logic_vector(31 downto 0);
	signal P03_REG_2_OUT : std_logic_vector(31 downto 0);
	signal P03_REG_3_OUT : std_logic_vector(31 downto 0);
	signal P03_REG_4_OUT : std_logic_vector(31 downto 0);
	signal P03_REG_5_OUT : std_logic_vector(31 downto 0);
	signal P03_REG_6_OUT : std_logic_vector(31 downto 0);
	signal P03_REG_7_OUT : std_logic_vector(31 downto 0);
	signal P03_REG_8_OUT : std_logic_vector(31 downto 0);

	signal P04_ADD_0_OUT : std_logic_vector(31 downto 0);
	signal P04_ADD_1_OUT : std_logic_vector(31 downto 0);
	signal P04_REG_OUT : state_type;


	signal STATE_ADD_OUT : state_type;

	signal F_STATE : state_type;

	signal STATE_MUX_OUT : std_logic_vector(DATA_WIDTH-1 downto 0);

begin

	-- CONTROL UNIT
	CU : SHA256_CONTROL_UNIT port map(CLK,
									  RST,
									  EN,
									  OPCODE,
									  ACK,
									  I_P,
									  WRITE_COMPLETED, 
									  READ_COMPLETED,
									  BUFF_EN,
									  BUFF_RW,
									  INTERRUPT, 
									  ERROR,
									  LD_ADDRESS,
									  RST_ADDRESS,
									  ADDRESS_MUX_SEL,
									  DATAIN_REG_EN,
									  BLOCK_FIFO_WR,
									  BLOCK_FIFO_SH,
									  BLOCK_FIFO_MUX_SEL,
									  R_REG_EN,
									  INC_STEP,
									  P01_MUX_SEL, 
									  P_REG_EN,
									  S_STATE_REG_EN,
									  F_STATE_REG_EN,
									  STATE_MUX_SEL,
									  DATAOUT_MUX_SEL);

	-- ADDRESS CIRCUITRY
	ADDRESS_REG : REGISTER_GENERIC generic map(ADD_WIDTH) port map(RST_ADDRESS, CLK, LD_ADDRESS, ADDRESS_MUX_OUT, ADDRESS_REG_OUT);
	ADDRESS_ADD : ADDER_GENERIC generic map(ADD_WIDTH) port map(ADDRESS_REG_OUT, "000001", ADDRESS_ADD_OUT);
	ADDRESS_MUX : MUX21_GENERIC generic map(ADD_WIDTH) port map(ADDRESS_ADD_OUT, "111111", ADDRESS_MUX_SEL, ADDRESS_MUX_OUT);
	ADDRESS <= ADDRESS_REG_OUT;

	-- INPUT DATA
	DATAIN_REG : REGISTER_GENERIC generic map(DATA_WIDTH) port map(RST, CLK, DATAIN_REG_EN, DATAIN, DATAIN_REG_OUT);


	-- BLOCK FIFO
	BLOCK_FIFO_MUX : MUX21_GENERIC generic map(32) port map(DATAIN_REG_OUT & DATAIN_REG_OUT, 
															R03_REG_OUT, 
															BLOCK_FIFO_MUX_SEL, 
															BLOCK_FIFO_MUX_OUT);
	BLOCK_FIFO_REG15H : REGISTER_GENERIC generic map(DATA_WIDTH) port map(RST, 
																		  CLK, 
																		  BLOCK_FIFO_WR(1), 
																		  BLOCK_FIFO_MUX_OUT(31 downto 16), 
																		  BLOCK_FIFO_W(15)(31 downto 16));
	BLOCK_FIFO_REG15L : REGISTER_GENERIC generic map(DATA_WIDTH) port map(RST, 
																		  CLK, 
																		  BLOCK_FIFO_WR(0), 
																		  BLOCK_FIFO_MUX_OUT(15 downto 0), 
																		  BLOCK_FIFO_W(15)(15 downto 0)); 
	gBLOCK_FIFO_REG : for i in 14 downto 0 generate
		BLOCK_FIFO_REG : REGISTER_GENERIC generic map(32) port map(RST, CLK, BLOCK_FIFO_SH, BLOCK_FIFO_W(i+1), BLOCK_FIFO_W(i));
	end generate; 	


	-- R PIPELINE
	R01_S0 : S0_BLOCK port map(BLOCK_FIFO_W(1), R01_S0_OUT);
	R01_S1 : S1_BLOCK port map(BLOCK_FIFO_W(14), R01_S1_OUT);
	R01_ADD : ADDER_GENERIC generic map(32) port map(BLOCK_FIFO_W(9), BLOCK_FIFO_W(0), R01_ADD_OUT);
	R01_REG_0 : REGISTER_GENERIC generic map(32) port map(RST, CLK, R_REG_EN, R01_S0_OUT, R01_REG_0_OUT);
	R01_REG_1 : REGISTER_GENERIC generic map(32) port map(RST, CLK, R_REG_EN, R01_S1_OUT, R01_REG_1_OUT);
	R01_REG_2 : REGISTER_GENERIC generic map(32) port map(RST, CLK, R_REG_EN, R01_ADD_OUT, R01_REG_2_OUT);

	R02_ADD : ADDER_GENERIC generic map(32) port map(R01_REG_0_OUT, R01_REG_1_OUT, R02_ADD_OUT);
	R02_REG_0 : REGISTER_GENERIC generic map(32) port map(RST, CLK, R_REG_EN, R02_ADD_OUT, R02_REG_0_OUT); 
	R02_REG_1 : REGISTER_GENERIC generic map(32) port map(RST, CLK, R_REG_EN, R01_REG_2_OUT, R02_REG_1_OUT);

	R03_ADD : ADDER_GENERIC generic map(32) port map(R02_REG_0_OUT, R02_REG_1_OUT, R03_ADD_OUT);
	R03_REG : REGISTER_GENERIC generic map(32) port map(RST, CLK, R_REG_EN, R03_ADD_OUT, R03_REG_OUT);


	-- STEP INCREMENT
	STEP_INC : ADDER_GENERIC generic map(6) port map(STEP_REG_OUT, "000001", STEP_INC_OUT); 
	STEP_REG : REGISTER_GENERIC generic map(6) port map(RST, CLK, INC_STEP, STEP_INC_OUT, STEP_REG_OUT);


	-- STARTING STATE REGISTERS
	gS_STATE_REG : for i in 0 to 7 generate
		S_STATE_REG_H : REGISTER_GENERIC generic map(DATA_WIDTH) port map(RST, CLK, S_STATE_REG_EN(2*i), DATAIN, S_STATE(i)(31 downto 16));
		S_STATE_REG_L : REGISTER_GENERIC generic map(DATA_WIDTH) port map(RST, CLK, S_STATE_REG_EN(2*i+1), DATAIN, S_STATE(i)(15 downto 0));
	end generate;


	-- P PIPELINE
	gP01_MUX : for i in 0 to 7 generate
		P01_MUX : MUX21_GENERIC generic map(32) port map(P04_REG_OUT(i), S_STATE(i), P01_MUX_SEL, P01_MUX_OUT(i));
	end generate;
	P01_S2 : S2_BLOCK port map(P01_MUX_OUT(0), P01_S2_OUT);
	gP01_F0 : for i in 31 downto 0 generate
		P01_F0 : F0_GATE port map(P01_MUX_OUT(0)(i), P01_MUX_OUT(1)(i), P01_MUX_OUT(2)(i), P01_F0_OUT(i));
	end generate;
	P01_S3 : S3_BLOCK port map(P01_MUX_OUT(4), P01_S3_OUT);
	gP01_F1 : for i in 31 downto 0 generate
		P01_F1 : F1_GATE port map(P01_MUX_OUT(4)(i), P01_MUX_OUT(5)(i), P01_MUX_OUT(6)(i), P01_F1_OUT(i));
	end generate;
	P01_ADD : ADDER_GENERIC generic map(32) port map(P01_MUX_OUT(7), BLOCK_FIFO_W(0), P01_ADD_OUT);
	RND : RND_LUT port map(STEP_REG_OUT, RND_LUT_OUT);
	P01_REG_0  : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P01_MUX_OUT(0), P01_REG_0_OUT );
	P01_REG_1  : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P01_S2_OUT, P01_REG_1_OUT );
	P01_REG_2  : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P01_MUX_OUT(1), P01_REG_2_OUT );
	P01_REG_3  : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P01_F0_OUT, P01_REG_3_OUT );
	P01_REG_4  : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P01_MUX_OUT(2), P01_REG_4_OUT );
	P01_REG_5  : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P01_MUX_OUT(3), P01_REG_5_OUT );
	P01_REG_6  : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P01_MUX_OUT(4), P01_REG_6_OUT );
	P01_REG_7  : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P01_S3_OUT, P01_REG_7_OUT );
	P01_REG_8  : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P01_MUX_OUT(5), P01_REG_8_OUT );
	P01_REG_9  : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P01_F1_OUT, P01_REG_9_OUT );
	P01_REG_10 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P01_MUX_OUT(6), P01_REG_10_OUT);
	P01_REG_11 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P01_ADD_OUT, P01_REG_11_OUT);
	P01_REG_12 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, RND_LUT_OUT, P01_REG_12_OUT);

	P02_ADD_0 : ADDER_GENERIC generic map(32) port map(P01_REG_1_OUT,  P01_REG_3_OUT,  P02_ADD_0_OUT);
	P02_ADD_1 : ADDER_GENERIC generic map(32) port map(P01_REG_7_OUT,  P01_REG_9_OUT,  P02_ADD_1_OUT);
	P02_ADD_2 : ADDER_GENERIC generic map(32) port map(P01_REG_11_OUT, P01_REG_12_OUT, P02_ADD_2_OUT);
	P02_REG_0 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P01_REG_0_OUT, P02_REG_0_OUT);
	P02_REG_1 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P02_ADD_0_OUT, P02_REG_1_OUT);
	P02_REG_2 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P01_REG_2_OUT, P02_REG_2_OUT);
	P02_REG_3 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P01_REG_4_OUT, P02_REG_3_OUT);
	P02_REG_4 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P01_REG_5_OUT, P02_REG_4_OUT);
	P02_REG_5 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P01_REG_6_OUT, P02_REG_5_OUT);
	P02_REG_6 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P02_ADD_1_OUT, P02_REG_6_OUT);
	P02_REG_7 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P01_REG_8_OUT, P02_REG_7_OUT);
	P02_REG_8 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P01_REG_10_OUT, P02_REG_8_OUT);
	P02_REG_9 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P02_ADD_2_OUT, P02_REG_9_OUT);

	P03_ADD : ADDER_GENERIC generic map(32) port map(P02_REG_6_OUT,  P02_REG_9_OUT,  P03_ADD_OUT);
	P03_REG_0 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P02_REG_0_OUT, P03_REG_0_OUT);
	P03_REG_1 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P02_REG_1_OUT, P03_REG_1_OUT);
	P03_REG_2 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P02_REG_2_OUT, P03_REG_2_OUT);
	P03_REG_3 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P02_REG_3_OUT, P03_REG_3_OUT);
	P03_REG_4 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P02_REG_4_OUT, P03_REG_4_OUT);
	P03_REG_5 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P02_REG_5_OUT, P03_REG_5_OUT);
	P03_REG_6 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P02_REG_7_OUT, P03_REG_6_OUT);
	P03_REG_7 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P02_REG_8_OUT, P03_REG_7_OUT);
	P03_REG_8 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P03_ADD_OUT, P03_REG_8_OUT);

	P04_ADD_0 : ADDER_GENERIC generic map(32) port map(P03_REG_4_OUT, P03_REG_8_OUT, P04_ADD_0_OUT);
	P04_ADD_1 : ADDER_GENERIC generic map(32) port map(P03_REG_1_OUT, P03_REG_8_OUT, P04_ADD_1_OUT);
	P04_REG_0 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P04_ADD_1_OUT, P04_REG_OUT(0));
	P04_REG_1 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P03_REG_0_OUT, P04_REG_OUT(1));
	P04_REG_2 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P03_REG_2_OUT, P04_REG_OUT(2));
	P04_REG_3 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P03_REG_3_OUT, P04_REG_OUT(3));
	P04_REG_4 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P04_ADD_0_OUT, P04_REG_OUT(4));
	P04_REG_5 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P03_REG_5_OUT, P04_REG_OUT(5));
	P04_REG_6 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P03_REG_6_OUT, P04_REG_OUT(6));
	P04_REG_7 : REGISTER_GENERIC generic map(32) port map(RST, CLK, P_REG_EN, P03_REG_7_OUT, P04_REG_OUT(7));


	-- INCREMENT AND FINAL STATE REGISTERS
	gSTATE_ADD : for i in 0 to 7 generate
		STATE_ADD : ADDER_GENERIC generic map(32) port map(P04_REG_OUT(i), S_STATE(i), STATE_ADD_OUT(i));
		F_STATE_REG : REGISTER_GENERIC generic map(32) port map(RST, CLK, F_STATE_REG_EN, STATE_ADD_OUT(i), F_STATE(i));
	end generate;


	-- STATE AND DATAOUT MULTIPLEXERS
	STATE_MUX : MUX161_16 port map(F_STATE(0)(31 downto 16),
							       F_STATE(0)(15 downto 0),
							       F_STATE(1)(31 downto 16),
							       F_STATE(1)(15 downto 0),
							       F_STATE(2)(31 downto 16),
							       F_STATE(2)(15 downto 0),
							       F_STATE(3)(31 downto 16),
							       F_STATE(3)(15 downto 0),
							       F_STATE(4)(31 downto 16),
							       F_STATE(4)(15 downto 0),
							       F_STATE(5)(31 downto 16),
							       F_STATE(5)(15 downto 0),
							       F_STATE(6)(31 downto 16),
							       F_STATE(6)(15 downto 0),
							       F_STATE(7)(31 downto 16),
							       F_STATE(7)(15 downto 0),
							       STATE_MUX_SEL,
							       STATE_MUX_OUT);
	DATAOUT_MUX : MUX21_GENERIC generic map(DATA_WIDTH) port map(STATE_MUX_OUT, x"FFFF", DATAOUT_MUX_SEL, DATAOUT);

end STRUCTURAL;