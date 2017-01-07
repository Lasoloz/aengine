;
; Copyright (c) 2016-2017 László Heim
;
; String utilities
; - Read one character from filestream
; - Copy String
;
; Dependencies:
;   third-party/util.inc
;

%ifndef __USERUTIL_INC__
%define __USERUTIL_INC__

;;;
extern uu_readChar
; Reads one char from the specified file stream
; In case of error/end-of-file carry flag is set
;
; Parameter:
; eax - File handle
; Returned:
; edx - Character in dl
; cf  - Read state


;;;
extern uu_copyStr
; Copies data from a string to a buffer
;
; Parameters:
; eax - Destination address
; ebx - Source address
; ecx - Destination size
; Returned:
; edx - Characters copied (excluding 0 character at the end)

%endif
