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


.org 0								//Vector de interrupción del RESET
rjmp setup
.org 0x002A							//Vector de interrupción de ADC (cuando se ha completado la conversión)
rjmp ADC_Conversion


setup:

	cbi DDRC, 5						//Pone en cero el puerto C0 para configurarlo como entrada
	cbi PORTC, 5					//Activa la resistencia pulldown del puertoC0
	sbi DDRC, 0						//Pone en 1 el bit 0 del puertoC, para configurarlo como salida
	sbi DDRC, 1						//Pone en 1 el bit 1 del puertoC, para configurarlo como salida
	sbi DDRC, 2						//Pone en 1 el bit 2 del puertoC, para configurarlo como salida
	sbi DDRC, 3						//Pone en 1 el bit 3 del puertoC, para configurarlo como salida
	ldi r16,0b1111_1100
	out DDRD, r16					//Configuramos el puertoD como salida
	ldi r16, 0xFF
	out DDRB, r16					//Configuramos el puertoB como salida
									//Configuramos el ADMUX ADC Multiplexor Selection Register
	ldi r16, 0b0110_0101
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


	ldi r16, 0b1100_1101			//Configuramos el ADCSRA ADC Control and Status Register, pero ahora iniciamos el ADC Start Conversion
	sts 0x7a, r16		
	sei
	



main:
	


									//Ciclo principal del programa
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
	clz								//Limpiamos la bandera de Z
									//Tenemos while anidado que nos ayudará a comparar el valor de r16 (nuestro voltaje), una vez que sepamos cual es, se sale del while, 
									//ya con las direcciones de memoria del display

	ldi r18, 0						
	loop_comp1:		
		inc r18
		ldi r17, 10
		ldi r19, 10
		mul r17, r18
		mov r17, r0			
		loop_comp2:
			dec r19
			dec r17
			cpi r17, 0
			breq loop_comp1
			cpi r17, 70
			breq es_cero			//En caso de que nuestro voltaje sea cero, nos vamos a la rutina es_cero
			cp r17,  r16
			brne loop_comp2

display:
	dec r18
	mov r28, r19					//Movemos el valor del contador r18 (nuestro entero) al apuntador de Y
	ld r16, Y						//Cargamos el valor apuntado en Y (Numero del display)
	mov r28, r18					//Movemos el valor del contador r18 (nuestro decimal) al apuntador de Y
	ld r17, Y						//Cargamos el valor apuntado en Y (Numero del display)
									//Rotamos el valor de los segmentos a los puertos que queremos usar en esta práctica
	clr r20
	lsl r16
	rol r17
	rol r20
	lsl r16
	rol r17
	rol r20
	out PORTD, r16					//Mandamos el valor del r16(numero del display) al PUERTOD
	out PORTB, r17					//Mandamos el valor del r17(numero del display) al PUERTOB
									//Rotamos otras dos veces el valor de nuestro r17, que será el que se desplegue en el PUERTOC, compensar el B7 y B8, que no estan en nuetra tarjeta
	lsl r17
	rol r20
	lsl r17
	rol r20
	out PORTC, r20					//Mandamos el valor del r20(numero del display) al PUERTOC
	sbi PORTC, 3					//Seteamos el valor del PUERTOC3, que es el punto decimal
	ret								//Retornamos de la función

es_cero:							//En caso de que sea cero, le damos los valores que va a desplegar en el display
	ldi r18, 1						
	ldi r17, 0
	rjmp display					//Saltamos a la función del display