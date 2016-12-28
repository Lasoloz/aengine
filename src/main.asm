;
; Copyright (c) 2016 László Heim
;
; Main file of the source code
; Testing stuff
;

%include 'third-party/io.inc'
%include 'third-party/gfx.inc'

global main

section .text

main:
    ; Main function of the file
        mov     eax, 1000
        mov     ebx, 1000
        mov     ecx, 0
        mov     edx, caption

        call    gfx_init

        test    eax, eax
        jnz     .init

        mov     eax, msg_initerror
        call    io_writestr
        call    io_writeln
        ret

    .init:
        mov     eax, msg_initsuccess
        call    io_writestr
        call    io_writeln

        call    gfx_destroy

        ret

section .data
    caption          db 'Testing gfx...', 0

    msg_initsuccess  db 'gfx successfully initialized!', 0
    msg_initerror    db 'Couldn', 39, 't initialize gfx!', 0
    msg_initexplain1 db 'Error occoured possibly because fullscreen width or height was to big!', 0
