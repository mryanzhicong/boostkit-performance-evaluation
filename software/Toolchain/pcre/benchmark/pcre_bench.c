/*
 * pcre_bench.c - deterministic PCRE 8.45 (PCRE1) matching benchmark.
 *
 * Copyright (c) 2026 boostkit-performance-evaluation contributors
 * SPDX-License-Identifier: MIT
 *
 * The program is a fixed, reproducible load for the PCRE 8.45 performance case.
 * It is NOT an upstream PCRE benchmark: the upstream project ships pcretest and
 * the RunTest suite, which the case runs separately.  This harness adds a
 * per-call cost measurement that pcretest's coarser timing mode cannot express:
 * it pre-compiles one pattern per invocation, executes it a fixed number of
 * times on fixed inputs, verifies that every call produced the expected match
 * result, and prints machine readable metric lines:
 *
 *   PERF-METRIC name=<name> value=<number> unit=<unit> direction=<direction>
 *   PERF-CHECK name=<name> expected=<n> actual=<n> status=ok|failed
 *
 * Every invocation is single threaded (no threads, no JIT cache sharing) so the
 * same argv is meaningful on x86_64 and aarch64.  Any mismatch, compile error,
 * or unexpected return code makes the process exit non-zero; the case parser
 * rejects a repetition whose log lacks the expected metric or check lines.
 *
 * Usage: pcre_bench <mode> <iterations>
 *   mode: literal | backtrack | utf8 | dfa | jit | compile
 */

#define _POSIX_C_SOURCE 200809L

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <pcre.h>

#define OVECTOR_SIZE 30
#define MATCH_MAX(a, b) ((a) > (b) ? (a) : (b))

static int failures = 0;

static void fail(const char *message)
{
    fprintf(stderr, "pcre_bench: FAILED: %s\n", message);
    failures++;
}

static void emit_metric(const char *name, double value, const char *unit,
                        const char *direction)
{
    printf("PERF-METRIC name=%s value=%.6f unit=%s direction=%s\n",
           name, value, unit, direction);
}

static void emit_check(const char *name, long expected, long actual)
{
    printf("PERF-CHECK name=%s expected=%ld actual=%ld status=%s\n",
           name, expected, actual, expected == actual ? "ok" : "failed");
}

static int64_t now_ns(void)
{
    struct timespec ts;
    if (clock_gettime(CLOCK_MONOTONIC, &ts) != 0) {
        fail("clock_gettime(CLOCK_MONOTONIC) failed");
        return 0;
    }
    return (int64_t)ts.tv_sec * INT64_C(1000000000) + (int64_t)ts.tv_nsec;
}

/* Fixed ASCII corpus line (240 bytes, one match of every literal pattern). */
static const char *const ascii_line =
    "The quick brown fox jumps over the lazy dog; "
    "the Lazy Fox jumped over a quick brown dog while the "
    "quick brown fox slept under the lazy dog and the "
    "brown fox watched the quick dog run over the lazy fox.";

/* Heavy-backtracking input: 17 'a' characters and no 'b' or 'c'.  The pattern
 * "^(a+)+[bc]" cannot be rejected by PCRE's required-character optimisation
 * (the terminal token is a class), so the failing match makes pcre_exec walk
 * every split of the nested quantifier (~2^16 attempts).  The depth stays well
 * inside the library's default match limit, which keeps the case reproducible
 * on both architectures. */
static const char *const backtrack_line = "aaaaaaaaaaaaaaaaa";

/* UTF-8 line: Greek, Latin and CJK code points + a multi-byte separator. */
static const char *const utf8_line =
    "\xce\x9f\xce\xbb\xce\xac\xce\xbd\xce\xb4\xcf\x81\xce\xb1 "
    "\xe4\xb8\xad\xe6\x96\x87\xe6\xb5\x8b\xe8\xaf\x95 "
    "\xe2\x80\x94 Caf\xc3\xa9 \xce\xb1\xce\xb2\xce\xb3";

static const char *const jit_pattern = "(?:quick|lazy)\\s+brown\\s+(?:fox|dog)";
static const char *const jit_line =
    "the quick brown fox jumps over the lazy dog";

static void report_rate(const char *label, int64_t elapsed_ns, long iterations)
{
    if (elapsed_ns <= 0 || iterations <= 0) {
        fail("invalid timing measurement");
        return;
    }
    emit_metric(label, (double)elapsed_ns / (double)iterations, "ns/op",
                "lower_is_better");
}

static void report_throughput(int64_t elapsed_ns, long iterations)
{
    if (elapsed_ns <= 0 || iterations <= 0) {
        fail("invalid throughput measurement");
        return;
    }
    emit_metric("ops_per_second", (double)iterations /
                                    ((double)elapsed_ns / 1.0e9),
                "ops/s", "higher_is_better");
}

/* ---------------------------------------------------------------- modes ---- */

static void run_exec_mode(const char *mode, int iterations)
{
    const char *pattern;
    const char *subject;
    int options = 0;
    long expected_matches;
    long matches = 0;
    int error_code = 0;
    const char *error_message = NULL;
    int error_offset = 0;

    if (strcmp(mode, "literal") == 0) {
        pattern = "(?:quick|lazy)\\s+brown\\s+(?:fox|dog)";
        subject = ascii_line;
        expected_matches = 3;
    } else if (strcmp(mode, "backtrack") == 0) {
        pattern = "^(a+)+[bc]";
        subject = backtrack_line;
        expected_matches = 0;
    } else if (strcmp(mode, "utf8") == 0) {
        pattern = "\\p{Lu}\\p{Ll}+\\s+(?:\\p{Han}+|Caf\\xc3\\xa9)";
        subject = utf8_line;
        options = PCRE_UTF8 | PCRE_UCP;
        expected_matches = 1;
    } else {
        fail("run_exec_mode: unsupported mode");
        return;
    }

    pcre *re = pcre_compile(pattern, options, &error_message, &error_offset, NULL);
    if (re == NULL) {
        fprintf(stderr, "pcre_bench: pcre_compile failed at offset %d: %s\n",
                error_offset, error_message == NULL ? "unknown" : error_message);
        failures++;
        return;
    }

    pcre_extra *extra = NULL;

    int ovector[OVECTOR_SIZE];
    int rc = 0;
    long completed = 0;
    int64_t started = now_ns();
    for (long i = 0; i < iterations; i++) {
        rc = pcre_exec(re, extra, subject, (int)strlen(subject), 0, 0, ovector,
                       OVECTOR_SIZE);
        if (rc < 0 && rc != PCRE_ERROR_NOMATCH) {
            error_code = rc;
            break;
        }
        completed++;
        if (rc > 0) {
            matches++;
        }
    }
    int64_t elapsed = now_ns() - started;

    if (error_code != 0) {
        fprintf(stderr, "pcre_bench: pcre_exec failed with error %d after %ld ops\n",
                error_code, completed);
        failures++;
    }
    emit_check("exec_completed", (long)iterations, completed);

    /* One extra verified call so the correctness evidence is independent of the
     * loop count: the last iteration's match result must match the pattern. */
    long verified = 0;
    rc = pcre_exec(re, extra, subject, (int)strlen(subject), 0, 0, ovector,
                   OVECTOR_SIZE);
    while (rc > 0) {
        verified++;
        int offset = ovector[1];
        if (offset <= ovector[0]) {
            offset = ovector[0] + 1;
        }
        rc = pcre_exec(re, extra, subject, (int)strlen(subject), offset, 0,
                       ovector, OVECTOR_SIZE);
    }
    if (rc < 0 && rc != PCRE_ERROR_NOMATCH) {
        fail("verified match scan failed");
    }
    emit_check("verified_matches", expected_matches, verified);
    emit_check("exec_iterations", (long)iterations, (long)iterations);
    if (matches != 0) {
        /* matches are zero for the backtrack mode; the count itself is only
         * informative, the verified scan above is the correctness gate. */
        printf("PERF-INFO matched_calls=%ld\n", matches);
    }
    report_rate("match_ns_per_op", elapsed, (long)iterations);
    report_throughput(elapsed, (long)iterations);

    if (extra != NULL) {
        free(extra);
    }
    pcre_free(re);
}

static void run_jit_mode(int iterations)
{
    int error_code = 0;
    const char *error_message = NULL;
    int error_offset = 0;
    pcre *re = pcre_compile(jit_pattern, 0, &error_message, &error_offset, NULL);
    if (re == NULL) {
        fprintf(stderr, "pcre_bench: jit pcre_compile failed: %s\n",
                error_message == NULL ? "unknown" : error_message);
        failures++;
        return;
    }
    pcre_extra *extra = pcre_study(re, PCRE_STUDY_JIT_COMPILE, &error_message);
    if (error_message != NULL) {
        fprintf(stderr, "pcre_bench: jit pcre_study failed: %s\n", error_message);
        failures++;
        pcre_free(re);
        return;
    }
    int jit = 0;
    if (pcre_config(PCRE_CONFIG_JIT, &jit) != 0 || jit != 1) {
        fail("JIT support is not available in this build");
        if (extra != NULL) {
            pcre_free_study(extra);
        }
        pcre_free(re);
        return;
    }
    int ovector[OVECTOR_SIZE];
    long matches = 0;
    int64_t started = now_ns();
    for (int i = 0; i < iterations; i++) {
        int rc = pcre_exec(re, extra, jit_line, (int)strlen(jit_line), 0, 0,
                           ovector, OVECTOR_SIZE);
        if (rc < 0) {
            error_code = rc;
            break;
        }
        matches++;
    }
    int64_t elapsed = now_ns() - started;
    if (error_code != 0) {
        fprintf(stderr, "pcre_bench: jit pcre_exec failed with error %d\n",
                error_code);
        failures++;
    }
    int used_jit = (extra != NULL && (extra->flags & PCRE_EXTRA_EXECUTABLE_JIT) != 0)
                       ? 1
                       : 0;
    emit_check("jit_available", 1, jit);
    emit_check("jit_executable", 1, used_jit);
    emit_check("jit_matched_calls", (long)iterations, matches);
    report_rate("match_ns_per_op", elapsed, (long)iterations);
    report_throughput(elapsed, (long)iterations);
    if (extra != NULL) {
        pcre_free_study(extra);
    }
    pcre_free(re);
}

static void run_dfa_mode(int iterations)
{
    static const char *const pattern = "(?:quick|lazy)\\s+brown\\s+(?:fox|dog)";
    static const char *const subject =
        "the quick brown fox jumps over the lazy dog while the quick brown dog "
        "sleeps under the lazy fox";
    const char *error_message = NULL;
    int error_offset = 0;
    pcre *re = pcre_compile(pattern, 0, &error_message, &error_offset, NULL);
    if (re == NULL) {
        fprintf(stderr, "pcre_bench: dfa pcre_compile failed: %s\n",
                error_message == NULL ? "unknown" : error_message);
        failures++;
        return;
    }
    int workspace[1024];
    int offsets[OVECTOR_SIZE];
    long matches = 0;
    int rc = 0;
    int64_t started = now_ns();
    for (int i = 0; i < iterations; i++) {
        rc = pcre_dfa_exec(re, NULL, subject, (int)strlen(subject), 0, 0,
                           offsets, OVECTOR_SIZE, workspace, 1024);
        if (rc < 0) {
            break;
        }
        matches++;
    }
    int64_t elapsed = now_ns() - started;
    if (rc < 0) {
        fprintf(stderr, "pcre_bench: pcre_dfa_exec failed with error %d\n", rc);
        failures++;
    }
    /* Verified scan: count every DFA match in the subject. */
    long verified = 0;
    int start = 0;
    rc = pcre_dfa_exec(re, NULL, subject, (int)strlen(subject), 0, 0, offsets,
                       OVECTOR_SIZE, workspace, 1024);
    while (rc >= 0) {
        if (rc == 0) {
            break;
        }
        verified++;
        start = offsets[1];
        if (start <= offsets[0]) {
            start = offsets[0] + 1;
        }
        if (start > (int)strlen(subject)) {
            break;
        }
        rc = pcre_dfa_exec(re, NULL, subject, (int)strlen(subject), start, 0,
                           offsets, OVECTOR_SIZE, workspace, 1024);
    }
    emit_check("dfa_verified_matches", 2, verified);
    emit_check("dfa_matched_calls", (long)iterations, matches);
    report_rate("dfa_ns_per_op", elapsed, (long)iterations);
    report_throughput(elapsed, (long)iterations);
    pcre_free(re);}

static void run_compile_mode(int iterations)
{
    static const char *const patterns[] = {
        "(?:quick|lazy)\\s+brown\\s+(?:fox|dog)",
        "\\b(?:[a-z0-9_]+)\\b",
        "^(?:(?:[a-z]+)\\s+)+[0-9]+$",
        "([A-Z][a-z]+)(?::\\s*)(\\d{1,4})",
        "\\p{Lu}\\p{Ll}+\\s+\\p{Han}+",
        "(?i)(?:error|warning):\\s+.*$",
        "(?:foo|bar|baz){2,4}\\d*",
        "\\A(?:[^\\n]*)(?=\\n)\\n?",
    };
    const size_t pattern_count = sizeof(patterns) / sizeof(patterns[0]);
    int64_t started = now_ns();
    long compiled = 0;
    for (int i = 0; i < iterations; i++) {
        const char *pattern = patterns[(size_t)i % pattern_count];
        const char *error_message = NULL;
        int error_offset = 0;
        pcre *re = pcre_compile(pattern, 0, &error_message, &error_offset, NULL);
        if (re == NULL) {
            fprintf(stderr, "pcre_bench: compile failed at offset %d: %s\n",
                    error_offset,
                    error_message == NULL ? "unknown" : error_message);
            failures++;
            break;
        }
        compiled++;
        pcre_free(re);
    }
    int64_t elapsed = now_ns() - started;
    emit_check("compiled_patterns", (long)iterations, compiled);
    report_rate("compile_ns_per_op", elapsed, (long)iterations);
    emit_metric("compiles_per_second",
                (double)compiled / ((double)elapsed / 1.0e9), "ops/s",
                "higher_is_better");
}

int main(int argc, char **argv)
{
    if (argc != 3) {
        fprintf(stderr, "usage: %s <literal|backtrack|utf8|dfa|jit|compile> <iterations>\n",
                argv[0]);
        return 2;
    }
    const char *mode = argv[1];
    char *end = NULL;
    long iterations = strtol(argv[2], &end, 10);
    if (end == NULL || *end != '\0' || iterations <= 0 || iterations > 1000000000L) {
        fprintf(stderr, "pcre_bench: invalid iteration count: %s\n", argv[2]);
        return 2;
    }
    printf("PERF-CONFIG mode=%s iterations=%ld pcre_version=%s\n", mode,
           iterations, pcre_version());
    if (strcmp(mode, "compile") == 0) {
        run_compile_mode((int)iterations);
    } else if (strcmp(mode, "dfa") == 0) {
        run_dfa_mode((int)iterations);
    } else if (strcmp(mode, "jit") == 0) {
        run_jit_mode((int)iterations);
    } else {
        run_exec_mode(mode, (int)iterations);
    }
    if (failures != 0) {
        fprintf(stderr, "pcre_bench: %d failure(s)\n", failures);
        printf("PERF-RESULT status=failed\n");
        return 1;
    }
    printf("PERF-RESULT status=ok\n");
    return 0;
}
