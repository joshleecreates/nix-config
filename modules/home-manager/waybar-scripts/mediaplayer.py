#!/usr/bin/env python3
import subprocess
import json
import sys

def get_player_status():
    try:
        # Get the player name
        player = subprocess.check_output(
            ["playerctl", "-l"],
            text=True
        ).strip().split('\n')[0]

        # Get status (playing, paused, stopped)
        status = subprocess.check_output(
            ["playerctl", "-p", player, "status"],
            text=True
        ).strip()

        if status not in ["Playing", "Paused"]:
            return None

        # Get metadata
        artist = subprocess.check_output(
            ["playerctl", "-p", player, "metadata", "artist"],
            text=True
        ).strip()

        title = subprocess.check_output(
            ["playerctl", "-p", player, "metadata", "title"],
            text=True
        ).strip()

        # Determine player class
        player_class = "spotify" if "spotify" in player.lower() else "default"

        # Format output
        if artist and title:
            text = f"{artist} - {title}"
        elif title:
            text = title
        else:
            text = ""

        # Truncate if too long
        if len(text) > 40:
            text = text[:37] + "..."

        output = {
            "text": text,
            "class": player_class,
            "alt": status.lower()
        }

        print(json.dumps(output))

    except subprocess.CalledProcessError:
        # No player found or not playing
        pass
    except Exception as e:
        print(json.dumps({"text": "", "class": "stopped"}), file=sys.stderr)

if __name__ == "__main__":
    get_player_status()
