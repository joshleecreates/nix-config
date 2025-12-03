#!/usr/bin/env python3
"""
Desktop notification script for upcoming Thunderbird calendar events
Sends notifications at 15 min, 5 min, and 1 min before events
"""

import sqlite3
import subprocess
from datetime import datetime, timedelta
from pathlib import Path

# Path to Thunderbird calendar cache
THUNDERBIRD_PROFILE = Path.home() / ".thunderbird" / "default"
CALENDAR_DB = THUNDERBIRD_PROFILE / "calendar-data" / "cache.sqlite"

# State file to track notified events
STATE_FILE = Path.home() / ".cache" / "calendar-notifications-state"

def send_notification(title, body, urgency="normal"):
    """Send desktop notification using notify-send"""
    try:
        subprocess.run([
            "notify-send",
            "--urgency", urgency,
            "--icon", "appointment-soon",
            "--app-name", "Calendar",
            title,
            body
        ], check=False)
    except Exception as e:
        print(f"Failed to send notification: {e}")

def get_notified_events():
    """Load set of already notified event IDs"""
    if not STATE_FILE.exists():
        STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
        return set()

    with open(STATE_FILE, 'r') as f:
        return set(line.strip() for line in f.readlines())

def mark_event_notified(event_id):
    """Mark an event as notified"""
    STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(STATE_FILE, 'a') as f:
        f.write(f"{event_id}\n")

def cleanup_old_notifications():
    """Remove old notification records (older than 24 hours)"""
    if not STATE_FILE.exists():
        return

    # For simplicity, just clear the file daily
    # In production, you'd want to parse and filter by timestamp
    mtime = datetime.fromtimestamp(STATE_FILE.stat().st_mtime)
    if datetime.now() - mtime > timedelta(days=1):
        STATE_FILE.unlink()

def get_upcoming_events():
    """Get events in the next 15 minutes that need notifications"""
    if not CALENDAR_DB.exists():
        return []

    try:
        conn = sqlite3.connect(f"file:{CALENDAR_DB}?mode=ro&immutable=1", uri=True, timeout=10.0)
        cursor = conn.cursor()

        now = datetime.now()
        now_unix = int(now.timestamp() * 1000000)

        # Look ahead 16 minutes to catch 15-minute warnings
        future_unix = int((now + timedelta(minutes=16)).timestamp() * 1000000)

        query = """
        SELECT
            id,
            title,
            event_start,
            event_end
        FROM cal_events
        WHERE event_start >= ? AND event_start <= ?
        AND (flags & 1) = 0
        ORDER BY event_start ASC
        """

        cursor.execute(query, (now_unix, future_unix))
        results = cursor.fetchall()
        conn.close()

        events = []
        for event_id, title, start_ts, end_ts in results:
            start_dt = datetime.fromtimestamp(start_ts / 1000000)
            end_dt = datetime.fromtimestamp(end_ts / 1000000) if end_ts else None

            events.append({
                'id': event_id,
                'title': title or "Untitled Event",
                'start': start_dt,
                'end': end_dt
            })

        return events

    except Exception as e:
        print(f"Error reading calendar: {e}")
        return []

def should_notify(event, notified_events):
    """Determine if we should send a notification for this event"""
    event_id = event['id']
    start_time = event['start']
    now = datetime.now()

    minutes_until = (start_time - now).total_seconds() / 60

    # Define notification thresholds
    thresholds = [15, 5, 1]

    for threshold in thresholds:
        notification_id = f"{event_id}_{threshold}min"

        if notification_id in notified_events:
            continue

        # Check if we're within the notification window
        if threshold - 0.5 <= minutes_until <= threshold + 0.5:
            return threshold, notification_id

    return None, None

def main():
    cleanup_old_notifications()
    notified_events = get_notified_events()
    upcoming_events = get_upcoming_events()

    for event in upcoming_events:
        threshold, notification_id = should_notify(event, notified_events)

        if threshold is not None:
            # Format notification
            start_time = event['start'].strftime("%H:%M")
            end_time = event['end'].strftime("%H:%M") if event['end'] else ""
            time_range = f"{start_time} - {end_time}" if end_time else start_time

            if threshold == 1:
                title = "Event starting in 1 minute!"
                urgency = "critical"
            elif threshold == 5:
                title = "Event starting in 5 minutes"
                urgency = "normal"
            else:  # 15 minutes
                title = "Event starting in 15 minutes"
                urgency = "normal"

            body = f"{event['title']}\n{time_range}"

            # Send notification
            send_notification(title, body, urgency)

            # Mark as notified
            mark_event_notified(notification_id)

if __name__ == "__main__":
    main()
