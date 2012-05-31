;------------------------------------------------------------
; ==> 8086 Library project <==                              |
; Released under GNU LGPLv3 or later.                       |
; Copyright 2011-2012 Orestis, b_gravedigger, Renelvon      | 
;------------------------------------------------------------

;------------------------------------------------------------
; Library of I/O procedures and macros                      |
; Contents:                                                 |
;    1) PRINT                                               |
;    2) PRINT_STR                                           |
;    3) READ                                                |
;    4) READ_ECHO                                           |
;------------------------------------------------------------

; == BACKSP ==
; Causes the cursor to delete last character.
; MODIFIES: [none]
; Untested.
BACKSP macro
	push AX         ; Save AX on stack.
    push DX         ; Save DX on stack. 
	mov DL, 0x08    ; Place '\b' in DL.
	mov AH, 0x02    ; Load DOS operation.
	int 21h         ; Call DOS.
    pop DX          ; Restore DX.
	pop AX          ; Restore AX.
endm

; == PRINT ==
; Prints char to screen.
; MODIFIES: [none]
PRINT macro CHAR
    push AX         ; Save AX on stack.
    push DX         ; Save DX on stack. 
    mov DL, CHAR    ; Place char byte in DL.
    mov AH, 0x02    ; Load DOS operation.
    int 21h         ; Call DOS.
    pop DX          ; Restore DX.
    pop AX          ; Restore AX.
endm

; == PRINT_STR ==
; Prints '$'-terminated string to screen.
; ASSUMES: String resides in segment pointed by DS.
; MODIFIES: [none]
PRINT_STR macro STRING
    push AX         ; Save AX on stack.
    push DX         ; Save DX on stack.
    lea DX,STRING   ; Load address of string @ DX.
    mov AH, 0x09    ; Load DOS operation.
    int 21h         ; Call DOS.
    pop DX          ; Restore DX.
	pop AX 			; Restore AX.
endm

; == READ ==
; Reads one char from keyboard. No echo.
; Character is returned in AL.
; MODIFIES: AX.
READ macro 
    mov AH, 0x08    ; Load DOS operation.
    int 21h         ; Call DOS.
endm

; == READ_ECHO ==
; Reads one char from keyboard and echoes it on screen.
; Character is returned in AL.
; MODIFIES: AX.
READ_ECHO macro
	mov AH, 0x01    ; Load DOS operation.
	int 21h         ; Call DOS.
endm
