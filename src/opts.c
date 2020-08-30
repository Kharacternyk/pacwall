#include <unistd.h>

#include "opts.h"
#include "util.h"

struct opts parse_opts(config_t *cfg) {
    struct opts opts = {
        .output_graphviz = "/tmp/pacwall.gv",
        .output_png = "/tmp/pacwall.png",
        .pacman_db = "/var/lib/pacman"
    };

    /*TODO: respect XDG_CONFIG_HOME*/
    chdir(getenv("HOME"));
    FILE *cfg_file = fopen(".config/pacwall/pacwall.conf", "r");
    if (cfg_file == NULL) {
        return opts;
    }
    if (!config_read(cfg, cfg_file)) {
        panic("Malformed config (line %d): %s\n",
              config_error_line(cfg),
              config_error_text(cfg));
    }
    fclose(cfg_file);

    config_lookup_string(cfg, "output.graphviz", &opts.output_graphviz);
    config_lookup_string(cfg, "output.png", &opts.output_png);
    config_lookup_string(cfg, "pacman.db", &opts.pacman_db);

    return opts;
}


