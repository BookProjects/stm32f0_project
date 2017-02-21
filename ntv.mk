# Requires env-vars: UNITY_SOURCE, CMOCK_SOURCE

# Define native test dependencies and variables

TEST_PATH := tests
_TEST_SRC := native_sw_test.c \
	test_basic.c
TEST_SRC := $(patsubst %,$(TEST_PATH)/%,$(_TEST_SRC))

UNITY_PATH := $(UNITY_SOURCE)
_UNITY_SRC := src/unity.c \
	extras/fixture/src/unity_fixture.c
UNITY_SRC := $(patsubst %,$(UNITY_PATH)/%,$(_UNITY_SRC))

CMOCK_PATH := $(CMOCK_SOURCE)
_CMOCK_SRC := src/cmock.c
CMOCK_SRC := $(patsubst %,$(CMOCK_PATH)/%,$(_CMOCK_SRC))

NTV_SRC := $(TEST_SRC) $(CMOCK_SRC) $(UNITY_SRC)
NTV_CPPFLAGS := -I$(UNITY_PATH)/src \
	-I$(UNITY_PATH)/extras/fixture/src \
	-I$(CMOCK_PATH)/src
