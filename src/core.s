    .include "via_const.inc"
    .export _delay
    .code

; c version of delay 
; void delay(u16 time)
; which are in a (low byte) and x (high byte) registers
_delay:
    sta VIA_REGISTER_T1CL + __VIA_START__
    stx VIA_REGISTER_T1CH + __VIA_START__
@delay_loop:
    bit VIA_REGISTER_IFR + __VIA_START__
    bvc @delay_loop
    lda VIA_REGISTER_T1CL + __VIA_START__ ; clear timer
    rts

