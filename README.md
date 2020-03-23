![screenshot](./screenshot.png)

`pacwall.sh` is a shell script that changes your wallpaper to the dependency graph of installed by pacman packages. Each package is a node and each edge indicates a dependency between two packages. The explicitly installed packages have a distinct color (orange by default).

## Changes in this fork
- parse [pywal](https://github.com/dylanaraps/pywal/) for color data
	- colors for nodes, etc can be exchanged for other colors exported by pywal
- feh removed, instead using hsetroot
	- hsetroot is more minimalistic (0.04MiB)
	- removes the dependency on imagemagic (9.72MiB)
	- removes the dependency on feh (0.17MiB)
	- removes the need to manually set SCREEN_SIZE

## Requirements
- graphviz
- pacman-contrib
- hsetroot
- pywal

`sudo pacman -S graphviz pacman-contrib hsetroot pywal`

## Customization
Any customizations should be performed by modifying the script itself. The code in the script is well-structured (should be). To discover the customization possibilities, read the man page of `graphviz` and `twopi`, particularly the section on GRAPH, NODE AND EDGE ATTRIBUTES.
