.include "constants.s"

.global SEND_POSITION

/*
 * Function SEND_POSITION(position)
 * 
 * Takes the a pointer to the cell's current position in the grid,
 * and sends it over UART to the computer.
 *
 * Will have to translate position to x, y coordinates (where 0,0 is
 * origin).
 */
SEND_POSITION:
    addi sp, sp, -8
    stw ra, 0(sp)
    stw r4, 4(sp)

    /* r4 is already a position ptr */
    call EXTRACT_XY
    andi r16, r2, 0xFFFF /* <- y */
    srli r17, r2, 16 /* <- x */

    /* Send X */
    mov r4, r17
    call WRITE_BYTE_TO_UART

    /* Send Y */
    mov r4, r16
    call WRITE_BYTE_TO_UART

    /* Send Obstacle Data */
    ldb r4, 4(sp)
    call WRITE_BYTE_TO_UART

    ldw ra, 0(sp)
    ldw r4, 4(sp)
    addi sp, sp, 8

    ret
