#include "usart.h"
#include "std_utils.h"
#include "timing.h"
#include "stm32f0xx_tim.h"

/* Temporary debugging function to display register values of timer
 *
 * Observing Capture reg 2 getting the interrupt value
 *
 */
void debug_timer();

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
    /*
    uint32_t time_val = 0;
    timing_get_capture_val(&time_val);
    itoa(time_val, c_str);
    usart_send_string(c_str);
    usart_send_string("\r\n");
    */
    debug_timer();
  }
  return 0;

}

void debug_timer() {
  uint32_t counter = TIM_GetCounter(TIM2);
  uint32_t cc1 = TIM_GetCapture1(TIM2);
  uint32_t cc2 = TIM_GetCapture2(TIM2);
  uint32_t cc3 = TIM_GetCapture3(TIM2);
  uint32_t cc4 = TIM_GetCapture4(TIM2);
  uint32_t status = TIM2->SR;


  char c_str[15];
  itoa(counter, c_str);
  usart_send_string("counter: ");
  usart_send_string(c_str);
  usart_send_string("\r\n");

  itoa(cc1, c_str);
  usart_send_string("cc1: ");
  usart_send_string(c_str);
  usart_send_string("\r\n");

  itoa(cc2, c_str);
  usart_send_string("cc2: ");
  usart_send_string(c_str);
  usart_send_string("\r\n");

  itoa(cc3, c_str);
  usart_send_string("cc3: ");
  usart_send_string(c_str);
  usart_send_string("\r\n");

  itoa(cc4, c_str);
  usart_send_string("cc4: ");
  usart_send_string(c_str);
  usart_send_string("\r\n");

  itoa(status, c_str);
  usart_send_string("status reg: ");
  usart_send_string(c_str);
  usart_send_string("\r\n");
}
