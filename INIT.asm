;= INITIALIZATION ==================================
INIT: MOV #WDTPW+WDTHOLD,&WDTCTL  ; Stop watchdog timer
  MOV #0x400,SP ;0x400 = 0x03FE+2, 0x03FE = RAM BOTTOM
  CLR.B &DCOCTL
/*
  BIS.B #MOD4+MOD3+MOD2+MOD1+MOD0,&DCOCTL
  BIC.B #RSEL3+RSEL2+RSEL1+RSEL0+XTS,&BCSCTL1
  BIS.B #LFXT1S_2,&BCSCTL3 ;main clock - VLO
  BIS.B #SELS+DIVS_3,&BCSCTL2 ;submainclock - VLO, divided by 8
  BIS.B #SCG0,SR ; turn off DCLOCK
  */
  MOV.B &CALBC1_1MHZ,&BCSCTL1 ;setting calibrated 1 MHz frequency
  MOV.B &CALDCO_1MHZ,&DCOCTL
  BIS.B #DIVS_3,&BCSCTL2 ;SMBCLCK divider -8, 125kHz
;===================================================
  CLR R4
  CLR R5
  CLR R6
  CLR R7
  CLR R8
  CLR R9
  CLR R10
  CLR R11
  CLR R12
  CLR R13
  CLR R14
  CLR R15
;===================================================
  MOV #0200h,TEMP ;0200h is RAM START
BLANK:  CLR 0(TEMP)
  INCD TEMP
  CMP #0x400,TEMP ;0x400 = 0x03FE+2, 0x03FE = RAM BOTTOM
  JL BLANK
  CLR TEMP
;===================================================
/*
;Watchdog in Interval Mode Init
  MOV #WDTPW+WDTTMSEL+WDTCNTCL,&WDTCTL ;interval mode, clear counter, set clock source - SMCLK
  ;divide by 32768
  EINT
  BIS.B #WDTIE,&IE1
  */
;===================================================
/*
; Timer in Interval Mode Init
  BIS.W #TASSEL_2+ID_3+MC_1,&TA0CTL
  MOV.W #374,&TACCR0 ;number of ticks to count to
  BIS.W #CCIE,&TA0CCTL0 ;timer interrupt enable
  EINT
 */
;===================================================
;Ports init
  MOV.B #0xFF,&P1DIR ;Port 1 is in output mode
  CLR.B &P1OUT ;all pins pulled low
  BIS.B #BIT1+BIT2+BIT6+BIT7,&P1SEL ;HW UART+I2C ENABLE
  BIS.B #BIT1+BIT2+BIT6+BIT7,&P1SEL2 ;1.6 -SCL, 1.7 - SDA
;  BIS.B #BIT3,&P1OUT ;pull up resistor on bit 3
;  BIS.B #BIT3,&P1REN ;RESITOR ENABLE on bit 3
;===================================================
;UART INIT
  BIS.B #UCSSEL_2,&UCA0CTL1 ;CLK = SBMCLCK
  MOV.B #13,&UCA0BR0 ;125kHz/9600
  CLR.B &UCA0BR1 ;both MODs zero
  CLR.B &UCA0MCTL ; MOD0
  BIC.B #UCSWRST,&UCA0CTL1 ;clear reset bit
  BIS.B #UCA0RXIE,&IE2 ;Interrupt on receive
;===================================================
;I2C
  BIS.B #UCSWRST,&UCB0CTL1
  BIS.B #UCMST+UCMODE_3+UCSYNC,&UCB0CTL0 ;I2C mode, MASTER mode,synchronous mode
  BIS.B #UCSSEL_2,&UCB0CTL1 ;clock source -SBMCLCK
  MOV.B #2,&UCB0BR0 ;SBMCLK divider - 2 (fSCL = SMCLK/1 = ~60kHz)
  CLR.B &UCB0BR1 ;SBMCLCK prescaler zero
  MOV #1010000b,&UCB0I2CSA ;slave address
  BIC.B #UCSWRST,&UCB0CTL1 ;clear reset bit
  EINT