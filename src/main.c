#include "generate.h"
#include "opts.h"
#include "util.h"

int main(int argc, char **argv) {
    config_t cfg;
    config_init(&cfg);
    const struct opts opts = parse_opts(&cfg);

    generate_graph(&opts);

    subprocess("twopi", "-Tpng",
               "-o", opts.output_path,
               opts.output_graph);

    subprocess("hsetroot",
               "-solid", opts.background,
               "-center", opts.output_path);

}
