#include <alpm.h>

#include "generate.h"
#include "util.h"

static void write_updates(FILE *file, const struct opts *opts) {
    subprocess_wait(subprocess_begin("/usr/lib/pacwall/showupdates.sh",
                                     "updates.db",
                                     opts->attributes.package.outdated,
                                     "updates.gv"), "/usr/lib/pacwall/showupdates.sh");
    FILE *updates = fopen("updates.gv", "r");
    char c;
    while ((c = getc(updates)) != EOF) {
        putc(c, file);
    }
    fclose(updates);
}


void generate_graph(pid_t fetch_pid, const struct opts *opts) {
    alpm_errno_t error = 0;
    alpm_handle_t *alpm = alpm_initialize("/", opts->db, &error);
    if (error) {
        alpm_release(alpm);
        panic("Could not read pacman database at %s", opts->db);
    }

    alpm_db_t *db = alpm_get_localdb(alpm);
    alpm_list_t *pkgs = alpm_db_get_pkgcache(db);

    struct {
        alpm_db_t *syncdb;
        const char *attributes;
    } *syncdb_attributes_map = calloc(sizeof * syncdb_attributes_map,
                                      opts->attributes.package.repository.length);
    for (size_t i = 0; i < opts->attributes.package.repository.length; ++i) {
        /* "*" becomes NULL and acts like a wildcard so that we can assign
         * attributes to foreign packages. */
        const char *name = opts->attributes.package.repository.entries[i].name;
        if (!strcmp(name, "*")) {
            syncdb_attributes_map[i].syncdb = NULL;
        } else {
            syncdb_attributes_map[i].syncdb = alpm_register_syncdb(alpm, name, 0);
            if (syncdb_attributes_map[i].syncdb == NULL) {
                alpm_release(alpm);
                panic("Could not register repository named '%s'", name);
            }
        }
        syncdb_attributes_map[i].attributes =
            opts->attributes.package.repository.entries[i].attributes;
    }

    FILE *file = fopen("pacwall.gv", "w");
    if (file == NULL) {
        alpm_release(alpm);
        panic("Could not create %s", "pacwall.gv");
    }

    fprintf(file, "strict digraph pacwall {\n");
    fprintf(file, "node [%s];\n", opts->attributes.package.common);
    fprintf(file, "edge [%s];\n", opts->attributes.dependency.common);
    while (pkgs) {
        alpm_pkg_t *pkg = pkgs->data;
        const char *name = alpm_pkg_get_name(pkg);

        fprintf(file, "\n");

        /* Explicit or implicit */
        if (alpm_pkg_get_reason(pkg) == ALPM_PKG_REASON_EXPLICIT) {
            fprintf(file, "\"%s\" [%s];\n", name, opts->attributes.package.explicit);
        } else {
            fprintf(file, "\"%s\" [%s];\n", name, opts->attributes.package.implicit);
        }

        /* Native (which repo) or foreign */
        for (size_t i = 0; i < opts->attributes.package.repository.length; ++i) {
            alpm_db_t *syncdb = syncdb_attributes_map[i].syncdb;
            const char *attributes = syncdb_attributes_map[i].attributes;
            /* NULL is a wildcard. */
            if (syncdb == NULL || alpm_db_get_pkg(syncdb, name)) {
                fprintf(file, "\"%s\" [%s];\n", name, attributes);
                break;
            }
        }

        alpm_list_t *requiredby = alpm_pkg_compute_requiredby(pkg);
        alpm_list_t *optionalfor = alpm_pkg_compute_optionalfor(pkg);

        /* Orphan or not */
        if (alpm_pkg_get_reason(pkg) == ALPM_PKG_REASON_DEPEND && requiredby == NULL) {
            fprintf(file, "\"%s\" [%s];\n", name, opts->attributes.package.orphan);
            /* Unneeded or not */
            if (optionalfor == NULL) {
                fprintf(file, "\"%s\" [%s];\n", name, opts->attributes.package.unneeded);
            }
        }

        /* Direct dependencies */
        while (requiredby) {
            fprintf(file, "\"%s\" -> \"%s\" [%s];\n", (char *)requiredby->data,
                    name, opts->attributes.dependency.hard);
            requiredby = requiredby->next;
        }
        FREELIST(requiredby);

        /* Optional dependencies */
        while (optionalfor) {
            fprintf(file, "\"%s\" -> \"%s\" [%s];\n", (char *)optionalfor->data,
                    name, opts->attributes.dependency.optional);
            optionalfor = optionalfor->next;
        }
        FREELIST(optionalfor);

        pkgs = pkgs->next;
    }
    alpm_release(alpm);

    /* Updates */
    if (fetch_pid > 0) {
        subprocess_wait(fetch_pid, "/usr/lib/pacwall/fetchupdates.sh");
    }
    write_updates(file, opts);

    /* Global attributes */
    fprintf(file, "\n%s\n}\n", opts->attributes.graph);

    fclose(file);

    /* Rendering */
    subprocess_wait(subprocess_begin("twopi", "-Tpng",
                                     "-o", "pacwall.png",
                                     "pacwall.gv"), "twopi");
}
