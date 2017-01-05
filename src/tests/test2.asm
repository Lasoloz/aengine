;
; Copyright (c) 2016-2017 Heim László
;
; test2 for aengine
; Testing sprites
;

%include 'third-party/io.inc'
%include 'third-party/mio.inc'
%include 'third-party/util.inc'
%include 'third-party/gfx.inc'
%include 'include/graphics/sprite.inc'
%include 'include/graphics/render.inc'

global main

section .text
main:
    ; Main file for test2
    mov     eax, msg_start
    call    io_writestr
    call    io_writeln

    mov     eax, msg_initwin
    call    io_writestr
    call    io_writeln

    mov     eax, 800
    mov     ebx, 600
    mov     ecx, 0
    mov     edx, win_title

    call    render_createWindow
    jc      .error

    mov     eax, msg_success
    call    io_writestr
    call    io_writeln

    ;mov     ecx, 1000 ; show 60 frames

    mov     eax, ppm_fname
    call    spr_load_gimp_ppm
    test    eax, eax
    jz      .error_img

    mov     edx, eax

    mov     eax, msg_imgsuccess
    call    io_writestr
    call    io_writeln


    ; x position
    mov     bx, -32

    ; y position
    mov     bx, -32

    ; x move offset
    mov     di, 5

    ; y move offset
    mov     si, 5

.runloop:
    .eventloop:
        call    gfx_getevent
        ; Handle exit:
        cmp     eax, 23
        je      .exit ; Quit on 'x' button

        cmp     eax, 27
        je      .exit ; Quit on escape

        test    eax, eax
        jnz     .eventloop ; No more events in event queue

    ; Clear background with random grayscale color:
    ; call    rand
    ; push    bx
    ; mov     bl, al
    ; xor     eax, eax
    ; or      al, bl
    ; shl     eax, 8
    ; or      al, bl
    ; shl     eax, 8
    ; or      al, bl
    ; call    render_clear
    ; pop     bx

    ; Clear background with growing brightness on black color
    xor     eax, eax
    mov     al, [grayscale_level]
    inc     al
    mov     [grayscale_level], al
    shl     eax, 8
    mov     al, [grayscale_level]
    shl     eax, 8
    mov     al, [grayscale_level]
    call    render_clear


    ; Calculate new positions
    add     bx, di
    add     cx, si

    ; Check right boundary
    cmp     bx, 800
    jl      .good_right
    neg     di

.good_right:
    ; Check left boundary
    cmp     bx, -32
    jge     .good_left
    neg     di

.good_left:
    ; Check down boundary
    cmp     cx, 600
    jl      .good_down
    neg     si

.good_down:
    ; Check up boundary
    cmp     cx, -32
    jge     .good_up
    neg     si

.good_up:
    ; Make position representation in ebx
    push    bx
    shl     ebx, 16
    or      bx, cx

    mov     eax, edx
    call    render_copyspr

    pop     bx

    call    render_show

    mov     eax, 33
    call    sleep

    jmp     .runloop ; iterate

.exit:

    mov     eax, edx
    call    spr_delete
.error_img:

    call    render_destroyWindow

.error:
    ret


section .data
    win_title db 'test2', 0
    ppm_fname db 'test3.ppm', 0
    msg_start db 'Testing sprites...',0
    msg_initwin db 'Initializing window...',0
    msg_success db 'Window initialized successfully!',0
    msg_imgsuccess db 'Image loaded successfully!', 0
    
    grayscale_level db 0
