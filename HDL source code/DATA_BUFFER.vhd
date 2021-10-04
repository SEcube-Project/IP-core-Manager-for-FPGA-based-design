--  ******************************************************************************
--  * File Name          : DATA_BUFFER.vhd
--  * Description        : 64x16bit Data Buffer for the IP Manager architecture
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

-- Version 1.1: Leonardo Izzi
-- Design splitted in 2 processes to distinguish registers from signal
-- Data Buffer no longer uses LUTs to create a memory, EBRs are used
-- Row0 is maintained in a register due to IP Manager's requirements
-- General area and timing optimizations

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.CONSTANTS.all;
use work.math_pack.all;

-- Due to RAM timing ADDSET and DATAST are increased from 2 to 3 clk cycles
entity DATA_BUFFER is
	generic (
			ADDSET : integer := 3;
			DATAST : integer := 3;
			-- Amount of clock cycles passing from when the RAM we is raised to when the data is available on the RAM output
			RAM_CPU_WRITE: integer := 2
		);
	port(	
		clock           	: in std_logic;		
		reset				: in std_logic;				
		row_0		    	: out std_logic_vector(DATA_WIDTH-1 downto 0); -- First line of the buffer. Must be read constantly by the ip manager
		-- CPU INTERFACE
		cpu_data	    	: inout std_logic_vector(DATA_WIDTH-1 downto 0);
		cpu_addr        	: in std_logic_vector(ADD_WIDTH-1 downto 0);
		cpu_noe    			: in std_logic;	
		cpu_nwe    			: in std_logic;		
		cpu_ne1    			: in std_logic;	
		-- IP MANAGER INTERFACE
		ipm_data_in	  		: in std_logic_vector(DATA_WIDTH-1 downto 0);
		ipm_data_out		: out std_logic_vector(DATA_WIDTH-1 downto 0);
		ipm_addr     		: in std_logic_vector(ADD_WIDTH-1 downto 0);
		ipm_rw 				: in std_logic;
		ipm_enable  		: in std_logic;
		cpu_read_completed 	: out std_logic;
		cpu_write_completed : out std_logic
		);
end entity DATA_BUFFER;

architecture BEHAVIOURAL of DATA_BUFFER is
	component buf_mem is
		port (
	        DataInA: in  std_logic_vector(15 downto 0); 
	        DataInB: in  std_logic_vector(15 downto 0); 
	        AddressA: in  std_logic_vector(5 downto 0); 
	        AddressB: in  std_logic_vector(5 downto 0); 
	        ClockA: in  std_logic; 
	        ClockB: in  std_logic; 
	        ClockEnA: in  std_logic; 
	        ClockEnB: in  std_logic; 
	        WrA: in  std_logic; 
	        WrB: in  std_logic; 
	        ResetA: in  std_logic; 
	        ResetB: in  std_logic; 
	        QA: out  std_logic_vector(15 downto 0); 
	        QB: out  std_logic_vector(15 downto 0));
	end component buf_mem;

	-- STATES OF THE FSM OF THE BUFFER
	type data_buffer_state_type is (IDLE, WAIT_ADDSET, MEMORY_OPERATION, WAIT_DATAST_WR, WAIT_DATAST_RD);
	type cpu_write_array is array (0 to RAM_CPU_WRITE-1) of std_logic;

	signal curr_state, next_state : data_buffer_state_type;

	-- Control and status register
	signal curr_row0, next_row0: std_logic_vector(DATA_WIDTH-1 downto 0);

	--  Internal counter used to detect state change during FMC communications
	constant CNT_SIZE : integer := n_bits(max(ADDSET, DATAST));
	signal curr_cnt, next_cnt : std_logic_vector(CNT_SIZE downto 0);
	constant zeros : std_logic_vector(ADD_WIDTH-1 downto 0) := (others => '0'); 

	--  INTERNAL SIGNAL TO TEMPORARY STORE THE ADDRESS COMING FROM THE CPU
	signal curr_address, next_address : std_logic_vector(ADD_WIDTH-1 downto 0);

	-- Drive the RAM WE signal
	signal ipm_mem_we, cpu_mem_we: std_logic;

	-- Memory data out
	signal ipm_mem_data_out, cpu_mem_data_out: std_logic_vector(DATA_WIDTH-1 downto 0);

	-- cpu_write_completed must be delayed to account RAM timing.
	signal curr_cpu_writes_completed, next_cpu_writes_completed: cpu_write_array;

begin
	-- buffer memory instantiation
	mem: buf_mem
		port map (
			DataInA => cpu_data,
			DataInB => ipm_data_in,
			AddressA => curr_address,
			AddressB => ipm_addr,
			ClockA => clock,
			ClockB => clock,
			ClockEnA => '1',
			ClockEnB => '1',
			WrA => cpu_mem_we,
			WrB => ipm_mem_we,
			ResetA => reset,
			ResetB => reset,
			QA => cpu_mem_data_out,
			QB => ipm_mem_data_out
		);

	clk_proc: process(clock)
	begin
		if (reset = '1') then
			curr_state <= IDLE;
			curr_cnt <= (others => '0');
			curr_address <= (others => '0');
			curr_row0 <= (others => '0');
			curr_cpu_writes_completed <= (others => '0');
		elsif (rising_edge(clock)) then
			curr_state <= next_state;
			curr_cnt <= next_cnt;
			curr_address <= next_address;
			curr_row0 <= next_row0;
			curr_cpu_writes_completed <= next_cpu_writes_completed;
		end if;
	end process clk_proc;

	-- cpu_write_completed is delayed to match RAM timing with IP timing
	cpu_write_completed <= curr_cpu_writes_completed(0);

	comblogic: process(curr_state, curr_cnt, curr_address, curr_row0, curr_cpu_writes_completed,
		cpu_data, cpu_addr, cpu_noe, cpu_nwe, cpu_ne1,
		ipm_enable, ipm_rw, ipm_addr, ipm_data_in)
	begin
		-- Default assignments
		next_state <= curr_state;
		next_cnt <= curr_cnt;
		next_address <= curr_address;
		next_row0 <= curr_row0;
		cpu_read_completed <= '0';
		cpu_data <= (others => 'Z');
		ipm_mem_we <= '0';
		cpu_mem_we <= '0';

		for i in 0 to RAM_CPU_WRITE-2 loop
			next_cpu_writes_completed(i) <= curr_cpu_writes_completed(i+1);
		end loop;

		next_cpu_writes_completed(RAM_CPU_WRITE-1) <= '0';

		-- possible writing from any IP
		if (ipm_enable = '1' and ipm_rw = '1') then
			-- if addr is redirect the write to row0
			if (ipm_addr = zeros) then
				next_row0 <= ipm_data_in;
			else
				ipm_mem_we <= '1';
			end if;
		end if;

		case (curr_state) is
			when IDLE =>
				if (cpu_ne1 = '0') then
					-- start of transaction
					next_state <= WAIT_ADDSET;
					next_cnt <= std_logic_vector(to_unsigned(ADDSET-1, CNT_SIZE+1));
				end if;

			-- read the operation's address
			when WAIT_ADDSET => 
				next_cnt <= std_logic_vector(unsigned(curr_cnt) - 1);

				if(curr_cnt = zeros(CNT_SIZE downto 0)) then
					next_address <= cpu_addr;
					next_state <= MEMORY_OPERATION;	
				end if;

			-- determine the operation type
			when MEMORY_OPERATION => 
				if(cpu_nwe = '0') then
					next_state <= WAIT_DATAST_WR;
					next_cnt <= std_logic_vector(to_unsigned(DATAST, CNT_SIZE+1));
				else
					if (curr_address <= zeros) then
						-- the CPU wants to read ipm data
						cpu_data <= curr_row0;
					else
						-- the CPU wants to read ip data
						cpu_data <= cpu_mem_data_out;
					end if;

					next_cnt <= std_logic_vector(to_unsigned(DATAST-1, CNT_SIZE+1));
					next_state <= WAIT_DATAST_RD;
				end if;

			-- write operation
			when WAIT_DATAST_WR => 
				if (curr_cnt /= zeros(CNT_SIZE downto 0)) then
					next_cnt <= std_logic_vector(unsigned(curr_cnt) - 1);
				end if;

				if(curr_cnt = zeros(CNT_SIZE downto 0) and cpu_ne1 = '1') then
					next_cnt <= std_logic_vector(to_unsigned(ADDSET-1, CNT_SIZE+1));
					if (curr_address = zeros) then
						next_row0 <= cpu_data;
					else
						cpu_mem_we <= '1';
					end if;

					-- start cpu_write_completed propagation in the FF chain
					next_cpu_writes_completed(RAM_CPU_WRITE-1) <= '1';
					next_state <= IDLE;
				end if;

			-- read operation
			when WAIT_DATAST_RD =>
				-- cpu_data must be reassigned as in MEMORY_OPERATION here,
				-- otherwise it goes back to Z
				if (curr_address <= zeros) then
					cpu_data <= curr_row0;
				else
					cpu_data <= cpu_mem_data_out;
				end if;

				next_cnt <= std_logic_vector(unsigned(curr_cnt) - 1);

				if(curr_cnt = zeros(CNT_SIZE downto 0)) then
					next_cnt <= std_logic_vector(to_unsigned(ADDSET-1, CNT_SIZE+1));
					-- Unlike the write, this can be sent to the IP straight away
					cpu_read_completed <= '1';
					next_state <= IDLE;
				end if;

			-- something went wrong...
			when others => 
				next_state <= IDLE;
		end case;
	end process comblogic;

	-- row_0 is always assigned to the first word of the buffer  
	row_0 <= curr_row0;
	ipm_data_out <= ipm_mem_data_out;

end architecture BEHAVIOURAL;






