#!/bin/bash
echo 'Generating the graph.'

# Prepare the environment.
mkdir -p /tmp/pacwall
cd /tmp/pacwall
mkdir -p stripped
mkdir -p raw
rm pkgcolors 2> /dev/null

# Get a space-separated list of the explicitly installed packages.
epkgs="$(pacman -Qeq | tr '\n' ' ')"
for package in $epkgs
do

    # Mark each explicitly installed package using a distinct solid color.
    echo "\"$package\" [color=orangered]" >> pkgcolors

    # Extract the list of edges from the output of pactree.
    pactree -g "$package" > "raw/$package"
    sed -E \
        -e 's/\[.*\]//' \
        -e 's/>?=.*" ->/"->/' \
        -e 's/>?=.*"/"/' \
        -e '/START/d' \
        -e '/^node/d' \
        -e '/\}/d' \
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
    -Gbgcolor=darkslategray \
    -Ecolor='#eeeeee55' \
    -Ncolor='#b0306099' \
    -Nshape=point \
    -Nheight=0.1 \
    -Nwidth=0.1 \
    -Earrowhead=normal \
    > pacwall.png

# Use imagemagick to resize the image to the size of the screen.
echo 'Displaying it.'
convert pacwall.png \
    -gravity center \
    -background darkslategray \
    -extent 1920x1280 \
    pacwall.png

feh --bg-center --no-fehbg pacwall.png
