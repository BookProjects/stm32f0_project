# Define library paths
STMFW_PATH := third_party/STM32F0-Discovery_FW_V1.0.0
STMLIB_PATH := $(STMFW_PATH)/Libraries
STMPROJ_PATH := $(STMFW_PATH)/Project
STMUTILS_PATH := $(STMFW_PATH)/Utilities

DRIVER_PATH := $(STMLIB_PATH)/STM32F0xx_StdPeriph_Driver
DEMO_PATH := $(STMPROJ_PATH)/Demonstration
PERIPH_EX_PATH := $(STMPROJ_PATH)/Peripheral_Examples

CMSIS_PATH := $(STMLIB_PATH)/CMSIS

# Define files that will get compiled
STARTUP := $(CMSIS_PATH)/ST/STM32F0xx/Source/Templates/gcc_ride7/startup_stm32f0xx.s
LINKER_SCRIPT := $(DEMO_PATH)/TrueSTUDIO/STM32F0-Discovery_Demo/stm32_flash.ld

_DRIVER_SRC := stm32f0xx_adc.c \
	stm32f0xx_cec.c \
	stm32f0xx_comp.c \
	stm32f0xx_crc.c \
	stm32f0xx_dac.c \
	stm32f0xx_dbgmcu.c \
	stm32f0xx_dma.c \
	stm32f0xx_exti.c \
	stm32f0xx_flash.c \
	stm32f0xx_gpio.c \
	stm32f0xx_i2c.c \
	stm32f0xx_iwdg.c \
	stm32f0xx_misc.c \
	stm32f0xx_pwr.c \
	stm32f0xx_rcc.c \
	stm32f0xx_rtc.c \
	stm32f0xx_spi.c \
	stm32f0xx_syscfg.c \
	stm32f0xx_tim.c \
	stm32f0xx_usart.c \
	stm32f0xx_wwdg.c
DRIVER_SRC := $(patsubst %,$(DRIVER_PATH)/src/%,$(_DRIVER_SRC))

_DISC_SRC := stm32f0_discovery.c
DISC_SRC := $(patsubst %,$(STMUTILS_PATH)/STM32F0-Discovery/%,$(_DISC_SRC))


# Externally used variables

MCU_CFLAGS := -I$(CMSIS_PATH)/Include \
	-I$(CMSIS_PATH)/ST/STM32F0xx/Include \
	-I$(STMUTILS_PATH)/STM32F0-Discovery \
	-I$(DRIVER_PATH)/inc \

MCU_LDFLAGS := -nostartfiles \
	-T$(LINKER_SCRIPT)

MCU_SRC := $(DRIVER_SRC) $(DISC_SRC)
