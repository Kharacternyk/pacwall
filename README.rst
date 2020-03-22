.. image:: screenshot.png

``pacwall.sh`` is a shell script that changes your wallpaper to the dependency graph of installed by ``pacman`` packages. Each package is a node and each edge indicates a dependency between two packages. The explicitly installed packages have a distinct color (orange by default).

------------
Requirements
------------

.. code-block:: bash

    sudo pacman -Syu --needed imagemagick graphviz pacman-contrib

-------------
Customization
-------------

Any customizations should be performed by modifying the script itself. The code in the script is well-structured (should be). To discover the customization possibilities, read the man page of ``graphviz`` and ``twopi``, particularly the section on *GRAPH, NODE AND EDGE ATTRIBUTES*.
