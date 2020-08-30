#include <alpm.h>

#include "generate.h"
#include "util.h"

void generate_graph(const struct opts *opts) {
    alpm_errno_t error = 0;
    alpm_handle_t *alpm = alpm_initialize("/", "/var/lib/pacman", &error);
    if (error) {
        panic("%s.\n", "Can not create a handle for the pacman database");
    }

    alpm_db_t *db = alpm_get_localdb(alpm);
    alpm_list_t *pkgs = alpm_db_get_pkgcache(db);

    FILE *file = fopen(opts->gv_out, "w");
    if (file == NULL) {
        panic("%s.\n", "Can not create a temporary file for the graph");
    }

    fprintf(file, "strict digraph G {\n");
    while (pkgs) {
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
