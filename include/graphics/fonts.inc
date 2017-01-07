;
; Copyright (c) 2016-2017 László Heim
;
; Header file for font system
; - Load fonts
; - Draw text
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
extern font_free
; Frees the font cache
;
; No parameters or return values


%endif
