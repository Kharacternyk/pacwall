#ifndef UTIL_H
#define UTIL_H

#include <sys/wait.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>

#define panic(fmt, ...) do {fprintf(stderr, fmt, __VA_ARGS__); exit(1);} while(0)

#define subprocess(name, ...) do { \
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
            panic("%s returned %d\n", name, exitcode); \
        } \
    } \
} while(0)

#define chdir_xdg(xdg_name, xdg_fallback, dir) do { \
    chdir(getenv("HOME")); \
    const char *xdg = getenv(xdg_name); \
    if (xdg == NULL) { \
        xdg = xdg_fallback; \
    } \
    mkdir(xdg, 0755); \
    if(chdir(xdg)) { \
        panic("Could not change the current directory to %s: %s\n", xdg, strerror(errno)); \
    } \
    mkdir(dir, 0755); \
    if(chdir(dir)) { \
        panic("Could not change the current directory to %s/%s: %s\n", xdg, dir, strerror(errno)); \
    } \
} while(0)

#endif
