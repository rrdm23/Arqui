%include  "io.mac"

;Proyecto programado 1: Calculadora multi base
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
;Macro: esBase
; Toma un valor de parametro y busca si trata de un carcter de número o de una letra aceptada
%macro esBase 1
	cmp %1, 'b'         ;Por ultimo valida que se trate de una base
    je esNumeroOBase
        
    cmp %1, 'o'
    je esNumeroOBase
        
    cmp %1, 'd'
    je esNumeroOBase
        
    cmp %1, 'h'
    je esNumeroOBase
%endmacro
;------------------------------------------------------------------------------------------
;Macro: cmpStrings
; Entrada: Dos cadenas de caracteres y un label
; Compara dos cadenas de caracteres, si son iguales realiza el salto, si no lo son solo termina el macro
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
	men_bienvenida db "Calculadora4B",10, 13, "Ingrese #ayuda para consultar la ayuda de ser necesario.", 0
    mensaje db "Ingrese un comando o una operacion infija: ", 0
    
    men_errorOverflow db "Error: Se ha generado un número con un mayor tamaño del que se puede trabajar.", 10, 13, 0
    men_errorCaracter db "Error: Se ingreso una variable sin definir.", 10, 13, 0
    men_errorBase db "Error: Se ingreso un número que no pertenece al base indicada.", 10, 13, 0
    men_errorComando db "Error: No se ha encontrado el comando ingresado.", 10, 13, 0
    men_ayuda db 10, 13, "Se encuentra en la ayuda. El programa consiste en una calculadora capaz de operar en bases como decimal, binario, octal y hexadecimal. Los comandos disponibles son los siguientes: ", 10, 13, "#ayuda: Muestra esta pantalla.", 10, 13, "#procedimiento: Activa o desactiva si se desea mostrar el procedimiento de la operación en binario.", 10, 13, "#bits: Útil para indicar cuántos bits de precisión se desean para las conversiones en punto flotante.", 10, 13, "#var: Muestra las variables definidas hasta el momento y su valor.", 10, 13, "#salir: Permite salir del programa.", 10, 13, 10, 13, 0
    men_procedOn db "Ahora se mostraran los procedimientos.", 0
    men_procedOff db "Ahora se ocultaran los procedimientos.", 0
    
    mensajeTemp db "Ahorita no joven, estamos terminado esta parte del codigo",0
	igual db '=',0
    mensajeSalida db "Instituto Tecnológico de Costa Rica", 10, 13, "Ingeniería en Computación", 10, 13, "IC-3101 Arquitectura de Computadores", 10, 13, "Prof. Esteban Arias Méndez", 10, 13, "Óscar Cortés Cordero - Randall Delgado Miranda", 10, 13, "I Semestre 2017", 10, 13, 0
    comando_ayuda db "#ayuda", 0
    comando_procedimientos db "#procedimiento", 0
    comando_bits db "#bits", 0
    comando_var db "#var", 0
    comando_salir db "#salir", 0
    
	enun_operacion1 db "---------- Operacion segment ----------", 0
	enun_operacion2 db "------------ Operacion ends ------------", 0
	
	enun_comando1 db "---------- Comando segment ----------", 0
	enun_comando2 db "------------ Comando ends ------------", 0
	
	enun_complemento1 db "---------- Complemento segment ----------", 0
	enun_complemento2 db "------------ Complemento ends ------------", 0
	
	
	
    precedencia db '*', 10,  '/',10,  '+',5,  '-',5,  '%',10, '$',0
    resultado dd 0
    mostrarProced db 0;
    flag_negativo db 0 ;valor booleano para saber si es negativo o no :)
	

.UDATA
strComplemento resb 256	;No sé, aqui se lo deje a Randy
prefija resb 256		;Se usa para guardar la expresion prefija
prefijaAux resb 256		;Se tiene un respaldo de 256 bytes para guardar las operaciones
lineaComandos resb 256	;Se reservan 256 bytes para la linea de comandos
variable resb 15 		;Se reservan 15 bytes por variable
baseRespuesta resb 1 	;Guarda el valor de la base en la parte alta y el char de la base en la parte baja
.CODE
     .STARTUP    
;***------------------------------------Codigo segment------------------------------------ ***
bienvenida: PutStr men_bienvenida
mov byte[mostrarProced], 0
nwln
inicio: ;PutStr mensaje              ;Se indica al usuario que puede usar un número o un comando 
	PutCh '>'
	PutCh '>'
	GetStr lineaComandos, 256       ;Se guarda el contenido de la linea de comandos en la variable
	
	;Se comprueba primero si esta en blanco la linea de comandos
	cmp byte[lineaComandos], 0 ;Primero si esta en blanco
	je inicio
	
	enter 0,0 ;Se guardar el EBP
    
	;Se eliminan los espacios antes de comprobar que hay
    mov ebx, lineaComandos		;Se mueve para eliminar los espacios
    call eliminaEspacios		;Se llama a eliminaEspacios para borrar todos los espacios del contenido del ebx
    
	
	;Se empieza a comprobar que hay en la linea de comandos
    cmp byte[lineaComandos], '#'	;Verifica si se trata de un comando
    je comandos
	
    cmp byte[lineaComandos], '~'    ;Verifica si se trata de un complemento de base
    je complementoDeBase
        
    cmp byte[lineaComandos], '.'    ;Verifica si se trata de convertir a punto flotante binario
    je convPuntoBinario
    
    ;jmp iniciarOperacion 	;Si no es ninguno de los anteriores es una operacion
    ;Si no se ingresa nada de lo anterior, se debe de revisar si se trata de una declaracion de variable o una operacion
	xor ecx, ecx
	xor esi, esi
	xor edi, edi
	
	ciclo_lectura:
		cmp byte[lineaComandos+esi], ':' ;Si encuentra un : es seguro que trata de una declaracion de una variable
		je declararVariable
		
		cmp byte[lineaComandos+esi], 0
		je error_raro
		
		cmp byte[lineaComandos+esi], 39h ;Si es menor se puede tratar de un conector o un numero pero no de una letra
		jbe iniciarOperacion
		inc esi
		
		jmp ciclo_lectura
		
error_raro: ;No se me ocurre como puede llegar a esta parte del codigo... pero por aquello
	jmp inicio
	
declararVariable:
	jmp inicio
	
;Lectura de los comandos
comandos: ;Hace una sere de comparaciones, si una comparacion es verdadera se hace un salto, sino se pasa a la siguiente comparacion
    cmpStrings lineaComandos, comando_ayuda, printAyuda
    cmpStrings lineaComandos, comando_procedimientos, cambEstadoProc
    cmpStrings lineaComandos, comando_bits, final
    cmpStrings lineaComandos, comando_var, final
    cmpStrings lineaComandos, comando_salir, final
    
    PutStr men_errorComando ;Si el comando no es compatible con nadie.. 
    nwln
    jmp inicio  
    
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
        mov byte [mostrarProced], 1
        PutStr men_procedOn ;Se le notifica al usuario el cambio
        nwln
        jmp inicio

;Conversion de un numero a su complementoDeBase binario
    complementoDeBase:
    mov ebx, lineaComandos 
    mov esi, 1 ;Se indica que se lee el segundo caracter de base
    call iniciarComplementoBase
    jmp inicio
    
    nwln
    jmp inicio

;Conversion del numero a binario flotante
    convPuntoBinario:
    PutStr mensajeTemp
    nwln
    jmp inicio

;Solucion de la operacion ingresada
iniciarOperacion: 
	nwln
	PutStr enun_operacion1 ;Enunciado de inicio operación
	nwln
	mov ebx, lineaComandos
    call generaPrefija
	
    cmp byte [prefija], '~' ;Si no se devolvió un error
    jne resolver            ;Se avanza
    
	PutStr men_errorCaracter
	nwln
    jmp inicio

resolver:
	call ajustarPrefija ;Se ajustan los espacios
	enter 0,0
    call resolverPrefija ;Se llama al proc que se encarga de resolver la operacion
	nwln
	PutStr enun_operacion2
	nwln
    jmp inicio
           
final:
    PutStr mensajeSalida
    nwln
.EXIT
;***------------------------------------Codigo ends------------------------------------ ***

;#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Procs #-#-#-#-#-#-#-#-#-#-#-#-#-#-#
;***------------------------------------------------------------------------------------------------------------***
;Proc: iniciarComplemento de base
;Inicia el proceso de sacar el complemento de base del contenido en el ebx con el esi apuntado al caracter de base
iniciarComplementoBase:
xor edx, edx
mov cl, [ebx+esi] ;Se mueve el carcter al cl
;Dependiendo del caracter se realiza un salt
cmp cl, 'b'
je complementoBin

cmp cl, 'd'
je complementoDec

cmp cl, 'o'
je complementoOct

cmp cl, 'h'
je complementoHex
;Si no es un caracter de base se verifica que sea de numero

cmp cl, '0';Si es menor a 0 da error
jb errorComplemento

cmp cl, '9';Si es mayot a 9 tambien
ja errorComplemento

dec esi ;Si es un numero se reduce el esi y se trata como un decimal

;En base al caracter de base se guarda un valor en el dl
complementoDec:
	mov dl, 10
	
complementoBin:
	mov dl, 2
	
complementoOct:
	mov dl, 8

complementoHex:
	mov dl, 16
	
mov [EBP+8], edx
call convertirADecimal ;Se obtiene el valor del numero en decimal
PutLInt eax
nwln
call mostrarComplemento
ret

errorComplemento:
	ret

;Recibe el número en el eax, se encarga de mostrar los pasos de complemento de base 2
mostrarComplemento: nwln 
	call mostrarBits; 	;Se muestra el binario actual
	nwln
	not eax 			;Se cambian unos y ceros
	call mostrarBits;	;Se muestra el cambio
	nwln
	PutCh '+'			;Se muestra que se suma 1
	PutCh '1'
	add eax, 1			;Se suma 1
	nwln
	call mostrarBits; 	;Y se muestra el resultado que seria el complemento

	;Se restablece el eax para seguir con los procesos
not eax		;Se niega a eax
add eax, 1 	;Se suma 1
nwln
ret


;Recibe en el eax el numero a imprimir. Lee los 1's y 0's para imprimirlos en pantalla
mostrarBits:
mov cx, 32
ciclo_mostarBits:
	rol eax, 1
	jc mostrarUno
	
	;mostrarCero
	PutCh '0'
	jmp continuarMostBits
	mostrarUno:
		PutCh '1'
	
	continuarMostBits:
	loop ciclo_mostarBits
	
	ret
	
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
	
mov [EBP+12], ebx 		;Se tiene en el ebx la direccion de la operacion
mov word [EBP + 16], 16 ;Guarda el desplzamiento a la ultima ingresada
  
jmp cicloGenPre

baseRes: inc esi
	mov dl, byte[ebx+esi];Se mueve al dl el contenido despues del =
	
	;validacion
	inc esi
	cmp byte[ebx+esi], 0
	jne error_gen
	;fin validacion
	
	cmp dl, 'b'         ;Por ultimo valida que se trate de una base
    je baseRes_bin
        
    cmp dl, 'o'
    je baseRes_oct
        
    cmp dl, 'd'
    je  baseRes_dec
        
    cmp dl, 'h'
    je  baseRes_hex
	
	cmp dl, 'd'
    je  baseRes_dec
	
	cmp dl, 0
    je  baseRes_dec
	
	jmp error_gen
	
	baseRes_bin: mov byte[baseRespuesta], 2
	jmp finalizarGenPre
	
	baseRes_oct: mov byte[baseRespuesta], 8
	jmp finalizarGenPre
	
	baseRes_dec: mov byte[baseRespuesta], 10
	jmp finalizarGenPre
	
	baseRes_hex: mov byte[baseRespuesta], 16
	jmp finalizarGenPre

cicloGenPre: mov ebx, [EBP+12] 	;se tiene en el ebx la direccion de la operacion
    mov dl, byte[ebx+esi]		;Se mueve al dl el contenido de operacion actual

    cmp dl, 0
    je baseRes_dec  ;Si es 0 se finaliza el ciclo
	
	cmp dl, '='
	je baseRes
    
    cmp dl, '('
    je parentesisIzq
    
    cmp dl, ')'
    je parentesisDer
        
    cmp dl, '+'
    je cambioSignosPos
        
    cmp dl, '*'
    je comparacion
        
    cmp dl, '/'
    je comparacion
        
    cmp dl, '-'
    je cambioSignosNeg
	
	cmp dl, '%'
	je comparacion
        
    esNumero dl     	;Comprueba si es un número, de serlo salta a esNumeroOBase
    
    esBase dl			;Comprueba si es base
    
    jmp error_gen

cambioSignosPos:
	cmp byte[ebx+esi+1], '-'
	je cambioPosNeg
	
	cmp byte[ebx+esi+1], '+'
	je cambioPosPos
	
	jmp comparacion
	
	cambioPosNeg: inc esi
		mov byte[ebx+esi], '-'
		jmp cicloGenPre
	
	cambioPosPos: inc esi
		mov byte[ebx+esi], '+'
		jmp cicloGenPre

cambioSignosNeg:
	cmp byte[ebx+esi+1], '-'
	je cambioNegNeg
	
	cmp byte[ebx+esi+1], '+'
	je cambioNegPos
	
	jmp comparacion
	
	cambioNegNeg: inc esi
		mov byte[ebx+esi], '+'
		jmp cicloGenPre
	
	cambioNegPos: inc esi
		mov byte[ebx+esi], '-'
		jmp cicloGenPre

cicloGenPre_aux:
    inc esi
    jmp cicloGenPre

parentesisIzq: xor ebx, ebx
    mov bx, [EBP + 16] 	;Obtengo el desplazamiento
	add bx, 2 			;Agrego dos para llegar a la siguiente casilla
    mov al, 0 			;Se pone de precedencia 0
    mov ah, '(' 		; a (
    mov [EBP + ebx], ax ;y se guarda
    mov [EBP + 16], bx ;se guarda el nuevo desplazamiento
	nwln
	PutInt bx
	nwln
    jmp cicloGenPre_aux
    
parentesisDer:
    xor ebx, ebx
    mov bx, [EBP + 16] ;Se obtiene el desplazamiento para llegar al ultimo valor en la pila
    mov byte[prefija+edi], ' ' ;Se escribe un espacio
    inc edi
    
	ciclo_parentesis:
        mov dx, [EBP + ebx] ;se pasa a dx el conector y su valor
        
        cmp dh, '(' 		;Se detiene al encontrar un parentesis izquierdo
        je fin_parentesis
        
        cmp bx, 16
        je error_gen
        
        mov byte[prefija+edi], dh 	;Se escribe un conector
        inc edi
            
        mov byte[prefija+edi], ' ' 	;Se escribe un espacio
        inc edi
        
        sub bx, 2
        jmp ciclo_parentesis
    
    fin_parentesis:
        sub bx, 2 			;Se resta el bx para no poder acceder luego al parentesis izquierdo
        mov [EBP + 16], bx
        jmp cicloGenPre_aux
		
esNumeroOBase:
    mov byte[prefija+edi], dl   ;Se escribe el digito
    inc edi                     ;Y se incrementa el edi
    jmp cicloGenPre_aux         ;Luego se salta al aux
        
error_gen:
    mov byte[prefija+0], '~'  ;Se escribe el digito
	nwln
    ret

comparacion:
    mov [EBP + 8], esi         	;Lo guarda
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
    ja mayorPrioridad          ;se salta a mayorPrioridad
        
    jmp menorPrioridad ;Si no se salta a menor prioridad
        
    
guardarEnPila:;Si la pila esta vacia
    mov word [EBP + 16], 18
    
    mov [EBP+18], ax ;Se guarda en la pila el conector y su valor
    mov byte[prefija+edi], 20h ;Se pone un espacio en el string
    inc edi ;Se incrementa la direccion de destino
        
    jmp cicloGenPre_aux
    
mayorPrioridad: ;Se guardan los dos en la pila
    mov word [EBP + ebx], dx ;se guarda el valor anterior
    mov word [EBP + ebx+2], ax ;Se guarda el valor actual
        
    add word[EBP + 16], 2 ;Se aumenta en dos la direccion

    mov byte[prefija+edi], ' ' ;Se escribe un espacio
    inc edi
        
    jmp cicloGenPre_aux ;Se sigue el ciclo
    
menorPrioridad:
    mov word [EBP + ebx], ax 	;Se guarda el valor actual
    
    mov byte[prefija+edi], 20h 	;Se escribe un espacio
    inc edi
    
    mov byte[prefija+edi], dh 	;Se escribe el conector que se saco de pila
    inc edi
        
    mov byte[prefija+edi], 20h 	;Se escribe un espacio
    inc edi
        
    jmp cicloGenPre_aux
    
finalizarGenPre: ;Se saca todo lo que hay en la pila antes de terminar
    cmp word [EBP + 16], 16 ; Si no se han ingresado conectores se salta al final
    je fin_Aux
    
    xor ebx, ebx
    mov bx, [EBP + 16] 			;Se obtiene el desplazamiento para llegar al valor anterior
    mov byte[prefija+edi], ' ' 	;Se escribe un espacio
    inc edi
        
    ciclo_prueba:
        mov dx, [EBP + ebx] ;se pasa a dx el conector y su valor
            
        mov byte[prefija+edi], dh 	;Se escribe un conector
        inc edi
            
        mov byte[prefija+edi], ' ' 	;Se escribe un espacio
        inc edi
        
        sub bx, 2
        cmp bx, 16
        jne ciclo_prueba
            
fin_Aux:
    mov byte[prefija+edi], 0
    ret

;***------------------------------------------------------------------------------------------------------------***
;Proc: Ajustar espacios prefija
; Lee la varibale prefija para ir ajustando los espacios para que no se generen secciones con más de un espacio
ajustarPrefija:
xor esi, esi
xor edi, edi

cicloBusq:
	mov cl, [prefija+esi] 	;Se mueve el contenido de la casilla
	cmp cl, 20h 
	jne cicloTranscripcion 	;Si no es un espacio se pega
	
	cmp cl, 0				;Si de casualidad se llega a 0 aqui se termina el proc
	je final_ajustar		
	
	inc esi					;Se incrementa el esi para llegar a la siguiente casilla
	jmp cicloBusq			;Y se continua el ciclo

cicloTranscripcion: mov [prefija+edi], cl	;Se hace apste
	inc edi	;Se incrementan el destiny y source
	inc esi
	
	cmp cl, 20h	;Si se llega a un espacio se salta al ciclo de busqueda para no copiar más de un espacio
	je cicloBusq
	
	cmp cl, 0
	je final_ajustar
	mov cl, [prefija+esi]
	jmp cicloTranscripcion
	
final_ajustar:
	ret

;***------------------------------------------------------------------------------------------------------------***
;Proc: Resolver prefija
; Lee la varibale prefija para 
resolverPrefija: mov byte[resultado],0

iniciarCicloResolver: xor esi, esi ;Se limpia el esi
	mov dword[EBP+12], 16 ;Se coloca en 12 al valor de referencia
	xor ecx, ecx
	
	mov cl, byte[mostrarProced+0] ;Si esta apagado
	cmp cl, 0
	je ciclo_resolver ;se salta sin mostrar los pasos

	PutCh '='
	PutCh ' '
	PutStr prefija ;Imprime paso a paso l
	nwln
	
	jmp ciclo_resolver

espacio: inc esi

ciclo_resolver:
	mov cl, [prefija+esi]	;Se guarda en cl el caracter
	cmp cl, 0
	je printSolucion
	
	cmp cl, 20h
	je espacio
	
	xor edx, edx
	obtenerBase ;Se obtiene el valor de la base en el dl
	cmp dl, 0 ;Si se devuelve un 0
	je buscarOperando ;Es porque se leyo un operando
	
	mov [EBP+8], edx ;De ser número se gurda el valor de la base en el EBP+8 a EBP+11
	mov ebx, prefija
	call convertirADecimal ;Se convierte a decimal y se guarda en la pila
	
	mov dl, [EBP+8] 	;Se obtiene la base
	xor ebx, ebx 		;Se limpia el puntero de base
	
	mov bx,[EBP+12] 		;La direccion de un puntero a base vacio
	mov [EBP+ebx], dl 		;Se guarda la basse
	mov [EBP+ebx+1], eax 	;Y en la siguiente casilla se guarda el número
	add word[EBP+12], 5 	;Se aumenta en 5 para apuntar a una casilla de base vacia
	
	inc esi
	jmp ciclo_resolver
	
	buscarOperando: 
		cmp cl, '+'
		je sumar

		cmp cl, '-'
		je restar

		cmp cl, '*'
		je multiplicar

		cmp cl, '/'
		je dividir
		
		cmp cl, '%'
		je divModulo

	jmp printSolucion

sumar: mov bx, [EBP+12] 	;Mueve el puntero a casilla de base vacia
	sub bx, 4 			;Se mueve para apuntar a un número
	mov eax, [EBP+ebx] 	;Se mueve el ultimo numero a ecx
	
	cmp word [EBP+12], 21 ;Compara para saber si solo hay un elemento en la pila como +4
	je guardarResultado
	;Se consigue un segundo número en otro caso
	
	sub bx, 5			;Se apunta al numero anterior
	mov ecx, [EBP+ebx] 	;Se guarda el numero en ecx
	
	test ecx, ecx	;Comprueba si el segundo operando negativo o positivo
	js suma_negativo
	
	
	realizarSuma:
		add eax, ecx 		;Se realiza la operacion
		jmp guardarResultado
	
	suma_negativo:
		neg dword[EBP+ebx]
		jmp restar

restar: mov bx, [EBP+12] 	;Mueve el puntero a casilla de base vacia
	sub bx, 4 				;Se mueve para apuntar a un número
	mov eax, [EBP+ebx] 		;Se mueve el ultimo numero a ecx
	
	cmp word [EBP+12], 21 ;Compara para saber si solo hay un elemento en la pila que se busca negar
	je negarNumero 
	
	;Se consigue un segundo número en otro caso
	sub bx, 5			;Se apunta al numero anterior
	mov ecx, [EBP+ebx] 	;Se guarda el numero en ecx
	cmp ecx, eax ;Se busca saber si se puede generar un negativo
	jb restNegativo
	
	sub ecx, eax 		;Se realiza la operacion
	mov eax, ecx		;Listo!
	jmp guardarResultado

	negarNumero: neg eax
		mov dword[EBP+ebx], eax ;Se niega el numero
		inc esi
		mov [resultado], eax
		
		cmp byte[prefija+esi], 0 ;Si el siguiente es un 0
		je printSolucion ;Se devuelve el numero
		
		jmp ciclo_resolver
	
	restNegativo: sub ecx, eax 		;Se realiza la operacion
		mov eax, ecx		;Listo!
		jmp guardarResultado

multiplicar: mov bx, [EBP+12] 	;Mueve el puntero a casilla de base vacia
	sub bx, 4 				;Se mueve para apuntar a un número
	mov ecx, [EBP+ebx] 		;Se mueve el ultimo numero a ecx
	
	cmp word [EBP+12], 21 ;Compara para saber si solo hay un elemento en la pila que se busca negar
	je error_cantConectores
	
	;Se consigue un segundo número en otro caso
	sub bx, 5			;Se apunta al numero anterior
	mov eax, [EBP+ebx] 	;Se guarda el numero en ecx
	mul ecx				;Se realiza la operacion
	jmp guardarResultado

dividir: mov bx, [EBP+12] 	;Mueve el puntero a casilla de base vacia
	sub bx, 4 				;Se mueve para apuntar a un número
	mov ecx, [EBP+ebx] 		;Se mueve el ultimo numero a ecx
	
	cmp word [EBP+12], 21 ;Compara para saber si solo hay un elemento en la pila que se busca negar
	je error_cantConectores
	
	;Se consigue un segundo número en otro caso
	sub bx, 5			;Se apunta al numero anterior
	mov eax, [EBP+ebx] 	;Se guarda el numero en ecx
	cmp ecx, 0
	je error_divisionCero
	
	div ecx				;Se realiza la operacion
	
	cmp eax, 0
	jbe error_divisionCero
	
	jmp guardarResultado

divModulo:mov bx, [EBP+12] 	;Mueve el puntero a casilla de base vacia
	sub bx, 4 				;Se mueve para apuntar a un número
	mov ecx, [EBP+ebx] 		;Se mueve el ultimo numero a ecx
	
	cmp word [EBP+12], 21 ;Compara para saber si solo hay un elemento en la pila que se busca negar
	je error_cantConectores
	
	;Se consigue un segundo número en otro caso
	sub bx, 5			;Se apunta al numero anterior
	mov eax, [EBP+ebx] 	;Se guarda el numero en ecx
	cmp ecx, 0
	je error_divisionCero
	
	div ecx				;Se realiza la operacion
	
	cmp eax, 0
	jbe error_divisionCero
	
	mov edx, eax ;Se pasa el modulo
	jmp guardarResultado
	
error_cantConectores:
	ret

error_divisionCero:		;Aqui seria colocar un print y luego un ret
	ret

guardarResultado:
	mov [resultado], eax	;Se guarda en resultado en la variable por si se termina en esta operación
	mov [EBP+ebx],eax 		;Se guarda el resultado en la pila
	mov cl, [baseRespuesta]
	mov byte[EBP+ebx-1], cl	;Se guarda la base que el user quiere
	
	dec ebx
	mov [EBP+12], bx 	;Se guarda el puntero a la base del ultimo numero
reiniciarCiclo:
	call restausarPrefija
	mov ebx, prefija
	call ajustarPrefija
	jmp iniciarCicloResolver

printSolucion: cmp byte[prefijaAux],0
	je sumar
	nwln
	PutCh '/'
	PutCh '='
	PutCh ' '
	PutStr prefija ;Imprime la solucion de la opracion
	PutCh ' '
	PutCh '/'
	mov eax, [resultado]
	PutCh ' '
	PutCh 'b'
	call mostrarBits
	nwln
	ret

;***------------------------------------------------------------------------------------------------------------***
;Proc: RestaurarPrefija
; Se encarga de leer todos los datos de la pila para luego ir copiandolos todos en la variable prefija, para luego
; devolver el esi a 0 e iniciar todo el ciclo_resolver de nuevo
restausarPrefija: xor edi, edi
	inc esi				;Se ignora el espacio usual
	mov word[EBP+14], 16 ;Se mueve al EBP+14 el valor de la primer casilla de base
	add word[EBP+12], 5 ;Se mueve el puntero una casilla arriba de las 4 casillas del numero
	
ciclo_restaurar:
	mov bx, [EBP+14] 	;Se pone en el bx un puntero a una casilla de base
	
	cmp bx, [EBP+12] 	;Comprueba si ya apunta más allá del ultimo numero
	je final_resturar 	;Si es así se salta al ultimo numero
	
	
	cmp byte[EBP+ebx], 2
	je print_bin
	
	cmp byte[EBP+ebx], 8
	je print_oct
	
	cmp byte[EBP+ebx], 10
	je print_dec
	
	print_hex:
		mov byte[prefijaAux+edi], 'h'
		jmp iniciarCiclo
	
	print_dec:
		mov byte[prefijaAux+edi], 'd'
		jmp iniciarCiclo
	
	print_oct:
		mov byte[prefijaAux+edi], 'o'
		jmp iniciarCiclo
	
	print_bin:
		mov byte[prefijaAux+edi], 'b'
	
	iniciarCiclo:
		inc edi
		mov eax, [EBP+ebx+1] ;Mueve al eax el numero al que esta apuntando
		
		xor cx, cx
		mov byte[flag_negativo], 0
		
		test eax, eax ;Se comprueba si trata de un negativo
		jns ciclo1PAX ;Si no es negativo siga
		
		mov byte[flag_negativo], 1 ;Se indica que s un negativo
		mov ecx, -1
		imul ecx
		xor ecx, ecx
	
	ciclo1PAX: mov bx, [EBP + 14] ;Se apunta a la casilla en turno
		mov dl, [EBP+ebx] 	;Mueve al edx la base del numero al que esta apuntando
		xor ebx, ebx
		mov bl, dl			;Se mueve al bl el contenido del dl para dividir
		xor edx, edx 		;Se limpia el edx

		div ebx				;Y se hace la division
		
		mov bx, [EBP + 12] 	;Se obtiene el valor de una casilla sobre los numeros
		add bx, cx 			;Se desplza por el valor de cx
		mov [EBP+ebx], dl 	;Y guarda el dl (el residuo de la division)
		
		inc cx ;Se incrementa el cx para aumentar el desplazamiento
		
		cmp eax, 0 ;Se comprueba si ya se termina la conversion
		jbe ciclo2PAX
		
		cmp eax, 0 ;Se comprueba si ya se termina la conversion
		jne ciclo1PAX

	ciclo2PAX: mov dl, [EBP+ebx] ;Se imprime el residuo del ultimo al primer
		cmp dl, 9 
		ja letra   ;Si es mayor a 9 se aumenta 37 para llegar al caracter de letra que le coresponde
		add dl, 30h ;Si no se aumenta solo en 30h
		jmp printelo
		
	letra: add dl, 37h
	printelo: mov byte[prefijaAux+edi], dl
		dec ebx
		inc edi
		loop ciclo2PAX
	
	mov byte[prefijaAux+edi], 20h
	
	inc edi
	add word[EBP+14], 5 ;Se aumenta para llegar al siguiente puntero de base
	
	cmp byte[flag_negativo], 0
	je ciclo_restaurar
	
	mov byte[prefijaAux+edi], '-'
	inc edi
	mov byte[prefijaAux+edi], 20h
	inc edi
	jmp ciclo_restaurar
	
final_resturar: 
	mov dl, byte[prefija+esi]
	mov byte[prefijaAux+edi], dl
	
	inc esi
	inc edi
	
	cmp dl, 0
	je ultimoPaso
	
	jmp final_resturar
	
ultimoPaso:
	xor esi, esi
	xor edi, edi
	
	cilo_ultPas:
	mov dl, byte[prefijaAux+esi]
	mov byte[prefija+edi], dl
	
	
	inc esi
	inc edi
	
	cmp dl, 0
	jne cilo_ultPas
		
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
