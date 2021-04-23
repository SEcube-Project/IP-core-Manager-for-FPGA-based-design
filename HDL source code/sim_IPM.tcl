##  ******************************************************************************
##  * File Name          : sim_IPM.tcl
##  * Description        : TCL script to be run into ModelSim for simulation
##  ******************************************************************************
##  *
##  * Copyright � 2016-present Blu5 Group <https://www.blu5group.com>
##  *
##  * This library is free software; you can redistribute it and/or
##  * modify it under the terms of the GNU Lesser General Public
##  * License as published by the Free Software Foundation; either
##  * version 3 of the License, or (at your option) any later version.
##  *
##  * This library is distributed in the hope that it will be useful,
##  * but WITHOUT ANY WARRANTY; without even the implied warranty of
##  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
##  * Lesser General Public License for more details.
##  *
##  * You should have received a copy of the GNU Lesser General Public
##  * License along with this library; if not, see <https://www.gnu.org/licenses/>.
##  *
##  ******************************************************************************

vlib work

vcom -2008 -work work CONSTANTS.vhd
vcom -2008 -work work DATA_BUFFER.vhd
vcom -2008 -work work IP_MANAGER.vhd

# vcom -2008 -work work IP_EXAMPLE.vhd

vcom -2008 -work work ./GENERICS/ADDER_GENERIC.vhd
vcom -2008 -work work ./GENERICS/MUX21_GENERIC.vhd
vcom -2008 -work work ./GENERICS/REGISTER_GENERIC.vhd

vcom -2008 -work work ./SHA256/SHA256_PACKAGE.vhd
vcom -2008 -work work ./SHA256/F0_GATE.vhd
vcom -2008 -work work ./SHA256/F1_GATE.vhd
vcom -2008 -work work ./SHA256/MUX161_16.vhd
vcom -2008 -work work ./SHA256/RND_LUT.vhd
vcom -2008 -work work ./SHA256/S0_BLOCK.vhd
vcom -2008 -work work ./SHA256/S1_BLOCK.vhd
vcom -2008 -work work ./SHA256/S2_BLOCK.vhd
vcom -2008 -work work ./SHA256/S3_BLOCK.vhd
vcom -2008 -work work ./SHA256/SHA256_CONTROL_UNIT.vhd
vcom -2008 -work work ./SHA256/SHA256_TOP.vhd                                                                                                                               

vcom -2008 -work work TOP_ENTITY.vhd

vcom -2008 -work work FPGA_testbench.vhd

vsim -voptargs=+acc work.FPGA_testbench

add wave -noupdate -group TB FPGA_testbench/hclk
add wave -noupdate -group TB FPGA_testbench/fpga_clk	
add wave -noupdate -group TB FPGA_testbench/reset	
add wave -noupdate -group TB FPGA_testbench/data	
add wave -noupdate -group TB FPGA_testbench/address	 
add wave -noupdate -group TB FPGA_testbench/noe		
add wave -noupdate -group TB FPGA_testbench/nwe		
add wave -noupdate -group TB FPGA_testbench/ne1		
add wave -noupdate -group TB FPGA_testbench/interrupt

add wave -noupdate -group DATA_BUFFER FPGA_testbench/UUT/data_buff/clock        
add wave -noupdate -group DATA_BUFFER FPGA_testbench/UUT/data_buff/reset				
add wave -noupdate -group DATA_BUFFER FPGA_testbench/UUT/data_buff/row_0		    	
add wave -noupdate -group DATA_BUFFER FPGA_testbench/UUT/data_buff/cpu_data	    	
add wave -noupdate -group DATA_BUFFER FPGA_testbench/UUT/data_buff/cpu_addr        	
add wave -noupdate -group DATA_BUFFER FPGA_testbench/UUT/data_buff/cpu_noe    			
add wave -noupdate -group DATA_BUFFER FPGA_testbench/UUT/data_buff/cpu_nwe    			
add wave -noupdate -group DATA_BUFFER FPGA_testbench/UUT/data_buff/cpu_ne1    			
add wave -noupdate -group DATA_BUFFER FPGA_testbench/UUT/data_buff/ipm_data_in	  		
add wave -noupdate -group DATA_BUFFER FPGA_testbench/UUT/data_buff/ipm_data_out		
add wave -noupdate -group DATA_BUFFER FPGA_testbench/UUT/data_buff/ipm_addr     		
add wave -noupdate -group DATA_BUFFER FPGA_testbench/UUT/data_buff/ipm_rw 				
add wave -noupdate -group DATA_BUFFER FPGA_testbench/UUT/data_buff/ipm_enable  		
add wave -noupdate -group DATA_BUFFER FPGA_testbench/UUT/data_buff/data_buffer_state
add wave -noupdate -group DATA_BUFFER FPGA_testbench/UUT/data_buff/cpu_read_completed 	
add wave -noupdate -group DATA_BUFFER FPGA_testbench/UUT/data_buff/cpu_write_completed
add wave -noupdate -group DATA_BUFFER FPGA_testbench/UUT/data_buff/cnt
add wave -noupdate -group DATA_BUFFER FPGA_testbench/UUT/data_buff/address
add wave -noupdate -group DATA_BUFFER FPGA_testbench/UUT/data_buff/data_buffer_state
add wave -noupdate -group DATA_BUFFER FPGA_testbench/UUT/data_buff/mem

add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/clock 			
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/reset          			
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/interrupt       		
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/ne1       		
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/buf_data_out    		
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/buf_data_in     		
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/buf_addr        		
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/buf_rw          		
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/buf_enable      		
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/row_0           		
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/cpu_read_completed  	
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/cpu_write_completed 	
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/addr_ip         	   
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/data_in_ip      	   
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/data_out_ip     	   
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/opcode_ip			   
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/int_pol_ip			   
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/rw_ip		    	   
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/buf_enable_ip   	   
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/enable_ip      		   
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/ack_ip 	        	   
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/interrupt_ip 		   
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/error_ip			   
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/cpu_read_completed_ip  
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/cpu_write_completed_ip
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/state
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/active_ip
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/buf_data_out_man 
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/buf_addr_man     
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/buf_rw_man       
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/buf_enable_man
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/faulty_ipaddress
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/opcode
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/i_p 
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/signaled_errors 
add wave -noupdate -group IP_MANAGER FPGA_testbench/UUT/ip_man/signaled_interrupts

# add wave -noupdate -group IP_EXAMPLE FPGA_testbench/UUT/ip_exmp1/clock             
# add wave -noupdate -group IP_EXAMPLE FPGA_testbench/UUT/ip_exmp1/reset 				
# add wave -noupdate -group IP_EXAMPLE FPGA_testbench/UUT/ip_exmp1/data_in 			
# add wave -noupdate -group IP_EXAMPLE FPGA_testbench/UUT/ip_exmp1/opcode 				
# add wave -noupdate -group IP_EXAMPLE FPGA_testbench/UUT/ip_exmp1/enable 				
# add wave -noupdate -group IP_EXAMPLE FPGA_testbench/UUT/ip_exmp1/ack 				
# add wave -noupdate -group IP_EXAMPLE FPGA_testbench/UUT/ip_exmp1/interrupt_polling
# add wave -noupdate -group IP_EXAMPLE FPGA_testbench/UUT/ip_exmp1/data_out 			
# add wave -noupdate -group IP_EXAMPLE FPGA_testbench/UUT/ip_exmp1/buffer_enable 		
# add wave -noupdate -group IP_EXAMPLE FPGA_testbench/UUT/ip_exmp1/address 			
# add wave -noupdate -group IP_EXAMPLE FPGA_testbench/UUT/ip_exmp1/rw 					
# add wave -noupdate -group IP_EXAMPLE FPGA_testbench/UUT/ip_exmp1/interrupt  			
# add wave -noupdate -group IP_EXAMPLE FPGA_testbench/UUT/ip_exmp1/error 				
# add wave -noupdate -group IP_EXAMPLE FPGA_testbench/UUT/ip_exmp1/write_completed		
# add wave -noupdate -group IP_EXAMPLE FPGA_testbench/UUT/ip_exmp1/read_completed		
# add wave -noupdate -group IP_EXAMPLE FPGA_testbench/UUT/ip_exmp1/state 
# add wave -noupdate -group IP_EXAMPLE FPGA_testbench/UUT/ip_exmp1/mode  
# add wave -noupdate -group IP_EXAMPLE FPGA_testbench/UUT/ip_exmp1/in1   
# add wave -noupdate -group IP_EXAMPLE FPGA_testbench/UUT/ip_exmp1/in2   
# add wave -noupdate -group IP_EXAMPLE FPGA_testbench/UUT/ip_exmp1/res   



add wave -noupdate -group SHA_STATE FPGA_testbench/UUT/sha_core/CLK	
add wave -noupdate -group SHA_STATE FPGA_testbench/UUT/sha_core/CU/state

add wave -noupdate -group SHA_INTERFACE FPGA_testbench/UUT/sha_core/RST 
add wave -noupdate -group SHA_INTERFACE FPGA_testbench/UUT/sha_core/EN 
add wave -noupdate -group SHA_INTERFACE FPGA_testbench/UUT/sha_core/OPCODE 
add wave -noupdate -group SHA_INTERFACE FPGA_testbench/UUT/sha_core/ACK 
add wave -noupdate -group SHA_INTERFACE FPGA_testbench/UUT/sha_core/I_P 
add wave -noupdate -group SHA_INTERFACE FPGA_testbench/UUT/sha_core/WRITE_COMPLETED
add wave -noupdate -group SHA_INTERFACE FPGA_testbench/UUT/sha_core/READ_COMPLETED 
add wave -noupdate -group SHA_INTERFACE FPGA_testbench/UUT/sha_core/BUFF_EN 
add wave -noupdate -group SHA_INTERFACE FPGA_testbench/UUT/sha_core/BUFF_RW 
add wave -noupdate -group SHA_INTERFACE FPGA_testbench/UUT/sha_core/ADDRESS 
add wave -noupdate -group SHA_INTERFACE FPGA_testbench/UUT/sha_core/INTERRUPT 
add wave -noupdate -group SHA_INTERFACE FPGA_testbench/UUT/sha_core/ERROR 
add wave -noupdate -group SHA_INTERFACE FPGA_testbench/UUT/sha_core/DATAIN 
add wave -noupdate -group SHA_INTERFACE FPGA_testbench/UUT/sha_core/DATAOUT 

add wave -noupdate -group SHA_ADDRESS FPGA_testbench/UUT/sha_core/LD_ADDRESS
add wave -noupdate -group SHA_ADDRESS FPGA_testbench/UUT/sha_core/RST_ADDRESS
add wave -noupdate -group SHA_ADDRESS FPGA_testbench/UUT/sha_core/ADDRESS_MUX_SEL
add wave -noupdate -group SHA_ADDRESS FPGA_testbench/UUT/sha_core/ADDRESS_MUX_OUT

add wave -noupdate -group SHA_BLOCK_FIFO FPGA_testbench/UUT/sha_core/DATAIN_REG_EN 
add wave -noupdate -group SHA_BLOCK_FIFO FPGA_testbench/UUT/sha_core/DATAIN_REG_OUT 
add wave -noupdate -group SHA_BLOCK_FIFO FPGA_testbench/UUT/sha_core/BLOCK_FIFO_MUX_SEL 
add wave -noupdate -group SHA_BLOCK_FIFO FPGA_testbench/UUT/sha_core/BLOCK_FIFO_MUX_OUT 
add wave -noupdate -group SHA_BLOCK_FIFO FPGA_testbench/UUT/sha_core/BLOCK_FIFO_WR
add wave -noupdate -group SHA_BLOCK_FIFO FPGA_testbench/UUT/sha_core/BLOCK_FIFO_SH 
add wave -noupdate -group SHA_BLOCK_FIFO FPGA_testbench/UUT/sha_core/BLOCK_FIFO_W 

add wave -noupdate -group SHA_R_PIPELINE FPGA_testbench/UUT/sha_core/R_REG_EN 
add wave -noupdate -group SHA_R_PIPELINE FPGA_testbench/UUT/sha_core/R01_S0_OUT 
add wave -noupdate -group SHA_R_PIPELINE FPGA_testbench/UUT/sha_core/R01_S1_OUT 
add wave -noupdate -group SHA_R_PIPELINE FPGA_testbench/UUT/sha_core/R01_ADD_OUT 
add wave -noupdate -group SHA_R_PIPELINE FPGA_testbench/UUT/sha_core/R01_REG_0_OUT 
add wave -noupdate -group SHA_R_PIPELINE FPGA_testbench/UUT/sha_core/R01_REG_1_OUT 
add wave -noupdate -group SHA_R_PIPELINE FPGA_testbench/UUT/sha_core/R01_REG_2_OUT 
add wave -noupdate -group SHA_R_PIPELINE FPGA_testbench/UUT/sha_core/R02_ADD_OUT 
add wave -noupdate -group SHA_R_PIPELINE FPGA_testbench/UUT/sha_core/R02_REG_0_OUT 
add wave -noupdate -group SHA_R_PIPELINE FPGA_testbench/UUT/sha_core/R02_REG_1_OUT 
add wave -noupdate -group SHA_R_PIPELINE FPGA_testbench/UUT/sha_core/R03_ADD_OUT 
add wave -noupdate -group SHA_R_PIPELINE FPGA_testbench/UUT/sha_core/R03_REG_OUT 

add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/S_STATE_REG_EN
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/S_STATE 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P_REG_EN 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P01_MUX_SEL 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P01_MUX_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/BLOCK_FIFO_W(0)
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/STEP_REG_OUT
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P01_S2_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P01_F0_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P01_S3_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P01_F1_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P01_ADD_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/INC_STEP 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/RND_LUT_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P01_REG_0_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P01_REG_1_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P01_REG_2_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P01_REG_3_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P01_REG_4_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P01_REG_5_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P01_REG_6_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P01_REG_7_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P01_REG_8_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P01_REG_9_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P01_REG_10_OUT
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P01_REG_11_OUT
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P01_REG_12_OUT
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P02_ADD_0_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P02_ADD_1_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P02_ADD_2_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P02_REG_0_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P02_REG_1_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P02_REG_2_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P02_REG_3_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P02_REG_4_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P02_REG_5_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P02_REG_6_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P02_REG_7_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P02_REG_8_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P02_REG_9_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P03_ADD_OUT  
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P03_REG_0_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P03_REG_1_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P03_REG_2_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P03_REG_3_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P03_REG_4_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P03_REG_5_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P03_REG_6_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P03_REG_7_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P03_REG_8_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P04_ADD_0_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P04_ADD_1_OUT 
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/P04_REG_OUT  
add wave -noupdate -group SHA_P_PIPELINE FPGA_testbench/UUT/sha_core/STATE_ADD_OUT

add wave -noupdate -group SHA_OUTPUT FPGA_testbench/UUT/sha_core/F_STATE_REG_EN 
add wave -noupdate -group SHA_OUTPUT FPGA_testbench/UUT/sha_core/F_STATE 
add wave -noupdate -group SHA_OUTPUT FPGA_testbench/UUT/sha_core/STATE_MUX_SEL
add wave -noupdate -group SHA_OUTPUT FPGA_testbench/UUT/sha_core/STATE_MUX_OUT 
add wave -noupdate -group SHA_OUTPUT FPGA_testbench/UUT/sha_core/DATAOUT_MUX_SEL 


run 20 us

