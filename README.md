# CSC385
## Autonomous Room Mapping Bot

__Developed By__

- Noah Ulster (noahnu)

## Description

### Overview

A car drives around a room and sends spatial data to a computer, building a live map of a room.

### Technical

Dimensions of a rectangular "move area" is set using 7 slider switches on the DE1-SOC
board. The segments #5-3 and segments #2-0 display the maximum width and height of
the "move area" respectively in distance units. Slider #9 toggles which dimension to
set (0 = width, 1 = height). Sliders #5-0 are used to select a value for the current dimension.
Push button #0 is used to "save" the value.

Distance units (the granularity the bot "scans" at) may have to be determined
experimentally. We will attempt to use unit = 0.5 cm for a max. area of 256cm x 256cm.

Push button #1 will reset the bot, push button #2 will pause, and push button #3 will
resume. When the bot is reset, it must be placed at coordinate (0,0) (bottom-left), facing the
+y direction. Below describes the bot's behaviour when started (i.e. reset & resumed).

Using PWM with a fixed constant for the modulation interval, the car will drive a steady
speed. This is implemented via a Timer #0 interrupt to ensure precise modulation.

The "move area" or "map" is stored in SDRAM represented by a 512x512 grid of 2 bits
each. Bit 0 indicates the cell has been visited. Bit 1 indicates the cell contains an obstacle.
This grid consumes 64KB of memory. A contiguous chunk is allocated in the "reset" stage.
A pointer references the current cell (position). The car will attempt to traverse the map
by straight lines up-down-up-down, moving to the right when a "move area" edge is reached.

If sensor #0 drops below a threshold, an interrupt will be triggered. The next next cell in the
direction the car is facing will be marked as an obstacle and visited. A target pointer will be
set to the cell directly behind the obstacle. The car will change to "target mode" and will
employ a search algorithm to attempt to reach the target. Whenever the car begins
movement (not including rotation), Timer #1 will start with a constant period. When Timer #1
elapses (interrupt), the car's position pointer advances, the cell is marked as visited with no
obstacle, the new direction is computed, Timer #1 restarts and the car continues movement.
Whenever a cell is marked as visited, a byte containing the position and the obstacle status
is sent via UART to a C program (we poll for available write space and stop movement of
the car until the byte is written). The C program receives the position data with obstacle
status and renders it on the screen (either graphically or with ASCII art).

## System Requirements

- DE1-SOC w/ NIOS II
    - [Docs: Assembler Directives](https://sourceware.org/binutils/docs/as/Pseudo-Ops.html#Pseudo-Ops)
    - [Docs: Instruction Set](http://www-ug.eecg.toronto.edu/desl/manuals/n2cpu_nii51017.pdf)
    - [Docs: Application Binary Interface](https://www.altera.com/content/dam/altera-www/global/en_US/pdfs/literature/hb/nios2/n2cpu_nii51016.pdf)
- Lego Controller w/ sensors and motors

Can also be simulated: http://cpulator.01xz.net

## Architecture

High Level System Block Diagram:

![System Block Diagram](./images/System%20Block%20Diagram.png)

## Challenges

- Movement detection is based on the assumption that while in STATE_MOVE, the car drives at a constant speed with no change in direction. Since the car is attached to the Lego Controller's sensor board, the slightest tension in the 3 wires can cause the robot's position to be out of sync. Since rotation is based on the same principle, each rotation may cause the position to gradually become out of sync.
