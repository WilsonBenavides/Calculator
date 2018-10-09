;*******************************************************************************
;testing...    
;version: 0.0    
;*******************************************************************************
   
    list p=16f887.inc
    #include P16f887.inc
    
;Directivas de configuración****************************************************    
    __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
    __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
    
;Definición de variables********************************************************
#DEFINE Pulsador1   PORTE,0	;Los pulsadores se conectan a estos 
#DEFINE Pulsador2   PORTE,1	;pines del puerto E.
#DEFINE Pulsador3   PORTE,2	;En total usamos tres pines del puerto E
#DEFINE Pulsador4   PORTD,7	;y un pin del puerto D.

;Código fuente******************************************************************    
    org 0x00	    ;El programa comienza en la dirección 0x00 
    goto Inicio	    ;de memoria de programa
    org 0x05
    
Inicio
    banksel ANSEL   ;El registro ANSEL debe inicializarse en cero para configurar
    clrf ANSEL	    ; un canal analógico como entradas digitales
    clrf ANSELH
    
    banksel TRISA	;Acceso al banco 1
    movlw b'11111111'	
    movwf TRISA		;Las líneas del Puerto A se configuran como entradas
    clrf TRISB		;Las líneasd del Puerto B se configuran como salidas
    clrf TRISC		;Las líneasd del Puerto C se configuran como salidas
    movlw b'10000000'	;Se utilizan los 7 primeros bits del Puerto D como 
    movwf TRISD		;salidas y el pin RD7 como entrada
    movlw b'00000111'
    movwf TRISE		;Pines RE0, RE1, RE2 como entradas.
    
    banksel PORTA
    clrf PORTA
    clrf PORTB
    clrf PORTC
    clrf PORTD
    clrf PORTE
Principal
    movf PORTA,W    ;Carga el registro de datos del Puerto A en W.
    movwf PORTB	    ;El contenido de W se deposita en el Puerto B.
    movwf PORTC	    ;El contenido de W se deposita en el Puerto C.
    movwf PORTD	    ;El contenido de W se deposita en el Puerto D.
    goto Principal  ;Se crea un bucle cerrado infinito
    
    END