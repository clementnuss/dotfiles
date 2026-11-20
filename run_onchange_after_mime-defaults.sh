#!/bin/sh
# mimeapps.list stays unmanaged: apps register their own URL handlers in it
set -eu
xdg-mime default net.code-industry.masterpdfeditor5.desktop application/pdf
