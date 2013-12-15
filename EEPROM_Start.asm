;= EEPROM_START ========================================
EEPROM_START:
	BIT.B #UCBBUSY,&UCB0STAT ;while (UCB0STAT & UCBUSY); // wait until I2C module has finished all operations
	JC $-6
	
LB1: CLR.B &UCB0STAT ;UCB0STAT = 0x00 // clear I2C interrupt flags
	BIS.B #UCTR,&UCB0CTL1 ;UCB0CTL1 |= UCTR; // I2CTRX=1 => Transmit Mode (R/W bit = 0)
	BIC.B #UCTXSTT,&UCB0CTL1 ;UCB0CTL1 &= ~UCTXSTT;
	
LB2: BIS.B #UCTXSTT,&UCB0CTL1 ;UCB0CTL1 |= UCTXSTT; // start condition is generated
	BIT.B #UCTXSTT,&UCB0CTL1 ;while(UCB0CTL1 & UCTXSTT) // wait till I2CSTT bit was cleared
	JNC LB3 ; if UCTXSTT is zero break out to lb6
	BIT.B #UCNACKIFG,&UCB0STAT ;if(!(UCNACKIFG & UCB0STAT)) // Break out if ACK received
	JC LB2 ;UCNACKIFG not zero, start again
	
LB3: BIS.B #UCTXSTP,&UCB0CTL1 ;UCB0CTL1 |= UCTXSTP; // stop condition is generated after
; slave address was sent => I2C communication is started

LB4: BIT.B #UCTXSTP,&UCB0CTL1 ;while(UCB0CTL1 & UCTXSTT) // wait till I2CSTT bit was cleared
	JNC LB4
	MOV #0xA5,TEMP ;__delay_cycles(500) !Don't you dare touch this!

LB5: ADD #0xFFFF,TEMP ;Figure out register to use though, maybe go for TEMP
	JC LB5
	CLR TEMP
	BIT.B #UCNACKIFG,&UCB0STAT ;while(UCNACKIFG & UCB0STAT);
	JC LB1
	BIT.B #UCBBUSY,&UCB0STAT ;while (UCB0STAT & UCBUSY); // wait until I2C module has finished all operations
	JC $-6
	BIC.B #UCB0TXIFG,&IFG2 ;Clear TX Flag
	BIS.B #UCB0TXIE,&IE2 ;Enable TX interrupt
	BIS.B #UCTXSTT,&UCB0CTL1 ;generating start condition
	
LB6: CMP.B #0xA,&EEPROM_CYCLE ;Checking whether whatever it is that we were doing
	JEQ EXIT_EEPROM ;either write op
	CMP.B #0xB,&EEPROM_CYCLE ;returned code for successful op
	JNE LB6 ;or read op
	EXIT_EEPROM: RET
;===================================================


