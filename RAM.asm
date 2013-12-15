
;= MEMORY STUFF ========================================
; DO NOT DECLARE EVEN NUMBERED BYTE VARIABLES (1 or more WORDS) after odd number
; of BYTES declared from the start of the RAM, otherwise compiler gets angry
; Perhaps it is an architecture limitation?
MAXBUFF_OUT EQU 128 ;buffer size
	ORG 0200h ;Allocating in RAM, 0200h - RAM Start
	
EEPROM_ADDRESS DS16 1 ;2 byte address of EEPROM data
;highest block of memory starts at location 0x1E00
;and ends at 0x1FFF.
EEPROM_CYCLE DS16 1 ;current cycle of write/read op. TWO BYTES!! DO NOT CHANGE!
;setting to one byte causes it to glitch on ADD op later
; 0<<1 - transmit HIGH BYTE of address, 1<<1 - transmit LOW BYTE of address,
; 2<<1 - transmit DATA to be written, 3<<1 - terminate connection,
; 0xA - write op successful, 0xB read op successful
SEQREAD_BYTENUM DS16 1 ;number of bytes to read sequentially
;MAX bytes to be read is obviously 0xFFFF (65535)
PAGEWRITE_BYTENUM DS8 1 ;number of bytes to transmit from TX buffer left
;max bytes to fit into write cache is 64
EEREAD_POINTER DS16 1 ;sequential read pointer
EEWRITE_POINTER DS8 1 ;page write pointer
EEWRITE_CURPOINTER DS8 1 ;page write pointer
DATA DS8 1 ;we are allocating just one byte here
EEWR_DATA DS8 1 ;we are allocating just one byte here
OUT_PTR_S DS8 1 ;POINTER_START
OUT_PTR_E DS8 1 ;POINTER_END
OUT_FULL DS8 1 ;Overflow Flag
EEWR_FULL DS8 1 ;Overflow Flag
;should be set back to zero in interrupt routine on successful page write cycle
OUT_buff DS8 MAXBUFF_OUT ; DS directive allocates space for 8 bit integers
;In this case MAXBUFF_OUT bytes
WRITE_OP DS8 1 ;Read/Write EEPROM OP
;WRITE_DATA DS8 1 ;data to be written into EEPROM
READ_DATA DS8 1 ;data read from EEPROM
SEQREAD_DATA DS8 256 ;seqread dump of EEPROM
PAGEWRITE_DATA DS8 64 ;pagewrite cache
;= MEMORY STUFF ========================================