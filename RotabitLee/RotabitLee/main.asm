;
; RotabitLee.asm
;
; Created: 12/04/2022 07:38:21 p. m.
; Author : Johan Lee
;


; Replace with your application code


setup:
	ldi		r16, 0b1111_1111
	out		DDRD, r16
	ldi		r16, 0b0101_0000
	clr		r17


izquierda:
	out		PORTD, r16
    rol		r16
	rol		r17
	call	delay
	tst		r16
	brne	izquierda

derecha:
	out		PORTD, r16
	ror		r17
	ror		r16
	call	delay
	tst		r16
	brne	derecha
	rjmp	izquierda



delay:
	ldi	r21, 50
	delay1:
		ldi	r22, 0xFF
		delay2:
			ldi  r23, 0xFF
			delay3:
				dec r23
				brne delay3
				dec r22
				brne delay2
				dec r21
				brne delay1
	ret