;------------------------------------------------------------
; ==> 8086 Library project <==                              |
; Released under GNU LGPLv3 or later.                       |
; Copyright 2011-2012 Orestis, Renelvon                     | 
;------------------------------------------------------------

;------------------------------------------------------------
; Library of I/O macros.                                    |
; Contents:                                                 |
;    1) BACKSP                                              |
;    2) PRINT                                               |
;    3) PRINT_UNSAFE                                        |
;    4) PRINT_STR                                           |
;    5) PRINT_STR_UNSAFE                                    |
;    6) READ                                                |
;    7) READ_ECHO                                           |
;------------------------------------------------------------

; Note: The 'unsafe' versions of the following macros
; have the same functionality as their normal counterparts.
; However, they forego any register saving/restoring. Thus,
; they are intended for those occasions where best performance
; or explicit stack control is required.

; == BACKSP ==
; Causes the cursor to delete last character.
; MODIFIES: [none]
; Untested.
BACKSP macro
	push AX         ; Save AX on stack.
    push DX         ; Save DX on stack. 
	mov DL, 0x08    ; Place '\b' in DL.
	mov AH, 0x02    ; Load DOS operation.
	int 0x21        ; Call DOS.
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
    int 0x21        ; Call DOS.
    pop DX          ; Restore DX.
    pop AX          ; Restore AX.
endm

; == PRINT_UNSAFE ==
; Prints char to screen.
; MODIFIES: AX, DX
PRINT_UNSAFE macro CHAR
    mov DL, CHAR    ; Place char byte in DL.
    mov AH, 0x02    ; Load DOS operation.
    int 0x21        ; Call DOS.
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
    int 0x21        ; Call DOS.
    pop DX          ; Restore DX.
	pop AX 			; Restore AX.
endm

; == PRINT_STR_UNSAFE ==
; Prints '$'-terminated string to screen.
; ASSUMES: String resides in segment pointed by DS.
; MODIFIES: AX, DX
PRINT_STR_UNSAFE macro STRING
    lea DX,STRING   ; Load address of string @ DX.
    mov AH, 0x09    ; Load DOS operation.
    int 0x21        ; Call DOS.
endm

; == READ ==
; Reads one char from keyboard. No echo.
; Character is returned in AL.
; MODIFIES: AX.
READ macro 
    mov AH, 0x08    ; Load DOS operation.
    int 0x21        ; Call DOS.
endm

; == READ_ECHO ==
; Reads one char from keyboard and echoes it on screen.
; Character is returned in AL.
; MODIFIES: AX.
READ_ECHO macro
	mov AH, 0x01    ; Load DOS operation.
	int 0x21        ; Call DOS.
endm
