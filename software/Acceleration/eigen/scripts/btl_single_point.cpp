// Fixed-dimension driver for the upstream BTL actions that ship in the pinned
// Eigen archive (bench/btl).
//
// Why this file exists: the upstream BTL sweep (btl_eigen3_*) constructs one
// Portable_Perf_Analyzer per action and then calls eval_mflops() for every size
// of the sweep.  eval_mflops() keeps the analyzer state (m_time_action and
// _nb_calc) across calls, so once the first --- largest --- size has exceeded
// MIN_TIME the remaining sizes are never re-timed: every printed MFlops value of
// the sweep is nb_op_base(size) divided by the *first* size's measured time.
// That upstream behaviour is kept untouched (it is what the measured
// btl_eigen3_* scenarios run), but the per-dimension GFLOPS metrics cannot be
// derived from it without fabricating numbers.
//
// This driver therefore reuses the unmodified upstream action headers
// (actions/*.hh, libs/eigen3/eigen3_interface.hh) and the unmodified upstream
// Portable_Perf_Analyzer, and only fixes the single dimension that BTL would
// otherwise take from its sweep grid.  One process measures exactly one
// (action, dimension) pair and prints a BTL-shaped result line, so the raw
// evidence is parsed by the same rules as the upstream sweep output.
#include <cstdio>
#include <cstdlib>
#include <string>

#include "utilities.h"
#include "eigen3_interface.hh"
#include "bench.hh"
#include "basic_actions.hh"
// Advanced actions are not part of basic_actions.hh; upstream main_adv.cpp
// includes them explicitly.
#include "action_cholesky.hh"
#include "action_trisolve_matrix.hh"

BTL_MAIN;

namespace {

typedef eigen3_interface<REAL_TYPE> BtlInterface;

template <class Action>
int measure_one(const int size) {
    Portable_Perf_Analyzer<Action> analyzer;
    const double mflops = analyzer.eval_mflops(size);
    if (!(mflops > 0.0)) {
        std::fprintf(stderr, "ERROR: the upstream BTL analyzer reported %g MFlops\n", mflops);
        return 1;
    }
    std::printf(" size = %d  %.10g MFlops    (1/1)\n", size, mflops);
    std::fflush(stdout);
    return 0;
}

}  // namespace

int main(int argc, char** argv) {
    if (argc != 3) {
        std::fprintf(stderr, "usage: %s <btl-action> <dimension>\n", argv[0]);
        return 2;
    }
    const std::string action = argv[1];
    char* end = nullptr;
    const long parsed = std::strtol(argv[2], &end, 10);
    if (end == nullptr || *end != '\0' || parsed <= 0 || parsed > 100000000L) {
        std::fprintf(stderr, "ERROR: invalid dimension: %s\n", argv[2]);
        return 2;
    }
    const int size = static_cast<int>(parsed);
    std::printf("# btl-single-point action=%s size=%d\n", action.c_str(), size);
    if (action == "matrix_matrix") {
        return measure_one<Action_matrix_matrix_product<BtlInterface> >(size);
    }
    if (action == "matrix_vector") {
        return measure_one<Action_matrix_vector_product<BtlInterface> >(size);
    }
    if (action == "trisolve_matrix") {
        return measure_one<Action_trisolve_matrix<BtlInterface> >(size);
    }
    if (action == "cholesky") {
        return measure_one<Action_cholesky<BtlInterface> >(size);
    }
    if (action == "axpy") {
        return measure_one<Action_axpy<BtlInterface> >(size);
    }
    std::fprintf(stderr, "ERROR: unsupported BTL action: %s\n", action.c_str());
    return 2;
}
