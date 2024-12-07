# Snake Game

## Overview
The Snake Game is a classic arcade game implemented in assembly language for the 16-bit Stump processor.

## Features
- Dynamic gameplay with a snake that grows as it consumes food.
- Collision detection.
- Real-time score updates.
- Simple graphics displayed on an 8x8 LED matrix.

## Constraints of the Stump Processor
The development of this game was guided by the following constraints imposed by the 16-bit Stump processor:

### Instruction Set
- The Stump processor supports the following operations:
  - **Data Operations**: ADD, ADC, SUB, SBC, AND, OR, with optional immediate values.
  - **Memory Transfers**: LD (load) and ST (store) with addressing modes including register direct, immediate offsets, and labels.
  - **Control Transfers**: Conditional and unconditional branch instructions, e.g., BEQ, BNE, BGE, BLT, etc.
  - **Pseudo-Operations**: MOV, CMP, TST, implemented as combinations of basic instructions.

### Immediate Values
- Immediate values in instructions are limited to 16 bits.

### Memory Map
- Peripherals are memory-mapped starting from address `FF00`. The game uses the following peripherals:
  - **8x8 LED Matrix**: Address range `FF00-FF3F` for displaying the game grid.
  - **Buttons and Switches**: Address `FF91` for player inputs.

### Hardware Constraints
- The processor has limited register and memory resources, requiring efficient use of registers and stack management.
- The system uses a 16-bit free-running counter at address `FFA4` for timing purposes.

## Installation
1. Clone the repository containing the game source code:
2. Assemble the code using the Stump assembler provided in your development environment.
3. Load the assembled binary onto the Spartan 6 board.
4. Start the game by executing the loaded program.

## How to Play
- Use the buttons on the Spartan 6 board to control the direction of the snake.
- Guide the snake to consume the food that appears on the grid.
- Avoid collisions with the walls and the snake's own body.
  
## Acknowledgments
This project was developed as part of the COMP22111 coursework, exploring the use of assembly programming for the Stump processor and its associated peripherals.

---

For any questions or support, please contact [Serhii Tupikin](sergey.st265@gmail.com).
