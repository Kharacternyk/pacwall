#ifndef OPTS_H
#define OPTS_H

#include <libconfig.h>

struct opts {
    const char *showupdates;
    const char *output_path;
    const char *output_updates;
    const char *output_fakedb;
    const char *output_graph;
    const char *pacman_db;
    const char *background;
    const char *attributes_graph;
    const char *attributes_package_common;
    const char *attributes_package_explicit;
    const char *attributes_package_orphan;
    const char *attributes_package_outdated;
    const char *attributes_dependency_hard;
    const char *attributes_dependency_optional;
};

struct opts parse_opts(config_t *cfg);

#endif
