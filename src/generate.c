#include <alpm.h>

#include "generate.h"
#include "util.h"

void generate_graph(const struct opts *opts) {
    alpm_errno_t error = 0;
    alpm_handle_t *alpm = alpm_initialize("/", opts->pacman_db, &error);
    if (error) {
        alpm_release(alpm);
        panic("Could not read pacman database at %s.\n", opts->pacman_db);
    }

    alpm_db_t *db = alpm_get_localdb(alpm);
    alpm_list_t *pkgs = alpm_db_get_pkgcache(db);

    FILE *file = fopen(opts->output_graphviz, "w");
    if (file == NULL) {
        alpm_release(alpm);
        panic("Could not create %s.\n", opts->output_graphviz);
    }

    fprintf(file, "strict digraph G {\n");
    while (pkgs) {
        fprintf(file, "\"%s\" [%s];\n",
                alpm_pkg_get_name(pkgs->data), opts->appearance_package_common);

        alpm_list_t *requiredby = alpm_pkg_compute_requiredby(pkgs->data);
        while (requiredby) {
            fprintf(file, "\"%s\" -> \"%s\" [%s];\n", (char *)requiredby->data,
                    alpm_pkg_get_name(pkgs->data), opts->appearance_dependency_hard);
            requiredby = requiredby->next;
        }
        FREELIST(requiredby);

        pkgs = pkgs->next;
    }
    fprintf(file, "}\n");

    fclose(file);
    alpm_release(alpm);
}
