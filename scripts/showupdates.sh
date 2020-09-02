#!/bin/bash
set -e

ATTRIBUTES=${1:-""}
OUTPUT=${2:-/dev/stdout}
PACMANDB=${3:-/var/lib/pacman}
FAKEDB=${4:-/tmp/showupdates-fake-db}

# Create a fake db directory for pacman.
mkdir -p "$FAKEDB"

# Link local packages.
ln -s "$PACMANDB/local/" "$FAKEDB/" &> /dev/null || true

# Fetch fresh sync databases.
fakeroot -- pacman -Sy --dbpath "$FAKEDB" --logfile /dev/null &> /dev/null

# Show the updates.
cat /dev/null > "$OUTPUT"
for PKG in $(pacman -Qqu --dbpath "$FAKEDB"); do
    printf "\"%s\" [%s];\n" $PKG "$ATTRIBUTES" >> "$OUTPUT"
done
