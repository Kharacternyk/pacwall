#include "generate.h"
#include "opts.h"
#include "util.h"

int main(int argc, char **argv) {
    config_t cfg;
    config_init(&cfg);
    const struct opts opts = parse_opts(&cfg);

    chdir_xdg("XDG_CACHE_HOME", ".cache/", "pacwall");
    generate_graph(&opts);

    subprocess("twopi", "-Tpng",
               "-o", "pacwall.png",
               "pacwall.gv");
    subprocess("hsetroot",
               "-solid", opts.background,
               "-center", "pacwall.png");
}
