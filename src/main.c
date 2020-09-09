#include "generate.h"
#include "opts.h"
#include "util.h"

int main(int argc, char **argv) {
    const struct opts opts = parse_opts(argc, argv);
    chdir_xdg("XDG_CACHE_HOME", ".cache/", "pacwall");

    pid_t fetch_pid = -1;
    fetch_pid = subprocess_begin("/usr/lib/pacwall/fetchupdates.sh",
                                 "updates.db", opts.db);
    generate_graph(fetch_pid, &opts);
    subprocess_wait(subprocess_begin("twopi", "-Tpng",
                                     "-o", "pacwall.png",
                                     "pacwall.gv"), "twopi");
    if (opts.hook != NULL) {
        setenv("W", "./pacwall.png", 1);
        execlp(opts.shell, opts.shell, "-c", opts.hook, (char *)NULL);
        panic("Could not execute shell %s: %s", opts.shell, strerror(errno));
    }
}
