.include "constants.s"

.global IS_OBSTACLE_AHEAD

/**
 * Function IS_OBSTACLE_AHEAD()
 *
 * Determines if there is an obstacle ahead. Returns 1 if there's
 * an obstacle, 0 otherwise.
 *
 * A map edge is also considered an "obstacle", although we don't record it
 * in the grid array. For map edges, we can just check XY coordinates and
 * compare with what we know of the map's boundaries.
 */
IS_OBSTACLE_AHEAD:
    addi sp, sp, -16
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r4, 8(sp)
    stw r5, 12(sp)

    /* Check if moving one forward would result in out-of-bounds. */
    movia r2, CURRENT_POSITION
    movia r3, CURRENT_DIRECTION
    ldw r4, 0(r2)
    ldw r5, 0(r3)
    call GET_NEXT_CELL

    /* If out of bound error, 'obstacle' exists in forward direction. */
    beq r2, r0, OBSTACLE_EXISTS

    /* Enable Sensor 0. */
	movia r2, LEGO_CONTROLLER
	ldw r3, 0(r2)
	movia r2, 0xFFFFFBFF
	and r3, r3, r2
	stwio r3, 0(r2)

POLL:
    /* Check valid bit. */
    ldwio r3, 0(r2)
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
    ldw ra, 0(sp)
    ldw r16, 4(sp)
    ldw r4, 8(sp)
    ldw r5, 12(sp)
    addi sp, sp, 16

    ret