/*
 * Single-process SPDK blobstore benchmark driver.
 *
 * SPDK is a C library framework whose official distribution channel is
 * the git repository (github.com/spdk/spdk) with its dpdk submodule, so
 * the software under test is the library set built from the official
 * v26.05 tag (recursive submodule checkout, configured with the official
 * configure/make defaults, compiled entirely inside the isolated work
 * directory).  This harness links the static SPDK libs from that build
 * and drives the blobstore — the local-storage object layer every SPDK
 * blob application is built on — with the classic workloads used to
 * profile it:
 *
 *   create: spdk_bs_create_blob + spdk_bs_delete_blob lifecycles — the
 *           metadata path every blob provision walks.  1 op = one blob
 *           created and deleted (a full lifecycle, so the metadata
 *           pages are recycled instead of exhausted).
 *
 *   write:  4KiB spdk_blob_io_write bursts at queue depth 8 against a
 *           preallocated 4MiB blob — the synchronous-journal data path
 *           shape of blob-backed stores.
 *
 *   read:   4KiB spdk_blob_io_read bursts at queue depth 8 against the
 *           same preallocated blob — the blob read path.
 *
 * Every worker owns a private blobstore instance created on its own
 * spdk_thread (blobstore metadata operations are executed on the
 * initializing thread, so one instance per worker is the deployment
 * shape real applications use to scale blob I/O across cores — the
 * same per-worker topology the DPDK ring workload uses).  The backing
 * spdk_bs_dev is an anonymous-memory block device, so the measurements
 * profile the blob layer itself and never touch host storage or
 * hugepages.  EAL is initialized once per process with
 * no-huge/no-pci/1GiB in no-lcore-discovery mode; workers are plain
 * pthreads driving their spdk_thread with spdk_thread_poll().
 *
 * Every operation is timed with clock_gettime(CLOCK_MONOTONIC) so all
 * latencies are reported in nanoseconds.  After the warmup phase the
 * counters and latency samples (every 1024th global completion) are
 * collected for the configured duration and written to a JSON report
 * consumed by scripts/collect_spdk_benchmark.py.
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
#include <sys/mman.h>

#include <spdk/blob.h>
#include <spdk/env.h>
#include <spdk/version.h>
#include <spdk/thread.h>

#include <rte_lcore.h>

#define SAMPLE_PERIOD 1024

/* Each worker gets a private 256MiB in-memory bs_dev (anonymous mmap,
 * physically allocated on demand only for the pages actually touched). */
#define DEV_BLOCKLEN 512u
#define DEV_BLOCKCNT (256u * 1024u * 1024u / DEV_BLOCKLEN)

/* io workloads: one 4MiB blob per worker (4 clusters of the default
 * 1MiB cluster size), 4KiB operations at queue depth 8. */
#define IO_CLUSTERS 4u
#define IO_UNITS_PER_OP 8u                          /* 8 * 512B = 4KiB */
#define IO_QD 8u

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
    /*
     * SPDK's global object bookkeeping (io-device registry, thread
     * registry, shared mempools) is serialized with spinlocks inside
     * the library, which collapses when dozens of oversubscribed
     * workers touch it at the same time.  The per-worker blobstore
     * setup and teardown only ever run once each, so they take this
     * mutex and run one at a time; the measured run loop stays fully
     * parallel and never touches this mutex.
     */
    pthread_mutex_t stage_mutex;
};

struct worker_ctx {
    struct shared *sh;
    int worker_index;
    uint64_t rng;

    /* per-worker SPDK objects (this pthread is the bs md thread) */
    struct spdk_thread *thread;
    struct spdk_bs_dev *bs_dev;
    struct spdk_blob_store *bs;
    struct spdk_io_channel *channel;
    struct spdk_blob *blob;

    /* operation state */
    int phase;              /* 0 = setup, 1 = run, 2 = drain, 3 = teardown */
    int in_flight;
    spdk_blob_id current_blobid;
    uint64_t op_start_ns;   /* submission timestamp of the in-flight op */
    uint64_t next_io_unit;  /* next 4KiB-aligned blob offset (io units) */
    void *payload;          /* 4KiB spdk_malloc buffer shared by io ops */
    int setup_error;
};

static uint64_t monotonic_ns(void) {
    struct timespec ts;
    if (clock_gettime(CLOCK_MONOTONIC, &ts) != 0) {
        fprintf(stderr, "[spdk-bench] ERROR: clock_gettime: %s\n",
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
            fprintf(stderr, "[spdk-bench] ERROR: sample buffer growth\n");
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

/* Record one completed operation: 1 op, its own latency reading. */
static void note_op(struct shared *sh, uint64_t op_ns) {
    unsigned long old_tick;
    unsigned long new_tick;

    if (!atomic_load(&sh->measuring)) {
        return;
    }
    atomic_fetch_add(&sh->operation_count, 1);
    old_tick = atomic_fetch_add(&sh->sample_tick, 1);
    new_tick = old_tick + 1;
    if ((old_tick / SAMPLE_PERIOD) != (new_tick / SAMPLE_PERIOD)) {
        record_sample(sh, op_ns);
    }
}

/* ---- anonymous-memory bs_dev ---- */

struct mem_bs_dev {
    struct spdk_bs_dev dev;     /* must stay first */
    uint8_t *data;
    uint64_t blockcnt;
};

static struct mem_bs_dev *mem_dev(struct spdk_bs_dev *dev) {
    return (struct mem_bs_dev *)dev;
}

/* The memory device needs no per-channel state, but the blobstore
 * requires create_channel to return a non-NULL device channel (it only
 * passes the pointer back to the device callbacks), so hand out a
 * small dummy object and free it on destroy. */
static struct spdk_io_channel *mem_create_channel(struct spdk_bs_dev *dev) {
    (void)dev;
    return (struct spdk_io_channel *)calloc(1, 64);
}

static void mem_destroy_channel(struct spdk_bs_dev *dev,
                                struct spdk_io_channel *ch) {
    (void)dev;
    free(ch);
}

static void mem_complete(struct spdk_bs_dev_cb_args *args, int bserrno) {
    args->cb_fn(args->channel, args->cb_arg, bserrno);
}

static void mem_read(struct spdk_bs_dev *dev, struct spdk_io_channel *ch,
                     void *payload, uint64_t lba, uint32_t lba_count,
                     struct spdk_bs_dev_cb_args *args) {
    struct mem_bs_dev *m = mem_dev(dev);
    (void)ch;
    memcpy(payload, m->data + lba * DEV_BLOCKLEN,
           (size_t)lba_count * DEV_BLOCKLEN);
    mem_complete(args, 0);
}

static void mem_write(struct spdk_bs_dev *dev, struct spdk_io_channel *ch,
                      void *payload, uint64_t lba, uint32_t lba_count,
                      struct spdk_bs_dev_cb_args *args) {
    struct mem_bs_dev *m = mem_dev(dev);
    (void)ch;
    memcpy(m->data + lba * DEV_BLOCKLEN, payload,
           (size_t)lba_count * DEV_BLOCKLEN);
    mem_complete(args, 0);
}

static void mem_readv(struct spdk_bs_dev *dev, struct spdk_io_channel *ch,
                      struct iovec *iov, int iovcnt, uint64_t lba,
                      uint32_t lba_count, struct spdk_bs_dev_cb_args *args) {
    struct mem_bs_dev *m = mem_dev(dev);
    size_t offset = 0;
    (void)ch;
    for (int i = 0; i < iovcnt && offset < (size_t)lba_count * DEV_BLOCKLEN;
         i++) {
        size_t len = iov[i].iov_len;
        if (offset + len > (size_t)lba_count * DEV_BLOCKLEN) {
            len = (size_t)lba_count * DEV_BLOCKLEN - offset;
        }
        memcpy(iov[i].iov_base, m->data + lba * DEV_BLOCKLEN + offset, len);
        offset += len;
    }
    mem_complete(args, 0);
}

static void mem_writev(struct spdk_bs_dev *dev, struct spdk_io_channel *ch,
                       struct iovec *iov, int iovcnt, uint64_t lba,
                       uint32_t lba_count, struct spdk_bs_dev_cb_args *args) {
    struct mem_bs_dev *m = mem_dev(dev);
    size_t offset = 0;
    (void)ch;
    for (int i = 0; i < iovcnt && offset < (size_t)lba_count * DEV_BLOCKLEN;
         i++) {
        size_t len = iov[i].iov_len;
        if (offset + len > (size_t)lba_count * DEV_BLOCKLEN) {
            len = (size_t)lba_count * DEV_BLOCKLEN - offset;
        }
        memcpy(m->data + lba * DEV_BLOCKLEN + offset, iov[i].iov_base, len);
        offset += len;
    }
    mem_complete(args, 0);
}

static void mem_flush(struct spdk_bs_dev *dev, struct spdk_io_channel *ch,
                      struct spdk_bs_dev_cb_args *args) {
    (void)dev;
    (void)ch;
    mem_complete(args, 0);
}

static void mem_write_zeroes(struct spdk_bs_dev *dev,
                             struct spdk_io_channel *ch, uint64_t lba,
                             uint64_t lba_count,
                             struct spdk_bs_dev_cb_args *args) {
    struct mem_bs_dev *m = mem_dev(dev);
    (void)ch;
    memset(m->data + lba * DEV_BLOCKLEN, 0,
           (size_t)lba_count * DEV_BLOCKLEN);
    mem_complete(args, 0);
}

static void mem_unmap(struct spdk_bs_dev *dev, struct spdk_io_channel *ch,
                      uint64_t lba, uint64_t lba_count,
                      struct spdk_bs_dev_cb_args *args) {
    (void)dev;
    (void)ch;
    (void)lba;
    (void)lba_count;
    mem_complete(args, 0);
}

static void mem_destroy(struct spdk_bs_dev *dev) {
    struct mem_bs_dev *m = mem_dev(dev);
    if (m->data != NULL) {
        munmap(m->data, m->blockcnt * DEV_BLOCKLEN);
    }
    free(m);
}

static struct spdk_bs_dev *mem_bs_dev_create(uint64_t blockcnt) {
    struct mem_bs_dev *m = calloc(1, sizeof(*m));
    if (m == NULL) {
        return NULL;
    }
    m->data = mmap(NULL, blockcnt * DEV_BLOCKLEN, PROT_READ | PROT_WRITE,
                   MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (m->data == MAP_FAILED) {
        free(m);
        return NULL;
    }
    m->blockcnt = blockcnt;
    m->dev.create_channel = mem_create_channel;
    m->dev.destroy_channel = mem_destroy_channel;
    m->dev.destroy = mem_destroy;
    m->dev.read = mem_read;
    m->dev.write = mem_write;
    m->dev.readv = mem_readv;
    m->dev.writev = mem_writev;
    m->dev.flush = mem_flush;
    m->dev.write_zeroes = mem_write_zeroes;
    m->dev.unmap = mem_unmap;
    m->dev.blockcnt = blockcnt;
    m->dev.blocklen = DEV_BLOCKLEN;
    m->dev.phys_blocklen = DEV_BLOCKLEN;
    return &m->dev;
}

/* ---- asynchronous setup helpers (driven by spdk_thread_poll) ---- */

static void run_thread_until(struct worker_ctx *ctx, atomic_int *done) {
    while (!atomic_load(done)) {
        spdk_thread_poll(ctx->thread, 0, 0);
    }
}

static void bs_init_done(void *cb_arg, struct spdk_blob_store *bs,
                         int bserrno) {
    struct worker_ctx *ctx = cb_arg;
    if (bserrno != 0) {
        ctx->setup_error = bserrno;
        ctx->bs = NULL;
    } else {
        ctx->bs = bs;
    }
    atomic_store((atomic_int *)ctx->payload, 1);
}

static void create_done(void *cb_arg, spdk_blob_id blobid, int bserrno) {
    struct worker_ctx *ctx = cb_arg;
    if (bserrno != 0) {
        ctx->setup_error = bserrno;
    } else {
        ctx->current_blobid = blobid;
    }
    atomic_store((atomic_int *)ctx->payload, 1);
}

static void open_done(void *cb_arg, struct spdk_blob *blob, int bserrno) {
    struct worker_ctx *ctx = cb_arg;
    if (bserrno != 0) {
        ctx->setup_error = bserrno;
    } else {
        ctx->blob = blob;
    }
    atomic_store((atomic_int *)ctx->payload, 1);
}

static void resize_done(void *cb_arg, int bserrno) {
    struct worker_ctx *ctx = cb_arg;
    if (bserrno != 0) {
        ctx->setup_error = bserrno;
    }
    atomic_store((atomic_int *)ctx->payload, 1);
}

/* Each setup step reuses ctx->payload as the done flag slot; it is only
 * repurposed for the io payload after setup finishes. */
static int worker_setup(struct worker_ctx *ctx) {
    struct spdk_bs_opts opts;
    atomic_int done;

    ctx->thread = spdk_thread_create(NULL, NULL);
    if (ctx->thread == NULL) {
        return -1;
    }
    /* bind this pthread as the SPDK thread context (blobstore metadata
     * operations run on the initializing thread) */
    spdk_set_thread(ctx->thread);
    ctx->bs_dev = mem_bs_dev_create(DEV_BLOCKCNT);
    if (ctx->bs_dev == NULL) {
        return -1;
    }

    spdk_bs_opts_init(&opts, sizeof(opts));
    atomic_init(&done, 0);
    ctx->payload = &done;
    spdk_bs_init(ctx->bs_dev, &opts, bs_init_done, ctx);
    run_thread_until(ctx, &done);
    if (ctx->setup_error != 0 || ctx->bs == NULL) {
        return -1;
    }

    if (strcmp(ctx->sh->cfg.workload, "create") == 0) {
        /* the create workload needs no prepared blob */
        ctx->payload = spdk_malloc(64, 0, NULL, SPDK_ENV_NUMA_ID_ANY,
                                   SPDK_MALLOC_DMA);
        if (ctx->payload == NULL) {
            return -1;
        }
        return 0;
    }

    /* io workloads: create -> open -> resize -> sync one 4MiB blob */
    atomic_store(&done, 0);
    spdk_bs_create_blob(ctx->bs, create_done, ctx);
    run_thread_until(ctx, &done);
    if (ctx->setup_error != 0) {
        return -1;
    }
    atomic_store(&done, 0);
    spdk_bs_open_blob(ctx->bs, ctx->current_blobid, open_done, ctx);
    run_thread_until(ctx, &done);
    if (ctx->setup_error != 0 || ctx->blob == NULL) {
        return -1;
    }
    atomic_store(&done, 0);
    spdk_blob_resize(ctx->blob, IO_CLUSTERS, resize_done, ctx);
    run_thread_until(ctx, &done);
    if (ctx->setup_error != 0) {
        return -1;
    }
    atomic_store(&done, 0);
    spdk_blob_sync_md(ctx->blob, resize_done, ctx);
    run_thread_until(ctx, &done);
    if (ctx->setup_error != 0) {
        return -1;
    }

    ctx->channel = spdk_bs_alloc_io_channel(ctx->bs);
    if (ctx->channel == NULL) {
        return -1;
    }
    ctx->payload = spdk_malloc(IO_UNITS_PER_OP * DEV_BLOCKLEN, 0, NULL,
                               SPDK_ENV_NUMA_ID_ANY, SPDK_MALLOC_DMA);
    if (ctx->payload == NULL) {
        return -1;
    }
    return 0;
}

/* ---- workload operations ---- */

static void create_delete_done(void *cb_arg, int bserrno) {
    struct worker_ctx *ctx = cb_arg;
    ctx->in_flight = 0;
    if (bserrno != 0) {
        atomic_store(&ctx->sh->failed, 1);
        return;
    }
    note_op(ctx->sh, monotonic_ns() - ctx->op_start_ns);
}

static void create_op_done(void *cb_arg, spdk_blob_id blobid,
                           int bserrno) {
    struct worker_ctx *ctx = cb_arg;
    if (bserrno != 0) {
        ctx->in_flight = 0;
        atomic_store(&ctx->sh->failed, 1);
        return;
    }
    ctx->current_blobid = blobid;
    spdk_bs_delete_blob(ctx->bs, blobid, create_delete_done, ctx);
}

static void io_op_done(void *cb_arg, int bserrno) {
    struct worker_ctx *ctx = cb_arg;
    ctx->in_flight--;
    if (bserrno != 0) {
        atomic_store(&ctx->sh->failed, 1);
        return;
    }
    note_op(ctx->sh, monotonic_ns() - ctx->op_start_ns);
}

static void submit_op(struct worker_ctx *ctx) {
    const char *workload = ctx->sh->cfg.workload;

    if (strcmp(workload, "create") == 0) {
        ctx->op_start_ns = monotonic_ns();
        ctx->in_flight = 1;
        spdk_bs_create_blob(ctx->bs, create_op_done, ctx);
        return;
    }

    /* io workload: sequential 4KiB ops over the 4MiB blob, QD 8 */
    ctx->op_start_ns = monotonic_ns();
    ctx->in_flight++;
    if (strcmp(workload, "write") == 0) {
        spdk_blob_io_write(ctx->blob, ctx->channel, ctx->payload,
                           ctx->next_io_unit, IO_UNITS_PER_OP,
                           io_op_done, ctx);
    } else {
        spdk_blob_io_read(ctx->blob, ctx->channel, ctx->payload,
                          ctx->next_io_unit, IO_UNITS_PER_OP,
                          io_op_done, ctx);
    }
    ctx->next_io_unit += IO_UNITS_PER_OP;
    if (ctx->next_io_unit >= IO_CLUSTERS * (1024u * 1024u / DEV_BLOCKLEN)
            - IO_UNITS_PER_OP) {
        ctx->next_io_unit = 0;
    }
}

/* ---- worker teardown ---- */

static void unload_done(void *cb_arg, int bserrno) {
    struct worker_ctx *ctx = cb_arg;
    if (bserrno != 0) {
        ctx->setup_error = bserrno;
    }
    atomic_store((atomic_int *)ctx->payload, 1);
}

static void close_done(void *cb_arg, int bserrno) {
    struct worker_ctx *ctx = cb_arg;
    if (bserrno != 0) {
        ctx->setup_error = bserrno;
    }
    atomic_store((atomic_int *)ctx->payload, 1);
}

static void worker_teardown(struct worker_ctx *ctx) {
    atomic_int done;

    atomic_init(&done, 0);
    ctx->payload = &done;
    if (ctx->blob != NULL) {
        spdk_blob_close(ctx->blob, close_done, ctx);
        run_thread_until(ctx, &done);
        ctx->blob = NULL;
        atomic_store(&done, 0);
    }
    if (ctx->channel != NULL) {
        spdk_bs_free_io_channel(ctx->channel);
        ctx->channel = NULL;
    }
    if (ctx->bs != NULL) {
        spdk_bs_unload(ctx->bs, unload_done, ctx);
        run_thread_until(ctx, &done);
        ctx->bs = NULL;
    }
    spdk_thread_exit(ctx->thread);
    /* let the thread library finish releasing the thread (bounded wait) */
    {
        uint64_t deadline = monotonic_ns() + 1000000000ULL;
        while (!spdk_thread_is_exited(ctx->thread)
               && monotonic_ns() < deadline) {
            spdk_thread_poll(ctx->thread, 0, 0);
        }
        if (!spdk_thread_is_exited(ctx->thread)) {
            fprintf(stderr,
                    "[spdk-bench] ERROR: worker %d spdk_thread did not exit\n",
                    ctx->worker_index);
            ctx->setup_error = -ETIMEDOUT;
            atomic_store(&ctx->sh->failed, 1);
        }
    }
    spdk_thread_destroy(ctx->thread);
    ctx->thread = NULL;
}

/* ---- worker main ---- */

static void *worker_main(void *arg) {
    struct worker_ctx *ctx = arg;
    struct shared *sh = ctx->sh;
    int qd = strcmp(sh->cfg.workload, "create") == 0 ? 1 : (int)IO_QD;

    /*
     * Register this pthread as a DPDK non-EAL thread so it gets its
     * own lcore identity: the SPDK thread library allocates its
     * message objects from a shared DPDK mempool, and without a
     * per-lcore cache every worker would hammer the pool's common
     * MP/SC ring, which collapses under thread-count oversubscription
     * (the same CAS contention the DPDK ring workload avoids with
     * per-worker SP/SC rings).  rte_thread_register() only assigns
     * lcore bookkeeping — thread affinity is untouched.
     */
    if (rte_thread_register() != 0) {
        fprintf(stderr,
                "[spdk-bench] ERROR: worker %d rte_thread_register failed\n",
                ctx->worker_index);
        atomic_store(&sh->failed, 1);
        return NULL;
    }

    pthread_mutex_lock(&sh->stage_mutex);
    int setup_status = worker_setup(ctx);
    pthread_mutex_unlock(&sh->stage_mutex);
    if (setup_status != 0) {
        fprintf(stderr,
                "[spdk-bench] ERROR: worker %d blobstore setup failed: %d\n",
                ctx->worker_index, ctx->setup_error);
        atomic_store(&sh->failed, 1);
        if (ctx->thread != NULL) {
            pthread_mutex_lock(&sh->stage_mutex);
            worker_teardown(ctx);
            pthread_mutex_unlock(&sh->stage_mutex);
        }
        rte_thread_unregister();
        return NULL;
    }

    ctx->rng = 0x9E3779B97F4A7C15ULL * (uint64_t)(ctx->worker_index + 1)
        + (uint64_t)monotonic_ns();
    (void)next_random(&ctx->rng);

    while (!atomic_load(&sh->shutting_down) || ctx->in_flight > 0) {
        if (!atomic_load(&sh->shutting_down) && ctx->in_flight < qd) {
            submit_op(ctx);
        }
        spdk_thread_poll(ctx->thread, 0, 0);
    }

    pthread_mutex_lock(&sh->stage_mutex);
    worker_teardown(ctx);
    pthread_mutex_unlock(&sh->stage_mutex);
    rte_thread_unregister();
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
    /* official runtime API: the version of the linked SPDK build */
    printf("spdk-version=%s\n", SPDK_VERSION_STRING);
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
                "[spdk-bench] ERROR: option --%s must be an integer "
                "between %d and %d (got '%s')\n",
                key, minimum, maximum, value);
        exit(1);
    }
    return (int)parsed;
}

static void usage_exit(void) {
    fprintf(stderr,
            "usage: spdk_benchmark --workload create|write|read "
            "--threads N --warmup-seconds N --duration-seconds N "
            "--scenario NAME --output FILE | --version\n");
    exit(1);
}

int main(int argc, char **argv) {
    struct shared sh;
    struct config cfg;
    struct spdk_env_opts env_opts;
    pthread_t *threads;
    struct worker_ctx *ctxs;
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
            || (strcmp(cfg.workload, "create") != 0
                && strcmp(cfg.workload, "write") != 0
                && strcmp(cfg.workload, "read") != 0)) {
        usage_exit();
    }

    /*
     * Initialize the SPDK environment (single lcore, no hugepages, no
     * PCI, 1GiB reserved memory) before any SPDK object is created.
     * EAL pins the main thread to the lcore-0 CPU, so save the original
     * affinity first and restore it afterwards — otherwise every worker
     * thread would inherit the single-core mask and serialize on one
     * CPU.
     */
    CPU_ZERO(&original_affinity);
    if (sched_getaffinity(0, sizeof(original_affinity),
                          &original_affinity) != 0) {
        fprintf(stderr, "[spdk-bench] ERROR: sched_getaffinity: %s\n",
                strerror(errno));
        return 1;
    }
    spdk_env_opts_init(&env_opts);
    env_opts.name = "spdk_benchmark";
    env_opts.core_mask = "0x1";
    env_opts.no_pci = true;
    env_opts.no_huge = true;
    env_opts.mem_size = 1024;
    if (spdk_env_init(&env_opts) != 0) {
        fprintf(stderr, "[spdk-bench] ERROR: spdk_env_init failed\n");
        return 1;
    }
    if (pthread_setaffinity_np(pthread_self(), sizeof(original_affinity),
                               &original_affinity) != 0) {
        fprintf(stderr, "[spdk-bench] ERROR: restoring thread affinity failed\n");
        return 1;
    }
    if (spdk_thread_lib_init(NULL, 0) != 0) {
        fprintf(stderr, "[spdk-bench] ERROR: spdk_thread_lib_init failed\n");
        return 1;
    }

    memset(&sh, 0, sizeof(sh));
    sh.cfg = cfg;
    atomic_init(&sh.measuring, 0);
    atomic_init(&sh.shutting_down, 0);
    atomic_init(&sh.failed, 0);
    atomic_init(&sh.operation_count, 0);
    atomic_init(&sh.sample_tick, 0);
    pthread_mutex_init(&sh.sample_mutex, NULL);
    pthread_mutex_init(&sh.stage_mutex, NULL);

    threads = calloc((size_t)cfg.threads, sizeof(pthread_t));
    ctxs = calloc((size_t)cfg.threads, sizeof(struct worker_ctx));
    if (threads == NULL || ctxs == NULL) {
        fprintf(stderr, "[spdk-bench] ERROR: thread setup failed\n");
        return 1;
    }
    for (int i = 0; i < cfg.threads; i++) {
        ctxs[i].sh = &sh;
        ctxs[i].worker_index = i;
        if (pthread_create(&threads[i], NULL, worker_main, &ctxs[i]) != 0) {
            fprintf(stderr, "[spdk-bench] ERROR: pthread_create failed\n");
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
        fprintf(stderr, "[spdk-bench] ERROR: a worker failed\n");
        return 1;
    }
    if (operations == 0) {
        fprintf(stderr, "[spdk-bench] ERROR: no operations were measured\n");
        return 1;
    }
    if (sh.sample_count == 0) {
        fprintf(stderr,
                "[spdk-bench] ERROR: no latency samples were collected\n");
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
        fprintf(stderr, "[spdk-bench] ERROR: cannot open %s: %s\n",
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
        fprintf(stderr, "[spdk-bench] ERROR: writing %s failed\n",
                cfg.output);
        return 1;
    }

    printf("[spdk-bench] scenario=%s workload=%s threads=%d "
           "operations=%" PRIu64 " ops/s=%.1f avgOp=%.1fns p99Op=%.1fns\n",
           cfg.scenario, cfg.workload, cfg.threads, operations,
           operations_per_second, avg_op_ns, p99_op_ns);

    free(threads);
    free(ctxs);
    free(sh.samples);
    pthread_mutex_destroy(&sh.sample_mutex);
    spdk_thread_lib_fini();
    return 0;
}
