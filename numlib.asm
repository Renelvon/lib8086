;------------------------------------------------------------
; ==> 8086 Library project <==                              |
; Released under GNU LGPLv3 or later.                       |
; Copyright 2011-2012 Orestis, Renelvon                     | 
;------------------------------------------------------------

;------------------------------------------------------------
; Library of numeric-specific routines and macros.          |
; Contents:                                                 |
;    1) OUT_HEX                                             |
;    2) OUT_BIN_ALL                                         |
;    3) OUT_DEC_ALL                                         |
;    4) OUT_HEX_ALL                                         |
;    5) IN_OCT                                              |
;    6) IN_DEC                                              |
;    7) IN_HEX                                              |
;------------------------------------------------------------

; Warning: Untested library.

; == OUT_HEX ==
; Prints DL as a hex digit.
; ASSUMES: 0x00 <= DL <= 0x0f
; MODIFIES: FLAGS, DX.
; REQUIRES: <iolib.asm>: PRINT_UNSAFE
OUT_HEX macro
LOCAL _ADD10, _HEX_OUT
    cmp DL, 9       ; DL <= 9?
    jle _ADD10      ; yes: jump to appropriate fixing code.
    add DL, 0x37    ; no : Prepare DL by adding chr(A) - 10d = 37h 
    jmp _HEX_OUT    ; ... and go to output stage.
_ADD10:
    add DL, 0x30    ; Prepare DL by adding chr(0) = 30h.
_HEX_OUT:
    PRINT_UNSAFE DL ; Print char to screen.
endm

; == OUT_BIN_ALL ==
; Prints number in AX as sequence of binary digits.
; MODIFIES: FLAGS, AX, CX, DX
; REQUIRES: <iolib.asm>: PRINT
OUT_BIN_ALL macro
LOCAL _PRINT, _OUT
    mov CX, 16      ; Set up loop to print 16 bits.
_PRINT:
    shl AX, 1       ; MSB goes into carry.
    mov DL, 0x00
    adc DL, '0'     ; Add 0x30 to take the ASCII code ('0' = 30h, '1' = 31h)
    PRINT DL        ; ... and print as char.
    loop _PRINT     ; Loop until no binary digits left (CX = 0).
endm

; == OUT_DEC_ALL ==
; Prints number in AX as sequence of decimal digits.
; MODIFIES: FLAGS, AX, BX, CX, DX
; REQUIRES: <iolib.asm>: PRINT_UNSAFE
OUT_DEC_ALL macro
LOCAL _PROC, _OUT
    mov CX, 0x00    ; CX will be used as counter for decimal digits.
_PROC:
    mov DX, 0x00        
    mov BX, 10      ; Divide by 10 to find next decimal digit.
    div BX          ; Quotient in AX, remainder in DX.
    push DX         ; Store decimal digit.
    inc CX          ; Increase digit counter. 
    cmp AX, 0x00    ; Repeat until there are no more digits (AX=0).
    jnz _PROC
_OUT:
    pop DX          ; Pop a decimal digit (from MSD to LSD).
    add DX, '0'     ; Take the ASCII code
    PRINT_UNSAFE DL ; ... and print as char.
    loop _OUT       ; Loop until no decimal digits left (CX = 0).
endm

; == IN_OCT ==
; Repeatedly requests a character from keyboard until user enters
; an octal digit. The octal digit is echoed on the screen.
; The value of the digit is returned in AL.
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
    PRINT AL        ; Char is in 0-7 range. Print it to screen.
    sub AL, '0'     ; Get numeric value.
_OQUIT:
endm

; == IN_DEC ==
; Repeatedly requests a character from keyboard until user enters
; a decimal digit. The decimal digit is echoed on the screen.
; The value of the digit is returned in AL.
; Routine is terminated immediately if user enters 'Q'.
; 
; MODIFIES: FLAGS, AX
; REQUIRES: <iolib.asm>: PRINT, READ
IN_DEC macro
LOCAL _DIGNORE, _DQUIT
_DIGNORE:
    READ            ; Read a char from keyboard.
    cmp AL, 'Q'     ; If user entered 'Q', terminate program.
    je _DQUIT
    cmp AL, '0'     ; chr(AL) < chr(0)?.
    jl _DIGNORE     ; yes: Ignore and request new char.
    cmp AL, '9'     ; chr(AL) > chr(9)?
    jg _DIGNORE     ; yes: Ignore and request new char.
    PRINT AL        ; Char is in 0-9 range. Print it to screen.
    sub AL, '0'     ; Get numeric value.
_DQUIT:
endm

; == IN_HEX ==
; Repeatedly requests a character from keyboard until user enters
; a hex digit. The hex digit is echoed on the screen.
; The value of the digit is returned in AL.
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
    PRINT AL        ; Char is in 0-9 range. Print it to screen.
    sub AL, '0'     ; Get numeric value.
    jmp _HQUIT      ; Terminate routine.
_HFORW:
    cmp AL, 'A'     ; chr(AL) < chr(A)?
    jl _HIGNORE     ; yes: Ignore and request new char.
    cmp AL, 'F'     ; chr(AL) > chr(F)?
    jg _HIGNORE     ; yes: Ignore and request new char.
    PRINT AL        ; Char is in A-F range. Print it to screen.
    sub AL, 'A'     ; Get differnce from 10.
	add AL, 0x0a	; Properly adjust numeric value.
_HQUIT:
endm
