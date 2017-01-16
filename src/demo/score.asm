;
; Copyright (c) 2016-2017 László Heim
;
; Source file for highscore handling
;

%include 'third-party/util.inc' ; File handling
%include 'include/userutil.inc' ; String copying
%include 'include/graphics/render.inc' ; Rendering utilities
%include 'include/graphics/fonts.inc' ; Text and number rendering

global sr_loadFromFile
global sr_testScore
global sr_pushScore
global sr_renderTable
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

        ; Save defaults to scorelist:
        xor     ecx, ecx

    .nameloop:
        xor     edx, edx
        .strcopy:
            mov     bl, [str_default+edx]
            mov     [namelist+ecx], bl

            inc     edx
            inc     ecx
            cmp     edx, 10
            jb      .strcopy

        cmp     ecx, 100
        jb      .nameloop


        ; Save default score values
        mov     edx, scorelist
        mov     ebx, 2
        mov     ecx, 10

    .scoreloop:
        mov     [edx], ebx

        add     ebx, 2
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
        ja      .save

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
        cmp     [esi+4], eax
        jae     .posfound

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


sr_renderTable:
    ; Render scores in the format of a table to a specified position
        push    eax
        push    ebx
        push    ecx
        push    edx
        push    edi
        push    esi

        ; Render base rectangle
        mov     eax, 0x00000a62
        mov     ecx, 0x00d90137
        call    render_renderRect

        ; Render header
        ; Align position to highscores string
        add     ebx, 0x00040004
        ; Render white rectangle under highscores string
        mov     eax, 0x00ffffff
        mov     ecx, 0x00d10018
        call    render_renderRect

        mov     eax, str_hs
        call    font_renderText

        ; Align position to name string
        add     ebx, 0x0000001a
        mov     eax, str_name
        call    font_renderText

        ; Save position
        mov     edi, ebx

        ; Align position to points string
        add     ebx, 0x00a10000
        mov     eax, str_points
        call    font_renderText

        ; Align position to first list item's place
        add     edi, 0x0000001c

        ; Start from 10th element of save arrays (with the best scores)
        mov     esi, 10

    .listloop:
        ; Iterate trough list elements
        dec     esi
        ; Copy name to buffer
        mov     eax, str_buffer

        mov     ebx, esi
        imul    ebx, 10 ; Will never be negative
        add     ebx, namelist

        mov     ecx, 11

        call    uu_copyStr


        ; Render text to position
        mov     ebx, edi
        call    font_renderText


        ; Render points to position
        mov     eax, [scorelist+esi*4]
        add     ebx, 0x00a10000
        mov     ecx, 3
        call    font_renderNumber

        ; Next line
        add     edi, 0x00000019

        ; Test if there is something to show from the table
        test    esi, esi
        jnz     .listloop


        ; End of rendering, restore registers
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
    scorelist resd 10
    file_name resb 64
    namelist resb 100
    modified resb 1
    str_buffer resb 11


section .data
    str_name db 'Name      ', 0
    str_points db 'Pts', 0
    str_default db 'default   ', 0
    str_hs db 'Highscores', 0
