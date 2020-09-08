#ifndef OPTS_H
#define OPTS_H

/* Options beginning with an underscore are CLI-only. */
struct opts {
    const char *hook;
    const char *shell;
    const char *db;
    const char *attributes_graph;
    const char *attributes_package_common;
    const char *attributes_package_implicit;
    const char *attributes_package_explicit;
    const char *attributes_package_orphan;
    const char *attributes_package_outdated;
    const char *attributes_dependency_common;
    const char *attributes_dependency_hard;
    const char *attributes_dependency_optional;
    int _hook_only;
};

struct opts parse_opts(int argc, char **argv);

#endif
