#include "usart.h"
#include "std_utils.h"
#include "timing.h"

int main (void)
{
  usart_create();
  usart_configure(9600);
  // ms base
  timing_configure_systick(1000);
  uint32_t base = 0;
  while(1)
  {
    timing_delay(base);
    usart_send_char('a');
    if(base >= 100) {
        base = 0;
    } else {
        base += 10;
    }
  }
  usart_destroy();
  return 0;
}
