.include "constants.s"

.global ROTATE_RIGHT
.global ROTATE_LEFT

/**
 * Function ROTATE_RIGHT()
 *
 * Performs a 90 degree rotation to the right / clockwise,
 * and updates the CURRENT_DIRECTION.
 */
ROTATE_RIGHT:
    addi sp, sp, -4
    /* 0(sp) = motor state */

    /* Save motor state. */
	movia r2, LEGO_CONTROLLER
	ldwio r2, 0(r2)
    stw r2, 0(sp)

    /* Motor 0 fwd, Motor 1 rev, and on */
    ori r2, r2, 8 /* motor 1 = rev */
    movia r3, 0xFFFFFFF8 /* 0b1000; preserve motor 1 direction */
    and r2, r2, r3 /* motor 1 = rev; both motors on */

    movia r3, LEGO_CONTROLLER
    stwio r2, 0(r3)

    movia r3, ROTATION_TMR_INTERVAL
ROTATE_RIGHT_POLL_TMR:
    subi r3, r3, 1
    bne r3, r0, ROTATE_RIGHT_POLL_TMR    

    /* Restore lego controller state. */
    ldw r2, 0(sp)
    movia r3, LEGO_CONTROLLER
    stwio r2, 0(r3)

    addi sp, sp, 4

    /* Update CURRENT_DIRECTION; dir = (dir + 1) % 4 */
    movia r3, CURRENT_DIRECTION
    ldw r3, 0(r2)
    addi r3, r3, 1
    andi r3, r3, 0x3
    stw r3, 0(r2)

    ret

/**
 * Function ROTATE_LEFT()
 *
 * Performs a 90 degree rotation to the left / counter-clockwise,
 * and updates the CURRENT_DIRECTION.
 */
ROTATE_LEFT:
    addi sp, sp, -4
    /* 0(sp) = motor state */

    /* Save motor state. */
	movia r2, LEGO_CONTROLLER
	ldwio r2, 0(r2)
    stw r2, 0(sp)

    /* Motor 0 rev, Motor 1 fwd, and on */
    ori r2, r2, 2 /* motor 0 = rev */
    movia r3, 0xFFFFFFF2 /* 0b0010; preserve motor 0 direction */
    and r2, r2, r3 /* motor 1 = fwd; both motors on */

    movia r3, LEGO_CONTROLLER
    stwio r2, 0(r3)

    movia r3, ROTATION_TMR_INTERVAL
ROTATE_LEFT_POLL_TMR:
    subi r3, r3, 1
    bne r3, r0, ROTATE_LEFT_POLL_TMR    

    /* Restore lego controller state. */
    ldw r2, 0(sp)
    movia r3, LEGO_CONTROLLER
    stwio r2, 0(r3)

    addi sp, sp, 4

    /* Update CURRENT_DIRECTION; dir = (dir + 3) % 4 */
    movia r3, CURRENT_DIRECTION
    ldw r3, 0(r2)
    addi r3, r3, 3
    andi r3, r3, 0x3
    stw r3, 0(r2)

    ret