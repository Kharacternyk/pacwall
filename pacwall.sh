#!/bin/bash
set -e

# Default values.
BACKGROUND=darkslategray
NODE='#dc143c88'
VNODE='#9400d388'
ENODE=darkorange
ONODE=magenta
FNODE='#1793d1'
EDGE='#ffffff44'
ROOT=""
RANKSEP=0.7
GSIZE=""
OUTPUT="pacwall.png"
STARTDIR="${PWD}"

prepare() {
    WORKDIR="$(mktemp -d)"
    mkdir -p "${WORKDIR}/"{stripped,raw}
    touch "${WORKDIR}/pkgcolors"
    cd "${WORKDIR}"
}

cleanup() {
    cd "${STARTDIR}" && rm -rf "${WORKDIR}"
}

mark_pkgs() {
    PACMAN_FLAGS=$1
    COLOR=$2
    set +e
    _PKGS="$(pacman -Qq$PACMAN_FLAGS)"
    set -e
    for _PKG in $_PKGS; do
        echo "\"$_PKG\" [color=\"$COLOR\"]" >> pkgcolors
    done
}

generate_graph_pactree() {
    # Get a space-separated list of the "leaves".
    PKGS="$(pacman -Qttq)"
    for package in $PKGS; do
        # Extract the list of edges from the output of pactree.
        pactree -g "$package" > "raw/$package"
        sed -E \
            -e '/START/d' \
            -e '/^node/d' \
            -e '/\}/d' \
            -e 's/\[arrowhead=none,.*\]/\[arrowhead=crow\]/' \
            -e 's/\[color=.*\]//' \
            -e 's/>?=.*" ->/!" ->/' \
            -e 's/>?=.*"/!"/' \
            "raw/$package" > "stripped/$package"
    done

    mark_pkgs "" $NODE

    # Mark each potential orphan using a distinct color.
    mark_pkgs ttd $ONODE

    # Mark each explicitly installed package using a distinct color.
    mark_pkgs e $ENODE

    # Mark each foreign package (AUR, etc) using a distinct color.
    mark_pkgs m $FNODE

    for arg in "$@"; do
        if [[ $arg =~ ^(.+)@(.+)$ ]]; then
            package="${BASH_REMATCH[1]}"
            COLOR="${BASH_REMATCH[2]}"
            echo "\"$package\" [color=\"$COLOR\"]" >> pkgcolors
        elif [[ $arg =~ ^(.+)%(.+)$ ]]; then
            GROUP="${BASH_REMATCH[1]}"
            COLOR="${BASH_REMATCH[2]}"
            RPKGS="$(pacman -Qqg $GROUP)"
            for package in $RPKGS; do
                # Mark each package from in GROUP using a distinct color.
                echo "\"$package\" [color=\"$COLOR\"]" >> pkgcolors
            done
        elif [[ $arg =~ ^(.+):(.+)$ ]]; then
            REPOS="${BASH_REMATCH[1]}"
            COLOR="${BASH_REMATCH[2]}"
            RPKGS="$(paclist $REPOS | sed -e 's/ .*$//')"
            for package in $RPKGS; do
                # Mark each package from REPOS using a distinct color.
                echo "\"$package\" [color=\"$COLOR\"]" >> pkgcolors
            done
        fi
    done
}

generate_graph_apt() {
    PKGS="$(apt list --installed 2> /dev/null | sed -e 's/\/.*$//')"
    apt-cache dotty $PKGS > raw/packages
    sed -E \
        -e '/^[^"]/d' \
        -e '/\[shape/d' \
        -e '/\[color=/d' \
        -e 's/\[.*\]//' \
        "raw/packages" > "stripped/packages"

    EPKGS="$(apt-mark showmanual)"
    for package in $EPKGS; do
        # Mark each explicitly installed package using a distinct color.
        echo "\"$package\" [color=\"$ENODE\"]" >> pkgcolors
    done

    PKGS=packages
}

compile_graph() {
    # Compile the file in DOT languge.
    # The graph is directed and strict (doesn't contain any edge duplicates).
    cd stripped
    echo 'strict digraph G {' > ../pacwall.gv
    cat ../pkgcolors ${PKGS} >> ../pacwall.gv
    echo '}' >> ../pacwall.gv
    cd ..
}

use_wal_colors() {
    if [[ ! -f ~/.cache/wal/colors ]]; then
        echo 'Run pywal first'
        exit 1
    fi

    echo 'Using pywal colors:'

    # change `n` in `head -n` to use the n-th terminal color set by pywal
    # you can preview these colors in ~/.cache/wal/colors.json
    BACKGROUND="$(head < ~/.cache/wal/colors -1 | tail -1)"
    NODE="$(head < ~/.cache/wal/colors -2 | tail -1)88"
    ENODE="$(head < ~/.cache/wal/colors -3 | tail -1)"
    ONODE="$(head < ~/.cache/wal/colors -6 | tail -1)"
    FNODE="$(head < ~/.cache/wal/colors -7 | tail -1)"
    VNODE="$(head < ~/.cache/wal/colors -5 | tail -1)88"
    EDGE="$(head < ~/.cache/wal/colors -8 | tail -1)44"

    echo "    Background:    $BACKGROUND"
    echo "    Node:          $NODE"
    echo "    Explicit node: $ENODE"
    echo "    Orphan node:   $ONODE"
    echo "    Foreign node:  $FNODE"
    echo "    Virtual node:  $VNODE"
    echo "    Edge:          $EDGE"
}

render_graph() {
    # Style the graph according to preferences.
    declare -a twopi_args=(
        '-Tpng' 'pacwall.gv'
        "-Gbgcolor=${BACKGROUND}"
        "-Granksep=${RANKSEP}"
        "-Ecolor=${EDGE}"
        "-Ncolor=${VNODE}"
        '-Nshape=point'
        '-Nheight=0.1'
        '-Nwidth=0.1'
        '-Earrowhead=normal'
    )

    # Optional arguments
    [[ -n $GSIZE ]] && twopi_args+=("-Gsize=${GSIZE}")
    [[ -n $ROOT ]] && twopi_args+=("-Groot=${ROOT}")

    twopi "${twopi_args[@]}" > "${OUTPUT}"
}

set_wallpaper() {
    set +e

    if [[ -n $DE_INTEGRATION ]]; then
        if [[ -z $SCREEN_SIZE ]]; then
            SCREEN_SIZE=$(
                xdpyinfo | grep dimensions | sed -r 's/^[^0-9]*([0-9]+x[0-9]+).*$/\1/'
            )
        fi
        convert "${OUTPUT}" \
            -gravity center \
            -background "${BACKGROUND}" \
            -extent "${SCREEN_SIZE}" \
            "${STARTDIR}/${OUTPUT}"
        copy_to_xdg

        #Write xml so that file is recognised in gnome-control-center
        mkdir -p "${XDG_DATA_HOME}/gnome-background-properties"
        echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
        <!DOCTYPE wallpapers SYSTEM \"gnome-wp-list.dtd\">
        <wallpapers>
	        <wallpaper deleted=\"false\">
		           <name>pacwall${BACKGROUND}</name>
		           <filename>${XDGOUT}</filename>
	        </wallpaper>
        </wallpapers>" \
            > "${XDG_DATA_HOME}/gnome-background-properties/pacwall${BACKGROUND}.xml"

        hsetroot -solid "$BACKGROUND"-full "${XDGOUT}" \
            2> /dev/null && echo 'Using hsetroot to set the wallpaper'

        feh --bg-center --no-fehbg --image-bg "$BACKGROUND" "${XDGOUT}" \
            2> /dev/null && echo 'Using feh to set the wallpaper'

        gsettings set org.gnome.desktop.background picture-uri "${XDGOUT}" \
            2> /dev/null && echo 'Using gsettings to set the wallpaper'

    else
        hsetroot -solid "$BACKGROUND" -full "${STARTDIR}/${OUTPUT}" \
            2> /dev/null && echo 'Using hsetroot to set the wallpaper'

        feh --bg-center --no-fehbg --image-bg "$BACKGROUND" "${STARTDIR}/${OUTPUT}" \
            2> /dev/null && echo 'Using feh to set the wallpaper'
    fi

    set -e
}

copy_to_xdg() {
    #Copy the output to $HOME/.local/share/wallpapers as it is a standard XDG Directory
    #This will make the wallpapers visible in KDE settings (and maybe WMs if they have a setting)
    mkdir -p "${XDG_DATA_HOME}/wallpapers/pacwall"
    cp "${STARTDIR}/${OUTPUT}" "${XDGOUT}"
}

main() {
    prepare

    if [[ -n $PYWAL_INTEGRATION ]]; then
        use_wal_colors
    fi

    if command -v apt > /dev/null; then
        echo 'Using apt to generate the graph'
        generate_graph_apt
    elif command -v pactree > /dev/null; then
        echo 'Using pactree to generate the graph'
        generate_graph_pactree "$@"
    else
        echo "Can't find pactree or debtree." >&2
        exit 1
    fi

    compile_graph

    render_graph

    cp "${WORKDIR}/${OUTPUT}" "${STARTDIR}"

    if [[ -z $IMAGE_ONLY ]]; then
        set_wallpaper
    fi

    cleanup

    echo "The image has been put to ${STARTDIR}/${OUTPUT}"
}

help() {
    echo "USAGE: $0
        [ -iDW ]
        [ -b BACKGROUND_COLOR ]
        [ -d NODE_COLOR ]
        [ -e EXPLICIT_NODE_COLOR ]
        [ -p ORPHAN_NODE_COLOR ]
        [ -f FOREIGN_NODE_COLOR ]
        [ -y VIRTUAL_NODE_COLOR ]
        [ -s EDGE_COLOR ]
        [ -c ROOT ]
        [ -r RANKSEP ]
        [ -g GSIZE ]
        [ -o OUTPUT ]
        [ -S SCREEN_SIZE ]
        [ REPO:COLOR ... ]
        [ GROUP%COLOR ... ]
        [ PACKAGE@COLOR ... ]

        Use -i to suppress wallpaper setting.
        Use -D to enable integration with desktop environments.
        Use -W to enable pywal integration.

        All colors may be specified either as
        - a color name (black, darkorange, ...)
        - a value of format #RRGGBB
        - a value of format #RRGGBBAA

        ROOT is the package that will be put in the center of the graph.
        RANKSEP is the distance in **inches** between the concentric circles.
        GSIZE is deprecated, you probably want to set RANKSEP instead.
        OUTPUT is the relative to CWD path of the generated image.
        SCREEN_SIZE makes sense to set only if -D is enabled and you're on Wayland.

        REPO:COLOR overrides the highlight color for packages from REPO to COLOR.
        GROUP%COLOR overrides the highlight color for packages from GROUP to COLOR.
        PACKAGE@COLOR overrides the highlight color for PACKAGE to COLOR.
        "

    exit 0
}

options='WDib:d:s:e:p:g:r:c:o:f:y:S:h'
while getopts $options option; do
    case $option in
        W) PYWAL_INTEGRATION=TRUE ;;
        D) DE_INTEGRATION=TRUE ;;
        i) IMAGE_ONLY=TRUE ;;
        b) BACKGROUND=${OPTARG} ;;
        d) NODE=${OPTARG} ;;
        e) ENODE=${OPTARG} ;;
        p) ONODE=${OPTARG} ;;
        f) FNODE=${OPTARG} ;;
        y) VNODE=${OPTARG} ;;
        s) EDGE=${OPTARG} ;;
        c) ROOT=${OPTARG} ;;
        r) RANKSEP=${OPTARG} ;;
        g) GSIZE=${OPTARG} ;;
        o) OUTPUT=${OPTARG} ;;
        S) SCREEN_SIZE=${OPTARG} ;;
        h) help ;;
        \?)
            echo "Unknown option: -${OPTARG}" >&2
            exit 1
            ;;
        :)
            echo "Missing option argument for -${OPTARG}" >&2
            exit 1
            ;;
        *)
            echo "Unimplemented option: -${OPTARG}" >&2
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

if [[ -z $XDG_DATA_HOME ]]; then
    XDG_DATA_HOME=~/.local/share
fi
XDGOUT="${XDG_DATA_HOME}/wallpapers/pacwall/pacwall${BACKGROUND}.png"

main "$@"
