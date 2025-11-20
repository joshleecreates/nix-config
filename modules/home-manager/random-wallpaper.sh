#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/repos/walls"
CACHE_DIR="$HOME/.cache/wallpapers/blurred"

# Create cache directory if it doesn't exist
mkdir -p "$CACHE_DIR"

# Get a random wallpaper from the directory
if [ -d "$WALLPAPER_DIR" ]; then
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | shuf -n 1)

    if [ -n "$WALLPAPER" ]; then
        # Get filename and create blurred version path
        FILENAME=$(basename "$WALLPAPER")
        BLURRED_WALLPAPER="$CACHE_DIR/blurred_$FILENAME"

        # Create blurred version if it doesn't exist
        if [ ! -f "$BLURRED_WALLPAPER" ]; then
            echo "Creating blurred version of $FILENAME..."
            magick "$WALLPAPER" -blur 0x20 "$BLURRED_WALLPAPER"
        fi

        # Wait for swww daemons to be ready (they're started by systemd)
        # Check default namespace
        for i in {1..10}; do
            if swww query &>/dev/null; then
                break
            fi
            sleep 0.5
        done

        # Check backdrop namespace
        for i in {1..10}; do
            if swww query -n backdrop &>/dev/null; then
                break
            fi
            sleep 0.5
        done

        # Set wallpaper for normal workspace (default namespace)
        swww img "$WALLPAPER" --transition-type none

        # Set wallpaper for overview backdrop (backdrop namespace)
        swww img -n backdrop "$BLURRED_WALLPAPER" --transition-type none

        echo "Wallpaper set: $FILENAME"
    fi
fi
