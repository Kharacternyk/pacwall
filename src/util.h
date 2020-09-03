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

#define panic(fmt, ...) ({fprintf(stderr, fmt "\n", __VA_ARGS__); exit(1);})

#define subprocess_begin(name, ...) ({ \
    pid_t pid = fork(); \
    if (pid < 0) { \
        panic("Could not execute fork(): %s", strerror(errno)); \
    } \
    if (pid == 0) { \
        execlp(name, name, __VA_ARGS__, (char *)NULL); \
        _exit(127); \
    } \
    pid; \
})

#define subprocess_wait(pid, name) ({ \
    int wstatus; \
    if (waitpid(pid, &wstatus, WUNTRACED) == -1) { \
        panic("Wait for %s failed: %s", name, strerror(errno)); \
    } \
    int exitcode = WEXITSTATUS(wstatus); \
    if (exitcode) { \
        panic("%s returned %d", name, exitcode); \
    } \
})

#define chdir_xdg(xdg_name, xdg_fallback, dir) do { \
    chdir(getenv("HOME")); \
    const char *xdg = getenv(xdg_name); \
    if (xdg == NULL) { \
        xdg = xdg_fallback; \
    } \
    mkdir(xdg, 0755); \
    if(chdir(xdg)) { \
        panic("Could not change the current directory to %s: %s", xdg, strerror(errno)); \
    } \
    mkdir(dir, 0755); \
    if(chdir(dir)) { \
        panic("Could not change the current directory to %s/%s: %s", xdg, dir, strerror(errno)); \
    } \
} while(0)

#endif
