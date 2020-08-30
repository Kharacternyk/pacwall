#ifndef OPTS_H
#define OPTS_H

#include <libconfig.h>

struct opts {
    const char *output_graphviz;
    const char *output_png;
    const char *pacman_db;
};

struct opts parse_opts(config_t *cfg);

#endif
