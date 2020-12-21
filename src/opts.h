#ifndef OPTS_H
#define OPTS_H

#include <sys/types.h>

/* Options beginning with an underscore are CLI-only. */
struct opts {
    const char *hook;
    const char *shell;
    const char *db;
    struct {
        const char *graph;
        struct {
            const char *common;
            const char *implicit;
            const char *explicit;
            const char *orphan;
            const char *unneeded;
            const char *outdated;
            const char *unresolved;
            struct {
                size_t length;
                struct {
                    const char *name;
                    const char *attributes;
                } * entries;
            } repository;
        } package;
        struct {
            const char *common;
            const char *hard;
            const char *optional;
        } dependency;
    } attributes;
    int _skip_fetch;
    int _skip_generate;
    int _skip_hook;
};

struct opts parse_opts(int argc, char **argv);

#endif
