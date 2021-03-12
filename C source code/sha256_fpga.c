/**
  ******************************************************************************
  * File Name          : sha256_fpga.c
  * Description        : High-level driver for communication between CPU and 
                         SHA256 IP core in an IP-Manager-based environment
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

#include "sha256_fpga.h"

#define SHA256_FPGA_CORE 0x1


void SHA256_FPGA_64_TO_8X8(uint64_t n, uint8_t *b)                       
{

    b[0] = (uint8_t)(n >> 54);      
    b[1] = (uint8_t)(n >> 48);      
    b[2] = (uint8_t)(n >> 40);      
    b[3] = (uint8_t)(n >> 32);
    b[4] = (uint8_t)(n >> 24);
    b[5] = (uint8_t)(n >> 16);
    b[6] = (uint8_t)(n >>  8);
    b[7] = (uint8_t)(n      );
}


static void SHA256_FPGA_compute_block(FPGA_IPM_DATA *block, FPGA_IPM_DATA *state)
{

	FPGA_IPM_ADDRESS add = 0x1;
	FPGA_IPM_DATA polling_semaphore = 0x0000;
	int i;

	// open a polling transaction
	 FPGA_IPM_open(SHA256_FPGA_CORE, 0, 0, 0);
	// write the current state onto the data buffer
	for(i=0; i<16; i++) {
		FPGA_IPM_write(SHA256_FPGA_CORE, add, &state[i]);
		add++;
	}
	 // write the block onto the data buffer
	 for(i=0; i<32; i++) {
	 	FPGA_IPM_write(SHA256_FPGA_CORE, add, &block[i]);
	 	add++;
	 }
	 // lock the CPU and wait for core unlocking
	 FPGA_IPM_write(SHA256_FPGA_CORE, 0x3F, &polling_semaphore);
	 while(polling_semaphore != 0xFFFF) {
	 	FPGA_IPM_read(0x1, 0x3F, &polling_semaphore);
	 }
	 //	read out intermediate digest as the new state
	add = 0x1;
	for(i=0; i<16; i++) {
		FPGA_IPM_read(SHA256_FPGA_CORE, add, &state[i]);
		add++;
	}
	// close the polling transaction
	FPGA_IPM_close(SHA256_FPGA_CORE);

}


SHA256_FPGA_RETURN_CODE SHA256_FPGA_digest_message(const uint8_t *message, uint64_t dataLen, uint8_t *digest)
{
    uint8_t len[8];
    uint64_t left;
    int i, j = 0;

    FPGA_IPM_DATA hash[16] =
    {
            0x6A09,
            0xE667,
            0xBB67,
            0xAE85,
            0x3C6E,
            0xF372,
            0xA54F,
            0xF53A,
            0x510E,
            0x527F,
            0x9B05,
            0x688C,
            0x1F83,
            0xD9AB,
            0x5BE0,
            0xCD19
    };

    FPGA_IPM_DATA msgBlock[32];

    uint8_t lastBlock[64];

    if((message == NULL) || (digest == NULL)) return SHA256_FPGA_RES_INVALID_ARGUMENT;


    left = dataLen;
    while(left > 64) {
        for(i=0; i<32; i++) {
            msgBlock[i] = (FPGA_IPM_DATA)((message[2*j] << 8) | (message[2*j + 1]));
            j++;
        }
        SHA256_FPGA_compute_block(msgBlock, hash);
        left -= 64;
    }
    j = j << 1;
    for(i=0; i<left; i++) {
        lastBlock[i] = message[j];
        j++;
    }
    lastBlock[left] = 0x80;
    for(i = left+1; i<55; i++) {
        lastBlock[i] = 0x00;
    } 
    SHA256_FPGA_64_TO_8X8(dataLen << 3, len);
    for(i=56; i<64; i++) {
        lastBlock[i] = len[i-56];
    }
    for(i=0; i<32; i++) {
        msgBlock[i] = (FPGA_IPM_DATA)((lastBlock[2*i] << 8) | (lastBlock[2*i + 1]));
    }
    SHA256_FPGA_compute_block(msgBlock, hash);
    for(i=0; i<16; i++) {
        digest[2*i]   = (uint8_t)(hash[i] >> 8);
        digest[2*i+1] = (uint8_t)(hash[i] & 0xFF);
    }

    return SHA256_FPGA_RES_OK;

}
