/* rinetd_bench.c -- loopback TCP benchmark harness for the rinetd case.
 *
 * The case compares a direct loopback TCP path with the same path through a
 * running rinetd instance.  The harness has four modes; one process performs
 * exactly one role so the recorded wall clock and peak RSS belong to a single
 * measured step:
 *
 *   serve-sink    <port> <connections>
 *       Accept the expected number of connections and read until every peer
 *       shuts down its write side; prints one SERVER line with the byte count.
 *
 *   serve-echo    <port> <request_bytes>
 *       Accept one connection, echo every request of exactly request_bytes back
 *       to the client until the client closes; prints one SERVER line.
 *
 *   client-throughput <host> <port> <payload_bytes> <connections>
 *       Open the requested number of connections concurrently (threads), send
 *       payload_bytes on each, shut the write side down, drain the replies and
 *       report bytes per second over the whole operation.
 *
 *   client-latency <host> <port> <request_bytes> <round_trips> <discard>
 *       One connection, request/response round trips; the first discard trips
 *       are not recorded (in-process warm-up), the rest produce the mean and
 *       99th percentile round-trip time.
 *
 * All sockets are bound to 127.0.0.1: the case measures the forwarding path,
 * not the network stack of a real link.
 */

#define _POSIX_C_SOURCE 200809L

#include <arpa/inet.h>
#include <errno.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <poll.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <time.h>
#include <unistd.h>

#define LISTEN_BACKLOG 128
#define IO_BUFFER_BYTES (256 * 1024)
#define CONNECT_ATTEMPTS 600
#define CONNECT_DELAY_MS 10

static double now_seconds(void) {
    struct timespec ts;
    if (clock_gettime(CLOCK_MONOTONIC, &ts) != 0) {
        perror("clock_gettime");
        exit(2);
    }
    return (double)ts.tv_sec + (double)ts.tv_nsec * 1e-9;
}

static int parse_long(const char *text, long minimum, long maximum, const char *name) {
    char *end = NULL;
    errno = 0;
    const long value = strtol(text, &end, 10);
    if (errno != 0 || end == text || *end != '\0' || value < minimum || value > maximum) {
        fprintf(stderr, "invalid %s: %s\n", name, text);
        exit(2);
    }
    return (int)value;
}

static int listen_on_loopback(int port) {
    const int fd = socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0) {
        perror("socket");
        exit(3);
    }
    const int enable = 1;
    if (setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &enable, sizeof(enable)) != 0) {
        perror("setsockopt(SO_REUSEADDR)");
        exit(3);
    }
    struct sockaddr_in address;
    memset(&address, 0, sizeof(address));
    address.sin_family = AF_INET;
    address.sin_port = htons((unsigned short)port);
    address.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    if (bind(fd, (struct sockaddr *)&address, sizeof(address)) != 0) {
        perror("bind");
        exit(3);
    }
    if (listen(fd, LISTEN_BACKLOG) != 0) {
        perror("listen");
        exit(3);
    }
    return fd;
}

static int connect_loopback(int port) {
    struct sockaddr_in address;
    memset(&address, 0, sizeof(address));
    address.sin_family = AF_INET;
    address.sin_port = htons((unsigned short)port);
    address.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    int attempt;
    for (attempt = 0; attempt < CONNECT_ATTEMPTS; attempt++) {
        const int fd = socket(AF_INET, SOCK_STREAM, 0);
        if (fd < 0) {
            perror("socket");
            exit(3);
        }
        const int enable = 1;
        setsockopt(fd, IPPROTO_TCP, TCP_NODELAY, &enable, sizeof(enable));
        if (connect(fd, (struct sockaddr *)&address, sizeof(address)) == 0) {
            return fd;
        }
        close(fd);
        struct timespec delay = {0, CONNECT_DELAY_MS * 1000000L};
        nanosleep(&delay, NULL);
    }
    fprintf(stderr, "cannot connect to 127.0.0.1:%d after %d attempts: %s\n",
            port, CONNECT_ATTEMPTS, strerror(errno));
    exit(4);
}

static void write_all(int fd, const char *buffer, size_t length) {
    size_t written = 0;
    while (written < length) {
        const ssize_t result = send(fd, buffer + written, length - written, 0);
        if (result < 0) {
            if (errno == EINTR) {
                continue;
            }
            perror("send");
            exit(5);
        }
        written += (size_t)result;
    }
}

static size_t read_until_eof(int fd) {
    char buffer[IO_BUFFER_BYTES];
    size_t total = 0;
    for (;;) {
        const ssize_t result = recv(fd, buffer, sizeof(buffer), 0);
        if (result == 0) {
            return total;
        }
        if (result < 0) {
            if (errno == EINTR) {
                continue;
            }
            perror("recv");
            exit(5);
        }
        total += (size_t)result;
    }
}

static void read_exact(int fd, char *buffer, size_t length) {
    size_t received = 0;
    while (received < length) {
        const ssize_t result = recv(fd, buffer + received, length - received, 0);
        if (result == 0) {
            fprintf(stderr, "unexpected EOF after %zu of %zu bytes\n", received, length);
            exit(5);
        }
        if (result < 0) {
            if (errno == EINTR) {
                continue;
            }
            perror("recv");
            exit(5);
        }
        received += (size_t)result;
    }
}

static int serve_sink(int port, int expected_connections) {
    const int listener = listen_on_loopback(port);
    printf("LISTENING role=sink port=%d connections=%d\n", port, expected_connections);
    fflush(stdout);

    int accepted = 0;
    int closed = 0;
    size_t total = 0;
    int *sockets = calloc((size_t)expected_connections, sizeof(int));
    struct pollfd *pollers = calloc((size_t)expected_connections, sizeof(struct pollfd));
    if (sockets == NULL || pollers == NULL) {
        fprintf(stderr, "out of memory\n");
        return 3;
    }
    while (closed < expected_connections) {
        while (accepted < expected_connections) {
            const int client = accept(listener, NULL, NULL);
            if (client < 0) {
                if (errno == EINTR) {
                    continue;
                }
                if (errno == EAGAIN || errno == EWOULDBLOCK) {
                    break;
                }
                perror("accept");
                return 5;
            }
            sockets[accepted] = client;
            pollers[accepted].fd = client;
            pollers[accepted].events = POLLIN;
            accepted++;
        }
        const int ready = poll(pollers, (nfds_t)expected_connections, 1000);
        if (ready < 0) {
            if (errno == EINTR) {
                continue;
            }
            perror("poll");
            return 5;
        }
        int index;
        for (index = 0; index < expected_connections; index++) {
            if (pollers[index].fd < 0 || pollers[index].revents == 0) {
                continue;
            }
            char buffer[IO_BUFFER_BYTES];
            const ssize_t result = recv(pollers[index].fd, buffer, sizeof(buffer), 0);
            if (result > 0) {
                total += (size_t)result;
            } else if (result == 0) {
                close(pollers[index].fd);
                pollers[index].fd = -1;
                closed++;
            } else if (errno != EINTR && errno != EAGAIN && errno != EWOULDBLOCK) {
                perror("recv");
                return 5;
            }
        }
    }
    close(listener);
    printf("SERVER role=sink connections=%d bytes=%zu\n", expected_connections, total);
    return 0;
}

static int serve_echo(int port, int request_bytes) {
    const int listener = listen_on_loopback(port);
    printf("LISTENING role=echo port=%d request_bytes=%d\n", port, request_bytes);
    fflush(stdout);
    const int client = accept(listener, NULL, NULL);
    if (client < 0) {
        perror("accept");
        return 5;
    }
    char *buffer = malloc((size_t)request_bytes);
    if (buffer == NULL) {
        fprintf(stderr, "out of memory\n");
        return 3;
    }
    size_t total = 0;
    for (;;) {
        size_t received = 0;
        while (received < (size_t)request_bytes) {
            const ssize_t result = recv(client, buffer + received, (size_t)request_bytes - received, 0);
            if (result == 0) {
                received = 0;
                break;
            }
            if (result < 0) {
                if (errno == EINTR) {
                    continue;
                }
                perror("recv");
                return 5;
            }
            received += (size_t)result;
        }
        if (received == 0) {
            break;
        }
        write_all(client, buffer, (size_t)request_bytes);
        total += (size_t)request_bytes;
    }
    close(client);
    close(listener);
    printf("SERVER role=echo bytes=%zu\n", total);
    return 0;
}

struct client_task {
    int port;
    int payload_bytes;
    size_t bytes_sent;
    int failed;
};

static void *client_throughput_thread(void *argument) {
    struct client_task *task = argument;
    const int fd = connect_loopback(task->port);
    char *buffer = malloc((size_t)task->payload_bytes);
    if (buffer == NULL) {
        task->failed = 1;
        return NULL;
    }
    memset(buffer, 0x5a, (size_t)task->payload_bytes);
    size_t sent = 0;
    while (sent < (size_t)task->payload_bytes) {
        const size_t chunk = (size_t)task->payload_bytes - sent;
        write_all(fd, buffer + sent, chunk);
        sent += chunk;
    }
    shutdown(fd, SHUT_WR);
    read_until_eof(fd);
    close(fd);
    free(buffer);
    task->bytes_sent = sent;
    return NULL;
}

static int client_throughput(int port, int payload_bytes, int connections) {
    pthread_t *threads = calloc((size_t)connections, sizeof(pthread_t));
    struct client_task *tasks = calloc((size_t)connections, sizeof(struct client_task));
    if (threads == NULL || tasks == NULL) {
        fprintf(stderr, "out of memory\n");
        return 3;
    }
    int index;
    for (index = 0; index < connections; index++) {
        tasks[index].port = port;
        tasks[index].payload_bytes = payload_bytes;
        tasks[index].bytes_sent = 0;
        tasks[index].failed = 0;
    }
    const double started = now_seconds();
    for (index = 0; index < connections; index++) {
        if (pthread_create(&threads[index], NULL, client_throughput_thread, &tasks[index]) != 0) {
            perror("pthread_create");
            return 3;
        }
    }
    size_t total = 0;
    int failed = 0;
    for (index = 0; index < connections; index++) {
        pthread_join(threads[index], NULL);
        total += tasks[index].bytes_sent;
        failed += tasks[index].failed;
    }
    const double elapsed = now_seconds() - started;
    if (failed != 0 || elapsed <= 0.0) {
        fprintf(stderr, "throughput client failed: failed=%d elapsed=%g\n", failed, elapsed);
        return 5;
    }
    printf("RESULT mode=throughput payload=%d connections=%d seconds=%.9f bytes=%zu "
           "bytes_per_second=%.3f\n",
           payload_bytes, connections, elapsed, total, (double)total / elapsed);
    return 0;
}

static int compare_double(const void *left, const void *right) {
    const double a = *(const double *)left;
    const double b = *(const double *)right;
    return (a > b) - (a < b);
}

static int client_latency(int port, int request_bytes, int round_trips, int discard) {
    const int fd = connect_loopback(port);
    char *buffer = malloc((size_t)request_bytes);
    double *samples = calloc((size_t)round_trips, sizeof(double));
    double *sorted = calloc((size_t)round_trips, sizeof(double));
    if (buffer == NULL || samples == NULL || sorted == NULL) {
        fprintf(stderr, "out of memory\n");
        return 3;
    }
    memset(buffer, 0xa5, (size_t)request_bytes);
    const int total_round_trips = round_trips + discard;
    int recorded = 0;
    const double started = now_seconds();
    int index;
    for (index = 0; index < total_round_trips; index++) {
        const double before = now_seconds();
        write_all(fd, buffer, (size_t)request_bytes);
        read_exact(fd, buffer, (size_t)request_bytes);
        const double after = now_seconds();
        if (index >= discard) {
            samples[recorded++] = after - before;
        }
    }
    const double elapsed = now_seconds() - started;
    shutdown(fd, SHUT_WR);
    read_until_eof(fd);
    close(fd);
    if (recorded != round_trips || elapsed <= 0.0) {
        fprintf(stderr, "latency client failed: recorded=%d elapsed=%g\n", recorded, elapsed);
        return 5;
    }
    memcpy(sorted, samples, (size_t)recorded * sizeof(double));
    qsort(sorted, (size_t)recorded, sizeof(double), compare_double);
    double sum = 0.0;
    for (index = 0; index < recorded; index++) {
        sum += samples[index];
    }
    const double mean_us = (sum / (double)recorded) * 1e6;
    const double p99_us = sorted[(int)((double)(recorded - 1) * 0.99)] * 1e6;
    const size_t bytes = (size_t)recorded * (size_t)request_bytes * 2;
    printf("RESULT mode=latency request_bytes=%d round_trips=%d seconds=%.9f bytes=%zu "
           "rtt_mean_us=%.3f rtt_p99_us=%.3f bytes_per_second=%.3f\n",
           request_bytes, recorded, elapsed, bytes, mean_us, p99_us,
           (double)bytes / elapsed);
    return 0;
}

static void usage(const char *program) {
    fprintf(stderr,
            "usage:\n"
            "  %s serve-sink <port> <connections>\n"
            "  %s serve-echo <port> <request_bytes>\n"
            "  %s client-throughput <port> <payload_bytes> <connections>\n"
            "  %s client-latency <port> <request_bytes> <round_trips> <discard>\n",
            program, program, program, program);
}

int main(int argc, char **argv) {
    if (argc < 2) {
        usage(argv[0]);
        return 2;
    }
    if (strcmp(argv[1], "serve-sink") == 0) {
        if (argc != 4) {
            usage(argv[0]);
            return 2;
        }
        return serve_sink(parse_long(argv[2], 1, 65535, "port"),
                          parse_long(argv[3], 1, 4096, "connections"));
    }
    if (strcmp(argv[1], "serve-echo") == 0) {
        if (argc != 4) {
            usage(argv[0]);
            return 2;
        }
        return serve_echo(parse_long(argv[2], 1, 65535, "port"),
                          parse_long(argv[3], 1, 1048576, "request_bytes"));
    }
    if (strcmp(argv[1], "client-throughput") == 0) {
        if (argc != 5) {
            usage(argv[0]);
            return 2;
        }
        return client_throughput(parse_long(argv[2], 1, 65535, "port"),
                                 parse_long(argv[3], 1, 64 * 1024 * 1024, "payload_bytes"),
                                 parse_long(argv[4], 1, 4096, "connections"));
    }
    if (strcmp(argv[1], "client-latency") == 0) {
        if (argc != 6) {
            usage(argv[0]);
            return 2;
        }
        return client_latency(parse_long(argv[2], 1, 65535, "port"),
                              parse_long(argv[3], 1, 1048576, "request_bytes"),
                              parse_long(argv[4], 1, 10000000, "round_trips"),
                              parse_long(argv[5], 0, 10000000, "discard"));
    }
    fprintf(stderr, "unknown mode: %s\n", argv[1]);
    usage(argv[0]);
    return 2;
}
