#!/bin/bash
set -e

# Change this to the right value for your screen.
SCREEN_SIZE=$(xdpyinfo | grep dimensions | sed -r 's/^[^0-9]*([0-9]+x[0-9]+).*$/\1/')

# Pick colors.
BACKGROUND=darkslategray
NODE='#dc143c88'
ENODE=darkorange
EDGE='#ffffff44'

echo 'Generating the graph.'

# Prepare the environment.
mkdir -p /tmp/pacwall
cd /tmp/pacwall
mkdir -p stripped
mkdir -p raw
cat /dev/null > /tmp/pkgcolors

# Get a space-separated list of the explicitly installed packages.
epkgs="$(pacman -Qeq | tr '\n' ' ')"
for package in $epkgs
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

# Compile the file in DOT languge.
# The graph is directed and strict (doesn't contain any edge duplicates).
cd stripped
echo 'strict digraph G {' > ../pacwall.gv
cat ../pkgcolors $epkgs >> ../pacwall.gv
echo '}' >> ../pacwall.gv

# Style the graph according to preferences.
echo 'Rendering it.'
cd ..
twopi \
    -Tpng pacwall.gv \
    -Gbgcolor=$BACKGROUND \
    -Ecolor=$EDGE\
    -Ncolor=$NODE \
    -Nshape=point \
    -Nheight=0.1 \
    -Nwidth=0.1 \
    -Earrowhead=normal \
    > pacwall.png

# Use imagemagick to resize the image to the size of the screen.
echo 'Changing the wallpaper.'
convert pacwall.png \
    -gravity center \
    -background $BACKGROUND \
    -extent $SCREEN_SIZE \
    pacwall.png

feh --bg-center --no-fehbg pacwall.png

echo 'Done.'
