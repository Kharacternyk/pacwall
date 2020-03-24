.. image:: screenshot.png

``pacwall.sh`` is a shell script that changes your wallpaper to the dependency graph of installed by ``pacman`` packages. Each package is a node and each edge indicates a dependency between two packages. The explicitly installed packages have a distinct color (orange by default).

------------
Requirements
------------

.. code-block:: bash

    sudo pacman -Syu --needed imagemagick graphviz pacman-contrib feh xorg-xdpyinfo

-------------
Customization
-------------

Customizations can be made on the commandline, see the options with the ``-h`` flag.

.. code-block:: bash

    USAGE: pacwall.sh
            [ -i ]
            [ -b BACKGROUND ]
            [ -d NODE_COLOR ]
            [ -e EXPLICIT_NODE_COLOR ]
            [ -s EDGE_COLOR ]
            [ -g GSIZE ]
            [ -o OUTPUT ]

            Use -i to suppress wallpaper setting.
            All colors may be specified either as
            - a color name (black, darkorange, ...)
            - a value of format #RRGGBB
            - a value of format #RRGGBBAA

Additional customizations can be performed by modifying the script itself. The code in the script is well-structured (should be). To discover the customization possibilities, read the man page of ``graphviz`` and ``twopi``, particularly the section on *GRAPH, NODE AND EDGE ATTRIBUTES*.

---------------
Troubleshooting
---------------

If the graph is too large, use the ``-g`` flag. The format should be the same as the ``twopi`` ``-Gsize`` option.

``7.5,7.5`` for example forces the graph to be not wider nor higher than 7.5 **inches**.

An alternative method is to add a ``-Granksep`` flag. For example, ``-Granksep=0.3`` means that the distance between the concentric circles of the graph will be 0.3 inch.
