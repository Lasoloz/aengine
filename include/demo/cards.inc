;
; Copyright (c) 2016-2017 László Heim
;
; Header file for card caching functions
; - Load cards
; - Render card
; - Render card back
; - Free card cache
;
; Dependencies:
;   ...
;

%ifndef __CARDS_INC__
%define __CARDS_INC__


;;;
extern card_loadCards
; Load cards from a specified directory
;
; Parameter:
; eax - directory string [max 57 bytes (64-7 for filename)]
; Return value:
; cf success state


;;;
extern card_renderCard
; Render card to a specified position
;
; Parameters:
; eax - card number to render (this must be calculated before entering function)
; ebx - position for rendering (higher part x value, lower part y value)
; No return value


;;;
extern card_renderCardBack
; Render card back to a specified location
;
; Parameter:
; ebx - position for rendering
; Np return value


;;;
extern card_free
; Free occupied card sprite cache
;
; No parameters, no return values

%endif
