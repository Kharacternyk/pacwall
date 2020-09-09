#!/bin/bash
set -e

FAKEDB=$1
PACMANDB=$2

# Create a fake db directory for pacman.
mkdir -p "$FAKEDB/sync"

# Link local packages.
ln -s "$PACMANDB/local/" "$FAKEDB/" &> /dev/null || true

# Fetch fresh sync databases.
fakeroot -- pacman -Sy --dbpath "$FAKEDB" --logfile /dev/null &> /dev/null
