.. image:: screenshot.png

``pacwall.sh`` is a shell script that changes your wallpaper to the dependency graph of installed packages. Each package is a node and each edge indicates a dependency between two packages. The explicitly installed packages have a distinct color (orange by default). The dependencies of type *X provides Y* are represented as an edge with an inverted arrow that points towards *Y* (applies only to Arch).

An `AUR package`_ is available.

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

``pacwall`` tries to set the wallpaper using ``feh`` and ``hsetroot``.

-------------------------------
Desktop environment integration
-------------------------------

Use `-D` to enable desktop environment integration (KDE Plasma, GNOME, ...). You will be able to see the generated wallpapers in the graphical wallpaper picker.

DE integration requires ``imagemagick`` and ``xorg-xdpyinfo`` (If you are on Wayland you need to specify the screen size manually like this: ``./pacwall.sh -S 1920x1200``).

**WARNING**: Setting a wallpaper in GNOME and the derivatives isn't possible with ``feh`` and ``hsetroot``. ``-D`` is required.
(If you don't know your DE, it is probably GNOME)

-----------------
Pywal integration
-----------------

Run ``./pacwall.sh -W`` to use colors set by pywal (1st, 2nd, 3rd and 8th color to be exact).

-------------
Customization
-------------

Customizations can be made on the commandline, see the options with the ``-h`` flag.

.. code-block:: bash

    USAGE: pacwall.sh
            [ -iDW ]
            [ -b BACKGROUND ]
            [ -d NODE_COLOR ]
            [ -e EXPLICIT_NODE_COLOR ]
            [ -s EDGE_COLOR ]
            [ -g GSIZE ]
            [ -r RANKSEP ]
            [ -o OUTPUT ]
            [ -S SCREEN_SIZE ]

            Use -W to enable pywal integration.
            Use -D to enable integration with desktop environments.
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

------------
Contributors
------------

* `Nazar Vinnichuk`_: the original author and maintainer;
* `ChiDal`_: integration with GNOME and other DEs, first ever rice_ with pacwall;
* `John Ramsden`_: PKGBUILD, cmdopts parsing, general code quality;
* `Luca Leon Happel`_: pywal integration, ``hsetroot`` backend;
* `Ruijie Yu`_: PKGBUILD;
* `QWxleA`_: screen size autodetection via ``xdpyinfo``;

----------------
Similar software
----------------

* pacgraph_
* pacvis_

.. LINKS:
.. _AUR package: https://aur.archlinux.org/packages/pacwall-git/
.. _Nazar Vinnichuk: https://github.com/Kharacternyk
.. _ChiDal: https://github.com/ChiDal
.. _John Ramsden: https://github.com/johnramsden
.. _Luca Leon Happel: https://github.com/Quoteme
.. _Ruijie Yu: https://github.com/RuijieYu
.. _QwxleA: https://github.com/QWxleA
.. _rice: https://www.reddit.com/r/unixporn/comments/fnfujo/gnome_first_rice_pacwall/ 
.. _pacgraph: http://kmkeen.com/pacgraph/
.. _pacvis: https://github.com/farseerfc/pacvis
