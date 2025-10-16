#!/bin/bash

if grep -q closed /proc/acpi/button/lid/LID0/state; then
    hyprctl keyword monitor "eDP-1, disable"
else
    hyprctl keyword monitor "eDP-1, preferred, auto, 2"
fi
