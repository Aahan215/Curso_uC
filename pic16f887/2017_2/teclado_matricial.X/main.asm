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
 
 TABLA_ASCII
    ADDWF   PCL,1
    DT	    0X30,0X31,0X32,0X33,0X34,0X35,0X36,0X37,0X38,0X39,.47,.42,.45,.64,.61,.43
   
FLECHA
    ADDWF   PCL,1
    DT	    0X04,0X04,0X04,0X04,0X15,0X0E,0X04,0X00

DIRECCION
    ADDWF   PCL,1
    DT	    0X40,0X41,0X42,0X43,0X44,0X45,0X46,0X47
    
 
LIN1	ADDWF	PCL,1
	DT  "LINEA UNO DE PRUEVA"
LIN2	ADDWF	PCL,1
	DT  "LIENA DOS DE PRUEVA"

START
    CALL    RETARDO
    BANKSEL ANSEL
    CLRF    ANSEL
    CLRF    ANSELH
    
    BANKSEL PORTB
    MOVLW   0XF0    
    MOVWF   PORTB
    
    BANKSEL WPUB
    MOVLW   0XF0
    MOVWF   IOCB
    MOVWF   WPUB
    MOVWF   TRISB
    CLRF    TRISC
    CLRF    TRISD
    CLRF    OPTION_REG
 
    MOVLW   0X88
    MOVWF   INTCON
    
    
    
    BANKSEL PORTB
    CLRF    PORTC
    MOVLW   0XF0    
    MOVWF   PORTB
    CLRF    PORTD
    CALL    INT_LCD
    
 PASA_LETRAS:
    MOVLW   0X0F
    MOVWF   A1
    CLRF    A2
CICLO_1:    
    MOVLW   0X80
    ADDWF   A1,W
    CALL    SEND_LCD_COMANDO
    
    MOVF    A1,W
    SUBLW   0X0F
    MOVWF   A3
    CLRF    A2
CICLO_2:    
    MOVF    A2,W
    CALL    LIN1
    CALL    SEND_LCD_DATO
    MOVF    A2,W
    XORWF   A3,W
    BTFSS   STATUS,Z
    GOTO    INC_A2
    GOTO    MOVER_LI
INC_A2:
    INCF    A2,F
    GOTO    CICLO_2
    
MOVER_LI:
    CALL    RETARDO
    DECF    A1,F
    GOTO    CICLO_1	
    GOTO $
    
    
 L1:
    MOVF    REG7,W
    CALL    LIN1
    MOVWF   REG5
    CALL    SEND_LCD_DATO
    INCF    REG7
    BTFSS   REG7,4
    GOTO    L1
    
     
    
    ;MOVLW   "A"
    ;CALL    DATO8
    
    MOVLW   B'11000000'		;APUNTADOR A LINEA 2 POSICION CERO
    MOVWF   REG5
    CALL    SEND_LCD_COMANDO
    CLRF    REG7
    
L2:
    MOVF    REG7,W
    CALL    LIN2
    MOVWF   REG5
    CALL    SEND_LCD_DATO
    INCF    REG7
    BTFSS   REG7,4
    GOTO    L2
    ;MOVLW   0X30
    ;CALL    SEND_LCD_DATO
    ;MOVLW   0X30
    ;CALL    SEND_LCD_DATO
    ;MOVLW   0X30
    ;CALL    SEND_LCD_DATO
    ;CALL    NEW_CHAR
    ;MOVLW   0X05
    ;CALL    SEND_LCD_DATO
    ;MOVLW   0X05
    ;CALL    SEND_LCD_DATO
    ;MOVLW   0X05
    ;CALL    SEND_LCD_DATO
    
    
    GOTO $                          ; loop forever+
    
NEW_CHAR
    CLRF    CUENTA
    MOVLW   0X68
    CALL    SEND_LCD_COMANDO
BUCLEE
    MOVF    CUENTA,W
    CALL    FLECHA
    CALL    SEND_LCD_DATO
    INCF    CUENTA,F
    MOVF    CUENTA,W
    BTFSS   CUENTA,3
    GOTO    BUCLEE
    MOVLW   0X83
    CALL    SEND_LCD_COMANDO
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

    ;-----SALVAR W Y STATUS
		MOVWF   AUX_W
		SWAPF   STATUS,W
		MOVWF   AUX_S
		
		BCF	INTCON,7    ;DESACTIVAMOS EL GLOBAL
		BTFSS	INTCON,0
		BTFSS	INTCON,1
		GOTO	INT_CAMBIO
		GOTO	INT_FLANCO
		
INT_CAMBIO
		;CALL    RETARDO
		BCF	INTCON,0
		MOVLW	0X0F
		MOVWF	PORTB
		
		BCF	PORTB,0
		
		MOVF	PORTB,W
		XORLW	0XEE
		BTFSS	STATUS,Z
		GOTO	$+4
		MOVLW	.7
		MOVWF	KEY
		GOTO	FIN_INTE
		
		MOVF	PORTB,W
		XORLW	0XDE
		BTFSS	STATUS,Z
		GOTO	$+4
		MOVLW	.8
		MOVWF	KEY
		GOTO	FIN_INTE
		
		MOVF	PORTB,W
		XORLW	0XBE
		BTFSS	STATUS,Z
		GOTO	$+4
		MOVLW	.9
		MOVWF	KEY
		GOTO	FIN_INTE
		
		MOVF	PORTB,W
		XORLW	0X7E
		BTFSS	STATUS,Z
		GOTO	$+4
		MOVLW	.10
		MOVWF	KEY
		GOTO	FIN_INTE
		
		BSF	PORTB,0
		BCF	PORTB,1
		
		
		MOVF	PORTB,W
		XORLW	0XED
		BTFSS	STATUS,Z
		GOTO	$+4
		MOVLW	.4
		MOVWF	KEY
		GOTO	FIN_INTE
		
		MOVF	PORTB,W
		XORLW	0XDD
		BTFSS	STATUS,Z
		GOTO	$+4
		MOVLW	.5
		MOVWF	KEY
		GOTO	FIN_INTE
		
		MOVF	PORTB,W
		XORLW	0XBD
		BTFSS	STATUS,Z
		GOTO	$+4
		MOVLW	.6
		MOVWF	KEY
		GOTO	FIN_INTE
		
		MOVF	PORTB,W
		XORLW	0X7D
		BTFSS	STATUS,Z
		GOTO	$+4
		MOVLW	.11
		MOVWF	KEY
		GOTO	FIN_INTE
		
		BSF	PORTB,1
		BCF	PORTB,2
		
		MOVF	PORTB,W
		XORLW	0XEB
		BTFSS	STATUS,Z
		GOTO	$+4
		MOVLW	.1
		MOVWF	KEY
		GOTO	FIN_INTE
		
		MOVF	PORTB,W
		XORLW	0XDB
		BTFSS	STATUS,Z
		GOTO	$+4
		MOVLW	.2
		MOVWF	KEY
		GOTO	FIN_INTE
		
		
		MOVF	PORTB,W
		XORLW	0XBB
		BTFSS	STATUS,Z
		GOTO	$+4
		MOVLW	.3
		MOVWF	KEY
		GOTO	FIN_INTE
		
		MOVF	PORTB,W
		XORLW	0X7B
		BTFSS	STATUS,Z
		GOTO	$+4
		MOVLW	.12
		MOVWF	KEY
		GOTO	FIN_INTE
		
		
		BSF	PORTB,2
		BCF	PORTB,3
		
		MOVF	PORTB,W
		XORLW	0XE7
		BTFSS	STATUS,Z
		GOTO	$+4
		MOVLW	.13
		MOVWF	KEY
		GOTO	FIN_INTE
		
		MOVF	PORTB,W
		XORLW	0XD7
		BTFSS	STATUS,Z
		GOTO	$+4
		MOVLW	.0
		MOVWF	KEY
		GOTO	FIN_INTE
		
		MOVF	PORTB,W
		XORLW	0XB7
		BTFSS	STATUS,Z
		GOTO	$+4
		MOVLW	.14
		MOVWF	KEY
		GOTO	FIN_INTE
		
		MOVF	PORTB,W
		XORLW	0X77
		BTFSS	STATUS,Z
		GOTO	$+4
		MOVLW	.15
		MOVWF	KEY
		GOTO	FIN_INTE
		
		
		
		
		
		
		
INT_FLANCO
		BCF	INTCON,1
		
FIN_INTE
		CLRF	PORTB
		MOVF	KEY,W
		CALL	TABLA_ASCII
		MOVWF	PORTC
		BCF	INTCON,0
    ;RESTAURAR W Y STATUS
		SWAPF   AUX_S,W
		MOVWF   STATUS
		MOVF    AUX_W,W
    ;---------------------------
		BSF	    INTCON,7
		RETFIE
		
		
    END