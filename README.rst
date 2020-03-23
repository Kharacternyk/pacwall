.. image:: screenshot.png

``pacwall.sh`` is a shell script that changes your wallpaper to the dependency graph of installed by ``pacman`` packages. Each package is a node and each edge indicates a dependency between two packages. The explicitly installed packages have a distinct color (orange by default).

------------
Requirements
------------

.. code-block:: bash

    sudo pacman -Syu --needed imagemagick graphviz pacman-contrib feh

-------------
Customization
-------------

Any customizations should be performed by modifying the script itself. The code in the script is well-structured (should be). To discover the customization possibilities, read the man page of ``graphviz`` and ``twopi``, particularly the section on *GRAPH, NODE AND EDGE ATTRIBUTES*.

---------------
Troubleshooting
---------------

If the graph is too large, add a ``-Gsize`` flag to the ``twopi`` invocation, like here:

.. code-block:: bash

    twopi \
        -Gsize="7.5,7.5" \
        -Tpng pacwall.gv \
        -Gbgcolor=$BACKGROUND \
        -Ecolor=$EDGE\
        -Ncolor=$NODE \
        -Nshape=point \
        -Nheight=0.1 \
        -Nwidth=0.1 \
        -Earrowhead=normal \
        > pacwall.png

The flag forces the graph to be not wider nor higher than 7.5 **inches**.

An alternative method is to add a ``-Granksep`` flag. For example, ``-Granksep=0.3`` means that the distance between the concentric circles of the graph will be 0.3 inch.
