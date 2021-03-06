# Changelog

Nov 14 (In Lab)
- Noah & Sajid:
    - Discussed and settled on a design and how we would implement it.
    - Implemented PWM for motors.
    - Implemented interrupt handler for timer.

Nov 17
- Noah: Added position timer (Timer 2) to interrupt handler. 

Nov 21 (Before Lab)
- Noah: Improved code/project structure for better modularity.
- Noah: Added state change logic (making use of a sort of finite state machine) to position timer interrupt.
- Noah: Re-designed how part of the state transition works and how the sensors will be implemented (potentially).

Nov 21 (In Lab)
- Added grid positioning system and associated functions.
- Added directions.

Nov 27
- Added 7 segment display functions.
- Added UART

Nov 28 (Before Lab)
- Fixed 7 segment.
- Fixed/debugged/tested quite a bit of older code.
- send position function
- did research prep for C program

Nov 28 (In Lab)
- Corrected some bugs.
- Added check for obstacles.

Dec 4
- fixed some bugs in positioning system
- added out of bounds error handling to obstacle function
- added rotations upon obstacle encounter
- added random bit generator

Dec 5 (Before Lab)
- made grid size entirely dependent on constant's value
- added "step-through" option on PUSH[1]
