;
; AssemblerApplication1.asm
;
; Created: 14/05/2022 06:07:05 p. m.
; Author : Johan Lee
;
; Replace with your application code






					.dseg 
					.org 0x100
tabla_teclado:		.byte 0x10		;Reserva 16 espacios de memoria para el array de valores
tabla_display:		.byte 0x10
					 .cseg

setup:

	.def display_anterior = r19
	.def tecla_anterior = r20
	.def signo = r21
	.def escrituraD = r22
	.def lecturaD = r23
	.def puertoB = r24
	.def puertoC = r25

	 clr display_anterior
	 clr tecla_anterior
	 clr signo
	 clr escrituraD
	 clr lecturaD
	 clr puertoB
	 clr puertoC


	ldi r26,low (tabla_teclado)		;Inicializando el apuntador X
    ldi r27, high (tabla_teclado)	

	ldi r16, 0b0111_0111 ; Numero 1 matricial
	st x+, r16				
	ldi r16, 0b0111_1011 ; Numero 2 matricial
	st x+, r16				
	ldi r16, 0b0111_1101 ; Numero 3 matricial
	st x+, r16	
	ldi r16, 0b0111_1110 ; Letra A matricial
	st x+, r16

	ldi r16, 0b1011_0111 ; Numero 4 matricial
	st x+, r16				
	ldi r16, 0b1011_1011 ; Numero 5 matricial
	st x+, r16				
	ldi r16, 0b1011_1101 ; Numero 6 matricial
	st x+, r16	
	ldi r16, 0b1011_1110 ; Letra B matricial
	st x+, r16

	ldi r16, 0b1101_0111 ; Numero 7 matricial
	st x+, r16				
	ldi r16, 0b1101_1011 ; Numero 8 matricial
	st x+, r16				
	ldi r16, 0b1101_1101 ; Numero 9 matricial
	st x+, r16	
	ldi r16, 0b1101_1110 ; Letra C matricial
	st x+, r16

	ldi r16, 0b1110_0111 ; Tecla * matricial (-)
	st x+, r16				
	ldi r16, 0b1110_1011 ; Numero 0 matricial
	st x+, r16				
	ldi r16, 0b1110_1101 ; Tecla # matricial 
	st x+, r16	
	ldi r16, 0b1110_1110 ; Letra D matricial
	st x+, r16


	ldi r28,low (tabla_display)		;Inicializando el apuntador Y
    ldi r29, high (tabla_display)	

	ldi r16, 0b000_0110 ; Numero 1 display
	st y+, r16				
	ldi r16, 0b101_1011 ; Numero 2 display
	st y+, r16				
	ldi r16, 0b100_1111 ; Numero 3 display
	st y+, r16	
	ldi r16, 0b011_1111 ; Letra A display (0)
	st y+, r16

	ldi r16, 0b110_0110 ; Numero 4 display
	st y+, r16				
	ldi r16, 0b110_1101 ; Numero 5 display
	st y+, r16				
	ldi r16, 0b111_1101 ; Numero 6 display
	st y+, r16	
	ldi r16, 0b011_1111 ; Letra B display (0)
	st y+, r16

	ldi r16, 0b000_0111 ; Numero 7 display
	st y+, r16				
	ldi r16, 0b111_1111 ; Numero 8 display
	st y+, r16				
	ldi r16, 0b110_1111 ; Numero 9 display
	st y+, r16	
	ldi r16, 0b011_1111 ; Letra C display (0)
	st y+, r16

	ldi r16, 0b1000_0000 ; signo - display
	st y+, r16				
	ldi r16, 0b011_1111 ; Numero 0 display
	st y+, r16				
	ldi r16, 0b011_1111 ; Signo # display (0)
	st y+, r16	
	ldi r16, 0b011_1111 ; Letra D display (0)
	st y+, r16

	ldi r16, 0b1111_0000
	out DDRD, r16
	ldi escrituraD, 0xFF
	out PORTD, escrituraD

	ldi r16, 0b1111_1111
	out DDRB, r16

	ldi r16, 0b111_1111
	out DDRC, r16

main:
	ldi escrituraD, 0b0111_1111
	out PORTD, escrituraD
	in lecturaD, PIND
	call comparacion

	ldi escrituraD, 0b1011_1111
	out PORTD, escrituraD
	in lecturaD, PIND
	call comparacion

	ldi escrituraD, 0b1101_1111
	out PORTD, escrituraD
	in lecturaD, PIND
	call comparacion

	ldi escrituraD, 0b1110_1111
	out PORTD, escrituraD
	in lecturaD, PIND
	call comparacion

	rjmp main


comparacion:
	clr r26
	clz
	ldi r17, 17
	loop_comp:
		dec r17
		ld r16, X+
		cpse r16, lecturaD
		brne loop_comp
	dec r26
	clz
	tst r17
	breq retorno_comp
	clz
	ldi r17, 0b1110_0111 ; Valor teclado matricial de cero
	cp r16, r17
	breq signo_apretado
	call display
	rjmp retorno_comp

	signo_apretado:
		cpse tecla_anterior, r17
		call suma_signo
		retorno_comp:
			ret 


suma_signo:
	clz
	tst signo
	breq guardar_signo
	clr signo
	rjmp retorno_display_signo
	guardar_Signo:	
		ldi signo, 0b1000_0000
	retorno_display_signo:
		call display_con_signo_recien_apretado
		ret
	


display:
	mov r28, r26
	adiw r28, 0x10 
	clr puertoC
	ld puertoB, Y
	add puertoB, signo
	mov r16, puertoB
	rol r16
	rol puertoC
	rol r16
	rol puertoC
	out PORTB, puertoB
	out PORTC, puertoC
	ld tecla_anterior, X
	ld display_anterior, Y
	ret


display_con_signo_recien_apretado:

	clz
	tst signo
	breq display_sin_signo
	add display_anterior, signo
	mov puertoB, display_anterior
	rjmp main_recien_apretado
	display_sin_signo:
		mov puertoB, display_anterior


	main_recien_apretado:
		mov r16, puertoB
		rol r16
		rol puertoC
		rol r16
		rol puertoC
		out PORTB, puertoB
		out PORTC, puertoC
		ld tecla_anterior, X
		ld display_anterior, Y
	ret