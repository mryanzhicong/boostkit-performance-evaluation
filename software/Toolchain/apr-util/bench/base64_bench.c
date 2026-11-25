/*
 * APR-util 1.6.5 base64 encode/decode benchmark harness.
 *
 * Only public APR-util APIs are used:
 *
 *   apr_base64_encode_len / apr_base64_encode_binary
 *   apr_base64_decode_len / apr_base64_decode_binary
 *
 * Both functions operate on caller-owned buffers; the harness pre-allocates
 * them once and loops the codec over a pinned deterministic payload.  The
 * measured unit is one process, so the case derives throughput from the
 * whole-process wall clock while the harness reports its own internal timing
 * and validates every repetition:
 *
 *   encoded_length  == apr_base64_encode_len(payload_bytes) (incl. NUL)
 *   decoded_length  == payload_bytes for every loop iteration
 *   roundtrip       one full encode/decode/memcmp before and after the loop
 *
 * Usage:
 *   base64_bench encode|decode --payload PATH --loops N
 *   base64_bench --version
 */

#define _GNU_SOURCE
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "apr_base64.h"
#include "apr_pools.h"
#include "apr_version.h"
#include "apu_version.h"

static int64_t now_ns(void) {
    struct timespec ts;

    if (clock_gettime(CLOCK_MONOTONIC, &ts) != 0) {
        return 0;
    }
    return (int64_t)ts.tv_sec * 1000000000LL + (int64_t)ts.tv_nsec;
}

static int fail(const char *message, const char *detail) {
    fprintf(stderr, "%s%s%s\n", message, detail ? ": " : "", detail ? detail : "");
    return 2;
}

static unsigned char *read_payload(const char *path, int *length) {
    FILE *file = fopen(path, "rb");
    long size;
    unsigned char *buffer;

    if (file == NULL) {
        return NULL;
    }
    if (fseek(file, 0, SEEK_END) != 0 || (size = ftell(file)) <= 0 ||
        fseek(file, 0, SEEK_SET) != 0) {
        fclose(file);
        return NULL;
    }
    buffer = malloc((size_t)size);
    if (buffer == NULL || fread(buffer, 1, (size_t)size, file) != (size_t)size) {
        fclose(file);
        free(buffer);
        return NULL;
    }
    fclose(file);
    *length = (int)size;
    return buffer;
}

/* Returns 0 when a full encode/decode/memcmp round trip matches. */
static int roundtrip_matches(const unsigned char *payload, int payload_length) {
    int capacity = apr_base64_encode_len(payload_length);
    char *encoded = malloc((size_t)capacity);
    unsigned char *decoded = malloc((size_t)payload_length + 4);
    int encoded_length;
    int decoded_length;
    int status = -1;

    if (encoded == NULL || decoded == NULL) {
        free(encoded);
        free(decoded);
        return -1;
    }
    encoded_length = apr_base64_encode_binary(encoded, payload, payload_length);
    /* apr_base64_encode_binary() returns the length including the trailing
     * NUL, which equals apr_base64_encode_len(). */
    if (encoded_length == capacity) {
        decoded_length = apr_base64_decode_binary(decoded, encoded);
        status = (decoded_length == payload_length &&
                  memcmp(decoded, payload, (size_t)payload_length) == 0)
                     ? 0
                     : -1;
    }
    free(encoded);
    free(decoded);
    return status;
}

static int run_encode(const unsigned char *payload, int payload_length, long loops) {
    int capacity = apr_base64_encode_len(payload_length);
    char *encoded = malloc((size_t)capacity);
    int64_t total_out = 0;
    int encoded_length = 0;
    int64_t started, elapsed;
    int roundtrip;

    if (encoded == NULL) {
        return fail("cannot allocate the base64 output buffer", NULL);
    }
    roundtrip = roundtrip_matches(payload, payload_length);
    started = now_ns();
    for (long index = 0; index < loops; index++) {
        encoded_length = apr_base64_encode_binary(encoded, payload, payload_length);
        if (encoded_length != capacity) {
            free(encoded);
            return fail("apr_base64_encode_binary returned an unexpected length", NULL);
        }
        total_out += encoded_length - 1; /* exclude the trailing NUL */
    }
    elapsed = now_ns() - started;
    printf("mode=encode payload_bytes=%d loops=%ld input_bytes=%" PRId64
           " encoded_length=%d encoded_bytes=%" PRId64 " elapsed_ns=%" PRId64
           " mib_per_second=%.6f\n",
           payload_length, loops, (int64_t)payload_length * loops, encoded_length,
           total_out, elapsed,
           ((double)payload_length * (double)loops / (1024.0 * 1024.0)) /
               ((double)elapsed / 1e9));
    printf("PERF-CHECK name=encoded_length expected=%d actual=%d status=%s\n",
           capacity, encoded_length, encoded_length == capacity ? "ok" : "failed");
    printf("PERF-CHECK name=roundtrip expected=ok actual=%s status=%s\n",
           roundtrip == 0 ? "ok" : "failed", roundtrip == 0 ? "ok" : "failed");
    free(encoded);
    return roundtrip == 0 ? 0 : 4;
}

static int run_decode(const unsigned char *payload, int payload_length, long loops) {
    int capacity = apr_base64_encode_len(payload_length);
    char *encoded = malloc((size_t)capacity);
    unsigned char *decoded = malloc((size_t)payload_length + 4);
    int encoded_length;
    int decoded_length = 0;
    int64_t started, elapsed;
    int roundtrip;

    if (encoded == NULL || decoded == NULL) {
        free(encoded);
        free(decoded);
        return fail("cannot allocate the base64 buffers", NULL);
    }
    encoded_length = apr_base64_encode_binary(encoded, payload, payload_length);
    if (encoded_length != capacity) {
        free(encoded);
        free(decoded);
        return fail("cannot prepare the encoded input", NULL);
    }
    roundtrip = roundtrip_matches(payload, payload_length);
    started = now_ns();
    for (long index = 0; index < loops; index++) {
        decoded_length = apr_base64_decode_binary(decoded, encoded);
        if (decoded_length != payload_length) {
            free(encoded);
            free(decoded);
            return fail("apr_base64_decode_binary returned an unexpected length", NULL);
        }
    }
    elapsed = now_ns() - started;
    printf("mode=decode payload_bytes=%d loops=%ld encoded_length=%d"
           " decoded_bytes=%" PRId64 " elapsed_ns=%" PRId64 " mib_per_second=%.6f\n",
           payload_length, loops, encoded_length, (int64_t)payload_length * loops,
           elapsed,
           ((double)payload_length * (double)loops / (1024.0 * 1024.0)) /
               ((double)elapsed / 1e9));
    printf("PERF-CHECK name=decoded_length expected=%d actual=%d status=%s\n",
           payload_length, decoded_length, decoded_length == payload_length ? "ok" : "failed");
    printf("PERF-CHECK name=roundtrip expected=ok actual=%s status=%s\n",
           roundtrip == 0 ? "ok" : "failed", roundtrip == 0 ? "ok" : "failed");
    free(encoded);
    free(decoded);
    return roundtrip == 0 ? 0 : 4;
}

int main(int argc, char **argv) {
    const char *mode = NULL;
    const char *payload_path = NULL;
    long loops = 0;
    unsigned char *payload = NULL;
    int payload_length = 0;
    apr_pool_t *pool = NULL;
    int status;

    if (argc == 2 && strcmp(argv[1], "--version") == 0) {
        printf("apu=%d.%d.%d apr=%d.%d.%d\n", APU_MAJOR_VERSION, APU_MINOR_VERSION,
               APU_PATCH_VERSION, APR_MAJOR_VERSION, APR_MINOR_VERSION,
               APR_PATCH_VERSION);
        return 0;
    }
    for (int index = 1; index < argc; index++) {
        if (strcmp(argv[index], "encode") == 0 || strcmp(argv[index], "decode") == 0) {
            mode = argv[index];
        } else if (strcmp(argv[index], "--payload") == 0 && index + 1 < argc) {
            payload_path = argv[++index];
        } else if (strcmp(argv[index], "--loops") == 0 && index + 1 < argc) {
            loops = atol(argv[++index]);
        } else {
            fprintf(stderr, "usage: base64_bench encode|decode --payload PATH --loops N\n");
            return 2;
        }
    }
    if (mode == NULL || payload_path == NULL || loops <= 0) {
        fprintf(stderr, "usage: base64_bench encode|decode --payload PATH --loops N\n");
        return 2;
    }
    payload = read_payload(payload_path, &payload_length);
    if (payload == NULL) {
        return fail("cannot read the payload", payload_path);
    }
    if (apr_initialize() != APR_SUCCESS) {
        free(payload);
        return fail("apr_initialize failed", NULL);
    }
    if (apr_pool_create(&pool, NULL) != APR_SUCCESS) {
        apr_terminate();
        free(payload);
        return fail("apr_pool_create failed", NULL);
    }

    status = (strcmp(mode, "encode") == 0)
                 ? run_encode(payload, payload_length, loops)
                 : run_decode(payload, payload_length, loops);
    printf("PERF-CHECK name=payload_bytes expected=%d actual=%d status=%s\n",
           payload_length, payload_length, "ok");
    printf("PERF-RESULT status=%s\n", status == 0 ? "ok" : "failed");
    apr_pool_destroy(pool);
    apr_terminate();
    free(payload);
    return status == 0 ? 0 : 4;
}
