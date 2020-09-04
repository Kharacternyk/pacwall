#include <unistd.h>

#include "opts.h"
#include "util.h"

struct opts parse_opts(config_t *cfg) {
    struct opts opts = {
        .hook = NULL,
        .showupdates = "/usr/share/pacwall/showupdates.sh",
        .pacman_db = "/var/lib/pacman",
        .attributes_graph = "bgcolor=\"#00000000\"",
        .attributes_package_common =
        "shape=point, color=\"#dc322faa\", height=0.1",
        .attributes_package_explicit =
        "color=\"#268bd2aa\"",
        .attributes_package_orphan =
        "color=\"#859900aa\", peripheries=2",
        .attributes_package_outdated =
        "color=\"#b58900aa\", peripheries=3",
        .attributes_dependency_hard =
        "arrowhead=normal, color=\"#fdf6e322\"",
        .attributes_dependency_optional =
        "arrowhead=normal, style=dashed, color=\"#fdf6e322\"",
    };

    chdir_xdg("XDG_CONFIG_HOME", ".config/", "pacwall");
    FILE *cfg_file = fopen("pacwall.conf", "r");
    if (cfg_file == NULL) {
        return opts;
    }
    if (!config_read(cfg, cfg_file)) {
        panic("Malformed config (line %d): %s",
              config_error_line(cfg),
              config_error_text(cfg));
    }
    fclose(cfg_file);

    config_lookup_string(cfg, "hook", &opts.hook);
    config_lookup_string(cfg, "showupdates", &opts.showupdates);
    config_lookup_string(cfg, "pacman.db", &opts.pacman_db);
    config_lookup_string(cfg, "attributes.graph", &opts.attributes_graph);
    config_lookup_string(cfg, "attributes.package.common",
                         &opts.attributes_package_common);
    config_lookup_string(cfg, "attributes.package.explicit",
                         &opts.attributes_package_explicit);
    config_lookup_string(cfg, "attributes.package.orphan",
                         &opts.attributes_package_orphan);
    config_lookup_string(cfg, "attributes.package.outdated",
                         &opts.attributes_package_outdated);
    config_lookup_string(cfg, "attributes.dependency.hard",
                         &opts.attributes_dependency_hard);
    config_lookup_string(cfg, "attributes.dependency.optional",
                         &opts.attributes_dependency_optional);

    return opts;
}


