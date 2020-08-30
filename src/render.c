#include "render.h"
#include "util.h"

void render_graph(const struct opts *opts) {
    int errorcode = 0;
    subprocess(&errorcode,
               "twopi", "-Tpng",
               "-Nshape=point",
               "-Nheight=0.1",
               "-Nwidth=0.1",
               "-Earrowhead=normal",
               "-o", opts->png_out,
               opts->gv_out);
    if (errorcode) {
        panic("Twopi returned %d.\n", errorcode);
    }
}
