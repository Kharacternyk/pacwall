.. image:: screenshot.png

``pacwall`` changes your wallpaper to the dependency graph of installed
with ``pacman`` packages. Each node is a package and each edge represents
a dependency between two packages. ``pacwall`` highlights outdated packages,
orphans, and packages with `.pacnew files`_. The highlighting is customizable.

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

If you use KDE Plasma, run:

.. code-block:: bash

    mkdir -p ~/.config/pacwall
    cp /usr/share/pacwall/examples/hook/plasmash ~/.config/pacwall/pacwall.conf

If you use Xorg sans GNOME/KDE, run:

.. code-block:: bash

    sudo pacman -S --needed hsetroot
    mkdir -p ~/.config/pacwall
    cp /usr/share/pacwall/examples/hook/hsetroot ~/.config/pacwall/pacwall.conf

If you use Sway, run:

.. code-block:: bash

    mkdir -p ~/.config/pacwall
    cp /usr/share/pacwall/examples/hook/swaymsg ~/.config/pacwall/pacwall.conf

For some setups, e.g. XFCE, there are no example hooks. Furthermore, the example
hooks can have bugs. You can verify that ``pacwall`` itself works fine by examining
the image that it has generated at ``~/.cache/pacwall/pacwall.png``.

If you use the standard ``hsetroot`` hook along with a ``systemd`` unit listed
below, you may notice that the package graph disappears if the unit triggers
while your screen is turned off (typically due to DPMS timeout). This can be
fixed by using the ``/usr/share/pacwall/examples/hook/hsetroot-dpms`` hook
instead of the plain ``hsetroot`` one. However, on multi-display systems, this
may cause undesired stretching of the graph over multiple screens.

-----
Usage
-----

Run ``pacwall``.

The circles represent packages, where the area of a circle is proportional to the
size of the package.
The blue circles are manually (explicitly) installed packages, the red ones are
automatically (implicitly) installed packages. The green circles are packages not found
in the official non-testing repositories (e.g. from the AUR). The outlined teal circles
are orphans, the outlined yellow circles are outdated packages. The outlined magenta
circles are packages with unresolved `.pacnew files`_ (it's time to run ``pacdiff``).
The dashed edges represent optional dependencies, the normal edges represent strict
(hard, direct) dependencies. The appearance is customizable, see Customization_.

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
    setting: "foo"
    group: {
        nestedSetting: "bar"
        nestedGroup: {
            nestedNestedSetting: "baz"
        }
    }
    longSetting: "A sequence of strings "
                 "is concatenated into "
                 "one, like in C."

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
  of the graph, nodes, and edges in various ways. See the
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

      The attributes that are applied to packages installed to satisfy some dependencies
      and not directly required anymore (separated by commas).

    * ``unneeded`` (no default value)

      The attributes that are applied to orphan packages that are not optionally
      required either (separated by commas).

    * ``outdated``
      (default: ``color='#b58900aa', fontcolor='#b58900', peripheries=3, xlabel='\\N'``)

      The attributes that are applied to outdated packages (separated by commas).

    * ``unresolved``
      (default: ``color='#d33682aa', fontcolor='#d33682', peripheries=4, xlabel='\\N'``)

      The attributes that are applied to packages with `.pacnew files`_
      (separated by commas).

      These files are `better to deal with immediately`_.

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

    * ``common`` (default: ``color='#fdf6e30a'``)

      The attributes that are applied to all dependencies (separated by commas).

    * ``hard`` (no default value)

      The attributes that are applied to hard (as opposed to optional) dependencies
      (separated by commas).

    * ``optional`` (default: ``arrowhead=empty, style=dashed``)

      The attributes that are applied to optional dependencies (separated by commas).

* ``features`` (group)

  The group that contains settings that control optional features.

  * ``installed-size`` (group) (default::

        enabled: true
        delta: 2e-5
    )

    The group that contains settings that control the installed size representation
    feature. If ``enabled`` is true, the ``height`` and ``width`` attributes of nodes
    are overwritten so that the area covered by a node is proportional to the size of
    the installed package. The formula is::

        width in inches = height in inches = (installed size in bytes)^(1/2) * delta

    Note that values of these settings are not strings and omit the quotes enclosing
    them.

---------------
Tips and tricks
---------------

~~~~~~~~~~~~~~~~
Background image
~~~~~~~~~~~~~~~~

============
Via hsetroot
============

If ``hsetroot`` is used as the wallpaper setter, use the built-in multilayer feature, e.g.:

.. code-block:: bash

    hook: "hsetroot -fill '/path/to/background' -center '$W' > /dev/null"

===============
Via imagemagick
===============

Use the ``convert`` command, e.g.:

.. code-block:: bash

    hook: "convert '/path/to/background.png' '$W' -gravity center -compose over -composite '$W';"
          "…"

The ``imagemagick`` package is required.

~~~~~
Pywal
~~~~~

Make use of `Pywal User Template Files`_ to integrate ``pacwall`` with pywal.
See `an example of such template here`_.

~~~~~~~~~~
Graph size
~~~~~~~~~~

Use the ``dpi`` graph attribute to scale the whole image.

Alternatively, change node size, font size, and graph size separately via their
respective attributes. Use the ``ranksep`` graph attribute instead of ``size``.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Highlighting specific packages
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Entries of the form
``'package-name' [comma-separated-list-of-attributes];``
in the ``attributes.graph`` setting add attributes to a specific package.

~~~~~~~~~
Web-graph
~~~~~~~~~

If you want nice web-graph like on the following image:

.. image:: https://imgur.com/Qc1KiIp.png

Then create the following config:

.. code-block ::

    hook: "convert ~/.cache/pacwall/pacwall.png -resize 1920x1200! ~/.cache/pacwall/pacwall-fit.png"

    attributes: {
        graph: "bgcolor='#16161D' ratio=0.58 overlap=false",
        package: {
            common: "shape=point, height=0.02, fontname='Roboto Sans', fontsize=11",
        },
        dependency: {
            common: "color='#fdf6e30a', arrowhead='dot', arrowsize=0.6, penwidth=0.6"
            optional: "color='#fdf6e0f', penwidth=0.4"
        }
    }

Here the most important component is ``overlap=false`` which renders web graph instead
of defalut circled. Also important is ``ratio=0.58`` which you should calculate by
dividing screen height per screen width. And not less important are colors with
transparency as well as thin edge styles otherwise arrows would be too bold.

Depends on ``convert`` from ``imagemagick`` to resize image because graph generated with
``overlap=false`` is too large by default.

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
.. _.pacnew files: https://wiki.archlinux.org/index.php/Pacman/Pacnew_and_Pacsave
.. _AUR package: https://aur.archlinux.org/packages/pacwall-git/
.. _libconfig format: https://hyperrealm.github.io/libconfig/libconfig_manual.html#Configuration-Files
.. _better to deal with immediately: https://www.reddit.com/r/archlinux/comments/iczyr0/psa_be_careful_with_pacnew_when_updating/
.. _Pywal User Template Files: https://github.com/dylanaraps/pywal/wiki/User-Template-Files
.. _an example of such template here: https://github.com/Kharacternyk/dotfiles/blob/master/.config/wal/templates/pacwall.conf
.. _pacgraph: http://kmkeen.com/pacgraph/
.. _pacvis: https://github.com/farseerfc/pacvis
