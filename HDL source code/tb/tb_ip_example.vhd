--  ******************************************************************************
--  * File Name          : FPGA_testbench.vhd
--  * Description        : Testbench for the IP Manager architecture
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
use work.CONSTANTS.all;
use work.ip_example_states.all;

entity FPGA_testbench is
end FPGA_testbench;

architecture test of FPGA_testbench is 

	-- TIME CONSTANTS (COMING FROM SOFTWARE SETTINGS)
	constant HCLK_PERIOD 		 : time    := 5555 ps; -- 180 MHz
	constant PRESCALER			 : integer := 2;
	constant FPGA_CLK_PERIOD	 : time    := HCLK_PERIOD*PRESCALER;
	constant ADDRESS_SETUP_TIME	 : integer := 6;
	constant DATA_SETUP_TIME	 : integer := 6;	
		
	-- CONSTANTS FOR DEFINING CONTROL WORD BITS TO BE WRITTEN IN ROW_0
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

	-- golden result of ip_example
	signal res, golden_res: std_logic_vector(DATA_WIDTH-1 downto 0);
   
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
			--wait for HCLK_PERIOD;
			ne1 <= '1';
			noe <= '1';
			result := data;
			res <= data;
		end read;
		
	begin
		
		wait for HCLK_PERIOD*24; -- random number of cc before starting
		golden_res <= X"FA31" xor X"01F7";
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
		write("000000", OFF & CONF_OPEN_TRANSACTION_POLMODE & "0000001");
		write("000001", x"FA31");
		write("000010", x"01F7");
		write("111111", (others => '0'));
		while result = x"0000" loop
			read("111111");
		end loop;
		read("000011");
		write("000000", OFF & CONF_CLOSE_TRANSACTION_POLMODE & "0000001");
		--------------------------------------------------------------------------------------------------------------
		-- TESTBENCH PROGRAM N. 2 - INTERRUPT MODE TESTING (EXAMPLE CORE)
		--------------------------------------------------------------------------------------------------------------
		--write("000000", OFF & CONF_OPEN_TRANSACTION_INTMODE & "0000001");
		--write("000001", x"FA31");
		--write("000010", x"01F7");
		--write("000000", OFF & CONF_CLOSE_TRANSACTION_INTMODE & "0000001");
		--wait until rising_edge(interrupt);
		--wait until rising_edge(hclk); -- ISR is called synchronously
		--read("000000");
		--write("000000", OFF & CONF_OPEN_TRANSACTION_ACK & "0000001");
		---- let the core necessary time for writing outputs and then read
		--wait for 4*HCLK_PERIOD;
		--read("000011");
		--write("000000", OFF & CONF_CLOSE_TRANSACTION_ACK & "0000001");
		--------------------------------------------------------------------------------------------------------------
		wait;
		
	end process;
end test;
