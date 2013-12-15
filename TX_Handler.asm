;=  TX_INTERRUPT HANDLER========================================
;The I2C transmit and receive interrupt flags UCBxTXIFG and UCBxRXIFG from
;USCI_Bx and UCAxTXIFG from USCI_Ax share another interrupt vector.
;UCBxTXIFG Transmit Interrupt flag
;UCBxRXIFG Receive Interrupt flag

TRANSMIT: BIT.B #UCA0TXIFG,&IFG2 ; USCI_A0 Transmit Interrupt?
  JNZ UART_TX ;UART handler
I2C_DATA: BIT.B #UCB0RXIFG,&IFG2 ;I2C_RX Interrupt?
  JNZ I2C_RX ;Yes, jump

;= I2C_TX Handler ========================================
I2C_TX: ;none of the above, ergo interrupt is I2C_TX
	ADD &EEPROM_CYCLE,PC
	JMP HIGH_ORDER
	JMP LOW_ORDER
	JMP DATA_BYTE
	JMP TERMINATE
	RETI ;just in case

HIGH_ORDER: MOV.B #1<<1,&EEPROM_CYCLE ;first cycle OK
  MOV.B &EEPROM_ADDRESS+1,&UCB0TXBUF ;HIGH ORDER BYTE of address
  RETI
LOW_ORDER:  MOV.B #2<<1,&EEPROM_CYCLE ;second cycle OK
  MOV.B &EEPROM_ADDRESS,&UCB0TXBUF ;LOW ORDER BYTE of address
  RETI
  
DATA_BYTE:	 TST.B &WRITE_OP ;READOP?
	JZ READINIT ;Indeed it is
	
	TST.B &PAGEWRITE_BYTENUM ;anything to transmit?
	JZ EXIT_WRITE ;nope, exit to termination
	
	PUSH TEMP ;yep, pushing TEMP
	MOV.B &EEWRITE_POINTER,TEMP ;moving pointer to TEMP
	ADD #PAGEWRITE_DATA,TEMP ;add PAGEWRITE_DATA address and pointer to obtain
	;current buffer write position
	MOV.B @TEMP,&UCB0TXBUF ;transmitting
	INC.B &EEWRITE_POINTER ;incrementing pointer
	DEC.B &PAGEWRITE_BYTENUM ;decrementing number of bytes left to transmit
	POP TEMP
	RETI
	
EXIT_WRITE: MOV.B #3<<1,&EEPROM_CYCLE ;third cycle OK
	CLR.B &EEWRITE_POINTER
	RETI
  
TERMINATE:  TERMINATE: BIS.B #UCTXSTP,&UCB0CTL1 ;sending stop condition, initiate writing
	BIC.B #UCB0TXIE,&IE2 ;Disable TX interrupt
	BIC.B #UCB0TXIFG,&IFG2 ;Clear TX Flag
	MOV.B #0xA,&EEPROM_CYCLE ;special code to signify successful write cycle
	RETI

READINIT: ;MOV.B #3<<1,&EEPROM_CYCLE ;third cycle OK -IRRELEVANT for READ cycle
	BIC.B #UCTR,&UCB0CTL1 ;receiver mode
	BIS.B #UCTXSTT,&UCB0CTL1 ;generating start condition
	BIC.B #UCB0TXIFG,&IFG2 ;Clear TX Flag
	RETI
;= I2C_RX Handler ========================================
I2C_RX: ; I2C Receive event
;IMPLEMENT CRITICAL BUG FIX from ERRATA
	TST SEQREAD_BYTENUM ;Any bytes left to read?
	JZ EXIT_READ ;no, terminate session
	
	PUSH TEMP ;yes, proceed
	MOV &EEREAD_POINTER,TEMP ;moving pointer to TEMP
	
	ADD #SEQREAD_DATA,TEMP ;add SEQREAD_DATA address and pointer to obtain
	;current buffer write position
	
	MOV.B &UCB0RXBUF,0(TEMP) ;saving read data into said position
	POP TEMP
	
SRE: INC EEREAD_POINTER ;incrementing pointer
	DEC SEQREAD_BYTENUM ;decrementing bytes left to read
	RETI
	
EXIT_READ: BIS.B #UCTXSTP,&UCB0CTL1 ;NACK+STP
	BIC.B #UCB0RXIE,&IE2 ;Disable RX interrupt
	BIC.B #UCB0RXIFG,&IFG2 ;Clear RX Flag
	MOV.B #0xB,&EEPROM_CYCLE ;special code to signify successful read cycle
	CLR &EEREAD_POINTER ;blank EEPROM read pointer
	;removing CLR op allows to continue filling the buffer with the next seqread op
	RETI
	
;=  UART_TX HANDLER========================================
;BEWARE, USES TEMP, no PUSH/POP!!!
;~39 cycles

UART_TX: CMP.B #1,&OUT_FULL ;checking overflow flag
  JEQ NeedSend
  
  CMP.B &OUT_PTR_S,&OUT_PTR_E ;OUT_PTR_S=OUT_PTR_E?
  JNE NeedSend ;buffer is not empty, jump
  
  ;Yes, ergo buffer is empty
  BIC.B #UCA0TXIE,&IE2 ;interrupt on empty TX buffer is disabled
  BIC.B #UCA0TXIFG,&IFG2 ;Clear TXIFG flag
  JMP TX_OUT
  
NeedSend: CLR.B &OUT_FULL  ;overflow flag clear

  MOV.B &OUT_PTR_S,TEMP ;move content of OUT_PTR_S to READ INCREMENTA STORAGE REGISTER
  
  ADD #OUT_buff,TEMP ;add READ INCREMENTA with OUT_buff to obtain current read position READPOINT
  
  MOV.B @TEMP,&UCA0TXBUF ;sending READPOINT content into TX buffer
  
  INC.B &OUT_PTR_S ;incrementing READ INCREMENTA STORAGE REGISTER
  
  CMP.B #MAXBUFF_OUT,&OUT_PTR_S
  JNE TX_OUT
  
  CLR.B &OUT_PTR_S
  
TX_OUT: RETI
  
;=  TX_INTERRUPT HANDLER========================================