/* mpfr_bench.c -- fixed-workload MPFR benchmark for the performance case.
 *
 * The upstream tools/bench/mpfrbench program always runs every operation at
 * every precision it knows about and takes about twelve minutes per run, which
 * cannot be used for a per-scenario measurement with one warm-up and five
 * repetitions.  This harness follows the same methodology (random operands
 * generated once, CPU time measured with a monotonic process clock, result
 * reported as operations per second) but selects a single operation, a single
 * precision and a bounded time budget, so one measured process covers exactly
 * one scenario.  It calls only public MPFR API functions.
 *
 * Usage: mpfr_bench <routine> <precision>
 *   routine: mpfr_mul | mpfr_div | mpfr_sqrt | mpfr_exp
 */

#define _POSIX_C_SOURCE 200809L

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <gmp.h>
#include <mpfr.h>

#define OPERAND_COUNT 8
#define CALIBRATION_SECONDS 0.05

enum operation {
    OP_MUL = 0,
    OP_DIV,
    OP_SQRT,
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
    if (strcmp(name, "mpfr_mul") == 0) {
        return OP_MUL;
    }
    if (strcmp(name, "mpfr_div") == 0) {
        return OP_DIV;
    }
    if (strcmp(name, "mpfr_sqrt") == 0) {
        return OP_SQRT;
    }
    if (strcmp(name, "mpfr_exp") == 0) {
        return OP_EXP;
    }
    return OP_UNKNOWN;
}

static void execute(enum operation op, mpfr_t result, const mpfr_t left, const mpfr_t right) {
    switch (op) {
    case OP_MUL:
        mpfr_mul(result, left, right, MPFR_RNDN);
        break;
    case OP_DIV:
        mpfr_div(result, left, right, MPFR_RNDN);
        break;
    case OP_SQRT:
        mpfr_sqrt(result, left, MPFR_RNDN);
        break;
    case OP_EXP:
        mpfr_exp(result, left, MPFR_RNDN);
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

    mpfr_t result[OPERAND_COUNT];
    mpfr_t left[OPERAND_COUNT];
    mpfr_t right[OPERAND_COUNT];
    int index;
    for (index = 0; index < OPERAND_COUNT; index++) {
        mpfr_init2(result[index], (mpfr_prec_t)precision);
        mpfr_init2(left[index], (mpfr_prec_t)precision);
        mpfr_init2(right[index], (mpfr_prec_t)precision);
        mpfr_urandomb(left[index], random_state);
        mpfr_urandomb(right[index], random_state);
        /* sqrt/log need a non-zero positive operand; urandomb draws in [0,1). */
        if (mpfr_zero_p(left[index])) {
            mpfr_set_ui(left[index], 1, MPFR_RNDN);
        }
        if ((op == OP_DIV) && mpfr_zero_p(right[index])) {
            mpfr_set_ui(right[index], 1, MPFR_RNDN);
        }
    }
    gmp_randclear(random_state);

    /* Warm the code paths, then calibrate the iteration count to a fixed CPU
     * budget so every scenario spends a comparable amount of time. */
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
        if (elapsed >= CALIBRATION_SECONDS || iterations >= (1UL << 27)) {
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
        checksum += mpfr_get_d(result[index], MPFR_RNDN);
    }
    sink += checksum;

    if (!(elapsed > 0.0)) {
        fprintf(stderr, "non-positive measurement window: %g\n", elapsed);
        return 3;
    }
    printf("VERSION mpfr=%s gmp=%s\n", mpfr_get_version(), gmp_version);
    printf("RESULT routine=%s precision=%ld iterations=%lu cpu_seconds=%.9f "
           "ops_per_second=%.6f checksum=%.17g\n",
           argv[1], precision, iterations, elapsed, (double)iterations / elapsed, checksum);

    for (index = 0; index < OPERAND_COUNT; index++) {
        mpfr_clear(result[index]);
        mpfr_clear(left[index]);
        mpfr_clear(right[index]);
    }
    return 0;
}
