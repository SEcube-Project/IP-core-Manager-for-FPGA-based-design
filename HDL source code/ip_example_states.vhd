library ieee;
use ieee.std_logic_1164.all;
use work.CONSTANTS.all;

package ip_example_states is
	constant OFF : std_logic_vector(OPCODE_SIZE-1 downto 0) 					:= "000000";
	constant WAIT_FIRST_OPERAND : std_logic_vector(OPCODE_SIZE-1 downto 0) 	:= "000001"; 
	constant ADDR_FIRST_OPERAND : std_logic_vector(OPCODE_SIZE-1 downto 0) 	:= "000010"; 
	constant READ_FIRST_OPERAND : std_logic_vector(OPCODE_SIZE-1 downto 0) 	:= "000011"; 
	constant WAIT_SECOND_OPERAND : std_logic_vector(OPCODE_SIZE-1 downto 0) 	:= "000100"; 
	constant ADDR_SECOND_OPERAND : std_logic_vector(OPCODE_SIZE-1 downto 0) 	:= "000101"; 
	constant READ_SECOND_OPERAND : std_logic_vector(OPCODE_SIZE-1 downto 0) 	:= "000110"; 
	constant COMPUTE : std_logic_vector(OPCODE_SIZE-1 downto 0) 				:= "001000"; 
	constant ACK_WAITING : std_logic_vector(OPCODE_SIZE-1 downto 0) 			:= "010000"; 
	constant WAIT_STATUS_CPU : std_logic_vector(OPCODE_SIZE-1 downto 0) 		:= "010001"; 
	constant WRITE_RESULT : std_logic_vector(OPCODE_SIZE-1 downto 0) 			:= "100000"; 
	constant WRITE_STATUS : std_logic_vector(OPCODE_SIZE-1 downto 0) 			:= "100001"; 
	constant DONE : std_logic_vector(OPCODE_SIZE-1 downto 0) 					:= "111111"; 
end package ip_example_states;