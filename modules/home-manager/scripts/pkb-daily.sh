#!/usr/bin/env bash
# Open today's PKB daily note in Neovim, inside a new Ghostty window.
set -euo pipefail

VAULT_PATH="$HOME/Documents/Obsidian/PKB"
DAILY_DIR="04 Periodic/Daily"
TEMPLATE="$VAULT_PATH/00 Meta/Templates/Daily.md"

DATE=$(date +%Y-%m-%d)
NOTE_REL="$DAILY_DIR/$DATE.md"
FULL_PATH="$VAULT_PATH/$NOTE_REL"

# Seed the note from the Obsidian template if it doesn't exist yet.
if [ ! -f "$FULL_PATH" ]; then
    mkdir -p "$VAULT_PATH/$DAILY_DIR"
    WEEK=$(date +%G-W%V)                       # e.g. 2026-W29
    TITLE=$(date '+%A, %B %-d, %Y')            # e.g. Tuesday, July 14, 2026
    if [ -f "$TEMPLATE" ]; then
        sed -e "s/{{date:gggg-\[W\]WW}}/$WEEK/g" \
            -e "s/{{date:dddd, MMMM D, YYYY}}/$TITLE/g" \
            "$TEMPLATE" > "$FULL_PATH"
    else
        printf '# %s\n' "$TITLE" > "$FULL_PATH"
    fi
fi

# Launch a new Ghostty window rooted in the vault, editing the note in Neovim.
exec ghostty --working-directory="$VAULT_PATH" -e nvim "$NOTE_REL"
