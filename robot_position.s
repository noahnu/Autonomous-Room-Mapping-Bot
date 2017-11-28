.include "constants.s"

.global GET_NEXT_CELL
.global EXTRACT_XY
.global XY_TO_POSITION

/*
 * Function GET_NEXT_CELL(r4: position, r5: direction)
 * 
 * Given a position (pointer to cell on grid) and a direction
 * in which the robot is facing, return the next position the
 * robot will be in if the direction does not change.
 *
 * Direction: 2 bits, MSb is +/-, LSb is x/y.
 *
 * Returns NULL (r0) if going in direction will result in out of bounds.
 */
GET_NEXT_CELL:
    addi sp, sp, -36
    stw ra, 0(sp)
    stw r4, 4(sp)
    stw r5, 8(sp)
    stw r6, 12(sp)
    stw r16, 16(sp)
    stw r17, 20(sp)
    stw r18, 24(sp)
    stw r19, 28(sp)
    stw r20, 32(sp)

    /* r2 <- x:y; r19: next x, r20: next y */
    call EXTRACT_XY
    or r19, r0, r2
    andi r19, r19, 0xFFFF
    srli r20, r2, 16

    /* r0: DIRECTION_NEG_Y */
    movi r16, DIRECTION_NEG_X
    movi r17, DIRECTION_POS_Y
    movi r18, DIRECTION_POS_X

    /* TODO: Rewrite without branches? */
    beq r5, r0, GET_NEXT_CELL_NEG_Y
    beq r5, r16, GET_NEXT_CELL_NEG_X
    beq r5, r17, GET_NEXT_CELL_POS_Y
    beq r5, r18, GET_NEXT_CELL_POS_X
    mov r2, r0
    br GET_NEXT_CELL_DONE

GET_NEXT_CELL_POS_X:
    /* x++ */
    addi r19, r19, 1
    br GET_NEXT_CELL_DONE

GET_NEXT_CELL_NEG_X:
    /* x-- */
    subi r19, r19, 1
    br GET_NEXT_CELL_DONE

GET_NEXT_CELL_POS_Y:
    /* y++ */
    addi r20, r20, 1
    br GET_NEXT_CELL_DONE

GET_NEXT_CELL_NEG_Y:
    /* y-- */
    subi r20, r20, 1
    br GET_NEXT_CELL_DONE

GET_NEXT_CELL_DONE:
    /* Bound x and y coordinates. */
    mov r5, r0
    movi r6, 511 /* 512 - 1 */

    mov r4, r19
    call MATH_CLAMP
    mov r19, r2

    mov r4, r20
    call MATH_CLAMP
    mov r20, r2

    /* r4 = x:y */
    slli r19, r19, 16
    or r4, r0, r19
    or r4, r4, r20
    call XY_TO_POSITION

    /* r2: next position */
    ldw r16, 4(sp) /* r16 <- original position */

    bne r2, r16, GET_NEXT_CELL_DONE_2
    /* old pos == new pos thus we attempted to go out of bounds, return NULL. */
    mov r2, r0

GET_NEXT_CELL_DONE_2:
    ldw ra, 0(sp)
    ldw r4, 4(sp)
    ldw r5, 8(sp)
    ldw r6, 12(sp)
    ldw r16, 16(sp)
    ldw r17, 20(sp)
    ldw r18, 24(sp)
    ldw r19, 28(sp)
    ldw r20, 32(sp)
    addi sp, sp, 36

    ret

/*
 * Function EXTRACT_XY(r4: position)
 *
 * Given a pointer to a cell in the grid, return the %hi(r2):x
 * and %lo(r2): y coordinates extracted from the position's memory address.
 */
EXTRACT_XY:
    addi sp, sp, -8
    stw r16, 0(sp)
    stw r17, 4(sp)

    /* Get position offset into r16: position - GRID_ARRAY_BASE. */
    movia r2, GRID_ARRAY_BASE
    sub r16, r4, r2

    /* x = offset / 512; range: [0, 512) */
    movia r17, 1
    slli r17, r17, 9 /* 2^9 = 512 */
    divu r2, r16, r17
    slli r2, r2, 16 /* move x into %hi(r2) */

    /* y = offset - (x * 512); range: [0, 512) */
    mov r17, r2 /* r17 <- x */
    slli r17, r17, 9 /* r17 <- x * 2^9 */
    sub r17, r16, r17
    or r2, r2, r17 /* copy y into %lo(r2) */
    
    ldw r16, 0(sp)
    ldw r17, 4(sp)
    addi sp, sp, 8

    ret

/*
 * Function XY_TO_POSITION(r4: x:y)
 *
 * Given an x:y coordinate, returns the position, or NULL
 * if out of bounds.
 */
XY_TO_POSITION:
    addi sp, sp, -4
    stw r3, 0(sp)

    /* position = base + (512 * x) + y */
    movia r2, GRID_ARRAY_BASE
    
    srli r3, r4, 16 /* r3 <- x */
    slli r3, r3, 9 /* r3 *= 2^9 (512) */
    add r2, r2, r3 /* r2 += (512 * x) */

    andi r3, r4, 0xFFFF
    add r2, r2, r3 /* r2 += y */

    movia r3, GRID_ARRAY_END
    bge r2, r3, XY_TO_POSITION_EBOUNDS
    blt r2, r0, XY_TO_POSITION_EBOUNDS

    br XY_TO_POSITION_DONE
XY_TO_POSITION_EBOUNDS:
    mov r2, r0

XY_TO_POSITION_DONE:
    ldw r3, 0(sp)
    addi sp, sp, 4
    ret