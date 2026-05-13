#!/usr/bin/env bash
PERCENTAGE=$(pmset -g batt | grep -Eo '[0-9]+%' | tr -d '%')
CHARGING=$(pmset -g batt | grep 'AC Power')

if [ -z "$PERCENTAGE" ]; then
    sketchybar --set "$NAME" icon="󱉝" label="?"
    exit 0
fi

if [ -n "$CHARGING" ]; then
    ICON="󰂄"
    COLOR=0xff40a02b
elif [ "$PERCENTAGE" -ge 80 ]; then
    ICON="󰁹" COLOR=0xff4c4f69
elif [ "$PERCENTAGE" -ge 60 ]; then
    ICON="󰂁" COLOR=0xff4c4f69
elif [ "$PERCENTAGE" -ge 40 ]; then
    ICON="󰁾" COLOR=0xffdf8e1d
elif [ "$PERCENTAGE" -ge 20 ]; then
    ICON="󰁼" COLOR=0xffd20f39
else
    ICON="󰁺" COLOR=0xffd20f39
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="${PERCENTAGE}%"