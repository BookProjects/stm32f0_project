# Define native test dependencies and variables

NTV_PATH := tests
_NTV_SRC := native_sw_test.c
NTV_SRC := $(patsubst %,$(NTV_PATH)/%,$(_NTV_SRC))
