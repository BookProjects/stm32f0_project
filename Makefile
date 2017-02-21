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


# Define dependencies and variables

# Define native test dependencies and variables
NATIVE_TEST_PATH := tests
_NATIVE_TEST_SRC := native_sw_test.c
NATIVE_TEST_SRC := $(patsubst %,$(NATIVE_TEST_PATH)/%,$(_NATIVE_TEST_SRC))

# Note using .native.o to separate from mcu compiled object files
_NATIVE_TEST_OBJ := $(NATIVE_TEST_SRC:.c=.native.o)
NATIVE_TEST_OBJ := $(patsubst %,$(OBJ_PATH)/%,$(_NATIVE_TEST_OBJ))


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

SRC := $(TARGET_SRC) $(BASE_SRC) $(CONFIG_SRC) $(MCU_SRC)

_OBJ := $(SRC:.c=.o)
_OBJ += $(STARTUP:.s=.o)
OBJ := $(patsubst %,$(OBJ_PATH)/%,$(_OBJ))

# Define targets

# Define native targets
NATIVE_TEST_TARGET := $(BUILD_PATH)/test_natively

# Define Cross compiled targets
CROSS_TARGET := $(BUILD_PATH)/hw_binary.bin
CROSS_HEX := $(CROSS_TARGET:.bin=.hex)
CROSS_ELF := $(CROSS_TARGET:.bin=.elf)

MAP_FILE := $(BUILD_PATH)/mapfile.map

# Define commands necessary for creating targets

# Native commands
NATIVE_CC:=gcc
NATIVE_LD:=$(NATIVE_CC)

# Cross compile commands
CC_TYPE:=arm-none-eabi
# CC_PATH must be defined in environment!
CC_PREFIX:=$(CC_PATH)/$(CC_TYPE)

CC:=$(CC_PREFIX)-gcc
GDBTUI = $(CC_PREFIX)-gdb
OBJCOPY:=$(CC_PREFIX)-objcopy
HEX:=$(OBJCOPY) -O ihex
BIN:=$(OBJCOPY) -O binary -S


LD:=$(CC)
AS:=$(CC) -x assembler-with-cpp

# Define compiler options
OPT =  # -Os

DEBUG_FLAGS := -g \
	-gdwarf-2

BASE_CFLAGS := -std=c99 \
	-Wall \
	$(DDEFS) $(OPT)

ARFLAGS := r

# Define native options
NATIVE_CFLAGS := $(BASE_CFLAGS) \
	$(DEBUG_FLAGS)
NATIVE_LDFLAGS := $(DEBUG_FLAGS)

# Define cross-compiler options
ASFLAGS := $(DEBUG_FLAGS) $(MCU_ASFLAGS)
CFLAGS := $(BASE_CFLAGS) \
	-I$(SRC_PATH) \
	-I$(CONFIG_PATH) \
	-I$(BASE_INC_PATH) \
	$(MCU_CFLAGS) \
	$(DEBUG_FLAGS)
LDFLAGS := $(DEBUG_FLAGS) \
	$(MCU_LDFLAGS) \
	-Wl,-Map=$(MAP_FILE),--cref,--no-warn-mismatch

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
	ASFLAGS += -Wa,-amhls=$(<:.s=.lst)
endif

# Make commands
.PHONY: all
all: $(CROSS_TARGET)

.PHONY: test
test: $(NATIVE_TEST_TARGET)
	./$(NATIVE_TEST_TARGET)

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


# Create all of the objects

# $^ is shorthand for all of the dependencies
# $< is shorthand for the first dependency
# $@ is shorthand for the target
$(OBJ_PATH)/%.native.o: %.c
	$(E)$(notdir $(NATIVE_CC)) compiling $(notdir $<) to $@
	$(Q)mkdir -p `dirname $@`
	$(Q)$(NATIVE_CC) -o $@ $< $(NATIVE_CFLAGS) -c

$(OBJ_PATH)/%.o: %.c
	$(E)$(notdir $(CC)) compiling $(notdir $<) to $@
	$(Q)mkdir -p `dirname $@`
	$(Q)$(CC) -o $@ $< $(CFLAGS) -c

$(OBJ_PATH)/%.o: %.s
	$(E)$(notdir $(AS)) assembling $(notdir $<) to $@
	$(Q)mkdir -p `dirname $@`
	$(Q)$(AS) -c $(ASFLAGS) $< -o $@

$(CROSS_TARGET): $(CROSS_ELF)
	$(E)Building $@
	$(Q)$(BIN) $< $@

$(CROSS_HEX): $(CROSS_ELF)
	$(E)Building $@
	$(Q)$(HEX) $< $@

$(CROSS_ELF): $(OBJ)
	$(E)$(notdir $(LD)) linking $@
	$(Q)$(LD) $(LDFLAGS) -o $@ $^

$(NATIVE_TEST_TARGET): $(NATIVE_TEST_OBJ)
	$(E)$(notdir $(NATIVE_LD)) linking $@
	$(Q)$(NATIVE_LD) $(NATIVE_LDFLAGS) -o $@ $^
