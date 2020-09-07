#include "generate.h"
#include "opts.h"
#include "util.h"

int main(int argc, char **argv) {
    const struct opts opts = parse_opts();
    chdir_xdg("XDG_CACHE_HOME", ".cache/", "pacwall");
    generate_graph(&opts);

    subprocess_wait(subprocess_begin("twopi", "-Tpng",
                                     "-o", "pacwall.png",
                                     "pacwall.gv"), "twopi");

    if (opts.hook != NULL) {
        setenv("W", "./pacwall.png", 1);
        execlp(opts.shell, opts.shell, "-c", opts.hook, (char *)NULL);
        panic("Could not execute shell %s: %s", opts.shell, strerror(errno));
    }
}
