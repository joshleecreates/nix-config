#!/usr/bin/env bash

SAVE_DIR="$HOME/wallpapers"

# Create wallpapers directory if it doesn't exist
mkdir -p "$SAVE_DIR"

# Get current wallpaper from swww (grab first image path from any output)
CURRENT_WALLPAPER=$(swww query | grep -oP '(?<=image: ).*' | head -n 1)

if [ -z "$CURRENT_WALLPAPER" ]; then
    echo "Error: Could not determine current wallpaper. Is swww running?"
    exit 1
fi

# Check if file exists
if [ ! -f "$CURRENT_WALLPAPER" ]; then
    echo "Error: Wallpaper file not found: $CURRENT_WALLPAPER"
    exit 1
fi

# Get filename
FILENAME=$(basename "$CURRENT_WALLPAPER")

# Copy to wallpapers directory
cp "$CURRENT_WALLPAPER" "$SAVE_DIR/$FILENAME"

echo "Saved wallpaper to: $SAVE_DIR/$FILENAME"
