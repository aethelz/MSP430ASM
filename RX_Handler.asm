;=  RX_INTERRUPT HANDLER ========================================
;In I2C mode the state change interrupt flags
;UCSTTIFG, UCSTPIFG, UCIFG, UCALIFG from USCI_Bx and UCAxRXIFG from USCI_Ax are routed to
;one interrupt vector.
;UCSTTIFG Start condition interrupt flag
;UCSTPIFG Stop condition interrupt flag
;UCNACKIFG  Not-acknowledge received interrupt flag
;UCALIFG Arbitration lost interrupt flag

RECIEVE:  BIT.B #UCA0RXIFG,&IFG2 ; USCI_A0 Receive Interrupt?
  JNZ UART_RX

;= I2C HANDLER ========================================
; Interrupt is not UART related, ergo it is I2C, decode futher if necessary

I2C_STATE: BIT.B #UCNACKIFG,&UCB0STAT ;checking whether it's a NACK event
  JZ RESERVED

;= NACK ========================================
;UCNACKIFG is not zero, ergo it is a NACK event
;Reset TXIFG in software within the NACKIFG interrupt service routine
;the TXIFG is not reset after a NACK is received if the master is
;configured to send a restart (UCTXSTT=1 & UCTXSTP=0). (see Errata)
	JMP $
	BIS.B #UCTXSTP,&UCB0CTL1 ;sending stop condition
	RETI

;= RESERVED ========================================
RESERVED:  NOP ;RESERVED for UCSTTIFG, UCSTPIFG, UCALIFG decoding
  RETI

;=  UART_RX HANDLER ========================================
UART_RX: XOR.B #BIT0,&P1OUT ;strobe red diode
  MOV.B &UCA0RXBUF,&UCA0TXBUF ;echo input
  RETI
  
;=  RX_INTERRUPT HANDLER ========================================
	

	

;= TRAPINT_INTERRUPT HANDLER ========================================
;ERRATA INTERRUPT VECTOR ADDITION
TRAPINT: NOP ;see errata for more info
	RETI
;= TRAPINT_INTERRUPT HANDLER ========================================
