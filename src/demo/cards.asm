;
; Copyright (c) 2016-2017 László Heim
;
; Source file for card caching functions
;

%include 'include/graphics/render.inc' ; Rendering functions
%include 'include/graphics/sprite.inc' ; Sprite functions
%include 'include/userutil.inc'        ; String processing
%include 'third-party/util.inc'        ; Memory allocation


global card_loadCards
global card_renderCard
global card_renderCardBack
global card_free


section .text
card_loadCards:
    ; Load cards from a specified directory specified in eax
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
        mov     ecx, 57
        call    uu_copyStr

        ; Characters copied
        ; Save complete filename's address in edi
        mov     edi, eax

        ; Calculate offset
        add     eax, edx

        ; Load error sprite
        mov     byte [eax], 'c'
        mov     byte [eax+1], 'e'
        mov     byte [eax+2], 'r'
        mov     byte [eax+3], '.'
        mov     byte [eax+4], 'p'
        mov     byte [eax+5], 'p'
        mov     byte [eax+6], 'm'
        mov     byte [eax+7], 0


        mov     ebx, eax
        mov     eax, edi

        call    spr_load_gimp_ppm
        test    eax, eax
        stc
        jz      .no_error_sprite

        ; Save error sprite
        mov     [error], eax

        ; Load background
        mov     byte [ebx+1], 'b'
        mov     byte [ebx+2], 'k'


        mov     eax, edi

        call    spr_load_gimp_ppm
        mov     [backg], eax


        ; Load actual card faces (hearts, spades, clubs, diamonds)
        ; Start with hearts

        mov     byte [ebx+1], 'h'
        mov     byte [ebx+2], 'a'

        mov     edx, 0
        mov     ecx, 13

    .hearts_loop:
        mov     eax, edi
        call    spr_load_gimp_ppm

        mov     [cards+edx*4], eax
        mov     eax, edx
        add     eax, 98 ; 'a' + 1
        mov     [ebx+2], al
        inc     edx

        loop    .hearts_loop

        ; Save spades
        mov     byte [ebx+1], 's'
        mov     byte [ebx+2], 'a'

        mov     ecx, 13

    .spades_loop:
        mov     eax, edi
        call    spr_load_gimp_ppm

        mov     [cards+edx*4], eax
        mov     eax, edx
        add     eax, 85 ; 'a' + 1 - 13
        mov     [ebx+2], al
        inc     edx

        loop    .spades_loop

        ; Save clubs
        mov     byte [ebx+1], 'c'
        mov     byte [ebx+2], 'a'

        mov     ecx, 13

    .clubs_loop:
        mov     eax, edi
        call    spr_load_gimp_ppm

        mov     [cards+edx*4], eax
        mov     eax, edx
        add     eax, 72 ; 'a' + 1 - 13 - 13
        mov     [ebx+2], al
        inc     edx

        loop    .clubs_loop

        ; Save diamonds
        mov     byte [ebx+1], 'd'
        mov     byte [ebx+2], 'a'

        mov     ecx, 13

    .diamonds_loop:
        mov     eax, edi
        call    spr_load_gimp_ppm

        mov     [cards+edx*4], eax
        mov     eax, eax
        add     eax, 59 ; 'a' + 1 - 13 - 13 - 13
        mov     [ebx+2], al
        inc     edx

        loop    .diamonds_loop


        ; All cards cached...
        clc

    .no_error_sprite:
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


card_renderCard:
    ; Render a specified card to the specified position
        push    eax
        push    edx

        mov     edx, eax
        mov     eax, [cards+edx*4]

        test    eax, eax
        jnz     .card_exists

        mov     eax, [error]

    .card_exists:

        call    render_copyspr

        pop     edx
        pop     eax

        ret


card_renderCardBack:
    ; Render card back to a specified position
        push    eax
        
        mov     eax, [backg]

        test    eax, eax
        jnz     .no_back

        mov     eax, [error]

    .no_back:
        call    render_copyspr

        pop     eax

        ret


card_free:
    ; Free up allocated card cache
        push    eax
        push    ecx

        mov     eax, [error]
        test    eax, eax
        jz      .no_error_sprite

        call    spr_delete
        mov     dword [error], 0

    .no_error_sprite:

        mov     eax, [backg]
        test    eax, eax
        jz      .no_backg_sprite

        call    spr_delete
        mov     dword [backg], 0

    .no_backg_sprite:

        ; Free up card images
        mov     ecx, 52
    
    .free_loop:
        mov     eax, [cards+ecx*4-4]

        test    eax, eax
        jz      .no_card_img

        call    spr_delete
        mov     dword [cards+ecx*4-4], 0

    .no_card_img:
        loop    .free_loop

        ; Everything freed up
        pop     ecx
        pop     eax

        ret


section .bss
    cards resd 52 ; For every card
    error resd 1 ; for error card
    backg resd 1 ; For background
