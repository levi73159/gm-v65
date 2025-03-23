        .include "via_const.inc"
        .include "zeropage.inc"

        .import __VIA_START__
        .export via_get_register
        .export _via_get_register
        .export via_set_register
        .export _via_set_register

        .macro inc_ptr pointer, offset
        .ifblank offset
        .local @skip
        inc pointer
        bne @skip
        inc pointer+1
@skip:
        .else
        php
        pha
        clc
        lda pointer
        adc offset
        sta pointer
        lda pointer+1
        adc #$00
        sta pointer+1
        pla
        plp 
        .endif
        .endmacro

        .code

via_get_register:
        lda __VIA_START__,X
        rts

_via_get_register:
        tax
        lda __VIA_START__,X
        rts

; NEGATIVE C COMPLIANT
via_set_register:
        sta __VIA_START__,X
        rts

_via_set_register:
        pha
        lda (sp)
        tax
        pla
        sta __VIA_START__,X
        inc_ptr sp
        rts
