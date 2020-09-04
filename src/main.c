#include "generate.h"
#include "opts.h"
#include "util.h"

int main(int argc, char **argv) {
    config_t cfg;
    config_init(&cfg);
    const struct opts opts = parse_opts(&cfg);

    chdir_xdg("XDG_CACHE_HOME", ".cache/", "pacwall");
    generate_graph(&opts);

    subprocess_wait(subprocess_begin("twopi", "-Tpng",
                                     "-o", "pacwall.png",
                                     "pacwall.gv"), "twopi");

    if (opts.hook != NULL) {
        setenv("W", "./pacwall.png", 1);
        execl("/bin/sh", "/bin/sh", "-c", opts.hook, (char *)NULL);
        panic("Could not execute /bin/sh: %s", strerror(errno));
    }
}
