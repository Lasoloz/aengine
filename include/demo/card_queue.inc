;
; Copyright (c) 2016-2017 László Heim
;
; Header file for card queue functions
; Card queue is a continues link of cards (one queue per game)
; - Add card to queue
; - Get card information from queue top
; - Remove card from queue
; - Flip the last card in queue
; - Render queue
;
; Dependencies:
; ...
;


%ifndef __CARD_QUEUE_INC__
%define __CARD_QUEUE_INC__


;;;
extern cq_addCard
; Add card to queue
;
; Parameter:
; eax - Card id
; Return value: no return value


;;;
extern cq_getTopCard
; Get the id of the card on the top
;
; No parameters
; Return value:
; eax - card id


;;;
extern cq_removeTopCard
; Delete the card on the top of the queue
;
; No parameters, no return values


;;;
extern cq_flipTop
; Flip a card to the top of the queue
;
; No parameters, no return values


;;;
extern cq_render
; Render the current state of the queue to a specified location
;
; Parameter:
; ebx - Position of render (x - higher part, y - lower part)
; No return values


%endif
