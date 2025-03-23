#include <lcd.h>
#include <core.h>
#include <stdbool.h>

int counter = 0;
int clock = 30;

void int_to_str(u16 num, char buf[]);

void delay_ms(u16 ms) {
    while (ms > 65) {
        delay(65000); // delay for 65 ms which is what in microseconds
        // 65 ms * 1000 = 65000 us
        ms -= 65;
    }
    if (ms > 0)
        delay(ms * 1000);
}

char buffer[10];
bool is_started = false;
int main() {
    lcd_init();
    enable_interrupts();

    lcd_print("Press to start");
    while (!is_started); // wait for button to be pressed
    
    lcd_instruction(LCD_CLEAR);
    lcd_instruction(LCD_HOME);
    lcd_print("counter: 0");

    while (clock > 0) {
        lcd_instruction(LCD_NEXT_LINE);
        disable_interrupts();
        int_to_str(clock, buffer);
        lcd_print(buffer);
        enable_interrupts();

        delay_ms(1000);
        clock--;
    }

    disable_interrupts();

    lcd_instruction(LCD_CLEAR);
    lcd_instruction(LCD_HOME);
    lcd_print("Can you beat:");
    lcd_instruction(LCD_NEXT_LINE);
    int_to_str(counter, buffer);
    lcd_print(buffer);

    return 0;
}

void int_to_str(u16 num, char buf[]) {
    char temp[10]; // Temporary buffer for reversed digits
    int i = 0, j;

    // Convert number to string (reversed order)
    do {
        temp[i++] = (num % 10) + '0'; // Extract last digit and convert to ASCII
        num /= 10;
    } while (num > 0);
    
    // Reverse string into buf
    for (j = 0; j < i; j++) {
        buf[j] = temp[i - j - 1];
    }
    buf[i] = '\0'; // Null-terminate string
}

void interrupt() {
    if (!is_started) {
        is_started = true;
        return;
    }
    lcd_instruction(LCD_HOME); // cursor home
    counter++;
    
    int_to_str(counter, buffer);
    lcd_print("counter: ");
    lcd_print(buffer);
}
