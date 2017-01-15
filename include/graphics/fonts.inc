;
; Copyright (c) 2016-2017 László Heim
;
; Header file for font system
; - Load fonts
; - Set spacing for text rendering
; - Set line height for text rendering
; - Render text
; - Render decimal number
; ? Calculate text area
; - Free font cache
;
; Dependencies:
;   include/graphics/sprite.inc  include/graphics/render.inc
;

%ifndef __FONTS_INC__
%define __FONTS_INC__


;;;
extern font_loadFonts
; Load fonts with a specified name format
;
; Parameter:
; eax - Directory string [max 59 bytes (64-5 for filename)]
; Returned:
; cf  - Success state


;;;
extern font_setSpacing
; Sets spacing between characters
;
; Parameter:
; ax - Spacing value (16-bit unsigned)
; No return value


;;;
extern font_setLineHeight
; Sets the height of a line
; When LINE FEED (new line) is detected, it advances the y position with this
; value. (Respectively CARRIAGE RETURN push backs the x position to the starting
; value.)
;
; Parameter:
; ax - Line height value (16-bit unsigned)
; No return value

;;;
extern font_renderText
; Renders a text to a specified location.
;
; Parameters:
; eax - String pointer (C-Style string)
; ebx - x, y positions for rendering (higher part x, lower part y)
; No return value


;;;
extern font_renderNumber
; Renders an unsigned number in decimal form
;
; Parameters:
; eax - Number to render
; ebx - x, y positions for rendering (higher bits x, lower bits y)
; ecx - Min width of number (first part filled with 0-s)
; No return values


;;;
extern font_free
; Frees the font cache
;
; No parameters or return values


%endif
