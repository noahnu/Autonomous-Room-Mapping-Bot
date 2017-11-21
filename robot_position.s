.include "constants.s"

.global GET_NEXT_CELL

/*
 * Function GET_NEXT_CELL(position, direction)
 * 
 * Given a position (pointer to cell on grid) and a direction
 * in which the robot is facing, return the next position the
 * robot will be in if the direction does not change.
 */
GET_NEXT_CELL:
    ret