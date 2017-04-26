%include  "io.mac"

;Proyecto programado 1: Calculadora multi base bien tuanis que vamos a terminar en solo 3 dias
;by: Óscar Cortés && Randall Delgado

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

     
.DATA
    mensaje db "Hola mundo", 0
    precedencia db '*', 10,  '/',10,  '+',5,  '-',5,    '$',0
    mensajeError db "Se ingreso un caracter incorecto", 0
    

.UDATA
operacion resb 256
prefija resb 256

.CODE
     .STARTUP    
;------------------Codigo segment------------------
     lectura:
        GetStr operacion, 256 ;Se guarda en operacion el string de la linea de comandos
        mov ebx, operacion ;Se mueve a operacion al ebx
        call eliminaEspacios ;y se llama a eliminaEspacios para borrar todos los espacios del contenido del ebx
     
     ;Aqui se llama el proc que lee la base en que se devuelve el resultado
     ;Y se deja a operacion solo con numeros y conectores aritmeticos, ok?
       
        nwln    ;ahora llamo al que hace la conversion y imprimo el resultado
        PutStr mensaje  ;resultado de elimina espacios
     conversion:
        enter 0,0 ;Se guardar el EBP
        call generaPrefija
        nwln
        cmp byte [prefija], '~'
        jne solucion
        
        PutStr mensajeError
        jmp final
    solucion:
        nwln
        PutStr prefija ;resultado
       
    
    final:
    nwln
.EXIT
;------------------Codigo ends------------------

;#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Procs #-#-#-#-#-#-#-#-#-#-#-#-#-#-#
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

;Proc: Genera prefija
; Usa las varibales operacion y prefija y el macro valor Precedencia
; Lee el string operacion y va escribiendo en prefija la operacion infija en
; prefija.
; Details: Al leer caracteres si lee un numero o un indicador de base lo escribe sin más.
;    En caso de encontrar un conector aritmetico, salta a comparacion. En comparacion pasan tres cosas:
;    - Si la pila esta vacia se gurda el conector
;    - Si el conector que esta tiene mayor precedencia se guardan los dos
;    - Si tiene menor precedencia se escribe el que se saca y el actual se guarda en la pila
;Faltan: Parentesis

generaPrefija:
xor esi, esi ;
xor edi, edi ;
mov word [EBP + 12], 12 ; Eso
    
cicloGenPre:
    mov dl, byte[operacion+esi];Se mueve al dl el contenido de operacion actual
        
    cmp dl, 0
    je finalizarGenPre  ;Si es 0 se finaliza el ciclo
        
    cmp dl, '+'
    je comparacion
        
    cmp dl, '*'
    je comparacion
        
    cmp dl, '/'
    je comparacion
        
    cmp dl, '-'
    je comparacion
        
    cmp dl, '0'         ;Si es menor a '0'
    jb error_gen
        
    cmp dl, '9'         ;Si es menor o igual a '9'
    jbe esNumeroOBase
    
    cmp dl, 'b'
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
        
esNumeroOBase:
    mov byte[prefija+edi], dl   ;Se escribe el digito
    inc edi                     ;Y se incrementa el edi
    jmp cicloGenPre_aux         ;Luego se salta al aux
        
error_gen:
    mov byte[prefija], '~'  ;Se escribe el digito
    jmp fin_Aux

comparacion:
    mov [EBP + 8], esi         ;Y el valor del esi
    valorPrecedencia dl         ;Se obtiene el valor de precedencia
    ;En este punto el ax tiene el conector en el ah y el valor en el al
    
    cmp word [EBP + 12], 12          ;si no se ha ingresado nadie, agreguelo a la pila
    je guardarEnPila
    ;0-7 = EBP, 8-11 = esi, 12-14 = a contador
    ;Si se ha ingresado a alguien se saca el conector y su valor de la pila
    
    xor ebx, ebx
    mov bx, [EBP + 12]          ;Se obtiene el desplazamiento para llegar al valor anterior
    mov dx, [EBP + ebx]         ;se pasa a dx el conector y su valor
        
    cmp al, dl                  ;Si el conector actual tiene mayor prioridad
    jae mayorPrioridad          ;se salta a mayorPrioridad
        
    jmp menorPrioridad ;Si no se salta a menor prioridad
        
    
guardarEnPila:;Si la pila esta vacia
    mov word [EBP + 12], 14 ; Eso
        
    mov [EBP+14], ax ;Se guarda en la pila el conector y su valor
       
    mov esi, [EBP + 8] ;También
        
    mov byte[prefija+edi], 20h ;Se pone un espacio en el string
    inc edi ;Se incrementa la direccion de destino
        
    jmp cicloGenPre_aux
    
mayorPrioridad: ;Se guardan los dos en la pila
    mov word [EBP + ebx], dx ;se guarda el valor anterior
    add bx, 2
    mov word [EBP + ebx], ax ;Se guarda el valor actual
        
    mov [EBP + 12], bx ;Se aumenta en dos la direccion
   
    mov esi, [EBP + 8] ;También
        
    mov byte[prefija+edi], ' ' ;Se escribe un espacio
    inc edi
        
    jmp cicloGenPre_aux ;Se sigue el ciclo
    
menorPrioridad:
    mov word [EBP + ebx], ax ;Se guarda el valor actual
    
    mov esi, [EBP + 8] ;También
    
    mov byte[prefija+edi], 20h ;Se escribe un espacio
    inc edi
    
    mov byte[prefija+edi], dh ;Se escribe el conector que se saco de pila
    inc edi
        
    mov byte[prefija+edi], 20h ;Se escribe un espacio
    inc edi
        
    jmp cicloGenPre_aux
    
finalizarGenPre:
    cmp word [EBP + 12], 12 ; Si no se han ingresado conectores se salta al final
    je fin_Aux
    
    xor eax, eax
    xor ebx, ebx
    mov bx, [EBP + 12] ;Se obtiene el desplazamiento para llegar al valor anterior
    mov byte[prefija+edi], ' ' ;Se escribe un espacio
    inc edi
        
    ciclo_prueba:
        mov dx, [EBP + ebx] ;se pasa a dx el conector y su valor
            
        mov byte[prefija+edi], dh ;Se escribe un conector
        inc edi
            
        mov byte[prefija+edi], ' ' ;Se escribe un espacio
        inc edi
        
        sub bx, 2
        cmp bx, 12
        jne ciclo_prueba
            
fin_Aux:
    mov byte[prefija+edi], 0
    ret
