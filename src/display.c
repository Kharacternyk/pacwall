#include "util.h"

void display_graph(const char *in_filename, const char *out_filename) {
    int errorcode;
    subprocess(&errorcode, "twopi", "-Tpng", "-o", out_filename, in_filename);
    if (errorcode) {
        panic("Twopi returned %d.\n", errorcode);
    }
}
