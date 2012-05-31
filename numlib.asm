;------------------------------------------------------------
; ==> 8086 Library project <==                              |
; Released under GNU LGPLv3 or later.                       |
; Copyright 2011-2012 Orestis, b_gravedigger, Renelvon      | 
;------------------------------------------------------------

;------------------------------------------------------------
; Library of numeric-specific routines and macros.          |
; Contents:                                                 |
;    1) OUT_DEC_ALL                                         |
;    2) OUT_HEX                                             |
;    3) IN_OCT                                              |
;    4) IN_HEX                                              |
;------------------------------------------------------------

; Warning: Untested library.

; == OUT_DEC_ALL ==
; Prints number in AX as sequence of decimal digits.
; MODIFIES: FLAGS, AX, BX, CX, DX
; REQUIRES: <iolib.asm>: PRINT
OUT_DEC_ALL macro
LOCAL _PROC, _OUT
    mov CX, 0x00    ; CX will be used as counter for decimal digits.
_PROC:
    mov DX, 0x00        
    mov BX, 10      ; Divide by 10 to find next decimal digit.
    div BX          ; Quotient in AX, remainder in DX.
    push DX         ; Store decimal digit.
    inc CX          ; Increase digits. 
    cmp AX, 0x00    ; When AX=0 there are no more digits.
    jnz _PROC
_OUT:
    pop DX          ; Pop decimal digits from MSD to LSD.
    add DX, 0x30    ; Add 30H to take the ASCII code
    PRINT DL        ; ... and print as char.
    loop _OUT       ; Loop until no decimal digits left (CX = 0).
endm

; == OUT_HEX ==
; Prints DL as a hex digit.
; ASSUMES: 0x00 <= DL <= 0x0f
; MODIFIES: FLAGS, DX.
; REQUIRES: <iolib.asm>: PRINT
OUT_HEX macro
LOCAL _ADD10, _HEX_OUT
    cmp DL, 9       ; DL <= 9?
    jle _ADD10      ; yes: jump to appropriate fixing code.
    add DL, 0x37    ; no : Prepare DL by adding chr(A) - 10d = 37h 
    jmp _HEX_OUT    ; ... and go to output stage.
_ADD10:
    add DL, 0x30    ; Prepare DL by adding chr(0) = 30h.
_HEX_OUT:
    PRINT DL        ; Print char to screen.
endm

; == IN_OCT ==
; Repeatedly requests a character from keyboard until user enters
; an octal digit. The octal digit is echoed on the screen.
; The binary value of the digit is returned in AL.
; Routine is terminated immediately if user enters 'Q'.
; 
; MODIFIES: FLAGS, AX
; REQUIRES: <iolib.asm>: PRINT, READ
IN_OCT macro
LOCAL _OIGNORE, _OQUIT
_OIGNORE:
    READ            ; Read a char from keyboard.
    cmp AL, 'Q'     ; If user entered 'Q', terminate program.
    je _OQUIT
    cmp AL, '0'     ; chr(AL) < chr(0)?.
    jl _OIGNORE     ; yes: Ignore and request new char.
    cmp AL, '7'     ; chr(AL) > chr(7)?
    jg _OIGNORE     ; yes: Ignore and request new char.
    PRINT al        ; Char is in 0-7 range. Print it to screen.
    sub AL, '0'     ; Get numeric value.
_OQUIT:
endm

; == IN_HEX ==
; Repeatedly requests a character from keyboard until user enters
; a hex digit. The hex digit is echoed on the screen.
; The binary value of the digit is returned in AL.
; Routine is terminated immediately if user enters 'Q'.
;
; MODIFIES: FLAGS, AX
; REQUIRES: <iolib.asm>: PRINT, READ
IN_HEX macro
LOCAL _HIGNORE, _HQUIT, _HFORW
_HIGNORE:
    READ            ; Read a char from keyboard.
    cmp AL, 'Q'     ; If user entered 'Q', terminate program.
    je _HQUIT
    cmp AL, '0'     ; chr(AL) < chr(0)?.
    jl _HIGNORE     ; yes: Ignore and request new char.
    cmp AL, '9'     ; chr(AL) > chr(9)?
    jg _HFORW       ; Go to A-F handler.
    PRINT al        ; Char is in 0-9 range. Print it to screen.
    sub AL, '0'     ; Get numeric value.
    jmp _HQUIT      ; Terminate routine.
_HFORW:
    cmp AL, 'A'     ; chr(AL) < chr(A)?
    jl _HIGNORE     ; yes: Ignore and request new char.
    cmp AL, 'F'     ; chr(AL) > chr(F)?
    jg _HIGNORE     ; yes: Ignore and request new char.
    PRINT al        ; Char is in A-F range. Print it to screen.
    sub AL, 'A'     ; Get differnce from 10.
	add AL, 0x0a	; Properly adjust numeric value.
_HQUIT:
endm
