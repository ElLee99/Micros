;
; PWM Lee.asm
;
; Created: 31/05/2022 01:11:45 p. m.
; Author : Johan Lee
;


; Replace with your application code

.org 0
rjmp setup
.org 0x0020					//Al momento de que se genera una interrupción mande ese vector
rjmp ISR_TOV0				// y hace un salto a la función de interrrupción

setup:


	ldi r16, 0b00_0000		
	out DDRC, r16			//Configura el puertoB de entradas
	sbi DDRD, 6				//Configura el puerto D6 como salida, que es nuestro OC0A (Output, clock 0, Compare A mode) 
	ldi r16, 0b1000_0011	// Set OC0A on compare match (setea en 1 a OCnx al llegar al valor de comparación y se pone en 0 al llegar a la bandera de desbordamiento)
	out TCCR0A, r16
	ldi r16, 0b0101			//clk /64 (from prescaler) (dividimos el valor entre 64) //PONER 011 para trabajar a 1Khz aproximadamente
	out TCCR0B, r16
	ldi r16,1<<TOIE0		//Habilita la interrupcion de overflow 
	sts TIMSK0, r16
	ldi r20, 0b1101			//Valor de la ganancia para el escalamiento
	ldi r21, 25				//Valor del offset para el escalamiento
	sei						//Habilitamos las interrupciones globales del SREG


main:
	rjmp main



ISR_TOV0:					//Interrupción del overflow timer

							//Estas primeras 3 lineas guardan el valor de nuestro SREG
	push r16				
	in r16,SREG
	push r16
	call escalamiento		//Llamamos a nuestra función de escalamiento
							//Estas ultimas lineas, regresan el valor que teniamos en el SREG, antes de entrar a la interrupción
	pop r16					
	out SREG,r16
	pop r16
	reti					//Retornamos de la interrupción


escalamiento:
	in r18, PINC			//Leemos el valor de nuestro PINC
							//Rotaremos hacía a la izquierda el valor 2 veces para pasarlo a los 6 mas significativos
	rol r18					
	rol r18					
	mul r18, r20			//Multiplicamos nuestro valor del puertoC por nuestra ganancia
							//Rotaremos hacía la derecha el resultado de multiplicacion 4 veces, que es lo mismo que dividirlo entre 16
	ror r1		
	ror r0
	ror r1
	ror r0
	ror r1
	ror r0
	ror r1
	ror r0
	add r0, r21				//Sumamos el offset
	sts 0x47, r0			//Guardamos el valor en la dirección 0x47 que corresponde a el OCR0A (Output Compare Register, Clock 0, A mode)
	ret						//Retornamos de nuestra función