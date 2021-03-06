; TODO INSERT CONFIG CODE HERE USING CONFIG BITS GENERATOR
    
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

 ;CRISTAL 8 MHz
 
CBLOCK 0X20
 CUENTA
 KEY
 AUX_W
 AUX_S
 A1
 A2
 A3
 REG1
 REG2	
 REG3
 REG4
 REG5
 REG7
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
    
INT_VECT  CODE	  0X0004
    GOTO    INTERRUPCION
    
org 0x05

; TODO ADD INTERRUPTS HERE IF USED

MAIN_PROG CODE                      ; let linker place main program
 
 
    


START
    BANKSEL ANSEL
    CLRF    ANSEL
    CLRF    ANSELH
    BANKSEL WPUB
    MOVLW   0XF0
    ;MOVWF   IOCB
    ;MOVWF   WPUB
    MOVWF   TRISB
    BSF	    TRISC,6
    BSF	    TRISC,7
    CLRF    TRISD
    ;CLRF    OPTION_REG
 
    ;MOVLW   0X88
    ;MOVWF   INTCON
    
    
    
    BANKSEL PORTB
    CLRF    PORTC
    CLRF    A1
    CALL    INIT_TX_RX
    CALL    INT_RX
    ;CALL    RX
    ;CALL    TX
    GOTO    $    
    
INICIA_BUCLE:
    MOVLW   0X30
    MOVWF   A1
BUCLE:
    MOVF    A1,W
    CALL    TX
    INCF    A1,F
    MOVF    A1,W
    XORLW   0X3A
    BTFSS   STATUS,Z
    GOTO    BUCLE
    MOVLW   .13
    CALL    TX
    GOTO    INICIA_BUCLE
    ;CALL    INT_LCD
    

    GOTO $
    
INT_RX:
    BSF	    INTCON,7	    ;ACTIVAMOS INTERRUPCIONES GLOBALES
    BSF	    INTCON,6
    BANKSEL PIE1
    BSF	    PIE1,5
    RETURN
RX:
   BANKSEL  PIR1
   BTFSS    PIR1,5
   GOTO	    $-1
   MOVF	    RCREG,W
   RETURN
   
   
TX:
    BANKSEL TXSTA
    BTFSS   TXSTA,1
    GOTO    TX
    BANKSEL TXREG
    MOVWF   TXREG
    RETURN
    
INIT_TX_RX:
    BANKSEL SPBRG
    ; CONFIUARAMOS VELOCIDAD DE TRANSMICION A 9600 BAUIDOS
    MOVLW   .207	
    MOVWF   SPBRG
    CLRF    SPBRGH
    ;CONFIGURAMOS TRASMINCIÓN DE ALTA FRECUENCIA Y GENERADOR DE BAUDIOS CON 16 BITS
    BANKSEL BAUDCTL 
    BSF	    BAUDCTL,3
    BANKSEL TXSTA
    BSF	    TXSTA,2
    BCF	    TXSTA,6 ;TRANSMICION A 8 BITS
    BSF	    TXSTA,5 ;ACTIVAMOS TRANSMICIÓN
    
    ;ACTIVAR COMUNICACIÓN ASINCRONA
    BCF	    TXSTA,4
    BANKSEL RCSTA
    BSF	    RCSTA,7
    BSF	    RCSTA,4 ;ACTIVAR RECEPCIÓN
    BCF	    RCSTA,6 ;RECEPCIÓN A 9 BITS DESACTIVADA
    
    RETURN
    
    
    
    
INT_LCD
    MOVLW   0X30
    CALL    SEND_LCD_COMANDO
    CALL    RETARDO
    CALL    SEND_LCD_COMANDO
    CALL    RETARDO
    CALL    SEND_LCD_COMANDO
    MOVLW   0X38
    CALL    SEND_LCD_COMANDO
    CALL    RETARDO
    MOVLW   0X0D
    CALL    SEND_LCD_COMANDO
    CALL    RETARDO
    MOVLW   0X06
    CALL    SEND_LCD_COMANDO
    CALL    RETARDO
    MOVLW   0X01
    CALL    SEND_LCD_COMANDO
    CALL    RETARDO
    RETURN
SEND_LCD_COMANDO
    BCF	    PORTD,0
    GOTO    $+2
SEND_LCD_DATO
    BSF	    PORTD,0	    ;BIT RS=1
    BCF	    PORTD,1	    ;BIT R/W=0
    BSF	    PORTD,2	    ;BIT E=1  
    MOVWF   PORTC
    CALL    RETARDO
    BCF	    PORTD,2	    ;BIT E=1
    RETURN
    
;----------RUTINA DE RETARDO---------------
RETARDO		MOVLW	.8
		MOVWF	REG3
DOS		MOVLW	.50
		MOVWF	REG2
UNO		MOVLW	.25
		MOVWF	REG1
		DECFSZ	REG1,1
		GOTO	$-1
		DECFSZ	REG2,1
		GOTO	UNO
		DECFSZ	REG3,1
		GOTO	DOS
		RETURN
;------------------------------------------
    
    
    
INTERRUPCION
		BCF	INTCON,7    
    ;-----SALVAR W Y STATUS
		MOVWF   AUX_W
		SWAPF   STATUS,W
		MOVWF   AUX_S
		
		BANKSEL	PIR1
		BCF	PIR1,5
		MOVF	RCREG,W
		
		CALL	TX
    ;RESTAURAR W Y STATUS
		SWAPF   AUX_S,W
		MOVWF   STATUS
		MOVF    AUX_W,W
    ;---------------------------
		BSF	    INTCON,7
		RETFIE
		
		
    END