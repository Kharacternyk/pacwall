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
               opts.renderer,
               "-T", opts.output_format,
               "-o", opts.output_path,
               opts.output_graph);
    if (errorcode) {
        panic("%s returned %d\n", opts.renderer, errorcode);
    }

    if (opts.hook != NULL) {
        errorcode = system(opts.hook);
        if (errorcode) {
            panic("Hook returned %d\n", errorcode);
        }
    }
}
