#ifndef CORE_H
#define CORE_H

typedef unsigned char u8;
typedef unsigned int u16;
typedef unsigned long u32;

// FROM FILE: src/interrupts.h
// it fitting to put this in here instead of a new file because we only have two functions
extern void enable_interrupts();
extern void disable_interrupts();

// FROM FILE: src/core.s
extern void delay(u16 microseconds);

#endif
