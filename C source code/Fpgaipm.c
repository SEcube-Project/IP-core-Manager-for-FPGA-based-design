/**
  ******************************************************************************
  * File Name          : Fpgaipm.c
  * Description        : Low-level APIs for CPU-FPGA communication in an 
  						 IP-Manager-based environment
  ******************************************************************************
  *
  * Copyright(c) 2016-present Blu5 Group <https://www.blu5group.com>
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

#include "Fpgaipm.h"

// extern members
SRAM_HandleTypeDef SRAM_READ;
SRAM_HandleTypeDef SRAM_WRITE;


// private members
static FPGA_IPM_DATA row0;
static FPGA_IPM_CORE currentCore;
static FPGA_IPM_SEM sem = 0;


// private functions
static FPGA_IPM_BOOLEAN checkCore(FPGA_IPM_CORE coreID);
static void writeRow0(FPGA_IPM_DATA newRow0);
static void readRow0();



// public functions

FPGA_IPM_BOOLEAN FPGA_IPM_open (FPGA_IPM_CORE coreID, FPGA_IPM_OPCODE opcode, FPGA_IPM_BOOLEAN interruptMode, FPGA_IPM_BOOLEAN ack)
{
	FPGA_IPM_DATA newRow0;
	if (sem > 0) {
		sem--;
		newRow0 = 0 | (coreID & FPGA_IPM_CORE_MASK) | ((opcode & FPGA_IPM_OPCODE_MASK) << FPGA_IPM_OPCODE_OFFSET) |
				(interruptMode ? FPGA_IPM_INTERRUPT_MODE : 0) | (ack ? FPGA_IPM_ACK : 0) | FPGA_IPM_BEGIN_TRANSACTION;
		writeRow0(newRow0);
		currentCore = coreID;
		return 0;
	}
	return 1;
}


FPGA_IPM_BOOLEAN FPGA_IPM_read (FPGA_IPM_CORE coreID, FPGA_IPM_ADDRESS address, FPGA_IPM_DATA *dataPtr)
{
	HAL_StatusTypeDef status;
	if (checkCore(coreID)) {
		uint32_t addr = (FPGA_SRAM_BASE_ADDR + 2*address);
		status = HAL_SRAM_Read_16b(&SRAM_READ, (uint32_t*)addr, dataPtr, 1);
		return status == HAL_OK ? 0 : 1;
	}
	return 1;
}


FPGA_IPM_BOOLEAN FPGA_IPM_write (FPGA_IPM_CORE coreID, FPGA_IPM_ADDRESS address, FPGA_IPM_DATA *dataPtr)
{
	HAL_StatusTypeDef status;
	if (checkCore(coreID)) {
		uint32_t addr = (FPGA_SRAM_BASE_ADDR + 2*address);
		status = HAL_SRAM_Write_16b(&SRAM_WRITE, (uint32_t*)addr, dataPtr, 1);
		return status == HAL_OK ? 0 : 1;
	}
	return 1;
}


FPGA_IPM_BOOLEAN FPGA_IPM_close (FPGA_IPM_CORE coreID)
{
	if (checkCore(coreID)) {
		FPGA_IPM_DATA newRow0 = row0 & ~FPGA_IPM_BEGIN_TRANSACTION;
		writeRow0(newRow0);
		sem++;
		return 0;
	}
	return 1;
}




static FPGA_IPM_BOOLEAN checkCore (FPGA_IPM_CORE coreID)
{
	return coreID == currentCore && sem == 0 && initialized;
}


static void writeRow0(FPGA_IPM_DATA newRow0) {
  uint32_t* addr = FPGA_SRAM_BASE_ADDR;
  HAL_SRAM_Write_16b(&SRAM_WRITE, addr, &newRow0, 1);
  row0 = newRow0;
}


static void readRow0() {
	uint32_t* addr = FPGA_SRAM_BASE_ADDR;
	HAL_SRAM_Read_16b(&SRAM_READ, addr, &row0, 1);
}



void EXTI9_5_IRQHandler(void) {
	/* Make sure that interrupt flag is set */
    if (EXTI_GetITStatus(EXTI_Line9) != RESET) {
        /* Do your stuff when PA9 is changed */
        /* switch among different cores and call the specific ISR for everyone of them */
    	readRow0();
    	switch(row0) {
    		case 1:
    			// insert here code for IP #1
    		default:
    			break;
    	}
        /* Clear interrupt flag */
        EXTI_ClearITPendingBit(EXTI_Line9);
    }
}


