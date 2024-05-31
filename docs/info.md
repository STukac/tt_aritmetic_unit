<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This is a 16 bit adder and subtractor that can also perform 8 bit by 8 bit multiplication.

## How to test

The IO pins are used to setup the circuit, start it and get feedback:

| C | MODE |  d2  |  d1  | d0 | S | ERR |
|---|------|------|------|----|---|-----|
|   | LDR  | REG1 | REG2 | RW |   |     |
|   | ZBR  |  P   |  N   | UA |   |     |
|   | SUB  |  P   |  N   | UA |   |     |
|   | MUL  |  P   |  N   | F  |   |     |

The direction of the pins changes depending on the mode:
REG, RW, UA are input pins and P, N, F change to output pins.
C, MODE, S are always input pins, while ERR is always an output pin.

C
-
C is used to indicate the usage of two's complement (C = 1, high) for representing negative numbers and must stay unchanged trought all operations until reset. Else it sets ERR to 1 (error ocured, unpredictable result).

MODE
-
MODE is used to change opeations.

| MODE | CODE |
|------|------|
| LDR  |  00  |
| ADD  |  01  |
| SUB  |  10  |
| MUL  |  11  |


LDR
- 
Used to read or write to internal registers for aritmetic operations.
Reg_A is used exclusively used for sotring and it's contents can only be altered manualy or while multiplying (content gets shifted).
Reg_B is used to store the result of the operation and can be used as an operand. Every operation alters it's content.
RW is used to reading (0, low) or write (1, high) to register. Last read register gets stored as the one selected on the output pins and stays so until alterd.

| REG | Chosen register part |
|-----|----------------------|
| 00  |   Reg_A [  7:0 ]     |
| 01  |   Reg_A [ 15:8 ]     |
| 10  |   Reg_B [  7:0 ]     |
| 11  |   Reg_B [ 15:8 ]     |

## External hardware

None
