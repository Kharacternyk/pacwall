#!/bin/bash

echo 'Generating the graph.'
pactree -gr glibc > /tmp/pkgtree-graph

sed \
    -e 's/\[color=.*\]//' \
    -e 's/^node.*$//' \
    /tmp/pkgtree-graph > /tmp/pkgtree-graph-stripped

echo 'Rendering it.'
dot -Tpng /tmp/pkgtree-colorized \
   > /tmp/pkgtree-image

echo 'Displaying it.'
feh /tmp/pkgtree-image

