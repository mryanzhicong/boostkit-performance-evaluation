/*
 * Run the server-free part of the upstream hiredis 1.5.0 test suite.
 *
 * ``test.c`` from the pinned source archive is included verbatim into this
 * translation unit (its own ``main`` is renamed), so the assertions executed
 * here are the upstream ones, not a re-implementation:
 *
 *   test_allocator_injection       custom allocator hooks
 *   test_format_commands           redisFormatCommand / redisFormatCommandArgv
 *   test_reply_reader              streaming RESP reply parser
 *   test_blocking_connection_errors error paths that need no server
 *   test_free_null                 freeReplyObject(NULL) / redisFree(NULL)
 *   test_nonblocking_connect_error_queue  Linux connection error queue
 *
 * The remaining upstream tests need a live Redis server and are intentionally
 * not part of this case; the case measures the parser/formatting library, not
 * network round trips.
 */

#define _GNU_SOURCE
#define main hiredis_upstream_test_main
#include "test.c"
#undef main

#ifndef HIREDIS_EXPECT_LOCAL_TESTS
#define HIREDIS_EXPECT_LOCAL_TESTS 77
#endif

int main(void) {
    test_allocator_injection();
    test_format_commands();
    test_reply_reader();
    test_blocking_connection_errors();
    test_free_null();
#ifdef __linux__
    test_nonblocking_connect_error_queue();
#endif

    printf("\nlocal tests=%d fails=%d skips=%d\n", tests, fails, skips);
    printf("PERF-CHECK name=local_tests_failed expected=0 actual=%d status=%s\n",
           fails, fails == 0 ? "ok" : "failed");
    printf("PERF-CHECK name=local_tests_passed expected=%d actual=%d status=%s\n",
           HIREDIS_EXPECT_LOCAL_TESTS, tests - fails,
           (tests - fails) == HIREDIS_EXPECT_LOCAL_TESTS ? "ok" : "failed");
    printf("PERF-CHECK name=local_tests_skipped expected=0 actual=%d status=%s\n",
           skips, skips == 0 ? "ok" : "failed");
    printf("PERF-RESULT status=%s\n",
           (fails == 0 && tests - fails == HIREDIS_EXPECT_LOCAL_TESTS) ? "ok" : "failed");
    return (fails == 0 && tests - fails == HIREDIS_EXPECT_LOCAL_TESTS) ? 0 : 1;
}
