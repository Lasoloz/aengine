;
; Copyright (c) 2016-2017 László Heim
;
; Header file for snake memory caching
; - Init snake map
; - Move snake to a direction
; - Render snake map
; - Query number of foods eaten
;
; Encoding of map:
; 0 - 000 - void
; 1 - 001 - snake moving left
; 2 - 010 - snake moving right
; 3 - 011 - snake moving up
; 4 - 100 - snake moving down
; 5 - 101 - snake head
; 6 - 102 - food
; 7 - 103 - wall
;
; Dependencies:
;   ...
;

%ifndef __SNAKE_MAP_INC__
%define __SNAKE_MAP_INC__


;;;
extern sm_initMap
; Initializes the game map with the default values (new game, new level, etc.)
;
; No parameters, no return values


;;;
extern sm_moveSnake
; Updates the map moving the snake to a specified direction
;
; Parameter:
; eax - direction code for the snake (00 - left, 01 - right, 10 - up, 11 - down)
; Return value:
; cf - Die state


;;;
extern sm_renderMap
; Renders the map (play field)
;
; No parameters, no return values


;;;
extern sm_queryFoodNum
; Return the number of foods eaten
;
; No parameters
; Return value:
; eax - Foods eaten


%endif
