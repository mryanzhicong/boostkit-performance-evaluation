/*
 * hiredis 1.5.0 RESP replay and command-formatting benchmark harness.
 *
 * The harness is case-owned but exercises only public hiredis APIs:
 *
 *   reader modes   redisReaderCreate / redisReaderFeed / redisReaderGetReply /
 *                  freeReplyObject  (the same streaming parser used by
 *                  redisCommand, redisGetReply and async.c)
 *   format modes   redisFormatCommand / redisFormatCommandArgv
 *
 * The measured command is one harness process; the harness itself loops a fixed
 * number of times over a pinned fixture so that the measured window is long
 * enough, and prints a machine-readable summary line plus PERF-CHECK/PERF-RESULT
 * lines.  The parser derives throughput from the whole-process wall clock and
 * cross-checks the harness' own reply/command counters against pinned values, so
 * a silently truncated replay cannot be reported as a valid measurement.
 *
 * Usage:
 *   resp_bench reader --mode <pipeline|bulk|nested|mixed|fragmented>
 *                     --fixture PATH --loops N --expected-replies N
 *   resp_bench format --mode <format_command|format_argv> --iterations N
 *   resp_bench --version
 */

#define _GNU_SOURCE
#include <errno.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "hiredis.h"

static int64_t now_ns(void) {
    struct timespec ts;

    if (clock_gettime(CLOCK_MONOTONIC, &ts) != 0) {
        return 0;
    }
    return (int64_t)ts.tv_sec * 1000000000LL + (int64_t)ts.tv_nsec;
}

static void print_version(void) {
    printf("%d.%d.%d\n", HIREDIS_MAJOR, HIREDIS_MINOR, HIREDIS_PATCH);
}

static int fail(const char *message, const char *detail) {
    fprintf(stderr, "%s%s%s\n", message, detail ? ": " : "", detail ? detail : "");
    return 2;
}

static int run_reader(const char *mode, const char *fixture_path, long loops,
                      long expected_replies) {
    FILE *file = fopen(fixture_path, "rb");
    char *buffer = NULL;
    long size = 0;
    long replies = 0;
    int fragmented = strcmp(mode, "fragmented") == 0;
    redisReader *reader = NULL;
    int64_t started, elapsed_ns;

    if (file == NULL) {
        return fail("cannot open the RESP fixture", fixture_path);
    }
    if (fseek(file, 0, SEEK_END) != 0 || (size = ftell(file)) <= 0 ||
        fseek(file, 0, SEEK_SET) != 0) {
        fclose(file);
        return fail("cannot size the RESP fixture", fixture_path);
    }
    buffer = malloc((size_t)size);
    if (buffer == NULL || fread(buffer, 1, (size_t)size, file) != (size_t)size) {
        fclose(file);
        free(buffer);
        return fail("cannot read the RESP fixture", fixture_path);
    }
    fclose(file);

    reader = redisReaderCreate();
    if (reader == NULL) {
        free(buffer);
        return fail("redisReaderCreate failed", NULL);
    }

    started = now_ns();
    for (long loop = 0; loop < loops; loop++) {
        size_t offset = 0;
        size_t chunk = fragmented ? 1 : 65536;
        while (offset < (size_t)size) {
            size_t feed = (size_t)size - offset;
            void *reply = NULL;
            if (feed > chunk) {
                feed = chunk;
            }
            if (redisReaderFeed(reader, buffer + offset, feed) != REDIS_OK) {
                fprintf(stderr, "redisReaderFeed failed: %s\n", reader->errstr);
                redisReaderFree(reader);
                free(buffer);
                return 3;
            }
            offset += feed;
            while (redisReaderGetReply(reader, &reply) == REDIS_OK && reply != NULL) {
                replies++;
                freeReplyObject(reply);
                reply = NULL;
            }
            if (reader->err != 0) {
                fprintf(stderr, "redisReaderGetReply failed: %s\n", reader->errstr);
                redisReaderFree(reader);
                free(buffer);
                return 3;
            }
            if (fragmented) {
                chunk = (chunk >= 4096) ? 1 : chunk * 2;
            }
        }
        {
            void *reply = NULL;
            while (redisReaderGetReply(reader, &reply) == REDIS_OK && reply != NULL) {
                replies++;
                freeReplyObject(reply);
                reply = NULL;
            }
        }
        if (reader->err != 0) {
            fprintf(stderr, "redisReaderGetReply (drain) failed: %s\n", reader->errstr);
            redisReaderFree(reader);
            free(buffer);
            return 3;
        }
    }
    elapsed_ns = now_ns() - started;
    redisReaderFree(reader);
    free(buffer);

    printf("mode=%s loops=%ld fixture_bytes=%ld bytes=%ld replies=%ld "
           "elapsed_ns=%" PRId64 " parse_mib_per_second=%.6f replies_per_second=%.6f\n",
           mode, loops, size, size * loops, replies, elapsed_ns,
           ((double)size * (double)loops / (1024.0 * 1024.0)) /
               ((double)elapsed_ns / 1e9),
           (double)replies / ((double)elapsed_ns / 1e9));
    printf("PERF-CHECK name=replies expected=%ld actual=%ld status=%s\n",
           expected_replies, replies, replies == expected_replies ? "ok" : "failed");
    printf("PERF-CHECK name=reader_error expected=none actual=none status=ok\n");
    printf("PERF-RESULT status=%s\n", replies == expected_replies ? "ok" : "failed");
    return replies == expected_replies ? 0 : 4;
}

static int run_format(const char *mode, long iterations) {
    int64_t started, elapsed_ns;
    long total_bytes = 0;
    int argv_mode = strcmp(mode, "format_argv") == 0;
    const char *argv[6] = {"SET", "key:0", "field:0", "value", "EX", "3600"};
    size_t argvlen[6] = {3, 5, 7, 5, 2, 4};

    started = now_ns();
    for (long index = 0; index < iterations; index++) {
        char *command = NULL;
        size_t length;
        if (argv_mode) {
            length = redisFormatCommandArgv(&command, 6, argv, argvlen);
        } else {
            length = redisFormatCommand(&command,
                                        "SET key:%ld field:%ld %ld EX 3600",
                                        index % 1000, index % 100, index);
        }
        if (length == 0 || command == NULL) {
            free(command);
            return fail("redisFormatCommand* returned an empty command", NULL);
        }
        total_bytes += (long)length;
        free(command);
    }
    elapsed_ns = now_ns() - started;
    printf("mode=%s iterations=%ld command_bytes=%ld elapsed_ns=%" PRId64
           " commands_per_second=%.6f\n",
           mode, iterations, total_bytes, elapsed_ns,
           (double)iterations / ((double)elapsed_ns / 1e9));
    printf("PERF-CHECK name=commands expected=%ld actual=%ld status=%s\n",
           iterations, iterations, "ok");
    printf("PERF-CHECK name=command_bytes expected=gt0 actual=%ld status=%s\n",
           total_bytes, total_bytes > 0 ? "ok" : "failed");
    printf("PERF-RESULT status=%s\n", total_bytes > 0 ? "ok" : "failed");
    return total_bytes > 0 ? 0 : 4;
}

static void usage(void) {
    fprintf(stderr,
            "usage:\n"
            "  resp_bench reader --mode MODE --fixture PATH --loops N "
            "--expected-replies N\n"
            "  resp_bench format --mode format_command|format_argv --iterations N\n"
            "  resp_bench --version\n");
}

int main(int argc, char **argv) {
    const char *mode = NULL;
    const char *fixture = NULL;
    const char *section = NULL;
    long loops = 0;
    long expected_replies = 0;
    long iterations = 0;

    for (int index = 1; index < argc; index++) {
        if (strcmp(argv[index], "--version") == 0) {
            print_version();
            return 0;
        }
        if (strcmp(argv[index], "reader") == 0 || strcmp(argv[index], "format") == 0) {
            section = argv[index];
            continue;
        }
        if (strcmp(argv[index], "--mode") == 0 && index + 1 < argc) {
            mode = argv[++index];
            continue;
        }
        if (strcmp(argv[index], "--fixture") == 0 && index + 1 < argc) {
            fixture = argv[++index];
            continue;
        }
        if (strcmp(argv[index], "--loops") == 0 && index + 1 < argc) {
            loops = atol(argv[++index]);
            continue;
        }
        if (strcmp(argv[index], "--expected-replies") == 0 && index + 1 < argc) {
            expected_replies = atol(argv[++index]);
            continue;
        }
        if (strcmp(argv[index], "--iterations") == 0 && index + 1 < argc) {
            iterations = atol(argv[++index]);
            continue;
        }
        usage();
        return 2;
    }
    if (section == NULL || mode == NULL) {
        usage();
        return 2;
    }
    if (strcmp(section, "reader") == 0) {
        if (fixture == NULL || loops <= 0 || expected_replies <= 0) {
            usage();
            return 2;
        }
        return run_reader(mode, fixture, loops, expected_replies);
    }
    if (iterations <= 0) {
        usage();
        return 2;
    }
    return run_format(mode, iterations);
}
