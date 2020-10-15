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

static char *str_escape(char *str) {
    for (char *cp = str; *cp; ++cp) {
        if (*cp == '"') {
            *cp = '\'';
        } else if (*cp == '\'') {
            *cp = '"';
        }
    }
    return str;
}

static void config_lookup_escape(config_t *cfg, const char *path, const char **out) {
    const char *str = NULL;
    config_lookup_string(cfg, path, &str);
    if (str == NULL) {
        return;
    }

    *out = str_escape(strdup(str));
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
                .repository = {
                    .length = 0,
                    .entries = NULL
                }
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

    /* Parsing attributes.package.repository */
    config_setting_t *repository_group = config_lookup(&cfg,
                                         "attributes.package.repository");
    if (repository_group && config_setting_is_group(repository_group)) {
        size_t length = config_setting_length(repository_group);
        opts.attributes.package.repository.length = length;
        opts.attributes.package.repository.entries =
            calloc(sizeof opts.attributes.package.repository.entries[0], length);
        for (size_t i = 0; i < length; ++i) {
            config_setting_t *entry = config_setting_get_elem(repository_group, i);
            opts.attributes.package.repository.entries[i].name =
                strdup(config_setting_name(entry));
            opts.attributes.package.repository.entries[i].attributes =
                str_escape(strdup(config_setting_get_string(entry)));
        }
    } else {
        /* Set the defaults */
        opts.attributes.package.repository.length = 5;
        opts.attributes.package.repository.entries =
            calloc(sizeof opts.attributes.package.repository.entries[0], 5);
        opts.attributes.package.repository.entries[0].name = "core";
        opts.attributes.package.repository.entries[0].attributes = "";
        opts.attributes.package.repository.entries[1].name = "extra";
        opts.attributes.package.repository.entries[1].attributes = "";
        opts.attributes.package.repository.entries[2].name = "community";
        opts.attributes.package.repository.entries[2].attributes = "";
        opts.attributes.package.repository.entries[3].name = "multilib";
        opts.attributes.package.repository.entries[3].attributes = "";
        opts.attributes.package.repository.entries[4].name = "*";
        opts.attributes.package.repository.entries[4].attributes = "color=\"#859900aa\"";
    }

    config_destroy(&cfg);

    parse_cli_opts(&opts, argc, argv);

    return opts;
}
