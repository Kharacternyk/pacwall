#ifndef UTIL_H
#define UTIL_H

#include <sys/wait.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdio.h>

#define panic(fmt, ...) do {fprintf(stderr, fmt, __VA_ARGS__); exit(1);} while(0)

#define subprocess(name, ...) \
    do { \
        int exitcode = 127; \
        if (!fork()) { \
            int null = open("/dev/null", O_WRONLY); \
            dup2(null, 1); \
            dup2(null, 2); \
            if (execlp(name, name, __VA_ARGS__, (char *)NULL)) { \
                _exit(127); \
            } \
        } else { \
            wait(&exitcode); \
            exitcode = WEXITSTATUS(exitcode); \
            if (exitcode) { \
                panic("%s returned %d", name, exitcode); \
            } \
        } \
    } while(0)

#endif
