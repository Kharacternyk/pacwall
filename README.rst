.. image:: screenshot.png

``pacwall`` changes your wallpaper to the dependency graph of installed
by ``pacman`` packages. Each node is a package and each edge represents
a dependency between two packages. ``pacwall`` highlights outdated packages
and orphans. The highlighting is meaningful by default still customizable.

``pacwall`` is bundled with systemd units that provide functionality
such as triggering wallpaper regeneration on package
upgrade/removal/installation, as well as periodical regeneration,
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
    mkdir -p ~/.config/pacwall
    cp /usr/share/pacwall/examples/hook/gsettings ~/.config/pacwall/pacwall.conf

If you use Xorg sans GNOME, run:
    
.. code-block:: bash

    sudo pacman -S --needed hsetroot
    mkdir -p ~/.config/pacwall
    cp /usr/share/pacwall/examples/hook/hsetroot ~/.config/pacwall/pacwall.conf

If you use Sway, run:

.. code-block:: bash

    mkdir -p ~/.config/pacwall
    cp /usr/share/pacwall/examples/hook/swaymsg ~/.config/pacwall/pacwall.conf

-----
Usage
-----

Run ``pacwall``.

The blue dots are manually (explicitly) installed packages, the red ones are
automatically (implicitly) installed packages. The outlined teal dots are orphans,
the outlined yellow dots are outdated packages. The dashed edges represent optional
dependencies, the normal edges represent strict (hard, direct) dependencies. If
you don't like the default appearance, ``goto`` Customization_.

If you want the wallpaper to be persistent, run ``pacwall -ug`` in the init file
of DE or WM you use. ``pacwall -ug`` doesn't regenerate the wallpaper, it just sets
the most recent one.

If you want the wallpaper to be automatically updated when a package is
upgraded/removed/installed, run:

.. code-block:: bash

    systemctl --user enable pacwall-watch-packages.path

Note that this one runs ``pacwall -u`` i.e. doesn't fetch newly available updates.

If you want the wallpaper to fetch and show newly available updates each hour, run:

.. code-block:: bash

    systemctl --user enable pacwall-fetch-updates.timer

---
CLI
---

* ``-u``: do not fetch updates

  This flag considerably speed-ups ``pacwall``. It also puts off some load from the
  Arch mirrors, though the load is arguably minor. This flag doesn't prevent
  already fetched updates to be displayed.

* ``-g``: do not regenerate the graph

  Displaying newly fetched updates is also considered "regenerating the graph",
  which means that ``pacwall -g`` may fetch some new updates, but it doesn't display
  them anyway.

* ``-k``: do not run the hook

  See Hook_ for more info.

-------------
Customization
-------------

``~/.config/pacwall/pacwall.conf`` is used to configure ``pacwall``.
The file is in the `libconfig format`_. TL;DR:

.. code-block::

    # comment
    // comment

    key: "value"
    # or
    key = "value"; # semicolon is optional

    group: {
        key: "value"
        another-group: {
            key: "value"
            ...
        }
        ...
    }

    key: "too-long" # consequtive strings are
         "-value"   # glued together, like in C

Note that you should use ``'`` in value strings wherever you would normally
use ``"`` and vice versa. It has been done because ``"`` is needed far more often
and the value strings would be littered with ugly escaped ``\"`` otherwise.

~~~~
Hook
~~~~

``hook: "some shell commands"``

The hook is one or more shell commands that are executed after the graph
has been generated. The hook is expected to set the wallpaper. The path
to the graph image is exported in the ``$W`` environmental variable.

``/usr/share/pacwall/examples/hook`` contains some example hooks for different
setups, one of which you have copied to ``pacwall.conf`` in the Installation_
section.

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
