#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/repos/walls"

# Get a random wallpaper from the directory
if [ -d "$WALLPAPER_DIR" ]; then
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | shuf -n 1)

    if [ -n "$WALLPAPER" ]; then
        # Kill existing swaybg instances
        pkill swaybg

        # Start swaybg with the random wallpaper
        swaybg -i "$WALLPAPER" -m fill &
    fi
fi
