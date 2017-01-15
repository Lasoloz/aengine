;
; Copyright (c) 2016-2017 László Heim
;
; Header file for score handling
; - Load score file
; - Test new highscore
; - Modify score cache
; - Render highscore table
; - Save score cache to file
;
; Highscore format:
; name1_____name2_____name3_____...name10______scr1scr2scr3...sc10
; (Every character means one byte)
;
; Dependencies:
;   third-party/util.inc  include/userutil.inc
;

%ifndef __SCORE_INC__
%define __SCORE_INC__

;;;
extern sr_loadFromFile
; Loads the highscore entries from a file
;
; Parameter:
; eax - Pointer to file string
; No return values


;;;
extern sr_testScore
; Tests a score, and modifies the list if it has to
;
; Parameter:
; eax - Points
; Return value:
; cf - Can be pushed?


;;;
extern sr_pushScore
; Push a score to the scoretable
;
; Paramters:
; eax - Points
; ebx - Name of player
; No return values


extern sr_renderTable
; Render a table for names and scores to a specified location
;
; Parameter:
; ebx - Position on screen
; No return values


;;;
extern sr_saveToFile
; Saves a score, if there is a modification
;
; No Parameters no return values

%endif
