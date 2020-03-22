.. image:: screenshot.png

``pacwall.sh`` is a shell script that changes your wallpaper to the dependency graph of installed by pacman packages.

------------
Requirements
------------

.. code-block:: bash

    sudo pacman -Syu --needed imagemagick graphviz pacman-contrib

-------------
Customization
-------------

Any customizations should be performed by modifying the script itself. The code in the script is well-structured (should be). To discover the customization possibilities, read the man page of ``graphviz`` and ``twopi``, particularly the section on *GRAPH, NODE AND EDGE ATTRIBUTES*.
