#include <alpm.h>

int main(int argc, char **argv) {
    alpm_errno_t error;
    alpm_handle_t *alpm = alpm_initialize("/", "/var/lib/pacman", &error);
    alpm_db_t *db = alpm_get_localdb(alpm);
    alpm_list_t *pkgs = alpm_db_get_pkgcache(db);

    printf("strict digraph G {\n");
    while (pkgs) {
        alpm_list_t *requiredby = alpm_pkg_compute_requiredby(pkgs->data);
        while (requiredby) {
            printf("\"%s\" -> \"%s\";\n",
                   (char *)requiredby->data, alpm_pkg_get_name(pkgs->data));
            requiredby = requiredby->next;
        }
        FREELIST(requiredby);
        pkgs = pkgs->next;
    }
    printf("}\n");

    alpm_release(alpm);
}
