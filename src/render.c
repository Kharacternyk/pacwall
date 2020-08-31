#include "render.h"
#include "util.h"

void render_graph(const struct opts *opts) {
    int errorcode = 0;
    subprocess(&errorcode,
               "twopi", "-Tpng",
               "-o", opts->output_png,
               opts->output_graphviz);
    if (errorcode) {
        panic("Twopi returned %d.\n", errorcode);
    }
}
