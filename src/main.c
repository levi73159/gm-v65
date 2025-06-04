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
    disable_interrupts();
    lcd_init();

    lcd_print("GM-65");

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
    counter++;
}
