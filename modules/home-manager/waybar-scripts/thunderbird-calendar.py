#!/usr/bin/env python3
"""
Waybar module to display upcoming events from Thunderbird calendar
Reads from Thunderbird's SQLite calendar cache
"""

import sqlite3
import json
import sys
from datetime import datetime, timedelta
from pathlib import Path
import os
import subprocess

# Path to Thunderbird calendar cache
THUNDERBIRD_PROFILE = Path.home() / ".thunderbird" / "default"
CALENDAR_DB = THUNDERBIRD_PROFILE / "calendar-data" / "cache.sqlite"

def is_thunderbird_running():
    """Check if Thunderbird is currently running"""
    try:
        # Check for thunderbird process (on NixOS it's .thunderbird-wrapped)
        result = subprocess.run(
            ['pgrep', 'thunderbird'],
            capture_output=True,
            text=True
        )
        return result.returncode == 0
    except Exception:
        return False

def parse_ical_datetime(dt_str):
    """Parse iCalendar datetime string to Python datetime"""
    if not dt_str:
        return None

    # Try different datetime formats
    formats = [
        "%Y%m%dT%H%M%S",  # Basic format
        "%Y%m%dT%H%M%SZ",  # UTC format
    ]

    for fmt in formats:
        try:
            return datetime.strptime(dt_str, fmt)
        except ValueError:
            continue

    return None

def get_next_event():
    """Get the next upcoming event from Thunderbird calendar"""
    if not CALENDAR_DB.exists():
        return None

    try:
        # Open in read-only mode with immutable flag to avoid locking issues
        conn = sqlite3.connect(f"file:{CALENDAR_DB}?mode=ro&immutable=1", uri=True, timeout=10.0)
        cursor = conn.cursor()

        # Get current time in Unix timestamp (microseconds)
        now = datetime.now()
        now_unix = int(now.timestamp() * 1000000)

        # Query events from the next 24 hours
        # Thunderbird stores times in microseconds since epoch
        tomorrow_unix = int((now + timedelta(days=1)).timestamp() * 1000000)

        query = """
        SELECT
            title,
            event_start,
            event_end,
            event_start_tz,
            flags
        FROM cal_events
        WHERE event_start >= ? AND event_start <= ?
        AND (flags & 1) = 0
        ORDER BY event_start ASC
        LIMIT 1
        """

        cursor.execute(query, (now_unix, tomorrow_unix))
        result = cursor.fetchone()
        conn.close()

        if not result:
            return None

        title, start_ts, end_ts, tz, flags = result

        # Convert microseconds to seconds
        start_dt = datetime.fromtimestamp(start_ts / 1000000)
        end_dt = datetime.fromtimestamp(end_ts / 1000000) if end_ts else None

        return {
            'title': title,
            'start': start_dt,
            'end': end_dt
        }

    except Exception as e:
        print(json.dumps({
            "text": f"󰃭 Calendar Error",
            "tooltip": f"Error reading calendar: {str(e)}",
            "class": "error"
        }), file=sys.stderr)
        return None

def format_time_until(event_start):
    """Format time until event starts"""
    now = datetime.now()
    diff = (event_start - now).total_seconds()

    if diff < 0:
        return "Now", "happening-now", "󱎫"
    elif diff < 900:  # 15 minutes
        minutes = int(diff / 60)
        return f"{minutes}m", "soon", "󱎫"
    elif diff < 3600:  # 1 hour
        minutes = int(diff / 60)
        return f"{minutes}m", "upcoming", "󰃭"
    else:
        hours = int(diff / 3600)
        return f"{hours}h", "later", "󰃭"

def count_total_events():
    """Count total events in the next 24 hours"""
    if not CALENDAR_DB.exists():
        return 0

    try:
        conn = sqlite3.connect(f"file:{CALENDAR_DB}?mode=ro&immutable=1", uri=True, timeout=10.0)
        cursor = conn.cursor()

        now = datetime.now()
        now_unix = int(now.timestamp() * 1000000)
        tomorrow_unix = int((now + timedelta(days=1)).timestamp() * 1000000)

        query = """
        SELECT COUNT(*)
        FROM cal_events
        WHERE event_start >= ? AND event_start <= ?
        AND (flags & 1) = 0
        """

        cursor.execute(query, (now_unix, tomorrow_unix))
        count = cursor.fetchone()[0]
        conn.close()

        return count

    except Exception:
        return 0

def main():
    thunderbird_running = is_thunderbird_running()
    event = get_next_event()

    if not event:
        # Show warning if Thunderbird is not running
        if not thunderbird_running:
            output = {
                "text": " No events (Thunderbird not running)",
                "tooltip": "No upcoming events in the next 24 hours\\n\\n⚠ Thunderbird is not running - calendar data may be stale",
                "class": "warning"
            }
        else:
            output = {
                "text": "󰃭 No events",
                "tooltip": "No upcoming events in the next 24 hours",
                "class": "no-events"
            }
        print(json.dumps(output))
        return

    # Get time until event and status
    time_text, status_class, icon = format_time_until(event['start'])

    # If Thunderbird is not running, replace icon with warning
    if not thunderbird_running:
        icon = ""
        status_class = "warning"

    # Truncate title if too long
    title = event['title'] or "Untitled Event"
    max_length = 30
    if len(title) > max_length:
        short_title = title[:max_length] + "..."
    else:
        short_title = title

    # Build tooltip
    start_time = event['start'].strftime("%H:%M")
    end_time = event['end'].strftime("%H:%M") if event['end'] else "?"
    tooltip = f"{title}\\n{start_time} - {end_time}"

    # Add warning if Thunderbird is not running
    if not thunderbird_running:
        tooltip = f"⚠ Thunderbird not running - data may be stale\\n\\n{tooltip}"

    # Count total events
    total = count_total_events()
    if total > 1:
        tooltip += f"\\n\\n{total - 1} more event(s) today"

    # Output JSON for Waybar
    output = {
        "text": f"{icon} {time_text}: {short_title}",
        "tooltip": tooltip,
        "class": status_class
    }

    print(json.dumps(output))

if __name__ == "__main__":
    main()
