# Requires
# * env-vars: UNITY_SOURCE, CMOCK_SOURCE

# Define native test dependencies and variables

TEST_PATH := tests
_TEST_SRC := native_sw_test.c \
	test_stdutils.c
TEST_SRC := $(patsubst %,$(TEST_PATH)/%,$(_TEST_SRC))

BASE_PATH := src
BASE_INC_PATH := inc
_BASE_SRC := std_utils.c
BASE_SRC := $(patsubst %,$(BASE_PATH)/%,$(_BASE_SRC))


UNITY_PATH := $(UNITY_SOURCE)
_UNITY_SRC := src/unity.c \
	extras/fixture/src/unity_fixture.c
UNITY_SRC := $(patsubst %,$(UNITY_PATH)/%,$(_UNITY_SRC))

CMOCK_PATH := $(CMOCK_SOURCE)
_CMOCK_SRC := src/cmock.c
CMOCK_SRC := $(patsubst %,$(CMOCK_PATH)/%,$(_CMOCK_SRC))

NTV_SRC := $(TEST_SRC) \
	$(BASE_SRC) \
	$(CMOCK_SRC) \
	$(UNITY_SRC)

NTV_CPPFLAGS := -I$(BASE_INC_PATH) \
	-I$(UNITY_PATH)/src \
	-I$(UNITY_PATH)/extras/fixture/src \
	-I$(CMOCK_PATH)/src
