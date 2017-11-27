.include "constants.s"

.global READ_BYTE_FROM_UART
.global WRITE_BYTE_TO_UART

/**
 * Function READ_BYTE_FROM_UART()
 * 
 * Returns: r2: byte
 */
READ_BYTE_FROM_UART:
	/* Only use registers r2, r3 which are implicitly caller-saved. */
	movia r2, JTAG_UART

	/* Data Register
	 * 31:16 bytes available (approx)
	 * 15 Read data is valid
	 * 7:0 data */
	ldwio r3, 0(r2)

	/* Check data validity, else read next */
	andi r2, r3, 0x8000
	beq r2, r0, READ_BYTE_FROM_UART

	/* Store data byte in return register */
	andi r2, r3, 0xFF

	ret

/**
 * Function WRITE_BYTE_TO_UART(byte)
 * 
 * r4: The byte to write.
 * Returns: void
 */
WRITE_BYTE_TO_UART:
	/* Only use registers r2, r3 which are implicitly caller-saved. */
	movia r2, JTAG_UART
  
WRITE_POLL:
	/* Control Register
	 * 31:16 space available */
	ldwio r3, 4(r2)

	/* Check if space available to write, else try again. */
	srli r3, r3, 16
	beq r3, r0, WRITE_POLL

	/* Space available. */
	stwio r4, 0(r2)

	ret
