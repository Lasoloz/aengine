;
; Copyright (c) 2016-2017 Heim László
;
; test3 for aengine
; Testing font system
;

%include 'third-party/io.inc'
%include 'third-party/mio.inc'
%include 'third-party/gfx.inc'
%include 'third-party/util.inc'
%include 'include/graphics/fonts.inc'
%include 'include/graphics/render.inc'

global main

section .text
main:
    ; Main function for testing
        mov     eax, msg_font
        call    io_writestr
        call    io_writeln

        mov     eax, font_dir

        call    font_loadFonts
        jc      .fontloaderror

        mov     eax, msg_font_loaded
        call    io_writestr
        call    io_writeln

        
        ; Init window
        mov     eax, msg_init
        call    io_writestr
        call    io_writeln

        mov     eax, 800
        mov     ebx, 600
        xor     ecx, ecx
        mov     edx, win_title

        call    render_createWindow
        jc      .winloaderror

        mov     eax, msg_start
        call    io_writestr
        call    io_writeln

        mov     ebx, 0x00000000

        mov     eax, 48
        call    font_setLineHeight

        ; Start main loop
    .mainloop:
        ; Event loop:
        .eventloop:
            ; Get events from event queue
            call    gfx_getevent
            ; Handle exit:
            cmp     eax, 23
            je      .exitapp

            cmp     eax, 27
            je      .exitapp

            test    eax, eax
            jnz     .eventloop
        
        ; mov     eax, 0x00ff2020
        mov     eax, 0x00ffffff
        call    render_clear

        mov     eax, msg_fontrender
        xor     ebx, ebx
        call    font_renderText

        ; Render a rectangle too
        mov     eax, 0x00ff0000
        mov     ebx, 0x00100190
        mov     ecx, 0x00810023
        call    render_renderRect


        ; Also: test number rendering
        mov     eax, 4291730865
        mov     ebx, 0x00a00190
        ; xor     ecx, ecx ; Zero prefill
        mov     ecx, 20 ; Test prefill
        call    font_renderNumber

        call    render_show

        jmp     .mainloop

    .exitapp:
        ; Close what we opened
        call    render_destroyWindow
        call    font_free

        ret

    .winloaderror:
        mov     eax, msg_init_unsuccessf
        call    io_writestr
        call    io_writeln
        call    font_free

        ret

    .fontloaderror:
        mov     eax, msg_font_notl
        call    io_writestr
        call    io_writeln

        ret


section .data
    font_dir db '..\resources\fonts\', 0
    win_title db 'test3', 0
    msg_init db 'Initializing window...', 0
    msg_init_successful db 'Window created successfully!', 0
    msg_init_unsuccessf db 'Could not create window!', 0
    msg_font db 'Loading fonts...', 0
    msg_font_loaded db 'Minimum font number loaded successfully!', 0
    msg_font_notl   db 'Could not load at least one character from fontset!', 0
    msg_start db 'Starting main loop of application...', 0
    msg_fontrender db 'Testing font rendering', 13, 10, 'abcdefghijklmnopqrstuvwxy', 13, 10, '0123456789', 13, 10, 'Last line and z character',0
