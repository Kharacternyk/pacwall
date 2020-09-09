#!/bin/bash
set -e

FAKEDB=$1
ATTRIBUTES=$2
OUTPUT=$3

# Show the updates.
cat /dev/null > "$OUTPUT"
for PKG in $(pacman -Qqu --dbpath "$FAKEDB"); do
    printf "\"%s\" [%s];\n" $PKG "$ATTRIBUTES" >> "$OUTPUT"
done
