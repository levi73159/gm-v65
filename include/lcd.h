#ifndef LCD_H
#define LCD_H

#define LCD_CLEAR 0x01
#define LCD_HOME 0x02
#define LCD_NEXT_LINE 0xC0

extern void lcd_init(void);
extern void lcd_instruction(const unsigned char instruction);
extern void print_char(const char c);
extern void lcd_print(const char string[]);

#endif
