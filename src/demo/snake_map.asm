;
; Copyright (c) 2016-2017 László Heim
;
; Source file for game functions (snake)
;

%include 'include/graphics/sprite.inc' ; Snake head, food
%include 'include/graphics/render.inc' ; Rendering functions
%include 'third-party/util.inc' ; Memory allocation and random

%define m_void   0
%define m_sleft  1
%define m_sright 2
%define m_sup    3
%define m_sdown  4
%define m_shead  5
%define m_food   6
%define m_wall   7
%define map_width  30
%define map_height 22
%define map_tilenum   660

global sm_initMap
global sm_moveSnake
global sm_renderMap
global sm_queryFoodNum


section .text
sm_initMap:
    ; Initializes game map
        push    eax
        push    ecx

        mov     eax, map
        mov     ecx, map_tilenum

    .initloop:
        mov     byte [eax], m_void
        inc     eax

        loop    .initloop

    ; After initialized to 0, put the snake and the first food and some walls
    ; to their starting positions
        mov     eax, map
        add     eax, map_width
        add     eax, map_width
        add     eax, 2
        
        mov     ecx, 4

    .wall_loop:
        mov     byte [eax], m_wall
        inc     eax
        loop    .wall_loop

        mov     ecx, 4
        add     eax, map_width
        add     eax, map_width
        sub     eax, 4

    .snake_loop:
        mov     byte [eax], m_sright
        inc     eax
        loop    .snake_loop

        mov     byte [eax], m_shead

        mov     dword [shead_x], 6
        mov     dword [shead_y], 4
        mov     dword [stail_x], 2
        mov     dword [stail_y], 4


        call    create_food

        mov     dword [points], 0


        pop     ecx
        pop     eax


        ret


;;; LOCAL FUNCTION
make_effective_address:
    ; Make effective address from map, ecx - x, and edx - y values in edi
        mov     edi, edx
        imul    edi, map_width
        add     edi, map
        add     edi, ecx

        ret


;;; LOCAL FUNCTION
create_food:
    ; Create food
        push    eax
        push    ecx
        push    edx
        push    edi

        call    rand
        mov     edi, map_width
        xor     edx, edx
        div     edi

        mov     ecx, edx ; Modulo


        call    rand
        mov     edi, map_height
        xor     edx, edx
        div     edi

        ; It's in edx


        call    make_effective_address
        cmp     byte [edi], m_void
        jz      .okay
        
        ; Position is used up, so we choose the first available position for our
        ; food

        mov     ecx, map_tilenum
        mov     edi, map

    .searchloop:
        cmp     byte [edi], m_void
        jz      .okay

        inc     edi

        loop    .searchloop
        
        ; If couldn't find free position, then we must end game (end of level)
        stc
        jmp     .exit

    .okay:
        mov     byte [edi], m_food
        
        clc

    .exit:
        pop     edi
        pop     edx
        pop     ecx
        pop     eax

        ret


sm_moveSnake:
    ; Update game state
        push    eax
        push    ebx
        push    ecx
        push    edx
        push    edi

        mov     ecx, [shead_x]
        mov     edx, [shead_y]

        ; Calculate the address for the current position of head in matrix
        call    make_effective_address

        cmp     eax, 0
        je      .left

        cmp     eax, 1
        je      .right

        cmp     eax, 2
        je      .up

        ; Else must be down
        mov     byte [edi], m_sdown
        inc     edx
        cmp     edx, map_height
        jge     .collision
        mov     [shead_y], edx
        jmp     .postest

    .left:
        mov     byte [edi], m_sleft
        dec     ecx
        cmp     ecx, 0
        jl      .collision
        mov     [shead_x], ecx
        jmp     .postest

    .right:
        mov     byte [edi], m_sright
        inc     ecx
        cmp     ecx, map_width
        jge     .collision
        mov     [shead_x], ecx
        jmp     .postest

    .up:
        mov     byte [edi], m_sup
        dec     edx
        cmp     edx, 0
        jl      .collision
        mov     [shead_y], edx

    .postest:
        ; Test value under position
        call    make_effective_address
        xor     ebx, ebx
        mov     bl, [edi]
        test    ebx, ebx
        jnz     .foodtest

        mov     byte [edi], m_shead
        jmp     .test_tail


    .foodtest:
        cmp     ebx, m_food
        jne     .collision

        mov     byte [edi], m_shead
        call    create_food
        jc      .collision
        ; Not really collision, but end of game, 'cause we can't create food

        mov     ebx, [points]
        inc     ebx
        mov     [points], ebx
        
        ; We took  a food, so we can't move the tail...
        jmp     .endfunc

    .test_tail:
        ; Move tail
        mov     ecx, [stail_x]
        mov     edx, [stail_y]

        ; Calculate the address of current tail position
        call    make_effective_address

        ; Get value in ebx
        xor     ebx, ebx
        mov     bl, [edi]

        mov     byte [edi], m_void

        cmp     ebx, m_sleft
        je      .tleft

        cmp     ebx, m_sright
        je      .tright

        cmp     ebx, m_sup
        je      .tup

        ; Else it's down
        inc     edx
        mov     [stail_y], edx
        clc
        jmp     .endfunc

    .tleft:
        dec     ecx
        mov     [stail_x], ecx
        clc
        jmp     .endfunc

    .tright:
        inc     ecx
        mov     [stail_x], ecx
        clc
        jmp     .endfunc

    .tup:
        dec     edx
        mov     [stail_y], edx
        clc
        jmp     .endfunc

    .collision:
        ; collision is detected
        stc

    .endfunc:

        ; Restore registers
        pop     edi
        pop     edx
        pop     ecx
        pop     ebx
        pop     eax

        ret


sm_renderMap:
    ; Render current state of the map
        push    eax
        push    ebx
        push    ecx
        push    edx
        push    esi

        mov     esi, map
        mov     ebx, 0x00200020
        mov     ecx, 0x00200020

        
        xor     edx, edx
    .yloop:
        and     ebx, 0x0000ffff
        add     ebx, 0x00200000
        cmp     edx, map_height
        jae     .yend

        push    edx
        xor     edx, edx

        .xloop:
            cmp     edx, map_width
            jae     .endx

            mov     al, [esi]
            cmp     al, m_food
            je      .draw_food

            cmp     al, m_shead
            je      .draw_head

            cmp     al, m_void
            je      .draw_void

            cmp     al, m_wall
            je      .draw_wall

            ; Else it's a snake element
            mov     eax, 0x1005ff
            call    render_renderRect
            jmp     .end_draw

        .draw_food:
            mov     eax, 0x00ffff00
            call    render_renderRect
            jmp     .end_draw

        .draw_head:
            mov     eax, 0x004020ff
            call    render_renderRect
            jmp     .end_draw

        .draw_void:
            mov     eax, 0x00000000
            call    render_renderRect
            jmp     .end_draw

        .draw_wall:
            mov     eax, 0x00ff2020
            call    render_renderRect

        .end_draw:
            ; End of draw choosing
            ; Advance..

            inc     esi
            inc     edx
            add     ebx, 0x00200000

            jmp     .xloop

        .endx:
        
        pop     edx

        inc     edx
        add     ebx, 0x00000020

        jmp     .yloop

    .yend:

        ; End of draw
        pop     esi
        pop     edx
        pop     ecx
        pop     ebx
        pop     eax

        ret


sm_queryFoodNum:
    ; Query the number of foods eaten
        ret


section .bss
    map resb map_tilenum ; map_width * map_height
    shead_x resd 1
    shead_y resd 1
    stail_x resd 1
    stail_y resd 1
    points  resd 1
