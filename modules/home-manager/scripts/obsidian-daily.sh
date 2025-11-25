#!/usr/bin/env bash
# Open today's daily note in Obsidian in a new window

VAULT_NAME="Altinity"
VAULT_PATH="$HOME/Documents/Obsidian/Altinity"
DAILY_DIR="Periodic/Daily"
DATE=$(date +%Y-%m-%d)
NOTE_PATH="$DAILY_DIR/$DATE.md"
FULL_PATH="$VAULT_PATH/$NOTE_PATH"

# Create the daily note if it doesn't exist
if [ ! -f "$FULL_PATH" ]; then
    mkdir -p "$VAULT_PATH/$DAILY_DIR"
    touch "$FULL_PATH"
fi

# Open in Obsidian - force new window with both URI parameter and CLI flag
obsidian --new-window "obsidian://open?vault=$VAULT_NAME&file=$NOTE_PATH&newpane=true"
