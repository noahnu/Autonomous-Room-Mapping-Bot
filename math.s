/* Math utility functions. */

.global MATH_CLAMP

/*
 * Function MATH_CLAMP(r4: value, r5: min, r6: max): r2
 * Returns FN_MIN(max, FN_MAX(min, value))
 */
MATH_CLAMP:
    ble r4, r6, MATH_CLAMP_LT_MAX

    /* value > max; clamp: value = max */
    mov r2, r6

MATH_CLAMP_LE_MAX: /* value <= max */
    bge r4, r5, MATH_CLAMP_DONE
    mov r2, r5 /* clamp: value = min */

MATH_CLAMP_DONE:
    /* min <= value <= max */
    ret
