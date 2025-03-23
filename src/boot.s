    .setcpu "65C02"

    .export __STARTUP__ : absolute = 1

    ; c import
    .import _main
    .import nmi, irq, irq_init
    .import __RAM_START__, __RAM_SIZE__       ; Linker generated
    .import copydata, zerobss ;

    .include "zeropage.inc"

    ; assembly import
    .segment "VECTORS"
    .word nmi
    .word init
    .word irq
    
    .segment "STARTUP"
init:
    cld
    ldx #$ff
    txs

    lda #<(__RAM_START__ + __RAM_SIZE__)
    sta sp
    lda #>(__RAM_START__ + __RAM_SIZE__)
    sta sp+1

    jsr zerobss
    jsr copydata

    jsr irq_init
    jsr _main

; Infinite loop
loop:
    jmp loop
