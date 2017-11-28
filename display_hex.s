.include "constants.s"

.global DISPLAY_HEX
.global DISPLAY_HEX_2BYTES

/*
 * Function DISPLAY_HEX_2BYTES(r4: Value)
 *
 * Displays the lower 2 bytes of a word using 4 hex segments.
 */
DISPLAY_HEX_HWORD:
	addi sp, sp, -8
	stw ra, 0(sp)
	stw r4, 4(sp)	
	
	/* Display byte 1. */
	ldb r4, 4(sp)
	mov r5, r0
	call DISPLAY_HEX

	ldb r4, 4(sp)
	srli r4, r4, 4
	movi r5, 1
	call DISPLAY_HEX

	/* Display byte 2. */
	ldb r4, 5(sp)
	movi r5, 2
	call DISPLAY_HEX

	ldb r4, 5(sp)
	srli r4, r4, 4
	movi r5, 3
	call DISPLAY_HEX

	ldw ra, 0(sp)
	ldw r4, 4(sp)
	addi sp, sp, 8
	
	ret

/*
 * Function DISPLAY_HEX(r4: Hex#, r5: Value)
 * 
 * Takes a hex display number from 0-5 and an unsigned byte,
 * and displays the byte correctly on the specified hex display.
 */
DISPLAY_HEX:
	addi sp, sp, -16
	stw ra, 0(sp)
	stw r4, 4(sp)
	stw r5, 8(sp)
	stw r16, 12(sp)

	movia r16, HEX_LOWER
	movia r3, 4

	/* If Hex# >= 4; use HEX_UPPER. */
	blt r4, r3, SET_SEGMENTS
	movia r16, HEX_UPPER
	subi r4, r4, 4 /* make r4 refer to byte offset */
SET_SEGMENTS:
	/* r2 <- segment byte for value */
	mov r4, r5
	call VAL_TO_HEX_SEGMENTS

	/* Store r2 into r4(r16) */
	movia r5, 0x000000FF

	ldw r4, 4(sp)
	slli r4, r4, 3 /* <- r4 x 8 */
	sll r5, r5, r4 /* create bitmask for the hex byte */
	movia r3, 0xFFFFFFFF
	xor r5, r5, r3 /* <- ~r5 */

	ldwio r3, 0(r16) /* get the current bitmap */
	and r3, r3, r5 /* clear target byte */

	sll r2, r2, r4
	or r3, r3, r2

	stwio r3, 0(r16)

	ldw ra, 0(sp)
	ldw r4, 4(sp)
	ldw r5, 8(sp)
	ldw r16, 12(sp)
	addi sp, sp, 16

    ret

/**
 * Function VAL_TO_HEX_SEGMENTS(r4: value)
 *
 * Returns r2: byte of segment bits for a single 7 segment display.
 */
VAL_TO_HEX_SEGMENTS:
	movia r2, HEX_SEGMENTS_ARRAY
	add r2, r2, r4
	ldb r2, 0(r2)

	ret
