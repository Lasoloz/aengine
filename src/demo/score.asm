;
; Copyright (c) 2016-2017 László Heim
;
; Source file for highscore handling
;

%include 'third-party/util.inc' ; File handling
%include 'include/userutil.inc' ; String copying

global sr_loadFromFile
global sr_testScore
global sr_pushScore
global sr_saveToFile

section .text

sr_loadFromFile:
    ; Loads highscore from file
        push    eax
        push    ebx
        push    ecx
        push    edx

        ; Copy filename string to local buffer
        mov     ebx, eax
        mov     eax, file_name
        mov     ecx, 64
        call    uu_copyStr

        ; Try to open file for read
        xor     ebx, ebx
        call    fio_open

        test    eax, eax
        jz      .open_fail


        ; Start reading names and scores
        ; Read name block from file
        mov     ebx, namelist
        mov     ecx, 100

        call    fio_read

        cmp     ecx, edx
        jne     .read_fail


        ; Read score block from file
        mov     ebx, scorelist
        mov     ecx, 40

        call    fio_read

        cmp     ecx, edx
        jne     .read_fail

        mov     byte [modified], 0
        call    fio_close
        jmp     .exit

    .read_fail:
        call    fio_close
        
    .open_fail:
        ; When fails to open file or read data from file...
        mov     byte [modified], 1 ; we have to save something
        mov     edx, namelist
        mov     ecx, 100

    .spaceloop:
        mov     byte [edx], ' '

        inc     edx
        loop    .spaceloop


        mov     edx, scorelist
        mov     ebx, 10
        mov     ecx, 10

    .scoreloop:
        mov     [edx], ebx

        add     ebx, 10
        add     edx, 4
        loop    .scoreloop

    .exit:

        ; Restore registers
        pop     edx
        pop     ecx
        pop     ebx
        pop     eax

        ret



sr_testScore:
    ; Test a score
        cmp     eax, [scorelist]
        jae     .save

        clc

        ret

    .save:
        stc

        ret



sr_pushScore:
    ; Push a score to the scoretable
        push    eax
        push    ebx
        push    ecx
        push    edx
        push    edi
        push    esi

    ; Start comparing scores
        mov     ecx, 9
        mov     esi, scorelist
        mov     edi, namelist

    .searchpos:
        cmp     [esi], eax
        jbe     .posfound

        mov     edx, [esi + 4]
        mov     [esi], edx


        push    ecx
        mov     ecx, 10
        .copyname:
            ; Move name in list
            mov     dl, [edi+10]
            mov     [edi], dl
            inc     edi

            loop    .copyname
        pop     ecx

        add     esi, 4

        loop    .searchpos

    .posfound:
        ; Position found
        mov     [esi], eax
        mov     ecx, 10

        .savename:
            ; Save name to the "top"
            mov     dl, [ebx]
            mov     [edi], dl

            inc     edi
            inc     ebx

            loop    .savename

        
        mov     byte [modified], 1

        pop     esi
        pop     edi
        pop     edx
        pop     ecx
        pop     ebx
        pop     eax

        ret


sr_saveToFile:
    ; Save scorelist to file
        push    eax
        push    ebx
        push    ecx
        push    edx

        cmp     byte [modified], 0
        je      .no_save

        mov     eax, file_name
        mov     ebx, 1

        call    fio_open

        test    eax, eax
        jz      .no_file

        ; File opened, start writing scores
        mov     ebx, namelist
        mov     ecx, 100
        call    fio_write

        ; Don't care about data writing, if it fails, then it fails...

        mov     ebx, scorelist
        mov     ecx, 40
        call    fio_write

        ; Finsihed writing, close file
        call    fio_close

    .no_file:
    .no_save:
        pop     edx
        pop     ecx
        pop     ebx
        pop     eax

        ret


section .bss
    file_name resb 64
    scorelist resd 10
    namelist resb 100
    modified resb 1
