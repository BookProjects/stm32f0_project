#include "timing.h"
#include "stm32f0xx_rcc.h"
#include "stm32f0xx_tim.h"

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


void timing_configure_input_capture() {
	// Enable clocks
	RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM2, ENABLE);
	RCC_AHBPeriphClockCmd(RCC_AHBPeriph_GPIOA, ENABLE);

	// Input config
	// TIM2_CH2 = A1 or B3
	GPIO_InitTypeDef gpio_init_struct = {
		.GPIO_Pin   = GPIO_Pin_1,
		.GPIO_Mode  = GPIO_Mode_AF,
		.GPIO_OType = GPIO_OType_PP,
		.GPIO_PuPd  = GPIO_PuPd_UP
	};
	GPIO_Init(GPIOA, &gpio_init_struct);
	GPIO_PinAFConfig(GPIOA, GPIO_PinSource1, GPIO_AF_2);

	// Timing config
	// Configure it to count slowly
	RCC_ClocksTypeDef clock_def;
	RCC_GetClocksFreq(&clock_def);
	TIM_TimeBaseInitTypeDef tim_base_struct = {
		.TIM_Period = 0xFFFF,
		.TIM_Prescaler = 5 * (clock_def.HCLK_Frequency / 0xFFFF),
		.TIM_ClockDivision = TIM_CKD_DIV1,
		.TIM_CounterMode = TIM_CounterMode_Up,
		.TIM_RepetitionCounter = 0x0
	};
	TIM_TimeBaseInit(TIM2, &tim_base_struct);
	TIM_ICInitTypeDef  tim_ic_init_struct = {
		.TIM_Channel     = TIM_Channel_2,
		.TIM_ICPolarity  = TIM_ICPolarity_Rising,
		.TIM_ICSelection = TIM_ICSelection_DirectTI,
		.TIM_ICFilter    = 0x0
	};
	TIM_ICInit(TIM2, &tim_ic_init_struct);
	TIM_SelectInputTrigger(TIM2, TIM_TS_TI2FP2);
	// Restart the counter when it triggers
	TIM_SelectSlaveMode(TIM2, TIM_SlaveMode_Reset);
	// Master mode
	TIM_SelectMasterSlaveMode(TIM2, TIM_MasterSlaveMode_Enable);
	TIM_Cmd(TIM2, ENABLE);
}

uint32_t timing_get_capture_val() {
	// Wait for flag
	while(TIM_GetFlagStatus(TIM2, TIM_FLAG_CC2) == RESET);
	return TIM_GetCapture2(TIM2);
}
