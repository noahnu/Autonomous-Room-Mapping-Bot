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
    ret