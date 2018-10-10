;*******************************************************************************
;testing...    
;version: 0.0    
;*******************************************************************************
   
    list p=16f887.inc
    #include P16f887.inc
    
;Directivas de configuraci�n****************************************************    
    __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
    __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
    
;
    CBLOCK 0x20
    OperandoA	    ;Guarda el valor del primero operando
    OperandoB	    ;Guarda el valor del segundo operando
    RegSuma	    ;Guarda el valor de la suma
    RegResta	    ;Guarda el valor de la resta
    RegComp	    ;Guarda el valor de la resta en complemento a 2
    ENDC
    
;Definici�n de variables********************************************************
#DEFINE Pulsador1   PORTE,0	;Los pulsadores se conectan a estos 
#DEFINE Pulsador2   PORTE,1	;pines del puerto E.
#DEFINE Pulsador3   PORTE,2	;En total usamos tres pines del puerto E
#DEFINE Pulsador4   PORTD,7	;y un pin del puerto D.

;C�digo fuente******************************************************************    
    org 0x00	    ;El programa comienza en la direcci�n 0x00 
    goto Inicio	    ;de memoria de programa
    org 0x05
    
Inicio
    banksel ANSEL   ;El registro ANSEL debe inicializarse en cero para configurar
    clrf ANSEL	    ; un canal anal�gico como entradas digitales
    clrf ANSELH
    
    banksel TRISA	;Acceso al banco 1
    movlw b'11111111'	
    movwf TRISA		;Las l�neas del Puerto A se configuran como entradas
    clrf TRISB		;Las l�neasd del Puerto B se configuran como salidas
    clrf TRISC		;Las l�neasd del Puerto C se configuran como salidas
    movlw b'10000000'	;Se utilizan los 7 primeros bits del Puerto D como 
    movwf TRISD		;salidas y el pin RD7 como entrada
    movlw b'00001111'
    movwf TRISE		;Pines RE0, RE1, RE2 como entradas.
    
    banksel PORTA
    clrf PORTA
    clrf PORTB
    clrf PORTC
    clrf PORTD
    clrf PORTE    
    clrf OperandoA
    clrf OperandoB
    
Principal       
    btfss Pulsador1	;Salta si el pulsador 1 no est� presionado
    goto CargarOpA
    btfss Pulsador2	;Salta si el pulsador 2 no est� presionado
    goto CargarOpB
    btfss Pulsador3	;Salta si el pulsador 3 no est� presionado
    goto SumaAB
    btfss Pulsador4	;Salta si el pulsador 4 no est� presionado
    goto RestaAB
    goto Principal

;Subrutina SumaAB***************************************************************
RestaAB    
    clrf PORTB
    movf OperandoB,W
    subwf OperandoA,W	;(W) = (OperandoA) - (OperandoB)
    movwf RegResta
    andlw b'00001111'	;Se queda conlos cuatro bits m�s bajos de entrada
    call DecoHEX	;Decodifica el nibble inferior en hexadecimal
    movwf PORTD		;Se visualiza por el puerto de salida
    
    swapf RegResta,W	;Se intercambian los nibbles del puerto
    andlw b'00001111'	;Se queda conlos cuatro bits m�s bajos de entrada
    call DecoHEX	;Decodifica el nibble inferior en hexadecimal
    movwf PORTC		;Se visualiza por el puerto de salida   
    
    movf OperandoB,W
    subwf OperandoA,W
    btfsc STATUS,C	;�El resultado es negativo? �C = 1?
    goto Principal	
    bsf PORTB,6		;Enciende el segmento g del display 
    comf RegResta,W	;Complementa a 2 el resultado de la resta
    addlw 0x01		;(W) + 01 -> (W)
    movwf RegComp	;Guarda el valor de la resta en complemento a  2
    andlw b'00001111'	;Se queda conlos cuatro bits m�s bajos de entrada
    call DecoHEX	;Decodifica el nibble inferior en hexadecimal
    movwf PORTD		;Se visualiza por el puerto de salida
    
    swapf RegComp,W	;Se intercambian los nibbles del puerto
    andlw b'00001111'	;Se queda conlos cuatro bits m�s bajos de entrada
    call DecoHEX	;Decodifica el nibble inferior en hexadecimal
    movwf PORTC		;Se visualiza por el puerto de salida 
    goto Principal
    
;Subrutina SumaAB***************************************************************
SumaAB    
    clrf PORTB
    movf OperandoB,W
    addwf OperandoA,W
    movwf RegSuma
    andlw b'00001111'	;Se queda conlos cuatro bits m�s bajos de entrada
    call DecoHEX	;Decodifica el nibble inferior en hexadecimal
    movwf PORTD		;Se visualiza por el puerto de salida
    
    swapf RegSuma,W	;Se intercambian los nibbles del puerto
    andlw b'00001111'	;Se queda conlos cuatro bits m�s bajos de entrada
    call DecoHEX	;Decodifica el nibble inferior en hexadecimal
    movwf PORTC		;Se visualiza por el puerto de salida   
    
    movf OperandoB,W
    addwf OperandoA,W
    btfss STATUS,C	;�Hubo desbordamiento? �C = 1?
    goto Principal	
    bsf PORTB,1		;Enciende el segmento b del display
    bsf PORTB,2		;Enciende el segmento c del display
    goto Principal
    
;Subrutina CargarOpA************************************************************
CargarOpA
    clrf PORTB
    movf PORTA,W	;Carga el registro de datos del Puerto A en W.
    movwf OperandoA	;Se guarda el valor del puerto en la regstro OperandoA        
    movf OperandoA,W	;Lee el valor de las variables de entrada
    andlw b'00001111'	;Se queda conlos cuatro bits m�s bajos de entrada
    call DecoHEX	;Decodifica el nibble inferior en hexadecimal
    movwf PORTD		;Se visualiza por el puerto de salida
    
    swapf OperandoA,W	;Se intercambian los nibbles del puerto
    andlw b'00001111'	;Se queda conlos cuatro bits m�s bajos de entrada
    call DecoHEX	;Decodifica el nibble inferior en hexadecimal
    movwf PORTC		;Se visualiza por el puerto de salida    
    goto Principal	;Se crea un bucle cerrado infinito
    
;Subrutina CargarOpA************************************************************
CargarOpB
    clrf PORTB
    movf PORTA,W	;Carga el registro de datos del Puerto A en W.
    movwf OperandoB	;Se guarda el valor del puerto en la regstro OperandoA        
    movf OperandoB,W	;Lee el valor de las variables de entrada
    andlw b'00001111'	;Se queda conlos cuatro bits m�s bajos de entrada
    call DecoHEX	;Decodifica el nibble inferior en hexadecimal
    movwf PORTD		;Se visualiza por el puerto de salida
    
    swapf OperandoB,W	;Se intercambian los nibbles del puerto
    andlw b'00001111'	;Se queda conlos cuatro bits m�s bajos de entrada
    call DecoHEX	;Decodifica el nibble inferior en hexadecimal
    movwf PORTC		;Se visualiza por el puerto de salida    
    goto Principal	;Se crea un bucle cerrado infinito
    
;Subrutina DecoHEX**************************************************************    
DecoHEX
    addwf PCL,F		;-gfedcba
    retlw b'00111111'	;0
    retlw b'00000110'	;1
    retlw b'01011011'	;2
    retlw b'01001111'	;3
    retlw b'01100110'	;4
    retlw b'01101101'	;5
    retlw b'01111101'	;6
    retlw b'00000111'	;7
    retlw b'01111111'	;8
    retlw b'01101111'	;9
    retlw b'01110111'	;A
    retlw b'01111100'	;b
    retlw b'00111001'	;C
    retlw b'01011110'	;d
    retlw b'01111001'	;E
    retlw b'01110001'	;F
    
    END