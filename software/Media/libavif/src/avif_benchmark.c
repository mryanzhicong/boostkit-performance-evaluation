// libavif benchmark driver: measures AVIF encode/decode latency through the
// official libavif API over a fixed, deterministically generated image set.
//
// The libavif project ships no benchmark tool: aviftest is a functional
// sweep, avifyuv is a color-conversion checker, and the avifenc/avifdec
// apps print no timing.  This driver only calls the public API exactly as
// those official apps do (avifEncoderAddImage/Finish, avifDecoder
// SetIOMemory/Parse/NextImage with the avifenc defaults speed=6,
// quality=60); the code under test is 100% the official library build
// statically linked with its official pinned codec (aom v3.14.1).
//
// Workloads (fixed LCG content, identical on every architecture):
//   1920x1080_yuv420_8bpc, 3840x2160_yuv420_8bpc, 1920x1080_yuv444_10bpc
// Scenarios: {encode, decode} x workloads x threads {1, 4, 16}
//
// Output (one line per scenario, pipe-separated, parsed by the collect
// script):
//   AVIFBENCH|<op>|<load>|<threads>|<median_ns>|<min_ns>|<max_ns>|<samples>
//
// Modes:
//   (none)     full 18-scenario matrix (with warmup runs)
//   --smoke    first workload, first thread count, one measured run

#include "avif/avif.h"

#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

typedef struct {
    const char *name;
    uint32_t width;
    uint32_t height;
    avifPixelFormat format;
    uint32_t depth;
} workload_t;

static const workload_t WORKLOADS[] = {
    { "1920x1080_yuv420_8bpc", 1920, 1080, AVIF_PIXEL_FORMAT_YUV420, 8 },
    { "3840x2160_yuv420_8bpc", 3840, 2160, AVIF_PIXEL_FORMAT_YUV420, 8 },
    { "1920x1080_yuv444_10bpc", 1920, 1080, AVIF_PIXEL_FORMAT_YUV444, 10 },
};

static const int THREADS_LADDER[] = { 1, 4, 16 };

#define WARMUP_RUNS 1

static uint64_t now_ns(void)
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (uint64_t)ts.tv_sec * 1000000000ull + (uint64_t)ts.tv_nsec;
}

static uint32_t lcg_next(uint32_t *state)
{
    *state = *state * 1664525u + 1013904223u;
    return *state;
}

// Fill the YUV planes with a fixed pseudo-random pattern (per-plane seed,
// full sample range) so every run on every architecture encodes the exact
// same bytes.
static void fill_planes(avifImage *image)
{
    const uint32_t maxSample = (1u << image->depth) - 1u;
    static const uint32_t seeds[3] = { 0x2f6e2b1u, 0x9e3779b9u, 0x7f4a7c15u };
    for (int plane = 0; plane < 3; ++plane) {
        uint32_t state = seeds[plane];
        uint32_t width = image->width;
        uint32_t height = image->height;
        if (plane != 0) {
            if (image->yuvFormat == AVIF_PIXEL_FORMAT_YUV420) {
                width /= 2;
                height /= 2;
            } else if (image->yuvFormat == AVIF_PIXEL_FORMAT_YUV422) {
                width /= 2;
            }
        }
        for (uint32_t y = 0; y < height; ++y) {
            if (image->depth == 8) {
                uint8_t *row = image->yuvPlanes[plane] + (size_t)y * image->yuvRowBytes[plane];
                for (uint32_t x = 0; x < width; ++x) {
                    row[x] = (uint8_t)(lcg_next(&state) >> 24);
                }
            } else {
                uint16_t *row = (uint16_t *)(image->yuvPlanes[plane] + (size_t)y * image->yuvRowBytes[plane]);
                for (uint32_t x = 0; x < width; ++x) {
                    row[x] = (uint16_t)(lcg_next(&state) % (maxSample + 1u));
                }
            }
        }
    }
}

static int compare_uint64(const void *a, const void *b)
{
    uint64_t va = *(const uint64_t *)a;
    uint64_t vb = *(const uint64_t *)b;
    return (va > vb) - (va < vb);
}

static int encode_once(const avifImage *image, int threads, avifRWData *output)
{
    avifEncoder *encoder = avifEncoderCreate();
    encoder->maxThreads = threads;
    encoder->speed = 6;    // avifenc default (AVIF_SPEED_DEFAULT maps to 6)
    encoder->quality = 60; // avifenc default quality
    avifResult result = avifEncoderAddImage(encoder, image, 1, AVIF_ADD_IMAGE_FLAG_SINGLE);
    if (result == AVIF_RESULT_OK) {
        result = avifEncoderFinish(encoder, output);
    }
    int ok = (result == AVIF_RESULT_OK);
    avifEncoderDestroy(encoder);
    return ok;
}

static int decode_once(const uint8_t *data, size_t size, int threads)
{
    avifDecoder *decoder = avifDecoderCreate();
    decoder->maxThreads = threads;
    int ok = 0;
    if (avifDecoderSetIOMemory(decoder, data, size) == AVIF_RESULT_OK &&
        avifDecoderParse(decoder) == AVIF_RESULT_OK &&
        avifDecoderNextImage(decoder) == AVIF_RESULT_OK) {
        ok = 1;
    }
    avifDecoderDestroy(decoder);
    return ok;
}

int main(int argc, char **argv)
{
    const int smoke = (argc > 1 && strcmp(argv[1], "--smoke") == 0);
    printf("AVIFBENCH version libavif %s\n", avifVersion());

    const size_t workloads = smoke ? 1 : sizeof(WORKLOADS) / sizeof(WORKLOADS[0]);
    const size_t ladder = smoke ? 1 : sizeof(THREADS_LADDER) / sizeof(THREADS_LADDER[0]);
    int failures = 0;

    for (size_t w = 0; w < workloads; ++w) {
        const workload_t *work = &WORKLOADS[w];
        avifImage *image = avifImageCreate(work->width, work->height, work->depth, work->format);
        avifImageAllocatePlanes(image, AVIF_PLANES_YUV);
        fill_planes(image);

        // Per-workload run counts: 1080p encode 10 runs, 4K encode 5 runs;
        // decoding is several times faster, so it gets twice as many runs.
        const int encodeRuns = smoke ? 1 : (work->width >= 3840 ? 5 : 10);
        const int decodeRuns = smoke ? 1 : (work->width >= 3840 ? 10 : 20);
        const int warmupRuns = smoke ? 0 : WARMUP_RUNS;

        for (size_t t = 0; t < ladder; ++t) {
            const int threads = THREADS_LADDER[t];

            // ---- encode ----
            uint64_t *samples = calloc(encodeRuns, sizeof(uint64_t));
            avifRWData encoded = AVIF_DATA_EMPTY;
            int ok = 1;
            for (int i = 0; i < warmupRuns && ok; ++i) {
                avifRWDataFree(&encoded);
                ok = encode_once(image, threads, &encoded);
            }
            for (int i = 0; i < encodeRuns && ok; ++i) {
                avifRWDataFree(&encoded);
                uint64_t start = now_ns();
                ok = encode_once(image, threads, &encoded);
                samples[i] = now_ns() - start;
            }
            if (!ok || encoded.size == 0) {
                fprintf(stderr, "ERROR: encode failed for %s threads=%d\n", work->name, threads);
                ++failures;
            } else {
                qsort(samples, encodeRuns, sizeof(uint64_t), compare_uint64);
                printf("AVIFBENCH|encode|%s|%d|%" PRIu64 "|%" PRIu64 "|%" PRIu64 "|%d\n",
                       work->name, threads,
                       samples[encodeRuns / 2], samples[0], samples[encodeRuns - 1], encodeRuns);
                fflush(stdout);

                // ---- decode (the encoded bytes from the same thread count) ----
                uint64_t *dsamples = calloc(decodeRuns, sizeof(uint64_t));
                int dok = 1;
                for (int i = 0; i < warmupRuns && dok; ++i) {
                    dok = decode_once(encoded.data, encoded.size, threads);
                }
                for (int i = 0; i < decodeRuns && dok; ++i) {
                    uint64_t start = now_ns();
                    dok = decode_once(encoded.data, encoded.size, threads);
                    dsamples[i] = now_ns() - start;
                }
                if (!dok) {
                    fprintf(stderr, "ERROR: decode failed for %s threads=%d\n", work->name, threads);
                    ++failures;
                } else {
                    qsort(dsamples, decodeRuns, sizeof(uint64_t), compare_uint64);
                    printf("AVIFBENCH|decode|%s|%d|%" PRIu64 "|%" PRIu64 "|%" PRIu64 "|%d\n",
                           work->name, threads,
                           dsamples[decodeRuns / 2], dsamples[0], dsamples[decodeRuns - 1], decodeRuns);
                    fflush(stdout);
                }
                free(dsamples);
            }
            avifRWDataFree(&encoded);
            free(samples);
        }

        avifImageDestroy(image);
    }

    if (failures) {
        fprintf(stderr, "ERROR: %d scenario(s) failed\n", failures);
        return 1;
    }
    return 0;
}
