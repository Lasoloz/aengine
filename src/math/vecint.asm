;
; Copyright (c) 2016 László Heim
;
; Source file for integer based vector functions
;

%include 'third-party/util.inc' ; Memory allocation
%include 'third-party/io.inc'   ; Printing to console
%include 'third-party/mio.inc'  ; Printing to console

global create_vec2int32
global delete_vec2int32
global print_vec2int32
global add_vec2int32
global add_x_vec2int32
global add_y_vec2int32
global neg_vec2int32
global sub_vec2int32
global mul_s_vec2int32
global div_s_vec2int32
global cpy_vec2int32
global c_v2int32_to_ps
global c_ps_to_v2int32


section .text
create_vec2int32:
    ; Allocate some memory for a 2D vector
        mov     eax, 8 ; Allocate an array of 2 double words = 64 bits = 8 bytes

        call    mem_alloc
        cmp     eax, 0
        je      .error

        ; If could allocate, then initialize to 0
        mov     dword [eax], 0
        mov     dword [eax+4], 0

    .error:
        ; Return the pointer
        ret


delete_vec2int32:
    ; Deallocate memory, if it was allocated in heap
        call    mem_free
        
        ; eax = NULL pointer
        xor     eax, eax

        ret


print_vec2int32:
    ; Print the value of a vector
    ; Format "(x, y)"
        push    eax
        push    ebx

        ; Save the pointer in ebx
        mov     ebx, eax

        ;;
        mov     al, '('
        call    mio_writechar

        ; Print out first value
        mov     eax, [ebx]
        call    io_writeint

        ;;
        mov     al, ','
        call    mio_writechar
        mov     al, ' '
        call    mio_writechar

        ; Print out the second value
        mov     eax, [ebx+4]
        call    io_writeint

        ;;
        mov     al, ')'
        call    mio_writechar

        ; Restore registers
        pop     ebx
        pop     eax

        ret


add_vec2int32:
    ; Add a vector to the another
        push    ebx

        ; Add first value of the vector
        mov     ebx, [eax]
        add     ebx, [edx]
        mov     [eax], ebx

        ; Add second value of the vector
        mov     ebx, [eax+4]
        add     ebx, [edx+4]
        mov     [eax+4], ebx

        ; Restore register
        pop     ebx

        ret


add_x_vec2int32:
    ; Add a value to the x component of a vector
        push    ebx

        ; Add value to the x component
        mov     ebx, [eax]
        add     ebx, edx
        mov     [eax], ebx

        ; Restore register
        pop     ebx

        ret


add_y_vec2int32:
    ; Add a value to the y component of a vector
        push    ebx

        ; Add value to y component
        mov     ebx, [eax+4]
        add     ebx, edx
        mov     [eax+4], ebx
        
        ; Restore register
        pop     ebx

        ret


neg_vec2int32:
    ; Negate the vector components
        push    ebx

        ; Negate x component
        mov     ebx, [eax]
        neg     ebx
        mov     [eax], ebx

        ; Negate y component
        mov     ebx, [eax+4]
        neg     ebx
        mov     [eax+4], ebx

        ; Restore register
        pop     ebx

        ret


sub_vec2int32:
    ; Subtract a vector from another
        push    ebx

        ; Subtract x component
        mov     ebx, [eax]
        sub     ebx, [edx]
        mov     [eax], ebx

        ; Subtract y component
        mov     ebx, [eax+4]
        sub     ebx, [edx+4]
        mov     [eax+4], ebx

        ; Restore ebx
        pop     ebx

        ret


mul_s_vec2int32:
    ; Multiply a vector with a scalar
        push    ebx

        ; Multiply x component
        mov     ebx, [eax]
        imul    ebx, edx
        mov     [eax], ebx

        ; Multiply y component
        mov     ebx, [eax+4]
        imul    ebx, edx
        mov     [eax+4], ebx

        ; Restore ebx
        pop     ebx
        
        ret


div_s_vec2int32:
    ; Divide a vector with scalar
        push    ebx
        push    ecx
        mov     ecx, edx
        mov     ebx, eax

        ; Divide x component
        mov     eax, [ebx]
        cdq
        idiv    ecx
        mov     [ebx], eax

        ; Divide y component
        mov     eax, [ebx+4]
        cdq
        idiv    ecx
        mov     [ebx+4], eax

        ; Restore everything
        mov     eax, ebx
        mov     edx, ecx
        pop     ecx
        pop     ebx

        ret


cpy_vec2int32:
    ; Copy vector
        push    ebx
        mov     ebx, [edx]
        mov     [eax], ebx

        mov     ebx, [edx+4]
        mov     [eax+4], ebx

        ; Restore register
        pop     ebx

        ret


c_v2int32_to_ps:
    ; Convert integer type vector to floating point (SSE type) vector
        push    ebx
        mov     ebx, [eax]
        pop     ebx
        ret


c_ps_to_v2int32:
        ret
