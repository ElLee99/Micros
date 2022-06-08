;
; Voltimetro digital.asm
;
; Created: 07/06/2022 12:07:54 p. m.
; Author : Johan Lee
;


; Replace with your application code

					.dseg 
					.org 0x100	
tabla_display:		.byte 0x10		//Reserva 16 espacios de memoria para el array de valores
					.cseg


.org 0
rjmp setup
.org 0x002A							//Vector de interrupción de ADC (cuando se ha completado la conversión)
rjmp ADC_Conversion


setup:

	cbi DDRC, 0						//Pone en cero el puerto C0 para configurarlo como entrada
	cbi PORTC, 0					//Activa la resistencia pulldown del puertoC0
	sbi DDRC, 1						//Pone en 1 el bit 1 del puertoC, para configurarlo como salida
	ldi r16,0xFF
	out DDRD, r16					//Configuramos el puertoD como salida
	out DDRB, r16					//Configuramos el puertoB como salida
									//Configuramos el ADMUX ADC Multiplexor Selection Register
	ldi r16, 0b0110_0000
	sts ADMUX, r16
									//Configuramos el ADCSRA ADC Control and Status Register
	ldi r16, 0b1000_1101
	sts ADCSRA, r16



	ldi r28,low (tabla_display)		//Inicializando el apuntador Y
    ldi r29, high (tabla_display)	
	ldi r16, 0b011_1111 ; Numero 0 display
	st y+, r16	
	ldi r16, 0b000_0110 ; Numero 1 display
	st y+, r16				
	ldi r16, 0b101_1011 ; Numero 2 display
	st y+, r16				
	ldi r16, 0b100_1111 ; Numero 3 display
	st y+, r16	
	ldi r16, 0b110_0110 ; Numero 4 display
	st y+, r16				
	ldi r16, 0b110_1101 ; Numero 5 display
	st y+, r16				
	ldi r16, 0b111_1101 ; Numero 6 display
	st y+, r16	
	ldi r16, 0b000_0111 ; Numero 7 display
	st y+, r16				
	ldi r16, 0b111_1111 ; Numero 8 display
	st y+, r16				
	ldi r16, 0b110_1111 ; Numero 9 display
	st y+, r16	


	ldi r16, 0b1100_1101
	sts 0x7a, r16		
	sei
	



main:								//Ciclo principal del programa
	rjmp main




ADC_Conversion:
									//Estas primeras 3 lineas guardan el valor de nuestro SREG
	push r16				
	in r16,SREG
	push r16
	call escalamiento				//Llamamos a la función de escalamiento

	ldi r16, 0b1100_1101
	sts 0x7a, r16					//Cargamos el valor de r16 al registro de memoria 0x7a(donde se encuentra el ADCSRA), con el fin de borrar la bandera de interrupción y vuelva a hacer la conversión
									//Estas ultimas lineas, regresan el valor que teniamos en el SREG, antes de entrar a la interrupción
	pop r16					
	out SREG,r16
	pop r16
	reti							//Retornamos de la interrupción


escalamiento:

	lds r16, ADCH					//Carga el valor de la parte alta de la conversion 
	ldi r17, 0b0001_1001			//Carga el valor de 0.19531.... al r17
	fmul r16,r17					//Multiplica el valor del r16 al r17, el segundo término lo agarra como fraccionario
	mov r16, r1						//Mueve el valor entero de nuestra multiplicación al r16
	ldi r17, 0b0000_1101			//Carga el valor de 0.1015625 al r17
	fmul r16, r17					//Multiplica el valor del r16 al r17, el segundo término lo agarra como fraccionario
	mov r21, r1						//Mueve el valor entero de nuestra conversión al r21
	sts 0x111, r1					//Carga el valor entero de nuestra conversión al r1
	ldi r17, 5						
	mul r0, r17						//Multiplicamos nuestro valor decimal de la conversion por 5 y lo dividimos por 128
	ror r1
	ror r0 
	ror r1
	ror r0 
	ror r1
	ror r0 
	ror r1
	ror r0 
	ror r1
	ror r0 
	ror r1
	ror r0 
	ror r1
	ror r0
	mov r22, r0						//Mueve el valor entero de nuestra conversión al r21
	sts 0x110, r0					//Carga el valor entero de nuestra conversión al r1



	clz								//Limpiamos la bandera de Z
	ldi r17, 10						//Cargamos el valor de 10 al r17 (contador)
	loop_comp:						//Loop de comparación para saber que numero entero tenemos
		dec r17
		cpse r17,  r21
		brne loop_comp
	mov r28, r17					//Movemos el valor del contador al apuntador de Y
	ld r16, Y						//Cargamos el valor apuntado en Y (Numero del display)
	out PORTD, r16					//Mandamos el valor del r16(numero del display) al PUERTOD
	sbi PORTD, 7					//Ponemos el punto decimal en 1

		
	clz								//Limpiamos la bandera de Z
	ldi r17, 10						//Cargamos el valor de 10 al r17 (contador)
	loop_comp2:						//Loop de comparación para saber que numero decimal tenemos
		dec r17
		cpse r17,  r22
		brne loop_comp2
	mov r28, r17					//Movemos el valor del contador al apuntador de Y
	ld r16, Y						//Cargamos el valor apuntado en Y (Numero del display)
	out PORTB, r16					//Mandamos el valor del r16(numero del display) al PUERTOD
	clr r17							//Limpiamos el r17
									//Rotamos a la izquierda el valor del r16 y r17
	rol r16
	rol r17
	rol r16
	rol r17
	rol r16
	rol r17
	out PORTC, r17					//Mandamos el valor del r17(numero rotado decimal del display) al PUERTOC
	ret								//Retornamos de la función