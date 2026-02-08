#!/bin/bash

# Path: /home/kev/.config/hypr/monitor_toggle.sh

INTERNAL_MONITOR="eDP-1"
EXTERNAL_MONITOR_DESC="AOC 2795E CZNC8JA000097"
#OGFILE="/tmp/monitor_setup.log"

toggle_internal_monitor() {
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

  # Check if external monitor is connected
  if ! hyprctl monitors all | grep -q "$EXTERNAL_MONITOR_DESC"; then
    echo "$TIMESTAMP - No external monitor detected. Doing nothing." #>> "$LOGFILE"
    notify-send "Monitor toggle" "No external monitor connected — cannot toggle."
    exit 0
  fi

  # Get current disabled state (true/false)
  INTERNAL_DISABLED=$(hyprctl monitors all | awk -v mon="$INTERNAL_MONITOR" '
    $0 ~ mon" " {in_block=1}
    in_block && /disabled:/ {print $2; exit}
  ')

  if [ "$INTERNAL_DISABLED" = "false" ]; then
    echo "$TIMESTAMP - External connected, disabling internal ($INTERNAL_MONITOR)..." #>> "$LOGFILE"
    hyprctl keyword monitor "$INTERNAL_MONITOR, disable"
    hyprctl keyword monitor "desc:$EXTERNAL_MONITOR_DESC, preferred, auto, 1"
    notify-send "Monitor toggle" "Internal monitor disabled"
  else
    echo "$TIMESTAMP - External connected, enabling internal ($INTERNAL_MONITOR)..." #>> "$LOGFILE"
    hyprctl keyword monitor "$INTERNAL_MONITOR, preferred, auto, 1"
    notify-send "Monitor toggle" "Internal monitor enabled"
  fi
}

toggle_internal_monitor
