
#include "stm32f0xx.h"
#include "stm32f0_discovery.h"


void usart_create();
void usart_destroy();

// Future:
// * HW flow control
// * optional RX/TX selection
// * word_length
// * stop bits
// * parity
void usart_configure(uint32_t baud_rate);

uint8_t usart_block_receive_char();
void usart_transmit_char(uint8_t c);
