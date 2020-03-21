#!/bin/bash

echo 'Generating the graph.'
pactree -gr glibc > /tmp/pkgtree-graph

sed \
    -e 's/\[color=.*\]//' \
    -e 's/START.*$//' \
    -e 's/^ .*$//' \
    /tmp/pkgtree-graph > /tmp/pkgtree-graph-stripped

echo 'Rendering it.'
twopi \
    -Tpng /tmp/pkgtree-graph-stripped \
    -Gbgcolor=darkred:darkblue \
    -Ecolor='#eeeeeeaa' \
    -Ncolor='#ffffffaa' \
    -Nshape=point \
    -Nheight=0.1 \
    -Nwidth=0.1 \
   > /tmp/pkgtree-image

echo 'Displaying it.'
feh /tmp/pkgtree-image

