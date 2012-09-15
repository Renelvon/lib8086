;------------------------------------------------------------
; ==> 8086 Library project <==                              |
; Released under GNU LGPLv3 or later.                       |
; Copyright 2011-2012 Orestis, Renelvon                     | 
;------------------------------------------------------------

;------------------------------------------------------------
; Library of generic macros.                                |
; Contents:                                                 |
;    1) RESETREG                                            |
;    2) EXIT                                                |
;    3) IS_ODD                                              |
;    4) IS_HEX                                              |
;    5) SAFE_CALL                                           |
;------------------------------------------------------------

; == RESETREG ==
; Sets all registers of 8086 to 0.
; MODIFIES: AX, BX, CX, DX, DI, SI.
RESETREG macro
    mov AX, 0
    mov BX, 0
    mov CX, 0
    mov DX, 0
    
    mov DI, 0
    mov SI, 0
endm

; == EXIT ==
; Successfully halts program execution.
; MODIFIES: AX.
EXIT macro 
    ; Service select: AH <- 0x4C
    ; Returned value: AL <- 0x00
    mov AX, 0x4C00
    int 0x21        ; Invoke DOS software interrupt.
endm

; == IS_ODD ==
; Sets carry flag if AL is odd.
; Clears carry flag otherwise.
; MODIFIES: FLAGS.
IS_ODD macro
LOCAL _MYEXIT
    clc             ; Clear carry.
    test AL, 0x01   ; Is LSB of AL = 1?
    jz _MYEXIT      ; yes: Leave carry cleared.
    stc             ; no : Set carry.
_MYEXIT:
endm

; == IS_HEX ==
; Sets carry flag if ASCII value of CHAR is a hexadecimal digit.
; Clears carry flag otherwise.
; ASSUMES: CHAR must be an 8-bit register.
; MODIFIES: FLAGS.
IS_HEX macro CHAR
LOCAL _HEX, _MYEXIT
    clc             ; Clear carry.
    cmp CHAR, '0'   ; chr(CHAR) <  chr(0) ?
    jb  _MYEXIT     ; yes: Not a hex digit.
    cmp CHAR, '9'   ; chr(CHAR) <= chr(9) ?
    jbe _HEX        ; yes: Hex digit.
    cmp CHAR, 'A'   ; chr(CHAR) <  chr(A) ?
    jb  _MYEXIT     ; yes: Not a hex digit.
    cmp CHAR, 'F'   ; chr(CHAR) <= chr(F) ?
    jbe _HEX        ; yes: Hex digit.
    cmp CHAR, 'a'   ; chr(CHAR) <  chr(a) ?
    jb  _MYEXIT     ; yes: Not a hex digit.
    cmp CHAR, 'f'   ; chr(CHAR) >  chr(f) ?
    jg  _MYEXIT     ; yes: Not a hex digit.
_HEX:
    stc             ; Set carry.
_MYEXIT:
endm              

; == SAFE_CALL ==
; Wraps a procedure call so that it doesn't affect
; any important register (AX, BX, CX, DX, FLAGS).
; MODIFIES: [none]
SAFE_CALL macro THE_PROC
    pushf           ; Store FLAGS
    push AX         ; Store AX.
    push BX         ; Store BX.
    push CX         ; Store CX.
    push DX         ; Store DX.

    call THE_PROC   ; Call the targeted procedure.

    pop  DX         ; Restore DX.
    pop  CX         ; Restore CX.
    pop  BX         ; Restore BX.
    pop  AX         ; Restore AX.
    popf            ; Restore FLAGS
endm
