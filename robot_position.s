.include "constants.s"

.global GET_NEXT_CELL
.global EXTRACT_XY

/*
 * Function GET_NEXT_CELL(r4: position, r5: direction)
 * 
 * Given a position (pointer to cell on grid) and a direction
 * in which the robot is facing, return the next position the
 * robot will be in if the direction does not change.
 */
GET_NEXT_CELL:
    ret

/*
 * Function EXTRACT_XY(r4: position)
 *
 * Given a pointer to a cell in the grid, return the %hi(r2):x
 * and %lo(r2): y coordinates extracted from the position's memory address.
 */
EXTRACT_XY:
    addi sp, sp, 8
    stw r16, 0(sp)
    stw r17, 4(sp)

    /* Get position offset into r16: position - GRID_ARRAY_BASE. */
    movia r2, GRID_ARRAY_BASE
    sub r16, r4, r2

    /* x = offset / (512 * 4); range: [0, 512) */
    slli r17, r17, 11 /* 2^11 = 512 * 4 */
    divu r2, r16, r17
    slli r2, r2, 16 /* move x into %hi(r2) */

    /* offset_y = offset - (x * 512)
     * y = offset_y / 4; range: [0, 512) */
    mov r17, r2 /* r17 <- x */
    slli r17, r17, 9 /* r17 <- x * 2^9 */
    sub r17, r16, r17
    or r2, r2, r17 /* copy y into %lo(r2) */
    
    ldw r16, 0(sp)
    ldw r17, 4(sp)
    addi sp, sp, -4

    ret