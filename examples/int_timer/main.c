#include "usart.h"
#include "std_utils.h"
#include "timing.h"
#include "stm32f0xx_tim.h"


int main (void)
{
  usart_create();
  usart_configure(9600);
  // ms base
  timing_configure_systick(1000);
  /*
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
  */
  timing_configure_input_capture();
  usart_send_string("starting capture");
  char c_str[15];
  for(;;) {
    uint32_t time_val = timing_get_capture_val();
    itoa(time_val, c_str);
    usart_send_string(c_str);
    usart_send_string("\r\n");
  }
  return 0;
}
