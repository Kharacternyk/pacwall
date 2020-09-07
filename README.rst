.. image:: screenshot.png

``pacwall`` changes your wallpaper to the dependency graph of installed
by ``pacman`` packages. Each node is a package and each edge represents
a dependency between two packages. ``pacwall`` highlights outdated packages
and orphans. The highlighting is meaningful by default still customizable.

``pacwall`` package also includes systemd units that provide functionality
such as triggering wallpaper regenerating on package
upgrade/removal/installation, as well as periodical regenerating,
which ensures that the displayed set of available updates is up-to-date.

.. contents:: Navigation:
   :backlinks: none

------------
Installation
------------

Install the ``pacwall-git`` `AUR package`_.

If you use GNOME, run:

.. code-block:: bash

    sudo pacman -S --needed imagemagick xorg-xdpyinfo
    cp /usr/share/pacwall/examples/hook/gsettings ~/.config/pacwall/pacwall.conf

If you use Xorg sans GNOME, run:
    
.. code-block:: bash

    sudo pacman -S --needed hsetroot
    cp /usr/share/pacwall/examples/hook/hsetroot ~/.config/pacwall/pacwall.conf

If you use Sway, run:

.. code-block:: bash

    cp /usr/share/pacwall/examples/hook/swaymsg ~/.config/pacwall/pacwall.conf

-----
Usage
-----

Run `pacwall`.

Blue dots are manually (explicitly) installed packages, red ones are automatically
(implicitly) installed packages. Outlined teal dots are orphans, outlined yellow
dots are outdated packages. Dashed edges represent optional dependencies, normal
edges represent strict (hard, direct) dependencies. If you don't like the default look,
``goto`` `Customization`_.

If you want the wallpaper to be persistent, run `pacwall-hook` in the init file
of DE or WM you use.

If you want the wallpaper to be automatically updated when a package is
upgraded/removed/installed, run:

.. code-block:: bash

    systemctl --user enable pacwall.path

If you want the wallpaper to be automatically updated each ~5 minutes, run:

.. code-block:: bash

    systemctl --user enable pacwall.timer

-------------
Customization
-------------

`~/.config/pacwall/pacwall.conf` is the configuration file in `libconfig format`_.

TODO

---------------
Tips and tricks
---------------

~~~~~
Pywal
~~~~~

TODO

~~~~~~~~~~
Graph size
~~~~~~~~~~

TODO

----------------
Similar software
----------------

* pacgraph_
* pacvis_

.. LINKS:
.. _AUR package: https://aur.archlinux.org/packages/pacwall-git/
.. _libconfig format: https://hyperrealm.github.io/libconfig/libconfig_manual.html#Configuration-Files
.. _pacgraph: http://kmkeen.com/pacgraph/
.. _pacvis: https://github.com/farseerfc/pacvis
