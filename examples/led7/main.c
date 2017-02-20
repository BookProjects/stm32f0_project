#include "led7.h"
#include "timing.h"


int main (void)
{
  timing_configure_systick(1000); // ms
  led7_create();
  for(;;) {
    for(int i = 0; i <= 9; ++i) {
      led7_write_digit(i);
      timing_delay(500);
    }
  }
  return 0;
}
