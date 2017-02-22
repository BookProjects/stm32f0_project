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
BUILD_DIR := build

# Define cross compiler variables
CROSS_COMPILER_SRC := gcc-arm-none-eabi-5_4-2016q3
CROSS_COMPILER_BASE := $(CROSS_COMPILER_SRC)-20160926-linux
CROSS_COMPILER_TAR := $(CROSS_COMPILER_BASE).tar.bz2
CROSS_COMPILER_URL := "https://launchpad.net/gcc-arm-embedded/5.0/5-2016-q3-update/+download/$(CROSS_COMPILER_TAR)"
CROSS_COMPILER_TAR_BUILD := $(BUILD_DIR)/$(CROSS_COMPILER_TAR)
CROSS_COMPILER_SRC_BUILD := $(BUILD_DIR)/$(CROSS_COMPILER_SRC)
CC_PATH := $(CROSS_COMPILER_SRC_BUILD)/bin



# Define dependencies and targets

# Define native test dependencies and variables
include ntv.mk
# Note using .native.o to separate from mcu compiled object files
_NTV_OBJ := $(NTV_SRC:.c=.native.o)
NTV_OBJ := $(patsubst %,$(OBJ_PATH)/%,$(_NTV_OBJ))

NTV_TEST_TARGET := $(BUILD_PATH)/test_natively

# Define cross-compiled dependencies and variables
include hw.mk

_HW_OBJ := $(HW_SRC:.c=.o)
_HW_OBJ += $(MCU_STARTUP:.s=.o)
HW_OBJ := $(patsubst %,$(OBJ_PATH)/%,$(_HW_OBJ))

# Define cross-compiled targets
CROSS_TARGET := $(BUILD_PATH)/hw_binary.bin
CROSS_HEX := $(CROSS_TARGET:.bin=.hex)
CROSS_ELF := $(CROSS_TARGET:.bin=.elf)

MAP_FILE := $(BUILD_PATH)/mapfile.map

# Define commands necessary for creating targets

# Native commands
NTV_CC:=gcc
NTV_LD:=$(NTV_CC)

# Cross compile commands
CC_TYPE:=arm-none-eabi
# CC_PATH must be defined in environment!
CC_PREFIX:=$(CC_PATH)/$(CC_TYPE)

HW_CC:=$(CC_PREFIX)-gcc
GDBTUI = $(CC_PREFIX)-gdb
OBJCOPY:=$(CC_PREFIX)-objcopy
HEX:=$(OBJCOPY) -O ihex
BIN:=$(OBJCOPY) -O binary -S


HW_LD:=$(HW_CC)
HW_AS:=$(HW_CC) -x assembler-with-cpp

# Define compiler options
OPT =  # -Os

DEBUG_FLAGS := -g \
	-gdwarf-2

BASE_CFLAGS := -std=c99 \
	-Wall \
	$(DDEFS) $(OPT)

ARFLAGS := r

# Define native options
NTV_CFLAGS := $(BASE_CFLAGS) \
	$(NTV_CPPFLAGS) \
	$(DEBUG_FLAGS)
NTV_LDFLAGS := $(DEBUG_FLAGS)

# Define cross-compiler options
HW_ASFLAGS := $(DEBUG_FLAGS) $(MCU_ASFLAGS)
HW_CFLAGS := $(BASE_CFLAGS) \
	$(HW_CPPFLAGS) \
	$(MCU_CFLAGS) \
	$(DEBUG_FLAGS)
HW_LDFLAGS := $(DEBUG_FLAGS) \
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
	HW_CFLAGS += -Wa,-amhls=$(<:.c=.lst)
	HW_ASFLAGS += -Wa,-amhls=$(<:.s=.lst)
	NTV_CFLAGS += -Wa,-amhls=$(<:.c=.lst)
	NTV_ASFLAGS += -Wa,-amhls=$(<:.s=.lst)
endif

# Make commands
.PHONY: all
all: hw_setup $(CROSS_TARGET)

.PHONY: help
help:
	$(E)
	$(E)"all:    Create the hw binary $(CROSS_TARGET)"
	$(E)"test:   Create a native test binary and run it"
	$(E)"flash:  Flash the hw binary to the chip"
	$(E)"erase:  Erase the flash data on the chip (useful for getting out of error state)"
	$(E)"debug:  Run gdb remotely on the chip"
	$(E)"serial: Open up a serial communication (must setup hardware appropriately)"
	$(E)"clean:  Remove any files created by this Makefile"
	$(E)

.PHONY: test
test: $(NTV_TEST_TARGET)
	./$(NTV_TEST_TARGET)

.PHONY: hw_setup
hw_setup: $(CROSS_COMPILER_SRC_BUILD)

$(CROSS_COMPILER_SRC_BUILD): $(CROSS_COMPILER_TAR_BUILD)
	cd $(BUILD_DIR) && tar -xjf $(CROSS_COMPILER_TAR)

$(CROSS_COMPILER_TAR_BUILD): $(BUILD_DIR)
	wget $(CROSS_COMPILER_URL) -O $(CROSS_COMPILER_TAR_BUILD)
	# cp ../$(CROSS_COMPILER_TAR) $(CROSS_COMPILER_TAR_BUILD)

$(BUILD_DIR):
	$(Q)mkdir -p $@

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
	$(E)$(notdir $(NTV_CC)) compiling $(notdir $<) to $@
	$(Q)mkdir -p `dirname $@`
	$(Q)$(NTV_CC) -o $@ $< $(NTV_CFLAGS) -c

$(OBJ_PATH)/%.o: %.c
	$(E)$(notdir $(HW_CC)) compiling $(notdir $<) to $@
	$(Q)mkdir -p `dirname $@`
	$(Q)$(HW_CC) -o $@ $< $(HW_CFLAGS) -c

$(OBJ_PATH)/%.o: %.s
	$(E)$(notdir $(AS)) assembling $(notdir $<) to $@
	$(Q)mkdir -p `dirname $@`
	$(Q)$(HW_AS) -c $(HW_ASFLAGS) $< -o $@

$(CROSS_TARGET): $(CROSS_ELF)
	$(E)Building $@
	$(Q)$(BIN) $< $@

$(CROSS_HEX): $(CROSS_ELF)
	$(E)Building $@
	$(Q)$(HEX) $< $@

$(CROSS_ELF): $(HW_OBJ)
	$(E)$(notdir $(HW_LD)) linking $@
	$(Q)$(HW_LD) $(HW_LDFLAGS) -o $@ $^

$(NTV_TEST_TARGET): $(NTV_OBJ)
	$(E)$(notdir $(NTV_LD)) linking $@
	$(Q)$(NTV_LD) $(NTV_LDFLAGS) -o $@ $^
