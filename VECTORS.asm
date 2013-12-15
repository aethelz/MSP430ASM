;= INTERRUPT VECTORS ========================================
#define IVTS 0xFFE0 ;Interrupt vector table start

  ORG TRAPINT_VECTOR+IVTS       /* 0xFFE0 TRAPINT_VECTOR (see Errata) */
  DW TRAPINT
  ORG PORT1_VECTOR+IVTS       /* 0xFFE4 Port 1 */
  RETI
  ORG PORT2_VECTOR+IVTS       /* 0xFFE6 Port 2 */
  RETI
  ORG ADC10_VECTOR+IVTS       /* 0xFFEA ADC10 */
  RETI
  ORG USCIAB0TX_VECTOR+IVTS   /* 0xFFEC USCI A0/B0 Transmit */
  DW TRANSMIT
  ORG USCIAB0RX_VECTOR+IVTS   /* 0xFFEE USCI A0/B0 Receive */
  DW RECIEVE
  ORG TIMER0_A1_VECTOR+IVTS   /* 0xFFF0 Timer0_A CC1, TA0 */
  RETI
  ORG TIMER0_A0_VECTOR+IVTS   /* 0xFFF2 Timer0_A CC0 */
  RETI
  ORG WDT_VECTOR+IVTS         /* 0xFFF4 Watchdog Timer */
  RETI
  ORG COMPARATORA_VECTOR+IVTS /* 0xFFF6 Comparator A */
  RETI
  ORG TIMER1_A1_VECTOR+IVTS   /* 0xFFF8 Timer1_A CC1-4, TA1 */
  RETI
  ORG TIMER1_A0_VECTOR+IVTS   /* 0xFFFA Timer1_A CC0 */
  RETI
  ORG NMI_VECTOR+IVTS         /* 0xFFFC Non-maskable */
  RETI
  ORG RESET_VECTOR+IVTS       /* 0xFFFE Reset [Highest Priority] */
  DW  INIT
;===================================================  