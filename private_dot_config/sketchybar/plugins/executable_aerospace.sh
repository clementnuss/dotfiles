#!/usr/bin/env bash
# $1 = workspace ID this item represents
# $2 = this workspace's accent color
# $FOCUSED_WORKSPACE = set by the aerospace_workspace_change trigger

COLOR="${2:-0xff4c4f69}"

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set "$NAME" \
        background.drawing=on    \
        background.color=$COLOR  \
        label.color=0xffeff1f5
else
    sketchybar --set "$NAME" \
        background.drawing=off   \
        label.color=$COLOR
fi