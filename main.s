.include "constants.s"

/* ============ DATA ============ */

.data

.include "seven_segments.dat"

.global GRID_ARRAY_BASE
.global GRID_ARRAY_END
.global CURRENT_DIRECTION
.global CURRENT_POSITION

.align 2
CURRENT_DIRECTION:
.word 0 /* 2 bits, MSb is +/-, LSb is x/y. */
CURRENT_POSITION:
.word 0 /* pointer to cell in GRID_ARRAY */

.align 0
GRID_ARRAY_BASE:
.skip (GRID_SIZE * GRID_SIZE), 0 /* array of (visited, obstacle) byte-padded tuple */
GRID_ARRAY_END:
.byte 0

.global RANDOM_SEED
.align 2
RANDOM_SEED:
.word 0xABCD1234

/* ============ TEXT ============ */

.text

.global _start
_start:
	/* reset IRQ line */
	wrctl ctl3, r0

	/* set the stack pointer to end of SDRAM, aligned */
	movia sp, SDRAM_END

	movia r8, LEGO_CONTROLLER
    
	/* default direction register value */
	movia r2, DEFAULT_LEGO_DIRECTION
	stwio r2, 4(r8)
  
	/* turn off all motors/sensors; + value mode 
	 * also set motors to fwd */
	movia r2, 0xFA6FFFF5
	stwio r2, 0(r8)

	/* Configure PWM with Timer 1 */
	movia r9, TIMER_1
	movia r2, PWM_INTERVAL
	stwio r2, 8(r9)
	srli r2, r2, 16
	stwio r2, 12(r9)

	/* Configure position tracker with Timer 2 */
	movia r9, TIMER_2
	movia r2, POSITION_TMR_INTERVAL
	stwio r2, 8(r9)
	srli r2, r2, 16
	stwio r2, 12(r9)

	/* Reset current position to origin. */
	movia r2, CURRENT_POSITION
	movia r8, GRID_ARRAY_BASE
	stw r8, 0(r2)

	/* Reset direction to +y */
	movia r2, CURRENT_DIRECTION
	movia r8, DIRECTION_POS_Y
	stw r8, 0(r2)

/*
 * In this state, the application is resumed.
 */
STATE_RESUME:
	/* Disable global interrupts; critical section. */
	wrctl ctl0, r0

	/* Disable motors. Stop movement. */
	movia r8, LEGO_CONTROLLER
	movia r9, 0xFFFFFFF5 /* 0b...0101 */
	stwio r9, 0(r8)

	/* Enable interrupt for Timer 1 & 2. */
	movia r8, IRQ_TIMER_1
	ori r8, r8, IRQ_TIMER_2
	wrctl ctl3, r8

	movia r8, TIMER_1
	movia r9, TIMER_2

	/* Re-/Enable global interrupts. */
	movi r2, 1
	wrctl ctl0, r2

	/* TODO: Make sure these are RESET, not just continued? */

	/* Enable PWM timer. */
	movia r2, 7
	stwio r2, 4(r8)

	/* Enable position timer. */
	movia r2, 7
	stwio r2, 4(r9)

	br STATE_MOVE

/*
 * This state is entered when the robot is deemed to have advanced
 * to a new position in the moveable area. We must determine the
 * direction the robot was facing, and along with its 'old' position,
 * determine the robot's current position.
 *
 * Note that this does NOT compute the NEXT position, but rather
 * determines and records the CURRENT position. This is essentially
 * the first part of a single 'turn' so to speak. Once we've established
 * that we are in a CURRENT_POSITION, we will check if we must change direction
 * (in the next state); for this reason, it may be better to implement the sensors
 * via polling rather than interrupts, espcially considering the negative-edge
 * detection introduces complications. With polling, we can:
 * "Advance Pointer -> Scan Area -> Compute Path/Rotate -> Move -> (repeat)"
 */
STATE_ADVANCE_CELL:
	/* Disable global interrupts; critical section. */
	wrctl ctl0, r0

	movia r16, CURRENT_POSITION
	ldw r4, 0(r16)
	movia r16, CURRENT_DIRECTION
	ldw r5, 0(r16)
	call GET_NEXT_CELL

	/* Update current position. */
	movia r16, CURRENT_POSITION
	stw r2, 0(r16)

	/* Announce position. */
	ldw r4, 0(r16)
	call DISPLAY_HEX_2BYTES

	ldw r4, 0(r16)
	call SEND_POSITION

	/* Transition into scan mode. */
	br STATE_SCAN_AHEAD

/* Scan cell boundaries */
STATE_SCAN_AHEAD:
	/* Poll sensors to see if we can move straight ahead.
	 * If we can't move ahead, adjust direction accordingly. */

	/* If there's no obstacle ahead, continue in that direction.
	 * Otherwise, traverse around obstacle. */
	call IS_OBSTACLE_AHEAD
	bne r2, r0, STATE_TRAVERSE_OBSTACLE

	/* Resume takes care of re-enabling appropriate interrupts. */
	br STATE_RESUME

/* There is an obstacle directly in front of the robot,
 * attempt to traverse it. */
STATE_TRAVERSE_OBSTACLE:
	/* Strategy #1: Rotate to a random direction. */

	call RANDOM_BIT
	bne r2, r0, STATE_TRAVERSE_OBSTACLE_RL

	call ROTATE_RIGHT
	br STATE_TRAVERSE_OBSTACLE_DONE

STATE_TRAVERSE_OBSTACLE_RL:
	call ROTATE_LEFT

STATE_TRAVERSE_OBSTACLE_DONE:
	/* Repeat obstacle check. */
	br STATE_SCAN_AHEAD

STATE_MOVE:
	br STATE_MOVE

.section .exceptions, "ax"
IHANDLER:
	addi sp, sp, -24
	
	/* Save interrupt data for nested interrupts. */
	stw et, 0(sp)
	rdctl et, ctl1
	stw et, 4(sp)
	stw ea, 8(sp)

	/* NOTE: on nested interrupts.
	 * 
	 * Due to the way we handle 'states', only select interrupts
	 * are able to re-enable the global interrupt bit; e.g. the
	 * sensor interrupts. The order the interrupts are handled
	 * are thus extremely important to their correctness. */

	/* Registers we will use. */
	stw r2, 12(sp)
	stw r3, 16(sp)
	stw r4, 20(sp)

	rdctl et, ctl4 /* ipending */

/*
 * Simple Pulse-Width Modulation (PWM)
 */
IHANDLER_TIMER_1:
	movia r2, IRQ_TIMER_1
	and r2, r2, et
	beq r2, r0, IHANDLER_TIMER_2

	/* PWM: Toggle on/off of motor 0 and 1. */
	movia r2, LEGO_CONTROLLER
	ldwio r3, 0(r2)
	movia r4, 5 /* 0b0101 */
	xor r3, r3, r4
	stwio r3, 0(r2)

	/* ACK the timeout. */
	movia r2, TIMER_1
	stwio r0, 0(r2)

/*
 * Position timer. This interrupt has the highest priority, however
 * it should NEVER be triggered during another interrupt.
 *
 * In this handler, the position timer has elapsed which means the robot
 * should have moved 1 physical unit in the direction it was facing.
 */
IHANDLER_TIMER_2:
	movia r2, IRQ_TIMER_2
	and r2, r2, et
	beq r2, r0, EXIT_IHANDLER

	/* Disable all interrupts individually, so that when eret re-enables
	 * the global interrupt bit, we remain in the ea's scope. */
	wrctl ctl3, r0

	/* Ensure we return to the appropriate state by setting 'ea'. */
	movia r2, STATE_ADVANCE_CELL
	addi r2, r2, 4 /* cancel out exit handler's subtraction */
	stw r2, 8(sp) /* write to ea in stack */

	/* ACK the timeout. */
	movia r2, TIMER_2
	stwio r0, 0(r2)

EXIT_IHANDLER:
	wrctl ctl0, r0

	/* Restore nested interrupt. */
	ldw et, 0(sp)
	ldw r2, 4(sp)
	wrctl ctl1, r2
	ldw ea, 8(sp)
	
	/* Restore registers. */
	ldw r2, 12(sp)
	ldw r3, 16(sp)
	ldw r4, 20(sp)

	addi sp, sp, 24

	addi ea, ea, -4
	eret
