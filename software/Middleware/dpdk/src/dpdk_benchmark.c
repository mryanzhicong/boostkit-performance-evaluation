/*
 * Single-process DPDK data-plane benchmark driver.
 *
 * DPDK is a C library framework whose official distribution is the
 * source tarball from dpdk.org, so the software under test is the
 * library set built from the official tarball (SHA-256 verified,
 * configured and compiled inside the isolated work directory with the
 * official meson defaults).  This harness is compiled against that
 * build via pkg-config and drives the three core data-plane libraries
 * that every DPDK packet application is built on, with the classic
 * workloads used to profile them:
 *
 *   ring: rte_ring SP/SC burst enqueue/dequeue (burst of 32), one
 *         dedicated ring pair per worker — the pipeline-stage topology
 *         real DPDK deployments use (rings are per stage pair and
 *         workers run on dedicated cores).  1 op = one element
 *         enqueued and dequeued (amortized over the burst pair).
 *
 *   hash: rte_hash lookups against a preloaded 256k-entry flow table
 *         (16-byte keys, 7/8 hits, 1/8 misses) — the exact flow-table
 *         lookup shape of OVS/vSwitch class applications.
 *
 *   lpm:  rte_lpm IPv4 lookups against 64k /24 routes (7/8 hits,
 *         1/8 default-route misses) — the FIB lookup shape of every
 *         DPDK route lookup benchmark.
 *
 * EAL is initialized once per process with "--no-huge --in-memory
 * -l 0 -m 1024" so the benchmark runs on any machine regardless of
 * hugepage configuration, without creating runtime files, and does
 * not depend on lcore discovery; workers are plain pthreads (rte_ring,
 * rte_hash and rte_lpm are safe from any threads: reads are
 * concurrency-safe by design and all writes happen during prefill).
 *
 * A fixed pool of worker threads runs one operation per iteration;
 * every operation is timed with clock_gettime(CLOCK_MONOTONIC) so all
 * latencies are reported in nanoseconds.  After the warmup phase the
 * counters and latency samples (every 1024th global completion) are
 * collected for the configured duration and written to a JSON report
 * consumed by scripts/collect_dpdk_benchmark.py.
 */

#define _GNU_SOURCE

#include <errno.h>
#include <inttypes.h>
#include <pthread.h>
#include <sched.h>
#include <stdatomic.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <rte_eal.h>
#include <rte_hash.h>
#include <rte_lpm.h>
#include <rte_ring.h>
#include <rte_version.h>

#define SAMPLE_PERIOD 1024

/* ring workload: one SP/SC ring pair per worker (the pipeline-stage
 * deployment topology real DPDK applications use), burst 32. */
#define RING_SIZE 65536
#define RING_BURST 32

/* hash workload: preloaded flow table, 16-byte keys, 1/8 misses. */
#define HASH_ENTRIES (1u << 18)
#define HASH_KEY_LEN 16
#define HASH_MISS_MASK 7u

/* lpm workload: preloaded /24 route table, 1/8 misses. */
#define LPM_ROUTES 65536
#define LPM_MISS_MASK 7u
#define LPM_ROUTE_BASE 0x0A000000u /* 10.0.0.0/16 range, /24 routes */
#define LPM_MISS_BASE  0xC0A80000u /* 192.168.x.x — never routed */

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
    /* ops per latency sample: 32 for ring bursts, 1 otherwise */
    double ops_per_sample;
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
        fprintf(stderr, "[dpdk-bench] ERROR: clock_gettime: %s\n",
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
            fprintf(stderr, "[dpdk-bench] ERROR: sample buffer growth\n");
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

/* Record a completed batch: n ops, one latency reading covering them. */
static void note_batch(struct shared *sh, uint64_t ops, uint64_t batch_ns) {
    unsigned long old_tick;
    unsigned long new_tick;

    if (!atomic_load(&sh->measuring)) {
        return;
    }
    atomic_fetch_add(&sh->operation_count, ops);
    old_tick = atomic_fetch_add(&sh->sample_tick, ops);
    new_tick = old_tick + ops;
    if ((old_tick / SAMPLE_PERIOD) != (new_tick / SAMPLE_PERIOD)) {
        record_sample(sh, batch_ns);
    }
}

/* ---- shared DPDK objects (created after EAL init) ---- */

static struct rte_hash *bench_hash;
static struct rte_lpm *bench_lpm;
/* flow-table keys for the hash workload (read-only after prefill) */
static uint64_t *hash_keys;

static int hash_setup(void) {
    struct rte_hash_parameters params = {
        .name = "dpdk_bench_hash",
        .entries = HASH_ENTRIES,
        .key_len = HASH_KEY_LEN,
        .socket_id = SOCKET_ID_ANY,
        /* extendable buckets so the full 256k-entry table can be loaded */
        .extra_flag = RTE_HASH_EXTRA_FLAGS_EXT_TABLE,
    };
    int32_t slot;

    bench_hash = rte_hash_create(&params);
    if (bench_hash == NULL) {
        return -1;
    }
    hash_keys = malloc((size_t)HASH_ENTRIES * HASH_KEY_LEN);
    if (hash_keys == NULL) {
        return -1;
    }
    for (uint32_t i = 0; i < HASH_ENTRIES; i++) {
        /* key = (index, salt): unique, and a miss key flips a high bit
         * of the index word so it can never collide with a stored key */
        hash_keys[2 * i] = i;
        hash_keys[2 * i + 1] =
            (uint64_t)i * 0x9E3779B97F4A7C15ULL;
        slot = rte_hash_add_key(bench_hash, &hash_keys[2 * i]);
        if (slot < 0) {
            fprintf(stderr,
                    "[dpdk-bench] ERROR: hash prefill add failed at %u: %d\n",
                    i, slot);
            return -1;
        }
    }
    return 0;
}

static int lpm_setup(void) {
    struct rte_lpm_config config = {
        .max_rules = LPM_ROUTES,
        .number_tbl8s = 256,
        .flags = 0,
    };
    int status;

    bench_lpm = rte_lpm_create("dpdk_bench_lpm", SOCKET_ID_ANY, &config);
    if (bench_lpm == NULL) {
        return -1;
    }
    for (uint32_t i = 0; i < LPM_ROUTES; i++) {
        /* route i covers 10.<i>>8.<i>&0xFF>.0/24 with next hop i&0xFF */
        status = rte_lpm_add(bench_lpm,
                             LPM_ROUTE_BASE | (i << 8),
                             24,
                             i & 0xFF);
        if (status != 0) {
            fprintf(stderr,
                    "[dpdk-bench] ERROR: lpm prefill add failed at %u: %d\n",
                    i, status);
            return -1;
        }
    }
    return 0;
}

/* ---- workload loops ---- */

static void ring_operation(struct shared *sh, struct rte_ring *ring,
                           void **tokens, void **out) {
    unsigned done;
    uint64_t start_ns;
    uint64_t end_ns;

    /* one iteration = enqueue 32 + dequeue 32 (32 element-ops) */
    start_ns = monotonic_ns();
    done = 0;
    while (done < RING_BURST) {
        done += rte_ring_enqueue_burst(ring, &tokens[done],
                                       RING_BURST - done, NULL);
    }
    done = 0;
    while (done < RING_BURST) {
        done += rte_ring_dequeue_burst(ring, &out[done],
                                       RING_BURST - done, NULL);
    }
    end_ns = monotonic_ns();
    note_batch(sh, RING_BURST, end_ns - start_ns);
}

static void hash_operation(struct shared *sh, uint64_t *rng) {
    const void *key;
    uint64_t miss_key[2];
    uint32_t index;
    uint64_t start_ns;
    uint64_t end_ns;

    index = (uint32_t)(next_random(rng) & (HASH_ENTRIES - 1));
    if ((next_random(rng) & HASH_MISS_MASK) == HASH_MISS_MASK) {
        miss_key[0] = (uint64_t)index | 0x8000000000000000ULL;
        miss_key[1] = next_random(rng);
        key = miss_key;
    } else {
        key = &hash_keys[2 * index];
    }
    start_ns = monotonic_ns();
    (void)rte_hash_lookup(bench_hash, key);
    end_ns = monotonic_ns();
    note_batch(sh, 1, end_ns - start_ns);
}

static void lpm_operation(struct shared *sh, uint64_t *rng) {
    uint32_t ip;
    uint32_t next_hop = 0;
    uint64_t start_ns;
    uint64_t end_ns;

    if ((next_random(rng) & LPM_MISS_MASK) == LPM_MISS_MASK) {
        ip = LPM_MISS_BASE | (uint32_t)next_random(rng);
    } else {
        uint32_t route = (uint32_t)(next_random(rng) & (LPM_ROUTES - 1));
        ip = LPM_ROUTE_BASE | (route << 8)
            | ((uint32_t)next_random(rng) & 0xFFu);
    }
    start_ns = monotonic_ns();
    (void)rte_lpm_lookup(bench_lpm, ip, &next_hop);
    end_ns = monotonic_ns();
    note_batch(sh, 1, end_ns - start_ns);
}

struct worker_ctx {
    struct shared *sh;
    uint64_t rng_seed;
    int worker_index;
};

static void *worker_main(void *arg) {
    struct worker_ctx *ctx = (struct worker_ctx *)arg;
    struct shared *sh = ctx->sh;
    uint64_t rng = ctx->rng_seed | 1;
    const char *workload = sh->cfg.workload;
    struct rte_ring *worker_ring = NULL;
    char ring_name[32];
    void *tokens[RING_BURST];
    void *out[RING_BURST];

    for (unsigned i = 0; i < RING_BURST; i++) {
        tokens[i] = &tokens[i];
    }

    if (strcmp(workload, "ring") == 0) {
        /* dedicated SP/SC ring pair per worker, the pipeline-stage
         * topology of real DPDK deployments (rings are never shared
         * by dozens of cores, and workers are never oversubscribed) */
        snprintf(ring_name, sizeof(ring_name), "dpdk_bench_ring_%d",
                 ctx->worker_index);
        worker_ring = rte_ring_create(ring_name, RING_SIZE,
                                      SOCKET_ID_ANY,
                                      RING_F_SP_ENQ | RING_F_SC_DEQ);
        if (worker_ring == NULL) {
            fprintf(stderr,
                    "[dpdk-bench] ERROR: worker ring creation failed\n");
            atomic_store(&sh->failed, 1);
            return NULL;
        }
    }

    while (!atomic_load(&sh->shutting_down)) {
        if (worker_ring != NULL) {
            ring_operation(sh, worker_ring, tokens, out);
        } else if (strcmp(workload, "hash") == 0) {
            hash_operation(sh, &rng);
        } else {
            lpm_operation(sh, &rng);
        }
    }
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
    /* official runtime API: the version of the linked DPDK build */
    printf("dpdk-version=%s\n", rte_version());
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
                "[dpdk-bench] ERROR: option --%s must be an integer "
                "between %d and %d (got '%s')\n",
                key, minimum, maximum, value);
        exit(1);
    }
    return (int)parsed;
}

static void usage_exit(void) {
    fprintf(stderr,
            "usage: dpdk_benchmark --workload ring|hash|lpm --threads N "
            "--warmup-seconds N --duration-seconds N --scenario NAME "
            "--output FILE | --version\n");
    exit(1);
}

int main(int argc, char **argv) {
    struct shared sh;
    struct config cfg;
    pthread_t *threads;
    struct worker_ctx *ctxs;
    char *eal_argv[] = {
        "dpdk_benchmark", "--no-huge", "--in-memory", "-l", "0",
        "-m", "1024", NULL,
    };
    cpu_set_t original_affinity;
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
            || (strcmp(cfg.workload, "ring") != 0
                && strcmp(cfg.workload, "hash") != 0
                && strcmp(cfg.workload, "lpm") != 0)) {
        usage_exit();
    }

    /*
     * Initialize EAL before any DPDK object is created.  The flags are
     * chosen so the run never depends on host hugepage configuration
     * and leaves no runtime files behind.  EAL pins the main thread to
     * the lcore-0 CPU, so save the original affinity first and restore
     * it afterwards — otherwise every worker thread would inherit the
     * single-core mask and serialize on one CPU.
     */
    CPU_ZERO(&original_affinity);
    if (sched_getaffinity(0, sizeof(original_affinity), &original_affinity) != 0) {
        fprintf(stderr, "[dpdk-bench] ERROR: sched_getaffinity: %s\n",
                strerror(errno));
        return 1;
    }
    if (rte_eal_init(7, eal_argv) < 0) {
        fprintf(stderr, "[dpdk-bench] ERROR: rte_eal_init failed\n");
        return 1;
    }
    if (pthread_setaffinity_np(pthread_self(), sizeof(original_affinity),
                               &original_affinity) != 0) {
        fprintf(stderr, "[dpdk-bench] ERROR: restoring thread affinity failed\n");
        return 1;
    }

    memset(&sh, 0, sizeof(sh));
    sh.cfg = cfg;
    sh.ops_per_sample = strcmp(cfg.workload, "ring") == 0
        ? (double)RING_BURST : 1.0;
    atomic_init(&sh.measuring, 0);
    atomic_init(&sh.shutting_down, 0);
    atomic_init(&sh.failed, 0);
    atomic_init(&sh.operation_count, 0);
    atomic_init(&sh.sample_tick, 0);
    pthread_mutex_init(&sh.sample_mutex, NULL);

    if (strcmp(cfg.workload, "hash") == 0) {
        if (hash_setup() != 0) {
            fprintf(stderr, "[dpdk-bench] ERROR: hash setup failed\n");
            return 1;
        }
    } else if (strcmp(cfg.workload, "lpm") == 0) {
        if (lpm_setup() != 0) {
            fprintf(stderr, "[dpdk-bench] ERROR: lpm setup failed\n");
            return 1;
        }
    }

    threads = calloc((size_t)cfg.threads, sizeof(pthread_t));
    ctxs = calloc((size_t)cfg.threads, sizeof(struct worker_ctx));
    if (threads == NULL || ctxs == NULL) {
        fprintf(stderr, "[dpdk-bench] ERROR: thread setup failed\n");
        return 1;
    }
    for (int i = 0; i < cfg.threads; i++) {
        ctxs[i].sh = &sh;
        ctxs[i].worker_index = i;
        ctxs[i].rng_seed =
            0x9E3779B97F4A7C15ULL * (uint64_t)(i + 1)
            + (uint64_t)monotonic_ns();
        if (pthread_create(&threads[i], NULL, worker_main, &ctxs[i]) != 0) {
            fprintf(stderr, "[dpdk-bench] ERROR: pthread_create failed\n");
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
        fprintf(stderr, "[dpdk-bench] ERROR: a worker failed\n");
        return 1;
    }
    if (operations == 0) {
        fprintf(stderr, "[dpdk-bench] ERROR: no operations were measured\n");
        return 1;
    }
    if (sh.sample_count == 0) {
        fprintf(stderr,
                "[dpdk-bench] ERROR: no latency samples were collected\n");
        return 1;
    }

    operations_per_second = (double)operations / duration;
    /* each sample covers ops_per_sample operations (ring bursts) */
    avg_op_ns = (double)sh.sample_sum
        / ((double)sh.sample_count * sh.ops_per_sample);
    qsort(sh.samples, sh.sample_count, sizeof(uint64_t), compare_u64);
    {
        size_t p99_index = (size_t)((double)sh.sample_count * 0.99);
        if (p99_index >= sh.sample_count) {
            p99_index = sh.sample_count - 1;
        }
        if (p99_index == 0 && sh.sample_count > 1) {
            p99_index = 1;
        }
        p99_op_ns = (double)sh.samples[p99_index] / sh.ops_per_sample;
    }

    out = fopen(cfg.output, "w");
    if (out == NULL) {
        fprintf(stderr, "[dpdk-bench] ERROR: cannot open %s: %s\n",
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
        fprintf(stderr, "[dpdk-bench] ERROR: writing %s failed\n",
                cfg.output);
        return 1;
    }

    printf("[dpdk-bench] scenario=%s workload=%s threads=%d "
           "operations=%" PRIu64 " ops/s=%.1f avgOp=%.1fns p99Op=%.1fns\n",
           cfg.scenario, cfg.workload, cfg.threads, operations,
           operations_per_second, avg_op_ns, p99_op_ns);

    free(threads);
    free(ctxs);
    free(sh.samples);
    free(hash_keys);
    pthread_mutex_destroy(&sh.sample_mutex);
    return 0;
}
