.include "constants.s"

.global IS_OBSTACLE_AHEAD

/**
 * Function IS_OBSTACLE_AHEAD()
 *
 * Determines if there is an obstacle ahead. Returns 1 if there's
 * an obstacle, 0 otherwise.
 */
IS_OBSTACLE_AHEAD:
    addi sp, sp, -4
    stw r16, 0(sp)

    /* Enable Sensor 0. */
	movia r2, LEGO_CONTROLLER
	ldw r3, 0(r2)
	movia r2, 0xFFFFFBFF
	and r3, r3, r2
	stwio r3, 0(r2)

POLL:
    /* Check valid bit. */
    ldw r3, 0(r2)
    movia r16, 0x800
    and r16, r16, r3
    
    /* valid if low */
    bne r16, r0, POLL

    /* sensor data is valid */
    srli r16, r16, 27
    andi r16, r16, 0x0F

    mov r2, r0
    movia r3, OBSTACLE_THRESHOLD
    ble r16, r3, OBSTACLE_EXISTS
    br DONE

OBSTACLE_EXISTS:
    movi r2, 1

DONE:
    ldw r16, 0(sp)
    addi sp, sp, 4

    ret