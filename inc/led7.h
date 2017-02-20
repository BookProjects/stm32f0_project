#ifndef __LED7_H
#define __LED7_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

void led7_create();
void led7_destroy();

void led7_write_digit(uint8_t digit);

#ifdef __cplusplus
}
#endif

#endif  // __LED7_H
