;------------------------------------------------------------
; ==> 8086 Library project <==                              |
; Released under GNU GPLv3 or later.                        |
; Credits to:                                               |
;   Orestis, b_gravedigger, Renelvon                        | 
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
; Buggy.
BACKSP macro
	push AX
	mov DL,08h
	mov AH,022h
	int 21h
	mov DL,020h
	mov AH,02h
	int 21h
	pop AX
endm

; == PRINT ==
; Prints char to screen.
PRINT macro CHAR
    push AX         ; Save AX on stack.
    push DX         ; Save DX on stack. 
    mov DL, CHAR    ; Place char byte in DL
    mov AH,2        ; Load DOS operation.
    int 21h         ; Call DOS.
    pop DX          ; Restore DX.
    pop AX          ; Restore AX.
endm

; == PRINT_STR ==
; Prints '$'-terminated string to screen.
; MODIFIES: [none]
PRINT_STR macro STRING
    push AX         ; Save AX on stack.
    push DX         ; Save DX on stack
    lea DX, STRING  ; Load address of string @ DX
    mov AH,9        ; Load DOS operation 
    int 21h         ; Call DOS.
    pop DX          ; Restore DX.
	pop AX 			; Restore AX.
endm

; == READ ==
; Reads one char from keyboard. No echo.
; Character is returned in AL.
; MODIFIES: AX.
READ macro 
    mov AH,0x08
    int 21h
endm

; == READ_ECHO ==
; Reads one char from keyboard and echoes it on screen.
; Character is returned in AL.
; MODIFIES: AX.
READ_ECHO macro
	mov AH,0x01
	int 21h
endm
