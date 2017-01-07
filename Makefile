# Makefile for compiling executables onto the stm32f0
#
#Verbosity flags (Q=quiet, E=echo)
ifdef VERBOSE
	Q =
	E = @echo
else
	Q = @
	E = @echo 
endif


# Define library paths
STMFW_PATH := third_party/STM32F0-Discovery_FW_V1.0.0
STMLIB_PATH := $(STMFW_PATH)/Libraries
STMPROJ_PATH := $(STMFW_PATH)/Project
STMUTILS_PATH := $(STMFW_PATH)/Utilities

DRIVER_PATH := $(STMLIB_PATH)/STM32F0xx_StdPeriph_Driver
DEMO_PATH := $(STMPROJ_PATH)/Demonstration

CMSIS_PATH := $(STMLIB_PATH)/CMSIS

# Define result paths
BUILD_PATH := bin
OBJ_PATH := $(BUILD_PATH)/obj

# Define files that will get compiled
STARTUP := $(CMSIS_PATH)/ST/STM32F0xx/Source/Templates/gcc_ride7/startup_stm32f0xx.s
LINKER_SCRIPT := $(DEMO_PATH)/TrueSTUDIO/STM32F0-Discovery_Demo/stm32_flash.ld

# Change to change example
SRC_PATH := $(DEMO_PATH)
_SRC := system_stm32f0xx.c \
		main.c \
		stm32f0xx_it.c
SRC := $(patsubst %,$(SRC_PATH)/%,$(_SRC))
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

_OBJ := $(_SRC:.c=.o)
OBJ := $(patsubst %,$(OBJ_PATH)/%,$(_OBJ))
_DRIVER_OBJ := $(_DRIVER_SRC:.c=.o)
DRIVER_OBJ := $(patsubst %,$(OBJ_PATH)/%,$(_DRIVER_OBJ))
_DISC_OBJ := $(_DISC_SRC:.c=.o)
DISC_OBJ := $(patsubst %,$(OBJ_PATH)/%,$(_DISC_OBJ))
_CROSS_OBJ := $(STARTUP:.s=.o)
CROSS_OBJ := $(patsubst %,$(OBJ_PATH)/%,$(_CROSS_OBJ))

# Define files to get compiled
CROSS_TARGET := $(BUILD_PATH)/hw_binary.bin
CROSS_HEX := $(CROSS_TARGET:.bin=.hex)
CROSS_ELF := $(CROSS_TARGET:.bin=.elf)

MAP_FILE := $(BUILD_PATH)/mapfile.map

# Cross compile commands
CC_TYPE:=arm-none-eabi
CC_PREFIX:=$(CC_PATH)/$(CC_TYPE)
CROSS_COMPILE:=$(CC_PREFIX)-gcc
CROSS_LINK:=$(CROSS_COMPILE)
GDBTUI = $(CC_PREFIX)-gdb
ASSEMBLE:=$(CROSS_COMPILE) -x assembler-with-cpp
OBJCOPY:=$(CC_PREFIX)-objcopy
HEX:=$(OBJCOPY) -O ihex
BIN:=$(OBJCOPY) -O binary -S

# Define compiler options
DEFS:= $(DDEFS) -DRUN_FROM_FLASH=1
MCU:=cortex-m0
MCFLAGS:= -mcpu=$(MCU)
OPT =  # -Os

BASE_CROSS_FLAGS := $(MCFLAGS) \
	-g \
	-gdwarf-2 \
	-mthumb

# arm headers
# stm32f0xx headers
# Discovery specific header
# peripheral headers
CFLAGS := -c \
	-std=c99 \
	-Wall \
	-I$(SRC_PATH) \
	-I$(CMSIS_PATH)/Include \
	-I$(CMSIS_PATH)/ST/STM32F0xx/Include \
	-I$(STMUTILS_PATH)/STM32F0-Discovery \
	-I$(DRIVER_PATH)/inc \
	$(BASE_CROSS_FLAGS) \
	-fomit-frame-pointer \
	-Wa,-amhls=$(<:.c=.lst) $(DEFS) $(OPT)
ARFLAGS := r

LDFLAGS := $(BASE_CROSS_FLAGS) -nostartfiles -T$(LINKER_SCRIPT) -Wl,-Map=$(MAP_FILE),--cref,--no-warn-mismatch

ASSEMBLER_FLAGS:= $(BASE_CROSS_FLAGS) -Wa,-amhls=$(<:.s=.lst)

# Make commands
.PHONY: all
all: $(CROSS_TARGET)

.PHONY: clean
clean:
	rm -rf $(BUILD_PATH)

# $^ is shorthand for all of the dependencies
# $@ is shorthand for the target
$(OBJ_PATH)/%.o: $(SRC_PATH)/%.c
	$(E)C Cross Compiling $< to $@
	$(Q)mkdir -p `dirname $@`
	$(CROSS_COMPILE) -o $@ $< $(CFLAGS)

$(OBJ_PATH)/%.o: $(DRIVER_PATH)/src/%.c
	$(E)C Cross Compiling $< to $@
	$(Q)mkdir -p `dirname $@`
	$(CROSS_COMPILE) -o $@ $< $(CFLAGS)

$(OBJ_PATH)/%.o: $(STMUTILS_PATH)/STM32F0-Discovery/%.c
	$(E)C Cross Compiling $< to $@
	$(Q)mkdir -p `dirname $@`
	$(CROSS_COMPILE) -o $@ $< $(CFLAGS)

$(OBJ_PATH)/%.o: %.s
	$(E)Assembling $< to $@
	$(Q)mkdir -p `dirname $@`
	$(ASSEMBLE) -c $(ASSEMBLER_FLAGS) $< -o $@

$(CROSS_TARGET): $(CROSS_ELF)
	$(E)"Building" $@
	$(Q)$(BIN) $< $@

$(CROSS_HEX): $(CROSS_ELF)
	$(E)"Building" $@
	$(Q)$(HEX) $< $@

$(CROSS_ELF): $(OBJ) $(DRIVER_OBJ) $(DISC_OBJ) $(CROSS_OBJ)
	$(E)"Linking" $@
	$(Q)$(CROSS_LINK) $(LDFLAGS) -o $@ $^
