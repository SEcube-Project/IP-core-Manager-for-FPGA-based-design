--  ******************************************************************************
--  * File Name          : IP_EXAMPLE.vhd
--  * Description        : Dummy IP core example for the IP Manager architecture
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
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.CONSTANTS.all;

entity IP_EXAMPLE is
	port(
			clock                   : in std_logic;
			reset 				    : in std_logic;
			data_in 				: in std_logic_vector(DATA_WIDTH-1 downto 0);
			opcode 					: in std_logic_vector(OPCODE_SIZE-1 downto 0);
			enable 					: in std_logic;
			ack 					: in std_logic;
			interrupt_polling		: in std_logic;
			data_out 				: out std_logic_vector(DATA_WIDTH-1 downto 0);
			buffer_enable 			: out std_logic;
			address 				: out std_logic_vector(ADD_WIDTH-1 downto 0);
			rw 						: out std_logic;
			interrupt  				: out std_logic;
			error 					: out std_logic;
			write_completed			: in std_logic;
			read_completed			: in std_logic
		);	
	
end IP_EXAMPLE;

architecture Behavioral of IP_EXAMPLE is

	type Statetype is	(OFF, 
						 WAIT_FIRST_OPERAND,
						 ADDR_FIRST_OPERAND, 
						 READ_FIRST_OPERAND, 
						 WAIT_SECOND_OPERAND, 
						 ADDR_SECOND_OPERAND,
						 READ_SECOND_OPERAND,
						 COMPUTE, 
						 ACK_WAITING, 
						 WAIT_STATUS_CPU,
						 WRITE_RESULT,
						 WRITE_STATUS, 
						 DONE);
	
	signal state : Statetype;
	signal mode  : std_logic; -- interrupt 1 / polling 0
	signal in1   : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal in2   : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal res   : std_logic_vector(DATA_WIDTH-1 downto 0);
	
begin 

	process (clock)
	begin

		if(reset = '1') then
			mode  <= '0';
			in1   <= (others => '0');
			in2   <= (others => '0');
			res   <= (others => '0');
			state <= OFF;
		elsif(rising_edge(clock)) then
			case state is

		
			when OFF =>
				data_out <= (others => '0');
				buffer_enable <= '0';
				address <= (others => '0');
				rw <= '0';
				interrupt <= '0';
				error <= '0';
				if(enable = '1') then
					mode <= interrupt_polling;
					state <= WAIT_FIRST_OPERAND;
				else
					state <= OFF;
				end if;
	
			
			when WAIT_FIRST_OPERAND =>
				if(write_completed = '1') then --if first input has been written...
					buffer_enable <= '1';
					address <= std_logic_vector(to_unsigned(1, ADD_WIDTH));
					data_out <= (others => '0');
					rw <= '0';
					interrupt <= '0';
					error <= '0';
					state <= ADDR_FIRST_OPERAND;
				else
					state <= WAIT_FIRST_OPERAND;
				end if;

			when ADDR_FIRST_OPERAND =>
				state <= READ_FIRST_OPERAND;

			when READ_FIRST_OPERAND =>
				in1 <= data_in;
				data_out <= (others => '0');
				buffer_enable <= '0';
				address <= (others => '0');
				rw <= '0';
				interrupt <= '0';
				error <= '0';
				state <= WAIT_SECOND_OPERAND;


			when WAIT_SECOND_OPERAND =>
				if(write_completed = '1') then --if second input has been written...
					buffer_enable <= '1';
					address <= std_logic_vector(to_unsigned(2, ADD_WIDTH));
					data_out <= (others => '0');
					rw <= '0';
					interrupt <= '0';
					error <= '0';
					state <= ADDR_SECOND_OPERAND;
				else 
					state <= WAIT_SECOND_OPERAND;					
				end if;

			when ADDR_SECOND_OPERAND =>
				state <= READ_SECOND_OPERAND;

			when READ_SECOND_OPERAND =>
				in2 <= data_in;
				data_out <= (others => '0');
				buffer_enable <= '0';
				address <= (others => '0');
				rw <= '0';
				interrupt <= '0';
				error <= '0';
				state <= COMPUTE;

			when COMPUTE =>
				-- dummy task
				res <= in1 xor in2;
				if (mode = '0') then
					data_out <= (others => '0');
					buffer_enable <= '0';
					address <= (others => '0');
					rw <= '0';
					interrupt <= '0';
					error <= '0';
					state <= WAIT_STATUS_CPU;
				else
					data_out <= (others => '0');
					buffer_enable <= '0';
					address <= (others => '0');
					rw <= '0';
					interrupt <= '1';
					error <= '0';
					state <= ACK_WAITING;
				end if;		
			
			
			when WAIT_STATUS_CPU =>
				data_out <= (others => '0');
				buffer_enable <= '0';
				address <= (others => '0');
				rw <= '0';
				interrupt <= '0';
				error <= '0';
				if(write_completed = '1') then
					buffer_enable <= '1';
					rw <= '1';
					address <= std_logic_vector(to_unsigned(3, ADD_WIDTH));
					data_out <= res;
					interrupt <= '0';
					error <= '0';
					state <= WRITE_RESULT;
				else
					state <= WAIT_STATUS_CPU;
				end if;
				
				
			when ACK_WAITING =>
				if(ack = '1' and enable = '1') then 
					data_out <= res;
					buffer_enable <= '1';
					address <= std_logic_vector(to_unsigned(3, ADD_WIDTH));
					rw <= '1';
					interrupt <= '0';
					error <= '0';
					state <= WRITE_RESULT;
				else
					state <= ACK_WAITING;
				end if;
			   

			when WRITE_RESULT => 
				if(mode = '0') then
					buffer_enable <= '1';
					rw <= '1';
					address <= std_logic_vector(to_unsigned(63, ADD_WIDTH));
					data_out <= x"FFFF";
					interrupt <= '0';
					error <= '0';
					state <= WRITE_STATUS;
				else
					data_out <= (others => '0');
					buffer_enable <= '0';
					address <= (others => '0');
					rw <= '0';
					interrupt <= '0';
					error <= '0';
					state <= DONE;
				end if;
			

			when WRITE_STATUS =>
				data_out <= (others => '0');
				buffer_enable <= '0';
				address <= (others => '0');
				rw <= '0';
				interrupt <= '0';
				error <= '0';
				state <= DONE;
			
				
			when DONE =>
				-- before leaving the DONE state, the core must be disabled (it happens when the CPU closes the transaction)
				if(enable = '0') then
					state <= OFF;
				else
					state <= DONE;
				end if;
				
			end case;
		end if;
	end process;

end Behavioral;

