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

    /* Some bad practices here. The keys become pointers to alpm_db_t,
     * they are not (char *) names anymore. */
    struct opt_list *repo = opts->attributes.package.repository;
    while (repo) {
        repo->key = alpm_register_syncdb(alpm, repo->key, 0);
        repo = repo->next;
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
        struct opt_list *repo = opts->attributes.package.repository;
        while (repo) {
            if (alpm_db_get_pkg(repo->key, name)) {
                fprintf(file, "\"%s\" [%s];\n", name, (char *)repo->value);
                break;
            }
            repo = repo->next;
        }

        alpm_list_t *requiredby = alpm_pkg_compute_requiredby(pkg);

        /* Orphan or not */
        if (alpm_pkg_get_reason(pkg) == ALPM_PKG_REASON_DEPEND && requiredby == NULL) {
            fprintf(file, "\"%s\" [%s];\n", name, opts->attributes.package.orphan);
        }

        /* Direct dependencies */
        while (requiredby) {
            fprintf(file, "\"%s\" -> \"%s\" [%s];\n", (char *)requiredby->data,
                    name, opts->attributes.dependency.hard);
            requiredby = requiredby->next;
        }
        FREELIST(requiredby);

        /* Optional dependencies */
        alpm_list_t *optionalfor = alpm_pkg_compute_optionalfor(pkg);
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
