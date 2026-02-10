; Demo Program - using timer interrupts.
; Written for ADuC841 evaluation board, with UCD extras.
; Generates a square wave on P3.6.
; Brian Mulkeen, September 2016

; Include the ADuC841 SFR definitions
$NOMOD51			; for Keil uVision - do not pre-define 8051 SFRs
$INCLUDE (MOD841)	; load this definition file instead

LED		EQU	P0
SOUND 	EQU P3.6
BIG_LED		EQU	P3.4		; P3.4 is red LED on eval board
CHECK	EQU P3.5
BUTTON 	EQU	P3.2
STEP	DATA 30h

;____________________________________________________________________
		; MAIN PROGRAM
CSEG	
		ORG	0000h		; starting at address 0
		JMP MAIN
		
		ORG 002Bh
		JMP TF2ISR
		
		ORG 0060h
MAIN:	
		MOV T2CON, #0h
		
		MOV RCAP2H, #0ffh
		MOV RCAP2L, #01dh
		MOV TH2, #0ffh
		MOV TL2, #01dh
		
		MOV IE, #0A0h
		SETB TR2
		
		MOV R1, #00h
		MOV P2, #01h
		
LOOP:
		MOV A, P2
		ANL A, #07h
		MOV R0, A
		
		MOV DPTR, #LED_LUT
		MOV A, R0
		MOVC A, @A+DPTR
		CPL A
		MOV P0, A
		
		MOV DPTR, #FREQ_LUT
		MOV A, R0
		MOVC A, @A+DPTR
		MOV STEP, A
		
		CALL DELAY
		JMP LOOP

DELAY:
		MOV R5, #10
DLY2:	MOV	R6, #255		; set number of repetitions for outer loop
DLY1:	MOV	R7, #255		; inner loop repeats 255 times
		DJNZ 	R7, $		; inner loop 255 x 3 cycles = 765 cycles  
		DJNZ	R6, DLY1		; + 5 to reload, x 144 = 110880 cycles
		;Read state of button every 20ms to avoid jump
		XCH A, BUTTON
		JNZ button, LOOP
		XCH A, BUTTON
		
		DJNZ	R5, DLY2
		CPL BIG_LED
		RET		; return from subroutine*/
		
TF2ISR:
		PUSH ACC
		
		MOV A, STEP
		ADD A, R1
		MOV R1, A
		
		JNC NO_OVF
		
		MOV R1, #00h
		CPL SOUND
		
NO_OVF: 
		CLR TF2
		
		POP ACC
		RETI
		
LED_LUT: DB 01h, 02h, 04h, 08h, 10h, 20h, 40h, 80h
FREQ_LUT: DB 0ch, 011h, 013h, 019h, 01dh, 01fh, 0Fh, 010h 			
END		
