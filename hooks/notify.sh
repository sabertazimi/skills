#!/usr/bin/env bash
# Claude Code notification hook script
# Reads event JSON from stdin and sends a desktop notification.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ICON="${SCRIPT_DIR}/claude.svg"

if ! command -v notify-send >/dev/null 2>&1; then
  exit 0
fi

input="$(cat)"

# Sanitize text to valid UTF-8 for notify-send
sanitize_utf8() {
  iconv -f UTF-8 -t UTF-8//IGNORE 2>/dev/null || cat
}

if command -v jq >/dev/null 2>&1; then
  event="$(echo "$input" | jq -r '.hook_event_name')"

  case "$event" in
  Stop)
    message="$(echo "$input" | jq -r '.last_assistant_message // "Task completed"' | head -c 200 | sanitize_utf8)"
    notify-send -i "$ICON" 'Claude Code' "$message"
    ;;
  Notification)
    message="$(echo "$input" | jq -r '.message // "Needs your input"' | head -c 200 | sanitize_utf8)"
    notify-send -i "$ICON" 'Claude Code' "$message"
    ;;
  *)
    message="$(echo "$input" | jq -r '.message // "Unknown event"' | head -c 200 | sanitize_utf8)"
    notify-send -i "$ICON" 'Claude Code' "$message"
    ;;
  esac
else
  # Fallback: detect event type without jq and use static messages
  if echo "$input" | grep -q '"Stop"'; then
    notify-send -i "$ICON" 'Claude Code' 'Task completed'
  else
    notify-send -i "$ICON" 'Claude Code' 'Needs your input'
  fi
fi
