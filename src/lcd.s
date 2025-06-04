; VIA variables
PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

; LCD bits
E  = %01000000
RW = %00100000
RS = %00010000

    .include "zeropage.inc"

    .code
    .export _lcd_init
_lcd_init:
    lda #%11111111 ; Set all pins on port B to output
    sta DDRB
    lda #%00000000 ; Set all pins on port A to input
    sta DDRA

    jsr lcd_init_start
    
    lda #%00101000 ; Set 4-bit mode; 2-line display; 5x8 font
    jsr _lcd_instruction
    lda #%00001110 ; Display on; cursor on; blink off
    jsr _lcd_instruction
    lda #%00000110 ; Increment and shift cursor; don't shift display
    jsr _lcd_instruction
    lda #%00000001 ; Clear display
    jsr _lcd_instruction
    rts

lcd_init_start:
    lda #%00000010 ; Set 4-bit mode
    sta PORTB
    ora #E
    sta PORTB
    and #%00001111
    sta PORTB

lcd_wait:
  pha
  lda #%11110000  ; LCD data is input
  sta DDRB
lcdbusy:
  lda #RW
  sta PORTB
  lda #(RW | E)
  sta PORTB
  lda PORTB       ; Read high nibble
  pha             ; and put on stack since it has the busy flag
  lda #RW
  sta PORTB
  lda #(RW | E)
  sta PORTB
  lda PORTB       ; Read low nibble
  pla             ; Get high nibble off stack
  and #%00001000
  bne lcdbusy

  lda #RW
  sta PORTB
  lda #%11111111  ; LCD data is output
  sta DDRB
  pla
  rts

    .export _lcd_instruction
_lcd_instruction:
    jsr lcd_wait
    pha
    lsr
    lsr
    lsr
    lsr            ; Send high 4 bits
    sta PORTB
    ora #E         ; Set E bit to send instruction
    sta PORTB
    eor #E         ; Clear E bit
    sta PORTB
    pla
    and #%00001111 ; Send low 4 bits
    sta PORTB
    ora #E         ; Set E bit to send instruction
    sta PORTB
    eor #E         ; Clear E bit
    sta PORTB
    rts

    .export _print_char
_print_char:
    jsr lcd_wait
    pha
    lsr
    lsr
    lsr
    lsr             ; Send high 4 bits
    ora #RS         ; Set RS
    sta PORTB
    ora #E          ; Set E bit to send instruction
    sta PORTB
    eor #E          ; Clear E bit
    sta PORTB
    pla
    and #%00001111  ; Send low 4 bits
    ora #RS         ; Set RS
    sta PORTB
    ora #E          ; Set E bit to send instruction
    sta PORTB
    eor #E          ; Clear E bit
    sta PORTB
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
