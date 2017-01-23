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

char usart_block_receive_char();
void usart_send_char(char c);
void usart_send_string(const char *c_str);
