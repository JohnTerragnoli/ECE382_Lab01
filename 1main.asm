;Author: John Terragnoli
;Project: Simple Assembly Calculator (Lab01)
;Period: T5A
;Teacher: Captain Trimble
;Date Started: 9 SEP 14
;Date Finished: 16 SEP 14
;Description: Intakes bytes from ROM (0xC000) that act as instructions for computing addition,
;subtraction, multiplication, clearing, and ending the program.  The program then
;writes the answers in memory at 0x0200.
;Inputs: Instructions from ROM (0xC000)
;Outputs: mathematical answers in memory (0x0200)
;Registers Destroyed: r5-r15
;-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file

;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section
            .retainrefs                     ; Additionally retain any sections
                                            ; that have references to current
                                            ; section
--------------------------------------------------------------------------------

NegativePR	.byte	0x16, 0x22, 0x14, 0x55
;addingTest	.byte	0xFF, 0x11, 0x02, 0x11, 0x03, 0x55
;which ever functionality you want to run, just comment out the other functionalities :)
;AFunctionality: .byte	0x22, 0x11, 0x22, 0x22, 0x33, 0x33, 0x08, 0x44, 0x08, 0x22, 0x09, 0x44, 0xFF, 0x11, 0xFF, 0x44, 0xCC, 0x33, 0x02, 0x33, 0x00, 0x44, 0x33, 0x33, 0x08, 0x55
;BFunctionality:	.byte	0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0xDD, 0x44, 0x08, 0x22, 0x09, 0x44, 0xFF, 0x22, 0xFD, 0x55
;RequiredFuntionality: .byte	0x11, 0x11, 0x11, 0x11, 0x11, 0x44, 0x22, 0x22, 0x22, 0x11, 0xCC, 0x55

--------------------------------------------------------------------------------



;CONSTANTS
STORE_NUM:	.equ	0x0200
WHICH_OP:	.equ	0x0011
ONE:		.equ	0x0001
UP_LIMIT:	.equ	0xFF
READ_NUM:	.equ	0xC000
FOUR:		.equ	0x0004
ZERO_B:		.equ	0x00
ZERO_W:		.equ	0x0000



;REGISTERS
NC_FLAG:	.equ	r2 ;register used to determine carry
PROG_LOC:	.equ	r5 ;where the program is reading from in ROM
FIRST:		.equ	r6 ;where the first number in the command is stored.
COMMAND:	.equ	r7 ;where the operand of the command is stored.
SECOND:		.equ	r8 ;where the second number in the command is stored.
MEM_STORE:	.equ	r9 ;the address of where the answers are currently begin stored.
CARRY_REG: 	.equ	r10 ; register where carry info is held.
NEG_REG:	.equ	r11 ; register
MUL_HOLD:	.equ	r12;
MUL_TOTAL:	.equ	r13; final result
FIRST_Q:	.equ	r14; first repition of multiplication?
HOLDER:		.equ	r15; holder for multiplication

RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
                                            ; Main loop here
;-------------------------------------------------------------------------------

;designtate where saving will occur
			mov.w	#STORE_NUM, MEM_STORE

;RECEIVING FIRST INSTRUCTION
			mov.w	#READ_NUM, PROG_LOC
GET_FIRST	mov.b	0(PROG_LOC), FIRST

GET_COM		inc		PROG_LOC
			mov.b	0(PROG_LOC), COMMAND


;------------------------------------------------------------------------
;DETERMINE THE OPERATION
			sub.w 	#WHICH_OP, COMMAND
			jz		ADD_OP
			sub.w	#WHICH_OP, COMMAND
			jz		SUB_OP
			sub.w	#WHICH_OP, COMMAND
			jz		multiply
			sub.w	#WHICH_OP, COMMAND
			jz		CLR_OP
			sub		#WHICH_OP, COMMAND
			jz		end

			jmp 	error
;catch if the command given isn't known by the system!!
;------------------------------------------------------------------------


;------------------------------------------------------------------------
;add the first and second numbers and store in the first number space :)

			;get second command operand and add to first.
ADD_OP		inc		PROG_LOC
			add.b	0(PROG_LOC), FIRST

			;check for over 255.
			mov.w	#ONE, CARRY_REG
			and.w	NC_FLAG, CARRY_REG
			jz		no_bust_add

			;EXCEEDS 255
			mov.b	#UP_LIMIT, 0(MEM_STORE)
			mov.w	#UP_LIMIT, FIRST
			inc		MEM_STORE
			jmp		GET_COM

			;within range
no_bust_add mov.b	FIRST, 0(MEM_STORE)
			inc		MEM_STORE
			jmp		GET_COM
;------------------------------------------------------------------------





;------------------------------------------------------------------------
SUB_OP		inc		PROG_LOC
			sub.b	0(PROG_LOC), FIRST

			;first check neg flag.
			mov.w	NC_FLAG, NEG_REG
			and.w	#FOUR, NEG_REG
			jz		no_bust

			;if below range
			mov.b	#ZERO_B, 0(MEM_STORE)
			inc		MEM_STORE
			jmp		GET_COM

			;within range
no_bust		mov.b	FIRST, 0(MEM_STORE)
			inc		MEM_STORE
			jmp		GET_COM
;-----------------------------------------------------------------------





;------------------------------------------------------------------------
multiply	;peasant multiplication
			mov.w	#ZERO_W, MUL_TOTAL; reset where product is stored.

			;GET SECOND OPERAND
			inc		PROG_LOC
			mov.b	0(PROG_LOC), SECOND

			jmp 	START_MUL

stillThere	rra		FIRST
			rla		SECOND

			;test if the one in 14 is even.
START_MUL	mov.w	FIRST, HOLDER
			and.w	#ONE, HOLDER
			;skip adding step if even
			jz		do_not_add
			add.w	SECOND, MUL_TOTAL

			;check for over 255.
;			mov.w	#0x0001, CARRY_REG
;			and.w	NC_FLAG, CARRY_REG
;			jz		bust_mul



do_not_add	add.w	#ZERO_W, FIRST
			jz		save_prod
			jmp 	stillThere

			;answer=new first
save_prod	mov.w	MUL_TOTAL, FIRST



store_prod	mov.b	FIRST, 0(MEM_STORE)
			inc		MEM_STORE

			jmp		GET_FIRST

;bust_mul	mov.w	#0xFF, FIRST
;			jmp		store_prod

;------------------------------------------------------------------------





;------------------------------------------------------------------------
CLR_OP		mov.b	#ZERO_B, 0(MEM_STORE)
			inc		MEM_STORE
			inc		PROG_LOC
			jmp		GET_FIRST
;------------------------------------------------------------------------



error		jmp 	error

end			jmp		end

;-------------------------------------------------------------------------------
;           Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect 	.stack

;-------------------------------------------------------------------------------
;           Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
