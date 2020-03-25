#!/bin/bash
set -e

# Default values.
BACKGROUND=darkslategray
NODE='#dc143c88'
ENODE=darkorange
EDGE='#ffffff44'
RANKSEP=1
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
        echo "\"$package\" [color=\"$ENODE\"]" >> pkgcolors

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
        "-Granksep=${RANKSEP}"
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

set_wallpaper() {
    set +e

    if [[ "$DESKTOP_SESSION" == *"gnome"* ]]; then
        if [[ -z "$SCREEN_SIZE" ]]; then
            SCREEN_SIZE=$(
                xdpyinfo | grep dimensions | sed -r 's/^[^0-9]*([0-9]+x[0-9]+).*$/\1/'
            )
        fi
        convert "${OUTPUT}" \
            -gravity center \
            -background "${BACKGROUND}" \
            -extent "${SCREEN_SIZE}" \
            "${STARTDIR}/${OUTPUT}"
            
        #Did this here because I think imagemagick stuff should run first?    
        copy_to_xdg
        #Change wallpaper
        gsettings set org.gnome.desktop.background picture-uri "${XDGOUT}"

        #Write xml so that file is recognised in gnome-control-center
        echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
        <!DOCTYPE wallpapers SYSTEM \"gnome-wp-list.dtd\">
        <wallpapers>
	        <wallpaper deleted=\"false\">
		           <name>pacwall${BACKGROUND}</name>
		           <filename>"${XDGOUT}"</filename>
	        </wallpaper>
        </wallpapers>" \
            > "${XDG_DATA_HOME}/gnome-background-properties/pacwall${BACKGROUND}.xml"


    else
    	copy_to_xdg
        hsetroot -solid $BACKGROUND -full "${XDGOUT}" \
            2> /dev/null && echo 'Set the wallpaper using hsetroot.'

        feh --bg-center --no-fehbg --image-bg "$BACKGROUND" "${XDGOUT}" \
            2> /dev/null && echo 'Set the wallpaper using feh.'
    fi

    set -e
}

copy_to_xdg()
{
        #Copy the output to $HOME/.local/share/wallpapers as it is a standard XDG Directory
        #This will make the wallpapers visible in KDE settings (and maybe WMs if they have a setting)
        mkdir -p "${XDG_DATA_HOME}/wallpapers/pacwall"
        cp "${STARTDIR}/${OUTPUT}" "${XDGOUT}"
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

    cp "${WORKDIR}/${OUTPUT}" "${STARTDIR}"

    if [[ -z "$IMAGE_ONLY" ]]; then
        set_wallpaper
    fi

    cleanup

    echo 'The image has been put into the current directory.'
    echo 'Done.'
}

help() {
    printf \
        "%s\n\t%s\n\t%s\n\t%s\n\t%s\n\t%s\n\t%s\n\t%s\n\t%s\n\n\t%s\n\t%s\n\t%s\n\t%s\n\t%s\n" \
        "USAGE: $0" \
        "[ -i ]" \
        "[ -b BACKGROUND ]" \
        "[ -d NODE_COLOR ]" \
        "[ -e EXPLICIT_NODE_COLOR ]" \
        "[ -s EDGE_COLOR ]" \
        "[ -g GSIZE ]" \
        "[ -r RANKSEP ]" \
        "[ -o OUTPUT ]" \
        "[ -S SCREEN_SIZE ]" \
        "Use -i to suppress wallpaper setting." \
        "All colors may be specified either as " \
        "- a color name (black, darkorange, ...)" \
        "- a value of format #RRGGBB" \
        "- a value of format #RRGGBBAA"
        exit 0
}

options='ib:d:s:e:g:r:o:S:h'
while getopts $options option
do
    case $option in
        i  ) IMAGE_ONLY=TRUE;;
        b  ) BACKGROUND=${OPTARG};;
        d  ) NODE=${OPTARG};;
        e  ) ENODE=${OPTARG};;
        s  ) EDGE=${OPTARG};;
        g  ) GSIZE=${OPTARG};;
        r  ) RANKSEP=${OPTARG};;
        o  ) OUTPUT=${OPTARG};;
        S  ) SCREEN_SIZE=${OPTARG};;
        h  ) help;;
        \? ) echo "Unknown option: -${OPTARG}" >&2; exit 1;;
        :  ) echo "Missing option argument for -${OPTARG}" >&2; exit 1;;
        *  ) echo "Unimplemented option: -${OPTARG}" >&2; exit 1;;
    esac
done
shift $((OPTIND - 1))

if [[ -z "$XDG_DATA_HOME" ]]; then
    XDG_DATA_HOME=~/.local/share
fi
XDGOUT="${XDG_DATA_HOME}/wallpapers/pacwall/pacwall${BACKGROUND}.png"

main
