;
; Copyright (c) 2016 Heim László
;
; test1 for aengine
; Testing sprites
;

%include 'third-party/io.inc'
%include 'third-party/mio.inc'
%include 'third-party/util.inc'
%include 'include/graphics/sprite.inc'

global main

section .text
main:
    ; Main function for testing
        mov     eax, 0x00100004

        call    spr_create
        
        test    eax, eax
        jz      .noalloc

        mov     ebx, eax
        xor     eax, eax

        mov     ax, [ebx]

        call    io_writeint

        mov     ax, [ebx + 2]
        call    io_writeln
        call    io_writeint
        call    io_writeln


        mov     eax, filename
        xor     ebx, ebx
        call    fio_open

        mov     ebx, mem
        mov     ecx, 500

        call    fio_read

        call    fio_close

        cmp     edx, ecx
        jne     .noalloc

        xor     eax, eax
    .write:
        mov     al, [ebx]
        call    io_writeint
        call    io_writeln
        inc     ebx
        loop    .write

    .noalloc:
        ret

section .bss
    mem resb 500

section .data
    filename db 'test.ppm', 0
