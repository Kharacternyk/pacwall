#include <alpm.h>

#include "generate.h"
#include "util.h"

static void write_updates(FILE *file, const struct opts *opts) {
    subprocess_wait(subprocess_begin("/usr/lib/pacwall/showupdates.sh",
                                     "updates.db",
                                     opts->attributes_package_outdated,
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

    FILE *file = fopen("pacwall.gv", "w");
    if (file == NULL) {
        alpm_release(alpm);
        panic("Could not create %s", "pacwall.gv");
    }

    fprintf(file, "strict digraph pacwall {\n");
    fprintf(file, "node [%s];\n", opts->attributes_package_common);
    fprintf(file, "edge [%s];\n", opts->attributes_dependency_common);
    while (pkgs) {
        fprintf(file, "\n");

        if (alpm_pkg_get_reason(pkgs->data) == ALPM_PKG_REASON_EXPLICIT) {
            fprintf(file, "\"%s\" [%s];\n",
                    alpm_pkg_get_name(pkgs->data), opts->attributes_package_explicit);
        } else {
            fprintf(file, "\"%s\" [%s];\n",
                    alpm_pkg_get_name(pkgs->data), opts->attributes_package_implicit);
        }

        alpm_list_t *requiredby = alpm_pkg_compute_requiredby(pkgs->data);

        /* Orphan */
        if (alpm_pkg_get_reason(pkgs->data) == ALPM_PKG_REASON_DEPEND &&
                requiredby == NULL) {
            fprintf(file, "\"%s\" [%s];\n",
                    alpm_pkg_get_name(pkgs->data), opts->attributes_package_orphan);
        }

        /* Direct dependencies */
        while (requiredby) {
            fprintf(file, "\"%s\" -> \"%s\" [%s];\n", (char *)requiredby->data,
                    alpm_pkg_get_name(pkgs->data), opts->attributes_dependency_hard);
            requiredby = requiredby->next;
        }
        FREELIST(requiredby);

        /* Optional dependencies */
        alpm_list_t *optionalfor = alpm_pkg_compute_optionalfor(pkgs->data);
        while (optionalfor) {
            fprintf(file, "\"%s\" -> \"%s\" [%s];\n", (char *)optionalfor->data,
                    alpm_pkg_get_name(pkgs->data), opts->attributes_dependency_optional);
            optionalfor = optionalfor->next;
        }
        FREELIST(optionalfor);

        pkgs = pkgs->next;
    }

    /* Updates */
    if (fetch_pid > 0) {
        subprocess_wait(fetch_pid, "/usr/lib/pacwall/fetchupdates.sh");
    }
    write_updates(file, opts);

    /* Global attributes */
    fprintf(file, "\n%s\n}\n", opts->attributes_graph);

    fclose(file);
    alpm_release(alpm);
}
