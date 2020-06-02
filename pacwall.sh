#!/bin/bash
BACKGROUND=#073642
EDGE=#fdf6e322
NODE=#dc322faa
ENODE=#268bd2aa
ONODE=#859900aa
FNODE=#d33682aa
UNODE=#b58900aa
VNODE=$EDGE

UFONT=#b58900ff
FONTNAME="monospace"
FONTSIZE=12.5

OOUTLINE=2
UOUTLINE=3
RANKSEP=0.7

OUTPUT="$PWD/pacwall.png"
STARTDIR="$PWD"

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
    OUTLINE=$3

    _PKGS="$(pacman -Qq$PACMAN_FLAGS)"
    for _PKG in $_PKGS; do
        echo "\"$_PKG\" [color=\"$COLOR\", peripheries=$OUTLINE]" >> pkgcolors
    done
}

generate_graph_pactree() {
    # Get a space-separated list of the "leaves".
    PKGS="$(pacman -Qq)"

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

    mark_pkgs "" $NODE 1

    # Mark each explicitly installed package using a distinct color.
    mark_pkgs e $ENODE 1

    # Mark each potential orphan using a distinct color.
    mark_pkgs ttd $ONODE $OOUTLINE

    # Mark each foreign package (AUR, etc) using a distinct color.
    mark_pkgs m $FNODE 1

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

    if [[ -z $NO_UPDATES ]]; then
        for package in $(checkupdates | sed -e "s/ .*$//"); do
            echo "\"$package\" [
                fontcolor=\"$UFONT\",
                fontsize=\"$FONTSIZE\",
                fontname=\"$FONTNAME\",
                xlabel=\"$package\",
                color=\"$UNODE\",
                peripheries=$UOUTLINE
            ]" >> pkgcolors
        done
    fi

    DEFAULT_NODE_COLOR=$VNODE
}

mark_pkgs_xbps() {
    XBPS_CMD=$1
    XBPS_FLAGS=$2
    COLOR=$3
    OUTLINE=$4

    _PKGS="$(xbps-$XBPS_CMD -$XBPS_FLAGS | sed -E -e 's/-[0-9].*$//')"
    for _PKG in $_PKGS; do
        echo "\"$_PKG\" [color=\"$COLOR\", peripheries=$OUTLINE]" >> pkgcolors
    done
}

generate_graph_xbps() {
    # Get all installed packages in a space separated list
    PKGS="$(xbps-query -l | sed -E -e 's/^.. (.*)-[0-9].*$/\1/')"

    for package in $PKGS; do
        touch stripped/$package
        echo "\"$package\" [color=\"$NODE\"]" >> pkgcolors
        DPKGS=$(xbps-query -x $package | sed -E -e 's/>?=.*//g')
        for dependency in $DPKGS; do
            echo "\"$package\" -> \"$dependency\";" >> stripped/$package
        done
    done

    # Mark manually installed packages
    mark_pkgs_xbps query m $ENODE 1

    # Mark orphaned packages
    mark_pkgs_xbps query O $ONODE $OOUTLINE

    # Mark outdated packages
    [[ -z $NO_UPDATES ]] && mark_pkgs_xbps install nuM $UNODE $UOUTLINE

    DEFAULT_NODE_COLOR=$NODE
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
    if [[ ! -f ~/.cache/wal/colors.sh ]]; then
        echo 'Run pywal first' >&2
        exit 1
    fi

    source ~/.cache/wal/colors.sh
    echo 'Using pywal colors:'

    # change `n` in `head -n` to use the n-th terminal color set by pywal
    # you can preview these colors in ~/.cache/wal/colors.json
    BACKGROUND=$background
    EDGE=${foreground}22
    NODE=${color1}aa
    ONODE=${color2}aa
    UNODE=${color3}aa
    UFONT=${color3}ff
    ENODE=${color4}aa
    FNODE=${color5}aa
    VNODE=$EDGE

    echo "    Background:    ${BACKGROUND}ff"
    echo "    Edge:          $EDGE"
    echo "    Node:          $NODE"
    echo "    Explicit node: $ENODE"
    echo "    Orphan node:   $ONODE"
    echo "    Foreign node:  $FNODE"
    echo "    Outdated node: $UNODE"
    echo "    Outdated font: $UFONT"
    echo "    Virtual node:  $VNODE"
}

render_graph() {
    # Style the graph according to preferences.
    declare -a twopi_args=(
        '-Tpng' 'pacwall.gv'
        "-Gbgcolor=${BACKGROUND}"
        "-Granksep=${RANKSEP}"
        "-Ecolor=${EDGE}"
        "-Ncolor=${DEFAULT_NODE_COLOR}"
        '-Nshape=point'
        '-Nheight=0.1'
        '-Nwidth=0.1'
        '-Earrowhead=normal'
    )

    # Optional arguments
    [[ -n $ROOT ]] && twopi_args+=("-Groot=${ROOT}")

    twopi "${twopi_args[@]}" > pacwall.png
}

set_wallpaper() {
    set +e

    if [[ -n $DE_INTEGRATION ]]; then
        if [[ -z $SCREEN_SIZE ]]; then
            SCREEN_SIZE=$(
                xdpyinfo | grep dimensions | sed -r 's/^[^0-9]*([0-9]+x[0-9]+).*$/\1/'
            )
        fi
        convert pacwall.png \
            -gravity center \
            -background "${BACKGROUND}" \
            -extent "${SCREEN_SIZE}" \
            "${OUTPUT}"
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
        hsetroot -solid "$BACKGROUND" -full "${OUTPUT}" \
            2> /dev/null && echo 'Using hsetroot to set the wallpaper'

        feh --bg-center --no-fehbg --image-bg "$BACKGROUND" "${OUTPUT}" \
            2> /dev/null && echo 'Using feh to set the wallpaper'
    fi

    set -e
}

copy_to_xdg() {
    #Copy the output to $HOME/.local/share/wallpapers as it is a standard XDG Directory
    #This will make the wallpapers visible in KDE settings (and maybe WMs if they have a setting)
    mkdir -p "${XDG_DATA_HOME}/wallpapers/pacwall"
    cp "${OUTPUT}" "${XDGOUT}"
}

main() {
    prepare

    if [[ -n $PYWAL_INTEGRATION ]]; then
        use_wal_colors
    fi

    if [[ -z $VOID ]]; then
        echo 'Using pactree to generate the graph'
        generate_graph_pactree "$@"
    else
        echo 'Using xbps to generate the graph'
        generate_graph_xbps
    fi

    compile_graph

    render_graph

    cp "${WORKDIR}/pacwall.png" "${OUTPUT}"

    if [[ -z $IMAGE_ONLY ]]; then
        set_wallpaper
    fi

    cleanup

    echo "The image has been put to ${OUTPUT}"
}

help() {
    echo "USAGE: $0
        [ -iDWUV ]
        [ -b BACKGROUND_COLOR ]
        [ -s EDGE_COLOR ]
        [ -d NODE_COLOR ]
        [ -e EXPLICIT_NODE_COLOR ]
        [ -p ORPHAN_NODE_COLOR ]
        [ -f FOREIGN_NODE_COLOR ]
        [ -u OUTDATED_NODE_COLOR ]
        [ -y VIRTUAL_NODE_COLOR ]
        [ -x ORPHAN_NODE_OUTLINE ]
        [ -z OUTDATED_NODE_OUTLINE ]
        [ -c ROOT ]
        [ -r RANKSEP ]
        [ -o OUTPUT ]
        [ -S SCREEN_SIZE ]
        [ REPO:COLOR ... ]
        [ GROUP%COLOR ... ]
        [ PACKAGE@COLOR ... ]

        Use -i to suppress wallpaper setting.
        Use -D to enable integration with desktop environments.
        Use -W to enable pywal integration.
        Use -U to disable highlighting of outdated packages.
        Use -V if you are on VOID LINUX (EXPERIMENTAL, SOME FEATURES DON'T WORK)

        All colors may be specified either as
        - a color name (black, darkorange, ...)
        - a value of format #RRGGBB
        - a value of format #RRGGBBAA

        If OUTLINE value is bigger than 1, then OUTLINE-1 additional circles are drawn
        around the corresponding packages.

        ROOT is the package that will be put in the center of the graph.
        RANKSEP is the distance in **inches** between the concentric circles.
        OUTPUT is the path where the generated image is put.
        SCREEN_SIZE makes sense to set only if -D is enabled and you're on Wayland.

        REPO:COLOR overrides the highlight color for packages from REPO to COLOR.
        GROUP%COLOR overrides the highlight color for packages from GROUP to COLOR.
        PACKAGE@COLOR overrides the highlight color for PACKAGE to COLOR.
        "

    exit 0
}

options='hiDWUVb:s:d:e:p:f:y:x:z:u:c:r:o:S:'
while getopts $options option; do
    case $option in
        h) help ;;
        i) IMAGE_ONLY=TRUE ;;
        D) DE_INTEGRATION=TRUE ;;
        W) PYWAL_INTEGRATION=TRUE ;;
        U) NO_UPDATES=TRUE ;;
        V) VOID=TRUE ;;
        b) BACKGROUND=${OPTARG} ;;
        s) EDGE=${OPTARG} ;;
        d) NODE=${OPTARG} ;;
        e) ENODE=${OPTARG} ;;
        p) ONODE=${OPTARG} ;;
        f) FNODE=${OPTARG} ;;
        u) UNODE=${OPTARG} ;;
        y) VNODE=${OPTARG} ;;
        x) OOUTLINE=${OPTARG} ;;
        z) UOUTLINE=${OPTARG} ;;
        c) ROOT=${OPTARG} ;;
        r) RANKSEP=${OPTARG} ;;
        o) OUTPUT=${OPTARG} ;;
        S) SCREEN_SIZE=${OPTARG} ;;
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
