#include <unistd.h>

#include "opts.h"
#include "util.h"

struct opts parse_opts(config_t *cfg) {
    struct opts opts = {
        .gv_out = "/tmp/pacwall.gv",
        .png_out = "/tmp/pacwall.png"
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

    config_lookup_string(cfg, "output.graphviz", &opts.gv_out);
    config_lookup_string(cfg, "output.png", &opts.png_out);

    return opts;
}


