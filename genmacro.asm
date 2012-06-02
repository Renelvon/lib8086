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
;------------------------------------------------------------


; == RESETREG ==
; Sets all registers of 8086 to 0.
; MODIFIES: AX, BX, CX, DX, DI, SI.
RESETREG macro
	  mov AX, 0x00
	  mov BX, 0x00
	  mov CX, 0x00
	  mov DX, 0x00

	  mov DI, 0x00
	  mov SI, 0x00
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
	push AX         ; Save AL (AX).
	and AL, 0x01    ; Is LSB of AL = 1?
	jz _MYEXIT      ; yes: Leave carry cleared.
	stc             ; no : Set carry.
_MYEXIT:
	pop AX          ; Restore AL (AX).
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
	jb	_MYEXIT     ; yes: Not a hex digit.
	cmp	CHAR, '9'   ; chr(CHAR) <= chr(9) ?
	jbe	_HEX        ; yes: Hex digit.
	cmp CHAR, 'A'   ; chr(CHAR) <  chr(A) ?
	jb	_MYEXIT     ; yes: Not a hex digit.
    cmp	CHAR, 'F'   ; chr(CHAR) <= chr(F) ?
	jbe	_HEX        ; yes: Hex digit.
	cmp	CHAR, 'a'   ; chr(CHAR) <  chr(a) ?
	jb	_MYEXIT     ; yes: Not a hex digit.
	cmp	CHAR, 'f'   ; chr(CHAR) >  chr(f) ?
	jg	_MYEXIT     ; yes: Not a hex digit.
_HEX:
	stc             ; Set carry.
_MYEXIT:
endm              
