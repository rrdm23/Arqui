%include  "io.mac"

;Proyecto programado 1: Calculadora multi base bien tuanis que vamos a terminar en solo 3 dias
;by: Óscar Cortés && Randall Delgado

.DATA
    mensaje db "Hola mundo", 0
    precedencia db '*', 10,  '/',10,  '+',5,  '-',5,    '$',0
    
    
.UDATA
operacion resb 256
    

.CODE
     .STARTUP
     
     %macro valorPrecedencia 1
        push ebx
        push esi
        
        xor ebx, ebx
        xor esi, esi
        mov ebx, precedencia
        cicloPrece:
            cmp byte[ebx+esi], %1
            je finalizarPrece
            
            cmp byte[ebx+esi], '$'
            je finalizarPrece
            
            inc esi
            jmp cicloPrece
        
        finalizarPrece:
            inc esi
            push %1 ;Se guarda el conector en la pila
            mov al, byte[ebx+esi] ;Y luego se guarda el valor del conector en al
            
        pop esi ;Se restablece el esi
        pop ebx ;Y el ebx
        push al ;;Y luego se guarda el valor del conector en la pila
     %endmacro
     
     
     GetStr operacion, 256 ;Se guarda en operacion el string de la linea de comandos
     mov ebx, operacion ;Se mueve a operacion al ebx
     call eliminaEspacios ;y se llama a eliminaEspacios para borrar todos los espacios del contenido del ebx
     
     ;Aqui se llama el proc que lee la base en que se devuelve el resultado
     ;Y se deja a operacion solo con numeros y conectores aritmeticos, ok?
     nwln
     ;ahora llamo al qeu hace la conversion y imprimo el resultado
     call generaInfija
     
.EXIT

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

generaInfija:
    xor esi, esi ;
    xor edi, edi ;
    xor ax, ax ;Se usa ax para contener el valor de cada conector
    xor dx, dx ;Se usa el dl para guardar el caracrter actual
    xor cx, cx;Se limpia el cx para usarse como contador de cuantos conectores estan en la pila
    
    cicloGenInf:
        mov dl, byte[ebx+esi];Se mueveal dl el contenido de operacion actual
        
        cmp dl, 0
        je finalizarGenInf ;Si es 0 se finaliza el ciclo
        
        cmp dl, '0' ;Si es menor a '0'
        jb error_gen
        
        cmp dl, '9' ;Si es menor o igual a '9'
        jbe esNumero
        
        cmp dl, '+'
        je comparacion
        
        cmp dl, '*'
        je comparacion
    
    cicloGenInf_aux:
        inc esi
        jmp cicloGenInf
        
    esNumero:
        mov byte[ebx+edi], dl
        inc edi
        jmp cicloGenInf_aux
        
    finalizarGenInf:
        ret
        
    error_gen:
        mov eax, 0
        ret
    
    comparacion:
        valorPrecedencia dl ;Se obtiene el valor de precedencia
        pop al ;Se saca dicho valor y se guarda en al
        
        cmp cx, 0 ; si no se ha ingresado nadie, agreguelo a la pila
        je guardarEnPila
        
        ;Si se ha ingresado a alguien se saca el conector y su valor de la pila
        pop dh ;Se obtiene al ultimo conector que se ingreso
        pop ah ;Y su valor de precedencia
        
        cmp al, ax ;Si el conector actual tiene mayorPrioridad se salta a mayorPrioridad
        jae mayorPrioridad
        
        jmp menorPrioridad
        
    
    guardarEnPila:;Si la pila esta vacia
        inc cx
        push al ;se guarda el valor primero
        push dl ;luego el conector
        jmp cicloGenInf_aux
        
    mayorPrioridad:
        inc cx
        push ah     ;Se guarda el valor del conector
        push dh     ;Y luego el conector
        
        push al     ;Se guarda el valor del conector
        push dl     ;Y luego el conector
        jmp cicloGenInf_aux
        
    menorPrioridad:       
        push al
        push dl
        mov byte[ebx+edi], 20h
        inc edi
        
        mov byte[ebx+edi], dh
        inc edi
        
        mov byte[ebx+edi], 2h
        inc edi
        jmp cicloGenInf_aux
