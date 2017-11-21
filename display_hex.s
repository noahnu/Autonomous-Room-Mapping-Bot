.include "constants.s"

.global DISPLAY_HEX

/*
 * Function DISPLAY_HEX(Hex#, Value)
 * 
 * Takes a hex display number from 0-5 and an unsigned byte,
 * and displays the byte correctly on the specified hex display.
 */
DISPLAY_HEX:
    ret