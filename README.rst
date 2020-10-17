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

``pacwall`` doesn't know how to set a wallpaper by itself. Therefore, ``pacwall``
requires help in the form of shell commands. Such commands are called *hook*.
There are some example hooks for different setups, one of which you should copy to
your local config.

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

For some setups e.g. XFCE there are no example hooks. Furthermore, the example
hooks can have bugs. You can verify that ``pacwall`` itself works fine by examining
the image that it has generated at ``~/.cache/pacwall/pacwall.png``.

-----
Usage
-----

Run ``pacwall``.

The blue dots are manually (explicitly) installed packages, the red ones are
automatically (implicitly) installed packages. The green dots are packages not found
in the official non-testing repositories (e.g. from AUR). The outlined teal dots are
orphans, the outlined yellow dots are outdated packages. The dashed edges represent
optional dependencies, the normal edges represent strict (hard, direct) dependencies.
The appearance is customizable, see Customization_.

If you want the wallpaper to be persistent, run ``pacwall -ug`` in the init file
of DE or WM you use. ``pacwall -ug`` doesn't regenerate the wallpaper, it just sets
the most recent one.

If you want the wallpaper to be automatically updated when a package is
upgraded/removed/installed, run:

.. code-block:: bash

    systemctl --user enable pacwall-watch-packages.path

Note that this one runs ``pacwall -u`` i.e. the displayed set of available updates
can only shrink.

If you want the wallpaper to be refreshed each hour with the up-to-date set of
available updates displayed, run:

.. code-block:: bash

    systemctl --user enable pacwall-watch-updates.timer

If you use Sway, you must run ``systemctl --user import-environment SWAYLOCK``
by the time the systemd units are triggered. They will fail otherwise.

---
CLI
---

* ``-u``: do not attempt to add entries to the set of available updates

  This flag speed-ups ``pacwall``. It also puts off some load from the
  Arch mirrors, though the load is arguably minor.

* ``-g``: do not regenerate the graph

  This flag doesn't prevent from adding entries to the set of available updates, but
  the entries will not be visible until the graph is regenerated.

* ``-k``: do not run the hook

-------------
Customization
-------------

``~/.config/pacwall/pacwall.conf`` is used to configure ``pacwall``.
The file is in the `libconfig format`_. TL;DR:

.. code-block::

    # comment
    // comment

    setting: "value"
    # or
    setting = "value"; # semicolon is optional

    group: {
        setting: "value"
        another-group: {
            setting: "value"
            ...
        }
        ...
    }

    setting: "too-long" # consequtive strings are
             "-value"   # glued together, like in C

Note that you must use ``'`` in value strings wherever you would normally
use ``"`` and vice versa. This avoids tons of ugly escaped ``\"``.

~~~~~~~~~~~~~~~~
List of settings
~~~~~~~~~~~~~~~~

* ``hook`` (no default value)

  The shell commands that are executed after the graph has been generated.  The
  hook is expected to set the wallpaper. The path to the graph image is exported
  in the ``$W`` environmental variable.

* ``shell`` (default: ``bash``)

  The shell in which the commands specified in ``hook`` ought to be executed.

* ``db`` (default: ``/var/lib/pacman``)

  The path to the ``pacman`` packages database.

* ``attributes`` (group)

  The group that contains graphviz attributes, which modify the appearance
  of the graph, nodes and edges in various ways.  See the
  ``GRAPH, NODE AND EDGE ATTRIBUTES`` section in ``man twopi``. Beware that attributes
  specific to layouts other than ``twopi`` won't work.

  ``/usr/share/pacwall/examples/attributes/default`` contains the attributes
  that are identical to the hardcoded defaults. It may be easier for you
  to copy them to your ``pacwall.conf`` and then further modify instead
  of writing these settings from scratch. You can also try out the other
  examples in the directory.

  * ``graph`` (default: ``bgcolor='#00000000'``)

    The graph attributes (separated by semicolons).

  * ``package`` (group)

    * ``common`` (default: ``shape=point, height=0.1, fontname=monospace, fontsize=10``)

      The attributes that are applied to all packages (separated by commas).

    * ``implicit`` (default: ``color='#dc322faa'``)

      The attributes that are applied to implicitly (i.e. to satisfy dependencies of
      some other packages) installed packages (separated by commas).

    * ``explicit`` (default: ``color='#268bd2aa'``)

      The attributes that are applied to explicitly installed packages
      (separated by commas).

    * ``orphan``
      (default: ``color='#2aa198aa', fontcolor='#2aa198', peripheries=2, xlabel='\\N'``)

      The attributes that are applied to orphan packages (separated by commas).

    * ``outdated``
      (default: ``color='#b58900aa', fontcolor='#b58900', peripheries=3, xlabel='\\N'``)

      The attributes that are applied to outdated packages (separated by commas).

    * ``repository`` (group) (default::

             core: ""
             extra: ""
             community: ""
             multilib: ""
             *: "color='#859900aa'"
      )

      The group that maps attributes to packages based on the origin repositories.
      Settings in this group are in the form of ``repository: "comma-separated attributes"``

      Only one set of attributes from this group is applied to a package; if a package
      is present in more than one repository, the first (from top to bottom) set takes
      precedence.

      A special entry in the form of ``*: "comma-separated attributes"`` is supported.
      The attributes will be applied to packages that are not present in any of the
      specified repositories. This entry should come last.

  * ``dependency`` (group)

    * ``common`` (default: ``color='#fdf6e311``)

      The attributes that are applied to all dependencies (separated by commas).

    * ``hard`` (no default value)

      The attributes that are applied to hard (as opposed to optional) dependencies
      (separated by commas).

    * ``optional`` (default: ``arrowhead=empty, style=dashed``)

      The attributes that are applied to optional dependencies (separated by commas).

---------------
Tips and tricks
---------------

~~~~~
Pywal
~~~~~

Make use of `Pywal User Template Files`_ to integrate ``pacwall`` with pywal.
See `an example of such template here`_.

~~~~~~~~~~
Graph size
~~~~~~~~~~

Use the ``dpi`` graph attribute to scale the whole image.

Alternatively, change node size, font size and graph size separately via their
respective attributes. Use the ``ranksep`` graph attribute instead of ``size``.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Highlighting specific packages
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can use entries of form
``'package-name' [comma-separated-list-of-package-specific-attributes];``
in the ``attributes.graph`` setting to add attributes to a specific package.

-------------------
Migrating from v1.*
-------------------

``pacwall`` v2.* is written in C and is very different from the v1.* one, which is
a Bash script. Migrating should be straightforward, though, **unless** you don't
run an Arch-based distro. v2.* is ``pacman``-only and will likely remain such.

----------------
Similar software
----------------

* pacgraph_
* pacvis_

.. LINKS:
.. _AUR package: https://aur.archlinux.org/packages/pacwall-git/
.. _libconfig format: https://hyperrealm.github.io/libconfig/libconfig_manual.html#Configuration-Files
.. _Pywal User Template Files: https://github.com/dylanaraps/pywal/wiki/User-Template-Files
.. _an example of such template here: https://github.com/Kharacternyk/dotfiles/blob/master/.config/wal/templates/pacwall.conf
.. _pacgraph: http://kmkeen.com/pacgraph/
.. _pacvis: https://github.com/farseerfc/pacvis
