;------------------------------------------------------------
; ==> 8086 Library project <==                              |
; Released under GNU GPLv3 or later.                        |
; Credits to:                                               |
;   Orestis, b_gravedigger, Renelvon                        | 
;------------------------------------------------------------

;------------------------------------------------------------
; Library of numeric-specific routines and macros.          |
; Contents:                                                 |
;    1) BIN_DEC                                             |
;    2) PRINT_HEX                                           |
;    3) OCT_KEYB                                            |
;    4) HEX_KEYB                                            |
;------------------------------------------------------------

; Library for numerical conversions.

; == BIN_DEC ==
; Prints number in AX as sequence of decimal digits.
; MODIFIES: FLAGS, AX, BX, CX, DX
; REQUIRES: <iolib.asm>
BIN_DEC macro       ; Print number in AX as decimal.
LOCAL _PROC, _OUT
    mov cx,0        ; CX will be used as counter for decimal digits.
_PROC:
    mov dx,0        
    mov bx,10       ; Divide by 10 to find next decimal digit.
    div bx          ; Quotient in AX, remainder in DX.
    push dx         ; Store decimal digit.
    inc cx          ; Increase digits. 
    cmp ax,0        ; When AX=0 there are no more digits.
    jnz _PROC
_OUT:
    pop dx          ; Pop decimal digits from MSD to LSD.
    add dx,30h      ; Add 30H to take the ASCII code
    PRINT dl        ; ... and print as char.
    loop _OUT       ; Loop until no decimal digits left (CX = 0).
endm

; == PRINT_HEX ==
; Prints DL as a hex digit. Assume 00h <= DL <= 0Fh
; MODIFIES: FLAGS, DX.
; REQUIRES: <iolib.asm>
PRINT_HEX macro
LOCAL _ADD10, _HEX_OUT
    cmp DL, 9       ; DL <= 9?
    jle _ADD10      ; yes: jump to appropriate fixing code.
    add DL, 37H     ; no : Prepare DL by adding chr(A) - 10d = 37h 
    jmp _HEX_OUT    ; ... and go to output stage
_ADD10:
    add DL, 30h     ; Prepare DL by adding chr(0) = 30h
_HEX_OUT:
    PRINT DL        ; Print char to screen.
endm

; == OCT_KEYB ==
; Repeatedly requests a character from keyboard until user enters
; an octal digit. The octal digit is echoed on the screen.
; The binary value of the digit is returned in AL.
; Routine is terminated immediately if user enters 'Q'.
; 
; MODIFIES: FLAGS, AX
; REQUIRES: <iolib.asm>
OCT_KEYB macro
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

; == HEX_KEYB ==
; Requests a hex digit form keyboard and returns its binary value in AL.
; Routine is terminated if user enters 'Q'
; MODIFIES: FLAGS, AX
; REQUIRES: <iolib.asm>
HEX_KEYB macro
LOCAL _HIGNORE, _HQUIT, _HFORW
_HIGNORE:
    READ            ; Read a char from keyboard.
    cmp AL, 'Q'     ; If user entered 'Q', terminate program.
    je _HQUIT
    cmp AL, '0'     ; chr(AL) < chr(0)?.
    jl _HIGNORE      ; yes: Ignore and request new char.
    cmp AL, '9'     ; chr(AL) > chr(9)?
    jg _HFORW        ; Go to A-F handler.
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
	add AL, 0Ah		; Properly adjust numeric value.
_HQUIT:
    ret
endm
