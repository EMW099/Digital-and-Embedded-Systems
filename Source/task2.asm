; Demo Program - using timer interrupts.
; Written for ADuC841 evaluation board, with UCD extras.
; Generates a square wave on P3.6.
; Brian Mulkeen, September 2016

; Include the ADuC841 SFR definitions
$NOMOD51
$INCLUDE (MOD841)
	
SOUND	EQU  	P3.6		; P3.6 will drive a transducer

CSEG
		ORG		0000h		; set origin at start of code segment
		JMP		MAIN		; jump to start of main program
		
		ORG		002Bh		; Timer 2 overflow interrupt address
		JMP		TF2ISR		; jump to interrupt service routine

		ORG		0060h		; set origin above interrupt addresses	
MAIN:	
; ------ Setup part - happens once only ----------------------------
        ; timer2 config
		; Need to find what the actual desired value of reload is
        MOV     RCAP2H, #0DCh   ; reload high
        MOV     RCAP2L, #0CDh    ; reload low
        MOV     TH2,    #0DCh   ; counter high
        MOV     TL2,    #0CDh    ; counter low 

        CLR     TF2             ; clear timer2 overflow flag
        CLR     EXF2            ; clear timer2 external flag

		; Timer 2 config start time counter only thing to set to 1 
		; TF2 EXF2 RCLK TCLK EXEN2 TR2 C/T2 CP/RL2 
		; 0   0    0    0    0     1   0    0
        MOV     T2CON,  #04h    ;
        SETB    ET2             ; enable Timer2 interrupt
        SETB    EA              ; global enable


; ------ Loop forever (in this example, doing nothing) -------------
LOOP:	NOP					; this does nothing, uses 1 clock cycle
		JMP		LOOP		; repeat - waiting for interrupt

		
; ------ Interrupt service routine ---------------------------------	
TF2ISR:		; Timer 0 overflow interrupt service routine
		CLR TF2				; reset overflow flag
		CPL		SOUND		; change state of output pin
		RETI				; return from interrupt
; ------------------------------------------------------------------	
		
END
	
/*
;********************************************************************
; Example program for Analog Devices EVAL-ADuC841 board.
; Based on example code from Analog Devices, 
; author        : ADI - Apps            www.analog.com/MicroConverter
; Date          : October 2003
;
; File          : blink.asm
;
; Hardware      : ADuC841 with clock frequency 11.0592 MHz
; Description   : Blinks LED on port 3 pin 4 continuously.
;                 400 ms period @ 50% duty cycle.
;
;********************************************************************

$NOMOD51			; for Keil uVision - do not pre-define 8051 SFRs
$INCLUDE (MOD841)	; load this definition file instead

LED		EQU	P3.4		; P3.4 is red LED on eval board

;____________________________________________________________________
		; MAIN PROGRAM
CSEG	
		ORG	0000h		; starting at address 0
		MOV	A, #020	; set delay length for 200 ms
		MOV R1, #00000001b
BLINK:	CPL	LED     	; change state of red LED
		CALL	DELAY   	; call software delay routine
		JMP	BLINK   	; repeat indefinately
		MOV A, P3
;____________________________________________________________________
		; SUBROUTINES
DELAY:	; delay for time A x 10 ms.  A is not changed. 
		MOV	R5, A		; set number of repetitions for outer loop
DLY2:	MOV	R6, #144		; middle loop repeats 144 times         
DLY1:	MOV	R7, #255		; inner loop repeats 255 times      
		DJNZ	R7, $		; inner loop 255 x 3 cycles = 765 cycles            
		DJNZ	R6, DLY1		; + 5 to reload, x 144 = 110880 cycles
		DJNZ	R5, DLY2		; + 5 to reload = 110885 cycles = 10.0264 ms
		RET				; return from subroutine
		
LOOKUP: XCH A, R1
		RL A
		MOV P3, A
		XCH A, R1
		RET
END
*/
	
	