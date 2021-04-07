format pe64 dll efi
entry main

section '.text' code executable readable

; Permite utilizar las funciones de I/O
include 'uefi.inc'

main:
	;Se inicializa la biblioteca UEFI
	InitializeLib
	jmp jugar

jugar:

	uefi_call_wrapper ConIn, Reset, ConIn, 0

	call mover_carros
	call pintar_carretera
	call get_user_input
	call identify_key
	jmp jugar

mover_carro_pequeno:
	xor eax,eax

	mov eax,[carro_pequeno_pos]

	; Borra el carro y pone un - 
	mov cl,byte[empty_cell]
	mov byte[board+eax],cl

	; Mover el carro para la izquierda
	sub eax,2

	call verificar_carro_pequeno
	call verificar_choque_p

	; Dibuja un O y actualiza la posicion
	mov cl,byte[vehicle]
	mov byte[board+eax],cl
	mov [carro_pequeno_pos],eax

	retn

mover_carro_mediano:
	xor eax,eax


	mov eax,[carro_mediano_pos]

	; Borra el carro y pone un - 
	mov cl,byte[empty_cell]
	mov byte[board+eax],cl

	; Mueve el carro mediano hacia la derecha
	add eax,4

	call verificar_carro_mediano
	call verificar_choque_m

	; Dibuja dos OO y actualiza la posicion
	mov cl,byte[vehicle]
	mov byte[board+eax],cl
	sub eax,2
	; Update the position
	mov [carro_mediano_pos],eax

	retn

mover_carro_grande:
	xor eax,eax

	mov eax,[carro_grande_pos]

	mov cl,byte[empty_cell]
	mov byte[board+eax],cl

	add eax,6

	call verificar_carro_grande
	call verificar_choque_g

	mov cl,byte[vehicle]
	mov byte[board+eax],cl

	sub eax,4

	; Actualiza la posicion
	mov [carro_grande_pos],eax
	retn

; Verifica si llega a la izquierda
verificar_carro_pequeno:
	add eax,2
	cmp eax,[limite_izquierdo4]
	je devolver_carrop

	sub eax,2
	retn

; Verifica si llega a la derecha
verificar_carro_mediano:
	sub eax,2
	cmp eax,[limite_derecho3]
	je devolver_carrom

	add eax,2
	retn

; Verifica si llega a la derecha
verificar_carro_grande:
	sub eax,2
	cmp eax,[limite_derecho2]
	je devolver_carrog


	add eax,2
	retn

; Devuelve el carro a la derecha
devolver_carrop:
	; Borra el carro 
	mov cl,byte[empty_cell]
	mov byte[board+eax],cl

	; Dibuja el carro en el otro extremo
	sub eax,2
	add eax,[columnas_carretera]

	xor ecx,ecx
	mov cl,byte[vehicle]
	mov byte[board+eax],cl

	; Actualiza la posicion
	mov [carro_pequeno_pos],eax

	jmp jugar

; Devuelve el carro mediano a la izquierda
devolver_carrom:
	; Borra dos OO
	mov cl,byte[empty_cell]
	mov byte[board+eax],cl

	sub eax,2
	mov byte[board+eax],cl

	; Obtiene la posicion inicial de la fila
	add eax,4
	sub eax,[columnas_carretera]

	; Dibuja OO al inicio
	xor ecx,ecx
	mov cl,byte[vehicle]
	mov byte[board+eax],cl
	add eax,2
	mov byte[board+eax],cl
	sub eax,2

	; Actualiza la posicion
	mov [carro_mediano_pos],eax

	jmp jugar


devolver_carrog:
	; Delete the 3 bus 'OOO'
	mov cl,byte[empty_cell]
	mov byte[board+eax],cl

	sub eax,2
	mov byte[board+eax],cl

	sub eax,2
	mov byte[board+eax],cl

	add eax,6
	sub eax,[columnas_carretera]

	xor ecx,ecx
	mov cl,byte[vehicle]
	mov byte[board+eax],cl
	add eax,2
	mov byte[board+eax],cl
	add eax,2
	mov byte[board+eax],cl

	sub eax,4

	mov [carro_grande_pos],eax

	jmp jugar

; Valida si se choco con un carro pequeno
verificar_choque_p:

	xor ecx,ecx
	mov cl,byte[frog]

	cmp byte[board+eax],cl
	je game_over

	retn

; Valida si se choco con un carro mediano 
verificar_choque_m:

	xor ecx,ecx
	mov cl,byte[frog]

	cmp byte[board+eax],cl
	je game_over

	retn

; Valida si se choco con un carro grande
verificar_choque_g:

	xor ecx,ecx
	mov cl,byte[frog]

	cmp byte[board+eax],cl
	je game_over

	retn

mover_carros:
	call mover_carro_pequeno
	call mover_carro_mediano
	call mover_carro_grande
	retn

pintar_carretera:
	uefi_call_wrapper ConOut, OutputString, ConOut, board
	retn


get_user_input:
	uefi_call_wrapper ConIn, ReadKeyStroke, ConIn, INPUT_KEY
	cmp byte[INPUT_KEY.UnicodeChar], 0
	jz get_user_input
	retn


identify_key:
	call clear_screen
	cmp byte[INPUT_KEY+2], "w"
	je mover_arriba
	cmp byte[INPUT_KEY+2], "a"
	je mover_izquierda
	cmp byte[INPUT_KEY+2], "s"
	je mover_abajo
	cmp byte[INPUT_KEY+2], "d"
	je mover_derecha

	retn

clear_screen:
	; funcion de uefi para limpiar pantalla
	uefi_call_wrapper ConOut, ClearScreen, ConOut
	retn

mover_abajo:

	xor eax,eax
	mov eax,[posicion_frogger]

	call validar_primera_fila

	; Borra a frogger y pone un -
	mov cl,byte[empty_cell]
	mov byte[board+eax],cl

	add eax,72

	call validar_game_over

	; Dibuja a frogger en la nueva posicion
	mov cl,byte[frog]
 	mov byte[board+eax],cl

	; Actualiza a frogger
	mov [posicion_frogger],eax

	retn

mover_arriba:


	xor eax,eax

	mov eax,[posicion_frogger]

	mov cl,byte[empty_cell]
	mov byte[board+eax],cl

	sub eax,72

	call validar_game_over
	call validar_victoria

	mov cl,byte[frog]
 	mov byte[board+eax],cl

	mov [posicion_frogger],eax

	retn

mover_derecha:

	xor eax,eax

	mov eax,[posicion_frogger]

 	mov cl,byte[empty_cell]
	mov byte[board+eax],cl

	add eax,2

	call validar_game_over
	call llego_limite_derecho

	mov cl,byte[frog]
	mov byte[board+eax],cl

	mov [posicion_frogger],eax

	retn

mover_izquierda:

	xor eax,eax

	mov eax,[posicion_frogger]

	mov cl,byte[empty_cell]
	mov byte[board+eax],cl

	sub eax,2

	call validar_game_over
	call llego_limite_izquierdo

	mov cl,byte[frog]
	mov byte[board+eax],cl

	mov [posicion_frogger],eax

	retn

validar_game_over:

	; Valida si frogger colisiona
	cmp byte[board+eax], 'O'
	je game_over
	retn

validar_primera_fila:
	add eax,72
	cmp eax, [limite_derecho5]
	jg jugar

	sub eax,72
	retn

validar_victoria:
	cmp eax,[columnas_carretera]
	jl victoria
	retn

; Valida si frogger llego al limite y lo devuelve al otro lado
llego_limite_derecho:
	sub eax,2
	cmp eax,[limite_derecho5]
	je devolver_frogger_izquierda
	cmp eax,[limite_derecho4]
	je devolver_frogger_izquierda
	cmp eax,[limite_derecho3]
	je devolver_frogger_izquierda
	cmp eax,[limite_derecho2]
	je devolver_frogger_izquierda

	add eax,2

	retn

devolver_frogger_izquierda:

	mov cl,byte[empty_cell]
	mov byte[board+eax],cl

	; Get the last position of the row
	add eax,2
	sub eax,[columnas_carretera]

	mov cl,byte[frog]
	mov byte[board+eax],cl

	; Update frog position
	mov [posicion_frogger],eax

	jmp jugar


llego_limite_izquierdo:

	add eax,2
	cmp eax,[limite_izquierdo5]
	je devolver_frogger_derecha
	cmp eax,[limite_izquierdo4]
	je devolver_frogger_derecha
	cmp eax,[limite_izquierdo3]
	je devolver_frogger_derecha
	cmp eax,[limite_izquierdo2]
	je devolver_frogger_derecha


	sub eax,2

	retn

devolver_frogger_derecha:

	mov cl,byte[empty_cell]
	mov byte[board+eax],cl


	sub eax,2
	add eax,[columnas_carretera]

	mov cl,byte[frog]
	mov byte[board+eax],cl


	mov [posicion_frogger],eax

	jmp jugar

game_over:
	;Limpia la pantalla muestra mensaje de error y llama a finalizar
	call clear_screen
	uefi_call_wrapper ConOut, OutputString, ConOut, mensaje_game_over 
	jmp finalizar

victoria:
	call clear_screen
	uefi_call_wrapper ConOut, OutputString, ConOut, mensaje_gane
	jmp finalizar

finalizar:
	mov eax, EFI_SUCCESS
	uefi_call_wrapper BootServices, Exit, BootServices

section '.data' data readable writeable

	;Definicion de los limites y posiciones
	limite_derecho1	dd		68
	limite_derecho2	dd		142
	limite_derecho3	dd		214
	limite_derecho4	dd		286
	limite_derecho5	dd		358
	limite_izquierdo1	dd		8
	limite_izquierdo2	dd		76
	limite_izquierdo3	dd		148
	limite_izquierdo4	dd		220
	limite_izquierdo5	dd		292
	posicion_frogger		dd		326
	carro_grande_pos		dd		80
	carro_mediano_pos	dd		182
	carro_pequeno_pos		dd		242
	
	filas_carretera			dd		5
	columnas_carretera			dd		68
	len_board				dd		360

	board						du		13,10,'----------------------------------',\
												13,10,'---OOO----------------------------',\
												13,10,'-------------------OO-------------',\
								 				13,10,'-----------O----------------------',\
								 				13,10,'-----------------M----------------',13,10,0

	frog						du		'M'
 	empty_cell			du		'-'
	vehicle					du		'O'
	INPUT_KEY				EFI_INPUT_KEY
	mensaje_game_over  	du 		'Game Over, Frogger fue brutalmente aplastado',13,10,\
												'',13,0
	mensaje_gane	  	du 		'Ganaste! Frogger ha vuelto con su esposa e hijos',13,10,\
												'',13,0
	
section '.reloc' fixups data discardable

