# Define cross-target dependencies and variables

# Main target
# Change path to change example
SRC_PATH := examples/led7
_TARGET_SRC := main.c
TARGET_SRC := $(patsubst %,$(SRC_PATH)/%,$(_TARGET_SRC))

# Modules
BASE_PATH := src
BASE_INC_PATH := inc
_BASE_SRC := stm32f0_usart.c \
			 std_utils.c \
			 stm32f0_timing.c \
			 stm32f0_led7.c
BASE_SRC := $(patsubst %,$(BASE_PATH)/%,$(_BASE_SRC))

# Board Configuration
CONFIG_PATH := system_configuration/stm32f0xx
_CONFIG_SRC := system_stm32f0xx.c \
	stm32f0xx_it.c
CONFIG_SRC := $(patsubst %,$(CONFIG_PATH)/%,$(_CONFIG_SRC))

# External variables
HW_SRC := $(TARGET_SRC) $(BASE_SRC) $(CONFIG_SRC) $(MCU_SRC)

HW_CPPFLAGS := -I$(SRC_PATH) \
	-I$(CONFIG_PATH) \
	-I$(BASE_INC_PATH)
