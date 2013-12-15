;= Start MACROS.asm ========================================
TX_RUN MACRO
	BIS.B #UCA0TXIE,&IE2 ;Interrupt on transmit buffer empty
 ENDM
 
UART_SYM MACRO P1 ;Substitute required symbol into P1 for sending
	MOV.B P1,&DATA
	CALL #Buff_Push
 ENDM
 
EEWR_PUSH MACRO P1 ;P1 is DATA to push into page write EEPROM buffer
	MOV.B P1,&EEWR_DATA
	CALL #EEWR_BufPush
 ENDM
 
EEPROM_PAGEWRITE MACRO P1 ;Address start(e.g. 0x1E20)
	CLR &EEPROM_CYCLE ;Cycle is 0
	MOV.B #1,&WRITE_OP ;WRITE OP TRUE
	MOV P1,&EEPROM_ADDRESS
	MOV.B &EEWRITE_POINTER,&PAGEWRITE_BYTENUM ;bytes left to transmit equals
;current pointer position
	CLR.B &EEWRITE_POINTER ;pointer is zero
; WARNING!!! Do not use buffer push while EEPROM Page write is in progress
;implement checking write in progress flag for buffer push subroutine
 ENDM
 
EEPROM_SEQREAD MACRO P1,P2 ;Address start (e.g. 0x1E20), Number of bytes to read
;Example: EEPROM_SEQREAD #0x1E10,#16
	CLR &EEPROM_CYCLE ;Cycle is 0
	CLR.B &WRITE_OP ;WRITE OP FALSE
	MOV P1,&EEPROM_ADDRESS
	MOV P2,&SEQREAD_BYTENUM
	BIS.B #UCB0RXIE,&IE2 ;Enable RX interrupt
 ENDM
 
delay MACRO
/*
	PUSH R14
	MOV #0xA5,R14
LB2: ADD #0xFFFF,R14
	JC LB2
	POP R14
*/
	PUSH TEMP
	MOV #0xFFFF, TEMP
	DEC TEMP
	JNZ $-2
	POP TEMP
 ENDM
/*