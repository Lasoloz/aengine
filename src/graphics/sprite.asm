;
; Copyright (c) 2016 László Heim
;
; Source file for image loading functions
;

%include 'third-party/util.inc'    ; Memory allocation and file heandling

global spr_create
global spr_load_gimp_ppm
global spr_delete

section .text
; Local functions:
fio_read_char:
    ; Read one character from the file handle specified in eax to edx register
    ; In case of error, carry flag is set
        push    ebx
        push    ecx

        mov     ecx, 1
        mov     ebx, read_buffer

        call    fio_read
        cmp     edx, ecx

        ; No more bytes to read
        jne     .noread

        ; Save character in edx
        xor     edx, edx
        mov     dl, [ebx]
        
        clc
        jmp     .exit

    .noread:
        stc

    .exit:
        pop     ecx
        pop     ebx
        
        ret


read_until_eol:
    ; Read characters (and discard them) until end-of-file is found
    ; eax - file handle
    ; ebx - buffer
    ; ecx=1 must be 1!
    ; edx - must not be used!
    .read_loop:
        call    fio_read
        test    edx, edx
        jz      .nomore

        cmp     byte [ebx], 10
        je      .eol

        jmp     .read_loop

    .eol:
        ; End-of-line found
        clc
        ret

    .nomore:
        ; No more bytes in file
        stc
        ret


mul_ebx_10:
    ; Multiply ebx by 10
        push    eax
        push    edx

        mov     eax, ebx
        mov     ebx, 10

        mul     ebx

        mov     ebx, eax

        pop     edx
        pop     eax

        ret


read_num:
    ; Read the width or height of the image from eax file handle and return
    ; it in edx
        push    ebx
        xor     ebx, ebx

    .read_loop:
        call    fio_read_char
        jc      .format_error

        cmp     edx, ' '
        clc
        je      .read_end

        cmp     edx, 10
        clc
        je      .read_end

        cmp     edx, '0'
        jb      .format_error

        cmp     edx, '9'
        ja      .format_error

        ; Valid character
        call    mul_ebx_10
        sub     edx, '0'
        add     ebx, edx

        jmp     .read_loop

    .format_error:
        stc

    .read_end:
        mov     edx, ebx
        pop     ebx

        ret


; Global functions:
spr_create:
    ; Create a texture map with width (eax heigher part) and height (eax lower
    ; part)
        push    ebx
        ; Save width and height
        push    eax

        xor     ebx, ebx

        test    eax, 0x80008000
        ; The width or the height is too big
        ; (We can't multiply width with height and 3, because it becomes bigger
        ; than 2^32 - 1)
        ; (We checked the first bits of the two numbers)
        jnz     .toobig_error

        ; Get the width and the height
        mov     bx, ax
        shr     eax, 16

        ; Calculate width * height
        mul     ebx
        
        ; Calculate width * height * 3
        mov     ebx, 3
        mul     ebx

        ; Calculate width * height * 3 + 4
        add     eax, 4

        ; Do memory allocation
        call    mem_alloc

        ; Check for allocation error
        test    eax, eax
        jz      .alloc_error

        ; Everything went fine... let's save width and height
        pop     ebx
        mov     [eax], ebx


        ; Restore register
        pop     ebx

        ; Successful return
        ret

        ; Unsuccessful returns
    .toobig_error:
        ; TODO: Handle them differently!
    .alloc_error:
        xor     eax, eax
        ; Restore ebx
        pop     ebx
        
        ret


spr_delete:
    ; Delete a sprite
        test    eax, eax

        jnz     .delete
        ret

    .delete:
        call    mem_free
        xor     eax, eax

        ret


spr_load_gimp_ppm:
    ; Create a texture map and load pixelmap from ppm as content
        push    ebx
        push    edx
        push    edi
        push    ecx

        ; Open file for read
        xor     ebx, ebx

        call    fio_open

        test    eax, eax
        jz      .cantopen_error


        ; Start reading header information
        call    fio_read_char
        jc      .format_error
        ; First byte = 'P' = 80
        cmp     edx, 80
        jne     .format_error

        ; Second byte = '6' = 54
        call    fio_read_char
        jc      .format_error
        cmp     edx, 54
        jne     .format_error

        ; Read comment
        call    read_until_eol

        ; Read width
        call    read_num
        jc      .format_error
        test    edx, 0xffff8000
        jne     .format_error

        ; Save width in ebx
        or      ebx, edx

        ; Read height
        call    read_num
        jc      .format_error
        test    edx, 0xffff8000
        jne     .format_error

        
        ; Save height in ebx
        shl     ebx, 16
        or      ebx, edx
        
        ; Read color depth (not interesting, gimp filters to 255 max value)
        call    read_num
        jc      .format_error

        
        ; Create sprite, before starting to save it
        mov     edi, eax

        mov     eax, ebx
        call    spr_create

        test    eax, eax
        je      .alloc_error

        ; Start saving pixel data
        xchg    eax, edi
        push    edi
        
        ; Write start position
        add     edi, 4


        ; Start writing data to sprite
        xor     ecx, ecx
        mov     cx, bx ; Move height in ecx

        shr     ebx, 16 ; Will contain width loop count

    .column_loop:
        ; Read columns - works on height

        push    ecx

        mov     ecx,  ebx
        ; Move inner loop
        .row_loop:
            ; Read rows

            push    ecx
            mov     ecx, 3
            .pixel_loop:
                ; Read pixel components
                call    fio_read_char
                jc      .format_error_inner
                mov     [edi], dl
                inc     edi

                loop    .pixel_loop

            pop     ecx
            loop    .row_loop
        
        pop     ecx
        loop    .column_loop

        ; Pixels saved in sprite memory
        pop     eax ; pop sprite address to eax (pushed with edx)


        ; Restore registers
        pop     ecx
        pop     edi
        pop     edx
        pop     ebx

        ret

    .format_error_inner:
        pop     eax
        call    spr_delete ; Delete sprite
    .cantopen_error:
        ; TODO: handle these differently...
    .format_error:
    .alloc_error:
        xor     eax, eax

        pop     ecx
        pop     edi
        pop     edx
        pop     ebx

        ret


section .bss:
    read_buffer resb 1
