--  ******************************************************************************
--  * File Name          : IP_MANAGER.vhd
--  * Description        : IP Manager behavioral description
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
-- Removed unused logic in IDLE state
-- Added states to reduce critical path's length
-- General area and timing optimizations

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.CONSTANTS.all;
use work.math_pack.all;

entity IP_MANAGER is
	port(	
            clock 					: in std_logic;
            reset          			: in std_logic;
            ne1						: in std_logic;
            interrupt       		: out std_logic;
            -- BUFFER INTERFACE		
            buf_data_out    		: out std_logic_vector(DATA_WIDTH-1 downto 0);
            buf_data_in     		: in std_logic_vector(DATA_WIDTH-1 downto 0);            
            buf_addr        		: out std_logic_vector(ADD_WIDTH-1 downto 0);
            buf_rw          		: out std_logic;
            buf_enable      		: out std_logic;
            row_0           		: in std_logic_vector (DATA_WIDTH-1 downto 0);
            cpu_read_completed  	: in std_logic; 
            cpu_write_completed 	: in std_logic; 
            -- IP INTERFACE
            addr_ip         	   : in addr_array;
            data_in_ip      	   : in data_array; 
            data_out_ip     	   : out data_array;                                         
            opcode_ip			   : out opcode_array;
            int_pol_ip			   : out std_logic_vector(NUM_IPS-1 downto 0);
            rw_ip		    	   : in std_logic_vector(NUM_IPS-1 downto 0);    
            buf_enable_ip   	   : in std_logic_vector(NUM_IPS-1 downto 0);    
            enable_ip      		   : out std_logic_vector(NUM_IPS-1 downto 0);
            ack_ip 	        	   : out std_logic_vector(NUM_IPS-1 downto 0);    
            interrupt_ip 		   : in std_logic_vector(NUM_IPS-1 downto 0);
            error_ip			   : in std_logic_vector(NUM_IPS-1 downto 0);
            cpu_read_completed_ip  : out std_logic_vector(NUM_IPS-1 downto 0);
			cpu_write_completed_ip : out std_logic_vector(NUM_IPS-1 downto 0)        	
		);
end entity IP_MANAGER;

architecture BEHAVIOURAL of IP_MANAGER is
	component prio_enc is
		generic (
			-- input bit size
			N: integer := 4;
			--output bit size
			M: integer := 2
		);
		port (
			x: in std_logic_vector(N-1 downto 0);
			o: out std_logic_vector(M-1 downto 0)
		);
	end component prio_enc;

	-- STATE OF THE INTERNAL FSM
	type ip_manager_state_type is (IDLE,
								   SERVE_ERROR,
								   WAIT_ERROR_ACK,
								   SERVE_IRQ,
								   SERVE_ACK,
								   SERVE_TR,
								   MULTIPLEXING,
								   IRQ_FORWARDING,
								   ERROR_SIGNALING,
								   ERROR_SIGNALING_DONE
	);

	-- Determine the size of the registers
	-- It must be at least 2 bits to avoid Lattice complaints about 0 downto 0 vectors 
	constant NUM_IPS_WIDTH : integer := n_bits(max(NUM_IPS, 2));

	-- used for comparison purposes
	constant max_ips : unsigned(NUM_IPS_WIDTH-1 downto 0) := to_unsigned(NUM_IPS, NUM_IPS_WIDTH);

	-- make sure this is set to the biggest constant value!!!!
	constant ZERO_SIZE : integer := DATA_WIDTH;
	
	constant zeros : std_logic_vector(ZERO_SIZE-1 downto 0) := (others => '0');  

	signal curr_state, next_state : ip_manager_state_type;
	
	--If curr_active_ip send to the Data Buffer IP data, otherwise send the IP manager data 
	signal curr_active_ip, next_active_ip : std_logic;
	
	-- Register containing the ID of the active IP 
	signal curr_ip_idx, next_ip_idx : std_logic_vector(NUM_IPS_WIDTH-1 downto 0);

	-- Internal register to store the address written in row_0
	signal curr_row0_addr, next_row0_addr: std_logic_vector(IPADDR_POS-1 downto 0);
	
	-- OUTPUTS TO BUFFER when controlled directly by the manager (see assignment out of the process)
	signal buf_data_out_man : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal buf_addr_man : std_logic_vector(ADD_WIDTH-1 downto 0);
	signal buf_rw_man : std_logic;
    signal buf_enable_man : std_logic;
    
    -- Internal register to save the ID of an IP signaling an error or an interrupt
	signal curr_signaling_ipaddress, next_signaling_ipaddress : std_logic_vector(NUM_IPS_WIDTH-1 downto 0);
	
	-- Internal signal representing the index of the IP reporting an error
    signal error_ip_num: std_logic_vector(NUM_IPS_WIDTH-1 downto 0);

    -- Internal signal representing the index of the IP raising an interrupt
    signal interrupt_ip_num: std_logic_vector(NUM_IPS_WIDTH-1 downto 0);

    -- Internal register used to not raise errors repeatedly before they have been ACKed.
    signal curr_error_raised, next_error_raised: std_logic;

    -- Internal register used to not raise interrupts repeatedly.
    signal curr_interrupt_raised, next_interrupt_raised: std_logic;

    -- Register maintaining the state of the interrupt line
    signal curr_interrupt, next_interrupt: std_logic;

    -- Internal signals used to store row0 configuration
    signal curr_addr_ip, next_addr_ip: std_logic_vector(ADD_WIDTH-1 downto 0);
    signal curr_opcode_ip, next_opcode_ip: std_logic_vector(OPCODE_SIZE-1 downto 0);
    signal curr_int_pol_ip, next_int_pol_ip: std_logic;
    signal curr_ack_ip, next_ack_ip: std_logic;


begin
	error_prio_enc: prio_enc
		generic map (
			N => NUM_IPS,
			M => NUM_IPS_WIDTH
		)
		port map (
			x => error_ip,
			o => error_ip_num
		);

	interrupt_prio_enc: prio_enc
		generic map (
			N => NUM_IPS,
			M => NUM_IPS_WIDTH
		)
		port map (
			x => interrupt_ip,
			o => interrupt_ip_num
		);

	state_reg: process(clock)
	begin
		if (reset = '1') then
			-- internals
			curr_state <= IDLE;
			curr_active_ip <= '0';
			curr_ip_idx <= (others => '0');
			curr_row0_addr <= (others => '0');
			curr_signaling_ipaddress <= (others => '0');
			curr_error_raised <= '0';
			curr_interrupt_raised <= '0';
			curr_interrupt <= '0';

			curr_addr_ip <= (others => '0');
			curr_opcode_ip <=(others => '0');
			curr_int_pol_ip <= '0';
			curr_ack_ip <= '0';
		elsif (rising_edge(clock)) then
			curr_state <= next_state;
			curr_active_ip <= next_active_ip;
			curr_ip_idx <= next_ip_idx;
			curr_row0_addr <= next_row0_addr;
			curr_signaling_ipaddress <= next_signaling_ipaddress;
			curr_error_raised <= next_error_raised;
			curr_interrupt_raised <= next_interrupt_raised;
			curr_interrupt <= next_interrupt;

			curr_addr_ip <= next_addr_ip;
			curr_opcode_ip <= next_opcode_ip;
			curr_int_pol_ip <= next_int_pol_ip;
			curr_ack_ip <= next_ack_ip;
		end if;
	end process state_reg;

	interrupt <= curr_interrupt;

	-- multiplexing interface between IPs and Data Buffer
	buf_data_out <= data_in_ip(to_integer(unsigned(curr_ip_idx))) when curr_active_ip /= '0' else buf_data_out_man;
	buf_addr <= addr_ip(to_integer(unsigned(curr_ip_idx))) when curr_active_ip /= '0' else buf_addr_man;
	buf_rw <= rw_ip(to_integer(unsigned(curr_ip_idx))) when curr_active_ip /= '0' else buf_rw_man;
	buf_enable <= buf_enable_ip(to_integer(unsigned(curr_ip_idx))) when curr_active_ip /= '0' else buf_enable_man;
	
	comblogic: process(curr_state, curr_active_ip, curr_ip_idx, curr_row0_addr, curr_signaling_ipaddress,
					   curr_error_raised, curr_interrupt_raised, curr_interrupt,
					   curr_opcode_ip, curr_int_pol_ip, curr_ack_ip,
					   ne1,
					   buf_data_in, row_0, cpu_read_completed, cpu_write_completed,
					   addr_ip, data_in_ip, rw_ip, buf_enable_ip, interrupt_ip, error_ip,
					   error_ip_num, interrupt_ip_num)
	begin
		-- default assignments
		next_state <= curr_state;
		next_active_ip <= curr_active_ip;
		next_ip_idx <= curr_ip_idx;
		next_row0_addr <= curr_row0_addr;
		next_signaling_ipaddress <= curr_signaling_ipaddress;
		next_error_raised <= curr_error_raised;
		next_interrupt_raised <= curr_interrupt_raised;

		next_addr_ip <= curr_addr_ip;
		next_opcode_ip <= curr_opcode_ip;
		next_int_pol_ip <= curr_int_pol_ip;
		next_ack_ip <= curr_ack_ip;

		buf_data_out_man <= (others => '0');
		buf_addr_man <= (others => '0');
		buf_enable_man <= '0';
		buf_rw_man <= '0';

		next_interrupt <= curr_interrupt;

		data_out_ip <= (others => (others => '0'));
		opcode_ip <= (others => (others => '0'));
		int_pol_ip <= (others => '0');
		enable_ip <= (others => '0');
		ack_ip <= (others => '0');
		cpu_read_completed_ip <= (others => '0');
		cpu_write_completed_ip <= (others => '0');

		-- connect the IP to the data buffer
		if (curr_active_ip /='0') then
			data_out_ip(to_integer(unsigned(curr_ip_idx))) <= buf_data_in;
			cpu_write_completed_ip(to_integer(unsigned(curr_ip_idx))) <= cpu_write_completed;
			cpu_read_completed_ip(to_integer(unsigned(curr_ip_idx))) <= cpu_read_completed;
		end if;

		case (curr_state) is
			-- The IDLE state considers, in order of importance:
			--	error signaling
			--	cores interrupt forwarding
			--	CPU acknowledgement
			-- CPU requests to open a transaction
			when IDLE =>
				next_opcode_ip <= (others => '0');
				next_int_pol_ip <= '0';
				next_ack_ip <= '0';
				-- BIG CHANGE FROM THE OLD IP MAN: it used to or all the errors and interrupts requests. However, these operations never occurred due to a flag
				-- canceling the operation. Hence, the code is simplified under the assumption that only one error/interrupt at the time can be served.

				-- An error signal arrives
				if (error_ip /= zeros(NUM_IPS-1 downto 0) and (ne1 = '1' or row_0(B_E_POS) = '0') and (curr_error_raised = '0')) then
					next_state <= SERVE_ERROR;
					next_signaling_ipaddress <= std_logic_vector(unsigned(error_ip_num) + 1);
				-- An interrupt signal is received
				elsif (interrupt_ip /= zeros(NUM_IPS-1 downto 0) and (ne1 = '1' or row_0(B_E_POS) = '0') and (curr_error_raised = '0') and (curr_interrupt_raised = '0')) then
					next_state <= SERVE_IRQ;
					next_signaling_ipaddress <= std_logic_vector(unsigned(interrupt_ip_num) + 1);
				-- The CPU sends an ACK
				elsif (row_0(B_E_POS) = '1' and row_0(ACK_POS) = '1') then
					next_state <= SERVE_ACK;
					next_row0_addr <= row_0(IPADDR_POS-1 downto 0);
				-- The CPU is opening a transaction
				elsif(row_0(B_E_POS) = '1' and row_0(ACK_POS) = '0') then
					next_state <= SERVE_TR;
					next_row0_addr <= row_0(IPADDR_POS-1 downto 0);
				end if;

			-- Send an interrupt to the CPU, communicating an error, and raise an error flag
			when SERVE_ERROR => 
				buf_enable_man <= '1';
				buf_rw_man <= '1';
				buf_addr_man <= (others => '0');
				buf_data_out_man <= (others => '0');
				next_interrupt <= '1';
				next_error_raised <= '1';
				-- if an interrupt was raised cancel it
				next_interrupt_raised <= '0';
				next_state <= IDLE;

			-- Send an interrupt to the CPU, passing the address of the IP requesting it, and raise a flag to forbid other interrupt requests
			when SERVE_IRQ => 
				buf_enable_man <= '1';
				buf_rw_man <= '1';
				buf_addr_man <= (others => '0');
				buf_data_out_man <= zeros(DATA_WIDTH - NUM_IPS_WIDTH - 1 downto 0)&curr_signaling_ipaddress;
				next_interrupt <= '1';
				next_interrupt_raised <= '1';
				next_state <= IDLE;

			-- Serve an ACK from the CPU
			when SERVE_ACK => 
				next_interrupt <= '0';

				-- An IP is ACKed
				if (curr_row0_addr /= zeros(IPADDR_POS-1 downto 0) and unsigned(curr_row0_addr) <= max_ips) then
					next_interrupt_raised <= '0';

					next_active_ip <= '1';
					next_ip_idx <= std_logic_vector(unsigned(curr_row0_addr(NUM_IPS_WIDTH-1 downto 0)) - 1);
					next_ack_ip <= '1';
					next_state <= MULTIPLEXING;
				-- if the manager itself is ACKed, it means that the CPU is serving an error signaling
				elsif (curr_row0_addr = zeros(IPADDR_POS-1 downto 0)) then
					next_error_raised <= '0';

					next_active_ip <= '0';
					buf_enable_man <= '1';
					buf_rw_man <= '1';
					buf_addr_man <= (0 => '1', others => '0');
					buf_data_out_man <= zeros(DATA_WIDTH-NUM_IPS_WIDTH-1 downto 0)&curr_signaling_ipaddress;
					next_state <= ERROR_SIGNALING;
				end if;

			-- Open a transaction
			when SERVE_TR => 
				if (curr_row0_addr /= zeros(IPADDR_POS-1 downto 0) and unsigned(curr_row0_addr) <= max_ips) then
					next_active_ip <= '1';
					next_ip_idx <= std_logic_vector(unsigned(curr_row0_addr(NUM_IPS_WIDTH-1 downto 0)) - 1);
					next_opcode_ip <= row_0(OPCODE_START_POS-1 downto OPCODE_END_POS);
					next_int_pol_ip <= row_0(I_P_POS);
					next_state <= MULTIPLEXING;
				end if;

			when MULTIPLEXING => 
				-- only control data must be multiplexed, data already is
				if (row_0(B_E_POS) = '0') then
					next_state <= IDLE;
					next_active_ip <= '0';
				end if;

				-- propagate row0 conf to the IP
				opcode_ip(to_integer(unsigned(curr_ip_idx))) <= curr_opcode_ip;
				int_pol_ip(to_integer(unsigned(curr_ip_idx))) <= curr_int_pol_ip;
				enable_ip(to_integer(unsigned(curr_ip_idx))) <= '1';
				ack_ip(to_integer(unsigned(curr_ip_idx))) <= curr_ack_ip;

			-- Signal to the CPU the IP raising the error
			when ERROR_SIGNALING => 
				buf_enable_man 	 <= '1';
				buf_rw_man <= '1';
				buf_addr_man <= (0 => '1', others => '0');
				buf_data_out_man <= zeros(DATA_WIDTH - NUM_IPS_WIDTH -1 downto 0)&curr_signaling_ipaddress;
				next_state <= ERROR_SIGNALING_DONE;

			-- this idleness state is reached when the manager has communicated to the CPU the ID of the core in error
			-- simply turn off all signals (which is the default behavior) and wait for the transaction to be closed
			when ERROR_SIGNALING_DONE => 
				if (row_0(B_E_POS) = '0') then
					next_state <= IDLE;
				end if;

			--... why are we here?
			when others =>
				next_state <= IDLE;
		end case;
	end process comblogic;
end architecture;
