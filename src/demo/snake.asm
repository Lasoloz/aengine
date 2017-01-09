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

%include 'include/graphics/render.inc' ; For rendering functions
%include 'include/graphics/fonts.inc'  ; For text rendering
%include 'include/graphics/sprite.inc' ; For image handling

global main

section .text
main:
    ; Main function for application

        ret

section .bss

section .data
