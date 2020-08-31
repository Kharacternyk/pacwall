#ifndef OPTS_H
#define OPTS_H

#include <libconfig.h>

struct opts {
    const char *output_graphviz;
    const char *output_png;
    const char *pacman_db;
    const char *appearance_graph;
    const char *appearance_package_common;
    const char *appearance_package_explicit;
    const char *appearance_dependency_hard;
    const char *appearance_dependency_optional;
    const char *hook;
};

struct opts parse_opts(config_t *cfg);

#endif
