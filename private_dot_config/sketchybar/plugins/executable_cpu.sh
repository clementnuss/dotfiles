#!/usr/bin/env bash
CPU=$(top -l 1 -n 0 | awk '/CPU usage/ {gsub(/%/,""); print int($3 + $5)}')

if [ "$CPU" -ge 80 ]; then
    COLOR=0xffd20f39
elif [ "$CPU" -ge 50 ]; then
    COLOR=0xffdf8e1d
else
    COLOR=0xff40a02b
fi

sketchybar --set "$NAME" icon.color="$COLOR" label="${CPU}%"