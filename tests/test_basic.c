#include <stdio.h>

#include "unity_fixture.h"


TEST_GROUP(BASIC);

TEST_GROUP_RUNNER(BASIC) {
	RUN_TEST_CASE(BASIC, BasicTest);
}

TEST_SETUP(BASIC) {
	printf("Setup\n");
}

TEST_TEAR_DOWN(BASIC) {
	printf("Tear down\n");
}

TEST(BASIC, BasicTest) {
	TEST_ASSERT_EQUAL_UINT32(0, 1);
}
