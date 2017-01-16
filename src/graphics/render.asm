;
; Copyright (c) 2016-2017 László Heim
;
; Source file for rendering functions
;

%include 'include/graphics/sprite.inc' ; For sprites
%include 'third-party/gfx.inc'         ; For rendering
%include 'third-party/util.inc'        ; Sync framerate to 60 Hz

global render_createWindow
global render_destroyWindow
global render_clear
global render_copyspr
global render_renderRect
global render_show

section .text
render_createWindow:
    ; Create a window, and save data in renderer buffers
        push    eax

        mov     [width], eax
        mov     [height], ebx

        call    gfx_init
        test    eax, eax
        jz      .create_error

        ; Could create window:
        clc
        jmp     .exit

    .create_error:
        stc

    .exit:
        pop     eax

        ret


render_destroyWindow:
    ; Destroy the window
        call    gfx_destroy
        ret


; LOCAL!
clear_row:
    ; Clear a row of framebuffer
        push    ecx
        mov     ecx, [width]
        
    .row_loop:
        mov     [eax], ebx
        add     eax, 4
        loop    .row_loop

        pop     ecx

        ret

; GLOBAL!
render_clear:
    ; Clear current framebuffer with a specified color (00rrggbb)
        push    ebx
        push    ecx
        mov     ebx, eax

        call    gfx_map
        mov     [frameptr], eax
        
        mov     ecx, [height]

    .col_loop:
        call    clear_row
        loop    .col_loop

        mov     eax, ebx
        pop     ecx
        pop     ebx
        
        ret


render_copyspr:
    ; Copy sprite to framebuffer
        ; Save the x, y containers, before using them
        push    ebx
        push    ecx
        ; Extract values from ebx
        xor     ecx, ecx
        mov     cx, bx
        test    cx, 0x8000
        jz      .no_extension
        or      ecx, 0xffff0000
    .no_extension:
        sar     ebx, 16

        ; Check right and down boundaries
        cmp     ebx, [width]
        jge     .no_draw1
        cmp     ecx, [height]
        jge     .no_draw1

        ; Save the registers
        push    eax
        push    edx
        push    edi
        push    esi
        
        ; ebx - framebuffer.xpos
        ; ecx - framebuffer.ypos
        ; edx - img.xpos
        xor     edx, edx
        ; edi - img.ypos
        xor     edi, edi

        ; Check, where x coord is located on framebuffer
        cmp     ebx, 0
        jge     .is_goodx

        ; Advance on both positions with delta
        sub     edx, ebx ; Advance on image
        xor     ebx, ebx ; Advance on framebuffer

        ; Check, if there is something to draw
        cmp     dx, [eax]
        jge     .no_draw2

    .is_goodx:
        ; Check where y coord is located on framebuffer
        cmp     ecx, 0
        jge     .is_goody

        ; Advance on both positions with delta
        sub     edi, ecx ; Advance on image
        xor     ecx, ecx ; Advance on framebuffer

        ; Check, if there is something to draw
        cmp     dx, [eax+2]
        jge     .no_draw2

    .is_goody:
        ; Now, we have to calculate the starting positions of
        ; source and destination
        ; Save eax in esi
        mov     esi, eax

        ; First, we save x and y on framebuffer
        mov     [buf_x], ebx
        mov     [buf_y], ecx

        ; Calulate absolute position for framebuffer:
        ; (frm.width * frm.y) + frm.x + &framebuffer
        mov     eax, [width]
        imul    ecx, eax
        imul    ecx, 4
        add     ecx, ebx
        add     ecx, ebx
        add     ecx, ebx
        add     ecx, ebx
        add     ecx, [frameptr] ; ecx - absolute position on framebuffer
        
        ; Calculate absolute position for image buffer
        ; (img.width * img.y) + img.x + &img
        xor     eax, eax
        mov     ax, [esi]
        imul    eax, edi
        imul    eax, 3
        add     eax, edx
        add     eax, edx
        add     eax, edx
        add     eax, 4
        add     eax, esi

        mov     ebx, eax ; ebx - absolute position on image buffer

        mov     eax, [buf_y]

        mov     [buf_imx], dx

    .yloop:
        ; Check if y is out of bounds (frame)
        cmp     eax, [height]
        jae     .endy

        ; Check if y is out of bounds (image)
        cmp     di, [esi+2]
        jae     .endy

        ; Push ebx and ecx (absolute values on memory array)
        push    ecx ; absolute img array pointer
        push    ebx ; absolute framebuffer array pointer

        mov     eax, [buf_x]
        mov     [buf_x_s], eax
        mov     dx, [buf_imx]
        .xloop:
            ; Check if x is out of bounds (frame)
            cmp     eax, [width]
            jae     .endx

            ; Check if x is out of bounds (image) 
            cmp     dx, [esi]
            jae     .endx

            ; If not, then we still want to copy
            mov     al, [ebx + 2]
            mov     [ecx], al     ; BLUE
            inc     ecx
            
            mov     al, [ebx + 1]
            mov     [ecx], al     ; GREEN
            inc     ecx
            
            mov     al, [ebx]
            mov     [ecx], al     ; RED
            add     ecx, 2
            add     ebx, 3

            ; Pixel finished, let's check next Pixel
            mov     eax, [buf_x_s]
            inc     eax
            mov     [buf_x_s], eax
            inc     dx

            jmp     .xloop

        .endx:
        ; x loop finshed, get ready to update y loop
        mov     eax, [buf_y]
        inc     eax
        mov     [buf_y], eax
        inc     di

        ; Advance to next line
        pop     ebx
        xor     ecx, ecx
        mov     cx, [esi]
        add     ebx, ecx     ; Next line = advance in array with width
        add     ebx, ecx
        add     ebx, ecx ; THIS TOO (See below... :p)
        
        pop     ecx
        add     ecx, [width] ; Next line = advance in array with width
        add     ecx, [width]
        add     ecx, [width] ; AM I REALLY DOING THIS?? I have to find
        add     ecx, [width] ; something better...
        
        jmp     .yloop
    .endy:
        ; Drawing finsihed (Bless God!)
        ; YAY!
    
    .no_draw2:
        ; Restore second pack of registers
        pop     esi
        pop     edi
        pop     edx
        pop     eax

    .no_draw1:
        ; Restore first pack of registers
        pop     ecx
        pop     ebx

        ret


render_renderRect:
    ; Render a filled rectangle
        ; Extract width and height from ecx to edx - esi
        push    ebx
        push    ecx
        push    edx
        push    esi

        ; height position
        xor     esi, esi
        mov     si, cx

        ; width position
        shr     ecx, 16
        mov     edx, ecx


        ; Extract x and y from ebx to ebx - ecx
        xor     ecx, ecx
        mov     cx, bx

        test    cx, 0x8000
        jz      .no_extension

        ; "cwd of ecx" - I should be a poet
        or      ecx, 0xffff0000

    .no_extension:
        ; x position
        sar     ebx, 16

        ; Check right and down boundaries
        cmp     ebx, [width]
        jge     .no_draw1
        cmp     ecx, [height]
        jge     .no_draw1

        ; Save the remaining registers
        push    edi

        ; ebx - ecx : x - y ; edx - esi : w - h
        ; Check left and right positions

        cmp     ebx, 0
        jge     .okayx

        add     edx, ebx ; (edx minus part not drawn)
        xor     ebx, ebx
        cmp     edx, 0
        jl      .no_draw2

    .okayx:

        cmp     ecx, 0
        jge     .okayy

        add     esi, ecx ; (esi minus part not drawn)
        xor     ecx, ecx
        cmp     esi, 0
        jl      .no_draw2

    .okayy:

        ; Calculate the right and down boundaries of the rectangle
        add     edx, ebx ; right bound
        cmp     edx, [width]

        jle     .no_wchange
        mov     edx, [width]

    .no_wchange:
        add     esi, ecx ; down part
        cmp     esi, [height]
        jle     .no_hchange
        mov     esi, [height]

    .no_hchange:
        
        ; Start drawing to the screen
        ; Calculate absolute position
        mov     edi, [width]
        imul    edi, ecx
        imul    edi, 4
        add     edi, ebx
        add     edi, ebx
        add     edi, ebx
        add     edi, ebx
        add     edi, [frameptr] ; edi now holds the absolute position on frameb.

        ; Save positions
        mov     [buf_x], ebx

    .yloop:
        ; Check if y is out of bounds
        cmp     ecx, esi
        jae     .endy

        mov     ebx, [buf_x]
        push    edi
        
        .xloop:
            ; Check if x is out of bounds
            cmp     ebx, edx
            jae     .endx

            ; Copy color to memory
            mov     [edi], eax
            add     edi, 4

            ; Pixel finished, let's check next Pixel
            inc     ebx

            jmp     .xloop

        .endx:
        ; x loop finished, update y loop
        inc     ecx

        ; Advance to the next line
        pop     edi
        add     edi, [width]
        add     edi, [width]
        add     edi, [width]
        add     edi, [width]

        jmp     .yloop
    .endy:
        ; Drawing rectangle finished

    .no_draw2:
        pop     edi

    .no_draw1:
        pop     esi
        pop     edx
        pop     ecx
        pop     ebx


        ret


render_show:
    ; Show result on the window
    ; Calculate sleep to achieve ~60 Hz
        push    eax
        push    ebx
        ; "Push" xmm0
        sub     esp, 16
        movdqu  [esp], xmm0

        call    gfx_unmap
        call    gfx_draw

        call    timer_query
        mulsd   xmm0, [cst_1000]
        cvttsd2si eax, xmm0

        mov     ebx, eax
        sub     eax, [last_time]

        sub     eax, 33
        neg     eax

        ; Do we have to sleep?
        cmp     eax, 33
        jg      .no_sync

        cmp     eax, 0
        jl      .no_sync

        call    sleep

    .no_sync:
        mov     [last_time], ebx

        ; "Pop" xmm0
        movdqu  xmm0, [esp]
        add     esp, 16

        pop     ebx
        pop     eax

        ret


section .bss
    last_time resd 1

    frameptr resd 1
    width    resd 1
    height   resd 1
    buf_x    resd 1
    buf_x_s  resd 1
    buf_y    resd 1
    buf_imx  resw 1


section .data
    cst_1000 dd 1000.0
