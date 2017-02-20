#include "stm32f0xx_gpio.h"

static const uint8_t led7_number_mapping [] = {
    [0] = 0x88,
    [1] = 0xEB,
    [2] = 0x4C,
    [3] = 0x49,
    [4] = 0x2B,
    [5] = 0x19,
    [6] = 0x18,
    [7] = 0xCB,
    [8] = 0x08,
    [9] = 0x0B,
};

void led7_create() {
  RCC_AHBPeriphClockCmd(RCC_AHBPeriph_GPIOB, ENABLE);
  GPIO_InitTypeDef gpio_init_struct = {
    .GPIO_Pin   = 0xFF, // First 8 bits
    .GPIO_Mode  = GPIO_Mode_OUT,
    .GPIO_OType = GPIO_OType_PP,
    .GPIO_PuPd  = GPIO_PuPd_UP
  };
  GPIO_Init(GPIOB, &gpio_init_struct);
}

void led7_destroy() {
}

void led7_write_digit(uint8_t digit) {
  assert_param(digit <= 9);
  GPIO_Write(GPIOB, led7_number_mapping[digit]);
}
