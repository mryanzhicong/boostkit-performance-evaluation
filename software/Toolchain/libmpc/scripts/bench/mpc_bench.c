/* mpc_bench.c -- fixed-workload libmpc benchmark for the performance case.
 *
 * Upstream tools/bench/mpcbench has no switch to select an operation or a
 * precision: one run always executes the complete fixed operation set.  This
 * harness keeps the same methodology (random operands generated once, CPU time
 * measured with a monotonic process clock, result reported as operations per
 * second) but measures exactly one operation at one precision in a bounded time
 * window, so one process covers one scenario.  Only public libmpc, MPFR and GMP
 * API functions are used.
 *
 * Usage: mpc_bench <routine> <precision>
 *   routine: mpc_mul | mpc_sqr | mpc_div | mpc_pow | mpc_exp
 */

#define _POSIX_C_SOURCE 200809L

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <gmp.h>
#include <mpfr.h>
#include <mpc.h>

#define OPERAND_COUNT 8
#define CALIBRATION_SECONDS 0.05

enum operation {
    OP_MUL = 0,
    OP_SQR,
    OP_DIV,
    OP_POW,
    OP_EXP,
    OP_UNKNOWN
};

static volatile double sink;

static double cpu_seconds(void) {
    struct timespec ts;
    if (clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &ts) != 0) {
        perror("clock_gettime");
        exit(2);
    }
    return (double)ts.tv_sec + (double)ts.tv_nsec * 1e-9;
}

static enum operation parse_operation(const char *name) {
    if (strcmp(name, "mpc_mul") == 0) {
        return OP_MUL;
    }
    if (strcmp(name, "mpc_sqr") == 0) {
        return OP_SQR;
    }
    if (strcmp(name, "mpc_div") == 0) {
        return OP_DIV;
    }
    if (strcmp(name, "mpc_pow") == 0) {
        return OP_POW;
    }
    if (strcmp(name, "mpc_exp") == 0) {
        return OP_EXP;
    }
    return OP_UNKNOWN;
}

static void execute(enum operation op, mpc_t result, const mpc_t left, const mpc_t right) {
    switch (op) {
    case OP_MUL:
        mpc_mul(result, left, right, MPC_RNDNN);
        break;
    case OP_SQR:
        mpc_sqr(result, left, MPC_RNDNN);
        break;
    case OP_DIV:
        mpc_div(result, left, right, MPC_RNDNN);
        break;
    case OP_POW:
        mpc_pow(result, left, right, MPC_RNDNN);
        break;
    case OP_EXP:
        mpc_exp(result, left, MPC_RNDNN);
        break;
    case OP_UNKNOWN:
        abort();
    }
}

int main(int argc, char **argv) {
    if (argc != 3) {
        fprintf(stderr, "usage: %s <routine> <precision>\n", argv[0]);
        return 2;
    }
    const enum operation op = parse_operation(argv[1]);
    if (op == OP_UNKNOWN) {
        fprintf(stderr, "unknown routine: %s\n", argv[1]);
        return 2;
    }
    errno = 0;
    const long precision = strtol(argv[2], NULL, 10);
    if (errno != 0 || precision < MPFR_PREC_MIN || precision > 1000000) {
        fprintf(stderr, "invalid precision: %s\n", argv[2]);
        return 2;
    }

    gmp_randstate_t random_state;
    gmp_randinit_default(random_state);
    gmp_randseed_ui(random_state, 20261102UL);

    mpc_t result[OPERAND_COUNT];
    mpc_t left[OPERAND_COUNT];
    mpc_t right[OPERAND_COUNT];
    int index;
    for (index = 0; index < OPERAND_COUNT; index++) {
        mpc_init2(result[index], (mpfr_prec_t)precision);
        mpc_init2(left[index], (mpfr_prec_t)precision);
        mpc_init2(right[index], (mpfr_prec_t)precision);
        mpfr_urandomb(mpc_realref(left[index]), random_state);
        mpfr_urandomb(mpc_imagref(left[index]), random_state);
        mpfr_urandomb(mpc_realref(right[index]), random_state);
        mpfr_urandomb(mpc_imagref(right[index]), random_state);
        /* Keep the base non-zero and the divisor non-zero, and stay away from
         * the branch cut: a positive real part is enough for exp/pow. */
        mpfr_set_d(mpc_realref(left[index]), mpfr_get_d(mpc_realref(left[index]), MPFR_RNDN) + 0.5,
                   MPFR_RNDN);
        mpfr_set_d(mpc_imagref(left[index]), mpfr_get_d(mpc_imagref(left[index]), MPFR_RNDN) - 0.5,
                   MPFR_RNDN);
        if (mpfr_zero_p(mpc_realref(right[index])) && mpfr_zero_p(mpc_imagref(right[index]))) {
            mpfr_set_d(mpc_realref(right[index]), 0.5, MPFR_RNDN);
        }
    }
    gmp_randclear(random_state);

    unsigned long iterations = 1;
    for (;;) {
        const double started = cpu_seconds();
        unsigned long index_iteration;
        for (index_iteration = 0; index_iteration < iterations; index_iteration++) {
            execute(op, result[index_iteration % OPERAND_COUNT],
                    left[index_iteration % OPERAND_COUNT],
                    right[index_iteration % OPERAND_COUNT]);
        }
        const double elapsed = cpu_seconds() - started;
        if (elapsed >= CALIBRATION_SECONDS || iterations >= (1UL << 24)) {
            break;
        }
        iterations *= 2;
    }

    const double started = cpu_seconds();
    unsigned long index_iteration;
    double checksum = 0.0;
    for (index_iteration = 0; index_iteration < iterations; index_iteration++) {
        execute(op, result[index_iteration % OPERAND_COUNT],
                left[index_iteration % OPERAND_COUNT],
                right[index_iteration % OPERAND_COUNT]);
    }
    const double elapsed = cpu_seconds() - started;
    for (index = 0; index < OPERAND_COUNT; index++) {
        checksum += mpfr_get_d(mpc_realref(result[index]), MPFR_RNDN);
        checksum += mpfr_get_d(mpc_imagref(result[index]), MPFR_RNDN);
    }
    sink += checksum;

    if (!(elapsed > 0.0)) {
        fprintf(stderr, "non-positive measurement window: %g\n", elapsed);
        return 3;
    }
    printf("VERSION mpc=%s mpfr=%s gmp=%s\n", mpc_get_version(), mpfr_get_version(), gmp_version);
    printf("RESULT routine=%s precision=%ld iterations=%lu cpu_seconds=%.9f "
           "ops_per_second=%.6f checksum=%.17g\n",
           argv[1], precision, iterations, elapsed, (double)iterations / elapsed, checksum);

    for (index = 0; index < OPERAND_COUNT; index++) {
        mpc_clear(result[index]);
        mpc_clear(left[index]);
        mpc_clear(right[index]);
    }
    return 0;
}
