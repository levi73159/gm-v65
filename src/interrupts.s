    .include "via_const.inc"
    .export irq_init
    .export _enable_interrupts
    .export _disable_interrupts
    .export irq
    .export nmi
    .import _interrupt

    .code
irq_init:
    sei ; disable interrupts at start
    lda #(VIA_IER_SET_FLAGS | VIA_IER_CA1_FLAG)
    sta VIA_REGISTER_IER + __VIA_START__
    lda #VIA_PCR_CA1_INTERRUPT_NEGATIVE
    sta VIA_REGISTER_PCR + __VIA_START__

    ; init timer to one shot mode
    lda #0
    sta VIA_REGISTER_ACR + __VIA_START__
    rts

_enable_interrupts:
    cli
    rts

_disable_interrupts:
    sei
    rts

irq:
    jsr _interrupt
    bit VIA_REGISTER_PORTA + __VIA_START__ ; clear interrupt
    rti

nmi:
    rti
