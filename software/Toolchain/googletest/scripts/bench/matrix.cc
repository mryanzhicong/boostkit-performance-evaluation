// Assertion-matrix driver for the GoogleTest performance case.
//
// The delivery manual's representative load is "the framework run overhead of
// 1000 successful assertion tests", so this driver only measures GoogleTest's
// own scheduling, assertion-macro and result-reporting cost - not the speed of
// any business algorithm.  Three compile-time variants are built from this one
// source:
//
//   -DGT_MATRIX_TESTS=1000           1000 registered parameterized tests
//   -DGT_MATRIX_TESTS=10000          10000 registered parameterized tests
//   -DGT_MATRIX_ASSERT_LOOP=5000000  one test with 5,000,000 assertions
//
// Every run validates itself: the main function reports the expected workload
// in a fixed machine-readable line, and the test stage pins that line together
// with the "[  PASSED  ]" summary, so an empty or skipped run cannot produce a
// valid sample.
#include <cstdint>
#include <cstdio>
#include <vector>

#include "gtest/gtest.h"

#ifndef GT_MATRIX_TESTS
#define GT_MATRIX_TESTS 1000
#endif
#ifndef GT_MATRIX_ASSERT_LOOP
#define GT_MATRIX_ASSERT_LOOP 0
#endif
#ifndef GT_MATRIX_MODE
#define GT_MATRIX_MODE "registered"
#endif

namespace {

#if GT_MATRIX_TESTS > 0
class MatrixTest : public ::testing::TestWithParam<int> {};

TEST_P(MatrixTest, OneAssertion) {
  const int value = GetParam();
  EXPECT_EQ(value * 2, value + value);
}

INSTANTIATE_TEST_SUITE_P(Matrix, MatrixTest,
                         ::testing::ValuesIn([] {
                           std::vector<int> values(GT_MATRIX_TESTS);
                           for (int i = 0; i < GT_MATRIX_TESTS; ++i) {
                             values[static_cast<size_t>(i)] = i;
                           }
                           return values;
                         }()));
#endif

#if GT_MATRIX_ASSERT_LOOP > 0
TEST(AssertionLoop, ManyAssertions) {
  // Values are built at run time on purpose: a compile-time-constant assertion
  // could be folded away, and this scenario measures the assertion macro path
  // rather than a constant comparison.
  std::vector<std::int64_t> left(1024);
  std::vector<std::int64_t> right(1024);
  for (int i = 0; i < 1024; ++i) {
    left[static_cast<size_t>(i)] = static_cast<std::int64_t>(i) * 3;
    right[static_cast<size_t>(i)] = static_cast<std::int64_t>(i) * 3;
  }
  for (std::int64_t i = 0; i < GT_MATRIX_ASSERT_LOOP; ++i) {
    ASSERT_EQ(left[static_cast<size_t>(i & 1023)],
              right[static_cast<size_t>(i & 1023)])
        << "index=" << i;
  }
}
#endif

}  // namespace

int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);
  const int rc = RUN_ALL_TESTS();
  std::printf(
      "[gt-matrix] mode=%s registered_tests=%d assertions=%lld rc=%d\n",
      GT_MATRIX_MODE, GT_MATRIX_TESTS,
      static_cast<long long>(GT_MATRIX_ASSERT_LOOP), rc);
  return rc;
}
