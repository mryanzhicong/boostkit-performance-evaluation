// Build/run self-check for the Eigen Acceleration case.
//
// The file is compiled twice during the build stage with the exact compiler
// flags of each measured group, and the resulting binary is executed:
//   * it prints the Eigen version read from the pinned upstream headers, so the
//     framework can prove which product was actually built;
//   * it prints the instruction-set and Eigen vectorisation macros that the
//     compiler really defined, which proves the two build groups differ;
//   * it multiplies two deterministic dense float matrices with Eigen and
//     compares the result against a plain triple loop, so a mis-compiled or
//     mis-linked build fails the build stage instead of the test stage.
#include <Eigen/Core>

#include <cmath>
#include <cstdio>

namespace {

void print_define(const char* name) { std::printf("define %s=1\n", name); }

void print_isa_macros() {
#ifdef __SSE2__
    print_define("__SSE2__");
#endif
#ifdef __SSE3__
    print_define("__SSE3__");
#endif
#ifdef __SSSE3__
    print_define("__SSSE3__");
#endif
#ifdef __SSE4_1__
    print_define("__SSE4_1__");
#endif
#ifdef __AVX__
    print_define("__AVX__");
#endif
#ifdef __AVX2__
    print_define("__AVX2__");
#endif
#ifdef __AVX512F__
    print_define("__AVX512F__");
#endif
#ifdef __FMA__
    print_define("__FMA__");
#endif
#ifdef __ARM_NEON
    print_define("__ARM_NEON");
#endif
#ifdef __ARM_FEATURE_SVE
    print_define("__ARM_FEATURE_SVE");
#endif
#ifdef __ARM_FEATURE_ATOMICS
    print_define("__ARM_FEATURE_ATOMICS");
#endif
#ifdef EIGEN_VECTORIZE
    print_define("EIGEN_VECTORIZE");
#endif
#ifdef EIGEN_VECTORIZE_SSE
    print_define("EIGEN_VECTORIZE_SSE");
#endif
#ifdef EIGEN_VECTORIZE_AVX
    print_define("EIGEN_VECTORIZE_AVX");
#endif
#ifdef EIGEN_VECTORIZE_AVX2
    print_define("EIGEN_VECTORIZE_AVX2");
#endif
#ifdef EIGEN_VECTORIZE_FMA
    print_define("EIGEN_VECTORIZE_FMA");
#endif
#ifdef EIGEN_VECTORIZE_NEON
    print_define("EIGEN_VECTORIZE_NEON");
#endif
#ifdef EIGEN_VECTORIZE_SVE
    print_define("EIGEN_VECTORIZE_SVE");
#endif
}

// Deterministic dense float product checked against a naive loop.  The values
// are exact small integers, so the comparison is a plain tolerance check.
bool check_gemm() {
    constexpr int n = 64;
    Eigen::MatrixXf a(n, n);
    Eigen::MatrixXf b(n, n);
    for (int row = 0; row < n; ++row) {
        for (int column = 0; column < n; ++column) {
            a(row, column) = static_cast<float>((row * 7 + column * 13) % 17) - 8.0F;
            b(row, column) = static_cast<float>((row * 5 + column * 3) % 11) - 5.0F;
        }
    }
    Eigen::MatrixXf c = a * b;
    double expected = 0.0;
    double actual = 0.0;
    for (int row = 0; row < n; ++row) {
        for (int column = 0; column < n; ++column) {
            double cell = 0.0;
            for (int inner = 0; inner < n; ++inner) {
                cell += static_cast<double>(a(row, inner)) *
                        static_cast<double>(b(inner, column));
            }
            expected += cell;
            actual += static_cast<double>(c(row, column));
        }
    }
    const double tolerance = 1e-3 * std::fmax(1.0, std::fabs(expected));
    const bool matches = std::fabs(actual - expected) <= tolerance;
    std::printf("gemm_sum expected=%.6f actual=%.6f tolerance=%.6f matches=%d\n",
                expected, actual, tolerance, matches ? 1 : 0);
    return matches;
}

}  // namespace

int main() {
    std::printf("EIGEN_VERSION_STRING=%s\n", EIGEN_VERSION_STRING);
    std::printf("EIGEN_WORLD_VERSION=%d\n", EIGEN_WORLD_VERSION);
    std::printf("EIGEN_MAJOR_VERSION=%d\n", EIGEN_MAJOR_VERSION);
    std::printf("EIGEN_MINOR_VERSION=%d\n", EIGEN_MINOR_VERSION);
    std::printf("EIGEN_PATCH_VERSION=%d\n", EIGEN_PATCH_VERSION);
    print_isa_macros();
    const bool gemm_ok = check_gemm();
    std::printf("selftest=%s\n", gemm_ok ? "ok" : "failed");
    return gemm_ok ? 0 : 1;
}
