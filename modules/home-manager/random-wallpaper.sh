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

        # Initialize swww daemon if not running (default namespace)
        if ! pgrep -x swww-daemon > /dev/null; then
            swww-daemon &
            sleep 1
        fi

        # Initialize swww daemon for backdrop namespace if not running
        if ! pgrep -f "swww-daemon.*backdrop" > /dev/null; then
            swww-daemon -n backdrop &
            sleep 1
        fi

        # Set wallpaper for normal workspace (default namespace)
        swww img "$WALLPAPER" --transition-type none

        # Set wallpaper for overview backdrop (backdrop namespace)
        swww img -n backdrop "$BLURRED_WALLPAPER" --transition-type none

        echo "Wallpaper set: $FILENAME"
    fi
fi
