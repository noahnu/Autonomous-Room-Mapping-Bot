.include "constants.s"

/* Math utility functions. */

.global MATH_CLAMP
.global RANDOM_BIT

/*
 * Function MATH_CLAMP(r4: value, r5: min, r6: max): r2
 * Returns FN_MIN(max, FN_MAX(min, value))
 */
MATH_CLAMP:
    mov r2, r4
    ble r4, r6, MATH_CLAMP_LE_MAX

    /* value > max; clamp: value = max */
    mov r2, r6

MATH_CLAMP_LE_MAX: /* value <= max */
    bge r4, r5, MATH_CLAMP_DONE
    mov r2, r5 /* clamp: value = min */

MATH_CLAMP_DONE:
    /* min <= value <= max */
    ret

/*
 * Function RANDOM_BIT()
 *
 * Returns (r2) a coin toss.
 */
RANDOM_BIT:
    movia r3, RANDOM_SEED
    ldw r2, 0(r3)

    movia r3, RANDOM_MULTIPLIER
    mul r2, r2, r3

    movia r3, RANDOM_INCREMENT
    add r2, r2, r3

    movia r3, RANDOM_SEED
    stw r2, 0(r3)
    andi r2, r2, 1

    ret