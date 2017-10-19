; TODO INSERT CONFIG CODE HERE USING CONFIG BITS GENERATOR
; PIC16F887 Configuration Bit Settings

; Assembly source line config statements

#include "p16f887.inc"

; CONFIG1
; __config 0xFFFC
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF


 
CBLOCK 0X20
 REG1
 REG2	
 REG3
 REG4
 REG5
 CONTEO   ;-256 0 255
 SIGNO
 DATO
 ROTAR
 AUX
ENDC
CBLOCK 0X30
 UNIDADES
 DECENAS 
 CENTENAS
 DECIMAL_1    ;UNIDADES Y DECENAS
 DECIMAL_2    ;CENTENAS
 FLAG
ENDC 
    
    
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

MAIN_PROG CODE                      ; let linker place main program
ORG 0X05
 
 TABLA	ADDWF	PCL,1				;7448
	retlw	b'00111111'	;0  0X3F
	retlw	b'00000110'	;1  0X06
	retlw	b'01011011'	;2  0X5B
	retlw	b'01001111'	;3  0X4F
	retlw	b'01100110'	;4  0X66
	retlw	b'01101101'	;5  0X6C
	retlw	b'01111101'	;6  0X7C
	retlw	b'00000111'	;7  0X07
	retlw	b'01111111'	;8  0X7F
	retlw	b'01101111'	;9  0X6F
	retlw	b'01110111'	;a  0X77
	retlw	b'01111100'	;b  0X7B
	retlw	b'00111001'	;c  0X39
	retlw	b'01011110'	;d  0X5E
	retlw	b'01111001'	;e  0X79
	retlw	b'01110001'	;f  0X71
	retlw	0
 


; TODO ADD INTERRUPTS HERE IF USED



START
    
    banksel	TRISD
    ;MOVLW	0b01110111	    ;TRABAJA A 8 MHZ
    ;MOVWF	OSCCON
    CLRF	TRISC
    CLRF	TRISD
    BANKSEL	PORTB
    CLRF	PORTB
    CLRF	REG3
    CLRF	REG4
    MOVLW	0X01
    MOVWF	PORTD
    ;BSF		PORTD,0
    ;BSF		PORTD,1
    ;BSF		PORTD,2
    ;BSF		PORTD,3
    CALL	BIN2BCD
    GOTO	ROTAR_BIT
    GOTO    $
;INIT_CUENTA:    
;    CLRF        REG3
;LEER:
;    MOVF	REG3,W
;    CALL        TABLA
;    MOVWF	PORTC
;    CALL	ROTAR_BIT
;    CALL	RETARDO
;    INCF	REG3,F
;    BTFSS	REG3,4
;    GOTO        LEER
;    GOTO	INIT_CUENTA
;   ; COMF	PORTC
;   GOTO	$
;END_R:
;    CALL    RETARDO
;    COMF    PORTB
;    GOTO    END_R
    
ROTAR_BIT:
    ;BTFSS   PORTD,0
    MOVF    UNIDADES,W
    MOVWF   PORTC
    CALL    RETARDO
    CLRF    PORTC
    BCF	    STATUS,C
    RLF	    PORTD,F
    
    MOVF    DECENAS,W
    MOVWF   PORTC
    CALL    RETARDO
    CLRF    PORTC
    BCF	    STATUS,C
    RLF	    PORTD,F
    
    MOVF    CENTENAS,W
    MOVWF   PORTC
    CALL    RETARDO
    CLRF    PORTC
    BCF	    STATUS,C
    RLF	    PORTD,F
    
    ;BTFSS   PORTD,3
    
    CLRF    PORTD
    BSF	    PORTD,0
    INCF    REG4    ;SE UTLIZA PARA CONTAR LAS VECES QUE SE ACTUALIZAN LOS DYSPLAY
    MOVF    REG4,W
    XORLW   0X33
    BTFSS   STATUS,Z
    GOTO    ROTAR_BIT
    INCF    REG3   ;LLEVA LA CUENTA DEL VALOR A MOSTRAR EN LOS 7
    CLRF    DECIMAL_1
    CLRF    DECIMAL_2
    CALL    BIN2BCD
    CLRF    REG4
    GOTO    ROTAR_BIT
    
    
    
BIN2BCD:    
    MOVF    REG3,W
    MOVWF   DATO
    
    MOVLW   .5
    MOVWF   ROTAR
    RLF	    DATO,F
    CALL    ROTAR_IZQUIERDA
    
    RLF	    DATO,F
    CALL    ROTAR_IZQUIERDA
    
COMPROBAR_UNIDADES:
    RLF	    DATO,F
    CALL    ROTAR_IZQUIERDA
    
    
    MOVF    DECIMAL_1,W  
    SUBLW   .4
    BTFSC   STATUS,DC
    GOTO    COMPROBAR_DECENAS
    MOVF    DECIMAL_1,W  
    ADDLW   .3
    MOVWF   DECIMAL_1
    
COMPROBAR_DECENAS:
    MOVF    DECIMAL_1,W  
    ANDLW   0XF0
    MOVWF   AUX
    SUBLW   0X40
    BTFSC   STATUS,C
    GOTO    COMPROBAR_CENTENAS
    MOVF    AUX,W
    ADDLW   0X30
    MOVWF   AUX
    
    BTFSS   STATUS,C
    GOTO    CC
    INCF    DECIMAL_2,F
CC:    
    MOVF    DECIMAL_1,W
    ANDLW   0X0F
    XORWF   AUX,W
    MOVWF   DECIMAL_1
    
 COMPROBAR_CENTENAS:
    MOVF    DECIMAL_2,W  
    SUBLW   .4
    BTFSC   STATUS,DC
    GOTO    CF
    MOVF    DECIMAL_2,W
    ADDLW   .3
    MOVWF   DECIMAL_2
CF:    
    DECF    ROTAR,F
    BTFSS   STATUS,Z
    GOTO    COMPROBAR_UNIDADES
    
    RLF	    DATO,F
    CALL    ROTAR_IZQUIERDA
    
    MOVF    DECIMAL_1,W  ;7-4  DECENAS 3-0 UNIDADES
    ANDLW   0X0F
    CALL    TABLA
    MOVWF   UNIDADES
    
    SWAPF   DECIMAL_1,W  ;7-4  DECENAS 3-0 UNIDADES
    ANDLW   0X0F
    CALL    TABLA
    MOVWF   DECENAS
    
    
    MOVF    DECIMAL_2,W   ;3-0 CENTENAS
    ANDLW   0X0F
    CALL    TABLA
    MOVWF   CENTENAS
    
    RETURN                         ; loop forever
    
ROTAR_IZQUIERDA:
    RLF	    DECIMAL_1,F
    RLF	    DECIMAL_2,F
    RETURN    
    
;---SECUENCIA DE RETARTDO---------------    
RETARDO:
    MOVLW	.43	    ;1
    MOVWF	REG2	    ;1

LOOP_1:
    MOVLW	.50	    ;1      REG2=255	
    MOVWF	REG1	    ;1	    REG2=255	
    
    LOOP:    
    NOP			    ;1      REG1*REG2
    NOP			    ;1      REG1*REG2
    NOP			    ;1      REG1*REG2
    DECFSZ    REG1,F	    ;1	    REG1*REG2
    GOTO      LOOP	    ;2	    (2*REG1-1)*REG2
    DECFSZ    REG2,F	    ;1	    REG2
    GOTO      LOOP_1	    ;2	    2*REG2-1
    RETURN		    ;2	
     ;R=(Tciclo*REG1*4)-1+2*Tciclo
    ;T=(3*REG1*REG2+(2*REG1-1)*REG2+REG2+2*REG2-1+2)*(Tcy)
END