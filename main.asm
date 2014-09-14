;-------------------------------------------------------------------------------
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
;-------------------------------------------------------------------------------
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
;MEM:		.equ	0x0200; where actually stored in mem.
;PROG:		.equ	0x0300; where program is actually being read from in memory.

RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;-------------------------------------------------------------------------------
                                            ; Main loop here
;-------------------------------------------------------------------------------
;BFunctionality:	.byte	0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0xDD, 0x44, 0x08, 0x22, 0x09, 0x44, 0xFF, 0x22, 0xFD, 0x55




;READ FROM ROM (0xCOOO-OxFFDF)
;------------------------------------------------------------------------
;			mov.w	BFunctionality, PROG_LOC



;designtate where saving will occur
			mov.w	#0x0200, MEM_STORE

;RECEIVING FIRST INSTRUCTION
			mov.w	#0x0340, PROG_LOC
GET_FIRST	mov.b	0(PROG_LOC), FIRST

GET_COM		inc		PROG_LOC
			mov.b	0(PROG_LOC), COMMAND


;------------------------------------------------------------------------
;DETERMINE THE OPERATION
			sub.w 	#0x0011, COMMAND
			jz		ADD_OP
			sub.w	#0x0011, COMMAND
			jz		SUB_OP
			sub.w	#0x0011, COMMAND
			jz		multiply
			sub.w	#0x0011, COMMAND
			jz		CLR_OP
			sub		#0x0011, COMMAND
			jz		forever

			jmp 	error
;catch if the command given isn't known by the system!!
;------------------------------------------------------------------------


;------------------------------------------------------------------------
;add the first and second numbers and store in the first number space :)

			;get second command operand and add to first.
ADD_OP		inc		PROG_LOC
			add.b	0(PROG_LOC), FIRST

			;check for over 255.
			mov.w	#0x0001, CARRY_REG
			and.w	NC_FLAG, CARRY_REG
			jz		no_bust_add

			;EXCEEDS 255
			mov.b	#0xFF, 0(MEM_STORE)
			inc		MEM_STORE
			jmp		GET_COM


no_bust_add mov.b	FIRST, 0(MEM_STORE)
			inc		MEM_STORE
			jmp		GET_COM
;------------------------------------------------------------------------





;------------------------------------------------------------------------
SUB_OP		inc		PROG_LOC
			sub.b	0(PROG_LOC), FIRST

			;first check neg flag.
			mov.w	NC_FLAG, NEG_REG
			and.w	#0x0003, NEG_REG
			jz		bust_low

no_low		mov.b	FIRST, 0(MEM_STORE)
			inc		MEM_STORE
			jmp		GET_COM


			;if bust range low
bust_low	mov.b	#0x00, 0(MEM_STORE)
			inc		MEM_STORE
			jmp		GET_COM


;------------------------------------------------------------------------


;------------------------------------------------------------------------
multiply
			mov.w	#0x0000, MUL_TOTAL; reset

			;GET SECOND OPERAND
			inc		PROG_LOC
			mov.b	0(PROG_LOC), SECOND

			jmp 	START_MUL

stillThere	rra		FIRST
			rla		SECOND

			;test if the one in 14 is even.
			;r15 used to check if even
START_MUL	mov.w	FIRST, HOLDER
			and.w	#0x0001, HOLDER
			;skip adding step if even
			jz		do_not_add
			add.w	SECOND, MUL_TOTAL

			;check for over 255.
;			mov.w	#0x0001, CARRY_REG
;			and.w	NC_FLAG, CARRY_REG
;			jz		bust_mul



do_not_add	add.w	#0x0000, FIRST
			jz		save_prod
			jmp 	stillThere

			;answer=new first
save_prod	mov.w	MUL_TOTAL, FIRST



store_prod	mov.b	FIRST, 0(MEM_STORE)
			inc		MEM_STORE

			jmp		GET_FIRST

;bust_mul	mov.w	#0xFF, FIRST
;			jmp		store_prod

;------------------------------------------------------------------------S







;------------------------------------------------------------------------
CLR_OP		mov.b	#0x00, 0(MEM_STORE)
			inc		MEM_STORE
			inc		PROG_LOC
			jmp		GET_FIRST
;------------------------------------------------------------------------

error		jmp 	error

forever		jmp		forever












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
