#ifndef OPTS_H
#define OPTS_H

#include <libconfig.h>

struct opts {
    const char *gv_out;
    const char *png_out;
    const char *pacman_db;
};

struct opts parse_opts(config_t *cfg);

#endif
