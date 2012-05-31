;------------------------------------------------------------
; ==> 8086 Library project <==                              |
; Released under GNU LGPLv3 or later.                       |
; Copyright 2011-2012 Orestis, b_gravedigger, Renelvon      | 
;------------------------------------------------------------

;------------------------------------------------------------
; Library of generic macros.                                |
; Contents:                                                 |
;    1) RESETREG                                            |
;    2) EXIT                                                |
;    3) ISODD                                               |
;    4) HALT                                                |
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
    int 21H     ; Invoke DOS software interrupt.
endm

; == ISODD ==
; Sets carry flag if AL is odd.
; Clears carry flag otherwise.
; Modifies: FLAGS.
ISODD macro
LOCAL _MYEXIT
	clc         ; Clear carry.
	push AX     ; Save AL (AX).
	and AL, 0x01 ; Is LSB of AL = 1?
	jz _MYEXIT  ; yes: Leave carry cleared.
	stc         ; no : Set carry.
_MYEXIT:
	pop AX      ; Restore AL (AX).
endm
