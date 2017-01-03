;
; Copyright (c) 2016 László Heim
;
; Header file for image loading functions
; - Create an image matrix
; - Destroy image matrix
; - Load image data from file
; - Render image (copy to gfx framebuffer)
;
; Dependencies:
;   third-party/util.inc
;

%ifndef __SPRITE_INC__
%define __SPRITE_INC__

;;;
extern spr_create
; Create an image matrix in the memory
; An image matrix is defined by an array of data:
; First two byte fields are containing the width and the height of the image
; The next width*height*4 bytes long array contains the color data
;
; Parameters:
; eax - width in upper part.
;     - height in lower part
; Returned:
; eax - Pointer to allocated data
;     - eax will contain 0, if couldn't allocate memory


;;;
extern spr_delete
; Deletes an allocated sprite array
;
; Paramters:
; eax - Sprite pointer


;;;
extern spr_load_gimp_ppm
; Loads an image from the filesystem (netpbm format) to the specified sprite
;
; Parameters:
; eax - Address of filename string
; Returned:
; eax - Sprite address
;     - 0 returned on failure


;;;
extern spr_render
; Renders an image to a gfx framebuffer
;
; Parameters:
; eax - Framebuffer address
; ebx - Sprite address
; ecx - x, y positions of the framebuffer (vecint)
; edx - width, height of the framebuffer (vecint)
; Nothing returned

%endif
