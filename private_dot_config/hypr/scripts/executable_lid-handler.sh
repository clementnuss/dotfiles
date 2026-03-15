#!/bin/bash

if grep -q closed /proc/acpi/button/lid/LID0/state; then
    # Only disable internal display if external display is connected
    external_connected=$(hyprctl monitors -j | jq '[.[] | select(.name != "eDP-1")] | length')
    if [ "$external_connected" -gt 0 ]; then
        brightnessctl -s
        hyprctl keyword monitor "eDP-1, disable"
    fi
else
    # Only re-enable if the monitor is currently disabled
    is_disabled=$(hyprctl monitors -j | jq '[.[] | select(.name == "eDP-1")] | length == 0')
    if [ "$is_disabled" = "true" ]; then
        hyprctl keyword monitor "eDP-1, preferred, auto, 2"
        brightnessctl -r
    fi
fi
