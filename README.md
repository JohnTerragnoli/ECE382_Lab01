ECE382_Lab01
============

#Purpose

The purpose for this lab is to create a simple calculator using assembly language.  It will perform the operations of addition, subtraction, multiplication, and clearing, as well as ending the program.  The program will run into an error loop if it is not fed the opcode for one of it's designed operations.  Additionally, when the result of an operation is above or below the range, the computer will record the result as 0xFF and 0x00, respectively, which are the numberical limits of the program.  


#Prelab

Below is the flowchart that was drawn before any coding was done.  The purpose for this was to get an idea of how the program would run to avoid confusion during the actual creation of the program.  It is written in pseudocode.  The start of the program is on top and the end of it is on the bottom.  

![alt tag](https://raw.githubusercontent.com/JohnTerragnoli/ECE382_Lab01/master/Flowchart.JPG "Flowchart")

#Required Functionality

For the required funcitonality the program had to be able to perform the following commands: Add, subtract, clear (which places 00 in the destination), and end (which just ends the program).  The descripion for how each is shown below: 

First, what was needed was a way to step through the instructions.  The register PROG_LOC, kept track of the current byte from memory.  After either a operand or an opcode was read, the number in PROG_LOC, referring to a location in ROM (0xC000), was incremented.  The first operand was stored in a register called FIRST, and the opcode was stored in a register named COMMAND.  

The program then subtracted 0x0011 from the number stored in COMMAND and checked if the answer was zero.  The opcodes for add, subtract, multiply, clear, and end are 0x11, 0x22, 0x33, 0x44, and 0x55, respectively.  It did this continuously until the opcode was determined.  The computer then jumped to the appropriate location in the program to carry out that function.  

##Add
The second operand was then found and stored in the register named SECOND. Registers FIRST and SECOND were then added together and stored in FIRST.  The result was recorded and stored as the desired location in memory (0x0200).

Fortunately, this was easy!

##Subtract
Same principle was used as with add, except SECOND was subtracted from FIRST. 

##Multiplication
Explained in A Funcitonality section.  


##Clear (CLR)
If just places the value zero in (0x00) in the destination and clears the value in FIRST. 

Easy stuff.  


After all of the above commands the PROG_LOC was incremented, as was the location that all of the answers are stored, which is held in register MEM_STORE.  

##End
Just puts the program into an infinite loop.  





#B Functionality

#A Functionality

#Lessons Learned 

The code for the final program may be seen here: 
[Final Code](https://raw.githubusercontent.com/JohnTerragnoli/ECE382_Lab01/master/main.asm)
