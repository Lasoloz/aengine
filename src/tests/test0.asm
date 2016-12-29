;
; Copyright (c) 2016 Heim László
;
; test0 for aengine
; Testing vectors
;

%include 'third-party/mio.inc'
%include 'third-party/io.inc'
%include 'include/math/vecint.inc'

global main

section .text:
test_alloc:
    ; Test vector allocation
        xor     eax, eax
        call    create_vec2int32
        
        cmp     eax, 0
        je      .alloc_err1

        ; Save the allocated vector's address to ebx
        mov     ebx, eax

        
        ; Second vector
        call    create_vec2int32

        cmp     eax, 0
        je      .alloc_err2

        ; Print out vectors
        ; Print second vector
        call    print_vec2int32

        mov     al, ';'
        call    mio_writechar
        mov     al, ' '
        call    mio_writechar

        ; Delete second vector
        call    delete_vec2int32

        ; Print first vector
        mov     eax, ebx

        call    print_vec2int32
        call    io_writeln
        ret

    .alloc_err2:
        mov     eax, msg_allocerror2
        call    io_writestr

        mov     eax, ebx
        call    delete_vec2int32

        ret

    .alloc_err1:
        mov     eax, msg_allocerror1
        call    io_writestr

        ret

print_value_ln:
    ; Print out vector value and new line
    ; eax - vec pointer
    ; edx - str pointer
        push    eax
        mov     eax, edx
        call    io_writestr
        pop     eax
        call    print_vec2int32
        call    io_writeln

        ret

test_arithmetics:
    ; Test arithmetics
        mov     eax, msg_default
        call    io_writestr
        call    io_writeln

        mov     eax, vec1
        mov     edx, msg_vec1
        call    print_value_ln

        mov     eax, vec2
        mov     edx, msg_vec2
        call    print_value_ln

        mov     eax, vec3
        mov     edx, msg_vec3
        call    print_value_ln

        mov     eax, vec4
        mov     edx, msg_vec4
        call    print_value_ln

        ; Add 4 to vec4's x component
        mov     edx, 4
        call    add_x_vec2int32

        ; Add -3 to vec4's y component
        mov     edx, -3
        call    add_y_vec2int32

        ; Print out value
        mov     edx, msg_vec4
        call    print_value_ln
        
        ret


main:
    ; Main function
        call    test_alloc
        call    io_writeln

        call    test_arithmetics
        call    io_writeln

        ret

section .bss
    vec1 resd 2
    vec2 resd 2
    vec3 resd 2
    vec4 resd 2

section .data:
    msg_allocerror1 db 'Could not allocate memory for first vector!', 0
    msg_allocerror2 db 'Could not allocate memory for second vector!', 0

    msg_default db 'Default value of vectors allocated in bss:',0
    msg_vec1 db 'vec1=', 0
    msg_vec2 db 'vec2=', 0
    msg_vec3 db 'vec3=', 0
    msg_vec4 db 'vec4=', 0
