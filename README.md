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

First, I created the locations for where the instructions will be read and where the answers will be written.  I put them in the registers PROG_LOC and MEM_STORE, respectively.  These locations were 0xC000 and 0x0200, respectively.    

Second, what was needed was a way to step through the instructions.  The register PROG_LOC, kept track of the current byte from ROM.  After either a operand or an opcode was read, the number in PROG_LOC, referring to a location in ROM (0xC000), was incremented.  The first operand was stored in a register called FIRST, and the opcode was stored in a register named COMMAND.  

The program then subtracted 0x0011 from the number stored in COMMAND and checked if the answer was zero.  The opcodes for add, subtract, multiply, clear, and end are 0x11, 0x22, 0x33, 0x44, and 0x55, respectively.  It did this continuously until the opcode was determined.  The computer then jumped to the appropriate location in the program to carry out that function.  

###Required Functionality Analyzing
When I was actually making this, however, I tried to collect the SECOND operand before I jumped to the correct operation block of code.  I decided to collect the second operand after I determined the operation in order to simplify the look of the code, and also because not every operation uses byte directly after the command as SECOND.  If the function were CLR, then the next byte would have been FIRST, not SECOND.  Another way I could've done it, I suppose, would be to just make the SECOND register the new FIRST after the CLR command was finished.  However, this did not occur to me until later.  


##Add Construction Process
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

I concluded that my program would work properly for any two hex digits numbers.  Knowing this, I decided to surround this portion of my code with dashes and label it, knowing that everything inside worked correctly.  



##Subtract Construction Process
(Includes debugging, testing, observations, and results)

The same principles were done with subtraction as with addition.  To start off, I just copied my addition code and pasted it below.  Then I just changed the add.b to a sub.b.  After I did this, I decided to experiment with some small tests.  I chose

```
0x11, 0x22, 0x11, 0x55
```
This yeilded zero as expected.  



```
0x16, 0x22, 0x11, 0x55
```

I ran this and got 5, which makes sense.  Then I ran this:


```
0x11, 0x22, 0x12, 0x55
```

This rolled over and resulted in 0xFF, like expected.  This made me wonder if there was some sort of negative carry flag in register 3.  I played the program again, and noticed that one of the flags did change.  The negative flag changed, but only when the answer should have been less than or equal to zero (I tested a lot of subtractions to find this).  This didn't really matter for the required functionality but it sounded pretty important for B functionality.  

##Subtraction Conclusions

I blocked off this code once it was finished so that I knew the code inside the dashes is all that computed subtraction.  The code created from the process above will clearly handle any subtraction correctly that doesn't involve a roll over.  





##Multiplication
Explained in A Funcitonality section, since it is not part of the Required Functionality.  


##Clear (CLR)
If just places the value zero in (0x00) in the destination and clears the value in FIRST. It also increments where the next byte will be read from in ROM (PROG_LOC) and where the next byte will be written (MEM_STORE).  There were no errors with this after the first try.  It is fairly straight forward and only took a few lines of code.  However, a reasonable assumption was made regarding the CLR function, which is described below.  


###Clear Trouble
It occured to me that it would be problematic if a clear was used as the first byte.  Not only does this not make sense, but then the number 0x44 could never be used as the first number to a program.  Therefore, I decided to assume that the command CLR could never happen first in the program.  

After all of the above commands, add, subtract, multiply, and clear, the PROG_LOC was incremented, as was the location that all of the answers are stored, which is held in register MEM_STORE.  



##Error
This is something of my own invention.  I created it so that the user would know if a command was fed into the system wrong or an unknown command was read.  This is also a possible end to the program. 


##End
Just puts the program into an infinite loop.

This marks the end of the Required Functionality and how it was achieved.  




#B Functionality

To achieve B functionality, overflow had to be controlled. If the result exceeded 0xFF, then the answer was 0xFF.  In order to do this, the carry flag was checked, indicating an overflow.  If the result went below 0x00, then the answer 0x00.  In order to do this, the negative flag was checked.  Both the zero and the negative flags are stored in register 3.

Attaining this functionality for addition and subtraction only required small amounts of code.  I will step through the process of creating the code for addition and subtraction separately below. 

##Addition Overflow

First, I realized when I was building the addition code that the carry flag is raised whenever overflow occurs.  This being said, I decided to find a way to check if the carry flag was raised.  I designed the following code for this mini experiment.  

```
		  	  ;check for over 255.
			    mov.w	#ONE, CARRY_REG
			    and.w	NC_FLAG, CARRY_REG
			    jz		no_carry
			    
carry	    jmp   carry

no_carry  jmp no_carry
			
			
```

ONE is the constant #0x0001.  NC_FLAG represents register 3, where the carry flag is located.  CARRY_REG is just a holding register where the calculation will be made.  

The carry flag is the least significant bit.  If it is raised, this bit will be a 1.  Therefore, by anding register 3 with the number 1, the result will be 1 if and only if the carry flag is raised, and thus an overflow has occured.  I then added the ideas from this experiment into my code to meet the requirements for B Functionality.  This can be shown below:

```
			;get second command operand and add to first.
ADD_OP		inc		PROG_LOC
			add.b	0(PROG_LOC), FIRST

			;check for over 255.
			mov.w	#ONE, CARRY_REG
			and.w	NC_FLAG, CARRY_REG
			jz		no_bust_add

			;EXCEEDS 255
			mov.b	#UP_LIMIT, 0(MEM_STORE)
			mov.b #UP_LIMIT, FIRST
			inc		MEM_STORE
			jmp		GET_COM

			;within range
no_bust_add mov.b	FIRST, 0(MEM_STORE)
			inc		MEM_STORE
			jmp		GET_COM
```

The only changes I made were to where the program will jump to.  If it's over 0xFF, or 255, then it will just put 0xFF in memory and make that the new FIRST.  If not, it will make the non-overflow answer FIRST and store that answer.  After either it will return to the top for the next command.  

When I was making this code, I encountered a couple problems. The first was that I would cause my jmps to go to the opposite location that they were supposed to go.  I quickly realized this when I noted that 0x01+ 0x02 is not 0xFF.  I simply made the correction at that point and fixed the code.  Also, I did not notice this until later, mostly because the test cases did not cover this, but the program did not set FIRST equal to 0xFF when an overflow occured.  This is technically right considering 0xFF is the answer to the previous mathematical statement.  This only took one line of code to correct.  

##Subtraction Overflow

To restrict answers to above 0x00, a similar method was used as with the addition code.  The only differences are as follows.  The bit for the negative flag, mentioned in the Required Functionality section, is held in the third least significant bit.  This means the same operation can be performed with the number 0x04, as in the addition overflow determination. 0x04 is 0b00000100.  This was done and it worked correctly the first time, since most of the trouble was found when creating the addition overflow detector.  

This concludes the process, debugging, and results that were done when creating the B Functionality.  


Unfortunately in my program, the overflow control for multiplication does not work.  It does work for addition and subtraction.  

#A Functionality

In order to earn full credit, this method needed to work in log(n) time.  This was done by implementing [Peasant Multiplication](http://www.cut-the-knot.org/Curriculum/Algebra/PeasantMultiplication.shtml). It is explained further in this cite.  The basic principle is that the first number is divided by two repeatedly, which the second number is doubled.  The results from doubling the second number are all added together to get the answer, with the exception of the second numbers that correspond to an even first number.  This means that the answer will be found in log(n) times.  

The multiplication does work, however, it is not compatable with the overflow check in the B functionality.  It will roll over sometimes. 

#Unexpected Problems

#Hardware Schematic
There is no need for a hardware schematic in this lab.  

#Lessons Learned 

1. I never knew peasant multiplication existed before but it makes me excited.  
2. Things stored as .byte variables at the beginning of the code will be save in ROM at 0xC000.  This makes sense, but I never thought of a practical use for it before on my own.  At first I kept typing the answers into a different location in RAM manually, and I'm really glad I don't have to do that anymore.  

The code for the final program may be seen here: 
[Final Code](https://raw.githubusercontent.com/JohnTerragnoli/ECE382_Lab01/master/main.asm)


#Documentation: 
Captain Trimble told me to look on the labs section of the course website to understand how this README should be written.  
