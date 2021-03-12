/**
  ******************************************************************************
  * File Name          : sha256_fpga.h
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

#ifndef SHA256_FPGA_H_
#define SHA256_FPGA_H_

#include <stdint.h>
#include <string.h>
#include "Fpgaipm.h"

// types
#define SHA256_FPGA_RETURN_CODE int8_t

/** \defgroup shaRet256 SHA256_FPGA return values
 * @{
 */
/** \name SHA256_FPGA return values */
///@{
#define SHA256_FPGA_RES_OK				 ( 0)
#define SHA256_FPGA_RES_INVALID_ARGUMENT (-1)
///@}
/** @} */


// public function

/**
 * @brief Compute the SHA256 algorithm on input data depending on the current status of the SHA256_FPGA context.
 * @param message Pointer to the input data.
 * @param dataLen Bytes to be processed.
 * @param digest Pointer to a blank memory area that can store the computed output digest.
 * @return See \ref shaRet256.
 */
SHA256_FPGA_RETURN_CODE SHA256_FPGA_digest_message (const uint8_t *message, uint64_t dataLen, uint8_t *digest);

#endif /* SHA256_FPGA_H_ */
