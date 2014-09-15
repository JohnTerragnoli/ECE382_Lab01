Simple Assembly Calculator
==========================
(Lab01)

#Purpose

The purpose for this lab is to create a simple calculator using assembly language.  It will perform the operations of addition, subtraction, multiplication, and clearing, as well as ending the program.  The program will run into an error loop if it is not fed the opcode for one of it's designed operations.  Additionally, when the result of an operation is above or below the range, the computer will record the result as 0xFF and 0x00, respectively, which are the numberical limits of the program.  

The code for the final program may be seen here: 
[Final Code](https://raw.githubusercontent.com/JohnTerragnoli/ECE382_Lab01/master/main.asm)


#Prelab

Below is the flowchart that was drawn before any coding was done.  The purpose for this was to get an idea of how the program would run to avoid confusion during the actual creation of the program.  It is written in pseudocode.  The start of the program is on top and the end of it is on the bottom.  

![alt tag](https://raw.githubusercontent.com/JohnTerragnoli/ECE382_Lab01/master/Flowchart.JPG "Flowchart")

Something not included until the actual construction was the error loop, which is not shown in the prelab flowchart.  The purpose of the error loop is to trap the machine when it is fed a command that it is not built to handle.  This way, the user can understand right away the nature of the problem that has occured and at what location, using the step command.  

#Required Functionality

For the required funcitonality the program had to be able to perform the following commands: Add, subtract, clear (which places 00 in the destination), and end (which just ends the program).  The descripion for how each is shown below: 

First, what was needed was a way to step through the instructions.  The register PROG_LOC, kept track of the current byte from memory.  After either a operand or an opcode was read, the number in PROG_LOC, referring to a location in ROM (0xC000), was incremented.  The first operand was stored in a register called FIRST, and the opcode was stored in a register named COMMAND.  

The program then subtracted 0x0011 from the number stored in COMMAND and checked if the answer was zero.  The opcodes for add, subtract, multiply, clear, and end are 0x11, 0x22, 0x33, 0x44, and 0x55, respectively.  It did this continuously until the opcode was determined.  The computer then jumped to the appropriate location in the program to carry out that function.  

###Required Functionality Analyzing
When I was actually making this, however, I tried to collect the SECOND operand before I jumped to the correct operation block of code.  I decided to collect the second operand after I determined the operation in order to simplify the look of the code, and also because not every operation uses byte directly after the command as SECOND.  If the function were CLR, then the next byte would have been FIRST, not SECOND.  Another way I could've done it, I suppose, would be to just make the SECOND register the new FIRST after the CLR command was finished.  However, this did not occur to me until later.  

##Add
This was my main idea when I first started out.  The second operand was then found and stored in the register named SECOND. Registers FIRST and SECOND were then added together and stored in FIRST.  The result was recorded and stored as the desired location in memory (0x0200).

###Add Construction Process
(Includes debugging, testing, observations, and results)
The test that I first used to determine the effectiveness of my code was this: 

```
0x11, 0x11, 0x11, 0x55
```

Running this code the program ran perfectly, reading 0x22 in 0x0200.  Then I tried this code: 

```
0x11, 0x11, 0x11, 0x11, ,0x11, 0x55
```

For which the answer should have been 0x22, 0x33 in 0x0200.  However, I came up with 0x33.  I quickly realized that this was because I did not increment the register holding the address to which the answer should be written.  This means the second answer was just overwriting the first.  

Also, I figured that it would be easier to just add the second number stored in ROM directly to FIRST, instead of first putting it in SECOND.  This is because the answer to the first operation becomes the FIRST number in the next operation.  

Next I tried my first test to ensure that my program still worked, and it did. 

Then, I used two numbers that would make the system roll over.  I chose: 

```
0xFF, 0x11, 0x02, 0x55
```

I was not sure if I would have to do something extra to make sure that it rolled over, so I just tested it anyway.  Turns out that I didn't, however, I noticed that when it rolled over the carry flag in register 3 was raised.  I just remembered this for now and realized it would come in handy for the B Functionality.  

###Add Conclusions





##Subtract
Same principle was used as with add, except SECOND was subtracted from FIRST. 

##Multiplication
Explained in A Funcitonality section.  


##Clear (CLR)
If just places the value zero in (0x00) in the destination and clears the value in FIRST. 

###Clear Trouble
It occured to me that it would be problematic if a clear was used as the first byte.  Not only does this not make sense, but then the number 0x44 could never be used as the first number to a program.  Therefore, I decided to assume that the command CLR could never happen first in the program.  

After all of the above commands the PROG_LOC was incremented, as was the location that all of the answers are stored, which is held in register MEM_STORE.  

##End
Just puts the program into an infinite loop.  





#B Functionality

To achieve B functionality, overflow had to be controlled. If the result exceeded 0xFF, then the answer was 0xFF.  In order to do this, the carry flag was check, indicating an overflow.  If the result went below 0x00, then the answer 0x00.  In order to do this, the negative flag was checked.  Both the zero and the negative flags are stored in register 3.  

Unfortunately in my program, the overflow control for multiplication does not work.  It does work for addition and subtraction.  

#A Functionality

In order to earn full credit, this method needed to work in log(n) time.  This was done by implementing [Peasant Multiplication](http://www.cut-the-knot.org/Curriculum/Algebra/PeasantMultiplication.shtml). It is explained further in this cite.  The basic principle is that the first number is divided by two repeatedly, which the second number is doubled.  The results from doubling the second number are all added together to get the answer, with the exception of the second numbers that correspond to an even first number.  This means that the answer will be found in log(n) times.  

The multiplication does work, however, it is not compatable with the overflow check in the B functionality.  It will roll over sometimes. 

#Unexpected Problems


#Lessons Learned 

1. I never knew peasant multiplication existed before but it makes me excited.  
2. Things stored as .byte variables at the beginning of the code will be save in ROM at 0xC000.  This makes sense, but I never thought of a practical use for it before on my own.  

The code for the final program may be seen here: 
[Final Code](https://raw.githubusercontent.com/JohnTerragnoli/ECE382_Lab01/master/main.asm)


#Documentation: 
NONE
