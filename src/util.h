#ifndef UTIL_H
#define UTIL_H

#include <sys/wait.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>

#define panic(fmt, ...) do {fprintf(stderr, fmt, __VA_ARGS__); exit(1);} while(0)

#define subprocess(exitcode, name, ...) \
    do { \
        if (!fork()) { \
            int null = open("/dev/null", O_WRONLY); \
            dup2(null, 1); \
            dup2(null, 2); \
            execlp(name, name, __VA_ARGS__, (char *)NULL); \
        } else { \
            wait(exitcode); \
            *exitcode = WEXITSTATUS(*exitcode); \
        } \
    } while(0)

#endif
