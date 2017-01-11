;
; Copyright (c) 2016-2017 Heim László
;
; Snake written in assembly
; This application is also part of aengine library, being a demo application
;
; Main file of source code
;

%include 'third-party/io.inc'  ; Message output
%include 'third-party/gfx.inc' ; Event handling
%include 'third-party/util.inc' ; Sleep

%include 'include/graphics/render.inc' ; For rendering functions
%include 'include/graphics/fonts.inc'  ; For text rendering
%include 'include/graphics/sprite.inc' ; For image handling
%include 'include/demo/snake_map.inc' ; Game utilities

global main

section .text
menuproc:
    ; Menu state process
        push    eax
        push    ebx
        push    ecx

        mov     eax, msg_enterMenuState
        call    io_writestr
        call    io_writeln

        xor     ecx, ecx
        ; Load up menu images
        ; Background
        mov     eax, menu_backg
        call    spr_load_gimp_ppm
        test    eax, eax
        jz      .alloc_failure
        mov     [menu_sprites+ecx*4], eax

        inc     ecx

        ; Start item state 0
        mov     eax, menu_start0
        call    spr_load_gimp_ppm
        test    eax, eax
        jz      .alloc_failure
        mov     [menu_sprites+ecx*4], eax

        inc     ecx

        ; Start item state 1
        mov     eax, menu_start1
        call    spr_load_gimp_ppm
        test    eax, eax
        jz      .alloc_failure
        mov     [menu_sprites+ecx*4], eax

        inc     ecx

        ; Highscore item state 0
        mov     eax, menu_highs0
        call    spr_load_gimp_ppm
        test    eax, eax
        jz      .alloc_failure
        mov     [menu_sprites+ecx*4], eax

        inc     ecx

        ; Highscore item state 1
        mov     eax, menu_highs1
        call    spr_load_gimp_ppm
        test    eax, eax
        jz      .alloc_failure
        mov     [menu_sprites+ecx*4], eax

        inc     ecx

        ; Exit item state 0
        mov     eax, menu_exitg0
        call    spr_load_gimp_ppm
        test    eax, eax
        jz      .alloc_failure
        mov     [menu_sprites+ecx*4], eax

        inc     ecx

        ; Highscore item state 1
        mov     eax, menu_exitg1
        call    spr_load_gimp_ppm
        test    eax, eax
        jz      .alloc_failure
        mov     [menu_sprites+ecx*4], eax

        inc     ecx
        push    ecx
        xor     ecx, ecx

        ; Start menu loop
    
        .rendermenuloop:
            ; Render menu
            .readeventsloop:
                ; Read events
                call    gfx_getevent

                test    eax, eax
                jz      .readeventsexit

                cmp     eax, 23
                je      .quitapp

                cmp     eax, 27
                je      .quitapp

                cmp     eax, 273
                je      .moveup

                cmp     eax, 274
                je      .movedown

                cmp     eax, 275
                je      .selected

                jmp     .readeventsloop

            .moveup:
                ; Move up selection
                dec     ecx
                cmp     ecx, 0
                jge     .readeventsloop

                mov     ecx, 2
                jmp     .readeventsloop

            .movedown:
                ; Move down selection
                inc     ecx
                cmp     ecx, 3
                jl      .readeventsloop

                mov     ecx, 0
                jmp     .readeventsloop

            .selected:
                ; Check selection
                cmp     ecx, 0
                je      .playgame

                cmp     ecx, 1
                je      .highscores

                mov     edx, -1
                jmp     .readeventsloop

            .playgame:
                mov     edx, 1
                jmp     .readeventsloop

            .highscores:
                mov     edx, 2
                jmp     .readeventsloop

            .readeventsexit:

            test    edx, edx
            jnz     .exitnormal ; edx was modified, so we want to exit
            
            ; Back to render loop
            mov     eax, 0x00ffffff
            call    render_clear

            ; Render background
            mov     eax, [menu_sprites]
            mov     ebx, 0x00000000
            call    render_copyspr


            ; Render menu items
            ; Play game item
            mov     ebx, 0x00200100
            cmp     ecx, 0
            je      .0sel

            mov     eax, [menu_sprites+4]
            jmp     .end0

        .0sel:
            mov     eax, [menu_sprites+8]

        .end0:
            call    render_copyspr

            ; Highscores item
            mov     ebx, 0x0020015a
            cmp     ecx, 1
            je      .1sel

            mov     eax, [menu_sprites+12]
            jmp     .end1

        .1sel:
            mov     eax, [menu_sprites+16]

        .end1:
            call    render_copyspr

            ; Exit item
            mov     ebx, 0x002001b4
            cmp     ecx, 2
            je      .2sel

            mov     eax, [menu_sprites+20]
            jmp     .end2

        .2sel:
            mov     eax, [menu_sprites+24]

        .end2:
            call    render_copyspr


            ; Render framebuffer content

            call    render_show
            jmp     .rendermenuloop


    .quitapp:
        mov     edx, -1 ; Exit requested

    .exitnormal:
        pop     ecx
        ; Exit normally
        .dealloc_loop0:
            mov     eax, [menu_sprites+ecx*4-4]
            call    spr_delete

            loop    .dealloc_loop0

        ; Restore registers
        pop     ecx
        pop     ebx
        pop     eax

        ret


    .alloc_failure:
        ; Dealloc images
        test    ecx, ecx
        jz      .exiterror

        .dealloc_loop1:
            mov     eax, [menu_sprites+ecx*4-4]
            call    spr_delete

            loop    .dealloc_loop1

    .exiterror:
        mov     edx, -1 ; Exit game due memory error
        ; Restore registers
        pop     ecx
        pop     ebx
        pop     eax

        ret





gameproc:
    ; Game state
        push    eax
        push    ebx
        push    ecx
        push    edi ; irany
        push    esi ; stepping
        
        mov     edi, 1
        mov     dword [last_dir], 1
        xor     esi, esi

        mov     eax, msg_enterGameState
        call    io_writestr
        call    io_writeln
        ; init game field (snake map)

        call    sm_initMap
        
        .render_test_loop:
            .eventloop:
                call    gfx_getevent

                test    eax, eax
                jz      .eventloopexit

                cmp     eax, 23
                je      .change_edx0

                cmp     eax, 27
                je      .change_edx1

                cmp     eax, 275
                je      .change_dir_right

                cmp     eax, 274
                je      .change_dir_down

                cmp     eax, 276
                je      .change_dir_left

                cmp     eax, 273
                je      .change_dir_up
                jmp     .eventloop

            .change_edx0:
                mov     edx, -1
                jmp     .eventloop

            .change_edx1:
                xor     edx, edx
                jmp     .eventloop

            .change_dir_right:
                cmp     dword [last_dir], 0
                je      .eventloop
                mov     edi, 1
                jmp     .eventloop

            .change_dir_down:
                cmp     dword [last_dir], 2
                je      .eventloop
                mov     edi, 3
                jmp     .eventloop

            .change_dir_left:
                cmp     dword [last_dir], 1
                je      .eventloop
                mov     edi, 0
                jmp     .eventloop

            .change_dir_up:
                cmp     dword [last_dir], 3
                je      .eventloop
                mov     edi, 2
                jmp     .eventloop

        .eventloopexit:
            cmp     edx, 0
            jle     .render_exit

            ; Stepping
            inc     esi
            cmp     esi, [speed]
            jb      .no_dir_change

            xor     esi, esi
            mov     eax, edi
            mov     [last_dir], edi
            call    sm_moveSnake
            jc      .death
            jmp     .no_dir_change

        .death:
            xor     edx, edx
            jmp     .render_exit

        .no_dir_change:


            mov     eax, 0x00ff2020
            call    render_clear

            call    sm_renderMap

            call    render_show


            mov     eax, 33
            call    sleep

            jmp     .render_test_loop

        .render_exit:
        ; Exiting rendering

        pop     esi
        pop     edi
        pop     ecx
        pop     ebx
        pop     eax

        ret



scoreproc:
    ; No score processing currently!
        push    eax

        mov     eax, msg_enterHScrState
        call    io_writestr
        call    io_writeln

        pop     eax
        
        ret



main:
    ; Initialize fonts
        mov     eax, msg_initFonts
        call    io_writestr
        call    io_writeln

        ; Set font path
        mov     eax, fonts_relative_path

        call    font_loadFonts
        jc      .font_error

        ; Success
        mov     eax, msg_initFsuccess
        call    io_writestr
        call    io_writeln

        ; Create window
        mov     eax, msg_createWin
        call    io_writestr
        call    io_writeln

        ; Set up window properties
        mov     eax, [width]
        mov     ebx, [height]
        mov     ecx, 0
        mov     edx, title

        call    render_createWindow
        jc      .win_error

        ; Success
        mov     eax, msg_createWsuccess
        call    io_writestr
        call    io_writeln


        ; Enter state selection loop
        ; States:
        ; 0 - Menu state, 1 - Game state, 2 - Highscore state
        mov     eax, msg_enterStateSelL
        call    io_writestr
        call    io_writeln
        ; Set up state
        xor     edx, edx


        ; Set speed (I have to change this later...)
        mov     esi, 2
        mov     [speed], esi

        .stateloop:
            ; State loop:
            test    edx, edx
            jz      .menustart
            cmp     edx, 1
            je      .gamestart
            cmp     edx, 2
            je      .highscore

            ; Menu returned other number, so exit is requested
            jmp     .exitgame

        .menustart:
            ; Start menu state
            call    menuproc
            jmp     .stateloop

        .gamestart:
            ; Start a game
            call    gameproc
            jmp     .stateloop

        .highscore:
            ; Start highscore state
            call    scoreproc
            xor     edx, edx ; Return to menu after game loop
            jmp     .stateloop

    .exitgame:
        ; Exit application
        mov     eax, msg_exit
        call    io_writestr
        call    io_writeln

        call    render_destroyWindow
        call    font_free

        ; Game exit #0 - without error
        ret



    .win_error:
        ; Exit application due window creation error
        mov     eax, msg_createWfailure
        call    io_writestr
        call    io_writeln

        call    font_free

        ; Game exit #1 - window error
        ret

    .font_error:
        mov     eax, msg_initFfailure
        call    io_writestr
        call    io_writeln

        ; Game exit #2 - font load error
        ret


section .bss
    ; Menu sprite cache
    menu_sprites resd 7
    last_dir resd 1
    speed   resd 1


section .data
    ; State messages
    msg_initFonts db 'Initializing fonts...', 0
    msg_initFsuccess db 'Fonts initialized successfully!', 0
    msg_initFfailure db 'Could not initialize fonts!', 0
    msg_initCards db 'Initializing cards...', 0
    msg_initCsuccess db 'Cards initialized successfully!', 0
    msg_initCfailure db 'Could not load cards!', 0
    msg_createWin db 'Creating window...', 0
    msg_createWsuccess db 'Window created successfully!', 0
    msg_createWfailure db 'Could not create window!', 0

    msg_enterStateSelL db 'Entering state selection loop...', 0
    msg_enterMenuState db 'Entering menu state...', 0
    msg_enterGameState db 'Entering game state...', 0
    msg_enterHScrState db 'Entering highscore menu state...', 0

    msg_exit db 'Exiting application...', 0

    ; Window data
    width  dd 1024
    height dd 768
    title  db 'Snake clone by Heim Laszlo', 0

    ; Font data
    fonts_relative_path db '..\resources\fonts\', 0


    ; Menu filenames
    menu_backg db '..\resources\background1.ppm', 0
    menu_start0 db '..\resources\start0.ppm', 0
    menu_start1 db '..\resources\start1.ppm', 0
    menu_highs0 db '..\resources\highs0.ppm', 0
    menu_highs1 db '..\resources\highs1.ppm', 0
    menu_exitg0 db '..\resources\exitg0.ppm', 0
    menu_exitg1 db '..\resources\exitg1.ppm', 0