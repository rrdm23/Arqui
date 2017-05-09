;Complemento a 2

%include "io.mac"

.DATA

bienvenida db 'Digite un número: ',0 
error db 'Error en el input',0

.UDATA

numero resb 32
compl resb 32
cantDigitos resb 5

.CODE
	.STARTUP
	
	PutStr bienvenida
	GetStr numero

	xor ESI, ESI

numCarac:
	cmp byte[numero+ESI], 0
	je cont
	inc ESI
	jmp numCarac

cont:	
	;PutLInt ESI
	mov [cantDigitos], ESI	
	xor EAX, EAX
	call convADecimal
	;PutLInt EDX

	xor ESI, ESI
	mov EAX, EDX
	xor EBX, EBX
	xor ECX, ECX
	call convABinario

	PutStr numero

salida:
	nwln
	.EXIT

convADecimal:
	cmp ESI, 0
	je salir
	dec ESI	
	mov AL, [numero+ESI]
	sub AL, 30h
	
	mov BL, 10	

	mov ECX, [cantDigitos]
	dec ECX
	sub ECX, ESI
		
ciclomul:
	cmp ECX, 0
	je continuar
	mul BL
	dec ECX
	jmp ciclomul

continuar:
	add EDX, EAX
	jmp convADecimal
salir:	
	ret

convABinario:
	rol EAX, 1
	jc uno
	cmp EBX, 1
	jge cero
	jmp comp
cero:
	mov byte[numero+ESI], 30h
	inc ESI	
	jmp comp
uno:
	inc EBX
	mov byte[numero+ESI], 31h
	inc ESI
comp:
	cmp ESI, 32
	jne convABinario
	ret

