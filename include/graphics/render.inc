;
; Copyright (c) 2016-2017 László Heim
;
; Header file for rendering functions
; - Create window, and save global framebuffer data
; - Destroy window
; - Clear gfx framebuffer
; - Render sprite to gfx framebuffer
; - Finalize rendering
;
; Dependencies:
;   include/graphics/sprite.inc  third-party/gfx.inc
;

%ifndef __RENDER_INC__
%define __RENDER_INC__


;;;
extern render_createWindow
; Creates a window
;
; Parameters (as in gfx)
; eax - Width
; ebx - Height
; ecx - Window mode (0[windowed]/1[fullscreen])
; edx - Pointer to title
; Return values:
; carry flag - success


;;;
extern render_destroyWindow
; Destroys a window
;
; No parameters, no return values


;;;
extern render_clear
; Clears the framebuffer
;
; Parameters:
; eax - Clear color (bbggrr00)
; No return values


;;;
extern render_copyspr
; Renders a sprite to the framebuffer
;
; Parameters:
; eax - Sprite's address
; ebx - x and y position for rendering (x - higher part, y - lower part)
;     - x and y might be negative
; No return values


;;;
extern render_show
; Finalize rendering, show result
;
; No parameters, no return values

%endif
