.. image:: screenshot.png

``pacwall.sh`` is a shell script that changes your wallpaper to the dependency graph of installed packages. Each package is a node and each edge indicates a dependency between two packages. The explicitly installed packages have a distinct color (orange by default). The dependencies of type *X provides Y* are represented as an edge with an inverted arrow that points towards *Y* (applies only to Arch).

.. contents:: Navigation:
   :backlinks: none

------------
Requirements
------------

~~~~~~~~~~
Arch Linux
~~~~~~~~~~

.. code-block:: bash

    sudo pacman -Syu --needed graphviz pacman-contrib

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Debian, Ubuntu, Mint, Pop!_OS, ...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

    sudo apt install graphviz

~~~~~~~~~~~~~~~~~~
Wallpaper backends
~~~~~~~~~~~~~~~~~~

* If you are on GNOME (Xorg), you also need ``imagemagick`` and ``xorg-xdpyinfo`` to set the wallpaper.

* If you are on GNOME (Wayland), you need ``imagemagick`` and to specify the screen size manually like this: ``./pacwall.sh -S 1920x1200``.

* If you aren't on GNOME, ``pacwall`` tries to set the wallpaper using ``feh`` and ``hsetroot``.

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
            [ -r RANKSEP ]
            [ -o OUTPUT ]
            [ -S SCREEN_SIZE ]

            Use -i to suppress wallpaper setting.
            All colors may be specified either as
            - a color name (black, darkorange, ...)
            - a value of format #RRGGBB
            - a value of format #RRGGBBAA

Additional customizations can be performed by modifying the script itself. The code in the script is well-structured (should be). To discover the customization possibilities, read the man page of ``graphviz`` and ``twopi``, particularly the section on *GRAPH, NODE AND EDGE ATTRIBUTES*.

---------------
Troubleshooting
---------------

If the graph is too large, use ``-r`` flag. For example, ``-r 0.3`` means that the distance between the concentric circles of the graph will be 0.3 **inch**.

An alternative method is to use ``-g`` flag. The format should be the same as the ``twopi`` ``-Gsize`` option. ``7.5,7.5`` for example forces the graph to be not wider nor higher than 7.5 **inches**.

