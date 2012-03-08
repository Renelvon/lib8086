;------------------------------------------------------------
; ==> 8086 Library project <==                              |
; Released under GNU GPLv3 or later.                        |
; Credits to:                                               |
;   Orestis, b_gravedigger, Renelvon                        | 
;------------------------------------------------------------


;------------------------------------------------------------
; Library of generic macros.                                |
; Contents:                                                 |
;    1) RESETREG                                            |
;    2) EXIT                                                |
;    3) ISODD                                               |
;------------------------------------------------------------


; == RESETREG ==
; Sets all registers of 8086 to 0.
; MODIFIES: AX, BX, CX, DX, DI, SI.
RESETREG macro
	  mov AX,0x00
	  mov BX,0x00
	  mov CX,0x00
	  mov DX,0x00

	  mov DI,0x00
	  mov SI,0x00
endm

; == EXIT ==
; Successfully halts program execution.
; MODIFIES: AX.
EXIT macro 
    ; Service select: AH <- 0x4C
    ; Returned value: AL <- 0x00
    mov AX,0x4C00
    int 21H     ; Invoke DOS software interrupt.
endm

; == ISODD ==
; Takes a hex digit in al. Sets carry if it is odd.
; Modifies: FLAGS.
ISODD macro
LOCAL _MYEXIT
	clc         ; Clear carry.
	push AX     ; Save AL (AX).
	and AL,0x01 ; Is LSB of AL = 1?
	jz _MYEXIT  ; yes: Leave carry cleared.
	stc         ; no : Set carry.
_MYEXIT:
	pop AX      ; Restore AL (AX).
endm
