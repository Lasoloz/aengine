;
; Copyright (c) 2016-2017 László Heim
;
; Source file containing utilities defined by me ("user" prefix added to
; distinguish from util library)
;

%include 'third-party/util.inc' ; Reading from file

global uu_readChar
global uu_copyStr

section .text

uu_readChar:
    ; Read one character from file:
        push    ebx
        push    ecx

        xor     edx, edx

        ; Set ebx and ecx for Read
        mov     ebx, charbuffer
        mov     ecx, 1

        ; Read atttempt
        call    fio_read

        ; Test read status
        test    edx, edx
        jz      .nomore

        mov     dl, [charbuffer]
        clc
        
        ; Restore registers
        pop     ecx
        pop     ebx

        ret

    .nomore:
        stc

        ; Restore registers
        pop     ecx
        pop     ebx

        ret


uu_copyStr:
    ; Copies one string to the other:
        push    esi
        push    edi
        push    eax
        push    ecx

        mov     edi, eax
        mov     esi, ebx

        dec     ecx ; Make space for 0 at the end
        xor     edx, edx

    .copyloop:
        lodsb

        ; End of source string
        test    al, al
        jz      .end_source

        ; Copy content to destination
        stosb

        ; Count copied characters (excluding 0 at the end)
        inc     edx

        loop    .copyloop
    
    .end_source:
        ; Put zero to destination string's end
        xor     al, al
        stosb

        pop     ecx
        pop     eax
        pop     edi
        pop     esi

        ret


section .bss
    charbuffer resb 1
