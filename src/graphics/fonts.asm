;
; Copyright (c) 2016-2017 László Heim
;
; Source file for font caching and text rendering functions
;

%include 'include/graphics/render.inc' ; Rendering functions
%include 'include/graphics/sprite.inc' ; Sprites
%include 'include/userutil.inc'        ; readChar and string processing
%include 'third-party/util.inc'        ; Memory allocation
; %include 'third-party/io.inc' ; Debugging ; remove IT!


global font_loadFonts
global font_setSpacing
global font_setLineHeight
global font_renderText
global font_free


section .text
font_loadFonts:
    ; Loads fonts from a specified directory and saves them in font system cache
        push    eax
        push    ebx
        push    ecx
        push    edx
        push    edi

        mov     ebx, eax
        mov     eax, 64
        call    mem_alloc

        test    eax, eax
        stc
        jz      .alloc_error

        ; Could allocate memory
        ; Copy directory name to string cache
        mov     ecx, 59
        call    uu_copyStr

        ; Characters copied
        ; Save complete filename's address in edi
        mov     edi, eax

        ; Calculate offset
        add     eax, edx

        ; Load general character
        mov     byte [eax], '_'
        mov     byte [eax+1], '.'
        mov     byte [eax+2], 'p'
        mov     byte [eax+3], 'p'
        mov     byte [eax+4], 'm'
        mov     byte [eax+5], 0
        
        ; push    eax
        ; mov     eax, edi
        ; call    io_writestr
        ; call    io_writeln
        ; pop     eax

        ; Save filename string pointer
        mov     ebx, eax

        mov     eax, edi
        call    spr_load_gimp_ppm
        test    eax, eax
        stc
        jz      .no_general_char

        ; Save general character
        mov     [glyphs], eax


        ; Try to allocate numerals
        mov     byte [ebx], '0'
        mov     edx, 1
        mov     ecx, 10

    .numeral_loop:
        mov     eax, edi
        ; call    io_writestr
        ; call    io_writeln
        call    spr_load_gimp_ppm

        mov     [glyphs+edx*4], eax
        mov     eax, edx
        add     eax, '0'
        mov     [ebx], al
        inc     edx

        loop    .numeral_loop

        ; Add a-z glyphs
        mov     byte [ebx], 'a'
        mov     ecx, 26

    .character_loop:
        mov     eax, edi
        ; call    io_writestr
        ; call    io_writeln
        call    spr_load_gimp_ppm

        mov     [glyphs+edx*4], eax
        inc     edx
        mov     eax, edx
        add     eax, 86 ; WOW! A magic constant :p
        mov     [ebx], al

        loop    .character_loop

    ; So... I think characters are loaded at this point..
    ; Anyway! test3 will tell us!
        clc

    .no_general_char:

        pushf
        ; Deallocate filename buffer
        mov     eax, edi
        call    mem_free

        popf

    .alloc_error:
        pop     edi
        pop     edx
        pop     ecx
        pop     ebx
        pop     eax

        ret


font_setSpacing:
    ; Sets spacing between characters
        mov     [spacing], ax
        ret


font_setLineHeight:
    ; Sets line height for text
        mov     [lineheight], ax
        ret


font_renderText:
    ; Render text to a specified position
        push    eax
        push    ebx
        push    ecx
        push    edx
        push    edi
        push    esi
        
        ; Extract positions from ebx to ecx, edx
        mov     dx, bx
        sar     ebx, 16
        test    dx, 0x8000
        jz      .no_extension

        or      edx, 0xFFFF0000
    .no_extension:
        mov     ecx, ebx
        mov     esi, eax

        mov     edi, ebx ; x advance (ecx is x starting position)

        ; Start printing out text
    .printloop:
        xor     ebx, ebx
        mov     bl, [esi]

        ; Check cases for rendering
        test    bl, bl
        jz      .endtext

        cmp     bl, 13
        je      .carriageret

        cmp     bl, 10
        je      .linefeed

        cmp     bl, '0'
        jb      .general

        cmp     bl, '9'
        jbe     .numeric

        cmp     bl, 'A'
        jb      .general

        cmp     bl, 'Z'
        jbe     .uppercase

        cmp     bl, 'a'
        jb      .general

        cmp     bl, 'z'
        jbe     .lowercase
    
    .general:
        mov     eax, [glyphs]
        jmp     .render

    .numeric:
        sub     bl, 47 ; (al - '0' + 1)

        mov     eax, [glyphs+ebx*4]
        ; Test if nullptr
        test    eax, eax
        jnz     .render
        mov     eax, [glyphs] ; Move general character to eax

        jmp     .render
    
    .lowercase:
        sub     bl, 32 ; It's the difference between 'a' and 'A'
    
    .uppercase:
        sub     bl, 54 ; Magic values, HEY! (Okay, it's al - 'A' + 11)

        mov     eax, [glyphs+ebx*4]
        ; Test if nullptr
        test    eax, eax
        jnz     .render
        mov     eax, [glyphs] ; Move general character to eax


    .render:
        ; Render the selected character
        ; TODO
        xor     ebx, ebx
        mov     ebx, edi
        shl     ebx, 16
        mov     bx, dx

        call    render_copyspr


        ; Advance on line
        add     di, [eax] ; Sprite width
        add     di, [spacing] ; Spacing between characters

        inc     esi

        jmp     .printloop

    .carriageret:
        ; Carriage return
        mov     edi, ecx ; Set original x position
        inc     esi
        jmp     .printloop

    .linefeed:
        ; Line feed (new line)
        add     dx, [lineheight]
        inc     esi
        jmp     .printloop

    .endtext:

        pop     esi
        pop     edi
        pop     edx
        pop     ecx
        pop     ebx
        pop     eax
        ret


font_free:
    ; Free up font memory
        push    eax
        push    ecx

        mov     ecx, 37

    .free_loop:
        mov     eax, [glyphs+ecx*4-4]
        test    eax, eax
        jz      .no_dealloc

        call    spr_delete
        mov     dword [glyphs+ecx*4], 0

    .no_dealloc:
        loop    .free_loop

        pop     ecx
        pop     eax

        ret


section .bss
    glyphs resd 37 ; A memory address for all sprites
    spacing    resw 1
    lineheight resw 1
