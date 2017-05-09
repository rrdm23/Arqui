;Instituto Tecnológico de Costa Rica
;Escuela de Computación
;IC-3101 Arquitectura de Computadores
;Tarea Programada #1
;Prof. Esteban Arias Méndez
;Estudiantes:
;Randall Delgado Miranda
;Óscar Cortés Cordero
;Grupo #2
;Fecha de entrega: 29 de abril
;I Semestre 2017

%include "io.mac"

.DATA

bienvenida db 'Digite un número en punto flotante: ',0 
error db 'El número ingresado no es flotante',0
exito db 'Número dividido',0

.UDATA

numero resb 32
parteEntera resb 32
parteDecimal resb 32

.CODE
	.STARTUP

	enter 0,0
	PutStr bienvenida
	GetStr numero
	mov EDX, numero
	xor EBX, EBX
entero:
	mov AL, byte[EDX]
	mov [parteEntera+EBX], AL
	inc EBX
	inc EDX
	cmp byte[EDX], 0
	je noFlotante
	cmp byte[EDX], 46
	jne entero

	xor EBX, EBX
	inc EDX

decimal:
	mov AL, byte[EDX]
	mov [parteDecimal+EBX], AL
	inc EBX
	inc EDX
	cmp byte[EDX], 0
	jne decimal
	jmp siFlotante

noFlotante:
	PutStr error
	jmp salida

siFlotante:
	mov EBX, parteEntera
	mov byte[EBP+8], 10
	mov CL, byte[EBX]
	call convertirADecimal
	PutLInt EAX	
	PutStr exito

salida:
	nwln
	.EXIT

;--------------------------------------------------------

;Proc: Convertir a decimal
; Recibe la base fuente en el EBP + 8, y el numero en el cl,procesa el numero para obtener su
; valor decimal y guardarlo en el ax
; una vez que lo tiene lo guarda en el eax
convertirADecimal:
xor eax, eax
	
jmp ciclo_conversion

error_conversion:
    PutStr error ;mensaje de error
    nwln
    ret
    
error_overflowC:
	ret
    
ciclo_conversion: inc esi
	mov cl, [ebx + esi]
    
    cmp cl, 20h ;Compara si hay un espacio
    je imprime  ;Si lo hay termina
    
    cmp cl, 0 ;Si es un 0 tambien se termina
    je imprime
	
	mov edx, [EBP+8]	;El edx guarda la base destino algo temporal
    sub cl, 30h     	;Se resta 30 para llegar al valor del numero
    
    cmp cl, 9;
    ja valLetra     ;si es mayor a 9, es un caracter hex entre A y F
	
    jmp suma    ;si no se sigue la conversion
    
    valLetra:
        sub cl, 7h  ;se resta 7 para llega al valor del numero hex
        
    suma:
		cmp ecx, edx  			;si es mayor que la base
        jae error_conversion    ;se salta a error
        mul edx      			;Se multiplica lo acumulado en el eax
		add eax, ecx
		jo error_overflowC		;Error de overflow por numero ingresado
	
    jmp ciclo_conversion
        
imprime:
    ret








