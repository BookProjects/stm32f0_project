#include <stdint.h>
#include <stdio.h>

#include "unity_fixture.h"


TEST_GROUP(STD_UTILS);

TEST_GROUP_RUNNER(STD_UTILS) {
	RUN_TEST_CASE(STD_UTILS, TestITOA);
}

static char itoa_buf[100];

TEST_SETUP(STD_UTILS) {
	itoa_buf[0] = '\0';
}

TEST_TEAR_DOWN(STD_UTILS) {
}

TEST(STD_UTILS, TestITOA) {
	itoa(0, itoa_buf);
	TEST_ASSERT_EQUAL_STRING("0", itoa_buf);
	itoa(100, itoa_buf);
	TEST_ASSERT_EQUAL_STRING("100", itoa_buf);
	itoa(12345, itoa_buf);
	TEST_ASSERT_EQUAL_STRING("12345", itoa_buf);
	char uint32_max_str[11];
	sprintf(uint32_max_str, "%ju", UINT32_MAX);
	itoa(-1, itoa_buf);
	TEST_ASSERT_EQUAL_STRING(uint32_max_str, itoa_buf);

}
