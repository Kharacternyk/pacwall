#include <alpm.h>

#include "generate.h"
#include "util.h"

void generate_graph(const struct opts *opts) {
    alpm_errno_t error = 0;
    alpm_handle_t *alpm = alpm_initialize("/", opts->pacman_db, &error);
    if (error) {
        panic("Could not read pacman database at %s.\n", opts->pacman_db);
    }

    alpm_db_t *db = alpm_get_localdb(alpm);
    alpm_list_t *pkgs = alpm_db_get_pkgcache(db);

    FILE *file = fopen(opts->gv_out, "w");
    if (file == NULL) {
        panic("Could not create %s.\n", opts->gv_out);
    }

    fprintf(file, "strict digraph G {\n");
    while (pkgs) {
        fprintf(file, "\"%s\";\n", alpm_pkg_get_name(pkgs->data));
        alpm_list_t *requiredby = alpm_pkg_compute_requiredby(pkgs->data);
        while (requiredby) {
            fprintf(file, "\"%s\" -> \"%s\";\n",
                    (char *)requiredby->data, alpm_pkg_get_name(pkgs->data));
            requiredby = requiredby->next;
        }
        FREELIST(requiredby);
        pkgs = pkgs->next;
    }
    fprintf(file, "}\n");

    fclose(file);
    alpm_release(alpm);
}
