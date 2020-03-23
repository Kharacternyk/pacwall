#!/bin/bash
set -e

# Pick colors.
# test if the wal folder (for pywal) exists
if test -f ~/.cache/wal/colors ; then
	echo "Pywal installed. Using Pywal settings."
	# change `n` in `head -n` to use the n-th terminal color set by pywal
	# you can preview these colors in ~/.cache/wal/colors.json
	BACKGROUND=$( echo "$(cat ~/.cache/wal/colors | head -1 | tail -1)" )
	echo "Background: " $BACKGROUND
	NODE=$( echo "$(cat ~/.cache/wal/colors | head -2 | tail -1)""88" )
	echo "Node: " $NODE
	ENODE=$( echo \""$(cat ~/.cache/wal/colors | head -3 | tail -1)""ff"\" )
	echo "Enode: " $ENODE
	EDGE=$( echo "$(cat ~/.cache/wal/colors | head -8 | tail -1)""44" )
	echo "Edge: " $EDGE
else
	echo "Using default colors."
	BACKGROUND=darkslategray
	NODE='#dc143c88'
	ENODE=darkorange
	EDGE='#ffffff44'
fi



echo 'Generating the graph.'

# Prepare the environment.
rm -rf /tmp/pacwall
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


#feh --bg-center --no-fehbg pacwall.png
hsetroot -solid $BACKGROUND -full pacwall.png

echo 'Done.'
