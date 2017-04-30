%include  "io.mac"

;Proyecto programado 1: Calculadora multi base bien tuanis que vamos a terminar en solo 3 dias
;by: Óscar Cortés && Randall Delgado


;------------------------------------------------------------------------------------------###
;#-#+#-#+#-#+#-#+#-#+#-#+#-#+# Macros #-#+#-#+#-#+#-#+#-#+#-#+#-#+#
;------------------------------------------------------------------------------------------
;Macro: valor de Precedenia
; Toma un valor de parametro y busca su valor en la variable precedencia
; AL encontrarlo, guarda el caracter en el ah y su valor en el al
; Por esto, el valor del ax que da modificado
%macro valorPrecedencia 1
    xor ebx, ebx
    xor esi, esi
        
    mov ebx, precedencia
    cicloPrece:
        cmp byte[ebx+esi], %1
        je finalizarPrece
            
        cmp byte [ebx+esi], '$'
        je finalizarPrece
            
        inc esi
        jmp cicloPrece
        
    finalizarPrece:
        inc esi
        mov ah, %1 ;Se guarda el conector en el ah
        mov al, byte[precedencia+esi] ;Y luego se guarda el valor del conector en al
%endmacro

;------------------------------------------------------------------------------------------
;Macro: esNumero
; Toma un valor de parametro y busca si trata de un carcter de número o de una letra aceptada
%macro esNumero 1
     
    cmp %1, '0'         ;Si es menor a '0'
    jb error_gen
        
    cmp %1, '9'         ;Si es menor o igual a '9'
    jbe esNumeroOBase
    
    cmp %1, 41h
    jb error_gen
    
    cmp %1, 46h
    jbe esNumeroOBase

    %endmacro

;------------------------------------------------------------------------------------------
;Macro: cmpStrings
; Entrada: Dos cadenas de caracteres y un label
; Compara dos cadenas de carcteres, si son iguales realiza el salto, si no lo son solo termina el macro
%macro cmpStrings 3
    push esi
    xor esi, esi
    
    %%cicloComp:
    mov cl, byte[%1+esi]
    mov ch, byte[%2+esi]
    
    cmp cl, ch
    jne %%falseCmp
    
    cmp cl, 0
    je %3
    
    inc esi
    jmp %%cicloComp
    
%%falseCmp:
    pop esi
    %endmacro
	
;------------------------------------------------------------------------------------------
;Macro: obtenerBase
; Compara el contenido de cl para saber cual base es. Escribe el valor en el bh
%macro obtenerBase 0
	cmp cl, 'b'
	je binario
	
	cmp cl, 'o'
	je octal
	
	cmp cl, 'h'
	je hexadecimal
	
	cmp cl, 'd'
	je decimal
	
	cmp cl, 30h
	jb final_obtBase
	
	cmp cl, 39h
	ja final_obtBase
	
	dec esi
	
decimal: mov dl, 10
	jmp final_obtBase

binario:mov dl, 2
	jmp final_obtBase
	
octal: mov dl, 8
	jmp final_obtBase

hexadecimal: mov dl, 16
	jmp final_obtBase
	
final_obtBase:
   %endmacro

;***------------------------------------Data segment------------------------------------ ***
.DATA
    mensaje db "Ingrese un comando o una operacion infija: ", 0
    
    men_errorOverflow db "Error: Se ha generado un número con un mayor tamaño del que se puede trabajar.", 0
    men_errorCaracter db "Error: Se ingreso una variable sin definir.", 0
    men_errorBase db "Error: Se ingreso un número que no pertenece al base indicada.", 0
    men_errorComando db "Error: No se ha encontrado el comando ingresado.", 0
    men_ayuda db "La ayuda viene en camino, cuando Randy la escriba", 0
    men_procedOn db "Ahora se mostraran los procedimientos.", 0
    men_procedOff db "Ahora se ocultaran los procedimientos.", 0
    
    mensajeTemp db "Ahorita no joven, estamos terminado esta parte del codigo",0
    
    comando_ayuda db "#ayuda", 0
    comando_procedimientos db "#procedimientos", 0
    comando_bits db "#bits", 0
    comando_var db "#var", 0
    comando_salir db "#salir", 0
    
    precedencia db '*', 10,  '/',10,  '+',5,  '-',5,    '$',0
    resultado dd 0
    mostrarProced db 0;
    prueba db "2",0
    

.UDATA
operacion resb 256
prefija resb 256
lineaComandos resb 256

.CODE
     .STARTUP    
;***------------------------------------Codigo segment------------------------------------ ***
inicio: PutStr mensaje              ;Se indica al usuario que puede usar un número o un comando 
    GetStr lineaComandos, 256       ;Se guarda el contenido de la linea de comandos en la variable
    mov ebx, lineaComandos
    call eliminaEspacios            ;Se llama a eliminaEspacios para borrar todos los espacios del contenido del ebx
        
    cmp byte[lineaComandos], '#'    ;Verifica si se trata de un comando
    je comandos
    
    cmp byte[lineaComandos], '~'    ;Verifica si se trata de un complemento de base
    je complementoDeBase
        
    cmp byte[lineaComandos], '.'    ;Verifica si se trata de convertir a punto flotante binario
    je convPuntoBinario
    
    jmp iniciarOperacion

;Lectura de los comandos
comandos: ;Hace una sere de comparaciones, si una comparacion es verdadera se hace un salto, sino se pasa a la siguiente comparacion
    cmpStrings lineaComandos, comando_ayuda, printAyuda
    cmpStrings lineaComandos, comando_procedimientos, final
    cmpStrings lineaComandos, comando_bits, final
    cmpStrings lineaComandos, comando_var, final
    cmpStrings lineaComandos, comando_salir, final
    
    PutStr men_errorComando ;Si el comando no es comatible con nadie.. 
    nwln
    jmp inicio  ;
    
    printAyuda:
        PutStr men_ayuda
        jmp inicio
    
    cambEstadoProc:
        cmp byte [mostrarProced], 0 ;Si esa apagado, se salta a encender
        je encenderMostrar
        
        mov byte [mostrarProced], 0 ;Sino, se apaga
        PutStr men_procedOff ;Se le notifica al usuario el cambio
        nwln
        jmp inicio
        
        encenderMostrar:
        mov  byte [mostrarProced], 1
        PutStr men_procedOn ;Se le notifica al usuario el cambio
        nwln
        jmp inicio
    
PutStr mensajeTemp
    nwln
    jmp inicio

;Converison de un numero a su complementoDeBase binario
complementoDeBase:PutStr mensajeTemp
    nwln
    jmp inicio

;Conversion del numero a binario flotante
convPuntoBinario:PutStr mensajeTemp
    nwln
    jmp inicio

;Solucion de la operacion ingresada
iniciarOperacion: enter 0,0 ;Se guardar el EBP
	mov ebx, lineaComandos
    call generaPrefija
    PutStr prefija ;resultado
    nwln
    cmp byte [prefija], '~' ;Si no se devolvió un error
    jne resolver            ;Se avanza
    
	PutStr men_errorCaracter
    jmp inicio

resolver:
    call resolverPrefija
    jmp inicio
           
final:
    nwln
.EXIT
;***------------------------------------Codigo ends------------------------------------ ***

;#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Procs #-#-#-#-#-#-#-#-#-#-#-#-#-#-#
;***------------------------------------------------------------------------------------------------------------***
;Proc: Elmina espacios
;Recibe un string en el ebx, lee todo el string
;y lo sobreescribe todo sin escribir espacios los espacios.
eliminaEspacios:
xor esi, esi
xor edi, edi
    
ciloElmEsp:
    mov al, byte [ebx + esi]
        
    cmp al, 20h
    je ciloElmEsp_aux
        
    mov byte [ebx + edi], al
    inc edi
        
    cmp al, 0
    je finalizarElmEsp
        
    ciloElmEsp_aux:
    inc esi
    jmp ciloElmEsp
    
finalizarElmEsp:
    ret

;***------------------------------------------------------------------------------------------------------------***
;Proc: Genera prefija
; Usa las varibales operacion y prefija y el macro valor Precedencia
; Lee el string operacion y va escribiendo en prefija la operacion infija en
; prefija.
; Details: Al leer caracteres si lee un numero o un indicador de base lo escribe sin más.
;    En caso de encontrar un conector aritmetico, salta a comparacion. En comparacion pasan tres cosas:
;    - Si la pila esta vacia se gurda el conector
;    - Si el conector que esta tiene mayor precedencia se guardan los dos
;    - Si tiene menor precedencia se escribe el que se saca y el actual se guarda en la pila
;    - Maneja los parentesis
generaPrefija:
xor esi, esi ;
xor edi, edi ;
mov [EBP+12], ebx ;se tiene en el ebx la direccion de la operacion
mov word [EBP + 16], 16 ; Eso
    
cicloGenPre:
	mov ebx, [EBP+12] ;se tiene en el ebx la direccion de la operacion
    mov dl, byte[ebx+esi];Se mueve al dl el contenido de operacion actual

    
    cmp dl, 0
    je finalizarGenPre  ;Si es 0 se finaliza el ciclo
    
    cmp dl, '('
    je parentesisIzq
    
    cmp dl, ')'
    je parentesisDer
        
    cmp dl, '+'
    je comparacion
        
    cmp dl, '*'
    je comparacion
        
    cmp dl, '/'
    je comparacion
        
    cmp dl, '-'
    je comparacion
        
    esNumero dl     ;Comprueba si es un número, de serlo salta a esNumeroOBase
    
    cmp dl, 'b'             ;Pasar esta area a macro
    je esNumeroOBase
        
    cmp dl, 'o'
    je esNumeroOBase
        
    cmp dl, 'd'
    je esNumeroOBase
        
    cmp dl, 'h'
    je esNumeroOBase
    
    jmp error_gen
        
cicloGenPre_aux:
    inc esi
    jmp cicloGenPre

parentesisIzq:
    xor ebx, ebx
    mov bx, [EBP + 16] ;Obtengo el desplazamiento
    add bx, 2 ;Agrego dos para llegar a la siguiente casilla
    mov al, 0 ;Se pone de precedencia 0
    mov ah, '(' ; a (
    mov [EBP + ebx], ax ;y se guarda
    mov [EBP + 16], bx ;se guarda el nuevo desplazamiento
    jmp cicloGenPre_aux
    
parentesisDer:
    xor ebx, ebx
    mov bx, [EBP + 16] ;Se obtiene el desplazamiento para llegar al ultimo valor en la pila
    mov byte[prefija+edi], ' ' ;Se escribe un espacio
    inc edi
        
    ciclo_parentesis:
        mov dx, [EBP + ebx] ;se pasa a dx el conector y su valor
        
        cmp dh, '('
        je fin_parentesis
        
        cmp bx, 16
        je error_gen
        
        mov byte[prefija+edi], dh ;Se escribe un conector
        inc edi
            
        mov byte[prefija+edi], ' ' ;Se escribe un espacio
        inc edi
        
        sub bx, 2
        jmp ciclo_parentesis
    
    fin_parentesis:
        mov byte[prefija+edi], 0 ;Se escribe un espacio
        dec edi
        
        sub bx, 2
        mov [EBP + 16], ebx
        jmp cicloGenPre_aux
    

esNumeroOBase:
    mov byte[prefija+edi], dl   ;Se escribe el digito
    inc edi                     ;Y se incrementa el edi
    jmp cicloGenPre_aux         ;Luego se salta al aux
        
error_gen:
    mov byte[prefija+0], '~'  ;Se escribe el digito
    ret

comparacion:
    mov [EBP + 8], esi         ;Y el valor del esi
    valorPrecedencia dl         ;Se obtiene el valor de precedencia
	mov esi, [EBP + 8] ;Se restablece el esi
    ;En este punto el ax tiene el conector en el ah y el valor en el al
    
    cmp word [EBP + 16], 16          ;si no se ha ingresado nadie, agreguelo a la pila
    je guardarEnPila
    ;0-7 = EBP, 8-11 = esi, 12-14 = a contador
    ;Si se ha ingresado a alguien se saca el conector y su valor de la pila
    
    xor ebx, ebx
    mov bx, [EBP + 16]          ;Se obtiene el desplazamiento para llegar al valor anterior
    mov dx, [EBP + ebx]         ;se pasa a dx el conector y su valor
        
    cmp al, dl                  ;Si el conector actual tiene mayor prioridad
    jae mayorPrioridad          ;se salta a mayorPrioridad
        
    jmp menorPrioridad ;Si no se salta a menor prioridad
        
    
guardarEnPila:;Si la pila esta vacia
    mov word [EBP + 16], 18
    
    mov [EBP+18], ax ;Se guarda en la pila el conector y su valor
    mov byte[prefija+edi], 20h ;Se pone un espacio en el string
    inc edi ;Se incrementa la direccion de destino
        
    jmp cicloGenPre_aux
    
mayorPrioridad: ;Se guardan los dos en la pila
    mov word [EBP + ebx], dx ;se guarda el valor anterior
    add bx, 2
    mov word [EBP + ebx], ax ;Se guarda el valor actual
        
    mov [EBP + 16], bx ;Se aumenta en dos la direccion

    mov byte[prefija+edi], ' ' ;Se escribe un espacio
    inc edi
        
    jmp cicloGenPre_aux ;Se sigue el ciclo
    
menorPrioridad:
    mov word [EBP + ebx], ax ;Se guarda el valor actual
    
    mov byte[prefija+edi], 20h ;Se escribe un espacio
    inc edi
    
    mov byte[prefija+edi], dh ;Se escribe el conector que se saco de pila
    inc edi
        
    mov byte[prefija+edi], 20h ;Se escribe un espacio
    inc edi
        
    jmp cicloGenPre_aux
    
finalizarGenPre:
    cmp word [EBP + 16], 16 ; Si no se han ingresado conectores se salta al final
    je fin_Aux
    
    xor eax, eax
    xor ebx, ebx
    mov bx, [EBP + 16] ;Se obtiene el desplazamiento para llegar al valor anterior
    mov byte[prefija+edi], ' ' ;Se escribe un espacio
    inc edi
        
    ciclo_prueba:
        mov dx, [EBP + ebx] ;se pasa a dx el conector y su valor
            
        mov byte[prefija+edi], dh ;Se escribe un conector
        inc edi
            
        mov byte[prefija+edi], ' ' ;Se escribe un espacio
        inc edi
        
        sub bx, 2
        cmp bx, 16
        jne ciclo_prueba
            
fin_Aux:
    mov byte[prefija+edi], 0
    ret

;***------------------------------------------------------------------------------------------------------------***
;Proc: Resolver prefija
; Lee la varibale prefija para 
resolverPrefija:
xor esi, esi ;Se limpia el esi
mov dword[EBP+12], 10 ;Se coloca en 12 al valor de referencia

ciclo_resolver:
	mov cl, [prefija+esi]	;Se guarda en cl el caracter
	
	;si no es un operando
	xor edx, edx
	obtenerBase ;Se obtiene el valor de la base en el dl
	cmp dl, 0
	je buscarOperando
	
	mov [EBP+8], edx
	
	call convertirADecimal
	inc esi
	jmp ciclo_resolver
	
	buscarOperando: 
	cmp cl, '+'
	je sumar
	
	jmp printSolucion
	ret

sumar:
	mov bx, [EBP+12] ;Mueve el desplzamiento al bx
	mov ecx, [EBP+ebx] ;Se mueve el ultimo numero
	
	sub bx, 5
	
	mov eax, [EBP+ebx]
	add eax, ecx
	mov [resultado], eax
	
	inc esi
	jmp ciclo_resolver

printSolucion:
	PutInt 4202
	nwln
	PutLInt [resultado]
	nwln
	ret
	
;***------------------------------------------------------------------------------------------------------------***
;Proc: Convertir a decimal
; Recibe la base fuente en el EBP + 8, y el numero en el cl,procesa el numero para obtener su
; valor decimal y guardarlo en el ax
; una vez que lo tiene lo guarda en el eax
convertirADecimal:
xor eax, eax

jmp ciclo_conversion

error_conversion:
    PutStr men_errorBase ;mensaje de error
    nwln
    ret
    
ciclo_conversion: inc esi
	mov cl, [prefija + esi]
    
    cmp cl, 20h ;Compara si hay un espacio
    je imprime  ;
    
    cmp cl, 0
    je imprime
	
	mov edx, [EBP+8]	;El edx guarda la base destino algo temporal
    sub cl, 30h     	;Se resta 30 para llegar al valor del numero
    
    cmp cl, 9;
    ja valLetra     ;si es mayor a 9, es un caracter hex entre A y F
	
    jmp suma    ;si no se sigue la conversion
    
    valLetra:
        sub cl, 7h  ;se resta 7 para llega al valor del numero hex
        
    suma:
		cmp ecx, edx  ;si es mayor que la base
        jae error_conversion    ;se salta a error
        mul edx      			;Se multiplica lo acumulado en el eax
        add eax, edx
		add eax, ecx
	
    jmp ciclo_conversion
        
imprime:
	mov dl, [EBP+8] ; Se obtiene la base
	;mov [resultado], eax
	xor ebx, ebx
	mov bx,[EBP+12] ;La direccion del ultimo numero en pila
	add ebx, 4		;Se aumenta a 4 para llegar a la siguiente casilla de base
	mov [EBP+ebx], dl ;Se guarda la base
	inc ebx
	mov [EBP+ebx], eax ;Se guarda el numero
	add word[EBP+12], 5 ;Se aumenta en 5 el contador para indciar al ultimo numero agregado
	
    ret