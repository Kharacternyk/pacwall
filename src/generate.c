#include <alpm.h>

#include "generate.h"
#include "util.h"

static void fetch_updates(const struct opts *opts) {
    int pid = fork();
    if (pid == -1) {
        panic("Could not execute fork(): %s", strerror(errno));
    }
    if (pid == 0) {
        execlp(opts->showupdates, opts->showupdates,
               opts->attributes_package_outdated,
               "updates.gv",
               opts->pacman_db,
               "updates.db",
               (char *)NULL);
        _exit(1);
    }
}

static void write_updates(FILE *file, const struct opts *opts) {
    /*
     * It's important to not insert any fork() in between
     * fetch_updates() and write_updates().
     */
    int exitcode;
    wait(&exitcode);
    if (WEXITSTATUS(exitcode)) {
        panic("Could not execute showupdates.sh at %s\n", opts->showupdates);
        exit(1);
    }
    FILE *updates = fopen("updates.gv", "r");
    char c;
    while ((c = getc(updates)) != EOF) {
        putc(c, file);
    }
    fclose(updates);
}


void generate_graph(const struct opts *opts) {
    alpm_errno_t error = 0;
    alpm_handle_t *alpm = alpm_initialize("/", opts->pacman_db, &error);
    if (error) {
        alpm_release(alpm);
        panic("Could not read pacman database at %s\n", opts->pacman_db);
    }

    fetch_updates(opts);

    alpm_db_t *db = alpm_get_localdb(alpm);
    alpm_list_t *pkgs = alpm_db_get_pkgcache(db);

    FILE *file = fopen("pacwall.gv", "w");
    if (file == NULL) {
        alpm_release(alpm);
        panic("Could not create %s\n", "pacwall.gv");
    }

    fprintf(file, "strict digraph pacwall {\n");
    while (pkgs) {
        /* Common attributes */
        fprintf(file, "\"%s\" [%s];\n",
                alpm_pkg_get_name(pkgs->data), opts->attributes_package_common);

        /* Explicitly installed */
        if (alpm_pkg_get_reason(pkgs->data) == ALPM_PKG_REASON_EXPLICIT) {
            fprintf(file, "\"%s\" [%s];\n",
                    alpm_pkg_get_name(pkgs->data), opts->attributes_package_explicit);
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
    write_updates(file, opts);

    /* Global attributes */
    fprintf(file, "%s\n}\n", opts->attributes_graph);

    fclose(file);
    alpm_release(alpm);
}
