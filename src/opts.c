#include <libconfig.h>

#include "opts.h"
#include "util.h"

static void parse_cli_opts(struct opts *opts, int argc, char **argv) {
    while (argc-- > 1) {
        char *s = argv[argc];
        while (*s) {
            switch (*(s++)) {
            case '-':
                break;
            case 'u':
                opts->_skip_fetch = 1;
                break;
            case 'g':
                opts->_skip_generate = 1;
                break;
            case 'k':
                opts->_skip_hook = 1;
                break;
            default:
                panic("USAGE: %s [-ugk]\n"
                      "See /usr/share/doc/pacwall/README.rst for more info.",
                      argv[0]);
            }
        }
    }
}

static void config_lookup_escape(config_t *cfg, const char *path, const char **out) {
    const char *str = NULL;
    config_lookup_string(cfg, path, &str);
    if (str == NULL) {
        return;
    }

    char *tmp = strdup(str);
    for (char *cp = tmp; *cp; ++cp) {
        if (*cp == '"') {
            *cp = '\'';
        } else if (*cp == '\'') {
            *cp = '"';
        }
    }

    *out = tmp;
}

struct opts parse_opts(int argc, char **argv) {
    /*INDENT-OFF*/
    struct opts opts = {
        .hook = NULL,
        .shell = "bash",
        .db = "/var/lib/pacman",
        .attributes = {
            .graph = "bgcolor=\"#00000000\"",
            .package = {
                .common = "shape=point, height=0.1,"
                         "fontname=monospace, fontsize=10",
                .implicit = "color=\"#dc322faa\"",
                .explicit = "color=\"#268bd2aa\"",
                .orphan = "color=\"#2aa198aa\", peripheries=2,"
                         "fontcolor=\"#2aa198\", xlabel=\"\\N\",",
                .outdated = "color=\"#b58900aa\", peripheries=3,"
                           "fontcolor=\"#b58900\", xlabel=\"\\N\"",
                .repository = NULL
            },
            .dependency = {
                .common = "color=\"#fdf6e311\"",
                .hard = "",
                .optional = "arrowhead=empty, style=dashed",
            }
        },
        ._skip_fetch = 0,
        ._skip_generate = 0,
        ._skip_hook = 0
    };
    /*INDENT-ON*/

    config_t cfg;
    config_init(&cfg);

    chdir_xdg("XDG_CONFIG_HOME", ".config/", "pacwall");
    FILE *cfg_file = fopen("pacwall.conf", "r");
    if (cfg_file == NULL) {
        panic("Could not open pacwall.conf: %s\n"
              "Refer to /usr/share/doc/pacwall/README.rst for a configuration guide",
              strerror(errno));
    }
    if (!config_read(&cfg, cfg_file)) {
        panic("Malformed pacwall.conf (line %d): %s",
              config_error_line(&cfg),
              config_error_text(&cfg));
    }
    fclose(cfg_file);

#define READ_OPT(opt) config_lookup_escape(&cfg, #opt, &opts.opt)

    READ_OPT(hook);
    READ_OPT(shell);
    READ_OPT(db);
    READ_OPT(attributes.graph);
    READ_OPT(attributes.package.common);
    READ_OPT(attributes.package.implicit);
    READ_OPT(attributes.package.explicit);
    READ_OPT(attributes.package.orphan);
    READ_OPT(attributes.package.outdated);
    READ_OPT(attributes.dependency.common);
    READ_OPT(attributes.dependency.hard);
    READ_OPT(attributes.dependency.optional);

    config_setting_t *repository_group = config_lookup(&cfg,
                                         "attributes.package.repository");
    if (repository_group && config_setting_is_group(repository_group)) {
        unsigned i = 0;
        struct opt_list **opt = &opts.attributes.package.repository;
        config_setting_t *repository_entry;
        while ((repository_entry = config_setting_get_elem(repository_group, i++))) {
            *opt = malloc(sizeof(struct opt_list));
            (*opt)->key = strdup(config_setting_name(repository_entry));
            (*opt)->value = strdup(config_setting_get_string(repository_entry));
            opt = &(*opt)->next;
        }
    }

    config_destroy(&cfg);

    parse_cli_opts(&opts, argc, argv);

    return opts;
}
