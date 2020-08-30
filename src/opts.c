#include "opts.h"

struct opts parse_opts(config_t *cfg) {
    struct opts defaults = {
        .gv_out = "/tmp/pacwall.gv",
        .png_out = "/tmp/pacwall.png"
    };
    /*TODO*/
    return defaults;
}


