/*
 * Bring the loopback interface up, then exec the measured command.
 *
 * Measurements run inside ``unshare -n`` to guarantee they cannot depend on the
 * network.  A fresh network namespace starts with ``lo`` administratively down,
 * so the upstream hiredis test suite (which exercises connection error paths on
 * 127.0.0.1) cannot run there.  This tiny launcher raises ``lo`` and then
 * ``exec``s the real workload, so the measured PID is still the harness and the
 * namespace remains isolated from every other interface.
 */

#define _GNU_SOURCE
#include <net/if.h>
#include <stdio.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <unistd.h>

int main(int argc, char **argv) {
    int descriptor;
    struct ifreq request;

    if (argc < 2) {
        fprintf(stderr, "usage: netns_loopback_up COMMAND [ARGUMENTS...]\n");
        return 127;
    }

    descriptor = socket(AF_INET, SOCK_DGRAM, 0);
    if (descriptor >= 0) {
        memset(&request, 0, sizeof(request));
        strncpy(request.ifr_name, "lo", IFNAMSIZ - 1);
        if (ioctl(descriptor, SIOCGIFFLAGS, &request) == 0) {
            request.ifr_flags |= IFF_UP | IFF_RUNNING;
            (void)ioctl(descriptor, SIOCSIFFLAGS, &request);
        }
        close(descriptor);
    }

    execvp(argv[1], &argv[1]);
    perror("execvp");
    return 127;
}
