.equ SDRAM_END, 0x03FFFFF0

.equ LEGO_CONTROLLER, 0xFF200060

.equ TIMER_1, 0xFF202000
.equ IRQ_TIMER_1, 0x1

.equ TIMER_2, 0xFF202020
.equ IRQ_TIMER_2, 0x800

.equ HEX_LOWER, 0xFF200020
.equ HEX_UPPER, 0xFF200030

.equ SLIDER_SWITCHES, 0xFF200040
.equ PUSH_BUTTONS, 0xFF200050

.equ PWM_INTERVAL, 262150 /* 2.62ms */

.text

.global _start
_start:
	/* stack pointer to close to end of SDRAM */
	movia sp, SDRAM_END

	movia r8, LEGO_CONTROLLER
    
	/* default direction register value */
	movia r2, 0x07f557ff
	stwio r2, 4(r8)
  
	/* turn off all motors/sensors */
	movia r2, 0xFA6FFFFF
	stwio r2, 0(r8)

	/* Configure PWM with Timer 1 */
	movia r9, TIMER_1
	movia r2, PWM_INTERVAL
	stwio r2, 8(r9)
	srli r2, r2, 16
	stwio r2, 12(r9)

	/* Enable interrupt for Timer 1 */
	movia r2, IRQ_TIMER_1
	wrctl ctl3, r2

STATE_INITIALIZATION:
	movia r9, TIMER_1

	/* Enable global interrupts. */
	movi r2, 1
	wrctl ctl0, r2

	/* Enable PWM timer. */
	movia r2, 7
	stwio r2, 4(r9)

STATE_ACTIVE:
	br LOOP_FOREVER

LOOP_FOREVER:
	br LOOP_FOREVER

.section .exceptions, "ax"
IHANDLER:
	addi sp, sp, -20
	
	/* Save interrupt data for nested interrupts. */
	stw et, 0(sp)
	rdctl et, ctl1
	stw et, 4(sp)
	stw ea, 8(sp)

	/* Registers we will use. */
	stw r2, 12(sp)
	stw r3, 16(sp)

	/* TODO: save ctl4? */
	rdctl et, ctl4 /* ipending */

/* PWM */
IHANDLER_TIMER_1:
	movia r2, IRQ_TIMER_1
	and r2, r2, et
	beq r2, r0, EXIT_IHANDLER

	/* PWM: Toggle on/off of motor 0. */
	movia r2, LEGO_CONTROLLER
	ldwio r3, 0(r2)
	movia et, 5
	xor r3, r3, et
	stwio r3, 0(r2)

	/* ACK the timeout. */
	movia r2, TIMER_1
	stwio r0, 0(r2)

EXIT_IHANDLER:
	wrctl ctl0, r0

	/* Restore nested interrupt. */
	ldw et, 0(sp)
	ldw r2, 4(sp)
	wrctl ctl1, r2
	ldw ea, 8(sp)
	
	/* Restore registers. */
	ldw r2, 12(sp)
	ldw r3, 16(sp)	

	addi sp, sp, 16

	addi ea, ea, -4
	eret
	