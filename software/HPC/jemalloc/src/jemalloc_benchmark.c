/*
 * Single-process jemalloc allocation-benchmark driver.
 *
 * jemalloc is a C library whose official distribution is the source
 * tarball from GitHub releases, so the software under test is the
 * library built from the official tarball (SHA-256 verified, configured
 * and compiled inside the isolated work directory).  This harness is
 * compiled against that build and drives it with the two classic
 * allocator workloads used across the industry (the same families the
 * academic allocator literature — Larson & Krishnan 1998 and successors
 * — and every allocator bake-off rely on):
 *
 *   small: short-lived small objects (16-512 B) recycled through a
 *          per-thread slot ring — exercises the thread-cache fast path
 *          (tcache) that dominates general-purpose application traffic.
 *
 *   mixed:  a large object arena with log-uniform sizes from 16 B to
 *          256 KiB and random replacement — exercises arena grow/shrink,
 *          size-class coverage and fragmentation handling.
 *
 * A fixed pool of worker threads runs one operation per iteration
 * (free the victim slot, allocate a fresh object, touch its first
 * bytes); every operation is timed with clock_gettime(CLOCK_MONOTONIC)
 * so all latencies are reported in nanoseconds.  After the warmup phase
 * the counters and latency samples (every 1024th global completion) are
 * collected for the configured duration and written to a JSON report
 * consumed by scripts/collect_jemalloc_benchmark.py.
 *
 * All jemalloc settings (arena count, tcache, decay) are left at their
 * out-of-the-box defaults.
 */

#include <errno.h>
#include <inttypes.h>
#include <pthread.h>
#include <stdatomic.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <jemalloc/jemalloc.h>

#define HEADER_SIZE 16
#define SAMPLE_MASK 1023

/* small workload: 16-512 B objects recycled through a slot ring. */
#define SMALL_SLOTS 4096
#define SMALL_MIN 16
#define SMALL_SPAN 496

/* mixed workload: log-uniform 16 B - 256 KiB, random replacement. */
#define MIXED_OBJECTS 16384
#define MIXED_MIN_LOG2 4    /* 16 B */
#define MIXED_MAX_LOG2 18   /* 256 KiB */

struct config {
    const char *workload;
    int threads;
    int warmup_seconds;
    int duration_seconds;
    const char *scenario;
    const char *output;
};

struct shared {
    struct config cfg;
    atomic_int measuring;
    atomic_int shutting_down;
    atomic_int failed;
    atomic_ulong operation_count;
    atomic_ulong sample_tick;
    /* aggregated latency samples (nanoseconds), guarded by sample_mutex */
    pthread_mutex_t sample_mutex;
    uint64_t *samples;
    size_t sample_count;
    size_t sample_capacity;
    uint64_t sample_sum;
};

static uint64_t monotonic_ns(void) {
    struct timespec ts;
    if (clock_gettime(CLOCK_MONOTONIC, &ts) != 0) {
        fprintf(stderr, "[jemalloc-bench] ERROR: clock_gettime: %s\n",
                strerror(errno));
        exit(1);
    }
    return (uint64_t)ts.tv_sec * 1000000000ULL + (uint64_t)ts.tv_nsec;
}

static void sleep_seconds(int seconds) {
    struct timespec ts;
    ts.tv_sec = seconds;
    ts.tv_nsec = 0;
    while (nanosleep(&ts, &ts) != 0 && errno == EINTR) {
        /* resume the remaining sleep */
    }
}

/* xorshift64*: per-thread pseudo-random generator, cheap and lock-free. */
static inline uint64_t next_random(uint64_t *state) {
    uint64_t x = *state;
    x ^= x >> 12;
    x ^= x << 25;
    x ^= x >> 27;
    *state = x;
    return x * 2685821657736338717ULL;
}

static void record_sample(struct shared *sh, uint64_t latency_ns) {
    pthread_mutex_lock(&sh->sample_mutex);
    if (sh->sample_count == sh->sample_capacity) {
        size_t new_capacity =
            sh->sample_capacity == 0 ? 1024 : sh->sample_capacity * 2;
        uint64_t *grown =
            realloc(sh->samples, new_capacity * sizeof(uint64_t));
        if (grown == NULL) {
            pthread_mutex_unlock(&sh->sample_mutex);
            fprintf(stderr, "[jemalloc-bench] ERROR: sample buffer growth\n");
            atomic_store(&sh->failed, 1);
            return;
        }
        sh->samples = grown;
        sh->sample_capacity = new_capacity;
    }
    sh->samples[sh->sample_count++] = latency_ns;
    sh->sample_sum += latency_ns;
    pthread_mutex_unlock(&sh->sample_mutex);
}

static void note_operation(struct shared *sh, uint64_t latency_ns) {
    atomic_fetch_add(&sh->operation_count, 1);
    if ((atomic_fetch_add(&sh->sample_tick, 1) & SAMPLE_MASK) == 0) {
        record_sample(sh, latency_ns);
    }
}

/* One iteration = free(victim) + malloc(size) + touch. */
static inline uint64_t do_operation(void **slots, uint64_t *rng, int mixed) {
    size_t index;
    size_t size;
    uint64_t start_ns;
    uint64_t end_ns;
    void *fresh;

    if (mixed) {
        index = (size_t)(next_random(rng) & (MIXED_OBJECTS - 1));
        /* log-uniform size in [2^MIN_LOG2, 2^MAX_LOG2] */
        size_t log2_span =
            (size_t)(next_random(rng) % (MIXED_MAX_LOG2 - MIXED_MIN_LOG2 + 1));
        size = (size_t)1 << (MIXED_MIN_LOG2 + log2_span);
    } else {
        index = (size_t)(next_random(rng) & (SMALL_SLOTS - 1));
        size = SMALL_MIN + (size_t)(next_random(rng) % SMALL_SPAN);
    }

    start_ns = monotonic_ns();
    fresh = malloc(size);
    if (fresh == NULL) {
        fprintf(stderr, "[jemalloc-bench] ERROR: malloc(%zu) failed\n", size);
        exit(1);
    }
    /* touch the first bytes so pages are genuinely materialized */
    memset(fresh, (int)(size & 0xFF), HEADER_SIZE);
    free(slots[index]);
    slots[index] = fresh;
    end_ns = monotonic_ns();
    return end_ns - start_ns;
}

struct worker_ctx {
    struct shared *sh;
    uint64_t rng_seed;
};

static void *worker_main(void *arg) {
    struct worker_ctx *ctx = (struct worker_ctx *)arg;
    struct shared *sh = ctx->sh;
    uint64_t rng = ctx->rng_seed | 1;
    const int mixed = strcmp(sh->cfg.workload, "mixed") == 0;
    const size_t slot_count =
        mixed ? MIXED_OBJECTS : SMALL_SLOTS;
    void **slots;

    slots = calloc(slot_count, sizeof(void *));
    if (slots == NULL) {
        fprintf(stderr, "[jemalloc-bench] ERROR: worker slot setup failed\n");
        atomic_store(&sh->failed, 1);
        return NULL;
    }
    /* pre-fill so every free() in the loop has a valid victim */
    for (size_t i = 0; i < slot_count; i++) {
        size_t size = mixed
            ? (size_t)1 << (MIXED_MIN_LOG2
                + (size_t)(next_random(&rng)
                    % (MIXED_MAX_LOG2 - MIXED_MIN_LOG2 + 1)))
            : SMALL_MIN + (size_t)(next_random(&rng) % SMALL_SPAN);
        slots[i] = malloc(size);
        if (slots[i] == NULL) {
            fprintf(stderr, "[jemalloc-bench] ERROR: pre-fill malloc failed\n");
            atomic_store(&sh->failed, 1);
            return NULL;
        }
    }

    while (!atomic_load(&sh->shutting_down)) {
        uint64_t latency_ns = do_operation(slots, &rng, mixed);
        if (atomic_load(&sh->measuring)) {
            note_operation(sh, latency_ns);
        }
    }

    for (size_t i = 0; i < slot_count; i++) {
        free(slots[i]);
    }
    free(slots);
    return NULL;
}

static int compare_u64(const void *a, const void *b) {
    uint64_t left = *(const uint64_t *)a;
    uint64_t right = *(const uint64_t *)b;
    if (left < right) {
        return -1;
    }
    return left > right ? 1 : 0;
}

static void print_version(void) {
    const char *version = NULL;
    size_t version_size = sizeof(version);
    /* official runtime API: the version the loaded jemalloc reports */
    if (mallctl("version", &version, &version_size, NULL, 0) != 0
            || version == NULL || version[0] == '\0') {
        fprintf(stderr,
                "[jemalloc-bench] ERROR: mallctl(\"version\") failed\n");
        exit(1);
    }
    printf("jemalloc-version=%s\n", version);
}

static int parse_int(const char *value, const char *key,
                     int minimum, int maximum) {
    char *end = NULL;
    long parsed;

    errno = 0;
    parsed = strtol(value, &end, 10);
    if (errno != 0 || end == value || *end != '\0'
            || parsed < minimum || parsed > maximum) {
        fprintf(stderr,
                "[jemalloc-bench] ERROR: option --%s must be an integer "
                "between %d and %d (got '%s')\n",
                key, minimum, maximum, value);
        exit(1);
    }
    return (int)parsed;
}

static void usage_exit(void) {
    fprintf(stderr,
            "usage: jemalloc_benchmark --workload small|mixed --threads N "
            "--warmup-seconds N --duration-seconds N --scenario NAME "
            "--output FILE | --version\n");
    exit(1);
}

int main(int argc, char **argv) {
    struct shared sh;
    struct config cfg;
    pthread_t *threads;
    struct worker_ctx *ctxs;
    uint64_t start_ns;
    uint64_t end_ns;
    double duration;
    uint64_t operations;
    double operations_per_second;
    double avg_op_ns;
    double p99_op_ns;
    FILE *out;

    if (argc == 2 && strcmp(argv[1], "--version") == 0) {
        print_version();
        return 0;
    }
    if (argc != 13) {
        usage_exit();
    }

    memset(&cfg, 0, sizeof(cfg));
    for (int i = 1; i < argc; i += 2) {
        const char *key = argv[i];
        const char *value = argv[i + 1];
        if (strcmp(key, "--workload") == 0) {
            cfg.workload = value;
        } else if (strcmp(key, "--threads") == 0) {
            cfg.threads = parse_int(value, "threads", 1, 1024);
        } else if (strcmp(key, "--warmup-seconds") == 0) {
            cfg.warmup_seconds = parse_int(value, "warmup-seconds", 0, 3600);
        } else if (strcmp(key, "--duration-seconds") == 0) {
            cfg.duration_seconds = parse_int(value, "duration-seconds", 1, 3600);
        } else if (strcmp(key, "--scenario") == 0) {
            cfg.scenario = value;
        } else if (strcmp(key, "--output") == 0) {
            cfg.output = value;
        } else {
            usage_exit();
        }
    }
    if (cfg.workload == NULL || cfg.scenario == NULL || cfg.output == NULL
            || (strcmp(cfg.workload, "small") != 0
                && strcmp(cfg.workload, "mixed") != 0)) {
        usage_exit();
    }

    memset(&sh, 0, sizeof(sh));
    sh.cfg = cfg;
    atomic_init(&sh.measuring, 0);
    atomic_init(&sh.shutting_down, 0);
    atomic_init(&sh.failed, 0);
    atomic_init(&sh.operation_count, 0);
    atomic_init(&sh.sample_tick, 0);
    pthread_mutex_init(&sh.sample_mutex, NULL);

    threads = calloc((size_t)cfg.threads, sizeof(pthread_t));
    ctxs = calloc((size_t)cfg.threads, sizeof(struct worker_ctx));
    if (threads == NULL || ctxs == NULL) {
        fprintf(stderr, "[jemalloc-bench] ERROR: thread setup failed\n");
        return 1;
    }
    for (int i = 0; i < cfg.threads; i++) {
        ctxs[i].sh = &sh;
        ctxs[i].rng_seed =
            0x9E3779B97F4A7C15ULL * (uint64_t)(i + 1)
            + (uint64_t)monotonic_ns();
        if (pthread_create(&threads[i], NULL, worker_main, &ctxs[i]) != 0) {
            fprintf(stderr, "[jemalloc-bench] ERROR: pthread_create failed\n");
            return 1;
        }
    }

    /* warmup: full-speed traffic, nothing counted */
    sleep_seconds(cfg.warmup_seconds);
    start_ns = monotonic_ns();
    atomic_store(&sh.measuring, 1);
    sleep_seconds(cfg.duration_seconds);
    atomic_store(&sh.measuring, 0);
    end_ns = monotonic_ns();

    atomic_store(&sh.shutting_down, 1);
    for (int i = 0; i < cfg.threads; i++) {
        pthread_join(threads[i], NULL);
    }

    duration = (double)(end_ns - start_ns) / 1e9;
    operations = atomic_load(&sh.operation_count);

    if (atomic_load(&sh.failed)) {
        fprintf(stderr, "[jemalloc-bench] ERROR: a worker failed\n");
        return 1;
    }
    if (operations == 0) {
        fprintf(stderr, "[jemalloc-bench] ERROR: no operations were measured\n");
        return 1;
    }
    if (sh.sample_count == 0) {
        fprintf(stderr,
                "[jemalloc-bench] ERROR: no latency samples were collected\n");
        return 1;
    }

    operations_per_second = (double)operations / duration;
    avg_op_ns = (double)sh.sample_sum / (double)sh.sample_count;
    qsort(sh.samples, sh.sample_count, sizeof(uint64_t), compare_u64);
    {
        size_t p99_index = (size_t)((double)sh.sample_count * 0.99);
        if (p99_index >= sh.sample_count) {
            p99_index = sh.sample_count - 1;
        }
        if (p99_index == 0 && sh.sample_count > 1) {
            p99_index = 1;
        }
        p99_op_ns = (double)sh.samples[p99_index];
    }

    out = fopen(cfg.output, "w");
    if (out == NULL) {
        fprintf(stderr, "[jemalloc-bench] ERROR: cannot open %s: %s\n",
                cfg.output, strerror(errno));
        return 1;
    }
    fprintf(out,
            "{\n"
            "  \"scenario\": \"%s\",\n"
            "  \"workload\": \"%s\",\n"
            "  \"threads\": %d,\n"
            "  \"warmup_seconds\": %d,\n"
            "  \"duration_seconds\": %.3f,\n"
            "  \"operations\": %" PRIu64 ",\n"
            "  \"operations_per_second\": %.3f,\n"
            "  \"avg_op_ns\": %.3f,\n"
            "  \"p99_op_ns\": %.3f\n"
            "}\n",
            cfg.scenario, cfg.workload, cfg.threads, cfg.warmup_seconds,
            duration, operations, operations_per_second, avg_op_ns,
            p99_op_ns);
    if (fclose(out) != 0) {
        fprintf(stderr, "[jemalloc-bench] ERROR: writing %s failed\n",
                cfg.output);
        return 1;
    }

    printf("[jemalloc-bench] scenario=%s workload=%s threads=%d "
           "operations=%" PRIu64 " ops/s=%.1f avgOp=%.1fns p99Op=%.1fns\n",
           cfg.scenario, cfg.workload, cfg.threads, operations,
           operations_per_second, avg_op_ns, p99_op_ns);

    free(threads);
    free(ctxs);
    free(sh.samples);
    pthread_mutex_destroy(&sh.sample_mutex);
    return 0;
}
