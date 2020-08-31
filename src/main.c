#include "generate.h"
#include "opts.h"
#include "util.h"

int main(int argc, char **argv) {
    config_t cfg;
    config_init(&cfg);
    const struct opts opts = parse_opts(&cfg);

    generate_graph(&opts);

    int errorcode = 0;
    subprocess(&errorcode,
               "twopi", "-Tpng",
               "-o", opts.output_png,
               opts.output_graphviz);
    if (errorcode) {
        panic("Twopi returned %d.\n", errorcode);
    }

    if (opts.hook != NULL) {
        errorcode = system(opts.hook);
        if (errorcode) {
            panic("Hook returned %d.\n", errorcode);
        }
    }
}
