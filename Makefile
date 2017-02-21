# Makefile for compiling executables onto the stm32f0
#
#Verbosity flags (Q=quiet, E=echo)
E = @echo 
ifdef VERBOSE
	Q =
else
	Q = @
endif

include mcu.mk

# Define result paths
BUILD_PATH := bin
OBJ_PATH := $(BUILD_PATH)/obj


CONFIG_PATH := system_configuration/stm32f0xx
_CONFIG_SRC := system_stm32f0xx.c \
	stm32f0xx_it.c
CONFIG_SRC := $(patsubst %,$(CONFIG_PATH)/%,$(_CONFIG_SRC))

# Change path to change example
SRC_PATH := examples/led7
_TARGET_SRC := main.c
TARGET_SRC := $(patsubst %,$(SRC_PATH)/%,$(_TARGET_SRC))


BASE_PATH := src
BASE_INC_PATH := inc
_BASE_SRC := stm32f0_usart.c \
			 std_utils.c \
			 stm32f0_timing.c \
			 stm32f0_led7.c
BASE_SRC := $(patsubst %,$(BASE_PATH)/%,$(_BASE_SRC))

SRC := $(TARGET_SRC) $(CONFIG_SRC) $(DRIVER_SRC) $(DISC_SRC) $(BASE_SRC)

_OBJ := $(SRC:.c=.o)
_OBJ += $(STARTUP:.s=.o)
OBJ := $(patsubst %,$(OBJ_PATH)/%,$(_OBJ))

# Define files to get compiled
CROSS_TARGET := $(BUILD_PATH)/hw_binary.bin
CROSS_HEX := $(CROSS_TARGET:.bin=.hex)
CROSS_ELF := $(CROSS_TARGET:.bin=.elf)

MAP_FILE := $(BUILD_PATH)/mapfile.map


# Make commands
.PHONY: all
all: $(CROSS_TARGET)

.PHONY: help
help:
	$(E)
	$(E)"all:    Create the hw binary $(CROSS_TARGET)"
	$(E)"flash:  Flash the hw binary to the chip"
	$(E)"erase:  Erase the flash data on the chip (useful for getting out of error state)"
	$(E)"debug:  Run gdb remotely on the chip"
	$(E)"serial: Open up a serial communication (must setup hardware appropriately)"
	$(E)"clean:  Remove any files created by this Makefile"
	$(E)

.PHONY: flash
flash: $(CROSS_TARGET)
	st-flash write $(CROSS_TARGET) 0x8000000

.PHONY: erase
erase:
	st-flash erase

.PHONY: debug
debug: $(CROSS_ELF)
	xterm -e st-util &
	$(GDBTUI) --eval-command="target remote localhost:4242"  $(CROSS_ELF) -ex 'load'

# Open up a serial connection
.PHONY: serial
serial:
	minicom -c on

.PHONY: clean
clean:
	rm -rf $(BUILD_PATH)

# Cross compile commands
CC_TYPE:=arm-none-eabi
CC_PREFIX:=$(CC_PATH)/$(CC_TYPE)
CC:=$(CC_PREFIX)-gcc
LD:=$(CC)
GDBTUI = $(CC_PREFIX)-gdb
ASSEMBLE:=$(CC) -x assembler-with-cpp
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
	-I$(CONFIG_PATH) \
	-I$(BASE_INC_PATH) \
	$(MCU_CFLAGS) \
	$(BASE_CROSS_FLAGS) \
	-fomit-frame-pointer \
	$(DEFS) $(OPT)
ARFLAGS := r
LDFLAGS := $(BASE_CROSS_FLAGS) \
	$(MCU_LDFLAGS) \
	-Wl,-Map=$(MAP_FILE),--cref,--no-warn-mismatch
ASSEMBLER_FLAGS := $(BASE_CROSS_FLAGS)
# Optionally turn on listings
# -Wa passes comma separated list of arguments onto assembler
#  -a (turns on listings)
#  m: include macro expansions
#  h: include high-level source
#  l: include assembly
#  s: include symbols
#  =: list to file
ifdef VERBOSE
	CFLAGS += -Wa,-amhls=$(<:.c=.lst)
	ASSEMBLER_FLAGS += -Wa,-amhls=$(<:.s=.lst)
endif

# Create all of the objects

# $^ is shorthand for all of the dependencies
# $< is shorthand for the first dependency
# $@ is shorthand for the target
$(OBJ_PATH)/%.o: %.c
	$(E)C Cross Compiling $< to $@
	$(Q)mkdir -p `dirname $@`
	$(Q)$(CC) -o $@ $< $(CFLAGS)

$(OBJ_PATH)/%.o: %.s
	$(E)Assembling $< to $@
	$(Q)mkdir -p `dirname $@`
	$(Q)$(ASSEMBLE) -c $(ASSEMBLER_FLAGS) $< -o $@

$(CROSS_TARGET): $(CROSS_ELF)
	$(E)"Building" $@
	$(Q)$(BIN) $< $@

$(CROSS_HEX): $(CROSS_ELF)
	$(E)"Building" $@
	$(Q)$(HEX) $< $@

$(CROSS_ELF): $(OBJ)
	$(E)"Linking" $@
	$(Q)$(LD) $(LDFLAGS) -o $@ $^
