#!/usr/bin/env bash

~/.config/quickshell/ii/scripts/colors/applycolor.sh

for cmd in "$@"; do
    [[ -z "$cmd" ]] && continue
    eval "command -v ${cmd%% *}" >/dev/null 2>&1 || continue
    eval "$cmd" &
    exit
done
