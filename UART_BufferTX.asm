; Load Loop Buffer 
; IN DATA 	- DATA
; OUT DATA 	- ERROR CODE 
;===================================================
;WRITE INCREMENTA STORAGE REGISTER R13
;===================================================
;BEWARE, USES TEMP, no PUSH/POP!!!
;33 cycles

Buff_Push:  
	PUSH SR  
	DINT  ; Disable interrupts
	NOP ;necessary command before non-interruptible sequence
	PUSH TEMP
	
  MOV.B &OUT_PTR_E,TEMP ;move content of OUT_PTR_E to WRITE INCREMENTA STORAGE REGISTER

  ADD #OUT_buff,TEMP ;add WRITE INCREMENTA with OUT_buff to obtain current write position WRITEPOINT
  ;addressing mode is immediate 
  MOV.B DATA,0(TEMP) ;saving DATA into incremented buffer in RAM (WRITEPOINT)
  
  INC.B OUT_PTR_E ;incrementing pointer end
  CMP.B #MAXBUFF_OUT,&OUT_PTR_E ;checking whether the end of the buffer is reached
  
  JNE _NoEnd
  CLR.B &OUT_PTR_E  ;if so reset to beginning
  
_NoEnd: CMP.B &OUT_PTR_S,&OUT_PTR_E ; Checking buffer overflow condition
  JNE _RX_OUT ; Everything is okay, jump to subroutine exit
  
_RX_FULL: MOV.B #1,&OUT_FULL ;Buffer overflow, writing 1, 1 is an overflow flag

_RX_OUT:  POP TEMP
	POP SR  ; Interrupts enable
	RET
;===================================================
;BUFFER WRITE MAIN SUBROUTINE
/*
NewTry: CALL  #Buff_Push ;moving DATA to buffer
check:  CMP.B #1,&OUT_FULL ; checking overflow of the buffer
  JNE RUN ;everything is okay 
  TX_RUN
  CALL  #DELAY		; waiting - doing smth useful
  JMP check		; trying again
RUN: TX_RUN
  RET	
DELAY:  NOP
  RET
  */