#!/bin/bash
set -e

# Pick colors.
BACKGROUND=darkslategray
NODE='#dc143c88'
ENODE=darkorange
EDGE='#ffffff44'

STARTDIR="${PWD}"

OUTPUT="pacwall.png"

WORKDIR=""

# Prepare the environment.
prepare() {
    WORKDIR="$(mktemp -d)"
    mkdir -p "${WORKDIR}/"{stripped,raw}
    touch "${WORKDIR}/pkgcolors"
}

cleanup() {
    cd "${STARTDIR}" && rm -rf "${WORKDIR}"
}

generate_graph() {
    # Get a space-separated list of the explicitly installed packages.
    epkgs="$(pacman -Qeq | tr '\n' ' ')"
    for package in ${epkgs}
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
    cat ../pkgcolors ${epkgs} >> ../pacwall.gv
    echo '}' >> ../pacwall.gv
}

render_graph() {
    # Style the graph according to preferences.
    cd ..
    twopi \
        -Tpng pacwall.gv \
        -Gbgcolor="${BACKGROUND}" \
        -Ecolor="${EDGE}" \
        -Ncolor="${NODE}" \
        -Nshape=point \
        -Nheight=0.1 \
        -Nwidth=0.1 \
        -Earrowhead=normal \
        > pacwall.png
}

resize_wallpaper() {
    # Use imagemagick to resize the image to the size of the screen.
    SCREEN_SIZE=$(xdpyinfo | grep dimensions | sed -r 's/^[^0-9]*([0-9]+x[0-9]+).*$/\1/')
    convert pacwall.png \
        -gravity center \
        -background "${BACKGROUND}" \
        -extent "${SCREEN_SIZE}" \
        pacwall.png

    feh --bg-center --no-fehbg pacwall.png
    if [[ $DESKTOP_SESSION == *"gnome"* ]]; then
      gsettings set org.gnome.desktop.background picture-uri /tmp/pacwall/pacwall.png
    fi
}

main() {
    prepare

    cd "${WORKDIR}"

    echo 'Generating the graph.'
    generate_graph

    echo 'Compiling the graph.'
    compile_graph

    echo 'Rendering it.'
    render_graph

    echo 'Resizing the wallpaper.'
    resize_wallpaper

    cp "${WORKDIR}/${OUTPUT}" "${STARTDIR}"

    cleanup

    echo 'Done.'
}

main