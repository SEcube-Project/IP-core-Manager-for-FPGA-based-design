/**
  ******************************************************************************
  * File Name          : FPGA_testbench.vhd
  * Description        : Testbench for the IP Manager architecture
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
use work.CONSTANTS.all;
use work.SHA256_PACKAGE.all;

entity FPGA_testbench is
end FPGA_testbench;

architecture test of FPGA_testbench is 

	-- TIME CONSTANTS (COMING FROM SETTINGS OF SOFTWARE)
	constant HCLK_PERIOD 		 : time    := 5555 ps; -- 180 MHz
	constant PRESCALER			 : integer := 3;
	constant FPGA_CLK_PERIOD	 : time    := HCLK_PERIOD*PRESCALER;
	constant ADDRESS_SETUP_TIME	 : integer := 6;
	constant DATA_SETUP_TIME	 : integer := 6;	
		
	-- CONSTANTS FOR BETTER DEFINING CONTROL WORD TO BE WRITTEN IN ROW_0
	constant OPCODE_VOID    			    : std_logic_vector(OPCODE_SIZE-1 downto 0) := "000000";
	constant CONF_OPEN_TRANSACTION_INTMODE  : std_logic_vector(2 downto 0) := "101";
	constant CONF_CLOSE_TRANSACTION_INTMODE : std_logic_vector(2 downto 0) := "100";
	constant CONF_OPEN_TRANSACTION_POLMODE  : std_logic_vector(2 downto 0) := "001";
	constant CONF_CLOSE_TRANSACTION_POLMODE : std_logic_vector(2 downto 0) := "000";
	constant CONF_OPEN_TRANSACTION_ACK      : std_logic_vector(2 downto 0) := "111";
	constant CONF_CLOSE_TRANSACTION_ACK     : std_logic_vector(2 downto 0) := "110";
		
	-- FPGA INTERFACE SIGNALS
	signal hclk		 : std_logic := '0';	
	signal fpga_clk  : std_logic := '0';
	signal reset     : std_logic := '0';
	signal data      : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => 'Z');
	signal address   : std_logic_vector(ADD_WIDTH-1 downto 0)  := (others => 'Z');
	signal noe		 : std_logic := '0';
	signal nwe		 : std_logic := '1';
	signal ne1		 : std_logic := '1';
	signal interrupt : std_logic;
   
begin
 
 
 
   UUT: entity work.TOP_ENTITY
   	generic map(
   		ADDSET => ADDRESS_SETUP_TIME/PRESCALER,
   		DATAST => DATA_SETUP_TIME/PRESCALER
   	)
   	port map(
   		cpu_fpga_bus_a   => address,
   		cpu_fpga_bus_d   => data,
   		cpu_fpga_bus_noe => noe,
   		cpu_fpga_bus_nwe => nwe,
   		cpu_fpga_bus_ne1 => ne1,
   		cpu_fpga_clk     => fpga_clk,
   		cpu_fpga_int_n   => interrupt,
   		cpu_fpga_rst     => reset
   	);
 
 
 
   pll_osc : process
   begin
		hclk <= '1';
		wait for HCLK_PERIOD/2;
		hclk <= '0';
		wait for HCLK_PERIOD/2;		
	end process;
	
	
	
	fpga_osc : process
	begin
		fpga_clk <= '1';
		wait for FPGA_CLK_PERIOD/2;
		fpga_clk <= '0';
		wait for FPGA_CLK_PERIOD/2;
	end process;
	
	
	
	reset <= '0', '1' after HCLK_PERIOD*2*PRESCALER, '0' after HCLK_PERIOD*4*PRESCALER;
	
	
	
	stimuli: process
		
		-- RESULT OF THE READING PROCEDURE
		variable result : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
		
		-- R/W PROCEDURES EXECUTED BY THE MASTER (CPU THROUGH FMC) 
		procedure write(w_addr : in std_logic_vector(ADD_WIDTH-1 downto 0);
						w_data : in std_logic_vector(DATA_WIDTH-1 downto 0)) is
		begin
			wait for 15*HCLK_PERIOD;
			ne1 <= '0';
			noe <= '1';
			nwe <= '1';
			address <= w_addr;
			wait for ADDRESS_SETUP_TIME*HCLK_PERIOD;
			nwe <= '0';
			data <= w_data;
			wait for DATA_SETUP_TIME*HCLK_PERIOD;
			nwe <= '1';
			wait for HCLK_PERIOD;
			ne1 <= '1';
			noe <= '0';
		end write;
	
		procedure read(r_addr : in std_logic_vector(ADD_WIDTH-1 downto 0)) is
		begin
			wait for 15*HCLK_PERIOD;
			ne1 <= '0';
			noe <= '1';
			nwe <= '1';
			data <= (others => 'Z');
			address <= r_addr;
			wait for ADDRESS_SETUP_TIME*HCLK_PERIOD;
			noe <= '0'; 
			wait for  DATA_SETUP_TIME*HCLK_PERIOD;
			ne1 <= '1';
			noe <= '1';
			result := data;
		end read;
		
	begin
		
		wait for HCLK_PERIOD*24; -- random number of cc before starting
		--------------------------------------------------------------------------------------------------------------
		--------------------------------------------------------------------------------------------------------------
		-- 												TESTBENCH PROGRAMS

		-- These programs make use of the read()/write() procedures emulating the software  in order to simulate one 
		-- of the possible scenario. Following, multiple of those are presented. Please uncomment JUST ONE AT ONCE 
		-- of the following when simulating. The first two programs are referred to an example adder core, the second
		-- to the SHA256 IP. Please go in TOP_ENTITY.vhd and comment/uncomment the IP referred to the executed 
		-- testbench.
		--------------------------------------------------------------------------------------------------------------
		--------------------------------------------------------------------------------------------------------------
		-- TESTBENCH PROGRAM N. 1 - POLLING MODE TESTING (EXAMPLE CORE)
		--------------------------------------------------------------------------------------------------------------
		--write("000000", OPCODE_VOID & CONF_OPEN_TRANSACTION_POLMODE & "0000001");
		--write("000001", x"FA31");
		--write("000010", x"01F7");
		--write("111111", (others => '0'));
		--while result = x"0000" loop
		--	read("111111");
		--end loop;
		--read("000011");
		--write("000000", OPCODE_VOID & CONF_CLOSE_TRANSACTION_POLMODE & "0000001");
		--------------------------------------------------------------------------------------------------------------
		-- TESTBENCH PROGRAM N. 2 - INTERRUPT MODE TESTING (EXAMPLE CORE)
		--------------------------------------------------------------------------------------------------------------
		--write("000000", OPCODE_VOID & CONF_OPEN_TRANSACTION_INTMODE & "0000001");
		--write("000001", x"FA31");
		--write("000010", x"01F7");
		--write("000000", OPCODE_VOID & CONF_CLOSE_TRANSACTION_INTMODE & "0000001");
		--wait until rising_edge(interrupt);
		--wait until rising_edge(hclk); -- ISR is called syncronously
		--read("000000");
		--write("000000", OPCODE_VOID & CONF_OPEN_TRANSACTION_ACK & "0000001");
		---- let the core necessary time for writing outputs and then read
		--wait for 4*HCLK_PERIOD;
		--read("000011");
		--write("000000", OPCODE_VOID & CONF_CLOSE_TRANSACTION_ACK & "0000001");
		--------------------------------------------------------------------------------------------------------------
		-- TESTBENCH PROGRAM N. 3 - SHA CORE TESTING - POLLING MODE (BE SURE THAT work.SHA256_PACKAGE.all IS DECLARED)
		--------------------------------------------------------------------------------------------------------------
		--write("000000", OPCODE_VOID & CONF_OPEN_TRANSACTION_POLMODE & "0000001");
		---- hash
		--write("000001", x"6A09");
		--write("000010", x"E667");
		--write("000011", x"BB67");
		--write("000100", x"AE85");
		--write("000101", x"3C6E");
		--write("000110", x"F372");
		--write("000111", x"A54F");
		--write("001000", x"F53A");
		--write("001001", x"510E");
		--write("001010", x"527F");
		--write("001011", x"9B05");
		--write("001100", x"688C");
		--write("001101", x"1F83");
		--write("001110", x"D9AB");
		--write("001111", x"5BE0");
		--write("010000", x"CD19");
		---- message
		--write("010001", x"BFA9");
		--write("010010", x"A9E7");
		--write("010011", x"752F");
		--write("010100", x"713E");
		--write("010101", x"66EE");
		--write("010110", x"4FAB");
		--write("010111", x"4115");
		--write("011000", x"49CF");
		--write("011001", x"5FC3");
		--write("011010", x"1F82");
		--write("011011", x"7CD9");
		--write("011100", x"7CB0");
		--write("011101", x"73E6");
		--write("011110", x"B988");
		--write("011111", x"029A");
		--write("100000", x"BC41");
		--write("100001", x"4491");
		--write("100010", x"D52B");
		--write("100011", x"9620");
		--write("100100", x"93C9");
		--write("100101", x"77C8");
		--write("100110", x"FA3C");
		--write("100111", x"97E8");
		--write("101000", x"3E2D");
		--write("101001", x"E081");
		--write("101010", x"96D1");
		--write("101011", x"C91E");
		--write("101100", x"7AAE");
		--write("101101", x"4EBC");
		--write("101110", x"686B");
		--write("101111", x"6E55");
		--write("110000", x"BA98");
		---- reading results
		--write("111111", x"0000");
		--while result = x"0000" loop
		--	read("111111");
		--end loop;
		--write("000000", OPCODE_VOID & CONF_CLOSE_TRANSACTION_POLMODE & "0000001");
		--------------------------------------------------------------------------------------------------------------
		-- TESTBENCH PROGRAM N. 4 - SHA CORE TESTING - INTERRUPT MODE (BE SURE THAT work.SHA256_PACKAGE.all IS DECLARED)
		--------------------------------------------------------------------------------------------------------------
		write("000000", OPCODE_VOID & CONF_OPEN_TRANSACTION_INTMODE & "0000001");
		--hash
		write("000001", x"6A09");
		write("000010", x"E667");
		write("000011", x"BB67");
		write("000100", x"AE85");
		write("000101", x"3C6E");
		write("000110", x"F372");
		write("000111", x"A54F");
		write("001000", x"F53A");
		write("001001", x"510E");
		write("001010", x"527F");
		write("001011", x"9B05");
		write("001100", x"688C");
		write("001101", x"1F83");
		write("001110", x"D9AB");
		write("001111", x"5BE0");
		write("010000", x"CD19");
		-- message
		write("010001", x"BFA9");
		write("010010", x"A9E7");
		write("010011", x"752F");
		write("010100", x"713E");
		write("010101", x"66EE");
		write("010110", x"4FAB");
		write("010111", x"4115");
		write("011000", x"49CF");
		write("011001", x"5FC3");
		write("011010", x"1F82");
		write("011011", x"7CD9");
		write("011100", x"7CB0");
		write("011101", x"73E6");
		write("011110", x"B988");
		write("011111", x"029A");
		write("100000", x"BC41");
		write("100001", x"4491");
		write("100010", x"D52B");
		write("100011", x"9620");
		write("100100", x"93C9");
		write("100101", x"77C8");
		write("100110", x"FA3C");
		write("100111", x"97E8");
		write("101000", x"3E2D");
		write("101001", x"E081");
		write("101010", x"96D1");
		write("101011", x"C91E");
		write("101100", x"7AAE");
		write("101101", x"4EBC");
		write("101110", x"686B");
		write("101111", x"6E55");
		write("110000", x"BA98");
		write("000000", OPCODE_VOID & CONF_CLOSE_TRANSACTION_INTMODE & "0000001");
		wait until rising_edge(interrupt);
		read("000000");
		write("000000", OPCODE_VOID & CONF_OPEN_TRANSACTION_ACK & "0000001");
		-- let the core necessary time for writing outputs and then read
		wait for 60*HCLK_PERIOD; 
		read("000001");
		read("000010");
		read("000011");
		read("000100");
		read("000101");
		read("000110");
		read("000111");
		read("001000");
		read("001001");
		read("001010");
		read("001011");
		read("001100");
		read("001101");
		read("001110");
		read("001111");
		read("010000");
		write("000000", OPCODE_VOID & CONF_CLOSE_TRANSACTION_ACK & "0000001");
		--------------------------------------------------------------------------------------------------------------

		wait;
		
	end process;
end test;
