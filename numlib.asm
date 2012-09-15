;------------------------------------------------------------
; ==> 8086 Library project <==                              |
; Released under GNU LGPLv3 or later.                       |
; Copyright 2011-2012 Orestis, Renelvon                     | 
;------------------------------------------------------------

;------------------------------------------------------------
; Library of routines for input, output and conversion      | 
; of various kinds of numeric quantities.                   |
; Contents:                                                 |
;    1) out_bin_word                                        |
;    2) out_dec_word                                        |
;    3) out_hex                                             |
;    4) out_hex_byte                                        |
;    5) out_hex_word                                        |
;    6) in_oct                                              |
;    7) in_dec                                              |
;    8) in_hex                                              |
;------------------------------------------------------------

; Warning: Untested library.

; == out_bin_word ==
; Prints number in AX as sequence of binary digits.
; MODIFIES: FLAGS, AX, CX, DX
; REQUIRES: <iolib.asm>: PRINT
out_bin_word proc NEAR
    mov CX, 16      ; Set up loop to print 16 bits.
_BOUT:
    mov DL, '0'     ; DL = chr(0). ('0' = 0x30, '1' = 0x31)
    shl AX, 1       ; Shift MSB of AX into CF.
    adc DL, 0       ; Add CF to DL to adjust the ASCII code 
    PRINT DL        ; ... and print DL as char.
    loop _BOUT      ; Loop until no binary digits left (CX = 0).
    ret             ; Terminate routine.
endp

; == out_dec_word ==
; Prints number in AX as sequence of decimal digits.
; MODIFIES: FLAGS, AX, BX, CX, DX
; REQUIRES: <iolib.asm>: PRINT_UNSAFE
out_dec_word proc NEAR
    mov CX, 0       ; CX will be used as counter for decimal digits.
_DCALC:             ; Digit-calculation loop.
    mov DX, 0       ; Zero DX.    
    mov BX, 10      ; Divide DX:AX by 10 to find next decimal digit.
    div BX          ; Quotient in AX, remainder in DX.
    push DX         ; Store decimal digit.
    inc CX          ; Increase digit counter. 
    cmp AX, 0       ; Repeat until there are no more digits (AX = 0).
    jnz _DCALC
_DOUT:              ; Digit-printing loop (from MSD to LSD).
    pop DX          ; Pop a decimal digit.
    add DX, '0'     ; Generate ASCII code
    PRINT_UNSAFE DL ; ... and print as char.
    loop _DOUT      ; Loop until no decimal digits left (CX = 0).
    ret             ; Terminate routine.
endp

; == out_hex ==
; Prints DL as a hex digit.
; ASSUMES: 0x00 <= DL <= 0x0f
; MODIFIES: FLAGS, DX.
; REQUIRES: <iolib.asm>: PRINT_UNSAFE
out_hex proc NEAR
    cmp DL, 9       ; DL <= 9?
    jle _DEC        ; yes: jump to appropriate fixing code.
    add DL, 0x37    ; no : Prepare DL by adding chr(A) - 10 = 0x37.
    jmp _HEX_OUT    ; ... and go to output stage.
_DEC:  
    add DL, '0'     ; Prepare DL by adding chr(0) = 0x30.
_HEX_OUT:
    PRINT_UNSAFE DL ; Print char to screen.
    ret             ; Terminate routine.
endp

; == out_hex_byte ==
; Prints AL as 2 hex digits.
; MODIFIES: AX, CX, DX
; REQUIRES: <numlib.asm>: out_hex
out_hex_byte proc NEAR
    mov CH, AL      ; Save AL in CH.
    mov CL, 4       ; Set rotation counter.
    shr AL, CL      ; Swap high & low nibble of AL, to print MSH first.
    and AL, 0x0f    ; Mask out high nibble (low nibble is single hex digit).
    mov DL, AL      ; Copy AL to DL.
    call out_hex    ; ... and print as hex.
    mov AL, CH      ; Recover unswapped AL from CH.
    and AL, 0x0f    ; Mask out high nibble (already printed).
    mov DL, AL      ; Copy AL to DL.
    call out_hex    ; ... and print as hex.
    ret             ; Terminate routine.
endp

; == out_hex_word ==
; Prints AX as 4 hex digits.
; MODIFIES: AX, CX, BX, DX
; REQUIRES: <numlib.asm>: out_hex_byte
out_hex_word proc NEAR
    mov BX, AX          ; Save AX in BX.
    xchg AH, AL         ; Exchange AL with AH,
                        ; Now AL contains the two most significant hex digits.
    call out_hex_byte   ; Print AL as 2 hex digits.
    mov AX, BX          ; Restore AX from BX.
                        ; Now AL contains the two least significant hex digits.
    call out_hex_byte   ; Print AL as 2 hex digits.
    ret                 ; Terminate routine.
endp

; == in_oct ==
; Repeatedly requests a character from keyboard until user enters
; an octal digit. The octal digit is echoed on the screen.
; The value of the digit is returned in AL.
; Routine is terminated immediately if user enters 'Q'.
; 
; MODIFIES: FLAGS, AX
; REQUIRES: <iolib.asm>: PRINT, READ
in_oct proc NEAR
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
    ret             ; Terminate routine.
endp

; == in_dec ==
; Repeatedly requests a character from keyboard until user enters
; a decimal digit. The decimal digit is echoed on the screen.
; The value of the digit is returned in AL.
; Routine is terminated immediately if user enters 'Q'.
; 
; MODIFIES: FLAGS, AX
; REQUIRES: <iolib.asm>: PRINT, READ
in_dec proc NEAR
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
    ret             ; Terminate routine.
endp

; == in_hex ==
; Repeatedly requests a character from keyboard until user enters
; a hex digit. The hex digit is echoed on the screen.
; The value of the digit is returned in AL.
; Routine is terminated immediately if user enters 'Q'.
;
; MODIFIES: FLAGS, AX
; REQUIRES: <iolib.asm>: PRINT, READ
in_hex proc NEAR
_HIGNORE:
    READ            ; Read a char from keyboard.
    cmp AL, 'Q'     ; If user entered 'Q', terminate program.
    je _HQUIT
    cmp AL, '0'     ; chr(AL) < chr(0)?.
    jl _HIGNORE     ; yes: Ignore and request new char.
    cmp AL, '9'     ; chr(AL) > chr(9)?
    jg _HFORW       ; Go to a-f/A-F handler.
    PRINT AL        ; Char is in 0-9 range. Print it to screen.
    sub AL, '0'     ; Get numeric value.
    ret             ; Terminate routine.
_HFORW:
    cmp AL, 'a'     ; chr(AL) < chr(a)?
    jl _HFORW2      ; yes: Go to A-F handler.
    cmp AL, 'f'     ; chr(AL) > chr(f)?
    jg _HIGNORE     ; yes: Ignore and request new char. (chr(F) < chr(f))
    PRINT AL        ; Char is in a-f range. Print it to screen.
    sub AL, 'a'     ; Get difference from 10.
    add AL, 0x0a    ; Properly adjust numeric value.
    ret             ; Terminate routine.
_HFORW2:
    cmp AL, 'A'     ; chr(AL) < chr(A)?
    jl _HIGNORE     ; yes: Ignore and request new char.
    cmp AL, 'F'     ; chr(AL) > chr(F)?
    jg _HIGNORE     ; yes: Ignore and request new char.
    PRINT AL        ; Char is in A-F range. Print it to screen.
    sub AL, 'A'     ; Get difference from 10.
    add AL, 0x0a    ; Properly adjust numeric value.
    ret             ; Terminate routine.
endp
