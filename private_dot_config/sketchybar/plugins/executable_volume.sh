#!/usr/bin/env bash
VOLUME=$(osascript -e 'output volume of (get volume settings)')
MUTED=$(osascript -e 'output muted of (get volume settings)')

if [ "$MUTED" = "true" ] || [ "$VOLUME" = "0" ]; then
    ICON="󰝟"
    COLOR=0xff7c7f93
elif [ "$VOLUME" -lt 34 ]; then
    ICON="󰕿"
    COLOR=0xff4c4f69
elif [ "$VOLUME" -lt 67 ]; then
    ICON="󰖀"
    COLOR=0xff4c4f69
else
    ICON="󰕾"
    COLOR=0xff4c4f69
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="${VOLUME}%"