#!/bin/bash

PID="$(pidof Xorg)"
[[ -n $PID ]] || exit 0
[[ $PID == 0 ]] && exit 0
sudo --user="$(ps -o user= -p $PID)" pacwall
