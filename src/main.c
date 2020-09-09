#include "generate.h"
#include "opts.h"
#include "util.h"

int main(int argc, char **argv) {
    const struct opts opts = parse_opts(argc, argv);
    chdir_xdg("XDG_CACHE_HOME", ".cache/", "pacwall");

    pid_t fetch_pid = -1;
    if (!opts._skip_fetch) {
        fetch_pid = subprocess_begin("/usr/lib/pacwall/fetchupdates.sh",
                                     "updates.db", opts.db);
    }

    if (!opts._skip_generate) {
        generate_graph(fetch_pid, &opts);
        subprocess_wait(subprocess_begin("twopi", "-Tpng",
                                         "-o", "pacwall.png",
                                         "pacwall.gv"), "twopi");
    } else if (fetch_pid > 0) {
        subprocess_wait(fetch_pid, "/usr/lib/pacwall/fetchupdates.sh");
    }

    if (!opts._skip_hook && opts.hook != NULL) {
        setenv("W", "./pacwall.png", 1);
        execlp(opts.shell, opts.shell, "-c", opts.hook, (char *)NULL);
        panic("Could not execute shell %s: %s", opts.shell, strerror(errno));
    }
}
