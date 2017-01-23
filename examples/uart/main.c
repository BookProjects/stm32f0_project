#include "usart.h"
#include "std_utils.h"

int main (void)
{
  usart_create();
  usart_configure(9600);
  uint16_t val;
  while(1)
  {
    val = usart_block_receive_char();
    usart_send_char(val + 1);
  }
  usart_destroy();
  return 0;
}
