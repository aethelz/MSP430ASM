;= WELCOME ======================================== 
  MOV #10,R4
TOP_BAR: UART_SYM #'*'
  DEC R4
  JNZ TOP_BAR
  UART_SYM #CR

  MOV #10,R4
  MOV #STRING,R5 ; 
str: MOV.B @R5+,R6 ;some string reading magic
  UART_SYM R6
  DEC R4
  JNZ str
  UART_SYM #CR

   MOV #10,R4
TOP_BAR2: UART_SYM #'*'
  DEC R4
  JNZ TOP_BAR2
  UART_SYM #CR
  
  TX_RUN
;= WELCOME ========================================