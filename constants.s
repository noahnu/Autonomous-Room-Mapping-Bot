/* ============ CONSTANTS ============ */

.equ SDRAM_END, 0x03FFFFF0
.equ LEGO_CONTROLLER, 0xFF200060
,equ DEFAULT_LEGO_DIRECTION, 0x07F557FF

.equ TIMER_1, 0xFF202000
.equ IRQ_TIMER_1, 0x1
.equ TIMER_2, 0xFF202020
.equ IRQ_TIMER_2, 0x800
.equ HEX_LOWER, 0xFF200020
.equ HEX_UPPER, 0xFF200030
.equ SLIDER_SWITCHES, 0xFF200040
.equ PUSH_BUTTONS, 0xFF200050

.equ PWM_INTERVAL, 262150 /* 2.62ms */
.equ POSITION_TMR_INTERVAL, 100000000 /* 1 second */

/* Direction ENUM */
.equ DIRECTION_POS_X, 3 /* 0b11 */ 
.equ DIRECTION_POS_Y, 2 /* 0b10 */
.equ DIRECTION_NEG_X, 1 /* 0b01 */
.equ DIRECTION_NEG_Y, 0 /* 0b00 */