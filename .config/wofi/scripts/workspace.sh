#!/bin/bash

current_addr=$(hyprctl activewindow -j | jq -r '.address')
current_ws=$(hyprctl activeworkspace -j | jq -r '.id')

# Build list: visible label + hidden metadata after ::: delimiter
windows=$(hyprctl clients -j | jq -r '.[] | "\(.workspace.id) | \(.class) | \(.title) :::\(.address)"' | sort -n -k1,1)

# Show only before delimiter in wofi
choice=$(echo "$windows" | sed 's/ :::.*//' | wofi --dmenu --prompt "Switch to:")

[ -z "$choice" ] && exit 0

# Extract the corresponding line with metadata
line=$(echo "$windows" | grep -F "$choice")

workspace=$(echo "$line" | cut -d ' ' -f1)
address=$(echo "$line" | sed 's/.*::://')

# Otherwise switch + focus
hyprctl dispatch workspace "$workspace"
hyprctl dispatch focuswindow "address:$address"
