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

    mov     eax, 0x00ffffff
    call    render_clear

    mov     eax, edx
    ; mov     ebx, 0x0010fff6 ; x=10h=16, y=fff6h=-10
    ; call    render_copyspr

    mov     ebx, 0x00100020
    call    render_copyspr
    mov     ebx, 0x00160030
    call    render_copyspr
    
    ; call    gfx_map
    call    render_show

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
    ppm_fname db 'test.ppm', 0
    msg_start db 'Testing sprites...',0
    msg_initwin db 'Initializing window...',0
    msg_success db 'Window initialized successfully!',0
    msg_imgsuccess db 'Image loaded successfully!', 0
