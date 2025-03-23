; VIA variables
PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

; LCD bits
E  = %10000000
RW = %01000000
RS = %00100000

    .include "zeropage.inc"

    .code
    .export _lcd_init
_lcd_init:
    lda #%11111111 ; Set all pins on port B to output
    sta DDRB
    lda #%11100000 ; Set top 3 pins on port A to output
    sta DDRA

    lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
    jsr _lcd_instruction
    lda #%00001110 ; Display on; cursor on; blink off
    jsr _lcd_instruction
    lda #%00000110 ; Increment and shift cursor; don't shift display
    jsr _lcd_instruction
    lda #%00000001 ; Clear display
    jsr _lcd_instruction
    rts



lcd_wait:
  pha
  lda #%00000000  ; Port B is input
  sta DDRB
lcdbusy:
  lda #RW
  sta PORTA
  lda #(RW | E)
  sta PORTA
  lda PORTB
  and #%10000000
  bne lcdbusy

  lda #RW
  sta PORTA
  lda #%11111111  ; Port B is output
  sta DDRB
  pla
  rts

    .export _lcd_instruction
_lcd_instruction:
    jsr lcd_wait
    sta PORTB
    lda #0         ; Clear RS/RW/E bits
    sta PORTA
    lda #E         ; Set E bit to send instruction
    sta PORTA
    lda #0         ; Clear RS/RW/E bits
    sta PORTA
    rts

    .export _print_char
_print_char:
    jsr lcd_wait
    sta PORTB
    lda #RS         ; Set RS; Clear RW/E bits
    sta PORTA
    lda #(RS | E)   ; Set E bit to send instruction
    sta PORTA
    lda #RS         ; Clear E bits
    sta PORTA
    rts

    .export _lcd_print
_lcd_print:
        sta ptr1
        stx ptr1+1
        ; store registers A and Y
        phy
        ldy #$00
@lcd_print_loop:
        ; Read next byte of init sequence data
        lda (ptr1),y
        ; Exit loop if $00 read
        beq @lcd_print_end
        ; Set carry for data operation
        jsr _print_char
        iny
        ; Next character
        bra @lcd_print_loop
@lcd_print_end:
        ply
        rts
