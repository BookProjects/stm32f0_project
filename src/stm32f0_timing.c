#include "timing.h"
#include "stm32f0xx_rcc.h"

volatile static uint32_t delay_value;

void timing_delay(uint32_t ms) {
    delay_value = ms;
    while(delay_value);
}

void timing_systick_handler() {
    if(delay_value) {
        -- delay_value;
    }
}

void timing_configure_systick(uint32_t num_per_sec) {
    RCC_ClocksTypeDef clock_def;
    RCC_GetClocksFreq(&clock_def);
    SysTick_Config(clock_def.HCLK_Frequency / num_per_sec);
}
