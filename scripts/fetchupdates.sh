#!/bin/bash
set -e

FAKEDB=$1
PACMANDB=$2

# Complain if db.lck exists.
[[ -f $FAKEDB/db.lck ]] &&
printf "%s\n%s\n" \
       "Looks like pacwall is already running." \
       "If you are sure that it isn't the case, delete $PWD/$FAKEDB/db.lck"

# Create a fake db directory for pacman.
mkdir -p "$FAKEDB/sync"

# Link local packages.
ln -s "$PACMANDB/local/" "$FAKEDB/" &> /dev/null || true

# Copy the system db in case it's newer.
cp -u --preserve=timestamps "$PACMANDB/sync/"*.db "$FAKEDB/sync/"

# Fetch fresh sync databases.
fakeroot -- pacman -Sy --dbpath "$FAKEDB" --logfile /dev/null &> /dev/null
