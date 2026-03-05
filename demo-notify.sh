#!/bin/bash
# Demo notification sequence for Omarchy Glass

sleep 1
notify-send "Omarchy Glass" "Frosted glass theme applied successfully"
sleep 3
notify-send "System Update" "Your system is up to date — all packages current"
sleep 3
notify-send "Screenshot copied & saved" "~/Pictures/screenshot-$(date +%H%M%S).png"
