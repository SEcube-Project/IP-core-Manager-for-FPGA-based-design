--  ******************************************************************************
--  * File Name          : SHA256_CONTROL_UNIT.vhd
--  * Description        : Control unit of the SHA256 IP core
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

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.CONSTANTS.all;
use work.SHA256_PACKAGE.all;

entity SHA256_CONTROL_UNIT is
	port (  -- EXTERNAL INTERFACE
			CLK : in std_logic;
			RST : in std_logic;
			EN : in std_logic;
			OPCODE : in std_logic_vector(OPCODE_SIZE-1 downto 0);
			ACK : in std_logic;
			I_P : in std_logic;
			WRITE_COMPLETED : in std_logic;
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
end SHA256_CONTROL_UNIT;

architecture BEHAVIORAL of SHA256_CONTROL_UNIT is

--STATES OF THE MACHINE---------------------------------------------------------------------------------------------------------------------
	type cu_state_type is (OFF,
						   WAIT_STATE,

						   ADDR_STATE_0H,
						   READ_STATE_0H,
						   ADDR_STATE_0L,
						   READ_STATE_0L,
						   ADDR_STATE_1H,
						   READ_STATE_1H,
						   ADDR_STATE_1L,
						   READ_STATE_1L,
						   ADDR_STATE_2H,
						   READ_STATE_2H,
						   ADDR_STATE_2L,
						   READ_STATE_2L,
						   ADDR_STATE_3H,
						   READ_STATE_3H,
						   ADDR_STATE_3L,
						   READ_STATE_3L,
						   ADDR_STATE_4H,
						   READ_STATE_4H,
						   ADDR_STATE_4L,
						   READ_STATE_4L,
						   ADDR_STATE_5H,
						   READ_STATE_5H,
						   ADDR_STATE_5L,
						   READ_STATE_5L,
						   ADDR_STATE_6H,
						   READ_STATE_6H,
						   ADDR_STATE_6L,
						   READ_STATE_6L,
						   ADDR_STATE_7H,
						   READ_STATE_7H,
						   ADDR_STATE_7L,
						   READ_STATE_7L,

						   LD_ADDR_STATE_0H,
						   LD_ADDR_STATE_0L,
						   LD_ADDR_STATE_1H,
						   LD_ADDR_STATE_1L,
						   LD_ADDR_STATE_2H,
						   LD_ADDR_STATE_2L,
						   LD_ADDR_STATE_3H,
						   LD_ADDR_STATE_3L,
						   LD_ADDR_STATE_4H,
						   LD_ADDR_STATE_4L,
						   LD_ADDR_STATE_5H,
						   LD_ADDR_STATE_5L,
						   LD_ADDR_STATE_6H,
						   LD_ADDR_STATE_6L,
						   LD_ADDR_STATE_7H,
						   LD_ADDR_STATE_7L,

						   ADDR_WORD_HIGH_0,
						   READ_WORD_HIGH_0,
						   ADDR_WORD_LOW_0,
						   READ_WORD_LOW_0,
						   FIFO_IN_WORD_0,
						   ADDR_WORD_HIGH_1,
						   READ_WORD_HIGH_1,
						   ADDR_WORD_LOW_1,
						   READ_WORD_LOW_1,
						   FIFO_IN_WORD_1, 
						   ADDR_WORD_HIGH_2,
						   READ_WORD_HIGH_2,
						   ADDR_WORD_LOW_2,
						   READ_WORD_LOW_2,
						   FIFO_IN_WORD_2,
						   ADDR_WORD_HIGH_3,
						   READ_WORD_HIGH_3,
						   ADDR_WORD_LOW_3,
						   READ_WORD_LOW_3,
						   FIFO_IN_WORD_3,
						   ADDR_WORD_HIGH_4,
						   READ_WORD_HIGH_4,
						   ADDR_WORD_LOW_4,
						   READ_WORD_LOW_4,
						   FIFO_IN_WORD_4,
						   ADDR_WORD_HIGH_5,
						   READ_WORD_HIGH_5,
						   ADDR_WORD_LOW_5,
						   READ_WORD_LOW_5,
						   FIFO_IN_WORD_5,
						   ADDR_WORD_HIGH_6,
						   READ_WORD_HIGH_6,
						   ADDR_WORD_LOW_6,
						   READ_WORD_LOW_6,
						   FIFO_IN_WORD_6,
						   ADDR_WORD_HIGH_7,
						   READ_WORD_HIGH_7,
						   ADDR_WORD_LOW_7,
						   READ_WORD_LOW_7,
						   FIFO_IN_WORD_7,
						   ADDR_WORD_HIGH_8,
						   READ_WORD_HIGH_8,
						   ADDR_WORD_LOW_8,
						   READ_WORD_LOW_8,
						   FIFO_IN_WORD_8,
						   ADDR_WORD_HIGH_9,
						   READ_WORD_HIGH_9,
						   ADDR_WORD_LOW_9,
						   READ_WORD_LOW_9,
						   FIFO_IN_WORD_9,
						   ADDR_WORD_HIGH_10,
						   READ_WORD_HIGH_10,
						   ADDR_WORD_LOW_10,
						   READ_WORD_LOW_10,
						   FIFO_IN_WORD_10,			
						   ADDR_WORD_HIGH_11,
						   READ_WORD_HIGH_11,
						   ADDR_WORD_LOW_11,
						   READ_WORD_LOW_11,
						   FIFO_IN_WORD_11,
						   ADDR_WORD_HIGH_12,
						   READ_WORD_HIGH_12,
						   ADDR_WORD_LOW_12,
						   READ_WORD_LOW_12,
						   FIFO_IN_WORD_12,
						   ADDR_WORD_HIGH_13,
						   READ_WORD_HIGH_13,
						   ADDR_WORD_LOW_13,
						   READ_WORD_LOW_13,
						   FIFO_IN_WORD_13,
						   ADDR_WORD_HIGH_14,
						   READ_WORD_HIGH_14,
						   ADDR_WORD_LOW_14,
						   READ_WORD_LOW_14,
						   FIFO_IN_WORD_14,
						   ADDR_WORD_HIGH_15,
						   READ_WORD_HIGH_15,
						   ADDR_WORD_LOW_15,
						   READ_WORD_LOW_15,
						   FIFO_IN_WORD_15,	


						   LD_ADDR_WORD_HIGH_0,
						    LD_ADDR_WORD_LOW_0,
						   LD_ADDR_WORD_HIGH_1,
						    LD_ADDR_WORD_LOW_1,
						   LD_ADDR_WORD_HIGH_2,
						    LD_ADDR_WORD_LOW_2,
						   LD_ADDR_WORD_HIGH_3,
						    LD_ADDR_WORD_LOW_3,
						   LD_ADDR_WORD_HIGH_4,
						    LD_ADDR_WORD_LOW_4,
						   LD_ADDR_WORD_HIGH_5,
						    LD_ADDR_WORD_LOW_5,
						   LD_ADDR_WORD_HIGH_6,
						    LD_ADDR_WORD_LOW_6,
						   LD_ADDR_WORD_HIGH_7,
						    LD_ADDR_WORD_LOW_7,
						   LD_ADDR_WORD_HIGH_8,
						    LD_ADDR_WORD_LOW_8,
						   LD_ADDR_WORD_HIGH_9,
						    LD_ADDR_WORD_LOW_9,
						   LD_ADDR_WORD_HIGH_10,
						    LD_ADDR_WORD_LOW_10,
						   LD_ADDR_WORD_HIGH_11,
						    LD_ADDR_WORD_LOW_11,
						   LD_ADDR_WORD_HIGH_12,
						    LD_ADDR_WORD_LOW_12,
						   LD_ADDR_WORD_HIGH_13,
						    LD_ADDR_WORD_LOW_13,
						   LD_ADDR_WORD_HIGH_14,
						    LD_ADDR_WORD_LOW_14,
 						   LD_ADDR_WORD_HIGH_15,
						    LD_ADDR_WORD_LOW_15,

						   P01_WORD_0,
						   P02_WORD_0,
						   P03_WORD_0,
						   P04_WORD_0,
						   P01_WORD_1,
						   P02_WORD_1,
						   P03_WORD_1,
						   P04_WORD_1,
						   P01_WORD_2,
						   P02_WORD_2,
						   P03_WORD_2,
						   P04_WORD_2,
						   P01_WORD_3,
						   P02_WORD_3,
						   P03_WORD_3,
						   P04_WORD_3,
						   P01_WORD_4,
						   P02_WORD_4,
						   P03_WORD_4,
						   P04_WORD_4,
						   P01_WORD_5,
						   P02_WORD_5,
						   P03_WORD_5,
						   P04_WORD_5,
						   P01_WORD_6,
						   P02_WORD_6,
						   P03_WORD_6,
						   P04_WORD_6,
						   P01_WORD_7,
						   P02_WORD_7,
						   P03_WORD_7,
						   P04_WORD_7,
						   P01_WORD_8,
						   P02_WORD_8,
						   P03_WORD_8,
						   P04_WORD_8,
						   P01_WORD_9,
						   P02_WORD_9,
						   P03_WORD_9,
						   P04_WORD_9,
						   P01_WORD_10,
						   P02_WORD_10,
						   P03_WORD_10,
						   P04_WORD_10,
						   P01_WORD_11,
						   P02_WORD_11,
						   P03_WORD_11,
						   P04_WORD_11,
						   P01_WORD_12,
						   P02_WORD_12,
						   P03_WORD_12,
						   P04_WORD_12,
						   P01_WORD_13,
						   P02_WORD_13,
						   P03_WORD_13,
						   P04_WORD_13,
						   P01_WORD_14,
						   P02_WORD_14,
						   P03_WORD_14,
						   P04_WORD_14,
						   P01_WORD_15,
						   P02_WORD_15,
						   P03_WORD_15,
						   P04_WORD_15,
						   P01_WORD_16,
						   P02_WORD_16,
						   P03_WORD_16,
						   P04_WORD_16,
						   P01_WORD_17,
						   P02_WORD_17,
						   P03_WORD_17,
						   P04_WORD_17,
						   P01_WORD_18,
						   P02_WORD_18,
						   P03_WORD_18,
						   P04_WORD_18,
						   P01_WORD_19,
						   P02_WORD_19,
						   P03_WORD_19,
						   P04_WORD_19,
						   P01_WORD_20,
						   P02_WORD_20,
						   P03_WORD_20,
						   P04_WORD_20,
						   P01_WORD_21,
						   P02_WORD_21,
						   P03_WORD_21,
						   P04_WORD_21,
						   P01_WORD_22,
						   P02_WORD_22,
						   P03_WORD_22,
						   P04_WORD_22,
						   P01_WORD_23,
						   P02_WORD_23,
						   P03_WORD_23,
						   P04_WORD_23,
						   P01_WORD_24,
						   P02_WORD_24,
						   P03_WORD_24,
						   P04_WORD_24,
						   P01_WORD_25,
						   P02_WORD_25,
						   P03_WORD_25,
						   P04_WORD_25,
						   P01_WORD_26,
						   P02_WORD_26,
						   P03_WORD_26,
						   P04_WORD_26,
						   P01_WORD_27,
						   P02_WORD_27,
						   P03_WORD_27,
						   P04_WORD_27,
						   P01_WORD_28,
						   P02_WORD_28,
						   P03_WORD_28,
						   P04_WORD_28,
						   P01_WORD_29,
						   P02_WORD_29,
						   P03_WORD_29,
						   P04_WORD_29,
						   P01_WORD_30,
						   P02_WORD_30,
						   P03_WORD_30,
						   P04_WORD_30,
						   P01_WORD_31,
						   P02_WORD_31,
						   P03_WORD_31,
						   P04_WORD_31,
						   P01_WORD_32,
						   P02_WORD_32,
						   P03_WORD_32,
						   P04_WORD_32,
						   P01_WORD_33,
						   P02_WORD_33,
						   P03_WORD_33,
						   P04_WORD_33,
						   P01_WORD_34,
						   P02_WORD_34,
						   P03_WORD_34,
						   P04_WORD_34,
						   P01_WORD_35,
						   P02_WORD_35,
						   P03_WORD_35,
						   P04_WORD_35,
						   P01_WORD_36,
						   P02_WORD_36,
						   P03_WORD_36,
						   P04_WORD_36,
						   P01_WORD_37,
						   P02_WORD_37,
						   P03_WORD_37,
						   P04_WORD_37,
						   P01_WORD_38,
						   P02_WORD_38,
						   P03_WORD_38,
						   P04_WORD_38,
						   P01_WORD_39,
						   P02_WORD_39,
						   P03_WORD_39,
						   P04_WORD_39,
						   P01_WORD_40,
						   P02_WORD_40,
						   P03_WORD_40,
						   P04_WORD_40,
						   P01_WORD_41,
						   P02_WORD_41,
						   P03_WORD_41,
						   P04_WORD_41,
						   P01_WORD_42,
						   P02_WORD_42,
						   P03_WORD_42,
						   P04_WORD_42,
						   P01_WORD_43,
						   P02_WORD_43,
						   P03_WORD_43,
						   P04_WORD_43,
						   P01_WORD_44,
						   P02_WORD_44,
						   P03_WORD_44,
						   P04_WORD_44,
						   P01_WORD_45,
						   P02_WORD_45,
						   P03_WORD_45,
						   P04_WORD_45,
						   P01_WORD_46,
						   P02_WORD_46,
						   P03_WORD_46,
						   P04_WORD_46,
						   P01_WORD_47,
						   P02_WORD_47,
						   P03_WORD_47,
						   P04_WORD_47,
						   P01_WORD_48,
						   P02_WORD_48,
						   P03_WORD_48,
						   P04_WORD_48,
						   P01_WORD_49,
						   P02_WORD_49,
						   P03_WORD_49,
						   P04_WORD_49,
						   P01_WORD_50,
						   P02_WORD_50,
						   P03_WORD_50,
						   P04_WORD_50,
						   P01_WORD_51,
						   P02_WORD_51,
						   P03_WORD_51,
						   P04_WORD_51,
						   P01_WORD_52,
						   P02_WORD_52,
						   P03_WORD_52,
						   P04_WORD_52,
						   P01_WORD_53,
						   P02_WORD_53,
						   P03_WORD_53,
						   P04_WORD_53,
						   P01_WORD_54,
						   P02_WORD_54,
						   P03_WORD_54,
						   P04_WORD_54,
						   P01_WORD_55,
						   P02_WORD_55,
						   P03_WORD_55,
						   P04_WORD_55,
						   P01_WORD_56,
						   P02_WORD_56,
						   P03_WORD_56,
						   P04_WORD_56,
						   P01_WORD_57,
						   P02_WORD_57,
						   P03_WORD_57,
						   P04_WORD_57,
						   P01_WORD_58,
						   P02_WORD_58,
						   P03_WORD_58,
						   P04_WORD_58,
						   P01_WORD_59,
						   P02_WORD_59,
						   P03_WORD_59,
						   P04_WORD_59,
						   P01_WORD_60,
						   P02_WORD_60,
						   P03_WORD_60,
						   P04_WORD_60,
						   P01_WORD_61,
						   P02_WORD_61,
						   P03_WORD_61,
						   P04_WORD_61,
						   P01_WORD_62,
						   P02_WORD_62,
						   P03_WORD_62,
						   P04_WORD_62,
						   P01_WORD_63,
						   P02_WORD_63,
						   P03_WORD_63,
						   P04_WORD_63,

						   UPDATE_STATE,
						   WAIT_ACK,

						   LD_ADDR_WRITE,

						   WRITE_STATE_0H,
						   WRITE_STATE_0L,
						   WRITE_STATE_1H,
						   WRITE_STATE_1L,
						   WRITE_STATE_2H,
						   WRITE_STATE_2L,
						   WRITE_STATE_3H,
						   WRITE_STATE_3L,
						   WRITE_STATE_4H,
						   WRITE_STATE_4L,
						   WRITE_STATE_5H,
						   WRITE_STATE_5L,
						   WRITE_STATE_6H,
						   WRITE_STATE_6L,
						   WRITE_STATE_7H,
						   WRITE_STATE_7L,

						   UNLOCK_CPU,
						   WAIT_CLOSE_TRANSACTION); 
	signal STATE : cu_state_type;
--------------------------------------------------------------------------------------------------------------------------------------------
	signal MODE : std_logic;

begin

	-- MAIN FSM PROCESS
	main: process(RST, CLK)
	begin
		if(RST = '1') then
			BUFF_EN            <= '0';
			BUFF_RW            <= '0';
			INTERRUPT 		   <= '0';
			ERROR 			   <= '0';
			LD_ADDRESS         <= '0';
			RST_ADDRESS        <= '1';
			ADDRESS_MUX_SEL    <= '0';
			DATAIN_REG_EN 	   <= '0';
			BLOCK_FIFO_WR 	   <= "00";	
			BLOCK_FIFO_SH      <= '0';
			BLOCK_FIFO_MUX_SEL <= '0'; 
			R_REG_EN 		   <= '0';
			INC_STEP 		   <= '0';
			P01_MUX_SEL 	   <= '0';
			P_REG_EN 		   <= '0';
			S_STATE_REG_EN 	   <= (others => '0');
			F_STATE_REG_EN     <= '0';
			STATE_MUX_SEL      <= (others => '0');
			DATAOUT_MUX_SEL    <= '0';
			STATE 			   <= OFF;

		elsif(CLK'event and CLK = '1') then

			case STATE is 
--OFF---------------------------------------------------------------------------------------------------------------------------------------
				when OFF =>
					RST_ADDRESS <= '0';
					if(EN = '1') then
						MODE         <= I_P;
						STATE        <= WAIT_STATE;
					end if;
--WAIT_STATE--------------------------------------------------------------------------------------------------------------------------------
				when WAIT_STATE =>
					if(WRITE_COMPLETED = '1') then
						ADDRESS_MUX_SEL <= '0';
						LD_ADDRESS 	    <= '1';
						STATE   	    <= LD_ADDR_STATE_0H;
					end if;
--LD_ADDR_STATE_0H--------------------------------------------------------------------------------------------------------------------------
				when LD_ADDR_STATE_0H =>
					BUFF_RW    <= '0';
					BUFF_EN    <= '1';
					LD_ADDRESS <= '0';
					STATE      <= ADDR_STATE_0H;

				when ADDR_STATE_0H =>
					S_STATE_REG_EN <= "0000000000000001";
					STATE          <= READ_STATE_0H;

				when READ_STATE_0H =>
					S_STATE_REG_EN <= "0000000000000000";
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE      <= LD_ADDR_STATE_0L;
					end if;			

				when LD_ADDR_STATE_0L =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_STATE_0L;

				when ADDR_STATE_0L =>
					S_STATE_REG_EN <= "0000000000000010";
					STATE          <= READ_STATE_0L;

				when READ_STATE_0L =>
					S_STATE_REG_EN <= "0000000000000000";
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_STATE_1H;
					end if;			 

				when LD_ADDR_STATE_1H =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_STATE_1H;

				when ADDR_STATE_1H =>
					S_STATE_REG_EN <= "0000000000000100";
					STATE          <= READ_STATE_1H;

				when READ_STATE_1H =>
					S_STATE_REG_EN <= "0000000000000000";
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_STATE_1L;
					end if;			

				when LD_ADDR_STATE_1L =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_STATE_1L;

				when ADDR_STATE_1L =>
					S_STATE_REG_EN <= "0000000000001000";
					STATE          <= READ_STATE_1L;

				when READ_STATE_1L =>
					S_STATE_REG_EN <= "0000000000000000";
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_STATE_2H;
					end if;				

				when LD_ADDR_STATE_2H =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_STATE_2H;

				when ADDR_STATE_2H =>
					S_STATE_REG_EN <= "0000000000010000";
					STATE          <= READ_STATE_2H;

				when READ_STATE_2H =>
					S_STATE_REG_EN <= "0000000000000000";
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_STATE_2L;
					end if;		

				when LD_ADDR_STATE_2L =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_STATE_2L;

				when ADDR_STATE_2L =>
					S_STATE_REG_EN <= "0000000000100000";
					STATE          <= READ_STATE_2L;

				when READ_STATE_2L =>
					S_STATE_REG_EN <= "0000000000000000";
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_STATE_3H;
					end if;	

				when LD_ADDR_STATE_3H =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_STATE_3H;

				when ADDR_STATE_3H =>
					S_STATE_REG_EN <= "0000000001000000";
					STATE          <= READ_STATE_3H;

				when READ_STATE_3H =>
					S_STATE_REG_EN <= "0000000000000000";
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_STATE_3L;
					end if;	

				when LD_ADDR_STATE_3L =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_STATE_3L;

				when ADDR_STATE_3L =>
					S_STATE_REG_EN <= "0000000010000000";
					STATE          <= READ_STATE_3L;

				when READ_STATE_3L =>
					S_STATE_REG_EN <= "0000000000000000";
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_STATE_4H;
					end if;	

				when LD_ADDR_STATE_4H =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_STATE_4H;

				when ADDR_STATE_4H =>
					S_STATE_REG_EN <= "0000000100000000";
					STATE          <= READ_STATE_4H;

				when READ_STATE_4H =>
					S_STATE_REG_EN <= "0000000000000000";
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_STATE_4L;
					end if;	

				when LD_ADDR_STATE_4L =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_STATE_4L;

				when ADDR_STATE_4L =>
					S_STATE_REG_EN <= "0000001000000000";
					STATE          <= READ_STATE_4L;

				when READ_STATE_4L =>
					S_STATE_REG_EN <= "0000000000000000";
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_STATE_5H;
					end if;	

				when LD_ADDR_STATE_5H =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_STATE_5H;

				when ADDR_STATE_5H =>
					S_STATE_REG_EN <= "0000010000000000";
					STATE          <= READ_STATE_5H;

				when READ_STATE_5H =>
					S_STATE_REG_EN <= "0000000000000000";
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_STATE_5L;
					end if;	

				when LD_ADDR_STATE_5L =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_STATE_5L;

				when ADDR_STATE_5L =>
					S_STATE_REG_EN <= "0000100000000000";
					STATE          <= READ_STATE_5L;

				when READ_STATE_5L =>
					S_STATE_REG_EN <= "0000000000000000";
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_STATE_6H;
					end if;	

				when LD_ADDR_STATE_6H =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_STATE_6H;

				when ADDR_STATE_6H =>
					S_STATE_REG_EN <= "0001000000000000";
					STATE          <= READ_STATE_6H;

				when READ_STATE_6H =>
					S_STATE_REG_EN <= "0000000000000000";
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_STATE_6L;
					end if;	

				when LD_ADDR_STATE_6L =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_STATE_6L;

				when ADDR_STATE_6L =>
					S_STATE_REG_EN <= "0010000000000000";
					STATE          <= READ_STATE_6L;

				when READ_STATE_6L =>
					S_STATE_REG_EN <= "0000000000000000";
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_STATE_7H;
					end if;	

				when LD_ADDR_STATE_7H =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_STATE_7H;

				when ADDR_STATE_7H =>
					S_STATE_REG_EN <= "0100000000000000";
					STATE          <= READ_STATE_7H;

				when READ_STATE_7H =>
					S_STATE_REG_EN <= "0000000000000000";
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_STATE_7L;
					end if;	

				when LD_ADDR_STATE_7L =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_STATE_7L;

				when ADDR_STATE_7L =>
					S_STATE_REG_EN <= "1000000000000000";
					STATE          <= READ_STATE_7L;

				when READ_STATE_7L =>
					S_STATE_REG_EN <= "0000000000000000";
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS    <= '1';
						STATE         <= LD_ADDR_WORD_HIGH_0;
					end if;	
--LD_ADDR_WORD_HIGH_0-----------------------------------------------------------------------------------------------------------------------
				when LD_ADDR_WORD_HIGH_0 =>
					DATAIN_REG_EN <= '1';
					LD_ADDRESS    <= '0';
					STATE         <= ADDR_WORD_HIGH_0;

				when ADDR_WORD_HIGH_0 =>
					BLOCK_FIFO_MUX_SEL <= '0';
					BLOCK_FIFO_WR	   <= "10";
					STATE              <= READ_WORD_HIGH_0;

				when READ_WORD_HIGH_0 =>
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_WORD_LOW_0;
					end if;	

				when LD_ADDR_WORD_LOW_0 =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_LOW_0;

				when ADDR_WORD_LOW_0 =>
					BLOCK_FIFO_WR <= "01";
					STATE         <= READ_WORD_LOW_0;

				when READ_WORD_LOW_0 =>
					STATE <= FIFO_IN_WORD_0;

				when FIFO_IN_WORD_0 =>
					BLOCK_FIFO_WR <= "00";
					if(WRITE_COMPLETED = '1') then
						BLOCK_FIFO_SH <= '1';
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_WORD_HIGH_1;
					end if;	

				when LD_ADDR_WORD_HIGH_1 =>
					BLOCK_FIFO_SH <= '0';
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_HIGH_1;

				when ADDR_WORD_HIGH_1 =>
					BLOCK_FIFO_WR <= "10";
					STATE         <= READ_WORD_HIGH_1;

				when READ_WORD_HIGH_1 =>
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_WORD_LOW_1;
					end if;	

				when LD_ADDR_WORD_LOW_1 =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_LOW_1;

				when ADDR_WORD_LOW_1 =>
					BLOCK_FIFO_WR <= "01";
					STATE         <= READ_WORD_LOW_1;

				when READ_WORD_LOW_1 =>
					STATE <= FIFO_IN_WORD_1;

				when FIFO_IN_WORD_1 =>
					BLOCK_FIFO_WR <= "00";
					if(WRITE_COMPLETED = '1') then
						BLOCK_FIFO_SH <= '1';
						LD_ADDRESS    <= '1';
						STATE         <= LD_ADDR_WORD_HIGH_2;
					end if;						

				when LD_ADDR_WORD_HIGH_2 =>
					BLOCK_FIFO_SH <= '0';
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_HIGH_2;

				when ADDR_WORD_HIGH_2 =>
					BLOCK_FIFO_WR <= "10";
					STATE         <= READ_WORD_HIGH_2;

				when READ_WORD_HIGH_2 =>
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_WORD_LOW_2;
					end if;	

				when LD_ADDR_WORD_LOW_2 =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_LOW_2;

				when ADDR_WORD_LOW_2 =>
					BLOCK_FIFO_WR <= "01";
					STATE         <= READ_WORD_LOW_2;

				when READ_WORD_LOW_2 =>
					STATE <= FIFO_IN_WORD_2;

				when FIFO_IN_WORD_2 =>
					BLOCK_FIFO_WR <= "00";
					if(WRITE_COMPLETED = '1') then
						BLOCK_FIFO_SH <= '1';
						LD_ADDRESS    <= '1';
						STATE         <= LD_ADDR_WORD_HIGH_3;
					end if;		

				when LD_ADDR_WORD_HIGH_3 =>
					BLOCK_FIFO_SH <= '0';
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_HIGH_3;

				when ADDR_WORD_HIGH_3 =>
					BLOCK_FIFO_WR <= "10";
					STATE         <= READ_WORD_HIGH_3;

				when READ_WORD_HIGH_3 =>
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_WORD_LOW_3;
					end if;	

				when LD_ADDR_WORD_LOW_3 =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_LOW_3;

				when ADDR_WORD_LOW_3 =>
					BLOCK_FIFO_WR <= "01";
					STATE         <= READ_WORD_LOW_3;

				when READ_WORD_LOW_3 =>
					STATE <= FIFO_IN_WORD_3;

				when FIFO_IN_WORD_3 =>
					BLOCK_FIFO_WR <= "00";
					if(WRITE_COMPLETED = '1') then
						BLOCK_FIFO_SH <= '1';
						LD_ADDRESS    <= '1';
						STATE         <= LD_ADDR_WORD_HIGH_4;
					end if;

				when LD_ADDR_WORD_HIGH_4 =>
					BLOCK_FIFO_SH <= '0';
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_HIGH_4;

				when ADDR_WORD_HIGH_4 =>
					BLOCK_FIFO_WR <= "10";
					STATE         <= READ_WORD_HIGH_4;

				when READ_WORD_HIGH_4 =>
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_WORD_LOW_4;
					end if;	

				when LD_ADDR_WORD_LOW_4 =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_LOW_4;

				when ADDR_WORD_LOW_4 =>
					BLOCK_FIFO_WR <= "01";
					STATE         <= READ_WORD_LOW_4;

				when READ_WORD_LOW_4 =>
					STATE <= FIFO_IN_WORD_4;

				when FIFO_IN_WORD_4 =>
					BLOCK_FIFO_WR <= "00";
					if(WRITE_COMPLETED = '1') then
						BLOCK_FIFO_SH <= '1';
						LD_ADDRESS    <= '1';
						STATE         <= LD_ADDR_WORD_HIGH_5;
					end if;	

				when LD_ADDR_WORD_HIGH_5 =>
					BLOCK_FIFO_SH <= '0';
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_HIGH_5;

				when ADDR_WORD_HIGH_5 =>
					BLOCK_FIFO_WR <= "10";
					STATE         <= READ_WORD_HIGH_5;

				when READ_WORD_HIGH_5 =>
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_WORD_LOW_5;
					end if;	

				when LD_ADDR_WORD_LOW_5 =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_LOW_5;

				when ADDR_WORD_LOW_5 =>
					BLOCK_FIFO_WR <= "01";
					STATE         <= READ_WORD_LOW_5;

				when READ_WORD_LOW_5 =>
					STATE <= FIFO_IN_WORD_5;

				when FIFO_IN_WORD_5 =>
					BLOCK_FIFO_WR <= "00";
					if(WRITE_COMPLETED = '1') then
						BLOCK_FIFO_SH <= '1';
						LD_ADDRESS    <= '1';
						STATE         <= LD_ADDR_WORD_HIGH_6;
					end if;	

				when LD_ADDR_WORD_HIGH_6 =>
					BLOCK_FIFO_SH <= '0';
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_HIGH_6;

				when ADDR_WORD_HIGH_6 =>
					BLOCK_FIFO_WR <= "10";
					STATE         <= READ_WORD_HIGH_6;

				when READ_WORD_HIGH_6 =>
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_WORD_LOW_6;
					end if;	

				when LD_ADDR_WORD_LOW_6 =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_LOW_6;

				when ADDR_WORD_LOW_6 =>
					BLOCK_FIFO_WR <= "01";
					STATE         <= READ_WORD_LOW_6;

				when READ_WORD_LOW_6 =>
					STATE <= FIFO_IN_WORD_6;

				when FIFO_IN_WORD_6 =>
					BLOCK_FIFO_WR <= "00";
					if(WRITE_COMPLETED = '1') then
						BLOCK_FIFO_SH <= '1';
						LD_ADDRESS    <= '1';
						STATE         <= LD_ADDR_WORD_HIGH_7;
					end if;	

				when LD_ADDR_WORD_HIGH_7 =>
					BLOCK_FIFO_SH <= '0';
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_HIGH_7;

				when ADDR_WORD_HIGH_7 =>
					BLOCK_FIFO_WR <= "10";
					STATE         <= READ_WORD_HIGH_7;

				when READ_WORD_HIGH_7 =>
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_WORD_LOW_7;
					end if;	

				when LD_ADDR_WORD_LOW_7 =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_LOW_7;

				when ADDR_WORD_LOW_7 =>
					BLOCK_FIFO_WR <= "01";
					STATE         <= READ_WORD_LOW_7;

				when READ_WORD_LOW_7 =>
					STATE <= FIFO_IN_WORD_7;

				when FIFO_IN_WORD_7 =>
					BLOCK_FIFO_WR <= "00";
					if(WRITE_COMPLETED = '1') then
						BLOCK_FIFO_SH <= '1';
						LD_ADDRESS    <= '1';
						STATE         <= LD_ADDR_WORD_HIGH_8;
					end if;	

				when LD_ADDR_WORD_HIGH_8 =>
					BLOCK_FIFO_SH <= '0';
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_HIGH_8;

				when ADDR_WORD_HIGH_8 =>
					BLOCK_FIFO_WR <= "10";
					STATE         <= READ_WORD_HIGH_8;

				when READ_WORD_HIGH_8 =>
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_WORD_LOW_8;
					end if;	

				when LD_ADDR_WORD_LOW_8 =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_LOW_8;

				when ADDR_WORD_LOW_8 =>
					BLOCK_FIFO_WR <= "01";
					STATE         <= READ_WORD_LOW_8;

				when READ_WORD_LOW_8 =>
					STATE <= FIFO_IN_WORD_8;

				when FIFO_IN_WORD_8 =>
					BLOCK_FIFO_WR <= "00";
					if(WRITE_COMPLETED = '1') then
						BLOCK_FIFO_SH <= '1';
						LD_ADDRESS    <= '1';
						STATE         <= LD_ADDR_WORD_HIGH_9;
					end if;	

				when LD_ADDR_WORD_HIGH_9 =>
					BLOCK_FIFO_SH <= '0';
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_HIGH_9;

				when ADDR_WORD_HIGH_9 =>
					BLOCK_FIFO_WR <= "10";
					STATE         <= READ_WORD_HIGH_9;

				when READ_WORD_HIGH_9 =>
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_WORD_LOW_9;
					end if;	

				when LD_ADDR_WORD_LOW_9 =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_LOW_9;

				when ADDR_WORD_LOW_9 =>
					BLOCK_FIFO_WR <= "01";
					STATE         <= READ_WORD_LOW_9;

				when READ_WORD_LOW_9 =>
					STATE <= FIFO_IN_WORD_9;

				when FIFO_IN_WORD_9 =>
					BLOCK_FIFO_WR <= "00";
					if(WRITE_COMPLETED = '1') then
						BLOCK_FIFO_SH <= '1';
						LD_ADDRESS    <= '1';
						STATE         <= LD_ADDR_WORD_HIGH_10;
					end if;	

				when LD_ADDR_WORD_HIGH_10 =>
					BLOCK_FIFO_SH <= '0';
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_HIGH_10;

				when ADDR_WORD_HIGH_10 =>
					BLOCK_FIFO_WR <= "10";
					STATE         <= READ_WORD_HIGH_10;

				when READ_WORD_HIGH_10 =>
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_WORD_LOW_10;
					end if;	

				when LD_ADDR_WORD_LOW_10 =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_LOW_10;

				when ADDR_WORD_LOW_10 =>
					BLOCK_FIFO_WR <= "01";
					STATE         <= READ_WORD_LOW_10;

				when READ_WORD_LOW_10 =>
					STATE <= FIFO_IN_WORD_10;

				when FIFO_IN_WORD_10 =>
					BLOCK_FIFO_WR <= "00";
					if(WRITE_COMPLETED = '1') then
						BLOCK_FIFO_SH <= '1';
						LD_ADDRESS    <= '1';
						STATE         <= LD_ADDR_WORD_HIGH_11;
					end if;	

				when LD_ADDR_WORD_HIGH_11 =>
					BLOCK_FIFO_SH <= '0';
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_HIGH_11;

				when ADDR_WORD_HIGH_11 =>
					BLOCK_FIFO_WR <= "10";
					STATE         <= READ_WORD_HIGH_11;

				when READ_WORD_HIGH_11 =>
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_WORD_LOW_11;
					end if;	

				when LD_ADDR_WORD_LOW_11 =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_LOW_11;

				when ADDR_WORD_LOW_11 =>
					BLOCK_FIFO_WR <= "01";
					STATE         <= READ_WORD_LOW_11;

				when READ_WORD_LOW_11 =>
					STATE <= FIFO_IN_WORD_11;

				when FIFO_IN_WORD_11 =>
					BLOCK_FIFO_WR <= "00";
					if(WRITE_COMPLETED = '1') then
						BLOCK_FIFO_SH <= '1';
						LD_ADDRESS    <= '1';
						STATE         <= LD_ADDR_WORD_HIGH_12;
					end if;	

				when LD_ADDR_WORD_HIGH_12 =>
					BLOCK_FIFO_SH <= '0';
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_HIGH_12;

				when ADDR_WORD_HIGH_12 =>
					BLOCK_FIFO_WR <= "10";
					STATE         <= READ_WORD_HIGH_12;

				when READ_WORD_HIGH_12 =>
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_WORD_LOW_12;
					end if;	

				when LD_ADDR_WORD_LOW_12 =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_LOW_12;

				when ADDR_WORD_LOW_12 =>
					BLOCK_FIFO_WR <= "01";
					STATE         <= READ_WORD_LOW_12;

				when READ_WORD_LOW_12 =>
					STATE <= FIFO_IN_WORD_12;

				when FIFO_IN_WORD_12 =>
					BLOCK_FIFO_WR <= "00";
					if(WRITE_COMPLETED = '1') then
						BLOCK_FIFO_SH <= '1';
						LD_ADDRESS    <= '1';
						STATE         <= LD_ADDR_WORD_HIGH_13;
					end if;	

				when LD_ADDR_WORD_HIGH_13 =>
					BLOCK_FIFO_SH <= '0';
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_HIGH_13;

				when ADDR_WORD_HIGH_13 =>
					BLOCK_FIFO_WR <= "10";
					STATE         <= READ_WORD_HIGH_13;

				when READ_WORD_HIGH_13 =>
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_WORD_LOW_13;
					end if;	

				when LD_ADDR_WORD_LOW_13 =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_LOW_13;

				when ADDR_WORD_LOW_13 =>
					BLOCK_FIFO_WR <= "01";
					STATE         <= READ_WORD_LOW_13;

				when READ_WORD_LOW_13 =>
					STATE <= FIFO_IN_WORD_13;

				when FIFO_IN_WORD_13 =>
					BLOCK_FIFO_WR <= "00";
					if(WRITE_COMPLETED = '1') then
						BLOCK_FIFO_SH <= '1';
						LD_ADDRESS    <= '1';
						STATE         <= LD_ADDR_WORD_HIGH_14;
					end if;	

				when LD_ADDR_WORD_HIGH_14 =>
					BLOCK_FIFO_SH <= '0';
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_HIGH_14;

				when ADDR_WORD_HIGH_14 =>
					BLOCK_FIFO_WR <= "10";
					STATE         <= READ_WORD_HIGH_14;

				when READ_WORD_HIGH_14 =>
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_WORD_LOW_14;
					end if;	

				when LD_ADDR_WORD_LOW_14 =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_LOW_14;

				when ADDR_WORD_LOW_14 =>
					BLOCK_FIFO_WR <= "01";
					STATE         <= READ_WORD_LOW_14;

				when READ_WORD_LOW_14 =>
					STATE <= FIFO_IN_WORD_14;

				when FIFO_IN_WORD_14 =>
					BLOCK_FIFO_WR <= "00";
					if(WRITE_COMPLETED = '1') then
						BLOCK_FIFO_SH <= '1';
						LD_ADDRESS    <= '1';
						STATE         <= LD_ADDR_WORD_HIGH_15;
					end if;	

				when LD_ADDR_WORD_HIGH_15 =>
					BLOCK_FIFO_SH <= '0';
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_HIGH_15;

				when ADDR_WORD_HIGH_15 =>
					BLOCK_FIFO_WR <= "10";
					STATE         <= READ_WORD_HIGH_15;

				when READ_WORD_HIGH_15 =>
					if(WRITE_COMPLETED = '1') then
						LD_ADDRESS <= '1';
						STATE   <= LD_ADDR_WORD_LOW_15;
					end if;	

				when LD_ADDR_WORD_LOW_15 =>
					LD_ADDRESS <= '0';
					STATE      <= ADDR_WORD_LOW_15;

				when ADDR_WORD_LOW_15 =>
					BLOCK_FIFO_WR <= "01";
					STATE         <= READ_WORD_LOW_15;

				when READ_WORD_LOW_15 =>
					STATE 	 <= FIFO_IN_WORD_15;

				when FIFO_IN_WORD_15 =>
					BLOCK_FIFO_WR <= "00";
					DATAIN_REG_EN <= '0';
					BUFF_EN       <= '0';
					BUFF_RW       <= '0';
					RST_ADDRESS   <= '1';
					R_REG_EN 	  <= '1';
					P_REG_EN 	  <= '1';
					P01_MUX_SEL   <= '1';
					STATE         <= P01_WORD_0;
--P01_WORD_0--------------------------------------------------------------------------------------------------------------------------------
				when P01_WORD_0 =>
					RST_ADDRESS <= '0';
					STATE <= P02_WORD_0;

				when P02_WORD_0 =>
					STATE <= P03_WORD_0;

				when P03_WORD_0 =>
					BLOCK_FIFO_MUX_SEL <= '1';
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_0;

				when P04_WORD_0 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					P01_MUX_SEL   <= '0';
					STATE         <= P01_WORD_1;

				when P01_WORD_1 =>
					STATE <= P02_WORD_1;

				when P02_WORD_1 =>
					STATE <= P03_WORD_1;

				when P03_WORD_1 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_1;

				when P04_WORD_1 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_2;

				when P01_WORD_2 =>
					STATE <= P02_WORD_2;

				when P02_WORD_2 =>
					STATE <= P03_WORD_2;

				when P03_WORD_2 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_2;

				when P04_WORD_2 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_3;

				when P01_WORD_3 =>
					STATE <= P02_WORD_3;

				when P02_WORD_3 =>
					STATE <= P03_WORD_3;

				when P03_WORD_3 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_3;

				when P04_WORD_3 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_4;

				when P01_WORD_4 =>
					STATE <= P02_WORD_4;

				when P02_WORD_4 =>
					STATE <= P03_WORD_4;

				when P03_WORD_4 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_4;

				when P04_WORD_4 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_5;

				when P01_WORD_5 =>
					STATE <= P02_WORD_5;

				when P02_WORD_5 =>
					STATE <= P03_WORD_5;

				when P03_WORD_5 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_5;

				when P04_WORD_5 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_6;

				when P01_WORD_6 =>
					STATE <= P02_WORD_6;

				when P02_WORD_6 =>
					STATE <= P03_WORD_6;

				when P03_WORD_6 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_6;

				when P04_WORD_6 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_7;

				when P01_WORD_7 =>
					STATE <= P02_WORD_7;

				when P02_WORD_7 =>
					STATE <= P03_WORD_7;

				when P03_WORD_7 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_7;

				when P04_WORD_7 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_8;

				when P01_WORD_8 =>
					STATE <= P02_WORD_8;

				when P02_WORD_8 =>
					STATE <= P03_WORD_8;

				when P03_WORD_8 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_8;

				when P04_WORD_8 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_9;

				when P01_WORD_9 =>
					STATE <= P02_WORD_9;

				when P02_WORD_9 =>
					STATE <= P03_WORD_9;

				when P03_WORD_9 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_9;

				when P04_WORD_9 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_10;

				when P01_WORD_10 =>
					STATE <= P02_WORD_10;

				when P02_WORD_10 =>
					STATE <= P03_WORD_10;

				when P03_WORD_10 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_10;

				when P04_WORD_10 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_11;

				when P01_WORD_11 =>
					STATE <= P02_WORD_11;

				when P02_WORD_11 =>
					STATE <= P03_WORD_11;

				when P03_WORD_11 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_11;

				when P04_WORD_11 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_12;

				when P01_WORD_12 =>
					STATE <= P02_WORD_12;

				when P02_WORD_12 =>
					STATE <= P03_WORD_12;

				when P03_WORD_12 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_12;

				when P04_WORD_12 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_13;

				when P01_WORD_13 =>
					STATE <= P02_WORD_13;

				when P02_WORD_13 =>
					STATE <= P03_WORD_13;

				when P03_WORD_13 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_13;

				when P04_WORD_13 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_14;

				when P01_WORD_14 =>
					STATE <= P02_WORD_14;

				when P02_WORD_14 =>
					STATE <= P03_WORD_14;

				when P03_WORD_14 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_14;

				when P04_WORD_14 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_15;

				when P01_WORD_15 =>
					STATE <= P02_WORD_15;

				when P02_WORD_15 =>
					STATE <= P03_WORD_15;

				when P03_WORD_15 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_15;

				when P04_WORD_15 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_16;

				when P01_WORD_16 =>
					STATE <= P02_WORD_16;

				when P02_WORD_16 =>
					STATE <= P03_WORD_16;

				when P03_WORD_16 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_16;

				when P04_WORD_16 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_17;

				when P01_WORD_17 =>
					STATE <= P02_WORD_17;

				when P02_WORD_17 =>
					STATE <= P03_WORD_17;

				when P03_WORD_17 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_17;

				when P04_WORD_17 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_18;

				when P01_WORD_18 =>
					STATE <= P02_WORD_18;

				when P02_WORD_18 =>
					STATE <= P03_WORD_18;

				when P03_WORD_18 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_18;

				when P04_WORD_18 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_19;

				when P01_WORD_19 =>
					STATE <= P02_WORD_19;

				when P02_WORD_19 =>
					STATE <= P03_WORD_19;

				when P03_WORD_19 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_19;

				when P04_WORD_19 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_20;

				when P01_WORD_20 =>
					STATE <= P02_WORD_20;

				when P02_WORD_20 =>
					STATE <= P03_WORD_20;

				when P03_WORD_20 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_20;

				when P04_WORD_20 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_21;

				when P01_WORD_21 =>
					STATE <= P02_WORD_21;

				when P02_WORD_21 =>
					STATE <= P03_WORD_21;

				when P03_WORD_21 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_21;

				when P04_WORD_21 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_22;

				when P01_WORD_22 =>
					STATE <= P02_WORD_22;

				when P02_WORD_22 =>
					STATE <= P03_WORD_22;

				when P03_WORD_22 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_22;

				when P04_WORD_22 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_23;

				when P01_WORD_23 =>
					STATE <= P02_WORD_23;

				when P02_WORD_23 =>
					STATE <= P03_WORD_23;

				when P03_WORD_23 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_23;

				when P04_WORD_23 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_24;

				when P01_WORD_24 =>
					STATE <= P02_WORD_24;

				when P02_WORD_24 =>
					STATE <= P03_WORD_24;

				when P03_WORD_24 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_24;

				when P04_WORD_24 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_25;

				when P01_WORD_25 =>
					STATE <= P02_WORD_25;

				when P02_WORD_25 =>
					STATE <= P03_WORD_25;

				when P03_WORD_25 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_25;

				when P04_WORD_25 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_26;

				when P01_WORD_26 =>
					STATE <= P02_WORD_26;

				when P02_WORD_26 =>
					STATE <= P03_WORD_26;

				when P03_WORD_26 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_26;

				when P04_WORD_26 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_27;

				when P01_WORD_27 =>
					STATE <= P02_WORD_27;

				when P02_WORD_27 =>
					STATE <= P03_WORD_27;

				when P03_WORD_27 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_27;

				when P04_WORD_27 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_28;

				when P01_WORD_28 =>
					STATE <= P02_WORD_28;

				when P02_WORD_28 =>
					STATE <= P03_WORD_28;

				when P03_WORD_28 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_28;

				when P04_WORD_28 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_29;

				when P01_WORD_29 =>
					STATE <= P02_WORD_29;

				when P02_WORD_29 =>
					STATE <= P03_WORD_29;

				when P03_WORD_29 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_29;

				when P04_WORD_29 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_30;

				when P01_WORD_30 =>
					STATE <= P02_WORD_30;

				when P02_WORD_30 =>
					STATE <= P03_WORD_30;

				when P03_WORD_30 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_30;

				when P04_WORD_30 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_31;

				when P01_WORD_31 =>
					STATE <= P02_WORD_31;

				when P02_WORD_31 =>
					STATE <= P03_WORD_31;

				when P03_WORD_31 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_31;

				when P04_WORD_31 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_32;

				when P01_WORD_32 =>
					STATE <= P02_WORD_32;

				when P02_WORD_32 =>
					STATE <= P03_WORD_32;

				when P03_WORD_32 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_32;

				when P04_WORD_32 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					P01_MUX_SEL   <= '0';
					STATE         <= P01_WORD_33;

				when P01_WORD_33 =>
					STATE <= P02_WORD_33;

				when P02_WORD_33 =>
					STATE <= P03_WORD_33;

				when P03_WORD_33 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_33;

				when P04_WORD_33 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_34;

				when P01_WORD_34 =>
					STATE <= P02_WORD_34;

				when P02_WORD_34 =>
					STATE <= P03_WORD_34;

				when P03_WORD_34 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_34;

				when P04_WORD_34 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_35;

				when P01_WORD_35 =>
					STATE <= P02_WORD_35;

				when P02_WORD_35 =>
					STATE <= P03_WORD_35;

				when P03_WORD_35 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_35;

				when P04_WORD_35 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_36;

				when P01_WORD_36 =>
					STATE <= P02_WORD_36;

				when P02_WORD_36 =>
					STATE <= P03_WORD_36;

				when P03_WORD_36 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_36;

				when P04_WORD_36 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_37;

				when P01_WORD_37 =>
					STATE <= P02_WORD_37;

				when P02_WORD_37 =>
					STATE <= P03_WORD_37;

				when P03_WORD_37 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_37;

				when P04_WORD_37 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_38;

				when P01_WORD_38 =>
					STATE <= P02_WORD_38;

				when P02_WORD_38 =>
					STATE <= P03_WORD_38;

				when P03_WORD_38 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_38;

				when P04_WORD_38 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_39;

				when P01_WORD_39 =>
					STATE <= P02_WORD_39;

				when P02_WORD_39 =>
					STATE <= P03_WORD_39;

				when P03_WORD_39 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_39;

				when P04_WORD_39 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_40;

				when P01_WORD_40 =>
					STATE <= P02_WORD_40;

				when P02_WORD_40 =>
					STATE <= P03_WORD_40;

				when P03_WORD_40 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_40;

				when P04_WORD_40 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_41;

				when P01_WORD_41 =>
					STATE <= P02_WORD_41;

				when P02_WORD_41 =>
					STATE <= P03_WORD_41;

				when P03_WORD_41 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_41;

				when P04_WORD_41 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_42;

				when P01_WORD_42 =>
					STATE <= P02_WORD_42;

				when P02_WORD_42 =>
					STATE <= P03_WORD_42;

				when P03_WORD_42 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_42;

				when P04_WORD_42 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_43;

				when P01_WORD_43 =>
					STATE <= P02_WORD_43;

				when P02_WORD_43 =>
					STATE <= P03_WORD_43;

				when P03_WORD_43 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_43;

				when P04_WORD_43 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_44;

				when P01_WORD_44 =>
					STATE <= P02_WORD_44;

				when P02_WORD_44 =>
					STATE <= P03_WORD_44;

				when P03_WORD_44 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_44;

				when P04_WORD_44 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_45;

				when P01_WORD_45 =>
					STATE <= P02_WORD_45;

				when P02_WORD_45 =>
					STATE <= P03_WORD_45;

				when P03_WORD_45 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_45;

				when P04_WORD_45 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_46;

				when P01_WORD_46 =>
					STATE <= P02_WORD_46;

				when P02_WORD_46 =>
					STATE <= P03_WORD_46;

				when P03_WORD_46 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_46;

				when P04_WORD_46 =>
					BLOCK_FIFO_SH <= '0';
					BLOCK_FIFO_WR <= "00";
					INC_STEP      <= '0';
					STATE         <= P01_WORD_47;

				when P01_WORD_47 =>
					STATE <= P02_WORD_47;

				when P02_WORD_47 =>
					STATE <= P03_WORD_47;

				when P03_WORD_47 =>
					BLOCK_FIFO_SH      <= '1';
					BLOCK_FIFO_WR	   <= "11";
					INC_STEP           <= '1';
					R_REG_EN           <= '0';
					STATE 			   <= P04_WORD_47;

				when P04_WORD_47 =>
					BLOCK_FIFO_SH      <= '0';
					BLOCK_FIFO_WR      <= "00";
					BLOCK_FIFO_MUX_SEL <= '0';
					INC_STEP           <= '0';
					STATE              <= P01_WORD_48;

				when P01_WORD_48 =>
					STATE <= P02_WORD_48;

				when P02_WORD_48 =>
					STATE <= P03_WORD_48;

				when P03_WORD_48 =>
					BLOCK_FIFO_SH      <= '1';
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_48;

				when P04_WORD_48 =>
					BLOCK_FIFO_SH <= '0';
					INC_STEP      <= '0';
					STATE         <= P01_WORD_49;

				when P01_WORD_49 =>
					STATE <= P02_WORD_49;

				when P02_WORD_49 =>
					STATE <= P03_WORD_49;

				when P03_WORD_49 =>
					BLOCK_FIFO_SH      <= '1';
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_49;

				when P04_WORD_49 =>
					BLOCK_FIFO_SH <= '0';
					INC_STEP      <= '0';
					STATE         <= P01_WORD_50;

				when P01_WORD_50 =>
					STATE <= P02_WORD_50;

				when P02_WORD_50 =>
					STATE <= P03_WORD_50;

				when P03_WORD_50 =>
					BLOCK_FIFO_SH      <= '1';
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_50;

				when P04_WORD_50 =>
					BLOCK_FIFO_SH <= '0';
					INC_STEP      <= '0';
					STATE         <= P01_WORD_51;

				when P01_WORD_51 =>
					STATE <= P02_WORD_51;

				when P02_WORD_51 =>
					STATE <= P03_WORD_51;

				when P03_WORD_51 =>
					BLOCK_FIFO_SH      <= '1';
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_51;

				when P04_WORD_51 =>
					BLOCK_FIFO_SH <= '0';
					INC_STEP      <= '0';
					STATE         <= P01_WORD_52;

				when P01_WORD_52 =>
					STATE <= P02_WORD_52;

				when P02_WORD_52 =>
					STATE <= P03_WORD_52;

				when P03_WORD_52 =>
					BLOCK_FIFO_SH      <= '1';
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_52;

				when P04_WORD_52 =>
					BLOCK_FIFO_SH <= '0';
					INC_STEP      <= '0';
					STATE         <= P01_WORD_53;

				when P01_WORD_53 =>
					STATE <= P02_WORD_53;

				when P02_WORD_53 =>
					STATE <= P03_WORD_53;

				when P03_WORD_53 =>
					BLOCK_FIFO_SH      <= '1';
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_53;

				when P04_WORD_53 =>
					BLOCK_FIFO_SH <= '0';
					INC_STEP      <= '0';
					STATE         <= P01_WORD_54;

				when P01_WORD_54 =>
					STATE <= P02_WORD_54;

				when P02_WORD_54 =>
					STATE <= P03_WORD_54;

				when P03_WORD_54 =>
					BLOCK_FIFO_SH      <= '1';
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_54;

				when P04_WORD_54 =>
					BLOCK_FIFO_SH <= '0';
					INC_STEP      <= '0';
					STATE         <= P01_WORD_55;

				when P01_WORD_55 =>
					STATE <= P02_WORD_55;

				when P02_WORD_55 =>
					STATE <= P03_WORD_55;

				when P03_WORD_55 =>
					BLOCK_FIFO_SH      <= '1';
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_55;

				when P04_WORD_55 =>
					BLOCK_FIFO_SH <= '0';
					INC_STEP      <= '0';
					STATE         <= P01_WORD_56;

				when P01_WORD_56 =>
					STATE <= P02_WORD_56;

				when P02_WORD_56 =>
					STATE <= P03_WORD_56;

				when P03_WORD_56 =>
					BLOCK_FIFO_SH      <= '1';
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_56;

				when P04_WORD_56 =>
					BLOCK_FIFO_SH <= '0';
					INC_STEP      <= '0';
					STATE         <= P01_WORD_57;

				when P01_WORD_57 =>
					STATE <= P02_WORD_57;

				when P02_WORD_57 =>
					STATE <= P03_WORD_57;

				when P03_WORD_57 =>
					BLOCK_FIFO_SH      <= '1';
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_57;

				when P04_WORD_57 =>
					BLOCK_FIFO_SH <= '0';
					INC_STEP      <= '0';
					STATE         <= P01_WORD_58;

				when P01_WORD_58 =>
					STATE <= P02_WORD_58;

				when P02_WORD_58 =>
					STATE <= P03_WORD_58;

				when P03_WORD_58 =>
					BLOCK_FIFO_SH      <= '1';
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_58;

				when P04_WORD_58 =>
					BLOCK_FIFO_SH <= '0';
					INC_STEP      <= '0';
					STATE         <= P01_WORD_59;

				when P01_WORD_59 =>
					STATE <= P02_WORD_59;

				when P02_WORD_59 =>
					STATE <= P03_WORD_59;

				when P03_WORD_59 =>
					BLOCK_FIFO_SH      <= '1';
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_59;

				when P04_WORD_59 =>
					BLOCK_FIFO_SH <= '0';
					INC_STEP      <= '0';
					STATE         <= P01_WORD_60;

				when P01_WORD_60 =>
					STATE <= P02_WORD_60;

				when P02_WORD_60 =>
					STATE <= P03_WORD_60;

				when P03_WORD_60 =>
					BLOCK_FIFO_SH      <= '1';
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_60;

				when P04_WORD_60 =>
					BLOCK_FIFO_SH <= '0';
					INC_STEP      <= '0';
					STATE         <= P01_WORD_61;

				when P01_WORD_61 =>
					STATE <= P02_WORD_61;

				when P02_WORD_61 =>
					STATE <= P03_WORD_61;

				when P03_WORD_61 =>
					BLOCK_FIFO_SH      <= '1';
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_61;

				when P04_WORD_61 =>
					BLOCK_FIFO_SH <= '0';
					INC_STEP      <= '0';
					STATE         <= P01_WORD_62;

				when P01_WORD_62 =>
					STATE <= P02_WORD_62;

				when P02_WORD_62 =>
					STATE <= P03_WORD_62;

				when P03_WORD_62 =>
					BLOCK_FIFO_SH      <= '1';
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_62;

				when P04_WORD_62 =>
					BLOCK_FIFO_SH <= '0';
					INC_STEP      <= '0';
					STATE         <= P01_WORD_63;

				when P01_WORD_63 =>
					STATE <= P02_WORD_63;

				when P02_WORD_63 =>
					STATE <= P03_WORD_63;

				when P03_WORD_63 =>
					BLOCK_FIFO_SH      <= '1';
					INC_STEP           <= '1';
					STATE 			   <= P04_WORD_63;

				when P04_WORD_63 =>
					BLOCK_FIFO_SH  <= '0';
					INC_STEP       <= '0';
					P_REG_EN       <= '0';
					F_STATE_REG_EN <= '1';
					STATE          <= UPDATE_STATE;
--UPDATE_STATE------------------------------------------------------------------------------------------------------------------------------
				when UPDATE_STATE =>
					F_STATE_REG_EN <= '0';
					if(MODE = '0') then
						STATE_MUX_SEL   <= "0000";
						DATAOUT_MUX_SEL <= '0';
						LD_ADDRESS      <= '1';
						STATE           <= LD_ADDR_WRITE;
					else
						INTERRUPT <= '1';
						STATE 	  <= WAIT_ACK;
					end if;

				when WAIT_ACK =>
					if(EN = '1' and ACK = '1') then
						INTERRUPT       <= '0';
						STATE_MUX_SEL   <= "0000";
						DATAOUT_MUX_SEL <= '0';
					    LD_ADDRESS      <= '1';
						STATE           <= LD_ADDR_WRITE;
					end if;
--LD_ADDR_WRITE-----------------------------------------------------------------------------------------------------------------------------
				when LD_ADDR_WRITE =>
					BUFF_EN <= '1';
					BUFF_RW <= '1';
					STATE   <= WRITE_STATE_0H;

				when WRITE_STATE_0H =>
					STATE_MUX_SEL <= "0001";
					STATE         <= WRITE_STATE_0L;

				when WRITE_STATE_0L =>
					STATE_MUX_SEL <= "0010";
					STATE 		  <= WRITE_STATE_1H;

				when WRITE_STATE_1H =>
					STATE_MUX_SEL <= "0011";
					STATE  		  <= WRITE_STATE_1L;

				when WRITE_STATE_1L =>
					STATE_MUX_SEL <= "0100";
					STATE 		  <= WRITE_STATE_2H;

				when WRITE_STATE_2H =>
					STATE_MUX_SEL <= "0101";
					STATE 		  <= WRITE_STATE_2L;

				when WRITE_STATE_2L =>
					STATE_MUX_SEL <= "0110";
					STATE         <= WRITE_STATE_3H;

				when WRITE_STATE_3H =>
					STATE_MUX_SEL <= "0111";
					STATE         <= WRITE_STATE_3L;

				when WRITE_STATE_3L =>
					STATE_MUX_SEL <= "1000";
					STATE         <= WRITE_STATE_4H;

				when WRITE_STATE_4H =>
					STATE_MUX_SEL <= "1001";
					STATE         <= WRITE_STATE_4L;

				when WRITE_STATE_4L =>
					STATE_MUX_SEL <= "1010";
					STATE         <= WRITE_STATE_5H;

				when WRITE_STATE_5H =>
					STATE_MUX_SEL <= "1011";
					STATE         <= WRITE_STATE_5L;

				when WRITE_STATE_5L =>
					STATE_MUX_SEL <= "1100";
					STATE         <= WRITE_STATE_6H;

				when WRITE_STATE_6H =>
					STATE_MUX_SEL <= "1101";
					STATE         <= WRITE_STATE_6L;

				when WRITE_STATE_6L =>
					STATE_MUX_SEL <= "1110";
					STATE         <= WRITE_STATE_7H;

				when WRITE_STATE_7H =>
					if(MODE = '0') then
						ADDRESS_MUX_SEL <= '1';
					end if;
					STATE_MUX_SEL <= "1111";
					STATE         <= WRITE_STATE_7L;

				when WRITE_STATE_7L =>
					if(MODE = '0') then
						DATAOUT_MUX_SEL <= '1';
						ADDRESS_MUX_SEL <= '0';
						STATE           <= UNLOCK_CPU;
					else
						BUFF_EN         <= '0';
						BUFF_RW         <= '0';
						LD_ADDRESS      <= '0';
						RST_ADDRESS     <= '1';
						STATE_MUX_SEL   <= "0000";
						DATAOUT_MUX_SEL <= '0';
						STATE           <= WAIT_CLOSE_TRANSACTION;
					end if;
--UNLOCK_CPU--------------------------------------------------------------------------------------------------------------------------------
				when UNLOCK_CPU =>
					DATAOUT_MUX_SEL <= '0';
					LD_ADDRESS      <= '0';
					RST_ADDRESS     <= '1';
					BUFF_EN         <= '0';
					BUFF_RW         <= '0';
					DATAOUT_MUX_SEL <= '0';
					STATE 			<= WAIT_CLOSE_TRANSACTION;

				when WAIT_CLOSE_TRANSACTION =>
					if(EN = '0') then
						STATE <= OFF; 
					end if;
--------------------------------------------------------------------------------------------------------------------------------------------
				when others =>
					STATE <= OFF;
			end case;

		end if;

	end process;


end BEHAVIORAL;