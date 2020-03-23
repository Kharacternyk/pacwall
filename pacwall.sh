#!/bin/bash
set -e

# Default colors.
BACKGROUND=darkslategray
NODE='#dc143c88'
ENODE=darkorange
EDGE='#ffffff44'
GSIZE=""

OUTPUT="pacwall.png"

STARTDIR="${PWD}"
WORKDIR=""

prepare() {
    WORKDIR="$(mktemp -d)"
    mkdir -p "${WORKDIR}/"{stripped,raw}
    touch "${WORKDIR}/pkgcolors"
    cd "${WORKDIR}"
}

cleanup() {
    cd "${STARTDIR}" && rm -rf "${WORKDIR}"
}

generate_graph() {
    # Get a space-separated list of the explicitly installed packages.
    EPKGS="$(pacman -Qeq | tr '\n' ' ')"
    for package in ${EPKGS}
    do

        # Mark each explicitly installed package using a distinct solid color.
        echo "\"$package\" [color=$ENODE]" >> pkgcolors

        # Extract the list of edges from the output of pactree.
        pactree -g "$package" > "raw/$package"
        sed -E \
            -e '/START/d' \
            -e '/^node/d' \
            -e '/\}/d' \
            -e '/arrowhead=none/d' \
            -e 's/\[.*\]//' \
            -e 's/>?=.*" ->/"->/' \
            -e 's/>?=.*"/"/' \
            "raw/$package" > "stripped/$package"

    done
}

compile_graph() {
    # Compile the file in DOT languge.
    # The graph is directed and strict (doesn't contain any edge duplicates).
    cd stripped
    echo 'strict digraph G {' > ../pacwall.gv
    cat ../pkgcolors ${EPKGS} >> ../pacwall.gv
    echo '}' >> ../pacwall.gv
    cd ..
}

render_graph() {
    # Style the graph according to preferences.
    declare -a twopi_args=(
        '-Tpng' 'pacwall.gv'
        "-Gbgcolor=${BACKGROUND}"
        "-Ecolor=${EDGE}"
        "-Ncolor=${NODE}"
        '-Nshape=point'
        '-Nheight=0.1'
        '-Nwidth=0.1'
        '-Earrowhead=normal'
    )

    # Optional arguments
    if [ -n "${GSIZE}" ]; then
        twopi_args+=("-Gsize=${GSIZE}")
    fi
    
    twopi "${twopi_args[@]}" > "${OUTPUT}"
}

resize_wallpaper() {
    # Use imagemagick to resize the image to the size of the screen.
    SCREEN_SIZE=$(xdpyinfo | grep dimensions | sed -r 's/^[^0-9]*([0-9]+x[0-9]+).*$/\1/')
    convert "${OUTPUT}" \
        -gravity center \
        -background "${BACKGROUND}" \
        -extent "${SCREEN_SIZE}" \
        "${OUTPUT}"    
}

set_wallpaper() {
    set +e
    gsettings set org.gnome.desktop.background picture-uri "${STARTDIR}/${OUTPUT}" \
        2> /dev/null && echo 'Set the wallpaper using gsettings.'
    feh --bg-center --no-fehbg "${STARTDIR}/${OUTPUT}" \
        2> /dev/null && echo 'Set the wallpaper using feh.'
    set -e
}

main() {
    echo 'Preparing the environment'
    prepare

    echo 'Generating the graph.'
    generate_graph

    echo 'Compiling the graph.'
    compile_graph

    echo 'Rendering it.'
    render_graph

    resize_wallpaper

    cp "${WORKDIR}/${OUTPUT}" "${STARTDIR}"

    set_wallpaper

    cleanup

    echo 'The image has been put into the current directory.'
    echo 'Done.'
}

help() {
    printf "%s\n\t%s\n\t%s\n\t%s\n\t%s\n\t%s\n\t%s\n" \
        "USAGE: $0" \
        "[ -b BACKGROUND ]" \
        "[ -d NODE_COLOR ]" \
        "[ -e EXPLICIT_NODE_COLOR ]" \
        "[ -s EDGE_COLOR ]" \
        "[ -g GSIZE ]" \
        "[ -o OUTPUT ]"
        exit 0
}

options=':b:d:s:e:g:o:h'
while getopts $options option
do
    case $option in
        b  ) BACKGROUND=${OPTARG};;
        d  ) NODE=${OPTARG};;
        e  ) ENODE=${OPTARG};;
        s  ) EDGE=${OPTARG};;
        g  ) GSIZE=${OPTARG};;
        o  ) OUTPUT=${OPTARG};;
        h  ) help;;
        \? ) echo "Unknown option: -${OPTARG}" >&2; exit 1;;
        :  ) echo "Missing option argument for -${OPTARG}" >&2; exit 1;;
        *  ) echo "Unimplemented option: -${OPTARG}" >&2; exit 1;;
    esac
done

shift $((OPTIND - 1))

main
